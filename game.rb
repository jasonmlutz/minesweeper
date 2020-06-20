require_relative "board"

class Game
  def initialize(size = 10, difficulty = 1)
    @board = Board.new(size, difficulty)
  end

  def play_turn
    system("clear")
    @board.render
    puts "enter a position to reveal e.g. 0,4"
    pos = (gets.chomp).split(",")
    pos.map! { |el| el.to_i }
    @board.reveal(pos)
  end

  def play_game
    until @board.won? || @board.lost?
      play_turn
    end
    system("clear")
    if @board.won?
      @board.render
      puts "you win!\n"
    end
    if @board.lost?
      @board.cheat
      @board.render
      puts "you lose!\n"
    end
  end

end