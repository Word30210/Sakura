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

    isLexing: boolean;
}, {} :: LexerImpl))

export type Lexme = {
    kind: string;
    span: vector;
    malformed: boolean?;
    metadata: any?;
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
    local malformed = nil
    local includingEscapeBased10 = nil
    local includingEscapeBased16 = nil

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
        elseif character == char "$" then
            self:bump()
            character = self:peek()

            if character ~= char "{" then
                self:throw("Expected '{' after '$' in name.")

                malformed = true

                continue
            end

            self:bump()
            character = self:peek()

            if character == char "}" then
                self:bump()
                character = self:peek()

                continue
            elseif character == char "u" then
                includingEscapeBased16 = true

                while true do
                    if self:eof() then
                        self:throw("Unexpected end of file in ascii/unicode escape sequence.")

                        malformed = true

                        break
                    end

                    if character == char "}" then
                        break
                    end

                    if not hex(character) then
                        self:throw("Expected hex character in ascii/unicode escape sequence.")

                        malformed = true

                        break
                    end

                    self:bump()
                    character = self:peek()
                end
            else
                includingEscapeBased10 = true

                while true do
                    if self:eof() then
                        self:throw("Unexpected end of file in ascii/unicode escape sequence.")

                        malformed = true

                        break
                    end

                    if character == char "}" then
                        break
                    end

                    if not digit(character) then
                        self:throw("Expected hex character in ascii/unicode escape sequence.")

                        malformed = true

                        break
                    end

                    self:bump()
                    character = self:peek()
                end
            end
        end

        self:bump()
        character = self:peek()
    end

    return {
        kind = "name";
        span = vector.create(startPosition, self.position - 1);
        malformed = malformed;
        metadata = if includingEscapeBased10 or includingEscapeBased16 then {
            includingEscapeBased10 = includingEscapeBased10;
            includingEscapeBased16 = includingEscapeBased16;
        } else nil;
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

        local token = {
            kind = "at";
            span = vector.create(startPosition, startPosition);
        }

        table.insert(self.tokens, token)

        return token
    elseif character == char ":" then
        self:bump()

        character = self:peek()

        if character == char ":" then
            self:bump()

            local token = {
                kind = "double_colon";
                span = vector.create(startPosition, startPosition + 1);
            }

            table.insert(self.tokens, token)

            return token
        else
            self:throw(`Unknown character '{ character }' found.`)

            local token = {
                kind = "unknwon";
                span = vector.create(startPosition, startPosition);
            }

            table.insert(self.tokens, token)

            return token
        end
    elseif character == char "?" then
        self:bump()

        local token = {
            kind = "question_mark";
            span = vector.create(startPosition, startPosition);
        }

        table.insert(self.tokens, token)

        return token
    elseif character == char "=" then
        self:bump()

        local token = {
            kind = "equal";
            span = vector.create(startPosition, startPosition);
        }

        table.insert(self.tokens, token)

        return token
    elseif character == char "&" then
        self:bump()

        local token = {
            kind = "ampersand";
            span = vector.create(startPosition, startPosition);
        }

        table.insert(self.tokens, token)

        return token
    elseif character == 0 then
        local token = {
            kind = "eof";
            span = vector.create(self.length, self.length);
        }

        table.insert(self.tokens, token)
    
        return token
    elseif name(character) or character == char "^" or character == char "$" then
        return self:readName()
    elseif whitespace(character) then
        repeat
            self:bump()
            character = self:peek()
        until not whitespace(character)

        local token = self:readKind()

        table.insert(self.tokens, token)

        return token
    else
        self:throw(`Unknown character '{ character }' found.`)

        local token = {
            kind = "unknown";
            span = vector.create(startPosition, startPosition);
        }

        table.insert(self.tokens, token)

        return token
    end
end

function LexerImpl:tostring(
    lexme: Lexme
): string
    return ([[
Lexer {
    kind = "%s";
    span = [%s, %s];
    content = [%s];
    malformed = %s;
    ref = [%s];
}
]]):format(
        lexme.kind,
        tostring(lexme.span.x),
        tostring(lexme.span.y),
        buffer.readstring(
            self.source,
            lexme.span.x,
            lexme.span.y - lexme.span.x + 1
        ),
        lexme.malformed and "true" or "false",
        tostring(lexme)
    )
end

return LexerImpl