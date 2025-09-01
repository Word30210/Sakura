--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local sakuraStorage = ReplicatedStorage.sakura_storage

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

local TabModules = require(sakuraStorage.modules.tab_module)

--#[ Fusion ]#--
local Fusion = require(Modules.fusion)
local peek = Fusion.peek
local scoped = Fusion.scoped

--#[ Types ]#--
type Fusion = typeof(Fusion)
type UsedAs<T> = Fusion.UsedAs<T>
type Scope<T = Fusion> = Fusion.Scope<T>

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