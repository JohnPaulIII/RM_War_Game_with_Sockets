# require_relative 'war_game'
#
# game = WarGame.new
# game.start
# until game.winner do
#   puts game.play_round
# end
# puts "Winner: #{game.winner.name}"
#

# cd repos/RoleModel/tdd_socket_card_game_war/
# ruby lib/war_runner.rb

require_relative 'war_socket_server'

server = WarSocketServer.new
server.start
#server.server.accept
puts "Recieved"
while true
  server.accept_new_player
  server.resolve_players
  server.create_game_if_possible
  server.gather_ready_ups
  server.run_rounds
end

END { server.stop }