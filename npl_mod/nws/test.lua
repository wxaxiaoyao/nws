
local test = {
	total = 0,   -- 单元测试数量
	failed = 0,  -- 失败数量
	
	failed_unit_info = {},

	failed_stop = false,
}

local this = test

function test:assert(b, msg)
	if b then
		return 
	end

	local obj = debug.getinfo(2)
	local filepos = obj.source .. ":" .. obj.currentline
	this.failed_unit_info[#this.failed_unit_info+1] = {
		filepos = filepos,
		--traceback = string.gsub(debug.traceback(), "__unit_test_func__", self.funcname),
		--funcname = self.funcname,
		msg = msg,
	}

	this.failed = this.failed + 1

	if self.failed_stop then
		error("unit test failed")
	end

end

function test:output()
	nws.log("测试案例数:" .. this.total .. " 失败案例数:" .. this.failed)
	nws.log(this.failed_unit_info)
end

function test:start(filereg, funcreg)
	arg = arg or {}
	filereg = filereg or (arg[2] and arg[1]) or ""
	funcreg = funcreg or (arg[2] or arg[1]) or ""
	filereg = ".*" .. filereg .. ".*_test.lua$"
	funcreg = ".*" .. funcreg .. ".*_test$"

	local obj = debug.getinfo(2)

	--nws.log(obj)
	--nws.log(filereg, funcreg, obj.source)
	--nws.log(string.match(obj.source, filereg))
	
	if not string.match(obj.source, filereg) then
		nws.log("文件不匹配:", obj.source)
		return 
	end

	for k, __unit_test_func__ in pairs(self) do
		if type(__unit_test_func__) == "function" and string.match(k, funcreg) then
			this.funcname = k
			this.total = this.total + 1
			--nws.log("执行单元测试:", k)
			__unit_test_func__(self)
		end
	end
end

function test:new(obj)
	obj = obj or {}

	setmetatable(obj, self)
	self.__index = self
	
	obj.is_frist = nws.is_frist

	return obj
end


return test
