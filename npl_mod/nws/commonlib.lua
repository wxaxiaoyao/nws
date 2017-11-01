commonlib = {}

---- get a table f, where f is a string
---- @param f: f is a string like "a.b.c.d"
---- @param rootEnv: it can be a table from which to search for f, if nil, the global table _G is used.
--function nws.gettable(f, root_table, default_value)
    --local t = root_table or _G    -- start with the table of globals
    --if not f then 
		--return t
	--end 

	--default_value = default_value or {}
    --for w, d in string.gfind(f, "([%w_]+)(.?)") do
        --t[w] = t[w] or default_value  -- create table if absent
        --t = t[w]            -- get the table
    --end 
    --return t;
--end
--
--commonlib.util = util

-- get a table f, where f is a string
-- @param f: f is a string like "a.b.c.d"
-- @param rootEnv: it can be a table from which to search for f, if nil, the global table _G is used.
function commonlib.gettable(f, rootEnv)
    local t = rootEnv or _G    -- start with the table of globals
    if not f then 
		return t
	end 

    for w, d in string.gmatch(f, "([%w_]+)(.?)") do
        t[w] = t[w] or {}   -- create table if absent
        t = t[w]            -- get the table
    end 
    return t;
end

commonlib.object = {}

-- 对象继承
function commonlib.inherit(base, derived)
	derived = derived or {}
	
	-- 创建子类
	base = base or {}

	if type(base.new) == "function" then
		base = base.new(base)
	end

	local _inherit = function(t, k)
		local mt = getmetatable(t)

		if not mt then
			return mt
		end

		local pos = string.find(k, '_')
		if pos == 1 then
			return nil
		end
		
		local value = mt[k]

		if value and type(value) == "function" then
			return function(self, ...)
				return value(mt, ...)
			end
		end

		return value
		--return mt[k]
	end

	setmetatable(derived, base)
	base.__index = _inherit

	base._derived_class = derived
	derived._base_class = base

	derived.new = function(self)
		-- self <=> derived
		local obj = {}

		setmetatable(obj, self)
		self.__index = _inherit

		self._derived_class = obj
		obj._base_class = self

		-- 调用子类构造函数
		if type(base.ctor) == "function" then
			base:ctor()
		end

		-- 调用派生类构造函数
		if type(self.ctor) == "function" then
			self.ctor(obj)
		end

		return obj
	end

	return derived
end

-- 对象导出
function commonlib.export(obj, list)
	return setmetatable({}, {
		__index = function(t,k)
			for _, key in ipairs(list or {}) do
				if key == k then
					local value = obj[key]
					if value and type(value) == "function" then
						return function(params)
							value(obj, params)
						end
					end
					return value
				end
			end
		end
	})
end

local function console(obj, out)
	out = out or print

	local outlist = {}
	function _print(obj, level, flag)
		-- 避免循环输出
		local obj_str = tostring(obj)
		for _, str in ipairs(outlist) do
			if str == obj_str then
				return
			end
		end
		outlist[#outlist+1] = obj_str

		level = level or 0
		local indent_str = ""
		for i = 1, level do
		  indent_str = indent_str.."    "
		end
	  
		if not flag then
			out(indent_str.."{")
		end
	  
		for k,v in pairs(obj) do
			if type(v) == "table" then 
				out(string.format("%s    %s = {", indent_str, tostring(k)))
				_print(v, level + 1, true)
			elseif type(v) == "string" then
				out(string.format('%s    %s = "%s"', indent_str, tostring(k), tostring(v)))
			else
				out(string.format("%s    %s = %s", indent_str, tostring(k), tostring(v)))
			end
		end
		out(indent_str.."}")
	end
	
	if type(obj) == "table" then
		_print(obj)
	elseif type(obj) == "string" then
		out('"' .. obj .. '"')
	else
		out(tostring(obj))
	end
end

-- 控制台输出
function commonlib.console(...)
	local count = select("#", ...)
	for i=1, count,1 do
		--print((select(i, ...)))
		console((select(i, ...)))
	end
end

-- 获取当前日期
function commonlib.get_date()
	return os.date("%Y-%m-%d")
end

function commonlib.get_time()
	return os.date("%H:%M:%S")
end

function commonlib.get_datetime()
	return commonlib.get_date() .. " " .. commonlib.get_time()
end

function string_split(str, sep)
	local list = {}

	for word in string.gmatch(str, sep .. '?([^' .. sep .. ']*)') do
		if word ~= "" then
			list[#list+1] = word
		end
	end

	return list
end

function merge_table(t1, t2)
	local t = {}

	for key, value in pairs(t1 or {}) do
		t[key] = value
	end

	for key, value in pairs(t2 or {}) do
		t[key] = value
	end

	return t
end

function getCurrentDir(dept)
	dept = dept or 0

	local info = debug.getinfo(dept)

	return string.match(info.source, '@?(.*)/[^/]*$')
end


function test()
	console(debug.getinfo(2))
end

--return commonlib

function ngx_log(...)
	local count = select("#", ...)
	for i=1, count,1 do
		--print((select(i, ...)))
		console((select(i, ...)), function(msg)
			ngx.log(ngx.ERR, msg)
		end)
	end
end


return commonlib
