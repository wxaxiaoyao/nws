--NPL.load("(gl)script/ide/Json.lua");

local util = commonlib.gettable("nws.util")
local request = commonlib.gettable("nws.request")

-- 将头部统一转小写
local function format_headers(headers)
	--local obj = {}
	for key, value in pairs(headers or {}) do
		local key_lower = string.lower(key)
		if key ~= key_lower then
			headers[key_lower] = headers[key]
			headers[key] = nil
		end
	end
end

function request:new(msg)
	if not msg then	
		return nil
	end	

	local obj = {}

	setmetatable(obj, self)
	self.__index = self
	
	format_headers(msg)
	obj.nid = msg.tid or msg.nid
	obj.headers= msg
	obj.method = msg.method
	obj.url = msg.url
	obj.path = string.gsub(obj.url, '?.*$', '') 
	
	return obj
end


local function get_boundary(content_type)
	local boundary = string.match(content_type, "boundary%=(.-)$")
	return "--" .. tostring(boundary)
end

local function insert_field(tab, name, value, overwrite)
	if (overwrite or not tab[name]) then
		tab[name] = value
	else
		local t = type(tab[name])
		if t == "table" then
			table.insert(tab[name], value)
		else
			tab[name] = { tab[name], value }
		end
	end
end

local function break_headers(header_data)
	local headers = {}
	for type, val in string.gmatch(header_data, '([^%c%s:]+):%s+([^\n]+)') do
		type = lower(type)
		headers[type] = val
	end
	return headers
end

local function read_field_headers(input, pos)
	local EOH = "\r?\n\r?\n"
	local s, e = string.find(input, EOH, pos)
	if s then
		return break_headers(string.sub(input, pos, s-1)), e+1
	else 
		return nil, pos 
	end
end

local function split_filename(path)
	local name_patt = "[/\\]?([^/\\]+)$"
	return (string.match(path, name_patt))
end

local function get_field_names(headers)
	local disp_header = headers["content-disposition"] or ""
	local attrs = {}
	for attr, val in string.gmatch(disp_header, ';%s*([^%s=]+)="(.-)"') do
		attrs[attr] = val
	end
	return attrs.name, attrs.filename and split_filename(attrs.filename)
end

local function read_field_contents(input, boundary, pos)
	local boundaryline = "\n" .. boundary
	local s, e = string.find(input, boundaryline, pos, true)
	if s then
		if(input:byte(s-1) == 13) then  -- '\r' == 0x0d == 13
			s = s - 1
		end
		return string.sub(input, pos, s-1), s-pos, e+1
	else 
		return nil, 0, pos 
	end
end

local function file_value(file_contents, file_name, file_size, headers)
	local value = { contents = file_contents, name = file_name,	size = file_size }
	for h, v in pairs(headers) do
		if h ~= "content-disposition" then
			value[h] = v
		end
	end
	return value
end

local function fields(input, boundary)
	local state, _ = { }

	_, state.pos = string.find(input, boundary, 1, true)
	if(not state.pos) then
		return function() end;
	end
	state.pos = state.pos + 1
	return function (state, _)
		local headers, name, file_name, value, size
		headers, state.pos = read_field_headers(input, state.pos)
		if headers then
			name, file_name = get_field_names(headers)
			if file_name then
				value, size, state.pos = read_field_contents(input, boundary, state.pos)
				value = file_value(value, file_name, size, headers)
			else
				value, size, state.pos = read_field_contents(input, boundary, state.pos)
			end
		end
		return name, value
	end, state
end

-- @param input: input string
-- @param input_type: the content type containing the boundary text. 
-- @param tab: table of key value pairs, if nil a new table is created and returned. 
-- @return table of key value pairs
function request:parse_multipart_data(input, input_type, tab, overwrite)
	tab = tab or {}
	local boundary = get_boundary(input_type);
	if(boundary) then
		for name, value in fields(input, boundary) do
			insert_field(tab, name, value, overwrite)
		end
	end
	return tab;
end

function request:parse_post_data()
	--log(self.headers, true)
	local params = {}
	local body = self.headers.body
	local input_type = self.headers["content-type"]
	if not input_type or not body or body == "" then
		return {}
	end

	local input_type_lower = string.lower(input_type)

	if (string.find(input_type_lower, "x-www-form-urlencoded")) then
		params = util.parse_url_args(body)
	elseif (string.find(input_type_lower, "multipart/form-data")) then
		params = self:parse_multipart_data(body, input_type, params, true);
	elseif (string.find(input_type_lower, "application/json")) then
		params = commonlib.Json.Decode(body) 
	else
		params = util.parse_url_args(body)
	end

	return params
end

function request:get_params()
	if self.params then
		return self.params
	end

	local url = self.url
	local args_str = string.match(url, "?(.+)$")

	if args_str then
		self.params = util.parse_url_args(args_str)
	else
		self.params = self:parse_post_data()
	end

	return self.params
end

return request
