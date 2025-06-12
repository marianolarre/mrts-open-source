include('shared.lua')

local VECTOR_UP = Vector(0,0,1)
local computeLighting = false

function ENT:Initialize()
	self:SharedInit()

	self.aimUntil = 0 // Un timer para que se mantenga apuntando por un segundo luego de perder el objetivo
	self.lastHit = 0 // Usado para la animacion
	self.lastAttack = 0 // Usado para la animacion
	self.nextAttack = 0 // Usado para la animacion

	self.ClientMovementAngle = Angle(0,0,0)
	self.ClientAimingAngle = Angle(0,0,0)
	self.animOffset = CurTime()+math.random(0,1)
	self.selectable = true
	self.selected = false
	self.windingUp = false
	self.visible = true

	self.waypoints = {}

	table.insert(mrtsUnits, self)
end

function ENT:ClientsideHit()
	self.lastHit = CurTime();
	if (self:GetTeam() == mrtsTeam) then
		MRTSNotifyCombat(self:GetCenter());
	end
end

function ENT:ClientsideAttack()
	self.windingUp = false
	self.lastAttack = CurTime();
	if (self:GetData() != nil) then
		self.nextAttack = CurTime()+self:GetData().attack.delay;
	end
	if (self:GetTeam() == mrtsTeam) then
		if (self:GetData().attack.damage) then
			MRTSNotifyCombat(self:GetCenter());
		end
	end
end

function ENT:ClientsideNextAttack(target)
	self.windingUp = true
	if (IsValid(target) and self:GetData()) then
		local diff = target:GetPos()-self:GetPos()
		self.ClientAimingAngle = diff:Angle().y
		self.nextAttack = CurTime()+self:GetData().attack.windup;
	end
end

function ENT:ClientsideCancelWindup()
	if (self.windingUp) then
		self.windingUp = false
	end
end

function ENT:Think()
	if (self:IsFOWVisibleToTeam(mrtsTeam)) then
		self:SetVisible(true)
	else
		self:SetVisible(false)
	end
	return true
end

function ENT:OnRemove()
	self:SharedRemove()
	table.RemoveByValue(mrtsUnits, self)
	if (istable(self.accessories)) then
		for k, accessory in pairs(self.accessories) do
			if (IsValid(accessory)) then
				accessory:Remove()
			end
		end
	end
end

function ENT:CreateAccessories()
	local data = self:GetData()
	if (data.accessories != nil) then
		local accessories = data.accessories

		for k, accessory in pairs(accessories) do
			self.accessories[k] = ents.CreateClientProp()
			self.accessories[k]:SetModel(accessory.model)

			if (accessory.material) then
				self.accessories[k]:SetMaterial(accessory.material)
			end

			if (accessory.tint) then
				self.accessories[k]:SetColor(mrtsTeams[self:GetTeam()].color)
			end
			
			local mat = Matrix()
			if (accessory.scale != nil) then
				local scale = Vector(accessory.scale.x, accessory.scale.y, accessory.scale.z)
				mat:Scale(scale)
			end
			self.accessories[k]:EnableMatrix("RenderMultiply", mat)
			self.accessories[k]:SetParent(self)

			if (accessory.fixed) then
				--Final position
				local ang = Angle(accessory.rotation.x, accessory.rotation.y, accessory.rotation.z)
				self.accessories[k]:SetAngles(self:GetAngles() + ang)
				local parentOffset = self:GetData().offset or {x=0,y=0,z=0}
				local vec = Vector(
					accessory.offset.x+parentOffset.x,
					accessory.offset.y+parentOffset.y,
					accessory.offset.z+parentOffset.y
				)
				self.accessories[k]:SetLocalPos(vec)
			else
				local ang = Angle(accessory.idle.rotation.x, accessory.idle.rotation.y, accessory.idle.rotation.z)
				self.accessories[k]:SetAngles(self:GetAngles() + ang)
				local parentOffset = self:GetData().offset or {x=0,y=0,z=0}
				local vec = Vector(
					accessory.idle.offset.x+parentOffset.x,
					accessory.idle.offset.y+parentOffset.y,
					accessory.idle.offset.z+parentOffset.y
				)
				self.accessories[k]:SetLocalPos(vec)
			end

			self.accessories[k]:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			self.accessories[k]:SetMoveType(MOVETYPE_NONE)
			self.accessories[k]:DrawShadow(false)
			self.accessories[k]:Spawn()

			self.accessories[k]:SetNoDraw(!self:IsFOWVisibleToTeam(mrtsTeam))
		end

		self:HandleAccessories()
	end
end

function ENT:CalculateAccesorieAngles(spdSqr, moving)
	if (IsValid(self:GetTarget())) then
		local diff = self:GetTargetPosition(self:GetTarget())-self:GetFiringOrigin(false)
		self.ClientAimingAngle = diff:Angle()
	end
	if (moving) then
		self.ClientMovementAngle = LerpAngle(math.min(0.25, spdSqr/8182), self.ClientMovementAngle, Angle(0,self:GetVelocity():Angle().y,0))
		if (not IsValid(self:GetTarget())) then
			self.ClientAimingAngle = self.ClientMovementAngle
		end
	end
end

function ENT:SetVisible(visible)
	if (visible == self.visible) then return end
	self:DrawShadow(visible)
	if (!visible) then
		self:DestroyShadow()
	else
		if (!self:IsAlliedToTeamID(mrtsTeam)) then
			MRTSNotifySighting(self:GetCenter())
		end
	end
	if (istable(self.accessories)) then
		for k, accessory in pairs(self.accessories) do
			accessory:SetNoDraw(!visible)
		end
	end
	self.visible = visible
end

function ENT:HandleAccessories()
	-- Look forward
	if (self == nil) then return false end
	local selfTable = self:GetTable()
	local spd = self:GetData().speed or 20
	local spdSqr = spd*spd
	local moving = self:GetVelocity():LengthSqr() > spdSqr/2
	self:CalculateAccesorieAngles(spdSqr, moving)

	local accessories = self:GetData().accessories
	if (istable(accessories)) then
		for k, accessory in pairs(accessories) do
			-- Animate
			if (not accessory.fixed and selfTable.accessories[k]) then
				local idleRotation = accessory.idle.rotation or {x=0,y=0,z=0}
				local idleRotationAngle = Angle(idleRotation.x, idleRotation.y, idleRotation.z)
				local idleOffset = accessory.idle.offset or {x=0,y=0,z=0}
				local idleOffsetVector = Vector(idleOffset.x, idleOffset.y, idleOffset.z)

				local totalRotation = idleRotationAngle
				local totalOffset = idleOffsetVector

				if (accessory.spin) then
					totalRotation = totalRotation + Angle(accessory.spin.x, accessory.spin.y, accessory.spin.z)*CurTime()
				end

				if (accessory.attack != nil and accessory.attack != nil) then
					local attackRotation = accessory.attack.rotation or {x=0,y=0,z=0}
					local attackRotationAngle = Angle(attackRotation.x, attackRotation.y, attackRotation.z)
					local attackOffset = accessory.attack.offset or {x=0,y=0,z=0}
					local attackOffsetVector = Vector(attackOffset.x, attackOffset.y, attackOffset.z)

					local lerp = math.max(0,selfTable.lastAttack-CurTime()+self:GetData().attack.delay) --Real lerp
					--local lerp = 1-(CurTime()/self:GetData().attack.delay)%1 --Test lerp
					totalRotation = LerpAngle(lerp, idleRotationAngle, attackRotationAngle)
					totalOffset = LerpVector(lerp, idleOffsetVector, attackOffsetVector)
				end

				-- Setup Animation
				local attack = self:GetData().attack
				if (attack != nil and (attack.setup or 0) > 0 and accessory.setup) then
					local percent = (CurTime()-selfTable.lastMove)/attack.setup
					if (moving) then
						percent = 0
					end
					if (percent < 1) then
						local setupRotation = accessory.setup.rotation or {x=0,y=0,z=0}
						local setupRotationAngle = Angle(setupRotation.x, setupRotation.y, setupRotation.z)
						local setupOffset = accessory.setup.offset or {x=0,y=0,z=0}
						local setupOffsetVector = Vector(setupOffset.x, setupOffset.y, setupOffset.z)

						local lerp = math.max(0,percent)
						totalRotation = LerpAngle(lerp, setupRotationAngle, idleRotationAngle)
						totalOffset = LerpVector(lerp, setupOffsetVector, idleOffsetVector)
					end
				end
				
				local angles = Angle(selfTable.ClientMovementAngle)
				
				if (/*IsValid(self:GetTarget()) and */not accessory.lookForward) then
					angles = Angle(selfTable.ClientAimingAngle)
				end

				if (accessory.backpack or accessory.lookForward) then
					angles.x = 0
					angles.z = 0
				end

				angles:RotateAroundAxis(angles:Forward(), totalRotation.x)
				angles:RotateAroundAxis(angles:Right(), totalRotation.y)
				angles:RotateAroundAxis(angles:Up(), totalRotation.z)

				if (selfTable.accessories) then
					if (IsValid(selfTable.accessories[k])) then
						selfTable.accessories[k]:SetAngles(angles)
					
						totalOffset:Rotate(angles)

						if (accessory.pivot) then
							local pivotOffset = Vector(accessory.pivot.x, accessory.pivot.y, accessory.pivot.z)
							pivotOffset:Rotate(self:GetAngles())
							totalOffset = totalOffset + pivotOffset
						end

						selfTable.accessories[k]:SetPos(self:GetPos() + totalOffset)
					end
				end
			end
		end
	end
end

function ENT:IsAlliedToTeamID(other)
	if (other == self:GetTeam()) then return true end
	if (mrtsTeams[self:GetTeam()].alliances[other]) then return true end
	return false
end

function ENT:IsAllied(other)
	if (other:GetTeam() == self:GetTeam()) then return true end
	if (mrtsTeams[self:GetTeam()].alliances[other:GetTeam()]) then return true end
	return false
end

function ENT:ReceiveWaypoints(waypoints)
	self.isMoving = true
	self.waypoints = waypoints
end