--#[ Services ]#--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local SakuraStorage = ReplicatedStorage.sakura_storage

local globals = require(SakuraStorage.globals)

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

local TabModule = require(SakuraStorage.modules.tab_module)

--#[ Constructors ]#--
local TabConstructor = require(SakuraStorage.constructors.tab_constructor)

--#[ Fusion ]#--
local Fusion = require(Modules.fusion)
local peek = Fusion.peek
local scoped = Fusion.scoped

--#[ Types ]#--
type Fusion = typeof(Fusion)
type UsedAs<T> = Fusion.UsedAs<T>
type Scope<T = Fusion> = Fusion.Scope<T>

--#[ Variables ]#--
--

--#[ Function ]#--
--

--#[ Main ]#--
local homeTab = TabConstructor.new(globals.rootScope, "sakura::home")
local whatsnewTab = TabConstructor.new(globals.rootScope, "sakura::whatsnew")

TabModule.addTabBack(homeTab)
TabModule.addTabBack(whatsnewTab)

local settingsTab = TabConstructor.new(globals.rootScope, "sakura::settings")
local menuTab = TabConstructor.new(globals.rootScope, "sakura::menu")

TabModule.addTabBack(settingsTab)
TabModule.addTabBack(menuTab)

-- TabModule.removeTab(homeTab)
-- homeTab:Destroy()

-- homeTab:DestroyAndRemoveFromTabs()