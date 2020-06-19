class Tile
  attr_accessor :value, :revealed

  def initialize(value)
    @value = value
    @revealed = false
    @neighbors = nil
  end
end