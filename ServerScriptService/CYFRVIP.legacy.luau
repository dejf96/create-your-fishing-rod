local Players=game:GetService("Players")

local gold=Color3.fromRGB(255,205,45)

local function refresh(p)

    local char=p.Character

    if not char then return end

    for _,obj in ipairs(char:GetDescendants()) do

        if obj.Name=="CYFRVIPHighlight"
            or obj.Name=="CYFRVIPParticles"
            or obj.Name=="CYFRVIPTag"
            or obj.Name=="CYFRVIPLight" then

            obj:Destroy()
        end
    end

    if p:GetAttribute("Premium_VIP")~=true then
        return
    end

    local root=char:FindFirstChild("HumanoidRootPart")
    local head=char:FindFirstChild("Head")

    if not root or not head then return end

    -- GOLDEN AURA

    local aura=Instance.new("Highlight")
    aura.Name="CYFRVIPHighlight"
    aura.Adornee=char
    aura.FillColor=gold
    aura.FillTransparency=.92
    aura.OutlineColor=gold
    aura.OutlineTransparency=.1
    aura.DepthMode=Enum.HighlightDepthMode.Occluded
    aura.Parent=char

    -- GOLDEN PARTICLES

    local particles=Instance.new("ParticleEmitter")
    particles.Name="CYFRVIPParticles"
    particles.Texture=
        "rbxasset://textures/particles/sparkles_main.dds"

    particles.Color=ColorSequence.new(gold)
    particles.Rate=18
    particles.Lifetime=NumberRange.new(1,2)
    particles.Speed=NumberRange.new(.5,2)
    particles.SpreadAngle=Vector2.new(180,180)
    particles.LightEmission=1

    particles.Size=NumberSequence.new({
        NumberSequenceKeypoint.new(0,.15),
        NumberSequenceKeypoint.new(.5,.35),
        NumberSequenceKeypoint.new(1,0)
    })

    particles.Parent=root

    -- GOLDEN LIGHT

    local light=Instance.new("PointLight")
    light.Name="CYFRVIPLight"
    light.Color=gold
    light.Range=10
    light.Brightness=.8
    light.Parent=root

    -- VIP NAMETAG

    local gui=Instance.new("BillboardGui")
    gui.Name="CYFRVIPTag"
    gui.Adornee=head
    gui.Size=UDim2.fromOffset(100,30)
    gui.StudsOffset=Vector3.new(0,3.5,0)
    gui.MaxDistance=80
    gui.AlwaysOnTop=false
    gui.Parent=head

    local text=Instance.new("TextLabel",gui)
    text.Size=UDim2.fromScale(1,1)
    text.BackgroundColor3=Color3.fromRGB(40,30,10)
    text.BackgroundTransparency=.15
    text.Text="VIP"
    text.TextColor3=gold
    text.TextScaled=true
    text.Font=Enum.Font.GothamBold

    local corner=Instance.new("UICorner",text)
    corner.CornerRadius=UDim.new(0,8)

    local stroke=Instance.new("UIStroke",text)
    stroke.Color=gold
    stroke.Thickness=1.5
end

local function setup(p)

    p:GetAttributeChangedSignal(
        "Premium_VIP"):Connect(function()
        refresh(p)
    end)

    p.CharacterAdded:Connect(function(char)

        char:WaitForChild("Head",10)
        char:WaitForChild("HumanoidRootPart",10)

        if p.Character==char then
            refresh(p)
        end
    end)

    if p.Character then
        task.defer(refresh,p)
    end
end

Players.PlayerAdded:Connect(setup)

for _,p in ipairs(Players:GetPlayers()) do
    setup(p)
end

print("CYFR VIP EFFECTS LOADED!")
