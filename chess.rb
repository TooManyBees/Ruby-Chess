class Chess

end

class Piece

  attr_accessor :location
  attr_reader :team

  def initialize(team)
    @team = team
  end

  def get_valid_moves(offsets, options = nil)

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
end

class Pawn < Piece
  #attr_accessor :first_move

  REGULAR_OFFSETS_BLACK = [
    [0, -1], [-1, -1], [1, -1]
  ]
  FIRST_MOVE_BLACK = [
    [0, -2]
  ]
  REGULAR_OFFSETS_WHITE = [
    [0, 1], [-1, 1], [1, 1]
  ]
  FIRST_MOVE_WHITE = [
    [0, 2]
  ]

  def get_valid_moves
    offsets = []
    if self.team == :black
      offsets += REGULAR_OFFSETS_BLACK
      offsets += FIRST_MOVE_BLACK if self.location[1] == "7"
    else
      offsets += REGULAR_OFFSETS_WHITE
      offsets += FIRST_MOVE_WHITE if self.location[1] == "2"
    end
    super(offsets)
  end

end

class Rook < Piece
  OFFSETS = Array.new(7) { |i| [0,i+1] } +
            Array.new(7) { |i| [0,-(i+1)] } +
            Array.new(7) { |i| [i+1,0] } +
            Array.new(7) { |i| [-(i+1),0] }

  def get_valid_moves
    super(OFFSETS)
  end
end

class Bishop < Piece
  OFFSETS = Array.new(7) { |i| [i+1,i+1] } +
            Array.new(7) { |i| [-(i+1),-(i+1)] } +
            Array.new(7) { |i| [i+1,-(i+1)] } +
            Array.new(7) { |i| [-(i+1),i+1] }

  def get_valid_moves
    super(OFFSETS)
  end
end

class Knight < Piece
  OFFSETS = [
              [1,2], [1,-2], [-1,2], [-1,-2],
              [2,1], [2,-1], [-2,1], [-2,-1]
            ]

  def get_valid_moves
    super(OFFSETS)
  end

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
end