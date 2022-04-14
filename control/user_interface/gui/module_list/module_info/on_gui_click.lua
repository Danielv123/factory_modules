return function (event)
    if event.element.name == "module_list_info_close_btn" then
        local player = game.players[event.player_index]
        player.gui.screen.module_list.module_list_split_layout.module_list_info.destroy()
        return
    end
end
