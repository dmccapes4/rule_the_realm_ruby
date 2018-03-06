require_relative 'tile'
require 'colorize'
require 'byebug'

# This class represents the hexagonal grid world board that players
# attempt to conquer. The grid is made up of ::Tile objects.

class WorldBoard
  attr_reader :grid, :player1, :player2
  attr_accessor :current_player

  def initialize
    @grid = build_grid
    true
  end

  def add_card(idx, jdx, card)
    self.grid[jdx][idx].add_card(card)
  end

  def remove_card(idx, jdx, card)
    self.grid[jdx][idx].remove_card(card)
  end

 # using a square layout for prototype
  def build_grid
    tiles = tile_stack.shuffle
    grid = Array.new(5) { Array.new(5) }
    grid.each_with_index do |row, jdx|
      row.each_with_index do |el, idx|
        case [idx, jdx]
        when [0, 0]
        when [0, 4]
        when [4, 0]
        when [4, 4]
        when [2, 2]
        when [0, 2]
          grid[jdx][idx] = Tile.new(:barracks, idx, jdx)
        when [4, 2]
          grid[jdx][idx] = Tile.new(:barracks, idx, jdx)
        else
          grid[jdx][idx] = Tile.new(tiles.pop, idx, jdx)
        end
      end
    end
  end

  def tile_stack
    [ :plains, :plains, :plains, :plains, :woods, :woods, :woods,
      :woods, :woods, :hills, :hills, :hills, :hills, :hills,
      :orc_longhouse, :dwarf_stronghold, :elf_fortress, :merc_camp,
      :merc_camp ]
  end

  def display
    self.grid.each_with_index do |row, jdx|
      puts "_________________________"
      row.each_with_index do |el, idx|
        if el == nil
          print "#####"
        else
          can_buy = (el.attributes[:may_purchase] ? "!" : " ")
          num_cards = (el.cards.length == 0 ? " " : el.cards.length)
          print "|#{can_buy}#{el.display}#{num_cards}|"
        end
      end
      print "\n"
    end
    puts "_________________________"
    true
  end
end
