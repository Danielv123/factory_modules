local fastest_transport_belt = nil

return function ()
    -- Use cached value if available
    if fastest_transport_belt ~= nil then return fastest_transport_belt end
    -- Find fastest transport belt
    for _, prototype in pairs(game.entity_prototypes) do
        if prototype.type == "transport-belt" then
            if fastest_transport_belt == nil or prototype.belt_speed > fastest_transport_belt.belt_speed then
                fastest_transport_belt = prototype
            end
        end
    end
    return fastest_transport_belt
end
