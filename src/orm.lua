
local _db = nil
local orm = nws.gettable("nws.orm")

orm.LIMIT = "$limit"
orm.OFFSET = "$offset"

orm.DB_TYPE_MYSQL=0
orm.DB_TYPE_TABLEDB=1


function orm:new()
	local obj = {}

	setmetatable(obj, self)
	self.__index = self
	--self.__index = function(t, k)
		--local mt = getmetatable(t)
		--local pos = string.find(k, '_')
		--if pos == 1 then
			--return nil
		--end
		
		--return mt[k]
	--end

	obj._db_type = self._db_type
	obj._db = self._db:new()

	--obj._db_type = orm.DB_TYPE_TABLEDB
	--obj._db = tabledb:new()

	--self.set_db_type(obj, orm.DB_TYPE_MYSQL)

	return obj
end


local function get_db(db_type)
	--_ = db_type or error(db_type)
	db_type = db_type or "mysql"
	_db = _db or nws.import("nws/src/orm/" .. db_type)
	return _db
end

function orm:ctor()
end

function orm:init(config)
	self._db = get_db(config.db_type)
	self._db_config = config[config.db_type]
	self._db_type = config.db_type

	self._db:init(self._db_config)
end

function orm:deinit()
	--self._db:deinit()
	self._db:deinit()
end

function orm:tablename(t)
	self._db:tablename(t)
end

function orm:addfield(fieldname, fieldtype)
	self._db:addfield(fieldname, fieldtype)
end

function orm:set_db_type(typ)
	self._db_type = typ

	if self._db_type ==  self.DB_TYPE_MYSQL then
		self._db = mysql:new()
	elseif self._db_type == self.DB_TYPE_TABLEDB then
		self._db = tabledb:new()
	end

	orm.LIMIT = self._db.LIMIT
	orm.OFFSET = self._db.OFFSET
end

function orm:count(t)
	return self._db:count(t)
end

function orm:find_one(t)
	return self._db:find_one(t)
end

function orm:find(t) 
	return self._db:find(t)
end

function orm:upsert(q, t)
	return self._db:upsert(q, t)
end

function orm:insert(t)
	return self._db:insert(t)
end

function orm:delete(t) 
	return self._db:delete(t)
end

function orm:update(q, t)
	return self._db:update(q, t)
end

function orm:execute(t)
	return self._db:execute(t)
end

function orm:db()
	return self._db
end

return orm

