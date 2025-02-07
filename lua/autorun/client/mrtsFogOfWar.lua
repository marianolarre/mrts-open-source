local tab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 0.75,
	["$pp_colour_colour"] = 0.75,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local function drawStencilSphere( pos, ref, compare_func, radius, color, detail )
	render.SetStencilReferenceValue( ref )
	render.SetStencilCompareFunction( compare_func )
	render.DrawSphere(pos, radius, detail, detail, color)
end

-- Call this before calling render.AddWorldRing()
function render.StartFOW()
	render.MRTS_FOW = {}
	cam.IgnoreZ(false)
	render.SetStencilEnable(true)
	render.SetStencilTestMask(255)
	render.SetStencilWriteMask(255)
	render.ClearStencil()
	render.SetColorMaterial()
end

-- Args: pos = where, radius = how big, [thicc = how thick, detail = how laggy]
-- Detail must be an odd number or it will look like shit.
function render.AddFOW(pos, radius, thicc, detail)
	detail = detail or 25
	thicc = thicc or 10
	local z = {detail=detail, pos=pos, radius=radius}
	table.insert(render.MRTS_FOW, z)
end

-- Call this to actually draw the rings added with render.AddWorldRing()
function render.FinishFOW(color)
	local ply = LocalPlayer()
	local zones = render.MRTS_FOW
    
    render.SetStencilZFailOperation( STENCILOPERATION_DECR )
	for i, zone in ipairs(zones) do
		local radius = zone.radius
		drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, zone.radius, color_mask2, zone.detail ) -- big
	end
	render.SetStencilZFailOperation( STENCILOPERATION_INCR )
	for i, zone in ipairs(zones) do
		local radius = zone.radius
		drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, -zone.radius, color_mask2, zone.detail ) -- big, inside-out
	end
	render.SetStencilZFailOperation( STENCILOPERATION_INCR )
	for i, zone in ipairs(zones) do
		drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, -zone.radius, color_mask2, zone.detail ) -- small, inside-out
	end
	render.SetStencilZFailOperation( STENCILOPERATION_DECR )
	for i, zone in ipairs(zones) do
		drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, zone.radius, color_mask2, zone.detail ) -- small
	end

	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	local cam_pos = ply:EyePos()
	local cam_angle = ply:EyeAngles()
	local cam_normal = cam_angle:Forward()
	cam.IgnoreZ(true)
	render.SetStencilReferenceValue( 1 )
	render.DrawQuadEasy(cam_pos + cam_normal * 10, -cam_normal,10000,10000,color,cam_angle.roll)
	cam.IgnoreZ(false)
	render.SetStencilEnable(false)
end

local col = Color(0, 0, 0, 0)
hook.Add("PostDrawTranslucentRenderables", "mrts_fow", function()
	if (mrtsTeam == -1) then return end
	if (!mrtsFOW) then return end
	if (LocalPlayer():GetActiveWeapon():GetClass() != "weapon_mrts") then return end

    render.SetStencilWriteMask(255)
    render.SetStencilTestMask(255)
    render.SetStencilReferenceValue(1)

    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilFailOperation(STENCIL_ZERO)
    render.SetStencilZFailOperation(STENCIL_ZERO)
    render.ClearStencil()

    render.SetColorMaterial()

    local targets = mrtsUnits

    render.SetStencilEnable(true)
        render.SetStencilCompareFunction(STENCIL_ALWAYS)

        for _, v in pairs(targets) do
			if (v:IsAlliedToTeamID(mrtsTeam) and !v:GetUnderConstruction()) then
				local sight = v:GetData().sight or 50
				local center = v:GetCenter()
				render.SetStencilZFailOperation(STENCIL_INCR)
				render.DrawSphere(center, -sight, 16, 7, col)
				render.SetStencilZFailOperation(STENCIL_DECR)
				render.DrawSphere(center, sight, 16, 7, col)
			end
        end

        render.SetStencilCompareFunction(STENCIL_GREATER)

        /*cam.Start2D()
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        cam.End2D()*/
		DrawColorModify(tab)

    render.SetStencilEnable(false)
end)