-- 翻訳コア: Google翻訳(非公式エンドポイント)をcurlで呼び出す
-- NOTE: 非公式エンドポイントのため仕様変更リスクあり。翻訳失敗時は原文をそのまま返す

local config = require("lsp_translator.config")

local M = {}

-- 翻訳結果キャッシュ(原文 -> 訳文)
-- NOTE: 翻訳失敗時も原文をキャッシュに入れ、失敗リクエストの再試ループを防ぐ
--- @type table<string, string>
local cache = {}

-- リクエスト進行中の原文と、その完了を待つコールバック群
--- @type table<string, fun(translated: string)[]>
local in_flight = {}

-- 1リクエストあたりの原文の最大バイト数
-- Why: GET URLの長さ制限回避。URLエンコードで最大9倍に膨張するため余裕を持った値
local MAX_CHUNK = 1000

--- キャッシュ済み訳文を取得する
--- @param text string 原文
--- @return string|nil 訳文(未キャッシュならnil)
function M.peek(text)
  return cache[text]
end

--- テキストを行境界でチャンク分割する
--- @param text string 分割対象テキスト
--- @return string[] チャンク配列(常に1要素以上)
local function chunk_text(text)
  if #text <= MAX_CHUNK then
    return { text }
  end
  local chunks, cur, cur_len = {}, {}, 0
  for line in vim.gsplit(text, "\n", { plain = true }) do
    local len = #line + 1
    if cur_len > 0 and cur_len + len > MAX_CHUNK then
      chunks[#chunks + 1] = table.concat(cur, "\n")
      cur, cur_len = {}, 0
    end
    cur[#cur + 1] = line
    cur_len = cur_len + len
  end
  if #cur > 0 then
    chunks[#chunks + 1] = table.concat(cur, "\n")
  end
  -- NOTE: 1行がMAX_CHUNK超の場合は分割せずそのまま送る(失敗時は原文で代替)
  return chunks
end

--- 非同期関数を各要素へ並列実行し、結果を順序保持で結合する
--- @param items any[] 入力要素
--- @param fn fun(item: any, callback: fun(result: any)) 要素ごとの非同期関数
--- @param done fun(results: any[]) 全完了時のコールバック
--- @return nil
local function pmap(items, fn, done)
  local results = {}
  local remaining = #items
  for i, item in ipairs(items) do
    fn(item, function(result)
      results[i] = result
      remaining = remaining - 1
      if remaining == 0 then
        done(results)
      end
    end)
  end
end

--- 単一チャンクをAPIへ送信する
--- @param text string チャンクテキスト
--- @param callback fun(translated: string) 完了時(失敗時は原文)
--- @return nil
local function request_chunk(text, callback)
  -- Why: translate_a/single(client=gtx)は当環境ではブロックページを返すため、
  -- 動作するdict-chrome-exエンドポイントを使用する。
  -- レスポンス形式: [["訳文","検出言語"]](qパラメータ1つにつき1要素。常に1つだけ送る)
  local url = ("https://clients5.google.com/translate_a/t?client=dict-chrome-ex&sl=%s&tl=%s"):format(
    config.values.source,
    config.values.target
  )
  vim.system({
    "curl",
    "-s",
    -- Why: タイムアウトなしだと接続ハング時にコールバックが一生呼ばれず、
    -- in_flightのエントリが永久に残るため
    "--max-time",
    "10",
    "-A",
    "Mozilla/5.0",
    "-G",
    url,
    "--data-urlencode",
    "q=" .. text,
  }, { text = true }, function(obj)
    local translated = text
    pcall(function()
      local decoded = vim.json.decode(obj.stdout or "")
      local first = decoded and decoded[1]
      -- 対応する形式:
      --   [["訳文","en"]]             単一テキスト(通常はこれ)
      --   [[["訳文1"],["訳文2"]],"en"] セグメント分割テキスト
      -- 2要素目は検出言語であり訳文の一部ではない
      local parts = {}
      if type(first) == "table" then
        if type(first[1]) == "string" then
          parts[1] = first[1]
        else
          for _, seg in ipairs(first) do
            if type(seg) == "table" and type(seg[1]) == "string" then
              parts[#parts + 1] = seg[1]
            end
          end
        end
      end
      -- 空文字列なら翻訳失敗とみなし原文を維持する
      local joined = table.concat(parts)
      if joined ~= "" then
        translated = joined
      end
    end)
    vim.schedule(function()
      callback(translated)
    end)
  end)
end

--- 単一テキストを翻訳する(キャッシュ・リクエスト重複排除つき)
--- @param text string 翻訳対象テキスト
--- @param callback fun(translated: string) 翻訳完了時(失敗時は原文)
--- @return nil
function M.translate(text, callback)
  local hit = cache[text]
  if hit then
    callback(hit)
    return
  end

  -- 同一テキストのリクエストが進行中なら、その完了を待つ
  local flight = in_flight[text]
  if flight then
    flight[#flight + 1] = callback
    return
  end
  in_flight[text] = { callback }

  -- チャンクを並列翻訳し、全完了時に結合する。
  -- Why: "\n"で結合するのは、チャンク分割は行境界でしか行われないため、
  -- チャンクk末尾行とチャンクk+1先頭行の間の改行をここで復元する必要がある
  pmap(chunk_text(text), request_chunk, function(results)
    local joined = table.concat(results, "\n")
    cache[text] = joined
    local waiters = in_flight[text]
    in_flight[text] = nil
    for _, cb in ipairs(waiters) do
      cb(joined)
    end
  end)
end

--- 複数テキストを一括翻訳する
--- @param texts string[] 翻訳対象テキスト配列
--- @param callback fun(results: string[]) 全完了時(順序保持。失敗分は原文)
--- @return nil
function M.translate_all(texts, callback)
  if #texts == 0 then
    callback({})
    return
  end
  pmap(texts, M.translate, callback)
end

return M
