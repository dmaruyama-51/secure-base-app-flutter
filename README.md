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

アプリケーションのアーキテクチャの詳細については、[アーキテクチャドキュメント](docs/architecture.md)を参照。


## ディレクトリ構成

```
lib/
├── models/                 # データモデル（Entity層）
│   ├── kindness_record.dart
│   └── kindness_giver.dart
├── repositories/           # データ取得・永続化（Repository層）
│   ├── kindness_record_repository.dart
│   └── kindness_giver_repository.dart
├── providers/              # 依存性注入（DI層）
│   ├── kindness_record/
│   │   └── kindness_record_providers.dart
│   └── kindness_giver/
│       └── kindness_giver_providers.dart
├── states/                 # 状態クラス（State層）
│   └── kindness_record/
│       └── kindness_record_add_state.dart
├── view_models/           # 状態管理・ビジネスロジック（ViewModel層）
│   └── kindness_record/
│       └── kindness_record_add_view_model.dart
└── views/                 # UI（View層）
    └── kindness_record/
        └── kindness_record_add_page.dart
```