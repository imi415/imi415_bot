module BotPlugins
    class ResistorHelper
       E96_TABLE = [
           1.00, 1.02, 1.05, 1.07, 1.10, 1.13, 1.15, 1.18,
           1.21, 1.24, 1.27, 1.30, 1.33, 1.37, 1.40, 1.43,
           1.47, 1.50, 1.54, 1.58, 1.62, 1.65, 1.69, 1.74,
           1.78, 1.82, 1.87, 1.91, 1.96, 2.00, 2.05, 2.10,
           2.15, 2.21, 2.26, 2.32, 2.37, 2.43, 2.49, 2.55,
           2.61, 2.67, 2.74, 2.80, 2.87, 2.94, 3.01, 3.09,
           3.16, 3.24, 3.32, 3.40, 3.48, 3.57, 3.65, 3.74,
           3.83, 3.92, 4.02, 4.12, 4.22, 4.32, 4.42, 4.53,
           4.64, 4.75, 4.87, 4.99, 5.11, 5.23, 5.36, 5.49,
           5.62, 5.76, 5.90, 6.04, 6.19, 6.34, 6.49, 6.65,
           6.81, 6.98, 7.15, 7.32, 7.50, 7.68, 7.87, 8.06,
           8.25, 8.45, 8.66, 8.87, 9.09, 9.31, 9.53, 9.76
       ]

       E96_MULTIPLIER = {
           "A" => 1, "B" => 10, "C" => "100", "D" => 1000, "E" => 10000, "F" => 100000,
           "H" => 10, "X" => 0.1, "S" => 0.1, "Y" => 0.01, "R" => 0.01, "Z" => 0.001
       }

      def smd_code_to_value
           return "0"
        end
    end

    module Resistor
        # The name of the plugin, not used.
        Name = "Resistor"

        # Register the following commands with this plugin
        Commands = [
            {cmd: "/srvalue", desc: {default: "Find SMD resistor value"}}
        ]
    
        # It will be called when a message start with above commands is received, do what you want here!
        def self.process(message)
            command_list = message.text.split(' ')
            command = command_list.first[1..-1]

            case command
            when "srvalue" then
                smd_code = command_list.last
                return { chat_id: message.chat.id, parse_mode: "HTML", text: "Code: #{smd_code}, value: #{smd_value}Ω, #{smd_percision}" }
            end
        end
    end
end

