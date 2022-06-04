require_relative 'playing_card'

class CardDeck
  attr_accessor :deck

  STANDARD_DECK_SIZE = 52
  def initialize(card_type = PlayingCard)
    @deck = []
    card_type::RANKS.each do |rank|
      card_type::SUITES.each do |suit|
        deck.push(card_type.new(rank, suit))
      end
    end
  end

  def card_count
    deck.length
  end

  def deal
    deck.pop
  end

  def shuffle
    deck.shuffle!
  end
end
