local template = require("resty.template")
local cjson = require("cjson")
local cjson_safe = require("cjson.safe")
local mimetype = require("mimetype")

local response = {}

function response:new()
	local obj = {}

	setmetatable(obj, self)
	self.__index = self

	-- 默认返回内容
	ngx.header["Content-Type"] = mimetype.html

	return obj
end

function response:set_header(key, val)
	ngx.header[key] = val
end

-- 返回视图
function response:render(view, context)
	template.render(view, context)
end

-- 发送文本
function response:send(data)
	data = data or ""
	if type(data) == "table" then
		ngx.header["Content-Type"] = mimetype.json
		data = cjson_safe.encode(data)
	else 
		data = tostring(data)
	end

	ngx.say(tostring(data))
end

return response
