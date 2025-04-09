-- Services
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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

-- Variables for charging
local isCharging = false
local chargeStartTime = 0
local maxChargeTime = 2 -- Maximum time to reach a multiplier of 2
local ShootingBarUI = nil

-- Variables for shiftlock
local shiftLockEnabled = false

-- Animation Variables
local Slide = "116367868199348"
local KickReady = "113902481186836"
local Kick = "106423748928091"
local Dribble = "131192896107847"

-- Preloaded animations
local animations = {
    KickReady = (function()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. KickReady
        return character.Humanoid.Animator:LoadAnimation(anim)
    end)(),
    Kick = (function()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. Kick
        return character.Humanoid.Animator:LoadAnimation(anim)
    end)(),
    Slide = (function()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. Slide
        return character.Humanoid.Animator:LoadAnimation(anim)
    end)(),
    Dribble = (function()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. Dribble
        return character.Humanoid.Animator:LoadAnimation(anim)
    end)()
}

-- Shooting UI
function InitShootingUI()
    -- Initialize the shooting UI here if needed
    -- Create the part that will hold the SurfaceGui
    local sprintBarPart = Instance.new("Part")
    sprintBarPart.Name = "ShootingBarPart"
    sprintBarPart.Size = Vector3.new(1.5, 0.15, 0.1) -- Adjust size as needed
    sprintBarPart.Transparency = 1
    sprintBarPart.CanCollide = false
    sprintBarPart.Anchored = false
    sprintBarPart.CanTouch = false
    sprintBarPart.CanQuery = false
    sprintBarPart.Parent = character

    -- Attach the part to the HumanoidRootPart using a Weld
    local weld = Instance.new("Weld")
    weld.Part0 = humanoidRootPart
    weld.Part1 = sprintBarPart
    weld.C0 = CFrame.new(3, 0, 0) * CFrame.Angles(math.rad(170), 0, math.rad(90))
    weld.Parent = humanoidRootPart

    -- Create and configure the SurfaceGui
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Name = "ShootingBarSurfaceGui"
    surfaceGui.Face = Enum.NormalId.Front
    surfaceGui.ResetOnSpawn = false
    surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    surfaceGui.PixelsPerStud = 50
    surfaceGui.Parent = sprintBarPart

    -- Create a background frame for the bar
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1.1, 0, 1.1, 0)
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.25
    frame.Visible = false -- Initially hidden
    frame.Parent = surfaceGui
    
    -- Create the actual sprint bar
    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = Color3.new(1, 1, 1)
    bar.BorderSizePixel = 0
    bar.BackgroundTransparency = 0.25
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(0, 1, 0)),   -- Green at start
        ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 0)), -- Yellow in middle
        ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))    -- Red at end
    })
    gradient.Parent = bar
    bar.BorderSizePixel = 0
    bar.BackgroundTransparency = 0.25
    bar.Parent = frame
    
    ShootingBarUI = bar
end
InitShootingUI()

-- Functions
function C_Shoot()
    local chargeDuration = math.min(tick() - chargeStartTime, maxChargeTime)
    local multiplier = 1 + (chargeDuration / maxChargeTime)

    for _, track in ipairs(character.Humanoid.Animator:GetPlayingAnimationTracks()) do
        track:Stop()
    end

    local kickTrack = animations.Kick
    kickTrack.Looped = false
    kickTrack:Play()
    
    kickTrack:AdjustSpeed(3)
    kickTrack.TimePosition = 0.9

    onShoot:FireServer(multiplier)
    ShootingBarUI.Parent.Visible = false
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        -- Explicitly call Move() to trigger the walk animation
        humanoid:Move(humanoid.MoveDirection, true)
    end
end

function C_Pass()
    local chargeDuration = math.min(tick() - chargeStartTime, maxChargeTime)
    local multiplier = 1 + (chargeDuration / maxChargeTime)
    onPass:FireServer(multiplier)
    ShootingBarUI.Parent.Visible = false
end

function C_Dribble()
    local dribbleTrack = animations.Dribble
    dribbleTrack.Looped = false
    dribbleTrack:Play()
    
    onDribble:FireServer()
    
    dribbleTrack.Stopped:Connect(function()
        dribbleTrack:Stop()
    end)
end

function C_Tackle()
    
    if workspace:FindFirstChild("Ball") then
        local ball = workspace.Ball
        
        if ball:FindFirstChild("Weld") then
            local part1 = ball.Weld.Part1
            
            if part1 and part1:IsA("BasePart") then
                local parent = part1.Parent
                
                if parent and parent:FindFirstChild("HumanoidRootPart") == humanoidRootPart then
                    return
                end
                
            end
            
        end
        
    end
    
    -- Store the current position
    local start_pos = humanoidRootPart.CFrame.Position

    humanoidRootPart.AssemblyLinearVelocity = humanoidRootPart.CFrame.LookVector * BallPhysicsProperties.Tackle.TackleForce
    
    -- send the event
    onTackle:FireServer()
    
    -- Play tackle animation
    
    local track : AnimationTrack = animations.Slide
    track.Looped = true
    track:Play()
    -- check the distance between the start and current until we reach threashold
    while true do
        
        if (start_pos - humanoidRootPart.CFrame.Position).Magnitude >= BallPhysicsProperties.Tackle.TackleDistance then
            break
        end
        
        task.wait(0.1) -- wait 0.1 seconds to not crash the client kekw
    end
    
    -- Clean up
    track:Stop()
end

function C_RainbowFlick()
    onRainbowflick:FireServer()
end

function C_ToggleShiftLock()
    if not shiftLockEnabled then return end
    
    character = player.Character or player.CharacterAdded:Wait()
    if not character then return end
    local Humanoid = character:FindFirstChild("Humanoid")
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    Humanoid.AutoRotate = false
    local RootRotation = humanoidRootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
    local CamRotation = workspace.CurrentCamera.CFrame.LookVector * Vector3.new(1, 0, 1)
    local Cross = RootRotation:Cross(CamRotation)
    local LookAccuracy = RootRotation:Dot(CamRotation)
    local X = math.cos(Cross.Y * math.pi / 2) * LookAccuracy
    local Y = 1
    local Z = 1 - math.abs(math.sin(Cross.Y * math.pi / 2))
    local OFFSET = Vector3.new(3, Y, -0.5)
    local pos = Vector3.new(X, Y, Z) * OFFSET
    local targetOffset = pos
    local currentOffset = Humanoid.CameraOffset
    local startTime = tick()
    local duration = 0.3
    
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    
    while tick() - startTime < duration do
        local alpha = math.min((tick() - startTime) / duration * 10, 1)
        Humanoid.CameraOffset = currentOffset:Lerp(targetOffset, alpha)
        humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + CamRotation), alpha)
        task.wait()
    end

    Humanoid.CameraOffset = targetOffset
    humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + CamRotation)
end

function ToggleShiftLockState()
    shiftLockEnabled = not shiftLockEnabled
    
    if not shiftLockEnabled then
        character = player.Character or player.CharacterAdded:Wait()
        if character then
            local Humanoid = character:FindFirstChild("Humanoid")
            if Humanoid then
                local targetOffset = Vector3.new(0, 0, 0)
                local currentOffset = Humanoid.CameraOffset
                local startTime = tick()
                local duration = 0.3

                while tick() - startTime < duration do
                    local alpha = math.min((tick() - startTime) / duration * 2, 1)
                    Humanoid.CameraOffset = currentOffset:Lerp(targetOffset, alpha)
                    task.wait()
                end

                Humanoid.CameraOffset = targetOffset
                Humanoid.AutoRotate = true
            end
        end
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

-- Update ShootingBarUI based on charge duration
function UpdateShootingBarUI(chargeDuration)
    if not ShootingBarUI then return end
    
    ShootingBarUI.Parent.Visible = true
    
    local chargeRatio = math.min(chargeDuration / maxChargeTime, 1)
    ShootingBarUI.Size = UDim2.new(chargeRatio, 0, 1, 0)

    local gradient = ShootingBarUI:FindFirstChild("UIGradient")
    if gradient then
        if chargeRatio <= 0.25 then
            gradient.Color = ColorSequence.new(Color3.new(0, 1, 0)) -- Green
        elseif chargeRatio <= 0.5 then
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0, 1, 0)),   -- Green at start
                ColorSequenceKeypoint.new(1, Color3.new(1, 1, 0))    -- Yellow at end
            })
        else
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0, 1, 0)),   -- Yellow at start
                ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 0)),   -- Yellow at start
                ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))    -- Red at end
            })
        end
    end
end

-- Connections
RunService.RenderStepped:Connect(C_ToggleShiftLock)

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- Start charging for Shoot (Left Click)
        isCharging = true
        chargeStartTime = tick()
        ShootingBarUI.Visible = true
        
        local kickReadyTrack = animations.KickReady
        kickReadyTrack.Looped = false
        kickReadyTrack:Play()
        
        task.wait(kickReadyTrack.Length * 0.9)
        
        kickReadyTrack:AdjustSpeed(0)
        kickReadyTrack.TimePosition = 0.9
        
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        -- Start charging for Pass (Right Click)
        isCharging = true
        chargeStartTime = tick()
        ShootingBarUI.Visible = true
    elseif input.KeyCode == Enum.KeyCode.Q then
        -- Dribble
        C_Dribble()
    elseif input.KeyCode == Enum.KeyCode.E then
        -- Tackle
        C_Tackle()
    elseif input.KeyCode == Enum.KeyCode.Space then
        -- Rainbowflick (Jump)
        C_RainbowFlick()
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        -- Toggle shift lock
        ToggleShiftLockState()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 and isCharging then
        -- Release charge for Shoot
        isCharging = false
        ShootingBarUI.Visible = false -- Hide the ShootingBarUI
        C_Shoot()
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 and isCharging then
        -- Release charge for Pass
        isCharging = false
        C_Pass()
    end
end)

-- Update ShootingBarUI during charging
RunService.RenderStepped:Connect(function()
    if isCharging then
        local chargeDuration = tick() - chargeStartTime
        UpdateShootingBarUI(chargeDuration)
    end
end)

character:WaitForChild("Ragdolled").Changed:Connect(function()
    if character.Ragdolled.Value == true then
        -- Stop all animations when ragdolled
        for _, track in ipairs(character.Humanoid.Animator:GetPlayingAnimationTracks()) do
            track:Stop()
        end
        character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    else
        character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end)
