local MIN_MODULE_SIZE = require("constants").MIN_MODULE_SIZE

local find_adjacent = function(entity)
    local entities = entity.surface.find_entities_filtered{
        area = {{entity.position.x - 1, entity.position.y - 1}, {entity.position.x + 1, entity.position.y + 1}},
        name = {"stone-wall", "steel-chest", "wooden-chest"}
    }
    return entities
end

--[[
    Directions:
    0 = north
    2 = east
    4 = south
    6 = west
]]

-- /c
local create_io = function(type, entity, direction)
    local loader_x_offset = 0
    local loader_y_offset = 0
    local chest_x_offset = 0
    local chest_y_offset = 0
    local loader_direction = (direction + 4) % 8
    game.print(loader_direction)
    if direction == 0 then
        loader_y_offset = -3
        chest_y_offset = -1
    end
    if direction == 2 then
        loader_x_offset = 2
        chest_x_offset = 1
    end
    if direction == 4 then
        loader_y_offset = 2
        chest_y_offset = 1
    end
    if direction == 6 then
        loader_x_offset = -3
        chest_x_offset = -1
    end
    --[[ Create loader ]]
    local loader_position = {
        x = entity.position.x + loader_x_offset,
        y = entity.position.y + loader_y_offset
    }
    local loader = entity.surface.create_entity{
        name = "express-loader",
        position = loader_position,
        direction = loader_direction,
        force = entity.force,
        create_build_effect_smoke = false,
    }
    --[[ Create chest ]]
    local chest_position = {
        x = entity.position.x + chest_x_offset,
        y = entity.position.y + chest_y_offset
    }
    local chest = entity.surface.create_entity{
        name = "wooden-chest",
        position = chest_position,
        direction = direction,
        force = entity.force,
        create_build_effect_smoke = false,
    }
    --[[ Module outputs require input loaders ]]
    if type == "output" then
        loader.loader_type = "input"
    elseif type == "input" then
        loader.loader_type = "output"
    end
    return {
        entities = {loader, chest}
    }
end
-- game.print(game.player.selected.direction)
-- create_io("output", game.player.selected, game.player.selected.direction)

-- Check if the walls are arranged in a rectangle
local check_if_new_module = function(entity)
    local entities = {{
        checked = false,
        entity = entity
    }}

    -- Find adjacent entities
    local number_unchecked = 1
    while number_unchecked > 0 do
        for _,i in pairs(entities) do
            if not i.checked then
                local adjacent_entities = find_adjacent(i.entity)

                for _,j in pairs(adjacent_entities) do
                    -- Check if the entity is already in the list
                    local found = false
                    for _,k in pairs(entities) do
                        if k.entity == j then
                            found = true
                            break
                        end
                    end
                    -- If not, add it
                    if not found then
                        table.insert(entities, {
                            checked = false,
                            entity = j
                        })
                        number_unchecked = number_unchecked + 1
                    end
                end
                -- Mark the entity as checked
                i.checked = true
                number_unchecked = number_unchecked - 1
            end
        end
    end

    -- Check if the entities is a rectangle
    for _,v in pairs(entities) do
        v.position = v.entity.position
    end

    local max_x = nil
    local max_y = nil
    local min_x = nil
    local min_y = nil
    for _,v in pairs(entities) do
        if max_x == nil or v.position.x > max_x then
            max_x = v.position.x
        end
        if max_y == nil or v.position.y > max_y then
            max_y = v.position.y
        end
        if min_x == nil or v.position.x < min_x then
            min_x = v.position.x
        end
        if min_y == nil or v.position.y < min_y then
            min_y = v.position.y
        end
    end

    -- Count number of entities along each wall
    local max_x_count = 0
    local max_y_count = 0
    local min_x_count = 0
    local min_y_count = 0
    for _,v in pairs(entities) do
        if v.position.x == max_x then
            max_x_count = max_x_count + 1
        end
        if v.position.y == max_y then
            max_y_count = max_y_count + 1
        end
        if v.position.x == min_x then
            min_x_count = min_x_count + 1
        end
        if v.position.y == min_y then
            min_y_count = min_y_count + 1
        end
    end

    -- Filter to have an array of only the entities making up the wall
    local filtered_entities = {}
    for _,v in pairs(entities) do
        if v.position.x == min_x 
        or v.position.x == max_x
        or v.position.y == min_y 
        or v.position.y == max_y
        then
            table.insert(filtered_entities, v)
        end
    end

    -- If the entity triggering the event isn't part of the wall, ignore
    local entity_is_part_of_wall = false
    for _,v in pairs(filtered_entities) do
        -- game.print(v.entity.unit_number .. " " .. entity.unit_number)
        if v.entity.unit_number == entity.unit_number then
            entity_is_part_of_wall = true
            break
        end
    end
    
    -- Check if the properties of the wall is consistent with being a rectangle
    if  max_x_count == min_x_count 
    and max_y_count == min_y_count 
    -- and #filtered_entities == (max_x_count + max_y_count + min_x_count + min_y_count - 4) 
    and max_x_count > MIN_MODULE_SIZE
    and max_y_count > MIN_MODULE_SIZE
    and entity_is_part_of_wall
    then
        game.print("Module created")
        local visualization = {
            rendering.draw_rectangle({
                color = {r = 0, g = 1, b = 0, a = 0.5},
                filled = false,
                left_top = {x = min_x, y = min_y},
                right_bottom = {x = max_x, y = max_y},
                surface = entity.surface,
            })
        }
        
        -- Create IO ports
        local ports = {}
        for _,v in pairs(filtered_entities) do
            local direction = 0
            if v.position.x == min_x then
                direction = 2
            end
            if v.position.y == min_y then
                direction = 4
            end
            if v.position.x == max_x then
                direction = 6
            end
            if v.position.y == max_y then
                direction = 0
            end
            if v.entity.name == "steel-chest" then
                table.insert(ports, create_io("output", v.entity, direction))
            end
            if v.entity.name == "wooden-chest" then
                table.insert(ports, create_io("input", v.entity, direction))
            end
        end

        table.insert(global.factory_modules.modules, {
            entities = filtered_entities,
            ports = ports,
            position = {
                x = (max_x + min_x) / 2,
                y = (max_y + min_y) / 2
            },
            bounding_box = {
                min_x,
                min_y,
                max_x,
                max_y
            },
            visualization = visualization,
            unit_number = entity.unit_number
        })
    end

    return true
end

return function(event)
    check_if_new_module(event.created_entity)
end
