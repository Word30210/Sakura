--#[ Services ]#--
local Player = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local SakuraStorage = ReplicatedStorage.sakura_storage

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

-- local UrlLexer = require("@sakura_modules/url_parser_module/ast/lexer")
-- local UrlParser = require("@sakura_modules/url_parser_module/ast/parser")
local UrlLexer = require(SakuraStorage.modules.url_parser_module.ast.lexer)
local UrlParser = require(SakuraStorage.modules.url_parser_module.ast.parser)

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

    AnchorPoint: UsedAs<Vector2>?;
    Position: UsedAs<UDim2>?;
    Size: UsedAs<UDim2>?;
    Rotation: UsedAs<number>?;

    BackgroundColor3: UsedAs<Color3>?;
    BackgroundTransparency: UsedAs<number>?;

    LayoutOrder: UsedAs<number>?;
	ZIndex: UsedAs<number>?;
	Visible: UsedAs<boolean>?;
	Active: UsedAs<boolean>?;

    Lexer: UrlLexer.Lexer;
    Parser: UrlParser.Parser;
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
    props.Parser.tokens = props.Lexer.tokens

    local highlightLabels: { TextLabel } = {}

    local waitForScanningAndParsingThread: thread?

    local isCorrectSyntax = scope:Value(false)

    local function updateHighlightLabels()
        local tokens = props.Lexer.tokens
        local parseResult = props.Parser.parseResult

        warn("source:", buffer.tostring(props.Lexer.source))
        warn("snapshot:", props.Lexer.snapshot)
        warn("tokens:", props.Lexer.tokens)
        warn("parseResult:", parseResult)

        warn("lexical issues:", props.Lexer.issues)
        warn("syntax issues:", props.Parser.issues)

        if next(props.Lexer.issues) or next(props.Parser.issues) then
            isCorrectSyntax:set(false)
        else
            isCorrectSyntax:set(true)
        end
    end

    return scope:New "TextBox" {
        Name = props.Name;
        Parent = props.Parent;

        AnchorPoint = props.AnchorPoint;
        Position = props.Position;
        Size = props.Size;
        Rotation = props.Rotation;

        BackgroundColor3 = props.BackgroundColor3;
        BackgroundTransparency = props.BackgroundTransparency;

        TextColor3 = scope:Computed(function(
            use: Fusion.Use
        )
            local isCorrectSyntax = use(isCorrectSyntax)

            return use(isCorrectSyntax) and Color3.fromHex("3fb950") or Color3.fromHex("da3633")
        end);
        -- TextColor3 = Color3.fromHex("eeeeee");
        FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);

        ClearTextOnFocus = false;
        MultiLine = false;

        LayoutOrder = props.LayoutOrder;
        ZIndex = props.ZIndex;
        Visible = props.Visible;
        Active = props.Active;

        [OnChange "Text"] = function(
            newText: string
        )
            local newBuffer = buffer.fromstring(newText)

            if buffer.len(newBuffer) >= 2 ^ 10 then
                globals.functions.warn {
                    title = script.Name;
                    why = "url entered was too long!";
                }

                isCorrectSyntax:set(false)

                return
            else
                isCorrectSyntax:set(true)
            end

            if waitForScanningAndParsingThread then
                task.cancel(waitForScanningAndParsingThread)
            end

            local currentThread = coroutine.running()

            if props.Lexer.isScanning or props.Parser.isParsing then
                waitForScanningAndParsingThread = task.spawn(function()
                    repeat task.wait() until props.Lexer.isScanning or props.Parser.isParsing

                    props.Lexer:changeSource(newText)
                    props.Lexer:scan()
                    props.Parser:syncWithLexer()
                    props.Parser:parse()

                    coroutine.resume(currentThread)
                end)

                coroutine.yield()
            end

            props.Lexer:changeSource(newText)
            props.Lexer:scan()
            props.Parser:syncWithLexer()
            props.Parser:parse()

            warn(props.Parser.isParsing)

            updateHighlightLabels()
        end;
    }
end