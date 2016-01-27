require "slack_bot/realtime"

Dir["slack_bot/observers/*.rb"].each {|file| require file }
Dir["slack_bot/handlers/*.rb"].each {|file| require file }
Dir["slack_bot/kickers/*.rb"].each {|file| require file }

require "slack_bot/notifier"
require "slack_bot/seeker"
require "slack_bot/responder_destination"
require "slack_bot/responder_users"
require "slack_bot/responder_validator"
require "slack_bot/responder"

class SlackBot
  attr_reader :realtime, :target

  def initialize(target = "general")
    @target   = target
    @realtime = SlackBot::Realtime.new
  end

  def start
    r  = observe_realtime
    sn = observe_slash_notifications
    an = observe_activity_notifications
    r.join
    sn.join
    an.join
  end

  def observe_realtime
    observer = realtime_observer
    observer.on do |response|
      SlackBot::Responder.new(
        send("#{response}_handler", observer)
      ).respond if observer.text.present?
    end
  end

  def observe_slash_notifications
    slash_notifications_observer.on do |response|
      SlackBot::Responder.new(
        slash_handler(parse_response(response))
      ).respond
    end
  end

  def observe_activity_notifications
    p "obsever called"
    activity_notifications_observer.on do |response|
      kicker = "SlackBot::Kickers::#{parse_response(response).type.capitalize}"
      p "Kicker name is: #{kicker}"
      kicker.constantize.new(realtime_attributes).perform
    end
  end

  private

  def realtime_attributes(extra = {})
    {realtime: realtime, target: target}.merge(extra)
  end

  def parse_response(response)
    JSON.parse(response).to_hashugar
  end

  # Obsever methods: relatime_observer
  %w(realtime slash_notifications activity_notifications).each do |name|
    define_method("#{name}_observer") do
      "SlackBot::Observers::#{name.camelize}".constantize.new(realtime_attributes)
    end
  end

  # Handler methods: slash_handler(event)
  %i(private public slash).each do |name|
    define_method("#{name}_handler") do |event|
      "SlackBot::Handlers::#{name.capitalize}".constantize.new realtime_attributes(event: event)
    end
  end
end
