
local savegamepatcher = {}

function savegamepatcher.AddMissingEntities(savedents, newents)
               
    if SaveGameIndex:GetCurrentMode() ~= "adventure" then
        local ground = GetWorld()
        if ground.meta == nil then
    		ground.meta = {}
        end

        if GetWorld().prefab == "forest" and (not ground.meta.patcher or not ground.meta.patcher.spawnedsunken_boat) then
            print("No sunken_boat in this world, adding one...")

            local sunken_boat = nil
            for i, node in ipairs( GetWorld().topology.nodes ) do
                if node.type == "background" then
                    local x = node.cent[1]
                    local z = node.cent[2]

                    for r=15,60,15 do
                        local offset = FindValidPositionByFan(0, r, 20, function(o)
                                local pos = Vector3(o.x+x, 0, o.z+z)
                                -- first, we need water
                                if ground.Map:GetTileAtPoint(pos.x, pos.y, pos.z) ~= GROUND.IMPASSABLE then
                                    return false
                                end
                                -- second, it should be surrounded by water (no rivers plz)
                                local land = FindValidPositionByFan(0, 10, 8, function(o2)
                                    return ground.Map:GetTileAtPoint(pos.x + o2.x, 0, pos.z + o2.z) ~= GROUND.IMPASSABLE
                                end)
                                if land ~= nil then return false end
                                return true
                            end)

                        if offset ~= nil then
                            -- We found ocean! now walk towards land and put us on the beach.
                            local pos = Vector3(offset.x+x, 0, offset.z+z)
                            local dir = offset:GetInverse():Normalize()
                            while math.abs(pos.x - x) > 1 and math.abs(pos.z - z) > 1 do
                                local tilepos = Vector3(ground.Map:GetTileCenterPoint(pos.x, pos.y, pos.z))
                                if ground.Map:GetTileAtPoint(tilepos.x, tilepos.y, tilepos.z) ~= GROUND.IMPASSABLE then
                                    -- first clean up the area
                                    local ents = TheSim:FindEntities(tilepos.x, tilepos.y, tilepos.z, 6)
                                    for i,v in ipairs(ents) do
                                        v:DoTaskInTime(0, v.Remove)
                                    end

                                    -- then spawn a boat!
                                    sunken_boat = SpawnPrefab("sunken_boat")
                                    sunken_boat.Transform:SetPosition(tilepos:Get())
                                    print("Spawned the sunken_boat.")
                                    break
                                end

                                pos = pos + dir
                            end
                        end
                        if sunken_boat then
                            break
                        end
                    end
                end
                if sunken_boat then
                    break
                end
            end
            if sunken_boat then
                if ground.meta.patcher == nil then
                    ground.meta.patcher = {}
                end
                ground.meta.patcher.spawnedsunken_boat = true

                -- Put some flotsam near the wreck for dramatic effect
                local offsets = {
                    Vector3(1, 0, 0),
                    Vector3(1, 0, 1),
                    Vector3(0, 0, 1),
                    Vector3(-1, 0, 1),
                    Vector3(-1, 0, 0),
                    Vector3(-1, 0, -1),
                    Vector3(0, 0, -1),
                    Vector3(1, 0, -1),
                }
                shuffleArray(offsets)
                local numspawned = 0
                local pos = Vector3(sunken_boat.Transform:GetWorldPosition())
                for i=1,#offsets do
                    local offset = offsets[i] * 12
                    local land = FindValidPositionByFan(0, 6, 8, function(o)
                        return GetGroundTypeAtPosition(pos + offset + o) ~= GROUND.IMPASSABLE
                    end)
                    if not land then
                        local flotsam = SpawnPrefab("flotsam")
                        flotsam.Transform:SetPosition((pos + offset):Get())
                        flotsam.components.drifter:SetDriftTarget(pos)
                        numspawned = numspawned + 1
                    end
                    if numspawned == 3 then
                        break
                    end
                end
            else
                print("UH OH! We couldn't find a spot in the world for the sunken_boat!")
            end
        end

        if IsDLCEnabled(PORKLAND_DLC) then
            if ( GetWorld().prefab == "forest" or GetWorld().prefab == "shipwrecked" ) and (not ground.meta.patcher or not ground.meta.patcher.spawneddeflated_balloon) then
                print("No balloon in this world, adding one...")

                local balloon = nil
                for i, node in ipairs( GetWorld().topology.nodes ) do
                    if node.type == "background" then
                        local x = node.cent[1]
                        local z = node.cent[2]
                        local pos = Vector3(x,0,z)
                        local tilepos = Vector3(ground.Map:GetTileCenterPoint(pos.x, pos.y, pos.z))
                        if ground.Map:GetTileAtPoint(tilepos.x, tilepos.y, tilepos.z) ~= GROUND.IMPASSABLE and not ground.Map:IsWater(ground.Map:GetTileAtPoint(tilepos.x, tilepos.y, tilepos.z)) then                                            
                            balloon = SpawnPrefab("deflated_balloon_basket")
                            balloon.Transform:SetPosition(tilepos:Get())
                            print("Spawned the deflated_balloon_basket.")
                        end
                        
                        local theta = math.random() * 2 * PI
                        local radius = 7
                        local pt = pos
                        local offset = FindWalkableOffset(pt, theta, radius, 12, true) 
                        if offset then
                            local pos = pt +offset

                            local ground = GetWorld()
                            local tile = GROUND.GRASS
                            if ground and ground.Map then
                                tile = ground.Map:GetTileAtPoint(pos:Get())

                                local onWater = ground.Map:IsWater(tile)
                                if not onWater then 
                                    local basket = SpawnPrefab("deflated_balloon")
                                    basket.Transform:SetPosition(pos:Get())
                                    print("Spawned the deflated_balloon.")
                                end 
                            end
                        end

                    end
                    if balloon then
                        break
                    end
                end
                if balloon then
                    if ground.meta.patcher == nil then
                        ground.meta.patcher = {}
                    end
                    ground.meta.patcher.spawneddeflated_balloon = true            
                else
                    print("UH OH! We couldn't find a spot in the world for the sunken_boat!")
                end
            end       
        end

    else
        print("it is adventure, no ship or balloon")
    end
end


return savegamepatcher
