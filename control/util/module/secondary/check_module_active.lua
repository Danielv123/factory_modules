local visualize_module = require "control.util.module.visualize_module"
local get_primary      = require "control.util.module.get_primary"
--[[
    Secondary modules don't compute their internals, so we need to check the validity of the inside manually.
    We do that by disabling "active" when we detect issues like missing power or missing entities.
]]

local is_powered_entity = function (entity)
    -- Check if entity consumes electrical power
    local prototype = game.entity_prototypes[entity.name]
    if prototype.electric_energy_source_prototype ~= nil then
        return true
    end
end

local is_entity_powered = function (entity)
    if entity.valid then
        if is_powered_entity(entity) then
            if entity.is_connected_to_electric_network() then
                return true
            else
                return false
            end
        end
    end
    return true
end

local is_module_active = function (module)
    -- Check if the module has sufficient power
    if not module.has_sufficient_power then
        return false
    end

    -- Check if the primary module contains illegal entities
    local primary_module = get_primary(module.module_id)
    if primary_module and primary_module.contains_illegal_entities then
        return false
    end

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

    -- Check if there are ghosts
    for _, entity in pairs(entities_inside_module) do
        if entity.name == "entity-ghost" then
            module.contains_ghosts = true
            return false
        end
    end
    module.contains_ghosts = false

    -- Check if marked for deconstruction
    for _, entity in pairs(entities_inside_module) do
        if entity.to_be_deconstructed() then
            module.marked_for_deconstruction = true
            return false
        end
    end
    module.marked_for_deconstruction = false

    -- Check if all powered entities are powered
    for _, entity in pairs(entities_inside_module) do
        if not is_entity_powered(entity) then
            module.contains_unpowered_entities = true
            return false
        end
    end
    module.contains_unpowered_entities = false

    return true
end

return function (module)
    local status = is_module_active(module)

    -- If status has changed, update module visualization
    if module.active ~= status then
        module.active = status
        visualize_module(module)
    end
end
