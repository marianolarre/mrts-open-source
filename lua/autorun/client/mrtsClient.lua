CreateConVar( "mrts_sandbox_mode", "0", FCVAR_REPLICATED )
CreateConVar( "mrts_playing", "1", FCVAR_REPLICATED )
CreateConVar( "mrts_fow", "0", FCVAR_REPLICATED )
CreateConVar( "mrts_max_population", "75", FCVAR_REPLICATED )
CreateConVar( "mrts_datapack", "default", FCVAR_ARCHIVE )
CreateConVar( "mrts_display_unit_team", "1", FCVAR_ARCHIVE )
CreateConVar( "mrts_display_notifications", "1", FCVAR_ARCHIVE )

CreateClientConVar( "mrts_render_grid", "0", true, false, "Whether or not a yellow grid should be drawn around the crosshair" )
CreateClientConVar( "mrts_render_walls", "0", true, false, "Whether or not to render the map controllers wall grid" )

mrtsContraptionPanel = nil
mrtsPlacingBuildingSource = nil;
mrtsPlacingBuilding = false;
mrtsPlacingBuildingBig = false;
mrtsShowCorner = false;
mrtsTeam = 1;

mrtsMapSetupPlacingTroop = false -- as opposed to placing a building
mrtsMapSetupUnitID = 0;
mrtsMapSetupUnitObjective = false;
mrtsMapSetupTeamPage = 0;
mrtsMapSetupUnitPage = 0;

mrtsRenderGrid = true;

mrtsShowingEventMenu = false;
mrtsNextEventMenuOpen = 0;

mrtsMapEditorWidth = 8
mrtsMapEditorHeight = 8
mrtsMapEditorChangingSize = false

mrtsCustomDatapackName = ""
mrtsUnits = {}

mrtsPaths = {}
mrtsMaterials = {}

hook.Add("Initialize", "mrts_initialize_client", function()
	MRTSWriteDefaultFiles()
	LocalPlayer().selectedEntities = {}
	mrtsUnits = ents.FindByClass("ent_mrts_building")
	table.Add(mrtsUnits, ents.FindByClass("ent_mrts_troop"))
	mrtsBoundPlanes = ents.FindByClass("ent_mrts_bound_plane")
	mrtsFOW = GetConVar("mrts_fow"):GetBool()
end)

function GetDatapackName()
	local convar = GetConVar("mrts_datapack")
	if (convar != nil) then
		local datapack = convar:GetString()
		if (datapack == "") then
			return "default"
		end
		return datapack
	end
	return "default"
end
/*
function LoadMRTSMaterial(key)
	if (mrtsMaterials[key] != nil) then
		return mrtsMaterials[key]
	else
		local datapack = GetDatapackName()
		local mat = Material("../data/mrts/datapacks/"..datapack.."/sprites/"..key..".png", "alphatest")
		mrtsMaterials[key] = mat
		return mat
	end
end

function DownloadMRTSSprite(key, url)
	-- cleanup old sprites
	file.Delete( "mrts/sprites/"..key..".png" )

	url = url or "https://raw.githubusercontent.com/marianolarre/mrts/master/UnitIcons/Scout.png"
	print(url)
	local datapack = GetDatapackName()
	http.Fetch(url, function(body)
	  -- fetch succeeded: write the file
	  file.Write("mrts/datapacks/"..datapack.."/sprites/"..key..".png", body)
	end, function(error)
		print("MRTS - Download of "..key.."'s sprite (url: "..tostring(url)..") failed: "..error)
	end)
end
*/
function MRTSWriteDefaultFiles()
	file.Delete( "mrts/datapacks/default" )
	file.CreateDir( "mrts/datapacks/default" )
	file.Write( "mrts/datapacks/readme.txt", mrtsDatapackInstruction )

	file.Write("mrts/datapacks/default/info.json", util.TableToJSON(mrtsGameData.info, true))
	file.CreateDir( "mrts/datapacks/default/teams" )
	for k, v in pairs(mrtsGameData.teams) do
		local lowercaseName = string.lower(v.name)
		file.Write( "mrts/datapacks/default/teams/"..lowercaseName..".json", util.TableToJSON(v,true) )
	end
	file.CreateDir( "mrts/datapacks/default/factions" )
	for k, v in pairs(mrtsGameData.factions) do
		file.Write( "mrts/datapacks/default/factions/"..v.uniqueName..".json", util.TableToJSON(v,true) )
	end
	file.CreateDir( "mrts/datapacks/default/resources" )
	for k, v in pairs(mrtsGameData.resources) do
		file.Write( "mrts/datapacks/default/resources/"..v.uniqueName..".json", util.TableToJSON(v,true) )
	end
	file.CreateDir( "mrts/datapacks/default/status" )
	for k, v in pairs(mrtsGameData.status) do
		file.Write( "mrts/datapacks/default/status/"..v.uniqueName..".json", util.TableToJSON(v,true) )
	end
	file.CreateDir( "mrts/datapacks/default/troops" )
	for k, v in pairs(mrtsGameData.troops) do
		file.Write( "mrts/datapacks/default/troops/"..v.uniqueName..".json", util.TableToJSON(v,true) )
	end
	file.CreateDir( "mrts/datapacks/default/buildings" )
	for k, v in pairs(mrtsGameData.buildings) do
		file.Write( "mrts/datapacks/default/buildings/"..v.uniqueName..".json", util.TableToJSON(v,true) )
	end
	file.CreateDir( "mrts/datapacks/default/parts" )
	for k, v in pairs(mrtsGameData.parts) do
		file.Write( "mrts/datapacks/default/parts/"..v.uniqueName..".json", util.TableToJSON(v,true) )
	end
end

function MRTSLoadDatapackFile()
	-- Load datapack
	local datapack = GetDatapackName()
	--if (datapack != "default") then
		fileContent = file.Read("mrts/datapacks/"..datapack.."/info.json", "DATA")
		local info = {name="Untitled datapack", author="unknown", description="-", additive=true}
		if (fileContent) then
			info = util.JSONToTable(fileContent)
		end
		local datapackTable = {}
		datapackTable.info = info
		datapackTable.teams = MRTSLoadFolderAsTable("mrts/datapacks/"..datapack.."/teams", true)
		datapackTable.factions = MRTSLoadFolderAsTable("mrts/datapacks/"..datapack.."/factions", true)
		datapackTable.resources = MRTSLoadFolderAsTable("mrts/datapacks/"..datapack.."/resources", true)
		datapackTable.status = MRTSLoadFolderAsTable("mrts/datapacks/"..datapack.."/status", true)
		datapackTable.troops = MRTSLoadFolderAsTable("mrts/datapacks/"..datapack.."/troops", true)
		datapackTable.buildings = MRTSLoadFolderAsTable("mrts/datapacks/"..datapack.."/buildings", true)
		datapackTable.parts = MRTSLoadFolderAsTable("mrts/datapacks/"..datapack.."/parts", true)
		--MRTSLoadTeams()
		return datapackTable

		/*local datapackContent = file.Read("mrts/datapacks/"..datapack.."/data.txt")
		if (datapackContent == nil) then
			notification.AddLegacy( "Couldn't find file 'data/mrts/datapacks/"..datapack.."/data.txt'", NOTIFY_ERROR, 4 )
			--MRTSLoadAllSprites("default")
			return false
		else
			mrtsGameData = {}

			mrtsGameData = util.JSONToTable(datapackContent)

			MRTSLoadTeams()
			success = true
			--notification.AddLegacy( "Successfuly loaded datapack '"..datapack.."'", NOTIFY_GENERIC, 5 )
			--MRTSLoadAllSprites(datapack)
			return true
		end
	else*/
		--MRTSLoadAllSprites("default")
	--end
end

function MRTSResetMenu(tab)
	if (IsValid(LocalPlayer())) then
		if (LocalPlayer():GetActiveWeapon():GetClass() == "weapon_mrts") then
			local menuOpen = IsValid(mrtsGameMenu) and mrtsGameMenu:IsVisible()
			mrtsGameMenu:Close()
			if (menuOpen) then
				LocalPlayer():GetActiveWeapon():OpenGameMenu()
				LocalPlayer():GetActiveWeapon():GoToTab(tab)
			end
		end
	end
end

function MRTSLoadFolderAsTable(folder, recursive)
	local fileNames, directories = file.Find(folder.."/*", "DATA")
	local tbl = {}
	local successfullFiles = 0
	for k, v in pairs(fileNames) do
		local fileContent = file.Read(folder.."/"..v, "DATA")
		local jsonToTable = util.JSONToTable(fileContent)
		table.insert(tbl, jsonToTable)
		if (not istable(jsonToTable)) then
			print("File "..folder.."/"..v.." is not a valid JSON")
		else
			successfullFiles = successfullFiles+1
		end
	end
	print(successfullFiles.." files loaded successfully from folder "..folder)
	
	if (recursive) then
		for k, v in pairs(directories) do
			local subtbl = MRTSLoadFolderAsTable(folder.."/"..v, true)
			table.Add(tbl, subtbl)
		end
	end

	table.SortByMember(tbl, "order", true)

	return tbl
end

function MRTSSendDatapackToServer()
	mrtsCustomDatapackName = GetConVar("mrts_datapack"):GetString()
	print("Sending client datapack to server: "..mrtsCustomDatapackName)
	/*if (mrtsCustomDatapackName == "default") then
		net.Start("MRTSRequestServerLoadDefaultDatapack")
		net.SendToServer()
	else*/
		datapackTable = MRTSLoadDatapackFile(mrtsCustomDatapackName)
		local info = datapackTable.info or {name="Untitled datapack", author="unknown", description="-", additive=true}
		if (datapackTable) then
			net.Start("MRTSStartDatapackTransfer")
				print("Transfering datapack: "..GetConVar("mrts_datapack"):GetString())
				net.WriteTable(datapackTable.info)
			net.SendToServer()
			for k, v in pairs(datapackTable.troops) do
				net.Start("MRTSDatapackTroop")
					net.WriteTable(v)
				net.SendToServer()
			end
			for k, v in pairs(datapackTable.buildings) do
				net.Start("MRTSDatapackBuilding")
					net.WriteTable(v)
				net.SendToServer()
			end
			for k, v in pairs(datapackTable.parts) do
				net.Start("MRTSDatapackPart")
					net.WriteTable(v)
				net.SendToServer()
			end
			net.Start("MRTSDatapackComplete")
				net.WriteTable(datapackTable.resources)
				net.WriteTable(datapackTable.teams)
				net.WriteTable(datapackTable.factions)
				net.WriteTable(datapackTable.status)
			net.SendToServer()
		end
	--end
end

hook.Add("PostDrawOpaqueRenderables", "mrts_debug_boxes", function()
	if (not mrtsPreviewBox) then return end
	if (not LocalPlayer():Alive()) then return end
	if (not IsValid(LocalPlayer():GetActiveWeapon())) then return end
	if (LocalPlayer():GetActiveWeapon():GetClass() != "weapon_mrts") then return end
	render.DrawWireframeBox( mrtsPreviewBox.pos,mrtsPreviewBox.angle,-mrtsPreviewBox.size,mrtsPreviewBox.size,color_white,true)
end)

hook.Add( "Think", "mrtsClientThink", function()	
	local tr = LocalPlayer():GetEyeTrace()
	local ent = tr.Entity
	if (IsValid(tr.Entity)) then
		if (ent:GetNWString("mrtsTooltip", "nope") != "nope") then
			AddWorldTip( nil,ent:GetNWString("mrtsTooltip", "tooltip error"), nil, Vector(0,0,0), ent )
		end
	end
end)

function MRTSAddStatus(unit, statusID)
	if (unit.status == nil) then
		unit.status = {}
	end
	unit.status[statusID] = true
end

function MRTSRemoveStatus(unit, statusID)
	unit.status[statusID] = nil
end

function MRTSDrawUnitIcon(uniqueName, _team, x, y, maxWidth, maxHeight, maxScale)
	local data = GetTroopByUniqueName(uniqueName)
	local texture = data.icon
	local mat = LoadMRTSMaterial(uniqueName)

	local width = maxWidth--mat:Width()
	local height = maxHeight--mat:Height()

	surface.SetMaterial(mat)
	surface.SetDrawColor(255,255,255)
	surface.DrawTexturedRect(x-width/2, y-height/2, width, height)
end

function MRTSDrawResourceIcon(uniqueName, x, y, width, height)
	local data = GetResourceByUniqueName(uniqueName)
	MRTSDrawIcon(data.icon, x, y, width, height)
	/*local data = GetResourceByUniqueName(uniqueName)
	local texture = data.url
	local mat = LoadMRTSMaterial(uniqueName)

	surface.SetMaterial(mat)
	surface.SetDrawColor(255,255,255)
	surface.DrawTexturedRect(x-math.floor(width/2), y-math.floor(height/2), width, height)*/
end

local gmodIcons = {}
function MRTSDrawIcon(icon, x, y, width, height)
	if (string.len(icon) > 4) then
		if (gmodIcons[icon] == nil) then
			gmodIcons[icon] = Material(icon)
		end
		surface.SetMaterial(gmodIcons[icon])
		surface.SetDrawColor(0, 0, 0)
		surface.DrawTexturedRect(x-width/2-1, y-height/2, width, height)
		surface.DrawTexturedRect(x-width/2+1, y-height/2, width, height)
		surface.DrawTexturedRect(x-width/2, y-height/2-1, width, height)
		surface.DrawTexturedRect(x-width/2, y-height/2+1, width, height)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawTexturedRect(x-width/2, y-height/2, width, height)
	else
		DrawEmoji(icon, x-1, y, width, true)
		DrawEmoji(icon, x+1, y, width, true)
		DrawEmoji(icon, x, y-1, width, true)
		DrawEmoji(icon, x, y+1, width, true)
		DrawEmoji(icon, x, y, width)
	end
end

function MRTSDrawPopulationIcon(x, y, width, height)
	MRTSDrawIcon("🏠", x, y, width, height)
end

function MRTSDrawCircularProgressBar(x, y, radius, percent)
	local cir = {}
	local seg = percent*64
	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( 180 + ( i / seg ) * -360 * percent)
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end
	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.SetDrawColor( 255, 255, 0, 255 )
	draw.NoTexture()
	surface.DrawPoly( cir )
end

function PercentToHealthbarColor(percent)
	return Color(math.min(2-percent*2, 1)*255, math.min(percent*2,1)*255, 0)
end

mrtsCurrentContraptionStr = ""
mrtsSelectedContraptionName = ""
mrtsCurrentAssembler = nil
function MRTSSaveContraptionDialogue(str)
	mrtsCurrentContraptionStr = str
	mrtsContraptionPanel = vgui.Create("DFrame") -- The name of the panel we don't have to parent it.
	mrtsContraptionPanel:SetPos(ScrW()/2-300, ScrH()/2-200) -- Set the position to 100x by 100y. 
	mrtsContraptionPanel:SetSize(600, 400) -- Set the size to 300x by 200y.
	mrtsContraptionPanel:SetTitle("Save Contraption") -- Set the title in the top left to "Derma Frame".
	mrtsContraptionPanel:MakePopup() -- Makes your mouse be able to move around.
	mrtsContraptionPanel:DockPadding(10,40,10,10)

	local TextEntryPH = vgui.Create( "DTextEntry", mrtsContraptionPanel )
	TextEntryPH:Dock( BOTTOM )
	TextEntryPH:DockMargin( 0, 5, 0, 0 )
	TextEntryPH:SetPlaceholderText( "Contraption name" )
	
	local browser = vgui.Create( "DFileBrowser", mrtsContraptionPanel )
	browser:Dock( FILL )
	browser:SetPath( "DATA" ) -- The access path i.e. GAME, LUA, DATA etc.
	browser:SetBaseFolder( "mrts/contraptions" ) -- The root folder
	browser:SetOpen( true ) -- Open the tree to show sub-folders
	browser:SetCurrentFolder( "mrts/contraptions" )
	function browser:OnSelect( path, pnl ) -- Called when a file is clicked
		local fileName = string.TrimLeft(path, "mrts/contraptions/")
		fileName = string.TrimRight(fileName, ".txt")
		TextEntryPH:SetValue(fileName)
	end
	function browser:OnDoubleClick( path, pnl ) -- Called when a file is clicked
		local fileName = string.TrimLeft(path, "mrts/contraptions/")
		fileName = string.TrimRight(fileName, ".txt")
		mrtsContraptionPanel:Close()
		MRTSSaveContraptionFile(mrtsCurrentContraptionStr, fileName)
	end

	TextEntryPH.OnEnter = function( self )
		mrtsContraptionPanel:Close()
		MRTSSaveContraptionFile(mrtsCurrentContraptionStr, self:GetValue())
	end
end

function MRTSSaveContraptionFile(str, name)
	notification.AddLegacy("Contraption saved as '"..name.."'", 0, 5)
	file.Write("mrts/contraptions/"..name..".txt", str)
end

function MRTSLoadContraption(contraptionName, pos)
    local contraptionPath = "mrts/contraptions/"..contraptionName..".txt"
	print("Loading "..contraptionPath)
	local str = file.Read(contraptionPath, "DATA")
	MRTSSendBigString(str, {purpose="LoadContraption", pos=pos})
end

function MRTSLoadContraptionDialog(assembler)
	mrtsCurrentAssembler = assembler
	mrtsCurrentContraptionStr = str
	mrtsContraptionPanel = vgui.Create("DFrame") -- The name of the panel we don't have to parent it.
	mrtsContraptionPanel:SetPos(ScrW()/2-300, ScrH()/2-200) -- Set the position to 100x by 100y. 
	mrtsContraptionPanel:SetSize(600, 400) -- Set the size to 300x by 200y.
	mrtsContraptionPanel:SetTitle("Load Contraption") -- Set the title in the top left to "Derma Frame".
	mrtsContraptionPanel:MakePopup() -- Makes your mouse be able to move around.
	mrtsContraptionPanel:DockPadding(10,40,10,10)
	mrtsContraptionPanel:SetDeleteOnClose(true)

	local Button = vgui.Create( "DButton", mrtsContraptionPanel )
	Button:Dock( BOTTOM )
	Button:SetText("Load")
	Button:SetEnabled(false)
	Button:DockMargin( 0, 5, 0, 0 )
	
	local browser = vgui.Create( "DFileBrowser", mrtsContraptionPanel )
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
		local str = file.Read(path, "DATA")
		mrtsContraptionPanel:Close()
		mrtsCurrentAssembler:SendContraption(str, {name=fileName})
		--self:SetStage(STAGE_LOADING_CONTRAPTION)
	end
end

---------------- Player Initial Spawn
-- CLIENT
/*hook.Add( "InitPostEntity", "MRTSReady", function()
	print("MRTS client ready")
	net.Start( "MRTSClientReady" )
	net.SendToServer()
end )*/
-------------------------------------

hook.Add("PreDrawTranslucentRenderables", "FixEyePos", function() EyePos() end)

concommand.Add( "mrts_reload_datapack", function( ply, cmd, args )
    MRTSSendDatapackToServer()
end )

concommand.Add( "mrts_load_contraption", function( ply, cmd, args )
	local pos = ply:GetEyeTrace().HitPos
	local contraptionName = args[1]
    local contraptionPath = "mrts/contraptions/"..contraptionName..".txt"
	print("Loading "..contraptionPath)
	local str = file.Read(contraptionPath, "DATA")
	MRTSSendBigString(str, {purpose="LoadContraption", pos=pos})
end )