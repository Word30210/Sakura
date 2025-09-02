--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local sakuraStorage = ReplicatedStorage.sakura_storage

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

local TabModules = require(sakuraStorage.modules.tab_module)
local RouteModule = require(sakuraStorage.modules.route_module)

--#[ Fusion ]#--
local Fusion = require(Modules.fusion)
local peek = Fusion.peek
local scoped = Fusion.scoped

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

    DestroyAndRemoveFromTabs: (
        self: Tab,
        autoSelectOtherTab: boolean?
    ) -> ();
}

export type Tab = typeof(setmetatable({} :: {
    url: UsedAs<string>;
    scope: Scope;
    dom: GuiObject?;

    title: Value<string?>;
    icon: Value<string?>;
}, {} :: TabImpl))

--#[ Variables ]#--
local globals = require(sakuraStorage.globals)

local tabImpl = {} :: TabImpl
tabImpl.__index = tabImpl

--#[ Functions ]#--
--

--#[ Main ]#--
function tabImpl.new(
    scope: Scope,
    url: UsedAs<string>
): Tab
    local innerScope = scope:innerScope {}

    local self = {}

    self.url = url
    self.scope = innerScope

    local peekedURL = peek(url)
    local pageRoute = RouteModule.getClientPageRoute(peekedURL)

    if not pageRoute then
        globals.functions.warn {
            title = script.Name;
            why = `cannot find page route for '{ peekedURL }' url.`;
        }
    end

    self.title = scope:Value(pageRoute and pageRoute.initialTitle)
    self.icon = scope:Value(pageRoute and pageRoute.initialIcon)

    table.insert(
        scope,
        self
    )

    return setmetatable(self, tabImpl)
end

function tabImpl:Destroy()
    local self = self :: any

    setmetatable(self, nil)

    for key, value in self do
        self[key] = nil
    end
end

function tabImpl:DestroyAndRemoveFromTabs()
    TabModules.removeTab(self)

    local self = self :: any

    setmetatable(self, nil)

    for key, value in self do
        self[key] = nil
    end
end

return tabImpl