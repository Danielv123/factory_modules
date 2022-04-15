local constants = require "constants"

local draw_module_panel = function (player)

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

    -- Draw container
    local split_layout = player.gui.screen.module_list.module_list_split_layout
    if split_layout.secondary_module_info_container then
        split_layout.secondary_module_info_container.destroy()
    end

    local container = split_layout.add({
        type = "frame",
        name = "secondary_module_info_container",
        direction = "vertical",
    })
    local header = container.add({
        type = "flow",
        name = "secondary_module_info_header",
        direction = "horizontal",
    })
    header.style.vertical_align = "center"
    header.add({
        type = "label",
        name = "secondary_module_info_header_name",
        caption = {"factory-modules.secondary_module_info_caption"},
    })
    header.add({
        type = "sprite-button",
        name = "secondary_module_group_close_btn",
        sprite = "utility/close_white",
        style = "close_button"
    })
    container.add({
        type = "label",
        name = "secondary_module_info_name",
        caption = {"factory-modules.secondary_module_info_name_caption"},
    })
    local secondary_module_info = container.add({
        type = "table",
        name = "secondary_module_info",
        column_count = 2,
    })
    -- Make it expand
    secondary_module_info.style.horizontally_stretchable = true
    secondary_module_info.add({
        type = "label",
        name = "secondary_module_info_position_label",
        caption = "Position",
    })
    secondary_module_info.add({
        type = "label",
        name = "secondary_module_info_position",
        caption = string.format("X: %d, Y: %d", module.position.x, module.position.y),
    })
    local label = secondary_module_info.add({
        type = "label",
        name = "secondary_module_info_direction_label",
        caption = "Contains ghosts: ",
    })
    local value = secondary_module_info.add({
        type = "label",
        name = "secondary_module_info_direction",
        caption = string.upper(tostring(module.contains_ghosts)) or "false",
    })
    if module.contains_ghosts then
        label.style.font_color = {r = 1, g = 0, b = 0}
        value.style.font_color = {r = 1, g = 0, b = 0}
    end
    label = secondary_module_info.add({
        type = "label",
        name = "secondary_module_info_marked_for_deconstruction",
        caption = "Marked for deconstruction: ",
    })
    value = secondary_module_info.add({
        type = "label",
        name = "secondary_module_info_marked_for_deconstruction_value",
        caption = string.upper(tostring(module.marked_for_deconstruction)) or "false",
    })
    if module.marked_for_deconstruction then
        label.style.font_color = {r = 1, g = 0, b = 0}
        value.style.font_color = {r = 1, g = 0, b = 0}
    end
    label = secondary_module_info.add({
        type = "label",
        name = "secondary_module_info_contains_unpowered",
        caption = "Contains unpowered entities: ",
    })
    value = secondary_module_info.add({
        type = "label",
        name = "secondary_module_info_contains_unpowered_value",
        caption = string.upper(tostring(module.contains_unpowered_entities)) or "false",
    })
    if module.contains_unpowered_entities then
        label.style.font_color = {r = 1, g = 0, b = 0}
        value.style.font_color = {r = 1, g = 0, b = 0}
    end
    label = secondary_module_info.add({
        type = "label",
        name = "secondary_module_info_do_detailed_update",
        caption = "Do detailed update: ",
    })
    value = secondary_module_info.add({
        type = "label",
        name = "secondary_module_info_do_detailed_update_value",
        caption = string.upper(tostring(module.last_tick_with_changes + constants.MODULE_ACTIVE_CHECK_INTERVAL * 2 >= game.tick)) or "false",
    })
    if module.last_tick_with_changes + constants.MODULE_ACTIVE_CHECK_INTERVAL * 2 >= game.tick then
        label.style.font_color = {r = 0, g = 1, b = 0}
        value.style.font_color = {r = 0, g = 1, b = 0}
    end

    -- Draw minimap
    local minimap = container.add({
        type = "minimap",
        name = "secondary_module_info_minimap",
        position = module.position,
        surface_index = module.surface.index,
        zoom = 0.75,
    })
end

return draw_module_panel
