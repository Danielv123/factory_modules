local constants = require "constants"
local table_contains = require "control.util.table_contains"
local handle_construction_in_module = require "control.util.module.handle_construction_in_module"
local check_if_entity_is_inside_module = require "control.util.module.check_if_entity_is_inside_module"

return function(event)
    if event.created_entity ~= nil and event.created_entity.valid then
        local is_inside_module = check_if_entity_is_inside_module(event.created_entity)
        if is_inside_module ~= false then
            handle_construction_in_module(is_inside_module.module, is_inside_module.entity)
        elseif table_contains(constants.WALL_PIECES, event.created_entity.name) and event.created_entity.type ~= "transport-belt" then
            -- Add it to list of entities to check for new modules next tick
            if global.factory_modules.entities_to_check_for_new_modules == nil then
                global.factory_modules.entities_to_check_for_new_modules = {}
            end
            table.insert(global.factory_modules.entities_to_check_for_new_modules, event.created_entity)
            global.factory_modules.entities_to_check_for_new_modules_tick = game.tick

            -- check if new module in on_tick
        end
    end
end
