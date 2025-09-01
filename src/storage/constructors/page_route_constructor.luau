--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local SakuraStorage = ReplicatedStorage.sakura_storage

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

--#[ Constructors ]#--
local TabConstructor = require(SakuraStorage.constructors.tab_constructor)

--#[ Fusion ]#--
local Fusion = require(Modules.fusion)
local peek = Fusion.peek
local scoped = Fusion.scoped

--#[ Types ]#--
type Fusion = typeof(Fusion)
type UsedAs<T> = Fusion.UsedAs<T>
type Scope<T = Fusion> = Fusion.Scope<T>

type PageRouteImpl = {
    __index: PageRouteImpl;

    new: (
        urlPattern: string
    ) -> PageRoute;

    ConstructDom: (
        self: PageRoute,
        scope: Scope,
        params: any
    ) -> Instance;
}

export type PageRoute = typeof(setmetatable({} :: {
    urlPattern: string;

    constructDom: (
        (
            scope: Scope,
            params: any
        ) -> Instance
    )?;
}, {} :: PageRouteImpl))

--#[ Variables ]#--
local globals = require(SakuraStorage.globals)

local pageRouteImpl = {} :: PageRouteImpl
pageRouteImpl.__index = pageRouteImpl

--#[ Functions ]#--
--

--#[ Main ]#--
function pageRouteImpl.new(
    urlPattern: string
): PageRoute
    local self = {}

    self.urlPattern = urlPattern

    return setmetatable(self, pageRouteImpl)
end

function pageRouteImpl:ConstructDom(
    scope: Scope,
    params: any
): Instance
    if not self.constructDom then
        error("No constructDom function defined for this PageRoute")
    end

    return self.constructDom(scope, params)
end

return pageRouteImpl