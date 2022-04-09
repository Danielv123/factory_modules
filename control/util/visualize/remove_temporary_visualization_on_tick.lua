--[[
    Remove expired visualizations
]]

return function ()
    if global.factory_modules.temporary_visualizations == nil then
        global.factory_modules.temporary_visualizations = {}
    end
    for index, visualization in pairs(global.factory_modules.temporary_visualizations) do
        if visualization.tick <= game.tick then
            rendering.destroy(visualization.visualization)
            table.remove(global.factory_modules.temporary_visualizations, index)
        end
    end
end
