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

RGBA.Red = RGBA(1., 0., 0.)
RGBA.Green = RGBA(0., 1., 0.)
RGBA.Blue = RGBA(0., 0., 1.)
RGBA.White = RGBA(1., 1., 1.)
RGBA.Black = RGBA(0., 0., 0.)
RGBA.Grey = RGBA(0.5, 0.5, 0.5)
RGBA.Yellow = RGBA(1., 1., 0.)
RGBA.Cyan = RGBA(0., 1., 1.)
RGBA.Magenta = RGBA(1., 0., 1.)