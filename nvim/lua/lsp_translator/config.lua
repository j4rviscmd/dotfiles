-- 設定管理

local M = {}

--- @class LspTranslatorOpts
--- @field source string Google翻訳のslパラメータ("auto"で自動検出)
--- @field target string Google翻訳のtlパラメータ
--- @field icons table<string, string> severityキー("error"|"warn"|"info"|"hint")に対するアイコン

--- @type LspTranslatorOpts
M.defaults = {
  source = "auto",
  target = "ja",
  icons = {
    error = "✖",
    warn = "▲",
    info = "■",
    hint = "■",
  },
}

--- @type LspTranslatorOpts
M.values = vim.deepcopy(M.defaults)

--- ユーザー指定のオプションを正規化して保存する
--- @param opts table|nil ユーザーオプション
--- @return nil
function M.setup(opts)
  local merged = vim.tbl_deep_extend("force", M.defaults, opts or {})
  -- 文字列のseverityキーを数値へ変換し診断から直接引けるようにする
  local icons = {}
  for key, icon in pairs(merged.icons or {}) do
    local severity = vim.diagnostic.severity[key:upper()]
    if severity then
      icons[severity] = icon
    end
  end
  merged.icons = icons
  M.values = merged
end

return M
