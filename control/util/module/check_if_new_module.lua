local constants = require "constants"
local filter_table = require "control.util.filter_table"
local get_primary_module = require "control.util.module.get_primary"
local visualize_module = require "control.util.module.visualize_module"
local update_entity_status = require "control.util.module.update_entity_status"
local floodfill = require "control.util.floodfill.floodfill"
local get_uid = require "control.util.get_uid"
local draw_animated_belt = require "control.util.visualize.draw_animated_belt"
local get_fastest_transport_belt = require "control.util.get_fastest_transport_belt"

--[[
    Directions:
    0 = north
    2 = east
    4 = south
    6 = west
]]

local create_io = function(type, entity, direction)
    local loader_x_offset = 0
    local loader_y_offset = 0
    local external_loader_x_offset = 0
    local external_loader_y_offset = 0
    local chest_x_offset = 0
    local chest_y_offset = 0
    local loader_direction = (direction + 4) % 8
    local area = {{0,0}, {0,0}}
    if direction == 0 then -- South facing belts
        loader_y_offset = -2
        external_loader_y_offset = 1
        chest_y_offset = -1
        area = {
            {entity.position.x, entity.position.y - 2},
            {entity.position.x, entity.position.y + 1},
        }
    end
    if direction == 2 then -- West facing belts
        loader_x_offset = 2
        external_loader_x_offset = -1
        chest_x_offset = 1
        area = {
            {entity.position.x - 1, entity.position.y},
            {entity.position.x + 2, entity.position.y},
        }
    end
    if direction == 4 then -- North facing belts
        loader_y_offset = 2
        external_loader_y_offset = -1
        chest_y_offset = 1
        area = {
            {entity.position.x, entity.position.y - 1},
            {entity.position.x, entity.position.y + 2},
        }
    end
    if direction == 6 then -- East facing belts
        loader_x_offset = -2
        external_loader_x_offset = 1
        chest_x_offset = -1
        area = {
            {entity.position.x - 2, entity.position.y},
            {entity.position.x + 1, entity.position.y},
        }
    end
    -- Remove obstructing belts
    local obsctructions = entity.surface.find_entities_filtered({
        area = area,
        name = entity.name,
        invert = true,
    })
    -- game.print("Removing "..#obsctructions.." obstructing belts")
    for _, obstruction in pairs(obsctructions) do
        if obstruction.valid and obstruction.name ~= "character" then
            obstruction.destroy()
        end
    end

    --[[ Create loader ]]
    local loader_position = {
        x = entity.position.x + loader_x_offset,
        y = entity.position.y + loader_y_offset
    }
    local loader_name = get_fastest_transport_belt().name
    local loader = entity.surface.create_entity{
        name = loader_name.."-loader",
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
        name = loader_name.."-loader",
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
        -- Create visualisation to complete belt look
        draw_animated_belt(direction, entity.surface, loader)
        draw_animated_belt(direction, entity.surface, external_loader)
    elseif type == "input" then
        loader.loader_type = "output"
        external_loader.loader_type = "input"
        -- Create visualisation to complete belt look
        draw_animated_belt(loader_direction, entity.surface, loader)
        draw_animated_belt(loader_direction, entity.surface, external_loader)
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
        direction = direction,
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

local create_electric_interface = function (params)
    local electric_interface = params.surface.create_entity({
        name = "factory-module-electric-energy-interface-"..params.number,
        position = params.position,
        force = game.forces.neutral,
        surface = params.surface,
        create_build_effect_smoke = false,
        move_stuck_players = true,
    })
    electric_interface.destructible = false
    electric_interface.minable = false
    electric_interface.operable = false
    electric_interface.power_production = 0
    electric_interface.power_usage = 0
    electric_interface.electric_buffer_size = 0
    return electric_interface
end

local create_power_pole = function (params)
    local power_pole = params.surface.create_entity({
        name = "big-electric-pole",
        position = params.position,
        force = game.forces.neutral,
        surface = params.surface,
        create_build_effect_smoke = false,
        move_stuck_players = true,
    })
    power_pole.destructible = false
    power_pole.minable = false
    power_pole.operable = false
    return power_pole
end

-- Check if the walls are arranged in a rectangle
local check_if_new_module = function(entity)
    local surface = entity.surface
    local force = entity.force

    -- Find entire wall
    local entities = floodfill(entity)

    local max_x = nil
    local max_y = nil
    local min_x = nil
    local min_y = nil
    for _,v in pairs(entities) do
        if v.entity.type ~= "transport-belt" then
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
            if v.position.x == min_x then -- West side
                direction = 2
            end
            if v.position.y == min_y then -- North side
                direction = 4
            end
            if v.position.x == max_x then -- East side
                direction = 6
            end
            if v.position.y == max_y then -- South side
                direction = 0
            end
            -- If the entity is a transport-belt, replace with the corresponding chest
            if v.entity.type == "transport-belt" then
                local name
                if direction == 0 then
                    if v.entity.direction == defines.direction.north then
                        name = "wooden-chest"
                    elseif v.entity.direction == defines.direction.south then
                        name = "steel-chest"
                    end
                elseif direction == 2 then
                    if v.entity.direction == defines.direction.east then
                        name = "wooden-chest"
                    elseif v.entity.direction == defines.direction.west then
                        name = "steel-chest"
                    end
                elseif direction == 4 then
                    if v.entity.direction == defines.direction.north then
                        name = "steel-chest"
                    elseif v.entity.direction == defines.direction.south then
                        name = "wooden-chest"
                    end
                elseif direction == 6 then
                    if v.entity.direction == defines.direction.east then
                        name = "steel-chest"
                    elseif v.entity.direction == defines.direction.west then
                        name = "wooden-chest"
                    end
                else
                    game.print("Invalid transport belt direction")
                    return false
                end
                if name ~= nil then
                    v.entity.destroy()
                    v.entity = surface.create_entity({
                        name = name,
                        position = v.position,
                        force = force,
                        create_build_effect_smoke = false,
                        move_stuck_players = true,
                    })
                end
            end

            if v.entity.name == "steel-chest" then
                table.insert(ports, create_io("output", v.entity, direction))
            end
            if v.entity.name == "wooden-chest" then
                table.insert(ports, create_io("input", v.entity, direction))
            end
        end

        table.sort(ports, function(a, b)
            if a.external_chest.position.x == b.external_chest.position.x then
                return a.external_chest.position.y < b.external_chest.position.y
            else
                return a.external_chest.position.x < b.external_chest.position.x
            end
        end)

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
                    if primary_module ~= nil then
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

        local module_id = combinator.get_or_create_control_behavior().parameters[1].count

        -- Create electic-energy-interface to simulate power draw
        local electric_interface = create_electric_interface({
            position = {
                x = min_x + 1,
                y = min_y + 1,
            },
            surface = surface,
            number = (module_id % constants.ENERGY_INTERFACE_COUNT) + 1,
        })
        table.insert(filtered_entities, {
            checked = true,
            entity = electric_interface,
            position = electric_interface.position,
        })
        -- Create large power pole to connect module easier
        local power_pole = create_power_pole({
            position = {
                x = min_x + 1,
                y = min_y + 1,
            },
            surface = surface,
        })
        table.insert(filtered_entities, {
            checked = true,
            entity = power_pole,
            position = power_pole.position,
        })

        local entity_number_lookup = {}
        for _,v in pairs(filtered_entities) do
            entity_number_lookup[v.entity.unit_number] = true
        end

        local module = {
            uid = get_uid(),
            primary = primary,
            active = true,
            combinator = combinator,
            electric_interface = electric_interface,
            power_pole = power_pole,
            module_id = module_id,
            entities = filtered_entities,
            entity_number_lookup = entity_number_lookup,
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
            visualization = {},
            force = force,
            has_sufficient_power = false,
            last_tick_with_changes = game.tick,
        }
        visualize_module(module)
        update_entity_status(module)

        table.insert(global.factory_modules.modules, module)
        return module
    end

    return false
end

return check_if_new_module
