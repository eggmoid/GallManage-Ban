require "sinatra"
require "json"

post "/block", :provides => :json do
  content_type :json

  request.body.rewind
  data = JSON.parse request.body.read

  unless data["no"]
    halt 400, { "Conteyt-Type" => "application/json" }, '{msg: "body에 no를 넣어주세요"}'
  end

  # success/fail
  # {status: 200, result: "success"}.to_json
  halt 200, { "Conteyt-Type" => "application/json" }, "{result: \"#{data["no"]}\"}"
end
