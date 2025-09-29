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
    return scope:New "Frame" {
        Size = UDim2.new(1, 0, 0, 32);

        BackgroundColor3 = scope:Computed(function(
            use: Fusion.Use
        )
            return use(globals.theme).secondaryBackgroundColor
        end);

        LayoutOrder = 0;

        [Children] = {
            scope:New "UICorner" {};

            scope:New "UIPadding" {
                PaddingBottom = UDim.new(0, 5);
                PaddingLeft = UDim.new(0, 10);
                PaddingRight = UDim.new(0, 10);
                PaddingTop = UDim.new(0, 5);
            };

            scope:New "Frame" {
                AnchorPoint = Vector2.new(1, 0.5);
                Position = UDim2.new(1, 8, 0.5, 0);
                Size = UDim2.new(0, 16, 1, 0);

                BackgroundColor3 = scope:Computed(function(
                    use: Fusion.Use
                )
                    return use(globals.theme).secondaryBackgroundColor
                end);

                [Children] = scope:New "UIGradient" {
					Transparency = NumberSequence.new {
						NumberSequenceKeypoint.new(0, 1);
						NumberSequenceKeypoint.new(0.5, 0);
						NumberSequenceKeypoint.new(1, 0);
					}
				}
            };

            scope:New "TextBox" {
                AnchorPoint = Vector2.new(0.5, 0.5);
                Position = UDim2.fromScale(0.5, 0.5);
                Size = UDim2.fromScale(1, 1);

                BackgroundTransparency = 1;

                Text = scope:Computed(function(
                    use: Fusion.Use
                )
                    local selectedTab = use(globals.selectedTab)

                    return selectedTab and selectedTab.url or ""
                end);
                TextSize = 12;
                TextColor3 = scope:Computed(function(
                    use: Fusion.Use
                )
                    return use(globals.theme).secondaryContentColor
                end);
                FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);

                TextXAlignment = Enum.TextXAlignment.Left;
            };
        }
    }
end