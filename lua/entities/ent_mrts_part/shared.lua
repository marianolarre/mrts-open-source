ENT.Type = "anim"
ENT.Base = "ent_mrts_troop"

ENT.Category = "MarumsRTS"

ENT.PrintName= "MarumRTS base contraption part"
ENT.Author= "Marum"
ENT.Contact= "don`t"
ENT.Purpose= "Play"
ENT.Instructions= "You shouldnt be able to just spawn this"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Editable = false

function ENT:GetData()
	return mrtsGameData.parts[self:GetUnitID()]
end

function ENT:SharedInit()
	self.unitCategory = MRTS_UNIT_CATEGORY_PART
end

duplicator.RegisterEntityClass("ent_mrts_part", function(ply, data)
	local entity= MRTSSpawnPart(ply.mrtsTeam, data.unitID, data.Pos, ply, true, false, false, false)
	return entity
end, "Data")