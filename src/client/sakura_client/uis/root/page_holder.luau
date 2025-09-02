--#[ Services ]#--
local Player = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local SakuraStorage = ReplicatedStorage.sakura_storage

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

local RouteModule = require(SakuraStorage.modules.route_module)

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
    local pageHolder = scope:New "Frame" {
        Size = UDim2.new(1, -158, 1, 0); --// 100% - 150px - 8pad

		BackgroundColor3 = scope:Computed(function(
            use: Fusion.Use
        )
            return use(globals.theme).secondaryBackgroundColor
        end);

		[Children] = {
			scope:New "UICorner" {
				CornerRadius = UDim.new(0, 4);
			};
		}
    }

    local selectedTabObserver = scope:Observer(globals.selectedTab)
    local oldSelectedTab: globals.Tab? = nil

    local function updatePage()
        local selectedTab = peek(globals.selectedTab)

        if oldSelectedTab then
            if oldSelectedTab.dom then
                oldSelectedTab.dom.Visible = false
                oldSelectedTab.dom.Parent = nil
            end
        end

        if selectedTab then
            if selectedTab.dom then
                selectedTab.dom.Visible = true
                selectedTab.dom.Parent = pageHolder
            else
                local selectedTabURL = peek(selectedTab.url)
                local pageRoute = RouteModule.getClientPageRoute(selectedTabURL)

                if not pageRoute then
                    globals.functions.warn {
                        title = script.Name;
                        why = `cannot find page route for '{ selectedTabURL }' url.`;
                        level = 3;
                    }

                    return
                end

                local newDom = pageRoute:ConstructDom(selectedTab, {})

                selectedTab.dom = newDom

                newDom.Parent = pageHolder
                newDom.Visible = true
            end
        end

        oldSelectedTab = selectedTab
    end

    selectedTabObserver:onChange(updatePage)

    return pageHolder
end