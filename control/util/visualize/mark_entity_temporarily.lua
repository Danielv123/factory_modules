--[[
    Mark an entity with a visualization for a certain amount of ticks
]]

return function (entity, ticks)
    if global.factory_modules.temporary_visualizations == nil then
        global.factory_modules.temporary_visualizations = {}
    end
    if #global.factory_modules.temporary_visualizations > 200 then
        return
    end
    table.insert(global.factory_modules.temporary_visualizations, {
        entity = entity,
        tick = game.tick + ticks,
        visualization = rendering.draw_circle({
            color = {r = 1, g = 0, b = 0},
            surface = entity.surface,
            filled = false,
            radius = 0.5,
            target = entity
        })
    })
end
