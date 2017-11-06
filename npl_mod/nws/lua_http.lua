
local util = nws.gettable("nws.util")
local request = nws.gettable("nws.request")
local response = nws.gettable("nws.response")
local router = nws.gettable("router")
local log = nws.gettable("log")

local http = {}

http.request = request
http.response = response
http.router = router
http.log = log
http.util = util

--local req = request:new()
--local resp = response:new()

--ngx_log(req.uri)

function http:init(config)
	config = config or {}
	--self.log = log:new(config.log)
end

function http:handle()
	--router:handle(req, resp)
end

return http

