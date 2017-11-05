local util = nws.gettable("nws.util")

local request = {}

function request:new()
	local obj = {}

	setmetatable(obj, self)
	self.__index = self
	
	obj.content_length = ngx.var.content_length
	obj.content_type = ngx.var.content_type
	obj.document_root = ngx.var.document_root
	obj.document_uri = ngx.var.document_uri
	obj.host = ngx.var.host
	obj.request_method = ngx.var.request_method
	obj.remote_addr = ngx.var.remote_addr
	obj.remote_port = ngx.var.remote_port
	obj.remote_user = ngx.remote_user
	obj.request_filename = ngx.var.request_filename -- 请求文件名
	obj.request_uri = ngx.var.request_uri -- 带参数uri
	obj.query_string = ngx.var.query_string -- 参数 args相同
	obj.scheme = ngx.var.scheme -- 协议
	obj.server_protocol = ngx.var.server_protocol -- 协议版本
	obj.server_addr = ngx.var.server_addr
	obj.server_port = ngx.var.server_port
	obj.server_name = ngx.var.server_name
	obj.uri = ngx.var.uri -- 不带参数uri
	obj.args = ngx.var.args

	obj.headers = ngx.req.get_headers()

	local authorization = obj.headers['authorization']
	local token = authorization and authorization:match("%s+(%S+)")
	obj.payload = util.decode_jwt(token or "")

	if obj.query_string then
		obj.params = ngx.req.get_uri_args() or {}
	elseif obj.content_type then
		--ngx_log(obj.content_type)
		--ngx_log(obj.headers)
		ngx.req.read_body()
		if (string.find(obj.content_type, "application/x-www-form-urlencoded")) then
			obj.params = ngx.req.get_post_args() or {}
		elseif (string.find(obj.content_type, "application/json")) then
			obj.params = util.from_json(ngx.req.get_body_data())
		else
			obj.params = ngx.req.get_body_data()
		end
	else
	end

	return obj
end

function request:get_params() 
	return self.params
end

function request:dump()
	ngx.header["Content-Type"] = "text/html"
end

return request
