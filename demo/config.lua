
-- 全局配置
local config = {
	server_type = "npl",   -- 服务器类型 npl, lua(lua-nginx)
	--server_type = "lua",   -- 服务器类型 npl, lua(lua-nginx)
	server_ip = nil,
	server_port = 8888,

	-- 数据库配置
	database = {
		--db_type = "tabledb",  --  数据库类型: tabledb, mysql
		db_type = "mysql",  --  数据库类型: tabledb, mysql

		tabledb = {             -- tabledb 数据库配置
			path = "database/", -- 数据库路径
			-- sync_mode = true,   -- 是否为异步模式
		},

		mysql = {                   -- mysql 数据库配置
			db_name = "keepwork",   -- 数据库名
			username = "wuxiangan", -- 账号名
			password = "wuxiangan", -- 账号密码
			host = "127.0.0.1",     -- 数据库ip地址
			port = 3306,            -- 数据库端口
		}
	},
}


return config
