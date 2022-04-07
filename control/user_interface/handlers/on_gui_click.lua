local show_module_list = require "control.user_interface.gui.show_module_list"
local show_secondary_module_details = require "control.user_interface.gui.show_secondary_module_details"
return function (event)
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
end
