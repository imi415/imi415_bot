require 'bundler'
Bundler.require

require './lib/plugin_manager'
require 'telegram/bot'

Dotenv.load
pm = PluginManager.new("./plugins")

pm.register

begin
    Telegram::Bot::Client.run(ENV["BOT_TOKEN"]) do |bot|
        bot.listen do | message |
            bot.api.send_message(chat_id: message.chat.id, text: pm.message_hook(message))
        end
    end
rescue Telegram::Bot::Exceptions::ResponseError
    p "Caught a response error message!"
end