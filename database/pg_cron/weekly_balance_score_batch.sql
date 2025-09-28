select cron.schedule(
  'weekly_balance_score_batch',
  '0 2 * * 1', -- 毎週月曜日 2時0分に実行
  $$ select public.run_weekly_balance_score_batch(); $$
);