-- ============================================
--  POLE X UI - Full Menu (Powered by Mono UI)
--  Loader: cukup jalankan script ini
--  Toggle "☰" otomatis muncul di pojok kiri atas
-- ============================================

-- Load library Mono UI dari kawan.lua
local MonoUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/akbarhalal025-alt/ewe-pasir/refs/heads/main/kawan.lua"))()

-- Buat window utama
local Window = MonoUI:CreateWindow("Pole X", "Exclusive Edition")

-- ============================================
--  TAB: PLAYER
-- ============================================
local PlayerTab = Window:CreateTab("Player", "🏃")

-- WalkSpeed Slider
PlayerTab:CreateSlider("WalkSpeed", 10, 200, 16, function(val)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = val
    end
end)

-- JumpPower Slider
PlayerTab:CreateSlider("JumpPower", 30, 300, 50, function(val)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.UseJumpPower = true
        char.Humanoid.JumpPower = val
    end
end)

-- Infinite Jump Toggle
PlayerTab:CreateToggle("Infinite Jump", false, function(state)
    if state then
        local UserInputService = game:GetService("UserInputService")
        local function onJump()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
        UserInputService.JumpRequest:Connect(onJump)
        Window:Notify("Infinite Jump", "ON", 2)
    else
        Window:Notify("Infinite Jump", "OFF", 2)
    end
end)

-- Fly Toggle (WASD + Space/LCtrl)
local flyEnabled = false
local flyBody = nil

local function setFly(state)
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if state then
        -- Buat BodyVelocity
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyBody"
        bv.MaxForce = Vector3.new(400000, 400000, 400000)
        bv.Velocity = Vector3.zero
        bv.Parent = char.HumanoidRootPart
        flyBody = bv
        flyEnabled = true

        -- Loop kontrol fly
        spawn(function()
            local uis = game:GetService("UserInputService")
            local cam = workspace.CurrentCamera
            while flyEnabled and char and char:FindFirstChild("FlyBody") do
                local vel = Vector3.zero
                if uis:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.CFrame.LookVector * 50 end
                if uis:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.CFrame.LookVector * 50 end
                if uis:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.CFrame.RightVector * 50 end
                if uis:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.CFrame.RightVector * 50 end
                if uis:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, 50, 0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0, 50, 0) end
                char.FlyBody.Velocity = vel
                wait(0.05)
            end
        end)
        Window:Notify("Fly", "ON", 2)
    else
        flyEnabled = false
        if char:FindFirstChild("FlyBody") then
            char.FlyBody:Destroy()
        end
        Window:Notify("Fly", "OFF", 2)
    end
end

PlayerTab:CreateToggle("Fly", false, function(state) setFly(state) end)

-- Fly Keybind (default: F)
PlayerTab:CreateKeybind("Fly Key", Enum.KeyCode.F, function()
    setFly(not flyEnabled)
end)

-- ============================================
--  TAB: ESP
-- ============================================
local ESPTab = Window:CreateTab("ESP", "👁️")
local espEnabled = false
local espCache = {}

local function toggleESP(state)
    espEnabled = state
    if state then
        spawn(function()
            while espEnabled do
                for _, player in ipairs(game.Players:GetPlayers()) do
                    if player ~= game.Players.LocalPlayer then
                        if player.Character and not espCache[player] then
                            local h = Instance.new("Highlight")
                            h.Name = "ESP"
                            h.FillColor = Color3.fromRGB(255, 255, 255)
                            h.FillTransparency = 0.8
                            h.OutlineColor = Color3.fromRGB(255, 255, 255)
                            h.OutlineTransparency = 0.5
                            h.Parent = player.Character
                            espCache[player] = h
                        elseif not player.Character and espCache[player] then
                            espCache[player]:Destroy()
                            espCache[player] = nil
                        end
                    end
                end
                wait(0.3)
            end
            -- Bersihkan saat dimatikan
            for _, h in pairs(espCache) do
                h:Destroy()
            end
            espCache = {}
        end)
        Window:Notify("ESP", "ON", 2)
    else
        Window:Notify("ESP", "OFF", 2)
    end
end

ESPTab:CreateToggle("Box ESP", false, toggleESP)

ESPTab:CreateColorpicker("ESP Color", Color3.fromRGB(255, 255, 255), function(color)
    for _, h in pairs(espCache) do
        h.FillColor = color
        h.OutlineColor = color
    end
end)

-- ============================================
--  TAB: AIMBOT
-- ============================================
local AimbotTab = Window:CreateTab("Aimbot", "🎯")
local aimbotEnabled = false
local aimbotPart = "Head"
local aimbotFOV = 150

AimbotTab:CreateDropdown("Target Part", {"Head", "HumanoidRootPart", "Torso", "Right Arm"}, function(part)
    aimbotPart = part
end)

AimbotTab:CreateSlider("FOV", 30, 300, 150, function(val)
    aimbotFOV = val
end)

AimbotTab:CreateToggle("Enable Aimbot", false, function(state)
    aimbotEnabled = state
    if state then
        spawn(function()
            while aimbotEnabled do
                local cam = workspace.CurrentCamera
                local lp = game.Players.LocalPlayer
                local char = lp.Character
                if not char or not char:FindFirstChild(aimbotPart) then wait(); continue end
                local myPart = char[aimbotPart]
                local closest = nil
                local closestDist = aimbotFOV
                for _, player in ipairs(game.Players:GetPlayers()) do
                    if player ~= lp and player.Character and player.Character:FindFirstChild(aimbotPart) then
                        local targetPart = player.Character[aimbotPart]
                        local screenPos, onScreen = cam:WorldToScreenPoint(targetPart.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closest = targetPart
                            end
                        end
                    end
                end
                if closest then
                    cam.CFrame = CFrame.new(cam.CFrame.Position, closest.Position)
                end
                wait()
            end
        end)
        Window:Notify("Aimbot", "ON", 2)
    else
        Window:Notify("Aimbot", "OFF", 2)
    end
end)

AimbotTab:CreateKeybind("Aimbot Key", Enum.KeyCode.E, function()
    aimbotEnabled = not aimbotEnabled
    Window:Notify("Aimbot", aimbotEnabled and "ON" or "OFF", 2)
end)

-- ============================================
--  TAB: MISC
-- ============================================
local MiscTab = Window:CreateTab("Misc", "⚙️")

MiscTab:CreateToggle("Anti AFK", false, function(state)
    if state then
        local vu = game:GetService("VirtualUser")
        game.Players.LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
        Window:Notify("Anti AFK", "ON", 2)
    else
        Window:Notify("Anti AFK", "OFF (restart script to fully disable)", 2)
    end
end)

MiscTab:CreateButton("Server Hop", function()
    local ts = game:GetService("TeleportService")
    ts:Teleport(game.PlaceId, game.Players.LocalPlayer)
end)

MiscTab:CreateButton("Rejoin", function()
    local ts = game:GetService("TeleportService")
    ts:Teleport(game.PlaceId, game.Players.LocalPlayer)
end)

MiscTab:CreateTextbox("Chat message...", function(text, enterPressed)
    if enterPressed and text ~= "" then
        local chatRemote = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if chatRemote and chatRemote:FindFirstChild("SayMessageRequest") then
            chatRemote.SayMessageRequest:FireServer(text, "All")
        end
        Window:Notify("Chat", "Terkirim: "..text, 2)
    end
end)

-- ============================================
--  NOTIFIKASI AWAL
-- ============================================
Window:Notify("Pole X Loaded", "Selamat menggunakan! Toggle di pojok kiri atas.", 5)

print("Pole X Full Menu siap. Toggle '☰' di kiri atas untuk buka/tutup UI.")
