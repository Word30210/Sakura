--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local globals = {}
local root = script.Parent

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

local oklch = require(Modules["oklch-rblx"])

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

    DestroyAndRemoveFromTabs: (
        self: Tab,
        autoSelectOtherTab: boolean?
    ) -> ();
}

export type Tab = typeof(setmetatable({} :: {
    url: UsedAs<string>;
	id: string;
    scope: Scope;
    dom: GuiObject?;

    title: Value<string?>;
    icon: Value<string?>;
}, {} :: TabImpl))

type ConstructDomFunction = (
    self: PageRoute,
    tab: Tab,
    params: any
) -> GuiObject

type PageRouteImpl = {
    __index: PageRouteImpl;

    new: (
        urlPattern: string,
        initialTitle: string?,
        initialIcon: string?
    ) -> PageRoute;

    ConstructDom: (
        self: PageRoute,
        tab: Tab,
        params: any
    ) -> GuiObject;
}

export type PageRoute = typeof(setmetatable({} :: {
    urlPattern: string;
    initialTitle: string?;
    initialIcon: string?;

    constructDom: ConstructDomFunction?;
}, {} :: PageRouteImpl))

--#[ Main ]#--
globals.root = root
globals.rootScope = rootScope

globals.tabs = rootScope:Value {} :: Value<{ Tab }>
globals.selectedTab = rootScope:Value(nil) :: Value<Tab?>
globals.selectedTabIndex = rootScope:Value(1)
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

	url_editor = {
		scope = Color3.fromRGB(203, 166, 247);
		headSegment = Color3.fromRGB(205, 214, 244);
		name = Color3.fromRGB(143, 180, 255);
		argument = Color3.fromRGB(250, 179, 135);
		queryKey = Color3.fromRGB(166, 227, 161);
		queryValue = Color3.fromRGB(166, 227, 161);

		--// operators
		at = Color3.fromRGB(188, 190, 200);
		double_colon = Color3.fromRGB(188, 190, 200);
		question_mark = Color3.fromRGB(188, 190, 200);
		equal = Color3.fromRGB(188, 190, 200);
		ampersand = Color3.fromRGB(188, 190, 200);

		--// malformed
		unknown = Color3.fromRGB(243, 139, 168);
	}
}

globals.functions = {}

function globals.functions.panic(
	panicData: {
		title: string?;
		why: string;
		level: number?;
	}
): never
	error(panicData.why, panicData.level or 2)
end

function globals.functions.warn(
	warnData: {
		title: string?;
		why: string;
	}
)
	warn(warnData.why)
end

function globals.functions.addNumberToColor3BasedRGB(
	color3: Color3,
	number: number
): Color3
	local r = math.floor(color3.R * 255)
	local g = math.floor(color3.G * 255)
	local b = math.floor(color3.B * 255)
	
	return Color3.fromRGB(r + number, g + number, b + number)
end

function globals.functions.createColor3FromOklch(
	lightness: number,
	chroma: number,
	hue: number
): Color3
	return oklch.toRGB(lightness, chroma, hue)
end

function globals.functions.addOklchToColor3(
	color3: Color3,
	lightnessAdd: number,
	chromaAdd: number,
	hueAdd: number
): Color3
	local l, c, h = oklch.fromRGB(color3)
	
	return oklch.toRGB(l + lightnessAdd, c + chromaAdd, h + hueAdd)
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