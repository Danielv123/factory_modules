local GUI = require "control.user_interface.gui.gui"

return function (event)
    if event.element.valid and event.element.name == "module_group_btn" then
        local player = game.players[event.player_index]
        GUI.draw_module_info(player.gui.screen.module_list.module_list_split_layout, player, event.element.tags.module_id)
        return
    end
end
