
local nws = commonlib.gettable("nws")
local controller = commonlib.gettable("nws.controller")

function controller:new(ctrl_name, model_name)
	local obj = {}

	if not ctrl_name then
		obj = commonlib.gettable("nws.controller." .. ctrl_name)
	end

	model_name = model_name or ctrl_name

	setmetatable(obj, self)
	self.__index = self

	obj:set_model_name(model_name)

	return obj
end

-- 设置模型名
function controller:set_model_name(model_name)
	if not model_name then
		return
	end

	self.model_name = model_name
	--self.model = nws.import('model.' .. model_name)
	xpcall(function()
		self.model = nws.import('model/' .. model_name)
	end, function(e)
		log(e)
	end)
end

-- 设置模型
function controller:set_model(model)
	self.model = model
end

-- READ RESOURCE
function controller:get(ctx)
	if not self.model then
		ctx.response:send("无效model", 500)
	end

	local url_params = ctx.request.url_params or {}
	local params = ctx.request:get_params()

	params.id = url_params[1] or params.id

	local data = self.model:find(params) or {}
	if params.id and #data > 0 then
		data = data[1]
	end

	ctx.response:send(data, 200)
end

-- UPDATE RESOURCE
function controller:put(ctx)
	if not self.model then
		ctx.response:send("无效model", 500)
	end
	
	local url_params = ctx.request.url_params or {}
	local params = ctx.request:get_params()
	local id = url_params[1] or params.id

	if not id then
		ctx.response:send("缺少资源id", 400)
	end

	local err, data = self.model:update({id=id}, params)

	if err then
		ctx.response:send(err, 400)
	else
		ctx.response:send(data, 200)
	end

	return
end

-- CREATE RESOURCE
function controller:post(ctx)
	if not self.model then
		ctx.response:send("无效model", 500)
	end

	local params = ctx.request:get_params()

	local err, data = self.model:insert(params)

	if err then
		ctx.response:send(err, 400)
	else
		ctx.response:send(data, 200)
	end

	return nil
end

-- DELETE RESOURCE
function controller:delete(ctx)
	nws.log(self.model:get_idname())
	if not self.model then
		ctx.response:send("无效model", 500)
	end

	local url_params = ctx.request.url_params or {}
	local params = ctx.request:get_params() or {}
	
	local id = url_params[1] or params.id
	params[self.model:get_idname()] = id

	if not id then
		ctx.response:send("缺少资源id", 400)
		return 
	end

	local err, data = self.model:delete(params)

	if err then
		ctx.response:send(err, 400)
	else
		ctx.response:send(data, 200)
	end

	return
end

function controller:view(ctx)
	if not self.model then
		ctx.response:send("无效model", 500)
	end
	local params = ctx.request:get_params()
	local fieldlist = self.model:get_field_list()
	local datalist = self.model:find(params) or {}
	local total = self.model:count(params) or 0
	local querylist = {}

	-- 查询字段
	for _, field in ipairs(fieldlist or {}) do
		if field.is_query then
			querylist[#querylist+1] = field
		end
	end

	--nws.log(fieldlist)
	local context = {
		total = total,
		fieldlist = fieldlist,
		datalist = datalist,
		querylist = querylist,
		tablename = self.model:get_tablename(),
		url_prefix = nws.config.api_url_prefix .. self.model:get_tablename(),
	}

	context.self_data = nws.util.to_json(context)

	local path_prefix = nws.get_nws_path_prefix()
	ctx.response:send(ctx.response.template.render(path_prefix .. "statics/view.html", context))
end

return controller
