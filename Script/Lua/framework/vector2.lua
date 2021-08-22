require "class"

Vector2 = Class(function(self, x, y)
    self.x, self.y = x or 0, y or 0
end)

function Vector2:__add(rhs)
    return Vector2(self.x + rhs.x, self.y + rhs.y)
end

function Vector2:__sub(rhs)
    return Vector2(self.x - rhs.x, self.y - rhs.y)
end

function Vector2:__mul(rhs)
    return Vector2(self.x * rhs, self.y * rhs)
end

function Vector2:__div(rhs)
    return Vector2(self.x / rhs, self.y / rhs)
end

function Vector2:Dot(rhs)
    return self.x * rhs.x + self.y * rhs.y
end

function Vector2:__tostring()
    return string.format("(%2.2f, %2.2f, %2.2f)", self.x, self.y)
end

function Vector2:__eq(rhs)
    return self.x == rhs.x and self.y == rhs.y
end

function Vector2:DistSq(other)
    return (self.x - other.x) * (self.x - other.x) + (self.y - other.y) * (self.y - other.y)
end

function Vector2:Dist(other)
    return math.sqrt(self:DistSq(other))
end

function Vector2:LengthSq()
    return self.x * self.x + self.y * self.y
end

function Vector2:Length()
    return math.sqrt(self:LengthSq())
end

function Vector2:Normalize()
    local len = self:Length()
    if len > 0 then
        self.x = self.x / len
        self.y = self.y / len
    end
    return self
end

function Vector2:GetNormalized()
    return self / self:Length()
end

function Vector2:Invert()
    self.x = -self.x
    self.y = -self.y
    return self
end

function Vector2:GetInverse()
    return Vector2(-self.x, -self.y)
end

function Vector2:Get()
    return self.x, self.y
end

function Vector2:IsVector2()
    return true
end

function ToVector2(obj, y)
    if not obj then
        return
    end
    if obj.IsVector2 then
        -- note: specifically not a function call!
        return obj
    end
    if type(obj) == "table" then
        return Vector2(tonumber(obj[1]), tonumber(obj[2]))
    else
        return Vector2(tonumber(obj), tonumber(y))
    end
end

