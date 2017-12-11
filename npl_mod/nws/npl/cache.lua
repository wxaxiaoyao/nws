
local cache = nws.gettable("nws.cache")

cache.store = {}

-- expire 单位秒
function cache:set(key, value, expire)
	local data = self.store[key] or {}
	data.value = value
	data.expire = os.time() + expire
end

-- 重置缓存值
function cache:reset(key, value, expire)
	local data = self.store[key] or {}
	data.expire = os.time() + expire
	data.value = value or data.value
end

-- 获取缓存值
function cache:get(key)
	local cur_time = os.time()
	local data = self.store[key]

	if not data or data.expire < cur_time then
		return nil
	end

	return data.value
end

return cache
