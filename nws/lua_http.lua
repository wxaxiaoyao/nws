
local common = require("common")

local util = require("lua_util")
local request = require("lua_request")
local response = require("lua_response")
local router = require("router")
local log = require("log")

local http = {}

http.request = request
http.response = response
http.router = router
http.log = log
http.util = util

local req = request:new()
local resp = response:new()

ngx_log(req.uri)

function http:init(config)
	config = config or {}
	--self.log = log:new(config.log)
end

function http:handle()
	router:handle(req, resp)
end

return http

