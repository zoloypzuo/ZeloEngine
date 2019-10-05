--this is called back by the engine side

PhysicsCollisionCallbacks = {}
function OnPhysicsCollision(guid1, guid2)
	local i1 = Ents[guid1]
	local i2 = Ents[guid2]

	if PhysicsCollisionCallbacks[guid1] then
		PhysicsCollisionCallbacks[guid1](i1, i2)
	end

	if PhysicsCollisionCallbacks[guid2] then
		PhysicsCollisionCallbacks[guid2](i2, i1)
	end

end