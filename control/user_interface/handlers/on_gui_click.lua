local show_module_list = require "control.user_interface.gui.show_module_list"
local show_secondary_module_details = require "control.user_interface.gui.show_secondary_module_details"
local hide_secondary_module_details = require "control.user_interface.gui.hide_secondary_module_details"
return function (event)
    -- game.print("on_gui_click ".. event.element.name)
    if event.element.name == "module_list_btn" then
        local player = game.players[event.player_index]
        show_module_list(player)
        return
    end
    if event.element.name == "module_list_close_btn" then
        local player = game.players[event.player_index]
        player.gui.screen.module_list.destroy()
        return
    end
    if event.element.name == "module_list_info_close_btn" then
        local player = game.players[event.player_index]
        player.gui.screen.module_list.module_list_split_layout.module_list_info.destroy()
        return
    end
    if event.element.name == "secondary_module_group_close_btn" then
        local player = game.players[event.player_index]
        hide_secondary_module_details(player, event.element)
        return
    end
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
