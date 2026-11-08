-- Учебный скрипт (адаптированный под IF NOT EXISTS)
do $do$
begin
    -- Создание таблицы заголовков (требование ТЗ)
    execute $sql$
        create table if not exists pl_report_headers (
            id              integer primary key,
            code            varchar(30) not null unique,
            title_name      varchar(200) not null,
            description     text,
            created_at      timestamp default now()
        )
    $sql$;

    -- Справочник типов таблиц исключений
    -- Связывает report_header_id
    execute $sql$
        create table if not exists pl_exception_table_types (
            id                  integer primary key,
            code                varchar(30) not null unique,
            name                varchar(100) not null,
            report_header_id    integer not null references pl_report_headers(id),
            description         text
        )
    $sql$;

    -- Таблицы (temp_deviations, wind_speed) предполагаются уже созданными
end $do$;

-- Корректировка данных по справочникам
-- Добавление отсутствующих высот
insert into ref_heights (id, height_value, description)
select v.id, v.height_value, v.description
from (values 
    (1, 200, 'Стандартная высота 200 м'),
    (2, 400, 'Стандартная высота 400 м'),
    (3, 800, 'Стандартная высота 800 м'),
    (4, 1200, 'Стандартная высота 1200 м')
) as v(id, height_value, description)
where not exists (select 1 from ref_heights where ref_heights.id = v.id);

-- Исправление/добавление данных temp_deviations
insert into temp_deviations (id, height_id, temp_deviation, val_neg, val_pos)
select 101, 2, -10.0, -1.2, -1.2
where not exists (
    select 1 from temp_deviations 
    where height_id = 2 and temp_deviation = -10.0
);

-- Исправление ошибочного значения
update temp_deviations
set val_pos = 1.8
where height_id = 1 and temp_deviation = 15.0;

-- Добавление данных в wind_speed
-- Пример: для высоты 800 height_id = 3 device_id = 1 входного значения 10.0
insert into wind_speed (height_id, device_id, input_value, wind_speed, angle_increment)
select 3, 1, 10.0, 12.5, 0.05
where not exists (
    select 1 from wind_speed 
    where height_id = 3 and device_id = 1 and input_value = 10.0
);

-- Наполнение таблицы заголовков и справочника исключений
insert into pl_report_headers (id, code, title_name, description)
select v.id, v.code, v.title_name, v.description
from (values 
    (1, 'HDR-METEO', 'Метеорологический бюллетень', 'Основной заголовок отчета'),
    (2, 'HDR-EXC', 'Исключения', 'Заголовок для таблиц исключений')
) as v(id, code, title_name, description)
where not exists (select 1 from pl_report_headers where pl_report_headers.code = v.code);

insert into pl_exception_table_types (id, code, name, report_header_id, description)
select v.id, v.code, v.name, v.report_header_id, v.description
from (values 
    (1, 'EXC-TEMP', 'Температурные исключения', 2, 'Исключения по температуре'),
    (2, 'EXC-WIND', 'Ветровые исключения', 2, 'Исключения по ветру')
) as v(id, code, name, report_header_id, description)
where not exists (select 1 from pl_exception_table_types where pl_exception_table_types.code = v.code);