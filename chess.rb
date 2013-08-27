require_relative 'chess_pieces.rb'

class Chess

  attr_reader :board

  def initialize
    @board = Hash.new(" ") #Keyed by location, value = piece obj

    place_white_pieces
    place_black_pieces

  end

  def print_board
    text_board = []

    8.downto(1) do |number|
      "a".upto("h") do |letter|
        coordinate = letter + number.to_s

        square = @board[coordinate]
        string = "\033["
        string << letter_color(square) << ";"
        string << background_color(letter, number) << "m"
        string << square.to_s << " "
        text_board << string
      end
    end

    8.times do |row|
      puts text_board[8*row, 8].join + "\033[0m"
    end
  end

  def letter_color(piece)
    return "" if piece.is_a?(String)
    if piece.team == :white
      "37;1" # ANSI for white and bold
    else
      "30;1" # ANSI for "bold black" (dark gray)
    end
  end

  def background_color(letter, number)
    if (letter.ord - number).even?
      "40" # ANSI for black background
    else
      "43" # ANSI for magenta background (may change)
    end
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
