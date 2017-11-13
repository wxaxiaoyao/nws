local current_dir = debug.getinfo(1,'S').source:match('^[@%./\\]*(.+[/\\])[^/\\]+$')

NPL.load(current_dir .. "nws.lua")

local handler = nws.gettable("nws.handler")

handler.MSG_TYPE_REQUEST_BEGIN = 1
handler.MSG_TYPE_REQUEST_FINISH = 2 

function handler:init_child_threads() 
	print("------------------init_child_threads-------------------")
	if self.is_inited then
		return 
	end
	
	self.thread_count = nws.config.thread_count or 40
	self.threads = {}
	for i = 1, self.thread_count do
		local thread_name = "worker_" .. i
		local thread = NPL.CreateRuntimeState(thread_name, 0):Start()
		handler.threads[i] = {
			thread_name = thread_name,
			msg_count = 0,
			thread = thread,
		}
		handler.threads[thread_name] = handler.threads[i]
	end
end

-- 获取请求优先级
function handler:get_level_by_url(url)
	return 5
end

function handler:get_thread_by_url(url)
	local level =  self:get_level_by_url(url)
	local min = level
	for i = level + 1, self.thread_count do
		if self.threads[min].msg_count > self.threads[i].msg_count then
			min = i
		end
	end

	return self.threads[min]
end


local function activate()
	if type(msg) ~= "table" then
		return
	end

	local thread = nil
	local url = msg.url
	local http = nws.http
	local thread_name = __rts__:GetName()

	if msg.msg_type == handler.MSG_TYPE_REQUEST_BEGIN then
		nws.http:handle(msg)

		NPL.activate("(main)" .. current_dir .. "npl_handler.lua", {
			msg_type = handler.MSG_TYPE_REQUEST_FINISH,
			thread_name = __rts__:GetName(),
		})
	elseif msg.msg_type == handler.MSG_TYPE_REQUEST_FINISH then
		thread_name = msg.thread_name
		thread = handler.threads[thread_name]
		thread.msg_count = thread.msg_count - 1
		nws.log(thread.thread_name .. " finish request, msg_count:" .. thread.msg_count)
	else
		-- http 请求
		-- 静态资源 主线程直接处理，可做缓存
		if http:is_statics(url) then
			http:handle(msg)
			return
		end

		-- http请求 交由子线程处理 
		thread = handler:get_thread_by_url(url)
		thread.msg_count = thread.msg_count + 1
		msg.msg_type = handler.MSG_TYPE_REQUEST_BEGIN

		nws.log(thread.thread_name .. " begin request, msg_count:" .. thread.msg_count)
		NPL.activate(string.format("(%s)" .. nws.get_nws_path_prefix() .. "npl_handler.lua", thread.thread_name), msg)
	end
end

NPL.this(activate)

return handler
