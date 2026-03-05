alter table public.coffee_logs
  drop constraint if exists coffee_logs_coffee_type_check;

alter table public.coffee_logs
  drop constraint if exists coffee_logs_caffeine_type_check;

alter table public.coffee_logs
  add column if not exists caffeine_type text;

alter table public.coffee_logs
  alter column caffeine_type set default 'caffeinated';

update public.coffee_logs
set caffeine_type = 'caffeinated'
where caffeine_type is null;

update public.coffee_logs
set coffee_type = 'hand_drip'
where coffee_type = 'brewed_coffee';

update public.coffee_logs
set caffeine_type = 'decaf'
where coffee_type = 'decaf';

update public.coffee_logs
set coffee_type = 'other'
where coffee_type = 'decaf';

alter table public.coffee_logs
  alter column caffeine_type set not null;

alter table public.coffee_logs
  add constraint coffee_logs_coffee_type_check
    check (
      coffee_type in (
        'espresso',
        'americano',
        'latte',
        'cappuccino',
        'mocha',
        'macchiato',
        'flat_white',
        'hand_drip',
        'cold_brew',
        'affogato',
        'other'
      )
    );

alter table public.coffee_logs
  add constraint coffee_logs_caffeine_type_check
    check (
      caffeine_type in ('caffeinated', 'half_caf', 'decaf')
    );
