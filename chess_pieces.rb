# N.B. each piece's to_s method outputs a unicode "black"
# chess piece for its white version, and vice versa.
# (As they are rendered in white against a dark background.)

class Piece

  attr_accessor :location
  attr_reader :team

  def initialize(team, location=nil)
    @team = team
    @location = location
  end

  def get_valid_moves(offsets, option=nil)

    positions = []
    offsets.each do |offset|
      positions << [ (offset[0] + self.location[0].ord).chr,
                     offset[1] + self.location[1].to_i ]
    end

    positions.select! do |pos|
      pos[0].between?("a","h") && pos[1].between?(1,8)
    end

    positions.map do |pos|
      pos[0] + pos[1].to_s
    end
  end

  def to_s
    " "
  end

  def empty?; true; end
end

class Pawn < Piece
  #attr_accessor :first_move
  ATTACK_OFFSETS_BLACK = [ [-1, -1], [1, -1] ]
  REGULAR_OFFSETS_BLACK = [ [0, -1] ]
  FIRST_MOVE_BLACK = [ [0, -2] ]

  ATTACK_OFFSETS_WHITE = [ [-1, 1], [1, 1] ]
  REGULAR_OFFSETS_WHITE = [ [0, 1] ]
  FIRST_MOVE_WHITE = [ [0, 2] ]

  def get_valid_moves(option=nil)
    offsets = []
    if self.team == :black
      offsets += REGULAR_OFFSETS_BLACK
      offsets += FIRST_MOVE_BLACK if self.location[1] == "7"
      offsets += ATTACK_OFFSETS_BLACK unless option == :normal
      offsets = ATTACK_OFFSETS_BLACK if option == :attack
    else
      offsets += REGULAR_OFFSETS_WHITE
      offsets += FIRST_MOVE_WHITE if self.location[1] == "2"
      offsets += ATTACK_OFFSETS_WHITE unless option == :normal
      offsets = ATTACK_OFFSETS_WHITE if option == :attack
    end
    super(offsets)
  end

  def to_s
    self.team == :white ? "\u265F" : "\u2659"
  end

  def empty?; false; end
end

class Rook < Piece
  OFFSETS = Array.new(7) { |i| [0,i+1] } +
            Array.new(7) { |i| [0,-(i+1)] } +
            Array.new(7) { |i| [i+1,0] } +
            Array.new(7) { |i| [-(i+1),0] }

  def get_valid_moves
    super(OFFSETS)
  end

  def to_s
    self.team == :white ? "\u265C" : "\u2656"
  end

  def empty?; false; end
end

class Bishop < Piece
  OFFSETS = Array.new(7) { |i| [i+1,i+1] } +
            Array.new(7) { |i| [-(i+1),-(i+1)] } +
            Array.new(7) { |i| [i+1,-(i+1)] } +
            Array.new(7) { |i| [-(i+1),i+1] }

  def get_valid_moves
    super(OFFSETS)
  end

  def to_s
    self.team == :white ? "\u265D" : "\u2657"
  end

  def empty?; false; end
end

class Knight < Piece
  OFFSETS = [
              [1,2], [1,-2], [-1,2], [-1,-2],
              [2,1], [2,-1], [-2,1], [-2,-1]
            ]

  def get_valid_moves
    super(OFFSETS)
  end

  def to_s
    self.team == :white ? "\u265E" : "\u2658"
  end

  def empty?; false; end
end

class Queen < Piece
  OFFSETS = Array.new(7) { |i| [0,i+1] } +
            Array.new(7) { |i| [0,-(i+1)] } +
            Array.new(7) { |i| [i+1,0] } +
            Array.new(7) { |i| [-(i+1),0] } +
            Array.new(7) { |i| [i+1,i+1] } +
            Array.new(7) { |i| [-(i+1),-(i+1)] } +
            Array.new(7) { |i| [i+1,-(i+1)] } +
            Array.new(7) { |i| [-(i+1),i+1] }

  def get_valid_moves
    super(OFFSETS)
  end

  def to_s
    self.team == :white ? "\u265B" : "\u2655"
  end

  def empty?; false; end
end

class King < Piece
  OFFSETS = [
              [1, 0], [1, 1], [1, -1],
              [0, 1], [0, -1],
              [-1, 0], [-1, 1], [-1, -1]
            ]

  def get_valid_moves
    super(OFFSETS)
  end

  def to_s
    self.team == :white ? "\u265A" : "\u2654"
  end

  def empty?; false; end
end
