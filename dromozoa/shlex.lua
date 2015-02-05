-- Copyright (C) 2015 Tomoyuki Fujimori <moyu@dromozoa.com>
--
-- This file is part of dromozoa-shlex.
--
-- dromozoa-shlex is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- dromozoa-shlex is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-shlex.  If not, see <http://www.gnu.org/licenses/>.

local utf8 = require "dromozoa.utf8"

local SQ = 0x27 -- U+0027 APORSTROPHE
local DQ = 0x22 -- U+0022 QUOTATION MARK
local SP = 0x20 -- U+0020 SPACE
local HT = 0x09 -- U+0009 CHARACTER TABULATION
local LF = 0x0A -- U+000A LINE FEED (LF)
local CR = 0x0D -- U+000D CARRIAGE RETURN (CR)
local BS = 0x5C -- U+005C REVERSE SOLIDUS

local function split(s)
  local token
  local state
  local escape = false
  local result = {}
  for p, c in utf8.codes(s) do
    local s = utf8.char(c)
    if state == SQ then
      if c == SQ then
        state = nil
      else
        token[#token + 1] = s
      end
    elseif state == DQ then
      if escape then
        if c == DQ or c == BS then
          token[#token + 1] = s
        else
          token[#token + 1] = "\\"
          token[#token + 1] = s
        end
        escape = false
      else
        if c == DQ then
          state = nil
        elseif c == BS then
          escape = true
        else
          token[#token + 1] = s
        end
      end
    else
      if escape then
        token[#token + 1] = s
        escape = false
      else
        if c == SP or c == HT or c == LF or c == CR then
          if token ~= nil then
            result[#result + 1] = table.concat(token)
            token = nil
          end
        else
          if token == nil then token = {} end
          if c == SQ then
            state = SQ
          elseif c == DQ then
            state = DQ
          elseif c == BS then
            escape = true
          else
            token[#token + 1] = s
          end
        end
      end
    end
  end

  if state ~= nil then
    error "no closing quotation"
  end
  if escape then
    error "no escaped character"
  end

  if token ~= nil then
    result[#result + 1] = table.concat(token)
  end
  return result
end

return {
  split = split;
  version = function () return "1.0" end;
}
