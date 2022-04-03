local constants = require "constants"
local table_contains = require "control.util.table_contains"
local handle_construction_in_module = require "control.util.module.handle_construction_in_module"
local check_if_entity_is_inside_module = require "control.util.module.check_if_entity_is_inside_module"
local check_if_new_module = require "control.util.module.check_if_new_module"

return function(event)
    local is_inside_module = check_if_entity_is_inside_module(event.created_entity)
    if is_inside_module ~= false then
        handle_construction_in_module(is_inside_module.module, is_inside_module.entity)
    elseif table_contains(constants.WALL_PIECES, event.created_entity.name) then
        check_if_new_module(event.created_entity)
    end
end
