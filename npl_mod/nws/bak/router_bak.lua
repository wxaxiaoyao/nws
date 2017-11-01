--require("helper")
local util = require("util")

function string_split(str, sep)
	local list = {}

	for word in string.gmatch(str, sep .. '?([^' .. sep .. ']*)') do
		if word ~= "" then
			list[#list+1] = word
		end
	end

	return list
end

function file_exist(filename)
	local file = io.open(filename, "rb")
	if file then
		file:close()
	end

	return file ~= nil
end

local router = {
	handler={
		pathHandler={},
		controllerHandler={},
		groupHandler={},
		fileHandler={},
	}
}


function router:new()
	local obj = {}

	setmetatable(o, self)
	self.__index = self
	
	return obj
end

--path 为路径
--handle 为处理链
function router:path(path, handle)
	local h = nil

	if type(handle) == "function" then
		h = {handle}
	elseif type(handle) ~= "object" then
		h = {function() return handle end}
	else
		h = handle
	end

	self.handler.pathHandler[path] = h
end

function router:group(path, handle)

end

function router:controller(path, handle)
	
end


function router:filemap(path, dir, before, after) 
	local handle = function(req, resp)
		local uri = req.uri
		local pos = string.find(uri, path)
		if 1 ~= pos then
			return false
		end
		
		local filename, funcname = string.match(uri, '^' .. path .. '/([^/]*)/(.*)')
		if not filename or not funcname then
			return false
		end

		filename = dir .. '/' .. filename
		funcname = string.gsub(funcname, '/','_')
		-- 文件不存在
		if not file_exist(filename .. '.lua') then
			ngx_log("file not exist:" .. filename)
			return false
		end
		-- 加载模块
		local module = require(filename)
		local func = module[funcname]
		if not func or type(func) ~= "function" then
			ngx_log("request url nox exist")
			return false
		end
		
		return func(module, req, resp)
	end

	local handles = {}
	for _, h in ipairs(before or {}) do
		if type(h) == "function" then
			handles[#handles+1] = h
		end
	end

	handles[#handles+1] = handle

	for _, h in ipairs(after or {}) do
		if type(h) == "function" then
			handles[#handles+1] = h
		end
	end

	self.handler.fileHandler[path] = handles
end

-- 默认处理程序
function router:setDefaultHandle(handle)
	self.defaultHandle = handle
end

-- 获取处理程序
function router:getHandle(path)
	-- 优先路径匹配
	local handle = self.handler.pathHandler[path]
	
	if handle then 
		return handle
	end

	-- 组匹配
	for key, value in pairs(self.handler.groupHandler) do
		local pos = string.find(path, key)
		if pos == 1 then 
			return value
		end
	end

	-- 文件匹配
	for key, value in pairs(self.handler.fileHandler) do
		local pos = string.find(path, key)
		if pos == 1 then 
			return value
		end
	end

	return {self.defaultHandle}
end

-- 处理请求
function router:handle(req, resp)
	local handle = self:getHandle(req.uri)

	for _, func in ipairs(handle or {}) do
		local ok = func(req, resp)

		if not ok then
			break
		end
	end
end

return router
