--[[
    When entities are constructed inside a module it should be mirrored to other modules with the same ID as blueprint ghosts.
    Construction is allowed in both primary and secondary modules.
    When entities are removed from a module it should also be mirrored as deconstruction orders.
]]

return function (module, entity)
    for _, mod in pairs(global.factory_modules.modules) do
        if mod.module_id == module.module_id and mod ~= module then
            -- Calculate position relative to the module
            local relative_position = {
                x = entity.position.x - module.position.x + mod.position.x,
                y = entity.position.y - module.position.y + mod.position.y,
            }
            -- Place ghost version of the entity
            local name = entity.name
            if name == "entity-ghost" then
                name = entity.ghost_name
            end
            local obsctructions = entity.surface.find_entities_filtered{
                position = relative_position,
                radius = 0.5
            }
            if #obsctructions < 1 then
                local ghost = entity.surface.create_entity{
                    name = "entity-ghost",
                    position = relative_position,
                    force = entity.force,
                    direction = entity.direction,
                    player = entity.last_user,
                    fast_replace = true,
                    spill = false,
                    move_stuck_players = true,
                    inner_name = name,
                }
            end
        end
    end
end
