require_relative "tile"
require "byebug"

class Board
  attr_reader :grid

  def initialize(size = 10)
    @size = size
    @grid = generate_grid
  end

  def generate_grid
    Array.new (@size) {
      Array.new(@size) {nil}
    }
  end

  def random_seed(size = 10)
    (0...size).to_a.sample
  end

  def populate_grid
    @grid.each do |row|
      row.map! do |el|
        random_seed == 0 ? Tile.new(:bomb) : Tile.new(:empty)
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

  def adj_bombs(row, col)
    adj_rows = grid_intersect((row-1..row+1).to_a)
    adj_cols = grid_intersect((col-1..col+1).to_a)
    adj_coords = adj_rows.product(adj_cols).delete([row, col])

    tiles = grid_select(adj_coords)
    tiles.count { |tile| tile.value == :bomb}
  end

  def count_bombs
    @grid.flatten.count { |el| el.value == :bomb }
  end

  def cheat
    @grid.each do |row|
      row.each do |tile|
        tile.revealed = true
      end
    end
  end

  def render
    # debugger
    @grid.each do |row|
      output = []
      row.each do |tile|
        if tile.revealed
          tile.value == :bomb ? output << "B" : output << tile.value
        else
          output << "_"
        end
      end
      puts output.join("")
    end
  end

end