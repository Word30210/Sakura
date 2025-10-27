--#[ Services ]#--
local Player = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
local SakuraStorage = ReplicatedStorage.sakura_storage

--#[ Modules ]#--
local Modules = ReplicatedStorage.modules

local UrlLexer = require("@sakura_modules/url_parser_module/ast/lexer")
local UrlParser = require("@sakura_modules/url_parser_module/ast/parser")

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
    Rotation: UsedAs<number>?;

    BackgroundColor3: UsedAs<Color3>?;
    BackgroundTransparency: UsedAs<number>?;

    TextSize: UsedAs<number>?;

    LayoutOrder: UsedAs<number>?;
	ZIndex: UsedAs<number>?;
	Visible: UsedAs<boolean>?;
	Active: UsedAs<boolean>?;

    Lexer: UrlLexer.Lexer;
    Parser: UrlParser.Parser;
}

type coloredTextLabelProps = {
    Name: UsedAs<string>?;
    Parent: UsedAs<Instance>?;

    Text: UsedAs<string>;
    Bold: UsedAs<boolean>?;
    TextSize: UsedAs<number>?;

    LayoutOrder: UsedAs<number>;

    Kind: UsedAs<string>;
}

--#[ Variables ]#--
local globals = require(SakuraStorage.globals)

--#[ Function ]#--
local function getcursorPosition(
    scollingFramsSizeX: number,
    contentSizeX: number
): number
    return math.clamp(contentSizeX - scollingFramsSizeX, 0, math.huge)
end

local function createHighlightTextLabel(
    scope: Scope,
    props: coloredTextLabelProps
)
    return scope:New "TextLabel" {
        Name = props.Name;
        Parent = props.Parent;

        Size = scope:Computed(function(
            use: Fusion.Use
        )
            local textSize = use(props.TextSize) or 14

            return UDim2.fromOffset(0, textSize)
        end);

        BackgroundTransparency = 1;

        AutomaticSize = Enum.AutomaticSize.X;

        Text = props.Text;
        TextSize = props.TextSize or 14;
        TextColor3 = scope:Computed(function(
            use: Fusion.Use
        )
            local color = use(globals.theme).url_editor[props.Kind];

            return color or use(globals.theme).secondaryContentColor
        end);
        FontFace = Font.new(
            "rbxassetid://16658246179",
            peek(props.Bold) and Enum.FontWeight.Bold or Enum.FontWeight.Regular,
            Enum.FontStyle.Normal
        );

        LayoutOrder = props.LayoutOrder;
    } :: TextLabel
end

--#[ Main ]#--
return function(
    scope: Scope,
    props: props
)
    props.Parser.tokens = props.Lexer.tokens

    local highlightLabels: Fusion.Value<{ Instance }> = scope:Value {}
    local textboxAbsoluteSizeX = scope:Value(0)
    local contentSizeX = scope:Value(0)

    local waitForScanningAndParsingThread: thread?

    local function clearHighlightLabels()
        local peekedHighlightLabels = peek(highlightLabels)

        for index, label in peekedHighlightLabels do
            label:Destroy()

            peekedHighlightLabels[index] = nil
        end

        highlightLabels:set(peekedHighlightLabels)
    end

    local function updateHighlightLabels()
        local tokens = props.Lexer.tokens
        local parseResult = props.Parser.parseResult

        clearHighlightLabels()

        local peekedHighlightLabels = peek(highlightLabels)

        contentSizeX:set(0)

        for index, token in tokens do
            if token.kind == "eof" then
                break
            end

            local highlightLabel = createHighlightTextLabel(
                scope,
                {
                    Name = token.kind;

                    Text = token.content or props.Lexer:extract(token.span);
                    Bold = token.kind == "scope" or token.kind == "head_segment";
                    TextSize = props.TextSize;

                    LayoutOrder = index;

                    Kind = token.kind
                }
            )

            
            contentSizeX:set(peek(contentSizeX) + highlightLabel.AbsoluteSize.X)

            table.insert(peekedHighlightLabels, highlightLabel)

            warn(highlightLabel.AbsoluteSize.X)
        end

        warn("Content Size X:", peek(contentSizeX))
        highlightLabels:set(peekedHighlightLabels)
    end

    local textbox = scope:New "TextBox" {
        Size = UDim2.fromScale(1, 1);

        BackgroundTransparency = 1;

        TextColor3 = scope:Computed(function(
            use: Fusion.Use
        )
            local color = use(globals.theme).secondaryContentColor

            return color
        end);

        FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Light, Enum.FontStyle.Normal);

        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Center;

        ClearTextOnFocus = false;
        MultiLine = false;

        [OnChange "Text"] = function(
            newText: string
        )
            local newBuffer = buffer.fromstring(newText)

            if buffer.len(newBuffer) >= 2 ^ 10 then
                globals.functions.warn {
                    title = script.Name;
                    why = "url entered was too long!";
                }

                return
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

            updateHighlightLabels()
        end;

        [Children] = scope:New "ScrollingFrame" {
            Size = UDim2.fromScale(1, 1);

            BackgroundTransparency = 1;

            CanvasPosition = scope:Computed(function(
                use: Fusion.Use
            )
                local contentSizeX = use(contentSizeX)
                local textboxAbsoluteSizeX = use(textboxAbsoluteSizeX)

                return Vector2.new(
                    getcursorPosition(textboxAbsoluteSizeX, contentSizeX),
                    0
                )
            end);
            CanvasSize = UDim2.new();
            ScrollBarThickness = 0;

            AutomaticCanvasSize = Enum.AutomaticSize.X;
                
            [Children] = {
                scope:New "UIListLayout" {
                    FillDirection = Enum.FillDirection.Horizontal;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                };

                highlightLabels :: any;
            }
        }
    } :: TextBox

    textboxAbsoluteSizeX:set(textbox.AbsoluteSize.X)

    local ui = scope:New "Frame" {
        Name = props.Name;
        Parent = props.Parent;

        AnchorPoint = props.AnchorPoint;
        Position = props.Position;
        Size = scope:Computed(function(
            use: Fusion.Use
        )
            local textSize = use(props.TextSize) or 14

            return UDim2.new(1, 0, 0, textSize)
        end);
        Rotation = props.Rotation;

        BackgroundColor3 = scope:Computed(function(
            use: Fusion.Use
        )
            return props.BackgroundColor3 or use(globals.theme).secondaryBackgroundColor
        end);
        BackgroundTransparency = props.BackgroundTransparency;

        ClipsDescendants = true;

        [Children] = textbox;
    }

    return ui
end