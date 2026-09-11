--[[
================================================================================
  👑 KING AKBAR - CAR DRIVING INDONESIA
  MODERN DASHBOARD + DELIVERY ASSISTANT + WEBHOOK INTEGRATION
  VERSION: PROFESSIONAL EDITION
================================================================================
--]]

-- ============================================================================
-- // 0. LOAD WINDUI (SAFE)
-- ============================================================================
local WindUI
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(
            "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
        ))()
    end)
    if ok and result then
        WindUI = result
    else
        warn("[King Akbar] WindUI failed to load: " .. tostring(result))
        return
    end
end

-- ============================================================================
-- // 0.5 CORE PAUSE BYPASS
-- ============================================================================
pcall(function()
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("RobloxGui") then
        local pauseScript = CoreGui.RobloxGui:FindFirstChild("CoreScripts/NetworkPause")
        if pauseScript then pauseScript:Destroy() end
    end
end)

-- ============================================================================
-- // 1. SERVICES
-- ============================================================================
local Services = {
    Players           = game:GetService("Players"),
    RunService        = game:GetService("RunService"),
    UserInput         = game:GetService("UserInputService"),
    Stats             = game:GetService("Stats"),
    TweenSvc          = game:GetService("TweenService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    VirtualInput      = game:GetService("VirtualInputManager"),
    CoreGui           = game:GetService("CoreGui"),
    HttpService       = game:GetService("HttpService"),
    StarterGui        = game:GetService("StarterGui"),
}

local LocalPlayer = Services.Players.LocalPlayer

local IsMobile = Services.UserInput.TouchEnabled
    and not Services.UserInput.KeyboardEnabled
    and not Services.UserInput.MouseEnabled

-- ============================================================================
-- // 1.5 GLOBAL STATS
-- ============================================================================
local Stats = {
    moneyBefore = 0,
    moneyNow    = 0,
    deliveries  = 0,
    farmTime    = 0,
    startTime   = os.time(),
}

-- ============================================================================
-- // 2. SPLASH SCREEN
-- ============================================================================
do
    local sg = Instance.new("ScreenGui")
    sg.Name = "KingAkbarSplash"; sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true; sg.DisplayOrder = 999
    sg.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local bg = Instance.new("Frame", sg)
    bg.Size = UDim2.fromScale(1,1); bg.BackgroundColor3 = Color3.fromHex("#0a0a0a")
    bg.BorderSizePixel = 0; bg.ZIndex = 1

    local grad = Instance.new("UIGradient", bg)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("#0a0a0a")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("#1e1e1e")),
    }); grad.Rotation = 135

    local ct = Instance.new("Frame", bg)
    ct.Size = UDim2.fromOffset(500, 300); ct.Position = UDim2.fromScale(0.5, 0.5)
    ct.AnchorPoint = Vector2.new(0.5, 0.5); ct.BackgroundTransparency = 1; ct.ZIndex = 2

    local function mkLabel(txt, yOff, sz)
        local l = Instance.new("TextLabel", ct)
        l.Size = UDim2.fromOffset(500, 70); l.Position = UDim2.fromOffset(0, yOff)
        l.BackgroundTransparency = 1; l.Text = txt; l.TextSize = sz
        l.Font = Enum.Font.GothamBold; l.TextColor3 = Color3.fromHex("#ffffff")
        l.TextTransparency = 1; l.ZIndex = 3; return l
    end

    local icon = Instance.new("ImageLabel", ct)
    icon.Size = UDim2.fromOffset(120, 120); icon.Position = UDim2.fromOffset(190, -40)
    icon.BackgroundTransparency = 1; icon.Image = "rbxassetid://91115084979317"
    icon.ImageTransparency = 1; icon.ZIndex = 3

    local title = mkLabel("King Akbar", 70, IsMobile and 38 or 50)
    local tg = Instance.new("UIGradient", title)
    tg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromHex("#ffffff")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("#aaaaaa")),
        ColorSequenceKeypoint.new(1,   Color3.fromHex("#555555")),
    }); tg.Rotation = 45

    local stat = mkLabel("Initializing system...", 200, 12)
    stat.Font = Enum.Font.Gotham; stat.TextColor3 = Color3.fromHex("#555555")
    stat.TextXAlignment = Enum.TextXAlignment.Left; stat.Position = UDim2.fromOffset(50, 200)

    local line = Instance.new("Frame", ct)
    line.Size = UDim2.fromOffset(0, 2); line.Position = UDim2.fromOffset(250, 152)
    line.AnchorPoint = Vector2.new(0.5, 0); line.BackgroundColor3 = Color3.fromHex("#444444")
    line.BorderSizePixel = 0; line.ZIndex = 3

    local barBg = Instance.new("Frame", ct)
    barBg.Size = UDim2.fromOffset(400, 5); barBg.Position = UDim2.fromOffset(50, 190)
    barBg.BackgroundColor3 = Color3.fromHex("#222222"); barBg.BackgroundTransparency = 1
    barBg.BorderSizePixel = 0; barBg.ZIndex = 3
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local bar = Instance.new("Frame", barBg)
    bar.Size = UDim2.fromOffset(0, 5); bar.BackgroundColor3 = Color3.fromHex("#ffffff")
    bar.BorderSizePixel = 0; bar.ZIndex = 4
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local function tw(obj, props, t)
        Services.TweenSvc:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
    end

    task.spawn(function()
        tw(icon,  { ImageTransparency = 0 }, 0.5); task.wait(0.15)
        tw(title, { TextTransparency  = 0 }, 0.6); task.wait(0.35)
        tw(line,  { Size = UDim2.fromOffset(400, 2) }, 0.7); task.wait(0.4)
        tw(barBg, { BackgroundTransparency = 0 }, 0.3)
        tw(stat,  { TextTransparency = 0 }, 0.3)
        for _, s in ipairs({
            { "Loading UI Library...",     0.30 },
            { "Verifying License...",      0.60 },
            { "Welcome, King Akbar!",      1.00 },
        }) do
            stat.Text = s[1]
            tw(bar, { Size = UDim2.fromOffset(400 * s[2], 5) }, 0.5)
            task.wait(0.55)
        end
        task.wait(0.3)
        for _, p in ipairs({ bg, icon, title, line, barBg, bar, stat }) do
            local prop = p == stat and "TextTransparency"
                or (p == icon  and "ImageTransparency" or "BackgroundTransparency")
            if p == title then prop = "TextTransparency" end
            tw(p, { [prop] = 1 }, 0.4)
        end
        task.wait(0.8); sg:Destroy()
    end)
    task.wait(3)
end

-- ============================================================================
-- // 3. CREATE WINDOW
-- ============================================================================
local wSz  = IsMobile and UDim2.fromOffset(420, 320) or UDim2.fromOffset(580, 460)
local mnSz = IsMobile and Vector2.new(600, 300) or Vector2.new(600, 350)
local mxSz = IsMobile and Vector2.new(650, 400) or Vector2.new(850, 560)

local Window = WindUI:CreateWindow({
    Title                       = "King Akbar - Car Driving Indonesia",
    Icon                        = "crown",
    Author                      = "King Akbar",
    Folder                      = "KingAkbarHub",
    Size                        = wSz,
    MinSize                     = mnSz,
    MaxSize                     = mxSz,
    Transparent                 = false,
    Background                  = "rbxassetid://127295801178451",
    BackgroundImageTransparency = 0.5,
    Theme                       = "Dark",
    Resizable                   = true,
    SideBarWidth                = 210,
    HideSearchBar               = false,
    ScrollBarEnabled            = true,
})

-- ============================================================================
-- // 4. TABS
-- ============================================================================
local InfoTab    = Window:Tab({ Title = "Info",    Icon = "info",    Border = true })
local FarmTab    = Window:Tab({ Title = "Farm",    Icon = "truck",   Border = true })
local WebhookTab = Window:Tab({ Title = "Webhook", Icon = "webhook", Border = true })

-- ============================================================================
-- // 5. INFO TAB
-- ============================================================================
local memberCount = "N/A"
local onlineCount = "N/A"

local function fetchDiscordInfo()
    local req = request or http_request or (syn and syn.request)
    if not req then return end
    local ok, res = pcall(function()
        return req({
            Url     = "https://discord.com/api/v9/invites/XmWf3YQPpZ?with_counts=true",
            Method  = "GET",
            Headers = { ["User-Agent"] = "Mozilla/5.0" }
        })
    end)
    if ok and res and res.StatusCode == 200 then
        local ok2, data = pcall(function() return Services.HttpService:JSONDecode(res.Body) end)
        if ok2 and data then
            memberCount = tostring(data.approximate_member_count   or "N/A")
            onlineCount = tostring(data.approximate_presence_count or "N/A")
        end
    end
end
fetchDiscordInfo()

local ServerInfo = InfoTab:Paragraph({
    Title         = "King Vypers | Official",
    Desc          = "• Member Count: " .. memberCount .. "\n• Online Count: " .. onlineCount,
    Image         = "rbxassetid://107726435417936",
    Thumbnail     = "rbxassetid://83197533072664",
    ThumbnailSize = 80,
    Buttons = {
        {
            Title    = "Copy Discord Invite",
            Color    = Color3.fromHex("#5707AB"),
            Icon     = "link",
            Callback = function()
                if setclipboard then setclipboard("https://discord.gg/XmWf3YQPpZ") end
            end
        },
        {
            Title    = "Update Info",
            Icon     = "refresh-cw",
            Callback = function()
                fetchDiscordInfo()
                ServerInfo:SetDesc("• Member Count: " .. memberCount .. "\n• Online Count: " .. onlineCount)
            end
        }
    }
})

-- ============================================================================
-- // 6. FARM TAB
-- ============================================================================

-- ANTI AFK
local StayActiveEnabled = false
local disabledIdledConns = {}

local function startStayActive()
    if StayActiveEnabled then return end
    StayActiveEnabled = true
    if getconnections and type(getconnections) == "function" then
        pcall(function()
            for _, c in ipairs(getconnections(LocalPlayer.Idled)) do
                if c then
                    if c.Disable then pcall(c.Disable, c) end
                    if c.DisableConnection then pcall(c.DisableConnection, c) end
                    table.insert(disabledIdledConns, c)
                end
            end
        end)
    end
    if #disabledIdledConns == 0 then
        local VirtualUser = game:GetService("VirtualUser")
        task.spawn(function()
            while StayActiveEnabled do
                task.wait(math.random() * 50 + 40)
                if not StayActiveEnabled then break end
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(), workspace.CurrentCamera.CFrame)
                end)
            end
        end)
    end
end
startStayActive()

-- ══════════════════════════════════════════════════════════════════════════
-- DELIVERY CONFIGURATION
-- ══════════════════════════════════════════════════════════════════════════
local farmConfig = {
    jobNPC          = Vector3.new(24034.58,  387.33,  33760.82),
    startJob        = Vector3.new(34938.02,  135.13, -54577.94),
    truckSpawn      = Vector3.new(35167.01,  134.51, -54683.35),
    ascentHeight    = 2000,
    routeDuration   = 45,
    deliveryTimeout = 10,
    autoStart       = true,
}

local autoFarmRunning = false
local hookConn, currentDelivery, deliveryUpdated

-- JOB EVENT LISTENER
local function startJobHook()
    local ev = Services.ReplicatedStorage:WaitForChild("NetworkContainer", 10)
    if not ev then return end
    ev = ev:WaitForChild("RemoteEvents", 10)
    if not ev then return end
    ev = ev:WaitForChild("Job", 10)
    if not ev then return end

    if hookConn then hookConn:Disconnect() end
    hookConn = ev.OnClientEvent:Connect(function(action, location)
        if action == "SetArrow" and typeof(location) == "Vector3" then
            currentDelivery = location
            deliveryUpdated = true
        end
    end)
end
task.spawn(startJobHook)

-- HELPER FUNCTIONS
local function notify(title, text)
    pcall(function()
        Services.StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = 3
        })
    end)
end

local function teleportChar(targetVec3)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(targetVec3)
end

local function getVehicle()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return nil end
    return hum.SeatPart:FindFirstAncestorOfClass("Model")
end

local function holdKey(keyCode, duration)
    Services.VirtualInput:SendKeyEvent(true,  keyCode, false, game)
    task.wait(duration)
    Services.VirtualInput:SendKeyEvent(false, keyCode, false, game)
end

local function clickUI(element)
    if not element then return false end
    local pos = element.AbsolutePosition + (element.AbsoluteSize / 2)
    if pos.X <= 0 or pos.Y <= 0 then return false end
    for _ = 1, 3 do
        Services.VirtualInput:SendMouseButtonEvent(pos.X, pos.Y, 0, true,  game, 0)
        task.wait(0.05)
        Services.VirtualInput:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
        task.wait(0.1)
    end
    return true
end

-- MONEY HELPERS
local function parseMoney(text)
    if not text then return 0 end
    local clean = text:gsub("[^%d]", "")
    return tonumber(clean) or 0
end

local function getMoney()
    local ok, val = pcall(function()
        return LocalPlayer.PlayerGui.Main.Container.Hub.CashFrame.Frame.TextLabel.Text
    end)
    if ok and val then return parseMoney(val) end
    return 0
end

local function formatMoney(n)
    local s = tostring(math.floor(math.abs(n)))
    local result = ""
    local count  = 0
    for i = #s, 1, -1 do
        count  = count + 1
        result = s:sub(i, i) .. result
        if count % 3 == 0 and i ~= 1 then result = "," .. result end
    end
    return "Rp. " .. result
end

local function formatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    if h > 0 then return string.format("%02d:%02d:%02d", h, m, s) end
    return string.format("%02d:%02d", m, s)
end

-- ═══════════════════════════════════════════════════════════════
--  DELIVERY EXECUTION ENGINE
-- ═══════════════════════════════════════════════════════════════
local function executeDeliveryRoute(vehicle, target)
    if not vehicle then return end
    local main = vehicle.PrimaryPart
    if not main then return end

    local parts, anchored = {}, {}
    for _, p in ipairs(vehicle:GetDescendants()) do
        if p:IsA("BasePart") then
            parts[#parts + 1] = p
            anchored[p] = p.Anchored
            p.Anchored = true
        end
        if p:IsA("VehicleSeat") then
            p.ThrottleFloat = 0
            p.SteerFloat = 0
        end
    end

    local _, yRot = main.CFrame:ToEulerAnglesYXZ()
    local mainCF = main.CFrame
    local offsets = {}
    for _, p in ipairs(parts) do
        if p ~= main then
            offsets[p] = mainCF:ToObjectSpace(p.CFrame)
        end
    end

    local start = target + Vector3.new(0, farmConfig.ascentHeight, 0)
    main.CFrame = CFrame.new(start) * CFrame.fromEulerAnglesYXZ(0, yRot, 0)
    for _, p in ipairs(parts) do
        if p ~= main and offsets[p] then
            p.CFrame = main.CFrame:ToWorldSpace(offsets[p])
        end
    end

    local tween = Services.TweenSvc:Create(
        main,
        TweenInfo.new(farmConfig.routeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { CFrame = CFrame.new(target) * CFrame.fromEulerAnglesYXZ(0, yRot, 0) }
    )

    local conn = Services.RunService.Heartbeat:Connect(function()
        for _, p in ipairs(parts) do
            if p ~= main and offsets[p] then
                p.CFrame = main.CFrame:ToWorldSpace(offsets[p])
            end
        end
    end)

    tween:Play()
    tween.Completed:Wait()
    conn:Disconnect()

    for _, p in ipairs(parts) do
        p.Anchored = anchored[p]
        pcall(function()
            p.AssemblyLinearVelocity  = Vector3.zero
            p.AssemblyAngularVelocity = Vector3.zero
        end)
    end
end

-- ============================================================================
-- // DELIVERY TRACKING
-- ============================================================================
local delivHistory    = {0,0,0,0,0,0,0,0,0}
local lastDelivMoney  = 0
local updateDelivBars

-- ============================================================================
-- // MONEY TRACKER OVERLAY — MINIMALIST DASHBOARD
-- ============================================================================
local C = {
    BG         = Color3.fromHex("#0A0C10"),
    PANEL      = Color3.fromHex("#12161F"),
    CARD       = Color3.fromHex("#181E29"),
    CARD2      = Color3.fromHex("#1F2633"),
    TEXT_MAIN  = Color3.fromHex("#F3F4F6"),
    TEXT_SUB   = Color3.fromHex("#9CA3AF"),
    TEXT_DIM   = Color3.fromHex("#4B5563"),
    BORDER     = Color3.fromHex("#2A303C"),
    GREEN      = Color3.fromHex("#10B981"),
    BLUE       = Color3.fromHex("#3B82F6"),
    RED        = Color3.fromHex("#EF4444"),
}

local moneyTrackerGui = Instance.new("ScreenGui")
moneyTrackerGui.Name           = "MoneyTrackerUI"
moneyTrackerGui.ResetOnSpawn   = false
moneyTrackerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
moneyTrackerGui.IgnoreGuiInset = true
moneyTrackerGui.Parent         = Services.CoreGui
moneyTrackerGui.Enabled        = false

local root = Instance.new("Frame", moneyTrackerGui)
root.Size = UDim2.new(1,0,1,0); root.BorderSizePixel = 0
root.BackgroundColor3 = C.BG; root.Active = true

local MT_wrap = Instance.new("Frame", root)
MT_wrap.Size = UDim2.new(0,960,0,540)
MT_wrap.AnchorPoint = Vector2.new(0.5,0.5)
MT_wrap.Position = UDim2.new(0.5,0,0.5,22)
MT_wrap.BackgroundTransparency = 1

local MT_scale = Instance.new("UIScale", MT_wrap)
local MT_cam   = workspace.CurrentCamera
local function MT_doScale()
    local vp = MT_cam.ViewportSize
    MT_scale.Scale = math.clamp(math.min((vp.X*0.92)/960,(vp.Y*0.90)/540), 0.36, 1.05)
end
MT_doScale()
MT_cam:GetPropertyChangedSignal("ViewportSize"):Connect(MT_doScale)

local function cr(p, r)
    Instance.new("UICorner", p).CornerRadius = UDim.new(0, r or 10)
end
local function mkStroke(p, col, th, tr)
    local s = Instance.new("UIStroke", p)
    s.Color = col; s.Thickness = th or 1; s.Transparency = tr or 0.8
    return s
end
local function mkFr(parent, props)
    local f = Instance.new("Frame", parent); f.BorderSizePixel = 0
    for k,v in pairs(props) do f[k] = v end; return f
end
local function mkLb(parent, props)
    local l = Instance.new("TextLabel", parent); l.BackgroundTransparency = 1
    for k,v in pairs(props) do l[k] = v end; return l
end

-- HEADER
local header = mkFr(MT_wrap, {
    Size=UDim2.new(1,0,0,44), BackgroundColor3=C.PANEL
}); cr(header, 10); mkStroke(header, C.BORDER, 1)

mkFr(header, {
    Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,0,0),
    BackgroundColor3=C.BLUE
}); cr(mkFr(header,{}), 2)

mkLb(header, {
    Size=UDim2.new(0,340,1,0), Position=UDim2.new(0,16,0,0),
    Text="KING AKBAR  |  CAR DRIVING INDONESIA",
    TextColor3=C.TEXT_MAIN, Font=Enum.Font.GothamBold, TextSize=13,
    TextXAlignment=Enum.TextXAlignment.Left,
})

local pillFr = mkFr(header, {
    Size=UDim2.new(0,140,0,26), Position=UDim2.new(0.5,-70,0.5,-13),
    BackgroundColor3=C.CARD,
}); cr(pillFr,13); mkStroke(pillFr, C.BORDER, 1)

local pillDot = mkFr(pillFr, {
    Size=UDim2.new(0,7,0,7), Position=UDim2.new(0,13,0.5,-3.5),
    BackgroundColor3=C.GREEN,
}); Instance.new("UICorner",pillDot).CornerRadius=UDim.new(1,0)

mkLb(pillFr, {
    Size=UDim2.new(1,-28,1,0), Position=UDim2.new(0,28,0,0),
    Text="SYSTEM ONLINE", TextColor3=C.GREEN,
    Font=Enum.Font.GothamBold, TextSize=11,
    TextXAlignment=Enum.TextXAlignment.Left,
})

local MT_LiveStats = mkLb(header, {
    Size=UDim2.new(0,210,1,0), Position=UDim2.new(1,-226,0,0),
    Text="PING ??  ·  FPS ??", TextColor3=C.TEXT_SUB,
    Font=Enum.Font.GothamBold, TextSize=12,
    TextXAlignment=Enum.TextXAlignment.Right,
})

-- CONTENT
local LW, RW, CY, CH = 592, 358, 52, 452

local leftPanel  = mkFr(MT_wrap, {Size=UDim2.new(0,LW,0,CH), Position=UDim2.new(0,0,0,CY), BackgroundTransparency=1})
local rightPanel = mkFr(MT_wrap, {Size=UDim2.new(0,RW,0,CH), Position=UDim2.new(0,LW+10,0,CY), BackgroundTransparency=1})

-- HERO BALANCE
local heroCard = mkFr(leftPanel, {
    Size=UDim2.new(1,0,0,180), BackgroundColor3=C.CARD,
}); cr(heroCard,14); mkStroke(heroCard, C.BORDER, 1)

mkLb(heroCard, {
    Size=UDim2.new(1,-30,0,18), Position=UDim2.new(0,22,0,20),
    Text="CURRENT BALANCE",
    TextColor3=C.TEXT_SUB, Font=Enum.Font.GothamMedium, TextSize=11,
    TextXAlignment=Enum.TextXAlignment.Left,
})

local MT_balanceMain = mkLb(heroCard, {
    Size=UDim2.new(1,-30,0,66), Position=UDim2.new(0,20,0,42),
    Text="Rp. 0", TextColor3=C.TEXT_MAIN,
    Font=Enum.Font.GothamBlack, TextSize=52,
    TextXAlignment=Enum.TextXAlignment.Left,
})

local progTrack = mkFr(heroCard, {
    Size=UDim2.new(1,-44,0,4), Position=UDim2.new(0,22,0,130),
    BackgroundColor3=C.TEXT_DIM,
}); cr(progTrack, 2)

local progFill = mkFr(progTrack, {
    Size=UDim2.new(0,0,1,0), BackgroundColor3=C.GREEN,
}); cr(progFill, 2)

local MT_progLabel = mkLb(heroCard, {
    Size=UDim2.new(1,-44,0,20), Position=UDim2.new(0,22,0,145),
    Text="SESSION GAIN: Rp. 0  —  TARGET Rp. 5.000.000",
    TextColor3=C.TEXT_SUB, Font=Enum.Font.GothamMedium, TextSize=11,
    TextXAlignment=Enum.TextXAlignment.Left,
})

-- ROW 2: MAIN CARDS
local R2W = (LW - 10) / 2

local function mkMainCard(xOff, col, title)
    local card = mkFr(leftPanel, {
        Size=UDim2.new(0,R2W,0,110), Position=UDim2.new(0,xOff,0,190),
        BackgroundColor3=C.CARD,
    }); cr(card,12); mkStroke(card, C.BORDER, 1)
    mkLb(card, {
        Size=UDim2.new(1,-22,0,18), Position=UDim2.new(0,20,0,16),
        Text=title, TextColor3=C.TEXT_SUB,
        Font=Enum.Font.GothamMedium, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,
    })
    local val = mkLb(card, {
        Size=UDim2.new(1,-22,0,46), Position=UDim2.new(0,20,0,54),
        Text="Rp. 0", TextColor3=col,
        Font=Enum.Font.GothamBold, TextSize=22,
        TextXAlignment=Enum.TextXAlignment.Left,
    })
    return val
end

local MT_valProfit  = mkMainCard(0,          C.GREEN, "TOTAL PROFIT")
local MT_valPerHour = mkMainCard(R2W+10,     C.GREEN, "INCOME / HOUR")

-- ROW 3: MINI CARDS
local R3W = (LW - 20) / 3

local function mkMiniCard(xOff, col, title)
    local card = mkFr(leftPanel, {
        Size=UDim2.new(0,R3W,0,70), Position=UDim2.new(0,xOff,0,310),
        BackgroundColor3=C.CARD2,
    }); cr(card,10); mkStroke(card, C.BORDER, 1)
    mkLb(card, {
        Size=UDim2.new(1,-14,0,18), Position=UDim2.new(0,16,0,8),
        Text=title, TextColor3=C.TEXT_SUB,
        Font=Enum.Font.GothamMedium, TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left,
    })
    local val = mkLb(card, {
        Size=UDim2.new(1,-14,0,32), Position=UDim2.new(0,16,0,34),
        Text="—", TextColor3=col,
        Font=Enum.Font.GothamBold, TextSize=15,
        TextXAlignment=Enum.TextXAlignment.Left,
    })
    return val
end

local MT_valPerDeliv   = mkMiniCard(0,                  C.TEXT_MAIN, "PER DELIVERY")
local MT_valDelPerHour = mkMiniCard(R3W+10,             C.TEXT_MAIN, "DEL / HOUR")
local MT_valInitial    = mkMiniCard((R3W+10)*2,         C.TEXT_MAIN, "START BALANCE")

-- ROW 4: INFO STRIP
local infoStrip = mkFr(leftPanel, {
    Size=UDim2.new(1,0,0,62), Position=UDim2.new(0,0,0,390),
    BackgroundColor3=C.PANEL,
}); cr(infoStrip,12); mkStroke(infoStrip, C.BORDER, 1)

mkLb(infoStrip, {
    Size=UDim2.new(0.6,-14,1,0), Position=UDim2.new(0,18,0,0),
    Text="Delivery System  ·  Car Driving Indonesia",
    TextColor3=C.TEXT_SUB, Font=Enum.Font.GothamMedium, TextSize=10,
    TextXAlignment=Enum.TextXAlignment.Left,
})
mkLb(infoStrip, {
    Size=UDim2.new(0.4,-14,1,0), Position=UDim2.new(0.6,0,0,0),
    Text="KING AKBAR HUB",
    TextColor3=C.TEXT_DIM, Font=Enum.Font.GothamMedium, TextSize=9,
    TextXAlignment=Enum.TextXAlignment.Right,
})

-- RIGHT PANEL: DELIVERIES
local delivCard = mkFr(rightPanel, {
    Size=UDim2.new(1,0,0,160), BackgroundColor3=C.CARD,
}); cr(delivCard,14); mkStroke(delivCard, C.BORDER, 1)

mkLb(delivCard, {
    Size=UDim2.new(1,-18,0,18), Position=UDim2.new(0,18,0,16),
    Text="DELIVERIES COMPLETED", TextColor3=C.TEXT_SUB,
    Font=Enum.Font.GothamBold, TextSize=10,
    TextXAlignment=Enum.TextXAlignment.Left,
})

local MT_delivCount = mkLb(delivCard, {
    Size=UDim2.new(0,120,0,60), Position=UDim2.new(0,18,0,40),
    Text="0", TextColor3=C.TEXT_MAIN,
    Font=Enum.Font.GothamBlack, TextSize=56,
    TextXAlignment=Enum.TextXAlignment.Left,
})

local chartFr = mkFr(delivCard, {
    Size=UDim2.new(0,176,0,55), Position=UDim2.new(1,-194,0,48),
    BackgroundTransparency=1, ClipsDescendants=true,
})

local delivBars = {}
for i = 1, 9 do
    local b = mkFr(chartFr, {
        Size=UDim2.new(0,14,0,4),
        Position=UDim2.new(0,(i-1)*20,1,-4),
        BackgroundColor3=C.TEXT_DIM,
    }); cr(b,4); 
    table.insert(delivBars, b)
end

mkFr(delivCard, {
    Size=UDim2.new(0,176,0,1), Position=UDim2.new(1,-194,0,104),
    BackgroundColor3=C.BORDER,
})

mkLb(delivCard, {
    Size=UDim2.new(1,-20,0,14), Position=UDim2.new(0,18,1,-22),
    Text="DELIVERY HISTORY",
    TextColor3=C.TEXT_DIM, Font=Enum.Font.Gotham, TextSize=8,
    TextXAlignment=Enum.TextXAlignment.Left,
})

updateDelivBars = function()
    local maxVal = 0
    for _, v in ipairs(delivHistory) do if v > maxVal then maxVal = v end end
    if maxVal == 0 then maxVal = 1 end
    for i, bar in ipairs(delivBars) do
        local pct = delivHistory[i] / maxVal
        local h   = math.max(4, math.floor(pct * 50))
        Services.TweenSvc:Create(bar, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0,14,0,h),
            BackgroundColor3 = pct > 0 and C.GREEN or C.TEXT_DIM,
        }):Play()
    end
end

-- SESSION TIME
local uptimeCard = mkFr(rightPanel, {
    Size=UDim2.new(1,0,0,90), Position=UDim2.new(0,0,0,170),
    BackgroundColor3=C.CARD,
}); cr(uptimeCard,12); mkStroke(uptimeCard, C.BORDER, 1)

mkLb(uptimeCard, {
    Size=UDim2.new(0.5,0,0,18), Position=UDim2.new(0,18,0,16),
    Text="SESSION TIME", TextColor3=C.TEXT_SUB,
    Font=Enum.Font.GothamBold, TextSize=10,
    TextXAlignment=Enum.TextXAlignment.Left,
})

local MT_uptimeVal = mkLb(uptimeCard, {
    Size=UDim2.new(0.5,0,0,38), Position=UDim2.new(0,18,0,40),
    Text="00:00", TextColor3=C.TEXT_MAIN,
    Font=Enum.Font.GothamBlack, TextSize=32,
    TextXAlignment=Enum.TextXAlignment.Left,
})

local elapsedTrack = mkFr(uptimeCard, {
    Size=UDim2.new(0.45,-10,0,4), Position=UDim2.new(0.55,0,0.5,8),
    BackgroundColor3=C.TEXT_DIM,
}); cr(elapsedTrack,2)
local elapsedFill = mkFr(elapsedTrack, {
    Size=UDim2.new(0,0,1,0), BackgroundColor3=C.TEXT_MAIN,
}); cr(elapsedFill,2)
mkLb(uptimeCard, {
    Size=UDim2.new(0.45,-10,0,18), Position=UDim2.new(0.55,0,0.5,-22),
    Text="MAX SESSION 2H", TextColor3=C.TEXT_DIM,
    Font=Enum.Font.GothamMedium, TextSize=9,
    TextXAlignment=Enum.TextXAlignment.Left,
})

-- NETWORK
local netCard = mkFr(rightPanel, {
    Size=UDim2.new(1,0,0,90), Position=UDim2.new(0,0,0,270),
    BackgroundColor3=C.CARD,
}); cr(netCard,12); mkStroke(netCard, C.BORDER, 1)

mkLb(netCard, {
    Size=UDim2.new(1,-18,0,18), Position=UDim2.new(0,18,0,12),
    Text="NETWORK STATUS", TextColor3=C.TEXT_SUB,
    Font=Enum.Font.GothamBold, TextSize=10,
    TextXAlignment=Enum.TextXAlignment.Left,
})

mkFr(netCard, {
    Size=UDim2.new(0,1,0.45,0), Position=UDim2.new(0.5,0,0.32,0),
    BackgroundColor3=C.BORDER,
})

local function mkNetStat(xPct, labelTxt)
    mkLb(netCard, {
        Size=UDim2.new(0.5,-20,0,18), Position=UDim2.new(xPct,18,0,36),
        Text=labelTxt, TextColor3=C.TEXT_DIM,
        Font=Enum.Font.GothamMedium, TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left,
    })
    return mkLb(netCard, {
        Size=UDim2.new(0.5,-20,0,32), Position=UDim2.new(xPct,18,0,54),
        Text="—", TextColor3=C.TEXT_MAIN,
        Font=Enum.Font.GothamBold, TextSize=22,
        TextXAlignment=Enum.TextXAlignment.Left,
    })
end

local MT_pingVal = mkNetStat(0,   "SERVER PING")
local MT_fpsVal  = mkNetStat(0.5, "CLIENT FPS")

-- STATUS BADGE
local statusCard = mkFr(rightPanel, {
    Size=UDim2.new(1,0,0,78), Position=UDim2.new(0,0,0,370),
    BackgroundColor3=C.CARD,
}); cr(statusCard,12); mkStroke(statusCard, C.BORDER, 1)

local MT_statusDot = mkFr(statusCard, {
    Size=UDim2.new(0,10,0,10), Position=UDim2.new(0,18,0.5,-5),
    BackgroundColor3=C.GREEN,
}); Instance.new("UICorner",MT_statusDot).CornerRadius=UDim.new(1,0)

mkLb(statusCard, {
    Size=UDim2.new(1,-50,0,22), Position=UDim2.new(0,36,0,18),
    Text="DELIVERY SYSTEM ACTIVE", TextColor3=C.TEXT_MAIN,
    Font=Enum.Font.GothamBold, TextSize=13,
    TextXAlignment=Enum.TextXAlignment.Left,
})
mkLb(statusCard, {
    Size=UDim2.new(1,-50,0,18), Position=UDim2.new(0,36,0,42),
    Text="CAR DRIVING INDONESIA  ·  SESSION ACTIVE",
    TextColor3=C.TEXT_SUB, Font=Enum.Font.GothamMedium, TextSize=9,
    TextXAlignment=Enum.TextXAlignment.Left,
})

-- SCAN LINE
local scanLine = mkFr(MT_wrap, {
    Size=UDim2.new(1,0,0,1), BackgroundColor3=C.TEXT_DIM,
    BackgroundTransparency=0.95, ZIndex=9,
})

task.spawn(function()
    local y = 0
    while true do
        task.wait(0.018)
        if moneyTrackerGui.Enabled then
            y = (y + 0.003) % 1.02
            scanLine.Position = UDim2.new(0,0,y,0)
        end
    end
end)

-- TICKER
local tickerFr = mkFr(MT_wrap, {
    Size=UDim2.new(1,0,0,28), Position=UDim2.new(0,0,1,-28),
    BackgroundColor3=C.PANEL, ClipsDescendants=true,
}); cr(tickerFr,8); mkStroke(tickerFr, C.BORDER, 1)

local tickerStr = "DELIVERY SYSTEM ACTIVE  ·  KING AKBAR  ·  CAR DRIVING INDONESIA  ·  TRUCK DELIVERY SYSTEM  ·  KING VYPERS  ·  SYSTEM ONLINE  ·  DELIVERY SYSTEM ACTIVE  ·  CAR DRIVING INDONESIA  ·  "

local tickerLb = mkLb(tickerFr, {
    Size=UDim2.new(3,0,1,0), Position=UDim2.new(0,0,0,0),
    Text=tickerStr, TextColor3=C.TEXT_DIM,
    Font=Enum.Font.GothamBold, TextSize=10,
    TextXAlignment=Enum.TextXAlignment.Left,
})

task.spawn(function()
    local p = 0
    while true do
        task.wait(0.018)
        if moneyTrackerGui.Enabled then
            p = p - 0.0003
            if p <= -1 then p = 0 end
            tickerLb.Position = UDim2.new(p,0,0,0)
        end
    end
end)

-- LOGIC & STATE
local bestDelivProfit = 0
local bestPerHour     = 0

local function resetMoneyTracker()
    Stats.moneyBefore    = getMoney()
    Stats.moneyNow       = Stats.moneyBefore
    Stats.deliveries     = 0
    Stats.farmTime       = 0
    Stats.startTime      = os.time()
    delivHistory         = {0,0,0,0,0,0,0,0,0}
    lastDelivMoney       = Stats.moneyBefore
    bestDelivProfit      = 0
    bestPerHour          = 0

    MT_balanceMain.Text  = formatMoney(Stats.moneyBefore)
    MT_valProfit.Text    = "Rp. 0"
    MT_valPerHour.Text   = "Rp. 0"
    MT_valInitial.Text   = formatMoney(Stats.moneyBefore)
    MT_valPerDeliv.Text  = "—"
    MT_valDelPerHour.Text= "0 / H"
    MT_delivCount.Text   = "0"
    MT_uptimeVal.Text    = "00:00"
    MT_progLabel.Text    = "SESSION GAIN: Rp. 0  —  TARGET Rp. 5.000.000"
    MT_progLabel.TextColor3 = C.TEXT_SUB
    Services.TweenSvc:Create(progFill,  TweenInfo.new(0.3), {Size=UDim2.new(0,0,1,0)}):Play()
    Services.TweenSvc:Create(elapsedFill, TweenInfo.new(0.3), {Size=UDim2.new(0,0,1,0)}):Play()
    updateDelivBars()
end

local MT_rowDeliver = MT_delivCount

local dotPhase = false
task.spawn(function()
    while task.wait(0.5) do
        if moneyTrackerGui.Enabled then
            dotPhase = not dotPhase
            MT_statusDot.BackgroundTransparency = dotPhase and 0 or 0.6
            pillDot.BackgroundTransparency      = dotPhase and 0 or 0.5
        end
    end
end)

local MT_accum = 0
Services.RunService.Heartbeat:Connect(function(dt)
    if not moneyTrackerGui.Enabled then return end

    Stats.farmTime = Stats.farmTime + dt
    MT_uptimeVal.Text = formatTime(Stats.farmTime)
    elapsedFill.Size = UDim2.new(math.clamp(Stats.farmTime/7200,0,1), 0, 1, 0)

    MT_accum = MT_accum + dt
    if MT_accum < 1.5 then return end
    MT_accum = 0

    pcall(function()
        local fps  = math.floor(1 / dt)
        local ping = math.floor(Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        MT_LiveStats.Text = string.format("PING %d ms  ·  FPS %d", ping, fps)
        MT_pingVal.Text   = tostring(ping).." ms"
        MT_fpsVal.Text    = tostring(fps)
        
        if ping < 80 then        MT_pingVal.TextColor3 = C.BLUE
        elseif ping < 150 then   MT_pingVal.TextColor3 = C.TEXT_MAIN
        else                     MT_pingVal.TextColor3 = C.RED end
        
        if fps >= 50 then        MT_fpsVal.TextColor3 = C.BLUE
        elseif fps >= 30 then    MT_fpsVal.TextColor3 = C.TEXT_MAIN
        else                     MT_fpsVal.TextColor3 = C.RED end
    end)

    Stats.moneyNow = getMoney()
    MT_balanceMain.Text = formatMoney(Stats.moneyNow)
    MT_valInitial.Text  = formatMoney(Stats.moneyBefore)
    MT_delivCount.Text  = tostring(Stats.deliveries)

    local income = Stats.moneyNow - Stats.moneyBefore
    if income > 0 then
        MT_valProfit.Text       = "+"..formatMoney(income)
        MT_valProfit.TextColor3 = C.GREEN

        local perHour = math.floor((income / Stats.farmTime) * 3600)
        MT_valPerHour.Text = formatMoney(perHour).." / H"
        if perHour > bestPerHour then bestPerHour = perHour end

        if Stats.deliveries > 0 then
            local perDeliv   = math.floor(income / Stats.deliveries)
            local delPerHour = math.floor((Stats.deliveries / Stats.farmTime) * 3600)
            MT_valPerDeliv.Text    = formatMoney(perDeliv)
            MT_valDelPerHour.Text  = tostring(delPerHour).." / H"
            if perDeliv > bestDelivProfit then bestDelivProfit = perDeliv end
        end

        local pct = math.clamp(income / 5000000, 0, 1)
        Services.TweenSvc:Create(progFill, TweenInfo.new(0.55), {
            Size = UDim2.new(pct, 0, 1, 0)
        }):Play()
        
        MT_progLabel.Text = string.format(
            "SESSION GAIN: +%s  (%s%% of 5M target)",
            formatMoney(income):gsub("Rp%. ","Rp. "),
            string.format("%.1f", pct*100)
        )
        MT_progLabel.TextColor3 = C.GREEN
    else
        MT_valProfit.TextColor3 = C.TEXT_DIM
    end
end)

-- ============================================================================
-- // DELIVERY CYCLE
-- ============================================================================
local function runFarmCycle()
    teleportChar(farmConfig.jobNPC)
    task.wait(2)
    if not autoFarmRunning then return end

    holdKey(Enum.KeyCode.E, 2)
    task.wait(2)
    if not autoFarmRunning then return end

    local ok1, truckBtn = pcall(function()
        return LocalPlayer.PlayerGui.Job.Components.ScrollingFrame.Truck
    end)
    if ok1 and truckBtn then clickUI(truckBtn) end
    task.wait(1)
    if not autoFarmRunning then return end

    local ok2, closeBtn = pcall(function()
        return LocalPlayer.PlayerGui.Job.Components.TextButton
    end)
    if ok2 and closeBtn then clickUI(closeBtn) end
    task.wait(2)
    if not autoFarmRunning then return end

    teleportChar(farmConfig.startJob)
    task.wait(3)
    if not autoFarmRunning then return end

    deliveryUpdated = false
    holdKey(Enum.KeyCode.E, 1.1)

    local waited = 0
    while not deliveryUpdated and waited < 5 do
        task.wait(0.2)
        waited += 0.2
    end

    if not currentDelivery then
        notify("Delivery", "Failed to fetch route")
        return
    end

    teleportChar(farmConfig.truckSpawn)
    task.wait(3)
    if not autoFarmRunning then return end

    holdKey(Enum.KeyCode.F, 1.1)
    task.wait(3)
    if not autoFarmRunning then return end

    holdKey(Enum.KeyCode.E, 1.1)
    task.wait(3)
    if not autoFarmRunning then return end

    -- Enable overlay once driver is onboard
    moneyTrackerGui.Enabled = true
    resetMoneyTracker()

    -- ── MAIN LOOP ─────────────────────────────────────────────────
    while autoFarmRunning do
        local vehicle = getVehicle()
        if not vehicle then
            notify("Delivery", "Session ended")
            moneyTrackerGui.Enabled = false
            break
        end

        Stats.deliveries += 1
        Stats.farmTime = os.time() - Stats.startTime

        if MT_rowDeliver then
            MT_rowDeliver.Text = tostring(Stats.deliveries)
        end

        local delivProfit = getMoney() - lastDelivMoney
        lastDelivMoney    = getMoney()
        table.remove(delivHistory, 1)
        table.insert(delivHistory, math.max(0, delivProfit))
        if updateDelivBars then updateDelivBars() end

        -- ── ROUTE EXECUTION ──────────────────────────────────────
        local targetNow = currentDelivery
        deliveryUpdated = false
        executeDeliveryRoute(vehicle, targetNow)

        -- Settle phase
        for _ = 1, 10 do
            if not autoFarmRunning then break end
            task.wait(1)
        end
        if not autoFarmRunning then break end

        -- Await next route
        waited = 0
        while not deliveryUpdated and waited < farmConfig.deliveryTimeout do
            task.wait(0.2)
            waited += 0.2
            if not autoFarmRunning then break end
        end

        if not deliveryUpdated then
            notify("Delivery", "Completed. Total: " .. Stats.deliveries)
            break
        end
    end

    moneyTrackerGui.Enabled = false
end

local function startFarm()
    if autoFarmRunning then return end
    autoFarmRunning = true
    if not hookConn then task.spawn(startJobHook) end
    notify("Delivery", "Auto Delivery started")

    task.spawn(function()
        while autoFarmRunning do
            pcall(runFarmCycle)
            if autoFarmRunning then task.wait(2) end
        end
    end)
end

local function stopFarm()
    autoFarmRunning = false
    moneyTrackerGui.Enabled = false
    notify("Delivery", "Auto Delivery stopped")
end

-- Farm Tab UI
local AutoFarmSection = FarmTab:Section({ Title = "Delivery System" })

local FarmToggle = AutoFarmSection:Toggle({
    Title    = "Auto Delivery",
    Desc     = "",
    Icon     = "truck",
    State    = true,
    Callback = function(state)
        if state then
            notify("Delivery System", "🚀 Active. Dashboard will appear once onboard.")
            startFarm()
        else
            notify("Delivery System", "⏹️ Stopped.")
            stopFarm()
        end
    end
})

-- Stop via RightShift
Services.UserInput.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if autoFarmRunning then
            stopFarm()
            pcall(function() FarmToggle:Set(false) end)
        end
    end
end)

-- ============================================================================
-- // 7. WEBHOOK TAB
-- ============================================================================
local WebhookEnabled         = false
local WebhookURL             = ""
local WebhookIntervalMinutes = 5
local webhookLoop            = nil

-- ══════════════════════════════════════════════════════════════════════════
--  WEBHOOK BUILDER — PROFESSIONAL REPORT
-- ══════════════════════════════════════════════════════════════════════════
local function buildReportEmbed()
    local profit     = Stats.moneyNow - Stats.moneyBefore
    local sessionSec = math.max(Stats.farmTime, 1)

    local perHour    = math.floor((profit / sessionSec) * 3600)
    local perDeliv   = Stats.deliveries > 0 and math.floor(profit / Stats.deliveries) or 0
    local delPerHour = math.floor((Stats.deliveries / sessionSec) * 3600)

    local statusIcon = profit > 0 and "🟢" or (profit < 0 and "🔴" or "🟡")
    local profitSign = profit >= 0 and "+" or "-"

    return {
        author = {
            name     = "King Akbar Hub",
            icon_url = "https://cdn-icons-png.flaticon.com/512/1077/1077012.png",
        },
        title       = "Delivery Session Report",
        description = string.format(
            "%s **Session Status:** %s\n"
            .. "**Account:** `%s`\n"
            .. "**Server:** `%s`",
            statusIcon,
            profit > 0 and "Profitable" or (profit < 0 and "Loss" or "Idle"),
            LocalPlayer.Name,
            game.JobId ~= "" and game.JobId:sub(1, 12).."..." or "Private"
        ),
        color = profit > 0 and 0x10B981
             or (profit < 0 and 0xEF4444 or 0xF59E0B),
        fields = {
            {
                name   = "💰  Wallet",
                value  = string.format(
                    "```yaml\nStarting : %s\nCurrent  : %s\n```",
                    formatMoney(Stats.moneyBefore),
                    formatMoney(Stats.moneyNow)
                ),
                inline = false,
            },
            {
                name   = "📈  Profit",
                value  = string.format("```diff\n%s%s\n```", profitSign, formatMoney(profit)),
                inline = true,
            },
            {
                name   = "⏱️  Session",
                value  = string.format("```yaml\n%s\n```", formatTime(sessionSec)),
                inline = true,
            },
            {
                name   = "🚚  Deliveries",
                value  = string.format("```yaml\n%d completed\n```", Stats.deliveries),
                inline = true,
            },
            {
                name   = "⚡  Performance",
                value  = string.format(
                    "```yaml\nIncome/hr : %s\nDeliver/hr: %d\n```",
                    formatMoney(perHour),
                    delPerHour
                ),
                inline = true,
            },
            {
                name   = "📦  Average",
                value  = string.format(
                    "```yaml\nPer delivery: %s\n```",
                    Stats.deliveries > 0 and formatMoney(perDeliv) or "—"
                ),
                inline = false,
            },
        },
        thumbnail = {
            url = "https://cdn-icons-png.flaticon.com/512/9337/9337597.png",
        },
        footer = {
            text = "King Akbar Hub  •  Delivery System  •  " .. os.date("%d %b %Y  •  %H:%M:%S"),
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }
end

local function sendWebhook()
    local url = WebhookURL
    if url == "" then
        notify("Webhook", "❌ Webhook URL is empty!")
        return
    end

    local payload = {
        username   = "King Akbar",
        avatar_url = "https://cdn-icons-png.flaticon.com/512/1077/1077012.png",
        embeds     = { buildReportEmbed() },
    }

    local jsonPayload = Services.HttpService:JSONEncode(payload)
    local success     = false
    local req         = request or http_request or (syn and syn.request)

    if req then
        local ok, res = pcall(function()
            return req({
                Url     = url,
                Method  = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body    = jsonPayload,
            })
        end)
        if ok and res and (res.StatusCode == 204 or res.StatusCode == 200) then
            success = true
        end
    else
        local ok = pcall(function()
            Services.HttpService:PostAsync(url, jsonPayload)
        end)
        if ok then success = true end
    end

    if success then
        notify("Webhook", "✅ Report sent to Discord.")
    else
        notify("Webhook", "❌ Delivery failed. Check URL or connection.")
    end
end

local function startWebhookLoop()
    if webhookLoop then task.cancel(webhookLoop) end
    if not WebhookEnabled or WebhookURL == "" then return end
    webhookLoop = task.spawn(function()
        while WebhookEnabled do
            if WebhookURL ~= "" then pcall(sendWebhook) end
            task.wait(WebhookIntervalMinutes * 60)
        end
    end)
end

local function stopWebhookLoop()
    WebhookEnabled = false
    if webhookLoop then task.cancel(webhookLoop); webhookLoop = nil end
end

-- ══════════════════════════════════════════════════════════════════════════
--  WEBHOOK TAB UI
-- ══════════════════════════════════════════════════════════════════════════

-- Info panel
WebhookTab:Paragraph({
    Title = "Discord Integration",
    Desc  = "Automatically send delivery session reports to your Discord "
         .. "channel. Reports include wallet balance, profit, session time, "
         .. "and performance metrics.",
    Image = "rbxassetid://107726435417936",
})

local ConfigSection = WebhookTab:Section({ Title = "Configuration" })

ConfigSection:Toggle({
    Title    = "Auto Send Reports",
    Desc     = "Automatically send report at the configured interval.",
    Icon     = "webhook",
    State    = false,
    Callback = function(state)
        WebhookEnabled = state
        if state then
            startWebhookLoop()
            notify("Webhook", "Auto reports enabled — every " .. WebhookIntervalMinutes .. " min.")
        else
            stopWebhookLoop()
            notify("Webhook", "Auto reports disabled.")
        end
    end
})

ConfigSection:Input({
    Title       = "Webhook URL",
    Desc        = "Discord webhook endpoint for report delivery.",
    Icon        = "link",
    Value       = "",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback    = function(val)
        WebhookURL = val
        if WebhookEnabled then startWebhookLoop() end
    end
})

ConfigSection:Input({
    Title       = "Interval (minutes)",
    Desc        = "How often reports are sent. Minimum 1 minute.",
    Icon        = "clock",
    Value       = tostring(WebhookIntervalMinutes),
    Placeholder = "5",
    Callback    = function(val)
        local n = tonumber(val)
        if n and n >= 1 then
            WebhookIntervalMinutes = math.floor(n)
            if WebhookEnabled then startWebhookLoop() end
        end
    end
})

local ActionSection = WebhookTab:Section({ Title = "Actions" })

ActionSection:Button({
    Title    = "Send Test Report",
    Desc     = "Send a report immediately to verify your webhook.",
    Icon     = "send",
    Callback = function()
        if WebhookURL == "" then
            notify("Webhook", "❌ Please enter a webhook URL first.")
            return
        end
        sendWebhook()
    end
})

ActionSection:Button({
    Title    = "Reset Session Stats",
    Desc     = "Reset all counters and balance tracking to zero.",
    Icon     = "rotate-ccw",
    Callback = function()
        Stats.moneyBefore = getMoney()
        Stats.moneyNow    = Stats.moneyBefore
        Stats.deliveries  = 0
        Stats.farmTime    = 0
        Stats.startTime   = os.time()
        notify("Session", "✅ Session stats have been reset.")
    end
})

-- ============================================================================
-- // 8. OPEN BUTTON & FPS TAG
-- ============================================================================
Window:EditOpenButton({
    Title           = "Open King Akbar",
    Icon            = "crown",
    CornerRadius    = UDim.new(0,12),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("#ffffff")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("#0a0a0a")),
    }),
    Enabled   = true,
    Draggable = true,
})

local FpsTag = Window:Tag({
    Title = "Fps: ...",
    Color = WindUI:Gradient({
        [0]   = { Color = Color3.fromHex("#0a0a0a"), Transparency = 0 },
        [100] = { Color = Color3.fromHex("#888888"), Transparency = 0 },
    }, { Rotation = 45 }),
})

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local fps  = math.floor(1 / Services.RunService.RenderStepped:Wait())
            local ping = math.floor(Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            if FpsTag and FpsTag.SetTitle then
                FpsTag:SetTitle(("Fps: %d | Ping: %d"):format(fps, ping))
            end
        end)
    end
end)

-- ============================================================================
-- // 9. INITIALIZATION + AUTO-START
-- ============================================================================
Window:SetIconSize(47)
WindUI:SetTheme("dark")
InfoTab:Select()

WindUI:Notify({
    Title    = "👑 KING AKBAR — DELIVERY SYSTEM",
    Content  = "Ready. Auto-start engaged — dashboard activates automatically.",
    Duration = 5,
})

-- Auto-start after 2 seconds
task.wait(2)
if farmConfig.autoStart then
    startFarm()
    pcall(function() FarmToggle:Set(true) end)
end

notify("King Akbar Delivery", "Auto Delivery ready & running. (Stop: RightShift)")
