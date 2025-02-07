ENT.Type = "anim"
ENT.Base = "ent_mrts_unit"

ENT.Category = "MarumsRTS"

ENT.PrintName= "MarumRTS base troop"
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
	self:NetworkVar( "Float", 1, "UnitCharge")
	self:NetworkVar( "Entity", 0, "Target")
	self:NetworkVar( "Entity", 1, "SecondaryTarget")
	self:NetworkVar( "Vector", 0, "MovePos")
	self:NetworkVar( "String", 0, "UniqueName")
	self:NetworkVar( "Bool", 0, "UnderConstruction")
	self:NetworkVar( "Bool", 1, "Capturable")
	self:NetworkVar( "Bool", 2, "Claimable")
end

function ENT:GetCapturable()
	return false
end

function ENT:GetBoxSize()
	return Vector(10, 10, 10)
end

function ENT:SharedRemove()
end

function ENT:SharedInit()
end

function MRTSSanitizeTroopTable(tbl)
	--print("--------- Unsanitized table")
	--PrintTable(tbl)
	return {
		Angle=tbl.Angle,
		Class=tbl.Class,
		ConstraintSystem=tbl.ConstraintSystem,
		Constraints=tbl.Constraints,
		Pos=tbl.Pos,
		UnitID=tbl.unitID
	}
	--print("--------- Sanitized table")
	--PrintTable(sanitizedTable)
	--return sanitizedTable
end

duplicator.RegisterEntityClass("ent_mrts_troop", function(ply, data)
	local troopID = GetTroopIDByUniqueName(data.DT.UniqueName)
	if (troopID == nil) then
		print("There is no troop in the current datapack with the unique name '"..data.DT.UniqueName.."'")
		return
	end
	local entity= MRTSSpawnTroop(ply.mrtsTeam, troopID, data.Pos, ply, true, false, false, false)
	return entity
end, "Data")