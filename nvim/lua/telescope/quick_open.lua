-- quick_open: VSCode Quick Open ライクな統合ピッカー
-- <C-i> で起動。通常入力はファイル検索、先頭 ">" でコマンド検索に切替。
-- ">" は取り除かれ、BS で空にするとファイル検索に復帰する。
-- 絶対パス（/、~/）で実在ファイルを入力すると単一候補を表示し、そのまま開ける。
-- コマンド検索は「最近使った順(履歴) + abc順」で表示（VSCode 互換）。

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

-- ファイル検索の finder（rg 使用、hidden 含む＝既存 find_files({ hidden = true }) 相当）
-- .worktrees/ は .gitignore で除外されていても明示パスとして渡し検索対象に含める
-- （rg は明示指定パス配下の .gitignore 判定を、親ディレクトリ除外から個別ファイル判定に切り替えるため）
local function make_file_finder()
  local cmd = { "rg", "--files", "--color", "never", "--hidden" }
  if vim.fn.isdirectory(".worktrees") == 1 then
    vim.list_extend(cmd, { "--", ".", ".worktrees/" })
  end
  return finders.new_oneshot_job(cmd, {
    entry_maker = make_entry.gen_from_file({}),
  })
end

-- 絶対パス（/、~/）で実在ファイルを入力された場合の展開後パスと単一候補 finder を返す
-- 実在しない場合は nil を返し、呼び出し側は従来どおりの曖昧検索へフォールバックする
-- （fnamemodify(":p") は "~" を展開しグロブ展開しないため、存在確認に安全）
local function make_path_finder(prompt)
  local path = vim.fn.fnamemodify(prompt, ":p")
  -- Note: filereadable のみで判定するためディレクトリは単一候補の対象外（フォルダ一覧ブラウズは削除済み）。ディレクトリ入力も非実在パス同様に曖昧検索へフォールバックする
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end
  return path, finders.new_table({
    results = { path },
    entry_maker = make_entry.gen_from_file({}),
  })
end

-- ===========================================
-- コマンド使用履歴（最近順、永続化）
-- ===========================================

local history = {}
local history_file = vim.fn.stdpath("data") .. "/quick_open_history.json"
local MAX_HISTORY = 30

-- 履歴をファイルから読込
local function load_history()
  local f = io.open(history_file, "r")
  if not f then
    return
  end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  if ok and type(data) == "table" then
    history = data
  end
end

-- 履歴をファイルへ保存
local function save_history()
  local f = io.open(history_file, "w")
  if not f then
    return
  end
  f:write(vim.json.encode(history))
  f:close()
end

-- コマンドを履歴の先頭に記録（重複排除・上限あり）
local function record_command(name)
  for i, n in ipairs(history) do
    if n == name then
      table.remove(history, i)
      break
    end
  end
  table.insert(history, 1, name)
  while #history > MAX_HISTORY do
    table.remove(history)
  end
  save_history()
end

-- モジュール読込時に履歴を読込
load_history()

-- コマンド検索の finder
-- 最近使ったコマンド(履歴順)を先頭に、残りは abc 順で並べる
local function make_command_finder()
  local all = vim.tbl_keys(vim.api.nvim_get_commands({}))
  table.sort(all)
  local remaining = {}
  for _, n in ipairs(all) do
    remaining[n] = true
  end
  -- 履歴のうち現存するコマンドを最近順で先頭に
  local ordered = {}
  for _, n in ipairs(history) do
    if remaining[n] then
      table.insert(ordered, n)
      remaining[n] = nil
    end
  end
  -- 残りは abc 順（all はソート済み）
  for _, n in ipairs(all) do
    if remaining[n] then
      table.insert(ordered, n)
    end
  end
  return finders.new_table({ results = ordered })
end

function M.quick_open(opts)
  opts = opts or {}
  local mode = "file" -- "file" | "path" | "command": 現在のモード（on_input_filter_cb と attach_mappings で共有）

  pickers
    .new(opts, {
      prompt_title = "Quick Open",
      finder = make_file_finder(),
      previewer = conf.file_previewer(opts),
      sorter = conf.generic_sorter(opts),
      on_input_filter_cb = function(prompt)
        -- ">" で始まる -> コマンドモードへ（">" を除去）
        if vim.startswith(prompt, ">") then
          mode = "command"
          return {
            prompt = prompt:sub(2),
            updated_finder = make_command_finder(),
          }
        end
        -- コマンドモード中に空になった -> ファイルモードへ復帰
        if mode == "command" and prompt == "" then
          mode = "file"
          return { updated_finder = make_file_finder() }
        end
        -- 絶対パス（/、~/）で実在ファイルなら単一候補へ切替（非実在は従来どおりの曖昧検索）
        -- Why: 対象を "/" と "~" に限定し相対パス（./、../ 等）を単一候補の対象外にするのは、リサーチにより quick-open の標準がパス断片のファジーマッチのみと判明したため（d84972e で追加したブラウザ型パスモードは標準外として削除）
        if vim.startswith(prompt, "/") or vim.startswith(prompt, "~") then
          local path, finder = make_path_finder(prompt)
          if finder then
            mode = "path"
            -- ソート対象は "~" 展開後のパスに揃える（単一候補の ordinal と一致させる）
            return { prompt = path, updated_finder = finder }
          end
        end
        -- 単一候補モード中に外れた -> ファイルモードへ復帰
        if mode == "path" then
          mode = "file"
          return { updated_finder = make_file_finder() }
        end
      end,
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          if not selection then
            return
          end
          if mode == "command" then
            actions.close(prompt_bufnr)
            record_command(selection.value) -- 履歴に記録してから実行
            vim.cmd(selection.value)
          else
            -- ファイルモード・パスモードのファイル: 通常のファイルオープン（close + edit）
            actions.file_edit(prompt_bufnr)
          end
        end)
        return true
      end,
    })
    :find()
end

return M
