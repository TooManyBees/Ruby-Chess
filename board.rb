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

    board_map = [ Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook ]

    chess960(board_map) if options[:random] || options[:chess960]

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
  # Continually shuffle the layout until the two conditions are met:
  # 1. The king is between both of the rooks,
  # 2. The bishops are on different colored squares
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
