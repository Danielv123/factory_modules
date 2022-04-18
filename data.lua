local create_factory_module_electric_energy_interface = require "data.entities.create_factory_module_electric_energy_interface"
local constants                                       = require "constants"
local create_hidden_loader                            = require "data.entities.create_hidden_loader"

-- Create electric energy interfaces for use in modules
-- Multiple ones to show in different colors on the power graph
for i = 1, constants.ENERGY_INTERFACE_COUNT do
    local prototype = create_factory_module_electric_energy_interface(i)
    data:extend({prototype})
end


-- Create belt visualization animations
local create_belt_animations = require "data.animations.create_belt_animations"
for _, belt in pairs(data.raw["transport-belt"]) do
    data:extend(create_belt_animations(belt))
end


-- Create custom loaders disguised as normal belts
for _, belt in pairs(data.raw["transport-belt"]) do
    data:extend({
        create_hidden_loader(belt),
    })
end
