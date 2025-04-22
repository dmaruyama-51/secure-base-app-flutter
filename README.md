# secure-base-app-flutter
心の安全基地を育むアプリ

## チーム開発ルール

### 1. ブランチ戦略
- `main`
  - 常にデプロイ可能な安定版のみを置く
- `develop`
  - 次リリース向けの統合ブランチ。すべての `feature/...` や `fix/...` はまずここへマージ
- `feature/#<issue番号>`
  - 新機能開発用。作業完了後、`develop` へPRを作成
- `fix/<チケット番号>-<バグ概要>`
  - バグ修正用。作業完了後、`develop` へPRを作成

### 2. Issue管理
- 新機能・バグは必ずIssueを切る
- 状態（Backlog -> In progress -> In review -> Done）は常に最新状態にしておく
- 担当機能のIssue内でサブIssueを切って開発を進める
