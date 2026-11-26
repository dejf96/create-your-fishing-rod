<<<<<<< HEAD
print("Hello world, from client!")
=======
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local remote = ReplicatedStorage:WaitForChild("MagnetFishingEvent")
local casting = false

local gui = Instance.new("ScreenGui")
gui.Name = "MagnetFishingGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.Position = UDim2.fromScale(0.5, 0.91)
panel.Size = UDim2.fromOffset(320, 76)
panel.BackgroundColor3 = Color3.fromRGB(19, 31, 43)
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -20, 0, 35)
label.Position = UDim2.fromOffset(10, 5)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.GothamBold
label.TextScaled = true
label.Text = ""
label.Parent = panel

local track = Instance.new("Frame")
track.Size = UDim2.new(1, -24, 0, 15)
track.Position = UDim2.fromOffset(12, 48)
track.BackgroundColor3 = Color3.fromRGB(65, 81, 98)
track.Parent = panel
Instance.new("UICorner", track).CornerRadius = UDim.new(0, 7)

local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0, 1)
fill.BackgroundColor3 = Color3.fromRGB(64, 218, 164)
fill.Parent = track
Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 7)

local tween

local function showResult(message)
    if tween then tween:Cancel() end
    casting = false
    panel.Visible = true
    label.Text = message
    fill.Size = UDim2.fromScale(1, 1)
    task.delay(2.5, function()
        if not casting and label.Text == message then
            panel.Visible = false
        end
    end)
end

local function setupTool(tool)
    if not tool:IsA("Tool") or tool.Name ~= "Magnes" then return end
    tool.Activated:Connect(function()
        if casting then return end
        if mouse.Target and mouse.Target.Name == "FishingWater" then
            remote:FireServer(mouse.Hit.Position)
        else
            panel.Visible = true
            label.Text = "Kliknij w wode, aby lowic!"
            fill.Size = UDim2.fromScale(0, 1)
            task.delay(2, function()
                if not casting and label.Text == "Kliknij w wode, aby lowic!" then
                    panel.Visible = false
                end
            end)
        end
    end)
end

local function onCharacter(character)
    for _, child in ipairs(character:GetChildren()) do
        setupTool(child)
    end
    character.ChildAdded:Connect(setupTool)
end

player.CharacterAdded:Connect(onCharacter)
if player.Character then onCharacter(player.Character) end

remote.OnClientEvent:Connect(function(status, a)
    if status == "START" then
        casting = true
        panel.Visible = true
        label.Text = "Magnes szuka skarbow..."
        fill.Size = UDim2.fromScale(0, 1)
        if tween then tween:Cancel() end
        tween = TweenService:Create(fill, TweenInfo.new(a, Enum.EasingStyle.Linear), {
            Size = UDim2.fromScale(1, 1)
        })
        tween:Play()
    elseif status == "CAUGHT" then
        showResult("Znaleziono: " .. tostring(a) .. "!")
    elseif status == "CANCEL" then
        showResult("Lowienie przerwane")
    end
end)
>>>>>>> aace542baf8fe19d1b2c18ba97ac5ef738efa6e2
