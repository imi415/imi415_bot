module BotPlugins
    module Metar
        Name = "Metar"
        Commands = ["/metar", "/taf"]

        def self.process(message)
            command_array = message.text.split(' ')
            if command_array.length != 2 then
                return "Usage: <pre>/metar ICAO</pre>"
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
                return "Bad request." # Whoops!
            rescue Faraday::ResourceNotFound
                return "Not found." # This won't happen.
            end

            # Parse response body
            begin
                response_json = JSON.parse(response.body)
            rescue JSON::ParserError
                return "JSON parse error!"
            end

            # We got an error
            if response_json["error"] != nil then
                return response_json["error"]
            end

            # Normal raw METAR response
            "<pre>#{response_json["raw"]}</pre>"

        end
    end
end