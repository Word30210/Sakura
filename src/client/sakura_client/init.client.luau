--!strict

--#[ Services ]#--
local Player = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local localPlayer = Player.LocalPlayer
local playerGui = localPlayer.PlayerGui
local mouse = localPlayer:GetMouse()

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

--#[ Variables ]#--
local uis = script.uis

--#[ Main ]#--
require(uis.root)