return function(event)
    -- Check if the entity is part of a module
    for k,v in pairs(global.factory_modules.modules) do
        for index,entity in pairs(v.entities) do
            if not entity.entity.valid or entity.entity.unit_number == event.entity.unit_number then
                -- Remove the module
                global.factory_modules.modules[k] = nil
                -- Remove the visualization
                for _,v in pairs(v.visualization) do
                    rendering.destroy(v)
                end
                break
            end
        end
    end
end
