require 'socket'
require_relative '../lib/war_game_client'

class MockIO

  attr_accessor :input

  def initialize(input)
    @input = input
  end

  def gets
    input
  end
end

describe WarSocketClient do

  before(:each) do
    @server = TCPServer.new('localhost', WarSocketClient::PORT_NUMBER)
    @client = WarSocketClient.new(logging: false)
  end

  after(:each) do
    @server.close
  end

  it "can recognize queries" do
    expect(!@client.query_response("Hello"))
    expect(@client.query_response("user"))
    expect(@client.query_response("Ready?"))
  end

  it 'can send and recieve from client' do
    socket1 = @server.accept
    socket1.puts "Hello"
    sleep(0.1)
    expect(@client.check_for_server_output).to eq "Hello"
    socket1.puts "Ready?"
    sleep(0.1)
    expect(@client.check_for_server_output(MockIO.new("yes"))).to eq "Ready?"
    sleep(0.1)
    expect(socket1.read_nonblock(1000)).to eq "yes\n"
  end

end