# secure-base-app-flutter
心の安全基地を育むアプリ

アプリの設計資料は [こちら](https://www.notion.so/20_secure-base-1c31f8583e6f80cc88f1d676d9c0f7b0?pvs=4)

## チーム開発ルール

### 1. ブランチ戦略
- `main`
  - 常にデプロイ可能な安定版のみを置く
- `develop`
  - 次リリース向けの統合ブランチ。すべての `feature/...` や `fix/...` はまずここへマージ
- `feature/#<issue番号>`
  - 新機能開発用。作業完了後、`develop` へPRを作成
- `fix/#<issue番号>`
  - バグ修正用。作業完了後、`develop` へPRを作成

### 2. Issue管理
- 新機能・バグは必ずIssueを切る
- 状態（Backlog -> In progress -> In review -> Done）は常に最新状態にしておく
- 担当機能のIssue内でサブIssueを切って開発を進める


## アーキテクチャ 

アプリケーションのアーキテクチャは MVVM パターンを採用します。

| レイヤー | ディレクトリ | 責務 |
|---------|------------|------|
| Model | `models/` | データモデルの定義とビジネスロジック |
| View | `views/` | UIの表示とユーザーインタラクションの処理 |
| ViewModel | `view_models/` | ViewとModelの橋渡し, 状態管理 |

※ 注意事項: Repository（`repositories/`）は可読性向上のためにデータアクセスの箇所を Model から分離しているだけで、DIは行いません。
