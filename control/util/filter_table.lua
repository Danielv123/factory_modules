return function (table, func)
    local filtered = {}
    for k,v in pairs(table) do
        if func(v) then
            filtered[k] = v
        end
    end
    return filtered
end
