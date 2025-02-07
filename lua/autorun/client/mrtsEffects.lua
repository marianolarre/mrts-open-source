function MRTS_Effect(effect, startPos, endPos)
	if (effect != nil) then
		if (effect== "smoketrail") then
			MRTS_VFX_SmokeTrail(startPos, endPos);
		elseif (effect== "heavysmoketrail") then
			MRTS_VFX_HeavySmokeTrail(startPos, endPos);
		elseif (effect== "shelltrail") then
			MRTS_VFX_ShellTrail(startPos, endPos);
		elseif (effect== "muzzle") then
			MRTS_VFX_Muzzle(startPos, endPos);
		elseif (effect== "heavymuzzle") then
			MRTS_VFX_HeavyMuzzle(startPos, endPos);
		elseif (effect== "heavydiagonalmuzzle") then
			MRTS_VFX_HeavyDiagonalMuzzle(startPos, endPos);
		elseif (effect== "explosion") then
			MRTS_VFX_Explosion(startPos, endPos);
		elseif (effect== "flakexplosion") then
			MRTS_VFX_FlakExplosion(startPos, endPos);
		elseif (effect== "giantexplosion") then
			MRTS_VFX_GiantExplosion(startPos, endPos);
		elseif (effect== "spark") then
			MRTS_VFX_Sparks(startPos, endPos);
		elseif (effect== "heal") then
			MRTS_VFX_Heal(startPos, endPos);
		elseif (effect== "healbeam") then
			MRTS_VFX_HealBeam(startPos, endPos);
		else
			print("No such effect type: "..effect);
		end
	end
end

function MRTS_VFX_SmokeTrail(startPos, endPos)
	local size = 1
	
	local diff = endPos-startPos
	local dist = diff:Length()
	local dir = diff/dist

	local pos = startPos+dir*8

	local emitter = ParticleEmitter( startPos) -- Particle emitter in this position
	for i = 0, (dist-8), 6 do -- SMOKE
		pos = pos+dir*6
		local part = emitter:Add( "color", pos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( math.random(0.25, 0.5) ) -- How long the particle should "live"
			local c = 200
			part:SetColor(c,c,c)
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
			part:SetStartSize( size ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed
			part:SetAirResistance(80)
			part:SetGravity( Vector( 0, 0, 8 ) ) -- Gravity of the particle
			part:SetVelocity( dir*math.random(5, 8) ) -- Initial velocity of the particle
		end
	end
	emitter:Finish()
end

function MRTS_VFX_HeavySmokeTrail(startPos, endPos)
	local size = 1.5
	
	local diff = endPos-startPos
	local dist = diff:Length()
	local dir = diff/dist

	local pos = startPos+dir*8

	local emitter = ParticleEmitter( startPos) -- Particle emitter in this position
	for i = 0, (dist-8), 3 do -- SMOKE
		pos = pos+dir*3
		local part = emitter:Add( "color", pos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( math.random(0.75, 1) ) -- How long the particle should "live"
			local c = 200
			part:SetColor(c,c,c)
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
			part:SetStartSize( size ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed
			part:SetAirResistance(80)
			part:SetGravity( Vector( 0, 0, 8 ) ) -- Gravity of the particle
			part:SetVelocity( dir*math.random(5, 8) ) -- Initial velocity of the particle
		end
	end
	emitter:Finish()
end

function MRTS_VFX_ShellTrail(startPos, endPos)
	local size = 1.5
	
	local diff = endPos-startPos
	local dist = diff:Length()
	local dir = diff/dist

	local emitter = ParticleEmitter( startPos) -- Particle emitter in this position
	local part = emitter:Add( "color", startPos ) -- Create a new particle at pos
	if ( part ) then
		part:SetDieTime( math.random(0.75, 1) ) -- How long the particle should "live"
		local c = 80
		part:SetColor(c,c,c)
		part:SetStartAlpha( 255 ) -- Starting alpha of the particle
		part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
		part:SetStartSize( size ) -- Starting size
		part:SetEndSize( 0 ) -- Size when removed
		part:SetAirResistance(80)
		part:SetGravity( Vector( 0, 0, 8 ) ) -- Gravity of the particle
		part:SetVelocity( dir*math.random(5, 8) ) -- Initial velocity of the particle
	end
	emitter:Finish()
end

function MRTS_VFX_Muzzle(startPos, endPos)
	local size = 2
	
	local diff = endPos-startPos
	local dist = diff:Length()
	local dir = diff/dist

	local pos = startPos+dir*5

	local emitter = ParticleEmitter( startPos) -- Particle emitter in this position
	for i = 0, 10 do -- SMOKE
		local part = emitter:Add( "color", pos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( 0.25 ) -- How long the particle should "live"
			part:SetColor(255,200,0)
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
			part:SetStartSize( size ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed
			part:SetAirResistance(100)
			part:SetGravity( Vector( 0, 0, 8 ) ) -- Gravity of the particle
			part:SetVelocity( dir*math.random(5, 30) ) -- Initial velocity of the particle
		end
	end
	emitter:Finish()
end

function MRTS_VFX_HeavyMuzzle(startPos, endPos)
	local size = 5
	
	local diff = endPos-startPos
	local dist = diff:Length()
	local dir = diff/dist

	local pos = startPos+dir*5

	local emitter = ParticleEmitter( startPos) -- Particle emitter in this position
	for i = 0, 15 do -- SMOKE
		local part = emitter:Add( "color", pos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( 0.35 ) -- How long the particle should "live"
			part:SetColor(255,200,0)
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
			part:SetStartSize( size ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed
			part:SetAirResistance(100)
			part:SetGravity( Vector( 0, 0, 8 ) ) -- Gravity of the particle
			part:SetVelocity( dir*math.random(5, 50) ) -- Initial velocity of the particle
		end
	end
	emitter:Finish()
end

function MRTS_VFX_HeavyDiagonalMuzzle(startPos, endPos)
	local size = 5
	
	local diff = endPos-startPos
	local dist = diff:Length()
	local dir = diff/dist

	local pos = startPos+dir*5

	local emitter = ParticleEmitter( startPos) -- Particle emitter in this position
	for i = 0, 15 do -- SMOKE
		local part = emitter:Add( "color", pos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( 0.35 ) -- How long the particle should "live"
			part:SetColor(255,200,0)
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
			part:SetStartSize( size ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed
			part:SetAirResistance(100)
			part:SetGravity( Vector( 0, 0, 8 ) ) -- Gravity of the particle
			local rand = math.random(5, 50)
			part:SetVelocity( Vector(dir.x, dir.y, 0.7)*rand ) -- Initial velocity of the particle
		end
	end
	emitter:Finish()
end

function MRTS_VFX_AreaRing(startPos, radius, color)
	local color = color or {r=255, g=0, b=0}
	local emitter = ParticleEmitter( startPos) -- Particle emitter in this position
	local full = math.pi*2
	local step = full/math.floor(radius)
	for i = 0, full, full/radius do -- SMOKE
		local cos = math.cos(i)
		local sin = math.sin(i)
		local part = emitter:Add( "color", startPos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( 0.3 ) -- How long the particle should "live"
			part:SetColor(color.r,color.g,color.b)
			part:SetPos(startPos+Vector(cos*radius, sin*radius, 0))
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
			part:SetStartSize( 2 ) -- Starting size
			part:SetEndSize( 2 ) -- Size when removed
		end
	end
	emitter:Finish()
end

function MRTS_VFX_Explosion(startPos, endPos)
	sound.Play("ambient/explosions/explode_4.wav", startPos, 72, 120, 1)
	for i= 0, 3 do
		MRTS_VFX_Debris(startPos, 6)
	end

	local size = 125
	local particles = 75
	local duration = 2
	local emitter = ParticleEmitter( startPos) -- Particle emitter in this position
	for i = 0, particles do -- SMOKE
		local part = emitter:Add( "color", startPos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( duration*math.random(0.25, 0.5) ) -- How long the particle should "live"
			local c = 80
			part:SetColor(c,c,c)
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
			part:SetStartSize( 1.5 ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed
			part:SetAirResistance(400)
			part:SetGravity( Vector( 0, 0, 8 ) ) -- Gravity of the particle
			part:SetVelocity( VectorRand()*size ) -- Initial velocity of the particle
		end
	end
	for i = 0, particles do -- SMOKE
		local part = emitter:Add( "color", startPos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( 0.3 ) -- How long the particle should "live"
			part:SetColor(255,200,0)
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 100 ) -- Particle size at the end if its lifetime
			part:SetStartSize( 2 ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed
			part:SetAirResistance(0)
			part:SetGravity( Vector( 0, 0, 8 ) ) -- Gravity of the particle
			part:SetVelocity( VectorRand()*size ) -- Initial velocity of the particle
		end
	end
	emitter:Finish()
end

function MRTS_VFX_FlakExplosion(startPos, endPos)
	sound.Play("weapons/ar2/fire1.wav", startPos, 72, 40, 1)
	for i= 0, 2 do
		MRTS_VFX_Debris(startPos, 6)
	end

	local size = 125
	local particles = 75
	local duration = 2
	local emitter = ParticleEmitter( startPos) -- Particle emitter in this position
	for i = 0, particles do -- SMOKE
		local part = emitter:Add( "color", startPos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( duration*math.random(0.25, 0.5) ) -- How long the particle should "live"
			local c = 20
			part:SetColor(c,c,c)
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
			part:SetStartSize( 2.5 ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed
			part:SetAirResistance(400)
			part:SetGravity( Vector( 0, 0, 8 ) ) -- Gravity of the particle
			part:SetVelocity( VectorRand()*size ) -- Initial velocity of the particle
		end
	end
	emitter:Finish()
end

function MRTS_VFX_GiantExplosion(startPos, endPos)
	sound.Play("ambient/explosions/explode_4.wav", startPos, 150, 120, 1)

	for i= 0, 10 do
		MRTS_VFX_Debris(startPos, 8)
	end

	local size = 250
	local particles = 150
	local duration = 4
	local emitter = ParticleEmitter( startPos) -- Particle emitter in this position
	for i = 0, particles do -- SMOKE
		local part = emitter:Add( "color", startPos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( duration*math.random(0.25, 0.5) ) -- How long the particle should "live"
			local c = 150
			part:SetColor(c,c,c)
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
			part:SetStartSize( 2 ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed
			part:SetAirResistance(400)
			part:SetGravity( Vector( 0, 0, 8 ) ) -- Gravity of the particle
			part:SetVelocity( VectorRand()*size ) -- Initial velocity of the particle
		end
	end
	for i = 0, particles do -- SMOKE
		local part = emitter:Add( "color", startPos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( 0.3 ) -- How long the particle should "live"
			part:SetColor(255,200,0)
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
			part:SetStartSize( 3 ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed
			part:SetAirResistance(0)
			part:SetGravity( Vector( 0, 0, 8 ) ) -- Gravity of the particle
			part:SetVelocity( VectorRand()*size ) -- Initial velocity of the particle
		end
	end
	emitter:Finish()
end

function MRTS_VFX_Sparks(startPos, endPos)
	local particles = 8
	local size = 80
	local emitter = ParticleEmitter( startPos) -- Particle emitter in this position
	for i = 0, particles do -- SMOKE
		local part = emitter:Add( "color", startPos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( 0.15 ) -- How long the particle should "live"
			part:SetColor(255,200,0)
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
			part:SetStartSize( 2 ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed
			part:SetAirResistance(5)
			part:SetGravity( Vector( 0, 0, -30 ) ) -- Gravity of the particle
			part:SetVelocity( VectorRand()*size ) -- Initial velocity of the particle
		end
	end
	emitter:Finish()
end

function MRTS_VFX_Debris(startPos, speed)
	local particles = 16
	local velocity = VectorRand()*speed
	if (velocity.z < speed/3) then
		velocity.z = -velocity.z+speed/3*2
	end
	local life = math.random(0.25, 1)
	local emitter = ParticleEmitter( startPos) -- Particle emitter in this position
	for i = 0, particles-2 do -- SMOKE
		local part = emitter:Add( "color", startPos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( 0.1*i*life ) -- How long the particle should "live"
			part:SetColor(75,75,75)
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
			part:SetStartSize( 2 ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed
			part:SetAirResistance(5)
			part:SetGravity( Vector( 0, 0, -1 )*i*i ) -- Gravity of the particle
			part:SetVelocity( velocity*i ) -- Initial velocity of the particle
		end
	end

	for i = particles-2, particles do -- SMOKE
		local part = emitter:Add( "color", startPos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( 0.1*i*life ) -- How long the particle should "live"
			part:SetColor(255,200,0)
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
			part:SetStartSize( 2 ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed
			part:SetAirResistance(5)
			part:SetGravity( Vector( 0, 0, -1 )*i*i ) -- Gravity of the particle
			part:SetVelocity( velocity*i ) -- Initial velocity of the particle
		end
	end
	emitter:Finish()
end

function MRTS_VFX_ShellTrail(startPos, endPos)
	if (math.random() < 0.5) then
		local size = 10
		local emitter = ParticleEmitter( startPos) -- Particle emitter in this position
		local part = emitter:Add( "color", startPos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( 1 ) -- How long the particle should "live"
			part:SetColor(80,80,80)
			part:SetStartAlpha( 100 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
			part:SetStartSize( 3 ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed
			part:SetAirResistance(0.5)
			part:SetGravity( Vector( 0, 0, -30 ) ) -- Gravity of the particle
			part:SetVelocity( VectorRand()*size ) -- Initial velocity of the particle
		end
		part = emitter:Add( "color", startPos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( 0.1 ) -- How long the particle should "live"
			part:SetColor(255,255,100)
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
			part:SetStartSize( 3 ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed
			part:SetAirResistance(0.5)
		end
		emitter:Finish()
	end
end

function MRTS_VFX_Heal(startPos, endPos)
	local particles = 3
	local emitter = ParticleEmitter( startPos) -- Particle emitter in this position
	local offsetx = 10
	local offsety = 0
	local angle = math.random(0, 360)
	for i = 0, particles do -- SMOKE
		local part = emitter:Add( "color", startPos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( 1 ) -- How long the particle should "live"
			part:SetColor(0,255,0)
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
			part:SetStartSize( 1.5 ) -- Starting size
			part:SetEndSize( 1.5 ) -- Size when removed
			part:SetAirResistance(175)
			part:SetGravity( Vector( 0, 0, -20 ) ) -- Gravity of the particle
			part:SetVelocity( Vector(offsetx * math.cos(angle), offsetx * math.sin(angle),70 + offsety) ) -- Initial velocity of the particle
			local aux = offsetx
			offsetx = offsety
			offsety = -aux
		end
	end
	emitter:Finish()
end

function MRTS_VFX_HealBeam(startPos, endPos)
	local size = 1
	
	local diff = endPos-startPos
	local dist = diff:Length()
	local dir = diff/dist

	local pos = startPos+dir*8

	local emitter = ParticleEmitter( startPos) -- Particle emitter in this position
	for i = 0, (dist-8), 6 do -- SMOKE
		pos = pos+dir*6
		local part = emitter:Add( "color", pos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( math.random(0.45, 0.5) ) -- How long the particle should "live"
			part:SetColor(0,255,0)
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
			part:SetStartSize( size ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed
			part:SetAirResistance(80)
			part:SetGravity( Vector( 0, 0, 8 ) ) -- Gravity of the particle
			part:SetVelocity( dir*math.random(5, 8) ) -- Initial velocity of the particle
		end
	end
	emitter:Finish()
end