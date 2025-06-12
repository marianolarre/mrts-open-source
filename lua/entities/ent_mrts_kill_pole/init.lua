AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include('shared.lua')

mrtsUsedKillPole = nil
mrtsKillPoles = {}
mrtsBoundPoles = {}

local function Connect(a, b)
    if (a:GetNextPole() == b) then
        if (IsValid(a.connection)) then
            a.connection:Remove()
            a.connection = nil
            a:SetNextPole(nil)
        end
        return false
    elseif (b:GetNextPole() == a) then
        if (IsValid(b.connection)) then
            b.connection:Remove()
            b.connection = nil
            b:SetNextPole(nil)
        end
        return false
    else
        if (IsValid(a.connection)) then
            a.connection:Remove()
        end
        a:SetNextPole(b)
        local cons= constraint.Elastic( a, b, 0, 0, Vector(0,5,1.5), Vector(0,5,1.5), 0, 0, 0, a.ropeTexture, a.ropeWidth, true, color_white )
        a.connection = cons
        return true
    end
end

function ENT:SetRopeTexture()
    self.ropeTexture = "cable/redlaser"
    self.ropeWidth = 5
    self.color = Color(255, 88, 88)
end

function ENT:Use( activator, caller, useType, value)
    if (self.mrtsPartOfTheMap) then
        return false
    end

    if (mrtsUsedKillPole != nil and mrtsUsedKillPole != self) then
        local action = Connect(mrtsUsedKillPole, self)
        if (action) then
            activator:PrintMessage( HUD_PRINTTALK, "Connected with last pole" )
        else
            activator:PrintMessage( HUD_PRINTTALK, "Removed connection" )
        end
        mrtsUsedKillPole = nil
    else
        mrtsUsedKillPole = self
        activator:PrintMessage( HUD_PRINTTALK, "Now Use another pole to connect" )
    end
end

function ENT:ConnectToLastPole()
    local count = #mrtsKillPoles
    if (count > 0) then
        Connect(mrtsKillPoles[count], self) 
    end
    if (count > 1) then
        Connect(self, mrtsKillPoles[1])
    end

    table.insert(mrtsKillPoles, self)
end

function ENT:OnRemove()
    table.RemoveByValue(mrtsKillPoles, self)
end