return function (event)
    if event.element.name == "secondary_module_group_close_btn" then
        local player = game.players[event.player_index]
        hide_secondary_module_details(player, event.element)
        return
    end
end
