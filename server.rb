require 'em-websocket'
require 'uuidtools'
require 'yajl'
require 'colorize'

class Player
  attr_accessor :uuid
  attr_accessor :websocket
  
  def initialize socket
    @uuid = UUIDTools::UUID.random_create.to_s
    @websocket = socket
  end
end

class Phone < Player
  attr_accessor :top
  attr_accessor :left
  
end

class World

  def initialize options = {}
    @desktops = {}
    @phones = {}
    EventMachine.run do
      EventMachine::WebSocket.start(options) do |websocket|
        # websocket.onopen     { list_all_players websocket }
        websocket.onmessage  { |m| handle_message websocket, m }
        websocket.onclose    { delete_participant websocket }
        websocket.onerror    { |e| puts "Error: #{e.message}" }
      end
      puts "Server started".magenta
    end
  end
  
  def handle_message websocket, message
    yajl = Yajl::Parser.new(:symbolize_keys => true)
    hash = yajl.parse message
    if respond_to? hash[:command]
      send hash[:command], websocket, hash[:arguments]
    else
      reply websocket, {
        :command => :method_missing
      }
    end
  end
  
  def phone_has_connected websocket, arguments
    phone = Phone.new websocket
    phone.top = rand(600)
    phone.left = rand(800)
    @phones[websocket] = phone
    notify_all_desktops({
      :command => 'create_new_player',
      :arguments => [phone.uuid, phone.top, phone.left]
    })
    reply websocket, {
      :command => 'create_new_player',
      :arguments => ['this_phone', '100', '100']
    }
    puts "Phone has connected #{phone.uuid}".blue
  end
  
  def desktop_has_connected websocket, arguments
    desktop = Player.new websocket
    @desktops[websocket] = desktop
    players = @phones.collect { |websocket, phone| "#{phone.uuid}|#{phone.top}|#{phone.left}" }
    reply websocket, {
      :command => 'create_existing_players',
      :arguments => players
    }
    puts "Desktop has connected #{desktop.uuid}".green
  end
  
  def notify_all_desktops hash
    yajl = Yajl::Encoder.new
    @desktops.each do |websocket, desktop|
      websocket.send yajl.encode(hash)
    end
  end
  
  def reply websocket, hash
    yajl = Yajl::Encoder.new
    websocket.send yajl.encode(hash)
  end
      
  def delete_participant websocket
    if @desktops[websocket]
      desktop = @desktops.delete websocket
      puts "Desktop has left #{desktop.uuid}".red
    elsif @phones[websocket]
      phone = @phones.delete websocket
      notify_all_desktops({
        :command => 'remove_player',
        :arguments => [phone.uuid]
      })
      puts "Phone has left #{phone.uuid}".red
    end
  end
  
  def move websocket, arguments
    tilt_left_right = arguments[0]
    tilt_front_back = arguments[1]
    direction = arguments[2]
    notify_all_desktops({
      :command => 'move_player',
      :arguments => [@phones[websocket].uuid, tilt_left_right, tilt_front_back, direction]
    })
    
  end  
end

world = World.new :host => "0.0.0.0", :port => 8080, :debug => false
















