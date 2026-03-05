alter table public.coffee_logs
  drop constraint if exists coffee_logs_coffee_type_check;

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
        'brewed_coffee',
        'cold_brew',
        'decaf',
        'affogato',
        'other'
      )
    );
