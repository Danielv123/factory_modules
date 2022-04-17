local update_secondary_module_entry = require "update_secondary_module_entry"
--[[
    Render list entry for the module. Has buttons to expand to show module details.
]]
return function(parent, module, index, player)
    if parent["module_group_show_panel_btn"..index] then
        return update_secondary_module_entry(parent, module, index, player)
        -- parent["module_group_show_panel_btn"..index].destroy()
    end
    -- for each module with same ID
    local module_frame = parent.add({
        type = "frame",
        name = "module_group_show_panel_btn"..index,
        direction = "horizontal",
        tags = {
            x = module.position.x,
            y = module.position.y,
            surface = module.surface.name,
            index = index,
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
        tags = {
            module_id = module.module_id,
            uid = module.uid,
        }
    })

    if global.factory_modules.players[player.name] == nil then
        global.factory_modules.players[player.name] = {}
    end
end
