require 'bundler'
Bundler.require

require './lib/plugin_manager'
require 'telegram/bot'

Dotenv.load
pm = PluginManager.new("./plugins")

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

