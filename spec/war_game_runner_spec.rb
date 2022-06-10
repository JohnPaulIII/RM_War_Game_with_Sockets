require_relative '../lib/war_game_runner'

PORT_NUMBER = 3030

describe WarGameRunner do

  before(:each) do
    @server = TCPServer.new('localhost', PORT_NUMBER)
    @clients = Array.new(2) { sleep(0.01); TCPSocket.new('localhost', PORT_NUMBER) }
    @sockets = @clients.map { sleep(0.01); @server.accept }
    @game = WarGameRunner.new(@sockets)
  end

  after(:each) do
    @clients.each { |client| client.close }
    @sockets.each { |socket| socket.close }
    @server.close
  end

  
  it 'can recieve usernames from clients' do
    usernames = ["Josh", "Braden"]
    @clients.each { |client| expect(client.read_nonblock(1000).chomp).to eq "Please provide a username:"; client.puts usernames.pop}
    expect(!@game.recieved_all_usernames?)
    @game.check_for_usernames
    expect(@game.recieved_all_usernames?)
  end

  it 'can recieve ready-ups from clients' do

  end

  it 'can run through a round' do

  end

  it '' do

  end

end