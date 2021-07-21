local Ui = require 'neogit.lib.ui'
local Component = require 'neogit.lib.ui.component'
local util = require 'neogit.lib.util'

local col = Ui.col
local row = Ui.row
local text = Ui.text

local map = util.map

local M = {}

-- * commit e0a6cd38f783a6028cf1f18a72fdbb761ad2fd62 (HEAD -> commit-inspection, origin/commit-inspection)
-- | Author:     TimUntersberger <timuntersberger2@gmail.com>
-- | AuthorDate: Sat May 29 19:31:30 2021 +0200
-- | Commit:     TimUntersberger <timuntersberger2@gmail.com>
-- | CommitDate: Sat May 29 19:31:30 2021 +0200
-- |
-- |     feat: improve commit view and ui lib
-- |

M.Commit = Component.new(function(commit)
  months = {
    Jan = 1,
    Feb = 2,
    Mar = 3,
    Apr = 4,
    May = 5,
    Jun = 6,
    Jul = 7,
    Aug = 8,
    Sep = 9,
    Otc = 10,
    Nov = 11,
    Dec = 12,
  }

  str="Sun Jul 18 18:29:40 2021 +0200"
  pattern="%a+ (%a+) (%d+) (%d+):(%d+):(%d+) (%d+) (+%d+)"

  month, day, hour, min, sec, year, tz=str:match(pattern) 

  -- print(os.time({tz=tz,day=day,month=months[month],year=year,hour=hour,min=min,sec=sec}))

  -- s="Sat, 29 Oct 1994 19:43:31 GMT"
  -- p="(%a+), (%d+) (%a+) (%d+) (%d+):(%d+):(%d+) GMT"
  -- week_day,day,month,year,hour,min,sec=s:match(p)

  space_len_1 = vim.api.nvim_eval('winwidth(0)') - string.len(commit.description[1]) -
    string.len(("* "):rep(commit.level + 2)) - 70
  space_len_2 = 20 - string.len(commit.author_name)
    -- print(asterisk_len)
  return col {
    row { 
      text(("* "):rep(commit.level + 1), { highlight = "Character" }),
      text(commit.oid:sub(1, 7), { highlight = "Number" }),
      text " ",
      text(commit.description[1]),
      text((" "):rep(space_len_1)),
      text(commit.author_name, { highlight = "Number" }),
      text((" "):rep(space_len_2)),
      text "---",
      -- text(months["Jan"]),
    },
    col.hidden(true).padding_left((commit.level + 1) * 2) {
      row {
        text "Author:     ",
        text(commit.author_name),
        text " <",
        text(commit.author_date),
        text ">"
      },
      row {
        text "AuthorDate: ",
        text(commit.author_date)
      },
      row {
        text "Commit:     ",
        text(commit.committer_name),
        text " <",
        text(commit.committer_date),
        text ">"
      },
      row {
        text "CommitDate: ",
        text(commit.committer_date)
      },
      text " ",
      col(map(commit.description, text), { padding_left = 4 })
    }
  }
end)

function M.LogView(data)
  return map(data, M.Commit)
end

return M
