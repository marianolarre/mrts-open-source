CreateConVar( "mrts_sandbox_mode", "0", FCVAR_REPLICATED )
CreateConVar( "mrts_playing", "1", FCVAR_REPLICATED )
CreateConVar( "mrts_lock_map_entities", "1", FCVAR_REPLICATED )
CreateConVar( "mrts_fow", "0", FCVAR_REPLICATED )
CreateConVar( "mrts_max_population", "80", FCVAR_REPLICATED )
CreateConVar( "mrts_allow_grav_gun_pickup", "0")

mrtsUnits = ents.FindByClass("ent_mrts_troop")
mrtsSquads = {}
mrtsPassiveSquads = {}

mrtsNextSquadUpdate = 0
mrtsUpdateSquadDelay = 4
mrtsNextSquadMove = 0
mrtsMoveSquadDelay = 0.25

mrtsMaxSquadCapacity = 25
mrtsMaxPassiveSquadArea = 250*250

mrtsNextUnitThink = 0
mrtsUnitThinkDelay = 1/6
mrtsNextIncomeThink = 0
mrtsIncomeThinkDelay = 1

mrtsEvents = {}
mrtsEventUnitCountObservers = {}

mrtsCustomDatapackName = "unnamed"
mrtsMapController = nil

mrtsColorRed = Color(255,0,0)
mrtsColorLime = Color(0,255,0)

mrtsSavedState = nil

cvars.AddChangeCallback("mrts_fow", function(convar_name, value_old, value_new)
	mrtsFOW = value_new
	net.Start("MRTSClientsideUpdateFOW")
		net.WriteBool(mrtsFOW == "1")
	net.Broadcast()
end)


/*
mrtsHasCustomDatapack = false
hook.Add( "Initialize", "mrts_initialize", function()
	if (GetConVar("mrts_datapack"):GetString() != "default") then
		mrtsHasCustomDatapack = true
	else
		mrtsHasCustomDatapack = false
	end
end )
*/

--eventTypes
--0: UnitCount: have <comparisson> <number> <unit type>

--comparissons
-- -2: less than
-- -1: at most
--  0: exactly
--  1: at least
--  2: more than

local MRTSSquadClass = {};
MRTSSquadClass.units = {};
MRTSSquadClass.mins = Vector(0,0,0);
MRTSSquadClass.maxs = Vector(0,0,0);
MRTSSquadClass.dirty = false;
MRTSSquadClass.team = -1;
MRTSSquadClass.closestEnemySquad = 1000000;

local function MRTSSendDebugSquads()
	net.Start("MRTSResetDebug")
	net.Broadcast()
	for k, v in pairs(mrtsPassiveSquads) do
		net.Start("MRTSDebugBox")
			net.WriteVector(v.mins)
			net.WriteVector(v.maxs)
		net.Broadcast()
	end
end

local function MRTSGetSquadArea(squad)
	local width = squad.maxs.x-squad.mins.x
	local depth = squad.maxs.y-squad.mins.y
	return width*depth
end

local function MRTSSquad(units, _team)
	local newSquad = table.Copy(MRTSSquadClass);
	newSquad.units = units
	newSquad.team = _team
	newSquad.dirty = true
	for k, v in pairs(units) do
		v.squad = newSquad
	end
	MRTSUpdateSquadBoundaries(newSquad)
	MRTSUpdateSquadClosest(newSquad)
	table.insert(mrtsSquads, newSquad)
	return newSquad;
end

local MRTSPassiveSquadClass = {};
MRTSPassiveSquadClass.units = {};
MRTSPassiveSquadClass.mins = Vector(0,0,0);
MRTSPassiveSquadClass.maxs = Vector(0,0,0);
MRTSPassiveSquadClass.team = -1;

local function MRTSPassiveSquad(units, _team)
	local newSquad = table.Copy(MRTSPassiveSquadClass);
	newSquad.units = units
	newSquad.team = _team
	for k, v in pairs(units) do
		v.squad = newSquad
	end
	MRTSUpdateSquadBoundaries(newSquad)
	table.insert(mrtsPassiveSquads, newSquad)
	return newSquad;
end

function MRTSAddToPassiveSquads(unit)
	local foundEntities = ents.FindInSphere(unit:GetPos(), 500)
	for foundEnt_k, foundEnt in pairs(foundEntities) do
		if (foundEnt:GetClass() == "ent_mrts_building") then
			if (foundEnt.squad != nil) then
				if (foundEnt:GetTeam() == unit:GetTeam()) then
					if (MRTSGetSquadArea(foundEnt.squad) < mrtsMaxPassiveSquadArea) then
						unit.squad = foundEnt.squad
						table.insert(foundEnt.squad.units, unit)
						MRTSUpdateSquadBoundaries(foundEnt.squad)
						return
					end
				end
			end
		end
	end
	MRTSPassiveSquad({unit}, unit:GetTeam())
end

function MRTSUpdateSquadBoundaries(squad)
	if (#squad.units > 0) then
		local randomUnit = table.GetFirstValue( squad.units )
		if (not IsValid(randomUnit)) then return end
		squad.mins = randomUnit:GetPos()
		squad.maxs = randomUnit:GetPos()
		for k, v in pairs(squad.units) do
			if (IsValid(v)) then
				local pos = v:GetPos()
				local size = v:GetData().size
				if (istable(size)) then
					size = math.max(size.x, size.y, size.z)
				end
				if (pos.x-size < squad.mins.x) then squad.mins.x = pos.x-size end
				if (pos.y-size < squad.mins.y) then squad.mins.y = pos.y-size end
				//if (pos.z < squad.mins.z) then squad.mins.z = pos.z end
				if (pos.x+size > squad.maxs.x) then squad.maxs.x = pos.x+size end
				if (pos.y+size > squad.maxs.y) then squad.maxs.y = pos.y+size end
				//if (pos.z > squad.maxs.z) then squad.maxs.z = pos.z end
			else
				table.RemoveByValue(squad.units, v)
			end
		end
		squad.mins = squad.mins
		squad.maxs = squad.maxs
	end
end

function MRTSUpdateSquadClosest(squad)
	local closestDistance = 1000000
	for i=0, 1 do
		local checking
		if (i == 0) then
			checking = mrtsSquads
		else
			checking = mrtsPassiveSquads
		end
		for k, v in pairs(checking) do
			if (v != squad) then
				if (v.team != squad.team) then
					local xdist = 0
					local ydist = 0
					local dist = 0
					if (v.maxs.x < squad.mins.x) then xdist = xdist+squad.mins.x-v.maxs.x end
					if (v.mins.x > squad.maxs.x) then xdist = xdist+v.mins.x-squad.maxs.x end
					if (v.maxs.y < squad.mins.y) then ydist = ydist+squad.mins.y-v.maxs.y end
					if (v.mins.y > squad.maxs.y) then ydist = ydist+v.mins.y-squad.maxs.y end
					if (xdist > 0 and ydist > 0) then
						dist = math.sqrt(xdist*xdist+ydist*ydist)
					else
						dist = xdist+ydist
					end
					if (dist < closestDistance) then
						closestDistance = dist
					end
				end
			end
		end
	end
	squad.closestEnemySquad = closestDistance
end

function MRTSSaveState()
	mrtsSavedState = {buildings={}, troops={}}
	for k, v in pairs(ents.FindByClass("ent_mrts_building")) do
		table.insert(mrtsSavedState.buildings, {
			name=v:GetData().uniqueName,
			entity=v,
			pos=v:GetPos(),
			ang=v:GetAngles(),
			team=v:GetTeam(),
			claimable=v:GetClaimable(),
			capturable=v:GetCapturable(),
		})
	end
	for k, v in pairs(ents.FindByClass("ent_mrts_troop")) do
		table.insert(mrtsSavedState.troops, {
			name=v:GetData().uniqueName,
			entity=v,
			pos=v:GetPos(),
			ang=v:GetAngles(),
			team=v:GetTeam(),
			claimable=v:GetClaimable(),
			capturable=v:GetCapturable(),
		})
	end
end

function MRTSStartMatch()
/*
	-- Test event
	mrtsEvents[1] = {
		eventType = 0,
		comparisson = 1,
		unitType = "marine",
		number = 10,
		resource = "",
		counter = 0
	}

	for tk, t in pairs(mrtsTeams) do
		if (t.enabled) then
			print("Enabled team: "..t.name)
			for k, v in pairs(mrtsEvents) do
				--???
			end
		end
	end*/

	MRTSSaveState()
	for k, v in pairs(ents.FindByClass("ent_capture_zone")) do
		v:ChangeTeam(0)
	end

	GetConVar("mrts_playing"):SetBool(false)
	for i=0, 3 do
		timer.Simple(i, function() 
			if (i < 3) then
				PrintMessage(HUD_PRINTCENTER, "Match starting in "..(3-i))
			else
				PrintMessage(HUD_PRINTCENTER, "Match started!")

				GetConVar("mrts_playing"):SetBool(true)
				MRTSReset()
				MRTSRecalculateTeams()

				for k, v in pairs(ents.FindByClass("ent_mrts_building")) do
					if (v:GetClaimable()) then
						v:SetClaimable(false)
					end
					if (v:GetTeam() < 0) then
						v:Remove()
					end
				end

				for k, v in pairs(ents.FindByClass("ent_mrts_survival_hq")) do
					v:Begin()
				end
			end
		end)
	end
end
/*
function MRTSCalculateCaptureZones()
	local count = 0
	mrtsCaptureZones = {}
	for k, zone in pairs(ents.FindByClass("ent_mrts_capture_zone")) do
		zone:SetZoneID(0)
	end

	for k, zone in pairs(ents.FindByClass("ent_mrts_capture_zone")) do
		if (zone:GetZoneID() == 0) then
			count = count+1
			local newID = count
			mrtsCaptureZones[newID] = table.Copy(MRTSCaptureZoneClass)
			zone:SetZoneID(newID)
			MRTSRecruitNeighbouringCaptureZones(zone, 0)
		end
	end

	net.Start("MRTSInitializeCaptureZones")
		net.WriteInt(count, 8) -- Count
	net.Broadcast()
end
*/
function MRTSUpdateCaptureZone(zone)
	net.Start("MRTSUpdateCaptureZones")
		net.WriteEntity(zone)
		net.WriteFloat(zone.capture)
		net.WriteTable(zone.captureSpeed)
		net.WriteBool(zone.contested)
		net.WriteInt(zone.capturingTeam, 8)
		net.WriteInt(zone.team, 8)
	net.Broadcast()
end

---------------- Player Initial Spawn Dirty Hack
hook.Add( "PlayerInitialSpawn", "FullLoadSetup", function( ply )
	print("Player initial spawn: "..ply:Nick())

	hook.Add( "SetupMove", ply, function( self, ply, _, cmd )
		if self == ply and not cmd:IsForced() then
			hook.Run( "PlayerFullLoad", self )
			hook.Remove( "SetupMove", self )
		end
	end )

	-- Assign team with least players
	local teamWithLeastPlayers = 1
	local leastPlayerCount = 128
	for k, v in pairs(mrtsTeams) do
		if (k != 0) then
			local playerCount = #team:GetPlayers(k)
			if (playerCount < leastPlayerCount) then
				leastPlayerCount = playerCount
				teamWithLeastPlayers = k
			end
		end
	end
	print("teamWithLeastPlayers: "..teamWithLeastPlayers)
	MRTSSetTeam(ply, teamWithLeastPlayers, true)

	local alliances = {}
	for k, v in pairs(mrtsTeams) do
		alliances[k] = v.alliances
	end
	net.Start("MRTSClientsideAlliances")
		net.WriteTable(alliances)
	net.Send(ply)

	--if (mrtsHasCustomDatapack) then
		if (ply:IsAdmin() or game.SinglePlayer()) then
			print("Requesting admin's MRTS datapack")
			net.Start("MRTSRequestClientDatapack")
				--net.WriteString(GetConVar("mrts_datapack"):GetString())
			net.Send(ply)
		else
			MRTSTransferDatapack(ply)
		end
	/*else
		net.Start("MRTSRequestClientLoadDefaultDatapack")
		net.Send(ply)
	end*/
	/*
	net.Start("MRTSInitialData")
		net.WriteTable(mrtsTeams)
	net.Send(ply)
	*/
end )

function MRTSSetTeam(pl, _team, shouldUpdateMenu)
	pl.mrtsTeam = _team
	pl:SetTeam(_team)
	net.Start("MRTSSetTeam")
		net.WriteInt(_team, 8)
		net.WriteBool(shouldUpdateMenu)
	net.Send(pl)
end

function MRTSSetFaction(_team, factionID)
	mrtsTeams[_team].faction = factionID
	net.Start("MRTSSetFaction")
		net.WriteInt(_team, 8)
		net.WriteInt(factionID, 8)
	net.Broadcast()
end

function MRTSAddUnitToBuildQueue(teamID, unit)
	if (#mrtsTeams[teamID].buildQueue == 0) then
		mrtsTeams[teamID].nextBuild = CurTime()+(unit:GetData().buildTime or 0.1)
	end
	table.insert(mrtsTeams[teamID].buildQueue, {
		unit=unit,
		time=unit:GetData().buildTime or 0.1
	})
	MRTSUpdateBuildQueue(teamID)
end

function MRTSSetAlliance(team1, team2, isAllied)
	mrtsTeams[team1].alliances[team2] = isAllied
	mrtsTeams[team2].alliances[team1] = isAllied
end

function MRTSSpawnTroop(teamID, unitID, pos, pl, ready, preallocated, capturable, claimable)

	local newUnit = ents.Create("ent_mrts_troop")
	newUnit:SetTeam(teamID)
	newUnit:SetUnitID(unitID)
	newUnit:SetPos(pos)

	local instant = GetConVar("mrts_sandbox_mode"):GetBool() or ready

	if (not preallocated and not ready) then
		newUnit:SetUnderConstruction(true)
	end

	if (capturable) then
		newUnit:SetCapturable(true)
	end
	if (claimable) then
		newUnit:SetClaimable(true)
		newUnit:SetTeam(-1)
	end

	newUnit:Spawn()

	if (not preallocated) then
		MRTSAffectUsedHousing(teamID, mrtsGameData.troops[unitID].population)
	end

	if (not instant) then
		MRTSAddUnitToBuildQueue(teamID, newUnit)
	end

	if (IsValid(pl)) then
		undo.Create("Unit")
			undo.AddEntity(newUnit)
			undo.SetPlayer(pl)
		undo.Finish()
	end

	return newUnit
end

function MRTSSpawnBuilding(teamID, unitID, pos, ang, pl, ready, capturable, claimable)
	local grid = mrtsGridSize
	local foundEnts = {}
	
	local newUnit = ents.Create("ent_mrts_building")
	newUnit:SetTeam(teamID)
	newUnit:SetUnitID(unitID)
	newUnit:SetPos(pos)
	newUnit:SetAngles(ang)

	if (not ready) then
		newUnit:SetUnderConstruction(true)
	end

	if (capturable) then
		newUnit:SetCapturable(true)
	end
	if (claimable) then
		newUnit:SetClaimable(true)
		newUnit:SetTeam(-1)
	end

	newUnit:Spawn()
	MRTSAffectUsedHousing(teamID, mrtsGameData.buildings[unitID].population)
	if (GetConVar("mrts_sandbox_mode"):GetBool() or ready) then
		timer.Simple(0.1, function()
			if (IsValid(newUnit)) then
				newUnit:FinishConstruction()
			end
		end)
	else
		MRTSAddUnitToBuildQueue(teamID, newUnit)
	end
	
	if (pl != nil) then
		undo.Create("Building")
			undo.AddEntity(newUnit)
			undo.SetPlayer(pl)
		undo.Finish()
	end

	return newUnit
end

function MRTSSpawnPart(teamID, unitID, pos, pl, ready, preallocated, tr)
	local newUnit = ents.Create("ent_mrts_part")
	newUnit:SetTeam(teamID)
	newUnit:SetUnitID(unitID)
	newUnit:SetPos(pos)

	local instant = GetConVar("mrts_sandbox_mode"):GetBool() or ready

	if (--[[not preallocated and ]]not ready) then
		newUnit:SetUnderConstruction(true)
	end

	newUnit:Spawn()

	if (not preallocated) then
		MRTSAffectUsedHousing(teamID, mrtsGameData.parts[unitID].population)
	end

	if (not instant) then
		MRTSAddUnitToBuildQueue(teamID, newUnit)
	end

	if (tr != nil and IsValid(tr.Entity)) then
		local constraintType = mrtsGameData.parts[unitID].constraint or "weld"
		if (constraintType == "weld") then
			constraint.Weld(newUnit, tr.Entity, 0, 0, 0, true, true)
		end
	end

	if (IsValid(tr) and IsValid(pl)) then
		undo.Create("Unit")
			undo.AddEntity(newUnit)
			undo.SetPlayer(pl)
		undo.Finish()
	end

	return newUnit
end

function MRTSSquadUpdate()
	mrtsSquads = {}
	if (istable(mrtsUnits)) then
		for k, v in ipairs(mrtsUnits) do
			if (not v:IsPassive()) then
				local vTable = v:GetTable()
				vTable.squad = nil
			end
		end

		for unit_k, unit in ipairs(mrtsUnits) do
			if (IsValid(unit)) then
				if (not unit:IsPassive()) then
					local unitTable = unit:GetTable()
					if (unitTable.squad == nil) then
						local foundEntities = ents.FindInSphere(unit:GetPos(), 100)
						local foundUnits = {}
						local count = 0
						for foundEnt_k, foundEnt in pairs(foundEntities) do
							local foundEntTable = foundEnt:GetTable()
							if (foundEntTable.isMRTSUnit) then
								if (foundEntTable.squad == nil) then
									if (foundEnt:GetTeam() == unit:GetTeam()) then
										table.insert(foundUnits, foundEnt)
										count = count+1
										if (count >= mrtsMaxSquadCapacity) then
											break
										end
									end
								end
							end
						end
						MRTSSquad(foundUnits, unit:GetTeam())
					end
				end
			end
		end
	end
end

function MRTSAddStatusByID(unit, statusID, time)
	if(unit.status[statusID] != nil) then
		if (unit.status[statusID] < CurTime()+time) then -- Reset the timer if its longer
			unit.status[statusID] = CurTime()+time
		end
	else
		unit.status[statusID] = CurTime()+time -- Set timer for the first time
	end

	if (mrtsGameData.status[statusID].ignite) then -- fire
		unit:Ignite(time)
	end

	net.Start("MRTSClientsideAddStatus")
		net.WriteEntity(unit)
		net.WriteInt(statusID, 8)
	net.Broadcast()
end

function MRTSAddStatus(unit, statusName, time)
	local statusID = GetStatusIDByName(statusName)
	MRTSAddStatusByID(unit, statusID, time)
end

function MRTSRemoveStatus(unit, statusID)
	unit.status[statusID] = nil
	net.Start("MRTSClientsideRemoveStatus")
		net.WriteEntity(unit)
		net.WriteInt(statusID, 8)
	net.Broadcast()
end

hook.Add("Think", "mrts_think", function()
	if (not GetConVar("mrts_playing"):GetBool()) then return end
	
	if (mrtsNextIncomeThink < CurTime()) then
		mrtsNextIncomeThink = CurTime()+mrtsIncomeThinkDelay
		for k, v in pairs(mrtsTeams) do
			for kk, vv in pairs(v.resources) do
				if (vv.income) then
					MRTSAffectResource(k, vv.income, kk)
				end
			end
		end
	end
	if (mrtsNextUnitThink < CurTime()) then
		mrtsNextUnitThink = CurTime()+mrtsUnitThinkDelay
		for k, v in ipairs(mrtsUnits) do
			if (not IsValid(v)) then
				table.remove(mrtsUnits, k)
			end
		end
		for k, v in ipairs(mrtsUnits) do
			if (v:GetTeam() > 0 and MRTSIsOutOfKillZone(v:GetPos())) then
				if (not v:GetClaimable() and not v:GetCapturable()) then
					v:Die()
				end
			else
				v:Update()
			end
		end
	end
	if (mrtsNextSquadUpdate < CurTime()) then
		//MRTSSendDebugSquads()
		mrtsNextSquadUpdate = CurTime()+mrtsUpdateSquadDelay
		MRTSSquadUpdate()
	else
		if (mrtsNextSquadMove < CurTime()) then
			//MRTSSendDebugSquads()
			mrtsNextSquadMove = CurTime()+mrtsMoveSquadDelay
			local thereWasDirty = false
			for k, v in ipairs(mrtsSquads) do
				if (v.dirty) then
					MRTSUpdateSquadBoundaries(v)
					thereWasDirty = true
					v.dirty = false
				end
			end
			if (thereWasDirty) then
				for k, v in ipairs(mrtsSquads) do
					MRTSUpdateSquadClosest(v)
				end
			end
		end
	end

	for k, v in pairs(mrtsTeams) do
		if (CurTime() >= v.nextBuild) then
			if (#v.buildQueue > 0) then
				MRTSFinishTeamBuildQueue(k)
			end
		end
	end
end)

function MRTSRestartBuild(teamID)
	local team = mrtsTeams[teamID]
	if (#team.buildQueue > 0) then
		team.nextBuild = CurTime()+team.buildQueue[1].time
	end
end

function MRTSFinishTeamBuildQueue(teamID)
	local team = mrtsTeams[teamID]
	if (#team.buildQueue > 0) then
		if (IsValid(team.buildQueue[1].unit)) then
			team.buildQueue[1].unit:FinishConstruction()
		end
		table.remove(team.buildQueue, 1)
	end
	if (#team.buildQueue > 0) then
		team.nextBuild = CurTime()+team.buildQueue[1].time
	end
	MRTSUpdateBuildQueue(teamID)
end

function MRTSSanitizeQueue(teamID)
	local team = mrtsTeams[teamID]
	local copy = {}
	local changed = false
	for k, v in pairs(team.buildQueue) do
		if (IsValid(v.unit)) then
			table.insert(copy, v)
		else
			changed = true
		end
	end
	if (changed) then
		team.buildQueue = copy
		MRTSUpdateBuildQueue(teamID)
	end
end

function MRTSMeetsUnitRequirements(teamID, troopData, costOverride)
	local team = mrtsTeams[teamID]
	local cappedHousing = math.min(team.maxHousing, GetConVar("mrts_max_population"):GetInt())
	if (troopData.population) then
		if (troopData.population > 0) then
			if (cappedHousing < team.usedHousing+troopData.population) then
				print("Not enough housing")
				return false
			end
		end
	end
	local cost = troopData.cost
	if (costOverride) then
		cost = costOverride
	end
	for k, v in pairs(cost) do
		if (team.resources[k] == nil or team.resources[k].current < v) then
			print ("Not enough "..k)
			return false
		end
	end
	return true
end

hook.Add("ShouldCollide", "mrtsFriendlyProjectiles", function(ent1, ent2)
	if (ent1:GetClass() != "ent_mrts_projectile") then return false end
	if (ent2:GetClass() == "ent_mrts_capture_zone") then return false end
	if (ent2.Base != "ent_mrts_unit") then return end
	return ent1:GetTeam() != ent2:GetTeam()
end)

hook.Add( "PhysgunPickup", "mrtsPreventPickup", function( ply, ent )
	local tbl = ent:GetTable()
	if (tbl.isMRTSUnit or (tbl.mrtsPartOfTheMap and GetConVar("mrts_lock_map_entities"):GetBool())) then
		return false
	end
end )

hook.Add("CanTool", "NoToolOnMyEntity", function(ply, trace, tool)
    local ent = trace.Entity
    if IsValid(ent) then
		local tbl = ent:GetTable()
		if (tbl.mrtsPartOfTheMap and GetConVar("mrts_lock_map_entities"):GetBool()) then
        	return false
		end
    end
end)

hook.Add("CanProperty", "NoPropertyOnMyEntity", function(ply, property, ent)
	local tbl = ent:GetTable()
	if (tbl.mrtsPartOfTheMap and GetConVar("mrts_lock_map_entities"):GetBool()) then
		return false
	end
end)

function MRTSAffectUsedHousing(specificTeam, amount, preventUpdate)
	if (amount != 0) then
		mrtsTeams[specificTeam].usedHousing = mrtsTeams[specificTeam].usedHousing+(amount or 0);
		if (!preventUpdate) then
			MRTSUpdateUsedHousing(specificTeam);
		end
	end
end

function MRTSUpdateUsedHousing(specificTeam)
	net.Start("MRTSUpdateUsedHousing");
		net.WriteInt(specificTeam, 8); // team
		net.WriteInt(mrtsTeams[specificTeam].usedHousing, 16); // used capacity
	net.Broadcast();
end

function MRTSAffectResource(specificTeam, amount, resource, preventUpdate)
	if (amount != 0) then
		mrtsTeams[specificTeam].resources[resource].current = mrtsTeams[specificTeam].resources[resource].current+(amount or 0);
		mrtsTeams[specificTeam].resources[resource].current = math.Clamp(
			mrtsTeams[specificTeam].resources[resource].current,
			0,
			mrtsTeams[specificTeam].resources[resource].capacity
		)
		if (!preventUpdate) then
			MRTSUpdateResource(specificTeam, resource);
		end
	end
end

function MRTSUpdateAll()
	for k, v in pairs(mrtsTeams) do
		for kk, vv in pairs(mrtsGameData.resources) do
			MRTSUpdateResource(k, vv.uniqueName)
		end
		MRTSUpdateUsedHousing(k)
	end
end

function MRTSUpdateResource(specificTeam, resource)
	net.Start("MRTSUpdateResource");
		net.WriteInt(specificTeam, 8); // team
		net.WriteInt(mrtsTeams[specificTeam].resources[resource].current, 32); // money
		net.WriteString(resource); // resource unique name
	net.Broadcast(v);
end

function MRTSAddIncome(specificTeam, income)
	table.insert(mrtsTeams[specificTeam].incomes, income)
	MRTSUpdateIncome(specificTeam);
end

function MRTSRemoveIncome(specificTeam, income)
	table.RemoveByValue(mrtsTeams[specificTeam].incomes, income)
	MRTSUpdateIncome(specificTeam);
end

function MRTSAffectIncome(specificTeam, amount, resource, preventUpdate)
	if (specificTeam < 0) then return false end
	if (amount != 0) then
		if (mrtsTeams[specificTeam].resources[resource].income == nil) then
			mrtsTeams[specificTeam].resources[resource].income = 0
		end
		mrtsTeams[specificTeam].resources[resource].income = mrtsTeams[specificTeam].resources[resource].income+(amount or 0);
		if (!preventUpdate) then
			MRTSUpdateIncome(specificTeam, resource);
		end
	end
end

function MRTSAffectCapacity(specificTeam, amount, resource, preventUpdate)
	if (amount != 0) then
		if (mrtsTeams[specificTeam].resources[resource].capacity == nil) then
			mrtsTeams[specificTeam].resources[resource].capacity = 0
		end
		mrtsTeams[specificTeam].resources[resource].capacity = mrtsTeams[specificTeam].resources[resource].capacity+(amount or 0);
		if (!preventUpdate) then
			MRTSUpdateCapacity(specificTeam, resource);
		end
	end
end

function MRTSUpdateIncome(specificTeam, resource)
	net.Start("MRTSUpdateIncome");
		net.WriteInt(specificTeam, 8); // team
		net.WriteInt(mrtsTeams[specificTeam].resources[resource].income*100, 32); // Income
		net.WriteString(resource); // resource unique name
	net.Broadcast(v);
end

function MRTSUpdateCapacity(specificTeam, resource)
	local res = mrtsTeams[specificTeam].resources[resource]
	net.Start("MRTSUpdateCapacity");
		net.WriteInt(specificTeam, 8); // team
		net.WriteInt(res.capacity, 32); // Income
		net.WriteString(resource); // resource unique name
	net.Broadcast(v);
	-- Overflow
	if (res.current > res.capacity) then
		res.current = res.capacity
		MRTSUpdateResource(specificTeam, resource)
	end
end

function MRTSUpdateBuildQueue(specificTeam)
	local clientBuildQueue = {}
	for k, v in pairs(mrtsTeams[specificTeam].buildQueue) do
		clientBuildQueue[k] = {
			icon = v.unit:GetData().icon,
			time = v.time
		}
	end
	net.Start("MRTSUpdateBuildQueue");
		net.WriteInt(specificTeam, 8); // team
		net.WriteTable(clientBuildQueue)
		net.WriteFloat(mrtsTeams[specificTeam].nextBuild)
	net.Broadcast(specificTeam);
end

function MRTSAffectMaxHousing(specificTeam, amount, preventUpdate)
	if (amount != 0) then
		mrtsTeams[specificTeam].maxHousing = mrtsTeams[specificTeam].maxHousing+(amount or 0);
		if (!preventUpdate) then
			MRTSUpdateMaxHousing(specificTeam);
		end
	end
end

function MRTSUpdateMaxHousing(specificTeam)
	net.Start("MRTSUpdateMaxHousing");
		net.WriteInt(specificTeam, 8); // team
		net.WriteInt(mrtsTeams[specificTeam].maxHousing, 16); // max capacity
	net.Broadcast();
end

function MRTSVerifyEvent(observers)
	for k, v in pairs(observers) do
		local eventType = v.eventType
		if (eventType == 0) then -- Unit count

		end
	end
end

function MRTSRecalculateTeams()
	local units = {}
	table.Add( units, ents.FindByClass("ent_mrts_troop") )
	table.Add( units, ents.FindByClass("ent_mrts_building") )

	for k, v in pairs(mrtsTeams) do
		v.population = 0
		v.housing = 0
		v.income = {}
	end

	for k, v in pairs(units) do
		local data = v:GetData()
		if (data.population != nil and data.population != 0) then
			MRTSAffectUsedHousing(v:GetTeam(), data.population, true)
		end
		if (data.housing != nil and data.housing != 0) then
			MRTSAffectMaxHousing(v:GetTeam(), data.housing, true)
		end
		if (istable(data.income)) then
			for kk, vv in pairs(data.income) do
				MRTSAffectIncome(v:GetTeam(), vv, kk, true)
			end
		end
		if (istable(data.capacity)) then
			for kk, vv in pairs(data.capacity) do
				MRTSAffectCapacity(v:GetTeam(), vv, kk, true)
			end
		end
	end

	for k, v in pairs(mrtsTeams) do
		MRTSUpdateUsedHousing(k)
		MRTSUpdateMaxHousing(k)
		for resourceID, resource in pairs(mrtsGameData.resources) do
			local resourceName = resource.uniqueName
			MRTSUpdateCapacity(k, resourceName)
			MRTSUpdateResource(k, resourceName)
			MRTSUpdateIncome(k, resourceName)
		end
	end
end

function MRTSAreaEffect(damager, pos, radius, teamID, data)
	local victims = {}
	if (data.friendly) then
		victims = MRTSGetEntitiesInRadius(pos, radius, teamID)
	else
		victims = MRTSGetEntitiesInRadius(pos, radius, teamID, true)
	end
	if (data.forcedVictim != nil and data.forcedVictim.isMRTSUnit) then
		if (not table.HasValue(victims, data.forcedVictim)) then
			table.insert(victims, data.forcedVictim)
		end
	end

	if (data.damage) then
		for k, v in pairs(victims) do
			v:Damage(damager, data.damage)
		end
	end
	if (data.healing) then
		for k, v in pairs(victims) do
			v:Heal(damager, data.healing)
		end
	end
	if (data.status) then
		for k, v in pairs(victims) do
			MRTSAddStatus(v, data.status.type, data.status.duration)
		end
	end

	net.Start("MRTSClientsideRing")
		net.WriteFloat(radius)
		net.WriteVector(pos)
		if (data.friendly) then
			net.WriteColor(mrtsColorLime)
		else
			net.WriteColor(mrtsColorRed)
		end
	net.Broadcast()
end

function MRTSEliminateTeam(teamID)
	for k, v in pairs(mrtsUnits) do
		if (v:GetTeam() == teamID) then
			if (v:GetCapturable()) then
				v:ChangeTeam(0)
				/*v:ComputeAllChanges(-1)
				v:SetTeam(0)
				v:ComputeAllChanges(1)*/
			else
				v:Die()
			end
		end
	end

	local text = mrtsTeams[teamID].name.." has been Eliminated."
	PrintMessage(HUD_PRINTCENTER, text)
	PrintMessage(HUD_PRINTTALK, text)
end

function MRTSReset()
	for teamId, team in pairs(mrtsTeams) do
		team.population = 0
		team.usedHousing = 0
		team.maxHousing = 0
		team.buildQueue = {}
		team.resources = MRTSGetInitializedResourceTable()
		MRTSUpdateUsedHousing(teamId)
		MRTSUpdateMaxHousing(teamId)
		for resourceID, resource in pairs(mrtsGameData.resources) do
			local resourceName = resource.uniqueName
			MRTSUpdateCapacity(teamId, resourceName)
			team.resources[resourceName].current = resource.startingAmount or 0
			MRTSUpdateResource(teamId, resourceName)
			MRTSUpdateIncome(teamId, resourceName)
		end
	end
end


function MRTSSendNotification(ply, message, notificationYype, time)
	net.Start("MRTSClientsideNotification")
		net.WriteInt(notificationYype, 4)
		net.WriteFloat(time)
		net.WriteString(message)
	net.Send(ply)
end


hook.Add("PostCleanupMap", "mrtsReset", function()
	MRTSReset()
end)

-- Pathfinding
/*
function Astar( start, goal )
	if ( !IsValid( start ) || !IsValid( goal ) ) then return false end
	if ( start == goal ) then return true end

	start:ClearSearchLists()

	start:AddToOpenList()

	local cameFrom = {}

	start:SetCostSoFar( 0 )

	start:SetTotalCost( heuristic_cost_estimate( start, goal ) )
	start:UpdateOnOpenList()

	while ( !start:IsOpenListEmpty() ) do
		local current = start:PopOpenList() // Remove the area with lowest cost in the open list and return it
		if ( current == goal ) then
			return reconstruct_path( cameFrom, current )
		end

		current:AddToClosedList()

		for k, neighbor in pairs( current:GetAdjacentAreas() ) do
			local newCostSoFar = current:GetCostSoFar() + heuristic_cost_estimate( current, neighbor )

			if ( neighbor:IsUnderwater() ) then // Add your own area filters or whatever here
				continue
			end
			
			if ( ( neighbor:IsOpen() || neighbor:IsClosed() ) && neighbor:GetCostSoFar() <= newCostSoFar ) then
				continue
			else
				neighbor:SetCostSoFar( newCostSoFar );
				neighbor:SetTotalCost( newCostSoFar + heuristic_cost_estimate( neighbor, goal ) )

				if ( neighbor:IsClosed() ) then
				
					neighbor:RemoveFromClosedList()
				end

				if ( neighbor:IsOpen() ) then
					// This area is already on the open list, update its position in the list to keep costs sorted
					neighbor:UpdateOnOpenList()
				else
					neighbor:AddToOpenList()
				end

				cameFrom[ neighbor:GetID() ] = current:GetID()
			end
		end
	end

	return false
end

function AstarVector( start, goal )
	local startArea = navmesh.GetNearestNavArea( start )
	local goalArea = navmesh.GetNearestNavArea( goal )
	return Astar( startArea, goalArea )
end

function heuristic_cost_estimate( start, goal )
	-- Perhaps play with some calculations on which corner is closest/farthest or whatever
	return start:GetCenter():Distance( goal:GetCenter() )
end

-- using CNavAreas as table keys doesn't work, we use IDs
function reconstruct_path( cameFrom, current )
	local total_path = { current }

	current = current:GetID()
	while ( cameFrom[ current ] ) do
		current = cameFrom[ current ]
		table.insert( total_path, navmesh.GetNavAreaByID( current ) )
	end
	return total_path
end

function drawThePath( path, time )
	local prevArea
	for _, area in pairs( path ) do
		debugoverlay.Sphere( area:GetCenter(), 8, time or 9, color_white, true  )
		if ( prevArea ) then
			debugoverlay.Line( area:GetCenter(), prevArea:GetCenter(), time or 9, color_white, true )
		end

		area:Draw()
		prevArea = area
	end
end

concommand.Add( "test_astar", function( ply )

	// Use the start position of the player who ran the console command
	local start = navmesh.GetNearestNavArea( ply:GetPos() )

	// Target position, use the player's aim position for this example
	local goal = navmesh.GetNearestNavArea( ply:GetEyeTrace().HitPos )

	local path = Astar( start, goal )
	if ( !istable( path ) ) then // We can't physically get to the goal or we are in the goal.
		return
	end

	PrintTable( path ) // Print the generated path to console for debugging
	drawThePath( path ) // Draw the generated path for 9 seconds

end)
*/