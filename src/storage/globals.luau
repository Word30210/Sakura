--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local globals = {}
local root = script.Parent

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

--#[ Fusion ]#--
local Fusion = require(Modules.fusion)
local peek = Fusion.peek
local scoped = Fusion.scoped
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange

--#[ Variables ]#--
local rootScope = scoped(Fusion)

--#[ Function ]#--
--

--#[ Types ]#--
type Fusion = typeof(Fusion)
type UsedAs<T> = Fusion.UsedAs<T>
type Scope<T = Fusion> = Fusion.Scope<T>
type Value<T> = Fusion.Value<T>

type TabImpl = {
    __index: TabImpl;

    new: (
        scope: Scope,
        url: UsedAs<string>
    ) -> Tab;

    Destroy: (
        self: Tab
    ) -> ();
}

export type Tab = typeof(setmetatable({} :: {
    url: UsedAs<string>;
    scope: Scope;
    dom: Instance?;

    title: UsedAs<string?>?;
    icon: UsedAs<string?>?;
}, {} :: TabImpl))

--#[ Main ]#--
globals.root = root
globals.rootScope = rootScope

globals.tabs = rootScope:Value {} :: Value<{ Tab }>
globals.currentTab = rootScope:Value(nil) :: Value<Tab?>
globals.currentTabIndex = rootScope:Value(1)
globals.draggingTab = rootScope:Value(nil) :: Value<Tab?>
globals.addingNewTab = rootScope:Value(false)

globals.mountedDoms = rootScope:Value {}

globals.theme = rootScope:Value {
	primaryBackgroundColor = Color3.fromRGB(36, 31, 31);
	secondaryBackgroundColor = Color3.fromRGB(46, 41, 41);
	tertiaryBackgroundColor = Color3.fromRGB(31, 26, 26);
	buttonColor = Color3.fromRGB(46, 41, 41);
	borderColor = Color3.fromRGB(66, 61, 61);
	primaryContentColor = Color3.fromRGB(194, 194, 194);
	secondaryContentColor = Color3.fromRGB(127, 127, 127);
	tertiaryContentColor = Color3.fromRGB(66, 61, 61);
}

globals.functions = {}

function globals.functions.addNumberToColor3BasedRGB(
	color3: Color3,
	number: number
): Color3
	local r = math.floor(color3.R * 255)
	local g = math.floor(color3.G * 255)
	local b = math.floor(color3.B * 255)
	
	return Color3.fromRGB(r + number, g + number, b + number)
end

function globals.functions.toOrdinal(
	number: number
): string
	local suffix = "th"
	local lastTwo = number % 100
	local lastOne = number % 10

	if lastTwo < 11 or lastTwo > 13 then
		if lastOne == 1 then
			suffix = "st"
		elseif lastOne == 2 then
			suffix = "nd"
		elseif lastOne == 3 then
			suffix = "rd"
		end
	end

	return `{ number }{ suffix }`
end

return globals