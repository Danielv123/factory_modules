local GUI = require "control.user_interface.gui.gui"
local module_list_on_gui_click = require "control.user_interface.gui.module_list.on_gui_click"
local module_info_on_gui_click = require "control.user_interface.gui.module_list.module_info.on_gui_click"
local module_panel_on_gui_click = require "control.user_interface.gui.module_list.module_info.module_panel.on_gui_click"
local secondary_module_entry_on_gui_click = require "control.user_interface.gui.module_list.module_info.secondary_module_entry.on_gui_click"

return function(event)
    if event.element.name == "module_list_btn" then
        local player = game.players[event.player_index]
        GUI.draw_module_list(player)
        return
    end
    if event.element.name == "module_list_close_btn" then
        local player = game.players[event.player_index]
        player.gui.screen.module_list.destroy()
        return
    end

    module_list_on_gui_click(event)
    module_info_on_gui_click(event)
    module_panel_on_gui_click(event)
    secondary_module_entry_on_gui_click(event)
end
