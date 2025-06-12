include('shared.lua')

local width = 4
local size = 50
local height = 50
local faces = 16

function ENT:Initialize()
	self:SharedInit()
	self:SetRenderBounds(-Vector(self:GetSize()/2, self:GetSize()/2, 0), Vector(self:GetSize()/2, self:GetSize()/2, 100))

	local radius = self:GetSize()/2
	local height = 150
	self.polygonPoints = {}
	for i=0, faces do
		self.polygonPoints[i] = {x=math.cos(i*math.pi*2/faces)*radius, y=math.sin(i*math.pi*2/faces)*radius}
	end	
end

local function DrawArc(percentage, radius, thickness)

	local height = 150
	local points = {}
	for i=0, faces do
		points[i] = {x=math.cos(i*math.pi*2/faces), y=math.sin(i*math.pi*2/faces)}
	end

	for i=0, faces*percentage do
		local this = points[i]
		local next = points[i%faces+1]
		if (i > faces*percentage-1) then
			local t = (percentage*faces)%1
			next.x = this.x*(1-t)+next.x*t
			next.y = this.y*(1-t)+next.y*t
		end
		surface.DrawPoly({
			{x=this.x*radius, y=this.y*radius},
			{x=next.x*radius, y=next.y*radius},
			{x=next.x*(radius-thickness), y=next.y*(radius-thickness)},
			{x=this.x*(radius-thickness), y=this.y*(radius-thickness)},
		})
	end
end

function ENT:Draw()
	local size = self:GetSize()
	local sizewidth = width-size

	cam.Start3D2D( self:GetPos()+Vector(0,0,1), self:GetAngles(), 1 )

		local radius = self:GetSize()/2
		draw.NoTexture()
		surface.SetDrawColor(0, 0, 0, 200)
		DrawArc(1, self:GetSize()/2+11, 11)

		if (self.isCaptured) then
			local capturingTeam = mrtsTeams[self.capturingTeam]
			surface.SetDrawColor(capturingTeam.color.r, capturingTeam.color.g, capturingTeam.color.b, 100)
		else
			local neutralTeam = MRTSGetNeutralTeam()
			surface.SetDrawColor(neutralTeam.color.r, neutralTeam.color.g, neutralTeam.color.b, 100)
		end
		surface.DrawPoly( self.polygonPoints )

		if (self.ready) then
			if (self.capturingTeam > 0) then
				local capturingTeam = mrtsTeams[self.capturingTeam]
				local s = math.floor((size-width)*self.capture/2)*2
				surface.SetDrawColor(capturingTeam.color.r, capturingTeam.color.g, capturingTeam.color.b, 200)
				
				--surface.DrawRect( -s/2, -s/2, s, s, math.min(s, width))
				DrawArc(self.capture, self:GetSize()/2+9, 7)
				-- outline color
			end

			--local progress = math.floor((size-width)*self.capture/2)/(size-width)

			/*surface.DrawRect(-size/2, -size/2, size*progress, width)--top
			surface.DrawRect(size/2-width, -size/2, width, size*progress)--right
			surface.DrawRect(size/2-size*progress, size/2-width, size*progress, width)--bottom
			surface.DrawRect(-size/2, size/2-size*progress, width, size*progress)--left

			surface.DrawRect(size/2-size*progress, -size/2, size*progress, width)--top
			surface.DrawRect(size/2-width, size/2-size*progress, width, size*progress)--right
			surface.DrawRect(-size/2, size/2-width, size*progress, width)--bottom
			surface.DrawRect(-size/2, -size/2, width, size*progress)--left*/
		end
	cam.End3D2D()
end