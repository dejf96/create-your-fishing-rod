
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local fishingEvent = ReplicatedStorage:WaitForChild("FishingEvent")

local function notify(title, message)
    print(title .. ": " .. message)

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = 4
        })
    end)
end

local function setupTool(tool)
    if not tool:IsA("Tool") then
        return
    end

    if tool.Name ~= "Fishing Rod" then
        return
    end

    tool.Activated:Connect(function()
        fishingEvent:FireServer()
    end)
end

local function setupCharacter(character)
    for _, child in ipairs(character:GetChildren()) do
        setupTool(child)
    end

    character.ChildAdded:Connect(setupTool)
end

player.CharacterAdded:Connect(setupCharacter)

if player.Character then
    setupCharacter(player.Character)
end

fishingEvent.OnClientEvent:Connect(function(status, fishName, value)
    if status == "START" then
        notify("Lowienie", "Czekaj na branie...")

    elseif status == "CAUGHT" then
        notify(
            "Zlowiono rybe!",
            fishName .. " | +" .. value .. " monet"
        )
    end
end)
