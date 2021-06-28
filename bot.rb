require 'bundler'
Bundler.require

require './lib/plugin_manager'
require 'telegram/bot'

Dotenv.load
pm = PluginManager.new("./plugins")

pm.register


begin
  Telegram::Bot::Client.run(ENV["BOT_TOKEN"]) do |bot|
        bot.api.set_my_commands pm.my_commands
        bot.listen do | message |
            bot.api.send_message pm.message_hook(message)
        end
    end
rescue Telegram::Bot::Exceptions::ResponseError => e
    p "Caught a response error message! #{e}"
end

