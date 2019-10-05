require "class"


Edge = Class(function(self, id, node1, node2, locked, data)  
	self.id = id
	-- an edge may belong to two graphs
	
    -- Graph properties
    self.node1 = node1
    self.node2 = node2
        
	table.insert(node1.edges, self)
	table.insert(node2.edges, self)
	
	if node1.graph.id ~= node2.graph.id then 
		--print("Registered Forign EDGE["..id.."] with Nodes "..node1.id.."("..node1.graph.id..") and "..node2.id.."("..node2.graph.id..")")
	end
    self.visited = false
    self.hidden = false
    
    -- Data
    self.data = data or nil
    
    -- Default to not locked; The lock applies to node 1 so the key should always be behind node2
    -- locks should be in the form {locktype, keytype, keynode}
    self.locked = locked or nil
    
    -- What we will populate this edge with
    self.contents = {}
    
    self.colour = {r=255,g=0,b=0,a=255}
    if data ~= nil then
    	self.colour = data.colour or self.colour
    end
end)

function Edge:RenderToMap(map, args)
	if self.hidden == true then
		return
	end
	
	local value = self.node2.data.value
	if args and args.value_override then
		value = args.value_override
	end
	local n1center = self.node1:GetCenterRelativeToMap(map) 
	local n2center = self.node2:GetCenterRelativeToMap(map) 
	
	-- We add 1 here because the map will be rendered in 0->width-1 instead of lua's 1->width
	map:DrawLine(n1center.x+1, n1center.y+1, n2center.x+1, n2center.y+1,  value) 
end

function Edge:DrawDebug(draw, map)
	local n1center = self.node1:GetCenterRelativeToMap(map) 
	local n2center = self.node2:GetCenterRelativeToMap(map) 

	
	draw:Line((n1center.x-map.width/2.0)*TILE_SCALE, (n1center.y-map.height/2.0)*TILE_SCALE, (n2center.x-map.width/2.0)*TILE_SCALE, (n2center.y-map.height/2.0)*TILE_SCALE, self.colour.r, self.colour.g, self.colour.b, self.colour.a)
end

function Edge:SaveEncode(map)
	return {
			n1=self.node1.id,
			n2=self.node2.id,
			c = self.colour,
			}
end

function Edge:Populate(map, spawnFn)
end
