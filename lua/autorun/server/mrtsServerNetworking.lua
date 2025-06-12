util.AddNetworkString( "MRTSInitialData" )

util.AddNetworkString( "MRTSMatchStart" )
util.AddNetworkString( "MRTSTogglePause" )
util.AddNetworkString( "MRTSToggleFOW" )
util.AddNetworkString( "MRTSToggleSandbox" )
util.AddNetworkString( "MRTSRecalculate" )
util.AddNetworkString( "MRTSClearEntities" )

util.AddNetworkString( "MRTSSetTeam" )
util.AddNetworkString( "MRTSSetFaction" )
util.AddNetworkString( "MRTSAnnouncePlayerTeam" )

util.AddNetworkString( "MRTSDelete" )
util.AddNetworkString( "MRTSQueueTroop" )
util.AddNetworkString( "MRTSCancelTroop" )
util.AddNetworkString( "MRTSQueueContraption" )
util.AddNetworkString( "MRTSSpawnTroop" )
util.AddNetworkString( "MRTSSpawnPart" )
util.AddNetworkString( "MRTSQueueBuilding" )
util.AddNetworkString( "MRTSSpawnBuilding" )
util.AddNetworkString( "MRTSOrderPosition" )
util.AddNetworkString( "MRTSOrderStop" )
util.AddNetworkString( "MRTSSpawnCaptureZone" )
util.AddNetworkString( "MRTSSpawnBoundPlane" )
util.AddNetworkString( "MRTSSpawnBoundPole" )
util.AddNetworkString( "MRTSSpawnKillPole" )
util.AddNetworkString( "MRTSSpawnSurvivalHQ" )
util.AddNetworkString( "MRTSSpawnConfigurator" )
util.AddNetworkString( "MRTSCancelEntity" )
util.AddNetworkString( "MRTSRequestActivation" )
util.AddNetworkString( "MRTSClaimUnit" )

util.AddNetworkString( "MRTSClientsideAlliances" )
util.AddNetworkString( "MRTSClientsideFX" )
util.AddNetworkString( "MRTSClientsideRing" )
util.AddNetworkString( "MRTSClientsideUnitHit" )
util.AddNetworkString( "MRTSClientsideUnitAttack" )
util.AddNetworkString( "MRTSClientsideUnitStopMoving" )
util.AddNetworkString( "MRTSClientsideUnitNextAttack" )
util.AddNetworkString( "MRTSClientsideUnitCancelWindup" )
util.AddNetworkString( "MRTSClientsideUnitDeath" )
util.AddNetworkString( "MRTSClientsideQueueTroop" )
util.AddNetworkString( "MRTSClientsideCancelTroop" )
util.AddNetworkString( "MRTSClientsideCancelFullQueue" )
util.AddNetworkString( "MRTSClientsideAddStatus" )
util.AddNetworkString( "MRTSClientsideRemoveStatus" )
util.AddNetworkString( "MRTSClientsideNextTroopInQueue" )
util.AddNetworkString( "MRTSClientsideFinishConstruction" )
util.AddNetworkString( "MRTSClientsideUpdateWaypoints" )
util.AddNetworkString( "MRTSClientsideUpdateFOW" )

util.AddNetworkString( "MRTSRequestConfigurator" )
util.AddNetworkString( "MRTSSaveConfigurator" )
util.AddNetworkString( "MRTSRequestMapChangeWalls" )
util.AddNetworkString( "MRTSRequestMapResize" )
util.AddNetworkString( "MRTSRequestMapBuild" )
util.AddNetworkString( "MRTSRequestMapRemove" )
util.AddNetworkString( "MRTSRequestMapBorder" )
util.AddNetworkString( "MRTSRequestAlliance" )

util.AddNetworkString( "MRTSUpdateResource" )
util.AddNetworkString( "MRTSUpdateCapacity" )
util.AddNetworkString( "MRTSUpdateIncome" )
util.AddNetworkString( "MRTSUpdateMaxHousing" )
util.AddNetworkString( "MRTSUpdateUsedHousing" )
util.AddNetworkString( "MRTSUpdateBuildQueue" )
util.AddNetworkString( "MRTSInitializeCaptureZones" )
util.AddNetworkString( "MRTSUpdateCaptureZones" )
util.AddNetworkString( "MRTSChangeTeam" )

util.AddNetworkString( "MRTSRequestServerLoadDefaultDatapack" )
util.AddNetworkString( "MRTSRequestClientLoadDefaultDatapack" )
util.AddNetworkString( "MRTSRequestClientDatapack" )
util.AddNetworkString( "MRTSReceiveClientDatapack" )
util.AddNetworkString( "MRTSStartDatapackTransfer" )
util.AddNetworkString( "MRTSDatapackTroop" )
util.AddNetworkString( "MRTSDatapackBuilding" )
util.AddNetworkString( "MRTSDatapackPart" )
util.AddNetworkString( "MRTSDatapackComplete" )
util.AddNetworkString( "MRTSClientsideNotification" )

util.AddNetworkString( "MRTSResetDebug" )
util.AddNetworkString( "MRTSDebugBox" )

util.AddNetworkString( "MRTSSaveContraption" )
util.AddNetworkString( "MRTSLoadContraption" )

util.AddNetworkString( "MRTSBigStringTransfer" )

-- Save and load
util.AddNetworkString( "MRTSEntityPasted" )

net.Receive("MRTSChangeTeam", function (len, pl)
	local ply = net.ReadEntity(ply)
	local newTeam = net.ReadInt(8)
end)

net.Receive( "MRTSRequestServerLoadDefaultDatapack", function() 
	MRTSLoadDefaultPack()
	MRTSBroadcastDatapack()
end)

net.Receive("MRTSReceiveClientDatapack", function( len, ply )
	MRTSBroadcastDatapack()
end)

function MRTSBroadcastDatapack()
	print("Broadcasting datapack")
	for k, v in pairs(player.GetAll()) do
		MRTSTransferDatapack(v)
	end
end

function MRTSTransferDatapack(ply)
	print("Sending datapack to "..ply:Nick())
	net.Start("MRTSStartDatapackTransfer")
		net.WriteTable(mrtsGameData.info)
	net.Send(ply)
	for k, v in pairs(mrtsGameData.troops) do
		net.Start("MRTSDatapackTroop")
			net.WriteTable(v)
		net.Send(ply)
	end
	for k, v in pairs(mrtsGameData.buildings) do
		net.Start("MRTSDatapackBuilding")
			net.WriteTable(v)
		net.Send(ply)
	end
	for k, v in pairs(mrtsGameData.parts) do
		net.Start("MRTSDatapackPart")
			net.WriteTable(v)
		net.Send(ply)
	end
	net.Start("MRTSDatapackComplete")
		net.WriteTable(mrtsGameData.resources)
		net.WriteTable(mrtsGameData.teams)
		net.WriteTable(mrtsGameData.factions)
		net.WriteTable(mrtsGameData.status)
	net.Send(ply)
end

net.Receive("MRTSDelete", function()
	local entity = net.ReadEntity()
	if (IsValid(entity)) then
		if (entity:GetCapturable() or entity:GetData().objective) then return end
		effectdata = EffectData()
		effectdata:SetEntity( entity )
		util.Effect( "entity_remove", effectdata )
		sound.Play("buttons/button19.wav", entity:GetPos(), 100, 100+math.random(15), 0.7)
		entity:Remove()
	end
end)

net.Receive( "MRTSMatchStart", function()
	--Save alliances
	local alliances = {}
	for k, v in pairs(mrtsTeams) do
		alliances[k] = v.alliances
	end

	MRTSLoadTeams()
	MRTSRecalculateTeams()
    MRTSStartMatch()

	--Load alliances
	for k, v in pairs(mrtsTeams) do
		v.alliances = alliances[k]
	end
	net.Start("MRTSMatchStart")
	net.Broadcast()
end)

net.Receive( "MRTSClearEntities", function()
	if (mrtsSavedState == nil) then return false end
	for k, v in pairs(ents.FindByClass("ent_mrts_building")) do
		v:Remove()
	end
	if (mrtsSavedState.buildings != nil) then
		for k, v in pairs(mrtsSavedState.buildings) do
			MRTSSpawnBuilding(v.team, GetBuildingIDByUniqueName(v.name), v.pos, v.ang, nil, true, v.capturable, v.claimable)
		end
	end
	for k, v in pairs(ents.FindByClass("ent_mrts_troop")) do
		v:Remove()
	end
	if (mrtsSavedState.troops != nil) then
		for k, v in pairs(mrtsSavedState.troops) do
			if (IsValid(v.entity)) then
				v.entity:Remove()
			end
			MRTSSpawnTroop(v.team, GetTroopIDByUniqueName(v.name), v.pos, nil, true, false, v.capturable, v.claimable)
		end
	end
	for k, v in pairs(ents.FindByClass("ent_mrts_capture_zone")) do
		v.capture = 0
		v.capturingTeam = 0
		v:ChangeTeam(0)
		MRTSUpdateCaptureZone(v)
	end
end)

net.Receive( "MRTSTogglePause", function()
	GetConVar("mrts_playing"):SetBool(not GetConVar("mrts_playing"):GetBool())

	for k, v in pairs(mrtsUnits) do
		v:GetPhysicsObject():Sleep()
	end
end)

net.Receive( "MRTSToggleFOW", function()
	GetConVar("mrts_fow"):SetBool(not GetConVar("mrts_fow"):GetBool())
end)

net.Receive( "MRTSToggleSandbox", function()
	GetConVar("mrts_sandbox_mode"):SetBool(not GetConVar("mrts_sandbox_mode"):GetBool())
end)

net.Receive( "MRTSRecalculate", function()
	MRTSReset()
	MRTSRecalculateTeams()
end)

net.Receive( "MRTSMatchEnd", function()
	for k, v in pairs(ents.FindByClass("ent_mrts_building")) do
		v:Remove()
	end
	for k, v in pairs(ents.FindByClass("ent_mrts_projectile")) do
		v:Remove()
	end
	for k, v in pairs(ents.FindByClass("ent_mrts_troop")) do
		v:Remove()
	end
	for k, v in pairs(ents.FindByClass("ent_mrts_capture_zone")) do
		v:Remove()
	end
	MRTSDefaultTeams()
	MRTSUpdateAll()
end)

net.Receive( "MRTSSetTeam", function(len, pl)
	local requestedTeam = net.ReadInt(8)
	local shouldUpdateMenu = net.ReadBool()
	MRTSSetTeam(pl, requestedTeam, shouldUpdateMenu)
	
	net.Start("MRTSAnnouncePlayerTeam")
		net.WriteBool(true)
		net.WriteInt(requestedTeam, 8)
		net.WriteString(pl:Nick())
	net.Broadcast()
end)

net.Receive( "MRTSSetFaction", function(len, pl)
	local team = net.ReadInt(8)
	local requestedFaction = net.ReadInt(8)
	MRTSSetFaction(team, requestedFaction)
end)

net.Receive( "MRTSOrderPosition", function()
	local position = net.ReadVector();
	local waypoint = net.ReadBool();
	local attackmove = net.ReadBool();
	local entity = net.ReadEntity();
	while (not entity:IsWorld() and entity:IsValid() and entity != nil) do
		entity:OrderPosition(position, waypoint, attackmove);
		entity = net.ReadEntity();
	end
	/*

	-- Parallel movement (reduces collisions)
	local position = net.ReadVector();
	local waypoint = net.ReadBool();
	local attackmove = net.ReadBool();
	local entity = net.ReadEntity();
	local entities = {entity}
	local posSum = entity:GetPos()
	local count = 1
	table.insert(entities, entity)
	while (entity:IsValid() and entity != nil) do
		entity = net.ReadEntity();
		if (not entity:IsWorld()) then
			table.insert(entities, entity)
			posSum = posSum+entity:GetPos()
			count = count+1
		end
	end
	if (count > 1) then
		local startAvg = posSum/count
		local difference = position - startAvg
		for k, v in ipairs(entities) do
			v:OrderPosition(v:GetPos()+difference, waypoint, attackmove);
		end
	else
		entities[1]:OrderPosition(position, waypoint, attackmove);
	end

	*/
end )

net.Receive( "MRTSOrderStop", function()
	local entity = net.ReadEntity();
	while (not entity:IsWorld() and entity:IsValid() and entity != nil) do
		entity:FinishAllMovement();
		entity = net.ReadEntity();
	end
end )

net.Receive( "MRTSSpawnCaptureZone", function(len, pl)
	local pos = net.ReadVector()
	/*
	local _pos = net.ReadVector()

	pos = Vector(math.Round(_pos.x/grid)*grid-grid/2, math.Round(_pos.y/grid)*grid-grid/2, _pos.z)
	foundEnts = ents.FindInBox( _pos-Vector(0.24, 0.24, 0.4)*grid, _pos+Vector(0.24, 0.24, 0.4)*grid )
	*/
	local newUnit = ents.Create("ent_mrts_capture_zone")
	newUnit:SetPos(pos)
	newUnit:Spawn()
	if (pl != nil) then
		undo.Create("Unit")
			undo.AddEntity(newUnit)
			undo.SetPlayer(pl)
		undo.Finish()
	end
end )

net.Receive( "MRTSSpawnBoundPlane", function(len, pl)
	local pos = net.ReadVector()
	local newUnit = ents.Create("ent_mrts_bound_plane")
	newUnit:SetPos(pos+Vector(0,0,2))
	newUnit:SetAngles(Angle(0,0,90))
	newUnit:Spawn()
	if (pl != nil) then
		undo.Create("Unit")
			undo.AddEntity(newUnit)
			undo.SetPlayer(pl)
		undo.Finish()
	end
end )

net.Receive( "MRTSSpawnBoundPole", function(len, pl)
	local pos = net.ReadVector()
	local newUnit = ents.Create("ent_mrts_bound_pole")
	newUnit:SetPos(pos+Vector(0,1.5,6))
	newUnit:Spawn()
	newUnit:ConnectToLastPole()
	if (pl != nil) then
		undo.Create("Unit")
			undo.AddEntity(newUnit)
			undo.SetPlayer(pl)
		undo.Finish()
	end
end )

net.Receive( "MRTSSpawnKillPole", function(len, pl)
	local pos = net.ReadVector()
	local newUnit = ents.Create("ent_mrts_kill_pole")
	newUnit:SetPos(pos+Vector(0,1.5,6))
	newUnit:Spawn()
	newUnit:ConnectToLastPole()
	if (pl != nil) then
		undo.Create("Unit")
			undo.AddEntity(newUnit)
			undo.SetPlayer(pl)
		undo.Finish()
	end
end )

net.Receive( "MRTSSpawnSurvivalHQ", function(len, pl)
	local pos = net.ReadVector()
	local newUnit = ents.Create("ent_mrts_survival_hq")
	newUnit:SetPos(pos+Vector(0,0,85))
	newUnit:SetAngles(Angle(0,0,0))
	newUnit:Spawn()
	if (pl != nil) then
		undo.Create("Unit")
			undo.AddEntity(newUnit)
			undo.SetPlayer(pl)
		undo.Finish()
	end
end )

net.Receive( "MRTSSpawnConfigurator", function(len, pl)
	local grid = mrtsGridSize
	local _pos = net.ReadVector()
	local _team = net.ReadInt(8)
	local _buildingID = net.ReadInt(8)

	local configs = ents.FindByClass("ent_mrts_configurator")
	if (#configs == 0) then
		local newUnit = ents.Create("ent_mrts_configurator")
		newUnit:SetPos(_pos+Vector(0,0,10))
		newUnit:Spawn()
		mrtsMapController = newUnit
		if (pl != nil) then
			undo.Create("Unit")
				undo.AddEntity(newUnit)
				undo.SetPlayer(pl)
			undo.Finish()
		end
	else
		PrintMessage(HUD_PRINTTALK, "There is a map controller already")
	end
end )

net.Receive( "MRTSQueueTroop", function (len, pl)
	local building = net.ReadEntity()
	if (building:GetUnderConstruction()) then return end
	local troopData = GetTroopByUniqueName(building:GetData().makesTroop.troop)
	local cost = building:GetData().makesTroop.cost
	local teamID = building:GetTeam()
	local team = mrtsTeams[teamID]
	if (not GetConVar("mrts_sandbox_mode"):GetBool()) then
		if (not MRTSMeetsUnitRequirements(teamID, troopData, cost)) then return end
		for k, v in pairs(cost) do
			MRTSAffectResource(teamID, -v, k)
		end
	end
	building:QueueTroop(troopID)
	net.Start("MRTSClientsideQueueTroop")
		net.WriteEntity(building)
	net.Broadcast()
end)

net.Receive( "MRTSQueueContraption", function (len, pl)
	local assembler = net.ReadEntity()
	print("Pasting contraption")
	local dupeTable = util.JSONToTable(assembler.contraption)
	/*local corner = dupeTable.Mins+dupeTable.Maxs
	print(dupeTable.Mins)
	print(dupeTable.Maxs)*/
	duplicator.SetLocalPos(assembler:GetPos()+Vector(0,0,20))
	local entities, constraints = duplicator.Paste( pl, dupeTable.Entities, dupeTable.Constraints )
	duplicator.SetLocalPos(Vector(0,0,0))

	local newContraption = table.Copy(MRTSContraptionClass)
	for k, v in pairs(entities) do
		local class = v:GetClass()
		if (class == "ent_mrts_part") then
			table.insert(newContraption.parts, v)
			
		else
			table.insert(newContraption.props, v)
			
		end
	end
end)

net.Receive( "MRTSRequestActivation", function (len, pl)
	local entity = net.ReadEntity()
	entity:Interact()
end)

net.Receive( "MRTSClaimUnit", function (len, pl)
	local entity = net.ReadEntity()
	local team = net.ReadInt(8)
	
	-- Replace
	if (team == -1) then
		entity:ChangeTeam(-1)
		return
	end

	local faction = mrtsGameData.factions[mrtsTeams[team].faction]
	if (faction) then
		if (faction.replacements) then
			for k, v in pairs(faction.replacements) do
				if (v[1] == entity:GetData().uniqueName) then

					local buildingID = 0
					local newBuildingData = nil
					for kk, vv in pairs(mrtsGameData.buildings) do
						if (vv.uniqueName == v[2]) then
							buildingID = kk
							newBuildingData = vv
						end
					end

					local originalPosition = entity:GetPos()
					local o = entity:GetData().offset or {x=0,y=0,z=0}
					local offset = Vector(o.x, o.y, o.z)
					offset:Rotate(entity:GetAngles())

					local originalAngles = entity:GetAngles()
					local a = entity:GetData().angle or {x=0,y=0,z=0}
					local angle = Angle(a.x, a.y, a.z)

					local no = newBuildingData.offset or {x=0,y=0,z=0}
					local newOffset = Vector(no.x, no.y, no.z)
					newOffset:Rotate(originalAngles-angle)

					local na = newBuildingData.angle or {x=0,y=0,z=0}
					local newAngle = Angle(a.x, a.y, a.z)

					MRTSSpawnBuilding(team, buildingID, originalPosition-offset+newOffset, originalAngles-angle+newAngle, pl, true, false, false)
					entity:Remove()
					return true
				end
			end
		end
	end

	-- Change team
	entity:ChangeTeam(team)
end)

net.Receive( "MRTSCancelEntity", function (len, pl)
	local entity = net.ReadEntity()
	if (entity:GetUnderConstruction()) then
		--entity:CancelConstruction(entity:GetTeam())
		entity:Remove()
	else
		if (entity:GetClass() == "ent_mrts_building") then
			if (entity:GetData().makesTroop) then
				entity:CancelTroop()
				net.Start("MRTSClientsideCancelTroop")
					net.WriteEntity(entity)
				net.Broadcast()
			end
		end
	end
end)
/*
net.Receive( "MRTSCancelTroop", function (len, pl)
	local building = net.ReadEntity()
	building:CancelTroop(unitID, positionInQueue)
	net.Start("MRTSClientsideCancelTroop")
		net.WriteEntity(building)
	net.Broadcast()
end)
*/
net.Receive( "MRTSQueueBuilding", function (len, pl)
	local building = net.ReadEntity()
	local buildingID = net.ReadInt(8)
	local pos = net.ReadVector()

	if (not MRTSMeetsUnitRequirements(teamID, troopData)) then return end
	for k, v in pairs(mrtsGameData.buildings[buildingID].cost) do
		MRTSAffectResource(building:GetTeam(), -v, k)
	end

	building:QueueBuilding(buildingID, pos)

	/*net.Start("MRTSClientsideQueueBuilding")
		net.WriteEntity(building)
		net.WriteInt(buildingID, 8)
	net.Broadcast()*/
end)

net.Receive( "MRTSSpawnBuilding", function (len, pl)
	local teamID = net.ReadInt(8)
	local unitID = net.ReadInt(8)
	local pos = net.ReadVector()
	local angle = net.ReadAngle()
	local adminAction = net.ReadBool()
	local capturable = net.ReadBool()
	local claimable = net.ReadBool()
	local trace = net.ReadTable()
	local buildingData = mrtsGameData.buildings[unitID]

	if (claimable) then
		teamID = 0
	end

	if (not GetConVar("mrts_sandbox_mode"):GetBool() and not adminAction) then
		--Copied from weapon_mrts' clientside verification--
		local sizeVector = Vector(buildingData.size.x, buildingData.size.y, buildingData.size.z)
		local offset = Vector(0,0,0)
		local testAngle = Angle(angle.x,angle.y,angle.z)

		if (buildingData.offset) then
			offset = Vector(buildingData.offset.x, buildingData.offset.y, buildingData.offset.z)
			offset:Rotate(angle)
		end
		--sizeVector:Rotate(testAngle)
		local canPlace, pos = MRTSCanPlaceBuilding(trace,buildingData,sizeVector,testAngle,teamID)
		if (not canPlace) then return false end
		------------------------------------------------------
	
		if (not MRTSMeetsUnitRequirements(teamID, buildingData)) then return end
		for k, v in pairs(buildingData.cost) do
			MRTSAffectResource(teamID, -v, k)
		end
	end

	local newBuilding = MRTSSpawnBuilding(teamID, unitID, pos, angle, pl, adminAction, capturable, claimable)
	if (capturable) then
		newBuilding:SetCapturable(true)
	end
	if (claimable) then
		newBuilding:SetClaimable(true)
	end
end );

net.Receive( "MRTSSpawnTroop", function (len, pl)
	local teamID = net.ReadInt(8)
	local unitID = net.ReadInt(8)
	local pos = net.ReadVector()
	local adminAction = net.ReadBool()
	local capturable = net.ReadBool()
	local claimable = net.ReadBool()
	local trace = net.ReadTable()
	local troopData = mrtsGameData.troops[unitID]

	if (claimable) then
		teamID = 0
	end

	if (not adminAction) then
		local canPlace, pos, message = MRTSCanPlaceTroop(trace, troopData, troopData.size, teamID)
		if (not canPlace) then
			MRTSSendNotification(pl, message, 1, 3)
			return
		end
	end

	if (not GetConVar("mrts_sandbox_mode"):GetBool() and not adminAction) then
		if (not MRTSMeetsUnitRequirements(teamID, troopData)) then return end
		for k, v in pairs(troopData.cost) do
			MRTSAffectResource(teamID, -v, k)
		end
	end
	
	MRTSSpawnTroop(teamID, unitID, pos, pl, adminAction, false, capturable, claimable)
end );

net.Receive( "MRTSSpawnPart", function (len, pl)
	local teamID = net.ReadInt(8)
	local unitID = net.ReadInt(8)
	local pos = net.ReadVector()
	local adminAction = net.ReadBool()
	local trace = net.ReadTable()
	local partData = mrtsGameData.parts[unitID]

	/*if (not GetConVar("mrts_sandbox_mode"):GetBool() and not adminAction) then
		if (not MRTSMeetsUnitRequirements(teamID, partData)) then return end
		for k, v in pairs(partData.cost) do
			MRTSAffectResource(teamID, -v, k)
		end
	end*/
	
	MRTSSpawnPart(teamID, unitID, pos, pl, adminAction, true, trace)
end );

net.Receive( "MRTSRequestMapChangeWalls", function (len, pl)
	print("Received map int array")
	local intArray = {}
	local ints = net.ReadUInt(32)
	for i=1, ints do
		table.insert(intArray, net.ReadUInt(32))
	end
	if (IsValid(mrtsMapController)) then
		mrtsMapController:ReceiveNewWalls(intArray, pl)
	end
end );

net.Receive( "MRTSRequestMapResize", function(len,pl)
	local width = net.ReadUInt(16)
	local height = net.ReadUInt(16)
	if (IsValid(mrtsMapController)) then
		mrtsMapController:ReceiveNewSize(width, height)
	end
end)

net.Receive( "MRTSRequestMapBuild", function (len, pl)
	if (IsValid(mrtsMapController)) then
		mrtsMapController:CalculateGreedyMeshing()
	end
end)

net.Receive( "MRTSRequestMapRemove", function (len, pl)
	if (IsValid(mrtsMapController)) then
		mrtsMapController:RemoveProps()
	end
end)

net.Receive( "MRTSRequestMapBorder", function(len,pl)
	if (IsValid(mrtsMapController)) then
		mrtsMapController:ToggleMapBorder()
	end
end)

net.Receive( "MRTSRequestAlliance", function(len, pl)
	local team1 = net.ReadInt(8)
	local team2 = net.ReadInt(8)
	local isAllied = net.ReadBool()

	MRTSSetAlliance(team1, team2, isAllied)

	local alliances = {}
	for k, v in pairs(mrtsTeams) do
		alliances[k] = v.alliances
	end
	net.Start("MRTSClientsideAlliances")
		net.WriteTable(alliances)
	net.Broadcast()
end)

local constraintTypes = {
	"Weld",
	"Axis",
	"AdvBallsocket",
	"Rope",
	"Elastic",
	"NoCollide",
	"Motor",
	"Pulley",
	"Ballsocket",
	"Winch",
	"Hydraulic",
	"Muscle",
	"Keepupright",
	"Slider"
}

net.Receive( "MRTSSaveContraption", function(len, pl)
	local entity = net.ReadEntity()
	
	local myTable = {
		Entities={},
		Constraints={},
		Mins=Vector(0,0,0),
		Maxs=Vector(0,0,0)
	}

	local pos = entity:GetPos()
	local min, max = entity:WorldSpaceAABB()
	pos.z = min.z
	duplicator.SetLocalPos(pos)
	local myTable = duplicator.CopyEnts({entity})
	duplicator.SetLocalPos(Vector(0,0,0))

	local sanitizedEntities = {}

	for k, v in pairs(myTable.Entities) do
		if (v.Class == "ent_mrts_troop") then
			table.insert(sanitizedEntities, k, MRTSSanitizeTroopTable(v))
		else
			table.insert(sanitizedEntities, k, v)
		end
	end

	local finalDupeTable = {
		Entities=sanitizedEntities,
		Constraints=myTable.Constraints,
		Mins=myTable.Mins,
		Maxs=myTable.Maxs
	}

	MRTSSendBigString(util.TableToJSON(finalDupeTable), {purpose="SaveContraption"}, pl)
end)