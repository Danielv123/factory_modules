return function(entity)
    local x = entity.position.x
    local y = entity.position.y
    local surface = entity.surface
    for _, module in pairs(global.factory_modules.modules) do
        local bounding_box = module.bounding_box
        if x > bounding_box.min_x
        and x < bounding_box.max_x
        and y > bounding_box.min_y
        and y < bounding_box.max_y
        and surface == module.surface then
            return {
                entity = entity,
                module = module
            }
        end
    end
    return false
end
