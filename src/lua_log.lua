local logging = require "logging"
local logging_console = require('logging.console')
local logging_file = require('logging.file')
local cjson_safe = require("cjson.safe")

local log = {
	DEBUG=logging.DEBUG,
	INFO=logging.INFO,
	WARN=logging.WARN,
	ERROR=logging.ERROR,
	FATAL=logging.FATAL,

	LOG_CONSOLE="console",
	LOG_FILE="file",
	LOG_ALL="all",
}

local defaultConfig = {
	console=false,

	file=true,
	filename="/var/log/http/log.txt",

	sql=false
}


local function merge_table(t1, t2)
	local t = {}

	for key, value in pairs(t1 or {}) do
		t[key] = value
	end

	for key, value in pairs(t2 or {}) do
		t[key] = value
	end

	return t
end


local function wrap_msg(msg, dept)
	dept = dept or 3
	local info = debug.getinfo(dept)
	local pos =  info.source .. ":" .. tostring(info.currentline)

	msg = cjson_safe.encode(msg)

	msg = pos .. " " .. msg 

	return msg
end

function log:new(config)
	local obj = {}
	
	setmetatable(obj, self)
	self.__index = self

	config = merge_table(defaultConfig, config)
	
	logs = {}
	if config.console then
		logs[log.LOG_CONSOLE] = logging_console()
	end

	if config.file then
		logs[log.LOG_FILE] = logging_file(config.filename)
	end

	obj.logs = logs

	return obj
end

function log:log(level, msg)
	for _, l in pairs(self.logs) do
		l:log(level, msg)
	end
end

function log:setLevel(log_type, level)
	log_type = log_type or log.LOG_ALL

	if log_type == log.LOG_ALL then
		for _, l in pairs(self.logs) do
			l:setLevel(level)
		end
	else
		self.logs[log_type]:setLevel(level)
	end
end

function log:debug(msg)
	msg = wrap_msg(msg)
	self:log(log.DEBUG, msg)
end

function log:info(msg)
	msg = wrap_msg(msg)
	self:log(log.INFO, msg)
end

function log:warn(msg)
	msg = wrap_msg(msg)
	self:log(log.WARN, msg)
end


function log:error(msg)
	msg = wrap_msg(msg)
	self:log(log.ERROR, msg)
end


function log:fatal(msg)
	msg = wrap_msg(msg)
	self:log(log.FATAL, msg)
end

log = setmetatable(log, {
	__call = function(self, ...)
		commonlib.console(...)
	end,
})

return log











