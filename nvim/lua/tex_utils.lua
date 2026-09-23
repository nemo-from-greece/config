-- Requires VimTeX (for the texMathZone syntax group). If you don't use
-- VimTeX, swap these for whatever your setup uses to detect math zones.
local M = {}

function M.in_mathzone()
  return vim.fn['vimtex#syntax#in']('texMathZone') == 1
end

function M.in_text()
  return not M.in_mathzone()
end

-- true if cursor is inside an environment named `name` (e.g. "cases")
function M.in_env(name)
  local is_inside = vim.fn['vimtex#env#is_inside'](name)
  return (is_inside[1] > 0 and is_inside[2] > 0)
end

return M
