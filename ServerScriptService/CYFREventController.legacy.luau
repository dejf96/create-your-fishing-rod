local state=game.ReplicatedStorage.CYFR.FishingEvent
local world=workspace:WaitForChild("CYFRWorld")
local terrain=workspace.Terrain
local rgb=Color3.fromRGB

local events={
    {
        name="Lucky Rain",
        desc="2x Luck",
        duration=180,
        weight=35,
        color=rgb(65,255,125)
    },
    {
        name="Golden Lake",
        desc="2x Sell Value",
        duration=180,
        weight=30,
        color=rgb(255,200,50)
    },
    {
        name="Double Materials",
        desc="2x Materials",
        duration=180,
        weight=23,
        color=rgb(65,175,255)
    },
    {
        name="Meteor Shower",
        desc="5x Celestial Weight",
        duration=120,
        weight=10,
        color=rgb(175,85,255)
    },
    {
        name="Secret Hunt",
        desc="10x Secret Weight",
        duration=60,
        weight=2,
        color=rgb(255,65,200)
    }
}

local function choose()
    local total=0

    for _,e in ipairs(events) do
        total+=e.weight
    end

    local roll=math.random()*total

    for _,e in ipairs(events) do
        roll-=e.weight

        if roll<=0 then return e end
    end

    return events[1]
end

local effects=world:FindFirstChild("FishingEventFX")
    or Instance.new("Folder",world)

effects.Name="FishingEventFX"

local normalWater=terrain.WaterColor

local function clearFX()
    effects:ClearAllChildren()
    terrain.WaterColor=normalWater
end

local function createFX(e)
    clearFX()

    terrain.WaterColor=normalWater:Lerp(e.color,.65)

    local lake=world:WaitForChild("Lake")

    for i=1,12 do
        local angle=math.pi*2*i/12
        local radius=45

        local part=Instance.new("Part")
        part.Name="EventParticles"
        part.Size=Vector3.new(1,1,1)
        part.Position=lake.Position+Vector3.new(
            math.cos(angle)*radius,
            5,
            math.sin(angle)*radius
        )

        part.Transparency=1
        part.Anchored=true
        part.CanCollide=false
        part.CanTouch=false
        part.CanQuery=false
        part.Parent=effects

        local emitter=Instance.new("ParticleEmitter",part)
        emitter.Texture=
            "rbxasset://textures/particles/sparkles_main.dds"

        emitter.Color=ColorSequence.new(e.color)
        emitter.LightEmission=1
        emitter.Rate=12
        emitter.Lifetime=NumberRange.new(2,4)
        emitter.Speed=NumberRange.new(3,7)
        emitter.SpreadAngle=Vector2.new(180,180)

        emitter.Size=NumberSequence.new({
            NumberSequenceKeypoint.new(0,.3),
            NumberSequenceKeypoint.new(.5,.65),
            NumberSequenceKeypoint.new(1,0)
        })

        if e.name=="Lucky Rain"
            or e.name=="Meteor Shower" then

            part.Position+=Vector3.new(0,18,0)
            emitter.EmissionDirection=Enum.NormalId.Bottom
            emitter.Acceleration=Vector3.new(0,-15,0)
            emitter.SpreadAngle=Vector2.new(20,20)
        end
    end
end

local function waitUntil(timestamp)
    while workspace:GetServerTimeNow()<timestamp do
        task.wait(.5)
    end
end

local function runEvent(e)
    local ending=workspace:GetServerTimeNow()+e.duration

    state:SetAttribute("Description",e.desc)
    state:SetAttribute("Color",e.color)
    state:SetAttribute("EndsAt",ending)
    state:SetAttribute("Event",e.name)

    createFX(e)

    print("[CYFR EVENT] Started: "..e.name)

    waitUntil(ending)

    state:SetAttribute("Event","None")
    state:SetAttribute("EndsAt",0)

    clearFX()

    print("[CYFR EVENT] Ended: "..e.name)
end

local first=true

while true do
    local cooldown=first and 60 or 300
    first=false

    local nextAt=workspace:GetServerTimeNow()+cooldown

    state:SetAttribute("NextAt",nextAt)

    waitUntil(nextAt)

    runEvent(choose())
end
