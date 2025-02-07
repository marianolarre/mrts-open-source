-- Load default datapack
net.Receive( "MRTSRequestClientLoadDefaultDatapack", function() 
	MRTSLoadDefaultPack()
end)

-- Receiving datapack
net.Receive( "MRTSRequestClientDatapack", function() 
	if (MRTSSendDatapackToServer != nil) then
		MRTSSendDatapackToServer()
	else
		print("MRTSSendDatapackToServer not yet defined")
	end
end )
----------------------

net.Receive( "MRTSClientsideUnitHit", function()
	local entity = net.ReadEntity();
	if (IsValid(entity)) then
		if (entity != nil) then
			if (entity.ClientsideHit != nil) then
				entity:ClientsideHit();
			end
		end
	end
end )

net.Receive( "MRTSClientsideFX", function()
	local effect = net.ReadString();
	local startPos = net.ReadVector();
	local endPos = net.ReadVector();
	MRTS_Effect(effect, startPos, endPos)
end )

net.Receive( "MRTSClientsideRing", function()
	local radius = net.ReadFloat();
	local pos = net.ReadVector();
	local color = net.ReadColor();
	MRTS_VFX_AreaRing(pos, radius, color);
end )

net.Receive( "MRTSClientsideUnitAttack", function()
	local entity = net.ReadEntity();
	local unitID = net.ReadInt(8);
	local unitCategory = net.ReadInt(8);
	local startPos = net.ReadVector();
	local endPos = net.ReadVector();
	local trailOnly = net.ReadBool();
	local attackID = net.ReadUInt(4);

	local entTable = entity:GetTable()
	if (IsValid(entity)) then
		if (entity != nil) then
			if (entTable.isMRTSUnit) then
				if (entTable.GetFiringOrigin != nil) then
					startPos = entTable.GetFiringOrigin(entity, true)
				end
			end
		end
	end

	timer.Simple(math.random()/24, function() 
		local attack
			
		if (attackID == MRTS_ATTACKID_CHARGE) then
			attack = GetDataByCategory(unitID,unitCategory).charge.attack
		else
			attack = GetDataByCategory(unitID,unitCategory).attack
		end

		if (attack.effect) then
			MRTS_Effect(attack.effect.start, startPos, endPos)
			MRTS_Effect(attack.effect.trail, startPos, endPos)
			MRTS_Effect(attack.effect.hit, endPos, startPos)
		end

		if (trailOnly) then return false end

		if (IsValid(entity)) then
			if (entity != nil) then
				if (entity.isMRTSUnit) then
					entity:ClientsideAttack(endPos);
				end
			end
		end

		if (IsValid(entity.weapon)) then
			startPos=entity.weapon:GetPos()
		end

		if (attack.sound) then
			sound.Play(attack.sound.path, startPos, attack.sound.volume, attack.sound.pitch*(math.random(90,110)/100), 0.7)
		end
		
	end)
end )

net.Receive( "MRTSClientsideUnitStopMoving", function()
	local entity = net.ReadEntity();
	if (IsValid(entity)) then
		if (entity != nil) then
			if (entity.ClientsideStopMoving != nil) then
				entity:ClientsideStopMoving();
			end
		end
	end
end )

net.Receive( "MRTSClientsideUpdateWaypoints", function()
	local entity = net.ReadEntity()
	local waypoints = net.ReadTable()
	if (IsValid(entity)) then
		entity:ReceiveWaypoints(waypoints)
	end
end)

net.Receive( "MRTSClientsideUnitNextAttack", function()
	local entity = net.ReadEntity();
	local target = net.ReadEntity();
	local entTable = entity:GetTable()
	if (IsValid(entity)) then
		if (entity != nil) then
			if (entTable.isMRTSUnit) then
				entTable.ClientsideNextAttack(entity, target);
			end
		end
	end
end )

net.Receive( "MRTSClientsideUnitCancelWindup", function()
	local entity = net.ReadEntity();
	local entTable = entity:GetTable()
	if (IsValid(entity)) then
		if(entTable.ClientsideCancelWindup != nil) then
			entTable.ClientsideCancelWindup(entity);
		end
	end
end )

net.Receive( "MRTSClientsideUnitDeath", function()
	local unitID = net.ReadInt(8);
	local unitCategory = net.ReadInt(8);
	local _team = net.ReadInt(8);
	local pos = net.ReadVector();

	local data = GetDataByCategory(unitID, unitCategory)

	local size
	local particles
	if (unitCategory != MRTS_UNIT_CATEGORY_BUILDING) then
		particles = 10+data.size*3
		size = 8+data.size*2
	else
		particles = 10+64*3
		size = 8+24*2
	end
	local color = mrtsTeams[_team].color
	local emitter = ParticleEmitter( pos) -- Particle emitter in this position
	for i = 0, particles do -- SMOKE
		local part = emitter:Add( "color", pos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( math.random(0.5, 1) ) -- How long the particle should "live"
			part:SetColor(color.r,color.g,color.b)
			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 255 ) -- Particle size at the end if its lifetime
			part:SetStartSize( 1 ) -- Starting size
			part:SetEndSize( 0.5 ) -- Size when removed
			part:SetAirResistance(0)
			part:SetGravity( Vector( 0, 0, -150 ) ) -- Gravity of the particle
			local vec = VectorRand()*size
			vec.z = vec.z*3
			if (vec.z < 0) then
				vec.z = -vec.z
			end
			part:SetVelocity( vec ) -- Initial velocity of the particle
		end
	end

	if (data.deathSound != nil) then
		timer.Simple((math.random()+0.5)/6, function() 
			sound.Play( data.deathSound, pos, 70, 100, 0.8 )
		end)
	end

	if (_team == mrtsTeam) then
		MRTSNotifyDeath(pos)
	end
end )

net.Receive( "MRTSClientsideAddStatus" , function()
	local unit = net.ReadEntity()
	local statusID = net.ReadInt(8)
	if (IsValid(unit)) then
		MRTSAddStatus(unit, statusID)
	end
end)

net.Receive( "MRTSClientsideRemoveStatus" , function()
	local unit = net.ReadEntity()
	local statusID = net.ReadInt(8)
	if (IsValid(unit)) then
		MRTSRemoveStatus(unit, statusID)
	end
end)

net.Receive( "MRTSClientsideQueueTroop" , function()
	local building = net.ReadEntity()
	local unitID = net.ReadInt(8)
	if (IsValid(building)) then
		building:QueueTroop(unitID)
	end
end)

net.Receive( "MRTSClientsideQueueBuilding" , function()
	local building = net.ReadEntity()
	local buildingID = net.ReadInt(8)
	if (IsValid(building)) then
		building:QueueBuilding(buildingID)
	end
end)

net.Receive( "MRTSClientsideCancelFullQueue" , function()
	local building = net.ReadEntity()
	if (IsValid(building)) then
		building:CancelFullQueue()
	end
end)

net.Receive( "MRTSClientsideCancelTroop" , function()
	local building = net.ReadEntity()
	if (IsValid(building)) then
		building:CancelTroop()
	end
end)

net.Receive("MRTSClientsideNextTroopInQueue", function()
	local building = net.ReadEntity()
	building:ClientsideNextTroopInQueue()
end)

net.Receive("MRTSUpdateResource", function()
	local _team = net.ReadInt(8); // team
	local amount = net.ReadInt(32); // amount
	local resource = net.ReadString(); // resource unique name
	mrtsTeams[_team].resources[resource].current = amount
end)

net.Receive("MRTSUpdateCapacity", function()
	local _team = net.ReadInt(8); // team
	local amount = net.ReadInt(32); // amount
	local resource = net.ReadString(); // resource unique name
	mrtsTeams[_team].resources[resource].capacity = amount
end)

net.Receive("MRTSUpdateIncome", function()
	local _team = net.ReadInt(8); // team
	local amount = net.ReadInt(32); // amount
	local resource = net.ReadString(); // resource unique name
	mrtsTeams[_team].resources[resource].income = amount/100
end)

net.Receive("MRTSUpdateUsedHousing", function()
	local _team = net.ReadInt(8); // team
	local amount = net.ReadInt(16); // capacity
	mrtsTeams[_team].usedHousing = amount
end)

net.Receive("MRTSUpdateMaxHousing", function()
	local _team = net.ReadInt(8); // team
	local amount = net.ReadInt(16); // capacity
	mrtsTeams[_team].maxHousing = amount
end)

net.Receive("MRTSUpdateBuildQueue", function()
	local _team = net.ReadInt(8); // team
	local _buildQueue = net.ReadTable(); // new queue
	local _nextBuild = net.ReadFloat();
	mrtsTeams[_team].buildQueue = _buildQueue
	mrtsTeams[_team].nextBuild = _nextBuild
end)

net.Receive("MRTSClientsideFinishConstruction", function()
	local entity = net.ReadEntity()
	if (IsValid(entity)) then
		entity.lastMove = CurTime()
		entity:FinishConstruction()
	end
end)

net.Receive("MRTSInitializeCaptureZones", function()
	mrtsCaptureZones = {} -- Reset
	local count = net.ReadInt(8);
	for i=1, count do
		table.insert(mrtsCaptureZones, table.Copy(MRTSCaptureZoneClass))
	end
end)

net.Receive( "MRTSUpdateCaptureZones", function( len, ply )
	local zone = net.ReadEntity()
	if (IsValid(zone)) then
		zone.capture = net.ReadFloat()
		zone.captureSpeed = net.ReadTable()
		zone.contested = net.ReadBool()
		zone.capturingTeam = net.ReadInt(8)	
		zone.team = net.ReadInt(8)	
	end
end )

net.Receive( "MRTSClientsideAlliances", function(len)
	local alliances = net.ReadTable()

	for k, v in pairs(alliances) do
		mrtsTeams[k].alliances = v
	end
	if (mrtsAllianceButtons) then
		for k1, v1 in pairs(mrtsAllianceButtons) do
			for k2, v2 in pairs(v1) do
				v2:SetChecked(mrtsTeams[k1].alliances[k2])
			end
		end
	end
end)

net.Receive("MRTSAnnouncePlayerTeam", function (len)
	local announce = net.ReadBool()
	local teamID = net.ReadInt(8)
	local nick = net.ReadString()
	local t = mrtsTeams[teamID]
	if (t != nil) then
		chat.AddText( Color( 200, 200, 200 ), "[MRTS] ", Color( 255, 255, 255 ), nick, Color( 200, 200, 200 ), " has joined team ", t.color, t.name )
	else
		chat.AddText( Color( 200, 200, 200 ), "[MRTS] ", Color( 255, 255, 255 ), nick, Color( 200, 200, 200 ), " is now spectating" )
	end
end)

net.Receive( "MRTSSetTeam", function(len)
	local requestedTeam = net.ReadInt(8)
	local shouldUpdateMenu = net.ReadBool()
	mrtsTeam = requestedTeam

	-- Refresh menu on team change
	if (shouldUpdateMenu) then
		MRTSResetMenu(2)
	end
end)

net.Receive( "MRTSSetFaction", function(len)
	local _team = net.ReadInt(8)
	local factionID = net.ReadInt(8)
	mrtsTeams[_team].faction = factionID

	if (mrtsTeam == _team) then
	-- Refresh menu on faction change
		if (mrtsGameMenu != nil) then
			notification.AddLegacy( "Faction changed", NOTIFY_GENERIC ,2 )
			if (LocalPlayer():GetActiveWeapon():GetClass() == "weapon_mrts") then
				mrtsGameMenu:Close()
				LocalPlayer():GetActiveWeapon():OpenGameMenu()
				LocalPlayer():GetActiveWeapon():GoToTab(2)
			end
		end
	end
end)

net.Receive( "MRTSClientsideNotification", function(len)
	local notificationType = net.ReadInt(4)
	local notificationTime = net.ReadFloat()
	local message = net.ReadString()
	notification.AddLegacy(message, notificationType ,notificationTime )
end)

net.Receive( "MRTSMatchStart", function()
	
end)

net.Receive( "MRTSClientsideUpdateFOW", function()
	mrtsFOW = net.ReadBool()
	print("Received FOW change: "..tostring(mrtsFOW))
end)

net.Receive("MRTSResetDebug", function()
	debugBoxes = {}
end)

net.Receive("MRTSDebugBox", function()
	local _mins = net.ReadVector()
	local _maxs = net.ReadVector()
	local debugBox = {mins=_mins, maxs=_maxs}
	table.insert(debugBoxes, debugBox)
end)

net.Receive("MRTSRequestConfigurator", function (len, pl)
    local eventCount = net.ReadInt(8)
	mrtsEvents = {}
	for i=0, eventCount do
		local newEvent = table.Copy(MRTSEventClass);
		newEvent.eventType=net.ReadInt(8)
		newEvent.comparisson=net.ReadInt(8)
		newEvent.unitType=net.ReadString()
		newEvent.number=net.ReadInt(8)
		newEvent.resource=net.ReadString()
		mrtsEvents[i] = newEvent
	end
	if (LocalPlayer():GetActiveWeapon():GetClass() == "weapon_mrts") then
		LocalPlayer():GetActiveWeapon():OpenGameMenu()
	end
end);
/*
net.Receive("MRTSEntityPasted", function()
	local entity = net.ReadEntity()
	if (IsValid(entity)) then
		entity:CreateAccessories()
	end
end)
*/