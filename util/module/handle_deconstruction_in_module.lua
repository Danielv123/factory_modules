--[[
    Deconstruction is allowed in both primary and secondary modules.
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
            local entities_in_mirror = entity.surface.find_entities_filtered({
                position = relative_position,
                radius = 0.5
            })
            if entities_in_mirror then
                for _, entity_in_mirror in pairs(entities_in_mirror) do
                    entity_in_mirror.order_deconstruction(entity_in_mirror.force, entity.last_user)
                end
            end
        end
    end
end
