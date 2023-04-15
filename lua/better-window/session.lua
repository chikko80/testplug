local utils = require("better-window.utils")
local json = require("better-window.json")

local TabManager = require("better-window.tab_manager")
local WindowManager = require("better-window.windows_manager")
local EditorGroup = require("better-window.editor_group")
local PaneTree = require("better-window.tree")
local Stack = require("better-window.stack")
local Node = require("better-window.node")

local SharedState = require("better-window.state")

local SessionManager = {}

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
-- TODO: save buffer ids
	vim.g.TEST = json.dump(SharedState.get_tab_manager())
end

-- TODO: restore / update buffer ids
function SessionManager:restore()
	print("restoring session")
	local _, restored = json.load(vim.g.TEST)
	restore_metatables(restored)
	print("restored")
	print(vim.inspect(restored))

	SharedState.set_tab_manager(restored)

	-- update window ids
	local tab_manager = SharedState.get_tab_manager()
	local tabs = utils.get_tabs()
	for _, tabId in ipairs(tabs) do
		-- get window ids of current session
		local mapper = utils.get_winnr_to_win_id_mapper(tabId)
		local windows_manager = tab_manager:get_windows_manager(tabId)
		-- print(vim.inspect(windows_manager))

		if windows_manager then
			for winNr, winId in pairs(mapper) do
				-- restore / update new window ids from current session
				windows_manager.paneTree:findNodeByWinNr(winNr).editorGroup:updateWinId(winId)
			end
		else
			error("no window manager")
		end
		-- update / restore last layout table
		windows_manager.last_layout = utils.get_layout(tabId)
	end
	print("final")
	print(vim.inspect(SharedState.get_tab_manager()))
end

return SessionManager
