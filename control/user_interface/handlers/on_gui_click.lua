local GUI = require "control.user_interface.gui.gui"
local module_list_on_gui_click = require "control.user_interface.gui.module_list.on_gui_click"
local module_info_on_gui_click = require "control.user_interface.gui.module_list.module_info.on_gui_click"
local module_panel_on_gui_click = require "control.user_interface.gui.module_list.module_info.module_panel.on_gui_click"

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
end

--[[
    return function (event)
    -- game.print("on_gui_click ".. event.element.name)

    for _, module in pairs(global.factory_modules.modules) do
        if event.element.name == "module_group_"..module.module_id then
            local player = game.players[event.player_index]
            show_module_list(player, module.module_id)
            return
        end
    end

    if event.element.name == "secondary_module_group_expand_btn" then
        show_secondary_module_details(event)
    end

    if event.element.name == "module_group_goto_btn" then
        local player = game.players[event.player_index]
        local x = event.element.parent.parent.tags.x
        local y = event.element.parent.parent.tags.y

        player.open_map({
            x = x,
            y = y,
        })
    end
end
]]