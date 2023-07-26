using Genie
import Genie.Renderer.Json: json

Genie.config.run_as_server = true

route("/") do
  (:message => "Hi there!") |> json
end

up()