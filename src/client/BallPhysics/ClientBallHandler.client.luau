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

    -- Move the ball to the specified position
    ball.Position = position + (direction * 2)

    -- Apply impulse for shooting
    local impulse = (direction * BallPhysicsProperties.Shooting.Force + (BallPhysicsProperties.Shooting.UpForce * multiplier)) * ball.AssemblyMass
    ball:ApplyImpulse(impulse)
end)

-- Handle passing on the client
onClientPass.OnClientEvent:Connect(function(player, position, direction, multiplier)
    local ball = workspace:FindFirstChild("Ball")
    if not ball then return end

    -- Move the ball to the specified position
    ball.Position = position + (direction * 2)

    -- Apply impulse for passing
    local impulse = (direction * BallPhysicsProperties.Passing.Force) * ball.AssemblyMass
    ball:ApplyImpulse(impulse)
end)
