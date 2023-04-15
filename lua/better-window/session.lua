local json = require("better-window.json")
local TabManager = require("better-window.tab_manager")
local WindowManager = require("better-window.windows_manager")
local EditorGroup = require("better-window.editor_group")
local PaneTree = require("better-window.tree")
local Stack = require("better-window.stack")
local Node = require("better-window.node")

local SharedState = require("better-window.state")

local SessionManager = {}

local tab_manager
local update_tab_manager_callback

function SessionManager.init(_tab_manager)
	tab_manager = _tab_manager
end

function serialize(tbl, indent)
	indent = indent or 0
	local str = "{\n"

	for k, v in pairs(tbl) do
		str = str .. string.rep("  ", indent + 1)

		if type(k) == "string" then
			str = str .. string.format('["%s"]', k)
		else
			str = str .. string.format("[%s]", k)
		end

		str = str .. " = "

		if type(v) == "table" then
			str = str .. serialize(v, indent + 1)
		elseif type(v) == "string" then
			str = str .. string.format('"%s"', v)
		else
			str = str .. tostring(v)
		end

		str = str .. ",\n"
	end

	str = str .. string.rep("  ", indent) .. "}"

	if indent == 0 then
		str = "return " .. str
	end

	return str
end

local function deserialize(str)
	-- Load the table from the serialized string
	local loaded_data = load(str)()

	-- Create a table to store references by their unique identifiers
	local refs = {}

	-- Helper function to recursively resolve references
	local function resolveRefs(t)
		for k, v in pairs(t) do
			if type(v) == "string" and v:find("_REF_") == 1 then
				local ref_key = v
				if not refs[ref_key] then
					-- First time encountering this reference, create an empty table
					refs[ref_key] = {}
				end
				t[k] = refs[ref_key]
			elseif type(v) == "table" then
				-- Recursively resolve references in child tables
				resolveRefs(v)
			end
		end
	end

	-- Resolve references in the loaded data
	resolveRefs(loaded_data)

	return loaded_data
end

local function restore_metatables(obj, visited)
	if type(obj) ~= "table" then
		return
	end

	visited = visited or {}

	if visited[obj] then
		return
	end

	visited[obj] = true

	if obj.tabs ~= nil and obj.windows_manager ~= nil then
		setmetatable(obj, TabManager)
	end

	if obj.paneTree ~= nil and obj.last_layout ~= nil then
		setmetatable(obj, WindowManager)
	end

	if obj.win_id ~= nil and obj.stack ~= nil then
		setmetatable(obj, EditorGroup)
	end

	if obj.rootNode ~= nil then
		setmetatable(obj, PaneTree)
	end

	if obj.items ~= nil then
		setmetatable(obj, Stack)
	end

	if obj.editorGroup ~= nil and obj.parent ~= nil then
		setmetatable(obj, Node)
	end

	for _, v in pairs(obj) do
		restore_metatables(v, visited)
	end
end

function SessionManager:save()
	print("saving session")
	print("Access to manager: ", not (tab_manager == nil))
	vim.g.TEST = json.dump(SharedState.get_tab_manager())
end

function SessionManager:restore()
	print("restoring session")
	local _, restored = json.load(vim.g.TEST)
	restore_metatables(restored)
	print(vim.inspect(restored))
	SharedState.set_tab_manager(restored)
end

return SessionManager
