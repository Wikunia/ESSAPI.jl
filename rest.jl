import DotEnv
using Oxygen
using HTTP
using JSON3

DotEnv.config()
VERIFY_TOKEN = ENV["VERIFY_TOKEN"]

@get "/subscribe" function(req::HTTP.Request)
    params = queryparams(req)
    verify_token = get(params, "hub.verify_token", "")
    if verify_token != VERIFY_TOKEN
        return html(""; status=401)
    end
    return Dict{String,String}("hub.challenge" => get(params,"hub.challenge", "not available"))
end

@post "/subscribe" function(req::HTTP.Request)
    params = queryparams(req)
    open("latest_data.json", "w") do io
        JSON3.pretty(io, params)
    end
    return "EVENT_RECEIVED"
end

serve(host="0.0.0.0", port=8000)