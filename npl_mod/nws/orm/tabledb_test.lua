
local tabledb = require("tabledb")

local test = tabledb:new()
test:tablename("test")
test:addfield("test_id", "number")
test:addfield("field", "string")


test:insert({field="helloworld"})

test:find({test_id=1, field="test"})

test:count({test_id=1, field="test"})

test:update({test_id=1}, {field="test"})

test:delete({test_id=1})
