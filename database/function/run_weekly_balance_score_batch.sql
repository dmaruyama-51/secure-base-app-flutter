/* 
週次 balance_scores 作成バッチ 
*/

create or replace function run_weekly_balance_score_batch()
returns void 
language plpgsql
as $$
    begin
    
        with

        weekly_stats as (
            select 
                user_id,

                -- 前週の開始日（月曜日）と終了日（日曜日）を計算
                date_trunc('week', current_date - interval '1 week')::date as week_start_date,
                (date_trunc('week', current_date - interval '1 week') + interval '6 days')::date as week_end_date,
                
                -- 送った優しさの件数とユニークメンバー数
                count(case when record_type = 'given' then 1 end) AS sent_count,
                count(distinct case when record_type = 'given' then giver_id end) AS sent_uu,
                
                -- 受け取った優しさの件数とユニークメンバー数
                count(case when record_type = 'received' then 1 end) AS receive_count,
                count(distinct case when record_type = 'received' then giver_id end) AS receive_uu
                
            from 
                public.kindness_records
            where 
                -- 前週のデータのみ対象
                created_at >= date_trunc('week', current_date - interval '1 week')
                and created_at < date_trunc('week', current_date)
            group by 
                user_id
        ),

        score_calculation as (
            select 
                user_id,
                week_start_date,
                week_end_date,
                sent_count,
                sent_uu,
                receive_count,
                receive_uu,
                
                -- 中間スコア計算（送った優しさ）
                (0.7 * least(sent_count, 7) + 0.3 * least(sent_uu, 5)) as supporting_score_raw,
                
                -- 中間スコア計算（受け取った優しさ）
                (0.7 * least(receive_count, 7) + 0.3 * least(receive_uu, 5)) as supported_score_raw,
                
                -- 最大値 = 0.7 * 7 + 0.3 * 5 = 6.4
                6.4 as max_raw_score
                
            from 
                weekly_stats
        ),

        normalized_scores as (
            select 
                user_id,
                week_start_date,
                week_end_date,
                sent_count,
                sent_uu,
                receive_count,
                receive_uu,
                supporting_score_raw,
                supported_score_raw,
                
                -- 正規化スコア
                supporting_score_raw / max_raw_score as supporting_score_norm,
                supported_score_raw / max_raw_score as supported_score_norm
                
            from 
                score_calculation
        ),

        final_scores as (
            select 
                user_id,
                week_start_date,
                week_end_date,
                sent_count,
                sent_uu,
                receive_count,
                receive_uu,
                round(supporting_score_norm * 100) as supporting_score,
                round(supported_score_norm * 100) as supported_score,
                supporting_score_norm,
                supported_score_norm,
                
                -- バランススコア（調和平均）
                case 
                when supporting_score_norm + supported_score_norm = 0 then 0
                else ROUND(50 + 50 * (supported_score_norm - supporting_score_norm)
                        / (supported_score_norm + supporting_score_norm)
                end as balance_score
                
            from 
                normalized_scores
        )

        -- balance_scoresテーブルに挿入
        insert into public.balance_scores (
            user_id,
            week_start_date,
            week_end_date,
            sent_count,
            sent_uu,
            receive_count,
            receive_uu,
            supporting_score,
            supported_score,
            supporting_score_norm,
            supported_score_norm,
            balance_score
        )
        select 
            user_id,
            week_start_date,
            week_end_date,
            sent_count,
            sent_uu,
            receive_count,
            receive_uu,
            supporting_score,
            supported_score,
            supporting_score_norm,
            supported_score_norm,
            balance_score
        from 
            final_scores
        where 
            user_id is not null;

        on conflict do nothing;
    end;
$$;