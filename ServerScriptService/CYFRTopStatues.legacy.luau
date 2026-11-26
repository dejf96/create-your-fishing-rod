local Players=game:GetService("Players")
local DSS=game:GetService("DataStoreService")
local RunService=game:GetService("RunService")

local cave=workspace.CYFRWorld:
    WaitForChild("LeaderboardCave")

local studio=RunService:IsStudio()

local store

if not studio then
    store=DSS:GetOrderedDataStore(
        "CYFR_GlobalCash_v1")
end

local folder=Instance.new("Folder")
folder.Name="TopPlayerStatues"
folder.Parent=cave

local rgb=Color3.fromRGB

local colors={
    rgb(255,210,45),
    rgb(205,215,235),
    rgb(205,135,75)
}

local statues={}

local function getRanking()

    local entries={}

    if studio then

        for _,p in ipairs(Players:GetPlayers()) do

            local cash=p:GetAttribute("RankCash")

            if type(cash)=="number" then
                table.insert(entries,{
                    id=p.UserId,
                    name=p.Name,
                    value=cash,
                    player=p
                })
            end
        end

        table.sort(entries,function(a,b)
            if a.value==b.value then
                return a.id<b.id
            end
            return a.value>b.value
        end)

    else

        local ok,pages=pcall(function()
            return store:GetSortedAsync(false,3)
        end)

        if not ok then
            warn("TOP STATUES:",pages)
            return nil
        end

        for _,entry in ipairs(
            pages:GetCurrentPage()) do

            local id=tonumber(entry.key)

            if id and id>0 then

                local success,name=pcall(function()
                    return Players:
                        GetNameFromUserIdAsync(id)
                end)

                table.insert(entries,{
                    id=id,
                    name=success and name
                        or "User "..id,
                    value=entry.value
                })
            end
        end
    end

    return entries
end

local function compact(n)

    for _,unit in ipairs({
        {1e12,"T"},
        {1e9,"B"},
        {1e6,"M"},
        {1e3,"K"}
    }) do

        if n>=unit[1] then
            return string.format(
                "%.2f%s",n/unit[1],unit[2])
        end
    end

    return tostring(math.floor(n))
end

local function createAvatar(entry)

    local ok,model=pcall(function()

        if entry.player then

            local char=entry.player.Character

            if char then

                local old=char.Archivable
                char.Archivable=true

                local clone=char:Clone()

                char.Archivable=old

                return clone
            end
        end

        if entry.id>0 then
            return Players:
                CreateHumanoidModelFromUserIdAsync(
                    entry.id)
        end
    end)

    if ok then return model end

    warn("Avatar creation failed:",model)

    return nil
end

local function createStatue(rank,entry)

    local podium=cave:FindFirstChild(
        "Podium"..rank)

    if not podium then return end

    local model=createAvatar(entry)

    if not model then return end

    model.Name="Top"..rank

    for _,obj in ipairs(model:GetDescendants()) do

        if obj:IsA("BaseScript")
            or obj:IsA("Tool")
            or obj:IsA("ParticleEmitter")
            or obj:IsA("Highlight")
            or obj:IsA("BillboardGui") then

            obj:Destroy()

        elseif obj:IsA("BasePart") then

            obj.Anchored=true
            obj.CanCollide=false
            obj.CanTouch=false
            obj.CanQuery=false
        end
    end

    local hum=model:FindFirstChildOfClass(
        "Humanoid")

    if hum then
        hum.DisplayDistanceType=
            Enum.HumanoidDisplayDistanceType.None
    end

    local color=colors[rank]

    model:ScaleTo(1.65)

    model:PivotTo(
        podium.CFrame*CFrame.Angles(0,math.pi,0))

    local cf,size=model:GetBoundingBox()

    local bottom=cf.Position.Y-size.Y/2

    local targetY=podium.Position.Y
        +podium.Size.Y/2+.25

    model:PivotTo(
        model:GetPivot()
        +Vector3.new(0,targetY-bottom,0))

    local highlight=Instance.new("Highlight")
    highlight.Adornee=model
    highlight.FillColor=color
    highlight.FillTransparency=.95
    highlight.OutlineColor=color
    highlight.OutlineTransparency=.2
    highlight.DepthMode=
        Enum.HighlightDepthMode.Occluded
    highlight.Parent=model

    local head=model:FindFirstChild("Head")

    if head then

        local gui=Instance.new("BillboardGui")
        gui.Name="RankingName"
        gui.Adornee=head
        gui.Size=UDim2.fromOffset(220,85)
        gui.StudsOffset=Vector3.new(0,3,0)
        gui.AlwaysOnTop=false
        gui.MaxDistance=100
        gui.Parent=head

        local title=Instance.new("TextLabel",gui)
        title.Size=UDim2.new(1,0,0,25)
        title.BackgroundTransparency=1
        title.Text="#"..rank.." GLOBAL CASH"
        title.TextColor3=color
        title.TextScaled=true
        title.Font=Enum.Font.GothamBold
        title.TextStrokeTransparency=.4

        local name=Instance.new("TextLabel",gui)
        name.Position=UDim2.fromOffset(0,27)
        name.Size=UDim2.new(1,0,0,25)
        name.BackgroundTransparency=1
        name.Text=entry.name
        name.TextColor3=rgb(255,255,255)
        name.TextScaled=true
        name.Font=Enum.Font.GothamBold
        name.TextStrokeTransparency=.4

        local cash=Instance.new("TextLabel",gui)
        cash.Name="Cash"
        cash.Position=UDim2.fromOffset(0,55)
        cash.Size=UDim2.new(1,0,0,25)
        cash.BackgroundTransparency=1
        cash.Text="$"..compact(entry.value)
        cash.TextColor3=rgb(65,255,135)
        cash.TextScaled=true
        cash.Font=Enum.Font.GothamBold
        cash.TextStrokeTransparency=.4

        -- ZLOTA KORONA

        if rank==1 then

            for i=1,8 do

                local angle=i*math.pi/4

                local jewel=Instance.new("Part")
                jewel.Name="Crown"
                jewel.Size=Vector3.new(.35,.65,.35)
                jewel.Color=color
                jewel.Material=Enum.Material.Neon
                jewel.Anchored=true
                jewel.CanCollide=false
                jewel.CanTouch=false
                jewel.CanQuery=false

                jewel.Position=head.Position
                    +Vector3.new(
                        math.cos(angle)*1.1,
                        head.Size.Y/2+.6,
                        math.sin(angle)*1.1)

                jewel.Parent=model
            end
        end
    end

    local root=model:FindFirstChild(
        "HumanoidRootPart")

    if root then

        local light=Instance.new("PointLight",root)
        light.Color=color
        light.Range=14
        light.Brightness=1

        local fx=Instance.new("ParticleEmitter",root)

        fx.Texture=
            "rbxasset://textures/particles/sparkles_main.dds"

        fx.Color=ColorSequence.new(color)
        fx.Rate=12
        fx.Lifetime=NumberRange.new(1,2)
        fx.Speed=NumberRange.new(1,3)
        fx.SpreadAngle=Vector2.new(180,180)
        fx.LightEmission=1
        fx.Size=NumberSequence.new(.25)
    end

    model.Parent=folder

    return model
end

local function refresh()

    local entries=getRanking()

    if not entries then return end

    for rank=1,3 do

        local entry=entries[rank]
        local old=statues[rank]

        if not entry then

            if old then
                old.model:Destroy()
                statues[rank]=nil
            end

        elseif not old or old.id~=entry.id then

            local model=createStatue(rank,entry)

            if model then

                if old then old.model:Destroy() end

                statues[rank]={
                    id=entry.id,
                    model=model
                }
            end

        else

            local head=old.model:
                FindFirstChild("Head")

            local gui=head and head:
                FindFirstChild("RankingName")

            if gui and gui:FindFirstChild("Cash") then
                gui.Cash.Text="$"..compact(entry.value)
            end
        end
    end
end

task.wait(5)

while true do

    local ok,err=pcall(refresh)

    if not ok then
        warn("TOP STATUES:",err)
    end

    task.wait(studio and 15 or 120)
end
