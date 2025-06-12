function MRTS_Attack(ent, attack, target, pos, attackID)
	if (attack.burst) then
		for i=0, attack.burst-1 do
			if (i==0 or attack.burstDelay == nil or attack.burstDelay == 0) then
				local trailOnly = i>0 --Only do sounds and animation for the first shot
				MRTS_ExecuteAttack(ent, attack, target, pos, trailOnly, attackID)
			else
				if (attack.burstDelay) then
					local burstDelay = attack.burstDelay/ent:GetDelayModifier()
					timer.Simple(burstDelay*i, function()
						if (IsValid(ent)) then
							MRTS_ExecuteAttack(ent, attack, target, pos, false, attackID)
						end
					end)
				end
			end
		end
	else
		MRTS_ExecuteAttack(ent, attack, target, pos, false, attackID)
	end

	if (attack.selfDestruct) then
		ent:Die()
	end
end

function MRTS_ExecuteAttack(ent, attack, target, pos, trailOnly, attackID)
	local a = attack.type;
	if (a == nil) then
		print("!!! Warning: attack does not have a 'type' property")
	end
	if (a == "basic") then
		MRTS_AttackType_Basic(ent, attack, target, pos, trailOnly, attackID)
	elseif (a == "trace") then
		MRTS_AttackType_Trace(ent, attack, target, pos, trailOnly, attackID)
	elseif (a == "area_instant") then
		PrintMessage(HUD_PRINTTALK, "'area_instant' attack type deprecated. Use 'basic' instead.")
		MRTS_AttackType_Basic(ent, attack, target, pos, trailOnly, attackID)
	elseif (a == "projectile") then
		MRTS_AttackType_Projectile(ent, attack, target, pos, trailOnly, attackID)
	elseif (a == "projectile_arc") then
		MRTS_AttackType_Projectile_Arc(ent, attack, target, pos, trailOnly, attackID)
	elseif (a == "projectile_phys") then
		MRTS_AttackType_Phys_Projectile(ent, attack, target, pos, trailOnly, attackID)
	elseif (a == "projectile_homing") then
		MRTS_AttackType_Projectile_Homing(ent, attack, target, pos, trailOnly, attackID)
	elseif (a == "area") then
		PrintMessage(HUD_PRINTTALK, "'area' attack type deprecated. Use 'self' instead.")
		MRTS_AttackType_Area(ent, attack, target, pos, trailOnly, attackID)
	elseif (a == "self") then
		MRTS_AttackType_Basic(ent, attack, ent, ent:GetPos(), trailOnly, attackID)
	elseif (a == "detonate") then
		PrintMessage(HUD_PRINTTALK, "'detonate' attack type deprecated. Use 'area' and add the property 'selfDestruct=true' instead.")
		MRTS_AttackType_Area(ent, attack, target, pos, trailOnly, attackID)
	elseif (a == "spawn") then
		MRTS_AttackType_Spawn(ent, attack, target, pos, trailOnly, attackID)
	else
		print("No such attack type: "..a);
	end
end

function MRTS_AttackType_Basic(ent, attack, target, pos, trailOnly, attackID)
	ent.nextAttack = CurTime() + (ent:GetModifiedDelay() or 1)
	/*if (ent:GetData().attack.windupEveryShot) then
		ent.firstHitting = true
	end*/
	if (attack.radius) then
		if (attack.spread) then
			local offset = VectorRand()
			offset.z = 0
			offset:Normalize()
			pos = pos + offset * math.random(0, attack.spread)
		end
		local targeting = nil
		if (attack.targeting != nil) then
			targeting = attack.targeting
		end
		local friendly = targeting.allies
		MRTSAreaEffect(ent, pos, attack.radius, ent:GetTeam(), {
			forcedVictim=target,
			damage=ent:GetModifiedDamage(attack),
			healing=attack.healing,
			status=attack.status,
			friendly=friendly
		})
	else
		if (attack.damage) then
			target:Damage(ent, ent:GetModifiedDamage(attack))
		end
		if (attack.healing) then
			target:Heal(ent, attack.healing)
		end
		if (attack.status != nil) then
			MRTSAddStatus(target, attack.status.type, attack.status.duration)
		end
	end

	if (attackID == MRTS_ATTACKID_PASSIVE) then return nil end
	net.Start("MRTSClientsideUnitAttack")
		net.WriteEntity(ent)
		net.WriteInt(ent:GetUnitID(), 8)
		net.WriteInt(ent.unitCategory, 8)
		net.WriteVector(ent:GetFiringOrigin())
		net.WriteVector(pos)
		net.WriteBool(trailOnly or false)
		net.WriteUInt(attackID, 4);
	net.Broadcast()
end

function MRTS_AttackType_Trace(ent, attack, target, pos, trailOnly, attackID)
	ent.nextAttack = CurTime() + ent:GetModifiedDelay()
	/*if (ent:GetData().attack.windupEveryShot) then
		ent.firstHitting = true
	end*/

	local vec = (pos-ent:GetFiringOrigin()):GetNormalized()*attack.range*1.1

	if (attack.spread) then
		vec:Rotate(Angle(0, math.random(-1.3, 1.3)*attack.spread, 0))--AngleRand()*attack.spread/100)
	end

	local start = ent:GetFiringOrigin()
	local tr = util.TraceLine( {
		start = start,
		endpos = start+vec,
		filter = function( foundEnt )
			if (foundEnt != ent) then
				local foundEntTable = foundEnt:GetTable()
				local cls = foundEntTable.ClassName
				if (cls == "prop_physics" or cls=="worldspawn" or (foundEntTable.isMRTSUnit and foundEntTable.GetTeam() != ent:GetTeam()) ) then
					return true
				end
			end
		end
	})

	if (attack.radius) then
		MRTSAreaEffect(ent, pos, attack.radius, ent:GetTeam(), {
			forcedVictim=target,
			damage=ent:GetModifiedDamage(attack),
			healing=attack.healing,
			status=attack.status,
			friendly=attack.targeting.allies
		})
	else
		local entTable = tr.Entity:GetTable()
		if (IsValid(tr.Entity) and entTable.isMRTSUnit) then
			if (attack.damage) then
				entTable.Damage(tr.Entity, ent, ent:GetModifiedDamage(attack))
			end
			if (attack.healing) then
				entTable.Heal(tr.Entity, ent, attack.healing)
			end
			if (attack.status != nil) then
				MRTSAddStatus(tr.Entity, attack.status.type, attack.status.duration)
			end
		end
	end

	if (attackID == MRTS_ATTACKID_PASSIVE) then return nil end
	net.Start("MRTSClientsideUnitAttack")
		net.WriteEntity(ent)
		net.WriteInt(ent:GetUnitID(), 8)
		net.WriteInt(ent.unitCategory, 8)
		net.WriteVector(ent:GetFiringOrigin())
		net.WriteVector(tr.HitPos)
		net.WriteBool(trailOnly or false)
		net.WriteUInt(attackID, 4);
	net.Broadcast()
end

function MRTS_AttackType_Projectile_Arc(ent, attack, target, pos, trailOnly, attackID)
	local data = ent:GetData()
	ent.nextAttack = CurTime() + ent:GetModifiedDelay()
	/*if (ent:GetData().attack.windupEveryShot) then
		ent.firstHitting = true
	end*/
	local projectile = ents.Create("ent_mrts_projectile")
	local arc = attack.arc
	local firingOrigin= ent:GetFiringOrigin()
	local targetPos = pos
	if (IsValid(target)) then
		targetPos = target:GetPos()
		if (target:GetClass() == "ent_mrts_building") then
			targetPos = target:GetClosestPoint(firingOrigin, margin)
		end
	end
	local dir = (targetPos-ent:GetPos()):GetNormalized()
	firingPos = ent:GetPos()
	projectile:SetPos(firingOrigin)
	projectile:SetOwner(ent)
	projectile:SetTeam(ent:GetTeam())
	projectile:SetData(ent, 0, attack, target, pos, ent:GetUnitID())
	projectile:Spawn()

	if (attackID == MRTS_ATTACKID_PASSIVE) then return nil end
	net.Start("MRTSClientsideUnitAttack")
		net.WriteEntity(ent)
		net.WriteInt(ent:GetUnitID(), 8)
		net.WriteInt(ent.unitCategory, 8)
		net.WriteVector(ent:GetFiringOrigin())
		net.WriteVector(projectile.targetPos or pos)
		net.WriteBool(trailOnly or false)
		net.WriteUInt(attackID, 4);
	net.Broadcast()
end

function MRTS_AttackType_Projectile(ent, attack, target, pos, trailOnly, attackID)
	ent.nextAttack = CurTime() + ent:GetModifiedDelay()
	local projectile = ents.Create("ent_mrts_projectile")
	local targetPos = target:GetPos()
	if (target:GetClass() == "ent_mrts_building") then
		targetPos = target:GetClosestPoint(firingOrigin, margin)
	end
	projectile:SetPos(ent:GetFiringOrigin())
	projectile:SetTeam(ent:GetNWInt("mrtsTeam", 0))
	projectile:Spawn()
	projectile:SetData(ent:GetUnitID())
	projectile:SetTarget(targetPos)

	if (attackID == MRTS_ATTACKID_PASSIVE) then return nil end
	net.Start("MRTSClientsideUnitAttack")
		net.WriteEntity(ent)
		net.WriteInt(ent:GetUnitID(), 8)
		net.WriteInt(ent.unitCategory, 8)
		net.WriteVector(ent:GetFiringOrigin())
		net.WriteVector(pos)
		net.WriteBool(trailOnly or false)
		net.WriteUInt(attackID, 4);
	net.Broadcast()
end

function MRTS_AttackType_Phys_Projectile(ent, attack, target, pos, trailOnly, attackID)
	ent.nextAttack = CurTime() + ent:GetModifiedDelay()
	local projectile = ents.Create("ent_mrts_phys_projectile")
	projectile:SetPos(ent:GetFiringOrigin())
	projectile:SetTeam(ent:GetNWInt("mrtsTeam", 0))
	projectile:Spawn()
	projectile:SetData(ent:GetUnitID())
	projectile:SetTarget(target:GetPos())

	if (attackID == MRTS_ATTACKID_PASSIVE) then return nil end
	net.Start("MRTSClientsideUnitAttack")
		net.WriteEntity(ent)
		net.WriteInt(ent:GetUnitID(), 8)
		net.WriteInt(ent.unitCategory, 8)
		net.WriteVector(ent:GetFiringOrigin())
		net.WriteVector(pos)
		net.WriteBool(trailOnly or false)
		net.WriteUInt(attackID, 4);
	net.Broadcast()
end

function MRTS_AttackType_Area(ent, attack, target, pos, trailOnly, attackID)
	ent.nextAttack = CurTime() + ent:GetModifiedDelay()
	MRTSAreaEffect(ent, ent:GetPos(), attack.radius, ent:GetTeam(), {
		forcedVictim=target,
		damage=attack.damage,
		healing=attack.healing,
		status=attack.status,
		friendly=attack.targeting.allies
	})

	if (attackID == MRTS_ATTACKID_PASSIVE) then return nil end
	net.Start("MRTSClientsideUnitAttack")
		net.WriteEntity(ent)
		net.WriteInt(ent:GetUnitID(), 8)
		net.WriteInt(ent.unitCategory, 8)
		net.WriteVector(ent:GetFiringOrigin())
		net.WriteVector(pos)
		net.WriteBool(trailOnly or false)
		net.WriteUInt(attackID, 4);
	net.Broadcast()
end

function MRTS_AttackType_Spawn(ent, attack, target, pos, trailOnly, attackID)
	ent.nextAttack = CurTime() + ent:GetModifiedDelay()
	local unitID = GetTroopIDByUniqueName(attack.troop)
	local troop = MRTSSpawnTroop(ent:GetTeam(), unitID, ent:GetPos()+Vector(0,0,ent:GetData().size or 10), nil, true, true, false, false)
	troop.stunnedUntil = CurTime()+(attack.stunTime or 1)
	local direction = pos-ent:GetPos()
	local initialVelocity = direction * (attack.forwardVelocity or 1) + Vector(0,0,100*(attack.upwardVelocity or 1)) + VectorRand()*(attack.spread*10 or 0)
	troop:GetPhysicsObject():SetVelocity(initialVelocity)

	local spawnedTroopData = GetTroopByUniqueName(attack.troop)
	if (spawnedTroopData.population) then
		if (spawnedTroopData.population > 0) then
			print("!!! Warning: Make sure that troops spawned from another troop's 'spawn' attack have 0 population")
		end
	end

	if (attackID == MRTS_ATTACKID_PASSIVE) then return nil end
	net.Start("MRTSClientsideUnitAttack")
		net.WriteEntity(ent)
		net.WriteInt(ent:GetUnitID(), 8)
		net.WriteInt(ent.unitCategory, 8)
		net.WriteVector(ent:GetFiringOrigin())
		net.WriteVector(pos)
		net.WriteBool(trailOnly or false)
		net.WriteUInt(attackID, 4);
	net.Broadcast()
end