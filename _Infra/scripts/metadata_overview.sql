select
    row_number() over (order by table_name) as "№",
    table_name                               as "Наименование",
    case table_type
        when 'BASE TABLE' then 'Таблица'
        when 'VIEW'       then 'Представление'
        else table_type
    end                                       as "Тип"
from information_schema.tables
where table_schema = 'public'
order by table_name;
