module BotPlugins
    module Test
        Name = "Test"
        Commands = ["/test"]

        def self.process(message)
            "This is a test plugin."
        end
    end
end