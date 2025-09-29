--#[ Services ]#--
local Player = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
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

export type props = {
	Name: UsedAs<string>?;
	Parent: UsedAs<Instance>?;
}

--#[ Variables ]#--
local globals = require(SakuraStorage.globals)

--#[ Function ]#--
--

--#[ Main ]#--
return function(
	scope: Scope,
	props: props
)
	local isHovering = scope:Value(false)
	local isHeldDown = scope:Value(false)
	local isCloseHovering = scope:Value(false)
	local isCloseHeldDown = scope:Value(false)
	
	local animationSpeed = 60
	
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
	
	local tabControlButtonContentColorRest = scope:Computed(function(
		use: Fusion.Use
	)
		return use(globals.theme).secondaryContentColor
	end)
	
	local tabControlButtonContentColorHeld = scope:Computed(function(
		use: Fusion.Use
	)
		return globals.functions.addNumberToColor3BasedRGB(
			use(globals.theme).secondaryContentColor,
			10
		)
	end)
	
	local tabControlButtonContentColorHover = scope:Computed(function(
		use: Fusion.Use
	)
		return globals.functions.addNumberToColor3BasedRGB(
			use(globals.theme).secondaryContentColor,
			5
		)
	end)
	
	local button = scope:New "Frame" {
		Name = props.Name;
		Parent = props.Parent;

		AnchorPoint = Vector2.new(0.5, 0.5);
		Position = UDim2.fromScale(0.5, 0.5);
		Size = UDim2.new(1, 0, 0, 40);
		
		BackgroundTransparency = 1;

		LayoutOrder = 2;
		
		[Children] = scope:New "Frame" {
			[OnEvent "InputBegan"] = function(
				inputObject: InputObject
			)
				if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
					isHovering:set(true)
				elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
					isHeldDown:set(true)
					globals.addingNewTab:set(true)
				end
			end;

			[OnEvent "InputEnded"] = function(
				inputObject: InputObject
			)
				if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
					isHovering:set(false)
				elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
					isHeldDown:set(false)
				end
			end;

			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.fromScale(0.5, 0.5);
			Size = UDim2.fromScale(1, 1);

			BackgroundColor3 = scope:Spring(
				scope:Computed(function(
					use: Fusion.Use
				)
					return
						if use(isHeldDown) or use(globals.addingNewTab) then use(tabButtonColorHeld)
						elseif use(isHovering) then use(tabButtonColorHover)
						else use(tabButtonColorRest)
				end),
				animationSpeed
			);

			ClipsDescendants = true;

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

					Image = "rbxassetid://82021737679600";
					ImageColor3 = scope:Spring(
						scope:Computed(function(
							use: Fusion.Use
						)
							local isHeldDown = use(isHeldDown)
							local isHovering = use(isHovering)
							local addingNewTab = use(globals.addingNewTab)

							return
								if isHeldDown or addingNewTab then use(tabControlButtonContentColorHeld)
								elseif isHovering then use(tabControlButtonContentColorHover)
								else use(tabControlButtonContentColorRest)
						end),
						animationSpeed
					);
				};

				scope:New "TextLabel" {
					AnchorPoint = Vector2.new(0, 0.5);
					Position = UDim2.new(0, 32, 0.5, 0);
					Size = UDim2.new(1, -32, 0, 12);

					BackgroundTransparency = 1;

					Text = "New Tab";
					TextColor3 = scope:Spring(
						scope:Computed(function(
							use: Fusion.Use
						)
							local isHeldDown = use(isHeldDown)
							local isHovering = use(isHovering)
							local addingNewTab = use(globals.addingNewTab)

							return
								if isHeldDown or addingNewTab then use(tabControlButtonContentColorHeld)
								elseif isHovering then use(tabControlButtonContentColorHover)
								else use(tabControlButtonContentColorRest)
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
							if use(isHeldDown) or use(isHovering) or use(globals.addingNewTab) then UDim2.new(0, 36, 1, 0)
							else UDim2.new(0, 8, 1, 0)
					end);

					BackgroundColor3 = scope:Spring(
						scope:Computed(function(
							use: Fusion.Use
						)
							return
								if use(isHeldDown) or use(globals.addingNewTab) then use(tabButtonColorHeld)
								elseif use(isHovering) then use(tabButtonColorHover)
								else use(tabButtonColorRest)
						end),
						animationSpeed
					);

					ZIndex = 5;

					[Children] = scope:New "UIGradient" {
						Transparency = scope:Computed(function(
							use: Fusion.Use
						)
							return
								if use(isHeldDown) or use(isHovering) or use(globals.addingNewTab) then NumberSequence.new {
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
			}
		}
	} :: Frame
	
	table.insert(
		scope,
		UserInputService.InputBegan:Connect(function(
			inputObject: InputObject
		)
			if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end
			
			-- 나중에 걍 따로 함수로 만들어서 new tab 입력하는? 창도 이거랑 똑같이 적용 시켜야 함
			-- 아니면 코드 복사 붙혀넣기 해도 될듯
			-- 아니다 걍 코드 복사 붙혀넣기 하자
			-- 아니 생각해보니깐 Root에서 이거 처리 해야할듯 ㅇㅇ
			
			local mousePositionX, mousePositionY = inputObject.Position.X, inputObject.Position.Y
			local buttonPositionX, buttonPositionY = button.AbsolutePosition.X, button.AbsolutePosition.Y
			local buttonSizeX, buttonSizeY = button.AbsoluteSize.X, button.AbsoluteSize.Y
			
			warn(mousePositionX, mousePositionY)

			if mousePositionX < buttonPositionX or buttonPositionX + buttonSizeX < mousePositionX
				or mousePositionY < buttonPositionY or buttonPositionY + buttonSizeY < mousePositionY
				and peek(globals.addingNewTab)
			then
				globals.addingNewTab:set(false)
			end
		end)
	)
	
	return button
end