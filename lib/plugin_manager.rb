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

    def message_hook(message)
        @plugins_list.each do | plugin |
            if plugin::Commands.include?(message.text.split(' ').first) then
                return plugin::process(message)
            end
        end
        return "No such command! #{message.text}"
    end
end