-- 診断とhoverドキュメントを統合した翻訳済みフロート。
-- Why: 行末のvirtual_textはwrap不可能で長い診断が見切れるため、
-- 診断全文をヘッダとして併載し、続けてhoverドキュメントを表示する(VSCodeのホバー相当)

local config = require("lsp_translator.config")
local translate = require("lsp_translator.translate")
local float = require("lsp_translator.float")

local M = {}

-- severityごとのハイライトグループ(標準の診断グループ)
local hl_groups = {
  [vim.diagnostic.severity.ERROR] = "DiagnosticError",
  [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
  [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
  [vim.diagnostic.severity.HINT] = "DiagnosticHint",
}

local ns_hover_diag = vim.api.nvim_create_namespace("lsp_translator_hover")

--- 診断+hoverドキュメントの翻訳済みフロートを表示する
--- @return nil
function M.show()
  -- Why: 0.11以降はencoding指定が必須(未指定だと警告が出る)。
  -- バッファの先頭クライアントに合わせる
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local encoding = (clients[1] and clients[1].offset_encoding) or "utf-16"
  local params = vim.lsp.util.make_position_params(0, encoding)
  local diags = vim.diagnostic.get(0, { lnum = params.position.line })
  local orig_msgs = vim.tbl_map(function(d)
    return d.message
  end, diags)
  local close_placeholder = float.open_placeholder()

  -- 翻訳済みテキスト。対応する翻訳が進行中の間はnilで、render()は
  -- 未確定部分を原文で代替して描画する
  --- @type string[]|nil
  local tr_diags = nil
  --- @type string[]|nil
  local tr_body = nil
  -- hoverドキュメントの原文行(LSP応答時に確定する)
  --- @type string[]|nil
  local raw_body = nil
  -- 最後に描画したフロートのウィンドウ(更新時に閉じ開きするため)
  local cur_win = nil

  --- 現在の状態で最善の内容でフロートを描画する
  --- @return nil
  local function render()
    if raw_body == nil then
      return
    end
    local icons = config.values.icons
    local msgs = tr_diags or orig_msgs
    local header, hl_rows = {}, {}
    for i, d in ipairs(diags) do
      local icon = icons[d.severity] or icons[vim.diagnostic.severity.HINT]
      local hl = hl_groups[d.severity] or hl_groups[vim.diagnostic.severity.HINT]
      for _, line in ipairs(vim.split(msgs[i], "\n", { plain = true })) do
        -- Why: append前の#headerを添字にすると、直後に1-basedで追加する行の
        -- 0-basedフロート行番号と一致する(extmarkのrowは0-based・end-exclusive。
        -- :h api-indexing)
        hl_rows[#header] = hl
        header[#header + 1] = icon .. " " .. line
      end
    end
    local body_lines = tr_body or raw_body
    local lines = {}
    vim.list_extend(lines, header)
    if #header > 0 and #body_lines > 0 then
      lines[#lines + 1] = "---"
    end
    vim.list_extend(lines, body_lines)
    -- TODO: 診断の訳文に改行2つ以上が連続する場合、open_floating_preview内の
    -- markdown正規化で行が詰められ、以降のハイライト行が1行ずれることが
    -- ある(実用上は稀)
    close_placeholder()
    if cur_win and vim.api.nvim_win_is_valid(cur_win) then
      vim.api.nvim_win_close(cur_win, true)
    end
    local fbuf, fwin = float.open_result(lines, "markdown")
    cur_win = fwin
    -- フロート内の診断行へseverity色を付与
    for row, hl in pairs(hl_rows) do
      vim.api.nvim_buf_set_extmark(fbuf, ns_hover_diag, row, 0, {
        end_line = row + 1,
        end_col = 0,
        hl_group = hl,
      })
    end
  end

  -- Why: 診断メッセージは既に手元にあるため、LSP hover要求と並列で翻訳する。
  -- ドキュメントの翻訳のみLSP応答を待つ必要がある
  if #orig_msgs > 0 then
    translate.translate_all(orig_msgs, function(tr)
      tr_diags = tr
      render()
    end)
  else
    tr_diags = {}
  end

  vim.lsp.buf_request_all(0, "textDocument/hover", params, function(results, ctx)
    -- Why: 翻訳によりLSP往復の上にネットワーク遅延が乗るため、結果到着時に
    -- バッファが変わっていることがある(built-in hoverと同じガード)
    if vim.api.nvim_get_current_buf() ~= ctx.bufnr then
      close_placeholder()
      return
    end
    local body = {}
    for _, resp in pairs(results or {}) do
      if resp.result then
        vim.list_extend(body, vim.lsp.util.convert_input_to_markdown_lines(resp.result.contents))
      end
    end
    if #diags == 0 and #body == 0 then
      close_placeholder()
      -- Note: 文言とINFOレベルはbuilt-in hoverと同一($VIMRUNTIME/lua/vim/lsp/buf.lua、0.11)
      vim.notify("No information available", vim.log.levels.INFO)
      return
    end
    raw_body = body
    if #body > 0 then
      local body_text = table.concat(body, "\n")
      -- Why: 翻訳の進行中も原文で即座にフロートを見せ続ける。
      -- 翻訳済みの場合は下書きを挟むと無意味な開き直しとなるため描画しない
      if not translate.peek(body_text) then
        render()
      end
      translate.translate(body_text, function(tr)
        tr_body = vim.split(tr, "\n", { plain = true })
        render()
      end)
    else
      tr_body = {}
      render()
    end
  end)
end

return M
