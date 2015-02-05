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
local unpack = table.unpack or unpack

-- quotes
-- escapedquotes
-- wordchars

-- mode
--   initial      nil
--   single quote 0x27
--   double quote 0x22
--   white space  0x20,0x09,0x0d,0x0a
-- escape         0x5C

local SQ = 0x27
local DQ = 0x22
local SP = 0x20
local HT = 0x09
local LF = 0x0A
local CR = 0x0D
local BS = 0x5C

local function split(s)
  local result = {}

  local token
  local state
  local escape
  for p, c in utf8.codes(s) do
    if state == SQ then
      if c == SQ then
        state = nil
      else
        token[#token + 1] = c
      end
    elseif state == DQ then
      if escape then
        if c ~= DQ and c ~= BS then
          token[#token + 1] = BS
        end
        token[#token + 1] = c
        escape = nil
      else
        if c == DQ then
          state = nil
        elseif c == BS then
          escape = true
        else
          token[#token + 1] = c
        end
      end
    else
      if escape then
        token[#token + 1] = c
        escape = nil
      else
        if c == SQ then
          state = SQ
          if token == nil then token = {} end
        elseif c == DQ then
          state = DQ
          if token == nil then token = {} end
        elseif c == BS then
          escape = true
          if token == nil then token = {} end
        elseif c == SP or c == HT or c == LF or c == CR then
          if token ~= nil then
            result[#result + 1] = utf8.char(unpack(token))
            token = nil
          end
        else
          if token == nil then token = {} end
          token[#token + 1] = c
        end
      end
    end
  end

  assert(state == nil)
  assert(not escape)
  if token ~= nil then
    result[#result + 1] = utf8.char(unpack(token))
    token = nil
  end
  return result
end

return {
  split = split;
}
