return {
  {
    "tpope/vim-fugitive",
    cmd = {
      "Git",
      "G",
      "Gdiffsplit",
      "Gvdiffsplit",
      "Gwrite",
      "Gread",
      "Gedit",
    },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status (Fugitive)" },
      { "<leader>gc", "<cmd>Git commit<cr>", desc = "Git commit (Fugitive)" },
      { "<leader>gp", "<cmd>Git push<cr>", desc = "Git push (Fugitive)" },
      { "<leader>gl", "<cmd>Git log --oneline<cr>", desc = "Git log (Fugitive)" },
    },
  },
}
