include('shared.lua')

local VECTOR_UP = Vector(0,0,1)
local computeLighting = false
local SETUP_BAR_COLOR = Color(255,0,255)
local CHARGE_BAR_COLOR = Color(0,255,255)

function ENT:Initialize()
	self:SharedInit()

	self.aimUntil = CurTime() // Un timer para que se mantenga apuntando por un segundo luego de perder el objetivo
	self.lastHit = CurTime() // Usado para la animacion
	self.lastAttack = CurTime() // Usado para la animacion
	self.nextAttack = CurTime() // Usado para la animacion

	self.ClientMovementAngle = Angle(0,0,0)
	self.ClientAimingAngle = Angle(0,0,0)
	self.animOffset = CurTime()+math.random(0,1)
	self.selectable = true
	self.selected = false
	self.settingUp = false
	self.windingUp = false

	self.visible = true
	self.accessories = {}

	self.lastMove = CurTime()
	self.waypoints = {}
	
	if (not self:GetUnderConstruction()) then
		if (self:GetData().accessories) then
			self:CreateAccessories()
		end
	end

	local data = self:GetData()
	if (data.scale or data.modelOffset != nil) then
		local mat = Matrix()
		if (data.scale != nil) then
			local scale = Vector(data.scale.x, data.scale.y, data.scale.z)
			mat:Scale(scale)
		end
		if (data.modelOffset != nil) then
			local modelOffset = Vector(data.modelOffset.x, data.modelOffset.y, data.modelOffset.z)
			mat:Translate(modelOffset)
		end
		self:EnableMatrix("RenderMultiply", mat)
	end

	table.insert(mrtsUnits, self)
end

function ENT:GetData()
	local selfTable = self:GetTable()
	if (not selfTable.data) then
		selfTable.data = mrtsGameData.troops[self:GetUnitID()]
	end
	return selfTable.data
end

function ENT:ClientsideHit()
	self.lastHit = CurTime();
	if (self:GetTeam() == mrtsTeam) then
		if (self:GetData().objective) then
			MRTSNotifyHQHit(self:GetCenter());
		else
			MRTSNotifyCombat(self:GetCenter());
		end
	end
end

function ENT:ClientsideAttack()
	self.windingUp = false
	self.lastAttack = CurTime();
	if (self:GetData() != nil) then
		self.nextAttack = CurTime()+(self:GetData().attack.delay or 1);
	end
	if (self:GetTeam() == mrtsTeam) then
		MRTSNotifyCombat(self:GetCenter());
	end
end

function ENT:ClientsideStopMoving()
	self.lastMove = CurTime();
	self.isMoving = false
end

function ENT:ClientsideNextAttack(target)
	self.windingUp = true
	if (IsValid(target)) then
		local diff = target:GetPos()-self:GetPos()
		self.ClientAimingAngle = diff:Angle()
		self.nextAttack = CurTime()+self:GetData().attack.windup;
	end
end

function ENT:ClientsideCancelWindup()
	if (self.windingUp) then
		self.windingUp = false
	end
end

function ENT:Interact(ply)
	if (self:GetUnderConstruction()) then return end
	if (self:GetClaimable()) then
		net.Start("MRTSClaimUnit")
			net.WriteEntity(self)
			net.WriteInt(mrtsTeam, 8)
		net.SendToServer()
		return
	end
end

local colormat = Material( "color" )
local limecolor = Color(0,255,0,255)
function ENT:Draw()
	if (!self.visible) then return end
	if (self.isMoving and self.selected) then
		render.SetMaterial( colormat )
		local offset = Vector(0,0,5)
		render.DrawBeam( self:GetPos(), self:GetMovePos()+offset, 1, 0, 1, limecolor )
		for k, v in pairs(self.waypoints) do
			if (k != 1) then
				render.DrawBeam( self.waypoints[k-1]+offset, v+offset, 1, 0, 1, limecolor )
			else
				render.DrawBeam( self:GetMovePos()+offset, v+offset, 1, 0, 1, limecolor )
			end
		end
	end
		
	--render.DrawBeam( Vector1, Vector2, 5, 1, 1, Color( 255, 255, 255, 255 ) ) 

	local hitEffect = math.max(0,self.lastHit-CurTime()+0.15);

	if (hitEffect > 0) then
		local mod = hitEffect*2
		local col = self:GetColor()
		render.SetColorModulation(col.r/255+mod, col.g/255+mod, col.b/255+mod)
	end
	self:DrawModel()
	if (not self:GetUnderConstruction()) then
		self:HandleAccessories()
	end
	render.SetColorModulation(1, 1, 1)

	local ang = (EyeVector():Angle()+Angle(-90,0,0))
	ang:RotateAroundAxis(EyeVector(),90)
	local data = self:GetData()
	
	cam.Start3D2D( self:GetPos() + Vector(0, 0, data.barOffset or 0), ang, 1 )

	local troopSize = data.size
	if (self.selected) then
		-- Healthbar
		local barWidth = math.floor(math.min(5,math.max(1,/*self:GetUnitMaxHealth()*/self:GetData().maxHealth/20)))*5
		local barHeight = 2

		surface.SetDrawColor(0,0,0)
		surface.DrawRect( -barWidth/2-1, -3-troopSize-barHeight, barWidth+2, barHeight+2 )
		local percent = self:GetUnitHealth()/self:GetData().maxHealth--self:GetUnitMaxHealth()
		surface.SetDrawColor(PercentToHealthbarColor(percent))
		surface.DrawRect( -barWidth/2, -2-troopSize-barHeight, math.max(1,barWidth*percent), barHeight )
	end

	-- Status
	if (self.status != nil) then
		local offset = 13
		for k, v in pairs(self.status) do
			local status = mrtsGameData.status[k]
			MRTSDrawIcon(status.icon, 0, -troopSize-offset, 8, 8)
			offset = offset+8
		end
	end

	-- Setup
	if (data.attack) then
		local setup = data.attack.setup or 0
		local offset = -3
		if (data.charge) then
			offset = offset-2
		end
		if (setup > 0) then
			local moving = self:GetVelocity():LengthSqr() > 100
			local percent = (CurTime()-self.lastMove)/setup
			if (moving) then
				percent = 0
			end
			if (moving or (CurTime()-self.lastMove) < setup) then
				local barWidth = 9--setup*3
				local barHeight = 1

				surface.SetDrawColor(0,0,0)
				surface.DrawRect( -barWidth/2-1, offset-1-troopSize-barHeight*2-1, barWidth+2, barHeight+2 )
				
				surface.SetDrawColor(SETUP_BAR_COLOR)
				surface.DrawRect( -barWidth/2, offset-troopSize-barHeight*2-1, math.max(1,barWidth*percent), barHeight )
			end
		end
	end

	-- Charge
	if (data.charge and not data.charge.hideBar) then
		local percent = self:GetUnitCharge()/data.charge.max
		local barWidth = 9
		local barHeight = 1

		surface.SetDrawColor(0,0,0)
		surface.DrawRect( -barWidth/2-1, -4-troopSize-barHeight*2-1, barWidth+2, barHeight+2 )
		
		surface.SetDrawColor(CHARGE_BAR_COLOR)
		surface.DrawRect( -barWidth/2, -3-troopSize-barHeight*2-1, math.max(1,barWidth*percent), barHeight )
	end
	cam.End3D2D()
end
