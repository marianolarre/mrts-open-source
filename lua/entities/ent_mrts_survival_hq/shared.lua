ENT.Type = "anim"
//ENT.Base = "base_gmodentity"

ENT.Category = "MarumsRTS"

ENT.PrintName= "MarumRTS survival hq"
ENT.Author= "Marum"
ENT.Contact= "don`t"
ENT.Purpose= "Play"
ENT.Instructions= "You shouldnt be able to just spawn this"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Editable = false

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
	self.nextSpawn = 0
end