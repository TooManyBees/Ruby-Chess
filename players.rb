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
      print "#{self}'s move: "
      from, to = gets.chomp.split
      raise ChessError.new("Enter two coordinates") if to.nil? or from.nil?
      [from, to].each do |coord|
        raise ChessError.moverange(coord) unless
          coord =~ /^[a-h][1-8]$/
      end
    rescue IOError => e
      puts e.message
      retry
    end
    [from, to]
  end

  def print_board(board, threats)
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
      print text_board[8*row, 8].join + "\033[0m"
      puts " " + (8-row).to_s
    end
    puts "  a b c d e f g h"

    unless threats.empty?
      print "#{self.team.capitalize} is in check from "
      puts threats.map { |piece| "#{piece.class} #{piece.location}" }.join(", ")
    end
  end

  private

  def letter_color(piece)
    return "" if piece.empty?
    "30"
  end

  def background_color(letter, number)
    if (letter.ord - number).even?
      "43" #ANSI yellow
    else
      "47" #ANSI white
    end
  end

end
