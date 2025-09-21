#!/usr/bin/env lua5.1
--
-- basic script for converting a neovim theme in lua to vim theme in .vim
-- format.
--

function basename(path)
	local b = path:match(".*[/\\](.*)")
	if not b then
		return path
	end
	return b
end

function dirname(path)
	if path:sub(-1) == '/' then
		path = path:sub(1, -2)
	end

	local d = path:match("(.*[/\\])")
	if not d then
		return './'
	end
	return d
end

function color(c)
	if not c or c:lower() == 'none' then
		return 'NONE'
	end
	return c
end

vim = {}
vim.tbl_extend = function (option, table, table_extend)
	return table_extend
end
vim.api = {}
vim.api.nvim_set_hl = function (index, name, c)
	-- skip names starting with @, not sure what they should map to in
	-- vim
	if string.find(name, "@") then
		return
	end
	print('  hi ' .. name .. ' guibg=' .. color(c.bg) .. ' guifg=' .. color(c.fg))
end
vim.o = {}
vim.g = {}

function print_theme_header(name)
	print("hi clear")
	print("if exists('syntax_on')")
	print("  syntax reset")
	print("endif")
	print("")
	print("let g:colors_name = '" .. name .. "'")
	print("")
end

function print_theme(mod, mode)
	vim.o.background = mode
	theme = require(mod .. '.theme')
	print("if &background == '" .. mode .. "'")
	theme.set_highlights({})
	print('endif')
end

function print_copyright_in_file(f)
	local found = false
	for line in f:lines() do
		match = line:find("Copyright")
		if match ~= nil then
			spos, epos = match
			copyright = line:sub(spos, epos)
			print("\" " .. copyright)
			found = true
		end
	end
	return found
end

function print_copyright(dir)
	local parent = dirname(dir)
	local names = {'LICENSE', 'LICENSE.md'}
	local found = false
	for _, name in pairs(names) do
		local path = parent .. name
		local f = io.open(path, 'r')
		if f ~= nil then
			found = print_copyright_in_file(f)
			f:close()
		end
		if found then
			break
		end
	end
end

local args = {...}
local path = args[1]
local name = basename(path)
local dir = dirname(path)

print_copyright(dir)
print('')
print('hi clear')
print("if exists('syntax_on')")
print('  syntax reset')
print('endif')
print('')
print("let g:colors_name = '" .. name .. "'")
print('')

package.path = package.path .. ';' .. dir .. '?.lua'
print_theme(name, 'dark')
print_theme(name, 'light')
