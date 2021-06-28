class PluginManager
    def initialize(plugin_dir)
        @plugin_dir = plugin_dir
    end

    def register
        file_names = Dir.glob("*.rb", base: @plugin_dir)
        file_names.each do | f |
            begin
                require "#{@plugin_dir}/#{f}"
            rescue LoadError => e
                puts "Load plugin failed: #{f}"
            end
        end

        @plugins_list = BotPlugins.constants.map {|const|
            BotPlugins.const_get(const)
        }.select {|const|
            const.is_a? Module # It should be a module.
        }

        puts "Loaded #{@plugins_list.count} plugins."
    end

    def my_commands()
        command_array = []
        @plugins_list.each do |plugin|
            plugin::Commands.each do |cmd|
                command_array.push({
                    command: cmd[:cmd][1..-1],
                    description: cmd[:desc][:default].nil? ? "No description available." : cmd[:desc][:default]
                })
            end
        end

        { commands: command_array }
    end

    def message_hook(message)
        command_text = message.text.split(' ').first
        @plugins_list.each do | plugin |
            command_list = plugin::Commands.select{|command| command[:cmd] == command_text}
            if command_list.first then
                return plugin::process(message)
            end
        end
        return { chat_id: message.chat.id, text: "PM: No such command! #{command_text}" }
    end

    def inline_hook(message)
    end
end
