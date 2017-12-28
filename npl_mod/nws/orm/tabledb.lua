NPL.load("(gl)script/ide/System/Database/TableDatabase.lua")
local TableDatabase = commonlib.gettable("System.Database.TableDatabase")

--local fake_tabledb = {}

--local function console(obj, out)
	--out = out or print

	--local outlist = {}
	--function _print(obj, level, flag)
		---- 避免循环输出
		--local obj_str = tostring(obj)
		--for _, str in ipairs(outlist) do
			--if str == obj_str then
				--return
			--end
		--end
		--outlist[#outlist+1] = obj_str

		--level = level or 0
		--local indent_str = ""
		--for i = 1, level do
		  --indent_str = indent_str.."    "
		--end
	  
		--if not flag then
			--out(indent_str.."{")
		--end
	  
		--for k,v in pairs(obj) do
			--if type(v) == "table" then 
				--out(string.format("%s    %s = {", indent_str, tostring(k)))
				--_print(v, level + 1, true)
			--elseif type(v) == "string" then
				--out(string.format('%s    %s = "%s"', indent_str, tostring(k), tostring(v)))
			--else
				--out(string.format("%s    %s = %s", indent_str, tostring(k), tostring(v)))
			--end
		--end
		--out(indent_str.."}")
	--end
	
	--if type(obj) == "table" then
		--_print(obj)
	--elseif type(obj) == "string" then
		--out('"' .. obj .. '"')
	--else
		--out(tostring(obj))
	--end
--end

--local function resume() 
--end

--local function yield()
--end

--function fake_tabledb:count(t, resume)
	--console(t)
	--resume()
--end

--function fake_tabledb:find(t, resume)
	--console(t)
	--resume()
--end

--function fake_tabledb:insertOne(q, p, resume)
	--console(q)
	--console(p)
	--resume()
--end

--function fake_tabledb:updateOne(q, p, resume)
	--console(q)
	--console(p)
	--resume()
--end

--function fake_tabledb:delete(t, resume)
	--console(t)
	--resume()
--end

local tabledb = {
	DEFAULT_LIMIT = 200,

	-- 关键字
	LIMIT = "$limit",
	OFFSET = "$offset",
	OR = "$or",
	AND = "$and",
	ON = "$on",
}


local l_db = nil

function tabledb:init(config)
	if l_db then
		return 
	end

	l_db = TableDatabase:new():connect(config.path or "database/", function() end);
	if not l_db then
		log("open tabledb failed")
	end

	l_db:EnableSyncMode(true)
end

function tabledb:deinit()
end

function tabledb:new()
	local obj = {}

	setmetatable(obj, self)
	self.__index = self
	
	obj._fields = {}

	--obj.idname = "id"
	return obj
end

function tabledb:tablename(name)
	self.table_name = name
	--self.table = fake_tabledb
	self.table = l_db[name]

	self.idname = self.table_name .. "_id"
	-- id字段默认存在
	self:addfield(self.idname, "number", "ID", true)
end

function tabledb:get_tablename()
	return self.table_name
end

function tabledb:get_idname()
	return self.idname
end

function tabledb:addfield(fieldname, fieldtype, aliasname, is_query)
	if not fieldname or not fieldtype then
		return 
	end

	local field = self._fields[fieldname] or {}
	field.fieldname = fieldname
	field.fieldtype = fieldtype
	field.aliasname = aliasname
	field.is_query = is_query

	if not self._fields[fieldname] then
		self._fields[#self._fields+1] = field
	end

	self._fields[fieldname] = field
end

function tabledb:get_value_id(t)
	if type(t) == "table" then
		return t["_id"]
	end

	return 0
end

-- 获取字段列表
function tabledb:get_field_list()
	return self._fields
end

-- 过滤字段
function tabledb:_filter_field(t)
	local nt = {}
	for key, value in pairs(t or {}) do
		local field = self._fields[key]
		if field then
			if field.fieldtype == "number" then
				nt[key] = tonumber(value)
			else
				nt[key] = tostring(value)
			end
		end
	end

	return nt
end

function tabledb:_get_query_object(t, is_pagination)
	t = t or {}

	local limit = t[tabledb.LIMIT] or tabledb.DEFAULT_LIMIT
	local offset = t[tabledb.OFFSET] or 0
	local key = ""
	local value = {}
	local id = t[self.idname] or t["_id"]
	local nt = self:_filter_field(t)

	--t["_id"] = nil
	--t[tabledb.LIMIT] = nil
	--t[tabledb.OFFSET] = nil
	
	if id then
		return {_id = tonumber(id)}
	end

	for k, v in pairs(nt) do
		if string.match(k, '^[+-]') then
			key = key .. k
		else
			key = key .. "+" .. k
		end
		value[#value+1] = v
	end

	if key == "" then
		key = "+_id"
		value["gt"] = 0
	end

	if is_pagination then
		value["skip"] = offset
		value["limit"] = limit
	end

	return {[key]=value}
end

function tabledb:count(t)
	local query = self:_get_query_object(t)

	nws.log(query);

	local _, data = self.table:count(query)
	--self.table:count(query, resume)
	--local _, data = yield()

	return data or 0
end

function tabledb:find(t)
	local query = self:_get_query_object(t, true)

	local _, data = self.table:find(query)
	--self.table:find(query, resume)
	--local err, data = yield()
	
	for _, x in ipairs(data or {}) do
		x[self.idname] = x._id
	end

	return data or {}
end

function tabledb:find_one(t)
	t = t or {}
	t[tabledb.LIMIT] = 2
	
	local data = self:find(t)

	if data and #data == 1 then
		return data[1]
	end
	
	return nil
end

function tabledb:update(q, t)
	local nq = self:_get_query_object(q)
	local nt = self:_filter_field(t)

	local err, data = self.table:updateOne(nq, nt)
	--self.table:updateOne(query, o, resume)
	--local _, data = yield()

	return err, data
end

function tabledb:delete(t)
	local query = self:_get_query_object(t)

	local err, data = self.table:delete(query)
	--self.table:delete(query, resume)
	--local _, data = yield()

	return err, data
end

function tabledb:insert(t)
	local nt = self:_filter_field(t)

	local err, data = self.table:insertOne(nil, nt)

	if not err then
		err, data = self.table:updateOne({_id=data._id}, {[self.idname]=data._id})
	end
	--self.table:insertOne(nil, t, resume)
	--local _, data = yield()

	return err, data
end

function tabledb:upsert(q, t)
	local nq = self:_get_query_object(q)
	local nt = self:_filter_field(t)

	local err, data = self.table:insertOne(nq, nt)
	--self.table:insertOne(query, t, resume)
	--local _, data = yield()

	return err, data
end

return tabledb
