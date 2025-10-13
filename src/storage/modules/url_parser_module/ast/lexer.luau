--#[ Services ]#--
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
-- local SakuraStorage = ReplicatedStorage.sakura_storage

-- local globals = require(SakuraStorage.globals)

--#[ Modules ]#--
-- local Modules = ReplicatedStorage.modules

--#[ Fusion ]#--
--

--#[ Types ]#--
export type LexerImpl = {
    __index: LexerImpl;

    new: (
        source: string
    ) -> Lexer;

    throw: (
        self: Lexer,
        why: string,
        span: vector?
    ) -> ();

    bump: (
        self: Lexer
    ) -> ();
    unbump:(
        self: Lexer
    ) -> ();
    peek: (
        self: Lexer
    ) -> number;
    lookahead: (
        self: Lexer
    ) -> number;

    eof: (
        self: Lexer
    ) -> boolean;

    escapeCaret: (
        self: Lexer
    ) -> boolean;
    asciiEscapeSequence: (
        self: Lexer
    ) -> boolean;
    unicodeEscapeSequence: (
        self: Lexer
    ) -> boolean;
    escapeDollar: (
        self: Lexer
    ) -> boolean;
    
    readName: (
        self: Lexer
    ) -> Lexme;
    readKind: (
        self: Lexer
    ) -> Lexme;

    scan: (
        self: Lexer
    ) -> ({ Lexme }, { Issue });

    changeSource:(
        self: Lexer,
        newSource: string
    ) -> ();
    initialize: (
        self: Lexer,
        initializeSnapshot: boolean?
    ) -> ();

    extract: (
        self: Lexer,
        span: vector
    ) -> string;

    tostring: (
        self: Lexer,
        lexme: Lexme
    ) -> string;
}

export type Lexer = typeof(setmetatable({} :: {
    source: buffer;
    length: number;
    position: number;
    line: number;
    tokens: { Lexme };
    issues: { Issue };
    snapshot: number;

    isScanning: boolean;
    hasScanned: boolean;
}, {} :: LexerImpl))

export type Lexme = {
    kind: string;
    span: vector;
    content: string?;
    malformed: boolean?;
}

export type Issue = {
    why: string;
    span: vector;
}

--#[ Variables ]#--
local LexerImpl = {} :: LexerImpl
LexerImpl.__index = LexerImpl

--#[ Functions ]#--
local function char(
    character: string
): number
    return string.byte(character)
end

local function whitespace(
    character: number
): boolean
    return character == char " \32"
        or character == char "\t"
        or character == char "\r"
        or character == char "\n"
        or character == char "\f"
        or character == char "\v"
end

local function reservedOperator(
    character: number
): boolean
    return character == char "@"
        or character == char ":"
        or character == char "?"
        or character == char "="
        or character == char "&"
end

local function everyOperator(
    character: number
): boolean
    return (char "!" <= character and character <= char "/")
        or (char ":" <= character and character <= char "@")
        or (char "[" <= character and character <= char "`")
        or (char "{" <= character and character <= char "~")
end

local function name(
    character: number
): boolean
    return (char "a" <= character and character <= char "z")
        or (char "A" <= character and character <= char "Z")
        or (char "0" <= character and character <= char "9")
        or character == char "_"
        or character == char "-"
        or character == char "."
end

local function digit(
    character: number
): boolean
    return char "0" <= character and character <= char "9"
end

local function hex(
    character: number
): boolean
    return (char "0" <= character and character <= char "9")
        or (char "a" <= character and character <= char "f")
        or (char "A" <= character and character <= char "F")
end

local function caretEscapeble(
    character: number
): boolean
    return name(character)
        or everyOperator(character)
end

--#[ Main ]#--
function LexerImpl.new(
    source: string
): Lexer
    local self = {}

    self.source = buffer.fromstring(source)
    self.length = buffer.len(self.source)
    self.position = 0
    self.line = 0
    self.tokens = {}
    self.issues = {}
    self.snapshot = 0

    self.isScanning = false
    self.hasScanned = false

    return setmetatable(self, LexerImpl)
end

function LexerImpl:throw(
    why: string,
    span: vector?
)
    table.insert(
        self.issues,
        {
            why = why;
            span = span or vector.create(self.position, self.position)
        }
    )
end

function LexerImpl:bump()
    if self.position >= self.length then
        return
    end

    self.position += 1
end

function LexerImpl:unbump()
    if self.position <= 0 then
        return
    end

    self.position -= 1
end

function LexerImpl:peek(): number
    if self.position >= self.length then
        return 0
    end

    return buffer.readu8(self.source, self.position)
end

function LexerImpl:lookahead(): number
    if self.position + 1 >= self.length then
        return 0
    end

    return buffer.readu8(self.source, self.position + 1)
end

function LexerImpl:eof(): boolean
    return self.position >= self.length
end

function LexerImpl:escapeCaret(): boolean
    if self:eof() then
        self:throw(
            "Unexpected EOF after '^'",
            vector.create(self.position, self.position)
        )

        return false
    end

    local character = self:peek()

    if not caretEscapeble(character) then
        self:throw(`Character '{ string.char(character) }' cannot be escaped with '^'`)

        return false
    end

    return true
end

function LexerImpl:asciiEscapeSequence(): boolean
    local character = self:peek()
    local braceClosed = false
    local malformed = false
    local malformedEscapeSequence = false
    local malformedEscapeSequenceStart = 0

    while
        (
            name(character)
            or character == char "}"
        )
        and not self:eof()
    do
        if character == char "}" then
            braceClosed = true

            if malformedEscapeSequence then
                self:throw(
                    "Malformed ASCII escape sequence.",
                    vector.create(malformedEscapeSequenceStart, self.position - 1)
                )

                malformedEscapeSequence = false
                malformedEscapeSequenceStart = 0
            end

            break
        end

        if not digit(character) and not malformedEscapeSequence then
            malformed = true
            malformedEscapeSequence = true
            malformedEscapeSequenceStart = self.position
        elseif digit(character) and malformedEscapeSequence then
            self:throw(
                "Malformed ASCII escape sequence.",
                vector.create(malformedEscapeSequenceStart, self.position - 1)
            )

            malformedEscapeSequence = false
            malformedEscapeSequenceStart = 0
        end

        self:bump()
        character = self:peek()
    end

    if malformedEscapeSequence then
        self:throw(
            "Malformed ASCII escape sequence.",
            vector.create(malformedEscapeSequenceStart, self.position - 1)
        )

        malformedEscapeSequence = false
        malformedEscapeSequenceStart = 0
    end

    if not braceClosed then
        self:throw("Unclosed ASCII escape sequence, expected '}'")

        self:unbump()

        return false
    end

    return not malformed
end

function LexerImpl:unicodeEscapeSequence(): boolean
    if self:eof() then
        self:throw("Unexpected EOF after '$\{u'")

        return false
    end

    local character = self:peek()

    if character == char "}" then
        self:throw("Malformed Unicode escape sequence.")

        return false
    end

    local braceClosed = false
    local malformed = false
    local malformedEscapeSequence = false
    local malformedEscapeSequenceStart = 0

    while
        (
            name(character)
            or character == char "}"
        )
        and not self:eof()
    do
        if character == char "}" then
            braceClosed = true

            if malformedEscapeSequence then
                self:throw(
                    "Malformed Unicode escape sequence.",
                    vector.create(malformedEscapeSequenceStart, self.position - 1)
                )

                malformedEscapeSequence = false
                malformedEscapeSequenceStart = 0
            end

            break
        end

        if not hex(character) and not malformedEscapeSequence then
            malformed = true
            malformedEscapeSequence = true
            malformedEscapeSequenceStart = self.position
        elseif hex(character) and malformedEscapeSequence then
            self:throw(
                "Malformed Unicode escape sequence.",
                vector.create(malformedEscapeSequenceStart, self.position - 1)
            )

            malformedEscapeSequence = false
            malformedEscapeSequenceStart = 0
        end

        self:bump()
        character = self:peek()
    end

    if malformedEscapeSequence then
        self:throw(
            "Malformed Unicode escape sequence.",
            vector.create(malformedEscapeSequenceStart, self.position - 1)
        )

        malformedEscapeSequence = false
        malformedEscapeSequenceStart = 0
    end

    if not braceClosed then
        self:throw("Unclosed Unicode escape sequence, expected '}'")

        self:unbump()

        return false
    end

    return not malformed
end

function LexerImpl:escapeDollar(): boolean
    if self:eof() then
        self:throw("Unexpected EOF after '$'")

        return false
    end

    local character = self:peek()

    if character ~= char "{" then
        self:throw(`Unexpected character '{ string.char(character) }' after '$', expected '\{'`)

        self:unbump()

        return false
    end

    self:bump()

    if self:eof() then
        self:throw("Unexpected EOF after '$\{'")

        return false
    end

    character = self:peek()

    if character == char "}" then
        self:throw(`Dollar escape requires an escape sequence, got empty.`)
        return false
    elseif digit(character) then
        return self:asciiEscapeSequence()
    elseif character == char "u" then
        self:bump()

        return self:unicodeEscapeSequence()
    else
        self:throw(`Unexpected character '{ string.char(character) }' after '$\{', expected 'u' or digit`)

        return false
    end
end

function LexerImpl:readName(): Lexme
    local startPosition = self.position
    local character = self:peek()
    local malformed = nil

    while
        (
            name(character)
            or character == char "^"
            or character == char "$"
        )
        and not self:eof()
    do
        if character == char "^" then
            self:bump()

            if not self:escapeCaret() then
                malformed = true
            end
        elseif character == char "$" then
            self:bump()

            if not self:escapeDollar() then
                malformed = true
            end
        end

        self:bump()
        character = self:peek()
    end

    return {
        kind = "name";
        span = vector.create(startPosition, self.position - 1);
        malformed = malformed;
    }
end

function LexerImpl:readKind(): Lexme
    if self:eof() then
        local token = {
            kind = "eof";
            span = vector.create(self.position, self.position);
        }

        table.insert(self.tokens, token)

        return token
    end

    local character = self:peek()

    if whitespace(character) then
        local whiteSpaceStart = self.position

        repeat
            self:bump()
            character = self:peek()
        until not whitespace(character)

        self:throw(
            "Whitespace is not allowed in URL",
            vector.create(whiteSpaceStart, self.position - 1)
        )
    end

    if character == char "@" then
        local token = {
            kind = "at";
            span = vector.create(self.position, self.position);
        }

        table.insert(self.tokens, token)

        self:bump()

        return token
    elseif character == char ":" then
        self:bump()
        character = self:peek()

        if character == char ":" then
            local token = {
                kind = "double_colon";
                span = vector.create(self.position - 1, self.position);
            }

            table.insert(self.tokens, token)

            self:bump()

            return token
        else
            local token = {
                kind = "unknown";
                span = vector.create(self.position - 1, self.position - 1);
                malformed = true;
            }

            table.insert(self.tokens, token)

            self:throw(
                `Unknown character ':'. Did you mean '::'?`,
                token.span
            )

            return token
        end
    elseif character == char "?" then
        local token = {
            kind = "question_mark";
            span = vector.create(self.position, self.position);
        }

        table.insert(self.tokens, token)

        self:bump()

        return token
    elseif character == char "=" then
        local token = {
            kind = "equal";
            span = vector.create(self.position, self.position);
        }

        table.insert(self.tokens, token)

        self:bump()

        return token
    elseif character == char "&" then
        local token = {
            kind = "ampersand";
            span = vector.create(self.position, self.position);
        }

        table.insert(self.tokens, token)

        self:bump()

        return token
    elseif name(character) or character == char "^" or character == char "$" then
        local token = self:readName()

        token.content = self:extract(token.span)

        table.insert(self.tokens, token)

        return token
    else
        local token = {
            kind = "unknown";
            span = vector.create(self.position, self.position);
            malformed = true;
        }

        table.insert(self.tokens, token)

        self:throw(
            `Unknown character '{ string.char(character) }'`,
            token.span
        )

        self:bump()

        return token
    end
end

function LexerImpl:scan(): ({ Lexme }, { Issue })
    if self.isScanning then
        error(`Lexer '{ tostring(self) }' is already scanning. no tokens or issues are returned`)
    end

    self.isScanning = true

    if self.hasScanned then
        warn(`Lexer '{ tostring(self) }' has already scanned once. Returning previous tokens and issues. If you want to re-scan, please use :changeSource(newSource) first.`)

        self.isScanning = false

        return self.tokens, self.issues
    end

    while not self:eof() do
        self:readKind()
    end

    self:readKind() --// to push EOF token

    self.isScanning = false
    self.hasScanned = true

    return self.tokens, self.issues
end

function LexerImpl:changeSource(
    newSource: string
)
    if self.isScanning then
        error(`Lexer '{ tostring(self) }' is currently scanning. Source cannot be changed`)
    end

    self:initialize()

    self.source = buffer.fromstring(newSource)
    self.length = buffer.len(self.source)
    self.snapshot += 1
    
    self.hasScanned = false
end

function LexerImpl:initialize(
    initializeSnapshot: boolean?
)
    if initializeSnapshot then
        self.snapshot = 0
    end

    self.position = 0
    self.line = 0
    
    table.clear(self.tokens)
    table.clear(self.issues)

    self.isScanning = false
    self.hasScanned = false
end

function LexerImpl:extract(
    span: vector
): string
    if span.x >= self.length and span.y >= self.length then
        return "<eof>"
    end

    local x = math.max(span.x or 0)
    local y = math.min(span.y or self.length - 1)

    return buffer.readstring(self.source, x, y - x + 1)
end

function LexerImpl:tostring(
    lexme: Lexme,
    displayRef: boolean?
): string
    local kind = lexme.kind
    local spanToString = `[{ lexme.span.x }, { lexme.span.y }]`
    local content = if lexme.span.x >= self.length or lexme.span.y >= self.length then "<eof>"
        else buffer.readstring(
            self.source,
            lexme.span.x,
            lexme.span.y - lexme.span.x + 1
        )
    local malformed = lexme.malformed and "MALFORMED" or "WELL-FORMED"

    return `lexme \{ { kind },\t{ spanToString },\t'{ content }',\t{ malformed } \}`
end

return LexerImpl