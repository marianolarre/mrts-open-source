include('shared.lua')

local width = 4
local size = 50
local height = 50

function ENT:Initialize()
	self:SharedInit()
	self:SetRenderBounds(-Vector(self:GetSize()/2, self:GetSize()/2, 0), Vector(self:GetSize()/2, self:GetSize()/2, 100))
end

function ENT:Draw()
	self:DrawModel()
	local size = self:GetSize()
	local sizewidth = width-size
	cam.Start3D2D( self:GetPos()+Vector(0,0,1), Angle(0,0,0), 1 )
		surface.SetDrawColor(255,255,255,50)
		surface.DrawRect(-size/2, -size/2, size, size)

		if (self.ready) then
			if (self.capturingTeam > 0) then
				local capturingTeam = mrtsTeams[self.capturingTeam]
				surface.SetDrawColor(capturingTeam.color.r, capturingTeam.color.g, capturingTeam.color.b, 150)
				local s = math.floor((size-width)*self.capture/2)*2
				surface.DrawRect( -s/2, -s/2, s, s, math.min(s, width))
				-- outline color
			end

			if (self.team > 0) then
				local capturingTeam = mrtsTeams[self.team]
				surface.SetDrawColor(capturingTeam.color.r, capturingTeam.color.g, capturingTeam.color.b, 255)
			else
				surface.SetDrawColor(255,255,255)
			end
			surface.DrawRect(-size/2, -size/2, size, width)--top
			surface.DrawRect(size/2-width, -size/2, width, size)--right
			surface.DrawRect(-size/2, size/2-width, size, width)--bottom
			surface.DrawRect(-size/2, -size/2, width, size)--left

			/*	
			-- capture
			if (zone.capturingTeam > 0) then
				local capturingTeam = mrtsTeams[zone.capturingTeam]
				surface.SetDrawColor(capturingTeam.color.r, capturingTeam.color.g, capturingTeam.color.b, 150)
				local s = math.floor((size-width)*percent/2)*2
				surface.DrawRect( -s/2, -s/2, s, s, math.min(s, width))
				-- outline color
			end
			*/
			/*
			-- outline
			if (zone.team > 0) then
				local team = mrtsTeams[zone.team]
				surface.SetDrawColor((team.color.r+8)*2, (team.color.g+8)*2, (team.color.b+8)*2, 255)
			else
				surface.SetDrawColor(255, 255, 255, 255)
			end
			*/
			/*
			-- +x: 1
			if (bit.band(neighbourMask, 1) == 0) then
				surface.DrawRect((-sizewidth)/2, (sizewidth)/2, -width, -sizewidth)
			end
			-- +y: 2
			if (bit.band(neighbourMask, 2) == 0) then
				surface.DrawRect((sizewidth)/2, (sizewidth)/2, -sizewidth, width)
			end
			-- -x: 4
			if (bit.band(neighbourMask, 4) == 0) then
				surface.DrawRect((sizewidth)/2, (sizewidth)/2, width, -sizewidth)
			end
			-- -y: 8
			if (bit.band(neighbourMask, 8) == 0) then
				surface.DrawRect((sizewidth)/2, (-sizewidth)/2, -sizewidth, -width)
			end
			*/
		end
	cam.End3D2D()
end