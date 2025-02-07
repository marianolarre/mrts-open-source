include('shared.lua')

local VECTOR_UP = Vector(0,0,1)
local computeLighting = false

function ENT:Initialize()
end

function ENT:Draw()
	self:DrawModel()
end