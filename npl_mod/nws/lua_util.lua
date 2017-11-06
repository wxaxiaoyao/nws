-- 加载第三方服务
local cjson = require("cjson")
local cjson_safe = require("cjson.safe")
local jwt = require("luajwt")
local md5 = require("md5")
--local requests = require("requests")

local util = nws.gettable("nws.util")

-- 控制台输出
function util.console(msg)
	if type(msg) == "table" then
		msg = util.toJson(msg)
	elseif type(msg) == "function" then
		msg = tostring(msg)
	end

	print(msg)
end

-- web 输出
function util.say(msg)
	if type(msg) == "table" then
		msg = util.toJson(msg)
	elseif type(msg) == "function" then
		msg = tostring(msg)
	end

	ngx.say(msg)
end

-- json 编码
function util.to_json(t)
	return cjson_safe.encode(t)
end

-- json 解码
function util.from_json(s)
	ngx_log("=============")
	ngx_log(s)
	return cjson_safe.decode(s)
end

-- jwt 编码
function util.encode_jwt(payload, secret, expire)
	local alg = "HS256"
	payload = payload or {}
	secret = secret or "keepwork"
	payload.iss = "xiaoyao"
	payload.nbf = os.time()
	payload.exp = os.time() + (expire or 3600)

	local token, err = jwt.encode(payload, secret, alg)

	return token
end

-- jwt 编码
function util.decode_jwt(token, secret)
	if not token then
		return nil
	end

	secret = secret or "keepwork"
	local payload, err = jwt.decode(token, secret)
	
	return payload
end

-- Encodes a string into its escaped hexadecimal representation
-- @param s:  binary string to be encoded
-- @return escaped representation of string binary
function util.escape(s)
    return string.gsub(s, "([^A-Za-z0-9_])", function(c)
        return string.format("%%%02x", string.byte(c))
    end)
end

-- Encodes a string into its escaped hexadecimal representation
-- @param s: binary string to be encoded
-- @return escaped representation of string binary
function util.unescape(s)
    return string.gsub(s, "%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end)
end

-- Decode an URL-encoded string (see RFC 2396)
function util.decode_url(str)
	if not str then return nil end
	str = string.gsub (str, "+", " ")
	str = string.gsub (str, "%%(%x%x)", function(h) return string.char(tonumber(h,16)) end)
	str = string.gsub (str, "\r\n", "\n")
	return str
end

-- URL-encode a string (see RFC 2396)
function util.encode_url(str)
	if not str then return nil end
	str = string.gsub (str, "\n", "\r\n")
	str = string.gsub (str, "([^%w ])",
		function (c) return string.format ("%%%02X", string.byte(c)) end)
	str = string.gsub (str, " ", "+")
	return str
end

-- Parses a string into variables to be stored in an array.
-- @param str: url query string such as "a=1&b&c=3"
-- @return the url params table returned. 
function util.parse_url_args(str, params)
	params = params or {};
	if(not str) then
		return params;
	end
	for param in string.gmatch (str, "([^&]+)") do
		local k,v = string.match (param, "(.*)=(.*)")
		if(k) then
			k = util.decode_url (k)
			v = util.decode_url (v)
		else
			k, v = param, "";
		end
		if k ~= nil then
			if params[k] == nil then
				params[k] = v
			elseif type (params[k]) == "table" then
				table.insert (params[k], v)
			else
				params[k] = {params[k], v}
			end
		end
	end
	return params;
end

-- 获取共享字典
--util.getSharedDict = function()
	--return ngx.shared.shared_dict
--end

-- url
-- method
-- headers
-- data
--res:{headers:{}, text:string, status_code:number}
function util.get_url(params)
	local method = params.method or "GET"

	if params.headers then
		params.headers['Content-Type'] = params.headers['Content-Type'] or "application/json"
	else
		params.headers = {['Content-Type'] = "application/json"}
	end

	if string.lower(method) == "get" then
		params.params = params.data
		--params.data = nil
	end
	local res = requests.request(method, params)

	res.data = res.json()

	return res
end

function util.md5(msg)
	return md5.sumhexa(msg)
	--return msg
end

return util
