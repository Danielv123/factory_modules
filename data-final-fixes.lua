local create_belt_animations = require "data.animations.create_belt_animations"
local create_hidden_loader = require "data.entities.create_hidden_loader"


-- Create belt visualization animations
for _, belt in pairs(data.raw["transport-belt"]) do
    data:extend(create_belt_animations(belt))
end


-- Create custom loaders disguised as normal belts
for _, belt in pairs(data.raw["transport-belt"]) do
    data:extend({
        create_hidden_loader(belt),
    })
end
