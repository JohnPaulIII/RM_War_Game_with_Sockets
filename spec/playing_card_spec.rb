require_relative '../lib/playing_card'

describe 'PlayingCard' do
  it 'has a valid rank' do
    PlayingCard::RANKS.each do |rank|
      card = PlayingCard.new(rank, 'Heart')
      expect(card.rank).to eq rank
    end
  end

  it 'has a valid suit' do
    PlayingCard::SUITES.each do |suit|
      card = PlayingCard.new('A', suit)
      expect(card.suit).to eq suit
    end
  end

  it 'ignores an invalid rank' do
    card = PlayingCard.new('22', 'Heart')
    expect(card.rank).to eq ''
  end

  it 'ignores an invalid suit' do
    card = PlayingCard.new('10', 'Circle')
    expect(card.suit).to eq ''
  end
  
  it 'can evaluate equivilence' do
    card1 = PlayingCard.new('10', 'Heart')
    card2 = PlayingCard.new('10', 'Heart')
    expect(card1).to eq card2
  end

  it 'can evaluate greater/less than' do
    card1 = PlayingCard.new('10', 'Heart')
    card2 = PlayingCard.new('9', 'Clubs')
    card3 = PlayingCard.new('K', 'Clubs')
    expect(card1).to be > card2
    expect(card1).to be < card3
  end

end
