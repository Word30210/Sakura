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

--#[ Variables ]#--
local globals = require(SakuraStorage.globals)

--#[ Main ]#--
function module.getTabs(): Fusion.Value<{ string }>
	return globals.tabs
end

function module.getLength(): number
	return #globals.tabs
end

function module.getCurrentTab(): string?
	return peek(globals.currentTab)
end

function module.getCurrentTabIndex(): number
	return peek(globals.currentTabIndex)
end

function module.addTabFront(
	path: string
): ()
	local tabs = peek(globals.tabs)
	
	table.insert(tabs, 1, path)
	
	globals.tabs:set(tabs, true)
end

function module.addTabBack(
	path: string
): ()
	local tabs = peek(globals.tabs)
	
	table.insert(tabs, path)
	
	globals.tabs:set(tabs)
end

function module.addTab(
	path: string,
	index: number
): ()
	local tabs = peek(globals.tabs)
	
	table.insert(tabs, index, path)
	
	globals.tabs:set(tabs)
end

function module.addTabAbove(
	path: string
): number
	local tabs = peek(globals.tabs)
	local currentTabIndex = peek(globals.currentTabIndex)
	
	table.insert(tabs, currentTabIndex, path)
	
	globals.tabs:set(tabs)
	
	return currentTabIndex
end

function module.addTabBelow(
	path: string
): number
	local tabs = peek(globals.tabs)
	local currentTabIndex = peek(globals.currentTabIndex)

	table.insert(tabs, currentTabIndex + 1, path)
	
	globals.tabs:set(tabs)

	return currentTabIndex + 1
end

function module.replaceTabWith(
	path: string,
	index: number
): ()
	local tabs = peek(globals.tabs)
	
	tabs[index] = path
	
	globals.tabs:set(tabs)
end

function module.replaceCurrentTabWith(
	path: string
): number
	local tabs = peek(globals.tabs)
	local currentTabIndex = peek(globals.currentTabIndex)

	tabs[currentTabIndex] = path

	globals.tabs:set(tabs)
	
	return currentTabIndex
end

function module.removeTab(
	path: string
): number
	local tabs = peek(globals.tabs)
	local index = table.find(tabs, path)
	
	if not index then
		error(`cannot find '{ path }' tab.`, 2)
	end
	
	table.remove(tabs, index)
	
	globals.tabs:set(tabs)
	
	return index
end

function module.removeTabByIndex(
	index: number
): ()
	local tabs = peek(globals.tabs)
	
	table.remove(tabs, index)
	
	globals.tabs:set(tabs)
end

function module.findTab(
	path: string
): number?
	local tabs = peek(globals.tabs)
	
	return table.find(tabs, path)
end

return module