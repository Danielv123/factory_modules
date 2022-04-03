local check_if_new_module = require "control.util.module.check_if_new_module"
--[[
    Migrate from vanilla to this mod
]]

return function (event)
    -- Detect modules using old combinators
    game.print("Migrating modules from vanilla to factory modules")
    for _, surface in pairs(game.surfaces) do
        local combinators = surface.find_entities_filtered({
            type = "constant-combinator",
        })

        -- Check if the combinator is a module identifier
        for _, combinator in pairs(combinators) do
            local parameters = combinator.get_or_create_control_behavior().parameters
            if parameters[1].signal.name == "signal-info" and parameters[1].count ~= nil and parameters[2].signal.name == "signal-green" then
                local module_id = parameters[1].count
                local migrated = false
                -- Check if the combinator is part of an existing module
                for _, module in pairs(global.factory_modules.modules) do
                    -- Check if the entity is the same
                    if module.combinator == combinator then
                        migrated = true
                    end
                end

                if not migrated then
                    game.print("Migrating module with id " .. module_id)
                    local module = check_if_new_module(combinator)
                end
            end
        end
    end
end
