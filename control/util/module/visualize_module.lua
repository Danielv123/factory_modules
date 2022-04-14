local format_power = require "control.util.format_power"
local get_primary  = require "control.util.module.get_primary"

return function (module)
    -- Remove old visualizations
    for _,v in pairs(module.visualization) do
        rendering.destroy(v)
    end
    -- Visualize module
    local border_color = {r = 0, g = 1, b = 0, a = 0.5}
    if not module.primary then border_color = {r = 0, g = 0, b = 1, a = 0.5} end
    if not module.active then border_color = {r = 1, g = 0, b = 0, a = 0.5} end

    local visualization = {
        rendering.draw_rectangle({
            color = border_color,
            filled = false,
            left_top = {x = module.bounding_box.min_x, y = module.bounding_box.min_y},
            right_bottom = {x = module.bounding_box.max_x, y = module.bounding_box.max_y},
            surface = module.surface,
        })
    }

    local text_offset = 0.5

    -- Visualize power consumption
    if module.primary and module.power_consumption ~= nil then
        table.insert(visualization, rendering.draw_text({
            text = "Power consumption: " .. format_power(module.power_consumption),
            color = {r = 1, g = 1, b = 1, a = 1},
            surface = module.surface,
            target = {
                x = module.bounding_box.min_x + 1,
                y = module.bounding_box.min_y + text_offset
            }
        }))
        text_offset = text_offset + 0.5
    end

    -- Report illegal entities in primary module
    local primary_module
    if module.primary then
        primary_module = module
    else
        primary_module = get_primary(module.module_id)
    end
    if primary_module ~= nil and primary_module.contains_illegal_entities then
        table.insert(visualization, rendering.draw_text({
            text = "Primary module contains illegal entities",
            color = {r = 1, g = 0, b = 0, a = 1},
            surface = module.surface,
            target = {
                x = module.bounding_box.min_x + 1,
                y = module.bounding_box.min_y + text_offset
            }
        }))
        text_offset = text_offset + 0.5
    end

    -- Say if there are players in the module, affects some behaviour
    if module.is_player_nearby == true then
        table.insert(visualization, rendering.draw_text({
            text = "Player nearby, performance might be impacted to improve simulation",
            color = {r = 1, g = 1, b = 1, a = 1},
            surface = module.surface,
            target = {
                x = module.bounding_box.min_x + 1,
                y = module.bounding_box.min_y + text_offset
            }
        }))
        text_offset = text_offset + 0.5
    end

    -- Did inefficient IO update
    if module.warning_inefficient_io_lookup == true then
        table.insert(visualization, rendering.draw_text({
            text = "Inefficient IO update, check IO ports or try /migrate_to_vanilla and /migrate_from_vanilla",
            color = {r = 1, g = 1, b = 0, a = 1},
            surface = module.surface,
            target = {
                x = module.bounding_box.min_x + 1,
                y = module.bounding_box.min_y + text_offset
            }
        }))
        text_offset = text_offset + 0.5
    end

    -- IO opereations mismatch
    if module.error_io_operations_mismatch == true then
        table.insert(visualization, rendering.draw_text({
            text = "IO operations mismatch, check IO ports",
            color = {r = 1, g = 0, b = 0, a = 1},
            surface = module.surface,
            target = {
                x = module.bounding_box.min_x + 1,
                y = module.bounding_box.min_y + text_offset
            }
        }))
        text_offset = text_offset + 0.5
    end

    module.visualization = visualization
end
