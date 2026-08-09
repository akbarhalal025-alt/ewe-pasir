-- ============================================
--  POLE X - Full Menu (with toggle icon 132783843721344)
--  Loader: jalankan script ini
--  Pastikan kawan.lua sudah pakai ImageButton + ID di atas
-- ============================================

-- Load library
local MonoUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/akbarhalal025-alt/ewe-pasir/refs/heads/main/kawan.lua"))()
local Window = MonoUI:CreateWindow("Pole X", "Exclusive Edition")

-- === FALLBACK TOGGLE: Jika gambar gagal muncul, ubah ke teks ☰ ===
local toggle = Window.ScreenGui:FindFirstChild("ToggleButton")
if toggle and toggle:IsA("ImageButton") then
    -- Cek setelah 2 detik apakah gambar berhasil dimuat (ukurannya > 0)
    spawn(function()
        wait(2)
        -- Kalau Image tidak beresolusi (mungkin tidak terload), ganti ke TextButton
        if toggle.ContentImageSize == Vector2.new(0,0) then
            -- Ubah ke TextButton
            local textToggle = Instance.new("TextButton")
            textToggle.Name = "ToggleButton"
            textToggle.Size = UDim2.new(0, 46, 0, 46)
            textToggle.Position = UDim2.new(0, 14, 0, 14)
            textToggle.BackgroundColor3 = Color3.fromRGB(18,18,18)
            textToggle.Text = "☰"
            textToggle.Font = Enum.Font.GothamBold
            textToggle.TextSize = 24
            textToggle.TextColor3 = Color3.fromRGB(255,255,255)
            textToggle.BorderSizePixel = 0
            textToggle.ZIndex = 20
            textToggle.AutoButtonColor = false
            textToggle.Parent = Window.ScreenGui
            -- Copy UICorner dan UIStroke jika ada
            local corner = toggle:FindFirstChild("UICorner")
            if corner then
                local c = corner:Clone()
                c.Parent = textToggle
            end
            local stroke = toggle:FindFirstChild("UIStroke")
            if stroke then
                local s = stroke:Clone()
                s.Parent = textToggle
            end
            -- Pindahkan koneksi klik
            local oldClick = toggle.MouseButton1Click
            textToggle.MouseButton1Click:Connect(function()
                oldClick:Fire()
            end)
            toggle:Destroy()
            toggle = textToggle
        end
    end)
end

-- ============================================
--  TAB: PLAYER
-- ============================================
local PlayerTab = Window:CreateTab("Player", "🏃")

PlayerTab:CreateSlider("WalkSpeed", 10, 200, 16, function(val)
    local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = val end
end)

PlayerTab:CreateSlider("JumpPower", 30, 300, 50, function(val)
    local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.UseJumpPower = true; hum.JumpPower = val end
end)

PlayerTab:CreateToggle("Infinite Jump", false, function(state)
    if state then
        local uis = game:GetService("UserInputService")
        uis.JumpRequest:Connect(function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

local flyEnabled = false
local flyBody
local function setFly(state)
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if state then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyBody"
        bv.MaxForce = Vector3.new(400000, 400000, 400000)
        bv.Velocity = Vector3.zero
        bv.Parent = char.HumanoidRootPart
        flyBody = bv
        flyEnabled = true
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
        if char:FindFirstChild("FlyBody") then char.FlyBody:Destroy() end
        Window:Notify("Fly", "OFF", 2)
    end
end

PlayerTab:CreateToggle("Fly", false, function(state) setFly(state) end)
PlayerTab:CreateKeybind("Fly Key", Enum.KeyCode.F, function() setFly(not flyEnabled) end)

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
                            h.FillColor = Color3.fromRGB(255,255,255)
                            h.FillTransparency = 0.8
                            h.OutlineColor = Color3.fromRGB(255,255,255)
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
            for _, h in pairs(espCache) do h:Destroy() end
            espCache = {}
        end)
        Window:Notify("ESP", "ON", 2)
    else
        Window:Notify("ESP", "OFF", 2)
    end
end

ESPTab:CreateToggle("Box ESP", false, toggleESP)
ESPTab:CreateColorpicker("ESP Color", Color3.fromRGB(255,255,255), function(color)
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
        Window:Notify("Anti AFK", "OFF", 2)
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
Window:Notify("Pole X Loaded", "UI siap. Toggle di pojok kiri atas (ID:132783843721344).", 5)
print("Pole X Full Menu siap.")
