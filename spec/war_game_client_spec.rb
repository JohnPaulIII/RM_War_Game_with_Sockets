require 'socket'
require_relative '../lib/war_game_client'
require_relative '../lib/war_socket_server'

describe WarSocketClient do

  it "can recognize queries" do
    client = WarSocketClient.new
    expect(!client.query_response("Hello"))
    expect(client.query_response("user"))
    expect(client.query_response("Ready?"))
  end

  it 'can recieve from server' do
    server = WarSocketServer.new
    client1 = WarSocketClient.new
  end

end