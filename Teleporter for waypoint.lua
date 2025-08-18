-- =================================================================================
-- == Final All-in-One Exploit & Waypoint GUI (V5 - Select-Then-Act Model)
-- == Features a robust selection system, centralized controls, and updated scripts.
-- =================================================================================

-- Services
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer

-- State Management & Data
local savedWaypoints = {}
local selectedWaypointIndex = nil -- This variable is crucial for tracking the selected item.
local saveFileName = "MyWaypoints_V5.json"

-- =================================================================================
-- == SECTION 1: GUI AND FRAMEWORK (Unchanged from your provided code)
-- =================================================================================

local WaypointGUI=Instance.new("ScreenGui");WaypointGUI.Name="WaypointGUI";WaypointGUI.Parent=player:WaitForChild("PlayerGui");WaypointGUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
local MainFrame=Instance.new("Frame");MainFrame.Name="MainFrame";MainFrame.Parent=WaypointGUI;MainFrame.AnchorPoint=Vector2.new(0.5,0.5);MainFrame.Position=UDim2.new(0.5,0,0.5,0);MainFrame.Size=UDim2.new(0,550,0,600);MainFrame.BackgroundColor3=Color3.fromRGB(30,30,30);MainFrame.BorderColor3=Color3.fromRGB(80,80,80);MainFrame.BorderSizePixel=2;MainFrame.Active=true;MainFrame.Selectable=true;local MainFrameCorner=Instance.new("UICorner");MainFrameCorner.CornerRadius=UDim.new(0,8);MainFrameCorner.Parent=MainFrame
local TitleLabel=Instance.new("TextLabel");TitleLabel.Name="TitleLabel";TitleLabel.Parent=MainFrame;TitleLabel.Size=UDim2.new(1,0,0,50);TitleLabel.Position=UDim2.new(0,0,0,10);TitleLabel.BackgroundTransparency=1;TitleLabel.Font=Enum.Font.Bangers;TitleLabel.Text="Save way point";TitleLabel.TextColor3=Color3.fromRGB(70,200,220);TitleLabel.TextSize=48
local SubtitleLabel=Instance.new("TextLabel");SubtitleLabel.Name="SubtitleLabel";SubtitleLabel.Parent=MainFrame;SubtitleLabel.Size=UDim2.new(0,200,0,30);SubtitleLabel.Position=UDim2.new(0,25,0,60);SubtitleLabel.BackgroundTransparency=1;SubtitleLabel.Font=Enum.Font.Bangers;SubtitleLabel.Text="MADE BY VINNY";SubtitleLabel.TextColor3=Color3.fromRGB(65,90,225);SubtitleLabel.TextSize=28
local CloseButton=Instance.new("TextButton");CloseButton.Name="CloseButton";CloseButton.Parent=MainFrame;CloseButton.Size=UDim2.new(0,35,0,35);CloseButton.Position=UDim2.new(1,-40,0,5);CloseButton.BackgroundColor3=Color3.fromRGB(255,0,0);CloseButton.Font=Enum.Font.SourceSansBold;CloseButton.Text="X";CloseButton.TextColor3=Color3.fromRGB(255,255,255);CloseButton.TextSize=24;local CloseButtonCorner=Instance.new("UICorner");CloseButtonCorner.CornerRadius=UDim.new(0,4);CloseButtonCorner.Parent=CloseButton
local WaypointNameBox=Instance.new("TextBox");WaypointNameBox.Name="WaypointNameBox";WaypointNameBox.Parent=MainFrame;WaypointNameBox.Size=UDim2.new(0,300,0,30);WaypointNameBox.Position=UDim2.new(0,25,0,100);WaypointNameBox.BackgroundColor3=Color3.fromRGB(45,45,45);WaypointNameBox.BorderColor3=Color3.fromRGB(150,150,150);WaypointNameBox.Font=Enum.Font.SourceSans;WaypointNameBox.PlaceholderText="Name a way point here to save";WaypointNameBox.TextColor3=Color3.fromRGB(255,255,255);WaypointNameBox.TextSize=16;local WaypointNameBoxCorner=Instance.new("UICorner");WaypointNameBoxCorner.CornerRadius=UDim.new(0,4);WaypointNameBoxCorner.Parent=WaypointNameBox
local function createPurpleButton(parent,text,size,position)local button=Instance.new("TextButton");button.Parent=parent;button.Name=text:gsub(" ","").."Button";button.Text=text;button.Size=size;button.Position=position;button.BackgroundColor3=Color3.fromRGB(118,58,142);button.Font=Enum.Font.SourceSansBold;button.TextColor3=Color3.fromRGB(255,255,255);button.TextSize=16;local corner=Instance.new("UICorner");corner.Name="Corner";corner.CornerRadius=UDim.new(0,4);corner.Parent=button;local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(200,120,220);stroke.Thickness=1.5;stroke.Parent=button;return button end
local AddWaypointButton=createPurpleButton(MainFrame,"Add waypoint",UDim2.new(0,100,0,25),UDim2.new(0,25,0,140))
local TeleportToWPButton=createPurpleButton(MainFrame,"Teleport to WP",UDim2.new(0,110,0,25),UDim2.new(0,135,0,140))
local RemoveWaypointButton=createPurpleButton(MainFrame,"Remove waypoint",UDim2.new(0,120,0,25),UDim2.new(0,255,0,140))
local SaveWaypointButton=createPurpleButton(MainFrame,"Save Waypoint",UDim2.new(0,120,0,25),UDim2.new(0,25,0,175))
local LoadAllWaypointButton=createPurpleButton(MainFrame,"Load All Waypoint",UDim2.new(0,140,0,25),UDim2.new(0,155,0,175))
local WaypointsTabButton=createPurpleButton(MainFrame,"Waypoints",UDim2.new(0,90,0,25),UDim2.new(0,335,0,102.5))
local DownloadAGameButton=createPurpleButton(MainFrame,"Download a game",UDim2.new(0,150,0,40),UDim2.new(0,25,0,450))
local InfiniteYieldButton=createPurpleButton(MainFrame,"Infinite yield",UDim2.new(0,150,0,40),UDim2.new(0,25,0,500))
local CarSpeedHacksButton=createPurpleButton(MainFrame,"Car speed hacks",UDim2.new(0,150,0,40),UDim2.new(0,25,0,550))
local DownloadWaypointButton=createPurpleButton(MainFrame,"download waypoint",UDim2.new(0,150,0,40),UDim2.new(1,-175,0,475))
local UploadWaypointFileButton=createPurpleButton(MainFrame,"Upload way point file",UDim2.new(0,150,0,40),UDim2.new(1,-175,0,525))
local DonateButton=createPurpleButton(MainFrame,"Please donate",UDim2.new(0,100,0,100),UDim2.new(1,-135,0,140));DonateButton.TextWrapped=true;DonateButton.TextSize=18;DonateButton.Corner.CornerRadius=UDim.new(1,0)
local DisplayHeader=Instance.new("TextLabel");DisplayHeader.Name="DisplayHeader";DisplayHeader.Parent=MainFrame;DisplayHeader.Size=UDim2.new(1,0,0,40);DisplayHeader.Position=UDim2.new(0,0,0,210);DisplayHeader.BackgroundTransparency=1;DisplayHeader.Font=Enum.Font.Bangers;DisplayHeader.Text="WAVE POINT HERE TO SAVE";DisplayHeader.TextColor3=Color3.fromRGB(65,90,225);DisplayHeader.TextSize=36
local WaypointList=Instance.new("ScrollingFrame");WaypointList.Name="WaypointList";WaypointList.Parent=MainFrame;WaypointList.Size=UDim2.new(0,500,0,150);WaypointList.Position=UDim2.new(0.5,0,0,260);WaypointList.AnchorPoint=Vector2.new(0.5,0);WaypointList.BackgroundColor3=Color3.fromRGB(20,20,20);local WaypointListStroke=Instance.new("UIStroke");WaypointListStroke.Color=Color3.fromRGB(70,200,220);WaypointListStroke.Thickness=2;WaypointListStroke.Parent=WaypointList;local listLayout=Instance.new("UIListLayout");listLayout.Padding=UDim.new(0,5);listLayout.SortOrder=Enum.SortOrder.LayoutOrder;listLayout.Parent=WaypointList
local FoxImage=Instance.new("ImageLabel");FoxImage.Name="FoxImage";FoxImage.Parent=MainFrame;FoxImage.Size=UDim2.new(0,180,0,150);FoxImage.Position=UDim2.new(0.5,0,1,-110);FoxImage.AnchorPoint=Vector2.new(0.5,1);FoxImage.BackgroundTransparency=1;FoxImage.Image="rbxassetid://6399329292"
local dragging,dragStart,startPos=false,nil,nil;MainFrame.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging,dragStart,startPos=true,input.Position,MainFrame.Position;input.Changed:Connect(function()if input.UserInputState==Enum.UserInputState.End then dragging=false end end)end end);UserInputService.InputChanged:Connect(function(input)if(input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch)and dragging then local delta=input.Position-dragStart;MainFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)end end)

-- =================================================================================
-- == SECTION 2: BACKEND FUNCTIONALITY (Select-Then-Act Model)
-- =================================================================================

local function executeScript(url) if not url or url == "" then return end; pcall(function() loadstring(game:HttpGet(url, true))() end) end

-- RE-ENGINEERED: This function now handles selection highlighting.
function updateWaypointList()
	for _, child in ipairs(WaypointList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
	
	for index, waypointData in ipairs(savedWaypoints) do
		local selectButton = Instance.new("TextButton")
		selectButton.Size = UDim2.new(1, -10, 0, 30)
		selectButton.Text = "  " .. waypointData.name
		selectButton.Font = Enum.Font.SourceSansBold
		selectButton.TextSize = 18
		selectButton.TextXAlignment = Enum.TextXAlignment.Left
		selectButton.Parent = WaypointList
		
		-- Visual feedback for selection
		if index == selectedWaypointIndex then
			selectButton.BackgroundColor3 = Color3.fromRGB(65, 90, 225) -- Highlight color
			selectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			selectButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Default color
			selectButton.TextColor3 = Color3.fromRGB(220, 220, 220)
		end
		
		-- The button's only job is to set the selected index.
		selectButton.MouseButton1Click:Connect(function()
			selectedWaypointIndex = index
			updateWaypointList() -- Redraw the list to show the new selection
		end)
	end
end

-- =================================================================================
-- == SECTION 3: BUTTON CONNECTIONS (Updated Logic)
-- =================================================================================

AddWaypointButton.MouseButton1Click:Connect(function()
	local name=WaypointNameBox.Text;if name~=""and player.Character and player.Character.PrimaryPart then local pos={player.Character.PrimaryPart.CFrame:GetComponents()};table.insert(savedWaypoints,{name=name,position=pos});WaypointNameBox.Text="";updateWaypointList()end
end)

-- NEW LOGIC: Acts on the selected waypoint.
TeleportToWPButton.MouseButton1Click:Connect(function()
	if selectedWaypointIndex and savedWaypoints[selectedWaypointIndex] then
		local waypointData = savedWaypoints[selectedWaypointIndex]
		print("Teleporting to selected waypoint:", waypointData.name)
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			pcall(function() player.Character.HumanoidRootPart.CFrame = CFrame.new(table.unpack(waypointData.position)) end)
		end
	else
		print("No waypoint selected to teleport to.")
	end
end)

-- NEW LOGIC: Removes the selected waypoint from the list.
RemoveWaypointButton.MouseButton1Click:Connect(function()
	if selectedWaypointIndex and savedWaypoints[selectedWaypointIndex] then
		print("Removing selected waypoint:", savedWaypoints[selectedWaypointIndex].name)
		table.remove(savedWaypoints, selectedWaypointIndex)
		selectedWaypointIndex = nil -- Deselect after removing
		updateWaypointList()
	else
		print("No waypoint selected to remove.")
	end
end)

SaveWaypointButton.MouseButton1Click:Connect(function()
	if writefile then local s,e=pcall(function()return HttpService:JSONEncode(savedWaypoints)end);if s then writefile(saveFileName,e);print("Waypoints saved:",saveFileName)else warn("Encode failed:",e)end else warn("'writefile' unavailable.")end
end)
LoadAllWaypointButton.MouseButton1Click:Connect(function()
	if isfile and readfile and isfile(saveFileName) then local s,d=pcall(function()return HttpService:JSONDecode(readfile(saveFileName))end);if s and type(d)=="table"then selectedWaypointIndex=nil;savedWaypoints=d;updateWaypointList();print("Waypoints loaded:",saveFileName)else warn("Decode failed:",d)end else print("No save file found.")end
end)

-- UPDATED SCRIPT: For "Download a game"
DownloadAGameButton.MouseButton1Click:Connect(function()
	pcall(function()
		local Params = {RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/", SSI = "saveinstance"}
		local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
		synsaveinstance({}) -- Execute with default options
	end)
end)

-- UPDATED SCRIPT: For "Please donate"
DonateButton.MouseButton1Click:Connect(function() executeScript('https://raw.githubusercontent.com/CF-Trail/tzechco-PlsDonateAutofarmBackup/main/old.lua') end)

-- Unchanged Buttons
InfiniteYieldButton.MouseButton1Click:Connect(function() executeScript("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source") end)
CarSpeedHacksButton.MouseButton1Click:Connect(function() executeScript("https://pastebin.com/raw/GypV3c3V") end)
CloseButton.MouseButton1Click:Connect(function() WaypointGUI:Destroy() end)
DownloadWaypointButton.MouseButton1Click:Connect(function() local cF=Instance.new("Frame");cF.Size=UDim2.new(0,400,0,200);cF.Position=UDim2.new(0.5,-200,0.5,-100);cF.BackgroundColor3=Color3.fromRGB(40,40,40);cF.Parent=MainFrame;local cT=Instance.new("TextLabel");cT.Size=UDim2.new(1,0,0,30);cT.BackgroundTransparency=1;cT.Text="Copy Your Waypoint Data Below";cT.TextColor3=Color3.fromRGB(255,255,255);cT.Parent=cF;local cI=Instance.new("TextBox");cI.Size=UDim2.new(1,-20,1,-40);cI.Position=UDim2.new(0,10,0,30);cI.MultiLine=true;cI.Text=HttpService:JSONEncode(savedWaypoints);cI.Parent=cF;cI.FocusLost:Connect(function()cF:Destroy()end)end)
UploadWaypointFileButton.MouseButton1Click:Connect(function()local uF=Instance.new("Frame");uF.Size=UDim2.new(0,400,0,200);uF.Position=UDim2.new(0.5,-200,0.5,-100);uF.BackgroundColor3=Color3.fromRGB(40,40,40);uF.Parent=MainFrame;local uT=Instance.new("TextLabel");uT.Size=UDim2.new(1,0,0,30);uT.BackgroundTransparency=1;uT.Text="Paste Waypoint Data Below";uT.TextColor3=Color3.fromRGB(255,255,255);uT.Parent=uF;local uI=Instance.new("TextBox");uI.Size=UDim2.new(1,-20,1,-70);uI.Position=UDim2.new(0,10,0,30);uI.MultiLine=true;uI.PlaceholderText="Paste data here...";uI.Parent=uF;local sB=createPurpleButton(uF,"Load",UDim2.new(0.5,-10,0,30),UDim2.new(0,10,1,-35));local cB=createPurpleButton(uF,"Cancel",UDim2.new(0.5,-10,0,30),UDim2.new(0.5,0,1,-35));cB.MouseButton1Click:Connect(function()uF:Destroy()end);sB.MouseButton1Click:Connect(function()local s,d=pcall(function()return HttpService:JSONDecode(uI.Text)end);if s and type(d)=="table"then selectedWaypointIndex=nil;savedWaypoints=d;updateWaypointList();uF:Destroy()else warn("Invalid data!")end end)end)

-- Initial Load
wait(0.5); LoadAllWaypointButton.MouseButton1Click:Wait(); print("V.I.N.N.Y's All-in-One Client (Select-Act Model) Initialized.")