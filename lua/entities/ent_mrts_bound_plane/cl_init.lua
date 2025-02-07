include('shared.lua')

local mat = Material("Models/effects/comball_tape")

function ENT:Initialize()
	table.insert(mrtsBoundPlanes, self)
end

function ENT:OnRemove()
	table.RemoveByValue(mrtsBoundPlanes, self)
end

function ENT:Draw()
	self:DrawModel()
	local pos = self:GetPos()
	local forward = self:GetForward()
	local right = self:GetRight()
	local up = self:GetUp()
	local size = 50
	render.SetMaterial(mat)
	render.DrawQuad( pos + up * size, pos - forward * size, pos - up * size, pos + forward * size )
end