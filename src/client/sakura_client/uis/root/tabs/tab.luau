--#[ Services ]#--
local Player = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local localPlayer = Player.LocalPlayer :: Player
local mouse = localPlayer:GetMouse()

local SakuraStorage = ReplicatedStorage.sakura_storage

local globals = require(SakuraStorage.globals)

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

local TabModule = require(SakuraStorage.modules.tab_module)

--#[ Fusion ]#--
local Fusion = require(Modules.fusion)
local peek = Fusion.peek
local scoped = Fusion.scoped
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange

--#[ Types ]#--
type Fusion = typeof(Fusion)
type UsedAs<T> = Fusion.UsedAs<T>
type Scope<T = Fusion> = Fusion.Scope<T>
type Value<T> = Fusion.Value<T>

export type PositionData = {
	Position: UsedAs<number>;
	SpringSpeed: UsedAs<number>?;
}

export type props = {
	Name: UsedAs<string>?;
	Parent: UsedAs<Instance>?;
	
	Tab: globals.Tab;
	Position: Value<PositionData>;
}

--#[ Variables ]#--
--

--#[ Function ]#--
--

--#[ Main ]#--
return function(
	scope: Scope,
	props: props
)
	local tabs = globals.tabs
	local selectedTab = globals.selectedTab
	local selectedTabIndex = globals.selectedTabIndex
	
	local isHovering = scope:Value(false)
	local isHeldDown = scope:Value(false)
	local isSelected = scope:Value(false)
	local isCloseHovering = scope:Value(false)
	local isCloseHeldDown = scope:Value(false)
	
	local padding = 8;
	local animationSpeed = 60
	
	local zIndexValue = scope:Value(1)

	local selectedTabObserver = scope:Observer(selectedTab):onBind(function()
		local peekedTab = peek(props.Tab)
		local peekedCurrnetTab = peek(selectedTab)

		if peekedCurrnetTab == peekedTab then
			isSelected:set(true)
		else
			isSelected:set(false)
		end
	end)
	
	local draggingConnection: RBXScriptConnection?
	
	local tabButtonColorRest = scope:Computed(function(
		use: Fusion.Use
	)
		return use(globals.theme).primaryBackgroundColor
	end)
	
	local tabButtonColorHeld = scope:Computed(function(
		use: Fusion.Use
	)
		return globals.functions.addNumberToColor3BasedRGB(
			use(globals.theme).primaryBackgroundColor,
			20
		)
	end)
	
	local tabButtonColorHover = scope:Computed(function(
		use: Fusion.Use
	)
		return globals.functions.addNumberToColor3BasedRGB(
			use(globals.theme).primaryBackgroundColor,
			10
		)
	end)
	
	local tabButtonContentColorRest = scope:Computed(function(
		use: Fusion.Use
	)
		return use(globals.theme).primaryContentColor
	end)
	
	local tabButtonContentColorHeld = scope:Computed(function(
		use: Fusion.Use
	)
		return globals.functions.addNumberToColor3BasedRGB(
			use(globals.theme).primaryContentColor,
			10
		)
	end)
	
	local tabButtonContentColorHover = scope:Computed(function(
		use: Fusion.Use
	)
		return globals.functions.addNumberToColor3BasedRGB(
			use(globals.theme).primaryContentColor,
			5
		)
	end)
	
	local tabCloseButtonColorRest = scope:Computed(function(
		use: Fusion.Use
	)
		return use(globals.theme).primaryBackgroundColor
	end)
	
	local tabCloseButtonColorHeld = scope:Computed(function(
		use: Fusion.Use
	)
		return globals.functions.addNumberToColor3BasedRGB(
			use(globals.theme).primaryBackgroundColor,
			60
		)
	end)
	
	local tabCloseButtonColorHover = scope:Computed(function(
		use: Fusion.Use
	)
		return globals.functions.addNumberToColor3BasedRGB(
			use(globals.theme).primaryBackgroundColor,
			30
		)
	end)
	
	local tabCloseButtonContentColorRest = scope:Computed(function(
		use: Fusion.Use
	)
		return use(globals.theme).secondaryContentColor
	end)
	
	local tabCloseButtonContentColorHeld = scope:Computed(function(
		use: Fusion.Use
	)
		return globals.functions.addNumberToColor3BasedRGB(
			use(globals.theme).secondaryContentColor,
			40
		)
	end)
	
	local tabCloseButtonContentColorHover = scope:Computed(function(
		use: Fusion.Use
	)
		return globals.functions.addNumberToColor3BasedRGB(
			use(globals.theme).secondaryContentColor,
			20
		)
	end)
	
	return scope:New "Frame" {
		[OnEvent "InputBegan"] = function(
			inputObject: InputObject
		)
			local peekedDraggingTab = peek(globals.draggingTab)
			
			if peekedDraggingTab and peekedDraggingTab ~= peek(props.Tab) then
				return
			end
			
			if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
				isHovering:set(true)
			elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				isHeldDown:set(true)
				
				local peekedTab = peek(props.Tab)
				local peekedPositionData: PositionData = peek(props.Position)
				local peekedPosition: number = peek(peekedPositionData.Position)
				local peekedTabs = peek(globals.tabs)
				local peekedselectedTab = peek(globals.selectedTab)

				TabModule.selectTab(peekedTab)
				
				if not peek(globals.draggingTab) then
					globals.draggingTab:set(peekedTab)

					local draggingStartPositionY = peekedPosition
					local draggingStartMouseY = mouse.Y
					
					zIndexValue:set(1000)

					draggingConnection = RunService.RenderStepped:Connect(function()
						local delta = mouse.Y - draggingStartMouseY
						
						if delta == 0 then
							return
						end
						
						local peekedPositionData: PositionData = peek(props.Position)
						local peekedPosition: number = peek(peekedPositionData.Position)
						local peekedTabs = peek(globals.tabs)

						local index = math.clamp(
							math.round((peekedPosition - 4) / (40 + 4)) + 1,
							1,
							#peekedTabs
						)
						
						local positionY = draggingStartPositionY + delta;
						local minPositionY = 0
						local maxPositionY = (#peekedTabs - 1) * (40 + padding)
						
						props.Position:set {
							Position = math.clamp(
								positionY,
								minPositionY,
								maxPositionY
							);
							SpringSpeed = 1000;
						}
						
						local foundIndex = table.find(peekedTabs, peekedTab)
						
						if foundIndex and foundIndex ~= index then
							peekedTabs[foundIndex] = peekedTabs[index]
							peekedTabs[index] = peekedTab
							
							globals.tabs:set(peekedTabs)
						end
					end)
				end
			end
		end;
		
		[OnEvent "InputEnded"] = function(
			inputObject: InputObject
		)
			local peekedDraggingTab = peek(globals.draggingTab)

			if peekedDraggingTab and peekedDraggingTab ~= peek(props.Tab) then
				return
			end
			
			if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
				isHovering:set(false)
			elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				isHeldDown:set(false)
				
				local peekedTab = peek(props.Tab)
				local peekedTabs = peek(globals.tabs)
				
				local peekedDraggingTab = peek(globals.draggingTab)
				
				if peekedDraggingTab and peekedDraggingTab == peekedTab then
					globals.draggingTab:set(nil)
					zIndexValue:set(1)
					
					if draggingConnection then
						draggingConnection:Disconnect()
						
						draggingConnection = nil
					end
					
					local foundIndex = table.find(peekedTabs, peekedTab)
					
					if foundIndex then
						props.Position:set {
							Position = (math.clamp(foundIndex, 1, #peekedTabs) - 1) * (40 + padding);
							SpringSpeed = animationSpeed * 4;
						}
					end
				end
			end
		end;
		
		Name = props.Name or props.Tab.url;
		Parent = props.Parent;
		
		AnchorPoint = Vector2.new(0.5, 0.5);
		Position = scope:Spring(
			scope:Computed(function(
				use: Fusion.Use
			)
				local positionData: PositionData = use(props.Position)
				local position: number = peek(positionData.Position)

				return UDim2.new(0.5, 0, 0, position + 20)
			end),
			scope:Computed(function(
				use: Fusion.Use
			)
				local positionData: PositionData = use(props.Position)
				
				return peek(positionData.SpringSpeed) or animationSpeed
			end)
		);
		Size = UDim2.new(1, 0, 0, 40);

		BackgroundColor3 = scope:Spring(
			scope:Computed(function(
				use: Fusion.Use
			)
				if use(globals.addingNewTab) then
					return
						if use(isHovering) then use(tabButtonColorHover)
						else use(tabButtonColorRest)
				else
					return
						if use(isHeldDown) or use(isSelected) then use(tabButtonColorHeld)
						elseif use(isHovering) then use(tabButtonColorHover)
						else use(tabButtonColorRest)
				end
			end),
			animationSpeed
		);
		
		ClipsDescendants = true;
		
		ZIndex = zIndexValue;

		[Children] = {
			scope:New "UIScale" {
				Scale = scope:Spring(
					scope:Computed(function(
						use: Fusion.Use
					)
						return
							if use(isHeldDown) then 0.98
							else 1
					end),
					animationSpeed
				)
			};
			
			scope:New "UICorner" {};

			scope:New "UIPadding" {
				PaddingBottom = UDim.new(0, 8);
				PaddingLeft = UDim.new(0, 8);
				PaddingRight = UDim.new(0, 8);
				PaddingTop = UDim.new(0, 8);
			};

			scope:New "ImageLabel" {
				AnchorPoint = Vector2.new(0, 0.5);
				Position = UDim2.fromScale(0, 0.5);
				Size = UDim2.fromOffset(24, 24);

				BackgroundTransparency = 1;

				Image = scope:Computed(function(
					use: Fusion.Use
				)
					local tab = props.Tab

					return use(tab.icon) or "rbxassetid://110302062292604"
				end);
				ImageColor3 = scope:Spring(
					scope:Computed(function(
						use: Fusion.Use
					)
						local isHeldDown = use(isHeldDown)
						local isHovering = use(isHovering)
						local isSelected = use(isSelected)
						local addingNewTab = use(globals.addingNewTab)
						
						if addingNewTab then
							return
								if isHovering then use(tabButtonContentColorHover)
								else use(tabButtonContentColorRest)
						else
							return
								if isHeldDown or isSelected then use(tabButtonContentColorHeld)
								elseif isHovering then use(tabButtonContentColorHover)
								else use(tabButtonContentColorRest)
						end
					end),
					animationSpeed
				);
			};

			scope:New "TextLabel" {
				AnchorPoint = Vector2.new(0, 0.5);
				Position = UDim2.new(0, 32, 0.5, 0);
				Size = UDim2.new(1, -32, 0, 12);

				BackgroundTransparency = 1;

				Text = scope:Computed(function(
					use: Fusion.Use
				)
					local tab = props.Tab

					return use(tab.title) or use(tab.url)
				end);
				TextColor3 = scope:Spring(
					scope:Computed(function(
						use: Fusion.Use
					)
						local isHeldDown = use(isHeldDown)
						local isHovering = use(isHovering)
						local isSelected = use(isSelected)
						local addingNewTab = use(globals.addingNewTab)

						if addingNewTab then
							return
								if isHovering then use(tabButtonContentColorHover)
								else use(tabButtonContentColorRest)
						else
							return
								if isHeldDown or isSelected then use(tabButtonContentColorHeld)
								elseif isHovering then use(tabButtonContentColorHover)
								else use(tabButtonContentColorRest)
						end
					end),
					animationSpeed
				);
				FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);

				TextXAlignment = Enum.TextXAlignment.Left;
			};

			scope:New "Frame" {
				AnchorPoint = Vector2.new(1, 0.5);
				Position = UDim2.new(1, 8, 0.5, 0);
				Size = scope:Computed(function(
					use: Fusion.Use
				)
					return
						if use(globals.addingNewTab) then UDim2.new(0, 8, 1, 0)
						elseif use(isHeldDown) or use(isHovering) or use(isSelected) then UDim2.new(0, 36, 1, 0)
						else UDim2.new(0, 8, 1, 0)
				end);

				BackgroundColor3 = scope:Spring(
					scope:Computed(function(
						use: Fusion.Use
					)
						if use(globals.addingNewTab) then
							return
								if use(isHovering) then use(tabButtonColorHover)
								else use(tabButtonColorRest)
						else
							return
								if use(isHeldDown) or use(isSelected) then use(tabButtonColorHeld)
								elseif use(isHovering) then use(tabButtonColorHover)
								else use(tabButtonColorRest)
						end
					end),
					animationSpeed
				);

				ZIndex = 5;

				[Children] = scope:New "UIGradient" {
					Transparency = scope:Computed(function(
						use: Fusion.Use
					)
						return
							if use(globals.addingNewTab) then NumberSequence.new {
								NumberSequenceKeypoint.new(0, 0.5);
								NumberSequenceKeypoint.new(0.5, 0.125);
								NumberSequenceKeypoint.new(1, 0);
							}
							elseif use(isHeldDown) or use(isHovering) or use(isSelected) then NumberSequence.new {
								NumberSequenceKeypoint.new(0, 0.5);
								NumberSequenceKeypoint.new(0.111, 0.125);
								NumberSequenceKeypoint.new(0.222, 0);
								NumberSequenceKeypoint.new(1, 0);
							}
							else NumberSequence.new {
								NumberSequenceKeypoint.new(0, 0.5);
								NumberSequenceKeypoint.new(0.5, 0.125);
								NumberSequenceKeypoint.new(1, 0);
							}
					end)
				}
			};
			
			scope:New "ImageButton" {
				[OnEvent "InputBegan"] = function(
					inputObject: InputObject
				)
					local peekedDraggingTab = peek(globals.draggingTab)
					
					if peekedDraggingTab and peekedDraggingTab ~= peek(props.Tab) then
						return
					end
					
					if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
						isCloseHovering:set(true)
					elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
						isCloseHeldDown:set(true)
					end
				end;
				
				[OnEvent "InputEnded"] = function(
					inputObject: InputObject
				)
					local peekedDraggingTab = peek(globals.draggingTab)
					
					if peekedDraggingTab and peekedDraggingTab ~= peek(props.Tab) then
						return
					end
					
					if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
						isCloseHovering:set(false)
						isCloseHeldDown:set(false)
					elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
						isCloseHeldDown:set(false)
					end
				end;

				[OnEvent "MouseButton1Click"] = function()
					local tab = props.Tab

					tab:DestroyAndRemoveFromTabs(true)
				end;
				
				AnchorPoint = Vector2.new(1, 0.5);
				Position = UDim2.fromScale(1, 0.5);
				Size = UDim2.fromOffset(20, 20);
				
				BackgroundColor3 = scope:Spring(
					scope:Computed(function(
						use: Fusion.Use
					)
						if use(globals.addingNewTab) then
							return
								if use(isCloseHeldDown) then use(tabCloseButtonColorHeld)
								elseif use(isCloseHovering) then use(tabCloseButtonColorHover)
								elseif use(isHovering) then use(tabButtonColorHover)
								else use(tabCloseButtonColorRest)
						else
							return
								if use(isHeldDown) then use(tabButtonColorHeld)
								elseif use(isCloseHeldDown) then use(tabCloseButtonColorHeld)
								elseif use(isCloseHovering) then use(tabCloseButtonColorHover)
								elseif use(isSelected) then use(tabButtonColorHeld)
								elseif use(isHovering) then use(tabButtonColorHover)
								else use(tabCloseButtonColorRest)
						end
					end),
					animationSpeed
				);
				BackgroundTransparency = scope:Computed(function(
					use: Fusion.Use
				)
					return
						if use(globals.addingNewTab) then 1
						elseif use(isHovering) or use(isHeldDown) or use(isSelected) then 0
						else 1
				end);
				
				Image = "rbxassetid://113186581619905";
				ImageColor3 = scope:Spring(
					scope:Computed(function(
						use: Fusion.Use
					)
						if use(globals.addingNewTab) then
							return
								if use(isCloseHovering) then use(tabCloseButtonContentColorHover)
								else use(tabCloseButtonContentColorRest)
						else
							return
								if use(isCloseHeldDown) then use(tabCloseButtonContentColorHeld)
								elseif use(isCloseHovering) then use(tabCloseButtonContentColorHover)
								else use(tabCloseButtonContentColorRest)
						end
					end),
					animationSpeed
				);
				ImageTransparency = scope:Computed(function(
					use: Fusion.Use
				)
					return
						if use(globals.addingNewTab) then 1
						elseif use(isHovering) or use(isHeldDown) or use(isSelected) then 0
						else 1
				end);
				
				ZIndex = 15;
				
				[Children] = scope:New "UICorner" {
					CornerRadius = UDim.new(0, 6);
				}
			};
		}
	}
end