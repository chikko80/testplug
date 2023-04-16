local Editor = {}
Editor.__index = Editor

function Editor.new(buf_nr, buf_name)
	local self = setmetatable({}, Editor)
	self.buf_nr = buf_nr
	self.buf_name = buf_name
	return self
end

return Editor
