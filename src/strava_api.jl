function get_access_token(user_id)
    url = "https://www.strava.com/oauth/token"
    refresh_token = readjson(joinpath(@__DIR__, "..", "data", "tokens", "$user_id.json"))[:refresh_token]

    payload = Dict(
        "client_id" => ENV["CLIENT_ID"],
        "client_secret" => ENV["CLIENT_SECRET"],
        "refresh_token" => refresh_token,
        "grant_type" => "refresh_token",
        "f" => "json"
    )

    r = HTTP.request("POST", url,
                    ["Content-Type" => "application/json"],
                    JSON3.write(payload))

    result = JSON3.read(String(r.body))
    return result[:access_token]
end

function get_activity_data(access_token, activity_id)
    url = "https://www.strava.com/api/v3/activities/$activity_id"

    headers = Dict("Authorization" => "Bearer $access_token", "Content-Type" => "application/json")

    r = HTTP.request("GET", url, headers)
    json_result = JSON3.read(String(r.body))
    return json_result
end

download_activity(user_id::Int, activity_id) = download_activity(user_id, get_access_token(user_id), activity_id)

function download_activity(user_id, access_token, activity_id, start_time)
    url = "https://www.strava.com/api/v3/activities/$activity_id/streams?keys=latlng,time"

    headers = Dict("Authorization" => "Bearer $access_token", "Content-Type" => "application/json")
    r = HTTP.request("GET", url, headers)
    
    result = copy(JSON3.read(String(r.body)))
    # convert the data into our own format
    save_data = Dict{Symbol, Any}()
    for stream in result
        if stream[:type] == "latlng"
            save_data[:latlon] = stream[:data]
        elseif stream[:type] == "time"
            save_data[:times] = stream[:data] 
        end
    end

    save_data[:start_time] = start_time
    path = joinpath(@__DIR__, "..", "data", "activities", "$user_id", "$activity_id.json")
    mkpath(dirname(path))
    open(path, "w") do io
        JSON3.pretty(io, save_data)
    end
end

function set_activity_fields(access_token, activity_id, payload)
    url = "https://www.strava.com/api/v3/activities/$activity_id"
    headers = Dict("Authorization" => "Bearer $access_token", "Content-Type" => "application/json")

    r = HTTP.request("PUT", url,
                    headers,
                    JSON3.write(payload))

    result = JSON3.read(String(r.body))
    return result
end

function prepend_activity_description(access_token, activity_data, desc)
    current_desc = activity_data[:description]
    new_desc = desc
    if !isnothing(current_desc)
        new_desc = "$new_desc\n$current_desc"
    end
    set_activity_fields(access_token, activity_data[:id], Dict(:description => strip(new_desc)))
end

function add_activity(user_id, activity_id)
    access_token = get_access_token(user_id)
    activity_data = get_activity_data(access_token, activity_id)
    start_time = activity_data[:start_date]
    download_activity(user_id, access_token, activity_id, start_time)
    travelled_distance_km = activity_data[:distance]/1000
    travelled_distance_str = @sprintf "Travel distance: %.2f km" travelled_distance_km 
    prepend_activity_description(access_token, activity_data, travelled_distance_str)
end