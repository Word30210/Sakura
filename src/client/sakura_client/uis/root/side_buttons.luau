--#[ Services ]#--
local Player = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local SakuraStorage = ReplicatedStorage.sakura_storage

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

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

type buttonProps = {
	Content: UsedAs<string>?;
	Icon: UsedAs<string>?;
	
	OnMouseButton1Click: (
		(
			...any
		) -> ()
	)?
}

export type props = {
	Name: UsedAs<string>?;
	Parent: UsedAs<Instance>?;
}

--#[ Variables ]#--
local globals = require(SakuraStorage.globals)

--#[ Function ]#--
--

--#[ Main ]#--
local function button(
	scope: Scope,
	props: buttonProps
)
	local isHovering = scope:Value(false)
	local isHeldDown = scope:Value(false)
	
	local buttonColorRest = scope:Computed(function(
		use: Fusion.Use
	)
		return use(globals.theme).buttonColor
	end)
	
	local buttonColorHover = scope:Computed(function(
		use: Fusion.Use
	)
		return globals.functions.addNumberToColor3BasedRGB(
			use(globals.theme).buttonColor,
			15
		)
	end)
	
	local buttonColorHeld = scope:Computed(function(
		use: Fusion.Use
	)
		return globals.functions.addNumberToColor3BasedRGB(
			use(globals.theme).buttonColor,
			10
		)
	end)
	
	local contentColorRest = scope:Computed(function(
		use: Fusion.Use
	)
		return use(globals.theme).secondaryContentColor
	end)
	
	local contentColorHover = scope:Computed(function(
		use: Fusion.Use
	)
		return globals.functions.addNumberToColor3BasedRGB(
			use(globals.theme).secondaryContentColor,
			15
		)
	end)
	
	local contentColorHeld = scope:Computed(function(
		use: Fusion.Use
	)
		return globals.functions.addNumberToColor3BasedRGB(
			use(globals.theme).secondaryContentColor,
			10
		)
	end)
	
	local animationSpeed = 60
	
	return scope:New "Frame" {
		Size = UDim2.new(0.5, -4, 1, 0);
		
		BackgroundTransparency = 1;

		[Children] = scope:New "Frame" {
			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.fromScale(0.5, 0.5);
			Size = UDim2.fromScale(1, 1);
			
			BackgroundColor3 = scope:Spring(
				scope:Computed(function(
					use: Fusion.Use
				)
					return
						if use(isHeldDown) then use(buttonColorHeld)
						elseif use(isHovering) then use(buttonColorHover)
						else use(buttonColorRest)
				end),
				animationSpeed
			);

			[Children] = {
				scope:New "UICorner" {};
				
				scope:New "UIScale" {
					Scale = scope:Spring(
						scope:Computed(function(
							use: Fusion.Use
						)
							return
								if use(isHeldDown) then 0.95
								elseif use(isHovering) then 1
								else 1
						end),
						animationSpeed
					)
				};

				scope:New "ImageLabel" {
					AnchorPoint = Vector2.new(0.5, 0.5);
					Position = UDim2.new(0.5, 0, 0.5, -10);
					Size = UDim2.fromOffset(24, 24);

					BackgroundTransparency = 1;

					Image = props.Icon;
					ImageColor3 = scope:Spring(
						scope:Computed(function(
							use: Fusion.Use
						)
							return
								if use(isHeldDown) then use(contentColorHeld)
								elseif use(isHovering) then use(contentColorHover)
								else use(contentColorRest)
						end),
						animationSpeed
					);
				};

				scope:New "TextLabel" {
					AnchorPoint = Vector2.new(0.5, 0.5);
					Position = UDim2.new(0.5, 0, 0.5, 13);
					Size = UDim2.new(1, 0, 0, 14);

					BackgroundTransparency = 1;

					Text = props.Content;
					TextColor3 = scope:Spring(
						scope:Computed(function(
							use: Fusion.Use
						)
							return
								if use(isHeldDown) then use(contentColorHeld)
								elseif use(isHovering) then use(contentColorHover)
								else use(contentColorRest)
						end),
						animationSpeed
					);
					FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);

					TextScaled = true;
				};

				scope:New "TextButton" {
					[OnEvent "MouseEnter"] = function()
						isHovering:set(true)
					end;

					[OnEvent "MouseLeave"] = function()
						isHovering:set(false)
						isHeldDown:set(false)
					end;

					[OnEvent "MouseButton1Up"] = function()
						isHeldDown:set(false)
					end;

					[OnEvent "MouseButton1Down"] = function()
						isHeldDown:set(true)
					end;

					[OnEvent "MouseButton1Click"] = props.OnMouseButton1Click;

					Size = UDim2.fromScale(1, 1);
					
					BackgroundTransparency = 1;

					Text = "";

					[Children] = scope:New "UICorner" {};
				}
			}
		}
	}
end

return function(
	scope: Scope,
	props: props
)
	return scope:New "Frame" {
		Size = UDim2.new(1, 0, 0, 64);
		
		BackgroundTransparency = 1;
		
		[Children] = {
			scope:New "UIListLayout" {
				Padding = UDim.new(0, 8);
				
				FillDirection = Enum.FillDirection.Horizontal;
			};
			
			button(scope, {
				Content = "Menu";
				Icon = "rbxassetid://74560567253978";
				
				OnMouseButton1Click = function()
					local peekedTabs = peek(globals.tabs)
					
					if not table.find(peekedTabs, "sakura::menu") then
						table.insert(peekedTabs, "sakura::menu")
						
						globals.tabs:set(peekedTabs)
					end
					
					globals.selectedTab:set("sakura::menu")
					globals.selectedTabIndex:set(#peekedTabs)
				end;
			});
			
			button(scope, {
				Content = "Settings";
				Icon = "rbxassetid://135586789898242";
				
				OnMouseButton1Click = function()
					local peekedTabs = peek(globals.tabs)

					if not table.find(peekedTabs, "sakura::settings") then
						table.insert(peekedTabs, "sakura::settings")

						globals.tabs:set(peekedTabs)
					end
					
					globals.selectedTab:set("sakura::settings")
					globals.selectedTabIndex:set(#peekedTabs)
				end;
			});
		}
	}
end