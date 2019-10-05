
function UpdateextentsForNode(extents, node)
	if node.data.position.x-node.data.size/2<extents.xmin then
		extents.xmin = node.data.position.x-node.data.size/2
	end
	if node.data.position.y-node.data.size/2<extents.ymin then
		extents.ymin = node.data.position.y-node.data.size/2
	end
	if node.data.position.x+node.data.size/2>extents.xmax then
		extents.xmax = node.data.position.x+node.data.size/2
	end
	if node.data.position.y+node.data.size/2>extents.ymax then
		extents.ymax = node.data.position.y+node.data.size/2
	end
end

function ResetextentsForNodes(nodes)
	local extents = {xmin=1000000,ymin=1000000,xmax=-1000000,ymax=-1000000}	
	for k,node in pairs(nodes) do
		Updateextents(extents, node)
	end
	
	return extents
end

-- radius, cx, cy = GetMinimumRadiusForNodes(sim, nodes)
function GetMinimumRadiusForNodes(nodes)
	local floats = {}
	for k,node in pairs(nodes) do
		table.insert(floats, node.data.position.x)
		table.insert(floats, node.data.position.y)
		
		local radius = node.data.size
		
		-- plus radius
		table.insert(floats, node.data.position.x+radius)
		table.insert(floats, node.data.position.y)
		table.insert(floats, node.data.position.x-radius)
		table.insert(floats, node.data.position.y)
		
		table.insert(floats, node.data.position.x)
		table.insert(floats, node.data.position.y+radius)
		table.insert(floats, node.data.position.x)
		table.insert(floats, node.data.position.y-radius)
		
	end

	return getminimumradius(floats) --sim:GetMinimumRadius(floats)
end

local function UpdateextentsForPoint(extents, point)
	if point[1]<extents.xmin then
		extents.xmin = point[1]
	end
	if point[2]<extents.ymin then
		extents.ymin = point[2]
	end
	if point[1]>extents.xmax then
		extents.xmax = point[1]
	end
	if point[2]>extents.ymax then
		extents.ymax = point[2]
	end
end
function ResetextentsForPoly(poly)
	local extents = {xmin=1000000,ymin=1000000,xmax=-1000000,ymax=-1000000}	
	
	for i =1, #poly do
		UpdateextentsForPoint(extents, poly[i])
	end
	
	extents.size = {x = extents.xmax - extents.xmin, y = extents.ymax - extents.ymin}

	if  extents.size.x > extents.size.y then
		extents.radius = extents.size.x
	else
		extents.radius = extents.size.y
	end

	return extents
end