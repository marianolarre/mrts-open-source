ENT.Type = "anim"
ENT.Base = "ent_mrts_unit"

ENT.Category = "MarumsRTS"

ENT.PrintName= "MarumRTS base building"
ENT.Author= "Marum"
ENT.Contact= "don`t"
ENT.Purpose= "Play"
ENT.Instructions= "You shouldnt be able to just spawn this"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Editable = false

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
	self.moving = false;
	self.isMRTSUnit = true;
	self:NetworkVar( "Int", 0, "UnitID")
	self:NetworkVar( "Int", 1, "Team")
	self:NetworkVar( "Float", 0, "UnitHealth")
	self:NetworkVar( "Float", 1, "UnitMaxHealth")
	self:NetworkVar( "Entity", 0, "Target")
	self:NetworkVar( "Vector", 0, "MovePos")
	self:NetworkVar( "Vector", 1, "SpawnPos")
	self:NetworkVar( "String", 0, "UniqueName")
	self:NetworkVar( "Bool", 0, "UnderConstruction")
	self:NetworkVar( "Bool", 1, "Blocked")
	self:NetworkVar( "Bool", 2, "Capturable")
	self:NetworkVar( "Bool", 3, "Claimable")

	self.troopQueue = 0
	self.nextSpawn = 0
end

function ENT:SetID(unitID)
	self.unitID = unitID
	self:SetUnitID(unitID);
end

function ENT:SharedInit()
end

function ENT:GetClosestPoint(pos, margin)
	local margin = margin or 0
	local data = self:GetData()
	local diff = pos-self:GetCenter()
	local size=Vector(data.size.x, data.size.y, data.size.z)

	local box = MRTSSanitizeBox({size=size, angle=self:GetAngles(), center=self:GetCenter()})
	
	local forwardVector = box.angle:Forward()
	local rightVector = box.angle:Right()
	local forwardDistance = diff:Dot(forwardVector)
	local rightDistance = diff:Dot(rightVector)
	forwardDistance = math.Clamp(forwardDistance, -box.size.x - margin, box.size.x + margin)
	rightDistance = math.Clamp(rightDistance, -box.size.y - margin, box.size.y + margin)

	diff.z = math.Clamp(diff.z, -box.size.z - margin, box.size.z + margin)

	return self:GetCenter()+forwardVector*forwardDistance+rightVector*rightDistance+Vector(0, 0, diff.z)
end

function ENT:SharedRemove()
end

function ENT:QueueTroop(troopID)
	local troopData = GetTroopByUniqueName(self:GetData().makesTroop.troop)
	if (self.troopQueue == 0) then
		self.nextSpawn = CurTime()+self:GetData().makesTroop.time
	end
	if (SERVER) then
		MRTSAffectUsedHousing(self:GetTeam(), troopData.population)
	end
	self.troopQueue = self.troopQueue + 1
end

function ENT:CancelFullQueue()
	if (SERVER) then
		-- Refund queued units
		if (self:GetData().makesTroop) then
			local troopData = GetTroopByUniqueName(self:GetData().makesTroop.troop)
			local cost = self:GetData().makesTroop.cost
			MRTSAffectUsedHousing(self:GetTeam(), -troopData.population*self.troopQueue)
			for k, v in pairs(cost) do
				MRTSAffectResource(self:GetTeam(), v*self.troopQueue, k)
			end
			net.Start("MRTSClientsideCancelFullQueue")
				net.WriteEntity(self)
			net.Broadcast()
		end
	end
	self.troopQueue = 0
end

function ENT:CancelTroop()
	if (self.troopQueue == 0) then return end
	if (SERVER) then
		local troopData = GetTroopByUniqueName(self:GetData().makesTroop.troop)
		local cost = self:GetData().makesTroop.cost
		MRTSAffectUsedHousing(self:GetTeam(), -troopData.population)
		for k, v in pairs(cost) do
			MRTSAffectResource(self:GetTeam(), v, k)
		end
	end
	self.troopQueue = self.troopQueue-1
end

function ENT:PrecalculateCenter()
	local data = self:GetData()
	local o = data.offset or {x=0, y=0, z=0}
	local offset = Vector(-o.x ,-o.y, -o.z)
	local a = data.angle or {x=0, y=0, z=0}
	local angle = Angle(a.x, a.y, a.z)
	offset:Rotate(self:GetAngles() - angle)
	local size = Vector(data.size.x, data.size.y, data.size.z)
	size:Rotate(self:GetAngles())
	local heightCorrection = math.abs(size.z)
	self.center = self:GetPos() + offset + Vector(0,0,heightCorrection)
end

function ENT:GetBoxSize()
	return self:GetData().size
end

function ENT:GetBox()
	return {
		center=self:GetCenter(),
		angle=self:GetAngles(),
		size=self:GetData().size
	}
end

function ENT:GetCenter()
	if (self.center) then
		return self.center
	else
		self:PrecalculateCenter()
		return self.center
	end
end