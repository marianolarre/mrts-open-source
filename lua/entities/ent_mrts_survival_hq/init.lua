AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props_c17/gravestone_statue001a.mdl")
	self:SetPhysics()
	self.nextWave = 0
	self.going = false
	self.waveNumber = 0
	self.availableTroopsIDs = {}
	self.unlockedTroops = 1
	self.targetHQ = nil
end

function ENT:SetPhysics()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid( SOLID_VPHYSICS )
	self:GetPhysicsObject():EnableMotion(false)
	self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionGroup(COLLISION_GROUP_VEHICLE)
end

function ENT:Begin()
	self.waveNumber = 1
	self.going = true
	self.nextWave = CurTime()+10

	local buildings = ents.FindByClass("ent_mrts_building")
	for k, v in pairs(buildings) do
		if (v:GetData().objective) then
			self.targetHQ = v
			break
		end
	end

	local faction = mrtsGameData.factions[mrtsTeams[0].faction]
	self.availableTroopsIDs = {}
	for k, v in pairs(mrtsGameData.troops) do
		if (not v.unlisted) then
			local whitelisted = faction.whitelist and table.HasValue(faction.whitelist, v.uniqueName)
			local blacklisted = faction.blacklist and table.HasValue(faction.blacklist, v.uniqueName)
			if (not blacklisted and (not v.factionSpecific or whitelisted)) then
				table.insert(self.availableTroopsIDs, k)
			end
		end
	end
	PrintMessage( HUD_PRINTCENTER, "Wave 1 starts in 10 seconds" )
end

function ENT:Think()
	if (not self.going) then return false end
	if (CurTime() > self.nextWave) then
		PrintMessage( HUD_PRINTCENTER, "Wave "..self.waveNumber )
		self:SendWave()
		self.nextWave = CurTime()+30
		self.waveNumber = self.waveNumber+1
	end
end

function ENT:SendWave()
	local directionTowardsHQ = self.targetHQ:GetPos()-self:GetPos()
	directionTowardsHQ:Normalize()
	directionTowardsHQ.z = 0

	if (self.unlockedTroops < #self.availableTroopsIDs) then
		if (self.waveNumber%3==0) then
			self.unlockedTroops = self.unlockedTroops+1
		end
	end

	-- Choose troops
	local budget = 25 + self.waveNumber * (20+self.waveNumber*2)
	local slowestSpeed = 10000
	local spawnedTroops = {}
	for i=1, 75 do
		local randomTroop = 1
		for fails=0, self.unlockedTroops do
			randomTroop = math.random(self.unlockedTroops-fails)
			for k, v in pairs(mrtsGameData.troops[self.availableTroopsIDs[randomTroop]].cost) do
				budget = budget - v
			end
			if budget > 0 then
				break
			end
		end
		if (budget > 0) then
			local troopID = self.availableTroopsIDs[randomTroop]
			local troop = MRTSSpawnTroop(0, troopID, self:GetPos()+directionTowardsHQ*150+VectorRand()*(25+self.waveNumber), nil, true, false, false, false)
			if (mrtsGameData.troops[troopID].speed < slowestSpeed) then
				slowestSpeed = mrtsGameData.troops[troopID].speed
			end
			table.insert(spawnedTroops, troop)
			troop.aiControlled = true
		end
	end
	for k, v in pairs(spawnedTroops) do
		v:LimitSpeed(slowestSpeed)
	end

	timer.Simple(0.5, function()
		local troops = ents.FindByClass("ent_mrts_troop")
		for k, v in pairs(troops) do
			if (v.aiControlled) then
				local speedLimit = v.speedLimit
				v:OrderPosition(self.targetHQ:GetPos(), false, true)
				v:LimitSpeed(speedLimit)
			end
		end
	end)
end