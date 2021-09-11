-- id_manager
-- created on 2021/9/11
-- author @zoloypzuo
IdManager = Class(function(self)
    self.counter = 0
end)

function IdManager:GenID()
    self.counter = self.counter + 1
    return self.counter
end