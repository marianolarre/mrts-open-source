ENT.Type = "anim"
//ENT.Base = "base_gmodentity"

ENT.Category = "MarumsRTS"

ENT.PrintName= "MarumRTS base"
ENT.Author= "Marum"
ENT.Contact= "don`t"
ENT.Purpose= "Play"
ENT.Instructions= "You shouldnt be able to just spawn this"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Editable = false

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetID(unitID)
	//self.data = unitData[unitID];
	self.unitID = unitID
	self:SetUnitID(unitID);
	self.isMRTSUnit = true;
end
/*
function ENT:SharedInit()
	if (SERVER or self.ready) then
		if (unitData[self.unitID]) then
			self.ready = true
			self.underConstruction = true;
			self.health = unitData[self.unitID].maxHealth
			self.size = unitData[self.unitID].size
			self.firingOrigin = self:GetPos()
			self.stuckTolerance = unitData[self.unitID].speed/500
			self.builtUnits = 0
			self.status = {}
			self.canMove = (unitData[self.unitID].moveType != "static")
		end
	end
end
*/
function ENT:FinishConstruction(supressEffects)
	if (SERVER) then
		self:SetUnderConstruction(false)
		self:BeginSetup()
		self:ComputeReadyChanges(1)
		-- Effects
		self:SetRenderFX(kRenderFxNone)
		self:SetRenderMode(RENDERMODE_NORMAL)

		net.Start("MRTSClientsideFinishConstruction")
			net.WriteEntity(self)
		net.Broadcast()
	end
	if (CLIENT) then
		self:CreateAccessories()

		if (not supressEffects and self:IsFOWVisibleToTeam(mrtsTeam)) then
			local effectdata = EffectData()
			effectdata:SetEntity( self )
			util.Effect( "propspawn", effectdata )
			effectdata = EffectData()
			effectdata:SetEntity( self )
			util.Effect( "entity_remove", effectdata )
			sound.Play(self:GetData().spawnSound, self:GetPos(), 100, 100+math.random(15), 0.7)
		end
	end
end

function ENT:SharedRemove()
end

function ENT:IsPassive()
	if (self:GetData().attack == nil) then
		return true
	end
	return false
end

function ENT:GetTargetPosition(target)
	local targetPos = target:GetCenter()
	if (target:GetClass() == "ent_mrts_building") then
		targetPos = target:GetClosestPoint(self:GetCenter(), 0)
	end
	return targetPos
end

function ENT:GetCenter()
	local totalOffset = Vector(0,0,0)
	if (self:GetData().offset) then
		local o = self:GetData().offset
		local offset = Vector(o.x ,o.y, o.z)
		offset:Rotate(self:GetAngles())
		totalOffset = totalOffset - offset
	end
	return self:GetPos() + totalOffset
end

function ENT:GetFiringOrigin(useWeapon)
	local data = self:GetData()

	if (CLIENT and useWeapon) then
		if (data.accessories) then
			for k, v in pairs(data.accessories) do
				if (v.weapon) then
					if (self.accessories) then
						if (self.accessories[k]) then
							return self.accessories[k]:GetPos()
						end
					end
				end
			end
		end
	end

	if (data.firingOffset) then
		local offset = Vector(data.firingOffset.x, data.firingOffset.y, data.firingOffset.z)
		offset:Rotate(self:GetAngles())
		return self:GetPos()+offset
	end
	
	return self:GetPos()+Vector(0,0,data.attack.offset or 0)
end

function ENT:IsFOWVisibleToTeam(toTeam)
	if (toTeam == -1) then return true end
	if (!GetConVar("mrts_fow"):GetBool()) then return true end
	return (self:IsAlliedToTeamID(toTeam) or self:GetNWFloat("visible"..tostring(toTeam,0)) >= CurTime() or self:GetData().objective or self:GetClaimable() or self:GetCapturable())
end