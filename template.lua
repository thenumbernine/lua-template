local table = require 'ext.table'
local class = require 'ext.class'
local showcode = require 'template.showcode'

local DefaultOutput = class()
function DefaultOutput:init()
	self.strs = table()
end
function DefaultOutput:__call(str)
	self.strs:insert(str)
end
function DefaultOutput:done()
	return self.strs:concat()
end

--[[
Lua template

template(code, env, args)
	text = text to process
	env = environment of the code in the text to use
	args = extra args
		output = override output function 
			During string processing, output(str) is called on each string block 'str'.
			Once processing is finished, the result of template() is output:done(), or nil if output has no 'done' function.
			The default 'output' accumulates strings and returns the concatenated results.

usage: template(code, {a=1, b=2, ...})
--]]
local function template(code, args, funcArgs)
	local argKeys, argValues = table(), table()
	if args then
		for k,v in pairs(args) do
			argKeys:insert(k)
			argValues:insert(v)
		end
	end
	local outputFuncName = '__output'
	local newcode = table{
		'local '..table():append({outputFuncName},argKeys):concat', '..' = ...\n',
	}
	local function addprint(from,to)
		local block = code:sub(from,to)
		local eq = ('='):rep(5)	-- TODO make sure no such [=..=[ appears in the code block
		local nl = block:find'\n' and '\n' or ''
		newcode:insert(outputFuncName..' ['..eq..'['..nl..block..']'..eq..']\n')
	end
	local pos = 1
	while true do
		local start1, start2 = code:find('<%?', pos)
		if not start1 then
			addprint(pos, #code)
			break
		else
			local ret
			if code:sub(start2+1,start2+1) == '=' then 
				ret = true
				start2 = start2 + 1
			end
			local end1, end2 = code:find('%?>', start2+1)
			end1 = end1 or #code+1
			end2 = end2 or #code-1
			addprint(pos, start1-1)
			local block = code:sub(start2+1, end1-1)
			if ret then
				newcode:insert(outputFuncName..'(tostring('..block..'))\n')
			else
				newcode:insert(block..'\n')
			end
			pos = end2+1
			if pos > #code then break end
		end
	end

	newcode = newcode:concat()
	local f, msg = load(newcode)
	if not f then
		error('\n'..showcode(newcode)..'\n'..msg)
	end

	local output = funcArgs and funcArgs.output or DefaultOutput()	
	local result, msg = pcall(function()
		f(output, argValues:unpack())
	end)
	if not result then
		error('\n'..showcode(newcode)..'\n'..msg)
	end
	return output.done and output:done() or nil
end

return template
