include('shared.lua')

local VECTOR_UP = Vector(0,0,1)
local computeLighting = false

function ENT:Initialize()
	self:SharedInit()

	self.aimUntil = 0 // Un timer para que se mantenga apuntando por un segundo luego de perder el objetivo
	self.lastHit = 0 // Usado para la animacion
	self.lastAttack = 0 // Usado para la animacion
	self.nextAttack = 0 // Usado para la animacion

	self.visible = true
	self.accessories = {}
	self.waypoints = {}

	--self:SetRenderBounds( Vector(-128, -128, -128), Vector(128, 128, 128))

	self.ClientMovementAngle = Angle(0,0,0)
	self.ClientAimingAngle = Angle(0,0,0)
	self.animOffset = CurTime()+math.random(0,1)
	self.selectable = true
	self.selected = false
	self.windingUp = false

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
/*
function ENT:ClientsideAttack()
	self.windingUp = false
	self.lastAttack = CurTime();
	if (unitData[self:GetUnitID()] != nil) then
		self.nextAttack = CurTime()+unitData[self:GetUnitID()].attack.delay;
	end
end

function ENT:ClientsideNextAttack(target)
	self.windingUp = true
	if (IsValid(target)) then
		local diff = target:GetPos()-self:GetPos()
		self.ClientDirectionAngle = diff:Angle().y
		self.nextAttack = CurTime()+unitData[self:GetUnitID()].attack.windup;
	end
end

function ENT:ClientsideCancelWindup()
	if (self.windingUp) then
		self.windingUp = false
	end
end
*/
/*
function ENT:OnRemove()
	if (self.underConstruction) then
		notification.AddLegacy( self:GetData().name.." destroyed during construction!", NOTIFY_ERROR, 5 )
	end
	self:SharedRemove()
end*/


function ENT:E()
	net.Start("MRTSCancelQueue")
		net.WriteEntity(self)
	net.SendToServer()
end

local moveFlagMaterial = Material("icon16/flag_green.png")
local cancelMaterial = Material("icon16/cancel.png")
local doorOpenMaterial = Material("icon16/door_out.png")
local doorMaterial = Material("icon16/door.png")

local MRTS_QUEUE_COLOR = Color(50, 50, 50)

local colormat = Material("color")
local limecolor = Color(0,255,0,255)
function ENT:Draw()
	if (!self.visible) then return end
	if (self.makesTroop and self.selected) then
		render.SetMaterial( colormat )
		local offset = Vector(0,0,5)
		render.DrawBeam( self:GetSpawnPos(), self:GetMovePos()+offset, 1, 0, 1, limecolor )
		for k, v in pairs(self.waypoints) do
			if (k != 1) then
				render.DrawBeam( self.waypoints[k-1]+offset, v+offset, 1, 0, 1, limecolor )
			else
				render.DrawBeam( self:GetMovePos()+offset, v+offset, 1, 0, 1, limecolor )
			end
		end
	end

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

	-- Debugging bounding box
	/*
	local size = Vector(self:GetData().size.x, self:GetData().size.y, self:GetData().size.z)
	render.DrawWireframeBox( self:GetCenter(),self:GetAngles(),-size,size,color_white,true)
	*/
	--

	-- Debugging target box
	/*
	render.DrawSphere(self:GetClosestPoint(self:GetCenter()+Vector(1000,1000,1000)), 3, 10, 10)
	render.DrawSphere(self:GetClosestPoint(self:GetCenter()+Vector(1000,1000,-1000)), 3, 10, 10)
	render.DrawSphere(self:GetClosestPoint(self:GetCenter()+Vector(1000,-1000,1000)), 3, 10, 10)
	render.DrawSphere(self:GetClosestPoint(self:GetCenter()+Vector(1000,-1000,-1000)), 3, 10, 10)
	render.DrawSphere(self:GetClosestPoint(self:GetCenter()+Vector(-1000,1000,1000)), 3, 10, 10)
	render.DrawSphere(self:GetClosestPoint(self:GetCenter()+Vector(-1000,1000,-1000)), 3, 10, 10)
	render.DrawSphere(self:GetClosestPoint(self:GetCenter()+Vector(-1000,-1000,1000)), 3, 10, 10)
	render.DrawSphere(self:GetClosestPoint(self:GetCenter()+Vector(-1000,-1000,-1000)), 3, 10, 10)
	*/

	render.SetColorModulation(1, 1, 1)

	if (self.selected) then
		-- Rally point
		if (self:GetData().makesTroop != nil) then
			local finalRallyPoint = self:GetMovePos()
			if (#self.waypoints > 0) then
				finalRallyPoint = self.waypoints[#self.waypoints]
			end
			if (self:GetBlocked()) then
				render.SetMaterial(doorMaterial)
				render.DrawSprite( self:GetSpawnPos(), 16, 16)
				render.SetMaterial(cancelMaterial)
				render.DrawSprite( finalRallyPoint, 16, 16)
			else
				render.SetMaterial(doorOpenMaterial)
				render.DrawSprite( self:GetSpawnPos(), 16, 16)
				render.SetMaterial(moveFlagMaterial)
				render.DrawSprite( finalRallyPoint, 16, 16)
			end
		end
	end

	-- Bars
	cam.IgnoreZ( true )
	local ang = (EyeVector():Angle()+Angle(-90,0,0))
	ang:RotateAroundAxis(EyeVector(),90)
	local buildingHeight = 20
	cam.Start3D2D( self:GetCenter()+Vector(0,0,self:GetData().barOffset or 0), ang, 0.5 )

		if (self:GetTeam() == mrtsTeam) then

			--render.PushFilterMag(TEXFILTER.POINT)
			local barWidth = math.floor(math.max(1,/*self:GetUnitMaxHealth()*/self:GetData().maxHealth/10))
			

			if (self:GetBlocked()) then
				surface.SetTextColor( 255, (1-CurTime()%1)*255, (1-CurTime()%1)*255, 255 )
				surface.SetFont("Trebuchet18")
				surface.SetTextPos(-35, 0)
				surface.DrawText("Exit blocked")
			end

			if (self.troopQueue > 0) then
				-- Current building unit
				local troopData = GetTroopByUniqueName(self:GetData().makesTroop.troop)
				local buildTime = self:GetData().makesTroop.time
				local buildPercent = math.Clamp((buildTime-self.nextSpawn+CurTime())/buildTime, 0, 1)
				
				local queuePosX = 0
				local queuePosY = -buildingHeight-32
				surface.SetTextColor( 255, 255, 255, 255 )
				surface.SetFont("Trebuchet24")
				
				local number = buildTime-(math.ceil((buildTime*buildPercent)*10)/10)
				if (number%1==0) then
					number = number..".0"
				end
				local str = number.."s"
				local textWidth = string.len(tostring(str))*10
				draw.RoundedBox(16, queuePosX-16, queuePosY-16, 52+textWidth, 32, MRTS_QUEUE_COLOR)
				draw.RoundedBox(28, queuePosX-28, queuePosY-28, 56, 56, MRTS_QUEUE_COLOR)
				MRTSDrawCircularProgressBar(queuePosX, queuePosY, 24, buildPercent)
				surface.SetTextPos(queuePosX+32, queuePosY-12)
				draw.RoundedBox(16, queuePosX-16, queuePosY-16, 32, 32, MRTS_QUEUE_COLOR)
				surface.DrawText(str)

				MRTSDrawIcon(troopData.icon, queuePosX, queuePosY, 16, 16)
				queuePosY = queuePosY-36

				local waitingQueue = self.troopQueue-1
				if (waitingQueue > 0) then
					for i=1, waitingQueue do
						draw.RoundedBox(16, queuePosX-16, queuePosY-16, 32, 32, MRTS_QUEUE_COLOR)
						MRTSDrawIcon(troopData.icon, queuePosX, queuePosY, 16, 16)
						queuePosY = queuePosY-16
					end
				end

				/*
				surface.SetDrawColor(0,0,0)
				surface.DrawRect( -barWidth/2-1, -3-buildingHeight, barWidth+2, 3 )
				surface.SetDrawColor(200,50,255)
				surface.DrawRect( -barWidth/2, -2-buildingHeight, math.max(1,barWidth*buildPercent), 1 )

				-- Queue length indicator
				local waitingQueue = self.troopQueue-1
				if (waitingQueue > 0) then
					for i=1, waitingQueue do
						local x = (i-1)%8+1
						local y = math.floor((i-1)/8)
						surface.SetDrawColor(0,0,0)
						surface.DrawRect( -barWidth/2+x*2-3+0.5, -buildingHeight+y*2-1, 3, 3 )
						surface.SetDrawColor(200,50,255)
						surface.DrawRect( -barWidth/2+x*2-2+0.5, -buildingHeight+y*2, 1, 1 )
					end
				end*/
			end

			if (self.selected) then
				-- Healthbar
				surface.SetDrawColor(0,0,0)
				surface.DrawRect( -barWidth/2-2, -5-buildingHeight, barWidth+4, 9 )
				local percent = self:GetUnitHealth()/self:GetData().maxHealth--self:GetUnitMaxHealth()
				surface.SetDrawColor(PercentToHealthbarColor(percent))
				surface.DrawRect( -barWidth/2, -3-buildingHeight, math.max(1,barWidth*percent), 5 )
			end
		end
	cam.End3D2D()
	cam.IgnoreZ( false )

	cam.Start3D2D( self:GetCenter()+Vector(0,0,self:GetData().barOffset or 0), ang, 0.5 )
		-- Status
		if (self.status != nil) then
			local offset = 13
			for k, v in pairs(self.status) do
				local status = mrtsGameData.status[k]
				MRTSDrawIcon(status.icon, 0, -buildingHeight-offset, 8, 8)
				offset = offset-8
			end
		end
	cam.End3D2D()
end

function ENT:GetData()
	local selfTable = self:GetTable()
	if (not selfTable.data) then
		selfTable.data = mrtsGameData.buildings[self:GetUnitID()]
	end
	return selfTable.data
end

function ENT:ClientsideNextTroopInQueue()
	self.troopQueue = self.troopQueue-1
	if (self.troopQueue > 0) then
		local troopData = GetTroopByUniqueName(self:GetData().makesTroop.troop)
		self.nextSpawn = CurTime()+self:GetData().makesTroop.time
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

	if (not GetConVar("mrts_playing"):GetBool()) then return end
	if (self:GetData().makesTroop != nil) then
		troopID = GetTroopID(self:GetData().makesTroop.troop)
		self:RequestTroop(troopID)
	end
	if (self:GetData().makesContraptions != nil) then
		if (self:GetNWString("contraptionName", "") == "") then
			self:OpenContraptionDialog()
		else
			self:RequestContraption()
		end
	end
	if (self:GetData().activation) then
		self:RequestActivation()
	end
end

function ENT:RequestTroop()
	if (self:GetUnderConstruction()) then return end
	local troopData = GetTroopByUniqueName(self:GetData().makesTroop.troop)
	local sandbox = GetConVar("mrts_sandbox_mode"):GetBool()
	if (not sandbox) then
		for k, v in pairs(self:GetData().makesTroop.cost) do
			if (mrtsTeams[self:GetTeam()].resources[k].current == nil or mrtsTeams[self:GetTeam()].resources[k].current < v) then
				return false
			end
		end
	end
	
	local maxHousing = mrtsTeams[self:GetTeam()].usedHousing
	if (sandbox) then
		maxHousing = 100
	end
	if (mrtsTeams[self:GetTeam()].maxHousing < mrtsTeams[self:GetTeam()].usedHousing+troopData.population) then
		return false
	end
	
	surface.PlaySound("buttons/lightswitch2.wav")

	net.Start("MRTSQueueTroop")
		net.WriteEntity(self)
	net.SendToServer()
	return true
end

function ENT:OpenContraptionDialog()
	if (self:GetUnderConstruction()) then return end
		
	surface.PlaySound("buttons/lightswitch2.wav")
	MRTSLoadContraptionDialog(self)

	return true
end

function ENT:SendContraption(str, data)
	if (self:GetUnderConstruction()) then return end
	MRTSSendBigString(str, {purpose="LoadContraptionOntoAssembler", assembler=self, name=data.name}, LocalPlayer())
	return true
end

function ENT:RequestContraption()
	surface.PlaySound("buttons/lightswitch2.wav")

	net.Start("MRTSQueueContraption")
		net.WriteEntity(self)
	net.SendToServer()

	return true
end

function ENT:RequestActivation()
	surface.PlaySound("buttons/lightswitch2.wav")
	net.Start("MRTSRequestActivation")
		net.WriteEntity(self)
	net.SendToServer()
end

function ENT:RequestBuilding(buildingID, pos)
	net.Start("MRTSQueueBuilding")
		net.WriteEntity(self)
		net.WriteInt(buildingID, 8)
		net.WriteVector(pos)
	net.SendToServer()
end
/*
function ENT:RequestCancel(troopID, positionInQueue)
	net.Start("MRTSCancelTroop")
		net.WriteEntity(self)
	net.SendToServer()
end
*/