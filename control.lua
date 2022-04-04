local on_built_entity_handler = require "control.handlers.on_built_entity"
local on_removed_entity_handler = require "control.handlers.on_removed_entity"
local on_tick_handler = require "control.handlers.on_tick"
local migrate_to_vanilla = require "control.commands.migrate_to_vanilla"
local migrate_from_vanilla = require "control.commands.migrate_from_vanilla"
local on_gui_click_handler = require "control.user_interface.handlers.on_gui_click"
local on_player_joined_game_handler = require "control.user_interface.handlers.on_player_joined_game"

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
    if global.factory_modules.players == nil then
        global.factory_modules.players = {}
    end
end
script.on_init(init)
script.on_configuration_changed(init)
script.on_nth_tick(60, init)

script.on_event(defines.events.on_player_joined_game, function(event)
    local player = game.players[event.player_index]
    if global.factory_modules.players[player.name] == nil then
        global.factory_modules.players[player.name] = {}
    end
    on_player_joined_game_handler(event)
end)

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

-- Register commands
commands.add_command("migrate_to_vanilla", "Migrate modules to being vanilla compatible", migrate_to_vanilla)
commands.add_command("migrate_from_vanilla", "Migrate modules from vanilla to factory modules", migrate_from_vanilla)
commands.add_command("reset_gui", "Force GUI reset", function(event)
    local player = game.players[event.player_index]
    if player.gui.top.factory_modules_menu then
        player.gui.top.factory_modules_menu.destroy()
    end
    on_player_joined_game_handler(event)
end)

script.on_event(
    defines.events.on_gui_click,
    on_gui_click_handler
)
