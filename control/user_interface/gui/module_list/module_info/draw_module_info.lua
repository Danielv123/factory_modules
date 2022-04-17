local draw_secondary_module_entry = require "secondary_module_entry.draw_secondary_module_entry"
local update_module_info          = require "update_module_info"

--[[
    Render a panel with overview of the module group and some general information.
    Below, show a list of all modules in the group using draw_secondary_module_entry()
]]
local function draw_module_info(player)
    local module_id = global.factory_modules.players[player.name].expanded_module_info.module_id
    local split_layout = player.gui.screen.module_list.module_list_split_layout

    -- If the container already exists, remove it
    if split_layout.module_list_info then
        return update_module_info(player)
        -- split_layout.module_list_info.destroy()
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
        draw_secondary_module_entry(module_info_modules, module, index, player)
    end
    update_module_info(player)
end

return draw_module_info
