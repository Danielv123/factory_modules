local on_built_entity_handler = require("handlers.on_built_entity")
local on_removed_entity_handler = require("handlers.on_removed_entity")
local on_tick_handler = require("handlers.on_tick")

local wall_segment_filter = {
    {filter = "name", name = "stone-wall"},
    {filter = "name", name = "steel-chest"},
    {filter = "name", name = "wooden-chest"},
}

local function init()
    -- Handle global state
    if global.factory_modules == nil then
        global.factory_modules = {}
    end
    if global.factory_modules.modules == nil then
        global.factory_modules.modules = {}
    end
end
script.on_init(init)
script.on_configuration_changed(init)

script.on_event(
    defines.events.on_built_entity,
    on_built_entity_handler,
    wall_segment_filter
)
script.on_event(
    defines.events.on_robot_built_entity,
    on_built_entity_handler,
    wall_segment_filter
)
script.on_event(
    defines.events.script_raised_built,
    on_built_entity_handler,
    wall_segment_filter
)
script.on_event(
    defines.events.script_raised_revive,
    on_built_entity_handler,
    wall_segment_filter
)

script.on_event(
    defines.events.on_pre_player_mined_item,
    on_removed_entity_handler,
    wall_segment_filter
)
script.on_event(
    defines.events.on_robot_pre_mined,
    on_removed_entity_handler,
    wall_segment_filter
)
script.on_event(
    defines.events.on_entity_died,
    on_removed_entity_handler,
    wall_segment_filter
)
script.on_event(
    defines.events.script_raised_destroy,
    on_removed_entity_handler,
    wall_segment_filter
)

script.on_event(
    defines.events.on_tick,
    on_tick_handler
)
