require "clockwork"
require 'config/boot'
require 'config/environment'

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  every(1.hour, "Check if somebody is active") {
    # Ping channel if nobody is active more than X hours
  }

  every(1.hour, "Check if somebody is alone :'(") {
    # Ping channel if only one person is active for certain emount of time
  }
end