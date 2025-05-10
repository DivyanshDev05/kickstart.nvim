-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = '[U]ndo Tree Toggle' })
vim.keymap.set('i', 'kl', '<esc>')

return {
  'mbbill/undotree',
}
