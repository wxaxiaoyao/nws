
commonlib = commonlib or nil
local server_type = "npl"
local server_type_lua = "lua"
local server_type_npl = "npl"

local default_config = {
	server_type = "npl",
	server_ip = nil,
	server_port = 8888,
	database = {
		db_type = "mysql",
		tabledb = {             -- tabledb 数据库配置
			path = "database/", -- 数据库路径
			-- sync_mode = true,   -- 是否为异步模式
		},

		mysql = {                   -- mysql 数据库配置
			db_name = "keepwork",   -- 数据库名
			username = "wuxiangan", -- 账号名
			password = "wuxiangan", -- 账号密码
			host = "127.0.0.1",     -- 数据库ip地址
			port = 3306,            -- 数据库端口
		}
	}
}

local nws = require("nws/nws")

-- 初始化server
nws.init = function(config)
	self = nws

	config = config or default_config 

	-- 服务器类型 npl lua
	server_type = config.server_type or "npl"

	if server_type == "npl" then
		NPL.load("(gl)script/ide/commonlib.lua")
		NPL.this(function() end)
	else
		commonlib = require("nws/commonlib")
	end

	self.is_start = false
	self.config = config
	--self.orm = self.import("nws/orm")
	self.orm = require("nws/orm") -- NPL.load 同时存在同名文件与目录报错
	self.router = self.import("nws/router")
	self.controller = self.import("nws/controller")
	self.mimetype = self.import("nws/mimetype")
	self.request = self.import("nws/" .. server_type .. "_request")
	self.response = self.import("nws/" .. server_type .. "_response")
	self.http = self.import("nws/" .. server_type .. "_http")
	self.util = self.import("nws/" .. server_type .. "_util")
	self.log = self.import("nws/" .. server_type .. "_log")

	self.orm:init(config.database)
end

---- 添加路由
--nws.router = function(path, controller, desc)
	
--end


-- 启动server
nws.start = function()
	self = nws

	if self.is_start then
		print("服务器已启动...")
		return 
	end


	self.http:handle(self.config)
end

return nws

