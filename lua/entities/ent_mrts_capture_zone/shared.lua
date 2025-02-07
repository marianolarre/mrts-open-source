ENT.Type = "anim"
//ENT.Base = "base_gmodentity"

ENT.Category = "MarumsRTS"

ENT.PrintName= "MarumRTS capture zone"
ENT.Author= "Marum"
ENT.Contact= "don`t"
ENT.Purpose= "Play"
ENT.Instructions= "You shouldnt be able to just spawn this"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Editable = false

local captureZoneThinkTime = 0.2

function ENT:SetupDataTables()
	/*self:NetworkVar( "Int", 0, "ZoneID")
	self:NetworkVar( "Int", 1, "NeighbourMask")*/
	self:NetworkVar( "Int", 0, "Size")
end

function ENT:SharedInit()
	self.units = {};
	self.capture = 0;
	self.captureSpeed = {};
	for k, v in pairs(mrtsTeams) do
		self.captureSpeed[k] = 0
	end
	self.contested = false;
	self.capturingTeam = 0;
	self.team = -1;
	self.isCaptured = false;

	self.nextThink = 0

	self:DrawShadow(false)

	self.ready = true
end

function ENT:Think()

	if (not self.ready) then return end

	if (CurTime() < self.nextThink) then return end

	if (not self.contested) then
		if (self.capturingTeam != 0) then
			-- Calculate capture speed
			local positiveCapturing = self.captureSpeed[self.capturingTeam]
			local negativeCapturing = 0
			local strongestOpposingTeam = 0
			local strongestDecapture = 0
			for k, v in pairs(self.captureSpeed) do
				if (k != self.capturingTeam) then
					if (v > strongestDecapture) then
						strongestOpposingTeam = k
						strongestDecapture = v
					end
					negativeCapturing = negativeCapturing + v
				end
			end
			local totalCaptureSpeed = positiveCapturing - negativeCapturing
			local tickInterval = 1/captureZoneThinkTime
			self.capture = self.capture+totalCaptureSpeed*tickInterval/100
			self.capture = math.Clamp(self.capture, 0, 1)
			if (not self.isCaptured) then
				if (totalCaptureSpeed > 0 and self.capture >= 1) then
					-- Finished capture
					self.capture = 1
					self.team = self.capturingTeam
					self.isCaptured = true
					if (SERVER) then
						self:ChangeTeam(self.capturingTeam)
					end
				end
			end
			if (totalCaptureSpeed < 0 and self.capture <= 0) then
				-- Finished uncapture
				self.capture = 0
				self.team = 0
				self.capturingTeam = strongestOpposingTeam
				self.isCaptured = false
				if (SERVER) then
					self:ChangeTeam(0)
				end
			end
		end
	end
	if (CLIENT) then
		self.nextThink = CurTime()+captureZoneThinkTime
	end
	if (SERVER) then
		self:NextThink(CurTime()+captureZoneThinkTime)
		return true
	end
end