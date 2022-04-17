--[[
    Run a mapper function over a table and return a table with the results
]]

return function (tbl, f)
    local t = {}
    for k,v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end
