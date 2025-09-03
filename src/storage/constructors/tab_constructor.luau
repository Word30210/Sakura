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

--#[ Variables ]#--
local globals = require(sakuraStorage.globals)

local tabImpl = {} :: TabImpl
tabImpl.__index = tabImpl

local tabIdCount = 0

--#[ Functions ]#--
local function getUniqueTabId(): string
    local returningId = tabIdCount

    tabIdCount += 1

    return tostring(returningId)
end

--#[ Main ]#--
function tabImpl.new(
    scope: Scope,
    url: UsedAs<string>
): Tab
    local innerScope = scope:innerScope {}

    local self = {}

    self.url = url
    self.id = getUniqueTabId()
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

function tabImpl:DestroyAndRemoveFromTabs()
    if TabModules.findMountedTabById(self.id) then
        TabModules.removeTab(self)
    end

    self.scope:doCleanup()

    local self = self :: any

    setmetatable(self, nil)

    for key, value in self do
        self[key] = nil
    end
end

return tabImpl