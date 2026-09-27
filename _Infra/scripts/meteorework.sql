-- Выполняется поверх meteoscript.sql

drop table if exists parameters_old;
drop table if exists param_types;
drop table if exists units;
drop table if exists base_units;

--  Базовые единицы измерения
create table base_units (
    id integer primary key,
    code varchar(30) not null unique,
    name varchar(100) not null
);

insert into base_units (id, code, name)
values (1, 'LENGTH', 'Длина'),
       (2, 'TEMPERATURE', 'Температура'),
       (3, 'PRESSURE', 'Давление'),
       (4, 'ANGLE', 'Угол'),
       (5, 'SPEED', 'Скорость');

-- Единицы измерения, каждая привязана к базовой единице
create table units (
    id integer primary key,
    code varchar(30) not null unique,
    name varchar(50) not null,
    base_unit_id integer not null references base_units (id)
);

insert into units (id, code, name, base_unit_id)
values (1, 'M', 'метр', 1),
       (2, 'C', 'градус Цельсия', 2),
       (3, 'MMHG', 'мм рт. ст.', 3),
       (4, 'MIL', 'деление угломера', 4),
       (5, 'MPS', 'метр в секунду', 5);

-- Типы параметров, каждый привязан к единице измерения
create table param_types (
    id integer primary key,
    code varchar(30) not null unique,
    name varchar(100) not null,
    unit_id integer not null references units (id)
);

insert into param_types (id, code, name, unit_id)
values (1, 'HEIGHT', 'Высота метеопоста', 1),
       (2, 'TEMPERATURE', 'Температура', 2),
       (3, 'PRESSURE', 'Давление', 3),
       (4, 'WIND_DIRECTION', 'Направление ветра', 4),
       (5, 'WIND_SPEED', 'Скорость ветра', 5),
       (6, 'BULLET_DRIFT', 'Дальность сноса пуль', 1);



-- откат данных в другую таблицу
create table parameters_old (
    id integer,
    code varchar(30),
    pack_id integer,
    name varchar(100),
    unit varchar(30),
    value varchar(10)
);

insert into parameters_old
select id, code, pack_id, name, unit, value
from parameters;

delete from parameters;

alter table parameters drop column name;
alter table parameters drop column unit;

alter table parameters add column param_type_id integer references param_types (id);

insert into parameters (id, code, pack_id, value, param_type_id)
select parameters_old.id,
       parameters_old.code,
       parameters_old.pack_id,
       parameters_old.value,
       param_types.id
from parameters_old
join param_types on param_types.name = parameters_old.name;
alter table parameters alter column param_type_id set not null;
drop table parameters_old;

-- запрос

select packs.measured_at                                  as measurement_date,
       packs.code                                          as pack_number,
       users.name                                          as employee_name,
       param_types.name || ', ' || units.name              as parameter,
       parameters.value                                    as value
from packs, users, parameters, param_types, units
where
        -- Связь пачка - сотрудник
        users.id = packs.user_id
        -- Связь параметр - пачка
    and parameters.pack_id = packs.id
        -- Связь параметр - тип параметра
    and parameters.param_type_id = param_types.id
        -- Связь тип параметра - единица измерения
    and param_types.unit_id = units.id
order by packs.code, param_types.code;