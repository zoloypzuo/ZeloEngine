require "class"

Vector3 = Class(function(self, x, y, z)
    self.x, self.y, self.z = x or 0, y or 0, z or 0
end)

Point = Vector3

function Vector3:__add( rhs )
    return Vector3( self.x + rhs.x, self.y + rhs.y, self.z + rhs.z)
end

function Vector3:__sub( rhs )
    return Vector3( self.x - rhs.x, self.y - rhs.y, self.z - rhs.z)
end

function Vector3:__mul( rhs )
    return Vector3( self.x * rhs, self.y * rhs, self.z * rhs)
end

function Vector3:__div( rhs )
    return Vector3( self.x / rhs, self.y / rhs, self.z / rhs)
end

function Vector3:Dot( rhs )
    return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z
end

function Vector3:Cross( rhs )
    return Vector3( self.y * rhs.z - self.z * rhs.y,
                    self.z * rhs.x - self.x * rhs.z,
                    self.x * rhs.y - self.y * rhs.x)
end

function Vector3:__tostring()
    return string.format("(%2.2f, %2.2f, %2.2f)", self.x, self.y, self.z) 
end

function Vector3:__eq( rhs )
    return self.x == rhs.x and self.y == rhs.y and self.z == rhs.z
end

function Vector3:DistSq(other)
    return (self.x - other.x)*(self.x - other.x) + (self.y - other.y)*(self.y - other.y) + (self.z - other.z)*(self.z - other.z)
end

function Vector3:Dist(other)
    return math.sqrt(self:DistSq(other))
end

function Vector3:LengthSq()
    return self.x*self.x + self.y*self.y + self.z*self.z
end

function Vector3:Length()
    return math.sqrt(self:LengthSq())
end

function Vector3:Normalize()
    local len = self:Length()
    if len > 0 then
        self.x = self.x / len
        self.y = self.y / len
        self.z = self.z / len
    end
    return self
end

function Vector3:GetNormalized()
    return self / self:Length()
end

function Vector3:Invert()
    self.x = -self.x
    self.y = -self.y
    self.z = -self.z
    return self
end

function Vector3:GetInverse()
    return Vector3(-self.x, -self.y, -self.z)
end

function Vector3:Get()
    return self.x, self.y, self.z
end

function Vector3:IsVector3()
    return true
end

function ToVector3(obj,y,z)
    if not obj then
        return
    end
    if obj.IsVector3 then  -- note: specifically not a function call! 
        return obj
    end
    if type(obj) == "table" then
        return Vector3(tonumber(obj[1]),tonumber(obj[2]),tonumber(obj[3]))
    else
        return Vector3(tonumber(obj),tonumber(y),tonumber(z))
    end
end

