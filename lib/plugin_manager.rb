class PluginManager
    def initialize(plugin_dir, log_level = Logger::INFO)
        @plugin_dir = plugin_dir
        @logger = Logger.new(STDOUT)
        @logger.level = log_level
    end

    def register
        file_names = Dir.glob("*.rb", base: @plugin_dir)
        file_names.each do |f|
            begin
                require "#{@plugin_dir}/#{f}"
            rescue LoadError => e
                @logger.error "Load plugin failed: #{f}"
            end
        end

        @plugins_list = BotPlugins.constants.map { |const|
            BotPlugins.const_get(const)
        }.select { |const|
            const.is_a? Module # It should be a module.
        }

        @logger.info "Loaded #{@plugins_list.count} plugins."
    end

    def my_commands()
        command_array = []
        @plugins_list.each do |plugin|
            plugin::Commands.each do |cmd|
                @logger.debug "Registered command #{cmd} from plugin #{plugin}"
                command_array.push({
                                       command: cmd[:cmd][1..-1],
                                       description: cmd[:desc][:default].nil? ? "No description available." : cmd[:desc][:default]
                                   })
            end
        end

        @logger.info "Registered #{command_array.count} commands from #{@plugins_list.count} plugins."

        { commands: command_array }
    end

    def message_hook(message)
        case message
        when Telegram::Bot::Types::Message
            if message.text.nil?
                @logger.info "Command #{message.hash} issued by #{message.chat.id} has invalid text field."
                @logger.debug "Unsupported command #{message.hash}: #{message.inspect}"
                return nil
            else
                @logger.info "Command #{message.hash} issued by #{message.chat.id}: #{message.text}"
            end

            command_text = message.text.split(' ').first

            @plugins_list.each do |plugin|
                command_list = plugin::Commands.select { |command| command[:cmd] == command_text }
                if command_list.first then
                    @logger.info "Command #{message.hash} handled by plugin #{plugin}"

                    result = plugin::process(message)

                    @logger.info "Command #{message.hash} returned from plugin"
                    @logger.debug "Command #{message.hash} result: #{result}"
                    return result
                end
            end
            @logger.info "Command #{message.hash} is not handled, text: #{message.text}."

            return { chat_id: message.chat.id, text: "PM: No such command! #{command_text}" }

        when Telegram::Bot::Types::ChatMemberUpdated
            @logger.info "ChatMemberUpdated"
            return nil
        end
    end

    def inline_hook(message) end
end
