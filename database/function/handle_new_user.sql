-- ユーザー名をprofilesテーブルにコピーするDatabase Functionを定義
create or replace function public.handle_new_user() returns trigger as $$
    begin
        insert into public.users(id)
        values(new.id);

        return new;
    end;
$$ language plpgsql security definer;
