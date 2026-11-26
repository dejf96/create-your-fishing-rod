local Players=game:GetService("Players")
local DSS=game:GetService("DataStoreService")
local RunService=game:GetService("RunService")

local board=workspace.CYFRWorld
    .RebirthLeaderboard.Board

local bg=board.RankingGUI.Background

local studio=RunService:IsStudio()
local rgb=Color3.fromRGB

local categories={
    {
        title="TOP CASH",
        attribute="RankCash",
        store="CYFR_GlobalCash_v1",
        color=rgb(65,235,135)
    },
    {
        title="TOP REBIRTHS",
        attribute="RankRebirths",
        store="CYFR_GlobalRebirths_v1",
        color=rgb(185,100,255)
    },
    {
        title="TOP INCOME",
        attribute="RankIncome",
        store="CYFR_GlobalIncome_v1",
        color=rgb(65,165,255)
    },
    {
        title="TOP MATERIALS",
        attribute="RankMaterials",
        store="CYFR_GlobalMaterials_v1",
        color=rgb(255,205,65)
    }
}

local stores={}
local cache={}
local saved={}
local saving={}

local names={}
local avatars={}
local pending={}

local maxValue=9007199254740991

if not studio then
    for i,cfg in ipairs(categories) do
        stores[i]=DSS:GetOrderedDataStore(
            cfg.store)
    end
end

-- FORMATOWANIE LICZB

local function compact(n)

    local units={
        {1e15,"Qa"},
        {1e12,"T"},
        {1e9,"B"},
        {1e6,"M"},
        {1e3,"K"}
    }

    for _,unit in ipairs(units) do
        if n>=unit[1] then
            return string.format(
                "%.2f%s",
                n/unit[1],unit[2])
        end
    end

    return tostring(n)
end

local function formatValue(index,value)

    if index==1 then
        return "$"..compact(value)

    elseif index==3 then
        return "$"..compact(value/100).."/s"
    end

    return compact(value)
end

-- NAZWY I AVATARY

local function requestProfile(id)

    if id<=0 or pending[id] then return end

    if names[id] and avatars[id] then
        return
    end

    pending[id]=true

    task.spawn(function()

        if not names[id] then

            local ok,name=pcall(function()
                return Players:
                    GetNameFromUserIdAsync(id)
            end)

            if ok then
                names[id]=name
            end
        end

        if not avatars[id] then

            local ok,image,ready=pcall(function()
                return Players:GetUserThumbnailAsync(
                    id,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size100x100
                )
            end)

            if ok and ready then
                avatars[id]=image
            end
        end

        pending[id]=nil
    end)
end

-- ZAPIS GLOBALNYCH STATYSTYK

local function savePlayer(p)

    if studio then return end

    if p.UserId<=0
        or not p:GetAttribute("RankingReady") then
        return
    end

    local id=p.UserId

    if saving[id] then return end

    saving[id]=true
    saved[id]=saved[id] or {}

    for i,cfg in ipairs(categories) do

        local value=p:GetAttribute(cfg.attribute)

        if type(value)=="number"
            and value==value then

            value=math.clamp(
                math.floor(value),0,maxValue)

            if saved[id][i]~=value then

                local ok,err=pcall(function()
                    stores[i]:SetAsync(
                        tostring(id),value)
                end)

                if ok then
                    saved[id][i]=value
                else
                    warn("[CYFR GLOBAL]",err)
                end
            end
        end
    end

    saving[id]=nil
end

-- ODCZYT TOP 10

local function refreshGlobal(index)

    local ok,pages=pcall(function()
        return stores[index]:
            GetSortedAsync(false,10)
    end)

    if not ok then
        warn("[CYFR GLOBAL] Read failed",pages)
        return
    end

    local entries={}

    for _,entry in ipairs(
        pages:GetCurrentPage()) do

        local id=tonumber(entry.key)

        if id then
            table.insert(entries,{
                id=id,
                value=entry.value
            })

            requestProfile(id)
        end
    end

    cache[index]=entries
end

-- PODGLAD LOKALNY W STUDIO

local function localRanking(index)

    local entries={}
    local cfg=categories[index]

    for _,p in ipairs(Players:GetPlayers()) do

        local value=p:GetAttribute(
            cfg.attribute)

        if type(value)=="number" then

            names[p.UserId]=p.Name

            table.insert(entries,{
                id=p.UserId,
                value=value
            })

            requestProfile(p.UserId)
        end
    end

    table.sort(entries,function(a,b)
        if a.value==b.value then
            return a.id<b.id
        end

        return a.value>b.value
    end)

    return entries
end

-- WYSWIETLANIE TABLICY

local function display(index)

    local model=workspace.CYFRWorld
        .LeaderboardCave.GlobalBoards[
            ({"Cash","Rebirths","Income","Materials"})[index]
        ]

    local board=model.Board
    local bg=board.RankingGUI.Background

    local cfg=categories[index]

    bg.Header.Title.Text=cfg.title
    bg.Header.Title.TextColor3=cfg.color

    bg.Header.Subtitle.Text=studio
        and "TOP 10 - STUDIO PREVIEW"
        or "TOP 10 - GLOBAL RANKING"

    bg.RebirthHeader.Text="VALUE"

    local entries=studio
        and localRanking(index)
        or cache[index] or {}

    for i=1,10 do

        local row=bg["Row"..i]
        local entry=entries[i]

        row.Amount.TextColor3=cfg.color

        if entry then

            row.Username.Text=
                names[entry.id]
                or "User "..entry.id

            row.Avatar.Image=
                avatars[entry.id] or ""

            row.Amount.Text=
                formatValue(index,entry.value)

            requestProfile(entry.id)

        else

            row.Username.Text="---"
            row.Avatar.Image=""
            row.Amount.Text="-"
        end
    end

    for _,part in ipairs(
        board.Parent:GetChildren()) do

        if part.Name=="NeonEdge"
            or part.Name=="SupportLight" then

            part.Color=cfg.color
        end
    end

    local light=board:FindFirstChildOfClass(
        "PointLight")

    if light then
        light.Color=cfg.color
    end
end

-- CYKLICZNY ZAPIS I ODSWIEZANIE

if not studio then

    task.spawn(function()

        while true do

            for _,p in ipairs(
                Players:GetPlayers()) do

                savePlayer(p)
                task.wait(.5)
            end

            for i=1,#categories do
                refreshGlobal(i)
                task.wait(1)
            end

            task.wait(120)
        end
    end)

    Players.PlayerRemoving:Connect(function(p)
        savePlayer(p)
    end)
end


-- CZTERY RANKINGI JEDNOCZESNIE

while true do

    for index=1,4 do

        display(index)

        local name=({
            "Cash","Rebirths",
            "Income","Materials"
        })[index]

        local bg=workspace.CYFRWorld
            .LeaderboardCave.GlobalBoards[name]
            .Board.RankingGUI.Background

        bg.Footer.Text="GLOBAL LEADERBOARD"
    end

    task.wait(5)
end
