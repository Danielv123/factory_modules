return function (module, position)
    return {
        x = position.x - module.position.x,
        y = position.y - module.position.y,
    }
end
