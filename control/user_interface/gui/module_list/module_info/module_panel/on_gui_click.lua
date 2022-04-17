return function (event)
    if event.element.valid and event.element.name == "secondary_module_group_close_btn" then
        local player = game.players[event.player_index]
        player.gui.screen.module_list.module_list_split_layout.secondary_module_info_container.destroy()
        return
    end

    -- Go to position on map button
    if event.element.valid and event.element.name == "secondary_module_info_minimap" then
        local player = game.players[event.player_index]
        local x = event.element.tags.x
        local y = event.element.tags.y

        player.zoom_to_world({
            x = x,
            y = y,
        }, 0.1)
    end
end
