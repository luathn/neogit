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


  space_len_1 = vim.api.nvim_eval('winwidth(0)') - string.len(commit.description[1]) -
    string.len(("* "):rep(2)) - 40
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
      -- text(tostring(month))
      -- text(tostring(day_offset), { highlight = "Character" }),
      -- text(" days ago", { highlight = "Character" }),
      text(genDate(commit), { highlight = "Character" }),
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

function genDate(commit)
  months = { Jan = 1, Feb = 2, Mar = 3, Apr = 4, May = 5, Jun = 6, Jul = 7, Aug = 8, Sep = 9, Oct = 10, Nov = 11, Dec = 12 }
  pattern="%a+ (%a+) (%d+) (%d+):(%d+):(%d+) (%d+) ([+-]%d+)"
  month, day, hour, min, sec, year, tz=commit.committer_date:match(pattern) 

  commit_datetime = os.time({tz=tz,day=day,month=months[month],year=year,hour=hour,min=min,sec=sec})
  day_offset = os.time() - commit_datetime

  number = 0
  unit = ""
  if day_offset >= 0 and day_offset < 60 then
    number = day_offset
    unit = "seconds"
  elseif day_offset > 60 and day_offset < 3600 then
    number = math.floor(day_offset/60)
    unit = "minutes"
  elseif day_offset >= 3600 and day_offset < 86400 then
    number = math.floor(day_offset/3600)
    unit = "hours"
  elseif day_offset >= 86400 and day_offset < 2592000 then
    number = math.floor(day_offset/86400)
    unit = "days"
  elseif day_offset >= 2592000 and day_offset < 31104000 then
    number = math.floor(day_offset/2592000)
    unit = "months"
  elseif day_offset >= 31104000 then
    number = math.floor(day_offset/31104000)
    unit = "years"
  end
  return tostring(number) .. " " .. unit .. " ago"
end

return M
