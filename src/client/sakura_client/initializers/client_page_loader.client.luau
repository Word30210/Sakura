--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local SakuraStorage = ReplicatedStorage.sakura_storage

local globals = require(SakuraStorage.globals)

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

local RouteModule = require(SakuraStorage.modules.route_module)

--#[ Variables ]#--
local pages = SakuraStorage.pages
local clientPages = pages.client_pages

--#[ Functions ]#--
--

--#[ Main ]#--
for _, pageRouteModuleScript in clientPages:GetChildren() do
    local pageRoute = (require :: any)(pageRouteModuleScript) :: globals.PageRoute

    RouteModule.registerClientPageRoute(pageRoute)
end