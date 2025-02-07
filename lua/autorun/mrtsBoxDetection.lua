/*
MRTSBoxDetection assumes the boxes are only rotated in the z axis
If its weirldy rotated, but it still has a flat horizontal surface,
this function will adjust the angle and the size so that its the same,
but it can be used by BoxDetection
*/
function MRTSSanitizeBox(box)
    local boxCopy = {
        size=Vector(box.size.x, box.size.y, box.size.z),
        angle=Angle(box.angle.x, box.angle.y, box.angle.z),
        center=Vector(box.center.x, box.center.y, box.center.z)
    }
    if (boxCopy.angle.x < 0) then boxCopy.angle.x = boxCopy.angle.x + 360 end
    if (boxCopy.angle.z < 0) then boxCopy.angle.z = boxCopy.angle.z + 360 end

    if (boxCopy.angle.x == 90 or boxCopy.angle.x == 270) then
        boxCopy.angle.x = 0
        local aux = boxCopy.size.x
        boxCopy.size.x = boxCopy.size.z
        boxCopy.size.z = aux
    end
    if (boxCopy.angle.z == 90 or boxCopy.angle.z == 270) then
        boxCopy.angle.z = 0
        local aux = boxCopy.size.y
        boxCopy.size.y = boxCopy.size.z
        boxCopy.size.z = aux
    end
    return boxCopy
end

-- Internal function
local function Get2DBoxVerices(box)
    local forward = box.angle:Forward()
    local right = box.angle:Right()
    return {
        box.center + forward * box.size.x + right * box.size.y,
        box.center + forward * box.size.x - right * box.size.y,
        box.center - forward * box.size.x + right * box.size.y,
        box.center - forward * box.size.x - right * box.size.y
    }
end

/*
The boxes should be a table with these parameters:
{angle:Angles, center:Vector, size:Vector (size measured from the center to a corner)}
return true if the boxes are intersecting
*/
function MRTSBoxDetection(boxA, boxB)
    boxA = MRTSSanitizeBox(boxA)
    boxB = MRTSSanitizeBox(boxB)

    -- Vertical separation
    -- Box A is too high up
    if (boxB.center.z + boxB.size.z < boxA.center.z - boxA.size.z) then
        return false
    end
    -- Box B is too high up
    if (boxA.center.z + boxA.size.z < boxB.center.z - boxB.size.z) then
        return false
    end

    -- 2D Separating axis theorem, projecting the boxes on the horizontal plane
    local axisList = {
        boxA.angle:Forward(),
        boxA.angle:Right(),
        boxB.angle:Forward(),
        boxB.angle:Right()
    }
    local boxAVertices = Get2DBoxVerices(boxA)
    local boxBVertices = Get2DBoxVerices(boxB)
    for k, axis in pairs(axisList) do
        local boxAMin = 0
        local boxAMax = 0
        local boxBMin = 0
        local boxBMax = 0
        -- Check for overlap when projecting on each axis
        for kk, vertex in pairs(boxAVertices) do
            local value = vertex:Dot(axis)
            if (boxAMin == 0 or value < boxAMin) then boxAMin = value end
            if (boxAMax == 0 or value > boxAMax) then boxAMax = value end
        end
        for kk, vertex in pairs(boxBVertices) do
            local value = vertex:Dot(axis)
            if (boxBMin == 0 or value < boxBMin) then boxBMin = value end
            if (boxBMax == 0 or value > boxBMax) then boxBMax = value end
        end
        -- If there is any space in any axis, then there is no collision
        if (boxBMin > boxAMax) then return false end
        if (boxAMin > boxBMax) then return false end
    end

    return true
end