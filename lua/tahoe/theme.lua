local M = {}

M.colors = {
  bg = "#191D27",
  bg_alt = "#141923",
  bg_float = "#1B202C",
  bg_highlight = "#1F2734",
  bg_status = "#1E2533",
  fg = "#E0E0E0",
  fg_dim = "#B7C1CE",
  comment = "#6C7C90",
  selection = "#273D4C",
  border = "#35424C",
  cursor = "#EDEDED",
  black = "#35424C",
  red = "#DF6C5A",
  green = "#79BE7E",
  yellow = "#E5C872",
  blue = "#67B5ED",
  magenta = "#D389E5",
  cyan = "#7CCBCD",
  white = "#DEE5EB",
  bright_black = "#465C6D",
  bright_red = "#DF6C5A",
  bright_green = "#79BE7E",
  bright_yellow = "#E5C872",
  bright_blue = "#67B5ED",
  bright_magenta = "#D389E5",
  bright_cyan = "#84DDE0",
  bright_white = "#E5EFF5",
  diff_add = "#20342A",
  diff_delete = "#402527",
  diff_change = "#1F3342",
  diff_text = "#27445C",
}

local function base_highlights(c)
  return {
    Normal = { fg = c.fg, bg = c.bg },
    NormalNC = { fg = c.fg, bg = c.bg },
    NormalFloat = { fg = c.fg, bg = c.bg_float },
    FloatBorder = { fg = c.border, bg = c.bg_float },
    FloatTitle = { fg = c.blue, bg = c.bg_float, bold = true },
    SignColumn = { fg = c.fg, bg = c.bg },
    Cursor = { fg = c.bg, bg = c.cursor },
    CursorLine = { bg = c.bg_highlight },
    CursorLineNr = { fg = c.yellow, bg = c.bg_highlight, bold = true },
    LineNr = { fg = c.comment, bg = c.bg },
    Folded = { fg = c.fg_dim, bg = c.bg_alt },
    FoldColumn = { fg = c.comment, bg = c.bg },
    ColorColumn = { bg = c.bg_alt },
    Conceal = { fg = c.comment },
    Directory = { fg = c.blue },
    EndOfBuffer = { fg = c.bg_alt },
    ErrorMsg = { fg = c.bg, bg = c.red, bold = true },
    WarningMsg = { fg = c.bg, bg = c.yellow },
    ModeMsg = { fg = c.cyan, bold = true },
    MoreMsg = { fg = c.green },
    Question = { fg = c.yellow },
    Title = { fg = c.blue, bold = true },
    Visual = { bg = c.selection },
    VisualNOS = { bg = c.selection },
    Search = { fg = c.bg, bg = c.yellow },
    IncSearch = { fg = c.bg, bg = c.magenta },
    Substitute = { fg = c.bg, bg = c.blue },
    MatchParen = { fg = c.yellow, bg = c.bg_alt, bold = true },
    NonText = { fg = c.comment },
    Pmenu = { fg = c.fg, bg = c.bg_float },
    PmenuSel = { fg = c.bg, bg = c.blue },
    PmenuSbar = { bg = c.bg_highlight },
    PmenuThumb = { bg = c.blue },
    WildMenu = { fg = c.bg, bg = c.green, bold = true },
    StatusLine = { fg = c.fg, bg = c.bg_status },
    StatusLineNC = { fg = c.comment, bg = c.bg_status },
    WinSeparator = { fg = c.border, bg = c.bg },
    VertSplit = { fg = c.border },
    TabLine = { fg = c.comment, bg = c.bg_alt },
    TabLineSel = { fg = c.fg, bg = c.bg_highlight, bold = true },
    TabLineFill = { fg = c.comment, bg = c.bg_alt },
    Whitespace = { fg = c.comment },
    HighlightedyankRegion = { bg = c.selection },
  }
end

local function syntax_highlights(c)
  return {
    Comment = { fg = c.comment, italic = true },
    Constant = { fg = c.cyan },
    String = { fg = c.green },
    Character = { fg = c.green },
    Number = { fg = c.yellow },
    Boolean = { fg = c.yellow },
    Float = { fg = c.yellow },
    Identifier = { fg = c.blue },
    Function = { fg = c.blue },
    Statement = { fg = c.magenta },
    Conditional = { fg = c.magenta },
    Repeat = { fg = c.magenta },
    Label = { fg = c.cyan },
    Operator = { fg = c.fg },
    Keyword = { fg = c.magenta },
    Exception = { fg = c.red },
    PreProc = { fg = c.cyan },
    Include = { fg = c.cyan },
    Define = { fg = c.magenta },
    Macro = { fg = c.yellow },
    Type = { fg = c.yellow },
    StorageClass = { fg = c.yellow },
    Structure = { fg = c.cyan },
    Typedef = { fg = c.yellow },
    Special = { fg = c.green },
    SpecialComment = { fg = c.comment, italic = true },
    Underlined = { fg = c.blue, underline = true },
    Bold = { bold = true },
    Italic = { italic = true },
    Todo = { fg = c.yellow, bg = c.bg_alt, bold = true },
  }
end

local function diagnostic_highlights(c)
  return {
    DiagnosticError = { fg = c.red },
    DiagnosticWarn = { fg = c.yellow },
    DiagnosticInfo = { fg = c.cyan },
    DiagnosticHint = { fg = c.blue },
    DiagnosticUnderlineError = { undercurl = true, sp = c.red },
    DiagnosticUnderlineWarn = { undercurl = true, sp = c.yellow },
    DiagnosticUnderlineInfo = { undercurl = true, sp = c.cyan },
    DiagnosticUnderlineHint = { undercurl = true, sp = c.blue },
    DiagnosticSignError = { fg = c.red, bg = c.bg },
    DiagnosticSignWarn = { fg = c.yellow, bg = c.bg },
    DiagnosticSignInfo = { fg = c.cyan, bg = c.bg },
    DiagnosticSignHint = { fg = c.blue, bg = c.bg },
  }
end

local function git_highlights(c)
  return {
    DiffAdd = { bg = c.diff_add },
    DiffChange = { bg = c.diff_change },
    DiffDelete = { bg = c.diff_delete },
    DiffText = { bg = c.diff_text },
    GitSignsAdd = { fg = c.green },
    GitSignsChange = { fg = c.cyan },
    GitSignsDelete = { fg = c.red },
  }
end

local function plugin_highlights(c)
  return {
    TelescopeNormal = { fg = c.fg, bg = c.bg_float },
    TelescopeBorder = { fg = c.border, bg = c.bg_float },
    TelescopeSelection = { fg = c.blue, bg = c.bg_highlight, bold = true },
    TelescopePromptNormal = { fg = c.fg, bg = c.bg_alt },
    TelescopePromptBorder = { fg = c.border, bg = c.bg_alt },
    TelescopePromptTitle = { fg = c.bg, bg = c.blue },
    TelescopePreviewTitle = { fg = c.bg, bg = c.green },
    TelescopeResultsTitle = { fg = c.bg, bg = c.magenta },
    LspReferenceRead = { bg = c.bg_highlight },
    LspReferenceText = { bg = c.bg_highlight },
    LspReferenceWrite = { bg = c.bg_highlight },
    NavicIconsFile = { fg = c.blue },
    NavicIconsModule = { fg = c.magenta },
    NavicIconsNamespace = { fg = c.yellow },
    NavicIconsPackage = { fg = c.yellow },
    NavicIconsClass = { fg = c.blue },
    NavicIconsMethod = { fg = c.blue },
    NavicIconsProperty = { fg = c.cyan },
    NavicIconsField = { fg = c.cyan },
    NavicIconsConstructor = { fg = c.magenta },
    NavicIconsEnum = { fg = c.yellow },
    NavicIconsInterface = { fg = c.cyan },
    NavicIconsFunction = { fg = c.blue },
    NavicIconsVariable = { fg = c.magenta },
    NavicIconsConstant = { fg = c.yellow },
    NavicIconsString = { fg = c.green },
    NavicIconsNumber = { fg = c.yellow },
    NavicIconsBoolean = { fg = c.yellow },
    NavicIconsArray = { fg = c.cyan },
    NavicIconsObject = { fg = c.cyan },
    NavicIconsKey = { fg = c.magenta },
    NavicIconsNull = { fg = c.comment },
    NavicIconsEnumMember = { fg = c.yellow },
    NavicIconsStruct = { fg = c.cyan },
    NavicIconsEvent = { fg = c.blue },
    NavicIconsOperator = { fg = c.cyan },
    NavicIconsTypeParameter = { fg = c.magenta },
    NavicText = { fg = c.fg_dim },
    NavicSeparator = { fg = c.border },
    NoiceCmdlinePopup = { fg = c.fg, bg = c.bg_float },
    NoiceCmdlinePopupBorder = { fg = c.border, bg = c.bg_float },
    SnacksPickerBorder = { fg = c.border, bg = c.bg_float },
  }
end

local function treesitter_highlights(c)
  return {
    ["@comment"] = { link = "Comment" },
    ["@constant"] = { link = "Constant" },
    ["@string"] = { link = "String" },
    ["@character"] = { link = "Character" },
    ["@number"] = { link = "Number" },
    ["@boolean"] = { link = "Boolean" },
    ["@float"] = { link = "Float" },
    ["@function"] = { link = "Function" },
    ["@function.builtin"] = { fg = c.magenta },
    ["@function.macro"] = { fg = c.yellow },
    ["@method"] = { link = "Function" },
    ["@field"] = { fg = c.cyan },
    ["@property"] = { fg = c.cyan },
    ["@parameter"] = { fg = c.fg },
    ["@keyword"] = { link = "Keyword" },
    ["@keyword.function"] = { fg = c.magenta },
    ["@keyword.operator"] = { link = "Operator" },
    ["@type"] = { link = "Type" },
    ["@type.builtin"] = { fg = c.yellow },
    ["@type.qualifier"] = { fg = c.magenta },
    ["@tag"] = { fg = c.red },
    ["@attribute"] = { fg = c.cyan },
    ["@punctuation.bracket"] = { fg = c.fg },
  }
end

function M.apply(opts)
  opts = opts or {}
  local c = M.colors

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end

  vim.o.background = "dark"
  vim.o.termguicolors = true
  vim.o.winblend = 0
  vim.o.pumblend = 0

  local highlights = {}
  for _, group in ipairs({
    base_highlights,
    syntax_highlights,
    diagnostic_highlights,
    git_highlights,
    plugin_highlights,
    treesitter_highlights,
  }) do
    local defs = group(c)
    for k, v in pairs(defs) do
      highlights[k] = v
    end
  end

  for name, definition in pairs(highlights) do
    vim.api.nvim_set_hl(0, name, definition)
  end

  vim.g.colors_name = "tahoe"

  if not opts.silent then
    vim.notify("Tahoe theme enabled")
  end
end

return M
