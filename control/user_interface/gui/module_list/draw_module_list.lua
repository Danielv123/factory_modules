local filter_table = require "control.util.filter_table"
--[[
    Show a list of all active modules and information about them.
]]

local function draw_module_list(player, module_id)
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
        local spacer = header.add{ type = "flow" }
        spacer.style.horizontally_stretchable = true
        -- Draw close button
        header.add({
            type = "sprite-button",
            name = "module_list_close_btn",
            direction = "vertical",
            sprite = "utility/close_white",
            style = "close_button"
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
                    module_count = 0,
                    modules = {},
                }
            end
            modules[module.module_id].module_count = modules[module.module_id].module_count + 1
            table.insert(modules[module.module_id].modules, module)
        end

        -- Draw module list
        for _, module in pairs(modules) do
            -- add flow
            local module_list_item = module_list_scroll.add({
                type = "flow",
                name = "module_list_item_" .. module.module_id,
                direction = "vertical",
            })
            module_list_item.add({
                type = "button",
                name = "module_group_btn",
                direction = "horizontal",
                tags = {
                    module_id = module.module_id,
                },
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

return draw_module_list
