-- =================================================================================
-- == VINNY's Definitive Suite
-- == Ground-up rewrite integrating all features from V12 and V20.
-- == FINAL BUILD: Cataclysm TPUA, Integrated Tweened UI, Flawless Dragging, Full Settings.
-- =================================================================================

-- Services
local HttpService = game:GetService("HttpService")
local PlayersService = game:GetService("Players")
local TeamsService = game:GetService("Teams")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = PlayersService.LocalPlayer

-- =================================================================================
-- == SECTION 1: STATE MANAGEMENT & DATA
-- =================================================================================
local savedWaypoints, selectedWaypointIndex = {}, nil
local playerWhitelist, teamWhitelist = {}, {}
local selectedPlayer, selectedTeam = nil, nil
local saveFileName = "MyWaypoints_V21_Merged.json"
local espHighlights = {}
local espColor = Color3.fromRGB(255, 0, 0) -- Default ESP color, can be changed in settings
local defaultWalkSpeed = 16
local defaultJumpPower = 50
local defaultFlingPower = 15000
local defaultTpuaPower = 50000
local tpuaActive = false
local tpuaLoop = nil

-- =================================================================================
-- == SECTION 2: CORE UTILITIES (DRAGGING)
-- =================================================================================
local function MakeDraggable(guiObject)
    local dragging = false
    local dragInput = nil
    local dragStart = Vector3.new(0, 0, 0)
    local startPosition = nil

    local function update(input)
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        guiObject.Position = newPosition
    end

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = guiObject.Position
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
        if dragging and dragInput then
            update(dragInput)
        end
    end)
end

-- =================================================================================
-- == SECTION 3: GUI CONSTRUCTION (INTEGRATED)
-- =================================================================================
-- The master ScreenGui container
local V_ScreenGui = Instance.new("ScreenGui"); V_ScreenGui.Name = "VScreenGui"; V_ScreenGui.Parent = player:WaitForChild("PlayerGui"); V_ScreenGui.ResetOnSpawn = false

-- The Main Exploit Window
local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Parent = V_ScreenGui; MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.Size = UDim2.new(0, 550, 0, 600); MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80); MainFrame.BorderSizePixel = 2; MainFrame.Active = true; MainFrame.Selectable = true; local MainFrameCorner = Instance.new("UICorner"); MainFrameCorner.CornerRadius = UDim.new(0, 8); MainFrameCorner.Parent = MainFrame
MainFrame.Position = UDim2.new(0.5, 0, -1, 0) -- Starts off-screen for tween

-- Standard Header
local TitleLabel = Instance.new("TextLabel"); TitleLabel.Name = "TitleLabel"; TitleLabel.Parent = MainFrame; TitleLabel.Size = UDim2.new(1, 0, 0, 50); TitleLabel.Position = UDim2.new(0, 0, 0, 10); TitleLabel.BackgroundTransparency = 1; TitleLabel.Font = Enum.Font.Bangers; TitleLabel.Text = "made by VINNY"; TitleLabel.TextColor3 = Color3.fromRGB(255, 0, 0); TitleLabel.TextSize = 48
local SubtitleLabel = Instance.new("TextLabel"); SubtitleLabel.Name = "SubtitleLabel"; SubtitleLabel.Parent = MainFrame; SubtitleLabel.Size = UDim2.new(0, 200, 0, 30); SubtitleLabel.Position = UDim2.new(0, 25, 0, 60); SubtitleLabel.BackgroundTransparency = 1; SubtitleLabel.Font = Enum.Font.Bangers; SubtitleLabel.Text = ""; SubtitleLabel.TextColor3 = Color3.fromRGB(200, 20, 20); SubtitleLabel.TextSize = 28
local CloseButton = Instance.new("TextButton"); CloseButton.Name = "CloseButton"; CloseButton.Parent = MainFrame; CloseButton.Size = UDim2.new(0, 35, 0, 35); CloseButton.Position = UDim2.new(1, -40, 0, 5); CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0); CloseButton.Font = Enum.Font.SourceSansBold; CloseButton.Text = "X"; CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255); CloseButton.TextSize = 24; local CloseButtonCorner = Instance.new("UICorner"); CloseButtonCorner.CornerRadius = UDim.new(0, 4); CloseButtonCorner.Parent = CloseButton

-- Button Creation Function
local function createPurpleButton(parent, text, size, position) local b = Instance.new("TextButton"); b.Parent = parent; b.Name = text:gsub(" ", "") .. "Button"; b.Text = text; b.Size = size; b.Position = position; b.BackgroundColor3 = Color3.fromRGB(118, 58, 142); b.Font = Enum.Font.SourceSansBold; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.TextSize = 16; local c = Instance.new("UICorner"); c.Name = "Corner"; c.CornerRadius = UDim.new(0, 4); c.Parent = b; local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(200, 120, 220); s.Thickness = 1.5; s.Parent = b; return b end

-- Tab System
local WaypointsTabButton = createPurpleButton(MainFrame, "Waypoints", UDim2.new(0, 100, 0, 25), UDim2.new(1, -345, 0, 60))
local PlayersTabButton = createPurpleButton(MainFrame, "Players", UDim2.new(0, 100, 0, 25), UDim2.new(1, -240, 0, 60))
local SettingsTabButton = createPurpleButton(MainFrame, "Settings", UDim2.new(0, 100, 0, 25), UDim2.new(1, -135, 0, 60))

local Content = Instance.new("Frame"); Content.Name = "Content"; Content.Parent = MainFrame; Content.Size = UDim2.new(1, 0, 1, -90); Content.Position = UDim2.new(0, 0, 0, 90); Content.BackgroundTransparency = 1
local WaypointsFrame = Instance.new("Frame"); WaypointsFrame.Name = "WaypointsFrame"; WaypointsFrame.Parent = Content; WaypointsFrame.Size = UDim2.new(1, 0, 1, 0); WaypointsFrame.BackgroundTransparency = 1; WaypointsFrame.Visible = true
local PlayersFrame = Instance.new("Frame"); PlayersFrame.Name = "PlayersFrame"; PlayersFrame.Parent = Content; PlayersFrame.Size = UDim2.new(1, 0, 1, 0); PlayersFrame.BackgroundTransparency = 1; PlayersFrame.Visible = false
local SettingsFrame = Instance.new("Frame"); SettingsFrame.Name = "SettingsFrame"; SettingsFrame.Parent = Content; SettingsFrame.Size = UDim2.new(1, 0, 1, 0); SettingsFrame.BackgroundTransparency = 1; SettingsFrame.Visible = false

-- Populate WaypointsFrame
local WaypointNameBox=Instance.new("TextBox");WaypointNameBox.Name="WaypointNameBox";WaypointNameBox.Parent=WaypointsFrame;WaypointNameBox.Size=UDim2.new(0,300,0,30);WaypointNameBox.Position=UDim2.new(0,25,0,10);WaypointNameBox.BackgroundColor3=Color3.fromRGB(45,45,45);WaypointNameBox.PlaceholderText="Name waypoint here...";WaypointNameBox.TextColor3=Color3.fromRGB(255,255,255);WaypointNameBox.TextSize=16;local WNBCorner=Instance.new("UICorner");WNBCorner.CornerRadius=UDim.new(0,4);WNBCorner.Parent=WaypointNameBox
local AddWaypointButton=createPurpleButton(WaypointsFrame,"Add & Save Waypoint",UDim2.new(0,150,0,25),UDim2.new(0,25,0,50));local TeleportToWPButton=createPurpleButton(WaypointsFrame,"Teleport to WP",UDim2.new(0,110,0,25),UDim2.new(0,185,0,50));local RemoveWaypointButton=createPurpleButton(WaypointsFrame,"Remove & Save WP",UDim2.new(0,140,0,25),UDim2.new(0,305,0,50));local LoadAllWaypointButton=createPurpleButton(WaypointsFrame,"Load Waypoints",UDim2.new(0,140,0,25),UDim2.new(0,25,0,85));local DisplayHeader=Instance.new("TextLabel");DisplayHeader.Name="DisplayHeader";DisplayHeader.Parent=WaypointsFrame;DisplayHeader.Size=UDim2.new(1,0,0,40);DisplayHeader.Position=UDim2.new(0,0,0,120);DisplayHeader.BackgroundTransparency=1;DisplayHeader.Font=Enum.Font.Bangers;DisplayHeader.Text="WAYPOINT DATABASE";DisplayHeader.TextColor3=Color3.fromRGB(255,0,0);DisplayHeader.TextSize=36
local WaypointList=Instance.new("ScrollingFrame");WaypointList.Name="WaypointList";WaypointList.Parent=WaypointsFrame;WaypointList.Size=UDim2.new(0,500,0,150);WaypointList.Position=UDim2.new(0.5,0,0,170);WaypointList.AnchorPoint=Vector2.new(0.5,0);WaypointList.BackgroundColor3=Color3.fromRGB(20,20,20);local WaypointListStroke=Instance.new("UIStroke");WaypointListStroke.Color=Color3.fromRGB(255,0,0);WaypointListStroke.Thickness=2;WaypointListStroke.Parent=WaypointList;local listLayout=Instance.new("UIListLayout");listLayout.Padding=UDim.new(0,5);listLayout.SortOrder=Enum.SortOrder.LayoutOrder;listLayout.Parent=WaypointList
local DownloadAGameButton=createPurpleButton(WaypointsFrame,"Save Instance",UDim2.new(0,150,0,40),UDim2.new(0,25,0,360));local InfiniteYieldButton=createPurpleButton(WaypointsFrame,"Infinite Yield",UDim2.new(0,150,0,40),UDim2.new(0,25,0,410));local DonateButton=createPurpleButton(WaypointsFrame,"Pls Donate Farm",UDim2.new(0,150,0,40),UDim2.new(0,200,0,360));local CarSpeedHacksButton=createPurpleButton(WaypointsFrame,"Car Speed Hacks",UDim2.new(0,150,0,40),UDim2.new(0,200,0,410));local DownloadWaypointButton=createPurpleButton(WaypointsFrame,"Copy Waypoints",UDim2.new(0,150,0,40),UDim2.new(1,-175,0,385));local UploadWaypointFileButton=createPurpleButton(WaypointsFrame,"Paste Waypoints",UDim2.new(0,150,0,40),UDim2.new(1,-175,0,435));

-- Populate PlayersFrame
local PlayerListLabel=Instance.new("TextLabel");PlayerListLabel.Parent=PlayersFrame;PlayerListLabel.Text="Players";PlayerListLabel.Position=UDim2.new(0,10,0,0);PlayerListLabel.Size=UDim2.new(0,100,0,20);PlayerListLabel.BackgroundTransparency=1;PlayerListLabel.TextColor3=Color3.fromRGB(255,255,255);PlayerListLabel.Font=Enum.Font.SourceSansBold
local PlayerList=Instance.new("ScrollingFrame");PlayerList.Parent=PlayersFrame;PlayerList.Size=UDim2.new(0,300,0,200);PlayerList.Position=UDim2.new(0,10,0,25);PlayerList.BackgroundColor3=Color3.fromRGB(20,20,20);PlayerList.BorderColor3=Color3.fromRGB(118,58,142);local pl=Instance.new("UIListLayout");pl.Padding=UDim.new(0,2);pl.Parent=PlayerList
local TeamListLabel=Instance.new("TextLabel");TeamListLabel.Parent=PlayersFrame;TeamListLabel.Text="Teams";TeamListLabel.Position=UDim2.new(0,10,0,250);TeamListLabel.Size=UDim2.new(0,100,0,20);TeamListLabel.BackgroundTransparency=1;TeamListLabel.TextColor3=Color3.fromRGB(255,255,255);TeamListLabel.Font=Enum.Font.SourceSansBold
local TeamList=Instance.new("ScrollingFrame");TeamList.Parent=PlayersFrame;TeamList.Size=UDim2.new(0,300,0,150);TeamList.Position=UDim2.new(0,10,0,275);TeamList.BackgroundColor3=Color3.fromRGB(20,20,20);TeamList.BorderColor3=Color3.fromRGB(118,58,142);local tl=Instance.new("UIListLayout");tl.Padding=UDim.new(0,2);tl.Parent=TeamList
local pBtnContainer=Instance.new("Frame");pBtnContainer.Parent=PlayersFrame;pBtnContainer.Size=UDim2.new(0,200,0,450);pBtnContainer.Position=UDim2.new(1,-210,0,25);pBtnContainer.BackgroundTransparency=1;local pbl=Instance.new("UIListLayout");pbl.Padding=UDim.new(0,10);pbl.Parent=pBtnContainer
local FlingContainer = Instance.new("Frame"); FlingContainer.Parent = pBtnContainer; FlingContainer.Size = UDim2.new(1,0,0,35); FlingContainer.BackgroundTransparency = 1;
local FlingPlayerBtn=createPurpleButton(FlingContainer,"Toggle Walk-Fling",UDim2.new(0.5, -5, 1, 0),UDim2.new(0,0,0,0));
local FlingPowerInput = Instance.new("TextBox"); FlingPowerInput.Parent = FlingContainer; FlingPowerInput.Size = UDim2.new(0.5, -5, 1, 0); FlingPowerInput.Position = UDim2.new(0.5, 5, 0, 0); FlingPowerInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45); FlingPowerInput.TextColor3 = Color3.fromRGB(255, 255, 255); FlingPowerInput.PlaceholderText = "Power"; FlingPowerInput.Text = tostring(defaultFlingPower); FlingPowerInput.Font = Enum.Font.SourceSansBold; FlingPowerInput.TextSize = 14; local FPIcorner = Instance.new("UICorner"); FPIcorner.CornerRadius = UDim.new(0, 4); FPIcorner.Parent = FlingPowerInput;
local TpuaContainer = Instance.new("Frame"); TpuaContainer.Parent = pBtnContainer; TpuaContainer.Size = UDim2.new(1,0,0,70); TpuaContainer.BackgroundTransparency = 1;
local TpuaButton = Instance.new("TextButton"); TpuaButton.Name = "TpuaButton"; TpuaButton.Parent = TpuaContainer; TpuaButton.Size = UDim2.new(1, 0, 0, 35); TpuaButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0); TpuaButton.Font = Enum.Font.Bangers; TpuaButton.Text = "CATACLYSM TPUA"; TpuaButton.TextColor3 = Color3.fromRGB(255, 255, 255); TpuaButton.TextSize = 24; local TpuaCorner = Instance.new("UICorner"); TpuaCorner.CornerRadius = UDim.new(0, 4); TpuaCorner.Parent = TpuaButton;
local TpuaPowerInput = Instance.new("TextBox"); TpuaPowerInput.Parent = TpuaContainer; TpuaPowerInput.Size = UDim2.new(1, 0, 0, 25); TpuaPowerInput.Position = UDim2.new(0, 0, 0, 45); TpuaPowerInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45); TpuaPowerInput.TextColor3 = Color3.fromRGB(255, 255, 255); TpuaPowerInput.PlaceholderText = "TPUA Strength"; TpuaPowerInput.Text = tostring(defaultTpuaPower); TpuaPowerInput.Font = Enum.Font.SourceSansBold; TpuaPowerInput.TextSize = 14; local TPIcorner = Instance.new("UICorner"); TPIcorner.CornerRadius = UDim.new(0, 4); TPIcorner.Parent = TpuaPowerInput;
local TeleportToPlayerBtn=createPurpleButton(pBtnContainer,"Teleport to",UDim2.new(1,0,0,35),UDim2.new())
local FlingSelectedPlayerBtn = createPurpleButton(pBtnContainer, "Fling Selected", UDim2.new(1, 0, 0, 35), UDim2.new())
local TeleportAllBtn = createPurpleButton(pBtnContainer,"Teleport to All",UDim2.new(1,0,0,35), UDim2.new())
local WhitelistPlayerBtn=createPurpleButton(pBtnContainer,"Whitelist Player",UDim2.new(1,0,0,35),UDim2.new())
local UnwhitelistPlayerBtn=createPurpleButton(pBtnContainer,"Un-Whitelist Player",UDim2.new(1,0,0,35),UDim2.new())
local WhitelistTeamBtn=createPurpleButton(PlayersFrame,"Whitelist Team",UDim2.new(0,120,0,25),UDim2.new(0,10,0,435));
local UnwhitelistTeamBtn=createPurpleButton(PlayersFrame,"Un-Whitelist Team",UDim2.new(0,130,0,25),UDim2.new(0,140,0,435))
local VoiceChatUnbanButton = Instance.new("TextButton"); VoiceChatUnbanButton.Name = "VoiceChatUnbanButton"; VoiceChatUnbanButton.Parent = PlayersFrame; VoiceChatUnbanButton.Size = UDim2.new(0, 130, 0, 40); VoiceChatUnbanButton.Position = UDim2.new(0, 320, 0, 385); VoiceChatUnbanButton.BackgroundColor3 = Color3.fromRGB(0, 160, 255); VoiceChatUnbanButton.Font = Enum.Font.SourceSansBold; VoiceChatUnbanButton.Text = "VC Unban"; VoiceChatUnbanButton.TextColor3 = Color3.fromRGB(255, 255, 255); VoiceChatUnbanButton.TextSize = 16; local VCUBCorner = Instance.new("UICorner"); VCUBCorner.CornerRadius = UDim.new(0, 4); VCUBCorner.Parent = VoiceChatUnbanButton;

-- Populate SettingsFrame
local function createSetting(parent, text, yPos) local container = Instance.new("Frame"); container.Size = UDim2.new(1, -20, 0, 30); container.Position = UDim2.new(0, 10, 0, yPos); container.BackgroundTransparency = 1; container.Parent = parent; local label = Instance.new("TextLabel"); label.Size = UDim2.new(0, 180, 1, 0); label.BackgroundTransparency = 1; label.Font = Enum.Font.SourceSansBold; label.Text = text; label.TextColor3 = Color3.fromRGB(220, 220, 220); label.TextSize = 18; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = container; local textbox = Instance.new("TextBox"); textbox.Size = UDim2.new(1, -270, 1, 0); textbox.Position = UDim2.new(0, 190, 0, 0); textbox.BackgroundColor3 = Color3.fromRGB(45, 45, 45); textbox.TextColor3 = Color3.fromRGB(255, 255, 255); textbox.TextSize = 16; local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 4); corner.Parent = textbox; textbox.Parent = container; local button = createPurpleButton(container, "Set", UDim2.new(0, 60, 1, 0), UDim2.new(1, -60, 0, 0)); return textbox, button end
local ESPHeader = Instance.new("TextLabel"); ESPHeader.Name = "ESPHeader"; ESPHeader.Parent = SettingsFrame; ESPHeader.Size = UDim2.new(1, 0, 0, 30); ESPHeader.Position = UDim2.new(0, 10, 0, 10); ESPHeader.BackgroundTransparency = 1; ESPHeader.Font = Enum.Font.Bangers; ESPHeader.Text = "ESP Settings"; ESPHeader.TextColor3 = Color3.fromRGB(255, 0, 0); ESPHeader.TextSize = 28; ESPHeader.TextXAlignment = Enum.TextXAlignment.Left
local ESPColorRBox, _ = createSetting(SettingsFrame, "ESP Color Red (0-255)", 50); local ESPColorGBox, _ = createSetting(SettingsFrame, "ESP Color Green (0-255)", 90); local ESPColorBBox, _ = createSetting(SettingsFrame, "ESP Color Blue (0-255)", 130); ESPColorRBox.Text = "255"; ESPColorGBox.Text = "0"; ESPColorBBox.Text = "0"
local ApplyESPColorButton = createPurpleButton(SettingsFrame, "Apply ESP Color", UDim2.new(1, -20, 0, 35), UDim2.new(0, 10, 0, 170))
local PlayerModsHeader = Instance.new("TextLabel"); PlayerModsHeader.Name = "PlayerModsHeader"; PlayerModsHeader.Parent = SettingsFrame; PlayerModsHeader.Size = UDim2.new(1, 0, 0, 30); PlayerModsHeader.Position = UDim2.new(0, 10, 0, 220); PlayerModsHeader.BackgroundTransparency = 1; PlayerModsHeader.Font = Enum.Font.Bangers; PlayerModsHeader.Text = "Player Modifications"; PlayerModsHeader.TextColor3 = Color3.fromRGB(255, 0, 0); PlayerModsHeader.TextSize = 28; PlayerModsHeader.TextXAlignment = Enum.TextXAlignment.Left
local WalkSpeedBox, SetWalkSpeedButton = createSetting(SettingsFrame, "WalkSpeed", 260); local JumpPowerBox, SetJumpPowerButton = createSetting(SettingsFrame, "JumpPower", 300); WalkSpeedBox.Text = tostring(defaultWalkSpeed); JumpPowerBox.Text = tostring(defaultJumpPower)
local ResetPlayerStatsButton = createPurpleButton(SettingsFrame, "Reset to Default", UDim2.new(1, -20, 0, 35), UDim2.new(0, 10, 0, 340))

-- Draggable Toggle Button
local toggleButton = Instance.new("Frame"); toggleButton.Name = "ToggleButton"; toggleButton.Size = UDim2.new(0, 60, 0, 60); toggleButton.Position = UDim2.new(0.01, 0, 0.5, 0); toggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25); toggleButton.BorderSizePixel = 2; toggleButton.BorderColor3 = Color3.fromRGB(255, 0, 0); toggleButton.BackgroundTransparency = 0.3; toggleButton.ClipsDescendants = true; toggleButton.Parent = V_ScreenGui
local buttonCorner = Instance.new("UICorner"); buttonCorner.CornerRadius = UDim.new(1, 0); buttonCorner.Parent = toggleButton
local videoIcon = Instance.new("VideoFrame"); videoIcon.Name = "VideoIcon"; videoIcon.Size = UDim2.new(1, 0, 1, 0); videoIcon.BackgroundTransparency = 1; videoIcon.Video = "rbxassetid://5608413286"; videoIcon.Looped = true; videoIcon.Playing = true; videoIcon.Parent = toggleButton
local clickDetector = Instance.new("TextButton"); clickDetector.Name = "ClickDetector"; clickDetector.Size = UDim2.new(1, 0, 1, 0); clickDetector.BackgroundTransparency = 1; clickDetector.Text = ""; clickDetector.Parent = toggleButton

-- =================================================================================
-- == SECTION 4: BACKEND FUNCTIONALITY
-- =================================================================================
local function executeScript(url) if not url or url == "" then return end; pcall(function() loadstring(game:HttpGet(url, true))() end) end
function getRoot(char) return char and (char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso')) end

-- ESP Rendering
RunService.RenderStepped:Connect(function()for p,h in pairs(espHighlights)do if not p or not p.Parent then h:Destroy();espHighlights[p]=nil end end;for _,tP in ipairs(PlayersService:GetPlayers())do local w=playerWhitelist[tP.Name]or(tP.Team and teamWhitelist[tP.Team.Name]);if tP~=player and tP.Character and w then local c=tP.Character;if not espHighlights[tP]then local h=Instance.new("Highlight");h.FillColor=espColor;h.OutlineColor=Color3.fromRGB(255,255,255);h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.FillTransparency=0.5;h.Parent=c;espHighlights[tP]=h end elseif espHighlights[tP]then espHighlights[tP]:Destroy();espHighlights[tP]=nil end end end)

-- List Update Functions
function updateWaypointList() for _,c in ipairs(WaypointList:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end;for i,w in ipairs(savedWaypoints)do local b=Instance.new("TextButton");b.Size=UDim2.new(1,-10,0,30);b.Text="  "..w.name;b.Font=Enum.Font.SourceSansBold;b.TextSize=18;b.TextXAlignment=Enum.TextXAlignment.Left;b.Parent=WaypointList;if i==selectedWaypointIndex then b.BackgroundColor3=Color3.fromRGB(65,90,225);b.TextColor3=Color3.fromRGB(255,255,255)else b.BackgroundColor3=Color3.fromRGB(45,45,45);b.TextColor3=Color3.fromRGB(220,220,220)end;b.MouseButton1Click:Connect(function()selectedWaypointIndex=i;updateWaypointList()end)end end
function updatePlayerList() for _,c in ipairs(PlayerList:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end;for _,p in ipairs(PlayersService:GetPlayers())do if p~=player then local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,0,40);b.Text="  "..p.Name;b.TextXAlignment=Enum.TextXAlignment.Left;b.Parent=PlayerList;b.TextSize=18;b.TextColor3=Color3.fromRGB(255,50,50);b.Font=Enum.Font.SourceSansBold;local a=Instance.new("ImageLabel");a.Size=UDim2.new(0,36,0,36);a.Position=UDim2.new(1,-38,0.5,-18);local t,s=Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48;local cont,r=PlayersService:GetUserThumbnailAsync(p.UserId,t,s);if r then a.Image=cont end;a.Parent=b;if p==selectedPlayer then b.BackgroundColor3=Color3.fromRGB(65,90,225)else b.BackgroundColor3=Color3.fromRGB(45,45,45)end;b.MouseButton1Click:Connect(function()selectedPlayer=p;updatePlayerList()end)end end end
function updateTeamList() for _,c in ipairs(TeamList:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end;for _,t in ipairs(TeamsService:GetTeams())do local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,0,30);b.Text="  "..t.Name;b.TextColor3=t.TeamColor.Color;b.TextXAlignment=Enum.TextXAlignment.Left;b.Parent=TeamList;if t==selectedTeam then b.BackgroundColor3=Color3.fromRGB(65,90,225)else b.BackgroundColor3=Color3.fromRGB(45,45,45)end;b.MouseButton1Click:Connect(function()selectedTeam=t;updateTeamList()end)end end

-- Walk-Fling Logic
local walkflinging = false; local Noclipping = nil
function noclip_command() if not player.Character then return end; Noclipping = RunService.Stepped:Connect(function() for _, c in pairs(player.Character:GetDescendants()) do if c:IsA("BasePart") then c.CanCollide = false end end end) end
function unnoclip_command() if Noclipping then Noclipping:Disconnect(); Noclipping = nil end end
function unwalkfling_command() walkflinging = false; unnoclip_command() end
function walkfling_command()
    unwalkfling_command(); if not player.Character then return end
    local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid"); if humanoid then humanoid.Died:Connect(unwalkfling_command) end
    noclip_command(); walkflinging = true
    coroutine.wrap(function()
        while walkflinging do
            local flingPower = tonumber(FlingPowerInput.Text) or defaultFlingPower
            local character = player.Character; if not character then unwalkfling_command(); break; end
            local root = getRoot(character); if not (root and root.Parent) then RunService.Heartbeat:Wait(); continue; end
            local vel = root.Velocity; root.Velocity = vel * (flingPower / 1000) + Vector3.new(0, flingPower/100, 0); RunService.RenderStepped:Wait()
            if root and root.Parent then root.Velocity = vel end; RunService.Heartbeat:Wait()
        end
    end)()
end

-- Cataclysm TPUA Logic
function start_cataclysm_tpua(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHead = targetPlayer.Character:FindFirstChild("Head")
    if not targetHead then return end
    tpuaActive = true
    local tpuaStrength = tonumber(TpuaPowerInput.Text) or defaultTpuaPower
    
    tpuaLoop = RunService.Heartbeat:Connect(function()
        if not targetPlayer.Parent or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then stop_cataclysm_tpua(); return end
        local targetPos = targetPlayer.Character.Head.Position
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(player.Character) and not part:IsDescendantOf(targetPlayer.Character) then
                local force = part:FindFirstChild("VinnyTpuaForce")
                if not force then
                    force = Instance.new("BodyPosition", part); force.Name = "VinnyTpuaForce"; force.MaxForce = Vector3.new(math.huge,math.huge,math.huge);
                end
                force.P = tpuaStrength
                force.Position = targetPos
            end
        end
    end)
end

function stop_cataclysm_tpua()
    tpuaActive = false
    if tpuaLoop then tpuaLoop:Disconnect(); tpuaLoop = nil end
    for _, part in pairs(workspace:GetDescendants()) do
        if part:FindFirstChild("VinnyTpuaForce") then part.VinnyTpuaForce:Destroy() end
    end
end

-- =================================================================================
-- == SECTION 5: BUTTON & UI CONNECTIONS
-- =================================================================================
-- Tab Switching
WaypointsTabButton.MouseButton1Click:Connect(function() WaypointsFrame.Visible=true; PlayersFrame.Visible=false; SettingsFrame.Visible=false end)
PlayersTabButton.MouseButton1Click:Connect(function() WaypointsFrame.Visible=false; PlayersFrame.Visible=true; SettingsFrame.Visible=false; updatePlayerList(); updateTeamList() end)
SettingsTabButton.MouseButton1Click:Connect(function() WaypointsFrame.Visible=false; PlayersFrame.Visible=false; SettingsFrame.Visible=true end)

-- Waypoint Buttons
AddWaypointButton.MouseButton1Click:Connect(function() local n=WaypointNameBox.Text; if n~=""and player.Character and getRoot(player.Character) then table.insert(savedWaypoints,{name=n,position={getRoot(player.Character).CFrame:GetComponents()}}); WaypointNameBox.Text=""; updateWaypointList(); if writefile then pcall(function() writefile(saveFileName,HttpService:JSONEncode(savedWaypoints)) end) end end end)
RemoveWaypointButton.MouseButton1Click:Connect(function()if selectedWaypointIndex then table.remove(savedWaypoints,selectedWaypointIndex);selectedWaypointIndex=nil;updateWaypointList();if writefile then pcall(function() writefile(saveFileName,HttpService:JSONEncode(savedWaypoints)) end) end end end)
TeleportToWPButton.MouseButton1Click:Connect(function()if selectedWaypointIndex and savedWaypoints[selectedWaypointIndex]then local w=savedWaypoints[selectedWaypointIndex];if player.Character and getRoot(player.Character)then pcall(function()getRoot(player.Character).CFrame=CFrame.new(table.unpack(w.position))end)end end end)
LoadAllWaypointButton.MouseButton1Click:Connect(function()if isfile and readfile and isfile(saveFileName)then pcall(function()local d=HttpService:JSONDecode(readfile(saveFileName));if type(d)=="table"then selectedWaypointIndex=nil;savedWaypoints=d;updateWaypointList()end end)end end)

-- Player Buttons
TeleportToPlayerBtn.MouseButton1Click:Connect(function() if selectedPlayer and getRoot(selectedPlayer.Character) and getRoot(player.Character) then getRoot(player.Character).CFrame = getRoot(selectedPlayer.Character).CFrame end end)
FlingSelectedPlayerBtn.MouseButton1Click:Connect(function() if selectedPlayer and selectedPlayer.Character and getRoot(selectedPlayer.Character) then local tR=getRoot(selectedPlayer.Character); local aG=Instance.new("BodyForce"); aG.Force=Vector3.new(0,workspace.Gravity*tR:GetMass()*1.5,0); aG.Parent=tR; local fV=Instance.new("BodyVelocity"); fV.MaxForce=Vector3.new(math.huge,math.huge,math.huge); fV.Velocity=Vector3.new(math.random(-2000,2000),2000,math.random(-2000,2000)); fV.Parent=tR; game:GetService("Debris"):AddItem(aG,0.2); game:GetService("Debris"):AddItem(fV,0.2) end end)
WhitelistPlayerBtn.MouseButton1Click:Connect(function() if selectedPlayer then playerWhitelist[selectedPlayer.Name]=true end end)
UnwhitelistPlayerBtn.MouseButton1Click:Connect(function() if selectedPlayer then playerWhitelist[selectedPlayer.Name]=nil end end)
WhitelistTeamBtn.MouseButton1Click:Connect(function() if selectedTeam then teamWhitelist[selectedTeam.Name]=true end end)
UnwhitelistTeamBtn.MouseButton1Click:Connect(function() if selectedTeam then teamWhitelist[selectedTeam.Name]=nil end end)
FlingPlayerBtn.MouseButton1Click:Connect(function() if walkflinging then unwalkfling_command() else walkfling_command(); coroutine.wrap(function() local oC = FlingPlayerBtn.BackgroundColor3; local fC = Color3.fromRGB(0,255,0); while walkflinging do FlingPlayerBtn.BackgroundColor3=fC;wait(0.2);FlingPlayerBtn.BackgroundColor3=oC;wait(0.2) end;FlingPlayerBtn.BackgroundColor3=oC end)() end end)
TeleportAllBtn.MouseButton1Click:Connect(function() coroutine.wrap(function() if not getRoot(player.Character) then return end; local oC = getRoot(player.Character).CFrame; local oP = {}; for _,p in pairs(PlayersService:GetPlayers()) do if p~=player then table.insert(oP,p) end end; for _,tP in pairs(oP) do if getRoot(tP.Character) and getRoot(player.Character) then local tR = getRoot(tP.Character); getRoot(player.Character).CFrame = tR.CFrame*CFrame.new(0,5,0); wait(0.5) end end; if getRoot(player.Character) then getRoot(player.Character).CFrame = oC end end)() end)
TpuaButton.MouseButton1Click:Connect(function() if tpuaActive then stop_cataclysm_tpua(); TpuaButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0); else start_cataclysm_tpua(selectedPlayer); TpuaButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0); end end)
VoiceChatUnbanButton.MouseButton1Click:Connect(function() pcall(function() game:GetService("VoiceChatService"):Join() end) end)

-- Script Loader Buttons
DownloadAGameButton.MouseButton1Click:Connect(function()pcall(function()local p={RepoURL="https://raw.githubusercontent.com/luau/SynSaveInstance/main/",SSI="saveinstance"};local s=loadstring(game:HttpGet(p.RepoURL..p.SSI..".luau",true),p.SSI)();s({})end)end)
DonateButton.MouseButton1Click:Connect(function()executeScript('https://raw.githubusercontent.com/CF-Trail/tzechco-PlsDonateAutofarmBackup/main/old.lua')end)
InfiniteYieldButton.MouseButton1Click:Connect(function()executeScript("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")end)
CarSpeedHacksButton.MouseButton1Click:Connect(function()executeScript("https://pastebin.com/raw/GypV3c3V")end)

-- Settings Tab Connections
local function updatePlayerStat(stat, value) local num = tonumber(value); if num and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid[stat] = num end end
SetWalkSpeedButton.MouseButton1Click:Connect(function() updatePlayerStat("WalkSpeed", WalkSpeedBox.Text) end)
SetJumpPowerButton.MouseButton1Click:Connect(function() updatePlayerStat("JumpPower", JumpPowerBox.Text) end)
ResetPlayerStatsButton.MouseButton1Click:Connect(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = defaultWalkSpeed; player.Character.Humanoid.JumpPower = defaultJumpPower; WalkSpeedBox.Text = tostring(defaultWalkSpeed); JumpPowerBox.Text = tostring(defaultJumpPower) end end)
ApplyESPColorButton.MouseButton1Click:Connect(function() local r = math.clamp(tonumber(ESPColorRBox.Text) or 255, 0, 255); local g = math.clamp(tonumber(ESPColorGBox.Text) or 0, 0, 255); local b = math.clamp(tonumber(ESPColorBBox.Text) or 0, 0, 255); espColor = Color3.fromRGB(r, g, b) end)

-- GUI Toggle & Close Logic
local isMainGuiVisible = false
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local positionOnScreen = UDim2.new(0.5, 0, 0.5, 0)
local positionOffScreen = UDim2.new(0.5, 0, -1, 0)
clickDetector.MouseButton1Click:Connect(function()
    isMainGuiVisible = not isMainGuiVisible
    if isMainGuiVisible then
        local showTween = TweenService:Create(MainFrame, tweenInfo, {Position = positionOnScreen})
        showTween:Play()
    else
        local hideTween = TweenService:Create(MainFrame, tweenInfo, {Position = positionOffScreen})
        hideTween:Play()
    end
end)
CloseButton.MouseButton1Click:Connect(function() V_ScreenGui:Destroy() end)

-- =================================================================================
-- == SECTION 6: INITIALIZATION
-- =================================================================================
MakeDraggable(MainFrame) -- Make the main window draggable
MakeDraggable(toggleButton) -- Make the toggle button draggable

-- Automatically load waypoints on start
wait(0.5)
pcall(function()
    if isfile and readfile and isfile(saveFileName) then
        local data = HttpService:JSONDecode(readfile(saveFileName))
        if type(data) == "table" then
            savedWaypoints = data
            updateWaypointList()
        end
    end
end)
print("VINNY's script initialized.")
