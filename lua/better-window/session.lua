local SessionManager = {}

local tab_manager

function SessionManager.init(_tab_manager)
	tab_manager = _tab_manager
end

function serialize(t, visited, indent)
	indent = indent or 0
	visited = visited or {}
	local str = ""

	for k, v in pairs(t) do
		local key_str = k

		if type(k) == "string" then
			key_str = string.format("%q", k)
		end

		if type(v) == "table" then
			if visited[v] then
				-- This is a circular reference, replace it with an identifier
				str = str .. string.rep("  ", indent) .. "[" .. key_str .. "] = " .. visited[v] .. ",\n"
			else
				visited[v] = "_REF_" .. tostring(v):gsub("table: ", "")
				str = str .. string.rep("  ", indent) .. "[" .. key_str .. "] = {\n"
				str = str .. serialize(v, visited, indent + 1)
				str = str .. string.rep("  ", indent) .. "},\n"
			end
		else
			local value_str = tostring(v)

			if type(v) == "string" then
				value_str = string.format("%q", v)
			elseif type(v) == "boolean" then
				value_str = tostring(v)
			end

			str = str .. string.rep("  ", indent) .. "[" .. key_str .. "] = " .. value_str .. ",\n"
		end
	end

	return str
end

function SessionManager:save()
	print("saving session")
    print(tab_manager == nil)
	print(serialize(tab_manager))
end

function SessionManager:restore()
	print("restoring session")
	tab_manager = vim.g.MY_VAR
end

return SessionManager
