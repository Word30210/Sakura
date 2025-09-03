--#[ Services ]#--
local Player = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local SakuraStorage = ReplicatedStorage.sakura_storage
local globals = require(SakuraStorage.globals)

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

local TabModule = require(SakuraStorage.modules.tab_module)

--#[ Fusion ]#--
local Fusion = require(Modules.fusion)
local peek = Fusion.peek
local scoped = Fusion.scoped
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange

local Tab = require(script.tab)

--#[ Types ]#--
type Fusion = typeof(Fusion)
type UsedAs<T> = Fusion.UsedAs<T>
type Scope<T = Fusion> = Fusion.Scope<T>

export type props = {
	Name: UsedAs<string>?;
	Parent: UsedAs<Instance>?;
}

--#[ Variables ]#--
--

--#[ Function ]#--
local function isEmpty(
	t: { [any]: any }
): boolean
	return not next(t)
end	

--#[ Main ]#--
return function(
	scope: Scope,
	props: props
)	
	local scope = scope:innerScope {
		Tab = Tab;
	}
	
	local tabsObserver = scope:Observer(globals.tabs)
	local oldTabs: { globals.Tab } = {}
	local tabInstances: Fusion.Value<{ Instance }> = scope:Value {}
	local positionDatas: { [string]: Fusion.Value<Tab.PositionData> } = {}
	
	local function updateTabs()
		local tabs = peek(globals.tabs)

		local tabsHash = {}
		local oldTabsHash = {}
		
		for _, tab in tabs do
			tabsHash[tab.id] = true
		end
		
		for _, tab in oldTabs do
			oldTabsHash[tab.id] = true
		end

		local peekedTabInstances = peek(tabInstances)
		local resolvedTabInstances: { [string]: Instance } = {}
		local finalTabInstances: { Instance } = {}

		for index = #peekedTabInstances, 1, -1 do --// table.remove해도 index 오차 안생기게 하기 위해 역순으로 진행
			local instance = peekedTabInstances[index]
			local id = instance.Name
			
			if not tabsHash[id] then --// 만약 tabsHash에 없다면(removedTab) 삭제
				instance:Destroy()
				
				table.remove(peekedTabInstances, index)
				positionDatas[id] = nil
				
				local peekedselectedTab = peek(globals.selectedTab)
				local peekedDraggingTab = peek(globals.draggingTab)

				if peekedselectedTab and peekedselectedTab.id == id then
					globals.selectedTab:set(nil)
					globals.selectedTabIndex:set(nil)
				end
				
				if peekedDraggingTab and peekedDraggingTab.id == id then
					globals.draggingTab:set(nil)
				end
			else --// tabsHash에 있다면(살아남은 Tab) resolvedTabInstances에 넣기
				resolvedTabInstances[id] = instance
			end
		end
		
		local peekedDraggingTab = peek(globals.draggingTab)
		
		for index, tab in tabs do
			local id = tab.id
			local tabInstance = resolvedTabInstances[id]
			
			if not tabInstance then --// 만약 tabInstance가 없다면(addedTab) 새로 생성
				local positionDataValue: Fusion.Value<Tab.PositionData> = scope:Value {
					Position = (index - 1) * 40 + (index - 1) * 8;
				}

				tabInstance = scope:Tab {
					Name = tab.id;
					
					Tab = tab :: globals.Tab;
					Position = positionDataValue;
				}
				
				positionDatas[id] = positionDataValue
			end
			
			finalTabInstances[index] = tabInstance

			if not peekedDraggingTab or (peekedDraggingTab and peekedDraggingTab.id ~= id) then
				positionDatas[id]:set {
					Position = (index - 1) * 40 + (index - 1) * 8;
				}
			end
		end
		
		tabInstances:set(finalTabInstances)
		
		oldTabs = table.clone(tabs)
	end
	
	tabsObserver:onChange(updateTabs)
	updateTabs()
	
	return scope:New "ScrollingFrame" {
		AnchorPoint = Vector2.new(0.5, 0);
		Size = UDim2.new(1, 0, 1, -72); --// 100% - 64px - 8pad
		
		BackgroundTransparency = 1;
		
		AutomaticCanvasSize = Enum.AutomaticSize.Y;
		
		CanvasSize = UDim2.new();
		
		ScrollBarThickness = 2;
		ScrollBarImageTransparency = 0.5;
		
		[Children] = {
			--scope:New "UIListLayout" {
			--	Padding = UDim.new(0, 8);
			--};
			
			tabInstances;
		}
	}
end