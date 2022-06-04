require_relative '../lib/war_player'

describe 'WarPlayer' do

  it 'should have a name' do
    player = WarPlayer.new('Player 1')
    expect(player.name).to eq 'Player 1'
  end

  it 'should hold cards' do
    player = WarPlayer.new('Player 1')
    player.take_card(PlayingCard.new('A', 'Spades'))
    expect(player.play_card).to eq PlayingCard.new('A', 'Spades')
  end

  it 'should play cards' do
    player = WarPlayer.new('Player 1')
    card = PlayingCard.new('A', 'Spades')
    player.take_card(card)
    played_card = player.play_card
    expect(played_card).to eq PlayingCard.new('A', 'Spades')
  end
  
  it 'should add cards to it\'s own deck' do
    player = WarPlayer.new('Player 1')
    player.take_card(PlayingCard.new('A', 'Spades'))
    player.take_card(PlayingCard.new('A', 'Hearts'))
    expect(player.card_count).to eq 2
  end
  
  it 'should indicate if it has cards' do
    player = WarPlayer.new('Player 1')
    player.take_card(PlayingCard.new('A', 'Spades'))
    expect(player.out?).to eq false
    player.play_card
    expect(player.out?).to eq true
  end
  
end
