local get_decimals = function (number)
    if number > 10 then return 0 end
    return 1
end
return function (joule_per_tick)
    local watts = joule_per_tick * 60
    local kilowatts = watts / 1000
    local megawatts = kilowatts / 1000
    local gigawatts = megawatts / 1000
    local terawatts = gigawatts / 1000
    local petawatts = terawatts / 1000
    if petawatts > 1 then
        return string.format("%."..get_decimals(petawatts).."f PW", petawatts)
    elseif terawatts > 1 then
        return string.format("%."..get_decimals(terawatts).."f TW", terawatts)
    elseif gigawatts > 1 then
        return string.format("%."..get_decimals(gigawatts).."f GW", gigawatts)
    elseif megawatts > 1 then
        return string.format("%."..get_decimals(megawatts).."f MW", megawatts)
    elseif kilowatts > 1 then
        return string.format("%."..get_decimals(kilowatts).."f kW", kilowatts)
    else
        return string.format("%."..get_decimals(watts).."f W", watts)
    end
end
