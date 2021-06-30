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
            command = command_array.first[1..-1]
            response = "Invalid command"

            case command
            when "metar" then
                response = AvwxMetarHelper::handle_metar(command_array.last)
            when "taf" then
                response = AvwxMetarHelper::handle_taf(command_array.last)
            end

            # Normal raw METAR response
            { chat_id: message.chat.id, parse_mode: "HTML", text: response }
        end

        class AvwxMetarHelper
            class << self
                METAR_CLOUDS = {
                    "BKN" => "Broken",
                    "FEW" => "Few",
                    "OVC" => "Overcast",
                    "SCT" => "Scattered",
                    "SKC" => "Clear",
                    "NCD" => "Not detected",
                    "CLR" => "Clear",
                    "VV"  => "Can not be seen"
                }

                def handle_metar(icao)
                    api_result = api_request("https://avwx.rest/api/metar/#{icao}")
                    if api_result[:has_errors] then
                        return api_result[:text]
                    end
                    api = api_result[:text]
                    # Raw
                    response = "<b>Raw: </b><pre>#{api["raw"]}</pre>\n"

                    # Airport
                    response += "<b>Station: </b>#{api["station"]}\n"

                    # Time
                    response += "<b>Time: </b>#{api["time"]["repr"]} (#{(Time.now - Time.iso8601(api["time"]["dt"])).to_i}s ago)\n"

                    # Wind
                    response += "<b>Wind: </b>#{api["wind_speed"]["value"]}#{api["units"]["wind_speed"]} at #{api["wind_direction"]["value"]} degrees"
                    unless api["wind_gust"].nil? then
                        response += ", gust #{api["wind_gust"]["value"]}#{api["units"]["wind_speed"]}"
                    end
                    unless api["wind_variable_direction"].empty? then
                        response += ", variable between #{api["wind_variable_direction"].first["value"]} and #{api["wind_variable_direction"].last["value"]} degrees"
                    end
                    response += "\n"

                    # Visibility
                    response += "<b>Visibility: </b>#{api["visibility"]["value"]}#{api["units"]["visibility"]}\n"

                    # Clouds
                    unless api["clouds"].empty? then
                        response += "<b>Clouds: </b>"
                        api["clouds"].each do |cl|
                            response += "#{METAR_CLOUDS[cl["type"]]} at "
                            if cl["altitude"].nil? then # Get rid of "BKN///"
                                response += "or below station level, "
                            else
                                response += "#{(cl["altitude"] * 100).to_s}#{api["units"]["altitude"]} AGL, "
                            end
                        end
                        response.delete_suffix!(", ")
                        response += "\n"
                    end

                    # Weather codes
                    unless api["wx_codes"].empty? then
                        response += "<b>Additional weather: </b>"
                        api["wx_codes"].each do |wx|
                            response += "#{wx["value"]}, "
                        end
                        response.delete_suffix!(", ")
                        response += "\n"
                    end

                    # Temperature and dewpoint
                    response += "<b>DHT: </b>Temperature: #{api["temperature"]["value"]}#{api["units"]["temperature"]}, "
                    response += "dewpoint #{api["dewpoint"]["value"]}#{api["units"]["temperature"]}, "
                    response += "relative humidity #{(api["relative_humidity"] * 100).round(2)}%\n"

                    # Altimeter
                    response += "<b>Altimeter: </b> #{api["altimeter"]["value"]}#{api["units"]["altimeter"]}\n"

                    # Flight rules
                    response += "<b>Flight condition: </b>#{api["flight_rules"]}"

                    response
                end

                def handle_taf(icao)
                    api_request("https://avwx.rest/api/taf/#{icao}")["raw"]
                end

                private
                def api_request(url)
                    # Make that request!
                    begin
                        response = Faraday.get(url) do | req |
                            # Params
                            req.params['format'] = 'json'
                            req.params['onfail'] = 'cache'
                            # Headers
                            req.headers['Authorization'] = ENV['METAR_APP_KEY']
                            req.headers['Content-Type'] = 'application/json'
                        end

                        { has_errors: false, text: JSON.parse(response.body) }
                    rescue Faraday::BadRequestError
                        return { has_errors: true, text: "Bad request." } # Whoops!
                    rescue Faraday::ResourceNotFound
                        return { has_errors: true, text: "Not found." } # This won't happen.
                    rescue JSON::ParserError
                        return { has_errors: true, text: "JSON parse error!" }
                    end
                end
            end
        end
    end
end

