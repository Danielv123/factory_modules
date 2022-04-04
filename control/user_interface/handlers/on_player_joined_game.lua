local show_menu = require "control.user_interface.gui.show_menu"
--[[
    Ensure GUI is available when player joins the game
]]

return function (event)
    local player = game.players[event.player_index]

    show_menu(player)
end
