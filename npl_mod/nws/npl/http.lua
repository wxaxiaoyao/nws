local handler = nws.import(nws.get_nws_path_prefix() .. "npl/handler")
local util = commonlib.gettable("nws.util")
local request = commonlib.gettable("nws.request")
local response = commonlib.gettable("nws.response")
local router = commonlib.gettable("nws.router")
local filter = commonlib.gettable("nws.filter")

--local log = import("log")

local http = {
	is_start = false,
}

http.request = request
http.response = response
http.router = router
http.util = util
http.filter = filter

local ctx = {}

function http:init(config)

end

-- 静态文件处理
function http:statics(ctx)
	local req, resp = ctx.request, ctx.response
	local url = req.url
	local path = url:match("([^?]+)")
	local ext = path:match('^.+%.([a-zA-Z0-9]+)$')
	
	local statics_dir = nws.config.statics_dir or nws.default_config.statics_dir
	local prefix, sub_path = path:match("/([^/]+)(.*)")
	local dir = statics_dir[prefix or ""]
	if not dir or not ext then
		return false
	end

	path = dir .. sub_path;
	resp:send_file(path)

	return true
end

function http:start(config)
	if self.is_start then
		return 
	end

	-- 创建子线程
	handler:init_child_threads()

	local filename = nws.get_nws_path_prefix() .. "npl/handler.lua"
	local port = config.port or 8888

	NPL.AddPublicFile(filename, -10)
	NPL.StartNetServer("0.0.0.0", tostring(port))
end

function http:handle(msg)
	if not msg then
		return 
	end

	ctx.request = request:init(msg)
	ctx.response = response:init(ctx.request)

	log(ctx.request.method .. " " .. ctx.request.url .. "\n")
	
	if self:statics(ctx) then
		return
	end

	self:do_filter(ctx, http.filter, 1)
end

-- 处理webserver请求
function http:handle_request(obj)
	if not obj then
		return 
	end

	self:handle(obj.headers)
end

-- 注册过滤器
function http:register_filter(filter_func)
	table.insert(self.filter, filter_func)
end

-- 执行过滤器
function http:do_filter(ctx, filters, i)
	if not filters or i > #filters then
		local ret = self:do_handle(ctx)
		if not ctx.response:is_send() then
			ctx.response:send(ret)
		end
		return 
	end

	(filters[i])(ctx, function()
		http:do_filter(ctx, filters, i+1)
	end)
end

-- 执行请求处理
function http:do_handle(ctx)
	local data, manual_send = router:handle(ctx)
	-- 确保成功发送
	if not manual_send then
		ctx.response:send(data)
	end
end

-- 是否是静态资源
function http:is_statics(url)
	local path = url:match("([^?]+)")
	local ext = path:match('^.+%.([a-zA-Z0-9]+)$')
	
	if not ext then
		return false
	end

	return true
end

return http
