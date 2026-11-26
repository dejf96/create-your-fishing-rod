local Players=game:GetService('Players')
local DSS=game:GetService('DataStoreService')
local store=DSS:GetDataStore('CYFR_v1')
local event=game.ReplicatedStorage.CYFR.Action
local bases=workspace.CYFRWorld.Bases
local fx=game.ReplicatedStorage.CYFR.CastFX
local items={{"Scrap",3,9.000000,"Common"},{"Bolt",5,9.000000,"Common"},{"Nail",4,9.000000,"Common"},{"Tin Can",5,9.000000,"Common"},{"Iron Plate",6,9.000000,"Common"},{"Coin",12,5.000000,"Uncommon"},{"Copper Wire",15,5.000000,"Uncommon"},{"Chain",18,5.000000,"Uncommon"},{"Old Key",21,5.000000,"Uncommon"},{"Metal Ring",24,5.000000,"Uncommon"},{"Gear",25,3.000000,"Rare"},{"Silver Coin",31,3.000000,"Rare"},{"Compass",37,3.000000,"Rare"},{"Bearing",43,3.000000,"Rare"},{"Steel Hook",50,3.000000,"Rare"},{"Crystal",100,1.600000,"Epic"},{"Ruby",125,1.600000,"Epic"},{"Sapphire",150,1.600000,"Epic"},{"Ancient Gear",175,1.600000,"Epic"},{"Golden Hook",200,1.600000,"Epic"},{"Relic",500,0.800000,"Legendary"},{"Golden Crown",625,0.800000,"Legendary"},{"Treasure Chest",750,0.800000,"Legendary"},{"Golden Skull",875,0.800000,"Legendary"},{"Emerald",1000,0.800000,"Legendary"},{"Dragon Scale",1500,0.400000,"Mythic"},{"Phoenix Core",1875,0.400000,"Mythic"},{"Mystic Orb",2250,0.400000,"Mythic"},{"Demon Horn",2625,0.400000,"Mythic"},{"Ancient Rune",3000,0.400000,"Mythic"},{"Angel Feather",5000,0.160000,"Divine"},{"Divine Crystal",6250,0.160000,"Divine"},{"Holy Crown",7500,0.160000,"Divine"},{"Sun Fragment",8750,0.160000,"Divine"},{"Celestial Key",10000,0.160000,"Divine"},{"Star Core",25000,0.036000,"Celestial"},{"Moon Shard",31250,0.036000,"Celestial"},{"Cosmic Gear",37500,0.036000,"Celestial"},{"Nebula Crystal",43750,0.036000,"Celestial"},{"Galaxy Orb",50000,0.036000,"Celestial"},{"Void Heart",100000,0.004000,"Secret"},{"Infinity Stone",125000,0.004000,"Secret"},{"Black Hole",150000,0.004000,"Secret"},{"Unknown Relic",175000,0.004000,"Secret"},{"Eternal Core",200000,0.004000,"Secret"}}
local recipes={{name='Scrap Rod',cost={Scrap=3,Bolt=2},income=2},{name='Mechanical Rod',cost={Bolt=4,Gear=2},income=8},{name='Crystal Rod',cost={Gear=3,Crystal=2},income=30},{name='Ancient Rod',cost={Crystal=3,Relic=1},income=120}}
-- RODS098A

local rodTiers = {
    {"Common",{
        "Scrap Rod","Rusty Rod","Bolt Rod",
        "Copper Rod","Reinforced Rod"
    },{2,3,5,7,10}},

    {"Uncommon",{
        "Mechanical Rod","Steel Rod","Industrial Rod",
        "Magnetic Rod","Turbo Rod"
    },{8,15,25,35,50}},

    {"Rare",{
        "Crystal Rod","Sapphire Rod","Ocean Rod",
        "Frost Rod","Thunder Rod"
    },{30,75,110,150,200}},

    {"Epic",{
        "Ancient Rod","Amethyst Rod","Phantom Rod",
        "Shadow Rod","Mystic Rod"
    },{120,300,450,600,750}},

    {"Legendary",{
        "Golden Rod","Royal Rod","Phoenix Rod",
        "Solar Rod","King's Rod"
    },{1250,1600,2000,2500,3000}},

    {"Mythic",{
        "Dragon Rod","Inferno Rod","Hydra Rod",
        "Demon Rod","Titan Rod"
    },{5000,6500,8000,10000,12500}},

    {"Divine",{
        "Holy Rod","Angel Rod","Seraph Rod",
        "Heaven Rod","Godlike Rod"
    },{20000,27500,35000,42500,50000}},

    {"Celestial",{
        "Galaxy Rod","Nebula Rod","Cosmic Rod",
        "Supernova Rod","Infinity Rod"
    },{75000,100000,130000,165000,200000}},

    {"Secret",{
        "Void Rod","Dark Matter Rod","Singularity Rod",
        "Eternal Rod","Omega Rod"
    },{300000,400000,500000,625000,750000}}
}

local materialsByTier = {}

for _,item in ipairs(items) do
    local tier = item[4]

    materialsByTier[tier] = materialsByTier[tier] or {}

    table.insert(materialsByTier[tier],item[1])
end

-- Zachowanie starych ID 1-4

for i=1,4 do
    recipes[i].rarity = rodTiers[i][1]
end

for rank,config in ipairs(rodTiers) do
    local tier = config[1]
    local names = config[2]
    local incomes = config[3]
    local materials = materialsByTier[tier]

    assert(materials and #materials >= 5,
        "Brak materialow: "..tier)

    for j,rodName in ipairs(names) do

        -- Pierwsze cztery wedki juz istnieja

        if not (rank <= 4 and j == 1) then
            local cost = {}

            cost[materials[j]] = 2+j
            cost[materials[j%5+1]] = 1+math.floor(j/2)

            if rank > 1 then
                local previous = materialsByTier[
                    rodTiers[rank-1][1]
                ]

                cost[previous[j]] = rank+2
            end

            table.insert(recipes,{
                name = rodName,
                rarity = tier,
                cost = cost,
                income = incomes[j]
            })
        end
    end
end

local data,slots,last,cast={}, {}, {}, {}
-- MAGNET096B

local rgb = Color3.fromRGB

local magnets = {
    Starter={"Neodymium Magnet",1,rgb(225,45,55),0},
    Common={"Iron Magnet",1.10,rgb(150,160,175),1},
    Uncommon={"Copper Magnet",1.25,rgb(210,125,65),2},
    Rare={"Titanium Magnet",1.50,rgb(65,150,255),3},
    Epic={"Crystal Magnet",2,rgb(180,85,255),4},
    Legendary={"Golden Magnet",3,rgb(255,195,35),5},
    Mythic={"Dragon Magnet",4.5,rgb(255,45,65),6},
    Divine={"Holy Magnet",6,rgb(255,240,150),7},
    Celestial={"Galaxy Magnet",8,rgb(60,235,255),8},
    Secret={"Void Magnet",12,rgb(180,30,255),9}
}

local function magnetConfig(d)
    local tier = d.equippedMagnet
    if d.magnets and d.magnets[tier] == true then
        return magnets[tier] or magnets.Starter
    end
    return magnets.Starter
end

-- MODELS097B

local function buildMagnet(tool,handle,cfg)
    local color = cfg[3]
    local rank = cfg[4]
    local silver = rgb(210,220,235)
    local dark = rgb(25,30,45)

    for _,o in ipairs(tool:GetChildren()) do
        if o:IsA("BasePart") and o ~= handle then
            o:Destroy()
        end
    end

    local function piece(size,offset,col,mat,angle,shape)
        local part = Instance.new("Part")
        part.Name = "MagnetModel"
        part.Size = size
        part.Color = col
        part.Material = mat or Enum.Material.Metal
        part.Shape = shape or Enum.PartType.Block
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.Massless = true
        part.CastShadow = false
        part.CFrame = handle.CFrame *
            CFrame.new(offset) *
            CFrame.Angles(0,0,angle or 0)

        part.Parent = tool

        local weld = Instance.new("WeldConstraint",part)
        weld.Part0 = handle
        weld.Part1 = part

        return part
    end

    local v = Vector3.new
    local metal = Enum.Material.Metal
    local neon = Enum.Material.Neon

    local width = .45 + rank*.025
    local thickness = .32 + rank*.012

    -- Glowny korpus

    piece(
        v(width*2+.3,.34,thickness),
        v(0,.4,0),color,metal
    )

    for _,side in ipairs({-1,1}) do
        local x = side*width

        piece(
            v(.3,.75,thickness),
            v(x,0,0),color,metal
        )

        piece(
            v(.32,.28,thickness+.04),
            v(x,-.5,0),silver,metal
        )

        -- Metalowe wzmocnienia

        if rank >= 1 then
            piece(
                v(.36,.13,thickness+.08),
                v(x,.12,0),dark,metal
            )
        end

        -- Paski energii

        if rank >= 2 then
            piece(
                v(.13,.4,.045),
                v(x,-.03,thickness/2+.025),
                color,rank>=3 and neon or metal
            )
        end

        -- Boczne pancerze

        if rank >= 5 then
            piece(
                v(.18,.45,thickness+.12),
                v(x+side*.19,.08,0),
                color,metal,-side*.2
            )
        end

        -- Rogi / skrzydla

        if rank >= 6 then
            piece(
                v(.18,.55,.23),
                v(x+side*.23,.5,0),
                color,metal,-side*.65
            )
        end

        if rank >= 7 then
            piece(
                v(.1,.45,.15),
                v(x+side*.35,.15,0),
                color,neon,-side*.5
            )
        end
    end

    -- Centralny krysztal

    if rank >= 3 then
        piece(
            v(.36,.36,.36),
            v(0,.4,thickness/2+.1),
            color,rank>=4 and neon or metal,
            math.rad(45)
        )
    end

    -- Zlote zdobienia

    if rank == 5 or rank == 7 then
        piece(
            v(.65,.12,.12),
            v(0,.6,0),
            rgb(255,215,75),metal
        )
    end

    -- Dragon Core

    if rank == 6 then
        piece(
            v(.28,.28,.28),
            v(0,.4,.38),
            rgb(255,115,25),neon,0,
            Enum.PartType.Ball
        )
    end

    -- Galaxy / Void Core

    if rank >= 8 then
        piece(
            v(.42,.42,.42),
            v(0,.42,.38),
            rank==9 and dark or color,
            rank==9 and metal or neon,
            0,Enum.PartType.Ball
        )

        for i=1,8 do
            local angle = i*math.pi/4

            piece(
                v(.13,.13,.13),
                v(
                    math.cos(angle)*.36,
                    .42+math.sin(angle)*.36,
                    .4
                ),
                color,neon,0,
                Enum.PartType.Ball
            )
        end
    end
end

local function styleMagnet(tool,d)
    local cfg = magnetConfig(d)
    local color = cfg[3]
    local rank = cfg[4]

    tool.ToolTip = cfg[1].." | Luck x"..cfg[2]
    tool:SetAttribute("MagnetName",cfg[1])
    tool:SetAttribute("MagnetLuck",cfg[2])
    tool:SetAttribute("MagnetColor",color)

    local handle = tool:FindFirstChild("Handle")
    if not handle then return end

    for _,o in ipairs(tool:GetDescendants()) do
        if o.Name == "MagnetRewardFX" then
            o:Destroy()
        end
    end

    buildMagnet(tool,handle,cfg)

if rank >= 3 then
        local light = Instance.new("PointLight")
        light.Name = "MagnetRewardFX"
        light.Color = color
        light.Brightness = rank*.25
        light.Range = 4+rank
        light.Parent = handle
    end

    if rank >= 5 then
        local aura = Instance.new("ParticleEmitter")
        aura.Name = "MagnetRewardFX"
        aura.Texture =
            "rbxasset://textures/particles/sparkles_main.dds"
        aura.Color = ColorSequence.new(color)
        aura.LightEmission = 1
        aura.Rate = rank*3
        aura.Lifetime = NumberRange.new(.4,.8)
        aura.Speed = NumberRange.new(.5,1.5)
        aura.SpreadAngle = Vector2.new(180,180)
        aura.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0,.2),
            NumberSequenceKeypoint.new(1,0)
        })
        aura.Parent = handle
    end
end

local function refreshMagnet(p,d)
    for _,container in ipairs({
        p:FindFirstChild("Backpack"),
        p.Character
    }) do
        local tool = container:FindFirstChild(
            "Neodymium Magnet"
        )
        if tool and tool:IsA("Tool") then
            styleMagnet(tool,d)
        end
    end
end

local function send(p,msg)
 local d=data[p];if not d then return end; p.leaderstats.Cash.Value=d.cash;event:FireClient(p,d,msg,recipes,items) end
local pullFX=game.ReplicatedStorage.CYFR.PullFX
local pulls={}
local chargeTimes={}

game.Players.PlayerRemoving:Connect(function(p)
    chargeTimes[p]=nil
end)

local difficulty={["Common"]={5,7},["Uncommon"]={9,9},["Rare"]={15,12},["Epic"]={24,15},["Legendary"]={35,20},["Mythic"]={45,24},["Divine"]={55,28},["Celestial"]={70,35},["Secret"]={90,45}}
local function finish(p,q,won)
 if pulls[p]~=q then return end
 pulls[p]=nil;cast[p]=os.clock()
 pullFX:FireAllClients(p,'end',won)
 if data[p]~=q.d then return end
 if won then
  -- INDEX081
  q.d.index[q.item[1]]=true

  q.d.bag[q.item[1]]=(q.d.bag[q.item[1]] or 0)+q.count
  send(p,'Found '..q.count..'x '..q.item[1]..' ['..q.item[4]..'] | $'..(q.item[2]*q.count))
 else send(p,'Przedmiot uciekl!') end
end
-- RODMODELS098C

local rodColors = {
    Common=Color3.fromRGB(165,175,190),
    Uncommon=Color3.fromRGB(65,220,110),
    Rare=Color3.fromRGB(65,150,255),
    Epic=Color3.fromRGB(185,85,255),
    Legendary=Color3.fromRGB(255,205,45),
    Mythic=Color3.fromRGB(255,65,95),
    Divine=Color3.fromRGB(255,240,150),
    Celestial=Color3.fromRGB(90,235,255),
    Secret=Color3.fromRGB(190,65,255)
}

local rodRanks = {
    Common=1,Uncommon=2,Rare=3,
    Epic=4,Legendary=5,Mythic=6,
    Divine=7,Celestial=8,Secret=9
}

-- BASE099A

local basePrices = {
    5000,50000,500000,5000000
}

local function standLimit(d)
    return 2+2*(d.baseLevel or 1)
end

local function updateBase(p)
    local base = slots[p]
    local d = data[p]

    if not base or not d then return end

    base:SetAttribute("BaseLevel",d.baseLevel)

    for i=1,12 do
        local stand=base:FindFirstChild("Stand"..i)

        if stand then
            local unlocked=i<=standLimit(d)

            stand.Transparency=unlocked and 0 or 1
            stand.CanCollide=unlocked
            stand.CanQuery=unlocked
            stand.CanTouch=unlocked
        end
    end
end

local function visual(p)

    local base = slots[p]
    if not base or not data[p] then return end

    for j=1,standLimit(data[p]) do
        local stand = base:FindFirstChild("Stand"..j)
        if not stand then continue end

        local old = stand:FindFirstChild("Rod")
        if old then old:Destroy() end

        local id = data[p].rods[j]
        local recipe = id and recipes[id]

        if not recipe then continue end

        local tier = recipe.rarity or "Common"
        local rank = rodRanks[tier] or 1
        local color = rodColors[tier]
            or Color3.new(1,1,1)

        local variant = (id-1)%5
        local v = Vector3.new

        local model = Instance.new("Model")
        model.Name = "Rod"
        model.Parent = stand

        local origin = stand.CFrame *
            CFrame.new(0,stand.Size.Y/2+.25,0) *
            CFrame.Angles(0,0,math.rad(-18))

        local function piece(size,cf,col,mat,shape)
            local part = Instance.new("Part")
            part.Size = size
            part.CFrame = origin*cf
            part.Color = col
            part.Material = mat or Enum.Material.Metal
            part.Shape = shape or Enum.PartType.Block
            part.Anchored = true
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            part.CastShadow = false
            part.Parent = model
            return part
        end

        local function segment(from,to,width,col,mat)
            local delta = to-from

            return piece(
                v(width,delta.Magnitude,width),
                CFrame.lookAt((from+to)/2,to) *
                    CFrame.Angles(math.pi/2,0,0),
                col,mat
            )
        end

        local metal = Enum.Material.Metal
        local neon = Enum.Material.Neon

        local dark = Color3.fromRGB(35,40,50)
        local silver = Color3.fromRGB(210,220,235)

        local length = 4.6+rank*.12+variant*.16

        local mainMaterial = rank>=5
            and neon or metal

        -- REKOJESC

        piece(
            v(.29,1.25,.29),
            CFrame.new(0,.65,0),
            rank>=5 and color or dark,
            Enum.Material.SmoothPlastic
        )

        for i=1,5 do
            piece(
                v(.32,.065,.32),
                CFrame.new(0,.2+i*.18,0),
                rank>=4 and color or silver,
                metal
            )
        end

        -- KOLOWROTEK

        local reel = piece(
            v(.24,.65,.65),
            CFrame.new(.34,1.15,0),
            color,metal,Enum.PartType.Cylinder
        )

        piece(
            v(.26,.37,.37),
            CFrame.new(.48,1.15,0),
            dark,metal,Enum.PartType.Cylinder
        )

        piece(
            v(.1,.4,.1),
            CFrame.new(.57,1.15,.12) *
                CFrame.Angles(.5,0,0),
            silver,metal
        )

        piece(
            v(.17,.17,.25),
            CFrame.new(.57,1.32,.23),
            dark,metal
        )

        -- WEDZISKO

        local previous = v(0,1.25,0)
        local tip

        for i=1,12 do
            local t=i/12

            local point=v(
                t*t*(.7+variant*.08),
                1.25+t*length,
                0
            )

            segment(
                previous,point,
                .16*(1-t)+.045,
                color,mainMaterial
            )

            if i%3==0 then
                piece(
                    v(.12,.12,.27),
                    CFrame.new(point+v(0,0,.1)),
                    silver,metal
                )
            end

            previous=point
            tip=point
        end

        -- ZYLKA I HACZYK

        local hook = tip-v(0,2.2,0)

        segment(
            tip,hook,.018,
            Color3.fromRGB(220,230,240),
            Enum.Material.SmoothPlastic
        )

        segment(
            hook,hook+v(.15,-.12,0),
            .045,silver,metal
        )

        segment(
            hook+v(.15,-.12,0),
            hook+v(.25,.08,0),
            .045,silver,metal
        )

        -- KRYSZTALY I ZDOBIENIA

        if rank>=3 then
            for i=1,variant+2 do
                piece(
                    v(.17,.3,.17),
                    CFrame.new(
                        math.sin(i*2)*.22,
                        1.5+i*.25,
                        math.cos(i*2)*.22
                    )*CFrame.Angles(0,0,.65),
                    color,rank>=4 and neon or metal
                )
            end
        end

        -- SKRZYDLA RZADKICH WEDEK

        if rank>=6 then
            for _,side in ipairs({-1,1}) do
                piece(
                    v(.18,.85,.28),
                    CFrame.new(side*.38,1.8,0) *
                        CFrame.Angles(0,0,-side*.65),
                    color,mainMaterial
                )
            end
        end

        -- EFEKTY SPECJALNE

        if rank>=5 then
            local light=Instance.new("PointLight",reel)
            light.Color=color
            light.Range=5+rank*.4
            light.Brightness=.5
        end

        if rank>=7 then
            local aura=Instance.new("ParticleEmitter",reel)
            aura.Texture="rbxasset://textures/particles/sparkles_main.dds"
            aura.Color=ColorSequence.new(color)
            aura.LightEmission=1
            aura.Rate=rank*2
            aura.Lifetime=NumberRange.new(.5,1)
            aura.Speed=NumberRange.new(.5,1.5)
            aura.SpreadAngle=Vector2.new(180,180)
            aura.Size=NumberSequence.new({
                NumberSequenceKeypoint.new(0,.2),
                NumberSequenceKeypoint.new(1,0)
            })
        end

        -- TABLICZKA NAD WEDKA

        local marker=piece(
            v(.1,.1,.1),
            CFrame.new(0,length+2.2,0),
            color,metal
        )

        marker.Transparency=1

        local gui=Instance.new("BillboardGui",marker)
        gui.Size=UDim2.fromOffset(155,62)
        gui.AlwaysOnTop=true
        gui.MaxDistance=45
        gui.Adornee=marker

        local frame=Instance.new("Frame",gui)
        frame.Size=UDim2.fromScale(1,1)
        frame.BackgroundColor3=Color3.fromRGB(16,24,39)
        frame.BackgroundTransparency=.12
        frame.BorderSizePixel=0

        local corner=Instance.new("UICorner",frame)
        corner.CornerRadius=UDim.new(0,9)

        local stroke=Instance.new("UIStroke",frame)
        stroke.Color=color
        stroke.Thickness=1.5

        local function label(txt,y,h,size,col)
            local l=Instance.new("TextLabel",frame)
            l.Position=UDim2.fromOffset(3,y)
            l.Size=UDim2.new(1,-6,0,h)
            l.BackgroundTransparency=1
            l.Text=txt
            l.TextSize=size
            l.TextColor3=col
            l.Font=Enum.Font.GothamBold
        end

        label(recipe.name,3,21,14,color)
        label(string.upper(tier),24,14,10,color)

        label(
            string.format("+$%.2f/sec",recipe.income/5),
            39,20,13,
            Color3.fromRGB(100,255,145)
        )
    end
end

local function save(p) local d=data[p];if d and d.saveOK then local payload={baseLevel=d.baseLevel,cash=d.cash,bag=d.bag,up=d.up,rods=d.rods,index=d.index,magnets=d.magnets,equippedMagnet=d.equippedMagnet};local ok,err=pcall(function() store:SetAsync('p'..p.UserId,payload) end);if not ok then warn(err) end end end
Players.PlayerAdded:Connect(function(p)
 local d={baseLevel=1,cash=0,bag={},up={Strength=1,Range=1,Speed=1,Luck=1},rods={},index={},magnets={},equippedMagnet="Starter"}
 local ok,loaded=pcall(function() return store:GetAsync('p'..p.UserId) end);if not p.Parent then return end;if ok and type(loaded)=='table' then for _,k in ipairs({'cash','bag','up','rods','index','magnets','equippedMagnet','baseLevel'}) do if loaded[k]~=nil then d[k]=loaded[k] end end end;d.index=d.index or {}
for name,count in pairs(d.bag) do
    if count>0 then d.index[name]=true end
end
if type(d.magnets) ~= "table" then
    d.magnets = {}
end

if not magnets[d.equippedMagnet]
    or (d.equippedMagnet ~= "Starter"
    and d.magnets[d.equippedMagnet] ~= true) then
    d.equippedMagnet = "Starter"
end

d.baseLevel=math.clamp(
    math.floor(tonumber(d.baseLevel) or 1),1,5
)

d.saveOK=ok;data[p]=d



 local stats=Instance.new('Folder',p);stats.Name='leaderstats';local cash=Instance.new('IntValue',stats);cash.Name='Cash';cash.Value=d.cash
 for _,b in ipairs(bases:GetChildren()) do if not b:GetAttribute('Owner') then b:SetAttribute('Owner',p.UserId);slots[p]=b;b.Sign.BillboardGui.TextLabel.Text=p.DisplayName.."'s base";break end end

-- CYFR070
 local base = slots[p]

 if base then
    local function spawnAtBase(char)
        local root = char:WaitForChild("HumanoidRootPart",10)
        if root and slots[p] == base and p.Character == char then
            char:PivotTo(base.Floor.CFrame *
                CFrame.new(0,4,-4))
        end
    end

    p.CharacterAdded:Connect(spawnAtBase)

    if p.Character then
        task.spawn(spawnAtBase,p.Character)
    end
 end

 local function equip() local backpack=p:WaitForChild('Backpack',10);if not backpack then return end;local tool=Instance.new('Tool');tool.Name='Neodymium Magnet';tool.CanBeDropped=false;local h=Instance.new('Part',tool);h.Name='Handle';h.Size=Vector3.new(1.2,.5,1.2);h.Color=Color3.fromRGB(225,45,55);h.Material=Enum.Material.Metal;h.Transparency=1;h.CanCollide=false;h.Massless=true
local function piece(size,offset,color,angle)
 local a=Instance.new('Part');a.Size=size;a.Color=color;a.Material=Enum.Material.Metal;a.CanCollide=false;a.CanTouch=false;a.Massless=true;a.CFrame=h.CFrame*CFrame.new(offset)*CFrame.Angles(0,0,angle or 0);a.Parent=tool
 local w=Instance.new('WeldConstraint',a);w.Part0=h;w.Part1=a
end
local red=Color3.fromRGB(225,45,55);local silver=Color3.fromRGB(205,215,225)
piece(Vector3.new(1.2,.35,.35),Vector3.new(0,.4,0),red)
for _,x in ipairs({-.45,.45}) do piece(Vector3.new(.3,.75,.35),Vector3.new(x,0,0),red);piece(Vector3.new(.3,.3,.35),Vector3.new(x,-.5,0),silver) end
styleMagnet(tool,d)
tool.Parent=backpack end
 p.CharacterAdded:Connect(equip);if p.Character then task.spawn(equip) end;updateBase(p);visual(p);send(p,'Welcome! Go to the dock and cast your magnet.')
end)
Players.PlayerRemoving:Connect(function(p) save(p);local b=slots[p];if b then b:SetAttribute('Owner',nil);b.Sign.BillboardGui.TextLabel.Text='Free base';b:SetAttribute("BaseLevel",1)

for j=1,12 do
    local stand=b:FindFirstChild("Stand"..j)

    if stand then
        local r=stand:FindFirstChild("Rod")
        if r then r:Destroy() end

        stand.Transparency=j<=4 and 0 or 1
        stand.CanCollide=j<=4
        stand.CanQuery=j<=4
        stand.CanTouch=j<=4
    end
end
 end;data[p]=nil;slots[p]=nil;last[p]=nil;cast[p]=nil end)
event.OnServerEvent:Connect(function(p,action,arg)
 local d=data[p];if not d then return end;local now=os.clock();if now-(last[p] or -100)<.15 then return end;if action~='sync' and action~='readyCast' then last[p]=now end

 if action=='sync' then send(p);return end

if action=="upgradeBase" then
    if not slots[p] then return end

    local level=d.baseLevel or 1
    local price=basePrices[level]

    if not price then
        send(p,"Maximum base level!")
        return
    end

    if d.cash<price then
        send(p,"Need $"..price)
        return
    end

    d.cash-=price
    d.baseLevel=level+1

    updateBase(p)
    visual(p)

    send(p,"Base upgraded to level "..d.baseLevel.."!")
    return
end

 
if action == "claimMagnet" then
    if type(arg) ~= "string"
        or arg == "Starter"
        or not magnets[arg] then
        return
    end

    if pulls[p] then
        send(p,"Finish fishing first!")
        return
    end

    local total = 0
    local discovered = 0

    for _,it in ipairs(items) do
        if it[4] == arg then
            total += 1
            if d.index[it[1]] == true then
                discovered += 1
            end
        end
    end

    if total ~= 5 or discovered ~= total then
        send(p,"Collection incomplete!")
        return
    end

    if d.magnets[arg] then
        send(p)
        return
    end

    d.magnets[arg] = true
    d.equippedMagnet = arg
    chargeTimes[p] = nil

    refreshMagnet(p,d)

    send(p,"Unlocked "..magnets[arg][1].."!")
    return
end

if action == "equipMagnet" then
    if type(arg) ~= "string"
        or not magnets[arg] then
        return
    end

    if pulls[p] then
        send(p,"Finish fishing first!")
        return
    end

    if arg ~= "Starter"
        and d.magnets[arg] ~= true then
        return
    end

    d.equippedMagnet = arg
    chargeTimes[p] = nil

    refreshMagnet(p,d)

    send(p,"Equipped "..magnets[arg][1].."!")
    return
end

if action=='readyCast' then

    local root = p.Character and
        p.Character:FindFirstChild("HumanoidRootPart")

    if not root then return end

    local nearest = math.huge

    for _,plank in ipairs(
        workspace.CYFRWorld.LakeVillage:GetChildren()
    ) do
        if plank.Name == "WoodPlank"
            and plank:IsA("BasePart") then

            local offset =
                plank.CFrame:PointToObjectSpace(root.Position)

            local dx = math.max(0,
                math.abs(offset.X)-plank.Size.X/2)

            local dz = math.max(0,
                math.abs(offset.Z)-plank.Size.Z/2)

            nearest = math.min(nearest,
                Vector2.new(dx,dz).Magnitude)
        end
    end

    if nearest > 8+d.up.Range*2 then
        chargeTimes[p] = nil
        return
    end

    local char = p.Character
    local tool = char and char:FindFirstChild('Neodymium Magnet')
    local delay = math.max(.65,3-(d.up.Speed-1)*.2)

    if tool and not pulls[p]
        and now-(cast[p] or -100)>=delay then

        chargeTimes[p]=now
        game.ReplicatedStorage.CYFR.CastReady:FireClient(p)
    end
    return
end

if action=='charge' then

    if not pulls[p] and p.Character
        and p.Character:FindFirstChild('Neodymium Magnet') then
        chargeTimes[p]=os.clock()
    end
    return
end

if action=='fish' then

  local q=pulls[p]
  if q then
   if now<q.start then return end
   if now>=q.deadline then finish(p,q,false);return end
   if not p.Character or not p.Character:FindFirstChild('Neodymium Magnet') then finish(p,q,false);return end
   q.progress=math.max(0,q.progress-(now-q.updated)*.35)+1;q.updated=now
   if q.progress>=q.goal then finish(p,q,true) else pullFX:FireClient(p,p,'progress',q.progress/q.goal) end
   return
  end
  local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart');local tool=p.Character and p.Character:FindFirstChild('Neodymium Magnet');if not root or not tool then send(p,'Equip your magnet first!');return end
  local lake=workspace.CYFRWorld.Lake
  local pos=lake.CFrame:PointToObjectSpace(root.Position)
  
local nearest = math.huge

for _, plank in ipairs(workspace.CYFRWorld.LakeVillage:GetChildren()) do
    if plank.Name == "WoodPlank" and plank:IsA("BasePart") then
        local offset = plank.CFrame:PointToObjectSpace(root.Position)

        local dx = math.max(0,math.abs(offset.X)-plank.Size.X/2)
        local dz = math.max(0,math.abs(offset.Z)-plank.Size.Z/2)

        local dist = Vector2.new(dx,dz).Magnitude
        nearest = math.min(nearest,dist)
    end
end

if nearest > 8+d.up.Range*2 then
    send(p,'Podejdz do pomostu!')
    return
end

local delay=math.max(.65,3-(d.up.Speed-1)*.2);if now-(cast[p] or -100)<delay then send(p,'Poczekaj na kolejny rzut!');return end;cast[p]=now
  local duration=delay*.9
  
local center = Vector3.new(0,1,0)
local direction = Vector3.new(
    center.X-root.Position.X,
    0,
    center.Z-root.Position.Z
)

if direction.Magnitude > 0.1 then
    direction = direction.Unit
else
    direction = Vector3.new(0,0,-1)
end

local landing = root.Position + direction*22
local target = Vector3.new(landing.X,1.2,landing.Z)

local elapsed = chargeTimes[p]
    and (os.clock()-chargeTimes[p]) or 0

chargeTimes[p]=nil

local power = 1-math.abs((elapsed*1.5)%2-1)

local castLuck = 1

if power>=.9 then castLuck=3
elseif power>=.7 then castLuck=2
elseif power>=.45 then castLuck=1.5
elseif power>=.2 then castLuck=1.25 end

local weights,total={},0
;for i,it in ipairs(items) do local w=it[3]*((it[4]~='Common' and it[4]~='Uncommon') and ((1+(d.up.Luck-1)*.2)*castLuck*magnetConfig(d)[2]) or 1);weights[i]=w;total+=w end;local roll=math.random()*total;local found=items[1];for i,w in ipairs(weights) do roll-=w;if roll<=0 then found=items[i];break end end
  local count=1+math.floor((d.up.Strength-1)/3);local cfg=difficulty[found[4]]
  local goal=math.max(3,math.ceil(cfg[1]/(1+(d.up.Strength-1)*.07)))
  local start=now+math.max(.65,duration*.65)
  local q={d=d,item=found,count=count,goal=goal,start=start,deadline=start+cfg[2],updated=start,progress=0}
  pulls[p]=q
  fx:FireAllClients(p,target,q.deadline-now+1,true)
  task.delay(start-now,function()
   if pulls[p]==q and p.Parent then pullFX:FireClient(p,p,'start',found[4],goal,cfg[2]) end
  end)
  task.spawn(function()
   while pulls[p]==q do
    task.wait(.1)
    if pulls[p]~=q then break end
    if not p.Parent then pulls[p]=nil;break end
    local char=p.Character;local r=char and char:FindFirstChild('HumanoidRootPart');local hum=char and char:FindFirstChildOfClass('Humanoid')
    if not r or not hum or hum.Health<=0 or not char:FindFirstChild('Neodymium Magnet') or (r.Position-target).Magnitude>60+d.up.Range*3 or os.clock()>=q.deadline then finish(p,q,false);break end
   end
  end)
 elseif action=='sell' then local earned=0;for _,it in ipairs(items) do earned+=(d.bag[it[1]] or 0)*it[2];d.bag[it[1]]=0 end;d.cash+=earned;send(p,'Sold materials for $'..earned)
 elseif action=='upgrade' and type(arg)=='string' and d.up[arg] then local level=d.up[arg];local price=50*level;if level>=20 then send(p,'Maximum level');return end;if d.cash<price then send(p,'Need $'..price);return end;d.cash-=price;d.up[arg]+=1;send(p,arg..' upgraded!')
 elseif action=='craft' and type(arg)=='number' and recipes[arg] then local r=recipes[arg];if #d.rods>=standLimit(d) then send(p,'All stands occupied!');return end;if not slots[p] then send(p,'No free base');return end;for k,v in pairs(r.cost) do if (d.bag[k] or 0)<v then send(p,'Missing '..k);return end end;for k,v in pairs(r.cost) do d.bag[k]-=v end;table.insert(d.rods,arg);visual(p);send(p,'Crafted '..r.name)
 elseif action=='remove' and type(arg)=='number' and arg%1==0 and d.rods[arg] then table.remove(d.rods,arg);visual(p);send(p,'Rod removed (no refund)') end
end)
task.spawn(function() while task.wait(5) do for p,d in pairs(data) do local income=0;if slots[p] then for _,id in ipairs(d.rods) do income+=recipes[id].income end end;if income>0 then d.cash+=income;send(p) end end end end)
task.spawn(function() while task.wait(60) do for p in pairs(data) do task.spawn(save,p) end end end)
game:BindToClose(function() local pending=0;for p in pairs(data) do pending+=1;task.spawn(function() save(p);pending-=1 end) end;local start=os.clock();while pending>0 and os.clock()-start<25 do task.wait(.1) end end)
