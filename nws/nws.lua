
local function gettable(f, r)
    local t = r or _G    -- start with the table of globals
    if not f then 
		return t
	end 

    for w, d in string.gmatch(f, "([%w_]+)(.?)") do
        t[w] = t[w] or {}   -- create table if absent
        t = t[w]            -- get the table
    end 
    return t;
end

local function settable(f, v, r)
    local t = r or _G    -- start with the table of globals
	local lt = t
	local lw = nil

	if not f then
		return 
	end

    for w, d in string.gmatch(f, "([%w_]+)(.?)") do
        t[w] = t[w] or {}   -- create table if absent
		lw = w
		lt = t
        t = t[w]            -- get the table
    end 

	lt[lw] = v
end

local nws = gettable("nws")

nws.gettable = gettable
nws.settable = settable
nws.server_type = "npl"

function nws.import(modname)
	if nws.server_type == "npl" then
		return NPL.load(modname .. ".lua")
	else
		return require(modname)
	end
end


function nws.inherit(base, derived)
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


return nws
