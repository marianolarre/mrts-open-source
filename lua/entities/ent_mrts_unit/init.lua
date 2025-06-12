AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()

	self.unitID = self:GetUnitID()
	self.teamID = self:GetTeam()
	self.teamData = mrtsTeams[self:GetTeam()]

	self:SetUnitHealth(self:GetData().maxHealth)
	if (self:GetData().charge) then
		if (self:GetData().charge.startingAmount) then
			self:SetUnitCharge(self:GetData().charge.startingAmount)
		end
	end
	self:SharedInit()

	self:SetPhysics()

	self.lastDistance = 0
	self.stuckCounter = 0
	self.stuckFrustration = 0
	self.movingSince = 0

	self.squad = nil
	self.target = nil
	self.possibleTargets = {}
	self.fowTargets = {}

	self.desiredVelocity = Vector(0,0,0)

	self.nextAttack = 0
	self.nextPassive = 0
	self.nextFOWCheck = 0
	self.firstHitting = true
	self.settingUp = false
	self.windingUp = false
	self.stunnedUntil = 0

	self.builderEntity = nil
	self.birth = CurTime()

	self.alive = true
	self.doomed = false
	--self.capturable = false

	self.selectable = true

	self.waypoints = {}
	self.currentwaypoint = 0
	self.waypointpointer = 0
	self.maxwaypoints = 30
	self.waypointsleft = 0

	self.chosenAttack = -1

	self.objective = false

	self.stanceAttackMove = false

	table.insert(mrtsUnits, self)
	MRTSSquadUpdate()
end

function ENT:PostEntityPaste( ply, ent, createdEntities )
	if (self:GetCapturable()) then
		self:SetMaterial("phoenix_storms/dome")
	end
	timer.Simple(1, function()
		net.Start("MRTSEntityPasted")
			net.WriteEntity(self)
		net.Broadcast()
	end)
end

function ENT:SetPhysics()
	self:PhysicsInitSphere( self:GetData().size, "gmod_ice" )
	self:SetCollisionBounds( Vector( -self:GetData().size, -self:GetData().size, -self:GetData().size )*0.5, Vector( self:GetData().size, self:GetData().size, self:GetData().size )*0.5 )
	self:PhysWake()
	self.phys = self:GetPhysicsObject()
	self.phys:SetDamping(0.2, 3)
end

function ENT:RevealEnemies()
	if (self:GetUnderConstruction()) then return end
	local selfTable = self:GetTable()
	for k, v in pairs(selfTable.fowTargets) do
		if (IsValid(v)) then
			local targetIsBuilding = (v:GetClass() == "ent_mrts_building")
			local sight = self:GetData().sight or 50
			if (targetIsBuilding) then
				local targetPos = v:GetClosestPoint(self:GetCenter(), 0)
				if (self:GetCenter():Distance(targetPos) <= sight) then
					v:SetFOWVisible(self:GetTeam())
				end
			else
				if (self:GetCenter():Distance(v:GetCenter()) <= sight + (v:GetData().size or 0)) then
					v:SetFOWVisible(self:GetTeam())
				end
			end
		end
	end

	if (selfTable.nextFOWCheck > CurTime()) then return end
	if (selfTable.squad.closestEnemySquad) then
		local sight = self:GetData().sight or 50
		local rangeSlack = 100
		if (selfTable.squad.closestEnemySquad <= sight+rangeSlack) then
			selfTable.fowTargets = MRTSGetEntitiesInRadius(self:GetCenter(), sight+rangeSlack, self:GetTeam(), true)
		end
		selfTable.nextFOWCheck = CurTime()+1
	end
end

function ENT:AddCharge(amount)
	local newCharge = self:GetUnitCharge() + amount
	if (amount > 0) then
		self:SetUnitCharge(math.min(self:GetData().charge.max, newCharge))
	else
		self:SetUnitCharge(math.max(0, newCharge))
	end
end

function ENT:HandleIsolatedAttack(attack, attackID)
	local selfTable = self:GetTable()
	if (CurTime() >= selfTable.nextAttack) then
		local target = self:SelectTarget(attack)
		if (IsValid(target)) then
			return self:TryAttack(attack, attackID, target)
		end
	end
	return false
end

function ENT:HandleAttack(attack, attackID)
	local selfTable = self:GetTable()
	local keepTarget = selfTable.CheckTarget(self, attack)
	if (keepTarget) then
		if (CurTime() >= selfTable.nextAttack) then
			return selfTable.TryAttack(self, attack, attackID)
		end
	else
		selfTable.LoseTarget(self, attack)
	end
	return false
end

function ENT:HandlePassive(passive)
	local selfTable = self:GetTable()
	if (CurTime() >= selfTable.nextPassive) then
		selfTable.nextPassive = CurTime()+(passive.delay or 1)
		MRTS_Attack(self, passive, self, self:GetCenter(), MRTS_ATTACKID_PASSIVE);
	end
end

function ENT:CheckTarget(attack)
	local selfTable = self:GetTable()
	if (selfTable.target != nil and not IsValid(selfTable.target)) then
		--self:LoseTarget()
		return false
	end
	if (not selfTable.moving or selfTable.stanceAttackMove or selfTable.GetData(self).canAttackWhileMoving) then
		selfTable.AquireTarget(self, selfTable.SelectTarget(self, attack));
		if (IsValid(selfTable.target)) then
			if (selfTable.windingUp) then
				local range = attack.range+selfTable.size+(selfTable.target.size or 0)
				local minRange = attack.minimumRange or -1000
				local distSqr = (selfTable.target:GetPos()-self:GetPos()):LengthSqr()
				local inRange = distSqr < range*range and distSqr > minRange*minRange
				if ((not selfTable.windingUp and not inRange or (!selfTable.target:IsFOWVisibleToTeam(self:GetTeam())) or selfTable.target.doomed)) then
					--self:LoseTarget()
					return false
				end
			end

			if (attack.targeting != nil) then
				local targeting = attack.targeting
				if (targeting.hurt == true) then
					if (selfTable.target:GetUnitHealth() >= selfTable.target:GetData().maxHealth) then
						--self:LoseTarget()
						return false
					end
				end
			end
		end

		return true
		--if (CurTime() > selfTable.nextAttack) then
		--	self:TryAttack()
		--end		
	end
	return true
end

function ENT:HandleStatus(thinkRate)
	local selfTable = self:GetTable()
	-- Status
	if (selfTable.status != nil) then
		for k, v in pairs(selfTable.status) do

			local status = mrtsGameData.status[k]

			-- Damage over time
			if (status.dot != nil) then
				selfTable.Damage(self, self, status.dot*thinkRate)
			end

			-- Heal over time
			if (status.heal != nil) then
				selfTable.Heal(self, self, status.heal*thinkRate)
			end

			if (CurTime() > v) then
				MRTSRemoveStatus(self, k)
			end
		end
	end
end

function ENT:GetTargetDistance(target)
	if (not IsValid(target)) then return end
	local selfTable = self:GetTable()
	local isBuilding = (self:GetClass() == "ent_mrts_building")
	local targetIsBuilding = (target:GetClass() == "ent_mrts_building")
	local center = self:GetCenter()
	local data = self:GetData()
	if (targetIsBuilding) then
		if (isBuilding) then
			local targetPos = target:GetClosestPoint(center, 0)
			local myPos = selfTable.GetClosestPoint(self, target:GetCenter(), 0)
			return targetPos:Distance(myPos)
		else
			local targetPos = target:GetClosestPoint(center, 0)
			return center:Distance(targetPos)-data.size
		end
	else
		if (isBuilding) then
			local myPos = selfTable.GetClosestPoint(self, target:GetCenter(), 0)
			return target:GetCenter():Distance(myPos)-target:GetData().size
		else
			return center:Distance(target:GetCenter())-data.size-target:GetData().size
		end
	end
end

function ENT:TryAttack(attack, attackID, forcedTarget)
	local target = forcedTarget or self.target
	
	if (target != nil) then
		local range = attack.range
		local minRange = attack.minimumRange or -1000
		local targetDistance = self:GetTargetDistance(target)
		
		if (not self.windingUp and (not IsValid(target) or target:GetData() == nil or targetDistance > range or targetDistance < minRange or (!target:IsFOWVisibleToTeam(self:GetTeam()) or target.doomed))) then
			self:LoseTarget(attack)
			self:AquireTarget(self:SelectTarget(attack))
		else
			local ignoresWalls = self:GetData().ignoresWalls or false
			local tr
			if (not ignoresWalls and target != nil and IsValid(target)) then
				tr = util.TraceLine( {
					start = self:GetFiringOrigin(false, target:GetCenter()),
					endpos = target:GetCenter(),
					filter = function( foundEnt )
						if (foundEnt != self and foundEnt != target) then
							local cls = foundEnt:GetClass()
							if (cls == "prop_physics" or cls=="worldspawn" or cls=="ent_mrts_building" ) then
								return true
							end
						end
					end
				})
			end
			if (not IsValid(target) and not forcedTarget) then
				self:LoseTarget(attack)
			else
				if (not ignoresWalls and tostring(tr.Entity) != '[NULL Entity]' and not forcedTarget) then
					self:LoseTarget(attack)
				else
					self.attacking = true
					return self:Attack(attack, attackID, target)
				end
			end
		end
	end
	self.attacking = false
	return false
end

function ENT:Attack(attack, attackID, forcedTarget)
	local target = forcedTarget or self.target
	if (!self.firstHitting) then
		self.windingUp = false
		if (IsValid(target)) then
			local dir = (target:GetCenter()-self:GetCenter()):GetNormalized()
			local targetPos = self:GetTargetPosition(target)
			self:SetFOWVisible(target:GetTeam())
			MRTS_Attack(self, attack, target, targetPos, attackID);
			if (target.doomed == true) then
				self:LoseTarget(attack)
			end
			return true
		end
	else
		self.firstHitting = false
		self.windingUp = true
		if (attack.windup != nil) then
			self.nextAttack = CurTime()+attack.windup
			net.Start("MRTSClientsideUnitNextAttack")
				net.WriteEntity(self)
				net.WriteEntity(self:GetTarget())
			net.Broadcast()
		end
	end
	return false
end

function ENT:AquireTarget(newTarget)
	local selfTable = self:GetTable()
	selfTable.target = newTarget
	selfTable.SetTarget(self, newTarget)
	if (IsValid(newTarget)) then
		if (selfTable.attacking == false and selfTable.moving == true) then
			selfTable.BeginSetup(self)
			net.Start("MRTSClientsideUnitStopMoving")
				net.WriteEntity(self)
			net.Broadcast()
		else
			if (selfTable.moving == false or selfTable.stanceAttackMove) then
				selfTable.Chase(self)
			end
		end
		selfTable.attacking = true
		selfTable.nextAttack = math.max(CurTime()-0.01, selfTable.nextAttack)
	end
	--self.firstHitting = true
end

function ENT:Chase()
	local attack = self:GetData().attack
	if (attack != nil) then
		if (attack.chaseRange != nil) then
			local selfTable = self:GetTable()
			if (IsValid(selfTable.target)) then
				local targetDirection = (selfTable.target:GetCenter()-self:GetCenter()):GetNormalized()
				local targetPos = self:GetTargetPosition(selfTable.target)-targetDirection*(attack.range-5)
				selfTable.SetMovePos(self, targetPos)
				selfTable.moving = true
			end
		end
	end
end

function ENT:BeginSetup()
	local data = self:GetData()
	if (data.attack != nil) then
		local setup = data.attack.setup
		if (setup != nil) then
			local selfTable = self:GetTable()
			selfTable.nextAttack = math.max(selfTable.nextAttack, CurTime() + setup)
		end
	end
end

function ENT:LoseTarget(attack)
	self:SetTarget(nil)
	local selfTable = self:GetTable()
	local data = selfTable.GetData(self)
	selfTable.target = nil
	local cancelWindup = false
	if (selfTable.attacking or data.canAttackWhileMoving or not selfTable.moving) then
		self:AquireTarget(self:SelectTarget(attack))
		if (not IsValid(self:GetTarget())) then
			cancelWindup = true
			selfTable.attacking = false
			if (selfTable.canMove) then
				self:GetPhysicsObject():Wake()
			end
		end
	else
		cancelWindup = true
	end
	if (cancelWindup) then
		if (data.attack) then
			if ((data.attack.windup or 0) > 0) then
				net.Start("MRTSClientsideUnitCancelWindup")
					net.WriteEntity(self)
				net.Broadcast()
			end
			selfTable.windingUp = false
			selfTable.firstHitting = true
		end
	end
end

function ENT:SelectTarget(attack)
	local target = nil
	local selfTable = self:GetTable()
	--if (self.target == nil) then
		selfTable.UnitSearchForPossibleTargets(self, attack)
		if (selfTable.possibleTargets != nil) then
			local nearestDist = 0
			local nearestEnt = nil
			local isUnit = false
			for k, v in pairs(selfTable.possibleTargets) do
				if (not IsValid(v) or v:GetCapturable()) then
					table.RemoveByValue( selfTable.possibleTargets, v )
				end
			end
			for k, v in pairs(selfTable.possibleTargets) do
				if (v != self) then
					if (IsValid(v)) then
						if (not v.doomed and not v:GetCapturable()) then
							local targetDistance = self:GetTargetDistance(v)
							local range = attack.chaseRange or attack.range
							local minRange = attack.minimumRange or -1000
							if (targetDistance < range and targetDistance > minRange) then
								if (v:IsFOWVisibleToTeam(self:GetTeam())) then
									if (nearestEnt == nil or targetDistance < nearestDist) then
										local ignore = false
										local vData = v:GetData()
										if (attack.targeting != nil) then
											local targeting = attack.targeting
											if (targeting.types != nil) then
												if (not table.HasValue(targeting.types, vData.type)) then
													ignore = true
												end
											end
											if (targeting.blacklist != nil) then
												if (table.HasValue(targeting.blacklist, vData.uniqueName)) then
													ignore = true
												end
											end
											if (targeting.hurt == true) then
												if (v:GetUnitHealth() >= vData.maxHealth) then
													ignore = true
												end
											end
										end

										if (not ignore) then
											local class = v:GetClass()
											local ignoresWalls = self:GetData().ignoresWalls or false
											if (not ignoresWalls) then
												local targetPos = self:GetTargetPosition(v)
												local tr = util.TraceLine( {
													start = self:GetFiringOrigin(false, targetPos),
													endpos = targetPos,
													filter = function( foundEnt )
														if (foundEnt != self and foundEnt != v) then
															local cls = foundEnt:GetClass()
															if (cls == "prop_physics" or cls=="worldspawn" or cls=="ent_mrts_building" ) then
																return true
															end
														end
													end
												})
												if (tostring(tr.Entity) == '[NULL Entity]') then
												----------------------------------------------------------Encontró target
													nearestDist = targetDistance
													nearestEnt = v
												end
											else
												nearestDist = targetDistance
												nearestEnt = v
											end
										end
									end
								end
							end
						end
					end
				end
			end
			target = nearestEnt
		end
		if (target != nil) then // TARGET AQUIRED
			--self:AquireTarget(selfTable.target)
			return target
		end
	--end
end

function ENT:ComputeAllChanges(sign)
	self:ComputeImmediateChanges(sign)
	if (not self:GetUnderConstruction()) then
		self:ComputeReadyChanges(sign)
	end
end

function ENT:ComputeImmediateChanges(sign)
	MRTSAffectUsedHousing(self:GetTeam(), sign*(self:GetData().population or 0))
end

function ENT:ComputeReadyChanges(sign)
	if (self:GetUnderConstruction()) then return end
	local data = self:GetData()
	if (data.housing != 0) then
		MRTSAffectMaxHousing(self:GetTeam(), sign*(data.housing or 0))
	end
	if (istable(data.income)) then
		for k, v in pairs(data.income) do
			MRTSAffectIncome(self:GetTeam(), sign*v, k)
		end
	end
	if (istable(data.capacity)) then
		for k, v in pairs(data.capacity) do
			MRTSAffectCapacity(self:GetTeam(), sign*v, k)
		end
	end
end

function ENT:UnitSearchForPossibleTargets(attack)
	if (attack.range != nil) then
		local rangeSlack = 200
		local targetAllies = false
		if (attack.targeting != nil) then
			targetAllies = attack.targeting.allies
		end
		local selfTable = self:GetTable()
		if (targetAllies) then
			selfTable.possibleTargets = MRTSGetEntitiesInRadius(self:GetCenter(), attack.range+selfTable.size+rangeSlack, self:GetTeam(), false, false)
		else
			if (selfTable.squad.closestEnemySquad) then
				if (selfTable.squad.closestEnemySquad <= attack.range+rangeSlack) then
					selfTable.possibleTargets = MRTSGetEntitiesInRadius(self:GetCenter(), attack.range+selfTable.size+rangeSlack, self:GetTeam(), true)
				else
					selfTable.possibleTargets = {}
				end
			end
		end
	end
end

function ENT:UnitMove(serverThinkRate)
	local selfTable = self:GetTable()
	if (not self:GetData().canAttackWhileMoving) then
		selfTable.firstHitting = true
	end
	if (selfTable.squad != nil) then
		selfTable.squad.dirty = true
	end
	MRTS_MoveType(self, serverThinkRate, self:GetData().moveType);
end

function ENT:Unstuck(multiplier, desiredVelocity)
	local size = self:GetData().size
	-- Check forward obstacle
	local tr1 = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos()+Vector(0,0,1-size)+desiredVelocity:GetNormalized()*20,
		filter = function( ent ) return ( ent:GetClass() == "prop_physics" or ent:IsWorld() ) end
	} )
	-- Check floor below
	if (tr1.Hit) then
		local tr2 = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:GetPos()+Vector(0,0,-1-size),
			filter = function( ent ) return ( ent:GetClass() == "prop_physics" or ent:IsWorld() ) end
		} )
		if (tr2.Hit) then
			if (self:GetData().moveType != "water") then
				self:GetPhysicsObject():ApplyForceCenter( Vector(0,0,self:GetPhysicsObject():GetMass()*150) )
			end
		end
	end
end

function ENT:Damage(damager, amount)
	if (self:GetCapturable()) then return false end
	if amount < 0 then end

	if (self:GetUnderConstruction()) then
		self.doomed = true
		self:Die()
		return
	end

	if (self.alive) then
		if (amount > 0) then
			self:DamageEffect(damager)
		end

		local totalAmount = amount * self:GetDamageTakenModifier()

		self:SetUnitHealth(self:GetUnitHealth()-totalAmount)
		if (self:GetUnitHealth() <= 0) then
			self.doomed = true
			self:Die()
		end
	end
end

function ENT:Heal(healer, amount)
	if amount < 0 then return false end

	if (self.alive) then
		self:DamageEffect(healer)
		local newHealth = self:GetUnitHealth()+amount
		if (newHealth > self:GetData().maxHealth) then
			newHealth = self:GetData().maxHealth
		end
		self:SetUnitHealth(newHealth)
	end
end

function ENT:DamageEffect(damager)
	net.Start("MRTSClientsideUnitHit")
		net.WriteEntity(self)
	net.Broadcast()
end

function ENT:Die()
	if (self.alive) then
		self.alive = false
		
		local ed = EffectData()
		ed:SetOrigin( self:GetCenter() )
		ed:SetEntity( self )
		ed:SetAngles(Angle(0, 0, 0))
		ed:SetNormal(Vector(0, 0, 1))
		util.Effect( "GlassImpact", ed, true, true )

		net.Start("MRTSClientsideUnitDeath")
			net.WriteInt(self:GetUnitID(), 8)
			net.WriteInt(self.unitCategory, 8)
			net.WriteInt(self:GetTeam(), 8)
			net.WriteVector(self:GetCenter())
		net.Broadcast()

		if (self:GetData().objective) then
			MRTSEliminateTeam(self:GetTeam())
		end

		if (self:GetData().attackOnDeath == true) then
			self:Attack(self:GetData().attack)
		end
	end
	self:Remove()
end
/*
function ENT:OnRemove()
	if (self:GetData() != nil) then
		MRTSAffectUsedHousing(self:GetTeam(), -self:GetData().population or 0)
		if (not self.underConstruction) then
			MRTSAffectMaxHousing(self:GetTeam(), -self:GetData().housing)
		end
		
		table.RemoveByValue(mrtsUnits, self)
		table.RemoveByValue(self.squad.units, self)
		self.squad.dirty = true
		self:SharedRemove()
	else
		print("Data is nil at the time of deleting")
		debug.Trace()
	end
end
*/
function ENT:PhysicsCollide( data, phys )
	local other = data.HitEntity
	if (other:GetClass() == "ent_mrts_unit") then
		if ( self.moving and not other.moving ) then
			if ( other:GetMovePos() == self:GetMovePos()) then
				self:FinishMovement()
			end
	 	end
	end 
end

function ENT:GetModifiedSpeed()
	local speed = self:GetData().speed
	if (self.status != nil) then
		for k, v in pairs(self.status) do
			if (mrtsGameData.status[k].speed != nil) then
				speed = speed*mrtsGameData.status[k].speed
			end
		end
	end

	if (self.speedLimit and not IsValid(self.target)) then
		if (speed > self.speedLimit) then
			speed = self.speedLimit
		end
	end

	return speed
end

function ENT:GetModifiedDamage(attack)
	if (attack.damage) then
		local modifier = 1
		if (self.status != nil) then
			for k, v in pairs(self.status) do
				if (mrtsGameData.status[k].damageDealt != nil) then
					modifier = modifier*mrtsGameData.status[k].damageDealt
				end
			end
		end
		return attack.damage*modifier
	else
		return nil
	end
end

function ENT:GetDelayModifier()
	local modifier = 1
	if (self.status != nil) then
		for k, v in pairs(self.status) do
			if (mrtsGameData.status[k].fireRate != nil) then
				modifier = modifier*mrtsGameData.status[k].fireRate
			end
		end
	end
	return modifier
end

function ENT:GetDamageTakenModifier()
	local modifier = 1
	if (self.status != nil) then
		for k, v in pairs(self.status) do
			if (mrtsGameData.status[k].damageTaken != nil) then
				modifier = modifier*mrtsGameData.status[k].damageTaken
			end
		end
	end
	return modifier
end

function ENT:GetModifiedDelay()
	return (self:GetData().attack.delay or 1) / self:GetDelayModifier()
end

function ENT:CancelConstruction()
	local team = mrtsTeams[self:GetTeam()]

	for k, v in pairs(mrtsTeams[self:GetTeam()].buildQueue) do
		if(v.unit == self) then
			table.remove(mrtsTeams[self:GetTeam()].buildQueue, k)

			if (k == 1) then
				MRTSRestartBuild(self:GetTeam())
			end

			MRTSUpdateBuildQueue(self:GetTeam())
			break
		end
	end

	--MRTSAffectUsedHousing(self:GetTeam(), -self:GetData().population)
	for k, v in pairs(self:GetData().cost) do
		MRTSAffectResource(self:GetTeam(), v, k)
	end
end

function ENT:ChangeTeam(newTeam)
	self:ComputeImmediateChanges(-1)
	if (not self:GetUnderConstruction()) then
		self:ComputeReadyChanges(-1)
	end
	if (newTeam != -1) then
		self.teamID = newTeam
		self.teamData = mrtsTeams[newTeam]
		self:SetTeam(newTeam)
		self:SetTeamColor()
		self:ComputeImmediateChanges(1)
		if (not self:GetUnderConstruction()) then
			self:ComputeReadyChanges(1)
		end
	else
		self.teamID = -1
		self:SetTeam(-1)
		self:SetTeamColor()
	end
end

function ENT:IsAlliedToTeamID(other)
	local selfTable = self:GetTable()
	if (other == selfTable.teamID) then return true end
	if (selfTable.teamData.alliances[other]) then return true end
	return false
end

function ENT:IsAllied(other)
	local selfTable = self:GetTable()
	local otherTable = other:GetTable()
	if (selfTable.teamID == otherTable.teamID) then return true end
	if (selfTable.teamData.alliances[otherTable.teamID]) then return true end
	return false
end

function ENT:SetTeamColor()
	local data = self:GetData()
	local color = {r=255, g=255, b=255, a=255}
	if (mrtsTeams[self:GetTeam()] != nil) then
		color = mrtsTeams[self:GetTeam()].color
	end
	if (data.color == nil) then
		self:SetColor(color)
	else
		local from = color
		local to = data.color
		local lerp = LerpVector(data.color.a, Vector(from.r, from.g, from.b), Vector(to.r,to.g,to.b))
		local lerpedColor = Color(lerp.x, lerp.y, lerp.z)
		self:SetColor(lerpedColor)
	end
end

function ENT:SetFOWVisible(team)
	self:SetNWFloat("visible"..tostring(team), CurTime()+2)
end

function ENT:GravGunPickupAllowed( ply )
	return GetConVar("mrts_allow_grav_gun_pickup"):GetBool()
end

function ENT:GravGunPunt( ply )
	return false
end