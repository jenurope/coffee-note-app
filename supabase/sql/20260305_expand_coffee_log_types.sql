alter table public.coffee_logs
  drop constraint if exists coffee_logs_coffee_type_check;

update public.coffee_logs
set coffee_type = 'hand_drip'
where coffee_type = 'brewed_coffee';

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
        'decaf',
        'affogato',
        'other'
      )
    );
