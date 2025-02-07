local MRTSNewItems = {}
local MRTSReplacedItems = {}

local function MRTSMergeItem(idName, targetTable, item)
	if (SERVER and mrtsCustomDatapackInfo.additive) then
		for k, v in pairs(targetTable) do
			if (v[idName] == item[idName]) then
				targetTable[k] = item
				table.insert(MRTSReplacedItems, item[idName])
				-- If its SERVER and its additive, replace the entry with the same idName
				return
			end
		end
	end

	table.insert(MRTSNewItems, item[idName])
	table.insert(targetTable, item)
end

net.Receive( "MRTSStartDatapackTransfer", function()
	mrtsCustomDatapackInfo = net.ReadTable()
	if ((SERVER and not mrtsCustomDatapackInfo.additive) or CLIENT) then
		mrtsGameData = {info=mrtsCustomDatapackInfo, troops={},buildings={},parts={}}
	end
	MRTSNewItems = {}
	MRTSReplacedItems = {}
	print("Starting reception of datapack '"..mrtsCustomDatapackInfo.name.."'")
end )

net.Receive( "MRTSDatapackTroop", function()
	local tbl = net.ReadTable()
	--table.insert(mrtsGameData.troops, tbl)
	MRTSMergeItem("uniqueName", mrtsGameData.troops, tbl)
	--print( "Loading troop: "..tbl.uniqueName)
end )

net.Receive( "MRTSDatapackBuilding", function()
	local tbl = net.ReadTable()
	--table.insert(mrtsGameData.buildings, tbl)
	MRTSMergeItem("uniqueName", mrtsGameData.buildings, tbl)
	--print( "Loading building: "..tbl.uniqueName)
end )

net.Receive( "MRTSDatapackPart", function()
	local tbl = net.ReadTable()
	--table.insert(mrtsGameData.parts, tbl)
	MRTSMergeItem("uniqueName", mrtsGameData.parts, tbl)
	--print( "Loading part: "..tbl.uniqueName)
end )

local function MRTSMergeTables(idName, target, source)
	for k, v in pairs(source) do
		local replaced = false
		for kk, vv in pairs(target) do
			if (v[idName] == vv[idName]) then
				target[kk] = v
				table.insert(MRTSReplacedItems, v[idName])
				replaced = true
				break
			end
		end
		if (not replaced) then
			table.insert(MRTSNewItems, v[idName])
			table.insert(target, v)
		end
	end
end

net.Receive( "MRTSDatapackComplete", function()
	if (SERVER and mrtsCustomDatapackInfo.additive) then
		MRTSMergeTables("uniqueName", mrtsGameData.resources, net.ReadTable())
		MRTSMergeTables("name", mrtsGameData.teams, net.ReadTable())
		MRTSMergeTables("uniqueName", mrtsGameData.factions, net.ReadTable())
		MRTSMergeTables("uniqueName", mrtsGameData.status, net.ReadTable())
		print("Additive datapack reception complete:")
		print(" - teams: "..#mrtsGameData.teams.." - factions: "..#mrtsGameData.factions.." - resources: "..#mrtsGameData.resources.." - status: "..#mrtsGameData.status.." - troops: "..#mrtsGameData.troops.." - buildings: "..#mrtsGameData.buildings.." - parts: "..#mrtsGameData.parts)
	else
		mrtsGameData.resources = net.ReadTable()
		mrtsGameData.teams = net.ReadTable()
		mrtsGameData.factions = net.ReadTable()
		mrtsGameData.status = net.ReadTable()
		print("Conversion datapack reception complete:")
		print(" - teams: "..#mrtsGameData.teams.." - factions: "..#mrtsGameData.factions.." - resources: "..#mrtsGameData.resources.." - status: "..#mrtsGameData.status.." - troops: "..#mrtsGameData.troops.." - buildings: "..#mrtsGameData.buildings.." - parts: "..#mrtsGameData.parts)
	end
	if (#MRTSNewItems > 0) then
		print("New items: ", table.concat(MRTSNewItems, ", "))
	else
		print("No new items")
	end
	if (#MRTSReplacedItems > 0) then
		print("Overwritten items: ", table.concat(MRTSReplacedItems, ", "))
	else
		print("No overwritten items")
	end
	MRTSInitializeDatapack()
	if (CLIENT) then
		notification.AddLegacy( "MRTS '"..mrtsCustomDatapackInfo.name.."' datapack transfer complete!", NOTIFY_GENERIC, 5 )
		if (mrtsGameMenu != nil) then
			mrtsGameMenu:Close()
		end
		PrintTable(mrtsGameData.troops[2].accessories[1].idle.offset)
	end
	if (SERVER) then
		print( "MRTS '"..mrtsCustomDatapackInfo.name.."' datapack transfer complete!")
		MRTSBroadcastDatapack()
	end
	if (CLIENT) then
		mrtsFOW = GetConVar("mrts_fow"):GetBool()
	end
end )

net.Receive("MRTSBigStringTransfer", function(len, ply)
	local data = net.ReadTable()
	local packetCount = net.ReadInt(8)
	local packets = {}
	for i=1, packetCount do
		table.insert(packets, net.ReadString())
	end
	local str = table.concat(packets)
	
	if (CLIENT) then
		if (data.purpose == "SaveContraption") then
			print("Saving contraption")
			MRTSSaveContraptionDialogue(str)
		end
	else
		if (data.purpose == "LoadContraption") then
			print("Loading contraption")
			PrintTable(data)
			local dupeTable = util.JSONToTable(str)
			/*local corner = dupeTable.Mins+dupeTable.Maxs
			print(dupeTable.Mins)
			print(dupeTable.Maxs)*/
			duplicator.SetLocalPos(data.pos)
			duplicator.Paste( pl, dupeTable.Entities, dupeTable.Constraints )
			duplicator.SetLocalPos(Vector(0,0,0))
		end
		if (data.purpose == "LoadContraptionOntoAssembler") then
			print("Loading contraption onto assembler")
			data.assembler.contraption = str
			data.assembler:SetNWString("contraptionName", data.name)
		end
	end
end)