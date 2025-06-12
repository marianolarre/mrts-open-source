AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include('shared.lua')

function ENT:KeyValue(key, value)
    key = string.lower(key)

    if key == "type" then
        self.type = value
    end

    if key == "uniquename" then
        self.uniquename = value
    end

    if key == "team" then
        self.team = value
    end

    if key == "capturable" then
        self.capturable = (value != "0" and value != "false")
    end

    if key == "claimable" then
        self.claimable = (value != "0" and value != "false")
    end
end

function ENT:Initialize()
    if ((self.type or "building") == "troop") then
        MRTSSpawnTroop(self.team or 0, GetTroopIDByUniqueName(self.uniquename or ""), self:GetPos(), nil, true, false, self.capturable or false, self.claimable or false)
    else
        MRTSSpawnBuilding(self.team or 0, GetBuildingIDByUniqueName(self.uniquename or ""), self:GetPos(), self:GetAngles(), nil, true, self.capturable or false, self.claimable or false)
    end
    self:Remove()
end