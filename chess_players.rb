class ChessPlayer

  attr_reader :team

  def initialize(team)
    @team = team
  end

  def print_board(board)

  end

  def get_move

  end

  def to_s
    team.to_s.capitalize
  end

end

class HumanPlayer < ChessPlayer

  def get_move
    begin
      puts "#{self}: Please enter your move as two space separated coordinates"
      from, to = gets.chomp.split
      raise IOError.new "Enter two coordinates" if to.nil? or from.nil?
      [from, to].each do |coord|
        raise IOError.new "Coordinate #{coord} out of bounds" unless
          coord =~ /^[a-h][1-8]$/
      end
    rescue IOError => e
      puts e.message
      retry
    end
    [from, to]
  end

  def print_board(board)
    text_board = []
    8.downto(1) do |number|
      "a".upto("h") do |letter|
        coordinate = letter + number.to_s

        square = board[coordinate]
        string = "\033["
        string << letter_color(square) << ";"
        string << background_color(letter, number) << "m"
        string << square.to_s << " "
        text_board << string
      end
    end

    puts "  a b c d e f g h"
    8.times do |row|
      print (8-row).to_s + " "
      puts text_board[8*row, 8].join + "\033[0m"
    end
  end

  private

  def letter_color(piece)
    return "" if piece.empty?
    if piece.team == :white
      "37;1" # ANSI for white and bold
    else
      "37" # ANSI for white (regular)
      # "30;1" # ANSI for "bold black" (dark gray)
    end
  end

  def background_color(letter, number)
    if (letter.ord - number).even?
      "40" # ANSI for black background
    else
      "43" # ANSI for magenta background (may change)
    end
  end

end
