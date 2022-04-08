local visualize_module = require "control.util.module.visualize_module"
--[[
    Get module power consumption
]]

return function (module)
    local entities_inside_module = module.surface.find_entities_filtered({
        area = {
            left_top = {
                x = module.bounding_box.min_x,
                y = module.bounding_box.min_y
            },
            right_bottom = {
                x = module.bounding_box.max_x,
                y = module.bounding_box.max_y
            }
        }
    })
    local power_consumption_per_tick = 0
    for _, entity in pairs(entities_inside_module) do
        local prototype = entity.prototype
        if prototype.electric_energy_source_prototype ~= nil then
            local energy_in_buffer = entity.energy
            -- local max_buffer = prototype.electric_energy_source_prototype.buffer_capacity
            local max_buffer = entity.electric_buffer_size
            local modifier = 1 -- energy_in_buffer / max_buffer
            local effects = entity.effects
            if effects ~= nil and effects.consumption ~= nil then
                modifier = effects.consumption.bonus
            end
            if max_buffer > 0 then
                -- Approximate slowdown when out of power
                -- The relationship between speed and buffer capacity is nonlinear, so this gets it slightly wrong
                -- by underestimating power consumption on the lower range, but it's close enough for now.
                modifier = modifier * (energy_in_buffer / max_buffer)
            end
            if prototype.energy_usage ~= nil then
                -- Multiply by activity factor
                -- ???
                -- Apply energy usage
                power_consumption_per_tick = power_consumption_per_tick + prototype.energy_usage * modifier
            end
        end
    end
    if module.power_consumption ~= power_consumption_per_tick then
        module.power_consumption = power_consumption_per_tick
        visualize_module(module)
    end
    module.power_consumption_is_up_to_date = true
    return power_consumption_per_tick
end
