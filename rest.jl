import DotEnv
using Oxygen
using HTTP

DotEnv.config()
VERIFY_TOKEN = ENV["VERIFY_TOKEN"]

@get "/subscribe" function(req::HTTP.Request)
    params = queryparams(req)
    verify_token = params["hub.verify_token"]
    if verify_token != VERIFY_TOKEN
        return html(""; status=401)
    end
    return Dict{String,String}("hub.challenge" => params["hub.challenge"])
end

serve(host="0.0.0.0", port=8000)