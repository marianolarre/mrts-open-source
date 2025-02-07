AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include('shared.lua')

usedMRTSPole = nil
mrtsPoles = {}

local function Connect(a, b)
    if (a.next == b) then
        if (IsValid(a.connection)) then
            a.connection:Remove()
            a.connection = nil
            a.next = nil
        end
        return false
    elseif (b.next == a) then
        if (IsValid(b.connection)) then
            b.connection:Remove()
            b.connection = nil
            b.next = nil
        end
        return false
    else
        if (IsValid(a.connection)) then
            a.connection:Remove()
        end
        a.next = b
        local cons= constraint.Elastic( a, b, 0, 0, Vector(0,5,1.5), Vector(0,5,1.5), 0, 0, 0, "cable/redlaser", 5, true, color_white )
        a.connection = cons
        return true
    end
end

function ENT:Initialize()
	self:SetModel("models/hunter/plates/plate025.mdl")
    self:SetMaterial("phoenix_storms/stripes")
    self:SetColor(Color(185, 88, 88))
    self:SetAngles(Angle(0,0,90))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid( SOLID_VPHYSICS )
    self:GetPhysicsObject():EnableMotion(false)
	self:SetCollisionGroup(COLLISION_GROUP_VEHICLE)
    self:SetUseType( SIMPLE_USE )
end

function ENT:Use( activator, caller, useType, value)
    if (usedMRTSPole != nil and usedMRTSPole != self) then
        local action = Connect(usedMRTSPole, self)
        if (action) then
            activator:PrintMessage( HUD_PRINTTALK, "Connected with last pole" )
        else
            activator:PrintMessage( HUD_PRINTTALK, "Removed connection" )
        end
        usedMRTSPole = nil
    else
        usedMRTSPole = self
        activator:PrintMessage( HUD_PRINTTALK, "Now Use another pole to connect" )
    end
end

function ENT:ConnectToLastPole()
    local count = #mrtsPoles
    if (count > 0) then
        Connect(mrtsPoles[count], self) 
    end
    if (count > 1) then
        Connect(self, mrtsPoles[1])
    end

    table.insert(mrtsPoles, self)
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
    ent:ConnectToLastPole()
	ent:Activate()

	return ent

   
end

function ENT:Think()
    if (self.rebuild) then
        self.rebuild = false
        for k, v in pairs(constraint.FindConstraints( self, "Elastic")) do
            if (v.Ent1 == self) then
                self.next = v.Ent2
                self:NextThink( CurTime() + 1000000 )
                return true
            end
        end
    end
end

function ENT:PostEntityPaste(ply, ent, createdEntities)
    self.rebuild = true
end

function ENT:OnRemove()
    table.RemoveByValue(mrtsPoles, self)
end