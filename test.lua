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

local shlex = require "dromozoa.shlex"

local utf8_char = {
  string.char(0x41, 0xE2, 0x89, 0xA2, 0xCE, 0x91, 0x2E);
  string.char(0xED, 0x95, 0x9C, 0xEA, 0xB5, 0xAD, 0xEC, 0x96, 0xB4);
  string.char(0xE6, 0x97, 0xA5, 0xE6, 0x9C, 0xAC, 0xE8, 0xAA, 0x9E);
  string.char(0xEF, 0xBB, 0xBF, 0xF0, 0xA3, 0x8E, 0xB4);
}

local data = {
  { [[\ bar]], { " bar" } };
  { [[\x bar]], { "x", "bar" } };
  { [[\ x bar]], { " x", "bar" } };
  { [[foo \ bar]], { "foo", " bar" } };
  { [[foo \x bar]], { "foo", "x", "bar" } };
  { [[foo \ x bar]], { "foo", " x", "bar" } };
  { [[foo'bar'baz]], { "foobarbaz" } };
  { [[foo"bar"baz]], { "foobarbaz" } };
  { [['']], { "" } };
  { [[""]], { "" } };
  { [[foo '' bar]], { "foo", "", "bar" } };
  { [[foo "" bar]], { "foo", "", "bar" } };
  { [[foo '' '' bar]], { "foo", "", "", "bar" } };
  { [[foo "" "" bar]], { "foo", "", "", "bar" } };
  { [[\']], { [[']] } };
  { [['foo\' bar'']], { [[foo\]], [[bar]] } };
  { [['foo\\ bar']], { [[foo\\ bar]] } };
  { [['foo\x bar']], { [[foo\x bar]] } };
  { [[\"]], { [["]] } };
  { [["\""]], { [["]] } };
  { [["foo\" bar\""]], { [[foo" bar"]] } };
  { [["foo\\ bar\""]], { [[foo\ bar"]] } };
  { [["foo\x bar\""]], { [[foo\x bar"]] } };
  { [["foo\\" bar\"]], { [[foo\]], [[bar"]] } };
  { [["foo\\\ bar\""]], { [[foo\\ bar"]] } };
  { [["foo\\x bar\""]], { [[foo\x bar"]] } };
  { [["foo\\\" bar\""]], { [[foo\" bar"]] } };
  { [["foo\\\\ bar\""]], { [[foo\\ bar"]] } };
  { [["foo\\\x bar\""]], { [[foo\\x bar"]] } };
  { table.concat(utf8_char, " "), utf8_char };
}

local WS = { " ", "\t", "\n", "\r" }
for i = 1, #WS do
  local ws = ""
  for j = 1, 4 do
    ws = ws .. WS[i]
  end
  data[#data + 1] = { "foo" .. ws .. "bar", { "foo", "bar" } }
  data[#data + 1] = { "foo" .. ws .. "bar" .. ws, { "foo", "bar" } }
  data[#data + 1] = { ws .. "foo" .. ws .. "bar", { "foo", "bar" } }
  data[#data + 1] = { ws .. "foo" .. ws .. "bar" .. ws, { "foo", "bar" } }
end

for i = 1, 2 do
  local Q = i == 1 and [[']] or [["]]
  for j = 1, 7 do
    local s = ""
    if j % 2 == 1 then s = s .. Q .. "foo" .. Q else s = s .. "foo" end
    s = s .. " "
    local j = math.floor(j / 2)
    if j % 2 == 1 then s = s .. Q .. "bar" .. Q else s = s .. "bar" end
    s = s .. " "
    local j = math.floor(j / 2)
    if j % 2 == 1 then s = s .. Q .. "baz" .. Q else s = s .. "baz" end
    data[#data + 1] = { s, { "foo", "bar", "baz" } }
  end
end

for i = 1, #data do
  local a = data[i][1]
  local b = data[i][2]
  io.write(string.format("[%d]=shlex.split(%q)\n", i, a))
  local c = shlex.split(a)
  assert(#b == #c)
  for i = 1, #b do
    assert(b[i] == c[i])
  end
end

assert(not pcall(shlex.split, [[foo \]]))
assert(not pcall(shlex.split, [[foo 'bar]]))
assert(not pcall(shlex.split, [[foo "bar]]))
assert(not pcall(shlex.split, [[foo "bar\]]))
assert(not pcall(shlex.split, [[foo "bar\"]]))
