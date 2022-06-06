require 'socket'

# load 'quick_client_startup.rb'

#client1.close if defined? client1
#client1 = nil if defined? client1
#client2.close if defined? client2
#client2 = nil if defined? client2


#server = TCPServer.new('localhost', 3336)

PLAYERS = ["Josh", "William", "Braden", "Caleb", "Jeremy"]
players = 2
client = []

(0..players - 1).each do |i|
  client[i] = TCPSocket.new('localhost', 3336)
  sleep(0.1)
  puts client[i].read_nonblock(1000)
  sleep(0.1)
  client[i].puts PLAYERS[i]
  puts PLAYERS[i]
  sleep(0.1)
end
escape = false
while !escape
  (0..players - 1).each do |i|
    client[i].puts 'yes' 
    sleep(0.01)
  end
  result = client[0].read_nonblock(1000)
  puts result
  (1..players - 1).each do |i|
    #client[i].read_nonblock(1000)
  end
  escape = /!/.match?(result)
end


END {
  client1.close
  client2.close
  puts "Shutting Down..."
}
