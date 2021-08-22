-- color
-- created on 2021/8/22
-- author @zoloypzuo
RGBA = Class(function(self, r, g, b, a)
    self.r = r or 1
    self.g = g or 1
    self.b = b or 1
    self.a = a or 1
end)

function RGBA:__tostring()
    return string.format("(%2.2f, %2.2f, %2.2f, %2.2f)", self.r, self.g, self.b, self.a)
end
