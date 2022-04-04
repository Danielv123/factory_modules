return function (player)
    if not player.gui.top.factory_modules_menu then
        player.gui.top.add({
            type = "frame",
            name = "factory_modules_menu",
            direction = "vertical",
        })
    end
    if not player.gui.top.factory_modules_menu.module_list_btn then
        player.gui.top.factory_modules_menu.add({
            type = "sprite-button",
            name = "module_list_btn",
            direction = "vertical",
            sprite = "item/assembling-machine-1",
        })
    end
end
