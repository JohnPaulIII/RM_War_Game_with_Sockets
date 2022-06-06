require_relative '../lib/war_game'

describe WarGame do
  it "checks if a game can be run" do
    game = WarGame.new(["Player 1", "Player 2"])
    game.start
    expect(game.is_ready?).to eq false
    game.ready_up("Player 1")
    expect(game.is_ready?).to eq false
    game.ready_up("Player 2")
    expect(game.is_ready?).to eq true
    result = game.play_round
    expect(result).to start_with("Player ")
  end

  it "checks if a game is finished" do
    game = WarGame.new(["Player 1", "Player 2"])
    game.players[0].hand = [PlayingCard.new("A", "Hearts")]
    game.players[1].hand = [PlayingCard.new("2", "Clubs")]
    expect(game.is_finished?).to eq false
    game.ready = [true,true]
    game.play_round
    expect(game.is_finished?).to eq true
  end

  it "checks if a round runs past an initial tie", :focus => true do
    game = WarGame.new(["Player 1", "Player 2"])
    game.players[0].hand = [PlayingCard.new("A", "Hearts"), PlayingCard.new("A", "Clubs")]
    game.players[1].hand = [PlayingCard.new("2", "Clubs"), PlayingCard.new("A", "Spades")]
    game.ready = [true,true]
    game.play_round
    expect(game.is_finished?).to eq true
  end




  # it 'should hold an initial deck' do
  #   game = WarGame.new(["Player 1", "Player 2"])
  #   #expect(game.deck).to be_instance_of(CardDeck)
  #   expect(game.deck.deal).to eq NewCard('A', 'Spades')
  # end

  it 'should have players' do
    game = start_war_game()
    expect(game.players[0].name).to eq "Player 1"
  end

  it 'should deal cards' do
    game = start_war_game(start: true)
    expect(game.players[0].card_count).to_not eq 0
  end

  it 'should play a round' do
    game = start_war_game(start: true)
    game.play_round
    expect(game.players[0].card_count).to_not eq game.players[1].card_count
  end

  it 'should let Player 1 win first round' do
    game = start_war_game(
      player1hand: NewCard('A', 'Spades'),
      player2hand: NewCard('2', 'Hearts')
    )
    expect(game.is_finished?).to eq false
    expect(game.play_round).to eq "Player 1 won with a A of Spades and took 2 cards"
    expect(game.finish_message).to start_with("Player 1")
  end

  it 'should present selected cards' do
    game = start_war_game(
      player1hand: NewCard('A', 'Spades'),
      player2hand: NewCard('2', 'Hearts')
    )
    cards = game.play_cards
    expect(cards[0]).to eq NewCard('A', 'Spades')
    expect(cards[1]).to eq NewCard('2', 'Hearts')
  end

  it 'should let Player 2 win first round' do
    game = start_war_game(
      player1hand: NewCard('2', 'Spades'),
      player2hand: NewCard('A', 'Hearts')
    )
    game.play_round
    expect(game.finish_message).to start_with("Player 2")
  end

  it 'should let Player 1 win second round'do
  game = start_war_game(
    player1hand: [NewCard('A', 'Spades'), NewCard('A', 'Clubs')],
    player2hand: [NewCard('A', 'Hearts'), NewCard('2', 'Hearts')]
  )
    game.play_round
    expect(game.finish_message).to start_with("Player 1")
  end

  it 'should let Player 2 run out of cards during round' do
    game = start_war_game(
      player1hand: [NewCard('A', 'Spades'), NewCard('A', 'Clubs')],
      player2hand: NewCard('A', 'Hearts')
    )
    expect(game.play_round).to eq "Player 1 won with a A of Clubs and took 3 cards"
    expect(game.finish_message).to start_with("Player 1")
  end

  it 'should run to completion', :focus => true  do
    game = WarGame.new(["Player 1", "Player 2"])
    game.start
    until game.is_finished? do
      game.play_round
    end
    expect(game.finish_message.match(/Player \d+/))
  end

  def start_war_game(start: false, player1hand: [], player2hand: [])
    game = WarGame.new(["Player 1", "Player 2"])
    game.start if start
    game.players[0].take_card(*Array(player1hand))
    game.players[1].take_card(*Array(player2hand))
    game
  end

  def NewCard(rank, suit)
    PlayingCard.new(rank, suit)
  end

end
