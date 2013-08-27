require_relative 'chess_pieces.rb'

class Chess

  def initialize
    @board = Hash.new(" ") #Keyed by location, value = piece obj

    place_white_pieces
    place_black_pieces

  end

  def print_board

    text_board = []

    8.downto(1) do |number|
      "a".upto("h") do |letter|
        text_board << @board[letter + number.to_s]
      end
    end

    # text_board.sort do |piece_1, piece_2|
#       piece_1.location.reverse <=> piece_2.location.reverse
#     end


    8.times do |row|
      puts text_board[8*row, 8].join(" ")
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
