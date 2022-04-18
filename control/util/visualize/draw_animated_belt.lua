local get_fastest_transport_belt = require "control.util.get_fastest_transport_belt"
local directions = {}
directions[0] = "south"
directions[2] = "west"
directions[4] = "north"
directions[6] = "east"

local fastest_transport_belt = nil

return function (direction, surface, loader)
    if fastest_transport_belt == nil then
        fastest_transport_belt = get_fastest_transport_belt().name
    end
    local prototype = game.entity_prototypes[loader.name]
    return rendering.draw_animation({
        animation = fastest_transport_belt.."-"..directions[direction],
        target = loader,
        render_layer = "floor",
        -- animation_speed = prototype.animation_speed_coefficient * prototype.belt_speed,
        animation_speed = 32 * prototype.belt_speed,
        surface = surface,
        orientation = 0,
    })
end
