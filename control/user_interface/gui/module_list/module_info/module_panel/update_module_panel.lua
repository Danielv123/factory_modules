local constants = require "constants"

--[[
    Update information in module panel without redrawing the whole panel, called in on_tick
]]

return function (player)
    local container = player.gui.screen.module_list.module_list_split_layout.secondary_module_info_container

    -- Get module to draw from player state
    if global.factory_modules.players[player.name].expanded_module_panel == nil then return end
    local module_id = global.factory_modules.players[player.name].expanded_module_panel.module_id
    local uid = global.factory_modules.players[player.name].expanded_module_panel.uid
    local module = nil
    for _, m in pairs(global.factory_modules.modules) do
        if m.uid == uid then
            module = m
            break
        end
    end

    -- If module is gone, close the panel
    if module == nil then
        global.factory_modules.players[player.name].expanded_module_panel = nil
        container.destroy()
        return
    end

    -- Draw container
    local white = {r = 1, g = 1, b = 1}
    local red = {r = 1, g = 0, b = 0}
    local green = {r = 0, g = 1, b = 0}
    local yellow = {r = 1, g = 1, b = 0}
    local blue = {r = 0, g = 0, b = 1}
    
    -- Update table data
    local info_table = container.secondary_module_info
    info_table.secondary_module_info_position.caption = string.format("X: %d, Y: %d", module.position.x, module.position.y)
    info_table.secondary_module_info_ghosts.caption = string.upper(tostring(module.contains_ghosts)) or "false"
    if module.contains_ghosts then
        info_table.secondary_module_info_ghosts_label.style.font_color = red
        info_table.secondary_module_info_ghosts.style.font_color = red
    else
        info_table.secondary_module_info_ghosts_label.style.font_color = white
        info_table.secondary_module_info_ghosts.style.font_color = white
    end
    info_table.secondary_module_info_marked_for_deconstruction_value.caption = string.upper(tostring(module.marked_for_deconstruction)) or "false"
    if module.marked_for_deconstruction then
        info_table.secondary_module_info_marked_for_deconstruction.style.font_color = red
        info_table.secondary_module_info_marked_for_deconstruction_value.style.font_color = red
    else
        info_table.secondary_module_info_marked_for_deconstruction.style.font_color = white
        info_table.secondary_module_info_marked_for_deconstruction_value.style.font_color = white
    end
    info_table.secondary_module_info_contains_unpowered_value.caption = string.upper(tostring(module.contains_unpowered_entities)) or "false"
    if module.contains_unpowered_entities then
        info_table.secondary_module_info_contains_unpowered.style.font_color = red
        info_table.secondary_module_info_contains_unpowered_value.style.font_color = red
    else
        info_table.secondary_module_info_contains_unpowered.style.font_color = white
        info_table.secondary_module_info_contains_unpowered_value.style.font_color = white
    end
    info_table.secondary_module_info_do_detailed_update_value.caption = string.upper(tostring(module.last_tick_with_changes + constants.MODULE_ACTIVE_CHECK_INTERVAL * 2 >= game.tick)) or "false"
    if module.last_tick_with_changes + constants.MODULE_ACTIVE_CHECK_INTERVAL * 2 >= game.tick then
        info_table.secondary_module_info_do_detailed_update.style.font_color = yellow
        info_table.secondary_module_info_do_detailed_update_value.style.font_color = yellow
    else
        info_table.secondary_module_info_do_detailed_update.style.font_color = white
        info_table.secondary_module_info_do_detailed_update_value.style.font_color = white
    end

    container.minimap_container.secondary_module_info_minimap.position = module.position
    container.minimap_container.secondary_module_info_minimap.surface_index = module.surface.index
    container.minimap_container.secondary_module_info_minimap.tags = {
        x = module.position.x,
        y = module.position.y,
    }
end
