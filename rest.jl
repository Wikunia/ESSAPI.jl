import DotEnv
using Genie
import Genie.Requests: getpayload
import Genie.Renderer.Json: json

DotEnv.config()
Genie.config.run_as_server = true
VERIFY_TOKEN = ENV["VERIFY_TOKEN"]

route("/subscribe") do
    verify_token = getpayload(Symbol("hub.verify_token"))
    if verify_token != VERIFY_TOKEN
        return Genie.Responses.setstatus(401)
    end
    d = Dict{String,String}("hub.challenge" => getpayload(Symbol("hub.challenge")))
    d |> json
end

up(8000, "0.0.0.0")