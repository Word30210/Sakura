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
    peek: (
        self: Lexer
    ) -> number;

    eof: (
        self: Lexer
    ) -> boolean;
    
    readName: (
        self: Lexer
    ) -> Lexme;
    readKind: (
        self: Lexer
    ) -> Lexme;
}

export type Lexer = typeof(setmetatable({} :: {
    source: buffer;
    length: number;
    position: number;
    line: number;
    tokens: { Lexme };
    issues: { Issue };

    isLexing: boolean;
}, {} :: LexerImpl))

export type Lexme = {
    kind: string;
    span: vector;
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

local function operator(
    character: number
): boolean
    return character == char "@"
        or character == char ":"
        or character == char "?"
        or character == char "="
        or character == char "&"
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

    self.isLexing = false

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

function LexerImpl:peek(): number
    if self.position >= self.length then
        return 0
    end

    return buffer.readu8(self.source, self.position)
end

function LexerImpl:eof(): boolean
    return self.position >= self.length
end

function LexerImpl:readName(): Lexme
    local startPosition = self.position
    local character = self:peek()

    while
        name(character) and not self:eof()
    do
        self:bump()
        character = self:peek()
    end

    return {
        kind = "name";
        span = vector.create(startPosition, self.position - 1);
    }
end

function LexerImpl:readKind(): Lexme
    local startPosition = self.position

    if startPosition >= self.length then
        return {
            kind = "eof";
            span = vector.create(self.length, self.length);
        }
    end

    local character = self:peek()

    if character == char "@" then
        self:bump()

        return {
            kind = "at";
            span = vector.create(startPosition, startPosition);
        }
    elseif character == char ":" then
        self:bump()

        character = self:peek()

        if character == char ":" then
            self:bump()

            return {
                kind = "double_colon";
                span = vector.create(startPosition, startPosition + 1);
            }
        else
            return {
                kind = "unknwon";
                span = vector.create(startPosition, startPosition);
            }
        end
    elseif character == char "?" then
        self:bump()

        return {
            kind = "question_mark";
            span = vector.create(startPosition, startPosition);
        }
    elseif character == char "=" then
        self:bump()

        return {
            kind = "equal";
            span = vector.create(startPosition, startPosition);
        }
    elseif character == char "&" then
        self:bump()

        return {
            kind = "ampersand";
            span = vector.create(startPosition, startPosition);
        }
    elseif character == 0 then
        return {
            kind = "eof";
            span = vector.create(self.length, self.length);
        }
    elseif name(character) then
        return self:readName()
    elseif whitespace(character) then
        repeat
            self:bump()
            character = self:peek()
        until not whitespace(character)

        return self:readKind()
    else
        return {
            kind = "unknown";
            span = vector.create(startPosition, startPosition);
        }
    end
end

return LexerImpl