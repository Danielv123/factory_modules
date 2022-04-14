
local function draw_module_info(parent, module, index, player)
    local module_frame = parent.add({
        type = "frame",
        name = "module_group_"..index,
        direction = "horizontal",
        tags = {
            x = module.position.x,
            y = module.position.y,
            surface = module.surface.name,
        }
    })
    module_frame.style.vertical_align = "center"
    module_frame.style.width = 320
    local left = module_frame.add({
        type = "flow",
        name = "module_group_left",
        direction = "horizontal",
    })
    left.style.width = 100
    left.style.vertical_align = "center"
    left.style.vertically_stretchable = true
    left.add({
        type = "label",
        name = "module_group_label",
        caption = "Position:",
    })
    local right = module_frame.add({
        type = "flow",
        name = "module_group_right",
        direction = "vertical",
    })
    right.style.minimal_width = 120
    right.style.vertical_align = "center"
    right.style.vertically_stretchable = true
    right.add({
        type = "label",
        name = "module_group_position",
        caption = "X: "..module.position.x.." Y: "..module.position.y,
    })
    local buttons = module_frame.add({
        type = "flow",
        name = "module_group_buttons",
        direction = "horizontal",
    })
    buttons.add({
        type = "sprite-button",
        name = "module_group_goto_btn",
        sprite = "item/artillery-targeting-remote",
        tooltip = "Go to module",
    })
    -- Expand button
    local expand_button = buttons.add({
        type = "sprite-button",
        name = "secondary_module_group_expand_btn",
        sprite = "utility/indication_arrow", -- Points up, not down
        tooltip = "Expand module details",
    })

    if global.factory_modules.players[player.name] == nil then
        global.factory_modules.players[player.name] = {}
    end
    if global.factory_modules.players[player.name].expand_module_references == nil then
        global.factory_modules.players[player.name].expand_module_references = {}
    end
    table.insert(global.factory_modules.players[player.name].expand_module_references, {
        module = module,
        expand_button = expand_button,
    })
end

return draw_module_info
