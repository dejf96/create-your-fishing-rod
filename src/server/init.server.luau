<<<<<<< HEAD
print("Hello world, from server!")
=======

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local fishingEvent = Instance.new("RemoteEvent")
fishingEvent.Name = "FishingEvent"
fishingEvent.Parent = ReplicatedStorage

local fishTypes = {
    {name = "Karp", chance = 45, value = 10},
    {name = "Okon", chance = 30, value = 20},
    {name = "Losos", chance = 15, value = 50},
    {name = "Zlota Ryba", chance = 8, value = 150},
    {name = "Legendarny Rekin", chance = 2, value = 500},
}

local busy = {}

local function rollFish()
    local roll = math.random(1, 100)
    local total = 0

    for _, fish in ipairs(fishTypes) do
        total += fish.chance

        if roll <= total then
            return fish
        end
    end

    return fishTypes[1]
end

local function createRod(player)
    local backpack = player:WaitForChild("Backpack")

    local rod = Instance.new("Tool")
    rod.Name = "Fishing Rod"
    rod.RequiresHandle = false
    rod.CanBeDropped = false
    rod.ToolTip = "Kliknij, aby lowic ryby!"
    rod.Parent = backpack
end

Players.PlayerAdded:Connect(function(player)
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player

    local fishCount = Instance.new("IntValue")
    fishCount.Name = "Fish"
    fishCount.Parent = stats

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Parent = stats

    player.CharacterAdded:Connect(function()
        busy[player] = nil
        createRod(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    busy[player] = nil
end)

fishingEvent.OnServerEvent:Connect(function(player)
    if busy[player] then
        return
    end

    local character = player.Character
    local rod = character and character:FindFirstChild("Fishing Rod")

    if not rod or not rod:IsA("Tool") then
        return
    end

    busy[player] = true
    fishingEvent:FireClient(player, "START")

    task.wait(math.random(3, 6))

    if player.Parent ~= Players then
        busy[player] = nil
        return
    end

    local fish = rollFish()

    player.leaderstats.Fish.Value += 1
    player.leaderstats.Coins.Value += fish.value

    fishingEvent:FireClient(
        player,
        "CAUGHT",
        fish.name,
        fish.value
    )

    busy[player] = nil
end)
>>>>>>> 9a2cd13f31d1d63fb03d0ab51ff4ebaa23340f98
