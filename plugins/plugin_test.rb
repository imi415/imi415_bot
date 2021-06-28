module BotPlugins
    module Test
        Name = "Test"
        Commands = [
            { cmd: "/test", desc: { default: "A test command." }}
        ]

        def self.process(message)
          { chat_id: message.chat.id, text: "<pre>This is a test plugin.</pre>" }
        end
    end
end

