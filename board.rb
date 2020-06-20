require_relative "tile"
require "byebug"

class Board

  def initialize(size = 10, difficulty = 1)
    @size = size
    @difficulty = difficulty
    @coords = generate_coords
    @grid = populate(blank_grid)
    include_adj
  end

  def generate_coords
    indices = (0...@size).to_a
    coords = indices.product(indices)
  end

  def blank_grid
    Array.new (@size) {
      Array.new(@size) {nil}
    }
  end

  def random_seed
    @coords.sample(@size*@difficulty)
  end

  # TODO inputs should be all (row, col) or all pos = [row, col]
  def [](row, col)
    @grid[row][col]
  end

  def populate(grid)
    @bomb_locations = random_seed
    @coords.each do |pos|
      row, col = pos
      grid[row][col] = (@bomb_locations.include?(pos) ? Tile.new(:bomb) : Tile.new(:empty))
    end
    grid
  end

  def include_adj
    @coords.each do |pos|
      row, col = pos
      tile = self[row, col]
      if tile.value == :empty
        tile.value = adj_bombs(pos)
      end 
    end
  end

  def adj_bombs(pos)
    adj_coords = coords_adj_tiles(pos)
    tiles = grid_select(adj_coords)
    output = tiles.count { |tile| tile.value == :bomb}
  end

  def coords_adj_tiles(pos)
    row, col = pos
    adj_rows = grid_intersect((row-1..row+1).to_a)
    adj_cols = grid_intersect((col-1..col+1).to_a)
    adj_coords = adj_rows.product(adj_cols)

    adj_coords
  end

  def grid_intersect(arr_of_indices)
    arr_of_indices.intersection((0...@size).to_a)
  end

  def grid_select(arr_of_coords)
    tiles = []
    arr_of_coords.each do |coords|
      row, col = coords
      tiles << self[row, col]
    end
    tiles
  end

  def count_bombs
    @grid.flatten.count { |el| el.value == :bomb }
  end

  def count_hidden_squares
    @grid.flatten.count { |el| el.revealed == false }
  end
  
  def cheat
    @bomb_locations.each do |pos|
      row, col = pos
      tile = self[row, col]
      tile.reveal
    end
    # self.render
  end

  # TODO delete?
  def reveal_all
    @grid.each do |row|
      row.each { |tile| tile.reveal }
    end
  end

  # TODO delete?
  def hide_all
    @grid.each do |row|
      row.each { |tile| tile.hide }
    end
  end

  def hline
    " -"*@size + " "
  end

  def render
    # TODO include line numbers (0..9) in display
    puts hline
    @grid.each do |row|
      output = []
      row.each do |tile|
        if tile.revealed
          case tile.value
          when 0
            output << " "
          when :bomb
            output << "B"
          else
            output << tile.value
          end
        else
          output << "*"
        end
      end
      puts "|" + output.join("|") + "|"
      puts hline
    end
  end

  def cascade_prep(pos)
    pass_to_cascade = []
    adj_coords = coords_adj_tiles(pos)
    adj_coords.each do |pos|
      row, col = pos
      tile = self[row, col]
      tile.reveal if (tile.value).is_a?(Integer)
      pass_to_cascade << pos if tile.value == 0
    end

    pass_to_cascade
  end

  def cascade(pos)
    to_cascade = [pos]
    completed = []

    while !to_cascade.empty?
      el = to_cascade.shift
      next if completed.include?(el)
      adj_emptys = cascade_prep(el)
      to_cascade += adj_emptys
      completed << el
    end
  end

  def won?
    count_bombs == count_hidden_squares
  end
  
  def lost?
    @bomb_locations.any? do |pos|
      row, col = pos
      tile = self[row, col]
      tile.revealed == true
    end
  end

  def reveal(pos)
    # TODO give "error" message if tile to be revealed is
    # already revealed.
    row, col = pos
    tile = self[row, col]
    tile.reveal
    value = tile.value
    case value
    when :bomb
      tile.value = "X"
    when 0
      cascade(pos)
      return true
    else
      return true
    end
  end

end