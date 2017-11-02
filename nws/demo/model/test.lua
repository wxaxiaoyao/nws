
-- DB模型测试  

local nws = commonlib.gettable("nws")
local orm = commonlib.gettable("nws.orm")
local test = nws.inherit(orm)

test:tablename("test")                   -- 表名
test:addfield("test_id", "number")       -- 主键id
test:addfield("username", "string")      -- 用户名字段
test:addfield("password", "string")      -- 密码字段

return test
