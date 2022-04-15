local constants = require "constants"
local to_relative_position = require "control.util.module.to_relative_position"
local from_relative_position = require "control.util.module.from_relative_position"
local filter_table = require "control.util.filter_table"
local check_module_active = require "control.util.module.secondary.check_module_active"
local update_power_consumption = require "control.util.module.primary.update_power_consumption"
local update_power_usage = require "control.util.module.secondary.update_power_usage"
local visualize_module = require "control.util.module.visualize_module"
local GUI = require "control.user_interface.gui.gui"
local get_uid = require "control.util.get_uid"

--[[
    on_tick.lua
    
    This file contains the on_tick event handler.
    It is responsible for updating the IO ports of the modules.
    For each primary module, move items from the input chest to the internal input chest and from the internal output chest to the output chest.
]]

local update_primary_module = function (module)
    local io_operations = {}
    for index, port in pairs(module.ports) do
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
                        io_operations[index] = {
                            type = port.type,
                            origin_inventory = to_relative_position(module, origin.position),
                            destination_inventory = to_relative_position(module, destination.position),
                            item_name = item_name,
                            item_count = moved_count
                        }
                        break -- Only move one item type, this probably breaks sushi belts
                    end
                end
            end
        end
    end

    return io_operations
end

local process_secondary_module_operations = function (module, io_operations, commit)
    local no_space = false
    if module.ports == nil or #module.ports ~= #io_operations then
        -- Something went wrong, the number of ports and the number of operations do not match
        if module.error_io_operations_mismatch ~= true then
            module.error_io_operations_mismatch = true
            visualize_module(module)
        end
        return false
    end
    if module.error_io_operations_mismatch ~= false then
        module.error_io_operations_mismatch = false
        visualize_module(module)
    end
    local did_inefficient_IO_lookup = false
    for index, operation in pairs(io_operations) do
        local port = module.ports[index]

        local origin_inventory_position = from_relative_position(module, operation.origin_inventory)
        local destination_inventory_position = from_relative_position(module, operation.destination_inventory)

        local origin = nil
        local destination = nil

        if port.internal_chest.position.x == origin_inventory_position.x and port.internal_chest.position.y == origin_inventory_position.y then
            origin = {port.internal_chest}
        elseif port.external_chest.position.x == origin_inventory_position.x and port.external_chest.position.y == origin_inventory_position.y then
            origin = {port.external_chest}
        else
            did_inefficient_IO_lookup = true
            origin = module.surface.find_entities_filtered{
                position = origin_inventory_position,
                name = {"steel-chest", "wooden-chest"},
                radius = 0.5,
            }
        end
        if port.internal_chest.position.x == destination_inventory_position.x and port.internal_chest.position.y == destination_inventory_position.y then
            destination = {port.internal_chest}
        elseif port.external_chest.position.x == destination_inventory_position.x and port.external_chest.position.y == destination_inventory_position.y then
            destination = {port.external_chest}
        else
            did_inefficient_IO_lookup = true
            destination = module.surface.find_entities_filtered{
                position = destination_inventory_position,
                name = {"steel-chest", "wooden-chest"},
                radius = 0.5,
            }
        end

        if origin and origin[1] and origin[1].valid and destination and destination[1] and destination[1].valid then
            local origin_inventory = origin[1].get_inventory(defines.inventory.chest)
            local destination_inventory = destination[1].get_inventory(defines.inventory.chest)
            if operation.type == "input" then
                local items = origin_inventory.get_contents()
                if items[operation.item_name] ~= nil and items[operation.item_name] >= operation.item_count then
                    if commit then
                        origin_inventory.remove{name=operation.item_name, count=operation.item_count}
                        -- Add to flow statistics
                        if module.force then
                            module.force.item_production_statistics.on_flow(operation.item_name, -operation.item_count)
                        end
                    end
                else
                    no_space = true
                end
            else -- Output
                if destination_inventory.can_insert({name=operation.item_name, count=operation.item_count}) then
                    -- Check how much we can insert
                    local inserted = destination_inventory.insert{name=operation.item_name, count=operation.item_count}
                    if inserted < operation.item_count then
                        no_space = true
                        destination_inventory.remove{name=operation.item_name, count=inserted}
                    else
                        -- Remove the items again if we aren't in commit mode
                        if not commit then
                            destination_inventory.remove{name=operation.item_name, count=inserted}
                        else
                            -- Add to flow statistics
                            if module.force then
                                module.force.item_production_statistics.on_flow(operation.item_name, operation.item_count)
                            end
                        end
                    end
                else
                    no_space = true
                end
            end
        end
    end

    if did_inefficient_IO_lookup == true and module.warning_inefficient_io_lookup ~= true then
        module.warning_inefficient_io_lookup = true
        visualize_module(module)
    elseif not did_inefficient_IO_lookup and module.warning_inefficient_io_lookup == true then
        module.warning_inefficient_io_lookup = false
        visualize_module(module)
    end
    return no_space
end

local update_secondary_module = function (module, io_operations)
    -- Update secondary module with IO operations from the primary module update
    -- Needs to be done twice. First pass checks that there is space to process all the operations,
    -- second pass actually processes the operations.
    local status = process_secondary_module_operations(module, io_operations, false)
    if status == false then
        process_secondary_module_operations(module, io_operations, true)
    end
end

return function (event)
    -- on_tick handler
    -- game.print(event.tick)

    if global.factory_modules.secondary_module_operations_target == nil then
        global.factory_modules.secondary_module_operations_target = {}
    end

    -- Update primary modules
    for _, module in pairs(global.factory_modules.modules) do
        -- Ensure all modules have an UID
        if module.uid == nil then
            module.uid = get_uid()
        end
        if module.primary then
            if event.tick % constants.MODULE_UPDATE_INTERVAL == module.module_id % constants.MODULE_UPDATE_INTERVAL then
                local io_operations = update_primary_module(module)
                global.factory_modules.secondary_module_operations_target[module.module_id] = {
                    io_operations = io_operations,
                    tick = game.tick,
                }
            end
            -- Update power consumption perioidically
            if event.tick % constants.MODULE_POWER_UPDATE_INTERVAL == module.module_id % constants.MODULE_POWER_UPDATE_INTERVAL
            and not module.power_consumption_is_up_to_date then
                update_power_consumption(module)
            end
        end
    end

    -- Update secondary modules
    for index, module in pairs(global.factory_modules.modules) do
        if not module.primary then
            if (event.tick + index) % constants.MODULE_UPDATE_INTERVAL == 0
                and global.factory_modules.secondary_module_operations_target[module.module_id] ~= nil -- Nil when there is no primary module
                and global.factory_modules.secondary_module_operations_target[module.module_id].tick >= game.tick - constants.MODULE_UPDATE_INTERVAL
                and module.active -- Module gets deactivated if there is construction in progress or no power
            then
                update_secondary_module(module, global.factory_modules.secondary_module_operations_target[module.module_id].io_operations)
            end
            -- Update active status periodically
            check_module_active(module, index)

            -- Update power consumption perioidically
            if event.tick % constants.MODULE_POWER_UPDATE_INTERVAL == module.module_id % constants.MODULE_POWER_UPDATE_INTERVAL then
                update_power_usage(module)
            end
        end
    end

    -- Check for delayed ghost clone tasks
    if global.factory_modules.clone_tasks ~= nil then
        for _, task in pairs(global.factory_modules.clone_tasks) do
            if task.tick == event.tick then
                task.entity.clone({
                    force = task.force,
                    position = task.position,
                    surface = task.module.surface,
                })
            end
        end
        global.factory_modules.clone_tasks = filter_table(
            global.factory_modules.clone_tasks,
            function (task)
                return task.tick > event.tick
            end
        )
    end

    -- Update player GUIs
    for _, player in pairs(game.players) do
        if global.factory_modules.players[player.name] == nil then
            global.factory_modules.players[player.name] = {}
        end
        if game.tick % 60 == 0
        and player.gui.screen.module_list
        and player.gui.screen.module_list.module_list_split_layout
        and player.gui.screen.module_list.module_list_split_layout.secondary_module_info_container ~= nil then
            GUI.draw_module_panel(player, global.factory_modules.players[player.name].selected_module_reference)
        end
    end
end
