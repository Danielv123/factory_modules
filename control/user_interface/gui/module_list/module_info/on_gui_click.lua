local GUI = require "control.user_interface.gui.gui"

return function (event)
    -- Close button
    if event.element.valid and event.element.name == "module_list_info_close_btn" then
        local player = game.players[event.player_index]
        player.gui.screen.module_list.module_list_split_layout.module_list_info.destroy()
        return
    end
    -- Show module details panel button
    if event.element.valid and event.element.name == "secondary_module_group_expand_btn" then
        local player = game.players[event.player_index]
        local index = event.element.tags.index
        global.factory_modules.players[player.name].expanded_module_panel = {
            module_id = event.element.tags.module_id,
            uid = event.element.tags.uid,
        }
        GUI.draw_module_panel(player)
        return
    end
    -- Go to position on map button
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
