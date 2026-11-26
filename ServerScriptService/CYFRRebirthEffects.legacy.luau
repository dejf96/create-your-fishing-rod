local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")

local rgb=Color3.fromRGB

local tiers={
    {20,rgb(65,235,255),"Infinity Aura"},
    {15,rgb(255,105,200),"Divine Aura"},
    {10,rgb(255,205,45),"Golden Aura"},
    {5,rgb(175,65,255),"Mystic Aura"},
    {3,rgb(65,155,255),"Electric Aura"},
    {1,rgb(65,235,120),"Energy Aura"}
}

local function getTier(level)
    for _,tier in ipairs(tiers) do
        if level>=tier[1] then
            return tier
        end
    end
end

local function clearAura(char)
    for _,obj in ipairs(char:GetDescendants()) do
        if obj.Name=="CYFRRebirthAura" then
            obj:Destroy()
        end
    end
end

local function applyAura(p)
    local char=p.Character
    if not char then return end

    clearAura(char)

    local level=p:GetAttribute("Rebirths") or 0
    local tier=getTier(level)

    if not tier then return end

    local root=char:FindFirstChild(
        "HumanoidRootPart")

    if not root then return end

    local color=tier[2]

    local attachment=Instance.new("Attachment")
    attachment.Name="CYFRRebirthAura"
    attachment.Position=Vector3.new(0,-2,0)
    attachment.Parent=root

    local particles=Instance.new(
        "ParticleEmitter",attachment)

    particles.Texture=
        "rbxasset://textures/particles/sparkles_main.dds"

    particles.Color=ColorSequence.new(color)

    if level>=20 then
        particles.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(
                0,rgb(255,75,150)),
            ColorSequenceKeypoint.new(
                .33,rgb(255,220,65)),
            ColorSequenceKeypoint.new(
                .66,rgb(65,235,255)),
            ColorSequenceKeypoint.new(
                1,rgb(175,65,255))
        })
    end

    particles.Rate=5+level*1.5
    particles.Lifetime=NumberRange.new(.6,1.3)
    particles.Speed=NumberRange.new(1,3)
    particles.Acceleration=Vector3.new(0,3,0)
    particles.SpreadAngle=Vector2.new(180,180)
    particles.LightEmission=1

    particles.Size=NumberSequence.new({
        NumberSequenceKeypoint.new(0,.18),
        NumberSequenceKeypoint.new(.4,.35),
        NumberSequenceKeypoint.new(1,0)
    })

    particles.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,.15),
        NumberSequenceKeypoint.new(1,1)
    })

    local highlight=Instance.new("Highlight")
    highlight.Name="CYFRRebirthAura"
    highlight.Adornee=char
    highlight.FillColor=color
    highlight.FillTransparency=.95
    highlight.OutlineColor=color
    highlight.OutlineTransparency=.4
    highlight.DepthMode=
        Enum.HighlightDepthMode.Occluded
    highlight.Parent=char

    if level>=5 then
        local light=Instance.new(
            "PointLight",attachment)

        light.Color=color
        light.Brightness=.6
        light.Range=8
    end
end

local function rebirthBurst(p,level)
    local char=p.Character
    local root=char and char:FindFirstChild(
        "HumanoidRootPart")

    if not root then return end

    local tier=getTier(level)
    if not tier then return end

    local color=tier[2]

    -- Fala energii

    for i=1,3 do
        task.delay((i-1)*.18,function()

            if not root.Parent then return end

            local ring=Instance.new("Part")
            ring.Name="RebirthShockwave"
            ring.Shape=Enum.PartType.Cylinder
            ring.Material=Enum.Material.Neon
            ring.Color=color
            ring.Transparency=.35
            ring.Size=Vector3.new(.12,2,2)
            ring.Anchored=true
            ring.CanCollide=false
            ring.CanTouch=false
            ring.CanQuery=false
            ring.CastShadow=false

            ring.CFrame=
                CFrame.new(root.Position
                    -Vector3.new(0,2.7,0))
                *CFrame.Angles(0,0,math.pi/2)

            ring.Parent=workspace

            TweenService:Create(ring,
                TweenInfo.new(1,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out),
                {
                    Size=Vector3.new(.12,25,25),
                    Transparency=1
                }
            ):Play()

            Debris:AddItem(ring,1.2)
        end)
    end

    -- Wybuch czasteczek

    local attachment=Instance.new(
        "Attachment",root)

    local burst=Instance.new(
        "ParticleEmitter",attachment)

    burst.Texture=
        "rbxasset://textures/particles/sparkles_main.dds"

    burst.Color=ColorSequence.new(color)
    burst.Rate=0
    burst.LightEmission=1
    burst.Lifetime=NumberRange.new(.8,1.8)
    burst.Speed=NumberRange.new(8,18)
    burst.SpreadAngle=Vector2.new(180,180)
    burst.Drag=3

    burst.Size=NumberSequence.new({
        NumberSequenceKeypoint.new(0,.5),
        NumberSequenceKeypoint.new(1,0)
    })

    burst:Emit(100)

    Debris:AddItem(attachment,2.5)
end

local function setup(p)
    local previous=p:GetAttribute("Rebirths")

    p:GetAttributeChangedSignal(
        "Rebirths"):Connect(function()

        local current=p:GetAttribute("Rebirths")

        applyAura(p)

        if previous~=nil
            and current
            and current>previous then

            rebirthBurst(p,current)
        end

        previous=current
    end)

    local function onCharacter(char)
        char:WaitForChild("HumanoidRootPart",10)

        if p.Character==char then
            applyAura(p)
        end
    end

    p.CharacterAdded:Connect(onCharacter)

    if p.Character then
        task.spawn(onCharacter,p.Character)
    end
end

Players.PlayerAdded:Connect(setup)

for _,p in ipairs(Players:GetPlayers()) do
    setup(p)
end

print("CYFR REBIRTH AURAS LOADED!")
