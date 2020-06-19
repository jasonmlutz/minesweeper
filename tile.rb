class Tile
  attr_accessor :value, :revealed

  def initialize(value)
    @value = value
    @revealed = false
  end
end