function readjson(fpath)
    json_string = read(fpath, String)
    return copy(JSON3.read(json_string))
end