AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:SetData(owner, size, attack, target, fallbackPosition)
	self:SetPhysics()
	self.attack = attack
	self.target = target
	self.damage = owner:GetModifiedDamage(attack)
	if (attack.arc != nil) then
		self:SetGravity(1)

		local pos = fallbackPosition
		local velocity = Vector(0,0,0)
		if (IsValid(target)) then
			pos = target:GetPos()
			velocity = target:GetVelocity()
		end

		if (attack.spread) then
			local offset = VectorRand()
			offset.z = 0
			offset:Normalize()
			pos = pos + offset * math.random(0, attack.spread)
		end

		local diff = pos/*+Vector(0,0,-target:GetData().size)*/-self:GetPos()

		local d = Vector(diff.x,diff.y,0):Length() // flat distance

		// Prediction
		if (attack.prediction) then
			local constant = 0.006
			local predictedMovement = velocity*attack.prediction*d*constant
			predictedMovement.z = 0
			if (predictedMovement:Length() > 10) then
				predictedMovement = predictedMovement:GetNormalized()*10
			end
			diff = pos+predictedMovement-self:GetPos()
			d = Vector(diff.x,diff.y,0):Length()
		end

		local v = diff.z // Vertical distance
		local a = attack.arc // arc

		local b = d*a
		local p = b/a // root distance

		local flatDir = Vector(diff.x, diff.y, 0):GetNormalized()*300/a
		local shotVelocity = Vector(flatDir.x, flatDir.y, p*a + v/d/a*300)

		self.targetPos = pos

		self:SetPos(self:GetPos()+shotVelocity:GetNormalized()*size)
		self:GetPhysicsObject():SetVelocity(shotVelocity)
	end
	if (attack.effect.bullettrail != nil) then
		self:SetNWString("trail", attack.effect.bullettrail)
	end
end

function ENT:SetTeam(t)
	self.team = t
end

function ENT:GetTeam()
	return self.team
end

function ENT:SetOwner(owner)
	self.owner = owner
end

function ENT:SetPhysics()
	local size = 0.05
	self:SetCustomCollisionCheck(true)
	self:SetModel("models/hunter/misc/sphere025x025.mdl")
	self:PhysicsInitSphere( size, "gmod_ice" )
	self:SetCollisionBounds( Vector( -size, -size, -size )*0.5, Vector( size, size, size )*0.5 )
	self:PhysWake()
	self:GetPhysicsObject():SetMass(0.01)
	self:GetPhysicsObject():SetDamping(0, 0)
end

function ENT:PhysicsCollide( data, phys )
	if (data.HitEntity != self.owner) then
		MRTSAreaEffect(self, self:GetPos(), self.attack.radius, self.team, {
			forcedVictim=data.HitEntity,
			damage=self.damage,
			healing=self.attack.healing,
			status=self.attack.status,
			friendly=self.attack.targeting.allies
		})
		self:Remove()
	end
end

function ENT:OnRemove()
	if (self.attack != nil) then
		if (self.attack.effect.bullethit != nil) then
			net.Start("MRTSClientsideFX")
				net.WriteString(self.attack.effect.bullethit);
				net.WriteVector(self:GetPos());
				net.WriteVector(self:GetPos());
			net.Broadcast()
		end
	end
end