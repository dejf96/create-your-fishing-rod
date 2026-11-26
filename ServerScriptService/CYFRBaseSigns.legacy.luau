local Players = game:GetService("Players")

for _,base in ipairs(workspace.CYFRWorld.Bases:GetChildren()) do
    local sign = base.Sign
    local gui = sign.BillboardGui
    local label = gui.TextLabel

    gui.Size = UDim2.fromOffset(180,90)
    gui.StudsOffset = Vector3.new(0,4,0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 65

    label.Position = UDim2.fromScale(0,.65)
    label.Size = UDim2.fromScale(1,.35)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBlack
    label.TextScaled = true
    label.TextStrokeTransparency = 0

    local avatar = Instance.new("ImageLabel",gui)
    avatar.Name = "OwnerAvatar"
    avatar.Size = UDim2.fromOffset(52,52)
    avatar.AnchorPoint = Vector2.new(.5,0)
    avatar.Position = UDim2.fromScale(.5,0)
    avatar.BackgroundColor3 = Color3.fromRGB(30,40,55)

    Instance.new("UICorner",avatar).CornerRadius =
        UDim.new(1,0)

    local stroke = Instance.new("UIStroke",avatar)
    stroke.Color = Color3.fromRGB(255,210,65)
    stroke.Thickness = 3

    local function update()
        local id = base:GetAttribute("Owner")
        local owner = id and Players:GetPlayerByUserId(id)

        avatar.Visible = owner ~= nil

        if owner then
            label.Text = owner.DisplayName.."'s Base"
            label.TextColor3 = Color3.fromRGB(255,215,65)

            local ok,img = pcall(function()
                return Players:GetUserThumbnailAsync(
                    id,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size150x150
                )
            end)

            if ok and base:GetAttribute("Owner") == id then
                avatar.Image = img
            end
        else
            label.Text = "FREE BASE"
            label.TextColor3 = Color3.fromRGB(80,255,120)
        end
    end

    base:GetAttributeChangedSignal("Owner"):Connect(function()
        task.defer(update)
    end)

    task.spawn(update)
end
