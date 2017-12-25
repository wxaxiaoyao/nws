local util = nws.gettable("nws.util")

local request = {}

function request:init()
	self.content_length = ngx.var.content_length
	self.content_type = ngx.var.content_type
	self.document_root = ngx.var.document_root
	self.document_uri = ngx.var.document_uri
	self.host = ngx.var.host
	self.request_method = ngx.var.request_method
	self.remote_addr = ngx.var.remote_addr
	self.remote_port = ngx.var.remote_port
	self.remote_user = ngx.remote_user
	self.request_filename = ngx.var.request_filename -- 请求文件名
	self.request_uri = ngx.var.request_uri -- 带参数uri
	self.query_string = ngx.var.query_string -- 参数 args相同
	self.scheme = ngx.var.scheme -- 协议
	self.server_protocol = ngx.var.server_protocol -- 协议版本
	self.server_addr = ngx.var.server_addr
	self.server_port = ngx.var.server_port
	self.server_name = ngx.var.server_name
	self.uri = ngx.var.uri -- 不带参数uri
	self.args = ngx.var.args

	self.headers = ngx.req.get_headers()

	local authorization = self.headers['authorization']
	local token = authorization and authorization:match("%s+(%S+)")
	self.payload = util.decode_jwt(token or "")

	if self.query_string then
		self.params = ngx.req.get_uri_args() or {}
	elseif self.content_type then
		--ngx_log(self.content_type)
		--ngx_log(self.headers)
		ngx.req.read_body()
		if (string.find(self.content_type, "application/x-www-form-urlencoded")) then
			self.params = ngx.req.get_post_args() or {}
		elseif (string.find(self.content_type, "application/json")) then
			self.params = util.from_json(ngx.req.get_body_data())
		else
			self.params = ngx.req.get_body_data()
		end
	else
	end
end

function request:new()
	local obj = {}

	setmetatable(obj, self)
	self.__index = self
	
	obj:init()

	return obj
end

function request:get_params() 
	return self.params
end

function request:dump()
	ngx.header["Content-Type"] = "text/html"
end

return request
