local constants = require "constants"
local mark_entity_temporarily = require "control.util.visualize.mark_entity_temporarily"
local filter_table            = require "control.util.filter_table"

local GetNeighbors = function (surface, position, entity)
    local entities = {}
    for _, entity in pairs(surface.find_entities_filtered({
            radius = 0,
            position = {
                x = position.x - 1,
                y = position.y
            },
            name = constants.WALL_PIECES,
        }))
    do
        table.insert(entities, entity)
    end
    for _, entity in pairs(surface.find_entities_filtered({
            radius = 0,
            position = {
                x = position.x + 1,
                y = position.y
            },
            name = constants.WALL_PIECES,
        }))
    do
        table.insert(entities, entity)
    end
    for _, entity in pairs(surface.find_entities_filtered({
            radius = 0,
            position = {
                x = position.x,
                y = position.y - 1
            },
            name = constants.WALL_PIECES,
        }))
    do
        table.insert(entities, entity)
    end
    for _, entity in pairs(surface.find_entities_filtered({
            radius = 0,
            position = {
                x = position.x,
                y = position.y + 1
            },
            name = constants.WALL_PIECES,
        }))
    do
        table.insert(entities, entity)
    end

    -- Filter out entities in the direction the belt is facing
    if entity.type == "transport-belt" then
        entities = filter_table(entities, function (found_entity)
            if entity.direction == defines.direction.north then
                return found_entity.position.y == position.y
            elseif entity.direction == defines.direction.east then
                return found_entity.position.x == position.x
            elseif entity.direction == defines.direction.south then
                return found_entity.position.y == position.y
            elseif entity.direction == defines.direction.west then
                return found_entity.position.x == position.x
            end
        end)
    end

    return entities
end

local floodfill = function (entity)
    local surface = entity.surface
    local unit_numbers = {
        [entity.unit_number] = true
    }

    local position = entity.position
    local wall_entities = {}
    local queue = {
        {
            position = position,
            unit_number = entity.unit_number,
            entity = entity,
        }
    }
    while #queue > 0 do
        local current = table.remove(queue, 1)
        table.insert(wall_entities, current)
        local neighbors = GetNeighbors(surface, current.position, current.entity)
        for _, neighbor in pairs(neighbors) do
            if neighbor.unit_number ~= current.unit_number then
                if not unit_numbers[neighbor.unit_number] then
                    unit_numbers[neighbor.unit_number] = true
                    table.insert(queue, {
                        position = neighbor.position,
                        unit_number = neighbor.unit_number,
                        entity = neighbor,
                    })
                    -- mark_entity_temporarily(neighbor, 60)
                end
            end
        end
    end

    return wall_entities
end
return floodfill
