begin;

truncate table public.coffee_logs,
               public.coffee_beans
restart identity cascade;

alter table public.coffee_logs
  drop constraint if exists coffee_logs_coffee_type_check,
  add constraint coffee_logs_coffee_type_check
  check (coffee_type in ('espresso','americano','latte','cappuccino','mocha','macchiato','flat_white','cold_brew','affogato','other'));

alter table public.coffee_beans
  drop constraint if exists coffee_beans_roast_level_check,
  add constraint coffee_beans_roast_level_check
  check (roast_level is null or roast_level in ('light','medium_light','medium','medium_dark','dark'));

commit;
