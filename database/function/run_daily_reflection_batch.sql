create or replace function run_daily_reflection_batch()
returns void 
language plpgsql
as $$
    declare process_date date := current_date; 

    begin
    
        with 
        
        /* userごとに最新の kindness_reflections の created_at を取得 */
        latest_reflection_date as (
            select
                user_id,
                max(created_at)::date as latest_ref_date
            from 
                public.kindness_reflections
            group by 
                1
        ),

        /* ユーザーごとの基準日を取得 */
        base_dates as (
            select
                u.id as user_id,
                -- 最新のkindness_reflectionのcreated_atが基準日
                -- レコードが存在しない場合はユーザーの作成日を基準日とする
                coalesce(lr.last_ref_date, u.created_at::date) as base_date,
                u.reflection_type_id,
                rtm.reflection_period
            from 
                public.users as u 
                    left join latest_reflection_date as lr 
                        on lr.user_id = u.id
                    inner join public.reflection_type_master as rtm 
                        on rtm.id = u.reflection_type_id
        ),

        /* insert 対象のユーザーを取得 */
        due_users as (
            select
                *
            from 
                base_dates 
            where
                -- 基準日 + reflection_period が今日の日付の場合 kindness_reflections に insert する
                process_date = (base_date + reflection_period * interval '1 day')::date
        )

        insert into public.kindness_reflections (
            created_at,
            reflection_type_id,
            reflection_title,
            reflection_start_date,
            reflection_end_date,
            user_id
        ) 

        select
            now() as created_at,
            reflection_type_id,
            format('安全基地ノート（%s年%02s月）', extract(year  from base_date), extract(month from base_date)) as reflection_title,
            base_date as reflection_start_date,
            process_date -1 as reflection_end_date,
            user_id
        from 
            due_users

        on conflict do nothing;
    end;
$$;