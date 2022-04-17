local GUI = require "control.user_interface.gui.gui"

return function (event)
    -- Show module details panel button
    if event.element.valid and event.element.name == "secondary_module_group_expand_btn" then
        local player = game.players[event.player_index]
        global.factory_modules.players[player.name].expanded_module_panel = {
            module_id = event.element.tags.module_id,
            uid = event.element.tags.uid,
        }
        GUI.draw_module_panel(player)
        return
    end
    -- Go to position on map button
    if event.element.valid and event.element.name == "module_group_goto_btn" then
        local player = game.players[event.player_index]
        local x = event.element.parent.parent.tags.x
        local y = event.element.parent.parent.tags.y

        player.zoom_to_world({
            x = x,
            y = y,
        }, 0.1)
    end
end
