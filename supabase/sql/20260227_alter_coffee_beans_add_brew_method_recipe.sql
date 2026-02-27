begin;

alter table public.coffee_beans
  add column if not exists brew_method text,
  add column if not exists recipe text;

alter table public.coffee_beans
  drop constraint if exists coffee_beans_brew_method_check;

alter table public.coffee_beans
  add constraint coffee_beans_brew_method_check
  check (
    brew_method is null
    or brew_method in (
      'espresso','pour_over','french_press','moka_pot',
      'aeropress','cold_brew','siphon','turkish','other'
    )
  );

commit;
