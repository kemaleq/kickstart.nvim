return {
  'FabijanZulj/blame.nvim',
  config = function()
    require('blame').setup {
      virtual_style = 'float',
    }
  end,
  keys = {
    { '<leader>gb', '<cmd>BlameToggle virtual<CR>', desc = 'Git blame' },
    { '<leader>gB', '<cmd>BlameToggle window<CR>', desc = 'Git blame (window)' },
  }
}
