require_relative 'chess_pieces.rb'
require_relative 'chess_players.rb'

class Chess

  attr_reader :board
  attr_accessor :game_state

  def initialize
    @board = Board.new( Piece.new(:none) ) #Keyed by location, value = piece obj
    @game_state = :in_progress
    @players = [HumanPlayer.new(:white), HumanPlayer.new(:black)]
    place_white_pieces
    place_black_pieces
  end

  def play
    # Game loop
    while self.game_state == :in_progress
      @players.each do |player|

        threats = self.board.threats( player.team )

        player.print_board(self.board, threats)

        begin
          from, to = player.get_move
          piece = self.board[from]

          self.board.piece_color_check(piece, player.team)
          self.board.legal_move_check(piece, to)
          self.board.legal_destination_check(piece, to, player.team)
          self.board.obstruction_check(piece, to)

          fake_board = self.board.deep_dup.update(to, from)
          unless fake_board.threats(player.team).empty?
            raise IOError.new("That move leaves your king in check!")
          end

          # Check check
        rescue IOError => e
          puts e.message
          retry
        end
        # update board state/game state
        # should save which piece got captured, if any, for reference
        @board = fake_board



        break unless self.game_state == :in_progress
      end
    end
  end

  def checkmate?

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

class Board < Hash

  def piece_color_check(piece, color)
    raise IOError.new("Piece not found") if piece.empty?
    raise IOError.new("That's not your piece!") if piece.team != color
  end

  def legal_move_check(piece, to)
    unless piece.get_valid_moves.include? (to)
      raise IOError.new("That is not a valid move for that piece.")
    end
  end

  def legal_destination_check(piece, to, team)
    if piece.is_a? Pawn
      if self[to].empty?
        raise IOError.new("Illegal move for Pawn") unless
          piece.get_valid_moves(:normal).include?(to)
      else
        raise IOError.new("Illegal attack move for Pawn") unless
          piece.get_valid_moves(:attack).include?(to)
      end
    end

    return if self[to].empty?
    if self[to].team == team
      raise IOError.new("There is a friendly piece in that spot.")
    end
  end

  def obstruction_check(piece, to)
    return if piece.is_a? Knight
    return if piece.is_a? King

    from = piece.location

    if (from[0] == to[0] or from[1] == to[1]) # not diagonal
      axis = from[0] == to[0] ? from[0] : from[1]
      path = self.keys.select { |key| key.include? axis }
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
        raise IOError.new("Move blocked at #{spot}.") unless self[spot].empty?
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
        raise IOError.new("Move blocked at #{curr}") unless
          self[curr].empty? or curr == to
      end

    end
  end

  def out_of_bounds?(coords)
    !("a".."h").include?(coords[0]) || !("1".."8").include?(coords[1])
  end

  def threats(team)
    threats = []

    opponent = team == :white ? :black : :white

    opponent_pieces = self.values.select do |piece|
      piece.team == opponent
    end

    # king = self.select do |piece|
#       piece.class == King and piece.team == team
#     end
#
#     king_loc = king.keys[0]

    king = self.values.select do |piece|
      piece.class == King and piece.team == team
    end

    king_loc = king[0].location

    opponent_pieces.each do |piece|

      begin
        self.legal_move_check(piece, king_loc)
        self.legal_destination_check(piece, king_loc, opponent)
        self.obstruction_check(piece, king_loc)
        # if it gets here king must be in check?
        threats << piece
      rescue IOError => e
        next
      end

    end
    # iterated through all opponent pieces, none had legal move
    # to team's king
    threats
  end

  def update(to, from)
    self[to] = self[from]
    self[to].location = to
    self.delete(from)
    self
  end

  def deep_dup

    new_board = Board.new( self.default )

    self.each do |coord, piece|
      new_board[coord.dup] = piece.deep_dup
    end

    new_board
  end

end
