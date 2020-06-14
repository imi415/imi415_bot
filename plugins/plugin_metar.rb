module BotPlugins
    module Metar
        Name = "Metar"
        Commands = ["/metar", "/taf"]

        def self.process(message)
            icao = message.text.split(' ').last
            command = message.text.split(' ').first

            # Make that request!
            begin
                response = Faraday.get("https://avwx.rest/api/metar/#{icao}") do | req |
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
            "`#{response_json["raw"]}`"

        end
    end
end