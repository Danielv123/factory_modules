local find_adjacent = function(entity)
    local entities = entity.surface.find_entities_filtered{
        area = {{entity.position.x - 1, entity.position.y - 1}, {entity.position.x + 1, entity.position.y + 1}},
        name = {"stone-wall", "steel-chest"}
    }
    return entities
end

-- Check if the walls are arranged in a rectangle
local check_rectangle = function(entity)
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
    
    -- Check if the properties of the wall is consistent with being a rectangle
    if  max_x_count == min_x_count 
    and max_y_count == min_y_count 
    and #entities == (max_x_count + max_y_count + min_x_count + min_y_count - 4) 
    and max_x_count > 4
    and max_y_count > 4
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
        table.insert(global.factory_modules.modules, {
            entities = entities,
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
    check_rectangle(event.created_entity)
end
