
-- 加载框架
local nws = require("npl_mod.nws.loader")
-- 加载配置文件
local config = require("config")
-- 初始化矿建
nws.init(config)
-- 导出日志对象
--local log = nws.log

nws.router("/", function(ctx)
	ctx.response:send("<div>hello npl webserver</div>")
end)


nws.log("启动服务器...")
-- 启动服务器
nws.start()
