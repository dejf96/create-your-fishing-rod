local FX={}
local Tween=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local rgb=Color3.fromRGB

local colors={
    Luck=rgb(65,235,125),
    Speed=rgb(255,215,55),
    Strength=rgb(255,65,85),
    Money=rgb(255,175,35),
    Income=rgb(65,165,255),
    Ultimate=rgb(185,75,255)
}

local active={}
local drinking={}

local function piece(parent,name,size,color,shape)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.Color=color
    p.Shape=shape or Enum.PartType.Block
    p.Material=Enum.Material.SmoothPlastic
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.Massless=true
    p.CastShadow=false
    p.Parent=parent
    return p
end

local function weld(a,b)
    local w=Instance.new("WeldConstraint",a)
    w.Part0=a
    w.Part1=b
end

local function particles(parent,color,rate)
    local e=Instance.new("ParticleEmitter",parent)

    e.Texture=
        "rbxasset://textures/particles/sparkles_main.dds"

    e.Color=ColorSequence.new(color)
    e.LightEmission=.65
    e.Rate=rate
    e.Lifetime=NumberRange.new(.6,1.4)
    e.Speed=NumberRange.new(1,3)
    e.SpreadAngle=Vector2.new(180,180)

    e.Size=NumberSequence.new({
        NumberSequenceKeypoint.new(0,.25),
        NumberSequenceKeypoint.new(.4,.4),
        NumberSequenceKeypoint.new(1,0)
    })

    e.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,.15),
        NumberSequenceKeypoint.new(1,1)
    })

    return e
end

-- MODEL BUTELKI

local function bottle(character,hand,color)
    local model=Instance.new("Model")
    model.Name="CYFRDrinkingPotion"
    model.Parent=character

    local body=piece(model,"Bottle",
        Vector3.new(.65,.75,.65),
        color,Enum.PartType.Ball)

    body.Material=Enum.Material.Glass
    body.Transparency=.15

    body.CFrame=hand.CFrame*
        CFrame.new(0,-.35,-.25)

    local liquid=piece(model,"Liquid",
        Vector3.new(.48,.48,.48),
        color,Enum.PartType.Ball)

    liquid.Material=Enum.Material.Neon
    liquid.CFrame=body.CFrame*
        CFrame.new(0,-.08,0)

    weld(body,liquid)

    local neck=piece(model,"Neck",
        Vector3.new(.3,.24,.24),
        color,Enum.PartType.Cylinder)

    neck.CFrame=body.CFrame*
        CFrame.new(0,.43,0)*
        CFrame.Angles(0,0,math.pi/2)

    weld(body,neck)

    local cork=piece(model,"Cork",
        Vector3.new(.15,.29,.29),
        rgb(170,115,65),
        Enum.PartType.Cylinder)

    cork.Material=Enum.Material.Wood

    cork.CFrame=body.CFrame*
        CFrame.new(0,.63,0)*
        CFrame.Angles(0,0,math.pi/2)

    weld(body,cork)
    weld(hand,body)

    model.PrimaryPart=body

    particles(body,color,5)

    Debris:AddItem(model,3)

    return model
end

-- IMPULS ENERGII

local function burst(root,color)
    if not root or not root.Parent then return end

    local attachment=Instance.new("Attachment",root)
    attachment.Name="PotionBurst"

    local e=particles(attachment,color,0)
    e.Speed=NumberRange.new(5,10)
    e.Lifetime=NumberRange.new(.5,1)
    e:Emit(45)

    Debris:AddItem(attachment,2)

    local ring=piece(workspace,"PotionPulse",
        Vector3.new(.12,2,2),
        color,Enum.PartType.Cylinder)

    ring.Anchored=true
    ring.Material=Enum.Material.Neon
    ring.Transparency=.65

    ring.CFrame=CFrame.new(
        root.Position-Vector3.new(0,2.5,0)
    )*CFrame.Angles(0,0,math.pi/2)

    Tween:Create(ring,TweenInfo.new(.7),{
        Size=Vector3.new(.08,10,10),
        Transparency=1
    }):Play()

    Debris:AddItem(ring,.8)
end

-- AURA AKTYWNYCH BOOSTOW

local function updateAura(player)
    local info=active[player]
    if not info then return end

    local character=player.Character
    if not character then return end

    local root=character:FindFirstChild(
        "HumanoidRootPart")

    if not root then return end

    local names={}

    for _,name in ipairs({
        "Luck","Speed","Strength","Money","Income"
    }) do
        if (info.untils[name] or 0)>os.time() then
            table.insert(names,name)
        end
    end

    local signature=table.concat(names,",")

    local old=character:FindFirstChild(
        "CYFRPotionAura")

    if #names==0 then
        if old then old:Destroy() end
        return
    end

    if old and old:GetAttribute("Signature")
        ==signature then
        return
    end

    if old then old:Destroy() end

    local folder=Instance.new("Folder",character)
    folder.Name="CYFRPotionAura"
    folder:SetAttribute("Signature",signature)

    local color=#names==1
        and colors[names[1]]
        or colors.Ultimate

    local highlight=Instance.new("Highlight",folder)
    highlight.Adornee=character
    highlight.FillColor=color
    highlight.OutlineColor=color
    highlight.FillTransparency=.94
    highlight.OutlineTransparency=.4
    highlight.DepthMode=
        Enum.HighlightDepthMode.Occluded

    local anchor=piece(folder,"AuraAnchor",
        Vector3.new(.1,.1,.1),color)

    anchor.Transparency=1
    anchor.CFrame=root.CFrame
    weld(root,anchor)

    local attachment=Instance.new(
        "Attachment",anchor)

    attachment.Position=Vector3.new(0,-1.8,0)

    for _,name in ipairs(names) do
        local e=particles(
            attachment,colors[name],5)

        e.Acceleration=Vector3.new(0,2,0)

        if name=="Speed" then
            e.Speed=NumberRange.new(3,6)
        end
    end

    local light=Instance.new("PointLight",anchor)
    light.Color=color
    light.Brightness=.35
    light.Range=7
end

function FX.Sync(player,d)
    active[player]={
        untils=d.potionUntil or {}
    }

    updateAura(player)
end

-- ANIMACJA WYPIJANIA

function FX.Drink(player,name)
    if drinking[player] then return end

    local character=player.Character
    if not character then return end

    local hand=character:FindFirstChild("RightHand")
        or character:FindFirstChild("Right Arm")

    local root=character:FindFirstChild(
        "HumanoidRootPart")

    if not hand or not root then return end

    local color=colors[name] or colors.Ultimate

    local token={}
    drinking[player]=token

    task.spawn(function()
        local model=bottle(character,hand,color)

        local shoulder=character:FindFirstChild(
            "RightShoulder",true)
            or character:FindFirstChild(
                "Right Shoulder",true)

        local original

        if shoulder and shoulder:IsA("Motor6D") then
            original=shoulder.C0

            Tween:Create(shoulder,
                TweenInfo.new(.45,
                    Enum.EasingStyle.Quad),
                {
                    C0=original*CFrame.Angles(
                        math.rad(105),0,math.rad(12))
                }):Play()
        end

        task.wait(.85)

        if model then model:Destroy() end

        if shoulder and shoulder.Parent
            and original then

            Tween:Create(shoulder,
                TweenInfo.new(.35),
                {C0=original}):Play()
        end

        if player.Character==character then
            burst(root,color)
            updateAura(player)
        end

        task.wait(.4)

        if drinking[player]==token then
            drinking[player]=nil
        end
    end)
end

-- ODSWIEZANIE I WYGASANIE AUR

task.spawn(function()
    while task.wait(1) do
        for player in pairs(active) do
            if player.Parent then
                updateAura(player)
            else
                active[player]=nil
                drinking[player]=nil
            end
        end
    end
end)

game.Players.PlayerRemoving:Connect(function(p)
    active[p]=nil
    drinking[p]=nil
end)

return FX
