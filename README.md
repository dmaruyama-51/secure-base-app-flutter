# secure-base-app-flutter
心の安全基地を育むアプリ

アプリの設計資料は [こちら](https://www.notion.so/20_secure-base-1c31f8583e6f80cc88f1d676d9c0f7b0?pvs=4)

## アーキテクチャ

このアプリは**MVVM + Repository パターン**と**Riverpod**を組み合わせた、初心者にも理解しやすいアーキテクチャを採用しています。

### 📐 アーキテクチャ全体像

```
┌─────────────────┐
│   View (UI)     │ ← ユーザーが見る画面
└─────────────────┘
         │
         ▼ 状態監視
┌─────────────────┐                ┌─────────────────┐
│   ViewModel     │ ◄─── DI注入 ─── │   Provider      │ ← DI管理
└─────────────────┘                │  (Repository)   │
         │                         └─────────────────┘
         ▼ 状態更新                          │
┌─────────────────┐                        ▼ 生成
│   State         │                ┌─────────────────┐
│   (Freezed)     │                │   Repository    │ ← データアクセス
└─────────────────┘                │   (Supabase)    │
                                   └─────────────────┘
```

**🔗 正しい依存関係：**
- **Provider** → **ViewModel** (Repository を DI注入)
- **ViewModel** → **State** (状態の更新のみ)
- **ViewModel** → **Repository** (データアクセス)  
- **View** → **ViewModel** (状態の監視)

**❌ StateはDI注入を受けません** - 単純なデータクラスです

### 🏗️ 各レイヤーの詳細

#### **1. Provider層（依存性注入）**
- **役割**: オブジェクトの生成・管理・配布
- **場所**: `lib/providers/`
- **特徴**:
  - Repository のインスタンス管理
  - 機能ごとにファイル分割
  - シングルトンパターンの自動実装
  - テスト時のモック差し替えが簡単

```dart
// 例：lib/providers/kindness_record/kindness_record_providers.dart
final kindnessRecordRepositoryProvider = Provider<KindnessRecordRepository>((ref) {
  return KindnessRecordRepository();  // ← 機能特化した工場
});

// 例：lib/providers/kindness_giver/kindness_giver_providers.dart
final kindnessGiverRepositoryProvider = Provider<KindnessGiverRepository>((ref) {
  return KindnessGiverRepository();   // ← 機能特化した工場
});
```

#### **2. State層（状態定義）**
- **役割**: UI状態の型安全な定義
- **場所**: `lib/states/`
- **特徴**:
  - Freezedによる不変オブジェクト
  - copyWithメソッドの自動生成
  - 型安全な状態管理

```dart
// 例：lib/states/kindness_record/kindness_record_add_state.dart
@freezed
class KindnessRecordAddState with _$KindnessRecordAddState {
  const factory KindnessRecordAddState({
    @Default('') String content,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _KindnessRecordAddState;
}
```

#### 1. **View（UI層）**
- **役割**: ユーザーが見る画面・操作する部分
- **場所**: `lib/views/`
- **特徴**: 
  - UIの表示のみに専念
  - ビジネスロジックは書かない
  - ViewModelの状態を監視して画面を更新

```dart
// 例：lib/views/kindness_record/kindness_record_add_page.dart
class KindnessRecordAddPage extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kindnessRecordAddViewModelProvider); // 状態を監視
    final viewModel = ref.read(kindnessRecordAddViewModelProvider.notifier);
    
    return Scaffold(
      body: Column(
        children: [
          TextField(
            onChanged: viewModel.updateContent, // ViewModelに処理を委譲
          ),
          ElevatedButton(
            onPressed: viewModel.saveKindnessRecord,
            child: Text('保存'),
          ),
        ],
      ),
    );
  }
}
```

#### 2. **ViewModel（状態管理・ビジネスロジック層）**
- **役割**: 状態管理・バリデーション・ビジネスロジック
- **場所**: `lib/view_models/`
- **特徴**: 
  - UIから独立したビジネスロジック
  - 状態の変更を自動でUIに通知
  - DI により Repository を外部から注入
  - テストしやすい構造

```dart
// 例：lib/view_models/kindness_record/kindness_record_add_view_model.dart
import '../../states/kindness_record/kindness_record_add_state.dart';
import '../../providers/repository_providers.dart';

class KindnessRecordAddViewModel extends StateNotifier<KindnessRecordAddState> {
  final KindnessRecordRepository _repository;

  // DIパターン：コンストラクタで Repository を受け取る
  KindnessRecordAddViewModel({
    required KindnessRecordRepository repository,
  }) : _repository = repository,
       super(const KindnessRecordAddState());

  // 内容更新（状態変更が自動でUIに通知される）
  void updateContent(String content) {
    state = state.copyWith(content: content);
  }

  // 保存処理（ビジネスロジック）
  Future<void> saveKindnessRecord() async {
    if (!_validateInput()) return;
    
    state = state.copyWith(isSaving: true);
    try {
      final result = await _repository.saveKindnessRecord(/* データ */);
      state = state.copyWith(
        isSaving: false,
        successMessage: '保存しました',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'エラーが発生しました',
      );
    }
  }
}

// ViewModelのProvider（DIで依存関係を注入）
final kindnessRecordAddViewModelProvider = 
    StateNotifierProvider<KindnessRecordAddViewModel, KindnessRecordAddState>(
  (ref) {
    // Repository Providerから依存関係を取得
    final repository = ref.read(kindnessRecordRepositoryProvider);
    
    return KindnessRecordAddViewModel(repository: repository);  // ← DI！
  },
);
```

#### 3. **Repository（データアクセス層）**
- **役割**: データの取得・保存・更新
- **場所**: `lib/repositories/`
- **特徴**: 
  - Supabaseへのクエリ発行
  - データソースの変更に強い
  - ビジネスロジックから分離

```dart
// 例：lib/repositories/kindness_record_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class KindnessRecordRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<KindnessRecord>> fetchKindnessRecords() async {
    // Supabaseからデータ取得
    final response = await _supabase
        .from('kindness_records')
        .select('*')
        .order('created_at', ascending: false);
    
    return response.map((data) => KindnessRecord.fromJson(data)).toList();
  }

  Future<bool> saveKindnessRecord(KindnessRecord record) async {
    try {
      // Supabaseにデータ挿入
      await _supabase.from('kindness_records').insert({
        'user_id': record.userId,
        'giver_id': record.giverId,
        'content': record.content,
        'created_at': record.createdAt.toIso8601String(),
        'updated_at': record.updatedAt.toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error saving kindness record: $e');
      return false;
    }
  }
}
```

### 🔄 状態管理（Riverpod）詳細

#### **なぜ状態管理が必要？**

従来のFlutterでは、データが変わった時に画面を更新するのに手間がかかりました：

```dart
// 従来の方法（StatefulWidget）
class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String content = '';
  
  void updateContent(String newContent) {
    setState(() {  // ← 毎回これを書く必要がある
      content = newContent;
    });
  }
}
```

#### **Riverpodでの状態管理**

Riverpodを使うと、状態の変更が自動でUIに反映されます：

```dart
// 1. 状態クラスを定義（別ファイル）
// lib/states/kindness_record/kindness_record_add_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'kindness_record_add_state.freezed.dart';

@freezed
class KindnessRecordAddState with _$KindnessRecordAddState {
  const factory KindnessRecordAddState({
    @Default('') String content,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _KindnessRecordAddState;
}

// 2. Repository Providerを定義（別ファイル）
// lib/providers/repository_providers.dart
final kindnessRecordRepositoryProvider = Provider<KindnessRecordRepository>((ref) {
  return KindnessRecordRepository();  // ← オブジェクト工場
});

// 3. ViewModelで状態を管理（別ファイル + DI）
// lib/view_models/kindness_record/kindness_record_add_view_model.dart
class KindnessRecordAddViewModel extends StateNotifier<KindnessRecordAddState> {
  final KindnessRecordRepository _repository;

  KindnessRecordAddViewModel({
    required KindnessRecordRepository repository,  // ← DI注入
  }) : _repository = repository,
       super(const KindnessRecordAddState());
  
  void updateContent(String content) {
    state = state.copyWith(content: content); // ← これだけで自動更新！
  }
}

// 4. ViewModel Providerを定義（DI実行）
final kindnessRecordAddViewModelProvider = 
    StateNotifierProvider<KindnessRecordAddViewModel, KindnessRecordAddState>(
  (ref) {
    final repository = ref.read(kindnessRecordRepositoryProvider);  // ← DI取得
    return KindnessRecordAddViewModel(repository: repository);      // ← DI注入
  },
);

// 5. UIで状態を監視
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kindnessRecordAddViewModelProvider); // 状態を監視
    
    return Text(state.content); // 状態が変わると自動で画面更新
  }
}
```

#### **状態管理の流れ**

1. **Provider がRepository を生成**: `kindnessRecordRepositoryProvider`
2. **Provider がViewModel を作成**: Repository を DI注入
3. **ViewModel が State を更新**: `state = state.copyWith(...)`
4. **自動通知**: Riverpodが変更を検知
5. **View が状態監視**: `ref.watch(viewModelProvider)`
6. **UI更新**: 状態変更時に自動で画面更新

#### **🔗 実際の依存関係**

```
Provider → ViewModel → Repository （データアクセス）
     ↓        ↓
  DI注入    State （状態管理）
             ↑
           View （状態監視）
```

**重要：** 依存関係の正しい方向
- **Provider**: ViewModel を作成し、Repository を注入
- **ViewModel**: State を更新し、Repository にアクセス
- **State**: 単純なデータクラス（依存関係なし）
- **View**: ViewModel の状態を監視

#### **DIパターンのメリット**

- ✅ **`setState()`不要** - より少ないコード
- ✅ **自動更新** - 状態が変わると画面が自動で更新
- ✅ **型安全** - コンパイル時にエラーを検知
- ✅ **テストしやすい** - UIとロジックが分離、モック注入可能
- ✅ **再利用しやすい** - 複数の画面で同じ状態を共有可能
- ✅ **保守しやすい** - 依存関係が明確で変更に強い

### 📁 フォルダ構成

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

### 🎯 設計の特徴

1. **6層アーキテクチャ**: View → ViewModel → Provider → Repository + State + Model
2. **責任分離**: 各レイヤーが明確な役割を持つ
3. **依存性注入**: Providerによる型安全なDI
4. **自動化**: 状態変更の通知を自動化
5. **拡張性**: 新機能追加時も同じパターンで開発可能
6. **テスト容易**: DI により各レイヤーを独立してテスト可能

### 💡 DIパターンの具体的なメリット

#### **テストしやすさ**
```dart
// テスト時にモックRepositoryを注入可能
test('保存処理のテスト', () {
  final mockRepository = MockKindnessRecordRepository();
  final viewModel = KindnessRecordAddViewModel(
    repository: mockRepository,  // ← モックを注入
  );
  
  // テスト実行...
});
```

#### **設定の柔軟性**
```dart
// 本番環境とテスト環境で異なるRepositoryを使える
final repositoryProvider = Provider<KindnessRecordRepository>((ref) {
  if (kDebugMode) {
    return MockKindnessRecordRepository();  // テスト用
  } else {
    return KindnessRecordRepository();      // 本番用
  }
});
```

#### **依存関係の明確化**
```dart
// どのRepositoryが必要かが明確
KindnessRecordAddViewModel({
  required KindnessRecordRepository repository,  // ← 必要な依存関係が明確
})
```

### 🔧 使用技術

- **Flutter**: UIフレームワーク
- **Riverpod**: 状態管理ライブラリ
- **StateNotifier**: Riverpodの状態管理クラス
- **Freezed**: 不変オブジェクトとcopyWithメソッドの自動生成
- **Provider**: 依存性注入（DI）パターンの実装

### 📚 参考文献・設計パターンの出典

このアーキテクチャは、Flutterコミュニティの確立されたベストプラクティスを組み合わせて構築されています：

#### **公式ドキュメント**
- [Flutter App Architecture Guide](https://docs.flutter.dev/app-architecture/guide) - Flutter公式アーキテクチャガイド
- [Flutter Architecture Recommendations](https://docs.flutter.dev/app-architecture/recommendations) - Flutter公式推奨事項
- [Compass App Sample](https://github.com/flutter/samples/tree/main/compass_app) - Flutter公式サンプルアプリ

#### **コミュニティエキスパート**
- [Code with Andrea - Riverpod Architecture](https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/) - Andrea Bizzotto による4層アーキテクチャ
- [Flutter MVVM with Riverpod](https://augustinevickky.medium.com/flutter-mvvm-architecture-with-riverpod-ce9ec1342413) - Augustine Victor によるプロダクション実装例
- [Very Good Engineering](https://verygood.ventures/blog) - Very Good Ventures によるアーキテクチャガイド

#### **主要パッケージ**
- [Riverpod 公式ドキュメント](https://riverpod.dev/) - 状態管理・DI
- [Freezed 公式ドキュメント](https://pub.dev/packages/freezed) - 不変オブジェクト生成

**このパターンは「集合知」から生まれた確立されたベストプラクティスです！** 🚀

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

### **アーキテクチャ概要**

このアプリは **MVVM + Repository パターン** で構築されており、Riverpodによる状態管理を採用しています。

**📂 責任分離の原則**
- **View**: UIの表示のみ
- **ViewModel**: 状態管理・ビジネスロジック
- **State**: 状態の定義（Freezedで不変オブジェクト化）
- **Repository**: データ取得・永続化
- **Model**: データ構造の定義
- **Provider**: 依存性注入（DI）による疎結合な設計

**🔧 依存性注入（DI）パターン**
- Providerを使った型安全な依存関係管理
- テスト時のモック注入が容易
- Repository の生成・管理を外部化
- 設定変更に強い柔軟な構成

この構成により、**テストしやすく、保守しやすく、拡張しやすい**コードが実現されています。