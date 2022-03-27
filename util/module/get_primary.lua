return function (id)
    for _,module in pairs(global.factory_modules.modules) do
        if module.module_id == id
            and module.primary
        then
            return module
        end
    end
    return false
end
