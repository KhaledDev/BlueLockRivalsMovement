-- Services
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local RS = game:GetService("ReplicatedStorage")

-- Create a collision group for the ball and players so that nothing collides with each other
PhysicsService:RegisterCollisionGroup("Ball")
PhysicsService:RegisterCollisionGroup("Player")
PhysicsService:CollisionGroupSetCollidable("Ball", "Player", false) -- Ball and Player collide
PhysicsService:CollisionGroupSetCollidable("Player", "Ball", false) -- Player and Ball collide
PhysicsService:CollisionGroupSetCollidable("Player", "Player", false) -- Player and Player collide

-- Create the ball
local ball : Part? = nil

-- Modules
local BallPhysicsProperties = require(RS.Modules.BallPhysics)
local RagdollService = require(script.RagdollService)

-- Events
local onShoot = RS.Events.onShoot
local onDribble = RS.Events.onDribble
local onTackle = RS.Events.onTackle
local onPass = RS.Events.onPass
local onRainbowflick = RS.Events.onRainbowflick

-- Variables
local canPickup : boolean? = true
local InGamePlayers = {}

function SetupBall() -- Initalize the ball on startup by creating the model and setting the material.
    ball = Instance.new("Part")
    ball.Name = "Ball"
    ball.Shape = Enum.PartType.Ball
    ball.Material = Enum.Material.SmoothPlastic
    ball.Size = Vector3.new(1, 1, 1) * 1.5
    ball.Position = Vector3.new(0, 0, 0)
    ball.CollisionGroup = "Ball"

    ball.Parent = workspace
    return ball
end
SetupBall()

--[[ 
    Creates the list of players in the game and have custom properties for it.
    Keeping it on the server ensures that its secure.
]]
function createPlayerProperties(player : Player?)
    
    if typeof(player) ~= "Instance" and not player:IsDescendantOf(Players) then return end
    
    InGamePlayers[player] = {
        Dribbling = false,
        HasBall = false,
    }
    
end

--[[ 
    Function that will remove the players properties.
    Checks also if the player had the ball on left, and make the ball not have an owner.
]]
function removePlayerProperties(player : Player?)
    
    if typeof(player) ~= "Instance" and not player:IsDescendantOf(Players) then return end

    -- Player left while having the ball, remove the network ownership and destroy the weld
    if InGamePlayers[player].HasBall then
        if ball:FindFirstChild("Weld") then ball.Weld:Destroy() end -- Destroy the weld to account for the player that left
        ball:SetNetworkOwner(nil) -- ensure that the network owner ship is back to the server
    end
    
    -- Remove the player from the InGamePlayers list
    if InGamePlayers[player] then
        InGamePlayers[player] = nil
    end
    
end

--[[
    Function to shoot the ball will be called from a remote event.
]]
function ShootBall(player : Player?, Multiplier : number?)
    --[[
        Check if the player has the ball
        if the player doesn't then dont shoot
    ]]
    if not InGamePlayers[player].HasBall then return end

    if typeof(Multiplier) ~= "number" then return end
    
    Multiplier = Multiplier or 1
    
    print(player.Name .. " is shooting")
    
    -- Remove the weld from the ball
    if ball:FindFirstChild("Weld") then
        ball.Weld:Destroy()
    end
    
    -- Move the ball 2 units in front of its current position, to avoid accidental collisions
    ball.Position = ball.Position + (ball.CFrame.LookVector * 2)
    
    -- Apply impulse for smoother shooting
    local impulse = (ball.CFrame.LookVector * BallPhysicsProperties.Shooting.Force + (BallPhysicsProperties.Shooting.UpForce * Multiplier)) * ball.AssemblyMass
    ball:ApplyImpulse(impulse)
    canPickup = false
    InGamePlayers[player].HasBall = false

    task.delay(BallPhysicsProperties.Shooting.TimetoPickUp, function() 
        canPickup = true
    end)
end

function PassBall(player : Player?, Multiplier : number?)
    --[[
        Check if the player has the ball
        if the player doesn't then dont pass
    ]]
    if not InGamePlayers[player].HasBall then return end
    
    if typeof(Multiplier) ~= "number" then return end
    
    print(player.Name .. " is passing")
    
    Multiplier = Multiplier or 1
    
    -- Remove the weld from the ball
    if ball:FindFirstChild("Weld") then
        ball.Weld:Destroy()
    end
    
    -- Move the ball 2 units in front of its current position, to avoid accidental collisions
    ball.Position = ball.Position + (ball.CFrame.LookVector * 2)
    
    -- Apply impulse for smoother passing
    local impulse = (ball.CFrame.LookVector * BallPhysicsProperties.Passing.Force) * ball.AssemblyMass
    ball:ApplyImpulse(impulse)
    canPickup = false
    InGamePlayers[player].HasBall = false

    task.delay(BallPhysicsProperties.Passing.TimetoPickUp, function() 
        canPickup = true
    end)
end

--[[
    Function to dribble the ball will be called from a remote event.
]]
function Dribble(player : Player?)
    --[[
        Check if the player has the ball
        if the player doesn't then dont dribble
    ]]
    
    if not InGamePlayers[player].HasBall then return end
    
    print(player.Name .. " is dribbling")
    
    --[[
        Small wait up check time to give time for start up animation
        hard to notice but should make it feel good
    ]]
    task.wait(BallPhysicsProperties.Dribble.DribbleStartupTime)
    
    -- Turn the dribbling property for the player to true
    InGamePlayers[player].Dribbling = true
    -- Turn the ball pickup property to false
    canPickup = false
    
    -- Wait until animation is done
    task.wait(BallPhysicsProperties.Dribble.DribbleTime)
    
    -- Disable the dribbling property for the player
    InGamePlayers[player].Dribbling = false
    
end

--[[
    Function to Tackle checkes player collision for a set period of time
    also will be called from a remote event
]]
function Tackle(player : Player?)
    
    if typeof(player) ~= "Instance" and not player:IsDescendantOf(Players) then return end
    
    if InGamePlayers[player].HasBall then return end -- Player already has the ball
    
    print(player.Name .. " Is Tackling")
    
    local character = player.Character
    
    -- Check if the player is touching another player
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer == player or not otherPlayer.Character then continue end
        
        local otherRootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not otherRootPart then continue end
        
        local distance = (character.HumanoidRootPart.Position - otherRootPart.Position).Magnitude
        if distance > BallPhysicsProperties.Tackle.Range then continue end

        if not (InGamePlayers[otherPlayer] and InGamePlayers[otherPlayer].HasBall) then continue end
        if InGamePlayers[otherPlayer].Dribbling then BreakAnkle(character) continue end

        -- Remove weld from the player that used to have the ball
        if ball:FindFirstChild("Weld") then
            ball.Weld:Destroy()
        end

        -- Update player properties
        InGamePlayers[otherPlayer].HasBall = false
        InGamePlayers[player].HasBall = true

        -- Weld the ball to the tackling player's HumanoidRootPart
        local weld = Instance.new("Weld")
        weld.Part0 = ball
        weld.Part1 = character.HumanoidRootPart
        weld.C0 = CFrame.new(0, 2, 2) -- Position the ball in front of the player's feet
        weld.Parent = ball

        break
    end
    
end

--[[
    Function to break the ankle
    Gets called if the player that has the ball is dribbling and a player tackles him.
]]
function BreakAnkle(character)
    RagdollService:Ragdoll(character)
end

--[[
    Function that launches the ball up and forward.
    Gets called when the player jumps
]]
function Rainbowflick(player : Player?)
    if not InGamePlayers[player].HasBall then return end

    -- Remove the weld from the ball
    if ball:FindFirstChild("Weld") then
        ball.Weld:Destroy()
    end
    
    -- Move the ball up using the upward force
    ball.Position = ball.Position + BallPhysicsProperties.Rainbowflick.UpForce
    
    -- Directly set the ball's velocity for a smooth upward and forward motion
    ball.AssemblyLinearVelocity = ball.CFrame.LookVector * BallPhysicsProperties.Rainbowflick.FrontForce
    canPickup = false
    InGamePlayers[player].HasBall = false

    task.delay(BallPhysicsProperties.Rainbowflick.TimetoPickUp, function()
        canPickup = true
    end)
end

-- Connections
function HandleBallTouch(hit : BasePart)
    local humanoid = hit.Parent:FindFirstChild("Humanoid")
    if not humanoid or not canPickup then return end

    canPickup = false -- Prevent continuous ball movement
    local player = Players:GetPlayerFromCharacter(hit.Parent)
    if not player then return end

    InGamePlayers[player].HasBall = true -- Assign ball to player
    local rootPart = hit.Parent:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    if ball:FindFirstChild("Weld") then
        ball.Weld:Destroy() -- Remove existing weld
    end

    local weld = Instance.new("Weld")
    weld.Part0 = ball
    weld.Part1 = rootPart
    weld.C0 = CFrame.new(0, 2, 2) -- Position ball in front of player
    weld.Parent = ball

    ball.AssemblyLinearVelocity = rootPart.AssemblyLinearVelocity * 1.5 -- Adjust velocity multiplier
    
end

-- Connect the ball's Touched event to the new function
ball.Touched:Connect(HandleBallTouch)

Players.PlayerAdded:Connect(function(player)
    createPlayerProperties(player)

    player.CharacterAdded:Connect(function(character)
        -- set the collision group for the player's character parts
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CollisionGroup = "Player"
            end
        end
        
        local ragdolled = Instance.new("BoolValue", character)
        ragdolled.Name = "Ragdolled"
        ragdolled.Value = false
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    removePlayerProperties(player)
end)

-- Event Connections
onShoot.OnServerEvent:Connect(ShootBall)
onPass.OnServerEvent:Connect(PassBall)
onDribble.OnServerEvent:Connect(Dribble)
onTackle.OnServerEvent:Connect(Tackle)
onRainbowflick.OnServerEvent:Connect(Rainbowflick)