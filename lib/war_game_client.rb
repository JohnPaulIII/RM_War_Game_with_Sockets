require 'socket'

class WarSocketClient

  QUERY_STRINGS = ["Please provide a username:", "Ready?"]
  PORT_NUMBER = 3336

  attr_reader :client, :logging

  def initialize(logging: true)
    @client = TCPSocket.new('localhost', PORT_NUMBER)
    @logging = logging
  end

  def puts(text)
    super(text) if logging
  end

  def query_response(text)
    QUERY_STRINGS.each do |query|
      return true if text.match(query)
    end
    false
  end

  def wait_for_input(io = STDIN)
    response = io.gets
    response = "ENTER" if response == "\n"
    client.puts response
  end

  def check_for_server_output(io = STDIN)
    begin
      message = client.read_nonblock(1000).chomp
    rescue
      message = ""
    ensure
      puts message
      wait_for_input(io) if query_response(message)
      message
    end
  end

  def run_client
    while true
      check_for_server_output
    end
  end
end