-- ユーザー作成時に`handle_new_user`を呼ぶためのトリガーを定義
create trigger on_auth_user_created
    after insert on auth.users
    for each row
    execute function handle_new_user();
