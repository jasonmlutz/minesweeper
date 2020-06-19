require_relative "tile"

class Board
  attr_reader :grid

  def initialize(size = 9)
    @size = size
    @grid = generate_grid
  end

  def generate_grid
    Array.new (@size) {
      Array.new(@size) {nil}
    }
  end

  def random_seed(size = 3)
    (0...size).to_a.sample
  end

  def populate_grid
    @grid.each do |row|
      row.map! do |el|
        random_seed == 0 ? Tile.new(:bomb) : Tile.new(:empty)
      end
    end
  end

  def count_bombs
    @grid.flatten.count { |el| el.value == :bomb }
  end

end