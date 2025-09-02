--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local SakuraStorage = ReplicatedStorage.sakura_storage

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

local RouteModule = require(SakuraStorage.modules.route_module)

--#[ Constructors ]#--
local PageRuoteConstructor = require(SakuraStorage.constructors.page_route_constructor)

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

--#[ Variables ]#--
local globals = require(SakuraStorage.globals)

--#[ Functions ]#--
--

--#[ Main ]#--
local pageRoute = PageRuoteConstructor.new("sakura::settings", "세틴;;")

function pageRoute:constructDom(
	tab: globals.Tab,
	params: any
): GuiObject
	local scope = tab.scope

	local selectedTabObserver = scope:Observer(globals.selectedTab)
	local rng = Random.new(os.clock())
	local randomNumber = scope:Value(rng:NextNumber())

	local function updateTitleAndRandomNumber()
		local selectedTab = peek(globals.selectedTab)

		if selectedTab == tab then
			tab.title:set("지금당신은세틴;;을보는준;;;입니;;;")
		else
			tab.title:set("세틴;;")
		end

		randomNumber:set(rng:NextNumber())
	end

	selectedTabObserver:onChange(updateTitleAndRandomNumber)
	updateTitleAndRandomNumber()

	return scope:New "Frame" {
		Size = UDim2.fromScale(1, 1);

		BackgroundColor3 = scope:Computed(function(
			use: Fusion.Use
		)
			return globals.functions.addNumberToColor3BasedRGB(
				use(globals.theme).secondaryBackgroundColor,
				30
			)
		end);

		[Children] = {
			scope:New "UICorner" {
				CornerRadius = UDim.new(0, 4);
			};

			scope:New "TextLabel" {
				AnchorPoint = Vector2.new(0.5, 0.5);
				Position = UDim2.fromScale(0.5, 0.5);
				Size = UDim2.fromOffset(200, 50);

				BackgroundTransparency = 1;
				
				Text = scope:Computed(function(
					use: Fusion.Use
				)
					return `세틴;; 페이지{ (";"):rep(use(randomNumber) * 10) }\n{ use(randomNumber) }`
				end);
				TextColor3 = scope:Computed(function(
					use: Fusion.Use
				)
					return use(globals.theme).secondaryContentColor
				end);

				TextScaled = true;
			}
		}
	} :: GuiObject
end

return pageRoute