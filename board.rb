require_relative "tile"
require "byebug"

class Board
  # TODO is this needed?
  attr_reader :grid

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

  # TODO rework this random portion so that *exactly* 10 
  # elements are bombs
  # DONE
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
    # returns the 3x3 grid with center pos
    # intersected with @grid, e.g [0,0] -> 4 elements
    row, col = pos
    adj_rows = grid_intersect((row-1..row+1).to_a)
    adj_cols = grid_intersect((col-1..col+1).to_a)
    adj_coords = adj_rows.product(adj_cols)
    # strictly adjacent
    # adj_coords.delete([row, col])
    # not needed; when called for adj bomb count,
    # only called if tile.vaule == :empty
    adj_coords
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
    self.render
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
        # TODO cases?
        if tile.revealed
          if (tile.value).is_a?(Integer)
            output << (tile.value > 0 ? tile.value : " ")
          elsif tile.value == :bomb
            output << "B"
          end
        else
          output << "*"
        end
        # output << "*" if !tile.revealed
        # output << 
        # if tile.revealed && tile.value != 0
        #   tile.value == :bomb ? output << "B" : output << tile.value
        # else
      end
      puts "|" + output.join("|") + "|"
      puts hline
    end
  end

  def cascade_prep(pos)
    # This method returns the coords of all "empty" tiles
    # adjacent to (and including) tile at pos,
    # where "empty" means tile.value == 0.
    # 
    # This method also reveals all adjacent tiles
    # which are not bombs.
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

  def reveal(pos)
    # TODO give "error" message if tile to be revealed is
    # already revealed.
    row, col = pos
    tile = self[row, col]
    tile.reveal
    value = tile.value
    case value
    when :bomb
      return false
    when 0
      cascade[pos]
      return true
    else
      return true
    end
  end

end

# load "board.rb"; board = Board.new; board.reveal_all; board.render; board.hide_all;