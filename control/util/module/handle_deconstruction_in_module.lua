local table_contains = require "control.util.table_contains"
local constants      = require "constants"
local visualize_module = require "control.util.module.visualize_module"
--[[
    Deconstruction is allowed in both primary and secondary modules.
    When entities are removed from a module it should also be mirrored as deconstruction orders.
]]

return function (module, entity)
    module.last_tick_with_changes = game.tick
    module.power_consumption_is_up_to_date = false
    for _, mod in pairs(global.factory_modules.modules) do
        if mod.module_id == module.module_id and mod ~= module then
            -- Mark module as changed
            mod.last_tick_with_changes = game.tick
            -- Calculate position relative to the module
            local relative_position = {
                x = entity.position.x - module.position.x + mod.position.x,
                y = entity.position.y - module.position.y + mod.position.y,
            }
            local entities_in_mirror = entity.surface.find_entities_filtered({
                position = relative_position,
                radius = 0.5,
                type = entity.type,
            })
            if entities_in_mirror then
                for _, entity_in_mirror in pairs(entities_in_mirror) do
                    entity_in_mirror.order_deconstruction(entity_in_mirror.force, entity.last_user)
                end
            end
        end
    end
    -- Check if the module still contains illegal entities
    if module.primary and module.contains_illegal_entities then
        local entities = module.surface.find_entities_filtered({
            area = {
                left_top = {
                    x = module.bounding_box.min_x + 1,
                    y = module.bounding_box.min_y + 1
                },
                right_bottom = {
                    x = module.bounding_box.max_x - 1,
                    y = module.bounding_box.max_y - 1
                }
            },
        })
        local contains_illegal_entities = false
        for _, entity2 in pairs(entities) do
            if table_contains(constants.NOT_ALLOWED_IN_MODULE, entity2.name) and entity2 ~= entity then
                contains_illegal_entities = true
                break
            end
        end
        if not contains_illegal_entities then
            module.contains_illegal_entities = false
            visualize_module(module)
        end
    end
end
