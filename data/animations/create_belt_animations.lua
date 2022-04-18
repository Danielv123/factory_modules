local function create_animation(prefix, sufix, y_offset, animation_set)
    return {
        type = "animation",
        name = prefix.."-"..sufix,
        priority = animation_set.priority,
        width = animation_set.width,
        height = animation_set.height,
        frame_count = animation_set.frame_count,
        stripes = {
            {
                filename = animation_set.filename,
                width_in_frames = animation_set.frame_count,
                height_in_frames = 1,
                x = 0,
                y = y_offset * animation_set.height,
            },
        },
        hr_version = {
            priority = animation_set.hr_version.priority,
            width = animation_set.hr_version.width,
            height = animation_set.hr_version.height,
            scale = animation_set.hr_version.scale,
            frame_count = animation_set.hr_version.frame_count,
            stripes = {
                {
                    filename = animation_set.hr_version.filename,
                    width_in_frames = animation_set.hr_version.frame_count,
                    height_in_frames = 1,
                    x = 0,
                    y = y_offset * animation_set.hr_version.height,
                },
            },
        }
    }
end

return function (belt)
    local animation_set = belt.belt_animation_set.animation_set
    local animations = {
        create_animation(belt.name, "east", 0, animation_set),
        create_animation(belt.name, "west", 1, animation_set),
        create_animation(belt.name, "north", 2, animation_set),
        create_animation(belt.name, "south", 3, animation_set),
    }
    return animations
end
