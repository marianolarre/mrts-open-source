local MRTSTeamClass = {};
MRTSTeamClass.factionID = 1;
MRTSTeamClass.enabled = false;
MRTSTeamClass.defeated = false;
MRTSTeamClass.color = Color(255, 255, 0);
MRTSTeamClass.name = "Unnamed team";
MRTSTeamClass.resources = {}
MRTSTeamClass.buildQueue = {}
MRTSTeamClass.nextBuild = 0
MRTSTeamClass.points = 0;
MRTSTeamClass.usedHousing = 0;
MRTSTeamClass.maxHousing = 0;
MRTSTeamClass.events = {};

MRTSEventClass = {};
MRTSEventClass.eventType = 0;
MRTSEventClass.comparisson = 0;
MRTSEventClass.unitType = "";
MRTSEventClass.number = 0;
MRTSEventClass.resource = "";
MRTSEventClass.counter = 0;

mrtsMapController = nil

mrtsGridSize = 24
mrtsFOW = false

MRTS_ATTACKID_PRIMARY = 0
MRTS_ATTACKID_CHARGE = 1
MRTS_ATTACKID_PASSIVE = 2

MRTS_UNIT_CATEGORY_BUILDING = 0
MRTS_UNIT_CATEGORY_TROOP = 1
MRTS_UNIT_CATEGORY_PART = 2

function MRTSGetInitializedResourceTable()
	local tbl = {}
	for k, v in pairs(mrtsGameData.resources) do
		tbl[v.uniqueName] = {order=k, current=0, capacity=0, income=0}
	end
	return tbl
end

function MRTSTeam(name, color) --Code is an optional argument.
	local newTeam = table.Copy(MRTSTeamClass);
	newTeam.name = name
	newTeam.color = color
	newTeam.resources = MRTSGetInitializedResourceTable();
	newTeam.faction = 1
	newTeam.alliances = {}
	return newTeam;
end

mrtsNeutralTeam = nil
function MRTSGetNeutralTeam()
	if (mrtsNeutralTeam == nil) then
		for k, v in pairs(mrtsGameData.teams) do
			if (v.neutral) then
				mrtsNeutralTeam = v
				break
			end
		end
	end
	return mrtsNeutralTeam
end

function MRTSLoadTeams()
	mrtsTeams = {}
	local n = MRTSGetNeutralTeam()
	mrtsTeams[0] = MRTSTeam(n.name, Color(n.color.r, n.color.g, n.color.b))
	for k, v in pairs(mrtsGameData.teams) do
		if (not v.neutral) then
			mrtsTeams[k] = MRTSTeam(v.name, Color(v.color.r, v.color.g, v.color.b))
		end
	end
end

function MRTSInitializeDatapack()
	troopsByUniqueName = {}
	troopsIDsByUniqueName = {}
	for k, v in pairs(mrtsGameData.troops) do
		troopsByUniqueName[v.uniqueName] = v
		troopsIDsByUniqueName[v.uniqueName] = k
	end
	buildingsByUniqueName = {}
	for k, v in pairs(mrtsGameData.buildings) do
		buildingsByUniqueName[v.uniqueName] = v
	end
	partsByUniqueName = {}
	for k, v in pairs(mrtsGameData.parts) do
		partsByUniqueName[v.uniqueName] = v
	end
	statusByUniqueName = {}
	for k, v in pairs(mrtsGameData.status) do
		statusByUniqueName[v.uniqueName] = v
	end
	resourcesByUniqueName = {}
	for k, v in pairs(mrtsGameData.resources) do
		resourcesByUniqueName[v.uniqueName] = v
	end

	MRTSLoadTeams()
end

function MRTSLoadDefaultPack()
	mrtsCustomDatapackName = "default"
	mrtsGameData = defaultMrtsGameData
	MRTSInitializeDatapack()
end

MRTSLoadDefaultPack()

function MRTSGetEntitiesInRadius(position, radius, teamfilter, invert, returnclosest, entityFilter, ignoreAllies)
	local entitiesInRadius = {}
	local closest = nil
	local nearestDistance = 0
	local boxSize = Vector(radius, radius, radius)
	local entsInSphere = ents.FindInBox( position-boxSize, position+boxSize )
	for k, v in pairs(entsInSphere) do
		local entTable = v:GetTable()
		if (not v.isMRTSUnit) then continue end
		local vPos = v:GetPos()
		local xDistance = vPos.x-position.x
		local yDistance = vPos.y-position.y
		local zDistance = vPos.z-position.z
		local size = 0
		if (entTable.size != nil) then
			size = entTable.size
		end
		local sqrDistance = xDistance*xDistance+yDistance*yDistance+zDistance*zDistance
		if (sqrDistance < (radius+size)*(radius+size)) then
			if (teamfilter != nil) then
				local otherTeam = v:GetTeam()
				local shouldInvert = (invert != nil and invert == true)
				if (entTable.isMRTSUnit) then
					local filteredTeam = (otherTeam == teamfilter)
					if (not ignoreAllies) then
						if (otherTeam == teamfilter or mrtsTeams[teamfilter].alliances[otherTeam]) then
							filteredTeam = true
						end
					end
					if ((shouldInvert and not filteredTeam) or (not shouldInvert and filteredTeam)) then
						if (returnclosest == nil or returnclosest == false) then
							if (entityFilter == nil or entTable.data.uniqueName == entityFilter) then
								table.insert(entitiesInRadius, v)
							end
						else
							local dist = (vPos-position):LengthSqr()
							if (closest == nil or dist < nearestDistance) then
								nearestDistance = dist
								closest = v
							end
						end
					end
				end
			else
				if (entTable.isMRTSUnit) then
					if (entityFilter == nil or entTable.data.uniqueName == entityFilter) then
						if (not selectableOnly or entTable.selectable) then
							table.insert(entitiesInRadius, v)
							local dist = (vPos-position):LengthSqr()
							if (closest == nil or dist < nearestDistance) then
								nearestDistance = dist
								closest = v
							end
						end
					end
				end
			end
		end
	end

	if (returnclosest) then
		return closest
	else
		return entitiesInRadius
	end
	
	return nil
end

function GetDataByCategory(unitID, category)
	if (category == MRTS_UNIT_CATEGORY_TROOP) then
		return mrtsGameData.troops[unitID]
	elseif (category == MRTS_UNIT_CATEGORY_BUILDING) then
		return mrtsGameData.buildings[unitID]
	elseif (category == MRTS_UNIT_CATEGORY_PART) then
		return mrtsGameData.parts[unitID]
	end
end

function GetTroopID(uniqueName)
	for k, v in pairs(mrtsGameData.troops) do
		if (v.uniqueName == uniqueName) then
			return k
		end
	end
	print("Could not get troop with uniqueName: "..uniqueName)
	return nil
end

function GetBuildingID(uniqueName)
	for k, v in pairs(mrtsGameData.buildings) do
		if (v.uniqueName == uniqueName) then
			return k
		end
	end
	print("Could not get building with uniqueName: "..uniqueName)
	return nil
end

function GetStatusIDByName(uniqueName)
	for k, v in pairs(mrtsGameData.status) do
		if (v.uniqueName == uniqueName) then
			return k
		end
	end
	print("Could not get status with uniqueName: "..uniqueName)
	return nil
end

function MRTSIsInBuildingRange(pos, team)
	for k, v in pairs(ents.FindByClass("ent_mrts_building")) do
		if (IsValid(v) and v != nil) then
			if (v:GetData().buildingRange and v:GetTeam() == team and not v:GetUnderConstruction()) then
				local distanceSqr = pos:DistToSqr(v:GetCenter())
				if (distanceSqr < v:GetData().buildingRange*v:GetData().buildingRange) then
					return true
				end
			end
		end
	end
	return false
end

function MRTSCanPlaceTroop(tr, unitData, size, team)
	local pos = tr.HitPos+tr.HitNormal*size

	if (IsValid(tr.Entity)) then
		local phys = tr.Entity:GetPhysicsObject()
		if (IsValid(phys) and phys:GetMaterial() == "gmod_ice") then
			return false, pos, "Can't build here"
		end
	end

	if (unitData.moveType != "water") then
		if ( bit.band( util.PointContents( pos+Vector(0,0,-size-5 )), CONTENTS_WATER ) > 0) then
			return false, pos, "Can't build on water"
		end
	else
		if ( bit.band( util.PointContents( pos+Vector(0,0,-size-5 )), CONTENTS_WATER ) == 0) then
			return false, pos, "Must be built on water"
		end
	end

	if (MRTSIsOutOfBounds(pos)) then
		return false, pos, "Out of bounds"
	end

	if (math.abs(tr.HitNormal.x) >= 0.5 or math.abs(tr.HitNormal.y) >= 0.5 or tr.HitNormal.z <= 0) then
		return false, pos, "Can't build on wall or steep incline"
	end

	local foundEnts = ents.FindInSphere( pos, size-2 )
	for k, v in pairs(foundEnts) do
		if (v:GetClass() == "prop_physics") then
			return false, pos, "There is something in the way"
		end
	end
	
	if (GetConVar("mrts_sandbox_mode"):GetBool()) then
		return true, pos
	end
	
	if (not unitData.canBeBuiltAnywhere) then
		if (not MRTSIsInBuildingRange(pos, team)) then
			return false, pos, "Outside of building range"
		end
	end
	return true, pos
end

function MRTSCanPlacePart(tr, unitData, size, team)
	local pos = tr.HitPos+tr.HitNormal*size

	local foundEnts = ents.FindInSphere( pos, size-2 )
	for k, v in pairs(foundEnts) do
		if (v:GetClass() == "ent_mrts_part") then
			return false, pos, "There is something in the way"
		end
	end

	if (IsValid(tr.Entity)) then
		if (tr.Entity:GetClass() == "prop_physics") then
			return true, pos
		end
	end
	
	return false, pos, "Can't build here"
end

function MRTSCanPlaceBuilding(tr, unitData, size, angle, team)
	local pos = tr.HitPos
	local vTable = tr.Entity:GetTable()

	if (IsValid(tr.Entity)) then
		local phys = tr.Entity:GetPhysicsObject()
		if (IsValid(phys) and phys:GetMaterial() == "gmod_ice") then
			return false, pos, "Can't build here"
		end
	end

	if (MRTSIsOutOfBounds(pos)) then
		return false, pos, "Out of bounds"
	end

	local maxSize = math.max(size.x, size.y, size.z)*1.41
	local boundingBox = Vector(maxSize, maxSize, maxSize)
	local foundEnts = ents.FindInBox(pos-boundingBox, pos+boundingBox)

	if (math.abs(tr.HitNormal.x) >= 0.5 or math.abs(tr.HitNormal.y) >= 0.5 or tr.HitNormal.z <= 0) then
		return false, pos, "Can't build on wall or steep incline"
	end

	for k, v in pairs(foundEnts) do
		if (v.isMRTSUnit) then
			local boxA = {center=pos, angle=angle, size=size}
			local boxB = {center=v:GetCenter(), angle=v:GetAngles(), size=v:GetBoxSize()}
			if (MRTSBoxDetection(boxA, boxB)) then
				return false, pos, "There is something in the way"
			end
		end
	end

	if (GetConVar("mrts_sandbox_mode"):GetBool()) then
		return true, pos
	end

	if (not unitData.canBeBuiltAnywhere) then
		if (not MRTSIsInBuildingRange(pos, team)) then
			return false, pos, "Outside of building range"
		end
	end

	return true, pos
end

function GetMapController()
	if (!IsValid(mrtsMapController)) then
		local find = ents.FindByClass("ent_mrts_configurator")
		if (table.Count(find) > 0) then
			mrtsMapController = find[1]
		end
	end
	return mrtsMapController
end

function MRTSIsOutOfBounds(pos)
	local boundPlanes = ents.FindByClass("ent_mrts_bound_plane")
	for k, v in pairs(boundPlanes) do
		local dif = pos-v:GetPos()
		if (dif:Dot(v:GetRight()) > 0) then
			return true
		end
	end

	-- Point inside a polygon algorithm: https://youtu.be/3OmkehAJoyo?si=Y2_dsmH4wh_u8sMQ&t=190

	local boundPoles = ents.FindByClass("ent_mrts_bound_pole")
	local nexts = {}
	if (#boundPoles > 2) then
		local linesToTheRight = 0
		for k, v in ipairs(boundPoles) do
			local next = v.next
			if (IsValid(next)) then
				local start = v:GetPos()
				local finish = next:GetPos()
				local miny = math.min(start.y, finish.y)
				local maxy = math.max(start.y, finish.y)
				if (pos.y < maxy and pos.y > miny) then
					local slope = (finish.x-start.x)/(finish.y-start.y)
					local yDifference = pos.y-start.y
					local intersectionX = slope*yDifference + start.x
					if (intersectionX > pos.x) then
						linesToTheRight = linesToTheRight+1
					end
				end
			end
		end
		if (linesToTheRight%2 == 0) then
			return true
		end
	end
	return false
end

function MRTSSendBigString(str, data, ply)
	local packetSize = 65000
	local packetCount = math.ceil(string.len(str)/packetSize)
	local packets = {}
	for i=1, packetCount do
		local packetStart = (i-1)*packetSize+1
		local packetEnd = i*packetSize
		table.insert(packets, string.sub(str, packetStart, packetEnd))
	end
	print("Sending big string")
	print("Packet count: "..packetCount)
	net.Start("MRTSBigStringTransfer")
	net.WriteTable(data)
	net.WriteInt(packetCount, 8)
	for k, v in pairs(packets) do
		net.WriteString(v)
	end
	if (CLIENT) then
		net.SendToServer()
	else
		if (ply) then
			net.Send(ply)
		else
			net.Broadcast()
		end
	end
end