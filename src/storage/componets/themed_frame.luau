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
	}
end