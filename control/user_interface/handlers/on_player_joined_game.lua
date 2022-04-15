local show_menu = require "control.user_interface.gui.show_menu"
--[[
    Ensure GUI is available when player joins the game
]]

return function (event)
    local player = game.players[event.player_index]
    if global.factory_modules.players[player.name] == nil then
        global.factory_modules.players[player.name] = {}
    end
    show_menu(player)
end
