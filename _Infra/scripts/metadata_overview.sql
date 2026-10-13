select
    row_number() over (order by "Тип", "Наименование") as "№",
    "Наименование",
    "Тип"
from (
    select
        table_name as "Наименование",
        case table_type
            when 'BASE TABLE' then 'Таблица'
            when 'VIEW'       then 'Представление'
            else table_type
        end        as "Тип"
    from information_schema.tables
    where table_schema  = 'public'
      and table_catalog = current_database()

    union all

    select
        sequence_name       as "Наименование",
        'Счётчик' as "Тип"
    from information_schema.sequences
    where sequence_schema  = 'public'
      and sequence_catalog = current_database()
) as objects
order by "Тип", "Наименование";