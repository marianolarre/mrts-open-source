function MRTS_MoveType(ent, serverThinkRate, moveType, first)
	if (moveType == "none") then
	elseif (moveType == "static") then
		MRTS_MoveType_Static(ent, serverThinkRate, first);
	elseif (moveType == "ground") then
		MRTS_MoveType_Ground(ent, serverThinkRate, first);
	elseif (moveType == "air") then
		MRTS_MoveType_Air(ent, serverThinkRate, first);
	elseif (moveType == "water") then
		MRTS_MoveType_Water(ent, serverThinkRate, first);
	elseif (moveType == "engine") then
		MRTS_MoveType_Engine(ent, serverThinkRate, first);
	else
		print("No such move type: "..moveType);
	end
end

function MRTS_MoveType_Static(ent, serverThinkRate, first)
	if (first) then
		ent:SetMoveType(MOVETYPE_NONE)
	end
end

function MRTS_MoveType_Ground(ent, serverThinkRate, first)
	if (not first) then
		local vel = ent:GetVelocity();
		local targetPos2D = Vector(ent:GetMovePos().x, ent:GetMovePos().y)
		local pos2D = Vector(ent:GetPos().x, ent:GetPos().y)
		
		local difference = targetPos2D-pos2D;

		local spd = ent:GetModifiedSpeed()
		if (difference:LengthSqr() > 2*(serverThinkRate*serverThinkRate)*(spd*spd)) then
			local diff2D = Vector(difference.x, difference.y)
			local dist = diff2D:Length()
			local movement = diff2D/math.max(dist,spd/2) // reduce movement when dist < spd/5
			if (dist < spd/2) then
				ent:FinishMovement()
			end

			local desiredSpeed = movement*spd

			ent:GetPhysicsObject():Wake()
			ent.desiredVelocity = desiredSpeed

			ent.currentDistance = difference:Length()
			if (not ent.attacking or ent.canAttackWhileMoving) then
				if (ent:GetVelocity():LengthSqr() < (spd*spd)/2/*ent.lastDistance-ent.currentDistance < ent.stuckTolerance+1*/) then
					ent.stuckCounter = ent.stuckCounter+1
				else
					ent.stuckCounter = 0
					ent.stuckFrustration = 0
				end
				if (ent.stuckCounter > 5) then
					if (ent.stuckFrustration < 2) then
						ent:Unstuck(ent.stuckFrustration, ent.desiredVelocity)
						ent.stuckFrustration = ent.stuckFrustration+1
						ent.stuckCounter = 0
					else
						ent:FinishMovement()
					end
				end
			end
			/*if (ent.lastDistance > ent.currentDistance) then
				ent.lastDistance = ent.currentDistance
			end*/
		else
			ent:FinishMovement()
		end
	else
		ent:SetMoveType(MOVETYPE_VPHYSICS)
		ent:GetPhysicsObject():EnableMotion(true)
	end
end

local function MRTS_Move_type_Air_Trace(ent)
	local height = ent:GetData().altitude or 60
	local tr = util.TraceLine( {
		start = ent:GetPos(),
		endpos = ent:GetPos() + Vector(0, 0, -height*10),
		mask = MASK_WATER+MASK_SOLID,
		filter = function( ent ) if ( ent:GetClass() == "prop_physics" or ent:IsWorld() ) then return true end end
	} )
	if (tr.Hit) then
		ent.flyHeight = tr.HitPos.z+height
	else
		ent.flyHeight = ent:GetPos().z-height*10
	end
	ent.nextFlyCheck = CurTime()+0.67
end

function MRTS_MoveType_Air(ent, serverThinkRate, first)
	if (not first) then
		if ((ent.nextFlyCheck or 0) <= CurTime()) then
			MRTS_Move_type_Air_Trace(ent)
		end
		local vel = ent:GetVelocity();
		local targetPos2D = Vector(ent:GetMovePos().x, ent:GetMovePos().y)
		local pos2D = Vector(ent:GetPos().x, ent:GetPos().y)
		local difference = targetPos2D-pos2D;

		local spd = ent:GetModifiedSpeed()
		if (difference:LengthSqr() > 2*(serverThinkRate*serverThinkRate)*(spd*spd)) then
			local diff2D = Vector(difference.x, difference.y)
			local dist = diff2D:Length()
			local movement = diff2D/math.max(dist,spd/2) // reduce movement when dist < spd/5
			if (dist < spd/2) then
				if (not ent.flies or math.abs(ent:GetPos().z-ent.flyHeight) < 5) then
					ent:FinishMovement()
				end
				MRTS_Move_type_Air_Trace(ent)
			end
			/*if (ent.target != nil) then
				spd = ent:GetData().speedWhileAttacking
			end*/

			local desiredSpeed = movement*spd

			ent:GetPhysicsObject():Wake()
			ent.desiredVelocity = desiredSpeed

			ent.currentDistance = difference:Length()
			if (not ent.attacking or ent.canAttackWhileMoving) then
				if (ent.lastDistance-ent.currentDistance < ent.stuckTolerance+1) then
					ent.stuckCounter = ent.stuckCounter+1
				else
					ent.stuckCounter = 0
					ent.stuckFrustration = 0
				end
				if (ent.stuckCounter > 3) then
					if (ent.stuckFrustration < 2) then
						ent:Unstuck(ent.stuckFrustration, ent.desiredVelocity)
						ent.stuckFrustration = ent.stuckFrustration+1
						ent.stuckCounter = 0
					else
						if (not ent.flies or math.abs(ent:GetPos().z-ent.flyHeight) < 10) then
							ent:FinishMovement()
						end
						MRTS_Move_type_Air_Trace(ent)
					end
				end
			end
			if (ent.lastDistance > ent.currentDistance) then
				ent.lastDistance = ent.currentDistance
			end
		else
			if (not ent.flies or math.abs(ent:GetPos().z-ent.flyHeight) < 10) then
				ent:FinishMovement()
			end
			MRTS_Move_type_Air_Trace(ent)
		end
	else
		ent.flies = false
		ent.flyHeight = ent:GetPos().z
		ent.nextFlyCheck = 0
		ent:GetPhysicsObject():EnableGravity(false)
		ent.flies = true
		ent:SetMoveType(MOVETYPE_VPHYSICS)
	end
end

function MRTS_MoveType_Water(ent, serverThinkRate, first)
	if (not first) then
		local vel = ent:GetVelocity();
		local targetPos2D = Vector(ent:GetMovePos().x, ent:GetMovePos().y)
		local pos2D = Vector(ent:GetPos().x, ent:GetPos().y)
		
		local difference = targetPos2D-pos2D;

		local spd = ent:GetModifiedSpeed()

		-- Float
		if ( bit.band( util.PointContents( ent:GetPos()+Vector(0,0,-(ent:GetData().waterCheckOffset or 10)) ), CONTENTS_WATER ) != CONTENTS_WATER ) then
			spd = ent:GetModifiedSpeed() * (ent:GetData().landSpeedMultiplier or 0.1)
		end

		if (difference:LengthSqr() > 2*(serverThinkRate*serverThinkRate)*(spd*spd)) then
			local diff2D = Vector(difference.x, difference.y)
			local dist = diff2D:Length()
			local movement = diff2D/math.max(dist,spd/2) // reduce movement when dist < spd/5
			if (dist < spd/2) then
				ent:FinishMovement()
			end

			local desiredSpeed = movement*spd

			ent:GetPhysicsObject():Wake()
			ent.desiredVelocity = desiredSpeed

			ent.currentDistance = difference:Length()
			if (not ent.attacking or ent.canAttackWhileMoving) then
				if (ent:GetVelocity():LengthSqr() < (spd*spd)/2/*ent.lastDistance-ent.currentDistance < ent.stuckTolerance+1*/) then
					ent.stuckCounter = ent.stuckCounter+1
				else
					ent.stuckCounter = 0
					ent.stuckFrustration = 0
				end
				if (ent.stuckCounter > 5) then
					if (ent.stuckFrustration < 2) then
						ent:Unstuck(ent.stuckFrustration, ent.desiredVelocity)
						ent.stuckFrustration = ent.stuckFrustration+1
						ent.stuckCounter = 0
					else
						ent:FinishMovement()
					end
				end
			end
			/*if (ent.lastDistance > ent.currentDistance) then
				ent.lastDistance = ent.currentDistance
			end*/
		else
			ent:FinishMovement()
		end
	else
		ent:SetMoveType(MOVETYPE_VPHYSICS)
		ent:GetPhysicsObject():EnableMotion(true)
		ent:GetPhysicsObject():SetBuoyancyRatio((ent:GetData().buoyancy or 1)/10)
	end
end

function MRTS_MoveType_Engine(ent, serverThinkRate, first)
	if (not first) then
		local vel = ent:GetVelocity();
		local targetPos2D = Vector(ent:GetMovePos().x, ent:GetMovePos().y)
		local pos2D = Vector(ent:GetPos().x, ent:GetPos().y)
		local difference = targetPos2D-pos2D;

		local spd = ent:GetModifiedSpeed()
		if (difference:LengthSqr() > 2*(serverThinkRate*serverThinkRate)*(spd*spd)) then
			local diff2D = Vector(difference.x, difference.y)
			local dist = diff2D:Length()
			local movement = diff2D/math.max(dist,spd/2) // reduce movement when dist < spd/5
			if (dist < spd/2) then
				ent:FinishMovement()
			end

			local desiredSpeed = movement*spd

			ent.desiredDirection = diff2D:GetNormalized()

			ent:GetPhysicsObject():Wake()
			ent.desiredVelocity = desiredSpeed

			ent.currentDistance = difference:Length()
			if (not ent.attacking or ent.canAttackWhileMoving) then
				if (ent:GetVelocity():LengthSqr() < (spd*spd)/2/*ent.lastDistance-ent.currentDistance < ent.stuckTolerance+1*/) then
					ent.stuckCounter = ent.stuckCounter+1
				else
					ent.stuckCounter = 0
					ent.stuckFrustration = 0
				end
				if (ent.stuckCounter > 5) then
					if (ent.stuckFrustration < 2) then
						ent:Unstuck(ent.stuckFrustration, ent.desiredVelocity)
						ent.stuckFrustration = ent.stuckFrustration+1
						ent.stuckCounter = 0
					else
						ent:FinishMovement()
					end
				end
			end
			/*if (ent.lastDistance > ent.currentDistance) then
				ent.lastDistance = ent.currentDistance
			end*/
		else
			ent:FinishMovement()
		end
	else
		ent:SetMoveType(MOVETYPE_VPHYSICS)
		ent:GetPhysicsObject():EnableMotion(true)
	end
end
