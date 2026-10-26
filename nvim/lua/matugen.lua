 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#101923',
    base01 = '#1e324a',
    base02 = '#243c59',
    base03 = '#436792',
    base04 = '#c7d0db',
    base05 = '#ebe1d9',
    base06 = '#ebe1d9',
    base07 = '#ebe1d9',
    base08 = '#ffb4ab',
    base09 = '#86a9d5',
    base0A = '#dfc1a2',
    base0B = '#ffb962',
    base0C = '#96bbe9',
    base0D = '#ffc680',
    base0E = '#e9c096',
    base0F = '#f4d9be',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#ebe1d9',          bg = '#101923' })
  hi('TelescopeBorder',         { fg = '#436792',             bg = '#101923' })
  hi('TelescopePromptNormal',   { fg = '#ebe1d9',          bg = '#101923' })
  hi('TelescopePromptBorder',   { fg = '#436792',             bg = '#101923' })
  hi('TelescopePromptPrefix',   { fg = '#ffb962',             bg = '#101923' })
  hi('TelescopePromptCounter',  { fg = '#c7d0db',  bg = '#101923' })
  hi('TelescopePromptTitle',    { fg = '#101923',             bg = '#ffb962' })
  hi('TelescopePreviewTitle',   { fg = '#101923',             bg = '#dfc1a2' })
  hi('TelescopeResultsTitle',   { fg = '#101923',             bg = '#86a9d5' })
  hi('TelescopeSelection',      { fg = '#ebe1d9',          bg = '#243c59' })
  hi('TelescopeSelectionCaret', { fg = '#ffb962',             bg = '#243c59' })
  hi('TelescopeMatching',       { fg = '#ffb962',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#ebe1d9',          bg = '#101923' })
  hi('MiniPickBorder',         { fg = '#436792',             bg = '#101923' })
  hi('MiniPickPrompt',   { fg = '#ebe1d9',          bg = '#101923' })
  hi('MiniPickPromptPrefix',   { fg = '#ffb962',             bg = '#101923' })
  hi('MiniPickBorderText',    { fg = '#101923',             bg = '#ffb962' })
  hi('MiniPickMatchCurrent',      { fg = '#ebe1d9',          bg = '#243c59' })
  hi('MiniPickPromptCaret', { fg = '#ffb962',             bg = '#243c59' })
  hi('MiniPickMatchRanges',       { fg = '#ffb962',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
