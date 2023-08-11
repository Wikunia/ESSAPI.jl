using Dates
import DotEnv
using EverySingleStreet
using Printf
using JLD2
using JSON3
using Oxygen
using HTTP
using Base.Threads

DotEnv.config()
const VERIFY_TOKEN = ENV["VERIFY_TOKEN"]
const DATA_FOLDER = ENV["DATA_FOLDER"]

include("strava_api.jl")
include("utils.jl")

@get "/subscribe" function(req::HTTP.Request)
    params = queryparams(req)
    verify_token = get(params, "hub.verify_token", "")
    if verify_token != VERIFY_TOKEN
        return html(""; status=401)
    end
    return Dict{String,String}("hub.challenge" => get(params,"hub.challenge", "not available"))
end

@post "/subscribe" function(req::HTTP.Request)
    data = json(req)
    open(joinpath(DATA_FOLDER, "pushs", "$(now()).json"), "w") do io
        JSON3.pretty(io, data)
    end
    if data[:aspect_type] == "create" && data[:object_type] == "activity"
        @spawn add_activity(data[:owner_id], data[:object_id])
    end
    return "EVENT_RECEIVED"
end

serve(host="0.0.0.0", port=8000)