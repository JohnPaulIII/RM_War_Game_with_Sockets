require_relative '../lib/card_deck'

describe 'CardDeck' do
  it 'Should have 52 cards when created' do
    deck = CardDeck.new(PlayingCard)
    expect(deck.card_count).to eq 52
  end

  it 'should deal the top card' do
    deck = CardDeck.new(PlayingCard)
    card = deck.deal
    expect(card).to eq PlayingCard.new('A', 'Spades')
    expect(deck.card_count).to eq 51
  end

  it 'should start with a set deck order' do
    deck = CardDeck.new(PlayingCard)
    shuffled_deck = CardDeck.new(PlayingCard)
    while deck.card_count > 0 do
      expect(deck.deal).to eq shuffled_deck.deal
    end
  end
  
  # it 'should shuffle the deck' do
  #   deck = CardDeck.new(PlayingCard)
  #   shuffled_deck = CardDeck.new(PlayingCard)
  #   shuffled_deck.shuffle
  #   expect(deck.deal).to_not eq shuffled_deck.deal
  # end

end
