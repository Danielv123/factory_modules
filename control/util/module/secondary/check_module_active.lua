local visualize_module = require "control.util.module.visualize_module"
local get_primary      = require "control.util.module.get_primary"
local constants        = require "constants"
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
        if entity.type ~= "transport-belt" and is_powered_entity(entity) then
            if entity.is_connected_to_electric_network() then
                return true
            else
                return false
            end
        end
    end
    return true
end

local get_entities_inside_module = function (module, index)
    local entities_inside_module = module.surface.find_entities_filtered({
        area = {
            left_top = {
                x = module.bounding_box.min_x + 1,
                y = module.bounding_box.min_y + 1
            },
            right_bottom = {
                x = module.bounding_box.max_x - 1,
                y = module.bounding_box.max_y - 1
            }
        }
    })
    module.entities_inside_module = entities_inside_module
end

local check_contains_ghosts = function (module, index)
    if module.entities_inside_module == nil then return end
    -- Check if there are ghosts
    for _, entity in ipairs(module.entities_inside_module) do
        if entity.valid and entity.name == "entity-ghost" then
            module.contains_ghosts = true
            return false
        end
    end
end

local check_marked_for_deconstruction = function (module, index)
    if module.entities_inside_module == nil then return end
    -- Check if marked for deconstruction
    for _, entity in ipairs(module.entities_inside_module) do
        if entity.valid and entity.to_be_deconstructed() then
            module.marked_for_deconstruction = true
            return false
        end
    end
    module.marked_for_deconstruction = false
end

local check_entities_powered = function (module, index)
    if module.entities_inside_module == nil then return end
    -- Check if all powered entities are powered
    for _, entity in ipairs(module.entities_inside_module) do
        if entity.valid and not is_entity_powered(entity) then
            module.contains_unpowered_entities = true
            return false
        end
    end
    module.contains_unpowered_entities = false
end

local is_module_active = function (module)
    if module.contains_ghosts == false then return false end
    if module.marked_for_deconstruction == false then return false end
    if module.contains_unpowered_entities == false then return false end
    return true
end

local spread_over_multiple_ticks = function (index, offset, module, fn)
    -- Check if the module has sufficient power
    if not module.has_sufficient_power then
        return false
    end

    -- Check if the primary module contains illegal entities
    local primary_module = get_primary(module.module_id)
    if primary_module and primary_module.contains_illegal_entities then
        return false
    end

    local tick_index = (game.tick + index + offset) % constants.MODULE_ACTIVE_CHECK_INTERVAL
    if tick_index == 0 then
        fn(module, tick_index)
    end
end

return function (module, index)
    spread_over_multiple_ticks(index * 17, 0, module, get_entities_inside_module)
    spread_over_multiple_ticks(index * 17, 1, module, check_contains_ghosts)
    spread_over_multiple_ticks(index * 17, 2, module, check_marked_for_deconstruction)
    spread_over_multiple_ticks(index * 17, 3, module, check_entities_powered)

    local status = is_module_active(module)

    -- If status has changed, update module visualization
    if module.active ~= status then
        module.active = status
        visualize_module(module)
    end
end
