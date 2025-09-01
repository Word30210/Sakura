--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local module = {}

local SakuraStorage = ReplicatedStorage.sakura_storage

local globals = require(SakuraStorage.globals)

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

--#[ Constructors ]#--
--

--#[ Fusion ]#--
local Fusion = require(Modules.fusion)
local peek = Fusion.peek
local scoped = Fusion.scoped

--#[ Variables ]#--
--

--#[ Main ]#--
function module.getTabs(): Fusion.Value<{ globals.Tab }>
	return globals.tabs
end

function module.getLength(): number
	return #globals.tabs
end

function module.getCurrentTab(): globals.Tab?
	return peek(globals.currentTab)
end

function module.getCurrentTabIndex(): number
	return peek(globals.currentTabIndex)
end

function module.setCurrentTab(
	tab: globals.Tab
)
	globals.currentTab:set(tab)
	globals.currentTabIndex:set(
		assert(
			table.find(
				peek(globals.tabs),
				tab
			)
		)
	)
end

function module.findTabByURL(
	url: string
): globals.Tab?
	local tabs = peek(globals.tabs)

	for _, tab in tabs do
		if tab.url == url then
			return tab :: globals.Tab
		end
	end

	return nil
end

function module.addTabFront(
	tab: globals.Tab
)
	local tabs = peek(globals.tabs)
	
	table.insert(tabs, 1, tab)
	
	globals.tabs:set(tabs, true)
end

function module.addTabBack(
	tab: globals.Tab
)
	local tabs = peek(globals.tabs)
	
	table.insert(tabs, tab)
	
	globals.tabs:set(tabs)
end

function module.addTab(
	tab: globals.Tab,
	index: number
)
	local tabs = peek(globals.tabs)
	
	table.insert(tabs, index, tab)
	
	globals.tabs:set(tabs)
end

function module.addTabAbove(
	tab: globals.Tab
): number
	local tabs = peek(globals.tabs)
	local currentTabIndex = peek(globals.currentTabIndex)
	
	table.insert(tabs, currentTabIndex, tab)
	
	globals.tabs:set(tabs)
	
	return currentTabIndex
end

function module.addTabBelow(
	tab: globals.Tab
): number
	local tabs = peek(globals.tabs)
	local currentTabIndex = peek(globals.currentTabIndex)

	table.insert(tabs, currentTabIndex + 1, tab)
	
	globals.tabs:set(tabs)

	return currentTabIndex + 1
end

function module.replaceTabWith(
	tab: globals.Tab,
	index: number
)
	local tabs = peek(globals.tabs)
	
	tabs[index] = tab
	
	globals.tabs:set(tabs)
end

function module.replaceCurrentTabWith(
	tab: globals.Tab
): number
	local tabs = peek(globals.tabs)
	local currentTabIndex = peek(globals.currentTabIndex)

	tabs[currentTabIndex] = tab

	globals.tabs:set(tabs)
	
	return currentTabIndex
end

function module.removeTab(
	tab: globals.Tab
): number
	local tabs = peek(globals.tabs)
	local index = table.find(tabs, tab)
	
	if not index then
		error(`cannot find '{ tab.url }' tab.`, 2)
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

return module