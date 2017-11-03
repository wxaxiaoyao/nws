

-- 加载框架
local nws = require("nws/loader")

-- 业务代码开始
nws.router("/", function(ctx)
	ctx.response:send("<div>hello npl webserver</div>")
end)

nws.router("/log", function(ctx)
	nws.log("log")
	nws.log.debug("debug log")
	nws.log.info("info log")
	nws.log.warn("warn log")
	nws.log.error("error log")
	nws.log.fatal("fatal log")

	nws.log.set_log_level("DEBUG")
	nws.log.debug("debug log")
	nws.log.info("info log")
	nws.log.warn("warn log")
	nws.log.error("error log")
	nws.log.fatal("fatal log")

	nws.log.info("arg1", "arg2", 3, 4)
end) 







nws.log("启动服务器...")
-- 启动服务器
nws.start()
