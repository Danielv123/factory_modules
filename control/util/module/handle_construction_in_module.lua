local table_contains = require "control.util.table_contains"
local constants      = require "constants"
local visualize_module = require "control.util.module.visualize_module"
--[[
    When entities are constructed inside a module it should be mirrored to other modules with the same ID as blueprint ghosts.
    Construction is allowed in both primary and secondary modules.
    When entities are removed from a module it should also be mirrored as deconstruction orders.
]]

return function (module, entity)
    for _, mod in pairs(global.factory_modules.modules) do
        -- Mirror construction inside modules
        if mod.module_id == module.module_id and mod ~= module then
            -- Calculate position relative to the module
            local relative_position = {
                x = entity.position.x - module.position.x + mod.position.x,
                y = entity.position.y - module.position.y + mod.position.y,
            }
            if entity.name == "entity-ghost" then
                table.insert(global.factory_modules.clone_tasks, {
                    entity = entity,
                    position = relative_position,
                    force = entity.force,
                    player = entity.last_user,
                    module = module,
                    tick = game.tick + 1,
                })
            else
                -- Place ghost version of the entity
                local name = entity.name
                local obsctructions = entity.surface.find_entities_filtered{
                    position = relative_position,
                    radius = 0.5
                }
                if #obsctructions < 1 then
                    local belt_to_ground_type = nil
                    if entity.type == "underground-belt" then
                        belt_to_ground_type = entity.belt_to_ground_type
                    end
                    local ghost = entity.surface.create_entity{
                        name = "entity-ghost",
                        position = relative_position,
                        force = entity.force,
                        direction = entity.direction,
                        player = entity.last_user,
                        fast_replace = true,
                        spill = false,
                        move_stuck_players = true,

                        -- Transfer data from entity
                        inner_name = name,
                        type = belt_to_ground_type,
                    }
                end
            end
        end
    end
    -- Set entities in secondary modules to inactive
    if not module.primary then
        entity.active = false
    else
        -- If an illegal entity is built in a primary module, deactivate it
        if table_contains(constants.NOT_ALLOWED_IN_MODULE, entity.name) then
            module.contains_illegal_entities = true
            visualize_module(module)
        end
    end
end
