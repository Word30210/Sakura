--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local SakuraStorage = ReplicatedStorage.sakura_storage

local globals = require(SakuraStorage.globals)

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

--#[ Fusion ]#--
local Fusion = require(Modules.fusion)
local peek = Fusion.peek
local scoped = Fusion.scoped

--#[ Types ]#--
type Fusion = typeof(Fusion)
type UsedAs<T> = Fusion.UsedAs<T>
type Scope<T = Fusion> = Fusion.Scope<T>

type ConstructDomFunction = (
    self: PageRoute,
    tab: globals.Tab,
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
        tab: globals.Tab,
        params: any
    ) -> GuiObject;
}

export type PageRoute = typeof(setmetatable({} :: {
    urlPattern: string;
    initialTitle: string?;
    initialIcon: string?;

    constructDom: ConstructDomFunction?;
}, {} :: PageRouteImpl))

--#[ Variables ]#--
local pageRouteImpl = {} :: PageRouteImpl
pageRouteImpl.__index = pageRouteImpl

--#[ Functions ]#--
--

--#[ Main ]#--
function pageRouteImpl.new(
    urlPattern: string,
    initialTitle: string?,
    initialIcon: string?
): PageRoute
    local self = {}

    self.urlPattern = urlPattern
    self.initialTitle = initialTitle
    self.initialIcon = initialIcon

    return setmetatable(self, pageRouteImpl)
end

function pageRouteImpl:ConstructDom(
    tab: globals.Tab,
    params: any
): GuiObject
    if not self.constructDom then
        globals.functions.panic {
            title = script.Name;
            why = "No constructDom function defined for this PageRoute";
            level = 3;
        }
    end

    return (self.constructDom :: ConstructDomFunction)(self, tab, params)
end

return pageRouteImpl