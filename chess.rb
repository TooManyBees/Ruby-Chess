require './pieces.rb'
require './players.rb'
require './board.rb'
require './chess_error.rb'

class Chess

  attr_reader :board
  attr_accessor :game_state

  def initialize(options = {})
    @board = Board.new( Piece.new(:none) ) #Keyed by location, value = piece obj
    @game_state = :in_progress
    @players = [HumanPlayer.new(:white), HumanPlayer.new(:black)]

    @board.place_pieces(options)
  end

  def play
    # Game loop
    puts "Enter moves as two space-separated coordinates (i.e. 'b2 b4')"
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

  # Returns whether or not a piece can move to block check
  def pieces_can_move?(king, threat)
    own_pieces = self.board.values.select do |piece|
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

if __FILE__ == $PROGRAM_NAME
  # Only variant right now is random (chess960)
  option = ARGV.pop || ""
  c = Chess.new(option.to_sym => true)
  c.play
end
