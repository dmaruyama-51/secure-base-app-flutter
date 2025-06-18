-- create extension if not exists pg_cron with schema extensions;

select cron.schedule(
  'run_daily_reflection_batch',
  '5 15 * * *', -- JST 0時5分に実行
  $$ select public.run_daily_reflection_batch(); $$
);