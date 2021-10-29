require "sinatra"
require "sinatra/config_file"
require "json"

require "mechanize"
require "uri"
require "net/http"

config_file "config.yml"

post "/block", :provides => :json do
  content_type :json

  request.body.rewind
  data = JSON.parse request.body.read

  unless data["no"]
    halt 400, { "Conteyt-Type" => "application/json" }, '{msg: "body에 no를 넣어주세요"}'
  end

  agent = Mechanize.new
  page = agent.get("https://gall.dcinside.com/mgallery/board/lists?id=girlgroup")

  link = page.links.select { |l| l.text == "로그인" }.first
  page = link.click

  form = page.forms.first
  form.user_id = settings.user_id
  form.pw = settings.pw
  page = form.submit

  posted = agent.post("https://dcid.dcinside.com/join/member_check.php", {
    user_id: settings.user_id,
    pw: settings.pw,
    s_url: "https%3A%2F%2Fgall.dcinside.com%2Fmgallery%2Fboard%2Flists%3Fid%3Dgirlgroup",
    tieup: "",
    url: "",
    ssl: "Y",
    checksaveid: "on",
  })

  no = data["no"]
  page = agent.get("https://gall.dcinside.com/mgallery/board/lists?id=girlgroup")

  update = agent.post("https://gall.dcinside.com/ajax/minor_manager_board_ajax/update_avoid_list", {
    ci_t: agent.cookies.select { |e| e.name == "ci_c" }.first.value,
    id: "girlgroup",
    'nos[]': [no],
    avoid_hour: "721",
    avoid_reason: "0",
    avoid_reason_txt: "명예훼손",
    del_chk: "1",
    _GALLTYPE_: "M",
  }, {
    "X-Requested-With" => "XMLHttpRequest",
    "Accept" => "application/json, text/javascript, */*; q=0.01",
    "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
  })
  content = update.content

  resp = JSON.parse content
  if resp["result"] == "fail"
    halt 400, { "Conteyt-Type" => "application/json" }, "{result: \"fail\", msg: \"#{resp["msg"]}\"}"
  end
  halt 200, { "Conteyt-Type" => "application/json" }, "{result: \"success\", msg: \"#{resp["msg"]}\"}"
end
