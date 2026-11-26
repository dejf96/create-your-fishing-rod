local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CAST_SECONDS = 3
local MAX_DISTANCE = 85
local rng = Random.new()

local loot = {
    {name = "Zlom", weight = 45, value = 5},
    {name = "Sruby", weight = 28, value = 12},
    {name = "Monety", weight = 15, value = 25},
    {name = "Czesci mechaniczne", weight = 9, value = 65},
    {name = "Stary skarb", weight = 3, value = 200},
}

local remote = ReplicatedStorage:FindFirstChild("MagnetFishingEvent") or Instance.new("RemoteEvent")
remote.Name = "MagnetFishingEvent"
remote.Parent = ReplicatedStorage

-- Temporary test pond; replace with a tagged/named water zone when building the map.
local water = workspace:FindFirstChild("FishingWater")
if not water then
    water = Instance.new("Part")
    water.Name = "FishingWater"
    water.Anchored = true
    water.CanCollide = false
    water.Size = Vector3.new(90, 1, 65)
    water.Position = Vector3.new(0, 0.2, -75)
    water.Color = Color3.fromRGB(36, 155, 210)
    water.Material = Enum.Material.Glass
    water.Transparency = 0.25
    water.Parent = workspace
end

local busy = {}

local function rollLoot()
    local total = 0
    for _, item in ipairs(loot) do
        total += item.weight
    end
    local roll = rng:NextNumber(0, total)
    for _, item in ipairs(loot) do
        roll -= item.weight
        if roll <= 0 then
            return item
        end
    end
    return loot[#loot]
end

local function makeValue(parent, name)
    local value = parent:FindFirstChild(name) or Instance.new("IntValue")
    value.Name = name
    value.Parent = parent
    return value
end

local function giveMagnet(player)
    local backpack = player:WaitForChild("Backpack")
    if backpack:FindFirstChild("Magnes") then return end
    local tool = Instance.new("Tool")
    tool.Name = "Magnes"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool.ToolTip = "Wyposaz magnes i kliknij w wode"
    tool.Parent = backpack
end

Players.PlayerAdded:Connect(function(player)
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player
    makeValue(stats, "Coins")
    makeValue(stats, "Finds")

    local inventory = Instance.new("Folder")
    inventory.Name = "Materials"
    inventory.Parent = player
    for _, item in ipairs(loot) do
        makeValue(inventory, item.name)
    end

    player.CharacterAdded:Connect(function()
        busy[player] = nil
        giveMagnet(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    busy[player] = nil
end)

remote.OnServerEvent:Connect(function(player, hitPosition)
    if busy[player] or typeof(hitPosition) ~= "Vector3" then return end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local magnet = character and character:FindFirstChild("Magnes")
    if not root or not humanoid or humanoid.Health <= 0 or not magnet or not magnet:IsA("Tool") then return end

    -- Never trust the client: validate the point against the server-owned pond.
    local relative = water.CFrame:PointToObjectSpace(hitPosition)
    if math.abs(relative.X) > water.Size.X / 2 or math.abs(relative.Z) > water.Size.Z / 2
        or math.abs(relative.Y) > water.Size.Y / 2 + 2 then return end
    if (root.Position - hitPosition).Magnitude > MAX_DISTANCE then return end

    busy[player] = true
    remote:FireClient(player, "START", CAST_SECONDS)
    task.wait(CAST_SECONDS)

    if player.Parent ~= Players or busy[player] ~= true then return end
    busy[player] = nil
    if not player.Character or player.Character ~= character or humanoid.Health <= 0 then
        remote:FireClient(player, "CANCEL")
        return
    end

    local item = rollLoot()
    player.Materials[item.name].Value += 1
    player.leaderstats.Finds.Value += 1
    -- Materials are stored, not automatically sold; crafting/selling comes next.
    remote:FireClient(player, "CAUGHT", item.name, item.value)
end)
