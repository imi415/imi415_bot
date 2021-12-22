require 'logger'

require 'bundler'
Bundler.require

require './lib/plugin_manager'
require 'telegram/bot'

Dotenv.load

log_level = Logger::WARN

unless ENV['LOG_LEVEL'].nil? then
    case ENV["LOG_LEVEL"]
    when "DEBUG"
        log_level = Logger::DEBUG
    when "INFO"
        log_level = Logger::INFO
    when "WARN"
        log_level = Logger::WARN
    when "ERROR"
        log_level = Logger::ERROR
    when "FATAL"
        log_level = Logger::FATAL
    when "UNKNOWN"
        log_level = Logger::UNKNOWN
    else
        puts "Unkown log level #{ENV["LOG_LEVEL"]}"
    end
end

pm = PluginManager.new("./plugins", log_level)

pm.register


Telegram::Bot::Client.run(ENV["BOT_TOKEN"]) do |bot|
    bot.api.set_my_commands pm.my_commands
    bot.listen do | message |
        begin
            bot.api.send_message pm.message_hook(message)
        rescue Telegram::Bot::Exceptions::ResponseError => e
            p "Telegram API error: #{e}"
        end
    end
end

