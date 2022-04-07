local filter_table = require "control.util.filter_table"
local draw_secondary_module_details = require "control.user_interface.gui.draw_secondary_module_details"

return function (event)
    local player = game.players[event.player_index]
    
    global.factory_modules.players[player.name].expand_module_references = filter_table(
        global.factory_modules.players[player.name].expand_module_references, function (value)
        return value.expand_button.valid
    end)

    for _, reference in pairs(global.factory_modules.players[player.name].expand_module_references) do
        if event.element == reference.expand_button then
            -- Save the selected element in global so we can update the GUI dynamically on tick
            global.factory_modules.players[player.name].selected_module_reference = reference
            draw_secondary_module_details.draw(player, reference)
            return
        end
    end
end
