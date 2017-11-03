

-- 加载框架
local nws = require("nws/loader")
-- 加载配置文件
local config = require("config")
-- 初始化矿建
nws.init(config)
-- 导出日志对象
log = nws.log

-- 业务代码开始
nws.router("/", function(ctx)
	ctx.response:send("<div>hello npl webserver</div>")
end)

nws.router("/log", function(ctx)
	log("log")
	log.debug("debug log")
	log.info("info log")
	log.warn("warn log")
	log.error("error log")
	log.fatal("fatal log")

	log.set_log_level("DEBUG")
	log.debug("debug log")
	log.info("info log")
	log.warn("warn log")
	log.error("error log")
	log.fatal("fatal log")

	log.info("arg1", "arg2", 3, 4)
end) 

--nws.router("/api/v0/demo", )






nws.log("启动服务器...")
-- 启动服务器
nws.start()
