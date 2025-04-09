local RagdollService = {}

local Players = game:GetService("Players")

function RagdollService:Ragdoll(Character)
    if Character:WaitForChild("Humanoid").Health <= 0 then return end
	
	Character.Ragdolled.Value = true
	
	for i, joint in pairs(Character:GetDescendants()) do
		if joint:IsA("Motor6D") then
			local socket = Instance.new("BallSocketConstraint",joint.Parent)
			local att0 = Instance.new("Attachment",joint.Part0)
			local att1 = Instance.new("Attachment",joint.Part1)

			att0.CFrame = joint.C0
			att1.CFrame = joint.C1

			socket.Attachment0 = att0
			socket.Attachment1 = att1
			socket.TwistLimitsEnabled = true
			socket.LimitsEnabled = true

			joint.Enabled = false
		end
	end
	task.spawn(function()
		task.wait(1)
		RagdollService:Unragdoll(Character)
	end)
end

function RagdollService:Unragdoll(Character)
	Character.Ragdolled.Value = false

    for i, joint in pairs(Character:GetDescendants()) do
		if joint:IsA("Motor6D") then
			joint.Enabled = true
		elseif joint:IsA("BallSocketConstraint") then
			joint.Enabled = false
		end
	end
end

return RagdollService