local math = {}

function math.clamp(min, n, max)
    return math.min(math.max(n, min), max)
end

function math.lerp(a, b, t)
    return a + (b - a) * t
end

function math.sign(n)
    return n > 0 and 1 or (n < 0 and -1 or 0)
end

-- math.floor basicamente
function math.round(n)
    return math.floor(n + 0.5)
end

return math