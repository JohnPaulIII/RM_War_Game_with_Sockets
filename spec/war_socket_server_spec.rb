require 'socket'
require_relative '../lib/war_socket_server'

class MockWarSocketClient
  attr_reader :socket
  attr_reader :output

  def initialize(port)
    @socket = TCPSocket.new('localhost', port)
    sleep(0.1)
  end

  def provide_input(text)
    @socket.puts(text)
    sleep(0.1)
  end

  def capture_output(delay=0.1)
    sleep(delay)
    @output = @socket.read_nonblock(1000).chomp # not gets which blocks
  rescue IO::WaitReadable
    @output = ""
  end

  def close
    @socket.close if @socket
  end
end

describe WarSocketServer do
  before(:each) do
    @clients = []
    @server = WarSocketServer.new(logging: false)
  end

  after(:each) do
    @server.stop
    @clients.each do |client|
      client.close
    end
  end

  it "is not listening on a port before it is started"  do
    expect {MockWarSocketClient.new(@server.port_number)}.to raise_error(Errno::ECONNREFUSED)
  end

  it "accepts new clients and starts a game if possible" do
    @server.start
    client1 = MockWarSocketClient.new(@server.port_number)
    @clients.push(client1)
    @server.accept_new_client("Player 1")
    @server.create_game_if_possible
    expect(@server.games.count).to be 0
    client2 = MockWarSocketClient.new(@server.port_number)
    @clients.push(client2)
    @server.accept_new_client("Player 2")
    @server.create_game_if_possible
    expect(@server.games.count).to be 1
  end

  it "checks for communication between client and server" do
    @server.start
    client1 = MockWarSocketClient.new(@server.port_number)
    @clients.push(client1)
    @server.accept_new_client("Player 1")
    @server.send_to_player("Ready Up", "Player 1")
    client1.capture_output
    expect(client1.output).to end_with("Ready Up")
    client1.provide_input("Ready")
    expect(@server.check_for_input(@server.player_sockets["Player 1"])).to eq "Ready"
  end

  # it "filters out unnessecary communication" do

  # end

  it "prevents duplicate names from registering" do
    @server.start
    client1, client2 = MockWarSocketClient.new(@server.port_number), MockWarSocketClient.new(@server.port_number)
    client1.provide_input("Player 1")
    @clients.push(client1)
    client2.provide_input("Player 1")
    @clients.push(client2)
    2.times { @server.accept_new_player }
    expect(@server.player_sockets.length).to eq 1
    expect(client2.capture_output).to include("name")
  end

  #Should probably be in WarGame spec
  # it "checks if a game can be run" do
  #   @server.start
  #   game = @server.new_game("Player 1", "Player 2")
  #   game.start
  #   expect(game.is_ready?).to eq false
  #   game.ready_up("Player 1")
  #   expect(game.is_ready?).to eq false
  #   game.ready_up("Player 2")
  #   expect(game.is_ready?).to eq true
  #   result = game.play_round
  #   expect(result).to start_with("Player ")
  # end
  
  it "can send ready queries from WarGame" do
    @server.start
    client1, client2 = MockWarSocketClient.new(@server.port_number), MockWarSocketClient.new(@server.port_number)
    @clients.push(client1)
    @clients.push(client2)
    client1.provide_input("Player 1")
    2.times { @server.accept_new_player }
    expect(client1.capture_output).to include("Waiting for more players")
    client2.provide_input("Player 2")
    expect(@server.player_sockets.length).to eq 1
    @server.resolve_players
    expect(@server.player_sockets.length).to eq 2
    expect(@server.unfinished_sockets.length).to eq 0
    expect(client2.capture_output).to include("Waiting for more players")
    @server.create_game_if_possible
    expect(client1.capture_output).to include("Player 2")
    expect(client2.capture_output).to include("Player 1")
  end

  #Should probably be in WarGame spec
  # it "checks if a game is finished" do
  #   @server.start
  #   game = @server.new_game("Player 1", "Player 2")
  #   game.players[0].hand = [PlayingCard.new("A", "Hearts")]
  #   game.players[1].hand = [PlayingCard.new("2", "Clubs")]
  #   expect(game.is_finished?).to eq false
  #   game.ready = [true,true]
  #   game.play_round
  #   expect(game.is_finished?).to eq true
  # end

  it "removes game and player sockets after game finishes" do
    @server.start
    client1, client2 = MockWarSocketClient.new(@server.port_number), MockWarSocketClient.new(@server.port_number)
    client1.provide_input("Player 1")
    @clients.push(client1)
    client2.provide_input("Player 2")
    @clients.push(client2)
    2.times { @server.accept_new_player }
    @server.create_game_if_possible
    @server.games[0].players[0].hand = [PlayingCard.new("A", "Hearts")]
    @server.games[0].players[1].hand = [PlayingCard.new("2", "Clubs")]
    @server.games[0].ready = [true,true]
    @server.run_rounds
    expect(@server.games.length).to eq 0
    expect(@server.games_by_player.length).to eq 0
    expect(@server.player_sockets.length).to eq 0
    expect(client1.capture_output).to end_with("Player 1 has won the game!")
  end

  # it "" do
    
  # end

  # Add more tests to make sure the game is being played
  # For example:
  #   make sure the mock client gets appropriate output
  #   make sure the next round isn't played until both clients say they are ready to play
  #   ...
end
