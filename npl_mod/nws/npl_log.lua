
NPL.load("(gl)script/ide/log.lua")

local log = commonlib.gettable("nws.log")

log.log_flag_short = 1   -- 纯日志信息 
log.log_flag_long = 2    -- 带时间跟文件位置
log.log_flag_datetime = 3   -- 带时间
log.log_flag_filepos = 4    -- 带文件位置
log.flag = log.log_flag_long

function log.get_date_time_str()
	return commonlib.log.GetLogTimeString()
end

function log.set_log_flag(flag)
	log.flag = flag
end

function log.get_log_msg(...)
	local args_count = select('#', ...)
	local msg = {...}

	if args_count == 1 then
		msg = select(1, ...)
	end

	if type(msg) == "table" then
		msg = commonlib.serialize(msg)
	else
		msg = tostring(msg)
	end

	--msg = "\n" .. msg

	if log.flag == log.log_flag_long or log.flag == log.log_flag_filepos then
		local filepos = commonlib.debug.locationinfo(3)
		msg = filepos .. " " .. msg
	end

	if log.flag == log.log_flag_long or log.flag == log.log_flag_datetime then
		local date, time = log.get_date_time_str()
		msg = date .. "|" .. time .. " " .. msg
	end

	return msg
end

function log.debug(...)
	local msg = log.get_log_msg(...)
	LOG.debug(msg)
end

function log.info(...)
	local msg = log.get_log_msg(...)
	LOG.info(msg)
end

function log.warn(...)
	local msg = log.get_log_msg(...)
	LOG.warn(msg)
end

function log.error(...)
	local msg = log.get_log_msg(...)
	LOG.error(msg)
end

function log.fatal(...)
	local msg = log.get_log_msg(...)
	LOG.fatal(msg)
end

function log.trace(...)
	LOG.trace(...)
end

-- @param level: string of FATAL, ERROR, WARN, INFO, DEBUG, TRACE
function log.set_log_level(level)
	log.level = level
	LOG.SetLogLevel(level)
end

log = setmetatable(log, {
	__call = function(self, ...)
		msg = log.get_log_msg(...) .. "\n"
		commonlib.log(msg)
	end,
})

return log
