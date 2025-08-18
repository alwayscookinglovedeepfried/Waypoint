-- =================================================================================
-- == V.I.N.N.Y's Definitive Suite (V13 - Ascension Fling Edition)
-- == Contains all features from the entire conversation in a stable, unified architecture.
-- =================================================================================

-- Services
local HttpService = game:GetService("HttpService")
local PlayersService = game:GetService("Players")
local TeamsService = game:GetService("Teams")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = PlayersService.LocalPlayer

-- =================================================================================
-- == SECTION 1: STATE MANAGEMENT & DATA
-- =================================================================================
local savedWaypoints, selectedWaypointIndex = {}, nil
local playerWhitelist, teamWhitelist = {}, {}
local selectedPlayer, selectedTeam = nil, nil
local saveFileName = "MyWaypoints_V10_Definitive.json"
local espHighlights = {}
local espColor = Color3.fromRGB(255, 0, 0)
local defaultWalkSpeed = 16
local defaultJumpPower = 50

-- =================================================================================
-- == SECTION 2: GUI CONSTRUCTION
-- =================================================================================
local WaypointGUI = Instance.new("ScreenGui"); WaypointGUI.Name = "WaypointGUI"; WaypointGUI.Parent = player:WaitForChild("PlayerGui"); WaypointGUI.ResetOnSpawn = false
local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Parent = WaypointGUI; MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); MainFrame.Size = UDim2.new(0, 550, 0, 600); MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80); MainFrame.BorderSizePixel = 2; MainFrame.Active = true; MainFrame.Selectable = true; local MainFrameCorner = Instance.new("UICorner"); MainFrameCorner.CornerRadius = UDim.new(0, 8); MainFrameCorner.Parent = MainFrame
local TitleLabel = Instance.new("TextLabel"); TitleLabel.Name = "TitleLabel"; TitleLabel.Parent = MainFrame; TitleLabel.Size = UDim2.new(1, 0, 0, 50); TitleLabel.Position = UDim2.new(0, 0, 0, 10); TitleLabel.BackgroundTransparency = 1; TitleLabel.Font = Enum.Font.Bangers; TitleLabel.Text = "Save way point"; TitleLabel.TextColor3 = Color3.fromRGB(70, 200, 220); TitleLabel.TextSize = 48
local SubtitleLabel = Instance.new("TextLabel"); SubtitleLabel.Name = "SubtitleLabel"; SubtitleLabel.Parent = MainFrame; SubtitleLabel.Size = UDim2.new(0, 200, 0, 30); SubtitleLabel.Position = UDim2.new(0, 25, 0, 60); SubtitleLabel.BackgroundTransparency = 1; SubtitleLabel.Font = Enum.Font.Bangers; SubtitleLabel.Text = "MADE BY VINNY"; SubtitleLabel.TextColor3 = Color3.fromRGB(65, 90, 225); SubtitleLabel.TextSize = 28
local CloseButton = Instance.new("TextButton"); CloseButton.Name = "CloseButton"; CloseButton.Parent = MainFrame; CloseButton.Size = UDim2.new(0, 35, 0, 35); CloseButton.Position = UDim2.new(1, -40, 0, 5); CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0); CloseButton.Font = Enum.Font.SourceSansBold; CloseButton.Text = "X"; CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255); CloseButton.TextSize = 24; local CloseButtonCorner = Instance.new("UICorner"); CloseButtonCorner.CornerRadius = UDim.new(0, 4); CloseButtonCorner.Parent = CloseButton
local function createPurpleButton(parent, text, size, position) local b = Instance.new("TextButton"); b.Parent = parent; b.Name = text:gsub(" ", "") .. "Button"; b.Text = text; b.Size = size; b.Position = position; b.BackgroundColor3 = Color3.fromRGB(118, 58, 142); b.Font = Enum.Font.SourceSansBold; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.TextSize = 16; local c = Instance.new("UICorner"); c.Name = "Corner"; c.CornerRadius = UDim.new(0, 4); c.Parent = b; local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(200, 120, 220); s.Thickness = 1.5; s.Parent = b; return b end
local WaypointsTabButton = createPurpleButton(MainFrame, "Waypoints", UDim2.new(0, 90, 0, 25), UDim2.new(1, -300, 0, 60))
local PlayersTabButton = createPurpleButton(MainFrame, "Players", UDim2.new(0, 90, 0, 25), UDim2.new(1, -200, 0, 60))
local SettingsTabButton = createPurpleButton(MainFrame, "Settings", UDim2.new(0, 90, 0, 25), UDim2.new(1, -100, 0, 60))
local Content = Instance.new("Frame"); Content.Name = "Content"; Content.Parent = MainFrame; Content.Size = UDim2.new(1, 0, 1, -90); Content.Position = UDim2.new(0, 0, 0, 90); Content.BackgroundTransparency = 1
local WaypointsFrame = Instance.new("Frame"); WaypointsFrame.Name = "WaypointsFrame"; WaypointsFrame.Parent = Content; WaypointsFrame.Size = UDim2.new(1, 0, 1, 0); WaypointsFrame.BackgroundTransparency = 1
local PlayersFrame = Instance.new("Frame"); PlayersFrame.Name = "PlayersFrame"; PlayersFrame.Parent = Content; PlayersFrame.Size = UDim2.new(1, 0, 1, 0); PlayersFrame.BackgroundTransparency = 1; PlayersFrame.Visible = false
local SettingsFrame = Instance.new("Frame"); SettingsFrame.Name = "SettingsFrame"; SettingsFrame.Parent = Content; SettingsFrame.Size = UDim2.new(1, 0, 1, 0); SettingsFrame.BackgroundTransparency = 1; SettingsFrame.Visible = false
-- Populate WaypointsFrame
local WaypointNameBox=Instance.new("TextBox");WaypointNameBox.Name="WaypointNameBox";WaypointNameBox.Parent=WaypointsFrame;WaypointNameBox.Size=UDim2.new(0,300,0,30);WaypointNameBox.Position=UDim2.new(0,25,0,10);WaypointNameBox.BackgroundColor3=Color3.fromRGB(45,45,45);WaypointNameBox.PlaceholderText="Name a way point here to save";WaypointNameBox.TextColor3=Color3.fromRGB(255,255,255);WaypointNameBox.TextSize=16;local WNBCorner=Instance.new("UICorner");WNBCorner.CornerRadius=UDim.new(0,4);WNBCorner.Parent=WaypointNameBox
local AddWaypointButton=createPurpleButton(WaypointsFrame,"Add waypoint",UDim2.new(0,100,0,25),UDim2.new(0,25,0,50));local TeleportToWPButton=createPurpleButton(WaypointsFrame,"Teleport to WP",UDim2.new(0,110,0,25),UDim2.new(0,135,0,50));local RemoveWaypointButton=createPurpleButton(WaypointsFrame,"Remove waypoint",UDim2.new(0,120,0,25),UDim2.new(0,255,0,50));local SaveWaypointButton=createPurpleButton(WaypointsFrame,"Save Waypoint",UDim2.new(0,120,0,25),UDim2.new(0,25,0,85));local LoadAllWaypointButton=createPurpleButton(WaypointsFrame,"Load All Waypoint",UDim2.new(0,140,0,25),UDim2.new(0,155,0,85));local DisplayHeader=Instance.new("TextLabel");DisplayHeader.Name="DisplayHeader";DisplayHeader.Parent=WaypointsFrame;DisplayHeader.Size=UDim2.new(1,0,0,40);DisplayHeader.Position=UDim2.new(0,0,0,120);DisplayHeader.BackgroundTransparency=1;DisplayHeader.Font=Enum.Font.Bangers;DisplayHeader.Text="WAVE POINT HERE TO SAVE";DisplayHeader.TextColor3=Color3.fromRGB(65,90,225);DisplayHeader.TextSize=36
local WaypointList=Instance.new("ScrollingFrame");WaypointList.Name="WaypointList";WaypointList.Parent=WaypointsFrame;WaypointList.Size=UDim2.new(0,500,0,150);WaypointList.Position=UDim2.new(0.5,0,0,170);WaypointList.AnchorPoint=Vector2.new(0.5,0);WaypointList.BackgroundColor3=Color3.fromRGB(20,20,20);local WaypointListStroke=Instance.new("UIStroke");WaypointListStroke.Color=Color3.fromRGB(70,200,220);WaypointListStroke.Thickness=2;WaypointListStroke.Parent=WaypointList;local listLayout=Instance.new("UIListLayout");listLayout.Padding=UDim.new(0,5);listLayout.SortOrder=Enum.SortOrder.LayoutOrder;listLayout.Parent=WaypointList
local DownloadAGameButton=createPurpleButton(WaypointsFrame,"Download a game",UDim2.new(0,150,0,40),UDim2.new(0,25,0,360));local InfiniteYieldButton=createPurpleButton(WaypointsFrame,"Infinite yield",UDim2.new(0,150,0,40),UDim2.new(0,25,0,410));local CarSpeedHacksButton=createPurpleButton(WaypointsFrame,"Car speed hacks",UDim2.new(0,150,0,40),UDim2.new(0,25,0,460));local DownloadWaypointButton=createPurpleButton(WaypointsFrame,"download waypoint",UDim2.new(0,150,0,40),UDim2.new(1,-175,0,385));local UploadWaypointFileButton=createPurpleButton(WaypointsFrame,"Upload way point file",UDim2.new(0,150,0,40),UDim2.new(1,-175,0,435));local DonateButton=createPurpleButton(WaypointsFrame,"Please donate",UDim2.new(0,100,0,100),UDim2.new(1,-135,0,50));DonateButton.TextWrapped=true;DonateButton.TextSize=18;DonateButton.Corner.CornerRadius=UDim.new(1,0)
local FoxImage=Instance.new("ImageLabel");FoxImage.Name="FoxImage";FoxImage.Parent=WaypointsFrame;FoxImage.Size=UDim2.new(0,180,0,150);FoxImage.Position=UDim2.new(0.5,0,1,-5);FoxImage.AnchorPoint=Vector2.new(0.5,1);FoxImage.BackgroundTransparency=1;FoxImage.Image="rbxassetid://6399329292"
-- Populate PlayersFrame
local PlayerListLabel=Instance.new("TextLabel");PlayerListLabel.Parent=PlayersFrame;PlayerListLabel.Text="Players";PlayerListLabel.Position=UDim2.new(0,10,0,0);PlayerListLabel.Size=UDim2.new(0,100,0,20);PlayerListLabel.BackgroundTransparency=1;PlayerListLabel.TextColor3=Color3.fromRGB(255,255,255);PlayerListLabel.Font=Enum.Font.SourceSansBold
local PlayerList=Instance.new("ScrollingFrame");PlayerList.Parent=PlayersFrame;PlayerList.Size=UDim2.new(0,300,0,200);PlayerList.Position=UDim2.new(0,10,0,25);PlayerList.BackgroundColor3=Color3.fromRGB(20,20,20);PlayerList.BorderColor3=Color3.fromRGB(118,58,142);local pl=Instance.new("UIListLayout");pl.Padding=UDim.new(0,2);pl.Parent=PlayerList
local TeamListLabel=Instance.new("TextLabel");TeamListLabel.Parent=PlayersFrame;TeamListLabel.Text="teams";TeamListLabel.Position=UDim2.new(0,10,0,250);TeamListLabel.Size=UDim2.new(0,100,0,20);TeamListLabel.BackgroundTransparency=1;TeamListLabel.TextColor3=Color3.fromRGB(255,255,255);TeamListLabel.Font=Enum.Font.SourceSansBold
local TeamList=Instance.new("ScrollingFrame");TeamList.Parent=PlayersFrame;TeamList.Size=UDim2.new(0,300,0,150);TeamList.Position=UDim2.new(0,10,0,275);TeamList.BackgroundColor3=Color3.fromRGB(20,20,20);TeamList.BorderColor3=Color3.fromRGB(118,58,142);local tl=Instance.new("UIListLayout");tl.Padding=UDim.new(0,2);tl.Parent=TeamList
local pBtnContainer=Instance.new("Frame");pBtnContainer.Parent=PlayersFrame;pBtnContainer.Size=UDim2.new(0,150,0,200);pBtnContainer.Position=UDim2.new(1,-160,0,25);pBtnContainer.BackgroundTransparency=1;local pbl=Instance.new("UIListLayout");pbl.Padding=UDim.new(0,10);pbl.Parent=pBtnContainer
local TeleportToPlayerBtn=createPurpleButton(pBtnContainer,"Teleport to",UDim2.new(1,0,0,35),UDim2.new());local WhitelistPlayerBtn=createPurpleButton(pBtnContainer,"Whitelist",UDim2.new(1,0,0,35),UDim2.new());local UnwhitelistPlayerBtn=createPurpleButton(pBtnContainer,"unwhitelist",UDim2.new(1,0,0,35),UDim2.new());local FlingPlayerBtn=createPurpleButton(pBtnContainer,"Fling Player",UDim2.new(1,0,0,35),UDim2.new())
local WhitelistTeamBtn=createPurpleButton(PlayersFrame,"Whitelist teams",UDim2.new(0,120,0,25),UDim2.new(0,10,0,435));local UnwhitelistTeamBtn=createPurpleButton(PlayersFrame,"unwhitelist teams",UDim2.new(0,120,0,25),UDim2.new(0,140,0,435))
local VoiceChatUnbanButton = Instance.new("TextButton"); VoiceChatUnbanButton.Name = "VoiceChatUnbanButton"; VoiceChatUnbanButton.Parent = PlayersFrame; VoiceChatUnbanButton.Size = UDim2.new(0, 130, 0, 40); VoiceChatUnbanButton.Position = UDim2.new(0, 320, 0, 310); VoiceChatUnbanButton.BackgroundColor3 = Color3.fromRGB(0, 160, 255); VoiceChatUnbanButton.Font = Enum.Font.SourceSansBold; VoiceChatUnbanButton.Text = "Voice chat unban"; VoiceChatUnbanButton.TextColor3 = Color3.fromRGB(255, 255, 255); VoiceChatUnbanButton.TextSize = 16; local VCUBCorner = Instance.new("UICorner"); VCUBCorner.CornerRadius = UDim.new(0, 4); VCUBCorner.Parent = VoiceChatUnbanButton;
-- Populate SettingsFrame
local function createSetting(parent, text, yPos) local container = Instance.new("Frame"); container.Size = UDim2.new(1, -20, 0, 30); container.Position = UDim2.new(0, 10, 0, yPos); container.BackgroundTransparency = 1; container.Parent = parent; local label = Instance.new("TextLabel"); label.Size = UDim2.new(0, 150, 1, 0); label.BackgroundTransparency = 1; label.Font = Enum.Font.SourceSansBold; label.Text = text; label.TextColor3 = Color3.fromRGB(220, 220, 220); label.TextSize = 18; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = container; local textbox = Instance.new("TextBox"); textbox.Size = UDim2.new(1, -240, 1, 0); textbox.Position = UDim2.new(0, 160, 0, 0); textbox.BackgroundColor3 = Color3.fromRGB(45, 45, 45); textbox.TextColor3 = Color3.fromRGB(255, 255, 255); textbox.TextSize = 16; local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 4); corner.Parent = textbox; textbox.Parent = container; local button = createPurpleButton(container, "Set", UDim2.new(0, 60, 1, 0), UDim2.new(1, -60, 0, 0)); return textbox, button end
local ESPHeader = Instance.new("TextLabel"); ESPHeader.Name = "ESPHeader"; ESPHeader.Parent = SettingsFrame; ESPHeader.Size = UDim2.new(1, 0, 0, 30); ESPHeader.Position = UDim2.new(0, 10, 0, 10); ESPHeader.BackgroundTransparency = 1; ESPHeader.Font = Enum.Font.Bangers; ESPHeader.Text = "ESP Settings"; ESPHeader.TextColor3 = Color3.fromRGB(65, 90, 225); ESPHeader.TextSize = 28; ESPHeader.TextXAlignment = Enum.TextXAlignment.Left
local ESPColorRBox, SetESPColorRButton = createSetting(SettingsFrame, "ESP Color Red (0-255)", 50); local ESPColorGBox, SetESPColorGButton = createSetting(SettingsFrame, "ESP Color Green (0-255)", 90); local ESPColorBBox, SetESPColorBButton = createSetting(SettingsFrame, "ESP Color Blue (0-255)", 130); ESPColorRBox.Text = "255"; ESPColorGBox.Text = "0"; ESPColorBBox.Text = "0"
local ApplyESPColorButton = createPurpleButton(SettingsFrame, "Apply ESP Color", UDim2.new(1, -20, 0, 35), UDim2.new(0, 10, 0, 170))
local PlayerModsHeader = Instance.new("TextLabel"); PlayerModsHeader.Name = "PlayerModsHeader"; PlayerModsHeader.Parent = SettingsFrame; PlayerModsHeader.Size = UDim2.new(1, 0, 0, 30); PlayerModsHeader.Position = UDim2.new(0, 10, 0, 220); PlayerModsHeader.BackgroundTransparency = 1; PlayerModsHeader.Font = Enum.Font.Bangers; PlayerModsHeader.Text = "Player Modifications"; PlayerModsHeader.TextColor3 = Color3.fromRGB(65, 90, 225); PlayerModsHeader.TextSize = 28; PlayerModsHeader.TextXAlignment = Enum.TextXAlignment.Left
local WalkSpeedBox, SetWalkSpeedButton = createSetting(SettingsFrame, "WalkSpeed", 260); local JumpPowerBox, SetJumpPowerButton = createSetting(SettingsFrame, "JumpPower", 300); WalkSpeedBox.Text = tostring(defaultWalkSpeed); JumpPowerBox.Text = tostring(defaultJumpPower)
local ResetPlayerStatsButton = createPurpleButton(SettingsFrame, "Reset to Default", UDim2.new(1, -20, 0, 35), UDim2.new(0, 10, 0, 340))
-- Draggable Logic
local dragging,dragStart,startPos=false,nil,nil;MainFrame.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging,dragStart,startPos=true,input.Position,MainFrame.Position;input.Changed:Connect(function()if input.UserInputState==Enum.UserInputState.End then dragging=false end end)end end);UserInputService.InputChanged:Connect(function(input)if(input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch)and dragging then local delta=input.Position-dragStart;MainFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)end end)

-- =================================================================================
-- == SECTION 3: BACKEND FUNCTIONALITY
-- =================================================================================
local function executeScript(url) if not url or url == "" then return end; pcall(function() loadstring(game:HttpGet(url, true))() end) end
-- ESP Rendering Loop
RunService.RenderStepped:Connect(function()for p,h in pairs(espHighlights)do if not p or not p.Parent then h:Destroy();espHighlights[p]=nil end end;for _,tP in ipairs(PlayersService:GetPlayers())do local w=playerWhitelist[tP.Name]or(tP.Team and teamWhitelist[tP.Team.Name]);if tP~=player and tP.Character and w then local c=tP.Character;if not espHighlights[tP]then local h=Instance.new("Highlight");h.FillColor=espColor;h.OutlineColor=Color3.fromRGB(255,255,255);h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.FillTransparency=0.5;h.Parent=c;espHighlights[tP]=h end elseif espHighlights[tP]then espHighlights[tP]:Destroy();espHighlights[tP]=nil end end end)
-- List Update Functions
function updateWaypointList() for _,c in ipairs(WaypointList:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end;for i,w in ipairs(savedWaypoints)do local b=Instance.new("TextButton");b.Size=UDim2.new(1,-10,0,30);b.Text="  "..w.name;b.Font=Enum.Font.SourceSansBold;b.TextSize=18;b.TextXAlignment=Enum.TextXAlignment.Left;b.Parent=WaypointList;if i==selectedWaypointIndex then b.BackgroundColor3=Color3.fromRGB(65,90,225);b.TextColor3=Color3.fromRGB(255,255,255)else b.BackgroundColor3=Color3.fromRGB(45,45,45);b.TextColor3=Color3.fromRGB(220,220,220)end;b.MouseButton1Click:Connect(function()selectedWaypointIndex=i;updateWaypointList()end)end end
function updatePlayerList() for _,c in ipairs(PlayerList:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end;for _,p in ipairs(PlayersService:GetPlayers())do if p~=player then local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,0,40);b.Text="  "..p.Name;b.TextXAlignment=Enum.TextXAlignment.Left;b.Parent=PlayerList;b.TextSize=18;b.TextColor3=Color3.fromRGB(255,50,50);b.Font=Enum.Font.SourceSansBold;local a=Instance.new("ImageLabel");a.Size=UDim2.new(0,36,0,36);a.Position=UDim2.new(1,-38,0.5,-18);local t,s=Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48;local cont,r=PlayersService:GetUserThumbnailAsync(p.UserId,t,s);if r then a.Image=cont end;a.Parent=b;if p==selectedPlayer then b.BackgroundColor3=Color3.fromRGB(65,90,225)else b.BackgroundColor3=Color3.fromRGB(45,45,45)end;b.MouseButton1Click:Connect(function()selectedPlayer=p;updatePlayerList()end)end end end
function updateTeamList() for _,c in ipairs(TeamList:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end;for _,t in ipairs(TeamsService:GetTeams())do local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,0,30);b.Text="  "..t.Name;b.TextColor3=t.TeamColor.Color;b.TextXAlignment=Enum.TextXAlignment.Left;b.Parent=TeamList;if t==selectedTeam then b.BackgroundColor3=Color3.fromRGB(65,90,225)else b.BackgroundColor3=Color3.fromRGB(45,45,45)end;b.MouseButton1Click:Connect(function()selectedTeam=t;updateTeamList()end)end end

-- =================================================================================
-- == SECTION 4: BUTTON CONNECTIONS
-- =================================================================================
WaypointsTabButton.MouseButton1Click:Connect(function()WaypointsFrame.Visible=true;PlayersFrame.Visible=false; SettingsFrame.Visible = false end)
PlayersTabButton.MouseButton1Click:Connect(function()WaypointsFrame.Visible=false;PlayersFrame.Visible=true; SettingsFrame.Visible = false; updatePlayerList();updateTeamList()end)
SettingsTabButton.MouseButton1Click:Connect(function()WaypointsFrame.Visible=false;PlayersFrame.Visible=false; SettingsFrame.Visible = true end)
AddWaypointButton.MouseButton1Click:Connect(function()local n=WaypointNameBox.Text;if n~=""and player.Character and player.Character.PrimaryPart then local p={player.Character.PrimaryPart.CFrame:GetComponents()};table.insert(savedWaypoints,{name=n,position=p});WaypointNameBox.Text="";updateWaypointList()end end)
TeleportToWPButton.MouseButton1Click:Connect(function()if selectedWaypointIndex and savedWaypoints[selectedWaypointIndex]then local w=savedWaypoints[selectedWaypointIndex];if player.Character and player.Character:FindFirstChild("HumanoidRootPart")then pcall(function()player.Character.HumanoidRootPart.CFrame=CFrame.new(table.unpack(w.position))end)end end end)
RemoveWaypointButton.MouseButton1Click:Connect(function()if selectedWaypointIndex and savedWaypoints[selectedWaypointIndex]then table.remove(savedWaypoints,selectedWaypointIndex);selectedWaypointIndex=nil;updateWaypointList()end end)
SaveWaypointButton.MouseButton1Click:Connect(function()if writefile then pcall(function()writefile(saveFileName,HttpService:JSONEncode(savedWaypoints))end)end end)
LoadAllWaypointButton.MouseButton1Click:Connect(function()if isfile and readfile and isfile(saveFileName)then pcall(function()local d=HttpService:JSONDecode(readfile(saveFileName));if type(d)=="table"then selectedWaypointIndex=nil;savedWaypoints=d;updateWaypointList()end end)end end)
TeleportToPlayerBtn.MouseButton1Click:Connect(function()if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character.PrimaryPart then player.Character.PrimaryPart.CFrame=selectedPlayer.Character.PrimaryPart.CFrame end end)
WhitelistPlayerBtn.MouseButton1Click:Connect(function()if selectedPlayer then playerWhitelist[selectedPlayer.Name]=true end end)
UnwhitelistPlayerBtn.MouseButton1Click:Connect(function()if selectedPlayer then playerWhitelist[selectedPlayer.Name]=nil end end)

-- [[ NEW FLING PLAYER START ]] --
FlingPlayerBtn.MouseButton1Click:Connect(function()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = selectedPlayer.Character.HumanoidRootPart
        
        -- Clean up any old fling mechanics just in case
        for _, v in pairs(rootPart:GetChildren()) do
            if v:IsA("BodyMover") then
                v:Destroy()
            end
        end

        local flingVelocity = Instance.new("BodyVelocity")
        flingVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flingVelocity.Velocity = Vector3.new(0, 50000, 0) -- Extreme upward velocity
        flingVelocity.Parent = rootPart
        -- Note: No Debris service is used. This effect is permanent until the character respawns.
    end
end)
-- [[ NEW FLING PLAYER END ]] --

WhitelistTeamBtn.MouseButton1Click:Connect(function()if selectedTeam then teamWhitelist[selectedTeam.Name]=true end end)
UnwhitelistTeamBtn.MouseButton1Click:Connect(function()if selectedTeam then teamWhitelist[selectedTeam.Name]=nil end end)
DownloadAGameButton.MouseButton1Click:Connect(function()pcall(function()local p={RepoURL="https://raw.githubusercontent.com/luau/SynSaveInstance/main/",SSI="saveinstance"};local s=loadstring(game:HttpGet(p.RepoURL..p.SSI..".luau",true),p.SSI)();s({})end)end)
DonateButton.MouseButton1Click:Connect(function()executeScript('https://raw.githubusercontent.com/CF-Trail/tzechco-PlsDonateAutofarmBackup/main/old.lua')end)
InfiniteYieldButton.MouseButton1Click:Connect(function()executeScript("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")end)
CarSpeedHacksButton.MouseButton1Click:Connect(function()executeScript("https://pastebin.com/raw/GypV3c3V")end)
CloseButton.MouseButton1Click:Connect(function()WaypointGUI:Destroy()end)
DownloadWaypointButton.MouseButton1Click:Connect(function()local cF=Instance.new("Frame");cF.Size=UDim2.new(0,400,0,200);cF.Position=UDim2.new(0.5,-200,0.5,-100);cF.BackgroundColor3=Color3.fromRGB(40,40,40);cF.Parent=MainFrame;local cT=Instance.new("TextLabel");cT.Size=UDim2.new(1,0,0,30);cT.BackgroundTransparency=1;cT.Text="Copy Your Waypoint Data Below";cT.TextColor3=Color3.fromRGB(255,255,255);cT.Parent=cF;local cI=Instance.new("TextBox");cI.Size=UDim2.new(1,-20,1,-40);cI.Position=UDim2.new(0,10,0,30);cI.MultiLine=true;cI.Text=HttpService:JSONEncode(savedWaypoints);cI.Parent=cF;cI.FocusLost:Connect(function()cF:Destroy()end)end)
UploadWaypointFileButton.MouseButton1Click:Connect(function()local uF=Instance.new("Frame");uF.Size=UDim2.new(0,400,0,200);uF.Position=UDim2.new(0.5,-200,0.5,-100);uF.BackgroundColor3=Color3.fromRGB(40,40,40);uF.Parent=MainFrame;local uT=Instance.new("TextLabel");uT.Size=UDim2.new(1,0,0,30);uT.BackgroundTransparency=1;uT.Text="Paste Waypoint Data Below";uT.TextColor3=Color3.fromRGB(255,255,255);uT.Parent=uF;local uI=Instance.new("TextBox");uI.Size=UDim2.new(1,-20,1,-70);uI.Position=UDim2.new(0,10,0,30);uI.MultiLine=true;uI.PlaceholderText="Paste data here...";uI.Parent=uF;local sB=createPurpleButton(uF,"Load",UDim2.new(0.5,-10,0,30),UDim2.new(0,10,1,-35));local cB=createPurpleButton(uF,"Cancel",UDim2.new(0.5,-10,0,30),UDim2.new(0.5,0,1,-35));cB.MouseButton1Click:Connect(function()uF:Destroy()end);sB.MouseButton1Click:Connect(function()local s,d=pcall(function()return HttpService:JSONDecode(uI.Text)end);if s and type(d)=="table"then selectedWaypointIndex=nil;savedWaypoints=d;updateWaypointList();uF:Destroy()else warn("Invalid data!")end end)end)
VoiceChatUnbanButton.MouseButton1Click:Connect(function() pcall(function() game:GetService("VoiceChatService"):Join() end) end)
-- Settings Tab Button Logic
local function updatePlayerStat(stat, value) local num = tonumber(value); if num and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid[stat] = num end end
SetWalkSpeedButton.MouseButton1Click:Connect(function() updatePlayerStat("WalkSpeed", WalkSpeedBox.Text) end)
SetJumpPowerButton.MouseButton1Click:Connect(function() updatePlayerStat("JumpPower", JumpPowerBox.Text) end)
ResetPlayerStatsButton.MouseButton1Click:Connect(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = defaultWalkSpeed; player.Character.Humanoid.JumpPower = defaultJumpPower; WalkSpeedBox.Text = tostring(defaultWalkSpeed); JumpPowerBox.Text = tostring(defaultJumpPower) end end)
ApplyESPColorButton.MouseButton1Click:Connect(function() local r = math.clamp(tonumber(ESPColorRBox.Text) or 255, 0, 255); local g = math.clamp(tonumber(ESPColorGBox.Text) or 0, 0, 255); local b = math.clamp(tonumber(ESPColorBBox.Text) or 0, 0, 255); espColor = Color3.fromRGB(r, g, b) end)

-- =================================================================================
-- == SECTION 5: INITIALIZATION
-- =================================================================================
wait(0.5); LoadAllWaypointButton.MouseButton1Click:Wait(); print("V.I.N.N.Y's Definitive Suite Initialized.")
