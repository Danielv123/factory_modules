--[[
    Render list entry for the module. Has buttons to expand to show module details.
]]
local function render_module(parent, module, index, player)
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
    if global.factory_modules.players[player.name].expand_module_references == nil then
        global.factory_modules.players[player.name].expand_module_references = {}
    end
    table.insert(global.factory_modules.players[player.name].expand_module_references, {
        module = module,
        expand_button = expand_button,
    })
end


--[[
    Render a panel with overview of the module group and some general information.
    Below, show a list of all modules in the group using render_module()
]]
local function draw_module_info(parent, player, module_id)
    local split_layout = player.gui.screen.module_list.module_list_split_layout
    local module = nil
    for _, m in pairs(global.factory_modules.modules) do
        if m.module_id == module_id then
            module = m
            break
        end
    end
    -- If the container already exists, remove it
    if split_layout.module_list_info then
        split_layout.module_list_info.destroy()
    end
    -- Draw module info
    local module_info = split_layout.add({
        type = "frame",
        name = "module_list_info",
        direction = "vertical",
    })
    -- Draw module info header
    local module_info_header = module_info.add({
        type = "flow",
        name = "module_list_info_header",
        direction = "horizontal",
    })
    module_info_header.style.vertical_align = "center"
    module_info_header.add({
        type = "label",
        name = "module_list_info_header_label",
        caption = "Module info",
    })
    -- Draw module info close button
    module_info_header.add({
        type = "sprite-button",
        name = "module_list_info_close_btn",
        direction = "vertical",
        sprite = "utility/close_white",
        style = "close_button"
    })
    -- Draw module info content
    local module_info_content = module_info.add({
        type = "flow",
        name = "module_list_info_content",
        direction = "vertical",
    })
    -- Module ID
    module_info_content.add({
        type = "label",
        name = "module_list_info_module_id",
        direction = "horizontal",
        caption = "Module ID: " .. module_id,
    })
    local modules = {}
    for _, module in pairs(global.factory_modules.modules) do
        -- Group by module ID
        if not modules[module.module_id] then
            modules[module.module_id] = {
                module_id = module.module_id,
                module_count = 0,
                modules = {},
            }
        end
        modules[module.module_id].module_count = modules[module.module_id].module_count + 1
        table.insert(modules[module.module_id].modules, module)
    end
    -- Module count
    module_info_content.add({
        type = "label",
        name = "module_list_info_module_count",
        direction = "horizontal",
        caption = "Module count: " .. #modules[module_id].modules,
    })

    -- List modules
    local module_info_modules = module_info_content.add({
        type = "flow",
        name = "module_list_info_modules",
        direction = "vertical",
    })
    for index, module in pairs(modules[module_id].modules) do
        render_module(module_info_modules, module, index, player)
    end
end

return draw_module_info
