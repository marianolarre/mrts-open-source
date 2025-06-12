AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include('shared.lua')

usedMRTSPole = nil
boundPoles = {}

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

function ENT:KeyValue(key, value)
    key = string.lower(key)

    if key == "next" then
        self.hammerNext = value
    end
end

function ENT:SetRopeTexture()
    self.ropeTexture = "cable/rope"
    self.ropeWidth = 2
    self.color = Color(255, 150, 150)
end

function ENT:Initialize()
    self:SetRopeTexture()

	self:SetModel("models/hunter/plates/plate025.mdl")
    self:SetMaterial("phoenix_storms/stripes")
    self:SetColor(self.color)
    self:SetAngles(Angle(0,0,90))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid( SOLID_VPHYSICS )
    self:GetPhysicsObject():EnableMotion(false)
	self:SetCollisionGroup(COLLISION_GROUP_VEHICLE)
    self:SetUseType( SIMPLE_USE )

    if (self.hammerNext != nil) then
        local this = self
        timer.Simple(0.05, function()
            for k, v in ipairs(ents.FindByName(self.hammerNext)) do
                Connect(self, v)
                break
            end
        end)
    end

    if (self:CreatedByMap()) then
		self.mrtsPartOfTheMap = true
	end
end

function ENT:DelayedHammerConnection()
    
end

function ENT:Use( activator, caller, useType, value)
    if (self.mrtsPartOfTheMap) then
        return false
    end

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
    local count = #mrtsBoundPoles
    if (count > 0) then
        Connect(mrtsBoundPoles[count], self) 
    end
    if (count > 1) then
        Connect(self, mrtsBoundPoles[1])
    end

    table.insert(mrtsBoundPoles, self)
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
                self:SetNextPole(v.Ent2)
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
    table.RemoveByValue(boundPoles, self)
end