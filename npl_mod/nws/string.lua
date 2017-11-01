
local string = string or {}

function string.split(str, sep)
	local list = {}

	for word in string.gmatch(str, '([^' .. sep .. ']+)') do
		list[#list+1] = word
	end

	return list
end
