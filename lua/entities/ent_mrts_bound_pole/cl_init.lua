include('shared.lua')

local mat = Material("Models/effects/comball_tape")

function ENT:Draw()
	self:DrawModel()
	--render.SetMaterial(mat)
end