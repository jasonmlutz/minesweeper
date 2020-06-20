require_relative "board"

class Game
  def initialize(size = 10, difficulty = 1)
    @board = Board.new(size, difficulty)
  end

  def play_turn
    board.render
    puts "enter a position to reveal e.g. 0,4"
    pos = (gets.chomp).split(",")
    success = @board.reveal(pos)
  end

  def play_game
    until won? || lost?
      play_turn
    end
    board.render
    puts "you win!" if won?
    puts "you lose!" if lost?
  end
  
end