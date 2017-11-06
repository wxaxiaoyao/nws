nws = nws or {}

local is_start = false
local server_type = "npl"

-- 通过全局arg参数识别类型
if arg then
	server_type = "lua"
	print("LUA PROGRAME")
else
	server_type = "npl"
	print("NPL PROGRAME")
end

local function get_nws_path_prefix()
	if server_type == "npl" then
		return "nws/"
	else
		return "npl_package/nws/npl_mod/nws/"
	end
end

local function import(modname)
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
	local nws_path_prefix = get_nws_path_prefix()


	if server_type == "npl" then
		NPL.load("(gl)script/ide/commonlib.lua")
		NPL.this(function() end)
	else
		commonlib = import(nws_path_prefix .. "commonlib")
	end

	nws = import(nws_path_prefix .. "nws")

	nws.get_nws_path_prefix = get_nws_path_prefix
	nws.import = import
	nws.config = config
	nws.orm = import(nws_path_prefix .. "orm")
	nws.router = import(nws_path_prefix .. "router")
	nws.controller = import(nws_path_prefix .. "controller")
	nws.mimetype = import(nws_path_prefix .. "mimetype")
	nws.request = import(nws_path_prefix .. server_type .. "_request")
	nws.response = import(nws_path_prefix .. server_type .. "_response")
	nws.http = import(nws_path_prefix .. server_type .. "_http")
	nws.util = import(nws_path_prefix .. server_type .. "_util")
	nws.log = import(nws_path_prefix .. server_type .. "_log")
	nws.cache = import(nws_path_prefix .. server_type .. "_cache")

	nws.orm:init(config.database)
end


-- 启动server
function start()
	if is_start then
		print("服务器已启动...")
		return 
	end

	-- 加载配置
	local config = nws.config
	if not config then
		local ok, errinfo = pcall(function()
			config = import("config")
			if not config then
				print("使用默认配置文件...")
			end
			config = config or import(nws.get_nws_path_prefix() .. "config")
		end)
	end

	-- 初始化服务器
	init(config)

	-- 使用内置server
	if config.use_inner_server then
		-- 加载入口文件
		pcall(function()
			nws.import("index")
		end)

		nws.log("启动服务器...")
		nws.http:start(config)
	end

	nws.handle = function(msg)
		nws.http:handle(msg)
	end

	is_start = true
end

start()

