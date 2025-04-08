repeat wait() until game.Players.LocalPlayer

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")

local UserInputService = game:GetService("UserInputService")
local Teams = game:GetService("Teams")

-- Define walking and running speeds 16 is the default speed 
local walkSpeed = 24
local runSpeed = 32

-- Stamina settings
local maxStamina = 100
local currentStamina = maxStamina
local staminaDrain = 10 -- Stamina drained per second while running
local staminaRegen = 5 -- Stamina regenerated per second while not running

-- Toggle sprint variables
local isRunning = false

local sprintBarUI = nil

-- Create Sprint Bar UI with Part and SurfaceGui attached to the HumanoidRootPart with an offset
local function createSprintBar()
    -- Create the part that will hold the SurfaceGui
    local sprintBarPart = Instance.new("Part")
    sprintBarPart.Name = "SprintBarPart"
    sprintBarPart.Size = Vector3.new(1.5, 0.15, 0.1) -- Adjust size as needed
    sprintBarPart.Transparency = 1
    sprintBarPart.CanCollide = false
    sprintBarPart.Anchored = false
    sprintBarPart.CanTouch = false
    sprintBarPart.CanQuery = false
    sprintBarPart.Parent = character

    -- Attach the part to the HumanoidRootPart using a Weld
    local weld = Instance.new("Weld")
    weld.Part0 = HumanoidRootPart
    weld.Part1 = sprintBarPart
    weld.C0 = CFrame.new(-3, -1.5, 0) * CFrame.Angles(math.rad(170), 0, math.rad(90))
    weld.Parent = HumanoidRootPart

    -- Create and configure the SurfaceGui
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Name = "SprintBarSurfaceGui"
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
    frame.Parent = surfaceGui

    -- Create the actual sprint bar
    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(1, 0, 1, 0)
    bar.BackgroundColor3 = Color3.new(0.176470, 0.223529, 0.874509)
    bar.BorderSizePixel = 0
    bar.BackgroundTransparency = 0.25
    bar.Parent = frame
    
    sprintBarUI = bar
end

createSprintBar()

-- Function to set running speed
local function setRunSpeed(shouldRun)
	if shouldRun and currentStamina > 0 then
		humanoid.WalkSpeed = runSpeed
	else
		humanoid.WalkSpeed = walkSpeed
	end
end


-- Function to handle sprint toggling
local function toggleSprint()
	isRunning = not isRunning
	setRunSpeed(isRunning)
end

-- Update the sprint bar size
local function updateSprintBar()
    if sprintBarUI then
        sprintBarUI.Size = UDim2.new(currentStamina / maxStamina, 0, 1, 0)
    end
end

-- Update stamina bar and manage running state
local function updateStamina(deltaTime)

	-- Only drain stamina if player is moving AND in sprint mode
	local isMoving = humanoid.MoveDirection.Magnitude > 0.1

	if isRunning and isMoving and currentStamina > 0 then
		currentStamina = math.max(0, currentStamina - staminaDrain * deltaTime) -- Reduce stamina when running and moving
	else
		currentStamina = math.min(maxStamina, currentStamina + staminaRegen * deltaTime) -- Regenerate stamina when not running or not moving
	end

	sprintBarUI.Size = UDim2.new((currentStamina / maxStamina), 0, 0.84, 0) -- Update stamina bar size based on current stamina

	-- When stamina is depleted, untoggle sprint mode
	if currentStamina <= 0 and isRunning then
		isRunning = false
		humanoid.WalkSpeed = walkSpeed -- Reset to walk speed if stamina is depleted
		print("Sprint disabled due to depleted stamina") -- Optional debug message
	end

    updateSprintBar()
end

-- Key, gamepad, and VR handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end -- Ignore input if the player is chatting or in a menu

	if input.UserInputType == Enum.UserInputType.Keyboard then
		-- Only process Shift keys for sprinting, explicitly ignore Ctrl+W combination
		if (input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift) and 
			not (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
			toggleSprint()
		end

		-- Prevent Ctrl+W from affecting the game
		if input.KeyCode == Enum.KeyCode.W and 
			(UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
			return -- Do nothing when Ctrl+W is pressed
		end
	elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
		if input.KeyCode == Enum.KeyCode.ButtonL3 then -- Using LSB for running
			toggleSprint()
		end
	end
end)

-- Update the stamina bar and stamina levels every frame
game:GetService("RunService").RenderStepped:Connect(updateStamina)