return function(entity)
    for _, module in pairs(global.factory_modules.modules) do
        if entity.position.x >= module.bounding_box.min_x
        and entity.position.x <= module.bounding_box.max_x
        and entity.position.y >= module.bounding_box.min_y
        and entity.position.y <= module.bounding_box.max_y
        and entity.surface == module.surface then
            return {
                entity = entity,
                module = module
            }
        end
    end
    return false
end
