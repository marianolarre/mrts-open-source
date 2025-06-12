ENT.Type = "anim"
//ENT.Base = "base_gmodentity"

ENT.Category = "MarumsRTS"

ENT.PrintName= "MRTS Bound Pole"
ENT.Author= "Marum"
ENT.Contact= "don`t"
ENT.Purpose= "Play"
ENT.Instructions= "Mark the limits of the play area, prevents building outside"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Editable = false

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "NextPole")
end