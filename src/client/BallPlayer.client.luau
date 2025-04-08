-- Services
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Modules
local BallPhysicsProperties = require(RS:WaitForChild("Modules"):WaitForChild("BallPhysics"))

-- Events
local onShoot = RS:WaitForChild("Events"):WaitForChild("onShoot")
local onPass = RS:WaitForChild("Events"):WaitForChild("onPass")
local onDribble = RS:WaitForChild("Events"):WaitForChild("onDribble")
local onTackle = RS:WaitForChild("Events"):WaitForChild("onTackle")
local onRainbowflick = RS:WaitForChild("Events"):WaitForChild("onRainbowflick")

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

function C_Shoot() end

function C_Pass() end

function C_Dribble() end

function C_Tackle()
    
    -- Store the current position
    local start_pos = humanoidRootPart.CFrame.Position

    humanoidRootPart.AssemblyLinearVelocity = humanoidRootPart.CFrame.LookVector * BallPhysicsProperties.Tackle.TackleForce
    
    -- send the event
    onTackle:FireServer()
    
    -- Play tackle animation
    
    -- check the distance between the start and current until we reach threashold
    while true do
        
        if (start_pos - humanoidRootPart.CFrame.Position).Magnitude >= BallPhysicsProperties.Tackle.TackleDistance then
            break
        end
        
        task.wait(0.1) -- wait 0.1 seconds to not crash the client kekw
    end
    
    -- stop the animation
    
end

function C_RainbowFlick()
    onRainbowflick:FireServer()
end

-- Connections

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- Shoot (Left Click)
        onShoot:FireServer(1)
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        -- Pass (Right Click)
        onPass:FireServer(1)
    elseif input.KeyCode == Enum.KeyCode.E then
        -- Dribble
        onDribble:FireServer()
    elseif input.KeyCode == Enum.KeyCode.T then
        -- Tackle
        C_Tackle()
    elseif input.KeyCode == Enum.KeyCode.Space then
        -- Rainbowflick (Jump)
        C_RainbowFlick()
    end
end)

-- Ball tracking
workspace.ChildAdded:Connect(function(child)
    if child:IsA("Part") and child.Name == "Ball" then
        -- Example: Add visual effects or UI indicators for the ball
        print("Ball added to the workspace")
    end
end)
