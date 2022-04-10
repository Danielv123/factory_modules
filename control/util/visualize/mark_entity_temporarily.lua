--[[
    Mark an entity with a visualization for a certain amount of ticks
]]

return function (entity, ticks)
    rendering.draw_circle({
        color = {r = 1, g = 0, b = 0},
        surface = entity.surface,
        filled = false,
        radius = 0.5,
        target = entity,
        time_to_live = ticks,
    })
end
