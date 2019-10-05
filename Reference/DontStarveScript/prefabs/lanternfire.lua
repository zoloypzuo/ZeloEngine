local texture = "fx/torchfire.tex"
local shader = "shaders/particle.ksh"
local colour_envelope_name = "firecolourenvelope"
local scale_envelope_name = "firescaleenvelope"

local assets =
{
	Asset( "IMAGE", texture ),
	Asset( "SHADER", shader ),
}

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
			{	{ 0,	IntColour( 187, 111, 60, 128 ) },
				{ 0.49,	IntColour( 187, 111, 60, 128 ) },
				{ 0.5,	IntColour( 255, 255, 0, 128 ) },
				{ 0.51,	IntColour( 255, 30, 56, 128 ) },
				{ 0.75,	IntColour( 255, 30, 56, 128 ) },
				{ 1,	IntColour( 255, 7, 28, 0 ) },
			} )

		EnvelopeManager:AddVector2Envelope(
			scale_envelope_name,
			{
				{ 0,	{ max_scale * 0.5, max_scale } },
				{ 1,	{ max_scale * 0.5 * 0.5, max_scale * 0.5 } },
			} )
	end
end

local max_lifetime = 0.3
--local ground_height = 0.1

local function fn(Sim)
	local inst = CreateEntity()
	inst:AddTag("FX")
	local trans = inst.entity:AddTransform()
	local emitter = inst.entity:AddParticleEmitter()

	InitEnvelopes()

	emitter:SetRenderResources( texture, shader )
	emitter:SetMaxNumParticles( 64 )
	emitter:SetMaxLifetime( max_lifetime )
	emitter:SetColourEnvelope( colour_envelope_name )
	emitter:SetScaleEnvelope( scale_envelope_name );
	emitter:SetBlendMode( BLENDMODE.Additive )
	emitter:EnableBloomPass( true )
	emitter:SetUVFrameSize( 1.0 / 4.0, 1.0 )

	inst.entity:AddLight()
    inst.Light:Enable(true)
    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(197/255,197/255,50/255)
    inst.Light:SetFalloff( 0.4 )
    inst.Light:SetRadius( 6 )
    
    inst.persists = false    
	-----------------------------------------------------
	local tick_time = TheSim:GetTickTime()

	local desired_particles_per_second = 64
	local particles_per_tick = desired_particles_per_second * tick_time

	local emitter = inst.ParticleEmitter

	local num_particles_to_emit = 1

	local sphere_emitter = CreateSphereEmitter( 0.05 )

	local emit_fn = function()
		local vx, vy, vz = 0.01 * UnitRand(), 0, 0.01 * UnitRand()
		local lifetime = max_lifetime * ( 0.9 + UnitRand() * 0.1 )
		local px, py, pz

		px, py, pz = sphere_emitter()
		px = px - 0.1
		py = py + 0.25 -- the 0.2 is to offset the flame particles upwards a bit so they can be used on a torch

		local uv_offset = math.random( 0, 3 ) * 0.25

		emitter:AddParticleUV(
			lifetime,			-- lifetime
			px, py, pz,			-- position
			vx, vy, vz,			-- velocity
			uv_offset, 0		-- uv offset
		)
	end
	
	local updateFunc = function()
		while num_particles_to_emit > 1 do
			emit_fn( emitter )
			num_particles_to_emit = num_particles_to_emit - 1
		end

		num_particles_to_emit = num_particles_to_emit + particles_per_tick
	end

	EmitterManager:AddEmitter( inst, nil, updateFunc )
    
    return inst
end

return Prefab( "common/fx/lanternfire", fn, assets) 
 
