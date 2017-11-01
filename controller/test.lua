-- 控制器文件测试
local demo = NPL.load("controller/demo.lua")
-- 获取控制器类
local controller = commonlib.gettable("nws.controller")
--  创建test控制器
local test = controller:new("test")

-- 编写test方法
function test:test(ctx)
	ctx.response:send("hello world")
end

--return test

return {demo = demo}
