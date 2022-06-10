require 'socket'
require 'pry'
require_relative 'war_game'

class WarSocketServer

  PLAYER_COUNT = 2

  attr_accessor :player_sockets, :games, :games_by_player, :unfinished_sockets, :server
  attr_reader :logging

  def initialize(logging: true)
    @unfinished_sockets = []
    @player_sockets = {}
    @games_by_player = {}
    @games = []
    @logging = logging
  end

  def puts(text)
    super(text) if logging
  end

  def port_number
    3336
  end

  def start
    @server = TCPServer.new(port_number)
    #END { @server.close if @server }
    puts "Server has started"
  end

  def stop
    @server.close if @server
  end

  def accept_new_player
    client = @server.accept_nonblock
    puts "New Connection" if client
    check_for_player_name(client, add_to_unfinished: true, ask_for_username: true) if !client.nil?
  rescue IO::WaitReadable, Errno::EINTR
    #puts "skip"
  end

  def accept_new_client(name)
    client = @server.accept_nonblock
    puts "New Connection" if client
    add_to_player_sockets(client, name) if !client.nil?
  rescue IO::WaitReadable, Errno::EINTR
    #puts "skip"
  end

  def check_for_player_name(client, add_to_unfinished: false, ask_for_username: false)
    response = check_for_input(client)
    if !response && ask_for_username
      send_to_socket("Please provide a username:", client)
      unfinished_sockets.push(client) if add_to_unfinished
    elsif player_sockets.keys.include?(response)
      send_to_socket("Username already exists, please choose a different name:", client) if response
      unfinished_sockets.push(client) if add_to_unfinished
    elsif response
      puts "New Player: #{response}"
      add_to_player_sockets(client, response, add_to_unfinished: add_to_unfinished)
    end
  end

  def add_to_player_sockets(client, name, add_to_unfinished: false)
    if name
      player_sockets[name] = client
      unfinished_sockets.delete(client) if !add_to_unfinished
      send_to_player("Waiting for more players", name)
    else
      unfinished_sockets.push(client) if add_to_unfinished
    end
  end

  def resolve_players
    return if unfinished_sockets == []
    unfinished_sockets.each { |socket| check_for_player_name(socket) }
  end

  def create_game_if_possible
    return unless player_sockets.length > (games.length + 1) * PLAYER_COUNT - 1
    players = (0..PLAYER_COUNT - 1).map { |i| player_sockets.keys[games.length * 2 + i] }
    game = new_game(players)
    games.push(game)
    assign_players(players, game)
  end

  def assign_players(players, game)
    players.each do |player|
      games_by_player[player] = game
      other_players = players.reject { |name| name == player}.join(", ")
      send_to_player("You have joined a game with #{other_players}.  Ready?", player)
    end
  end

  def send_to_socket(message, client)
    client.puts message
  end

  def send_to_player(message, name)
    player_sockets[name].puts message
  end

  def check_for_input(client)
    client.read_nonblock(1000).chomp
  rescue IO::WaitReadable
    false
  end

  def check_for_inputs(client)
    player_sockets[client].read_nonblock(1000).chomp.split('\n')
  rescue IO::WaitReadable
    #puts "No messages waiting"
  end

  def new_game(players)
    game = WarGame.new(players)
    game.start
    game
  end

  #Should be demoted to WarGameRunner
  def gather_ready_ups
    games_by_player.each_pair do |name, game|
      responses = check_for_inputs(name)
      next unless responses
      responses.each do |response|
        game.ready_up(name) if response
        puts "#{name} has readied up"
      end
    end
  end

  #Rewrite to interact with WarGameRunner instead
  def run_rounds
    games.each do |game|
      if game.is_ready?
        run_game(game)
        remove_game_if_finished(game)
      end
    end
  end

  #Should be demoted to WarGameRunner
  def run_game(game)
    #WarGameRunner.run_game()
    puts "Running game"
    puts result = game.play_round
    game.player_names.each do |player|
      send_to_player(result, player)
      send_to_player("Ready?", player)
    end
  end
  
  def remove_game_if_finished(game)
    return unless game.is_finished?
    garbage_removal(game)
    games.delete(game)
    puts "A game has been removed"
  end

  def garbage_removal(game)
    game.player_names.each do |player|
      games_by_player.delete(player)
      send_to_player(game.finish_message, player)
      player_sockets[player].close
      player_sockets.delete(player)
      puts "#{player} has been removed"
    end
  end

  def run_server
    start
    while true
      accept_new_player
      resolve_players
      create_game_if_possible
      gather_ready_ups
      run_rounds
    end
  end
end
