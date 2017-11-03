nws = nws or nil

local is_start = false
local server_type = "npl"

function import(modname)
	if server_type == "npl" then
		return NPL.load(modname .. ".lua")
	else
		return require(modname)
	end
end

-- 初始化server
function init(config)
	-- 服务器类型 npl lua
	server_type = config.server_type or server_type
	nws = import("nws/src/nws")

	if server_type == "npl" then
		NPL.load("(gl)script/ide/commonlib.lua")
		NPL.this(function() end)
	else
		commonlib = import("nws/src/commonlib")
	end

	nws.import = import
	nws.config = config
	nws.orm = import("nws/src/orm")
	nws.router = import("nws/src/router")
	nws.controller = import("nws/src/controller")
	nws.mimetype = import("nws/src/mimetype")
	nws.request = import("nws/src/" .. server_type .. "_request")
	nws.response = import("nws/src/" .. server_type .. "_response")
	nws.http = import("nws/src/" .. server_type .. "_http")
	nws.util = import("nws/src/" .. server_type .. "_util")
	nws.log = import("nws/src/" .. server_type .. "_log")
	nws.cache = import("nws/src/" .. server_type .. "_cache")

	nws.orm:init(config.database)
end


-- 启动server
function start()
	if is_start then
		print("服务器已启动...")
		return 
	end

	-- 加载配置
	local config = nil
	local ok, errinfo = pcall(function()
		config = require("config")
		config = config or require("nws.config")
	end)
	if not ok then
		print("使用默认配置文件...")
	end

	-- 初始化服务器
	init(config)

	-- 加载入口文件
	pcall(function()
		nws.import("index")
	end)

	-- 启动服务器
	nws.log("启动服务器...")
	nws.http:handle(config)
	is_start = true
end

start()

