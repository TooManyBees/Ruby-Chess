class ChessError < StandardError
  def self.blocked(piece, to)
    ChessError.new("#{piece.class} #{piece.location} blocked at #{to}")
  end

  def self.illegal(piece, to=nil)
    ChessError.new("Illegal move for #{piece.class} #{piece.location}")
  end

  def self.moverange(coord)
    ChessError.new("Coordinate #{coord} out of bounds")
  end

  def self.nopiece(coord=nil)
    ChessError.new("You own no piece #{coord.nil? ? "there" : "at " + coord}")
  end

  def self.check(verb)
    ChessError.new("That move #{verb} your king in check!")
  end
end
