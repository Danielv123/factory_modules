return function ()
    -- Get a unique id
    if global.factory_modules.uid_counter == nil then
        global.factory_modules.uid_counter = 0
    end
    global.factory_modules.uid_counter = global.factory_modules.uid_counter + 1
    return global.factory_modules.uid_counter
end
