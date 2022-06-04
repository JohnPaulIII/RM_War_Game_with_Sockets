require 'socket'
require 'pry'

class WarSocketServer

  attr_accessor :player_sockets, :games

  def initialize
    @player_sockets = {}
    @games = []
  end

  def port_number
    3336
  end

  def start
    @server = TCPServer.new(port_number)
  end

  def accept_new_client(player_name = "Random Player")
    client = @server.accept_nonblock
    player_sockets[player_name] = client
  rescue IO::WaitReadable, Errno::EINTR
    puts "No client to accept"
  end

  def create_game_if_possible
    if player_sockets.length > games.length * 2 + 1
      player1, player2 = player_sockets.keys[games.length * 2], player_sockets.keys[games.length * 2 + 1]
      #binding.pry
      games.push("#{player1} is playing against #{player2}")
    end
  end

  def send_to_socket(message, client)
    player_sockets[client].puts message
  end

  def check_for_input(client)
    player_sockets[client].read_nonblock(1000).chomp
  rescue IO::WaitReadable
    puts "No messages waiting"
  end

  def stop
    @server.close if @server
  end
end
