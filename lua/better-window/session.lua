local utils = require("better-window.utils")
local json = require("better-window.json")

local TabManager = require("better-window.tab_manager")
local WindowManager = require("better-window.windows_manager")

local EditorGroup = require("better-window.editor_group")
local Stack = require("better-window.stack")
local Node = require("better-window.node")
local Editor = require("better-window.editor")

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

	if obj.editor_groups ~= nil and obj.last_layout ~= nil then
		setmetatable(obj, WindowManager)
	end

	if obj.win_id ~= nil and obj.stack ~= nil then
		setmetatable(obj, EditorGroup)
	end

	if obj.items ~= nil then
		setmetatable(obj, Stack)
	end

	if obj.editorGroup ~= nil and obj.parent ~= nil then
		setmetatable(obj, Node)
	end

	if obj.buf_nr ~= nil and obj.buf_name ~= nil then
		setmetatable(obj, Editor)
	end

	for _, v in pairs(obj) do
		restore_metatables(v, visited)
	end
end

function SessionManager:write_to_session_file(content)
	local session_path = vim.fn.stdpath("data") .. "/better-window/sessions/"
	local pwd = vim.fn.getcwd()
	local session_file = session_path .. string.gsub(pwd, "/", "%%") .. ".betterwindow"
	local session_dir = session_path .. vim.fn.fnamemodify(pwd, ":h")
	if vim.fn.isdirectory(session_dir) == 0 then
		local success, err_msg = pcall(vim.fn.mkdir, session_dir, "p")
		if not success then
			error("Failed to create session directory: " .. err_msg)
		end
	end
	local session_handle, err_msg = io.open(session_file, "w")
	if not session_handle then
		error("Failed to open session file: " .. err_msg)
	end
	session_handle:write(content)
	session_handle:close()
end

function SessionManager:read_from_session_file()
	local session_path = vim.fn.stdpath("data") .. "/better-window/sessions/"
	local pwd = vim.fn.getcwd()
	local session_file = session_path .. string.gsub(pwd, "/", "%%") .. ".betterwindow"

	if vim.fn.filereadable(session_file) == 0 then
		error("Session file not found or not readable: " .. session_file)
	end

	local session_handle, err_msg = io.open(session_file, "r")
	if not session_handle then
		error("Failed to open session file: " .. err_msg)
	end

	local content = session_handle:read("*all")
	session_handle:close()

	return content
end

function SessionManager:save()
	print("saving session")
	-- print(json.dump(SharedState.get_tab_manager()))
	SharedState.get_tab_manager():update_window_numbers(vim.api.nvim_tabpage_list_wins(1))
	local content = json.dump(SharedState.get_tab_manager())
	SessionManager:write_to_session_file(content)
end

-- TODO: restore / update buffer ids
function SessionManager:restore()
	print("restoring session")
	local content = SessionManager:read_from_session_file()
	local _, restored = json.load(content)
	restore_metatables(restored)

	SharedState.set_tab_manager(restored)

	-- update window ids
	local tab_manager = SharedState.get_tab_manager()
	local buf_mapper = utils.get_buf_name_to_bufnr() -- this is the buf list for all tabs

	local tabs = utils.get_tabs()

	for _, tabId in ipairs(tabs) do
		-- get window ids of current session
		local mapper = utils.get_winnr_to_win_id_mapper(tabId)
		print(vim.inspect(#mapper))

		local windows_manager = tab_manager:get_windows_manager(tabId)
		if not windows_manager then
			error("no window manager")
		end

		-- windows_manager:prettyPrint()

		if windows_manager then
			local updated_editors = {}
			-- restore / update new window ids from current session
			for winNr, winId in pairs(mapper) do
				print("mapper data", winNr, winId)
				local editor_group = windows_manager:popEditorGroupByWinNr(winNr)
				if editor_group then
					editor_group:updateWinId(winId)
					editor_group:updateBufNrs(buf_mapper)
					updated_editors[winId] = editor_group
				end
			end
			windows_manager:updateEditorGroups(updated_editors)
		else
			error("no window manager")
		end
		-- update / restore last layout table
		windows_manager.last_layout = utils.get_layout(tabId)
		print("len last layout after init", #windows_manager.last_layout)
	end
	-- print("final")
	-- print(vim.inspect(SharedState.get_tab_manager()))
end

return SessionManager
