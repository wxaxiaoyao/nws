
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

function http:init(config)

end

-- 静态文件处理
function http:statics(req, resp)
	local url = req.url
	local path = url:match("([^?]+)")
	local ext = path:match('^.+%.([a-zA-Z0-9]+)$')
	
	if not ext then
		return false
	end

	resp:send_file(path, ext)

	return true
end

function http:handle(config)
	if self.is_start then
		return 
	end

	local debug_info = debug.getinfo(1, 'S')
	local filename = debug_info.source:match("@?(.*)")
	--log(filename)
	--log(filename:match("@?(.*)"))
	--log(debug.getinfo(1,'S').source:match('^[@%./\\]*(.+[/\\])[^/\\]+$'))
	
	local port = config.port or 8888
	NPL.AddPublicFile(filename, -10)
	NPL.StartNetServer("0.0.0.0", tostring(port))
end

-- 注册过滤器
function http:register_filter(filter_func)
	table.insert(self.filter, filter_func)
end

-- 执行过滤器
local function do_filter(ctx, filters, i)
	if not filters or i > #filters then
		do_handle(ctx)
		return 
	end

	(filters[i])(ctx, function()
		do_filter(ctx, filters, i+1)
	end)
end

-- 执行请求处理
function do_handle(ctx)
	local data, manual_send = router:handle(ctx)
	-- 确保成功发送
	if not manual_send then
		ctx.response:send(data)
	end
end

function activate()
	if not msg then
		return 
	end

	local req = request:new(msg)
	local resp = response:new(req)
	local ctx = {
		request = req,
		response = resp,
	}

	log(req.method .. " " .. req.url .. "\n")
	--log(req.path .. "\n")
	
	if http:statics(req, resp) then
		return
	end

	do_filter(ctx, http.filter, 1)
end

--http:register_filter(function(ctx, do_next)
	--log("this is filter 1")
	--do_next()
--end)

--http:register_filter(function(ctx, do_next)
	--log("this is filter 2")
	--do_next()
--end)

--NPL.export(http)
NPL.this(activate)

return http
