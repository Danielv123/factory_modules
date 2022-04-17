--[[
    Render list entry for the module. Has buttons to expand to show module details.
]]
return function(parent, module, index, player)
    -- for each module with same ID
    local module_frame = parent["module_group_show_panel_btn"..index]
    module_frame.tags = {
        x = module.position.x,
        y = module.position.y,
        surface = module.surface.name,
        index = index,
    }
    local left = module_frame.module_group_left
    local right = module_frame.module_group_right
    right.module_group_position.caption = "X: "..module.position.x.." Y: "..module.position.y

    local buttons = module_frame.module_group_buttons
    local expand_button = buttons.secondary_module_group_expand_btn
    expand_button.tags = {
        module_id = module.module_id,
        uid = module.uid,
    }

    if global.factory_modules.players[player.name] == nil then
        global.factory_modules.players[player.name] = {}
    end
end
