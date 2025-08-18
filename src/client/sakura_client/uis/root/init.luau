--!strict

--#[ Services ]#--
local Player = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

--#[ Head Variables ]#--
local localPlayer = Player.LocalPlayer :: Player
local playerGui = localPlayer.PlayerGui

local SakuraStorage = ReplicatedStorage.sakura_storage
local Components = SakuraStorage.componets

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

local ThemedBorderFrame = require(Components.themed_border_frame)

local SideButtons = require(script.side_buttons)
local AddNewTabButton = require(script.add_new_tab_button)
local Tabs = require(script.tabs)

--#[ Variables ]#--
local globals = require(SakuraStorage.globals)
local scope = globals.rootScope:innerScope(
	Fusion,
	{
		ThemedBorderFrame = ThemedBorderFrame;

		SideButtons = SideButtons;
		AddNewTabButton = AddNewTabButton;
		Tabs = Tabs;
	}
)
local tabs = globals.tabs

--#[ Function ]#--
--

--#[ Main ]#--
scope:New "ScreenGui" {
	Name = "Sakura";
	Parent = playerGui;

	IgnoreGuiInset = true;
	ResetOnSpawn = false;

	[Children] = scope:ThemedBorderFrame {
		AnchorPoint = Vector2.new(0.5, 0.5);
		Position = UDim2.fromScale(0.5, 0.5);
		Size = UDim2.fromOffset(900, 500);
		
		CornerRadius = UDim.new(0, 8);

		[Children] = {
			scope:New "UIListLayout" {
				Padding = UDim.new(0, 8);

				FillDirection = Enum.FillDirection.Horizontal;

				VerticalAlignment = Enum.VerticalAlignment.Bottom;
			};

			scope:New "UIPadding" {
				PaddingBottom = UDim.new(0, 8);
				PaddingLeft = UDim.new(0, 8);
				PaddingRight = UDim.new(0, 8);
				PaddingTop = UDim.new(0, 8);
			};

			scope:New "Frame" {
				AnchorPoint = Vector2.new(0, 0.5);
				Size = UDim2.new(0, 150, 1, 0);

				BackgroundTransparency = 1;

				[Children] = {
					scope:New "UIListLayout" {
						Padding = UDim.new(0, 8);

						HorizontalAlignment = Enum.HorizontalAlignment.Center;
					};

					scope:New "UIPadding" {
						PaddingBottom = UDim.new(0, 8);
						PaddingLeft = UDim.new(0, 8);
						PaddingRight = UDim.new(0, 8);
						PaddingTop = UDim.new(0, 8);
					};

					scope:SideButtons {};
					
					scope:AddNewTabButton {};
					
					scope:Tabs {
						tabs = tabs;
					};
				}
			};

			scope:New "Frame" {
				Size = UDim2.new(1, -158, 1, 0); --// 100% - 150px - 8pad

				BackgroundColor3 = Color3.fromRGB(46, 41, 41);

				[Children] = {
					scope:New "UICorner" {
						CornerRadius = UDim.new(0, 4);
					};

					scope:New "UIPadding" {
						PaddingBottom = UDim.new(0, 4);
						PaddingLeft = UDim.new(0, 4);
						PaddingRight = UDim.new(0, 4);
						PaddingTop = UDim.new(0, 4);
					};
				}
			};
		}
	}
}

return nil