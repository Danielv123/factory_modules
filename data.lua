local create_factory_module_electric_energy_interface = require "data.entities.create_factory_module_electric_energy_interface"
local constants                                       = require "constants"


-- Create electric energy interfaces for use in modules
-- Multiple ones to show in different colors on the power graph
for i = 1, constants.ENERGY_INTERFACE_COUNT do
    local prototype = create_factory_module_electric_energy_interface(i)
    data:extend({prototype})
end
