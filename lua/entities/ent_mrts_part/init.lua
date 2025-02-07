AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	self.teamID = self:GetTeam()
	self.teamData = mrtsTeams[self:GetTeam()]
	local unitID = self:GetUnitID()
	self.unitID = unitID
	local data = mrtsGameData.parts[unitID]
	self.data = data
	self:SetUnitHealth(data.maxHealth)
	if (data.charge) then
		if (data.charge.startingAmount) then
			self:SetUnitCharge(data.charge.startingAmount)
		end
	end
	self.unitCategory = MRTS_UNIT_CATEGORY_PART
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
