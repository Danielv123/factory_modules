local constants = require "constants"
local table_contains = require "control.util.table_contains"
local check_if_entity_is_inside_module = require "control.util.module.check_if_entity_is_inside_module"
local handle_deconstruction_in_module = require "control.util.module.handle_deconstruction_in_module"

local check_if_module_should_be_removed = function (event)
    -- Check if the entity is part of a module
    for k,v in pairs(global.factory_modules.modules) do
        for index,entity in pairs(v.entities) do
            if not entity.entity.valid or not event.entity.valid or entity.entity.unit_number == event.entity.unit_number then
                -- Remove special entities connected to the module ports
                for _,port in pairs(v.ports) do
                    for _,port_entity in pairs(port.entities) do
                        if port_entity.valid then
                            port_entity.destroy()
                        end
                    end
                end
                if v.electric_interface ~= nil and v.electric_interface.valid then
                    v.electric_interface.destroy()
                end
                if v.power_pole ~= nil and v.power_pole.valid then
                    v.power_pole.destroy()
                end

                -- Remove the module
                global.factory_modules.modules[k] = nil
                -- Remove the visualization
                for _,v in pairs(v.visualization) do
                    rendering.destroy(v)
                end
                break
            end
        end
    end
end

return function(event)
    if event.entity and event.entity.valid then
        if table_contains(constants.WALL_PIECES, event.entity.name) and event.entity.type ~= "transport-belt" then
            check_if_module_should_be_removed(event)
        end

        -- Mirror deconstruction inside modules
        if event.entity.valid then
            local is_inside_module = check_if_entity_is_inside_module(event.entity)
            if is_inside_module then
                handle_deconstruction_in_module(is_inside_module.module, is_inside_module.entity)
            end
        end
    end
end
