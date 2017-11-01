NPL.load('script/ide/commonlib.lua')
NPL.load('script/ide/Json.lua')
local mimetype = commonlib.gettable("nws.mimetype")
local template = require("resty.template")

local status_strings = {
    ['200'] ="HTTP/1.1 200 OK\r\n",
    ['201'] ="HTTP/1.1 201 Created\r\n",
    ['202'] ="HTTP/1.1 202 Accepted\r\n",
    ['204'] = "HTTP/1.1 204 No Content\r\n",
    ['300'] = "HTTP/1.1 300 Multiple Choices\r\n",
    ['301'] = "HTTP/1.1 301 Moved Permanently\r\n",
    ['302'] = "HTTP/1.1 302 Moved Temporarily\r\n",
    ['304'] = "HTTP/1.1 304 Not Modified\r\n",
    ['400'] = "HTTP/1.1 400 Bad Request\r\n",
    ['404'] = "HTTP/1.1 401 Unauthorized\r\n",
    ['403'] = "HTTP/1.1 403 Forbidden\r\n",
    ['404'] = "HTTP/1.1 404 Not Found\r\n",
    ['500'] = "HTTP/1.1 500 Internal Server Error\r\n",
    ['501'] = "HTTP/1.1 501 Not Implemented\r\n",
    ['502'] = "HTTP/1.1 502 Bad Gateway\r\n",
    ['503'] = "HTTP/1.1 503 Service Unavailable\r\n",
}


local response = commonlib.gettable("nws.response")


function response:new(req)
	local obj = {}
	setmetatable(obj, self)
	self.__index = self
	obj._is_send = false
	obj.request = req
	obj.charset = 'utf-8'
	obj.status = '200'
	obj.content_type = mimetype.html
	obj.headers = {
		--['status'] = '200',
		['Content-Type'] = mimetype.html
	}
	return obj
end


function response:set_status(status)
	if status then 	self.status = tostring(status) end
end


function response:set_content_type(mime_type)
	self.content_type = mime_type
	if not self.content_type then
		self:set_header('Content-Type', nil)
	else
		--self:set_header('Content-Type', mime_type .. ' charset=' .. self.charset)
		self:set_header('Content-Type', mime_type)
	end
end


function response:set_charset(charset)
	self.charset = charset
	self:set_header('Content-Type', self.content_type .. ' charset=' .. self.charset)
end


function response:set_content(data)
	self.data = data
	self:set_header('Content-Length', #data)
end


function response:set_header(key, val)
	self.headers[key] = val
end


function response:on_before()

end


function response:on_after()

end


function response:append_cookie(cookie)
	if(not self.cookies) then
		self.cookies = {}
	end
	self.cookies[#(self.cookies) + 1] = cookie
end

function response:is_send()
	return self._is_send
end

function response:_send()
	if self._is_send then
		return 
	end

	local out = {}
    out[#out+1] = status_strings[self.status]

    for name, value in pairs(self.headers) do
        out[#out+1] = format("%s: %s\r\n", name, value)
    end

	--if(self.cookies) then
		--local i = 1
		--for i = 1, #(self.cookies) do
			--local cookie = self.cookies[i]
			--out[#out + 1] = cookie:toString()
		--end
	--end

    out[#out+1] = "\r\n"
    out[#out+1] = self.data

	self._is_send = true

    NPL.activate(format("%s:http", self.request.nid), table.concat(out))
end


-- 返回视图
function response:render(view, context)
	local data = template.compile(view)(context)
	--self:set_content("<div>hello world</div>")
	self:set_content(data)

	self:_send()
end

-- 发送数据
function response:send(data, status_code)
	data = data or ""
	
	if(type(data) == 'table') then
		self:set_content_type(mimetype.json)
		data = commonlib.Json.Encode(data)
	else
		data = tostring(data)
	end

	self:set_status(status_code)
	self:set_content(data)

	self:_send()
end

-- 发送文件
function response:send_file(path, ext)
	if not path or path == "" then
		return
	end

	path = string.gsub(path, '//', '/')
	ext = ext or path:match('^.+%.([a-zA-Z0-9]+)$')

	local file = io.open("./" .. path, "rb")

	if not file then 
		self:send("文件路径错误", 404)
	end

	local content = file:read("*a")
	file:close()

	self:set_content_type(mimetype[ext])
	self:send(content)
end

-- 重定向
function response:redirect(url)
	self:set_status(302)
	self:set_header('Location', url)
	self:send()
end

return response
