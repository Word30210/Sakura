--#[ Services ]#--
local Player = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local SakuraStorage = ReplicatedStorage.sakura_storage

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

local RouterModule = require(SakuraStorage.modules.router_module)

--#[ Fusion ]#--
local Fusion = require(Modules.fusion)
local peek = Fusion.peek
local scoped = Fusion.scoped
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange

--#[ Types ]#--
type Fusion = typeof(Fusion)
type UsedAs<T> = Fusion.UsedAs<T>
type Scope<T = Fusion> = Fusion.Scope<T>

export type props = {
	Name: UsedAs<string>?;
	Parent: UsedAs<Instance>?;
}

--#[ Variables ]#--
local globals = require(SakuraStorage.globals)

--#[ Function ]#--
--

--#[ Main ]#--
return function(
    scope: Scope,
    props: props
)
    local tabObserver = scope:Observer(globals.tabs)
    local oldTabs = {}
    local doms: Fusion.Value<{ Instance }> = scope:Value {}

    local function updatePages()
        local tabs = peek(globals.tabs)

        local tabHash = {}
        local oldTabHash = {}

        for _, path in tabs do
            tabHash[path] = true
        end

        for _, path in oldTabs do
            oldTabHash[path] = true
        end

        local peekedDoms = peek(doms)
        local resolvedDoms: { [string]: Instance } = {}
        local finalDoms: { Instance } = {}

        for index = #peekedDoms, 1, -1 do
            local dom = peekedDoms[index]
            local path = dom.Name

            if not tabHash[path] then
                dom:Destroy()

                table.remove(peekedDoms, index)
            else
                resolvedDoms[path] = dom
            end
        end

        for index, path in tabs do
            local dom = resolvedDoms[path]

            if not dom then
                local page = RouterModule.getClientPage(path)

                if page then
                    (require :: any)(page.pageModule).new()
                end
            end

            table.insert(finalDoms, dom)
        end
    end
end