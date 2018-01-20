--[[
Title: utility functions
Author: LiXizhi
Date: 2015/6/9
Desc: this static collections of helper functions are also exposed to npl page environment as `util`
reference: some code from wsapi_util.lua in Xavante
-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/npl_util.lua");
local util = commonlib.gettable("WebServer.util");
-----------------------------------------------
]]

NPL.load("(gl)script/ide/System/os/GetUrl.lua")
NPL.load("(gl)script/ide/Encoding.lua")
NPL.load('script/ide/Json.lua')
NPL.load("(gl)script/ide/System/Encoding/jwt.lua")
--local requests = require("requests")

local Encoding = commonlib.gettable("commonlib.Encoding");
local jwt = commonlib.gettable("System.Encoding.jwt")
local util = commonlib.gettable("nws.util");
local config = commonlib.gettable("nws.config");

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

function util.to_json(t)
	return commonlib.Json.Encode(t)
end

function util.from_json(s)
	return commonlib.Json.Decode(s)
end

function util.encode_jwt(payload, secret, expire)
	secret = secret or config.secret or "keepwork"
	return jwt.encode(payload, secret, nil, expire)
end

function util.decode_jwt(token, secret)
	secret = secret or config.secret or "keepwork"
	return jwt.decode(token, secret)
end

function util.encode_base64(text)
	return Encoding.base64(text)
end

function util.decode_base64(text)
	return Encoding.unbase64(text)
end

function util.md5(msg)
	return ParaMisc.md5(msg)
end

-- url
-- method
-- headers
-- data
--res:{headers:{}, text:string, status_code:number}
--function util.get_url(params)
	--local method = params.method or "GET"

	--if params.headers then
		--params.headers['Content-Type'] = params.headers['Content-Type'] or "application/json"
	--else
		--params.headers = {['Content-Type'] = "application/json"}
	--end

	--if string.lower(method) == "get" then
		--params.params = params.data
		----params.data = nil
	--end
	--local res = requests.request(method, params)

	--res.data = res.json()

	--return res
--end

--NPL.load("/usr/local/share/lua/5.1")
local requests = require("requests")
function util.get_url(params)
	local method = params.method or "GET"

	if params.headers then
		params.headers['Content-Type'] = params.headers['Content-Type'] or "application/json"
	else
		params.headers = {['Content-Type'] = "application/json"}
	end

	if string.lower(method) == "get" then
		params.params = params.data
	end
	local res = requests.request(method, params)

	res.data = res.json()

	return res
end

--function util.get_url(params, callback)
	--local method = params.method or "GET"

	--if string.upper(method) == "GET" then
		--params.qs = params.data
	--else
		--params.form = params.data
	--end

	--local _, data = System.os.GetUrl(params)
	--data.status_code = data.rcode
	--return data
--end

-- 获取当前日期
function util.get_date()
	return os.date("%Y-%m-%d")
end

function util.get_time()
	return os.date("%H:%M:%S")
end

function util.get_datetime()
	return os.date("%Y-%m-%d %H:%M:%S")
end

return util
