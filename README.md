[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=KYWUWS86GSFGL)

This is the template function that was in my LuaJIT-driven HydroCL project.
I liked it so much I put it in its own project, so other projects could use it.

Here's an example of how it works.  Similar to PHP.  

The <? ?>'s wrap executed code and the <?= ?> wrap automatically printed code.

### Dependencies:

- [lua-ext](https://github.com/thenumbernine/lua-ext)

### Example:

``` Lua
local template = require 'template'
fields = {
	{a = 'int'},
	{b = 'const char*'},
	{c = 'double'},
}
print(template([[
typedef struct {
<? for _,name_ctype in ipairs(fields) do
	local name, ctype = next(name_ctype)
?>	<?=ctype?> <?=name?>;
<? end
?>} S;
]], {
	fields = fields,
}))
```

...produces...

``` C
typedef struct {
	int a;
	const char* b;
	double c;
} S;
```

...which fits perfectly inside a ffi.cdef() call.
