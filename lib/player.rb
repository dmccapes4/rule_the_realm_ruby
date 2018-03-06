require_relative 'world_board'
# This class contains the player's collection of tiles with their
# collections of cards that the player has purchased and moved to the
# tile. This class also contains the methods that orchestrate gameplay.
class Player
  attr_reader :name
  attr_accessor :board, :coin, :tiles, :deck, :side

  def initialize(name, board)
    @name = name
    @coin = 2
    @board = board
    @deck = []
  end

  def tiles
    self.board.grid.flatten.select do |tile|
      if tile != nil
        tile.owner == name
      else
        false
      end
    end
  end

  def spawn_tiles
    self.tiles.select { |tile| tile.attributes[:may_purchase] }
  end

  def card_tiles
    self.tiles.select { |tile| !tile.cards.empty? }
  end

  def build_tiles
    self.tiles.select { |tile| tile.attributes[:may_build] }
  end

  def cards
    self.card_tiles.reduce([]) do |cards, tile|
      tile.cards.each { |card| cards << card}
    end
  end

  def cards_to_move?
    self.cards.each { |card| return true if card.world_moved == false }
    false
  end

  def cards_to_attack?
    self.cards.each { |card| return true if card.attacked == false }
    false
  end

  def build
    if self.coin < 1
      puts "insufficient coin"
      return false
    end
    builders = self.build_tiles
    builders.each_with_index do |tile, index|
      puts "index #{index} : #{tile.type} [#{tile.idx}, #{tile.jdx}]"
    end
    puts "enter a tile index to build"
    tile = builders[gets.chomp.to_i]
    puts "enter build option:"
    puts "tower : 1"
    puts "castle : 2"
    build = gets.chomp.to_sym
    if self.coin > TILES[build].attributes[:cost]
      tile = Tile.new(build, tile.idx, tile.jdx)
      tile.owner = self.name
      true
    else
      puts "insufficient coin"
      false
    end
  end

  def buy_card(tile, card_type)
    if tile.attributes[:may_purchase]
      cost = Card.new(card_type).cost
      if self.coin >= cost && tile.available_cards[card_type] > 0
        self.coin -= cost
        tile.remove_spawn_card(card_type)
        tile.add_player_card(Card.new(card_type, self.name))
      else
        puts "Insufficient coin to buy #{card_type} or no more #{card_type}"
      end
    else
      puts "You may not purchase soldiers on this tile"
    end
  end

  def buy_cards
    spawn_tiles.each do |tile|
      puts "[#{tile.idx}, #{tile.jdx}] has:"
      puts tile.available_cards
    end
    puts "enter coordinates"
    coords = gets.chomp.split(",").map { |el| el.strip.to_i }
    puts "enter stop or card type"
    card_type = gets.chomp.to_sym
    while card_type != :stop && self.coin > 0
      buy_card(@board.grid[coords[1]][coords[0]], card_type)
      puts "#{@name} has #{@coin} coins left"
      puts "your cards:"
      self.card_tiles.each do |tile|
        puts "[#{tile.idx}, #{tile.jdx}]"
        tile.cards.each { |card| card.display_world }
      end
      puts "enter stop or card type"
      card_type = gets.chomp.to_sym
    end
  end

  def move_card(card_type, from_tile, to_tile)
    if from_tile.get_num_card_type(card_type) > 0
      card = from_tile.select_card(card_type)
      to_tile.add_player_card(card)
      from_tile.remove_player_card(card)
    else
      puts "There are no #{card_type} on this tile"
      false
    end
    true
  end

 # input is a hash attack_cards[card_type] => number to move
  def move_cards
    self.card_tiles.each do |tile|
      puts "[#{tile.idx}, #{tile.jdx}] has:"
      tile.display_cards
    end
    puts "enter from coordinates"
    coords = gets.chomp.split(",").map { |el| el.strip.to_i }
    from_tile = self.board.grid[coords[1]][coords[0]]
    puts "enter to coordinates"
    coords = gets.chomp.split(",").map { |el| el.strip.to_i }
    to_tile = self.board.grid[coords[1]][coords[0]]
    stop = "move"
    while stop != "stop"
      if from_tile.get_num_cards(self) <= 0
        puts "no more cards of that type"
        break
      end
      puts "enter card type"
      card_type = gets.chomp.to_sym
      move_card(card_type, from_tile, to_tile)
      puts "enter stop to exit"
      stop = gets.chomp
    end
    to_tile
  end
end
