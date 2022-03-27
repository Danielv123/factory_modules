
--[[
    on_tick.lua
    
    This file contains the on_tick event handler.
    It is responsible for updating the IO ports of the modules.
    For each primary module, move items from the input chest to the internal input chest and from the internal output chest to the output chest.
]]

local update_primary_module = function (module)
    for _, port in pairs(module.ports) do
        local origin
        local destination
        if port.type == "input" then
            origin = port.external_chest
            destination = port.internal_chest
        else
            origin = port.internal_chest
            destination = port.external_chest
        end
        if origin.valid and destination.valid then
            local origin_inventory = origin.get_inventory(defines.inventory.chest)
            local destination_inventory = destination.get_inventory(defines.inventory.chest)
            if origin_inventory.is_empty() then
                -- Nothing to move
            else
                local items = origin_inventory.get_contents()
                for item_name, item_count in pairs(items) do
                    local moved_count = destination_inventory.insert{name=item_name, count=item_count}
                    if moved_count > 0 then
                        origin_inventory.remove{name=item_name, count=moved_count}
                    end
                end
            end
        end
    end
end

local update_module = function (module)
    if module.primary == true then
        update_primary_module(module)
    end
end

return function (event)
    -- on_tick handler
    -- game.print(event.tick)
    for _, module in pairs(global.factory_modules.modules) do
        update_module(module)
    end
end
