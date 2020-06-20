require_relative "tile"
require "byebug"

class Board
  attr_reader :grid

  def initialize(size = 10)
    @size = size
    @grid = populate(blank_grid)
    include_adj
  end

  def blank_grid
    Array.new (@size) {
      Array.new(@size) {nil}
    }
  end

  def random_seed(size = 10)
    (0...size).to_a.sample
  end

  def populate(grid)
    grid.each do |row|
      row.map! do |el|
        random_seed == 0 ? Tile.new(:bomb) : Tile.new(:empty)
      end
    end
  end

  def include_adj
    indices = (0...@size).to_a
    coords = indices.product(indices)
    coords.each do |coord|
      row, col = coord
      tile = self[row, col]
      if tile.value == :empty
        tile.value = adj_bombs(row, col)
      end 
    end
  end

  def [](row, col)
    @grid[row][col]
  end

  def grid_intersect(arr_of_indices)
    # arr is expected to be a one-dimensional array
    # which could represent a subset of the row/column
    # indices of @grid
    # 
    # this method returns only those indices
    # that are within the range to be indices for
    # a row/column of @grid
    arr_of_indices.intersection((0...@size).to_a)
  end

  def grid_select(arr_of_coords)
    # returns the tiles of @grid which are at the given coords
    tiles = []
    arr_of_coords.each do |coords|
      row, col = coords
      tiles << self[row, col]
    end
    tiles
  end

  def coords_adj_tiles(pos)
    row, col = pos
    adj_rows = grid_intersect((row-1..row+1).to_a)
    adj_cols = grid_intersect((col-1..col+1).to_a)
    adj_coords = adj_rows.product(adj_cols)
    # strictly adjacent
    adj_coords.delete([row, col])
    
    adj_coords
  end

  def adj_bombs(row, col)
    pos = row, col
    adj_coords = coords_adj_tiles(pos)
    tiles = grid_select(adj_coords)
    tiles.count { |tile| tile.value == :bomb}
  end

  def count_bombs
    @grid.flatten.count { |el| el.value == :bomb }
  end

  def reveal_all
    @grid.each do |row|
      row.each { |tile| tile.reveal }
    end
  end

  def hide_all
    @grid.each do |row|
      row.each { |tile| tile.hide }
    end
  end

  def hline
    " -"*@size + " "
  end

  def render
    # debugger
    puts hline
    @grid.each do |row|
      output = []
      row.each do |tile|
        if tile.revealed && tile.value != 0
          tile.value == :bomb ? output << "B" : output << tile.value
        else
          output << " "
        end
      end
      puts "|" + output.join("|") + "|"
      puts hline
    end
  end

  def cascade_prep(pos)
    to_cascade = []
    adj_coords = coords_adj_tiles(pos)
    adj_coords.each do |pos|
      row, col = pos
      tile = self[row, col]
      tile.reveal if (tile.value).is_a?(Integer)
      to_cascade << pos if tile.value == 0
    end

    to_cascade
  end

  def cascade(pos)
    @to_cascade = [pos]
    @already_cascaded = []

    @to_cascade.each do |el|
      next if @already_cascaded.include?(el)
      adj_emptys = cascade_prep(el)
      @to_cascade += adj_emptys
      @already_cascaded << el
    end

  end

end