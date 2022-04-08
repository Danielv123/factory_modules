--[[
    Show a list of all active modules and information about them.
]]

local function render_module(parent, module, index, player)
    local module_frame = parent.add({
        type = "frame",
        name = "module_group_"..index,
        direction = "horizontal",
    })
    module_frame.style.vertical_align = "center"
    module_frame.style.width = 320
    local left = module_frame.add({
        type = "flow",
        name = "module_group_left"..index,
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
        name = "module_group_right"..index,
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
        name = "module_group_buttons"..index,
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

local function show_module_list(player, module_id)
    -- Rerender with module selected
    if module_id ~= nil and player.gui.screen.module_list then
        player.gui.screen.module_list.destroy()
    end
    if not player.gui.screen.module_list then
        local module_list = player.gui.screen.add({
            type = "frame",
            name = "module_list",
            direction = "vertical",
            auto_center = true,
        })
        -- Draw header
        local header = module_list.add({
            type = "flow",
            name = "module_list_header",
            direction = "horizontal",
        })
        header.style.vertical_align = "center"
        header.add({
            type = "label",
            name = "module_list_header_name",
            caption = {"factory-modules.module_list_caption"},
        })
        -- Draw close button
        header.add({
            type = "sprite-button",
            name = "module_list_close_btn",
            direction = "vertical",
            sprite = "utility/close_fat",
        })

        local split_layout = module_list.add({
            type = "flow",
            name = "module_list_split_layout",
            direction = "horizontal",
        })

        -- Draw module list scroll pane
        local module_list_scroll = split_layout.add({
            type = "scroll-pane",
            name = "module_list_scroll_pane",
            direction = "vertical",
        })
        local modules = {}
        for _, module in pairs(global.factory_modules.modules) do
            -- Group by module ID
            if not modules[module.module_id] then
                modules[module.module_id] = {
                    module_id = module.module_id,
                    module_count = 1,
                    modules = {},
                }
            end
            table.insert(modules[module.module_id].modules, module)
        end

        -- Draw module list
        for _, module in pairs(modules) do
            local module_list_item = module_list_scroll.add({
                type = "button",
                name = "module_group_" .. module.module_id,
                direction = "horizontal",
                caption = {"factory-modules.module_list_item_caption", module.module_id, module.module_count},
            })
        end

        if module_id then
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
                sprite = "utility/close_fat",
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
    end
end

return show_module_list