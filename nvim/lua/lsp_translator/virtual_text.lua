-- vim.diagnosticのvirtual_text handlerをwrapし、訳文を表示する。
-- Why: 診断データ本体(vim.diagnostic.get()、quickfix等)は原文を保持し、
-- 表示時のみ差し替えるためにこの方式をとる

local translate = require("lsp_translator.translate")

local M = {}

--- virtual_text handlerのwrapを適用する
--- @return nil
function M.wrap()
  local orig = vim.diagnostic.handlers.virtual_text

  -- Note: __index = origにより、先に他プラグインがhandlerテーブルへ
  -- 追加した拡張フィールドを破壊しない
  vim.diagnostic.handlers.virtual_text = setmetatable({
    show = function(ns, bufnr, diagnostics, opts)
      local replaced = {}
      local uncached = {}
      for i, diag in ipairs(diagnostics) do
        local translated = translate.peek(diag.message)
        if translated and translated ~= diag.message then
          replaced[i] = vim.tbl_extend("force", diag, { message = translated })
        else
          replaced[i] = diag
          if not translated then
            uncached[#uncached + 1] = diag.message
          end
        end
      end
      orig.show(ns, bufnr, replaced, opts)

      -- 未キャッシュのメッセージを翻訳し、訳出できていれば再表示する。
      -- 再表示はこのwrapを再度通るが、その時点でキャッシュ済みのため
      -- 追加のリクエストは発生しない
      if #uncached > 0 then
        translate.translate_all(uncached, function(tr)
          -- Why: 訳出できた場合のみ再表示する。失敗(原文返却)時の
          -- 再描画は無駄なため
          for i, msg in ipairs(uncached) do
            if tr[i] ~= msg then
              vim.schedule(function()
                vim.diagnostic.show(ns, bufnr)
              end)
              return
            end
          end
        end)
      end
    end,
    hide = function(ns, bufnr)
      return orig.hide(ns, bufnr)
    end,
  }, { __index = orig })
end

return M
