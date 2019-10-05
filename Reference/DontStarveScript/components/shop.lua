local Shop = Class(function(self, inst)
    self.inst = inst
	self.tab = ""
	self.title = "Shop"
end)

function Shop:SetStartTab(tab)
	self.tab = tab
end

function Shop:SetTitle(title)
	self.title = title
end

function Shop:CollectSceneActions(doer, actions)
--    table.insert(actions, ACTIONS.OPEN_SHOP)
end

function Shop:DeliverItems(items)
	assert(items)
	local x, y, z = self.inst.Transform:GetWorldPosition()
	local physcsPT = Vector3(x, y, z) + Vector3(0,4.5,0)
	
	-- loop through and create objects
	for k,prefab in pairs(items) do
		print('Spawning', prefab)
		local item = SpawnPrefab(prefab)
		if item then
			if item.Physics then                
				item.Transform:SetPosition(physcsPT:Get())
				local angle = 0
				local sp = math.random()*6+3
				item.Physics:SetVel(sp*math.cos(angle), math.random()*3+10, sp*math.sin(angle))
			else
				item.Transform:SetPosition(	x-math.random()*6, y, z-math.random()*6 )
			end
		else
			print('Could not spawn', prefab)
		end
	end
end


return Shop
