return function ()
    local modules = {}
    for _, module in pairs(global.factory_modules.modules) do
        -- Group by module ID
        if not modules[module.module_id] then
            modules[module.module_id] = {
                module_id = module.module_id,
                module_count = 0,
                modules = {},
            }
        end
        modules[module.module_id].module_count = modules[module.module_id].module_count + 1
        table.insert(modules[module.module_id].modules, module)
    end
    return modules
end
