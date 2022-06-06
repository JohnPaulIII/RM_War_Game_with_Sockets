require 'socket'

class WarSocketClient

  QUERY_STRINGS = ["Please provide a username:", "Ready?"]

  def query_response(text)
    QUERY_STRINGS.each do |query|
      return true if text.match(query)
    end
    false
  end

  def wait_for_input(client)
    response = STDIN.gets
    response = "ENTER" if response == "\n"
    client.puts response
  end

  def check_for_queries(client)
    begin
      message = client.read_nonblock(1000).chomp
      puts message
      if query_response(message)
        wait_for_input(client)
      end
    rescue
    end
  end

  def run_client
    client = TCPSocket.new('localhost', 3336)
    while true
      check_for_queries(client)
    end
  end
end