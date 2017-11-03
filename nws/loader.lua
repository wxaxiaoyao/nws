
commonlib = commonlib or nil
local nws = require("nws/nws")
local config = nil

local ok, errinfo = pcall(function()
	config = require("config")
	config = config or require("nws.config")
end)

if not ok then
	print("使用默认配置文件...")
end



-- 初始化server
nws.init = function(config)
	self = nws

	-- 服务器类型 npl lua
	local server_type = config.server_type or "npl"

	if server_type == "npl" then
		NPL.load("(gl)script/ide/commonlib.lua")
		NPL.this(function() end)
	else
		commonlib = require("nws/commonlib")
	end

	self.is_start = false
	self.server_type = server_type or self.server_type

	self.config = config
	self.orm = self.import("nws/orm")
	self.router = self.import("nws/router")
	self.controller = self.import("nws/controller")
	self.mimetype = self.import("nws/mimetype")
	self.request = self.import("nws/" .. server_type .. "_request")
	self.response = self.import("nws/" .. server_type .. "_response")
	self.http = self.import("nws/" .. server_type .. "_http")
	self.util = self.import("nws/" .. server_type .. "_util")
	self.log = self.import("nws/" .. server_type .. "_log")
	self.cache = self.import("nws/" .. server_type .. "_cache")

	self.orm:init(config.database)
end

-- 路由简写
nws.get = function(path, controller)
	nws.router(path, controller, "get")
end

nws.put = function(path, controller)
	nws.router(path, controller, "put")
end

nws.post = function(path, controller)
	nws.router(path, controller, "post")
end

nws.delete = function(path, controller)
	nws.router(path, controller, "delete")
end

nws.head = function(path, controller)
	nws.router(path, controller, "head")
end

nws.patch = function(path, controller)
	nws.router(path, controller, "patch")
end

nws.options = function(path, controller)
	nws.router(path, controller, "options")
end

nws.any = function(path, controller)
	nws.router(path, controller, "any")
end

--  过滤器注册
nws.register_filter = function(filter)
	nws.http:register_filter(filters)
end

-- 启动server
nws.start = function()
	self = nws

	if self.is_start then
		print("服务器已启动...")
		return 
	end


	self.http:handle(self.config)
end

nws.init(config)
--nws.start()

return nws

