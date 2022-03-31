local on_built_entity_handler = require "handlers.on_built_entity"
local on_removed_entity_handler = require "handlers.on_removed_entity"
local on_tick_handler = require "handlers.on_tick"

local function init()
    -- Handle global state
    if global.factory_modules == nil then
        global.factory_modules = {}
    end
    if global.factory_modules.modules == nil then
        global.factory_modules.modules = {}
    end
    if global.factory_modules.module_id_counter == nil then
        global.factory_modules.module_id_counter = 0
    end
    if global.factory_modules.clone_tasks == nil then
        global.factory_modules.clone_tasks = {}
    end
end
script.on_init(init)
script.on_configuration_changed(init)
script.on_nth_tick(60, init)

script.on_event(
    defines.events.on_built_entity,
    on_built_entity_handler
)
script.on_event(
    defines.events.on_robot_built_entity,
    on_built_entity_handler
)
script.on_event(
    defines.events.script_raised_built,
    on_built_entity_handler
)
script.on_event(
    defines.events.script_raised_revive,
    on_built_entity_handler
)

script.on_event(
    defines.events.on_pre_player_mined_item,
    on_removed_entity_handler
)
script.on_event(
    defines.events.on_robot_pre_mined,
    on_removed_entity_handler
)
script.on_event(
    defines.events.on_entity_died,
    on_removed_entity_handler
)
script.on_event(
    defines.events.script_raised_destroy,
    on_removed_entity_handler
)
script.on_event(
    defines.events.on_pre_ghost_deconstructed,
    on_removed_entity_handler
)

script.on_event(
    defines.events.on_tick,
    on_tick_handler
)
