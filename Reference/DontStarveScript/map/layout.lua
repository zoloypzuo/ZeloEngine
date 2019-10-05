-- springForce - how far we want to keep away from our linked neighbors
-- chargeForce - how far we want to keep away from everyone else
-- dampingForce - how much to slow the system down
local function ForceDirected(nodes, springForce, chargeForce, dampingForce, globalEffectFN, constrainFn)
	local total_kinetic_energy = 0
	for k,node in pairs(nodes) do
		for k,otherNode in pairs(nodes) do
			if node ~= otherNode then
				local dx = otherNode.data.position.x - node.data.position.x
				local dy = otherNode.data.position.y - node.data.position.y
				local distance = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))
				local force = 0
				
				--print("ForceDirected", node.id, otherNode.id)
				if node:IsConnectedTo(otherNode) then
					force = (distance - springForce) / 2.0
				else
					-- we will use the size as the mass
					--force = -((node.data.size * otherNode.data.size) / math.pow(distance, 2)) * chargeForce
					force = -(1.0 / math.pow(distance, 2)) * chargeForce
				end
				
				
				if isbadnumber(force) then
					force = 0
				end
				
--				if distance > 0 then
					dx = dx / distance
					dy = dy / distance
--				end
				dx = dx * force
				dy = dy * force
				
				--force = force + globalEffectFN(node.data.position.x, node.data.position.y)
--				local newforcedx,newforcedy =  globalEffectFN(node.data.position.x, node.data.position.y)
--				--print ("ORIG FORCE", dx..","..dy, "NEW FORCE", newforcedx..","..newforcedy)
--	
--				--assert(not isnan(newforcedx))
--				--assert(not isinf(newforce))
--				
--				dx = dx + newforcedx
--				dy = dy + newforcedy
				
				node.data.dx = node.data.dx + dx
				node.data.dy = node.data.dy + dy
			end
		end
		node.data.dx = node.data.dx * dampingForce
		node.data.dy = node.data.dy * dampingForce
		
		
		node:UpdateMovePositionWithConstraint(constrainFn)
		
		-- crude
		total_kinetic_energy = total_kinetic_energy + (node.data.dx + node.data.dy)*(node.data.dx + node.data.dy) -- * MASS
	end
	
	return total_kinetic_energy
end


local function KeepAwayFromWall(wall, x, y, attract)
	local force = 0.0
-- USE BOIDS HERE
--	local right = math.abs((wall.center.x-wall.width/2.0) - x)	-- Force goes right
--	local left = math.abs(x - (wall.center.x+wall.width/2.0))	-- Force goes left
--	local up = math.abs((wall.center.y-wall.height/2.0) - y)	-- Force goes down
--	local down = math.abs(y - (wall.center.y+wall.height/2.0))	-- Force goes up
	local right = (wall.center.x-wall.width/2.0) - x	-- Force goes right
	local left = x - (wall.center.x+wall.width/2.0)	-- Force goes left
	local up = (wall.center.y-wall.height/2.0) - y	-- Force goes down
	local down = y - (wall.center.y+wall.height/2.0)	-- Force goes up

	--if right~=0 then
		--force = force + (1 / math.pow(right, 2)) * 0.5
		force = force + (right - 1) / 2.0
	--end
	
	--if left~=0 then
		--force = force + (1 / math.pow(left, 2)) * 0.5
		force = force + (left - 1) / 2.0
	--end
	--if up~=0 then
		--force = force + (1 / math.pow(up, 2)) * 0.5
		force = force + (up - 1) / 2.0
	--end
	--if down~=0 then
		--force = force + (1 / math.pow(down, 2)) * 0.5
		force = force + (down - 1) / 2.0
	--end
	
	--print("Force:",force, right,left,up,down)	
	assert(not isnan(force))
	assert(not isinf(force))
	if attract then
		return force
	end
	
	return -force
end

local function KeepAwayFromPoints(points, x, y, attract)
	local force = 0.0
	local dxAcc = 0
	local dyAcc = 0
	for i,point in pairs(points) do	
		local dx = point.x - x
		local dy = point.y - y
		local distance = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))
		force = -(1.0 / math.pow(distance, 2)) * 1.5
		
		if isbadnumber(force) then
			force = 0
		end
		--if not isbadnumber(force) then
		--assert(not isbadnumber(force))
			dx = dx / distance
			dy = dy / distance
			dx = dx * force
			dy = dy * force
			
			dxAcc = dxAcc + dx
			dyAcc = dyAcc + dx
		--end
	end
	
	return dxAcc,dyAcc
end




local function printNodes(nodelist)
	local str = ""
	for k,node in pairs(nodelist) do
		str = str.."("..math.floor(node.data.position.x)..","..math.floor(node.data.position.y)..")"
		--str = str.."("..node.data.position.x..","..node.data.position.y..")"
	end

	 return "nodes:\n"..str
end

local function RunForceDirected(center, nodes, layoutFn, constrainFn)
	--print ("Center: ",center.x..","..center.y,printNodes(nodes))
	--print (center, nodes, layoutFn, constrainFn)
	local wall = {width=10, height=6, center=center}
	local points = {
		{x=center.x-3,y=center.y-3},
		{x=center.x-2,y=center.y-3},
		{x=center.x-1,y=center.y-3},
		{x=center.x,  y=center.y-3},
		{x=center.x-3,y=center.y+3},
		{x=center.x-2,y=center.y+3},
		{x=center.x-1,y=center.y+3},
		{x=center.x,  y=center.y+3},
	}
	--print ("center",center.x..","..center.y, (center.x-wall.width/2)..","..(center.y-wall.height/2), (center.x+wall.width/2)..","..(center.y+wall.height/2))
	--local layoutFn = function(x,y) return KeepAwayFromWall(wall, x,y, true) end
	local layoutFn = function(x,y)  return 0,0  end--function(x,y) return KeepAwayFromPoints(points, x,y, true) end
	
	-- set velocities to 0 
	for k,node in pairs(nodes) do
		node.data.dx = 0
		node.data.dy = 0
	end
	--placement.randpositon( nodes, center, placement.posfnCirc)

	local total_kinetic_energy = 100
	--printNodes(nodes)
	-- Spread the Nodes apart
	local iteration=0
	while total_kinetic_energy >0.5 and iteration < 100 do -- and iteration < 40 do
		total_kinetic_energy = ForceDirected(nodes, 1.5, 1.8, 0.5, layoutFn, constrainFn)
		iteration = iteration + 1
	end
	--print (iteration.." iterations -> Center: ",center.x..","..center.y,printNodes(nodes))
	
end


layout = {run=RunForceDirected, avoidwall = KeepAwayFromWall, avoidpoints = KeepAwayFromPoints}
