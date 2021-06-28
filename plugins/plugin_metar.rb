module BotPlugins
    module Metar
        Name = "Metar"
        Commands = [
            { cmd: "/metar", desc: { default: "Get weather information about an airport" }},
            { cmd: "/taf", desc: { default: "Get weather forecast around an airport" }}
        ]

        def self.process(message)
            command_array = message.text.split(' ')
            if command_array.length != 2 then
                return { chat_id: message.chat.id, parse_mode: "HTML", text: "Usage: \n<pre>/metar ICAO</pre>\n<pre>/taf ICAO</pre>" }
            end

            icao = command_array.last
            command = command_array.first.slice(1, 5)

            # Make that request!
            begin
                response = Faraday.get("https://avwx.rest/api/#{command}/#{icao}") do | req |
                    # Params
                    req.params['format'] = 'json'
                    req.params['onfail'] = 'cache'
                    # Headers
                    req.headers['Authorization'] = ENV['METAR_APP_KEY']
                    req.headers['Content-Type'] = 'application/json'
                end
            rescue Faraday::BadRequestError
                return { chat_id: message.chat.id, text: "Bad request." } # Whoops!
            rescue Faraday::ResourceNotFound
                return { chat_id: message.chat.id, text: "Not found." } # This won't happen.
            end

            # Parse response body
            begin
                response_json = JSON.parse(response.body)
            rescue JSON::ParserError
                return { chat_id: message.chat.id, text: "JSON parse error!" }
            end

            # We got an error
            if response_json["error"] != nil then
                return { chat_id: message.chat.id, text: response_json["error"] }
            end

            # Normal raw METAR response
            { chat_id: message.chat.id, parse_mode: "HTML", text: "<pre>#{response_json["raw"]}</pre>" }
        end
    end
end

