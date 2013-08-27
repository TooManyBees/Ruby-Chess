require_relative 'chess_pieces.rb'
require_relative 'chess_players.rb'

class Chess

  attr_reader :board
  attr_accessor :game_state

  def initialize
    @board = Hash.new(" ") #Keyed by location, value = piece obj
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
          # move validity checking:
          # not among valid moves?
          # piece in the way? check?
          piece_color_check(piece, player.team)
          legal_move_check(piece, to)
          legal_destination_check(piece, to, player.team)
          obstruction_check(piece, to)
        rescue IOError => e
          # print message from error raised
          puts e.message
          retry
        end
        # update board state/game state
        self.board[to] = self.board[from]
        self.board.delete(from)


        break unless self.game_state == :in_progress
      end
    end

  end

  def piece_color_check(piece, color)
    raise IOError.new("Piece not found") if piece == " "
    raise IOError.new("That's not your piece!") if piece.team != color
  end

  def legal_move_check(piece, to)
    unless piece.get_valid_moves.include? (to)
      raise IOError.new("That is not a valid move for that piece.")
    end
  end

  def legal_destination_check(piece, to, team)
    if piece.is_a? Pawn
      if self.board[to].is_a? String
        raise IOError.new("Illegal move for Pawn") unless
          piece.get_valid_moves(:normal).include?(to)
      else
        raise IOError.new("Illegal attack move for Pawn") unless
          piece.get_valid_moves(:attack).include?(to)
      end
    end

    return if self.board[to].is_a? String
    if self.board[to].team == team
      raise IOError.new("There is a friendly piece in that spot.")
    end
  end

  def obstruction_check(piece, to)
    return if piece.is_a? Knight

    #if not diagonal
    from = piece.location
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
      raise IOError.new("Move blocked at #{spot}.") unless self.board[spot].is_a? String
    end

    #else


    #end
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
