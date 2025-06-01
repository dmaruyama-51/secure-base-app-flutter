create table if not exists public.users (
    id uuid references auth.users on delete cascade not null primary key,
    created_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    updated_at timestamp with time zone default timezone('utc' :: text, now()) not null
);
comment on table public.users is 'ユーザー情報を保持する';

-- RLSを有効化
alter table users enable row level security;

-- ポリシーを作成
CREATE POLICY "Users can create a users."
ON users FOR INSERT
TO authenticated
WITH CHECK ( (SELECT auth.uid()) = id );

CREATE POLICY "Users can update their own users."
ON users FOR UPDATE
TO authenticated
USING ( (SELECT auth.uid()) = id )
WITH CHECK ( (SELECT auth.uid()) = id );

CREATE POLICY "Users can view their own users."
ON users
FOR SELECT USING ( (SELECT auth.uid()) = id );