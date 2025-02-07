include('shared.lua')

function ENT:Initialize()
	self.trail = ""
end

function ENT:Draw()
	local size = math.random()*6+4

	if (self.trail != "") then
		MRTS_Effect(self.trail, self:GetPos(), self:GetPos())
	else
		local trail = self:GetNWString("trail", "")
		if (trail != "") then
			self.trail = trail
		end
	end

	cam.Start3D() -- Start the 3D function so we can draw onto the screen.
		render.SetColorMaterial() -- Tell render what material we want, in this case the flash from the gravgun
		render.DrawSprite( self:GetPos(), size, size, Color(255,255,100)) -- Draw the sprite in the middle of the map, at 16x16 in it's original colour with full alpha.
	cam.End3D()
end