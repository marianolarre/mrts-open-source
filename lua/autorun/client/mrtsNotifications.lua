mrtsNotifications = {}

function MRTSNotifyCombat(position)
    MRTSAddNotification(position, "icon16/bullet_error.png")
end

function MRTSNotifyDeath(position)
    MRTSAddNotification(position, "icon16/cross.png")
end

function MRTSNotifySighting(position)
    MRTSAddNotification(position, "icon16/eye.png")
end

function MRTSNotifyHQHit(position)
    MRTSAddNotification(position+Vector(0,0,100), "icon16/exclamation.png")
end

function MRTSAddNotification(position, icon)
    if (!GetConVar("mrts_display_notifications"):GetBool()) then return end
    for k, v in pairs(mrtsNotifications) do
        if (v.pos:Distance(position) < 25) then
            if (icon != v.icon or v.time < CurTime()-1) then
                v.time = CurTime()
            end
            v.icon = icon
            return
        end
    end
    table.insert(mrtsNotifications, {pos=position, icon=icon, time=CurTime()})
end

hook.Add( "HUDPaint", "MRTSNotifications", function()
    for k, v in pairs(mrtsNotifications) do
        local scrPos = v.pos:ToScreen()
        local dist = v.pos:Distance(EyePos())
        local scrPosFromCenter = Vector(ScrW()/2, ScrH()/2, 0) - Vector(scrPos.x, scrPos.y, 0)
        local maxDistFromCenter = math.min(ScrW(), ScrH())*0.45
        local distFromCenter = scrPosFromCenter:Length()
        if (distFromCenter > maxDistFromCenter) then
            scrPosFromCenter = scrPosFromCenter:GetNormalized()*maxDistFromCenter
            scrPos = Vector(ScrW()/2, ScrH()/2, 0)-scrPosFromCenter
        end
        local animation = 1/(0.02+(CurTime()-v.time))
        local centerFadeOut = math.Clamp((distFromCenter*3 + dist*3 - 4000), -100, 0)
        local size = math.Clamp(32 + centerFadeOut + animation, 0, 128)
        if (size <= 0) then
            table.RemoveByValue(mrtsNotifications, v)
        end
        MRTSDrawIcon(v.icon, scrPos.x, scrPos.y-25, size, size)
    end
end )

hook.Add( "Think", "MRTSCleanNotifications", function()
	for k, v in pairs(mrtsNotifications) do
        if (v.time < CurTime()-5) then
            table.RemoveByValue(mrtsNotifications, v)
        end
    end
end )