local TabManager = require("better-window.tab_manager")

-- shared_state.lua
local SharedState = {}

local tab_manager = TabManager.new()

function SharedState.set_tab_manager(new_tab_manager)
	tab_manager = new_tab_manager
end

function SharedState.get_tab_manager()
	return tab_manager
end

return SharedState
