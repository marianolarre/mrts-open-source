include('shared.lua')

function ENT:CalculateAccesorieAngles(spdSqr, moving)
	if (IsValid(self:GetTarget())) then
		local diff = self:GetTargetPosition(self:GetTarget())-self:GetFiringOrigin(false)
		self.ClientAimingAngle = diff:Angle()
	else
		self.ClientAimingAngle = self:GetAngles()
	end
end

function ENT:GetData()
	local selfTable = self:GetTable()
	if (not selfTable.data) then
		selfTable.data = mrtsGameData.parts[self:GetUnitID()]
	end
	return selfTable.data
end