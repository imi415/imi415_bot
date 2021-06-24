module BotPlugins
    module Test
        Name = "Test"
        Commands = ["/test"]

        def self.process(message)
          { chat_id: message.chat_id, text: "<pre>This is a test plugin.</pre>" }
        end
    end
end

