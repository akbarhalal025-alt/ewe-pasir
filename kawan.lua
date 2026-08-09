--[[
╔═══════════════════════════════════════════════════════════════════════╗
║                    ⚫⚪ MONO UI - FULL VERSION                        ║
║        UI Library Hitam Putih — Responsive Mobile & PC              ║
║        Tombol toggle buka/tutup ada di POJOK KIRI ATAS               ║
╚═══════════════════════════════════════════════════════════════════════╝

CARA PAKAI:
local MonoUI = loadstring(game:HttpGet("URL_RAW_KAMU"))()

local Window = MonoUI:CreateWindow("Judul Script", "Subjudul")
local Tab = Window:CreateTab("Main", "🏠")

Tab:CreateButton("Klik Aku", function() print("diklik!") end)
Tab:CreateToggle("Auto Farm", false, function(v) print(v) end)
Tab:CreateSlider("Speed", 16, 100, 16, function(v) print(v) end)
Tab:CreateDropdown("Mode", {"Easy","Hard"}, function(v) print(v) end)
Tab:CreateTextbox("Masukkan nama...", function(text) print(text) end)
Tab:CreateColorpicker("Warna", Color3.fromRGB(255,255,255), function(c) print(c) end)
Tab:CreateKeybind("Toggle UI", Enum.KeyCode.RightShift, function() end)

Window:Notify("Sukses", "Script berhasil dimuat!", 3)
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer

-- ============ DETEKSI PLATFORM (Mobile / PC) ============
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local viewportSize = workspace.CurrentCamera.ViewportSize
local isSmallScreen = viewportSize.X < 700

-- Ukuran window menyesuaikan device
local WINDOW_W = (isMobile or isSmallScreen) and math.min(viewportSize.X * 0.92, 420) or 520
local WINDOW_H = (isMobile or isSmallScreen) and math.min(viewportSize.Y * 0.62, 360) or 360
local SIDEBAR_W = (isMobile or isSmallScreen) and 100 or 140
local TOGGLE_ICON_ID = "rbxassetid://132783843721344"

-- ============ PALET WARNA HITAM PUTIH ============
local Colors = {
	White       = Color3.fromRGB(255, 255, 255),
	OffWhite    = Color3.fromRGB(240, 240, 240),
	LightGray   = Color3.fromRGB(210, 210, 210),
	MidGray     = Color3.fromRGB(150, 150, 150),
	DarkGray    = Color3.fromRGB(60, 60, 60),
	Black       = Color3.fromRGB(18, 18, 18),
	Charcoal    = Color3.fromRGB(28, 28, 28),
	Success     = Color3.fromRGB(220, 220, 220),
	Error       = Color3.fromRGB(235, 90, 90),
	TextMain    = Color3.fromRGB(255, 255, 255),
	TextSub     = Color3.fromRGB(170, 170, 170),
	TextDark    = Color3.fromRGB(20, 20, 20),
}

-- ============ UTILITAS ============
local function tween(obj, info, props)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
	return c
end

local function stroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Colors.LightGray
	s.Thickness = thickness or 1.5
	s.Transparency = 0.3
	s.Parent = parent
	return s
end

local function makeDraggable(dragHandle, frame)
	local dragging, dragStart, startPos
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	dragHandle.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- ============ LIBRARY UTAMA ============
local MonoUI = {}
MonoUI.__index = MonoUI

function MonoUI:CreateWindow(title, subtitle)
	title = title or "Mono UI"
	subtitle = subtitle or "Full Feature • Black & White"

	local old = LocalPlayer.PlayerGui:FindFirstChild("MonoUI_ScreenGui")
	if old then old:Destroy() end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "MonoUI_ScreenGui"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	-- ===== TOMBOL TOGGLE (POJOK KIRI ATAS) =====
	local ToggleBtn = Instance.new("ImageButton")
	ToggleBtn.Name = "ToggleButton"
	ToggleBtn.Size = UDim2.new(0, 46, 0, 46)
	ToggleBtn.Position = UDim2.new(0, 14, 0, 14)
	ToggleBtn.BackgroundColor3 = Colors.Black
	ToggleBtn.Image = TOGGLE_ICON_ID
	ToggleBtn.ScaleType = Enum.ScaleType.Fit
	ToggleBtn.ImageColor3 = Colors.White
	ToggleBtn.BorderSizePixel = 0
	ToggleBtn.ZIndex = 20
	ToggleBtn.Parent = ScreenGui
	corner(ToggleBtn, 12)
	stroke(ToggleBtn, Colors.White, 1.5)

	local ImgPad = Instance.new("UIPadding")
	ImgPad.PaddingTop = UDim.new(0, 8)
	ImgPad.PaddingBottom = UDim.new(0, 8)
	ImgPad.PaddingLeft = UDim.new(0, 8)
	ImgPad.PaddingRight = UDim.new(0, 8)
	ImgPad.Parent = ToggleBtn

	-- Shadow belakang window
	local Shadow = Instance.new("Frame")
	Shadow.Size = UDim2.new(0, WINDOW_W, 0, WINDOW_H)
	Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Shadow.BackgroundTransparency = 0.6
	Shadow.BorderSizePixel = 0
	Shadow.ZIndex = 9
	Shadow.Parent = ScreenGui
	corner(Shadow, 16)

	-- Window utama
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, WINDOW_W, 0, WINDOW_H)
	Main.Position = UDim2.new(0.5, -WINDOW_W / 2, 0.5, -WINDOW_H / 2)
	Main.BackgroundColor3 = Colors.Charcoal
	Main.BorderSizePixel = 0
	Main.ZIndex = 10
	Main.ClipsDescendants = true
	Main.Visible = true
	Main.Parent = ScreenGui
	corner(Main, 16)
	stroke(Main, Colors.White, 1.5)

	-- Sinkron shadow ke posisi Main
	local function syncShadow()
		Shadow.Position = Main.Position + UDim2.new(0, 3, 0, 5)
		Shadow.Size = Main.Size
	end
	syncShadow()
	Main:GetPropertyChangedSignal("Position"):Connect(syncShadow)
	Main:GetPropertyChangedSignal("Size"):Connect(syncShadow)

	-- Title bar
	local TitleBar = Instance.new("Frame")
	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, 0, 0, 52)
	TitleBar.BackgroundColor3 = Colors.Black
	TitleBar.BorderSizePixel = 0
	TitleBar.ZIndex = 11
	TitleBar.Parent = Main
	corner(TitleBar, 16)

	local TitleBarFix = Instance.new("Frame")
	TitleBarFix.Size = UDim2.new(1, 0, 0, 16)
	TitleBarFix.Position = UDim2.new(0, 0, 1, -16)
	TitleBarFix.BackgroundColor3 = Colors.Black
	TitleBarFix.BorderSizePixel = 0
	TitleBarFix.ZIndex = 11
	TitleBarFix.Parent = TitleBar

	local Dot = Instance.new("Frame")
	Dot.Size = UDim2.new(0, 10, 0, 10)
	Dot.Position = UDim2.new(0, 14, 0, 21)
	Dot.BackgroundColor3 = Colors.White
	Dot.BorderSizePixel = 0
	Dot.ZIndex = 12
	Dot.Parent = TitleBar
	corner(Dot, 5)

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(1, -160, 0, 22)
	TitleLabel.Position = UDim2.new(0, 32, 0, 5)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = title
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = (isMobile or isSmallScreen) and 15 or 17
	TitleLabel.TextColor3 = Colors.TextMain
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	TitleLabel.ZIndex = 12
	TitleLabel.Parent = TitleBar

	local SubLabel = Instance.new("TextLabel")
	SubLabel.Size = UDim2.new(1, -160, 0, 16)
	SubLabel.Position = UDim2.new(0, 32, 0, 27)
	SubLabel.BackgroundTransparency = 1
	SubLabel.Text = subtitle
	SubLabel.Font = Enum.Font.Gotham
	SubLabel.TextSize = 11
	SubLabel.TextColor3 = Colors.TextSub
	SubLabel.TextXAlignment = Enum.TextXAlignment.Left
	SubLabel.TextTruncate = Enum.TextTruncate.AtEnd
	SubLabel.ZIndex = 12
	SubLabel.Parent = TitleBar

	-- Tombol close (di window, bukan toggle utama)
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 30, 0, 30)
	CloseBtn.Position = UDim2.new(1, -40, 0, 11)
	CloseBtn.BackgroundColor3 = Colors.DarkGray
	CloseBtn.Text = "✕"
	CloseBtn.TextColor3 = Colors.White
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 14
	CloseBtn.BorderSizePixel = 0
	CloseBtn.ZIndex = 12
	CloseBtn.Parent = TitleBar
	corner(CloseBtn, 8)

	local MinBtn = Instance.new("TextButton")
	MinBtn.Size = UDim2.new(0, 30, 0, 30)
	MinBtn.Position = UDim2.new(1, -76, 0, 11)
	MinBtn.BackgroundColor3 = Colors.DarkGray
	MinBtn.Text = "–"
	MinBtn.TextColor3 = Colors.White
	MinBtn.Font = Enum.Font.GothamBold
	MinBtn.TextSize = 18
	MinBtn.BorderSizePixel = 0
	MinBtn.ZIndex = 12
	MinBtn.Parent = TitleBar
	corner(MinBtn, 8)

	for _, b in ipairs({CloseBtn, MinBtn}) do
		b.MouseEnter:Connect(function() tween(b, TweenInfo.new(0.15), { BackgroundColor3 = Colors.White, TextColor3 = Colors.Black }) end)
		b.MouseLeave:Connect(function() tween(b, TweenInfo.new(0.15), { BackgroundColor3 = Colors.DarkGray, TextColor3 = Colors.White }) end)
	end

	makeDraggable(TitleBar, Main)

	local windowVisible = true
	local function playOpen()
		Main.Visible = true
		Shadow.Visible = true
		Main.Size = UDim2.new(0, 0, 0, 0)
		Main.Position = UDim2.new(0.5, 0, 0.5, 0)
		tween(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, WINDOW_W, 0, WINDOW_H),
			Position = UDim2.new(0.5, -WINDOW_W / 2, 0.5, -WINDOW_H / 2),
		})
	end

	local function playClose(destroyAfter)
		local t = tween(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
		})
		t.Completed:Connect(function()
			Main.Visible = false
			Shadow.Visible = false
			if destroyAfter then ScreenGui:Destroy() end
		end)
	end

	playOpen()

	ToggleBtn.MouseButton1Click:Connect(function()
		windowVisible = not windowVisible
		if windowVisible then
			playOpen()
		else
			playClose(false)
		end
		tween(ToggleBtn, TweenInfo.new(0.15), { ImageColor3 = windowVisible and Colors.White or Colors.MidGray })
	end)

	CloseBtn.MouseButton1Click:Connect(function()
		windowVisible = false
		playClose(false)
	end)

	-- Sidebar
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -52)
	Sidebar.Position = UDim2.new(0, 0, 0, 52)
	Sidebar.BackgroundColor3 = Colors.Black
	Sidebar.BorderSizePixel = 0
	Sidebar.ZIndex = 10
	Sidebar.Parent = Main

	local TabList = Instance.new("UIListLayout")
	TabList.Padding = UDim.new(0, 6)
	TabList.Parent = Sidebar

	local TabPad = Instance.new("UIPadding")
	TabPad.PaddingTop = UDim.new(0, 10)
	TabPad.PaddingLeft = UDim.new(0, 6)
	TabPad.PaddingRight = UDim.new(0, 6)
	TabPad.Parent = Sidebar

	local ContentArea = Instance.new("Frame")
	ContentArea.Name = "ContentArea"
	ContentArea.Size = UDim2.new(1, -SIDEBAR_W, 1, -52)
	ContentArea.Position = UDim2.new(0, SIDEBAR_W, 0, 52)
	ContentArea.BackgroundColor3 = Colors.Charcoal
	ContentArea.BorderSizePixel = 0
	ContentArea.ZIndex = 10
	ContentArea.Parent = Main

	local isMinimized = false
	MinBtn.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		if isMinimized then
			Sidebar.Visible = false
			ContentArea.Visible = false
			tween(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, WINDOW_W, 0, 52),
			})
		else
			tween(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, WINDOW_W, 0, WINDOW_H),
			})
			task.wait(0.22)
			Sidebar.Visible = true
			ContentArea.Visible = true
		end
	end)

	local Window = setmetatable({}, { __index = MonoUI })
	Window.Tabs = {}
	Window.ScreenGui = ScreenGui

	function Window:CreateTab(tabName, icon)
		icon = icon or "•"

		local TabButton = Instance.new("TextButton")
		TabButton.Name = tabName
		TabButton.Size = UDim2.new(1, 0, 0, 36)
		TabButton.BackgroundColor3 = Colors.White
		TabButton.BackgroundTransparency = 1
		TabButton.Text = ""
		TabButton.AutoButtonColor = false
		TabButton.BorderSizePixel = 0
		TabButton.Parent = Sidebar
		corner(TabButton, 8)

		local TabIcon = Instance.new("TextLabel")
		TabIcon.Size = UDim2.new(0, 22, 1, 0)
		TabIcon.Position = UDim2.new(0, 6, 0, 0)
		TabIcon.BackgroundTransparency = 1
		TabIcon.Text = icon
		TabIcon.TextSize = 14
		TabIcon.TextColor3 = Colors.White
		TabIcon.Parent = TabButton

		local TabText = Instance.new("TextLabel")
		TabText.Size = UDim2.new(1, -30, 1, 0)
		TabText.Position = UDim2.new(0, 28, 0, 0)
		TabText.BackgroundTransparency = 1
		TabText.Text = tabName
		TabText.Font = Enum.Font.GothamMedium
		TabText.TextSize = (isMobile or isSmallScreen) and 11 or 13
		TabText.TextColor3 = Colors.TextMain
		TabText.TextXAlignment = Enum.TextXAlignment.Left
		TabText.TextTruncate = Enum.TextTruncate.AtEnd
		TabText.Parent = TabButton

		local Page = Instance.new("ScrollingFrame")
		Page.Name = tabName .. "_Page"
		Page.Size = UDim2.new(1, -20, 1, -20)
		Page.Position = UDim2.new(0, 10, 0, 10)
		Page.BackgroundTransparency = 1
		Page.BorderSizePixel = 0
		Page.ScrollBarThickness = 3
		Page.ScrollBarImageColor3 = Colors.White
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		Page.Visible = false
		Page.Parent = ContentArea

		local PageLayout = Instance.new("UIListLayout")
		PageLayout.Padding = UDim.new(0, 8)
		PageLayout.Parent = Page

		local Tab = { Page = Page, Button = TabButton }

		local function selectTab()
			for _, t in pairs(Window.Tabs) do
				t.Page.Visible = false
				tween(t.Button, TweenInfo.new(0.15), { BackgroundTransparency = 1 })
				local txt = t.Button:FindFirstChildOfClass("TextLabel")
			end
			Page.Visible = true
			tween(TabButton, TweenInfo.new(0.15), { BackgroundTransparency = 0.85 })
		end

		TabButton.MouseButton1Click:Connect(selectTab)
		TabButton.MouseEnter:Connect(function()
			if Page.Visible then return end
			tween(TabButton, TweenInfo.new(0.15), { BackgroundTransparency = 0.92 })
		end)
		TabButton.MouseLeave:Connect(function()
			if Page.Visible then return end
			tween(TabButton, TweenInfo.new(0.15), { BackgroundTransparency = 1 })
		end)

		table.insert(Window.Tabs, Tab)
		if #Window.Tabs == 1 then selectTab() end

		local elementH = (isMobile or isSmallScreen) and 40 or 38

		function Tab:CreateLabel(text)
			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, 0, 0, 22)
			Label.BackgroundTransparency = 1
			Label.Text = text
			Label.Font = Enum.Font.GothamBold
			Label.TextSize = 14
			Label.TextColor3 = Colors.TextMain
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Page
			return Label
		end

		function Tab:CreateButton(text, callback)
			callback = callback or function() end
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 0, elementH)
			Btn.BackgroundColor3 = Colors.White
			Btn.Text = text
			Btn.Font = Enum.Font.GothamMedium
			Btn.TextSize = 14
			Btn.TextColor3 = Colors.Black
			Btn.AutoButtonColor = false
			Btn.BorderSizePixel = 0
			Btn.Parent = Page
			corner(Btn, 10)

			Btn.MouseEnter:Connect(function()
				tween(Btn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.LightGray })
			end)
			Btn.MouseLeave:Connect(function()
				tween(Btn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.White })
			end)
			Btn.MouseButton1Click:Connect(function()
				tween(Btn, TweenInfo.new(0.08), { Size = UDim2.new(1, -6, 0, elementH - 4) }).Completed:Connect(function()
					tween(Btn, TweenInfo.new(0.08), { Size = UDim2.new(1, 0, 0, elementH) })
				end)
				callback()
			end)
			return Btn
		end

		function Tab:CreateToggle(text, default, callback)
			callback = callback or function() end
			local state = default or false

			local Holder = Instance.new("Frame")
			Holder.Size = UDim2.new(1, 0, 0, elementH)
			Holder.BackgroundColor3 = Colors.Black
			Holder.BorderSizePixel = 0
			Holder.Parent = Page
			corner(Holder, 10)
			stroke(Holder, Colors.DarkGray, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -60, 1, 0)
			Label.Position = UDim2.new(0, 12, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = text
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 13
			Label.TextColor3 = Colors.TextMain
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Holder

			local Switch = Instance.new("Frame")
			Switch.Size = UDim2.new(0, 44, 0, 22)
			Switch.Position = UDim2.new(1, -54, 0.5, -11)
			Switch.BackgroundColor3 = state and Colors.White or Colors.DarkGray
			Switch.BorderSizePixel = 0
			Switch.Parent = Holder
			corner(Switch, 11)

			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.new(0, 18, 0, 18)
			Knob.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
			Knob.BackgroundColor3 = state and Colors.Black or Colors.White
			Knob.BorderSizePixel = 0
			Knob.Parent = Switch
			corner(Knob, 9)

			local ClickCatcher = Instance.new("TextButton")
			ClickCatcher.Size = UDim2.new(1, 0, 1, 0)
			ClickCatcher.BackgroundTransparency = 1
			ClickCatcher.Text = ""
			ClickCatcher.Parent = Holder

			ClickCatcher.MouseButton1Click:Connect(function()
				state = not state
				tween(Switch, TweenInfo.new(0.2), { BackgroundColor3 = state and Colors.White or Colors.DarkGray })
				tween(Knob, TweenInfo.new(0.2), {
					Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
					BackgroundColor3 = state and Colors.Black or Colors.White,
				})
				callback(state)
			end)

			return Holder
		end

		function Tab:CreateSlider(text, min, max, default, callback)
			min, max = min or 0, max or 100
			default = default or min
			callback = callback or function() end

			local Holder = Instance.new("Frame")
			Holder.Size = UDim2.new(1, 0, 0, 52)
			Holder.BackgroundColor3 = Colors.Black
			Holder.BorderSizePixel = 0
			Holder.Parent = Page
			corner(Holder, 10)
			stroke(Holder, Colors.DarkGray, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -20, 0, 20)
			Label.Position = UDim2.new(0, 10, 0, 4)
			Label.BackgroundTransparency = 1
			Label.Text = text .. ": " .. tostring(default)
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 12
			Label.TextColor3 = Colors.TextMain
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Holder

			local Track = Instance.new("Frame")
			Track.Size = UDim2.new(1, -20, 0, 8)
			Track.Position = UDim2.new(0, 10, 0, 32)
			Track.BackgroundColor3 = Colors.DarkGray
			Track.BorderSizePixel = 0
			Track.Parent = Holder
			corner(Track, 4)

			local Fill = Instance.new("Frame")
			local pct = (default - min) / (max - min)
			Fill.Size = UDim2.new(pct, 0, 1, 0)
			Fill.BackgroundColor3 = Colors.White
			Fill.BorderSizePixel = 0
			Fill.Parent = Track
			corner(Fill, 4)

			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.new(0, 16, 0, 16)
			Knob.Position = UDim2.new(pct, -8, 0.5, -8)
			Knob.BackgroundColor3 = Colors.White
			Knob.BorderSizePixel = 0
			Knob.ZIndex = 2
			Knob.Parent = Track
			corner(Knob, 8)
			stroke(Knob, Colors.Black, 2)

			local dragging = false
			local function updateFromInput(inputPos)
				local relative = math.clamp((inputPos.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
				local value = math.floor(min + (max - min) * relative)
				Fill.Size = UDim2.new(relative, 0, 1, 0)
				Knob.Position = UDim2.new(relative, -8, 0.5, -8)
				Label.Text = text .. ": " .. tostring(value)
				callback(value)
			end

			Knob.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
				end
			end)
			Track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					updateFromInput(input.Position)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateFromInput(input.Position)
				end
			end)

			return Holder
		end

		function Tab:CreateDropdown(text, options, callback)
			options = options or {}
			callback = callback or function() end

			local Holder = Instance.new("Frame")
			Holder.Size = UDim2.new(1, 0, 0, elementH)
			Holder.BackgroundColor3 = Colors.Black
			Holder.BorderSizePixel = 0
			Holder.ClipsDescendants = true
			Holder.ZIndex = 5
			Holder.Parent = Page
			corner(Holder, 10)
			stroke(Holder, Colors.DarkGray, 1)

			local Selected = Instance.new("TextButton")
			Selected.Size = UDim2.new(1, 0, 0, elementH)
			Selected.BackgroundTransparency = 1
			Selected.Text = "  " .. text .. ": " .. (options[1] or "-") .. "  ▾"
			Selected.Font = Enum.Font.GothamMedium
			Selected.TextSize = 13
			Selected.TextColor3 = Colors.TextMain
			Selected.TextXAlignment = Enum.TextXAlignment.Left
			Selected.ZIndex = 5
			Selected.Parent = Holder

			local ListFrame = Instance.new("Frame")
			ListFrame.Size = UDim2.new(1, 0, 0, #options * 30)
			ListFrame.Position = UDim2.new(0, 0, 0, elementH)
			ListFrame.BackgroundTransparency = 1
			ListFrame.ZIndex = 5
			ListFrame.Parent = Holder

			local ListLayout = Instance.new("UIListLayout")
			ListLayout.Parent = ListFrame

			local open = false
			for _, opt in ipairs(options) do
				local OptBtn = Instance.new("TextButton")
				OptBtn.Size = UDim2.new(1, 0, 0, 30)
				OptBtn.BackgroundTransparency = 1
				OptBtn.Text = "     " .. opt
				OptBtn.Font = Enum.Font.Gotham
				OptBtn.TextSize = 12
				OptBtn.TextColor3 = Colors.TextMain
				OptBtn.TextXAlignment = Enum.TextXAlignment.Left
				OptBtn.ZIndex = 5
				OptBtn.Parent = ListFrame

				OptBtn.MouseEnter:Connect(function()
					tween(OptBtn, TweenInfo.new(0.1), { BackgroundTransparency = 0.85, BackgroundColor3 = Colors.White })
				end)
				OptBtn.MouseLeave:Connect(function()
					tween(OptBtn, TweenInfo.new(0.1), { BackgroundTransparency = 1 })
				end)

				OptBtn.MouseButton1Click:Connect(function()
					Selected.Text = "  " .. text .. ": " .. opt .. "  ▾"
					open = false
					tween(Holder, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, elementH) })
					callback(opt)
				end)
			end

			Selected.MouseButton1Click:Connect(function()
				open = not open
				local targetSize = open and UDim2.new(1, 0, 0, elementH + #options * 30) or UDim2.new(1, 0, 0, elementH)
				tween(Holder, TweenInfo.new(0.2), { Size = targetSize })
			end)

			return Holder
		end

		function Tab:CreateTextbox(placeholder, callback)
			callback = callback or function() end

			local Holder = Instance.new("Frame")
			Holder.Size = UDim2.new(1, 0, 0, elementH)
			Holder.BackgroundColor3 = Colors.Black
			Holder.BorderSizePixel = 0
			Holder.Parent = Page
			corner(Holder, 10)
			stroke(Holder, Colors.DarkGray, 1)

			local Input = Instance.new("TextBox")
			Input.Size = UDim2.new(1, -20, 1, 0)
			Input.Position = UDim2.new(0, 10, 0, 0)
			Input.BackgroundTransparency = 1
			Input.PlaceholderText = placeholder or "Ketik sesuatu..."
			Input.Text = ""
			Input.Font = Enum.Font.Gotham
			Input.TextSize = 13
			Input.TextColor3 = Colors.TextMain
			Input.PlaceholderColor3 = Colors.TextSub
			Input.ClearTextOnFocus = false
			Input.Parent = Holder

			Input.FocusLost:Connect(function(enterPressed)
				callback(Input.Text, enterPressed)
			end)

			return Holder
		end

		function Tab:CreateColorpicker(text, default, callback)
			default = default or Color3.fromRGB(255, 255, 255)
			callback = callback or function() end

			local Holder = Instance.new("Frame")
			Holder.Size = UDim2.new(1, 0, 0, elementH)
			Holder.BackgroundColor3 = Colors.Black
			Holder.BorderSizePixel = 0
			Holder.Parent = Page
			corner(Holder, 10)
			stroke(Holder, Colors.DarkGray, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -80, 1, 0)
			Label.Position = UDim2.new(0, 12, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = text
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 13
			Label.TextColor3 = Colors.TextMain
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Holder

			local Preview = Instance.new("Frame")
			Preview.Size = UDim2.new(0, 44, 0, 24)
			Preview.Position = UDim2.new(1, -56, 0.5, -12)
			Preview.BackgroundColor3 = default
			Preview.BorderSizePixel = 0
			Preview.Parent = Holder
			corner(Preview, 6)
			stroke(Preview, Colors.White, 1)

			local HexBox = Instance.new("TextBox")
			HexBox.Size = UDim2.new(0, 0, 0, 0)
			HexBox.Visible = false
			HexBox.Parent = Holder -- hex input hidden helper (opsional pemakaian lanjutan)

			local ClickCatcher = Instance.new("TextButton")
			ClickCatcher.Size = UDim2.new(0, 44, 0, 24)
			ClickCatcher.Position = UDim2.new(1, -56, 0.5, -12)
			ClickCatcher.BackgroundTransparency = 1
			ClickCatcher.Text = ""
			ClickCatcher.Parent = Holder

			-- Palet warna cepat hitam-putih-abu (grayscale picker)
			local palette = {
				Color3.fromRGB(255,255,255), Color3.fromRGB(210,210,210),
				Color3.fromRGB(150,150,150), Color3.fromRGB(90,90,90),
				Color3.fromRGB(40,40,40), Color3.fromRGB(0,0,0),
			}

			local PaletteFrame = Instance.new("Frame")
			PaletteFrame.Size = UDim2.new(1, 0, 0, 36)
			PaletteFrame.Position = UDim2.new(0, 0, 1, 0)
			PaletteFrame.BackgroundTransparency = 1
			PaletteFrame.Visible = false
			PaletteFrame.Parent = Holder

			local PaletteLayout = Instance.new("UIListLayout")
			PaletteLayout.FillDirection = Enum.FillDirection.Horizontal
			PaletteLayout.Padding = UDim.new(0, 6)
			PaletteLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			PaletteLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			PaletteLayout.Parent = PaletteFrame

			local open = false
			for _, col in ipairs(palette) do
				local Swatch = Instance.new("TextButton")
				Swatch.Size = UDim2.new(0, 28, 0, 28)
				Swatch.BackgroundColor3 = col
				Swatch.Text = ""
				Swatch.BorderSizePixel = 0
				Swatch.Parent = PaletteFrame
				corner(Swatch, 6)
				stroke(Swatch, Colors.White, 1)

				Swatch.MouseButton1Click:Connect(function()
					Preview.BackgroundColor3 = col
					callback(col)
				end)
			end

			ClickCatcher.MouseButton1Click:Connect(function()
				open = not open
				PaletteFrame.Visible = open
				tween(Holder, TweenInfo.new(0.2), { Size = open and UDim2.new(1, 0, 0, elementH + 42) or UDim2.new(1, 0, 0, elementH) })
			end)

			Holder.ClipsDescendants = true

			return Holder
		end

		function Tab:CreateKeybind(text, defaultKey, callback)
			callback = callback or function() end
			local currentKey = defaultKey or Enum.KeyCode.RightShift
			local listening = false

			local Holder = Instance.new("Frame")
			Holder.Size = UDim2.new(1, 0, 0, elementH)
			Holder.BackgroundColor3 = Colors.Black
			Holder.BorderSizePixel = 0
			Holder.Parent = Page
			corner(Holder, 10)
			stroke(Holder, Colors.DarkGray, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -100, 1, 0)
			Label.Position = UDim2.new(0, 12, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = text
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 13
			Label.TextColor3 = Colors.TextMain
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Holder

			local KeyBtn = Instance.new("TextButton")
			KeyBtn.Size = UDim2.new(0, 84, 0, 28)
			KeyBtn.Position = UDim2.new(1, -94, 0.5, -14)
			KeyBtn.BackgroundColor3 = Colors.White
			KeyBtn.Text = currentKey.Name
			KeyBtn.Font = Enum.Font.GothamBold
			KeyBtn.TextSize = 12
			KeyBtn.TextColor3 = Colors.Black
			KeyBtn.BorderSizePixel = 0
			KeyBtn.Parent = Holder
			corner(KeyBtn, 6)

			KeyBtn.MouseButton1Click:Connect(function()
				listening = true
				KeyBtn.Text = "..."
			end)

			UserInputService.InputBegan:Connect(function(input, processed)
				if listening and input.UserInputType == Enum.UserInputType.Keyboard then
					currentKey = input.KeyCode
					KeyBtn.Text = currentKey.Name
					listening = false
				elseif not processed and input.KeyCode == currentKey then
					callback()
				end
			end)

			return Holder
		end

		return Tab
	end

	function Window:Notify(title, text, duration)
		duration = duration or 3

		local Notif = Instance.new("Frame")
		Notif.Size = UDim2.new(0, 260, 0, 70)
		Notif.Position = UDim2.new(1, 20, 1, -90)
		Notif.BackgroundColor3 = Colors.Black
		Notif.BorderSizePixel = 0
		Notif.ZIndex = 30
		Notif.Parent = ScreenGui
		corner(Notif, 12)
		stroke(Notif, Colors.White, 1.5)

		local NDot = Instance.new("Frame")
		NDot.Size = UDim2.new(0, 8, 0, 8)
		NDot.Position = UDim2.new(0, 12, 0, 12)
		NDot.BackgroundColor3 = Colors.White
		NDot.BorderSizePixel = 0
		NDot.ZIndex = 31
		NDot.Parent = Notif
		corner(NDot, 4)

		local NTitle = Instance.new("TextLabel")
		NTitle.Size = UDim2.new(1, -34, 0, 20)
		NTitle.Position = UDim2.new(0, 28, 0, 8)
		NTitle.BackgroundTransparency = 1
		NTitle.Text = title
		NTitle.Font = Enum.Font.GothamBold
		NTitle.TextSize = 13
		NTitle.TextColor3 = Colors.TextMain
		NTitle.TextXAlignment = Enum.TextXAlignment.Left
		NTitle.ZIndex = 31
		NTitle.Parent = Notif

		local NText = Instance.new("TextLabel")
		NText.Size = UDim2.new(1, -34, 0, 34)
		NText.Position = UDim2.new(0, 28, 0, 28)
		NText.BackgroundTransparency = 1
		NText.Text = text
		NText.Font = Enum.Font.Gotham
		NText.TextSize = 12
		NText.TextColor3 = Colors.TextSub
		NText.TextWrapped = true
		NText.TextXAlignment = Enum.TextXAlignment.Left
		NText.TextYAlignment = Enum.TextYAlignment.Top
		NText.ZIndex = 31
		NText.Parent = Notif

		tween(Notif, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -280, 1, -90),
		})

		task.delay(duration, function()
			local outT = tween(Notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.new(1, 20, 1, -90),
			})
			outT.Completed:Connect(function() Notif:Destroy() end)
		end)
	end

	return Window
end

return MonoUI
