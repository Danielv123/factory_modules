local constants = require "constants"
local filter_table = require "util.filter_table"
local table_contains = require "util.table_contains"
local get_primary_module = require "util.module.get_primary"
local handle_construction_in_module = require "util.module.handle_construction_in_module"
local check_if_entity_is_inside_module = require "util.module.check_if_entity_is_inside_module"

local find_adjacent = function(entity)
    local entities = entity.surface.find_entities_filtered{
        area = {{entity.position.x - 1, entity.position.y - 1}, {entity.position.x + 1, entity.position.y + 1}},
        name = {"stone-wall", "steel-chest", "wooden-chest", "constant-combinator", "gate"}
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
    local external_loader_x_offset = 0
    local external_loader_y_offset = 0
    local chest_x_offset = 0
    local chest_y_offset = 0
    local loader_direction = (direction + 4) % 8
    if direction == 0 then
        loader_y_offset = -3
        external_loader_y_offset = 1
        chest_y_offset = -1
    end
    if direction == 2 then
        loader_x_offset = 2
        external_loader_x_offset = -2
        chest_x_offset = 1
    end
    if direction == 4 then
        loader_y_offset = 2
        external_loader_y_offset = -2
        chest_y_offset = 1
    end
    if direction == 6 then
        loader_x_offset = -3
        external_loader_x_offset = 1
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
        force = game.forces.neutral,
        create_build_effect_smoke = false,
        move_stuck_players = true,
    }
    if loader == nil then
        -- Loader was not created, probably because it was built by bots already.
        loader = entity.surface.find_entity(
            "express-loader",
            loader_position
        )
    end

    --[[ Create external loader ]]
    local external_loader_position = {
        x = entity.position.x + external_loader_x_offset,
        y = entity.position.y + external_loader_y_offset
    }
    local external_loader = entity.surface.create_entity{
        name = "express-loader",
        position = external_loader_position,
        direction = direction,
        force = game.forces.neutral,
        create_build_effect_smoke = false,
        move_stuck_players = true,
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
        force = game.forces.neutral,
        create_build_effect_smoke = false,
        move_stuck_players = true,
        bar = 1, -- Only allow 1 slot in the chest to avoid excessive buffer
    }
    if chest == nil then
        -- Loader was not created, probably because it was built by bots already.
        chest = entity.surface.find_entity(
            "wooden-chest",
            chest_position
        )
    end

    --[[ Module outputs require input loaders ]]
    if type == "output" then
        loader.loader_type = "input"
        external_loader.loader_type = "output"
    elseif type == "input" then
        loader.loader_type = "output"
        external_loader.loader_type = "input"
    end

    --[[ Set other entity properties ]]
    loader.destructible = false
    loader.minable = false
    loader.operable = false
    external_loader.destructible = false
    external_loader.minable = false
    external_loader.operable = false
    chest.destructible = false
    chest.minable = false
    chest.operable = false

    return {
        type = type,
        entities = {loader, chest, external_loader}, -- Entities to remove on module removal
        internal_chest = chest,
        external_chest = entity,
    }
end
-- game.print(game.player.selected.direction)
-- create_io("output", game.player.selected, game.player.selected.direction)

local create_combinator = function(entity_container)
    local new_entity = {
        name = "constant-combinator",
        position = entity_container.entity.position,
        force = entity_container.entity.force,
        create_build_effect_smoke = false,
        move_stuck_players = true,
    }
    local surface = entity_container.entity.surface
    entity_container.entity.destroy()
    local combinator = surface.create_entity(new_entity)

    -- Set combinator to contain module information
    local module_id = global.factory_modules.module_id_counter + 1
    global.factory_modules.module_id_counter = module_id
    combinator.get_or_create_control_behavior().parameters = {
        {
            index = 1,
            signal = {type = "virtual", name = "signal-info"},
            count = module_id, -- Module ID, used for finding secondary nodes. Carried over when blueprinted
        },{
            index = 2,
            signal = {type = "virtual", name = "signal-green"},
            count = 1, -- 1 = Primary module, 0 = Secondary module
        }
    }

    entity_container.entity = combinator
    return combinator
end

-- Check if the walls are arranged in a rectangle
local check_if_new_module = function(entity)
    local entities = {{
        checked = false,
        entity = entity
    }}

    local surface = entity.surface

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
    local filtered_entities = filter_table(entities, function(i)
        return i.position.x == max_x
        or i.position.y == max_y
        or i.position.x == min_x
        or i.position.y == min_y
    end)

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
    and max_x_count > constants.MIN_MODULE_SIZE
    and max_y_count > constants.MIN_MODULE_SIZE
    and entity_is_part_of_wall
    then
        -- game.print("Module created")

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

        -- Create corner combinator to hold module information
        local primary
        local combinator
        for _,v in pairs(filtered_entities) do
            if v.position.x == min_x and v.position.y == min_y then
                if v.entity.name ~= "constant-combinator" then
                    combinator = create_combinator(v)
                    primary = true
                else
                    -- Try to find a primary module with the same ID
                    combinator = v.entity
                    local primary_module = get_primary_module(combinator.get_or_create_control_behavior().parameters[1].count)
                    if primary_module ~= false then
                        primary = false
                        combinator.get_or_create_control_behavior().set_signal(2, {
                            signal = {
                                type = "virtual",
                                name = "signal-green"
                            },
                            count = 0
                        })
                    else
                        -- If we didn't find a module with this ID, assign this module as the primary
                        primary = true
                        combinator.get_or_create_control_behavior().set_signal(2, {
                            signal = {
                                type = "virtual",
                                name = "signal-green"
                            },
                            count = 1
                        })
                    end
                end
            end
        end

        -- Visualize module
        local border_color = {r = 0, g = 1, b = 0, a = 0.5}
        if not primary then border_color = {r = 0, g = 0, b = 1, a = 0.5} end
        local visualization = {
            rendering.draw_rectangle({
                color = border_color,
                filled = false,
                left_top = {x = min_x, y = min_y},
                right_bottom = {x = max_x, y = max_y},
                surface = surface,
            })
        }

        table.insert(global.factory_modules.modules, {
            primary = primary,
            active = true,
            combinator = combinator,
            module_id = combinator.get_or_create_control_behavior().parameters[1].count,
            entities = filtered_entities,
            ports = ports,
            position = {
                x = (max_x + min_x) / 2,
                y = (max_y + min_y) / 2
            },
            surface = surface,
            bounding_box = {
                min_x = min_x,
                min_y = min_y,
                max_x = max_x,
                max_y = max_y
            },
            visualization = visualization
        })
    end

    return true
end

return function(event)
    local is_inside_module = check_if_entity_is_inside_module(event.created_entity)
    if is_inside_module ~= false then
        handle_construction_in_module(is_inside_module.module, is_inside_module.entity)
    elseif table_contains(constants.WALL_PIECES, event.created_entity.name) then
        check_if_new_module(event.created_entity)
    end
end
