-- Services
local RS = game:GetService("ReplicatedStorage")

-- Modules
local BallPhysicsProperties = require(RS:WaitForChild("Modules"):WaitForChild("BallPhysics"))

-- RemoteEvents
local onClientShoot = RS.Events.onClientShoot
local onClientPass = RS.Events.onClientPass

-- Handle shooting on the client
onClientShoot.OnClientEvent:Connect(function(player, position, direction, multiplier)
    local ball = workspace:FindFirstChild("Ball")
    if not ball then return end
    
    -- get the angle of direction
    local angle = direction.Y
    
    -- get the angle in degrees
    local angleInDegrees = math.deg(math.asin(angle))
    
    local baseForce = BallPhysicsProperties.Shooting.Force * direction
    
    -- Add vertical lift based on multiplier (for height)
    local upForce = Vector3.new(0, BallPhysicsProperties.Shooting.UpForce.Y * multiplier, 0)
    
    if angleInDegrees >= 68 then
        -- Looking up
        baseForce = baseForce * 0.1
    elseif angleInDegrees <= -68 then
        -- Looking down
        baseForce = baseForce * 0.5
        upForce = Vector3.zero
    else
        -- Move the ball 2 units in front of its current position, to avoid accidental collisions
        ball.Position = position + (direction * 1.5)
    end
    
    -- Combine forces and apply mass
    local impulse = (baseForce + upForce) * ball.AssemblyMass
    ball:ApplyImpulse(impulse)
end)

-- Handle passing on the client
onClientPass.OnClientEvent:Connect(function(player, position, direction, multiplier)
    local ball = workspace:FindFirstChild("Ball")
    if not ball then return end
    
    -- get the angle of direction
    local angle = direction.Y
    
    -- get the angle in degrees
    local angleInDegrees = math.deg(math.asin(angle))
    
    -- Use the same structure as shooting but with pass-specific forces
    local baseForce = BallPhysicsProperties.Shooting.Force * 0.6 * direction -- Passes are generally weaker than shots
    
    -- Add vertical lift based on multiplier (for height), but less than for shooting
    local upForce = Vector3.new(0, BallPhysicsProperties.Shooting.UpForce.Y * multiplier * 0.5, 0)
    
    if angleInDegrees >= 68 then
        -- Looking up
        baseForce = baseForce * 0.1
    elseif angleInDegrees <= -68 then
        -- Looking down
        baseForce = baseForce * 0.5
        upForce = Vector3.zero
    else
        -- Move the ball 2 units in front of its current position, to avoid accidental collisions
        ball.Position = position + (direction * 1.5)
    end
    
    -- Combine forces and apply mass
    local impulse = (baseForce + upForce) * ball.AssemblyMass
    ball:ApplyImpulse(impulse)
end)
