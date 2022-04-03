--[[
    Migrate modules to being vanilla compatible
]]

return function (event)
    game.print("Migrating factory modules to vanilla")
    for _, module in pairs(global.factory_modules.modules) do
        -- Remove io ports and replace with belts
        for _, port in pairs(module.ports) do
            local position = port.external_chest.position

            -- Remove the port
            for _, entity in pairs(port.entities) do
                entity.destroy()
            end
            port.external_chest.destroy({
                raise_destroy = true -- Allow the mod to cleanup module data
            })

            -- Belt positions
            local belt_positions = {}
            if port.direction == defines.direction.north then -- South side, facing north
                belt_positions = {
                    {x = position.x, y = position.y - 3},
                    {x = position.x, y = position.y - 2},
                    {x = position.x, y = position.y - 1},
                    {x = position.x, y = position.y},
                    {x = position.x, y = position.y + 1},
                    {x = position.x, y = position.y + 2},
                }
            elseif port.direction == defines.direction.east then -- West side, facing east
                belt_positions = {
                    {x = position.x - 2, y = position.y},
                    {x = position.x - 1, y = position.y},
                    {x = position.x, y = position.y},
                    {x = position.x + 1, y = position.y},
                    {x = position.x + 2, y = position.y},
                    {x = position.x + 3, y = position.y},
                }
            elseif port.direction == defines.direction.south then -- North side, facing south
                belt_positions = {
                    {x = position.x, y = position.y - 2},
                    {x = position.x, y = position.y - 1},
                    {x = position.x, y = position.y},
                    {x = position.x, y = position.y + 1},
                    {x = position.x, y = position.y + 2},
                    {x = position.x, y = position.y + 3},
                }
            elseif port.direction == defines.direction.west then -- East side, facing west
                belt_positions = {
                    {x = position.x - 3, y = position.y},
                    {x = position.x - 2, y = position.y},
                    {x = position.x - 1, y = position.y},
                    {x = position.x, y = position.y},
                    {x = position.x + 1, y = position.y},
                    {x = position.x + 2, y = position.y},
                }
            end

            -- Replace with express-transport-belt
            for _, position in pairs(belt_positions) do
                local direction
                if port.type == "input" then
                    direction = port.direction
                else
                    direction = (port.direction + 4) % 8
                end
                local entity = game.surfaces[1].create_entity{
                    name = "express-transport-belt",
                    position = position,
                    force = game.forces.player,
                    direction = direction,
                }
            end

            -- Activate all entities inside the module
            local entities = module.surface.find_entities_filtered({
                area = {
                    left_top = {
                        x = module.bounding_box.min_x,
                        y = module.bounding_box.min_y
                    },
                    right_bottom = {
                        x = module.bounding_box.max_x,
                        y = module.bounding_box.max_y
                    }
                },
            })
            for _, entity in pairs(entities) do
                entity.active = true
            end
        end
    end
end
