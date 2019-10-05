local function Randomize(positions)
	for i = #positions, 2, -1 do -- backwards
	    local r = math.random(i) -- select a random number between 1 and i
	    positions[i], positions[r] = positions[r], positions[i] -- swap the randomly selected item to position i
	end 				
end

local function genRandomPositions(num)
	local positions = {}
	local y = 0
	for x = -math.floor(num/2), math.floor(num/2) do
		y = math.random(num)
		table.insert(positions, {x=x,y=y})
	end
	--print("genRandomPositions", num, #positions)
	Randomize(positions)
	
	return positions
end				


local function genCircEdgePositions(num)
	assert(num>0)
	local positions = {}
	for i = 1, num do
	   	local a = (math.pi*2/num) * i
		table.insert(positions, {x=math.sin(a),y=math.cos(a)})
	end
	return positions
end	

local function genCircOffsetPositions(num)
	assert(num>0)
	local positions = {}
	for i = 1, num do
	   	local s = i/32.0--(num/2) -- 32.0
	   	local a = math.sqrt(s*512.0)
	   	local b = math.sqrt(s)
		table.insert(positions, {x=math.sin(a)*b,y=math.cos(a)*b})
	end
	Randomize(positions)
	return positions
end	

local function PositionNodesRandom(nodes, center, positionFN)
	local count = GetTableSize(nodes)
	--print("GetTableSize(nodes)", count) 
	if count == 0 then
		return
	end 
	
	local positions = positionFN(GetTableSize(nodes))
	local pos = 1
	for k,node in pairs(nodes) do
		node:SetPosition({x=positions[pos].x+center.x, y=positions[pos].y+center.y})
		pos = pos + 1
	end
end

local function PlaceNodesRandom(topology, placedNodes, openEdges)
	--print("PlaceNodesRandom", topology.root.id)
	local nodes = topology.root:GetNodes(true)
	--print("GetTableSize(nodes)", GetTableSize(nodes))
	local positions = genCircOffsetPositions(GetTableSize(nodes))
    
	local pos = 1
	for k,node in pairs(nodes) do
		node:SetPosition(positions[pos])
		placedNodes:push(node)
		--UpdateExtents(extents, node)
		pos = pos + 1
		
		for k,edge in pairs(node.edges) do
			if edge and not edge.visited then
				openEdges:push(edge)
				edge.visited = true
			end						
		end
	end
end


				
local function genMoveList()
	local deg = {}
	
	for degrees = 0, 350, 10 do
		table.insert(deg, degrees)	
		--print ("{x=25*math.sin("..degrees.."), y=25*math.cos("..degrees..")}", 25*math.sin(degrees), 25*math.cos(degrees))		
	end
	
	for i = #deg, 2, -1 do -- backwards
		--print ("i", moves[r].x, moves[r].y)		
	    local r = math.random(i) -- select a random number between 1 and i
	    deg[i], deg[r] = deg[r], deg[i] -- swap the randomly selected item to position i
	end 				
	
	local moves = {}
	for k,degrees in pairs(deg) do
		--print ("i", k,degrees)		
		moves[k] =  {x=math.floor(10*math.sin(degrees)), y=math.floor(10*math.cos(degrees))}
	end
		
	return moves
end				

local function PlaceNodesMode0(topology, placedNodes, openEdges)
	map_center = {x=0, y=0}


	currentNode = topology.startNode
	currentNode:SetPosition(map_center)
	
	--print ("currentNode.edges", currentNode.edges)
	--dumptable(currentNode.edges)
	
	for k,v in pairs(currentNode.edges) do
		if not v.visited then
			openEdges:push(v)
		end
	end
	placedNodes:push(currentNode)
	while openEdges:getn() > 0 do
		currentNode.visited = true
		--print ("openEdges:getn()", openEdges:getn(), "currentNode: ", currentNode.id)
		local edgeID = openEdges:pop()
		if edgeID ~= nil then
			--local currentEdge = topology.root:GetEdge(edgeID)	
			local currentEdge = edgeID	
			if currentEdge ~= nil then --and not currentEdge.visited then
				
				--print ("currentEdge: ", currentEdge.id)
				currentEdge.visited = true
				
				local prevPos = currentNode.data.position
				
				--dumptable(currentEdge)
				if not currentEdge.node1.visited then
					currentNode = currentEdge.node1
				else
					currentNode = currentEdge.node2
				end
				
				local placed = false
				
				-- Do the work
				for k,offset in pairs(genMoveList()) do
					--position = {x=offset.x+prevPos.x,y=offset.y+prevPos.y}
					position = {x=offset.x+map_center.x,y=offset.y+map_center.y}
					--dumptable(position)
					-- Try placing
					local pos_available = true
					for kk, node in pairs(placedNodes._et) do
						if position.x == node.data.position.x and position.y == node.data.position.y then
							pos_available = false
							break
						end
					end		
					
					-- Place the node
					if pos_available then
						currentNode:SetPosition(position)
						placed = true
						
						break
					--else
					--	print (currentNode.id,"no position available")
					end
				end
				
				if not placed then
					print("ERROR: Cant place Node", currentNode.id)
					dumptable(currentNode)
					dumptable(currentNode.data)
					return
				end
				
				if currentNode.edges then
					for k,edgeID in pairs(currentNode.edges) do
						---local edge = topology.root:GetEdge(edgeID)
						local edge = edgeID
						if edge and not edge.visited then
							--print (currentNode.id,"Adding Edge["..edge.id.."] with Nodes "..edge.node1.id.."("..edge.node1.graph.id..") and "..edge.node2.id.."("..edge.node2.graph.id..")")
							openEdges:push(edgeID)
						--else
							--print (currentNode.id,"Not Adding Edge["..edgeID.id.."]")
						end
						
					end
				else
					print (currentNode.id,"No edges?")
				end
				
				placedNodes:push(currentNode)
			end
		end
	end
end

placement = {
	mode0=PlaceNodesMode0, random=PlaceNodesRandom, randpositon=PositionNodesRandom, 
	posfnCirc = genCircOffsetPositions, posfnLine = genRandomPositions, posfnCircEdge = genCircEdgePositions
	}
