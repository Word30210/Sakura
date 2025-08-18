--!strict

--[[

문제점 1. 탭을 마우스로 드래그 중 일 때에도 문제가 없게 코드를 짤 수 있을지 모르겠음

]]

--#[ Services ]#--
local Player = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local localPlayer = Player.LocalPlayer

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

local Tab = require(script.tab)

--#[ Types ]#--
type Fusion = typeof(Fusion)
type UsedAs<T> = Fusion.UsedAs<T>
type Scope<T = Fusion> = Fusion.Scope<T>

export type props = {
	Name: UsedAs<string>?;
	Parent: UsedAs<Instance>?;
	
	tabs: UsedAs<{ string }>;
}

--#[ Variables ]#--
local globals = require(SakuraStorage.globals)

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
	
	local tabsObserver = scope:Observer(props.tabs)
	local oldTabs = {}
	local tabInstances: Fusion.Value<{ Instance }> = scope:Value {}
	local positionDatas: { [string]: Fusion.Value<Tab.PositionData> } = {}
	
	local function updateTabs()
		local tabs = peek(props.tabs)

		local tabsHash = {}
		local oldTabsHash = {}
		
		for _, path in tabs do
			tabsHash[path] = true
		end
		
		for _, path in oldTabs do
			oldTabsHash[path] = true
		end

		local peekedTabInstances = peek(tabInstances)
		local resolvedTabInstances: { [string]: Instance } = {}
		local finalTabInstances: { Instance } = {}

		for index = #peekedTabInstances, 1, -1 do --// table.remove해도 index 오차 안생기게 하기 위해 역순으로 진행
			local instance = peekedTabInstances[index]
			local path = instance.Name
			
			if not tabsHash[path] then --// 만약 tabsHash에 없다면(removedTab) 삭제
				instance:Destroy()
				
				table.remove(peekedTabInstances, index)
				positionDatas[path] = nil
				
				if peek(globals.currentTab) == path then
					globals.currentTab:set(nil)
					globals.currentTabIndex:set(nil)
				end
				
				if peek(globals.draggingTab) == path then
					globals.draggingTab:set(nil)
				end
			else --// tabsHash에 있다면(살아남은 Tab) resolvedTabInstances에 넣기
				resolvedTabInstances[path] = instance
			end
		end
		
		local peekedDraggingTab = peek(globals.draggingTab)
		
		for index, path in tabs do
			local tabInstance = resolvedTabInstances[path]
			
			if not tabInstance then --// 만약 tabInstance가 없다면(addedTab) 새로 생성
				local positionDataValue: Fusion.Value<Tab.PositionData> = scope:Value {
					Position = (index - 1) * 40 + (index - 1) * 8;
				}
				
				tabInstance = scope:Tab {
					Name = path;
					
					Path = path;
					Position = positionDataValue;
				}
				
				positionDatas[path] = positionDataValue
			end
			
			finalTabInstances[index] = tabInstance
			
			if peekedDraggingTab ~= path then
				positionDatas[path]:set {
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