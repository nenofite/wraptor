---
-- Wrap paragraphs of text along word boundaries while preserving line
-- prefixes.
--
-- @module wraptor
local M = {}

-- Uncomment this line when running unit tests.
--local lpeg = require 'lpeg'

---
-- The maximum length of a line of text when wrapping.
M.max_line_length = 80

---
-- Check whether the given argument is of the expected type, throwing an error
-- if it is not.
--
-- @tparam string name The name of the argument, to be used in the error
-- message.
--
-- @param arg The argument to check.
--
-- @tparam string expected_type The string form of the expected type, as
-- returned by the builtin function @{type}.
--
-- @tparam boolean optional (optional) Whether the argument is optional. If
-- the argument is optional, then nil is an accepted value. Defaults to false.
local function arg(name, arg, expected_type, optional)
  local bad = type(arg) ~= expected_type
  
  if bad and optional and arg == nil then
    bad = false
  end

  if bad then
    local message = "The argument `" .. name .. "` must be of the type " ..
      expected_type
    
    if optional and expected_type ~= 'nil' then
      message = message .. " or nil"
    end
    
    error(message .. ".")
  end
end

---
-- Separate the lines in the text into a list.
--
-- @tparam string text The text to split.
--
-- @treturn table A list of lines, none of which contain newlines.
function M.split_lines(text)
  local result = {}

  local start_index = 1
  
  while true do
    local stop_index = string.find(text, '\n', start_index)
    
    if stop_index then
      table.insert(result, string.sub(text, start_index, stop_index - 1))
      start_index = stop_index + 1
    else
      table.insert(result, string.sub(text, start_index, -1))
      break
    end
  end
  
  return result
end

---
-- Split the text into lines such that no line exceeds the maximum line length.
--
-- @tparam string text The text to wrap.
--
-- @tparam number max_line_length The maximum length of a single line. This
-- must be at least 2.
--
-- @treturn table A list of lines of text.
function M.wrap_text(text, max_line_length)
  arg('text', text, 'string')
  arg('max_line_length', max_line_length, 'number')
  
  assert(
    max_line_length >= 2,
    "The argument `max_line_length` must be at least 2."
  )
  
  local result = {}
  
  local current_line = ''
	
	local function add_word(word, is_second_try)
		local candidate_length = #word
		local add_space = #current_line ~= 0
    
		if add_space then
			candidate_length = candidate_length + 1
		end
		
		if #current_line + candidate_length < max_line_length then
			if add_space then
				current_line = current_line .. ' ' .. word
			else
				current_line = current_line .. word
			end
		else
			if is_second_try then
        current_line = word
			else
				if #current_line > 0 then
          table.insert(result, current_line)
          current_line = ''
        end
        
				add_word(word, true)
			end
		end
	end
	
	for word in string.gmatch(text, '[^ \t\n\r]+') do
		add_word(word)
	end
  
  if #current_line > 0 then
    table.insert(result, current_line)
  end
	
	return result
end

local line_prefix_peg = lpeg.C(
  (lpeg.P(1) - (lpeg.R'az' + lpeg.R'AZ' + lpeg.R'09')) ^ 0
)

---
-- Determine what portion of this line is the prefix and return it.
--
-- @tparam string line The line from which to extract the prefix. It must
-- contain no newlines.
--
-- @treturn string The prefix of the given line.
function M.extract_prefix(line)
  arg('line', line, 'string')
  
  return line_prefix_peg:match(line)
end

---
-- Determine whether this line could be considered part of a paragraph.
--
-- @tparam string line The line to consider. It must contain no newlines. It
-- still contains the prefix.
--
-- @tparam string prefix The prefix of this line, extracted by the function
-- @{M.extract_prefix}.
--
-- @treturn boolean Whether the line could be part of a paragraph.
function M.is_within_paragraph(line, prefix)
  arg('line', line, 'string')
  arg('prefix', prefix, 'string')

  return #prefix ~= #line
end

---
-- Split the lines of text apart such that no line exceeds the maximum line
-- length, while preserving individual paragraphs.
--
-- Text will only wrap within the same paragraph. Lines between paragraphs
-- will be preserved.
--
-- @tparam string text The text to wrap.
--
-- @tparam number max_line_length The maximum length of a line of text.
--
-- @treturn string The wrapped text.
function M.wrap_paragraphs(text, max_line_length)
  arg('text', text, 'string')
  arg('max_line_length', max_line_length, 'number')

  local lines = M.split_lines(text)
  
  local result_lines = {}
  
  local num_lines = #lines
  local i = 1
  
  -- Loop through each line of text.
  while i <= num_lines do
    local line = lines[i]
  
    local prefix = M.extract_prefix(line)
    if M.is_within_paragraph(line, prefix) then
      -- If the line is a paragraph, loop through the remaining lines until we find
      -- the end of the paragraph or the end of the input text. Remove the prefix
      -- from each line and add it to a temporary buffer.
      local paragraph = ''
      while i <= num_lines do
        line = lines[i]
        
        local prefix2 = M.extract_prefix(line)
        if M.is_within_paragraph(line, prefix2) then
          paragraph = paragraph .. '\n' .. string.sub(line, #prefix2 + 1)
          i = i + 1
        else
          i = i - 1
          break
        end
      end
      
      -- Wrap the buffer, discounting the length of the prefix from the maximum
      -- line length.
      local wrapped_lines = M.wrap_text(paragraph, max_line_length - #prefix)
      
      -- Loop through the results of the wrap, prepending them with the prefix and
      -- adding the resulting line to our results.
      for _, wrapped_line in ipairs(wrapped_lines) do
        table.insert(result_lines, prefix .. wrapped_line)
      end
    else
      -- If the line is non-paragraph, pass it through to the results without
      -- modification.
      table.insert(result_lines, line)
    end
    
    i = i + 1
  end
  
  if #result_lines == 0 then
    return ''
  end
  
  local result = result_lines[1]
  
  for i = 2, #result_lines do
    result = result .. '\n' .. result_lines[i]
  end
  
  return result
end

---
-- Wrap the text that is currently selected in Textadept.
function M.wrap_selection()
  local original_text = buffer:get_sel_text()
  
  local start = buffer.selection_start
  local length = buffer.selection_end - start
  
  local wrapped = M.wrap_paragraphs(original_text, M.max_line_length)
  
  buffer:begin_undo_action()
  buffer:delete_range(start, length)
  buffer:insert_text(-1, wrapped)
  buffer:end_undo_action()
end

return M