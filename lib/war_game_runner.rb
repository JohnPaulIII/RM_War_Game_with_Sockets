require_relative 'war_game'

class WarGameRunner

  attr_accessor :players, :ready

  def initialize(clients)
    @players = {}
    clients.each { |client| players[client] = "" }
    @ready = Array.new(clients.length, false)
    ask_for_usernames
  end

  def create_game(player_names)

  end

  def ask_for_usernames
    players.each { |client, _| client.puts "Please provide a username:"}
  end

  def recieved_all_usernames?
    players.all? { |_, name| name != ""}
  end

  def check_for_usernames
    players.select { |_, name| name != "" }.each_pair do |client, _|

    end
  end


  # def run_game(game)
  #   return unless ready?
  #   puts "Running game"
  #   puts result = game.play_round
  #   game.player_names.each do |player|
  #     send_to_player(result, player)
  #     send_to_player("Ready?", player)
  #   end
  # end

  def is_ready?
    # gather_ready_ups
    # !ready.include?(false)
  end

  # def gather_ready_ups
  #   games_by_player.each_pair do |name, game|
  #     responses = check_for_inputs(name)
  #     next unless responses
  #     responses.each do |response|
  #       game.ready_up(name) if response
  #       puts "#{name} has readied up"
  #     end
  #   end
  # end

  def send_to_player(message, player)

  end

  def check_for_inputs(client)

  end

  def is_finished?

  end

end