local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

return function (belt)
    local loader = {
        type = "loader-1x1",
        name = belt.name.."-loader",
        icon = "__base__/graphics/icons/express-loader.png",
        icon_size = 64, icon_mipmaps = 4,
        flags = {"placeable-neutral", "player-creation", "fast-replaceable-no-build-while-moving", "hidden"},
        max_health = 170,
        filter_count = 0,
        open_sound = sounds.machine_open,
        close_sound = sounds.machine_close,
        working_sound = sounds.express_loader,
        corpse = "small-remnants",
        resistances = {
            {
                type = "fire",
                percent = 60
            }
        },
        collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        damaged_trigger_effect = hit_effects.entity(),
        animation_speed_coefficient = 32,
        belt_animation_set = belt.belt_animation_set,
        fast_replaceable_group = "loader",
        container_distance = 1,
        speed = 0.09375,
        structure_render_layer = "lower-object",
        structure = {
            direction_in = {
                sheet = {
                    filename = "__factory_modules__/graphics/empty.png",
                    priority = "extra-high",
                    width = 8,
                    height = 8,
                }
            },
            direction_out = {
                sheet = {
                    filename = "__factory_modules__/graphics/empty.png",
                    priority = "extra-high",
                    width = 8,
                    height = 8,
                }
            }
        }
    }
    return loader
end
