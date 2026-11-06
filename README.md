# claude-codex-kit

Claude Code を司令塔に、Codex CLI（ChatGPT ログイン）を画像生成・盲検クロスレビュー・作業委譲に使う個人用キット。
ローカル（macOS / Linux）と Claude Code のクラウド環境で同じ構成を1コマンドで再現する。

## 中身
| パス | 役割 | 入る場所 |
|---|---|---|
| `home/CLAUDE.md` | Claude / Codex 共通ルール | `~/.claude/CLAUDE.md` と `~/.codex/AGENTS.md`（同じファイルへのリンク） |
| `skills/codex/` | `codex` スキル（SKILL.md + スクリプト） | `~/.claude/skills/codex`（Claude）・`~/.agents/skills/codex`（Codex） |
| `skills/codex/scripts/` | `codex-image` / `codex-review` / `codex-run` | `~/.local/bin`（ローカル）・`/usr/local/bin`（クラウド） |
| `cloud/setup-script.sh` | クラウド環境のセットアップスクリプト | 環境設定に貼る |

| コマンド | 内容 |
|---|---|
| `codex-image "<英語プロンプト>" out.png` | Codex 内蔵の画像生成。保存先の絶対パスを出力 |
| `codex-review [--base main] ["重点"]` | 読み取り専用の敵対的レビュー。**自分の見解を先に書き、Codex には渡さない**（盲検） |
| `codex-run [-C dir] "<指示>"` | 自己完結したタスクを Codex に委譲 |

考える深さ（reasoning effort）の既定: `codex-image`=low、`codex-run`=medium、`codex-review`=Codex の設定どおり。
`CODEX_IMAGE_EFFORT` / `CODEX_RUN_EFFORT` / `CODEX_REVIEW_EFFORT` で上書き可（low / medium / high / xhigh）。

## ローカル（macOS）
```bash
git clone https://github.com/fireheat135/claude-codex-kit ~/claude-codex-kit
~/claude-codex-kit/install.sh --with-agmsg
```
- 既存の `~/.claude/CLAUDE.md` などは `~/.claude-codex-kit-backup/<日時>/` に退避される（削除はしない）。Codex の `config.toml` には触れない。
- `~/.local/bin` が PATH に無ければ表示に従って追加。初回は `codex login`。
- 更新は `cd ~/claude-codex-kit && git pull`（リンクなので再インストール不要。新しいファイルが増えたときだけ `./install.sh` を再実行）。
- `--with-agmsg`: [agmsg](https://github.com/fujibee/agmsg) を入れる。Claude Code で `/agmsg`、Codex で `$agmsg` を実行し同じチームに参加すると、開いたままの両セッションが相互にレビュー依頼できる。

## クラウド（Claude Code on the web）
環境設定 → Edit → Setup script に `cloud/setup-script.sh` の中身を貼る。ネットワークは Limited のまま、許可ホストに `chatgpt.com` と `auth.openai.com` を追加。
Codex のログイン情報はコンテナと共に消えるので、各セッションで `codex login --device-auth`（ChatGPT 設定 → セキュリティで「デバイスコードサインイン」を有効化しておく）。

## 新しいゲームプロジェクト
[fireheat135/Game-Lab](https://github.com/fireheat135/Game-Lab) を GitHub の Template repository にして「Use this template」。
CLAUDE.md（= AGENTS.md）・`.agents/skills`（feature-workflow / game-feel / input-systems / performance-optimization）・CI・Pages 公開が揃った状態で始まる。

## 動作環境
bash（macOS 標準の 3.2 で可）・Node.js（Codex CLI 用）・perl（timeout が無い macOS での時間制限用、標準搭載）。
