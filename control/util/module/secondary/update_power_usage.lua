local get_primary = require "control.util.module.get_primary"
local constants   = require "constants"
return function (module)
    -- Update electric energy interface power consumption with the same as the primary module
    if not module.electric_interface.valid then return end
    local primary_module = get_primary(module.module_id)
    if primary_module then
        -- Set buffer size to amount of electricity needed to power the module for the entirety of MODULE_POWER_UPDATE_INTERVAL
        local consumption = primary_module.power_consumption or 0
        module.electric_interface.electric_buffer_size = consumption * constants.MODULE_POWER_UPDATE_INTERVAL

        -- If sufficient charge is gathered, the module will be powered
        if module.electric_interface.energy - primary_module.power_consumption * constants.MODULE_POWER_UPDATE_INTERVAL == 0 then
            module.electric_interface.power_usage = primary_module.power_consumption or 0
            module.has_sufficient_power = true
        else
            -- If low on charge, turn off module
            module.electric_interface.power_usage = 0
            module.has_sufficient_power = false
        end
    else
        module.electric_interface.power_usage = 0
    end
end
