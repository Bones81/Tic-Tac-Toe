module GameBoard
  class Board 
    def initialize
      @cell_contents = [1, 2, 3, 4, 5, 6, 7, 8, 9]
      @rows = []
      @columns = []
      @diagonals = []
      @turns_taken = 0
    end

    attr_accessor :cell_contents, :rows, :columns, :diagonals, :turns_taken

    def update_and_display
      update
      display
    end
    
    def win?
      row_win? || column_win? || diagonal_win? ? true : false
    end

    def is_full?(marker1, marker2)
      count_marks(marker1, marker2) == 9 ? true : false
    end 

    private

    def display
      puts ""
      puts "-------------"
      puts "| #{cell_contents[0]} | #{cell_contents[1]} | #{cell_contents[2]} |"
      puts "-------------"
      puts "| #{cell_contents[3]} | #{cell_contents[4]} | #{cell_contents[5]} |"
      puts "-------------"
      puts "| #{cell_contents[6]} | #{cell_contents[7]} | #{cell_contents[8]} |"
      puts "-------------"
      puts ""
    end

    def update
      update_rows
      update_columns
      update_diagonals
    end
    
    def count_marks(a,b)
      self.cell_contents.count { |elt| elt == a || elt == b}
    end

    def update_rows
      @rows = [
        [@cell_contents[0], @cell_contents[1], @cell_contents[2]], 
        [@cell_contents[3], @cell_contents[4], @cell_contents[5]],
        [@cell_contents[6], @cell_contents[7], @cell_contents[8]]
      ]
    end

    def update_columns
      @columns = [
        [@cell_contents[0], @cell_contents[3], @cell_contents[6]], 
        [@cell_contents[1], @cell_contents[4], @cell_contents[7]],
        [@cell_contents[2], @cell_contents[5], @cell_contents[8]]
      ]
    end

    def update_diagonals
      @diagonals = [
        [@cell_contents[0], @cell_contents[4], @cell_contents[8]],
        [@cell_contents[2], @cell_contents[4], @cell_contents[6]]
      ]
    end

    def row_win?
      @rows.include?(['X', 'X', 'X']) || @rows.include?(['O', 'O', 'O']) ? true : false
    end

    def column_win?
      @columns.include?(['X', 'X', 'X']) || @columns.include?(['O', 'O', 'O']) ? true : false
    end

    def diagonal_win?
      @diagonals.include?(['X', 'X', 'X']) || @diagonals.include?(['O', 'O', 'O']) ? true : false
    end
  end
end

module Players
  class Player
    @@players = 0

    def initialize
      @@players += 1
      @name = "Player #{@@players}"
      @selections = []
      if @@players % 2 == 0
        @marker = 'O'
      else
        @marker = 'X'
      end
    end

    attr_reader :marker
    attr_accessor :name, :selections

    def get_choice(board)
      choice = gets.chomp.to_i
      if !choice.between?(1,9)
        print "Invalid selection. Please select an available cell by typing in the corresponding number (1-9): "
        get_choice(board)
      elsif board.cell_contents[choice-1] != choice
        puts "That cell is not available because it was chosen on a previous turn. Please choose an available cell (1-9): "
        get_choice(board)
      else
        self.selections.push(choice)
      end
    end

  end
end

class Game
  include GameBoard
  include Players

  def initialize
    @p1 = Player.new
    @p2 = Player.new
    @game_board = Board.new
    @continue = true
  end

  attr_accessor :p1, :p2, :game_board, :continue

  def setup_game
    print "What is Player 1's name?: "
    p1.name = gets.chomp
    puts "Great! Player 1 is #{p1.name}. #{p1.name}'s marker is #{p1.marker}."
    print "What is Player 2's name?: "
    p2.name = gets.chomp
    puts "Excellent! Player 2 is #{p2.name}. #{p2.name}'s marker is #{p2.marker}."  
  
    game_board.update_and_display
  end

  def active_player
    game_board.turns_taken % 2 == 0 ? p1 : p2
  end
  
  def other_player
    self.active_player == p1 ? p2 : p1
  end

  def declare_win
    puts "Congratulations! #{active_player.name} wins!"
  end

  def declare_draw
    puts "It's a draw!"
  end

  def play_again
    print "Play again? (y/n): "
    answer = gets.chomp
    answer == "y"
  end

  def exit_game
    @continue = false
    puts "Thanks for playing!"
    exit
  end

  def start_new_game
    puts "Ok. Starting a new game..."
    new_game = Game.new
    new_game.run_game # run the gameplay sequence
  end

  def game_sequence
    print "#{active_player.name}, choose an available cell to mark with an #{active_player.marker}. (1-9): "
    active_player.get_choice(game_board)
    # if (game_board.cell_contents[choice-1] == p1.marker || game_board.cell_contents[choice-1] == p2.marker)
    #   puts "That spot is not available (reason: already chosen). Please choose an available spot (1-9): "
    #   active_player.get_choice
    game_board.cell_contents[active_player.selections.last - 1] = active_player.marker
    game_board.update_and_display
  
    if game_board.win?
      declare_win
      !play_again ? exit_game : start_new_game
    end

    if game_board.is_full?(active_player.marker, other_player.marker) 
      declare_draw
      !play_again ? exit_game : start_new_game
    end

    puts ""

    game_board.turns_taken += 1

    @continue == true ? game_sequence : exit
  end
  
  def run_game
    setup_game
    game_sequence
  end

end

game = Game.new
game.run_game
