AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include('shared.lua')

function ENT:Initialize()
	self.teamID = self:GetTeam()
	self.teamData = mrtsTeams[self:GetTeam()]
	local unitID = self:GetUnitID()
	self.unitID = unitID
	local data = mrtsGameData.troops[unitID]
	self.data = data
	self:SetUnitHealth(data.maxHealth)
	if (data.charge) then
		if (data.charge.startingAmount) then
			self:SetUnitCharge(data.charge.startingAmount)
		end
	end
	self.unitCategory = MRTS_UNIT_CATEGORY_TROOP
	self:SharedInit()

	self.lastDistance = 0
	self.currentDistance = 0
	self.stuckCounter = 0
	self.stuckFrustration = 0
	self.movingSince = 0

	self.squad = nil
	self.target = nil
	self.possibleTargets = {}
	self.fowTargets = {}

	self.desiredVelocity = Vector(0,0,0)
	self.forceMultiplier = 0.2

	self.nextAttack = 0
	self.nextPassive = 0
	self.nextFOWCheck = 0
	self.firstHitting = true
	self.windingUp = false
	self.stunnedUntil = 0

	self.underwater = false

	--self.builderEntity = nil
	self.birth = CurTime()

	--self:SetModel("models/holograms/icosphere.mdl")

	self.alive = true
	self.doomed = false

	self.selectable = true

	self.neighbors = {}

	self.waypoints = {}
	self.currentwaypoint = 0
	self.waypointpointer = 0
	self.maxwaypoints = 15
	self.waypointsleft = 0

	self.stanceAttackMove = false

	self:SetUniqueName(data.uniqueName)
	self:SetRenderMode( RENDERMODE_TRANSTEXTURE )
	self.ready = true
	self.health = data.maxHealth
	self.size = data.size
	self.stuckTolerance = data.speed/500
	self.status = {} // key: Status ID, value: time of finish
	self.canMove = (data.moveType != "static" or data.moveType != "none")
	self.unitCategory = MRTS_UNIT_CATEGORY_TROOP
	if (data.offset != nil) then
		local offset = Vector(data.offset.x, data.offset.y, data.offset.z)
		self:SetPos(self:GetPos() + offset)
	end
	self:SetModel(data.model or "models/balloons/balloon_dog.mdl")
	
	if (not data.keepMaterial) then
		self:SetMaterial(data.material or "models/debug/debugwhite")
	end
	
	local effectdata = EffectData()
	effectdata:SetEntity( self )
	util.Effect( "propspawn", effectdata )

	self:SetTeamColor()
	self:SetPhysics()

	if (data.moveType == "air") then
		
	end
	
	MRTS_MoveType(self, 0.001, data.moveType, true);

	table.insert(mrtsUnits, self)
	MRTSAffectMaxHousing(self:GetTeam(), data.housing)
	MRTSSquadUpdate()

	if (self:GetUnderConstruction()) then
		self:SetRenderFX(kRenderFxDistort)
	end
	if (self:GetCapturable()) then
		self:SetMaterial("phoenix_storms/dome")
	end
	if (self:GetClaimable()) then
		self:SetColor(Color(200,200,200))
	end
end

function ENT:Update()
	local selfTable = self:GetTable()
	local data = self:GetData()
	if (data.lifetime) then
		if (CurTime() > selfTable.birth+data.lifetime) then
			selfTable.Die(self)
		end
	end

	if (mrtsFOW) then
		selfTable.RevealEnemies(self)
	end

	if (CurTime() < selfTable.stunnedUntil) then return end
	if (selfTable.GetUnderConstruction(self)) then return end

	if (selfTable.underwater) then
		if (data.moveType != "water") then
			selfTable.Damage(self, self, data.maxHealth/10)
		end
	end
	
	local serverThinkRate = 1/6
	local vel = self:GetVelocity()
	if (selfTable.moving and (not selfTable.attacking or data.canAttackWhileMoving)) then
		// Movement
		selfTable.UnitMove(self, serverThinkRate, vel)
	else
		// Not movement
		selfTable.UnitStill(self, serverThinkRate, vel)
		selfTable.Chase(self)
	end	

	local attacked = false
	local charge = data.charge
	if (charge) then
		if (selfTable.GetUnitCharge(self) >= (charge.cost or 0)) then
			attacked = selfTable.HandleIsolatedAttack(self, charge.attack, MRTS_ATTACKID_CHARGE)
			if (attacked) then
				selfTable.AddCharge(self, -(charge.cost or 0))
			end
		end

		if (charge.passiveGain) then
			selfTable.AddCharge(self, serverThinkRate * charge.passiveGain)
		end
	end
	
	if (not attacked and data.attack) then
		attacked = selfTable.HandleAttack(self, data.attack, MRTS_ATTACKID_PRIMARY)
		if (attacked and charge) then
			if (charge.attackGain) then
				selfTable.AddCharge(self, charge.attackGain)
			end
		end
	end

	if (data.passive) then
		selfTable.HandlePassive(self, data.passive)
	end

	selfTable.HandleStatus(self, serverThinkRate)
end

function ENT:SetID(unitID)
	//self.data = unitData[unitID];
	self.unitID = unitID
	self:SetUnitID(unitID);
end

function ENT:GetData()
	local selfTable = self:GetTable()
	return selfTable.data
end

function ENT:LimitSpeed(speed)
	local selfTable = self:GetTable()
	selfTable.speedLimit = speed
end

function ENT:SetPhysics()
	local selfTable = self:GetTable()
	if (selfTable.data.rolling) then
		self:PhysicsInitSphere( selfTable.data.size/*, "gmod_ice"*/ )
		self:GetPhysicsObject():SetDamping(0.2, 2)
	else
		self:PhysicsInit(SOLID_VPHYSICS)
		self:GetPhysicsObject():SetDamping(0, 10)
		self:GetPhysicsObject():SetMaterial("gmod_ice")
	end
	self:GetPhysicsObject():SetMass(selfTable.data.mass or 1)
	self:SetCollisionBounds( Vector( -selfTable.data.size, -selfTable.data.size, -selfTable.data.size )*0.5, Vector( selfTable.data.size, selfTable.data.size, selfTable.data.size )*0.5 )
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:PhysWake()
end

function ENT:PostPaste(ply, ent, createdEntities)
	self:SetPhysics()
end

function ENT:OrderPosition(position, waypoint, attackmove)
	if (!self.canMove) then return end
	local selfTable = self:GetTable()
	selfTable.movingSince = CurTime()
	if (waypoint and selfTable.waypointsleft > 0) then
		if (selfTable.waypointsleft < selfTable.maxwaypoints) then
			local nextwaypoint = (selfTable.waypointpointer+1)%selfTable.maxwaypoints
			selfTable.waypoints[nextwaypoint] = position
			selfTable.waypointpointer = nextwaypoint
			selfTable.waypointsleft = selfTable.waypointsleft+1

			selfTable.UpdateClientWaypoints(self)
		end
	else
		selfTable.waypoints = {}
		selfTable.waypointpointer = 0
		selfTable.currentwaypoint = 0
		selfTable.waypointsleft = 1
		selfTable.stuckCounter = 0;
		selfTable.stuckFrustration = 0
		self:SetMovePos(position);
		self:GetPhysicsObject():Wake()
		selfTable.lastDistance = position:Distance(self:GetPos())
		selfTable.currentDistance = position:Distance(self:GetPos())

		self:UpdateClientWaypoints()
	end

	selfTable.moving = true

	if (attackmove) then
		selfTable.stanceAttackMove = true
	else
		selfTable.stanceAttackMove = false
		selfTable.attacking = false
		selfTable.stuckCounter = 0
		selfTable.stuckFrustration = 0
		if (not self:GetData().canAttackWhileMoving) then
			self:LoseTarget()
		end
	end
end

function ENT:UpdateClientWaypoints()
	local selfTable = self:GetTable()
	if (selfTable.waypointsleft > 0) then
		local waypoints = {}
		for i=#selfTable.waypoints-selfTable.waypointsleft+1, #selfTable.waypoints do
			table.insert(waypoints, selfTable.waypoints[i])
		end
		net.Start("MRTSClientsideUpdateWaypoints")
			net.WriteEntity(self)
			net.WriteTable(waypoints)
		net.Broadcast()
	else
		net.Start("MRTSClientsideUpdateWaypoints")
			net.WriteEntity(self)
			net.WriteTable({})
		net.Broadcast()
	end
end

function ENT:UnitMove(serverThinkRate)
	if (not self:GetData().canAttackWhileMoving) then
		self.firstHitting = true
	end
	if (self.squad != nil) then
		self.squad.dirty = true
	end
	self.underwater = ( bit.band( util.PointContents( self:GetPos() ), CONTENTS_WATER ) == CONTENTS_WATER )
	self:BeginSetup()
	MRTS_MoveType(self, serverThinkRate, self:GetData().moveType);
end

function ENT:UnitStill(serverThinkRate, vel)
	if (self.canMove) then
		if (self.birth+1 < CurTime()) then
			vel = self:GetVelocity()
			if (not self:GetPhysicsObject():IsAsleep()) then
				self.desiredVelocity = Vector(0,0)
				local troopForce = self:GetData().force or 1
				self:GetPhysicsObject():ApplyForceCenter( Vector(-vel.x, -vel.y, 0)*0.1*troopForce )
				if (vel:LengthSqr() < 500) then
					if (not self.flies or math.abs(self:GetPos().z-self.flyHeight) < 10) then
						self:GetPhysicsObject():Sleep()
					end
				end
			end
		end
	end
end

function ENT:FinishMovement()
	self.waypointsleft = self.waypointsleft-1
	if (self.waypointsleft <= 0) then
		self:FinishAllMovement()
	else
		local nextwaypoint = (self.currentwaypoint+1)%self.maxwaypoints
		self:SetMovePos(self.waypoints[nextwaypoint])
		self.lastDistance = self:GetMovePos():Distance(self:GetPos())
		self.currentDistance = self.lastDistance
		self.currentwaypoint = nextwaypoint
		self.stuckCounter = 0
		self.stuckFrustration = 0
		self:UpdateClientWaypoints()
	end
end

function ENT:FinishAllMovement()
	if (self.moving) then
		self.moving = false
		self.waypointpointer = 0
		self.currentwaypoint = 0
		self.waypointsleft = 0
		self.lastDistance = 0
		self.stuckCounter = 0
		self.stuckFrustration = 0
		
		if (not IsValid(self:GetTarget()) or not self.stanceAttackMove) then
			self:BeginSetup()
			net.Start("MRTSClientsideUnitStopMoving")
				net.WriteEntity(self)
			net.Broadcast()
		end
	end
end

function ENT:OnRemove()
	if (self:GetUnderConstruction()) then
		self:CancelConstruction()
	end

	if (self:GetData() != nil) then
		MRTSAffectUsedHousing(self:GetTeam(), -self:GetData().population)

		if (not self:GetUnderConstruction() and self:GetData().maxHousing != 0) then
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

function ENT:PhysicsUpdate()
	if (!IsValid(self:GetPhysicsObject())) then return end
	local selfTable = self:GetTable()
	if (CurTime() < selfTable.stunnedUntil) then return end
	local vel = self:GetPhysicsObject():GetVelocity()
	local vel2D = Vector(vel.x, vel.y)
	local force = selfTable.desiredVelocity-vel2D
	if (selfTable.flies) then
		local flyForce = 1
		local dampen = 1
		force = force + Vector(0,0,flyForce*(selfTable.flyHeight - self:GetPos().z) - vel.z*dampen)
	end
	/*if (selfTable.desiredDirection) then
		local lookForward = self:GetForward():Cross(Vector(0,0,1))*30
		self:GetPhysicsObject():ApplyTorqueCenter()
	end*/
	local troopForce = selfTable.data.force or 1
	self:GetPhysicsObject():ApplyForceCenter( force*selfTable.forceMultiplier*3*troopForce )

	if (not selfTable.data.rolling) then
		local keepUpRight = self:GetUp():Cross(Vector(0,0,1))*30
		self:GetPhysicsObject():ApplyTorqueCenter(keepUpRight)
	end
	
	if (selfTable.forceMultiplier < 0.2) then
		selfTable.forceMultiplier = selfTable.forceMultiplier+0.01
	end
end

function ENT:PhysicsCollide( data, phys )
	local other = data.HitEntity
	if (other:GetClass() == "ent_mrts_troop") then
		self.forceMultiplier = 0.05
		if (other.moving) then
			self.stuckFrustration = math.max(0, self.stuckFrustration-1)
		end
		if ( self.moving and not other.moving ) then
			if ( other:GetMovePos() == self:GetMovePos()) then
				if (not self.flies or math.abs(self:GetPos().z-self.flyHeight) < 10) then
					self:FinishMovement()
				end
			end
	 	end
	end 
end