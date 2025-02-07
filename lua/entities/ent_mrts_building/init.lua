AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	self.teamID = self:GetTeam()
	self.teamData = mrtsTeams[self:GetTeam()]
	local unitID = self:GetUnitID()
	self.unitID = unitID
	local data = mrtsGameData.buildings[unitID]
	self.data = data
	self:SetUnitHealth(data.maxHealth)
	if (data.charge) then
		if (data.charge.startingAmount) then
			self:SetUnitCharge(data.charge.startingAmount)
		end
	end
	self:SharedInit()	

	self:SetUniqueName(data.uniqueName)
	self:SetRenderMode( RENDERMODE_TRANSTEXTURE )
	self.health = data.maxHealth
	if (data.big) then
		self.size = mrtsGridSize
	else
		self.size = mrtsGridSize/2
	end
	self.firingOrigin = self:GetPos()
	self.builtUnits = 0
	self.status = {} // key: Status ID, value: time of finish
	self.canMove = false
	self.unitCategory = MRTS_UNIT_CATEGORY_BUILDING
	self:PrecalculateCenter()
	self:SetModel(data.model or "models/balloons/balloon_dog.mdl")
	if (not data.keepMaterial) then
		self:SetMaterial(data.material or "models/debug/debugwhite")
	end
	if (self:GetUnderConstruction()) then
		self:SetRenderFX(kRenderFxDistort)
	end

	self:SetPhysics()

	self:ChooseValidExit()

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
	self.windingUp = false
	self.settingUp = false
	self.stunnedUntil = 0

	self.builderEntity = nil
	self.birth = CurTime()

	self.alive = true
	self.doomed = false

	self.selectable = true
	self.unitCategory = MRTS_UNIT_CATEGORY_BUILDING
	self.activated = false
	self.activationValue = 0
	self.originalPosition = self:GetPos()

	self.waypoints = {}
	self.currentwaypoint = 0
	self.waypointpointer = 0
	self.maxwaypoints = 50
	self.waypointsleft = 0

	self.stanceAttackMove = false
	--self.capturable = false

	self:SetTeamColor()

	table.insert(mrtsUnits, self)

	timer.Simple(0.1, function()
		if (IsValid(self)) then
			self:FinishAllMovement()
		end
	end)
	MRTSAddToPassiveSquads(self)

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

function ENT:GetData()
	local selfTable = self:GetTable()
	return selfTable.data
end

function ENT:PostEntityPaste(ply, ent, createdEntities)
	timer.Simple(1, function()
		if (IsValid(self)) then
			self:ChooseValidExit()
			self:FinishConstruction(true)
		end
	end)
end

function ENT:SetPhysics()
	self:PhysicsInitStatic(SOLID_VPHYSICS)
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )
	self:GetPhysicsObject():EnableMotion(false)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end

function ENT:Interact()
	if (self:GetUnderConstruction()) then return end
	self.activated = not self.activated
end

function ENT:Update()
	if (self:GetUnderConstruction()) then return end

	if (mrtsFOW) then
		self:RevealEnemies()
	end

	local serverThinkRate = 1/6

	local attack = self:GetData().attack
	if (attack != nil) then
		self:AquireTarget(self:SelectTarget(attack));
		if (IsValid(self.target)) then
			if (self.windingUp) then
				local range = attack.range-- + self.target.size
				if (self.target.unitCategory != MRTS_UNIT_CATEGORY_BUILDING) then
					range = range + (self.target.size or 0)
				end
				local minRange = attack.minimumRange or 0
				local distSqr = (self.target:GetPos()-self:GetPos()):LengthSqr()
				local inRange = distSqr < range*range and distSqr > minRange*minRange
				if (not IsValid(self.target) or (not self.windingUp and not inRange or (!self.target:IsFOWVisibleToTeam(self:GetTeam())) or self.target.doomed)) then
					self:LoseTarget()
				end
			end
			if (CurTime() > self.nextAttack) then
				self:TryAttack(attack, MRTS_ATTACKID_PRIMARY)
			end
		end
	end

	if (self.troopQueue > 0) then
		if (CurTime() > self.nextSpawn) then
			self:SpawnQueuedTroop()
		end
	end

	-- Activation	
	local activation = self:GetData().activation
	if (activation) then
		if (activation.type == "move") then
			if (self.activated) then
				if (self.activationValue < 1) then
					self.activationValue = self.activationValue + serverThinkRate/activation.time
					if (self.activationValue > 1) then
						self.activationValue = 1
					end
					local offsetVector = Vector(activation.offset.x, activation.offset.y, activation.offset.z)
					self:SetPos(self.originalPosition + offsetVector * self.activationValue)
				end
			else
				if (self.activationValue > 0) then
					self.activationValue = self.activationValue - serverThinkRate/activation.time
					if (self.activationValue < 0) then
						self.activationValue = 0
					end
					local offsetVector = Vector(activation.offset.x, activation.offset.y, activation.offset.z)
					self:SetPos(self.originalPosition + offsetVector * self.activationValue)
				end
			end
		end
	end

	self:HandleStatus(serverThinkRate)
end

function ENT:OrderPosition(position, waypoint, attackmove)
	position = position+Vector(0,0,6)
	if (waypoint) then
		if (self.waypointsleft < self.maxwaypoints) then
			local nextwaypoint = (self.waypointpointer+1)%self.maxwaypoints
			self.waypoints[nextwaypoint] = position
			self.waypointpointer = nextwaypoint
			self.waypointsleft = self.waypointsleft+1

			self:UpdateClientWaypoints()
		end
	else
		self.waypointpointer = 0
		self.currentwaypoint = 0
		self.waypointsleft = 0
		self:SetMovePos(position)
		self.lastDistance = position:Distance(self:GetPos())
		self.currentDistance = self.lastDistance
		self:CalculateSpawnPosition()

		self:UpdateClientWaypoints()
	end
end

function ENT:UpdateClientWaypoints()
	if (self.waypointsleft > 0) then
		local waypoints = {}
		for i=1, self.waypointsleft do
			table.insert(waypoints, self.waypoints[i])
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

function ENT:FinishAllMovement()
	--self:CancelTroop()
end

function ENT:ChooseValidExit()
	self:SetMovePos(self:GetPos()+Vector(0,100,0))
	local pos, blocked = self:CalculateSpawnPosition()
	if (blocked) then
		self:SetMovePos(self:GetPos()+Vector(-100,0,0))
		pos, blocked = self:CalculateSpawnPosition()
		if (blocked) then
			self:SetMovePos(self:GetPos()+Vector(0,-100,0))
			pos, blocked = self:CalculateSpawnPosition()
			if (blocked) then
				self:SetMovePos(self:GetPos()+Vector(100,0,0))
				self:CalculateSpawnPosition()
			end
		end
	end
end

function ENT:DamageEffect(damager)
	net.Start("MRTSClientsideUnitHit")
		net.WriteEntity(self)
	net.Broadcast()
end

function ENT:OnRemove()
	if (self:GetUnderConstruction()) then
		self:CancelConstruction()
	end

	if (self:GetData() != nil) then
		self:ComputeAllChanges(-1)
		
		table.RemoveByValue(mrtsUnits, self)
		table.RemoveByValue(self.squad.units, self)
		if (#self.squad.units <= 0) then
			if (self:IsPassive()) then
				table.RemoveByValue(mrtsPassiveSquads, self.squad)
			end
		else
			MRTSUpdateSquadBoundaries(self.squad)
		end
		if (self.worker != nil) then
			self.worker:Return()
			self.worker = nil
		end
		self:SharedRemove()
	else
		print("Data is nil at the time of deleting")
		debug.Trace()
	end
end

function ENT:CalculateSpawnPosition()
	local data = self:GetData()
	if (not data.makesTroop) then return end
	local troopData = GetTroopByUniqueName(data.makesTroop.troop)
	--local pos = self:GetMovePos()-self:GetPos()
	local margin = data.makesTroop.spawnMargin or 2
	if (troopData != nil) then
		margin = troopData.size+(data.makesTroop.spawnMargin or 2)
	end
	/*local offset=Vector(data.offset.x, data.offset.y, data.offset.z)
	offset:Rotate(self:GetAngles())
	local size=Vector(data.size.x, data.size.y, data.size.z)
	size:Rotate(self:GetAngles())
	size=Vector(math.abs(size.x),math.abs(size.y),math.abs(size.z))
	pos.x = math.Clamp(pos.x, -size.x - margin - offset.x, size.x + margin - offset.x)
	pos.y = math.Clamp(pos.y, -size.y - margin - offset.y, size.y + margin - offset.y)
	pos.z = math.Clamp(pos.z, -size.z - margin, size.z + margin)
	local pos = self:GetPos()+pos*/
	local pos = self:GetClosestPoint(self:GetMovePos(), margin) + Vector(0,0,margin)
	
	local blocked = false
	local blockingEnts = ents.FindInSphere( pos, troopData.size )
	for k, v in pairs(blockingEnts) do
		if v != self and (v:GetClass() == "ent_mrts_building" or v:GetClass() == "prop_physics") then
			blocked = true
		end
	end

	self:SetBlocked(blocked)
	self:SetSpawnPos(pos)

	return pos, blocked
end

function ENT:SpawnQueuedTroop()
	local pos, blocked = self:CalculateSpawnPosition()

	if (not blocked) then
		local troopID = GetTroopID(self:GetData().makesTroop.troop)
		local newTroop = MRTSSpawnTroop(self:GetTeam(), troopID, pos+VectorRand()*5, nil, true, true)
		timer.Simple(0.1, function()
			if (IsValid(newTroop)) then
				newTroop:OrderPosition(self:GetMovePos())
				newTroop.waypoints = self.waypoints
				newTroop.waypointsleft = self.waypointsleft
				newTroop:UpdateClientWaypoints()
			end
		end)

		self.troopQueue = self.troopQueue - 1
		if (self.troopQueue > 0) then
			local troopData = GetTroopByUniqueName(self:GetData().makesTroop.troop)
			self.nextSpawn = CurTime()+self:GetData().makesTroop.time
		end
		net.Start("MRTSClientsideNextTroopInQueue")
			net.WriteEntity(self)
		net.Broadcast()
	end
end