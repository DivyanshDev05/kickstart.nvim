-- enabled lsp
vim.lsp.enable 'phpactor'

--undotree keybindings
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = '[U]ndo Tree Toggle' })

--personal keybindings
vim.keymap.set('i', 'kl', '<esc>')
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = '[B]uffer [D]elete' })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = '[Q]uit Nvim' })
vim.keymap.set('n', '<leader>m', ':Mason<CR>', { desc = '[M]ason' })
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = '[W]rite/Save File' })
vim.opt.relativenumber = true

--telescope keybindings
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader><leader>', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>/', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>,', builtin.buffers, { desc = '[ ] Find existing buffers' })
-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set('n', '<leader>sb', function()
  -- You can pass additional configuration to Telescope to change the theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

return {
  'mbbill/undotree',

  -- flash plugin
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  -- neo-tree lazyconfig
  {
    'nvim-neo-tree/neo-tree.nvim',
    cmd = 'Neotree',
    keys = {
      {
        '<leader>fe',
        function()
          require('neo-tree.command').execute { toggle = true, dir = vim.uv.cwd() }
        end,
        desc = 'Explorer NeoTree (Root Dir)',
      },
      {
        '<leader>fE',
        function()
          require('neo-tree.command').execute { toggle = true, dir = vim.uv.cwd() }
        end,
        desc = 'Explorer NeoTree (cwd)',
      },
      { '<leader>E', '<leader>fe', desc = 'Explorer NeoTree (Root Dir)', remap = true },
      { '<leader>e', '<leader>fE', desc = 'Explorer NeoTree (cwd)', remap = true },
      {
        '<leader>ge',
        function()
          require('neo-tree.command').execute { source = 'git_status', toggle = true }
        end,
        desc = 'Git Explorer',
      },
      {
        '<leader>be',
        function()
          require('neo-tree.command').execute { source = 'buffers', toggle = true }
        end,
        desc = 'Buffer Explorer',
      },
    },
    deactivate = function()
      vim.cmd [[Neotree close]]
    end,
    init = function()
      -- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
      -- because `cwd` is not set up properly.
      vim.api.nvim_create_autocmd('BufEnter', {
        group = vim.api.nvim_create_augroup('Neotree_start_directory', { clear = true }),
        desc = 'Start Neo-tree with directory',
        once = true,
        callback = function()
          if package.loaded['neo-tree'] then
            return
          else
            local stats = vim.uv.fs_stat(vim.fn.argv(0))
            if stats and stats.type == 'directory' then
              require 'neo-tree'
            end
          end
        end,
      })
    end,
    opts = {
      sources = { 'filesystem', 'buffers', 'git_status' },
      open_files_do_not_replace_types = { 'terminal', 'Trouble', 'trouble', 'qf', 'Outline' },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = {
        mappings = {
          ['l'] = 'open',
          ['h'] = 'close_node',
          ['<space>'] = 'none',
          ['Y'] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg('+', path, 'c')
            end,
            desc = 'Copy Path to Clipboard',
          },
          ['O'] = {
            function(state)
              require('lazy.util').open(state.tree:get_node().path, { system = true })
            end,
            desc = 'Open with System Application',
          },
          ['P'] = { 'toggle_preview', config = { use_float = false } },
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = '',
          expander_expanded = '',
          expander_highlight = 'NeoTreeExpander',
        },
        git_status = {
          symbols = {
            unstaged = '󰄱',
            staged = '󰱒',
          },
        },
      },
    },
    config = function(_, opts)
      local function on_move(data)
        Snacks.rename.on_rename_file(data.source, data.destination)
      end

      local events = require 'neo-tree.events'
      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
      })
      require('neo-tree').setup(opts)
      vim.api.nvim_create_autocmd('TermClose', {
        pattern = '*lazygit',
        callback = function()
          if package.loaded['neo-tree.sources.git_status'] then
            require('neo-tree.sources.git_status').refresh()
          end
        end,
      })
    end,
  },
}
