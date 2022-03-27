return function (id)
    for _,module in pairs(global.factory_modules.modules) do
        if module.combinator.get_or_create_control_behavior().parameters[1].count == id
            and module.combinator.get_or_create_control_behavior().parameters[2].count == 1 -- Primary module
        then
            return module
        end
    end
    return false
end
