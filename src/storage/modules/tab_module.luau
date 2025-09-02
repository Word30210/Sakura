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

function module.peekTabs(): { globals.Tab }
	return peek(globals.tabs)
end

function module.peekLength(): number
	return #peek(globals.tabs)
end

function module.getselectedTab(): globals.Tab?
	return peek(globals.selectedTab)
end

function module.getselectedTabIndex(): number
	return peek(globals.selectedTabIndex)
end

function module.selectTab(
	tab: globals.Tab
)
	local foundIndex = table.find(peek(globals.tabs), tab)

	if not foundIndex then
		globals.functions.panic {
			why = `cannot select '{ tab.url }' tab because it does not exist in tabs.`,
			level = 3;
		}
	end

	globals.selectedTab:set(tab)
	globals.selectedTabIndex:set(foundIndex)
end

function module.selectTabByIndex(
	index: number
)
	local tabs = peek(globals.tabs)
	
	if not tabs[index] then
		globals.functions.panic {
			why = `cannot find tab at index { index }`,
			level = 3;
		}
	end
	
	globals.selectedTab:set(tabs[index])
	globals.selectedTabIndex:set(index)
end

function module.selectNone()
	globals.selectedTab:set(nil)
	globals.selectedTabIndex:set(nil)
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

	if table.find(tabs, tab) then
		globals.functions.panic {
			why = `cannot add '{ tab.url }' tab at front because it already exists in tabs.`,
			level = 3;
		}
	end
	
	table.insert(tabs, 1, tab)
	
	globals.tabs:set(tabs, true)
end

function module.addTabBack(
	tab: globals.Tab
)
	local tabs = peek(globals.tabs)

	if table.find(tabs, tab) then
		globals.functions.panic {
			why = `cannot add '{ tab.url }' tab at back because it already exists in tabs.`,
			level = 3;
		}
	end
	
	table.insert(tabs, tab)
	
	globals.tabs:set(tabs)
end

function module.addTab(
	tab: globals.Tab,
	index: number
)
	local tabs = peek(globals.tabs)

	if table.find(tabs, tab) then
		globals.functions.panic {
			why = `cannot add '{ tab.url }' tab at index { index } because it already exists in tabs.`,
			level = 3;
		}
	end
	
	table.insert(tabs, index, tab)
	
	globals.tabs:set(tabs)
end

function module.addTabAbove(
	tab: globals.Tab
): number
	local tabs = peek(globals.tabs)
	local selectedTabIndex = peek(globals.selectedTabIndex)

	if table.find(tabs, tab) then
		globals.functions.panic {
			why = `cannot add '{ tab.url }' tab above selectedTab because it already exists in tabs.`,
			level = 3;
		}
	end
	
	table.insert(tabs, selectedTabIndex, tab)
	
	globals.tabs:set(tabs)
	
	return selectedTabIndex
end

function module.addTabBelow(
	tab: globals.Tab
): number
	local tabs = peek(globals.tabs)
	local selectedTabIndex = peek(globals.selectedTabIndex)

	if table.find(tabs, tab) then
		globals.functions.panic {
			why = `cannot add '{ tab.url }' tab below selectedTab because it already exists in tabs.`,
			level = 3;
		}
	end

	table.insert(tabs, selectedTabIndex + 1, tab)
	
	globals.tabs:set(tabs)

	return selectedTabIndex + 1
end

function module.replaceTabWith(
	tab: globals.Tab,
	index: number
)
	local tabs = peek(globals.tabs)

	if table.find(tabs, tab) then
		globals.functions.panic {
			why = `cannot replace tab at index { index } with '{ tab.url }' tab because it already exists in tabs.`,
			level = 3;
		}
	end
	
	tabs[index] = tab

	if index == peek(globals.selectedTabIndex) then
		globals.selectedTab:set(tab)
	end
	
	globals.tabs:set(tabs)
end

function module.replaceSelectedTabWith(
	tab: globals.Tab
): number
	local tabs = peek(globals.tabs)
	local selectedTabIndex = peek(globals.selectedTabIndex)

	if table.find(tabs, tab) then
		globals.functions.panic {
			why = `cannot replace selectedTab with '{ tab.url }' tab because it already exists in tabs.`,
			level = 3;
		}
	end

	tabs[selectedTabIndex] = tab

	globals.tabs:set(tabs)
	globals.selectedTab:set(tab)
	
	return selectedTabIndex
end

function module.removeTab(
	tab: globals.Tab,
	autoSelectOtherTab: boolean?
): number
	local tabs = peek(globals.tabs)
	local index = table.find(tabs, tab)
	
	if not index then
		globals.functions.panic {
			why = `cannot find '{ tab.url }' tab.`,
			level = 2;
		}
	end

	local index = index :: number
	
	table.remove(tabs, index)
	
	globals.tabs:set(tabs)

	if autoSelectOtherTab then
		if #tabs > 0 then
			module.selectTabByIndex(math.clamp(index, 1, #tabs))
		else
			module.selectNone()
		end
	else
		module.selectNone()
	end
	
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