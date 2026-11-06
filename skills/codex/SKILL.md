---
name: codex
description: Delegate to Codex CLI (ChatGPT login); Claude orchestrates. Use for 画像生成/ロゴ/スプライト, blind second-opinion code review, or "Codexで".
---
# Codex bridge (Claude = main, Codex = worker)
**Codex 自身が読んでいる場合**: 下のコマンドは呼ばない（入れ子になる）。画像は内蔵ツール、レビューは自分で行う。

| 用途 | コマンド | 出力 |
|---|---|---|
| 画像生成 | `codex-image "<英語。縦横比・背景・用途も>" out.png` | 保存先の絶対パス |
| 盲検レビュー | `codex-review [-C dir] [--base <ref>] ["重点"]` | 指摘 + `VERDICT: ship/needs-attention` |
| タスク委譲 | `codex-run [-C <dir>] "<自己完結した指示>"` | Codex の最終メッセージ |

**盲検セカンドオピニオン**: ①自分の見解を先に書く（Codex に渡さない）→ ②`codex-review` を run_in_background →
③突き合わせ: 両方指摘=確度高→直す／Codex のみ=コードで再現して真偽判定／
自分のみ=見落としやすい点として残す → ④採否と理由を1表で報告。

1. Claude が分解・指示・検証。Codex の指示は自己完結。変更は `git diff` で確認、コミット/PR は Claude が行う。
2. 画像は生成後に Read で確認し、ずれたらプロンプトを直して再生成。SendUserFile で渡す。
3. 認証は ChatGPT ログイン（API キー不使用）。未ログインなら `codex login --device-auth` をバックグラウンド起動し、
   URL とコードを日本語で伝える（初回は ChatGPT 設定→セキュリティ→デバイスコードサインインを有効化）。
4. 各スクリプトは timeout・stdin 遮断（`</dev/null`）・生成画像の回収込み。自作で `codex exec` を呼ぶときも `</dev/null` を付ける（無いと入力待ちで止まる）。
5. 公式プラグイン openai/codex-plugin-cc（`/codex:review` 等）が入っていれば通常レビューはそちらでも可。
