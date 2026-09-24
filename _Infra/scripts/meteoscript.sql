create table if not exists positions (
    id integer primary key,
    code varchar(30) not null unique,
    name varchar(100) not null
);

create table if not exists equipment_types (
    id integer primary key,
    code varchar(30) not null unique,
    name varchar(100) not null
);

create table if not exists users (
    id integer primary key,
    code varchar(30) not null unique,
    name varchar(150) not null,
    position_id integer not null references positions (id)
);

create table if not exists packs (
    id integer primary key,
    code varchar(30) not null unique,
    user_id integer not null references users (id),
    equipment_type_id integer not null references equipment_types (id),
    measured_at timestamp not null
);

create table if not exists parameters (
    id integer primary key,
    code varchar(30) not null unique,
    pack_id integer not null references packs (id),
    name varchar(100) not null,
    unit varchar(30),
    value varchar(10) not null
);

insert into positions (id, code, name)
select 1, 'POS-001', 'Начальник метеопоста'
where not exists (select 1 from positions where code = 'POS-001');

insert into positions (id, code, name)
select 2, 'POS-002', 'Метеоролог-наблюдатель'
where not exists (select 1 from positions where code = 'POS-002');

insert into positions (id, code, name)
select 3, 'POS-003', 'Расчетчик'
where not exists (select 1 from positions where code = 'POS-003');

insert into equipment_types (id, code, name)
select 1, 'EQP-DMK', 'ДМК'
where not exists (select 1 from equipment_types where code = 'EQP-DMK');

insert into equipment_types (id, code, name)
select 2, 'EQP-VR', 'ВР'
where not exists (select 1 from equipment_types where code = 'EQP-VR');

insert into users (id, code, name, position_id)
select 1, 'USR-001', 'Иванов Иван', 1
where not exists (select 1 from users where code = 'USR-001');

insert into users (id, code, name, position_id)
select 2, 'USR-002', 'Петров Петр', 2
where not exists (select 1 from users where code = 'USR-002');

insert into users (id, code, name, position_id)
select 3, 'USR-003', 'Сидоров Сидор', 3
where not exists (select 1 from users where code = 'USR-003');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 1, 'PCK-001', 1, 1, cast('2026-09-20 09:30:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-001');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 2, 'PCK-002', 2, 2, cast('2026-09-20 10:00:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-002');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 3, 'PCK-003', 3, 1, cast('2026-09-20 10:30:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-003');

insert into parameters (id, code, pack_id, name, unit, value)
select 1, 'PRM-001', 1, 'Высота метеопоста', 'м', '100'
where not exists (select 1 from parameters where code = 'PRM-001');

insert into parameters (id, code, pack_id, name, unit, value)
select 2, 'PRM-002', 1, 'Температура', 'C', '25'
where not exists (select 1 from parameters where code = 'PRM-002');

insert into parameters (id, code, pack_id, name, unit, value)
select 3, 'PRM-003', 1, 'Давление', 'мм рт. ст.', '765'
where not exists (select 1 from parameters where code = 'PRM-003');

insert into parameters (id, code, pack_id, name, unit, value)
select 4, 'PRM-004', 1, 'Направление ветра', 'дел. угломера', '15'
where not exists (select 1 from parameters where code = 'PRM-004');

insert into parameters (id, code, pack_id, name, unit, value)
select 5, 'PRM-005', 1, 'Скорость ветра', 'м/с', '6'
where not exists (select 1 from parameters where code = 'PRM-005');

insert into parameters (id, code, pack_id, name, unit, value)
select 6, 'PRM-006', 2, 'Высота метеопоста', 'м', '100'
where not exists (select 1 from parameters where code = 'PRM-006');

insert into parameters (id, code, pack_id, name, unit, value)
select 7, 'PRM-007', 2, 'Температура', 'C', '15'
where not exists (select 1 from parameters where code = 'PRM-007');

insert into parameters (id, code, pack_id, name, unit, value)
select 8, 'PRM-008', 2, 'Давление', 'мм рт. ст.', '750'
where not exists (select 1 from parameters where code = 'PRM-008');

insert into parameters (id, code, pack_id, name, unit, value)
select 9, 'PRM-009', 2, 'Направление ветра', 'дел. угломера', '00'
where not exists (select 1 from parameters where code = 'PRM-009');

insert into parameters (id, code, pack_id, name, unit, value)
select 10, 'PRM-010', 2, 'Дальность сноса пуль', 'м', '50'
where not exists (select 1 from parameters where code = 'PRM-010');

insert into parameters (id, code, pack_id, name, unit, value)
select 11, 'PRM-011', 3, 'Высота метеопоста', 'м', '60'
where not exists (select 1 from parameters where code = 'PRM-011');

insert into parameters (id, code, pack_id, name, unit, value)
select 12, 'PRM-012', 3, 'Температура', 'C', '23'
where not exists (select 1 from parameters where code = 'PRM-012');

insert into parameters (id, code, pack_id, name, unit, value)
select 13, 'PRM-013', 3, 'Давление', 'мм рт. ст.', '757'
where not exists (select 1 from parameters where code = 'PRM-013');

insert into parameters (id, code, pack_id, name, unit, value)
select 14, 'PRM-014', 3, 'Направление ветра', 'дел. угломера', '30'
where not exists (select 1 from parameters where code = 'PRM-014');

insert into parameters (id, code, pack_id, name, unit, value)
select 15, 'PRM-015', 3, 'Скорость ветра', 'м/с', '4'
where not exists (select 1 from parameters where code = 'PRM-015');

select packs.code as pack_code,
       packs.measured_at,
       users.code as user_code,
       users.name as user_name,
       positions.name as position_name,
       equipment_types.name as equipment_name,
       parameters.code as parameter_code,
       parameters.name as parameter_name,
       parameters.value,
       parameters.unit
from packs
join users on users.id = packs.user_id
join positions on positions.id = users.position_id
join equipment_types on equipment_types.id = packs.equipment_type_id
join parameters on parameters.pack_id = packs.id
order by packs.code, parameters.code;
