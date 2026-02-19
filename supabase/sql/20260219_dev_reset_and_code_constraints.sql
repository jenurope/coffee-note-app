begin;

truncate table public.brew_details,
               public.bean_details,
               public.coffee_logs,
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

alter table public.brew_details
  drop constraint if exists brew_details_brew_method_check,
  add constraint brew_details_brew_method_check
  check (brew_method is null or brew_method in ('espresso','pour_over','french_press','moka_pot','aeropress','cold_brew','siphon','turkish','other'));

alter table public.brew_details
  drop constraint if exists brew_details_grind_size_check,
  add constraint brew_details_grind_size_check
  check (grind_size is null or grind_size in ('extra_fine','fine','medium_fine','medium','medium_coarse','coarse','extra_coarse'));

commit;
