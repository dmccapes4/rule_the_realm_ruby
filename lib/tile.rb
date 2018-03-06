require 'colorize'

# This class contains the various types of tiles used by the game board.
# These tiles are accessed by the ::type variable returning a name and
# list of attributes. Tiles that produce cards are also given an array
# of cards that can be bought, and replenish upon death.
class Tile
  attr_reader :type, :attributes, :idx, :jdx
  attr_accessor :cards, :owner, :available_cards

  def initialize(type, idx = 0, jdx = 0)
    @type = type
    @idx = idx
    @jdx = jdx
    @attributes = TILES[type][0]
    @cards = TILES[type][1]
    @owner = :none
    @available_cards = TILES[type][2]
  end

  def set_owner(player)
    @owner = player
  end

  def add_player_card(card)
    self.cards << card
  end

  def select_card(card_type)
    if !self.cards.empty?
      self.cards.each { |card| return card if card.type == card_type }
    else
      puts "there are no cards of that type on this tile"
      false
    end
  end

  def spawn_card(card)
    if self.attributes[:may_purchase]
      self.available_cards[card] += 1
    else
      puts "not a spawn tile"
    end
  end

  def remove_spawn_card(card_type)
    if self.available_cards[card_type] > 0
      self.available_cards[card_type] -= 1
    else
      puts "this tile has no more available #{card_type}"
    end
  end

  def remove_player_card(card)
    self.cards.delete(card)
  end

  def get_num_cards(player)
    self.cards.reduce(0) do |sum, card|
      card.owner == player.name ? sum + 1 : sum
    end
  end

  def get_num_card_type(card_type)
    self.cards.reduce(0) do |sum, card|
      card.type == card_type ? sum + 1 : sum
    end
  end

  def display
    if self.owner == :player1
      "#".blue
    elsif self.owner == :player2
      "#".red
    else
      "?"
    end
  end

  def display_attributes
    puts "#{self.type}:"
    puts "owner: #{self.owner}"
    puts "attributes:"
    puts self.attributes
    puts "cards:"
    self.cards.each { |card| card.display_world }
  end

  def display_cards
    self.cards.each { |card| puts card.type }
  end
end

# This hash contains the types of tiles returns an array containing two
# hashes: attributes and cards
# TILES[:type] => [{attributes}, {cards}]
# attributes contain constants while card keys return the number of
# available cards of that type.
  TILES = {
    plains: [
      {
        may_build: true,
        may_purchase: false,
        encounter_chance: 0.3,
        difficult_terrain: false
      },
      []
    ],
    hills: [
      {
        may_build: false,
        may_purchase: false,
        encounter_chance: 0.7,
        difficult_terrain: true
      },
      []
    ],
    woods: [
      {
        may_build: false,
        may_purchase: false,
        encounter_chance: 0.5,
        difficult_terrain: true
      },
      []
    ],
    barracks: [
      {
        may_build: false,
        may_purchase: true,
        encounter_chance: 0.0,
        difficult_terrain: false
      },
      [],
      Hash.new(0).merge(
        {
        swordsman: 2,
        archer: 2,
        spearman: 2
      }
    )
    ],
    orc_longhouse: [
      {
        may_build: false,
        may_purchase: true,
        encounter_chance: 1.0,
        difficult_terrain: false
      },
      [],
      Hash.new(0).merge(
        {
        orc: 2
      }
    )
    ],
    dwarf_stronghold: [
      {
        may_build: false,
        may_purchase: true,
        encounter_chance: 1.0,
        difficult_terrain: false
      },
      [],
      Hash.new(0).merge(
        {
        dwarf: 2
      }
    )
    ],
    elf_fortress: [
      {
        may_build: false,
        may_purchase: true,
        encounter_chance: 1.0,
        difficult_terrain: false
      },
      [],
      Hash.new(0).merge(
        {
        elf: 2
      }
    )
    ],
    merc_camp: [
      {
        may_build: false,
        may_purchase: true,
        encounter_chance: 0.0,
        difficult_terrain: false
      },
      [],
      Hash.new(0).merge(
        {
        orc: 1,
        elf: 1,
        dwarf: 1
      }
    )
    ],
    tower: [
      {
        may_build: false,
        may_purchase: true,
        encounter_chance: 0.0,
        difficult_terrain: false,
        cost: 1
      },
      [],
      Hash.new(0).merge(
        {
          ranger: 1,
          spearman: 1,
          archer: 1
        }
      )
    ],
    castle: [
      {
        may_build: false,
        may_purchase: true,
        encounter_chance: 0.0,
        difficult_terrain: false,
        cost: 2
      },
      [],
      Hash.new(0).merge(
        {
          knight: 2,
          ranger: 2,
          swordsman: 1,
          archer: 1
        }
      )
    ]
  }
