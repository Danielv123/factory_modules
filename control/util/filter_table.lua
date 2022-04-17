return function (table_to_filter, func)
    local filtered = {}
    for k,v in pairs(table_to_filter) do
        if func(v) then
            table.insert(filtered, v)
        end
    end
    return filtered
end
