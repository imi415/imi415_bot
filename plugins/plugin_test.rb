module BotPlugins
    module Test
        Name = "Test"
        Commands = ["/test"]

        def self.process(message)
            "<pre>This is a test plugin.</pre>"
        end
    end
end