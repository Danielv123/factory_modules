--[[
    If this is a secondary module, set entities to inactive. If it is a primary module, set them to active.
]]

return function (module)
    local entities = module.surface.find_entities_filtered({
        area = {
            left_top = {
                x = module.bounding_box.min_x + 1,
                y = module.bounding_box.min_y + 1
            },
            right_bottom = {
                x = module.bounding_box.max_x - 1,
                y = module.bounding_box.max_y - 1
            }
        },
        type = {"combat-robot", "construction-robot", "logistic-robot", "spider-vehicle", "car", "character"},
        invert = true,
    })
    for _, entity in pairs(entities) do
        entity.active = module.primary
    end
end
