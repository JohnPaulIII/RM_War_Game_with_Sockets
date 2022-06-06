require_relative 'card_deck'
require_relative 'war_player'

class WarGame

  attr_accessor :players, :player_names, :deck, :ready

  def initialize(new_players)
    @players = (0..new_players.length - 1).map { |i| WarPlayer.new(new_players[i]) }
    @player_names = new_players
    @deck = CardDeck.new(PlayingCard)
    deck.shuffle
    clear_ready
  end

  def start
    deck.deck.each_index { |i| players[i % players.length].take_card(deck.deal) }
  end

  def is_ready?
    !ready.include?(false)
  end

  def ready_up(player)
    player_names.find_index(player)
    ready[player_names.find_index(player)] = true
  end

  def clear_ready
    @ready = Array.new(players.length, false)
  end

  def play_round
    clear_ready
    cards = play_cards
    winning_cards = get_winning_cards(cards)
    evaluate_round(cards, winning_cards)
  end

  def play_tie_round(indexes, pool)
    cards = play_reduced_cards(indexes)
    winning_cards = get_winning_cards(cards)
    evaluate_round(cards, winning_cards, pool: pool)
  end

  def evaluate_round(cards, winning_cards, pool: [])
    if winning_cards.length == 1
      collect_winnings(cards, winning_cards, pool: pool)
    else
      winners = winning_cards.keys
      play_tie_round(winners, cards.values + pool)
    end
  end

  def collect_winnings(cards, winning_cards, pool: [])
    winner_index = winning_cards.keys[0]
    winnings = []
    cards.each_value { |card| winnings.push(card) }
    pool.each { |card| winnings.push(card) }
    winnings.compact.shuffle.each { |card| players[winner_index].take_card(card) }
    "#{player_names[winner_index]} won with a #{winning_cards.values[0].rank} of #{winning_cards.values[0].suit} and took #{winnings.length} cards"
  end

  def play_cards
    cards = {}
    players.each_index { |i| cards[i] = players[i].play_card if !players[i].out?}
    cards
  end

  def play_reduced_cards(indexes)
    cards = {}
    indexes.each { |i| cards[i] = players[i].play_card if !players[i].out?}
    cards
  end

  def get_winning_cards(cards)
    max_value = cards.values.max { |value1, value2| PlayingCard::RANKS.index(value1.rank) <=> PlayingCard::RANKS.index(value2.rank) }.rank
    cards.select { |key, card| card.rank == max_value }
  end

  def is_finished?
    players.select { |player| !player.out? }.length < 2
  end

  def finish_message
    if is_finished?
      winner = players.select { |player| !player.out? }[0]
      "#{winner.name} has won the game!"
    end
  end
end