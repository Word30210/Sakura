--#[ Services ]#--
local Player = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local localPlayer = Player.LocalPlayer :: Player
local playerGui = localPlayer.PlayerGui

local SakuraStorage = ReplicatedStorage.sakura_storage

local globals = require(SakuraStorage.globals)

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

-- local UrlLexer = require("@sakura_modules/url_parser_module/ast/lexer")
-- local UrlParser = require("@sakura_modules/url_parser_module/ast/parser")
local UrlLexer = require(SakuraStorage.modules.url_parser_module.ast.lexer)
local UrlParser = require(SakuraStorage.modules.url_parser_module.ast.parser)

--#[ Constructors ]#--
--

--#[ Fusion ]#--
local Fusion = require(Modules.fusion)
local Children = Fusion.Children
local peek = Fusion.peek
local scoped = Fusion.scoped

-- local UrlEditor = require("@sakura_components/url_editor")
local UrlEditor = require(SakuraStorage.components.url_editor)

--#[ Types ]#--
type Fusion = typeof(Fusion)
type UsedAs<T> = Fusion.UsedAs<T>
type Scope<T = Fusion> = Fusion.Scope<T>

--#[ Variables ]#--
local testScope = scoped(
    Fusion,
    {
        UrlEditor = UrlEditor;
    }
)

local testLexer = UrlLexer.new("test")
local testParser = UrlParser.new(testLexer.tokens)

--#[ Function ]#--
--

--#[ Main ]#--
testScope:New "ScreenGui" {
    Name = script.Name;
    Parent = playerGui;

    [Children] = testScope:UrlEditor {
        AnchorPoint = Vector2.new(0.5, 0.5);
        Position = UDim2.fromScale(0.5, 0.5);
        Size = UDim2.fromOffset(1000, 50);

        BackgroundColor3 = Color3.fromRGB(26, 21, 21);

        Lexer = testLexer;
        Parser = testParser;
    }
}