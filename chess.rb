require_relative 'chess_pieces.rb'
require_relative 'chess_players.rb'

class Chess

  attr_reader :board
  attr_accessor :game_state

  def initialize(options = {})
    @board = Board.new( Piece.new(:none) ) #Keyed by location, value = piece obj
    @game_state = :in_progress
    @players = [HumanPlayer.new(:white), HumanPlayer.new(:black)]

    # @board.place_white_pieces
#     @board.place_black_pieces
    @board.place_pieces(options)
  end

  def play
    # Game loop
    while self.game_state == :in_progress
      @players.each do |player|

        opponent = (player.team == :white ? "Black" : "White")
        threats = self.board.threats( player.team )

        player.print_board(self.board, threats)

          if mate?(threats, player.team)
            if threats.empty?
              puts "Stalemate."
            else
              puts "#{opponent} wins."
            end
            return self.game_state
          end

        begin
          from, to = player.get_move
          piece = self.board[from]

          self.board.piece_color_check(piece, player.team)
          self.board.pathing_checks(piece, to)

          fake_board = self.board.deep_dup.update(to, from)
          unless fake_board.threats(player.team).empty?
            raise ChessError.check("places") if threats.empty?
            raise ChessError.check("leaves")
          end

          # Check check
        rescue ChessError => e
          puts e.message
          retry
        end
        # update board state/game state
        # should save which piece got captured, if any, for reference
        @board = fake_board

        break unless self.game_state == :in_progress
      end
    end # while loop

  end

  def mate?(threats, team)
    # return false if threats.empty?

    king_arr = self.board.values.select do |piece|
      piece.class == King && piece.team == team
    end
    king = king_arr[0]

    return false if king_can_escape?(king)
    return true if threats.length > 1 # can't block double check
    return false if pieces_can_move?(king, threats[0])

    unless threats.empty?
      self.game_state = (team == :white ? :black_wins : :white_wins)
    else
      self.game_state = :stalemate
    end
    true
  end

  def king_can_escape?(king)
    king_moves = king.get_valid_moves
    king_moves.each do |move|
      begin
        fake_board = self.board.deep_dup
        fake_king = fake_board[king.location]
        # run tests
        self.board.pathing_checks(king, move)

        fake_board.update(move, fake_king.location)
        next unless fake_board.threats(king.team).empty?

        return true
      rescue ChessError => e
        next
      end
    end
    false
  end

  def pieces_can_move?(king, threat)
    own_pieces = self.board.values.select do |piece|
      # piece.class != King && piece.team == king.team
      piece.team == king.team
    end

    if king && threat
      path = self.board.get_path(king.location, threat.location)
    else
      path = "a1".upto("h8").select { |el| not "09".include?(el[1]) }
    end

    own_pieces.each do |piece|
      path.each do |spot|
        begin
          # Can't block a knight
          next if threat.is_a?(Knight) && spot != threat_loc

          fake_board = self.board.deep_dup
          fake_piece = piece.deep_dup
          fake_board.pathing_checks(fake_piece, spot)

          fake_board.update(spot, fake_piece.location)
          next unless fake_board.threats(king.team).empty?
          return true
        rescue ChessError => e
          next
        end
      end
    end
    false
  end

end

class Board < Hash

  def piece_color_check(piece, color)
    raise ChessError.nopiece if piece.empty?
    raise ChessError.new("That's not your piece!") if piece.team != color
  end

  def pathing_checks(piece, location)
    self.legal_move_check(piece, location)
    self.legal_destination_check(piece, location)
    self.obstruction_check(piece, location)
  end

  def legal_move_check(piece, to)
    unless piece.get_valid_moves.include? (to)
      raise ChessError.illegal(piece)
    end
  end

  def legal_destination_check(piece, to)
    if piece.is_a? Pawn
      if self[to].empty?
        raise ChessError.illegal(piece) unless
          piece.get_valid_moves(:normal).include?(to)
      else
        raise ChessError.new("Illegal attack move for Pawn") unless
          piece.get_valid_moves(:attack).include?(to)
      end
    end

    return if self[to].empty?
    if self[to].team == piece.team
      raise ChessError.blocked(piece, to)
    end
  end

  def obstruction_check(piece, to)
    return if piece.is_a? Knight
    return if piece.is_a? King

    from = piece.location

    path = get_path(to, from)
    # p path
    path.each do |spot|
      next if [to, from].include? spot
      raise ChessError.blocked(piece, spot) unless self[spot].empty?
    end
  end

  def get_path(to, from)
    path = [from]
    dir = Array.new(2) { 0 }

    0.upto(1) do |i|
      if to[i] < from[i]
        dir[i] = -1
      elsif to[i] > from[i]
        dir[i] = 1
      end
    end

    curr = from.dup
    until curr == to || out_of_bounds?(curr)
      curr[0] = (curr[0].ord + dir[0]).chr
      curr[1] = (curr[1].ord + dir[1]).chr
      path << curr.dup
    end
    path
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

    king = self.values.select do |piece|
      piece.class == King and piece.team == team
    end

    king_loc = king[0].location
    opponent_pieces.each do |piece|

      begin
        pathing_checks(piece, king_loc)
        # if it gets here king must be in check?
        threats << piece
      rescue ChessError => e
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

  def place_pieces(options = {})
    board_teams = { black: "8", white: "1"}
    board_pawns = { black: "7", white: "2"}

    p options
    board_map = [ Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook ]

    chess960(board_map) if options[:random]

    board_teams.each do |team, number|
      board_map.each_with_index do |type, letter_i|
        letter = (letter_i + 97).chr
        coord = letter+number
        self[coord] = type.new(team, coord)
      end
      "a".upto("h") do |x|
        coord = x+board_pawns[team]
        self[coord] = Pawn.new(team, coord)
      end
      board_map.reverse! if options[:random]
    end
  end

  # Methods for Chess 960 randomized positions
  def chess960(board_map)
    loop do
      board_map.shuffle!
      break if bishops_opposite?(board_map) && king_between_rooks?(board_map)
    end
  end

  def bishops_opposite?(board_map)
    first_bishop_index = board_map.index(Bishop)
    second_bishop_index = board_map.rindex(Bishop)

    first_bishop_index.even? ^ second_bishop_index.even?
  end

  def king_between_rooks?(board_map)
    first_rook_index = board_map.index(Rook)
    second_rook_index = board_map.rindex(Rook)

    board_map[first_rook_index..second_rook_index].include?(King)
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

  def self.nopiece(coord=nil)
    ChessError.new("You own no piece #{coord.nil? ? "there" : "at " + coord}")
  end

  def self.check(verb)
    ChessError.new("That move #{verb} your king in check!")
  end
end


if __FILE__ == $PROGRAM_NAME
  c = Chess.new
  c.play
end
