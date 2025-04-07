
-- Services
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

-- Create a collision group for the ball and players so that nothing collides with each other
PhysicsService:RegisterCollisionGroup("Ball")
PhysicsService:RegisterCollisionGroup("Player")
PhysicsService:CollisionGroupSetCollidable("Ball", "Player", false) -- Ball and Player collide
PhysicsService:CollisionGroupSetCollidable("Player", "Ball", false) -- Player and Ball collide
PhysicsService:CollisionGroupSetCollidable("Player", "Player", false) -- Player and Player collide

-- Create the ball
local ball : Part? = nil

function SetUpBall()
    ball = Instance.new("Part")
    ball.Name = "Ball"
    ball.Shape = Enum.PartType.Ball
    ball.Material = Enum.Material.SmoothPlastic
    ball.Size = Vector3.new(1, 1, 1) * 2
    ball.Position = Vector3.new(0, 0, 0)
    ball.CollisionGroup = "Ball"
    ball.Parent = workspace
    return ball
end
SetUpBall()


ball.Touched:Connect(function(hit : BasePart)
    if hit.Parent:FindFirstChild("Humanoid") then
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then
            -- Weld the ball to the humanoid root part
            local rootPart = hit.Parent:FindFirstChild("HumanoidRootPart")
            if rootPart then
                if ball:FindFirstChild("Weld") then
                    ball.Weld:Destroy() -- Remove existing weld if it exists
                end
                
                local weld = Instance.new("Weld")
                weld.Part0 = ball
                weld.Part1 = rootPart
                weld.C0 = CFrame.new(0, 2, 2) -- Position the ball in front of the player's feet
                weld.Parent = ball

                -- Set the ball's velocity to the humanoid's velocity
                local humanoidVelocity = humanoid.RootPart.Velocity
                ball.Velocity = humanoidVelocity * 1.5 -- Adjust the multiplier as needed

                -- Check if another player has network ownership
                local currentOwner = ball:GetNetworkOwner()
                if currentOwner then
                    -- Reset network ownership to nil before assigning a new owner
                    ball:SetNetworkOwner(nil)
                end

                -- Set network ownership to the player who picked up the ball
                local player = game.Players:GetPlayerFromCharacter(hit.Parent)
                if player then
                    ball:SetNetworkOwner(player)
                end
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- set the collision group for the player's character parts
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CollisionGroup = "Player"
            end
        end
    end)
end)
