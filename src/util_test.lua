local util = require("util")

local token = util.encodeJWT({username="xiaoyao", userId=1})

util.console(token)

util.console(util.decodeJWT(token))
