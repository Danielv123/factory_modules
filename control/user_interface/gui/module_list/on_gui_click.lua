local GUI = require "control.user_interface.gui.gui"

return function (event)
    if event.element.valid and event.element.name == "module_group_btn" then
        local player = game.players[event.player_index]
        global.factory_modules.players[player.name].expanded_module_info = {
            module_id = event.element.tags.module_id,
        }
        GUI.draw_module_info(player)
        return
    end
end
