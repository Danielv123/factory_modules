return function (number)
    -- Get digits from number
    local digits = {}
    local temp_number = number
    while temp_number > 0 do
        local digit = temp_number % 10
        table.insert(digits, digit)
        temp_number = math.floor(temp_number / 10)
    end

    local icons = {{
        icon = "__base__/graphics/icons/assembling-machine-1.png",
        tint = {r=0.5, g=0.5, b=0.5, a=1}, -- Make darker to bring out number
    }}

    for i = 1, #digits do
        local icon = {
            icon = string.format("__factory_modules__/graphics/icons/generated/number_%s_%s.png", digits[#digits - i + 1], i - 1),
            tint = {r = 1, g = 1, b = 1, a = 1},
        }
        table.insert(icons, icon)
    end

    return {
        type = "electric-energy-interface",
        name = string.format("factory-module-electric-energy-interface-%s", number),
        icons = icons,
        icon_size = 64,
        icon_mipmaps = 4,
        localised_name = {"factory-modules.factory-module-eei", number},
        flags = {},
        max_health = 150,
        collision_box = {{0, 0}, {0, 0}},
        selection_box = {{-0, -0}, {0, 0}},
        selectable_in_game = false,
        energy_source =
        {
            type = "electric",
            buffer_capacity = "10GJ",
            usage_priority = "secondary-input",
            input_flow_limit = "1GW",
            output_flow_limit = "1GW"
        },
        energy_production = "0kW",
        energy_usage = "0kW",
        picture =
        {
            filename = "__core__/graphics/empty.png",
            priority = "extra-high",
            width = 1,
            height = 1
        },
        order = "h-e-e-i"
    }
end
