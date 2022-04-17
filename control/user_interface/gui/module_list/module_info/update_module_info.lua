local draw_secondary_module_entry = require "secondary_module_entry.draw_secondary_module_entry"
local get_module_groups             = require "control.util.gui.get_module_groups"
--[[
    Update information in module info without redrawing the whole panel
]]

return function (player)
    local module_id = global.factory_modules.players[player.name].expanded_module_info.module_id
    local module_info = player.gui.screen.module_list.module_list_split_layout.module_list_info
    local content = module_info.module_list_info_content
    local module_info_modules = content.module_list_info_modules

    local modules = get_module_groups()

    -- Remove extraneous modules
    if global.factory_modules.players[player.name].secondary_module_entries_drawn ~= nil 
    and global.factory_modules.players[player.name].secondary_module_entries_drawn > #modules[module_id].modules then
        for i = #modules[module_id].modules, global.factory_modules.players[player.name].secondary_module_entries_drawn do
            local module_info_module = module_info_modules["module_group_show_panel_btn"..i]
            if module_info_module ~= nil and module_info_module.valid then
                module_info_module.destroy()
            end
        end
    end
    -- Update modules without having to redraw them
    for index, module in pairs(modules[module_id].modules) do
        draw_secondary_module_entry(module_info_modules, module, index, player)
        global.factory_modules.players[player.name].secondary_module_entries_drawn = index
    end
end
