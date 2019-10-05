ChattyNode = Class(BehaviourNode, function(self, inst, chatlines, child)
    BehaviourNode._ctor(self, "ChattyNode", {child})
    
    self.inst = inst
    self.chatlines = chatlines
    self.nextchattime = nil
end)


function ChattyNode:Visit()
    local child = self.children[1]
    
    child:Visit()
    self.status = child.status

    if self.status == RUNNING then
        
        local t = GetTime()
        
        if not self.nextchattime or t > self.nextchattime then
            
            local str = self.chatlines[math.random(#self.chatlines)]
            self.inst.components.talker:Say(str)
            self.nextchattime = t + 10 +math.random()*10
        end
        if self.nextchattime then
            self:Sleep(self.nextchattime - t)
        end
    end
    
end

