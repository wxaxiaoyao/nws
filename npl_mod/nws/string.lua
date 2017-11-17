
local string = string or {}

function string.split(str, sep)
	local list = {}

	if not (string.match(str, sep .. "$")) then
		str = str .. sep
	end

	for word in string.gmatch(str, '([^' .. sep .. ']*)' .. sep) do
		list[#list+1] = word
	end

	return list
end
