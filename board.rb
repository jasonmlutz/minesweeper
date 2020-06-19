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