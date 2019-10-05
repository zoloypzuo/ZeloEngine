require "class"
require "map/graphedge"
require "map/graphnode"
require "map/extents"
require "map/terrain"

Graph = Class(function(self, id, args)   
	self.id = id
	--print("Graph",id, args.parent,  args.data,  args.nodes,  args.edges,  args.exit_nodes,  args.exit_edges,  args.default_bg)
    -- Is this graph inside another graph
    self.parent =  args.parent or nil
    if self.parent then
    	self.parent:AddChild(self)
    end
    
    -- Do we have any child graphs
    self.children =  args.children or {}
    
    -- Nodes within a graph may have cross linking
    self.nodes =  args.nodes or {}
    -- keep a track on the internal edges
    self.edges =  args.edges or {}
    
    -- These nodes connect this subgraph to other graphs by Edges
    self.exit_nodes =  args.exit_nodes or {}
    self.exit_edges =  args.exit_edges or {}
    
    -- Data
    --self.data = data

	-- Used as a logical representation of progression
	self.story_depth = args.story_depth or -1
    
    -- Search
    self.visited = false
    
    self.data = {position={x=0,y=0},old_pos={x=0,y=0}, width=0, height=0, size=0, value= args.default_bg, background=args.background}--value=0.43


    self.colour = args.colour or {r=1,g=0,b=0,a=1}

	-- a list of layouts to be distributed amongst children
	self.set_pieces = args.set_pieces
	self.maze_tiles = args.maze_tiles
	-- print("####New node!! ",self.id, self.maze_tiles)
	-- dumptable(self.maze_tiles,1)
	self.MIN_WORMHOLE_ID = 2300000
end)

------------------------------------------------------------------------------------------
---------             Utility                   --------------------------------------
------------------------------------------------------------------------------------------

function Graph:Dump(depth)
	if depth == nil then
		depth = ""
	end
	
	if self.parent then
		print(depth..self.id.." Parent: "..self.parent.id)
	end
	
	print(depth..self.id.." Nodes: "..GetTableSize(self.nodes))
	for k,v in pairs(self.nodes) do
	    print(depth.."     Node: ",k, "Data:", v.data)
	end
	print(depth..self.id.." Edges: "..GetTableSize(self.edges))
	for k,v in pairs(self.edges) do
	    print(depth.."     Edge: ",k, v.node1.id,"-->",v.node2.id)
	end
	
	print(depth..self.id.." Exits: "..GetTableSize(self.exit_edges))
	for k,v in pairs(self.exit_edges) do
	    print(depth.."     Exit: ",k,v.node1.id.."("..v.node1.graph.id..")","-->",v.node2.id.."("..v.node2.graph.id..")")
	end
	
	print(depth..self.id.." Children: "..GetTableSize(self.children))
	for k,v in pairs(self.children) do
	    print(depth.."     Child: ",k)
	    v:Dump(depth.."      ")
	end
end

------------------------------------------------------------------------------------------
-----------             SAVE/LOAD                   --------------------------------------
------------------------------------------------------------------------------------------

function EncodeColour(item, encoded)
	local found = false 
	if #encoded.colours > 0 then			
		for k,colour in ipairs(encoded.colours) do
			if colour~= nil and colour.a == item.c.a and colour.r == item.c.r and 
									colour.g == item.c.g and colour.b == item.c.b then
				found = true
				item.c = k
				break
			end 
		end
	end
		
	if found == false then
		table.insert(encoded.colours, item.c)
		item.c = #encoded.colours
	end
end

function Graph:SaveEncode(map, encoded)

	--print ("Encoding: ".. self.id)
	
	if encoded.nodes == nil then
		encoded.nodes = {}
		encoded.edges = {}
		encoded.ids = {}
		encoded.story_depths = {}
		encoded.colours = {}
	end
	
	
	local edge_ids = {}
	--print("\tExits: "..GetTableSize(self.exit_edges))
	for id,edge in pairs(self.exit_edges) do
		local encoded_edge = edge:SaveEncode(map)		
		EncodeColour(encoded_edge, encoded)		
		table.insert(encoded.edges, encoded_edge)
		table.insert(edge_ids, #encoded.edges)
	end

	
	--print("\tGot "..GetTableSize(self.edges) .." edges")
	for id,edge in pairs(self.edges) do
		local encoded_edge = edge:SaveEncode(map)		
		EncodeColour(encoded_edge, encoded)		
		table.insert(encoded.edges, encoded_edge)
		table.insert(edge_ids, #encoded.edges)
	end
	
	for id,node in pairs(self.exit_nodes) do --self.nodes) do
		local encoded_node =  node:SaveEncode(map)		
		EncodeColour(encoded_node, encoded)		

		table.insert(encoded.ids, id)
		table.insert(encoded.story_depths, self.story_depth)
		table.insert(encoded.nodes, encoded_node)
		
		for edge_id,edge in ipairs(encoded.edges) do
			local edge = encoded.edges[edge_id]
			if edge.n1 == id then
				edge.n1 = #encoded.nodes
			end
			if edge.n2 == id then
				edge.n2 = #encoded.nodes
			end
			
		end
	end

	--print("\tGot "..GetTableSize(self.nodes) .." nodes")
	for id,node in pairs(self.nodes) do --self.nodes) do
		local encoded_node =  node:SaveEncode(map)		
		EncodeColour(encoded_node, encoded)		

		table.insert(encoded.ids, id)
		table.insert(encoded.story_depths, self.story_depth)
		table.insert(encoded.nodes, encoded_node)
		
		for edge_id,edge in ipairs(encoded.edges) do
			local edge = encoded.edges[edge_id]
			if edge.n1 == id then
				edge.n1 = #encoded.nodes
			end
			if edge.n2 == id then
				edge.n2 = #encoded.nodes
			end
			
		end
	end
	--print("\tGot children "..GetTableSize(self.children) .." nodes")
	for id,child in pairs(self.children) do
		child:SaveEncode(map, encoded)
	end

	-- Get the background nodes
	-- This should include links to which nodes are touching

--
--	local function GetEncodedBackgroundNone(map, id)
--		local poly_x, poly_y = WorldSim:GetSitePolygon(id)
--		local poly_def = {}
--		for current_pos_idx = 1, #poly_x  do
--			poly_def[current_pos_idx] = {math.floor((poly_x[current_pos_idx]-map.width/2.0)*TILE_SCALE), math.floor((poly_y[current_pos_idx]-map.height/2.0)*TILE_SCALE)}
--			current_pos_idx = current_pos_idx + 1
--		end
--		return {
--					poly = poly_def,
--					c = self.colour,
--					}
--	end	
--
--	for id,node in pairs(self.nodes) do --self.nodes) do
--		local encoded_node = GetEncodedBackgroundNone(map, id)		
--		EncodeColour(encoded_node, encoded)		
--
--		table.insert(encoded.ids, id)
--		table.insert(encoded.nodes, encoded_node)
--		
--		for edge_id,edge in ipairs(encoded.edges) do
--			local edge = encoded.edges[edge_id]
--			if edge.n1 == id then
--				edge.n1 = #encoded.nodes
--			end
--			if edge.n2 == id then
--				edge.n2 = #encoded.nodes
--			end
--			
--		end
--	end
	
	--print ("\tEncoding complete: ".. self.id, #encoded.ids, #encoded.colours, #encoded.nodes, #encoded.edges)
end


------------------------------------------------------------------------------------------
---------             Graph               --------------------------------------
------------------------------------------------------------------------------------------

function Graph:AddChild(child)
	assert(child)
	assert(not self.children[child.id])
	
	self.children[child.id] = child
end

function Graph:RemoveChild(child)
	assert(child)
	assert(self.children[child.id])
	
	return table.remove(self.children, child.id)
end
function Graph:GetChildren()
	return self.children
end

function Graph:LockGraph(id, left_exit_node, right_exit_node, lock)
	-- Lock a graph by adding an exit edge across both nodes
	--print(self.id..":LockGraph: Edge id:".. id, "Left Node:"..left_exit_node.id.."("..left_exit_node.graph.id..")", "Right Node:"..right_exit_node.id.."("..right_exit_node.graph.id..")", "Lock:"..lock.type)
	
	--print(lock, lock.type, lock.key)
	
	assert(lock)
	--assert(lock.type)
	--assert(lock.key)

	if id == nil then
		id = "Exit"..GetTableSize(self.exit_edges)
	end
	assert(not self.exit_edges[id])
	
	self.exit_edges[id] = Edge(id, left_exit_node, right_exit_node, lock)
	
	WorldSim:AddExternalLink(left_exit_node.id, right_exit_node.id)

	return self.exit_edges[id]
end

function Graph:GetExitEdges()
	local edges = {}
 	for k,v in pairs(self.exit_edges) do
 		edges[k] = v
	end	
	return edges
end

function Graph:RemoveExitEdge(id)
	assert(id)
	assert(self.exit_edges[id])
	return table.remove(self.exit_edges, id)
end

function Graph:IsConnectedTo(graph)
	assert(graph)
	
	for k,edge in pairs(self.edges) do
		if edge.node1.graph == graph or edge.node2.graph == graph then
			return true
		end
	end
		
	return false
end



------------------------------------------------------------------------------------------
---------             EDGES                   --------------------------------------
------------------------------------------------------------------------------------------
function Graph:AddEdgeByNode(id, node1, node2, lock)
	--print(self.id..":AddEdgeByNode: ",id, node1, node2, lock)
	assert(node1)
	assert(node2)
	
	if id  ==  nil then
		id = "edge"..GetTableSize(self.edges)
	end
	assert(not self.edges[id])
		
	
	if self.nodes[node1.id] == nil then
		--print(self.id.."::AddEdgeByNode: Node1 ",node1.id,"added")
		self:AddNodeByNode(node1)
	end
	
	if self.nodes[node2.id] == nil then
		--print(self.id.."::AddEdgeByNode: Node2 ",node2.id,"added")
		self:AddNodeByNode(node2)
	end
	
	local edge =  Edge(id, node1, node2, lock, {colour = self.colour})
	self.edges[id] = edge
	
	--print(self.id.."::AddEdgeByNode: Edge ",id,"added")
	
	-- The Edge constructor adds itself to its nodes, this isn't necessary (I hope)
	--table.insert(self.nodes[node1.id].edges, edge)
	--table.insert(self.nodes[node2.id].edges, edge)
	--self.nodes[node2.id].edges[id] = self.edges[id]
	
	assert(self.nodes[node1.id])
	assert(self.nodes[node2.id])
	
	WorldSim:AddLink(node1.id, node2.id)
		
	return self.edges[id]
end

function Graph:AddEdge(args)
	--print(self.id..":AddEdge:", args.id, args.node1id, args.node2id, args.lock)
	
	assert(args.node1id)
	assert(args.node2id)
	assert(self.nodes[args.node1id])
	assert(self.nodes[args.node2id])
	
	if args.id  ==  nil then
		args.id = "edge"..GetTableSize(self.edges)
	end
	assert(not self.edges[args.id])
	
	
	local node1 = self.nodes[args.node1id]
	local node2 = self.nodes[args.node2id]
		
	return self:AddEdgeByNode(args.id, node1, node2, args.lock)
end

function Graph:GetEdge(id)
	assert(id)
	
	--print(self.id..":GetEdge ["..id.."]")
	if self.edges[id] then	
		--print(self.id..":GetEdge found edge ["..id.."]")
		return self.edges[id]
	end
	
	if self.exit_edges[id] then	
		--print(self.id..":GetEdge found exit edge ["..id.."]")
		return self.exit_edges[id]
	end
	
	for k,child in pairs(self.children) do
		--print(self.id..":GetEdge looking in child", id, child.id)
		edge = child:GetEdge(id)
		if edge then
			--print(self.id..":GetEdge found in child", id, child.id)
			return edge
		end
	end
	
	--print(self.id..":GetEdge could not find ["..id.."]")
	--dumptable(self.edges)
	return nil
end

function Graph:RemoveEdge(id)
	assert(id)
	assert(self.edges[id])
	return table.remove(self.edges, id)
end

function Graph:GetEdges(incChildren)
	local edges = {}
 	for k,v in pairs(self.edges) do
 		edges[k] = v
	end	
	
	if incChildren ~= nil and incChildren == true then
		for id,child in pairs(self.children) do
			local childEdges = child:GetEdges(incChildren)
		 	for k,v in pairs(childEdges) do
		 		edges[k] = v
			end	
		end
	end
	
	return edges
end

------------------------------------------------------------------------------------------
---------             NODES                   --------------------------------------
------------------------------------------------------------------------------------------

function Graph:AddNodeByNode(node)
	assert(node)
	assert(node.id)
	assert(not self.nodes[node.id])
	
	node.graph = self
	self.nodes[node.id] = node

	if node.data.entrance then
		self.entrancenode = node
	end

	--dumptable(self.nodes[node.id])
	--print(self.id..":Graph:AddNodeByNode ", node.id, GetTableSize(self.nodes), "Parent:"..self.nodes[node.id].graph.id)
	--dumptable(self.nodes)
	
	assert(self.nodes[node.id])
	--print(self.id..":Graph:AddNodeByNode ", self.id, node.id, node.data.value, node.colour.r, node.colour.g, node.colour.b, node.colour.a)

	WorldSim:AddChild(self.id, node.id, node.data.value, 
						node.colour.r, node.colour.g, node.colour.b, node.colour.a, 
						node.data.type, node.data.internal_type or NODE_INTERNAL_CONNECTION_TYPE.EdgeSite)

	if node.data.tags ~= nil and #node.data.tags >0 then
		--WorldSim:SetSiteFlags(node.id, node.data.tags[1])
	end

	return self.nodes[node.id]
end

function Graph:AddNode(args)
	
	if args.id  ==  nil then
		args.id = "node"..GetTableSize(self.nodes)
	end
	assert(args.id)
	
	--print(self.id..":Graph:AddNode ", args.id, args.data)
	--dumptable(self.nodes)
	assert(not self.nodes[args.id])
	
	--print("AddNode:", args.id, args.data)
	--dumptable(args.data)
	local node = Node(args.id, args.data)

	return self:AddNodeByNode(node)
end

function Graph:GetNode(id)
	assert(id)
	assert(self.nodes[id])
	return self.nodes[id]
end

function Graph:GetNodeById(id)
	--print(self.id,"Looking for ", id)
	assert(id)

	if self.id == id then
		return self
	end
	
	if self.nodes[id] ~= nil then
		--print("Found",id)
		return self.nodes[id]
	end
	for child_id,child in pairs(self.children) do
		local childNode = child:GetNodeById(id)
		if childNode ~= nil then
			--print("Child Found",id)
			return childNode
		end
	end	

	return nil
end

function Graph:HasNode(id)
	if self.nodes[id] ~= nil then
		return true
	end
	return false
end

function Graph:GetNodes(incChildren)
	local nodes = {}
 	for k,v in pairs(self.nodes) do
 		nodes[k] = v
	end	
	
	if incChildren ~= nil and incChildren == true then
		for id,child in pairs(self.children) do
			local childNodes = child:GetNodes(incChildren)
		 	for k,v in pairs(childNodes) do
		 		nodes[k] = v
			end	
		end
	end
	
	--print(self.id.." Graph:GetNodes"..GetTableSize(self.nodes).."-->"..GetTableSize(nodes))
	return nodes
end

function Graph:GetRandomNode()
 	local picked = nil
	-- We should never pick blockers
	while not picked or picked.data.entrance == true do
		local choice = math.random(GetTableSize(self.nodes)) -1
		--print("Graph:GetRandomNode", choice)
 	
		for k,v in pairs(self.nodes) do
			--print("Graph:GetRandomNode", choice,  k,v)
			picked = v
			if choice<= 0 then
				break
			end
			choice = choice -1
		end
 	end
	
 	assert(picked)
	return picked
end

-- Each increment is one more link ie: a triangle would be factor 1, a line factor 0, a tree factor 0, a square -> 1
function Graph:CrosslinkRandom(crossLinkFactor)
	if GetTableSize(self.nodes)<=2 then
		return
	end
	
	local iterations = 0
	while crossLinkFactor > 0 and iterations < 20 do	
		local n1 = self:GetRandomNode()
		local n2 = self:GetRandomNode()
		if n1 ~= n2 and n1:IsConnectedTo(n2)~= true and not n1.data.entrance and not n2.data.entrance then
			local crosslink = self:AddEdge({node1id=n1.id, node2id=n2.id})
			-- hide crosslinks
			crosslink.hidden = true
			crossLinkFactor = crossLinkFactor -1
		end
		iterations = iterations + 1
	end
end

function Graph:MakeLoop()
	-- This assumes the graph is linear, and connects one end with the other
	local first = nil
	local last = nil
	for nodeid,node in pairs(self.nodes) do
		--print(self.id, nodeid, #node.edges)
		if #node.edges == 1 then
			if not first then
				first = node
			else
				last = node
				break
			end
		end
	end

	if not first or not last then
		print("Warning: Tried to make "..self.id.." into a loop but couldn't find end nodes.")
		return
	end

	if first.data.entrance then
		if first.edges[1].node1 == first then
			first = first.edges[1].node2
		else
			first = first.edges[1].node1
		end
	end
	if last.data.entrance then
		if last.edges[1].node1 == last then
			last = last.edges[1].node2
		else
			last = last.edges[1].node1
		end
	end

	self:AddEdge({node1id=first.id, node2id=last.id})
end

function Graph:RemoveNode(id)
	assert(id)
	assert(self.nodes[id])
	
	self.nodes[id].graph = nil
	
	return table.remove(self.nodes, id)
end

function Graph:UpdateMinimumRadius()
	
	local x,y,r =  GetMinimumRadiusForNodes(self.nodes)

	self.data.size = math.ceil(r)
	assert(self.data.size>= 0)
	self.data.old_pos.x = self.data.position.x
	self.data.old_pos.y = self.data.position.y
	self.data.position.x = math.floor(x)
	self.data.position.y = math.floor(y)
end



function Graph:ConvertGround(map, spawnFN, entities, check_col)
	local nodes = self:GetNodes(true)
	for k,node in pairs(nodes) do
		node:ConvertGround(map, spawnFN, entities, check_col)
	end 
end

function Graph:Populate(map, spawnFN, entities, check_col)
	local nodes = self:GetNodes(true)
	--print(self.id.." Populating "..GetTableSize(nodes).." nodes...")	
	for k,node in pairs(nodes) do
		node:Populate(map, spawnFN, entities, check_col)
	end 
	--[[  
	local edges = self:GetEdges(true)
	--print("Populating "..GetTableSize(nodes)+GetTableSize(self.exit_edges).." edges...")	
	for k,edge in pairs(edges) do
		edge:Populate(map, spawnFN, entities, check_col)
	end
	
	for k,edge in pairs(self.exit_edges) do
		edge:Populate(map, spawnFN, entities, check_col)
	end
	--]]
	
    -- Spawn the default items
	local children = self:GetChildren()
	
	local graph_minus = {}
	local graph_points = {}
	
	for k,child in pairs(children) do
		-- Generate a list of points that are inside 
		-- minus the areas that their subchildren take up
		-- This list is all the area that is not covered by nodes
		child:GetArea(map, graph_points, graph_minus)
		--print(self.id..":"..child.id.." graph_points now ".. GetTableSize(graph_points))
		--print(self.id..":"..child.id.." graph_minus now ".. GetTableSize(graph_minus))
	end
	
	for key,point in pairs(graph_points) do
	 	--print(key,graph_minus[key])
	 	if graph_minus[key] == nil then
	 		spawnFN.spawnfordefault(map, point.x, point.y, entities, check_col)
	 	end
	end
end

function Graph:PopulateVoronoi(spawnFN, entities, width, height, world_gen_choices)
	local nodes = self:GetNodes(false)
	--print(self.id.." Populating "..GetTableSize(nodes).." nodes...")	
	for k,node in pairs(nodes) do
		node:PopulateVoronoi(spawnFN, entities, width, height, world_gen_choices)
		local perTerrain = false
		if type(self.data.background) == type({}) then
			perTerrain = true
		end
		local backgroundRoom = self:GetBackgroundRoom(self.data.background)
		node:PopulateChildren(spawnFN, entities, width, height, backgroundRoom, perTerrain, world_gen_choices)
	end 
	for k,child in pairs(self:GetChildren()) do
		child:PopulateVoronoi(spawnFN, entities, width, height, world_gen_choices)
	end
end

function Graph:GetBackgroundRoom(roomName)
	if type(roomName) == type("") then 
		return self:GetRoomForName(roomName)
	elseif type(roomName) == type({}) then
		local rooms = {}
		for ground,name in pairs(roomName) do
			rooms[ground] = self:GetRoomForName(name)
		end
		return rooms
	end
	return nil	
end

function Graph:GetRoomForName(roomName)
	local backgroundRoom = terrain.rooms[roomName]
	return backgroundRoom
end


function Graph:GlobalPrePopulate(entities, width, height)
	self:ProcessInsanityWormholes(entities, width, height)
end


function Graph:GlobalPostPopulate(entities, width, height)
	-- Spawn wormhole pairs (randomly, for now)
	self:SwapOutWormholeMarkers(entities, width, height)

end

local function IsNodeTagged(node, look_for_tag)
	if not node.data.tags then
		return false
	end
	for i,tag in ipairs(node.data.tags) do
		if tag == look_for_tag then
			return true
		end
	end
	return false
end


function Graph:ProcessInsanityWormholes(entities, width, height)
	--print("*** PROCESSSING INSANITY WORMHOLES ***")

	local IsNodeAWormhole = function(node) return IsNodeTagged(node, "OneshotWormhole") end

	local NeighborNodes = function(task, node)
		local prevNode = nil
		local nextNode = nil
		for edgeId,edge in pairs(task:GetEdges(false)) do
		    --print("internal edge",edge.node1.id, edge.node2.id)
			if edge.node1.id == node.id and not edge.node2.data.blocker_blank then
			    --print("\tlink!!")
				assert(nextNode == nil, "We already have a node from this task!")
				nextNode = edge.node2
			elseif edge.node2.id == node.id and not edge.node1.data.blocker_blank then
			    --print("\tlink!!")
				assert(nextNode == nil, "We already have a node from this task!")
				nextNode = edge.node1
			end
		end
        for edgeId,edge in pairs(self:GetExitEdges(false)) do
            --print("external edge",edge.node1.id, edge.node2.id)
            if edge.node1.id == node.id then
                --print("\tlink!!")
                assert(prevNode == nil, "We already have a node from the other task!")
                prevNode = edge.node2
            elseif edge.node2.id == node.id then
                --print("\tlink!!")
                assert(prevNode == nil, "We already have a node from the other task!")
                prevNode = edge.node1
            end
		end
		assert(prevNode ~= nil and nextNode ~= nil, "A wormhole blocker must have exactly 2 neighbors!!")
		return prevNode, nextNode
	end

	local DoWormholeLayout = function(node, data)
		local obj_layout = require("map/object_layout")
		local prefab_list = {}
		
		-- Get the list of special items for this node

		local add_fn = {fn=function(...) node:AddEntity(...) end,args={entitiesOut=entities, width=width, height=height, rand_offset = false, debug_prefab_list=prefab_list}}
		
		local layout = obj_layout.LayoutForDefinition("WormholeOneShot") 
		local prefabs = obj_layout.ConvertLayoutToEntitylist(layout)

		for i,p in ipairs(prefabs) do
			if string.find(p.prefab, "wormhole") ~= nil then
				p.properties = data
				break
			end
		end
		
		obj_layout.ReserveAndPlaceLayout(node.id, layout, prefabs, add_fn)

	end

	local ProcessWormholes = function(task, node)
		local prevNode, nextNode = NeighborNodes(task,node)
		--print("Wormhole connecting nodes", prevNode.id, nextNode.id)

		local id1 = self.MIN_WORMHOLE_ID
		local id2 = self.MIN_WORMHOLE_ID + 1
		self.MIN_WORMHOLE_ID = self.MIN_WORMHOLE_ID + 2

		local firstWormholeData = {id=id1, data={teleporter={target=id2}}}
		local secondWormholeData = {id=id2, data={teleporter={target=id1}}}

		DoWormholeLayout(prevNode, firstWormholeData)
		DoWormholeLayout(nextNode, secondWormholeData)
	end

	local TryProcessTask = function(task)
		for id,node in pairs(task.nodes) do
			if IsNodeAWormhole(node) then
				ProcessWormholes(task, node)
			end
		end
	end

	for id,task in pairs(self:GetChildren()) do
		TryProcessTask(task)
	end

end

function Graph:SwapOutWormholeMarkers(entities, width, height)
		
	if entities["wormhole_MARKER"] ~= nil then

		if entities["wormhole"] == nil then
			entities["wormhole"] = {}
		end

		local id = self.MIN_WORMHOLE_ID

		local firstMarkerData = nil
		for i,data in ipairs(entities["wormhole_MARKER"]) do
				if firstMarkerData == nil then
					firstMarkerData = data
				else
					local secondMarkerData = data
					firstMarkerData["id"] = id
					secondMarkerData["id"] = id + 1
					id = id + 2

					firstMarkerData["data"] = {teleporter={target=secondMarkerData["id"]}}
					secondMarkerData["data"] = {teleporter={target=firstMarkerData["id"]}}

					table.insert(entities["wormhole"], firstMarkerData)
					table.insert(entities["wormhole"], secondMarkerData)

					firstMarkerData = nil
				end
		end
		self.MIN_WORMHOLE_ID = id
		entities["wormhole_MARKER"] = nil
	end
end


function Graph:ApplyWormhole(entities, width, height, x1, y1, x2, y2)
	if x1 ~= nil and x2 ~= nil and y1 ~= nil and y2 ~= nil and x1>1 and x2 >1 and y1>1 and y2>1 then
		--print("\t\t\t(".. x1 ..",".. y1 ..")\t<--->\t(".. x2 ..",".. y2 ..")")

		local xx1 = math.floor((x1 - width/2)*TILE_SCALE*10)/10
		local yy1 = math.floor((y1 - height/2)*TILE_SCALE*10)/10
		local firstMarkerData = {data={teleporter={target=self.MIN_WORMHOLE_ID+1}}, id = self.MIN_WORMHOLE_ID, x=xx1,z=yy1}
			
		local xx2 = math.floor((x2 - width/2)*TILE_SCALE*10)/10
		local yy2 = math.floor((y2 - height/2)*TILE_SCALE*10)/10
		local secondMarkerData = {data={teleporter={target=self.MIN_WORMHOLE_ID}}, id = self.MIN_WORMHOLE_ID+1, x=xx2,z=yy2}
			
		self.MIN_WORMHOLE_ID = self.MIN_WORMHOLE_ID + 2
	
		table.insert(entities["wormhole"], firstMarkerData)
		table.insert(entities["wormhole"], secondMarkerData)
	else
		self.error = true
		self.error_string = "ApplyWormhole nil wormhole"
	end 
end

function Graph:SwapWormholesAndRoadsExtra(entities, width, height)
	if entities["wormhole"] == nil then
		entities["wormhole"] = {}
	end
	--self:SwapWormholesAndRoads(entities, width, height)
	
    local wx1,wy1,wx2,wy2 = WorldSim:GetWormholesExtra()
    if wx1 ~= nil and wy1 ~= nil and wx2 ~= nil and wy2 ~= nil and 
    	#wx1 ~= 0 and #wx1 == #wy1 and #wx1 == #wx2 and #wx1 == #wy2  then
    	
    	for i=1,#wx1 do
    		self:ApplyWormhole(entities, width, height, wx1[i], wy1[i], wx2[i], wy2[i])
    		if self.error == true then
    			return
    		end
    	end
 	else
		if wx1 ~= nil and #wx1 ~= 0 then 
			self.error = true
			self.error_string = "GetWormholesExtra failed"
		end
   	end

end

function Graph:ApplyPoisonTag()
	local nodes = self:GetNodes(true)
	for k,node in pairs(nodes) do
		-- TODO: Need to handle BG nodes
		if IsNodeTagged(node, "ForceDisconnected") then --or string.find(node.id, "LOOP_BLANK_SUB")~=nil then
			WorldSim:ClearNodeLinks(node.id)
			
			-- TODO: Move this to a more generic location
			WorldSim:SetNodeType(node.id, 1) -- BLANK
		end
		local flags = 0
		if IsNodeTagged(node, "ForceConnected") then 
			flags = flags + 0x000002
		end
		if IsNodeTagged(node, "RoadPoison") then 
			flags = flags + 0x000004
		end
		WorldSim:SetSiteFlags(node.id, flags)
	end
	-- Process the graph and unlink any poisoned nodes
	local children = self:GetChildren()
	for k,child in pairs(children) do
		child:ApplyPoisonTag()
	end	
end

function Graph:SwapWormholesAndRoads(entities, width, height)
	if entities["wormhole"] == nil then
		entities["wormhole"] = {}
	end
	
	--print(self.id.."\tSwapWormholesAndRoads", #entities["wormhole"], self.MIN_WORMHOLE_ID)

	for k,edge in pairs(self.exit_edges) do
		if edge.node1.id ~= "LOOP_BLANK_SUB" and edge.node2.id ~= "LOOP_BLANK_SUB" 
			and edge.node1.id ~= "START" and edge.node2.id ~= "START" then
			
			--print(self.id.."\t\t", edge.id, edge.node1.id, edge.node2.id) 
			-- Get x1,y1,x2,y2 for this edge
			local x1,y1,x2,y2 = WorldSim:GetWormholes(edge.node1.id, edge.node2.id)
	    	self:ApplyWormhole(entities, width, height, x1,y1,x2,y2)
	    end
	end
	
	--print(self.id.."\tSwapWormholesAndRoads complete", #entities["wormhole"])
	
	local children = self:GetChildren()
	for k,child in pairs(children) do
		child:SwapWormholesAndRoads(entities, width, height)
	end
end
