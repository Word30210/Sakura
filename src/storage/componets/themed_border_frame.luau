--!strict

--#[ Services ]#--
local Player = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local localPlayer = Player.LocalPlayer
local playerGui = localPlayer.PlayerGui

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
	
	AnchorPoint: UsedAs<Vector2>?;
	Position: UsedAs<UDim2>?;
	Size: UsedAs<UDim2>?;
	Rotation: UsedAs<UDim2>?;
	
	BackgroundColor3: UsedAs<Color3>?;
	BackgroundTransparency: UsedAs<number>?;
	BorderColor3: UsedAs<Color3>?;
	BorderSize: UsedAs<number>?;
	CornerRadius: UsedAs<UDim>?;
	
	AutomaticSize: UsedAs<Enum.AutomaticSize>?;
	SizeConstraint: UsedAs<Enum.SizeConstraint>?;
	ClipsDescendants: UsedAs<boolean>?;
	
	LayoutOrder: UsedAs<number>?;
	ZIndex: UsedAs<number>?;
	Visible: UsedAs<boolean>?;
	Active: UsedAs<boolean>?;
	
	[Fusion.SpecialKey]: any;
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
	return scope:New "Frame" {
		Name = props.Name;
		Parent = props.Parent;
		
		AnchorPoint = props.AnchorPoint;
		Position = props.Position;
		Size = props.Size;
		Rotation = props.Rotation;
		
		BackgroundColor3 = scope:Computed(function(
			use: Fusion.Use
		)
			return use(props.BackgroundColor3) or use(globals.theme).primaryBackgroundColor
		end);
		BackgroundTransparency = props.BackgroundTransparency;
		
		AutomaticSize = props.AutomaticSize;
		SizeConstraint = props.SizeConstraint;
		ClipsDescendants = props.ClipsDescendants;
		
		LayoutOrder = props.LayoutOrder;
		ZIndex = props.ZIndex;
		Visible = props.Visible;
		Active = props.Active;
		
		[Children] = {
			scope:New "UICorner" {
				CornerRadius = props.CornerRadius;
			};
			
			scope:New "UIPadding" {
				PaddingBottom = UDim.new(0, 2);
				PaddingLeft = UDim.new(0, 2);
				PaddingRight = UDim.new(0, 2);
				PaddingTop = UDim.new(0, 2);
			};
			
			scope:New "Frame" {
				AnchorPoint = Vector2.new(0.5, 0.5);
				Position = UDim2.fromScale(0.5, 0.5);
				Size = UDim2.fromScale(1, 1);
				
				BackgroundTransparency = 1;
				
				[Children] = {
					scope:New "UICorner" {
						CornerRadius = scope:Computed(function(
							use: Fusion.Use
						)
							local cornerRadius = use(props.CornerRadius) or UDim.new(0, 0)
							
							return UDim.new(cornerRadius.Scale * 3 / 4, cornerRadius.Offset * 3 / 4)
						end);
					};
					
					scope:New "UIStroke" {
						Thickness = scope:Computed(function(
							use: Fusion.Use
						)
							return use(props.BorderSize) or 0.5
						end);
						
						Color = scope:Computed(function(
							use: Fusion.Use
						)
							return use(props.BorderColor3) or use(globals.theme).borderColor
						end);
						Transparency = props.BackgroundTransparency;
					};
					
					props[Children];
				}
			}
		}
	}
end