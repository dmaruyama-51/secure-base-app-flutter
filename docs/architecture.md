## アーキテクチャ

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
- **View** → **ViewModel** (状態の監視)
- **ViewModel** → **Provider** (DI注入のため)
- **Provider** → **Repository** (インスタンス管理)
- **ViewModel** → **State** (状態の管理・更新)

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
  return KindnessRecordRepository();
});

// 例：lib/providers/kindness_giver/kindness_giver_providers.dart
final kindnessGiverRepositoryProvider = Provider<KindnessGiverRepository>((ref) {
  return KindnessGiverRepository();
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

#### **❄️ Freezedによる状態クラス生成**

**Freezedとは？**
- Dartのコード生成ライブラリ
- **不変オブジェクト**と**copyWithメソッド**を自動生成
- 型安全で効率的な状態管理を実現

**🔧 設定手順**

1. **依存関係追加** (`pubspec.yaml`)
```yaml
dependencies:
  freezed_annotation: ^2.4.1

dev_dependencies:
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serialization: ^1.0.0
```

2. **状態クラス作成** (例：`kindness_record_add_state.dart`)
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/kindness_giver.dart';

part 'kindness_record_add_state.freezed.dart';  // ← 自動生成ファイル

@freezed
class KindnessRecordAddState with _$KindnessRecordAddState {
  const factory KindnessRecordAddState({
    @Default([]) List<KindnessGiver> kindnessGivers,
    @Default('') String content,
    KindnessGiver? selectedKindnessGiver,
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    String? errorMessage,
    String? successMessage,
    @Default(false) bool shouldNavigateBack,
  }) = _KindnessRecordAddState;
}
```

3. **自動生成コマンド実行**
```bash
# 初回または大きな変更時
dart run build_runner build --delete-conflicting-outputs

# 開発中の継続的な生成
dart run build_runner watch
```

**📁 生成されるファイル**
- `kindness_record_add_state.freezed.dart` ← 自動生成（編集禁止）
- 以下のメソッドが自動生成される：
  - `copyWith()` - 部分更新
  - `toString()` - デバッグ表示
  - `==` と `hashCode` - 等価比較
  - その他多数のヘルパーメソッド

**✨ Freezedのメリット**

```dart
// ❌ 手動で書く場合（大変！）
class MyState {
  final String content;
  final bool isLoading;
  
  MyState({required this.content, required this.isLoading});
  
  // copyWithを手動実装（面倒&エラーが起きやすい）
  MyState copyWith({String? content, bool? isLoading}) {
    return MyState(
      content: content ?? this.content,
      isLoading: isLoading ?? this.isLoading,
    );
  }
  
  // toString, ==, hashCodeも手動実装...
}

// ✅ Freezedで自動生成（楽！）
@freezed
class MyState with _$MyState {
  const factory MyState({
    @Default('') String content,
    @Default(false) bool isLoading,
  }) = _MyState;
}
// ↑ これだけでcopyWith等が全て自動生成！
```

#### **Riverpodでの状態管理**

Riverpodを使うと、状態の変更が自動でUIに反映されます：

```dart
// 1. 状態クラスを定義（別ファイル + Freezed自動生成）
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

// 2. ViewModelで状態を管理（別ファイル + DI）
class KindnessRecordAddViewModel extends StateNotifier<KindnessRecordAddState> {
  KindnessRecordAddViewModel() : super(const KindnessRecordAddState());
  
  void updateContent(String content) {
    state = state.copyWith(content: content); // ← Freezed自動生成のcopyWith！
  }
  
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading); // ← 部分更新が簡単！
  }
}

// 3. ViewModelのProvider
final kindnessRecordAddViewModelProvider = 
    StateNotifierProvider<KindnessRecordAddViewModel, KindnessRecordAddState>(
  (ref) => KindnessRecordAddViewModel(),
);

// 4. UIで状態を監視
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kindnessRecordAddViewModelProvider); // 状態を監視
    final viewModel = ref.read(kindnessRecordAddViewModelProvider.notifier);
    
    return Column(
      children: [
        Text(state.content), // 状態が変わると自動で画面更新
        TextField(
          onChanged: viewModel.updateContent, // 入力で状態更新
        ),
        if (state.isLoading) CircularProgressIndicator(), // 条件表示も簡単
      ],
    );
  }
}
```

**🔧 Freezed使用時のポイント**

1. **partディレクティブが重要**
```dart
part 'ファイル名.freezed.dart';  // ← これを忘れるとエラー
```

2. **ファイル名規則**
```
元ファイル: kindness_record_add_state.dart
生成ファイル: kindness_record_add_state.freezed.dart
```

3. **build_runner実行タイミング**
```bash
# 新しい@freezedクラスを作った時
dart run build_runner build

# フィールドを追加・削除した時  
dart run build_runner build --delete-conflicting-outputs

# 開発中は watch で自動生成
dart run build_runner watch
```

**⚠️ よくあるエラーと対処法**

```bash
# エラー例
Target of URI doesn't exist: 'package:app/states/my_state.freezed.dart'

# 対処法
dart run build_runner build --delete-conflicting-outputs
```

```bash
# 警告例  
Classes can only mix in mixins and classes.

# 原因: build_runnerをまだ実行していない
# 対処法: 上記コマンド実行
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