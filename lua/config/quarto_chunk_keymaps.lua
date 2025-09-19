-- Quarto/Markdown chunk motions and run-chunk via Iron
local chunks = require("config.r_quarto_chunks")
local templates = require("config.quarto_chunk_templates")

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "quarto", "markdown", "rmd", "qmd" },
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.keymap.set("n", "]]", chunks.goto_next_chunk, { buffer = buf, desc = "Next code chunk" })
    vim.keymap.set("n", "[[", chunks.goto_prev_chunk, { buffer = buf, desc = "Prev code chunk" })
    vim.keymap.set("n", "<leader>rc", chunks.send_current_chunk, { buffer = buf, desc = "Run current chunk (R)" })
    -- Override iron defaults in prose buffers: only send when inside R chunks
    vim.keymap.set("n", "<space>sl", chunks.send_line_in_chunk, { buffer = buf, desc = "Send line (R chunk only)" })
    vim.keymap.set("n", "<space>sp", chunks.send_paragraph_in_chunk, { buffer = buf, desc = "Send paragraph (R chunk only)" })
    pcall(vim.keymap.del, "v", "<space>sc", { buffer = buf })
    vim.keymap.set("v", "<space>sc", chunks.send_selection_in_chunk, { buffer = buf, desc = "Send selection (R chunk only)" })
    vim.keymap.set("n", "<leader>qf", templates.insert_figure_chunk, { buffer = buf, desc = "Insert figure chunk" })
    vim.keymap.set("n", "<leader>qs", templates.insert_asis_chunk, { buffer = buf, desc = "Insert as-is chunk" })
    vim.keymap.set("n", "<leader>qt", templates.insert_table_chunk, { buffer = buf, desc = "Insert table chunk" })
    vim.keymap.set("n", "<leader>qc", templates.insert_empty_r_chunk, { buffer = buf, desc = "Insert empty R chunk" })
    vim.keymap.set("n", "<leader>qb", templates.insert_pagebreak, { buffer = buf, desc = "Insert page break" })
  end,
  desc = "Quarto/Markdown chunk keymaps",
})
