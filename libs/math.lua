local m = {}

function m.clamp(min, n, max)
    return math.min(math.max(n, min), max)
end

-- interpolates a value
function m.lerp(a, b, t)
    return a + (b - a) * t
end

function m.sign(n)
    return n > 0 and 1 or (n < 0 and -1 or 0)
end

-- math.floor basicamente
function m.round(n)
    return math.floor(n + 0.5)
end

return m