--#[ Services ]#--
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")

--#[ Head Variables ]#--
-- local SakuraStorage = ReplicatedStorage.sakura_storage

-- local globals = require(SakuraStorage.globals)

--#[ Modules ]#--
-- local Modules = ReplicatedStorage.modules

--#[ Constructors ]#--
local LexerImpl = require("./lexer")

--#[ Types ]#--
export type Issue = {
    why: string;
    span: vector;
}

export type ParserImpl = {
    __index: ParserImpl;

    new: (
        tokens: { LexerImpl.Lexme }
    ) -> Parser;

    throw: (
        self: Parser,
        why: string,
        span: vector?
    ) -> ();

    bump: (
        self: Parser
    ) -> ();
    peek: (
        self: Parser
    ) -> LexerImpl.Lexme;

    eof: (
        self: Parser
    ) -> boolean;

    parseHead: (
        self: Parser
    ) -> ();
    parseSegment: (
        self: Parser
    ) -> ();
    parseSegments: (
        self: Parser
    ) -> boolean;
    parseQuery: (
        self: Parser
    ) -> boolean;
    parseQueries: (
        self: Parser
    ) -> ();

    parse: (
        self: Parser
    ) -> ParseResult;
}

export type Parser = typeof(setmetatable({} :: {
    tokens: { LexerImpl.Lexme };
    length: number;
    position: number;
    issues: { Issue };
    parseResult: ParseResult;
    snapshot: number;

    isParsing: boolean;
}, {} :: ParserImpl))

export type ParseResult = {
    scope: string?;
    headSegment: string?;
    segments: { string? };
    queries: { [string]: string };
}

--#[ Variables ]#--
local ParserImpl = {} :: ParserImpl
ParserImpl.__index = ParserImpl

--#[ Functions ]#--
--

--#[ Main ]#--
function ParserImpl.new(
    tokens: { LexerImpl.Lexme }
): Parser
    local self = {}

    self.tokens = tokens
    self.length = #tokens
    self.position = 1
    self.issues = {}
    self.parseResult = {
        segments = {};
        queries = {};
    }
    self.snapshot = 0

    self.isParsing = false

    return setmetatable(self, ParserImpl)
end

function ParserImpl:throw(
    why: string,
    span: vector?
)
    table.insert(
        self.issues,
        {
            why = why;
            span = span or self:peek().span
        }
    )
end

function ParserImpl:bump()
    if self.position >= self.length then
        return
    end

    self.position += 1
end

function ParserImpl:peek(): LexerImpl.Lexme
    if self.position >= self.length then
        return self.tokens[self.length] --// EOF token
    end

    return self.tokens[self.position]
end

function ParserImpl:parseHead()
    local firstToken = self:peek()

    if firstToken.kind ~= "name" then
        self:throw(`Expected a name token at the start, got { firstToken.kind }`)
    else
        self.parseResult.scope = firstToken.content
    end

    self:bump()
    local secondToken = self:peek()

    if secondToken.kind ~= "at" then
        self:throw(`Expected '@' token, got { secondToken.kind }`)
    end

    self:bump()
    local thirdToken = self:peek()

    if thirdToken.kind ~= "name" then
        self:throw(`Expected a name token, got { thirdToken.kind }`)
    else
        self.parseResult.headSegment = thirdToken.content
    end
end

function ParserImpl:parseSegment()
    local token = self:peek()

    if token.kind ~= "double_colon" then
        self:throw(`Expected '::' token, got { token.kind }`)
    end

    self:bump()
    token = self:peek()

    if token.kind ~= "name" then
        self:throw(`Expected name(segment) token after '::' token, got { token.kind }`)
    else
        table.insert(self.parseResult.segments, token.content or nil)
    end
end

function ParserImpl:parseSegments(): boolean
    local token = self:peek()
    local hasQuery = false

    while not self:eof() do
        if token.kind == "question_mark" then
            hasQuery = true

            break
        end

        self:parseSegment()

        self:bump()
        token = self:peek()
    end

    return hasQuery
end

function ParserImpl:parseQuery(): boolean
    local token = self:peek()
    local hasAnotherQuery = false
    local key: string?, value: string?

    if token.kind ~= "name" then
        self:throw(`Expected a name token for query key, got { token.kind }`)

        return false
    else
        key = token.content
    end

    self:bump()
    local token = self:peek()

    if token.kind ~= "equal" then
        self:throw(`Expected '=' token after a query key token, got { token.kind }`)

        return false
    end

    self:bump()
    local token = self:peek()

    if token.kind ~= "name" then
        self:throw(`Expected a name token for query value after '=' token, got { token.kind }`)
    else
        value = token.content
    end

    if key and value then
        self.parseResult.queries[key] = value
    end

    self:bump()
    token = self:peek()

    if token.kind == "ampersand" then
        hasAnotherQuery = true
    end

    return hasAnotherQuery
end

function ParserImpl:parseQueries()
    local token = self:peek()

    if token.kind ~= "question_mark" then --// HOW???
        return
    end

    self:bump()
    local token = self:peek()

    while self:parseQuery() or not self:eof() do
        self:bump()
    end
end

function ParserImpl:parse()
    if self.isParsing then
        error(`Parser '{ tostring(self) }' is already parsing. no parseResult is returned`)
    end

    self.isParsing = true

    if self.length == 0 then
        self.isParsing = false

        return self.parseResult
    end

    self:parseHead()

    self:bump()

    local hasQuery = self:parseSegments()

    if hasQuery then
        self:parseQueries()
    end

    self.isParsing = false

    return self.parseResult
end

function ParserImpl:eof(): boolean
    local token = self:peek()

    if not token then
        return true
    end

    if token.kind == "eof" then
        return true
    end

    return false
end

return ParserImpl