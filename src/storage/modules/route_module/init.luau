--[[

urlPattern: scope@segment1::segment2::%argument1:int%::segment3::%argument2:alphabet%
url: scope@segment1::segment2::123456::segment3::abcdef?key1=value2&key2=value2

]]

--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local module = {}

local SakuraStorage = ReplicatedStorage.sakura_storage

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

--#[ Constructors ]#--
local PageRouteConstructor = require(SakuraStorage.constructors.page_route_constructor)

--#[ Fusion ]#--
local Fusion = require(Modules.fusion)
local peek = Fusion.peek
local scoped = Fusion.scoped

--#[ Types ]#--
type Fusion = typeof(Fusion)
type UsedAs<T> = Fusion.UsedAs<T>
type Scope<T = Fusion> = Fusion.Scope<T>

--#[ Variables ]#--
local globals = require(SakuraStorage.globals)

local registeredClientPageRoutes: { [string]: PageRouteConstructor.PageRoute } = {}

--#[ Main ]#--
function module.registerClientPageRoute(
    pageRoute: PageRouteConstructor.PageRoute
)
    if registeredClientPageRoutes[pageRoute.urlPattern] then
        globals.functions.panic {
            title = script.Name;
            why = `URL pattern '{ pageRoute.urlPattern }' is already registered.`;
            level = 3;
        }
    end

    registeredClientPageRoutes[pageRoute.urlPattern] = pageRoute
end

function module.getClientPageRoute(
    url: string
): PageRouteConstructor.PageRoute?
    return registeredClientPageRoutes[url]
end

return module