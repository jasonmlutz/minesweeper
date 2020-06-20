class Tile
  attr_accessor :value
  attr_reader :revealed

  def initialize(value)
    @value = value
    @revealed = false
  end

  def reveal
    @revealed = true
  end

  def hide
    @revealed = false
  end
  
end