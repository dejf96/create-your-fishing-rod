local Players=game:GetService("Players")
local Market=game:GetService("MarketplaceService")
local config=require(game.ReplicatedStorage.CYFR.PremiumConfig)

local function refresh(p)

    for _,cfg in ipairs(config) do

        local owned=false

        if cfg[5]>0 and p.UserId>0 then

            local ok,result=pcall(function()
                return Market:UserOwnsGamePassAsync(
                    p.UserId,cfg[5])
            end)

            owned=ok and result==true
        end

        if not p.Parent then return end

        p:SetAttribute("Premium_"..cfg[1],owned)
    end
end

Players.PlayerAdded:Connect(refresh)

for _,p in ipairs(Players:GetPlayers()) do
    task.spawn(refresh,p)
end

Market.PromptGamePassPurchaseFinished:Connect(
    function(p,id,purchased)

        if purchased then
            task.spawn(refresh,p)
        end
    end)

while task.wait(60) do
    for _,p in ipairs(Players:GetPlayers()) do
        task.spawn(refresh,p)
    end
end
