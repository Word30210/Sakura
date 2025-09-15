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
        lexer: LexerImpl.Lexer
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
    ) -> LexerImpl.Lexme?;

    eof: (
        self: Parser
    ) -> boolean;

    parse: (
        self: Parser
    ) -> ParseResult;
}

export type Parser = typeof(setmetatable({} :: {
    lexer: LexerImpl.Lexer;
    length: number;
    position: number;
    issues: { Issue };
    snapshot: number;

    isParsing: boolean;
}, {} :: ParserImpl))

export type ParseResult = {
    scope: string;
    headSegment: string;
    segments: { string };
    queries: { [string]: string }?;
}

--#[ Variables ]#--
local ParserImpl = {} :: ParserImpl
ParserImpl.__index = ParserImpl

--#[ Functions ]#--
--

--#[ Main ]#--
function ParserImpl.new(
    lexer: LexerImpl.Lexer
): Parser
    local self = {}

    self.tokens = tokens
    self.length = #tokens
    self.position = 1
    self.issues = {}

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
            span = span or vector.create(self.position, self.position)
        }
    )
end

function ParserImpl:bump()
    if self.position >= self.length then
        return
    end

    self.position += 1
end

function ParserImpl:peek(): LexerImpl.Lexme?
    if self.position >= self.length then
        return nil
    end

    return self.tokens[self.position]
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