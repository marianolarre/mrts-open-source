AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include('shared.lua')

function ENT:Initialize()
	self:SharedInit()

	self:SetSize(175)
	
	self:SetMoveType( MOVETYPE_NONE )
	self:DrawShadow(false)

	local points = {}

	local faces = 16
	local radius = self:GetSize()/2
	local height = 150
	for i=1, faces do
		table.insert(points, Vector( math.cos(i*math.pi*2/faces)*radius, math.sin(i*math.pi*2/faces)*radius, 0 ))
		table.insert(points, Vector( math.cos(i*math.pi*2/faces)*radius, math.sin(i*math.pi*2/faces)*radius, height ))
	end	

	self:PhysicsInitConvex( points )

	self:SetSolid( SOLID_VPHYSICS )
	self:EnableCustomCollisions( true )

	self:SetCollisionGroup(COLLISION_GROUP_VEHICLE)
	self:SetTrigger( true )

	if (self:CreatedByMap()) then
		self.mrtsPartOfTheMap = true
	end
end

function ENT:StartTouch(unit)
	if (unit:GetClass() == "ent_mrts_troop") then
		if (self.capturingTeam == 0) then
			self.capturingTeam = unit:GetTeam()
		end

		if (not table.HasValue(self.units, unit)) then
			self.captureSpeed[unit:GetTeam()] = (self.captureSpeed[unit:GetTeam()] or 0) + (unit:GetData().captureSpeed or 0)
			MRTSUpdateCaptureZone(self)
		end
		table.insert(self.units, unit)
	end
end

function ENT:EndTouch(unit)
	if (unit:GetClass() == "ent_mrts_troop") then
		table.RemoveByValue(self.units, unit)
		if (not table.HasValue(self.units, unit)) then
			self.captureSpeed[unit:GetTeam()] = (self.captureSpeed[unit:GetTeam()] or 0) - (unit:GetData().captureSpeed or 0)
			MRTSUpdateCaptureZone(self)
		end
	end
end

function ENT:ChangeTeam(newTeam)
	local size = Vector(self:GetSize()/2+100, self:GetSize()/2+100, 100)
	local buildings = ents.FindInBox(-size+self:GetPos(), size+self:GetPos())
	for k, v in pairs(buildings) do
		local vTable = v:GetTable()
		if (vTable.isMRTSUnit) then
			if (vTable.GetCapturable(v)) then
				vTable.CancelFullQueue(v)
				vTable.ChangeTeam(v, newTeam)
			end
		end
	end
end