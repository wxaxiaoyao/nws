

-- 获取控制器类
local controller = commonlib.gettable("nws.controller")
--  创建test控制器
local demo = controller:new("demo")

-- 编写test方法
function demo:get(ctx)
	ctx.response:send("hello world")
end

--return demo
return {key="demo"}
