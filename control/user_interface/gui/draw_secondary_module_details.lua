local draw = function (player, reference)
    if reference == nil then return end
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
        caption = string.format("X: %d, Y: %d", reference.module.position.x, reference.module.position.y),
    })
    local label = secondary_module_info.add({
        type = "label",
        name = "secondary_module_info_direction_label",
        caption = "Contains ghosts: ",
    })
    local value = secondary_module_info.add({
        type = "label",
        name = "secondary_module_info_direction",
        caption = string.upper(tostring(reference.module.contains_ghosts)) or "false",
    })
    if reference.module.contains_ghosts then
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
        caption = string.upper(tostring(reference.module.marked_for_deconstruction)) or "false",
    })
    if reference.module.marked_for_deconstruction then
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
        caption = string.upper(tostring(reference.module.contains_unpowered_entities)) or "false",
    })
    if reference.module.contains_unpowered_entities then
        label.style.font_color = {r = 1, g = 0, b = 0}
        value.style.font_color = {r = 1, g = 0, b = 0}
    end

    -- Draw minimap
    local minimap = container.add({
        type = "minimap",
        name = "secondary_module_info_minimap",
        position = reference.module.position,
        surface_index = reference.module.surface.index,
        zoom = 0.75,
    })
end

return {
    draw = draw
}
