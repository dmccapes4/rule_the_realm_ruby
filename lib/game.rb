require_relative 'card'
require_relative 'tile'
require_relative 'player'
require_relative 'world_board'
require_relative 'battle_board'
require 'byebug'


# This class facilitates the gameplay
class Game
  attr_reader :player1, :player2
  attr_accessor :current_player, :board

  def initialize
    @board = WorldBoard.new
    @moved_to_tile
    set_players
  end

  def set_players()
    @player1 = Player.new(:player1, board)
    @player2 = Player.new(:player2, board)
    @current_player = @player1
    board.grid[2][0].set_owner(:player1)
    board.grid[2][4].set_owner(:player2)
  end

  #
  def encounter?(tile)
    if tile.owner == :none
      return tile.attributes[:encounter_chance] > Random.rand
    end
    false
  end

  def battle?(tile, player)
    if player.name == :player1
      tile.owner == :player2
    else
      tile.owner == :player1
    end
  end

  def battle(player1, player2, tile)
    battle_board = BattleBoard.new(player1, player2, tile)
    battle_board.play
  end

  def switch_players
    if @current_player.name == :player1
      @current_player = @player2
    else
      @current_player = @player1
    end
  end

  def play
    until won?
      @board.display
      @current_player.coin += 1
      puts "move buy build stop "
      command = gets.chomp
      while command != "stop"
        case command
        when "build"
          @current_player.build
        when "buy"
          @current_player.buy_cards
        when "move"
          moved_to_tile = @current_player.move_cards
          moved_to_tile.display_attributes
          if encounter?(moved_to_tile)
            puts "ENCOUNTER!"
            case moved_to_tile.owner
            when :none
              debugger
              moved_to_tile.cards << Card.new(:bax, :wild) << Card.new(:bar, :wild)
              player = Player.new(:wild, @board)
              moved_to_tile.owner = battle(@current_player, player, moved_to_tile)
            end
          elsif battle?(moved_to_tile, @current_player)
            puts "BATTLE!"
            moved_to_tile.owner = battle(@player1, @player2, moved_to_tile)
            system('clear')
            @board.display
          else
            puts "NO CONTEST!"
            moved_to_tile.owner = @current_player.name
            system('clear')
            @board.display
          end
        end
        system('clear')
        @board.display
        puts "enter a new command: move buy stop"
        command = gets.chomp
      end
      system('clear')
      @board.display
      switch_players
      puts @current_player.name.to_s.upcase()
    end
  end

  def won?
    board.grid[2][0].owner != :player1 ||
    board.grid[2][4].owner != :player2
  end
end

game = Game.new.play
