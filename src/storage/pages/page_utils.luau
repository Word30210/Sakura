--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local module = {}

local SakuraStorage = ReplicatedStorage.sakura_storage

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
local globals = require(SakuraStorage.globals)
local scopes = globals.scopes

--#[ Functions ]#--
--

--#[ Types ]#--
type Fusion = typeof(Fusion)
type UsedAs<T> = Fusion.UsedAs<T>
type Scope<T = Fusion> = Fusion.Scope<T>

type Page<T=any> = globals.Page<T>

--#[ Main ]#--
function module.initializePage(
    path: string
)
    if scopes[path] then
        scopes[path]:doCleanup()
    end

    scopes[path] = globals.rootScope:innerScope(Fusion)
end

function module.uninitializePage(
    pages: { [Scope]: Page }
)
    for scope, page in pages do
        scope:doCleanup()

        pages[scope :: Scope] = nil
    end
end

return module