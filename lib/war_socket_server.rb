require 'socket'
require 'pry'

class WarSocketServer

  attr_accessor :player_sockets, :games, :games_by_player

  def initialize
    @unfinished_sockets = []
    @player_sockets = {}
    @games_by_player = {}
    @games = []
  end

  def port_number
    3336
  end

  def start
    @server = TCPServer.new(port_number)
    @server.listen(3)
  end

  def accept_new_client(player_name = "Random Player")
    client = @server.accept_nonblock
    player_sockets[player_name] = client
  rescue IO::WaitReadable, Errno::EINTR
    puts "No client to accept"
  end

  def accept_new_player
    client = @server.accept_nonblock
    puts client
    check_for_player_name(client) if !client.nil?
  rescue IO::WaitReadable, Errno::EINTR
    puts "skip"
  end

  def check_for_player_name(client, add_to_unfinished: false)
    response = check_for_input(client)
    if player_sockets.keys.include?(response)
      send_to_socket("Username already exists, please choose a different name:", client)
      unfinished_sockets.push(client) if add_to_unfinished
    else
      if response
        player_sockets[response] = client
      else
        unfinished_sockets.push(client) if add_to_unfinished
      end
    end
  end

  def create_game_if_possible
    return unless player_sockets.length > games.length * 2 + 1
    player1, player2 = player_sockets.keys[games.length * 2], player_sockets.keys[games.length * 2 + 1]
    game = "#{player1} is playing against #{player2}"
    games.push(game)
    [player1, player2].each { |player| games_by_player[player] = game}
  end

  def send_to_socket(message, client)
    client.puts message
  end

  def send_to_player(message, client)
    player_sockets[client].puts message
  end

  def check_for_input(client)
    client.read_nonblock(1000).chomp
  rescue IO::WaitReadable
    false
  end

  def check_for_inputs(client)
    player_sockets[client].read_nonblock(1000).chomp.split('\n')
  rescue IO::WaitReadable
    puts "No messages waiting"
  end

  def stop
    @server.close if @server
  end
end
