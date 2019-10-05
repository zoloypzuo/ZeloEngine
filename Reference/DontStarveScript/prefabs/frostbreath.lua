local texture = "fx/frostbreath.tex"
local shader = "shaders/particle.ksh"
local colour_envelope_name = "breathcolourenvelope"
local scale_envelope_name = "breathscaleenvelope"

local assets =
{
	Asset( "IMAGE", texture ),
	Asset( "SHADER", shader ),
}

local min_scale = 0.4
local max_scale = 3

local function IntColour( r, g, b, a )
	return { r / 255.0, g / 255.0, b / 255.0, a / 255.0 }
end

local init = false
local function InitEnvelopes()
	
	if EnvelopeManager and not init then
		init = true
		EnvelopeManager:AddColourEnvelope(
			colour_envelope_name,
			{	{ 0,	IntColour( 255, 255, 255, 0 ) },
				{ 0.10,	IntColour( 255, 255, 255, 128 ) },
				{ 0.3,	IntColour( 255, 255, 255, 64 ) },
				{ 1,	IntColour( 255, 255, 255, 0 ) },
			} )

		EnvelopeManager:AddVector2Envelope(
			scale_envelope_name,
			{
				{ 0,	{ min_scale, min_scale } },
				{ 1,	{ max_scale, max_scale } },
			} )
	end
end

local max_lifetime = 2.5

local function Emit(inst)
	local emitter = inst.ParticleEmitter
	local sphere_emitter = CreateSphereEmitter( 0.05 )

	local vx, vy, vz = 0, .005, 0
	local lifetime = max_lifetime * ( 0.9 + UnitRand() * 0.1 )
	local px, py, pz

	px, py, pz = sphere_emitter()

	local angle = UnitRand()*360
	local angular_velocity = UnitRand()*5

	emitter:AddRotatingParticleUV(
		lifetime,			-- lifetime
		px, py, pz,			-- position
		vx, vy, vz,			-- velocity
		angle,				-- rotation
		angular_velocity,	-- angular_velocity :P
		0, 0				-- uv offset
	)
	
end

local function fn(Sim)
	local inst = CreateEntity()
	inst:AddTag("FX")
	local trans = inst.entity:AddTransform()
	local emitter = inst.entity:AddParticleEmitter()

	InitEnvelopes()

	emitter:SetRenderResources( texture, shader )
	emitter:SetRotationStatus( true )
	emitter:SetMaxNumParticles( 64 )
	emitter:SetMaxLifetime( max_lifetime )
	emitter:SetColourEnvelope( colour_envelope_name )
	emitter:SetScaleEnvelope( scale_envelope_name );
	emitter:SetBlendMode( BLENDMODE.Premultiplied )
	emitter:SetUVFrameSize( 1.0, 1.0 )

    inst.persists = false
    
	-----------------------------------------------------
	inst.Emit = Emit


	--local breath_period = 2.0
	--local particle_this_breath = false

	--local updateFunc = function()
		--local breathforce = math.sin(GetTime()/breath_period*math.pi*2)
		--if breathforce > 0 then
			--if particle_this_breath == false then
				--particle_this_breath = true
				--inst.Emit( inst, sphere_emitter )
			--end
		--else
			--particle_this_breath = false
		--end
	--end

	local empty_func = function() end

	EmitterManager:AddEmitter( inst, nil, empty_func )--updateFunc )
    
    return inst
end

return Prefab( "common/fx/frostbreath", fn, assets) 
 
