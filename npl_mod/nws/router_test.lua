require("commonlib")

local router = require("router")


local ctx = {
	request = {
		method = "get"
	}
}

function print_request(ctx)
	print(ctx.request.url, "  ", ctx.request.method)
	commonlib.console(ctx)
end

function normal_router_test()
	print("----------normal router test-----------")
	router:router("/api/v0/user/login", function(ctx) print_request(ctx) end, 'get')
	ctx.request.method = "get"
	ctx.request.url = "/api/v0/user/login"
	router:handle(ctx.request.url, ctx)
	ctx.request.method = "post"
	router:handle(ctx.request.url, ctx)

	router:router("/api/v0/user/login", function(ctx) print_request(ctx) end)
	ctx.request.method = "delete"
	router:handle(ctx.request.url, ctx)
end

--normal_router_test()

function controller_router_test()
	local userController = {}

	function userController:login(ctx) print_request(ctx) end
	function userController:api_register(ctx) print_request(ctx) end

	local url_prefix = "/controller/router/user"
	ctx.request.url = url_prefix .. "/login"
	ctx.request.method = "get"
	router:router(url_prefix, userController)
	router:handle(ctx.request.url, ctx)

	ctx.request.url = url_prefix .. "/login/test"
	ctx.request.method = "get"
	router:router(url_prefix, userController)
	router:handle(ctx.request.url, ctx)
	--ctx.request.url = url_prefix .. "/register"
	--ctx.request.method = "get"
	--router:router(ctx.request.url, userController, "post:api_register")
	--router:handle(ctx.request.url, ctx)
end
--controller_router_test()

function regexp_router_test()
	local url_prefix = "/regexp/router/test"
	
	router:router(url_prefix .. "/:id(int)", function(ctx) print_request(ctx) end)
	ctx.request.url = url_prefix .. "/123"
	router:handle(ctx.request.url, ctx)
	ctx.request.url = url_prefix .. "/123.23"
	router:handle(ctx.request.url, ctx)

	router:router(url_prefix .. "/:id(number)", function(ctx) print_request(ctx) end)
	ctx.request.url = url_prefix .. "/123.12"
	router:handle(ctx.request.url, ctx)

	router:router(url_prefix .. "/:str(string)", function(ctx) print_request(ctx) end)
	ctx.request.url = url_prefix .. "/hello"
	router:handle(ctx.request.url, ctx)
	
	router:router(url_prefix .. "/abc/:str([abc]+)", function(ctx) print_request(ctx) end)
	ctx.request.url = url_prefix .. "/abc/test"
	router:handle(ctx.request.url, ctx)
	ctx.request.url = url_prefix .. "/abc/ab"
	router:handle(ctx.request.url, ctx)
end

regexp_router_test()

commonlib.console(router)

-- 常规路由
--router:router("/api/v0/user/login", function(ctx) print_request(ctx) end) -- 任意方法请求
--router:router("/api/v0/user/login", function(ctx) print_request(ctx) end, 'any') -- 任意方法请求
--router:router("/api/v0/user/login", function(ctx) print_request(ctx) end, 'get')
--router:router("/api/v0/user/login", function(ctx) print_request(ctx) end, 'post')
--router:router("/api/v0/user/login", function(ctx) print_request(ctx) end, 'delete')
--router:router("/api/v0/user/login", function(ctx) print_request(ctx) end, 'put')
--router:router("/api/v0/user/login", function(ctx) print_request(ctx) end, 'head')
--router:router("/api/v0/user/login", function(ctx) print_request(ctx) end, 'patch')
--router:router("/api/v0/user/login", function(ctx) print_request(ctx) end, 'options')

---- 控制器路由
--local userController = {}
--router:router("/api/v0/user", userController) -- get => userController:get()  post => userController:post() ...
--router:router("/api/v0/user/register", userController, "post:api_register") -- post =>  userController:register()
--router:router("/api/v0/user/getByName", userController, "get_by_name") -- get =>  userController:getByName()

---- 正则路由
--router:router("/api/v0/user/(int)", userController, 'get')
--router:router("/api/:ver/:username(string)/:userid(int)/regstr([%w]+)", function()end)


--ctx.request.method = "get"
--ctx.request.url = "/api/v0/user/login"
--router:handle(ctx.request.url, ctx)
--ctx.request.method = "unknow_method"
--router:handle(ctx.request.url, ctx)

--ctx.request.method = "get"
--router:handle("/api/v0/user/login", ctx)
--ctx.request.method = "post"
--router:handle("/api/v0/user/login", ctx)


--local is_reg, regstr, argslist = router:parse_path("/api/:ver/:user(string)/(int)/login")
--print(regstr)
--print(string.match("/api/v2/user/3/login", regstr))
