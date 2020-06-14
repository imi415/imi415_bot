module BotPlugins
    module Hello
        # The name of the plugin, not used.
        Name = "Hello"

        # Register the following commands with this plugin
        Commands = ["/hello", "/start", "/stop"]
    
        # It will be called when a message start with above commands is received, do what you want here!
        def self.process(message)
            "Hello World!!, #{message.chat.id}"
        end
    end
end