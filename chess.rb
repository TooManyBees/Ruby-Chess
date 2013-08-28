require_relative 'chess_pieces.rb'
require_relative 'chess_players.rb'

class Chess

  attr_reader :board
  attr_accessor :game_state

  def initialize
    @board = Hash.new( Piece.new(:none) ) #Keyed by location, value = piece obj
    @game_state = :in_progress
    @players = [HumanPlayer.new(:white), HumanPlayer.new(:black)]
    place_white_pieces
    place_black_pieces
  end

  def play
    # Game loop
    while self.game_state == :in_progress
      @players.each do |player|
        player.print_board(self.board)

        begin
          from, to = player.get_move
          piece = self.board[from]

          piece_color_check(from, player.team)
          legal_move_check(piece, to)
          legal_destination_check(piece, to, player.team)
          obstruction_check(piece, to)
          # Check check
        rescue ChessError => e
          # puts "#{piece.class} #{from} is #{e.message}"
          puts e.message
          retry
        end
        # update board state/game state
        # should save which piece got captured, if any, for reference
        self.board[to] = self.board[from]
        self.board[to].location = to
        self.board.delete(from)


        break unless self.game_state == :in_progress
      end
    end
  end

  def piece_color_check(from, color)
    piece = self.board[from]
    raise ChessError.nopiece(from) if piece.empty?
    raise ChessError.nopiece(from) if piece.team != color
  end

  def legal_move_check(piece, to)
    unless piece.get_valid_moves.include? (to)
      raise ChessError.illegal(piece, to)
    end
  end

  def legal_destination_check(piece, to, team)
    if piece.is_a? Pawn
      if self.board[to].empty?
        raise ChessError.illegal(piece) unless
          piece.get_valid_moves(:normal).include?(to)
      else
        raise ChessError.new("Illegal attack move for Pawn #{piece.location}") unless
          piece.get_valid_moves(:attack).include?(to)
      end
    end

    return if self.board[to].empty?
    if self.board[to].team == team
      raise IOError.new("There is a friendly piece in that spot.")
    end
  end

  def obstruction_check(piece, to)
    return if piece.is_a? Knight
    return if piece.is_a? King

    from = piece.location

    if (from[0] == to[0] or from[1] == to[1]) # not diagonal
      axis = from[0] == to[0] ? from[0] : from[1]
      path = board.keys.select { |key| key.include? axis }
      path << to unless path.include? to
      path.sort!
      path.reverse! if to < from

      collision_check = false
      path.each do |spot|
        return if collision_check and [from, to].include? spot
        if [from, to].include? spot
          collision_check = true
          next
        end
        next unless collision_check
        raise ChessError.blocked(piece, spot) unless self.board[spot].empty?
      end
    else # is a diagonal
      path = []
      directions = [[-1, -1], [-1, 1], [1, -1], [1, 1]]

      if to[0] < from[0] and to[1] < from[1]
        dir = directions[0]
      elsif to[0] < from[0] and to[1] > from[1]
        dir = directions[1]
      elsif to[0] > from[0] and to[1] < from[1]
        dir = directions[2]
      else
        dir = directions[3]
      end

      curr = from.dup
      until curr == to || out_of_bounds?(curr)
        curr[0] = (curr[0].ord + dir[0]).chr
        curr[1] = (curr[1].ord + dir[1]).chr
        raise ChessError.blocked(piece, curr) unless
          self.board[curr].empty? or curr == to
      end

    end
  end

  def out_of_bounds?(coords)
    !("a".."h").include?(coords[0]) || !("1".."8").include?(coords[1])
  end

  def place_white_pieces
    "a".upto("h") do |x|
      @board[x+"2"] = Pawn.new(:white, x+"2")
    end
    ["a1","h1"].each do |spot|
      @board[spot] = Rook.new(:white, spot)
    end
    ["b1","g1"].each do |spot|
      @board[spot] = Knight.new(:white, spot)
    end
    ["c1", "f1"].each do |spot|
      @board[spot] = Bishop.new(:white, spot)
    end
    @board["d1"] = Queen.new(:white, "d1")
    @board["e1"] = King.new(:white, "e1")
  end

  def place_black_pieces
    "a".upto("h") do |x|
      @board[x+"7"] = Pawn.new(:black, x+"7")
    end
    ["a8","h8"].each do |spot|
      @board[spot] = Rook.new(:black, spot)
    end
    ["b8","g8"].each do |spot|
      @board[spot] = Knight.new(:black, spot)
    end
    ["c8", "f8"].each do |spot|
      @board[spot] = Bishop.new(:black, spot)
    end
    @board["d8"] = Queen.new(:black, "d8")
    @board["e8"] = King.new(:black, "e8")
  end

end

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

  def self.nopiece(coord)
    ChessError.new("You own no piece at #{coord}")
  end
end
