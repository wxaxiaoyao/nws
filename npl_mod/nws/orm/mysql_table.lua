local mysql = require("orm/mysql")
local mysql_query = require("orm/mysql_query")

local mysql_table = {}

function mysql_table:ctor()
	--print('table:ctor()')
end

function mysql_table:new()
	--print("table:new()")
	local obj = {}

	setmetatable(obj, self)
	self.__index = self
	
	obj.fields = {}

	return obj
end

-- 设置表名
function mysql_table:tablename(name)
	if not name then
		return self.table_name
	end


	self.table_name = name

	return self.table_name
end


-- get query 
function mysql_table:get_query()
	return mysql_query:new(self, {tablename=self.table_name})
end

-- 添加表字段
function mysql_table:addfield(name, typ)
	self.fields[name] = {
		name=name,
		typ=typ,
	}
end

function mysql_table:get_where_str(t)
	t = t or {}

	local sql_str = "";
	local has_where = false
	local is_first = true
	local is_or_first = true
	for key, value in pairs(t) do
		-- 非关键字
		local pos = string.find(key, "%$")
		if pos ~= 1 then
			if not has_where then
				sql_str = sql_str .. " where "
				has_where = true
			end
		
			if not is_first then
				sql_str = sql_str .. " and "
			end
			is_first = false

			sql_str = sql_str .. self:get_key_value_str(key, value)
		end
	end

	if t[mysql.OR] then
		if not has_where then
			sql_str = sql_str .. " where "
			has_where = true
		end
	
		if not is_first then
			sql_str = sql_str .. " and ("
		end

		for key, value in pairs(t[mysql.OR]) do
			if not is_or_first then
				sql_str = sql_str .. " or "
			end

			sql_str = sql_str .. self:get_key_value_str(key, value)
		end

		if not is_first then
			sql_str = sql_str .. ")"
		end
	end
	if t[mysql.LIMIT] then
		sql_str = sql_str .. " limit " .. tostring(t[mysql.LIMIT] or mysql.DEFAULT_LIMIT)  .. " "
	end

	if t[mysql.OFFSET] then
		sql_str = sql_str .. " offset " .. tostring(t[mysql.OFFSET] or 0) .. " "
	end
	return sql_str
end

function mysql_table:get_key_value_str(key, value)
	local expr = "="
	if type(value) == "object" then
		for k, v in pairs(value) do
			expr = k
			value = v
		end
	end

	if type(value) == "string" then
		value = "'" .. tostring(value) .. "'"
	elseif type(value) == "number" then
		value = tostring(value)
	end

	return "`".. key .. "`" .. " " .. expr .. " " .. value, value, expr
end

-- 查找记录
function mysql_table:find(t)
	local sql_str = "select * from `" .. self.table_name .. "` " .. self:get_where_str(t)
	
	mysql.log(sql_str)

	local list = {}
	local row = {}
	local cur, err = mysql:execute(sql_str)
	if not cur then
		return cur, err
	end
	
	row = cur:fetch({}, "a") 
	while row do
		list[#list+1] = row
		--mysql.log(row.username)
		row = cur:fetch({}, "a") 
	end
	 
	return list
end

-- 查找单条记录
function mysql_table:find_one(t)
	t = t or {}
	t[mysql.LIMIT] = 2

	local list, err = self:find(t)
	if not list then
		return list, err
	end

	if #list == 1 then
		return list[1]
	end

	return nil, "record count error!!!"
end

-- 插入记录
function mysql_table:insert(obj)
	local sql_str = "insert into `" .. self.table_name .. "`("
	local sql_value_str = "values("
	local first = true

	for key, value in pairs(obj or {}) do
		local _, v = self:get_key_value_str(key, value)
		if first then
			sql_str = sql_str .. "`" .. key .. "`"
			sql_value_str = sql_value_str .. v
		else
			sql_str = sql_str .. "," .. "`" .. key .. "`"
			sql_value_str = sql_value_str .. "," .. v
		end

		first = false
	end

	sql_str = sql_str .. ") "
	sql_value_str = sql_value_str .. ")"
	sql_str = sql_str .. " " .. sql_value_str

	mysql.log(sql_str)
	return mysql:execute(sql_str)
	--return sql_str
end

-- 更新记录
function mysql_table:update(q, o)
	local sql_str = "update `" .. self.table_name .. "` set "	
	local first = true

	for key, value in pairs(o or {}) do
		local _, v = self:get_key_value_str(key, value)
		if first then
			sql_str = sql_str .. "`" .. key .. "`" .. "=" .. v 
		else
			sql_str = sql_str .. ", " .. "`"  .. key .. "`" .. "=" .. v
		end
		first = false
	end

	sql_str = sql_str .. " " .. self:get_where_str(q)
	
	mysql.log(sql_str)
	return mysql:execute(sql_str)
	--return sql_str
end

-- 删除记录
function mysql_table:delete(q)
	local sql_str = "delete from `" .. self.table_name .. "` "

	sql_str = sql_str .. self:get_where_str(q)

	mysql.log(sql_str)

	return mysql:execute(sql_str)
end

-- 增改记录
function mysql_table:upsert(q, o)
	if self:findOne(q) then
		return self:update(q,o)
	end

	return self:insert(o)
end

return mysql_table






















