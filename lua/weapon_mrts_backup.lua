SWEP.PrintName = "MarumRTS controller backup"

SWEP.Slot = 5
SWEP.SlotPos = 3

SWEP.DrawAmmo = false

SWEP.DrawCrosshair = true

SWEP.Spawnable = true
SWEP.AdminSpawnable = false

SWEP.HoldType = "magic" // so it looks like telekinesis
SWEP.UseHands = false
SWEP.ViewModel = ""

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo	= "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo	= "none"

local selectionStartingPoint
local selectionEndingPoint
local selecting
local orderPoint
local orderTimer
local lastClick = 0
local orderedAttackMove = false

local selectedUnit = 1
local mrtsPlacingUnitID = 0

local helpPanel = nil

local mrtsMainSheet = nil

local plainMaterial = Material( "color" )

mrtsDrawRings = false
mrtsGameMenu = nil
mrtsCurrentMenuTab = ""
mrtsCurrentMapEditorMenuTab = ""
mrtsPreviewBox = nil
local buildingMenuOpen = false
local menuEntity = nil
local menuScale = 0
local buildingMenuOpenTime = 0
local currentMenuTab = 1
local currentMapEditorTab = 1
local maxQueue = 10

local preview = nil

local STAGE_MAIN = 0
local STAGE_PLACING_BUILDING = 1
local STAGE_PLACING_TROOP = 2
local STAGE_PLACING_PART = 3
local STAGE_DELETING = 4
local STAGE_PLACING_BOUND_PLANE = 11
local STAGE_PLACING_CAPTURE_ZONE = 12
local STAGE_PLACING_SURVIVAL_HQ = 13
local STAGE_PLACING_BOUND_POLE = 14
local STAGE_SAVING_CONTRAPTION = 20
local STAGE_LOADING_CONTRAPTION = 21
local STAGE_DEBUG_ANALIZE_CONTRAPTION = 100
local adminAction = false
local placingCapturable = false
local placingClaimable = false

local MRTS_GRAY = Color(50,50,50)
local MRTS_TROOP_BUTTON_COLOR = Color(80,80,80)
local MRTS_TROOP_BUTTON_COLOR_ADMIN_ONLY = Color(100,80,40)
local MRTS_TROOP_BUTTON_HOVER_COLOR = Color(110,110,110)
local MRTS_DARK_COLOR = Color(20, 20, 20)
local color_black = Color(0, 0, 0)
local CAN_PLACE_COLOR = Color(0, 255, 0)
local CAN_NOT_PLACE_COLOR = Color(255, 0, 0)
local outline_color = Color(0,0,0,150)
local outline_width = 1

local angleSnap = 15

SWEP.stage = STAGE_MAIN
SWEP.menuframe = nil
SWEP.button_reload = false
SWEP.button_use= false

SWEP.iconButtons = {}

SWEP.lastSelectionTime = 0
SWEP.lastSelectedUnit = -1

SWEP.unit = 0
SWEP.prop = 0

SWEP.selectedTab = nil
SWEP.selectedCategory = nil

SWEP.categorySheet = nil

if (CLIENT) then
	selectionStartingPoint = Vector(0,0,0)
	selectionEndingPoint = Vector(0,0,0)
	selecting = false;
	drawingMap = false

	orderPoint = Vector(0,0,0);
	orderTimer = 0

	mrtsSelectedUnits = {}
	LocalPlayer().mrtsBuildQueue = {}

	stage = STAGE_MAIN
	mrtsDrawRings = false
end

function GetNonUnitTrace()
	local tr = util.TraceLine( {
		start = EyePos(),
		endpos = EyePos() + LocalPlayer():GetAngles():Forward() * 10000,
		mask = MASK_WATER+MASK_SOLID,
		filter = function( ent )
			if ( ent:GetClass() == "prop_physics" or ent:IsWorld() ) then
				return true
			end
			return false
		end
	})
	return tr
end

local function GetUnitTrace()
	local tr = util.TraceLine( {
		start = EyePos(),
		endpos = EyePos() + LocalPlayer():GetAngles():Forward() * 10000,
		mask = MASK_WATER+MASK_SOLID,
		filter = function( ent )
			if ( ent:GetClass() == "ent_mrts_building" or ent:GetClass() == "ent_mrts_troop" or ent:GetClass() == "ent_mrts_part" ) then
				return true
			end
			return false
		end
	})
	return tr
end

function SWEP:Initialize()
	// other initialize code goes here
	self:SetHoldType( self.HoldType );
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

if CLIENT then

function SWEP:SetStage(stage)
	self.stage = stage
	adminAction = false
	mrtsPreviewBox = nil
	if (stage == STAGE_MAIN) then
		self:DeletePreview()
		mrtsDrawRings = false
		mrtsPlacingBuilding = false
		placingClaimable = false
		self:SetClickCooldown()
	elseif (stage == STAGE_PLACING_TROOP) then
		mrtsDrawRings = true
	elseif (stage == STAGE_PLACING_BUILDING) then
		mrtsDrawRings = true
	elseif (stage == STAGE_PLACING_CAPTURE_ZONE) then
		self:DeletePreview()
		adminAction = true
	elseif (stage == STAGE_PLACING_BOUND_PLANE) then
		self:DeletePreview()
		adminAction = true
	elseif (stage == STAGE_PLACING_BOUND_POLE) then
		self:DeletePreview()
		adminAction = true
	elseif (stage == STAGE_PLACING_SURVIVAL_HQ) then
		self:DeletePreview()
		adminAction = true
	elseif (stage == STAGE_DELETING) then
		self:DeletePreview()
	elseif (stage == STAGE_SAVING_CONTRAPTION) then
		self:DeletePreview()
	elseif (stage == STAGE_LOADING_CONTRAPTION) then
		self:DeletePreview()
	elseif (stage == STAGE_DEBUG_ANALIZE_CONTRAPTION) then
		self:DeletePreview()
	end
end

function SWEP:Holster()
	self:DeletePreview()
end

local mouseLogicPos
function SWEP:Think()	
	if (LocalPlayer():KeyDown(IN_RELOAD) and not self.button_reload and lastClick+0.05 < CurTime()) then
		if not game.SinglePlayer() and not IsFirstTimePredicted() then return end
		self:RButton()
		self.button_reload = true;
		self:SetClickCooldown()
	end
	if (not LocalPlayer():KeyDown(IN_RELOAD)) then
		if not game.SinglePlayer() and not IsFirstTimePredicted() then return end
		self.button_reload = false;
	end

	if (LocalPlayer():KeyDown(IN_USE) and not self.button_use) then
		if not game.SinglePlayer() and not IsFirstTimePredicted() then return end
		self:EButton()
		if (LocalPlayer():KeyDown(IN_SPEED)) then
			self:SprintE()
		end
		self.button_use = true;
		self:SetClickCooldown()
	end
	
	if (not GetConVar("mrts_playing"):GetBool() and not adminAction) then return end
	
	if (lastClick+0.05 < CurTime()) then
		if (self.stage == STAGE_MAIN) then // Selecting
			if (!selecting) then
				if (self:PrimaryPressed()) then
					selectionStartingPoint = GetNonUnitTrace().HitPos
					surface.PlaySound("common/talk.wav")
					selectionEndingPoint = selectionStartingPoint
					selecting = true
					self:SetClickCooldown()
				end
			else 
				selectionEndingPoint = GetNonUnitTrace().HitPos
				if (!self:PrimaryHeld()) then
					surface.PlaySound("common/talk.wav")
					self:DoSelection(selectionStartingPoint, selectionEndingPoint)
					selecting = false
				end
			end

			if (self:SecondaryPressed()) then
				self:OrderSelectedUnits(orderPoint)
				self:SetClickCooldown()
			end

			if (LocalPlayer():KeyPressed(IN_DUCK)) then
				self:OrderStopSelectedUnits()
				self:CrouchButton()
				self:SetClickCooldown()
			end

		elseif (self.stage == STAGE_PLACING_TROOP) then // Placing troop
			local troopData = mrtsGameData.troops[mrtsPlacingUnitID]
			local troopSize = troopData.size
			local canPlace, pos = MRTSCanPlaceTroop(GetNonUnitTrace(), troopData, troopSize, mrtsTeam)

			local sandbox = adminAction or GetConVar("mrts_sandbox_mode"):GetBool()

			if (sandbox) then 
				canPlace = true
			end
			if (IsValid(self.preview)) then
				local offset = Vector(0,0,0)
				if (troopData.offset) then
					offset = Vector(troopData.offset.x, troopData.offset.y, troopData.offset.z)
				end
				self.preview:SetPos(pos+offset)
				self.preview:SetAngles(Angle(0,0,0))
				if (canPlace) then
					self.preview:SetColor(CAN_PLACE_COLOR)
				else
					self.preview:SetColor(CAN_NOT_PLACE_COLOR)
				end
			end
			if (self:PrimaryPressed()) then
				local checkForEnemies = MRTSGetEntitiesInRadius(pos, 150, mrtsTeam, true, true)
				if (checkForEnemies and not sandbox) then
					notification.AddLegacy( "Too close to enemies!" , NOTIFY_ERROR, 4 )
				else
					if (canPlace) then
						net.Start("MRTSSpawnTroop")
						net.WriteInt(mrtsTeam, 8)
						net.WriteInt(mrtsPlacingUnitID, 8)
						net.WriteVector(pos+VectorRand())
						net.WriteBool(sandbox)
						net.WriteBool(placingCapturable)
						net.WriteBool(placingClaimable)
						net.SendToServer()
					end
				end
				self:SetClickCooldown()
			end

			if (self:SecondaryPressed()) then
				self:SetStage(STAGE_MAIN)
			end

			if (LocalPlayer():KeyPressed(IN_DUCK)) then
				self:OrderStopSelectedUnits()
				self:CrouchButton()
				self:SetClickCooldown()
			end
		elseif (self.stage == STAGE_PLACING_PART) then // Placing part
			local partData = mrtsGameData.parts[mrtsPlacingUnitID]
			local partSize = partData.size
			local tr = GetNonUnitTrace()
			local canPlace, pos = MRTSCanPlacePart(tr, partData, partSize, mrtsTeam)

			/*if (adminAction) then 
				canPlace = true
			end*/
			if (IsValid(self.preview)) then
				local offset = Vector(0,0,0)
				if (partData.offset) then
					offset = Vector(partData.offset.x, partData.offset.y, partData.offset.z)
				end
				self.preview:SetPos(pos+offset)
				--self.preview:SetAngles(Angle(0,0,0))
				local angle = Angle(0, LocalPlayer():EyeAngles().yaw, 0)
				self.preview:SetAngles(angle)
				if (canPlace) then
					self.preview:SetColor(CAN_PLACE_COLOR)
				else
					self.preview:SetColor(CAN_NOT_PLACE_COLOR)
				end
			end
			if (self:PrimaryPressed()) then
				local checkForEnemies = MRTSGetEntitiesInRadius(pos, 150, mrtsTeam, true, true)
				if (checkForEnemies and not adminAction) then
					notification.AddLegacy( "Too close to enemies!" , NOTIFY_ERROR, 4 )
				else
					if (canPlace) then
						net.Start("MRTSSpawnPart")
						net.WriteInt(mrtsTeam, 8)
						net.WriteInt(mrtsPlacingUnitID, 8)
						net.WriteVector(pos+VectorRand())
						net.WriteBool(adminAction)
						net.WriteTable(tr)
						net.SendToServer()
					end
				end
				self:SetClickCooldown()
			end

			if (self:SecondaryPressed()) then
				self:SetStage(STAGE_MAIN)
			end

			if (LocalPlayer():KeyPressed(IN_DUCK)) then
				self:OrderStopSelectedUnits()
				self:CrouchButton()
				self:SetClickCooldown()
			end

		elseif (self.stage == STAGE_PLACING_BUILDING) then // Placing building
			local buildingData = mrtsGameData.buildings[mrtsPlacingUnitID]
			local sizeVector = Vector(buildingData.size.x, buildingData.size.y, buildingData.size.z)
			local offset = Vector(0,0,0)
			local direction=math.Round((LocalPlayer():LocalEyeAngles().y)/angleSnap)*angleSnap
			local angle = Angle(0,direction,0)
			
			if (buildingData.offset) then
				offset = Vector(buildingData.offset.x, buildingData.offset.y, buildingData.offset.z)
				offset:Rotate(angle)
			end
			if (buildingData.angle) then
				angle = angle + Angle(buildingData.angle.x, buildingData.angle.y, buildingData.angle.z)
			end
			

			local trace = GetNonUnitTrace()

			local box = {size=sizeVector, angle=Angle(angle.x, angle.y, angle.z), center=trace.HitPos}
			box = MRTSSanitizeBox(box)
			
			local canPlace, pos = MRTSCanPlaceBuilding(trace,buildingData,sizeVector,angle,mrtsTeam) -- Placeholder CanPlace

			--sizeVector:Rotate(angle)
			mrtsPreviewBox = {
				pos=pos+Vector(0,0,math.abs(box.size.z)),
				size=box.size,
				angle=box.angle
			}

			local sandbox = adminAction or GetConVar("mrts_sandbox_mode"):GetBool()

			if (sandbox) then 
				canPlace = true
			end

			if (IsValid(self.preview)) then
				self.preview:SetPos(pos+offset)
				self.preview:SetAngles(angle)
				if (canPlace) then
					self.preview:SetColor(CAN_PLACE_COLOR)
				else
					self.preview:SetColor(CAN_NOT_PLACE_COLOR)
				end
			end

			if (self:PrimaryPressed()) then
				local checkForEnemies = MRTSGetEntitiesInRadius(pos, 150, mrtsTeam, true, true)
				if (checkForEnemies and not sandbox) then
					notification.AddLegacy( "Too close to enemies!" , NOTIFY_ERROR, 4 )
				else
					if (canPlace) then
						net.Start("MRTSSpawnBuilding")
						net.WriteInt(mrtsTeam, 8)
						net.WriteInt(mrtsPlacingUnitID, 8)
						net.WriteVector(pos+offset)
						net.WriteAngle(angle)
						net.WriteBool(sandbox)
						net.WriteBool(placingCapturable)
						net.WriteBool(placingClaimable)
						net.WriteTable(trace)
						net.SendToServer()
					end
				end
				self:SetClickCooldown()
			end

			if (self:SecondaryPressed()) then
				self:SetStage(STAGE_MAIN)
			end

			if (LocalPlayer():KeyPressed(IN_DUCK)) then
				self:OrderStopSelectedUnits()
				self:CrouchButton()
				self:SetClickCooldown()
			end
		elseif (self.stage == STAGE_PLACING_CAPTURE_ZONE) then // Admin Placing Capture Zone
			local pos = GetNonUnitTrace().HitPos
			mrtsPreviewBox = {
				pos=pos,
				size=Vector(75,75,0.2),
				angle=Angle(0,0,0)
			}
			if (self:PrimaryPressed()) then
				net.Start("MRTSSpawnCaptureZone")
					net.WriteVector(pos)
				net.SendToServer()
				self:SetClickCooldown()
			end

			if (self:SecondaryPressed()) then
				self:SetStage(STAGE_MAIN)
			end
		elseif (self.stage == STAGE_PLACING_BOUND_PLANE) then // Admin Placing Bound Plane
			local pos = GetNonUnitTrace().HitPos
			mrtsPreviewBox = {
				pos=pos,
				size=Vector(20,20,0.2),
				angle=Angle(0,0,0)
			}
			if (self:PrimaryPressed()) then
				net.Start("MRTSSpawnBoundPlane")
					net.WriteVector(pos)
				net.SendToServer()
				self:SetClickCooldown()
			end

			if (self:SecondaryPressed()) then
				self:SetStage(STAGE_MAIN)
			end
		elseif (self.stage == STAGE_PLACING_BOUND_POLE) then // Admin Placing Bound Plane
			local pos = GetNonUnitTrace().HitPos
			mrtsPreviewBox = {
				pos=pos,
				size=Vector(2,2,15),
				angle=Angle(0,0,0)
			}
			if (self:PrimaryPressed()) then
				net.Start("MRTSSpawnBoundPole")
					net.WriteVector(pos)
				net.SendToServer()
				self:SetClickCooldown()
			end

			if (self:SecondaryPressed()) then
				self:SetStage(STAGE_MAIN)
			end
		elseif (self.stage == STAGE_PLACING_SURVIVAL_HQ) then // Admin Placing Survival HQ
			local pos = GetNonUnitTrace().HitPos
			mrtsPreviewBox = {
				pos=pos,
				size=Vector(300,300,0.2),
				angle=Angle(0,0,0)
			}
			if (self:PrimaryPressed()) then
				self:SetStage(STAGE_MAIN)
				net.Start("MRTSSpawnSurvivalHQ")
					net.WriteVector(pos)
				net.SendToServer()
				self:SetClickCooldown()
			end

			if (self:SecondaryPressed()) then
				self:SetStage(STAGE_MAIN)
			end
		elseif (self.stage == STAGE_DELETING) then
			if (self:PrimaryPressed()) then
				local eyeEntity = self:GetEyeEntity()
				if (IsValid(eyeEntity)) then
					if (eyeEntity:GetTeam() == mrtsTeam) then
						if (eyeEntity:GetUnderConstruction()) then
							net.Start("MRTSCancelEntity")
								net.WriteEntity(eyeEntity)
							net.SendToServer()
						else
							net.Start("MRTSDelete")
								net.WriteEntity(eyeEntity)
							net.SendToServer()
						end
						surface.PlaySound("buttons/button16.wav")
						self:SetClickCooldown()
					end
				end
			end

			if (self:SecondaryPressed()) then
				self:SetStage(STAGE_MAIN)
			end
		elseif (self.stage == STAGE_SAVING_CONTRAPTION) then
			if (self:PrimaryPressed()) then
				local tr = util.TraceLine( {
					start = EyePos(),
					endpos = EyePos() + LocalPlayer():GetAngles():Forward() * 10000,
					mask = MASK_WATER+MASK_SOLID,
					filter = LocalPlayer()
				})
				local entity = tr.Entity
				if (IsValid(entity)) then
					net.Start("MRTSSaveContraption")
						net.WriteEntity(entity)
					net.SendToServer()
				end
				self:SetClickCooldown()
			end

			if (self:SecondaryPressed()) then
				self:SetStage(STAGE_MAIN)
			end
		elseif (self.stage == STAGE_LOADING_CONTRAPTION) then
			if (self:PrimaryPressed()) then
				MRTSLoadContraption(mrtsSelectedContraptionName, LocalPlayer():GetEyeTrace().HitPos)
				self:SetClickCooldown()
			end

			if (self:SecondaryPressed()) then
				self:SetStage(STAGE_MAIN)
			end
		end

		if (not LocalPlayer():KeyDown(IN_USE)) then
			self.button_use = false;
		end
	end

	if (orderTimer > 0) then
		orderTimer = orderTimer - FrameTime();
	end
end

function SWEP:GetEyeEntity()
	local tr = GetUnitTrace()
	local entity = tr.Entity
	if (IsValid(entity)) then
		local entTable = entity:GetTable()
		if (entTable.isMRTSUnit) then
			if (entTable.GetTeam() == mrtsTeam or entTable.GetClaimable()) then
				return entity
			end
		end
	end
	return nil
end

function SWEP:EButton()
	local eyeEntity = self:GetEyeEntity()
	if (IsValid(eyeEntity)) then
		local entTable = eyeEntity:GetTable()
		if (entTable.isMRTSUnit) then
			entTable.Interact(eyeEntity, LocalPlayer())
		end
	end
end

function SWEP:CrouchButton()
	local eyeEntity = self:GetEyeEntity()
	if (IsValid(eyeEntity)) then
		local entTable = eyeEntity:GetTable()
		if (entTable.isMRTSUnit) then
			net.Start("MRTSCancelEntity")
				net.WriteEntity(eyeEntity)
			net.SendToServer()
			surface.PlaySound("buttons/button16.wav")
		end
	end
end

function SWEP:OpenBuildingMenu(entity)
	gui.EnableScreenClicker( true )
	buildingMenuOpen = true
	buildingMenuOpenTime = CurTime()
	menuScale = 0.01
	menuEntity = entity
	surface.PlaySound("weapons/smg1/switch_burst.wav")
end

function SWEP:DrawButton(x, y, w, h, text)
	local clicked = false
	local mouseOver = false
	if (gui.MouseX() > x and gui.MouseX() < x+w and
		gui.MouseY() > y and gui.MouseY() < y+h) then
		mouseOver = true
	end

	if (mouseOver) then
		surface.SetDrawColor(255,255,255)
		if (not self.mousePressed and input.IsMouseDown( MOUSE_LEFT )) then
			clicked = true
			self.mousePressed = true
		end
	else
		surface.SetDrawColor(180,180,180)
	end
	surface.DrawRect(x, y, w, h)
	draw.DrawText( text, "CloseCaption_Normal", x+w/2, y+h/2-14, Color(0, 0, 0, 255 ), TEXT_ALIGN_CENTER)
	return clicked
end

function MRTSDisplayUnitInfo(unit, x, y)
	local width = 250
	local height = 250
	local margin = 10
	surface.SetDrawColor(50, 50, 50, 240)
	surface.DrawRect(x, y-height/2, width, height)

	/*surface.SetFont("Trebuchet24")
	surface.SetTextColor(Color(255,255,255))
	surface.SetTextPos(x+margin, y-height/2+margin)
	surface.DrawText(unit.name)*/

	draw.SimpleTextOutlined( unit.name, "Trebuchet24", x+margin, y-height/2+margin, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outline_width, outline_color )

	MRTSDrawWrappingText(unit.description, x+margin, y-height/2+28+margin, width-margin*2)
end

function MRTSDrawWrappingText(text, x, y, width)
	//surface.SetFont("BudgetLabel")
	local words = string.Split(text, " ")
	local xoffset = 0
	local yoffset = 0
	for k, v in pairs(words) do
		local textWidth = string.len(tostring(v))*7+5
		if (xoffset+textWidth > width) then
			xoffset = 0
			yoffset = yoffset+18
		end
		/*surface.SetTextPos(x+xoffset, y+24+yoffset)
		surface.DrawText(v)*/

		draw.SimpleTextOutlined( v, "BudgetLabel", x+xoffset, y+24+yoffset, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outline_width, outline_color )
		
		xoffset = xoffset+textWidth
	end
end

function SWEP:CloseBuildingMenu()
	gui.EnableScreenClicker( false )
	if (buildingMenuOpen) then
		buildingMenuOpen = false
		surface.PlaySound("weapons/smg1/switch_single.wav")
	end
end

function SWEP:RButton()
	if (mrtsGameMenu != nil and mrtsGameMenu:IsVisible()) then
		self:CloseGameMenu()
	else
		self:OpenGameMenu()
	end
end

function SWEP:SetClickCooldown()
	lastClick = CurTime()+0.05
end

function SWEP:DoSelection(startingPos, endingPos)

	local center = (startingPos+endingPos)/2;
	local radius = (startingPos-endingPos):Length()/2

	local foundEntities = {}

	local foundTroops = false

	if (mrtsSelectedUnits != nil) then
		if (not LocalPlayer():KeyDown(IN_SPEED)) then
			for k, v in pairs(mrtsSelectedUnits) do
				v.selected = false
			end
			table.Empty(mrtsSelectedUnits)
		end
	else
		mrtsSelectedUnits = {}
	end
	if (radius > 10) then 
		table.Add(foundEntities, MRTSGetEntitiesInRadius(center, radius, mrtsTeam, false, false, nil, true))
	else
		local entity = GetUnitTrace().Entity
		local entTable = entity:GetTable()
		local selectedEntity = nil

		if (entTable.isMRTSUnit) then
			if (entTable.GetTeam() == mrtsTeam) then
				selectedEntity = entity
			end
		else
			selectedEntity = MRTSGetEntitiesInRadius(center, 20, mrtsTeam, false, true, nil, true)
		end

		// Double click Type selection
		if (selectedEntity != nil) then
			if (self.lastSelectionTime+0.25 > CurTime() and self.lastSelectedUnit == selectedEntity:GetData().uniqueName) then
				table.Add(foundEntities, MRTSGetEntitiesInRadius(center, 150, mrtsTeam, false, false, selectedEntity:GetData().uniqueName, true))
				self.lastSelectionTime = CurTime()-1
			else
				table.insert(foundEntities, selectedEntity)
				if (selectedEntity.isMRTSUnit) then
					self.lastSelectedUnit = selectedEntity:GetData().uniqueName
				end
			end
		else
			self.lastSelectedUnit = ""
			self.lastSelectionTime = CurTime()-1
		end

		self.lastSelectionTime = CurTime()
	end

	if (istable(foundEntities)) then
		for k, v in pairs(foundEntities) do
			if (not table.HasValue(mrtsSelectedUnits, v))then
				table.insert(mrtsSelectedUnits, v)
			end
		end
		for k, v in pairs(mrtsSelectedUnits) do
			v.selected = true
		end
	end
end

function SWEP:NewTeam(name, color)
	net.Start( "MRTSNewTeam" )
		net.WriteInt(-1, 8)
		net.WriteInt(1, 8)
		net.WriteString(name)
		net.WriteColor(color)
	net.SendToServer()
end

function SWEP:OrderSelectedUnits(position)
	if (mrtsSelectedUnits != nil) then
		local count = table.Count(mrtsSelectedUnits)
		if (count > 0) then
			orderTimer = 1
			orderPoint = GetNonUnitTrace().HitPos
			local walk = LocalPlayer():KeyDown(IN_WALK)
			if (walk) then
				surface.PlaySound( "buttons/button17.wav")
				orderedAttackMove = true
			else
				surface.PlaySound( "buttons/button15.wav")
				orderedAttackMove = false
			end
			net.Start( "MRTSOrderPosition" )
			net.WriteVector(orderPoint)
			net.WriteBool(LocalPlayer():KeyDown(IN_SPEED)) // Add as checkpoint
			net.WriteBool(walk) // Force Attack Move
			for k, v in pairs(mrtsSelectedUnits) do
				if (not IsValid(v) or v:IsWorld()) then
					table.RemoveByValue(mrtsSelectedUnits, v)
				else
					if (not v:GetData().autonomous) then
						net.WriteEntity(v)
					end
				end
			end
			net.SendToServer()
		end
	end
end

function SWEP:OrderStopSelectedUnits()
	if (mrtsSelectedUnits ~= nil) then
		local troops = {}
		for k, v in pairs(mrtsSelectedUnits) do
			if (IsValid(v)) then
				if (v:GetClass() == "ent_mrts_troop" or v:GetClass() == "ent_mrts_part") then
					table.insert(troops, v)
				end
			end
		end
		if (#troops > 0) then
			net.Start( "MRTSOrderStop" )
			for k, v in pairs(troops) do
				if (not IsValid(v)) then
					table.RemoveByValue(troops, v)
				else
					if (not v:GetData().autonomouse) then
						net.WriteEntity(v)
					end
				end
			end
			surface.PlaySound( "buttons/button16.wav")
			net.SendToServer()
		end
	end
end

function SWEP:PrimaryHeld()
	return LocalPlayer():KeyDown(IN_ATTACK)
end

function SWEP:PrimaryPressed()
	if not game.SinglePlayer() and not IsFirstTimePredicted() then return end
	return LocalPlayer():KeyPressed(IN_ATTACK)
end

function SWEP:SecondaryHeld()
	return LocalPlayer():KeyDown(IN_ATTACK2)
end

function SWEP:SecondaryPressed()
	if not game.SinglePlayer() and not IsFirstTimePredicted() then return end
	return LocalPlayer():KeyPressed(IN_ATTACK2)
end

function MRTSDrawSelectionCircle(startingPos, endingPos)
	surface.SetDrawColor( 0, 255, 0, 255 )

	local ply = LocalPlayer()

	local baseSize = 5000

	local pos
	local center = (startingPos+endingPos)/2
	local radius = (startingPos-endingPos):Length()/2

	local oneTurn = math.pi*2

	local pointCount = 12

	for i=0, oneTurn, oneTurn/pointCount do
		local worldPos = center + Vector(radius*math.sin(i), radius*math.cos(i), 0)
		local screenPos = worldPos:ToScreen()
		local size = baseSize/(ply:EyePos()-worldPos):Length()
		surface.DrawRect( screenPos.x-size/2, screenPos.y-size/2, size, size )
	end

	local lineCount = 24

	local pointPos = center + Vector(radius, 0, 0)
	local increment = oneTurn/lineCount
	for i=0, oneTurn, increment do
		local nextPos = center + Vector(radius*math.cos(i+increment), radius*math.sin(i+increment), 0)
		//local size = baseSize/(ply:EyePos()-worldPos):Length()
		local startPoint = pointPos:ToScreen()
		local endPoint = nextPos:ToScreen()
		pointPos = nextPos
		surface.DrawLine( startPoint.x, startPoint.y, endPoint.x, endPoint.y)
	end

	local startSize = baseSize/(ply:EyePos()-startingPos):Length()
	local startScreenPos = startingPos:ToScreen()
	surface.DrawRect( startScreenPos.x-startSize, startScreenPos.y-startSize, startSize*2, startSize*2 )

	local endSize = baseSize/(ply:EyePos()-endingPos):Length()
	local endScreenPos = endingPos:ToScreen()
	surface.DrawRect( endScreenPos.x-endSize, endScreenPos.y-endSize, endSize*2, endSize*2 )

	//surface.DrawLine( startScreenPos.x, startScreenPos.y, endScreenPos.x, endScreenPos.y)

	local centerSize = (startSize+endSize)/2
	local centerScreenPos = center:ToScreen()
	surface.DrawRect( centerScreenPos.x-centerSize/2, centerScreenPos.y-centerSize/2, centerSize, centerSize )
end

function DrawKeybind(x, y, text, icon, modifier)
	
	if (modifier) then
		if (modifier == "alt") then
			MRTSDrawIcon("icon16/tab.png", x, y+7, 32, 32)
			draw.DrawText( "ALT", "DermaDefault", x, y, color_black, TEXT_ALIGN_CENTER )
		elseif (modifier == "ctrl") then
			MRTSDrawIcon("icon16/tab.png", x, y+7, 32, 32)
			draw.DrawText( "CTRL", "DermaDefault", x, y, color_black, TEXT_ALIGN_CENTER )
		elseif (modifier == "shift") then
			MRTSDrawIcon("icon16/tab.png", x, y+7, 32, 32)
			draw.DrawText( "SHFT", "DermaDefault", x, y, color_black, TEXT_ALIGN_CENTER )
		end
		draw.SimpleTextOutlined( text, "DermaDefault", x+40, y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outline_width, outline_color )
		if (icon) then
			MRTSDrawIcon(icon, x+28, y+7, 16, 16)
		end
	else
		draw.SimpleTextOutlined( text, "DermaDefault", x+16, y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outline_width, outline_color )
		if (icon) then
			MRTSDrawIcon(icon, x, y+7, 16, 16)
		end
	end
end

function SWEP:DrawHUD()

	local tr = GetUnitTrace()

	local eyeEntity = tr.Entity
	if (IsValid(eyeEntity)) then
		local entTable = eyeEntity:GetTable()
		if (entTable.isMRTSUnit) then
			if (entTable.IsFOWVisibleToTeam(eyeEntity, mrtsTeam)) then
				local data = entTable.GetData(eyeEntity)
				if (GetConVar("mrts_display_unit_team"):GetBool()) then
					draw.SimpleTextOutlined( "["..mrtsTeams[entTable.GetTeam(eyeEntity)].name.."] "..data.name, "Trebuchet18", ScrW()/2, ScrH()/2+10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, outline_width, outline_color)
				else
					draw.SimpleTextOutlined( data.name, "Trebuchet18", ScrW()/2, ScrH()/2+10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, outline_width, outline_color)
				end
				if (entTable.GetClaimable(eyeEntity)) then
					MRTSDrawIcon("icon16/key.png", ScrW()/2, ScrH()/2+40, 16, 16)
					MRTSDrawIcon("gui/e.png", ScrW()/2, ScrH()/2+62, 16, 16)
					draw.SimpleTextOutlined("Claim", "DermaDefault", ScrW()/2+24, ScrH()/2+56, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, outline_width, outline_color)
				elseif (entTable.GetTeam(eyeEntity) == mrtsTeam) then
					if (entTable.GetUnderConstruction(eyeEntity)) then
						MRTSDrawIcon("icon16/tab.png", ScrW()/2, ScrH()/2+64, 32, 32)
						draw.DrawText( "CTRL", "DermaDefault", ScrW()/2, ScrH()/2+57, color_black, TEXT_ALIGN_CENTER)
						if (entTable.ClassName == "ent_mrts_troop") then
							draw.SimpleTextOutlined( "Cancel recruitment", "DermaDefault", ScrW()/2+20, ScrH()/2+57, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outline_width, outline_color)
						else
							draw.SimpleTextOutlined( "Cancel construction", "DermaDefault", ScrW()/2+20, ScrH()/2+57, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outline_width, outline_color)
						end
					else
						draw.SimpleTextOutlined( math.ceil(entTable.GetUnitHealth(eyeEntity)).."/"..data.maxHealth, "Trebuchet18", ScrW()/2, ScrH()/2+30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, outline_width, outline_color)
						if (data.makesTroop) then
							local troopData = GetTroopByUniqueName(data.makesTroop.troop)
							local cost = data.makesTroop.cost
							draw.SimpleTextOutlined( "Recruit "..troopData.name, "DermaDefault", ScrW()/2+16, ScrH()/2+60, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outline_width, outline_color)
							MRTSDrawIcon("gui/e.png", ScrW()/2, ScrH()/2+67, 16, 16)
							MRTSDrawCost(ScrW()/2, ScrH()/2+80, 100, 0, cost, mrtsTeam)
							MRTSDrawIcon("icon16/tab.png", ScrW()/2, ScrH()/2+110, 32, 32)
							draw.DrawText( "CTRL", "DermaDefault", ScrW()/2, ScrH()/2+103, color_black, TEXT_ALIGN_CENTER)
							draw.SimpleTextOutlined( "Cancel recruitment", "DermaDefault", ScrW()/2+20, ScrH()/2+103, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outline_width, outline_color)
							draw.SimpleTextOutlined( "[Move] Set rally point", "DermaDefault", ScrW()/2-16, ScrH()/2+126, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outline_width, outline_color)
						end
						if (data.activation) then
							draw.SimpleTextOutlined( "Activate", "DermaDefault", ScrW()/2+16, ScrH()/2+60, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outline_width, outline_color)
							MRTSDrawIcon("gui/e.png", ScrW()/2, ScrH()/2+67, 16, 16)
						end
					end
				else
					if (entTable.GetData(eyeEntity).objective) then
						draw.SimpleTextOutlined( math.ceil(entTable.GetUnitHealth(eyeEntity)).."/"..data.maxHealth, "Trebuchet18", ScrW()/2, ScrH()/2+30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, outline_width, outline_color)
					end
				end
			end
		end
	end

	if (mrtsTeam < 0) then return end -- Spectator

	-- Creates error on others
	if (not GetConVar("mrts_playing"):GetBool()) then
		draw.SimpleTextOutlined("PAUSED", "DermaLarge", ScrW()/2, ScrH()-100, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, outline_width, outline_color)
	end

	render.SetMaterial(plainMaterial)
	if (selecting) then
		MRTSDrawSelectionCircle(selectionStartingPoint, selectionEndingPoint);
	end

	if (mrtsPlacingBuilding != false) then
		if (IsValid(mrtsPlacingBuildingSource)) then
			local circleCenter = mrtsPlacingBuildingSource:GetPos()
			if (mrtsPlacingBuildingSource:GetData().buildingRange != nil) then
				local circleOffset = Vector(mrtsPlacingBuildingSource:GetData().buildingRange, 0, 0)
				MRTSDrawSelectionCircle(circleCenter+circleOffset, circleCenter-circleOffset)
			end
		end
	end

	if (orderTimer > 0) then
		local orderSize = 30*orderTimer*orderTimer*orderTimer*orderTimer;
		local screenOrderPoint = orderPoint:ToScreen();
		MRTSDrawPing(screenOrderPoint, orderSize);
	end

	if (menuScale > 0) then
		self:DrawBuildMenu()
	end

	local _team = mrtsTeams[mrtsTeam]

	-- Resources display
	
	local iconSize = 16
	
	local resBoxW = 135
	local resBoxH = 25
	local resBoxSpacing = 10

	local outline = 5
	local padding = 5
	local w = (resBoxW+resBoxSpacing)*(table.Count(mrtsGameData.resources)+1)

	if (GetConVar("mrts_sandbox_mode"):GetBool()) then
		w=resBoxW+resBoxSpacing
	end

	local allies = mrtsTeams[mrtsTeam].alliances
	local allyCount = 0
	for k, v in pairs(allies) do
		if v and k != mrtsTeam then
			allyCount = allyCount + 1
		end
	end
	if (allyCount > 0) then
		w = w + 60
	end
	w = w + allyCount*24

	local h = resBoxH+12
	local x = ScrW()/2-w/2
	local y = ScrH()-h

	local resBoxX = x+6
	local resBoxY = y+6
	local cornerRadius = 5

	local color = _team.color
	if (placingClaimable) then
		color = color_white
	end
	draw.RoundedBox( cornerRadius+padding+outline,x-outline-padding, y-outline-padding, w+(outline+padding)*2, h+(outline+padding)*2+100, Color(20,20,20) )
	draw.RoundedBox( cornerRadius+padding, x-padding, y-padding, w+padding*2, h+padding*2+100, color )
	draw.RoundedBox( cornerRadius, x, y, w, h+100, Color(0,0,0,230) )

	if (GetConVar("mrts_sandbox_mode"):GetBool()) then
		draw.DrawText("Sandbox mode", "Trebuchet24", ScrW()/2, ScrH()-70, TRANSPARENT_WHITE_COLOR, TEXT_ALIGN_CENTER)
	else
		for k, v in SortedPairsByMemberValue(_team.resources, "order") do
			surface.SetDrawColor(0,0,0,230)
			surface.DrawRect(resBoxX, resBoxY, resBoxW, resBoxH)
			MRTSDrawResourceIcon(k, resBoxX+iconSize/2+2, resBoxY+iconSize/2+5, iconSize, iconSize)
			surface.SetFont("Trebuchet24")
			local full = v.current == v.capacity
			surface.SetTextColor(255,255,255)
			if (full and v.income > 0) then
				surface.SetTextColor(255,100,0)
			end
			surface.SetTextPos( resBoxX+iconSize+5, resBoxY+1 ) 
			surface.DrawText(v.current)
			surface.SetTextColor(255,255,255,100)
			if (full and v.income > 0) then
				surface.SetTextColor(255,100,0,100)
			end
			surface.SetFont("Trebuchet18")
			surface.DrawText("+"..v.income.."")
			surface.SetTextColor(255,255,255,75)
			if (full and v.income > 0) then
				if (CurTime()%1 < 0.5) then surface.SetTextColor(255,100,0,75)
				else surface.SetTextColor(255,255,255,75) end
			end
			surface.DrawText(" /"..v.capacity)
			resBoxX = resBoxX+resBoxW+resBoxSpacing
		end
	end

	surface.SetDrawColor(0,0,0,230)
	surface.DrawRect(resBoxX, resBoxY, resBoxW, resBoxH)
	MRTSDrawPopulationIcon(resBoxX+iconSize/2+2, resBoxY+iconSize/2+5, iconSize, iconSize)
	surface.SetFont("Trebuchet24")
	surface.SetTextColor(255,255,255)
	if (_team.usedHousing == _team.maxHousing) then
		surface.SetTextColor(255,100,0)
	end
	surface.SetTextPos( resBoxX+iconSize+5, resBoxY+1 ) 
	surface.DrawText(_team.usedHousing)
	surface.SetFont("Trebuchet18")
	local maxpop = GetConVar("mrts_max_population"):GetInt()
	surface.DrawText(" /"..math.min(_team.maxHousing, maxpop))
	if (_team.maxHousing >= maxpop) then
		surface.DrawText(" (Max)")
	end
	resBoxX = resBoxX+resBoxW+resBoxSpacing

	-- Allies
	if (allyCount > 0) then
		surface.SetTextColor(255,255,255,255)
		surface.SetTextPos( resBoxX+10, resBoxY+3 ) 
		surface.DrawText("Allies:")
		surface.SetFont("Trebuchet18")
	end
	resBoxX = resBoxX+50
	for k, v in pairs(allies) do
		if v and k != mrtsTeam then
			draw.RoundedBox(4, resBoxX, resBoxY, 24, 24, Color(0,0,0,230))
			draw.RoundedBox(4, resBoxX+4, resBoxY+4, 16, 16, mrtsTeams[k].color)
			resBoxX = resBoxX+24
		end
	end

	-- Draw Build queue
	local queuePosX = 64
	local queuePosY = ScrH()-160
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetFont("Trebuchet24")
	local first = true
	for k, v in pairs(mrtsTeams[mrtsTeam].buildQueue) do
		if (first) then
			local number = (math.ceil((mrtsTeams[mrtsTeam].nextBuild-CurTime())*10)/10)
			if (number < -3) then break end
			if (number < 0) then
				number = 0
			end
			if (number%1==0) then
				number = number..".0"
			end
			local str = number.."s"
			local textWidth = string.len(tostring(str))*10
			draw.RoundedBox(16, queuePosX-16, queuePosY-16, 52+textWidth, 32, MRTS_DARK_COLOR)
			draw.RoundedBox(28, queuePosX-28, queuePosY-28, 56, 56, MRTS_DARK_COLOR)
			local percent = 1-(mrtsTeams[mrtsTeam].nextBuild-CurTime())/v.time
			MRTSDrawCircularProgressBar(queuePosX, queuePosY, 24, percent)
			surface.SetTextPos(queuePosX+32, queuePosY-12)
			draw.RoundedBox(16, queuePosX-16, queuePosY-16, 32, 32, MRTS_DARK_COLOR)
			surface.DrawText(str)
		else
			local str = v.time.."s"
			local textWidth = string.len(tostring(str))*10
			draw.RoundedBox(16, queuePosX-16, queuePosY-16, 36+textWidth, 32, MRTS_DARK_COLOR)
			surface.SetTextPos(queuePosX+16, queuePosY-12)
			surface.DrawText(v.time.."s")
		end
		
		MRTSDrawIcon(v.icon, queuePosX, queuePosY, 16, 16)
		if (first) then
			queuePosY = queuePosY-50
		else
			queuePosY = queuePosY-36
		end
		first = false
	end

	local offset = 160
	if (self.stage == STAGE_MAIN) then
		DrawKeybind(32, offset+32, "Open/Close menu", "gui/r.png")
		DrawKeybind(32, offset+52, "(Drag) Select units", "gui/lmb.png")
		if (istable(mrtsSelectedUnits) and #mrtsSelectedUnits > 0) then
			DrawKeybind(32, offset+72, "Add to selection", "gui/lmb.png", "shift")
			DrawKeybind(32, offset+92, "Move selected units", "gui/rmb.png")
			DrawKeybind(32, offset+112, "Add movement waypoint", "gui/rmb.png", "shift")
			DrawKeybind(32, offset+132, "Move and attack", "gui/rmb.png", "alt")
			DrawKeybind(32, offset+152, "Stop", nil, "ctrl")
		end
	elseif (self.stage == STAGE_PLACING_TROOP) then
		DrawKeybind(32, offset+32, "Open/Close menu", "gui/r.png")
		DrawKeybind(32, offset+52, "Place troop", "gui/lmb.png")
		DrawKeybind(32, offset+72, "Stop placing troops", "gui/rmb.png")
		local troopData = mrtsGameData.troops[mrtsPlacingUnitID]
		local cost = troopData.cost
		draw.SimpleTextOutlined("Placing "..troopData.name, "Trebuchet18", ScrW()/2, ScrH()/2+50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, outline_width, outline_color)
		MRTSDrawCost(ScrW()/2-40, ScrH()/2+75, 100, 0, cost, mrtsTeam)
	elseif (self.stage == STAGE_PLACING_BUILDING) then
		DrawKeybind(32, offset+32, "Open/Close menu", "gui/r.png")
		DrawKeybind(32, offset+52, "Place building", "gui/lmb.png")
		DrawKeybind(32, offset+72, "Stop placing buildings", "gui/rmb.png")
		local buildingData = mrtsGameData.buildings[mrtsPlacingUnitID]
		if (not buildingData.unlisted) then
			local cost = buildingData.cost
			draw.SimpleTextOutlined("Placing "..buildingData.name, "Trebuchet18", ScrW()/2, ScrH()/2+50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, outline_width, outline_color)
			MRTSDrawCost(ScrW()/2-40, ScrH()/2+75, 100, 0, cost, mrtsTeam)
		end
	elseif (self.stage == STAGE_PLACING_CAPTURE_ZONE) then
		DrawKeybind(32, offset+32, "Open/Close menu", "gui/r.png")
		DrawKeybind(32, offset+52, "Place capture zone", "gui/lmb.png")
		DrawKeybind(32, offset+72, "Stop placing capture zones", "gui/rmb.png")
	elseif (self.stage == STAGE_PLACING_BOUND_PLANE) then
		DrawKeybind(32, offset+32, "Open/Close menu", "gui/r.png")
		DrawKeybind(32, offset+52, "Place kill plane", "gui/lmb.png")
		DrawKeybind(32, offset+72, "Stop placing kill planes", "gui/rmb.png")
	elseif (self.stage == STAGE_PLACING_BOUND_POLE) then
		DrawKeybind(32, offset+32, "Open/Close menu", "gui/r.png")
		DrawKeybind(32, offset+52, "Place bound pole", "gui/lmb.png")
		DrawKeybind(32, offset+72, "Stop placing bound poles", "gui/rmb.png")
	elseif (self.stage == STAGE_PLACING_SURVIVAL_HQ) then
		DrawKeybind(32, offset+32, "Open/Close menu", "gui/r.png")
		DrawKeybind(32, offset+52, "Place survival hq", "gui/lmb.png")
		DrawKeybind(32, offset+72, "Cancel", "gui/rmb.png")
	elseif (self.stage == STAGE_DELETING) then
		DrawKeybind(32, offset+32, "Open/Close menu", "gui/r.png")
		DrawKeybind(32, offset+52, "Delete unit", "gui/lmb.png")
		DrawKeybind(32, offset+72, "Stop deleting", "gui/rmb.png")

		MRTSDrawIcon("icon16/bin_empty.png", ScrW()/2-16, ScrH()/2, 16, 16)
	end
end

function SWEP:SprintE()
	--net.Start("MRTSSetTeam")
	--	net.WriteInt(mrtsTeam%2+1, 8)
	--net.SendToServer()
	--LocalPlayer():SetNWInt("mrtsTeam",(LocalPlayer():GetNWInt("mrtsTeam",0))%2+1)
end

function SWEP:DrawWorldModel()
end

function SWEP:DoDrawCrosshair(x, y)
	local crosshairSize = 5;
	local borderSize = 9;
	surface.SetDrawColor(0, 0, 0, 100);
	surface.DrawRect( x-borderSize/2,y-borderSize/2+1, borderSize, borderSize );
	surface.SetDrawColor(255, 255, 255, 255);
	surface.DrawRect( x-crosshairSize/2,y-crosshairSize/2+1, crosshairSize, crosshairSize );
end

function MRTSPercentageToColor(p, transparency)
	return Color(math.Clamp((1-p)*510,0,255), math.Clamp(p*510,0,255), 0, transparency)
end

function MRTSDrawSelected(screenPosition, size, color)
	surface.SetDrawColor( color )
	surface.DrawRect(screenPosition.x-size/2, screenPosition.y-size/2, size, size, color)
end

function MRTSDrawPing(screenPosition, size)
	if (size >= 1) then
		local function drawBorderedRect(x, y, w, h, r, g, b)
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawRect(x-(w+4)/2, y-(h+4)/2, (w+4), (h+4), color)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawRect(x-(w+2)/2, y-(h+2)/2, (w+2), (h+2), color)
			surface.SetDrawColor( r, g, b, 255 )
			surface.DrawRect(x-w/2, y-h/2, w, h, color)
		end

		local r, g, b = 0, 255, 0
		if (orderedAttackMove) then
			r, g, b = 255, 0, 0
		end
		drawBorderedRect(screenPosition.x-size-2, screenPosition.y, size*0.3, 3, r, g, b)
		drawBorderedRect(screenPosition.x+size+2, screenPosition.y, size*0.3, 3, r, g, b)
		drawBorderedRect(screenPosition.x, screenPosition.y-size-2, 3, size*0.3, r, g, b)
		drawBorderedRect(screenPosition.x, screenPosition.y+size+2, 3, size*0.3, r, g, b)

		drawBorderedRect(screenPosition.x, screenPosition.y, size*size/50, size*size/50, r, g, b)
	end
end

function SWEP:OpenMapSavePopup()
	local frame = vgui.Create( "DFrame" )
	frame:SetSize( 640, 440 )
	frame:Center()
	frame:MakePopup()

	local TextEntry = vgui.Create( "DTextEntry", frame ) -- create the form as a child of frame
	TextEntry:Dock( TOP )
	TextEntry.OnEnter = function( self )
		chat.AddText( self:GetValue() )	-- print the textentry text as a chat message
	end

	local TextEntryPH = vgui.Create( "DTextEntry", frame )
	TextEntryPH:Dock( TOP )
	TextEntryPH:DockMargin( 0, 5, 0, 0 )
	TextEntryPH:SetPlaceholderText( "I am a placeholder" )
	TextEntryPH.OnEnter = function( self )
		chat.AddText( self:GetValue() )
	end
end

local color_orange = Color(255,150,0)
function MRTSDrawCost(x, y, w, h, cost, team)
	surface.SetFont("Trebuchet18")
	surface.SetDrawColor(255,255,255)
	surface.SetTextColor(255,255,255)
	local iconSize = 16
	local xoffset = x
	local padding = 4
	
	-- This is so that resources appear in the order of the gameData json
	local sortedResources = {}
	for k, v in pairs(mrtsGameData.resources) do
		if (cost[v.uniqueName]) then
			sortedResources[k] = cost[v.uniqueName]
		end
	end

	for k, v in SortedPairs(sortedResources) do
		local current = mrtsTeams[team].resources[mrtsGameData.resources[k].uniqueName].current
		local chosenColor = color_red
		if (current < v) then
			chosenColor = color_orange
		end
		local str = tostring(current).."/"..tostring(v)
		local textWidth = 20+string.len(str)*10
		MRTSDrawResourceIcon(mrtsGameData.resources[k].uniqueName, 20+xoffset, y+h/2, iconSize, iconSize)
		draw.SimpleTextOutlined( str, "Trebuchet18", 30+xoffset, y+h/2-8, chosenColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outline_width, outline_color )
		xoffset = xoffset+textWidth
	end
end

function MRTSDrawResources(x, y, w, h, resources)
	surface.SetFont("Trebuchet18")
	surface.SetDrawColor(255,255,255)
	surface.SetTextColor(255,255,255)
	local iconSize = 16
	local xoffset = x
	local padding = 4
	
	-- This is so that resources appear in the order of the gameData json
	local sortedResources = {}
	for k, v in pairs(mrtsGameData.resources) do
		if (resources[v.uniqueName]) then
			sortedResources[k] = resources[v.uniqueName]
		end
	end

	for k, v in SortedPairs(sortedResources) do
		local textWidth = 20+string.len(tostring(v))*10
		MRTSDrawResourceIcon(mrtsGameData.resources[k].uniqueName, 20+xoffset, y+h/2, iconSize, iconSize)
		surface.SetTextPos(30+xoffset, y+h/2-8)
		surface.DrawText(v)
		xoffset = xoffset+textWidth
	end
end

function MakeMRTSUnitButton(parent, h, unit, showInfo, onClick)
	local but = vgui.Create( "DButton", parent )
	but:SetText( "" )
	but:SetColor( color_white )
	but:SetPos(0, 10)
	but:SetHeight( h )
	but.Paint = function(btn, w, h)
		
		if (btn:IsHovered()) then
			draw.RoundedBox( h, 0, 0, w, h, MRTS_TROOP_BUTTON_HOVER_COLOR )
		else
			if (unit.unlisted) then
				draw.RoundedBox( h, 0, 0, w, h, MRTS_TROOP_BUTTON_COLOR_ADMIN_ONLY )
			else
				draw.RoundedBox( h, 0, 0, w, h, MRTS_TROOP_BUTTON_COLOR )
			end
		end
		draw.RoundedBox( 24, 4, h/2-12, 24, 24, MRTS_DARK_COLOR)
		MRTSDrawIcon(unit.icon or "icon16/bullet_black.png", 16, h/2, 16, 16)
		draw.DrawText(unit.name, "Trebuchet24", 35, 5)
		if (showInfo) then
			if (unit.cost) then
				MRTSDrawResources(0+w*0.4, 0, w*0.45, h, unit.cost)
			end
			if (unit.buildTime and unit.buildTime > 0) then
				MRTSDrawIcon("⏳", w-115, 16, 16, 16)
				draw.DrawText((unit.buildTime).."s", "Trebuchet18", w-105, 8)
			end
			if (unit.population and unit.population > 0) then
				MRTSDrawPopulationIcon(w-65, 16, 16, 16)
				draw.DrawText(unit.population, "Trebuchet18", w-55, 8)
			end
		end

		if (unit.unlisted) then
			MRTSDrawIcon("icon16/shield.png", 8, 8, 16, 16)
		end
	end

	function but:DoClick()
		onClick()
	end

	if (showInfo) then
		local infoButton = vgui.Create("DButton", but)
		infoButton:Dock(RIGHT)
		infoButton:DockMargin(10,10,8,10)
		infoButton:SetWidth(32)
		infoButton:SetText("")
		infoButton.Paint = function(self, w, h)
			MRTSDrawIcon("icon16/information.png", w/2, h/2, 16, 16)
		end
		function infoButton:DoClick()
			if (IsValid(helpPanel)) then
				helpPanel:Close()
			end
			helpPanel = vgui.Create("DFrame") -- The name of the panel we don't have to parent it.
			helpPanel:SetPos(ScrW()/2+350, ScrH()/2-200) -- Set the position to 100x by 100y. 
			helpPanel:SetSize(300, 400) -- Set the size to 300x by 200y.
			helpPanel:SetTitle("Unit Info") -- Set the title in the top left to "Derma Frame".
			helpPanel:MakePopup() -- Makes your mouse be able to move around.
			helpPanel:SetKeyboardInputEnabled(false)
			helpPanel:DockPadding(10,40,10,10)

			local title = vgui.Create("DLabel", helpPanel)
			title:Dock(TOP)
			title:SetFont("Trebuchet24")
			title:SetText(unit.name)

			local function AddLabel(text)
				local infoLabel = vgui.Create("DLabel", helpPanel)
				infoLabel:Dock(BOTTOM)
				infoLabel:SetText(text)
			end

			if (unit.attack) then
				if (unit.attack.status) then
					local status = GetStatusByUniqueName(unit.attack.status.type)
					AddLabel("Applies "..status.name.." ("..status.description.." for "..unit.attack.status.duration.."s )")
				end
				if (unit.attack.setup) then AddLabel("Setup time: "..unit.attack.setup.."s") end
				if (unit.attack.delay) then AddLabel("Fire rate: "..unit.attack.delay.."s") end
				if (unit.attack.radius) then AddLabel("Radius: "..unit.attack.radius) end
				if (unit.attack.health) then AddLabel("Healing: "..unit.attack.health) end
				if (unit.attack.damage) then AddLabel("Damage: "..unit.attack.damage) end
				AddLabel("Range: "..unit.attack.range)
			end
			if (unit.canAttackWhileMoving) then AddLabel("Can attack while moving") end
			if (unit.speed) then AddLabel("Speed: "..unit.speed) end
			AddLabel("HP: "..unit.maxHealth)
			if (unit.makesTroop) then AddLabel("Produces "..GetTroopByUniqueName(unit.makesTroop.troop).name) end
			AddLabel("Type: "..unit.type)

			local description = vgui.Create("RichText", helpPanel)
			description:DockMargin(10,10,10,10)
			description:Dock(FILL)
			description:SetText(unit.description)
		end
	end

	return but
end

function SWEP:OpenGameMenu()
	--self:CloseBuildingMenu()
	menuScale = 0
	surface.PlaySound("weapons/smg1/switch_single.wav")

	if (mrtsGameMenu != nil) then
		mrtsGameMenu:SetVisible(true)
		return
	end
	mrtsGameMenu = vgui.Create( "DFrame" )
	mrtsGameMenu:SetSize( 700, 640 )
	mrtsGameMenu:Center()
	mrtsGameMenu:MakePopup()
	mrtsGameMenu:SetTitle("MRTS Game Menu")
	mrtsGameMenu:SetKeyboardInputEnabled(false)
	mrtsGameMenu.OnClose = function()
		gui.EnableScreenClicker( false )
		surface.PlaySound("weapons/smg1/switch_single.wav")
		mrtsGameMenu = nil
	end

	mrtsMainSheet = vgui.Create( "DPropertySheet", mrtsGameMenu )
	mrtsMainSheet:Dock( FILL )

	---------------------------------------------------------------------------------------------
	--										Play
	---------------------------------------------------------------------------------------------
	if (mrtsTeam >= 0) then
		local playPanel = vgui.Create( "DPanel", mrtsMainSheet )
		mrtsMainSheet:AddSheet( "Play", playPanel, "icon16/control_play_blue.png" )
		playPanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 100, 100, 100, self:GetAlpha() ) ) end 

		local playCategories = vgui.Create( "DColumnSheet", playPanel )
		playCategories:Dock(FILL)
		playCategories:SetSize(150,0)
		local unitButtonSize = 34

		--------------------------------- Troops
		local troopsPanel = vgui.Create( "DScrollPanel", playCategories )
		troopsPanel:Dock( FILL )
		troopsPanel:SetSize(250, 0)
		troopsPanel.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 30, 30, 30, self:GetAlpha() ) )
		end 

		/*local costWarning = vgui.Create("DPanel", troopsPanel)
		costWarning:Dock(TOP)
		costWarning:DockPadding(5,5,5,5)
		costWarning.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 100, 0, 0 ) )
		end 
		local costWarningLabel = vgui.Create("DLabel", costWarning)
		costWarningLabel:SetText("Units created this way take longer and cost more than ones created from barracks. Freelancers aren't cheap!")
		costWarningLabel:Dock(FILL)*/

		local faction = mrtsGameData.factions[mrtsTeams[mrtsTeam].faction]
		for k, v in pairs(mrtsGameData.troops) do
			if (not v.unlisted) then
				local whitelisted = faction.whitelist and table.HasValue(faction.whitelist, v.uniqueName)
				local blacklisted = faction.blacklist and table.HasValue(faction.blacklist, v.uniqueName)
				if (faction.replacements) then
					for kk, vv in pairs(faction.replacements) do
						if (vv[1] == v.uniqueName) then blacklisted = true end
						if (vv[2] == v.uniqueName) then whitelisted = true end
					end
				end
				if (not blacklisted and (not v.factionSpecific or whitelisted)) then
					local but = MakeMRTSUnitButton(troopsPanel, unitButtonSize, v, true, function()
						self:SetPreviewModel(v.model)
						self:SetStage(STAGE_PLACING_TROOP)
						placingCapturable = false
						placingClaimable = false
						adminAction = false
						mrtsPlacingUnitID = k
						self:CloseGameMenu()
					end)
					but:DockMargin(4,4,4,4)
					but:Dock(TOP)
				end
			end
		end
		local troopSheet = playCategories:AddSheet( "Troops", troopsPanel/*, "icon16/status_online.png"*/ )
		troopSheet.Button:SetSize(0,100)

		--------------------------------- Buildings
		local buildingsPanel = vgui.Create( "DScrollPanel", playCategories )
		buildingsPanel:Dock( FILL )
		buildingsPanel:SetSize(250, 0)
		buildingsPanel.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 30, 30, 30, self:GetAlpha() ) )
		end 
		for k, v in pairs(mrtsGameData.buildings) do
			if (not v.unlisted) then
				local whitelisted = faction.whitelist and table.HasValue(faction.whitelist, v.uniqueName)
				local blacklisted = faction.blacklist and table.HasValue(faction.blacklist, v.uniqueName)
				if (faction.replacements) then
					for kk, vv in pairs(faction.replacements) do
						if (vv[1] == v.uniqueName) then blacklisted = true end
						if (vv[2] == v.uniqueName) then whitelisted = true end
					end
				end
				if (not blacklisted and (not v.factionSpecific or whitelisted)) then
					local but = MakeMRTSUnitButton(buildingsPanel, unitButtonSize, v, true, function()
						self:SetStage(STAGE_PLACING_BUILDING)
						placingCapturable = false
						placingClaimable = false
						adminAction = false
						self:SetPreviewModel(v.model)
						mrtsPlacingUnitID = k
						self:CloseGameMenu()
					end)
					but:DockMargin(4,4,4,4)
					but:Dock(TOP)
				end
			end
		end
		local buildingSheet = playCategories:AddSheet( "Buildings", buildingsPanel/*, "icon16/building.png"*/ )
		buildingSheet.Button:SetSize(0,100)

		-------------------------------------- Delete tool
		local deleteButton = vgui.Create("DButton", playPanel)
		deleteButton:SetPos(10, 525)
		deleteButton:SetSize(100, 30)
		deleteButton:SetText("Delete")
		deleteButton.PaintOver = function(self, w, h)
			MRTSDrawIcon("icon16/bin_closed.png", h/2, h/2, 16, 16)
		end
		deleteButton.DoClick = function()		
			self:CloseGameMenu()
			self:SetStage(STAGE_DELETING)
		end
	end
	---------------------------------------------------------------------------------------------
	--										Teams
	---------------------------------------------------------------------------------------------
	local teamsPanel = vgui.Create( "DPanel", mrtsMainSheet )
	mrtsMainSheet:AddSheet( "Teams", teamsPanel, "icon16/flag_red.png" )
	teamsPanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 50, 50, 50, self:GetAlpha() ) ) end 

	local DScrollPanel = vgui.Create( "DScrollPanel", teamsPanel )
	DScrollPanel:Dock(FILL)
	DScrollPanel:SetSize(200,0)
	DScrollPanel.Paint = function( self, w, h )
		draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, self:GetAlpha()/2 ) )
	end 

	local padding = 5

	local row = vgui.Create("DPanel", DScrollPanel)
	row:Dock( TOP )
	row:SetHeight(52)
	row:DockMargin( 5, 5, 5, 0 )
	row.Paint = function( self, w, h ) end
	local DButton = vgui.Create( "DButton", row )
	DButton:Dock( FILL )
	DButton:SetText( "" )
	DButton:SetColor(Color(255,255,255))
	DButton.Paint = function( self, w, h )
		self:Clear()
		draw.RoundedBox( 42, padding, padding, w-padding*2, 35, Color( 255, 255, 255, self:GetAlpha() ) )
		draw.RoundedBox( 42, w/2+padding+5-100, padding+5, 200, 35-10, Color( 0, 0, 0, self:GetAlpha()*0.8 ) )
		draw.DrawText("Spectate", "Trebuchet24", w/2+padding+15-50, padding+5)
	end
	function DButton:DoClick() -- Callback inherited from DLabel, which is DColorButton's base
		net.Start("MRTSSetTeam")
			net.WriteInt(-1, 8)
			net.WriteBool(true)
		net.SendToServer()
	end

	for k, v in pairs(mrtsTeams) do
		local row = vgui.Create("DPanel", DScrollPanel)
		row:Dock( TOP )
		row:SetHeight(52)
		row:DockMargin( 5, 5, 5, 0 )
		row.Paint = function( self, w, h ) end

		local comboBox = vgui.Create("DComboBox", row)
		comboBox:Dock( RIGHT )
		comboBox:SetWidth(100)
		comboBox:DockMargin(5, 5, 5, 5)
		comboBox:SetValue( mrtsGameData.factions[v.faction].name )
		comboBox.OnSelect = function( self, index, value )
			net.Start("MRTSSetFaction")
				net.WriteInt(k, 8)
				net.WriteInt(index, 8)
			net.SendToServer()
		end

		local DButton = vgui.Create( "DButton", row )
		DButton:Dock( FILL )
		DButton:SetText( "" )
		DButton:SetColor(Color(255,255,255))
		DButton.Paint = function( self, w, h )
			self:Clear()
			draw.RoundedBox( 42, padding, padding, w-padding*2, 42, Color( v.color.r, v.color.g, v.color.b, self:GetAlpha() ) )
			draw.RoundedBox( 42, padding+5, padding+5, 200, 42-10, Color( 0, 0, 0, self:GetAlpha()*0.8 ) )
			draw.DrawText(v.name, "Trebuchet24", padding+15, padding+9)
			for kk, vv in pairs(team.GetPlayers( k )) do
				--draw.DrawText(vv:Nick(), "Trebuchet24", padding+150, padding+5)
				local avatar = vgui.Create("AvatarImage", DButton)
				-- Layout the avatars in a grid
				avatar:SetPos(padding+180+kk*32, padding+5)
				-- Load the avatar image
				avatar:SetSteamID(vv:SteamID64(), 32)
				avatar:SetSize(32, 32)
			end
		end

		for _, v in ipairs( mrtsGameData.factions ) do
			comboBox:AddChoice( v.name )
		end

		function DButton:DoClick() -- Callback inherited from DLabel, which is DColorButton's base
			net.Start("MRTSSetTeam")
				net.WriteInt(k, 8)
				net.WriteBool(true)
			net.SendToServer()
		end
	end

	---------------------------------------------------------------------------------------------
	--										Contraptions
	---------------------------------------------------------------------------------------------
	if (false and mrtsTeam >= 0) then
		local contraptionPanel = vgui.Create( "DPanel", mrtsMainSheet )
		mrtsMainSheet:AddSheet( "Contraptions", contraptionPanel, "icon16/car.png" )
		contraptionPanel:DockPadding(20,20,20,20)
		contraptionPanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 100, 100, 100, self:GetAlpha() ) ) end 

		local disclaimer = vgui.Create("DPanel", contraptionPanel)
		disclaimer:Dock(TOP)
		disclaimer:DockPadding(5,5,5,5)
		disclaimer.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 100, 0, 0 ) )
		end 
		local disclaimerLabel = vgui.Create("DLabel", disclaimer)
		disclaimerLabel:SetText("(!) Contraptions are still in a testing phase and are not fit for use in matches")
		disclaimerLabel:Dock(FILL)

		local DermaButton = vgui.Create( "DButton", contraptionPanel )
		DermaButton:SetText( "Save contraption" )	
		DermaButton:DockMargin(10,10,10,10)				
		DermaButton:Dock(TOP)		
		DermaButton:SetSize(0,30)	
		DermaButton.DoClick = function()				
			self:SetStage(STAGE_SAVING_CONTRAPTION)
			self:CloseGameMenu()
		end

		local DermaButton = vgui.Create( "DButton", contraptionPanel )
		DermaButton:SetText( "Load contraption" )	
		DermaButton:DockMargin(10,10,10,10)				
		DermaButton:Dock(TOP)		
		DermaButton:SetSize(0,30)	
		DermaButton.DoClick = function()				
			MRTSLoadContraptionDialog()
			self:CloseGameMenu()
		end

		local partsPanel = vgui.Create( "DScrollPanel", contraptionPanel )
		partsPanel:Dock( FILL )
		partsPanel:SetSize(250, 0)
		partsPanel.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 30, 30, 30, self:GetAlpha() ) )
		end 

		local unitButtonSize = 34
		--local faction = mrtsGameData.factions[mrtsTeams[mrtsTeam].faction]
		for k, v in pairs(mrtsGameData.parts) do
			if (not v.unlisted) then
				/*local whitelisted = faction.whitelist and table.HasValue(faction.whitelist, v.uniqueName)
				local blacklisted = faction.blacklist and table.HasValue(faction.blacklist, v.uniqueName)
				if (faction.replacements) then
					for kk, vv in pairs(faction.replacements) do
						if (vv[1] == v.uniqueName) then blacklisted = true end
						if (vv[2] == v.uniqueName) then whitelisted = true end
					end
				end
				if (not blacklistedand (not v.factionSpecific or whitelisted)) then*/
					local but = MakeMRTSUnitButton(partsPanel, unitButtonSize, v, true, function()
						self:SetPreviewModel(v.model)
						self:SetStage(STAGE_PLACING_PART)
						placingCapturable = false
						placingClaimable = false
						adminAction = false
						mrtsPlacingUnitID = k
						self:CloseGameMenu()
					end)
					but:DockMargin(4,4,4,4)
					but:Dock(TOP)
				--end
			end
		end
	end
	
	---------------------------------------------------------------------------------------------
	--										Options
	---------------------------------------------------------------------------------------------
	local optionsPanel = vgui.Create( "DPanel", mrtsMainSheet )
	mrtsMainSheet:AddSheet( "Options", optionsPanel, "icon16/cog.png" )
	optionsPanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 100, 100, 100, self:GetAlpha() ) ) end 
	optionsPanel:DockPadding(20,20,20,20)

	local unitTeamOption = vgui.Create("DCheckBoxLabel", optionsPanel)
	unitTeamOption:Dock(TOP)
	unitTeamOption:SetText("Show team name when looking at a unit")
	unitTeamOption:SetConVar("mrts_display_unit_team")

	local notificationOption = vgui.Create("DCheckBoxLabel", optionsPanel)
	notificationOption:Dock(TOP)
	notificationOption:SetText("Show sighting, combat and death notifications")
	notificationOption:SetConVar("mrts_display_notifications")

	---------------------------------------------------------------------------------------------
	--										Admin
	---------------------------------------------------------------------------------------------
	if (LocalPlayer():IsAdmin()) then

		local adminPanel = vgui.Create( "DPanel", mrtsMainSheet )
		mrtsMainSheet:AddSheet( "Admin", adminPanel, "icon16/shield.png" )
		adminPanel:DockPadding(0,10,0,0)
		adminPanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 100, 100, 100, self:GetAlpha() ) ) end 

		local adminSheet = vgui.Create( "DPropertySheet", adminPanel )
		adminSheet:Dock( FILL )

		----------------------------------- Match
		local matchPanel = vgui.Create( "DScrollPanel", adminSheet )
		adminSheet:AddSheet( "Match", matchPanel, "icon16/wand.png" )
		matchPanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 100, 100, 100, self:GetAlpha() ) ) end 

		matchPanel:DockPadding(20,20,20,20)

		local DermaButton = vgui.Create( "DButton", matchPanel )
		DermaButton:SetText( "Start Match" )	
		DermaButton:DockMargin(5,5,5,5)				
		DermaButton:Dock(TOP)		
		DermaButton:SetSize(0,30)	
		DermaButton.DoClick = function()				
			net.Start("MRTSMatchStart")
			net.SendToServer()
			self:CloseGameMenu()
		end

		local DermaButton = vgui.Create( "DButton", matchPanel )
		DermaButton:SetText( "Toggle Pause" )	
		DermaButton:DockMargin(5,5,5,5)								
		DermaButton:Dock(TOP)		
		DermaButton:SetSize(0,30)	
		DermaButton.DoClick = function()				
			net.Start("MRTSTogglePause")
			net.SendToServer()
			self:CloseGameMenu()
		end

		local DermaButton = vgui.Create( "DButton", matchPanel )
		DermaButton:SetText( "Toggle Fog of War" )	
		DermaButton:DockMargin(5,5,5,5)								
		DermaButton:Dock(TOP)		
		DermaButton:SetSize(0,30)	
		DermaButton.DoClick = function()				
			net.Start("MRTSToggleFOW")
			net.SendToServer()
		end

		local DermaButton = vgui.Create( "DButton", matchPanel )
		DermaButton:SetText( "Recalculate income and housing" )	
		DermaButton:DockMargin(5,5,5,5)								
		DermaButton:Dock(TOP)		
		DermaButton:SetSize(0,30)	
		DermaButton.DoClick = function()				
			net.Start("MRTSRecalculate")
			net.SendToServer()
			self:CloseGameMenu()
		end

		local DermaButton = vgui.Create( "DButton", matchPanel )
		DermaButton:SetText( "Toggle Sandbox" )		
		DermaButton:DockMargin(5,5,5,5)							
		DermaButton:Dock(TOP)		
		DermaButton:SetSize(0,30)	
		DermaButton.DoClick = function()				
			net.Start("MRTSToggleSandbox")
			net.SendToServer()
			self:CloseGameMenu()
		end

		local allianceText = vgui.Create( "DLabel", matchPanel )
		allianceText:DockMargin(20,10,0,0)
		allianceText:Dock(TOP)
		allianceText:SetText("Alliances")

		local allianceGrid = vgui.Create( "DGrid", matchPanel )
		allianceGrid:Dock(TOP)
		allianceGrid:DockMargin(20,5,0,0)
		allianceGrid:SetCols( #mrtsTeams+1 )
		local size = 24
		local outline = 4
		allianceGrid:SetColWide( size )
		allianceGrid:SetRowHeight( size )

		mrtsAllianceButtons = {}
		for k1, v1 in pairs(mrtsTeams) do
			local allianceLabel = vgui.Create("DPanel")
			allianceLabel:SetSize(size, size)
			allianceLabel.Paint = function(self, w, h)
				draw.RoundedBox(0, 0, 0, w, h, color_black)
				draw.RoundedBox(0, outline, outline, w-outline*2, h-outline*2, v1.color)
			end
			allianceGrid:AddItem(allianceLabel)
			mrtsAllianceButtons[k1] = {}
			for k2, v2 in pairs(mrtsTeams) do
				local allianceButton = vgui.Create("DCheckBox")
				mrtsAllianceButtons[k1][k2] = allianceButton
				allianceButton:SetSize(size, size)
				allianceGrid:AddItem(allianceButton)
				allianceButton:SetValue(v1.alliances[k2])
				allianceButton.Paint = function(self, w, h)
					if k2 < k1 then
						draw.RoundedBox(0, 1, 1, w-2, h-2, color_black)
						if (self:GetChecked()) then
							draw.RoundedBox(0, outline, outline, w/2, h-outline*2, v1.color)
							draw.RoundedBox(0,  w/2, outline, w/2-outline, h-outline*2, v2.color)
						else
						end
					end
					if k2 > k1 then
						draw.RoundedBox(0, 1, 1, w-2, h-2, MRTS_TROOP_BUTTON_COLOR)
						if (self:GetChecked()) then
							draw.RoundedBox(0, outline, outline, w-outline*2, h-outline*2, MRTS_TROOP_BUTTON_HOVER_COLOR)
						end
					end
				end
				if (k1 != k2) then
					allianceButton.OnChange = function(self, checked)
						net.Start("MRTSRequestAlliance")
							net.WriteInt(k1, 8)
							net.WriteInt(k2, 8)
							net.WriteBool(checked)
						net.SendToServer()
					end
				end
			end
		end

		local tableCorner = vgui.Create("DPanel")
		tableCorner:SetSize(size, size)
		tableCorner.Paint = function(self, w, h)
		end
		allianceGrid:AddItem(tableCorner)
		for k, v in pairs(mrtsTeams) do
			local allianceLabel = vgui.Create("DPanel")
			allianceLabel:SetSize(size, size)
			allianceLabel.Paint = function(self, w, h)
				draw.RoundedBox(0, 0, 0, w, h, color_black)
				draw.RoundedBox(0, outline, outline, w-outline*2, h-outline*2, v.color)
			end
			allianceGrid:AddItem(allianceLabel)
		end

		------------------------------------------------------------------- Elements
		local elementsPanel = vgui.Create( "DPanel", adminSheet )
		adminSheet:AddSheet( "Map", elementsPanel, "icon16/map.png" )
		elementsPanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 100, 100, 100, self:GetAlpha() ) ) end 

		elementsPanel:DockPadding(20,20,20,20)

		local DermaButton = vgui.Create( "DButton", elementsPanel ) 
		DermaButton:SetText( "Place HQ" )		
		DermaButton:Dock(TOP)				
		DermaButton:SetSize( 150, 30 )		
		DermaButton:DockMargin(10,10,10,10)
		DermaButton.DoClick = function()
			for k, v in pairs(mrtsGameData.buildings) do
				if (v.defaultHQ) then
					self:SetPreviewModel(v.model)
					self:SetStage(STAGE_PLACING_BUILDING)
					adminAction = true
					placingClaimable = true
					mrtsPlacingUnitID = k

					if (GetConVar("mrts_playing"):GetBool()) then
						net.Start("MRTSTogglePause")
						net.SendToServer()
					end

					self:CloseGameMenu()
					return
				end
			end
		end

		local DermaButton = vgui.Create( "DButton", elementsPanel ) 
		DermaButton:SetText( "Place Capture Zone" )		
		DermaButton:Dock(TOP)				
		DermaButton:SetSize( 150, 30 )		
		DermaButton:DockMargin(10,10,10,10)
		DermaButton.DoClick = function()	
			self:SetStage(STAGE_PLACING_CAPTURE_ZONE)
			self:CloseGameMenu()
		end

		local DermaButton = vgui.Create( "DButton", elementsPanel ) 
		DermaButton:SetText( "Place Kill Plane" )		
		DermaButton:Dock(TOP)				
		DermaButton:SetSize( 150, 30 )	
		DermaButton:DockMargin(10,10,10,10)	
		DermaButton.DoClick = function()	
			self:SetStage(STAGE_PLACING_BOUND_PLANE)
			self:CloseGameMenu()
		end

		local DermaButton = vgui.Create( "DButton", elementsPanel ) 
		DermaButton:SetText( "Place Bound Pole" )		
		DermaButton:Dock(TOP)				
		DermaButton:SetSize( 150, 30 )	
		DermaButton:DockMargin(10,10,10,10)	
		DermaButton.DoClick = function()	
			self:SetStage(STAGE_PLACING_BOUND_POLE)
			self:CloseGameMenu()
		end

		local DermaButton = vgui.Create( "DButton", elementsPanel ) 
		DermaButton:SetText( "Place Survival HQ" )		
		DermaButton:Dock(TOP)				
		DermaButton:SetSize( 150, 30 )	
		DermaButton:DockMargin(10,10,10,10)	
		DermaButton.DoClick = function()	
			self:SetStage(STAGE_PLACING_SURVIVAL_HQ)
			self:CloseGameMenu()
		end

		------------------------------------------------------------------- Units
		local unitPanel = vgui.Create( "DPanel", adminSheet )
		adminSheet:AddSheet( "Units", unitPanel, "icon16/house.png" )
		unitPanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 100, 100, 100, self:GetAlpha() ) ) end 

		local DScrollPanel = vgui.Create( "DScrollPanel", unitPanel )
		DScrollPanel:Dock(LEFT)
		DScrollPanel:SetSize(150,0)
		DScrollPanel.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, self:GetAlpha()/2 ) )
		end 

		-- Claimable
		local DButton = vgui.Create( "DButton", DScrollPanel )
		DButton:Dock( TOP )
		DButton:SetSize(200, 42)
		DButton:DockMargin( 5, 5, 5, 5 )
		DButton:Paint( 100, 30 )
		DButton:SetText( "" )
		DButton:SetColor(Color(255,255,255))
		DButton.Paint = function( self, w, h )
			self:Clear()
			draw.RoundedBox( 42, 0, 0, w, 42, Color( 255, 255, 255, self:GetAlpha() ) )
			draw.RoundedBox( 42, 5, 5, w-10, 42-10, Color( 0, 0, 0, self:GetAlpha()*0.8 ) )
			draw.DrawText("Claimable", "Trebuchet24", 15, 9)
		end 
		function DButton:DoClick()
			placingClaimable = true
		end

		for k, v in pairs(mrtsTeams) do
			local DButton = vgui.Create( "DButton", DScrollPanel )
			DButton:Dock( TOP )
			DButton:SetSize(200, 42)
			DButton:DockMargin( 5, 5, 5, 5 )
			DButton:Paint( 100, 30 )
			DButton:SetText( "" )
			DButton:SetColor(Color(255,255,255))
			DButton.Paint = function( self, w, h )
				self:Clear()
				draw.RoundedBox( 42, 0, 0, w, 42, Color( v.color.r, v.color.g, v.color.b, self:GetAlpha() ) )
				draw.RoundedBox( 42, 5, 5, w-10, 42-10, Color( 0, 0, 0, self:GetAlpha()*0.8 ) )
				draw.DrawText(v.name, "Trebuchet24", 15, 9)
			end 
			function DButton:DoClick() -- Callback inherited from DLabel, which is DColorButton's base
				placingClaimable = false
				net.Start("MRTSSetTeam")
					net.WriteInt(k, 8)
					net.WriteBool(false)
				net.SendToServer()
			end
		end

		local optionsPanel = vgui.Create("DPanel", unitPanel)
		optionsPanel:Dock(BOTTOM)
		optionsPanel:SetHeight(50)
		optionsPanel.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50 ) )
		end 

		local DermaCheckbox = vgui.Create( "DCheckBoxLabel", optionsPanel ) -- Create the checkbox
		DermaCheckbox:SetPos( 15, 15 )						-- Set the position
		DermaCheckbox:SetText("Capturable")					-- Set the text next to the box
		DermaCheckbox:SetValue( placingCapturable )		-- Initial value
		DermaCheckbox:SizeToContents()						-- Make its size the same as the contents
		DermaCheckbox.OnChange = function( self, isChecked )
			placingCapturable = isChecked
		end

		-- Troops and buildings
		DScrollPanel = vgui.Create( "DScrollPanel", unitPanel )
		DScrollPanel:Dock(FILL)
		DScrollPanel.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, MRTS_DARK_COLOR)
		end 

		local buildingLabel = vgui.Create("DLabel", DScrollPanel)
		buildingLabel:SetTextColor(color_white)
		buildingLabel:SetText("Buildings")
		buildingLabel:SetFont("Trebuchet24")
		buildingLabel:DockMargin(10,15,10,0)
		buildingLabel:Dock(TOP)

		local _team = mrtsTeams[mrtsTeam]
		local unitButtonSize = 34

		local buildingGrid = vgui.Create( "DGrid", DScrollPanel )
		buildingGrid:Dock(TOP)
		buildingGrid:DockMargin(10,10,10,10)
		buildingGrid:SetCols( 2 )
		buildingGrid:SetColWide( 235 )
		buildingGrid:SetRowHeight( 40 )

		for k, v in pairs(mrtsGameData.buildings) do
			local but = MakeMRTSUnitButton(buildingGrid, unitButtonSize, v, false, function()
				self:SetPreviewModel(v.model)
				self:SetStage(STAGE_PLACING_BUILDING)
				adminAction = true
				mrtsPlacingUnitID = k
				self:CloseGameMenu()
			end)
			but:SetWidth(225)
			buildingGrid:AddItem(but)
		end

		local troopLabel = vgui.Create("DLabel", DScrollPanel)
		troopLabel:SetTextColor(color_white)
		troopLabel:SetText("Troops")
		troopLabel:SetFont("Trebuchet24")
		troopLabel:DockMargin(10,15,10,0)
		troopLabel:Dock(TOP)

		local troopGrid = vgui.Create( "DGrid", DScrollPanel )
		troopGrid:Dock(TOP)
		troopGrid:DockMargin(10,10,10,10)
		troopGrid:SetCols( 2 )
		troopGrid:SetColWide( 235 )
		troopGrid:SetRowHeight( 40 )

		for k, v in pairs(mrtsGameData.troops) do
			local but = MakeMRTSUnitButton(troopGrid, unitButtonSize, v, false, function()
				self:SetPreviewModel(v.model)
				self:SetStage(STAGE_PLACING_TROOP)
				adminAction = true
				mrtsPlacingUnitID = k
				self:CloseGameMenu()
			end)
			but:SetWidth(225)
			troopGrid:AddItem(but)
		end

		local partLabel = vgui.Create("DLabel", DScrollPanel)
		partLabel:SetTextColor(color_white)
		partLabel:SetText("Parts")
		partLabel:SetFont("Trebuchet24")
		partLabel:DockMargin(10,15,10,0)
		partLabel:Dock(TOP)

		local partGrid = vgui.Create( "DGrid", DScrollPanel )
		partGrid:Dock(TOP)
		partGrid:DockMargin(10,10,10,10)
		partGrid:SetCols( 2 )
		partGrid:SetColWide( 235 )
		partGrid:SetRowHeight( 40 )

		for k, v in pairs(mrtsGameData.parts) do
			local but = MakeMRTSUnitButton(partGrid, unitButtonSize, v, false, function()
				self:SetPreviewModel(v.model)
				self:SetStage(STAGE_PLACING_PART)
				adminAction = true
				mrtsPlacingUnitID = k
				self:CloseGameMenu()
			end)
			but:SetWidth(225)
			partGrid:AddItem(but)
		end

		------------------------------------------------------------------- Custom datapacks
		local customPanel = vgui.Create( "DPanel", adminSheet )
		adminSheet:AddSheet( "Custom content", customPanel, "icon16/wrench.png" )
		customPanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 100, 100, 100, self:GetAlpha() ) ) end 

		local DLabel = vgui.Create( "DLabel", customPanel )
		DLabel:DockMargin(20,20,20,0)
		DLabel:Dock(TOP)
		DLabel:SetText("Select a datapack. To create your own datapack, go to the data folder and follow the instructions:")

		local DLabel = vgui.Create( "DLabel", customPanel )
		DLabel:DockMargin(20,0,20,0)
		DLabel:Dock(TOP)
		DLabel:SetText("steamapps/common/GarrysMod/garrysmod/data/mrts/datapacks")

		local files, directories = file.Find("mrts/datapacks/*", "DATA")

		-- TODO: this should be a better menu, with instructions, and a separate list for loading normal datapacks and checking and unchecking additive mods
		local DComboBox = vgui.Create( "DComboBox", customPanel )
		DComboBox:DockMargin(20,20,20,0)
		DComboBox:Dock(TOP)
		DComboBox:SetConVar("mrts_datapack")
		for k, v in pairs(directories) do
			DComboBox:AddChoice( v )
		end
		DComboBox.OnSelect = function( self, index, value )
			GetConVar("mrts_datapack"):SetString(value)
			MRTSSendDatapackToServer()
		end

		local DButton = vgui.Create( "DButton", customPanel )
		DButton:DockMargin(20,20,20,0)
		DButton:Dock(TOP)
		DButton:SetText("Reload datapack")
		DButton.DoClick = function( self )
			MRTSSendDatapackToServer()
		end
	end
end

function SWEP:CloseGameMenu()
	if (IsValid(helpPanel)) then
		helpPanel:Close()
	end
	surface.PlaySound("weapons/smg1/switch_single.wav")
	gui.EnableScreenClicker( false )
	--surface.PlaySound("weapons/smg1/switch_single.wav")
	mrtsGameMenu:SetVisible(false)
	--mrtsGameMenu:Close()
	--mrtsGameMenu = nil
end

function SWEP:SetPreviewModel(model)
	if (IsValid(self.preview)) then
		self.preview:SetModel(model)
	else
		self.preview = ents.CreateClientProp()
		self.preview:SetMaterial("models/debug/debugwhite")
		self.preview:SetColor(Color(0,255,0,200))
		self.preview:SetRenderMode(RENDERMODE_TRANSCOLOR)
		self.preview:SetRenderFX(kRenderFxDistort)
		self.preview:SetModel(model)
	end
	/*if (scale == nil) then return end
	local mat = Matrix()
	mat:Scale(scale)
	self.preview:EnableMatrix("RenderMultiply", mat)*/
end

function SWEP:GoToTab(number)
	if (mrtsTeam == -1) then
		mrtsMainSheet:SetActiveTab( mrtsMainSheet:GetItems()[1].Tab )
	else
		mrtsMainSheet:SetActiveTab( mrtsMainSheet:GetItems()[2].Tab )
	end
end

function SWEP:DeletePreview()
	if (IsValid(self.preview)) then
		self.preview:Remove()
	end
	mrtsPreviewBox = nil
end

function SWEP:OnRemove()
	self:DeletePreview()
	if (IsValid(mrtsGameMenu)) then
		mrtsGameMenu:Close()
	end
end

function SWEP:LoadContraptionDialogue()
	mrtsCurrentContraptionStr = str
	local contraptionPanel = vgui.Create("DFrame") -- The name of the panel we don't have to parent it.
	contraptionPanel:SetPos(ScrW()/2-300, ScrH()/2-200) -- Set the position to 100x by 100y. 
	contraptionPanel:SetSize(600, 400) -- Set the size to 300x by 200y.
	contraptionPanel:SetTitle("Load Contraption") -- Set the title in the top left to "Derma Frame".
	contraptionPanel:MakePopup() -- Makes your mouse be able to move around.
	contraptionPanel:DockPadding(10,40,10,10)

	local Button = vgui.Create( "DButton", contraptionPanel )
	Button:Dock( BOTTOM )
	Button:SetText("Load")
	Button:SetEnabled(false)
	Button:DockMargin( 0, 5, 0, 0 )
	
	local browser = vgui.Create( "DFileBrowser", contraptionPanel )
	browser:Dock( FILL )
	browser:SetPath( "DATA" ) -- The access path i.e. GAME, LUA, DATA etc.
	browser:SetBaseFolder( "mrts/contraptions" ) -- The root folder
	browser:SetOpen( true ) -- Open the tree to show sub-folders
	browser:SetCurrentFolder( "mrts/contraptions" )
	function browser:OnSelect( path, pnl ) -- Called when a file is clicked
		local fileName = string.TrimLeft(path, "mrts/contraptions/")
		fileName = string.TrimRight(fileName, ".txt")
		mrtsSelectedContraptionName = fileName
		Button:SetEnabled(true)
	end
	browser.OnDoubleClick = function( browser, path, pnl ) -- Called when a file is clicked
		local fileName = string.TrimLeft(path, "mrts/contraptions/")
		fileName = string.TrimRight(fileName, ".txt")
		mrtsSelectedContraptionName = fileName
		contraptionPanel:Close()
		self:SetStage(STAGE_LOADING_CONTRAPTION)
	end
end

end