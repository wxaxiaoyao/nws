local current_dir = debug.getinfo(1,'S').source:match('^[@%./\\]*(.+[/\\])[^/\\]+$')

local function gettable(f, v, r)
    local t = r or _G    -- start with the table of globals
    if not f then 
		return t
	end 

    for w, d in string.gmatch(f, "([%w_]+)(.?)") do
		if d == "." then
			t[w] = t[w] or {}   -- create table if absent
		else 
			t[w] = t[w] or v or {}   -- 设置默认值
		end
		t = t[w]            -- get the table
    end 
    return t;
end

local function settable(f, v, r)
    local t = r or _G    -- start with the table of globals
	if not f then
		return 
	end

    for w, d in string.gmatch(f, "([%w_]+)(.?)") do
		if d == "." then
			t[w] = t[w] or {}   -- create table if absent
			t = t[w]            -- get the table
		else 
			t[w] = v
		end
    end 
end

local function get_nws_path_prefix()
	if server_type == "npl" then
		--return "nws."
		return current_dir
	else
		return current_dir
	end
end

local function import(modname)
	if server_type == "npl" then
		return NPL.load(modname .. ".lua")
		--return NPL.load(modname)
	else
		return require(modname)
	end
end

local nws = gettable("nws")

server_type = server_type or "npl"
-- 通过全局arg参数识别类型
if arg then
	server_type = "lua"
	print("LUA PROGRAME")
else
	server_type = "npl"
	print("NPL PROGRAME")
end

nws.gettable = gettable
nws.settable = settable
nws.import = import
nws.server_type = server_type
nws.get_nws_path_prefix = get_nws_path_prefix

function nws.inherit(base, derived)
	derived = derived or {}
	
	-- 创建子类
	base = base or {}

	if type(base.new) == "function" then
		base = base.new(base)
	end

	local _inherit = function(t, k)
		local mt = getmetatable(t)

		if not mt then
			return mt
		end

		local pos = string.find(k, '_')
		if pos == 1 then
			return nil
		end
		
		local value = mt[k]

		if value and type(value) == "function" then
			return function(self, ...)
				return value(mt, ...)
			end
		end

		return value
		--return mt[k]
	end

	setmetatable(derived, base)
	base.__index = _inherit

	base._derived_class = derived
	derived._base_class = base

	derived.new = function(self)
		-- self <=> derived
		local obj = {}

		setmetatable(obj, self)
		self.__index = _inherit

		self._derived_class = obj
		obj._base_class = self

		-- 调用子类构造函数
		if type(base.ctor) == "function" then
			base:ctor()
		end

		-- 调用派生类构造函数
		if type(self.ctor) == "function" then
			self.ctor(obj)
		end

		return obj
	end

	return derived
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

-- 处理函数
nws.handle = function(msg)
	nws.http:handle(msg)
end

-- 初始化server
function init()
	-- 服务器类型 npl lua
	nws.server_log("----------------------init---------------------")
	local nws_path_prefix = get_nws_path_prefix()
	if server_type == "npl" then
		NPL.load("(gl)script/ide/commonlib.lua")
		NPL.this(function() end)
	else
		commonlib = import(nws_path_prefix .. "commonlib")
	end

	-- 加载配置
	local config = nws.config
	if not config then
		local ok, errinfo = pcall(function()
			config = import("config")
			if not config then
				nws.server_log("使用默认配置文件...")
			end
			config = config or import(nws.get_nws_path_prefix() .. "config")
		end)
	end

	nws.server_log("----------------load config finish-------------")

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

	nws.test = import(nws_path_prefix .. "test")
	nws.orm:init(config.database)
	
	-- 加载入口文件
	if config.index then
		nws.server_log("load index file")
		pcall(function()
			nws.import(config.index)
		end)
	end

	if __rts__:GetName() == "main" then
		if config.use_inner_server then
			nws.start()
		end
	end
end

-- 启动server接口
nws.start = function()
	nws.server_log("启动NPL Server...")
	if nws.is_start then
		return 
	end
	nws.http:start(nws.config)
	nws.is_start = true
end

-- 程序退出
nws.exit = function()
	if nws.server_type == "npl" then
		NPL.load("(gl)script/ide/timer.lua")
		commonlib.TimerManager.SetTimeout(function()  
			exit(0)
		end, 1000)
	end
end

-- 服务器内部日志
nws.server_log = function(msg)
	if nws.config and nws.config.server_log then
		if nws.log then
			nws.log(msg)
		else
			print(msg)
		end
	end
end

init()

return nws
