require_relative 'player'
require_relative 'tile'

# This class facilitates the battles on a separate 5x5 grid that can
# store one card. Players are given decks from the cards they have on
# the tile. They then place 3 cards on their back line. They can place 2
# additional cards on the back line.
class BattleBoard
  attr_reader :player1, :player2, :tile
  attr_accessor :grid, :player1_deck, :player2_deck, :current_player

  def initialize(player1, player2, tile)
    @grid = build_grid
    @player1 = player1
    @player2 = player2
    @tile = tile
    @player1.deck = get_cards(tile, player1)
    @player2.deck = get_cards(tile, player2)
    @current_player = @player1
    @player1.side = :top
    @player2.side = :bottom
  end

  def build_grid
    Array.new(5) { Array.new(5) }
  end

  def get_cards(tile, player)
    tile.cards.select do |card|
      card.owner == player.name
    end
  end

  def empty?(x, y)
    self.grid[y][x] == nil
  end

  def place_card(player)
    while true
      display
      puts "your cards are:"
      player.deck.each_with_index do |card, index|
        puts "index #{index}: #{card.type}"
      end
      puts "enter card index to choose a card"
      card_index = gets.chomp.to_i
      card = player.deck[card_index]
      puts "enter column index to place card"
      coord_x = gets.chomp.to_i
      coord_y = (self.current_player.side == :top ? 0 : 4)
      if empty?(coord_x, coord_y)
        self.grid[coord_y][coord_x] = card
        card.x = coord_x
        card.y = coord_y
        player.deck.delete_at(card_index)
        card.battle_moves -= 1
        break
      else
        puts "that tile is already occupied"
      end
    end
    display
  end

  def cards_to_move?(player)
    self.grid.flatten.each do |card|
      next if card == nil
      return true if card.owner == player.name && card.battle_moves > 0
    end
    false
  end

  def move_card(player)
    display
    puts "cards to move"
    index = 0
    player_cards = []
    self.grid.each do |row|
      row.each do |card|
        next if card == nil
        if card.battle_moves > 0 && card.owner == self.current_player.name
          puts "index #{index} : #{card.type} at #{card.x}, #{card.y}"
          player_cards << card
          index += 1
        end
      end
    end
    puts "enter card index"
    card = player_cards[gets.chomp.to_i]
    while true
      display
      puts "enter coordinates to move to"
      coords = gets.chomp.split(",").map { |el| el.strip.to_i }
      if !in_range?(card, coords[0], coords[1], 1)
        puts "those coordinates are out of range"
      elsif self.grid[coords[1]][coords[0]] == nil
        self.grid[card.y][card.x] = nil
        card.x = coords[0]
        card.y = coords[1]
        self.grid[coords[1]][coords[0]] = card
        card.battle_moves -= 1
        display
        break
      else
        puts "there is already a card there"
      end
    end
  end

  def cards_to_attack?(player)
    self.grid.flatten.each do |card|
      next if card == nil
      return true if card.owner == player.name && !card.attacked
    end
    false
  end

  def attack(player)
    puts "cards to attack with:"
    index = 0
    player_cards = []
    self.grid.each do |row|
      row.each do |card|
        next if card == nil
        if !card.attacked && card.owner == player.name
          puts "index #{index} : #{card.type} at #{card.x}, #{card.y}"
          player_cards << card
          index += 1
        end
      end
    end
    success = false
    until success
      display
      puts "enter card index or stop"
      card_index = gets.chomp
      cards = []
      until card_index == "stop"
        cards << player_cards[card_index.to_i]
        puts "enter card index or stop"
        card_index = gets.chomp
      end
      display
      puts "enter coordinates to attack or stop"
      coords = gets.chomp
      break if coords == "stop"
      coords = coords.split(",").map { |el| el.strip.to_i }
      location = self.grid[coords[1]][coords[0]]
      if location == nil
        "must select an enemy location"
      else
        if location.owner == player.name
          puts "must select an enemy location"
        elsif !in_ranges?(cards, coords[0], coords[1])
          puts "those coordinates are out of range"
        else
          puts "BATTLE"
          self.battle(cards, location)
          cards.each do |card|
            card.attacked = true;
            card.battle_moves -= 1;
          end
          success = true
        end
        display
      end
    end
  end

  def battle(attackers, defender)
    display
    attack_rolls = []
    attackers.each do |attacker|
      attacker.attack.times { |roll| attack_rolls << Random.rand(3) }
    end
    puts "attack rolls:"
    puts attack_rolls
    puts "-"
    puts attack_rolls.reduce(0) { |sum, roll| sum + roll };
    defense_rolls = defender.defense.times.reduce([]) do |rolls, roll|
      rolls << Random.rand(3)
    end
    puts "defense rolls:"
    puts defense_rolls
    puts "-"
    puts defense_rolls.reduce(0) { |sum, roll| sum + roll };
    if attack_rolls.reduce(:+) > defense_rolls.reduce(:+)
      puts "attacker wins"
      self.grid[defender.y][defender.x] = nil
    else
      puts "attack fails"
    end
  end

  def in_range?(card, x, y, range)
    (card.x - x).abs + (card.y - y).abs <= range
  end

  def in_ranges?(cards, x, y)
    cards.each { |card| return false if !in_range?(card, x, y, card.range) }
    true
  end

  def switch_players
    if self.current_player.name == self.player1.name
      self.current_player = self.player2
    else
      self.current_player = self.player1
    end
  end

  def get_played_cards(player)
    cards = []
    self.grid.flatten.each do |card|
      if card == nil
        cards
      else
        if card.owner == player.name
          cards << card
        end
      end
    end
    cards
  end

  def lost?(player)
    player.deck.empty? && get_played_cards(player).empty?
  end

  def winner
    if lost?(self.player1)
      self.player2.name
    else
      self.player1.name
    end
  end

  def over?
    lost?(self.player1) || lost?(self.player2)
  end

  def reset_cards(player)
    self.grid.each_with_index do |row, j|
      row.each_with_index do |card, i|
        if self.grid[i][j] != nil
          if self.grid[i][j].owner == player.name
            self.grid[i][j].battle_moves = 2
            self.grid[i][j].attacked = false
          end
        end
      end
    end
  end

  def play_move(player)
    num_places = 2
    play = true
    while play
      puts "place move stop attack"
      case gets.chomp
      when "stop"
        play = false
      when "place"
        if num_places > 0
          place_card(player)
          num_places -= 1
        else
          puts "out of places"
        end
      when "move"
        if cards_to_move?(player)
          move_card(player)
        else
          puts "no more cards to move"
        end
      when "attack"
        if cards_to_attack?(player)
          attack(player)
        else
          puts "no more cards to attack"
        end
      else
        puts "incorrect entry"
      end
    end
  end

  def play
    place_card(self.current_player)
    switch_players
    place_card(self.current_player)
    switch_players
    until over?
      display
      puts self.current_player.name.to_s.upcase()
      self.current_player.coin += 1
      reset_cards(self.current_player)
      play_move(self.current_player)
      switch_players if !over?
    end
    self.current_player.name
  end

  def display
    puts "___________XXXXXXX____________"
    puts "    0    1    2    3    4"
    puts "______________________________"
    self.grid.each_with_index do |row, jdx|
      row.each_with_index do |el, idx|
        print "#{jdx} |" if idx == 0
        if el == nil
          print "    |"
        else
          print el.display_battle + " |"
        end
      end
      print "\n"
      puts "______________________________"
    end
    puts "___________XXXXXXX____________"
    true
  end
end
