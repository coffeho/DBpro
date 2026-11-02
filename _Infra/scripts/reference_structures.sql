-- DML-скрипт: наполнение тестовыми данными
-- Сформирован по промту, приложенному в Pull Request

-- ============================================================
-- 1. Таблицы
-- ============================================================

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

create table if not exists base_units (
    id integer primary key,
    code varchar(30) not null unique,
    name varchar(100) not null
);

create table if not exists units (
    id integer primary key,
    code varchar(30) not null unique,
    name varchar(50) not null,
    base_unit_id integer not null references base_units (id)
);

create table if not exists param_types (
    id integer primary key,
    code varchar(30) not null unique,
    name varchar(100) not null,
    unit_id integer not null references units (id)
);

create table if not exists parameters (
    id integer primary key,
    code varchar(30) not null unique,
    pack_id integer not null references packs (id),
    value varchar(10) not null,
    param_type_id integer not null references param_types (id)
);

-- ============================================================
-- 2. Справочники (нужны для внешних ключей новых данных)
-- ============================================================

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

insert into base_units (id, code, name)
select 1, 'LENGTH', 'Длина'
where not exists (select 1 from base_units where code = 'LENGTH');

insert into base_units (id, code, name)
select 2, 'TEMPERATURE', 'Температура'
where not exists (select 1 from base_units where code = 'TEMPERATURE');

insert into base_units (id, code, name)
select 3, 'PRESSURE', 'Давление'
where not exists (select 1 from base_units where code = 'PRESSURE');

insert into base_units (id, code, name)
select 4, 'ANGLE', 'Угол'
where not exists (select 1 from base_units where code = 'ANGLE');

insert into base_units (id, code, name)
select 5, 'SPEED', 'Скорость'
where not exists (select 1 from base_units where code = 'SPEED');

insert into units (id, code, name, base_unit_id)
select 1, 'M', 'метр', 1
where not exists (select 1 from units where code = 'M');

insert into units (id, code, name, base_unit_id)
select 2, 'C', 'градус Цельсия', 2
where not exists (select 1 from units where code = 'C');

insert into units (id, code, name, base_unit_id)
select 3, 'MMHG', 'мм рт. ст.', 3
where not exists (select 1 from units where code = 'MMHG');

insert into units (id, code, name, base_unit_id)
select 4, 'MIL', 'деление угломера', 4
where not exists (select 1 from units where code = 'MIL');

insert into units (id, code, name, base_unit_id)
select 5, 'MPS', 'метр в секунду', 5
where not exists (select 1 from units where code = 'MPS');

insert into param_types (id, code, name, unit_id)
select 1, 'HEIGHT', 'Высота метеопоста', 1
where not exists (select 1 from param_types where code = 'HEIGHT');

insert into param_types (id, code, name, unit_id)
select 2, 'TEMPERATURE', 'Температура', 2
where not exists (select 1 from param_types where code = 'TEMPERATURE');

insert into param_types (id, code, name, unit_id)
select 3, 'PRESSURE', 'Давление', 3
where not exists (select 1 from param_types where code = 'PRESSURE');

insert into param_types (id, code, name, unit_id)
select 4, 'WIND_DIRECTION', 'Направление ветра', 4
where not exists (select 1 from param_types where code = 'WIND_DIRECTION');

insert into param_types (id, code, name, unit_id)
select 5, 'WIND_SPEED', 'Скорость ветра', 5
where not exists (select 1 from param_types where code = 'WIND_SPEED');

insert into param_types (id, code, name, unit_id)
select 6, 'BULLET_DRIFT', 'Дальность сноса пуль', 1
where not exists (select 1 from param_types where code = 'BULLET_DRIFT');

-- ============================================================
-- 3. Новые пользователи (минимум 3)
-- ============================================================

insert into users (id, code, name, position_id)
select 4, 'USR-004', 'Смирнов Алексей', 1
where not exists (select 1 from users where code = 'USR-004');

insert into users (id, code, name, position_id)
select 5, 'USR-005', 'Кузнецов Дмитрий', 2
where not exists (select 1 from users where code = 'USR-005');

insert into users (id, code, name, position_id)
select 6, 'USR-006', 'Новиков Егор', 3
where not exists (select 1 from users where code = 'USR-006');

-- ============================================================
-- 4. Новые пачки измерений (минимум 20)
-- ============================================================

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 4, 'PCK-004', 4, 1, cast('2026-09-21 07:00:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-004');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 5, 'PCK-005', 5, 2, cast('2026-09-22 10:15:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-005');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 6, 'PCK-006', 5, 1, cast('2026-09-23 08:00:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-006');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 7, 'PCK-007', 4, 2, cast('2026-09-24 17:00:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-007');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 8, 'PCK-008', 5, 1, cast('2026-09-25 12:00:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-008');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 9, 'PCK-009', 4, 2, cast('2026-09-26 07:15:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-009');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 10, 'PCK-010', 5, 1, cast('2026-09-27 14:00:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-010');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 11, 'PCK-011', 5, 2, cast('2026-09-28 09:45:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-011');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 12, 'PCK-012', 5, 1, cast('2026-09-21 13:30:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-012');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 13, 'PCK-013', 4, 2, cast('2026-09-22 18:15:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-013');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 14, 'PCK-014', 5, 1, cast('2026-09-23 12:30:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-014');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 15, 'PCK-015', 6, 2, cast('2026-09-24 08:15:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-015');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 16, 'PCK-016', 6, 1, cast('2026-09-25 07:00:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-016');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 17, 'PCK-017', 5, 2, cast('2026-09-26 07:30:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-017');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 18, 'PCK-018', 6, 1, cast('2026-09-27 15:30:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-018');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 19, 'PCK-019', 4, 2, cast('2026-09-28 17:45:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-019');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 20, 'PCK-020', 5, 1, cast('2026-09-21 07:45:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-020');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 21, 'PCK-021', 4, 2, cast('2026-09-22 14:30:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-021');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 22, 'PCK-022', 4, 1, cast('2026-09-23 15:30:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-022');

insert into packs (id, code, user_id, equipment_type_id, measured_at)
select 23, 'PCK-023', 5, 2, cast('2026-09-24 09:00:00' as timestamp)
where not exists (select 1 from packs where code = 'PCK-023');

-- ============================================================
-- 5. Параметры новых пачек (по 5 на каждую пачку)
-- ============================================================

insert into parameters (id, code, pack_id, value, param_type_id)
select 16, 'PRM-016', 4, '-27', 1
where not exists (select 1 from parameters where code = 'PRM-016');

insert into parameters (id, code, pack_id, value, param_type_id)
select 17, 'PRM-017', 4, '18.7', 2
where not exists (select 1 from parameters where code = 'PRM-017');

insert into parameters (id, code, pack_id, value, param_type_id)
select 18, 'PRM-018', 4, '895', 3
where not exists (select 1 from parameters where code = 'PRM-018');

insert into parameters (id, code, pack_id, value, param_type_id)
select 19, 'PRM-019', 4, '18', 4
where not exists (select 1 from parameters where code = 'PRM-019');

insert into parameters (id, code, pack_id, value, param_type_id)
select 20, 'PRM-020', 4, '2', 5
where not exists (select 1 from parameters where code = 'PRM-020');

insert into parameters (id, code, pack_id, value, param_type_id)
select 21, 'PRM-021', 5, '387', 1
where not exists (select 1 from parameters where code = 'PRM-021');

insert into parameters (id, code, pack_id, value, param_type_id)
select 22, 'PRM-022', 5, '-31.0', 2
where not exists (select 1 from parameters where code = 'PRM-022');

insert into parameters (id, code, pack_id, value, param_type_id)
select 23, 'PRM-023', 5, '551', 3
where not exists (select 1 from parameters where code = 'PRM-023');

insert into parameters (id, code, pack_id, value, param_type_id)
select 24, 'PRM-024', 5, '24', 4
where not exists (select 1 from parameters where code = 'PRM-024');

insert into parameters (id, code, pack_id, value, param_type_id)
select 25, 'PRM-025', 5, '71', 6
where not exists (select 1 from parameters where code = 'PRM-025');

insert into parameters (id, code, pack_id, value, param_type_id)
select 26, 'PRM-026', 6, '182', 1
where not exists (select 1 from parameters where code = 'PRM-026');

insert into parameters (id, code, pack_id, value, param_type_id)
select 27, 'PRM-027', 6, '15.7', 2
where not exists (select 1 from parameters where code = 'PRM-027');

insert into parameters (id, code, pack_id, value, param_type_id)
select 28, 'PRM-028', 6, '686', 3
where not exists (select 1 from parameters where code = 'PRM-028');

insert into parameters (id, code, pack_id, value, param_type_id)
select 29, 'PRM-029', 6, '10', 4
where not exists (select 1 from parameters where code = 'PRM-029');

insert into parameters (id, code, pack_id, value, param_type_id)
select 30, 'PRM-030', 6, '11', 5
where not exists (select 1 from parameters where code = 'PRM-030');

insert into parameters (id, code, pack_id, value, param_type_id)
select 31, 'PRM-031', 7, '131', 1
where not exists (select 1 from parameters where code = 'PRM-031');

insert into parameters (id, code, pack_id, value, param_type_id)
select 32, 'PRM-032', 7, '-33.7', 2
where not exists (select 1 from parameters where code = 'PRM-032');

insert into parameters (id, code, pack_id, value, param_type_id)
select 33, 'PRM-033', 7, '636', 3
where not exists (select 1 from parameters where code = 'PRM-033');

insert into parameters (id, code, pack_id, value, param_type_id)
select 34, 'PRM-034', 7, '44', 4
where not exists (select 1 from parameters where code = 'PRM-034');

insert into parameters (id, code, pack_id, value, param_type_id)
select 35, 'PRM-035', 7, '18', 6
where not exists (select 1 from parameters where code = 'PRM-035');

insert into parameters (id, code, pack_id, value, param_type_id)
select 36, 'PRM-036', 8, '261', 1
where not exists (select 1 from parameters where code = 'PRM-036');

insert into parameters (id, code, pack_id, value, param_type_id)
select 37, 'PRM-037', 8, '15.7', 2
where not exists (select 1 from parameters where code = 'PRM-037');

insert into parameters (id, code, pack_id, value, param_type_id)
select 38, 'PRM-038', 8, '773', 3
where not exists (select 1 from parameters where code = 'PRM-038');

insert into parameters (id, code, pack_id, value, param_type_id)
select 39, 'PRM-039', 8, '46', 4
where not exists (select 1 from parameters where code = 'PRM-039');

insert into parameters (id, code, pack_id, value, param_type_id)
select 40, 'PRM-040', 8, '7', 5
where not exists (select 1 from parameters where code = 'PRM-040');

insert into parameters (id, code, pack_id, value, param_type_id)
select 41, 'PRM-041', 9, '33', 1
where not exists (select 1 from parameters where code = 'PRM-041');

insert into parameters (id, code, pack_id, value, param_type_id)
select 42, 'PRM-042', 9, '-4.4', 2
where not exists (select 1 from parameters where code = 'PRM-042');

insert into parameters (id, code, pack_id, value, param_type_id)
select 43, 'PRM-043', 9, '638', 3
where not exists (select 1 from parameters where code = 'PRM-043');

insert into parameters (id, code, pack_id, value, param_type_id)
select 44, 'PRM-044', 9, '59', 4
where not exists (select 1 from parameters where code = 'PRM-044');

insert into parameters (id, code, pack_id, value, param_type_id)
select 45, 'PRM-045', 9, '142', 6
where not exists (select 1 from parameters where code = 'PRM-045');

insert into parameters (id, code, pack_id, value, param_type_id)
select 46, 'PRM-046', 10, '62', 1
where not exists (select 1 from parameters where code = 'PRM-046');

insert into parameters (id, code, pack_id, value, param_type_id)
select 47, 'PRM-047', 10, '21.4', 2
where not exists (select 1 from parameters where code = 'PRM-047');

insert into parameters (id, code, pack_id, value, param_type_id)
select 48, 'PRM-048', 10, '893', 3
where not exists (select 1 from parameters where code = 'PRM-048');

insert into parameters (id, code, pack_id, value, param_type_id)
select 49, 'PRM-049', 10, '49', 4
where not exists (select 1 from parameters where code = 'PRM-049');

insert into parameters (id, code, pack_id, value, param_type_id)
select 50, 'PRM-050', 10, '1', 5
where not exists (select 1 from parameters where code = 'PRM-050');

insert into parameters (id, code, pack_id, value, param_type_id)
select 51, 'PRM-051', 11, '67', 1
where not exists (select 1 from parameters where code = 'PRM-051');

insert into parameters (id, code, pack_id, value, param_type_id)
select 52, 'PRM-052', 11, '37.3', 2
where not exists (select 1 from parameters where code = 'PRM-052');

insert into parameters (id, code, pack_id, value, param_type_id)
select 53, 'PRM-053', 11, '661', 3
where not exists (select 1 from parameters where code = 'PRM-053');

insert into parameters (id, code, pack_id, value, param_type_id)
select 54, 'PRM-054', 11, '25', 4
where not exists (select 1 from parameters where code = 'PRM-054');

insert into parameters (id, code, pack_id, value, param_type_id)
select 55, 'PRM-055', 11, '68', 6
where not exists (select 1 from parameters where code = 'PRM-055');

insert into parameters (id, code, pack_id, value, param_type_id)
select 56, 'PRM-056', 12, '-17', 1
where not exists (select 1 from parameters where code = 'PRM-056');

insert into parameters (id, code, pack_id, value, param_type_id)
select 57, 'PRM-057', 12, '-33.5', 2
where not exists (select 1 from parameters where code = 'PRM-057');

insert into parameters (id, code, pack_id, value, param_type_id)
select 58, 'PRM-058', 12, '790', 3
where not exists (select 1 from parameters where code = 'PRM-058');

insert into parameters (id, code, pack_id, value, param_type_id)
select 59, 'PRM-059', 12, '56', 4
where not exists (select 1 from parameters where code = 'PRM-059');

insert into parameters (id, code, pack_id, value, param_type_id)
select 60, 'PRM-060', 12, '10', 5
where not exists (select 1 from parameters where code = 'PRM-060');

insert into parameters (id, code, pack_id, value, param_type_id)
select 61, 'PRM-061', 13, '58', 1
where not exists (select 1 from parameters where code = 'PRM-061');

insert into parameters (id, code, pack_id, value, param_type_id)
select 62, 'PRM-062', 13, '18.0', 2
where not exists (select 1 from parameters where code = 'PRM-062');

insert into parameters (id, code, pack_id, value, param_type_id)
select 63, 'PRM-063', 13, '702', 3
where not exists (select 1 from parameters where code = 'PRM-063');

insert into parameters (id, code, pack_id, value, param_type_id)
select 64, 'PRM-064', 13, '56', 4
where not exists (select 1 from parameters where code = 'PRM-064');

insert into parameters (id, code, pack_id, value, param_type_id)
select 65, 'PRM-065', 13, '117', 6
where not exists (select 1 from parameters where code = 'PRM-065');

insert into parameters (id, code, pack_id, value, param_type_id)
select 66, 'PRM-066', 14, '23', 1
where not exists (select 1 from parameters where code = 'PRM-066');

insert into parameters (id, code, pack_id, value, param_type_id)
select 67, 'PRM-067', 14, '-27.3', 2
where not exists (select 1 from parameters where code = 'PRM-067');

insert into parameters (id, code, pack_id, value, param_type_id)
select 68, 'PRM-068', 14, '626', 3
where not exists (select 1 from parameters where code = 'PRM-068');

insert into parameters (id, code, pack_id, value, param_type_id)
select 69, 'PRM-069', 14, '47', 4
where not exists (select 1 from parameters where code = 'PRM-069');

insert into parameters (id, code, pack_id, value, param_type_id)
select 70, 'PRM-070', 14, '8', 5
where not exists (select 1 from parameters where code = 'PRM-070');

insert into parameters (id, code, pack_id, value, param_type_id)
select 71, 'PRM-071', 15, '332', 1
where not exists (select 1 from parameters where code = 'PRM-071');

insert into parameters (id, code, pack_id, value, param_type_id)
select 72, 'PRM-072', 15, '9.8', 2
where not exists (select 1 from parameters where code = 'PRM-072');

insert into parameters (id, code, pack_id, value, param_type_id)
select 73, 'PRM-073', 15, '798', 3
where not exists (select 1 from parameters where code = 'PRM-073');

insert into parameters (id, code, pack_id, value, param_type_id)
select 74, 'PRM-074', 15, '25', 4
where not exists (select 1 from parameters where code = 'PRM-074');

insert into parameters (id, code, pack_id, value, param_type_id)
select 75, 'PRM-075', 15, '92', 6
where not exists (select 1 from parameters where code = 'PRM-075');

insert into parameters (id, code, pack_id, value, param_type_id)
select 76, 'PRM-076', 16, '62', 1
where not exists (select 1 from parameters where code = 'PRM-076');

insert into parameters (id, code, pack_id, value, param_type_id)
select 77, 'PRM-077', 16, '57.7', 2
where not exists (select 1 from parameters where code = 'PRM-077');

insert into parameters (id, code, pack_id, value, param_type_id)
select 78, 'PRM-078', 16, '570', 3
where not exists (select 1 from parameters where code = 'PRM-078');

insert into parameters (id, code, pack_id, value, param_type_id)
select 79, 'PRM-079', 16, '32', 4
where not exists (select 1 from parameters where code = 'PRM-079');

insert into parameters (id, code, pack_id, value, param_type_id)
select 80, 'PRM-080', 16, '15', 5
where not exists (select 1 from parameters where code = 'PRM-080');

insert into parameters (id, code, pack_id, value, param_type_id)
select 81, 'PRM-081', 17, '-4', 1
where not exists (select 1 from parameters where code = 'PRM-081');

insert into parameters (id, code, pack_id, value, param_type_id)
select 82, 'PRM-082', 17, '29.7', 2
where not exists (select 1 from parameters where code = 'PRM-082');

insert into parameters (id, code, pack_id, value, param_type_id)
select 83, 'PRM-083', 17, '556', 3
where not exists (select 1 from parameters where code = 'PRM-083');

insert into parameters (id, code, pack_id, value, param_type_id)
select 84, 'PRM-084', 17, '09', 4
where not exists (select 1 from parameters where code = 'PRM-084');

insert into parameters (id, code, pack_id, value, param_type_id)
select 85, 'PRM-085', 17, '40', 6
where not exists (select 1 from parameters where code = 'PRM-085');

insert into parameters (id, code, pack_id, value, param_type_id)
select 86, 'PRM-086', 18, '355', 1
where not exists (select 1 from parameters where code = 'PRM-086');

insert into parameters (id, code, pack_id, value, param_type_id)
select 87, 'PRM-087', 18, '20.9', 2
where not exists (select 1 from parameters where code = 'PRM-087');

insert into parameters (id, code, pack_id, value, param_type_id)
select 88, 'PRM-088', 18, '805', 3
where not exists (select 1 from parameters where code = 'PRM-088');

insert into parameters (id, code, pack_id, value, param_type_id)
select 89, 'PRM-089', 18, '04', 4
where not exists (select 1 from parameters where code = 'PRM-089');

insert into parameters (id, code, pack_id, value, param_type_id)
select 90, 'PRM-090', 18, '12', 5
where not exists (select 1 from parameters where code = 'PRM-090');

insert into parameters (id, code, pack_id, value, param_type_id)
select 91, 'PRM-091', 19, '145', 1
where not exists (select 1 from parameters where code = 'PRM-091');

insert into parameters (id, code, pack_id, value, param_type_id)
select 92, 'PRM-092', 19, '11.1', 2
where not exists (select 1 from parameters where code = 'PRM-092');

insert into parameters (id, code, pack_id, value, param_type_id)
select 93, 'PRM-093', 19, '739', 3
where not exists (select 1 from parameters where code = 'PRM-093');

insert into parameters (id, code, pack_id, value, param_type_id)
select 94, 'PRM-094', 19, '33', 4
where not exists (select 1 from parameters where code = 'PRM-094');

insert into parameters (id, code, pack_id, value, param_type_id)
select 95, 'PRM-095', 19, '64', 6
where not exists (select 1 from parameters where code = 'PRM-095');

insert into parameters (id, code, pack_id, value, param_type_id)
select 96, 'PRM-096', 20, '233', 1
where not exists (select 1 from parameters where code = 'PRM-096');

insert into parameters (id, code, pack_id, value, param_type_id)
select 97, 'PRM-097', 20, '41.9', 2
where not exists (select 1 from parameters where code = 'PRM-097');

insert into parameters (id, code, pack_id, value, param_type_id)
select 98, 'PRM-098', 20, '505', 3
where not exists (select 1 from parameters where code = 'PRM-098');

insert into parameters (id, code, pack_id, value, param_type_id)
select 99, 'PRM-099', 20, '43', 4
where not exists (select 1 from parameters where code = 'PRM-099');

insert into parameters (id, code, pack_id, value, param_type_id)
select 100, 'PRM-100', 20, '3', 5
where not exists (select 1 from parameters where code = 'PRM-100');

insert into parameters (id, code, pack_id, value, param_type_id)
select 101, 'PRM-101', 21, '299', 1
where not exists (select 1 from parameters where code = 'PRM-101');

insert into parameters (id, code, pack_id, value, param_type_id)
select 102, 'PRM-102', 21, '44.6', 2
where not exists (select 1 from parameters where code = 'PRM-102');

insert into parameters (id, code, pack_id, value, param_type_id)
select 103, 'PRM-103', 21, '884', 3
where not exists (select 1 from parameters where code = 'PRM-103');

insert into parameters (id, code, pack_id, value, param_type_id)
select 104, 'PRM-104', 21, '17', 4
where not exists (select 1 from parameters where code = 'PRM-104');

insert into parameters (id, code, pack_id, value, param_type_id)
select 105, 'PRM-105', 21, '87', 6
where not exists (select 1 from parameters where code = 'PRM-105');

insert into parameters (id, code, pack_id, value, param_type_id)
select 106, 'PRM-106', 22, '7', 1
where not exists (select 1 from parameters where code = 'PRM-106');

insert into parameters (id, code, pack_id, value, param_type_id)
select 107, 'PRM-107', 22, '-24.0', 2
where not exists (select 1 from parameters where code = 'PRM-107');

insert into parameters (id, code, pack_id, value, param_type_id)
select 108, 'PRM-108', 22, '580', 3
where not exists (select 1 from parameters where code = 'PRM-108');

insert into parameters (id, code, pack_id, value, param_type_id)
select 109, 'PRM-109', 22, '29', 4
where not exists (select 1 from parameters where code = 'PRM-109');

insert into parameters (id, code, pack_id, value, param_type_id)
select 110, 'PRM-110', 22, '0', 5
where not exists (select 1 from parameters where code = 'PRM-110');

insert into parameters (id, code, pack_id, value, param_type_id)
select 111, 'PRM-111', 23, '319', 1
where not exists (select 1 from parameters where code = 'PRM-111');

insert into parameters (id, code, pack_id, value, param_type_id)
select 112, 'PRM-112', 23, '43.6', 2
where not exists (select 1 from parameters where code = 'PRM-112');

insert into parameters (id, code, pack_id, value, param_type_id)
select 113, 'PRM-113', 23, '634', 3
where not exists (select 1 from parameters where code = 'PRM-113');

insert into parameters (id, code, pack_id, value, param_type_id)
select 114, 'PRM-114', 23, '32', 4
where not exists (select 1 from parameters where code = 'PRM-114');

insert into parameters (id, code, pack_id, value, param_type_id)
select 115, 'PRM-115', 23, '45', 6
where not exists (select 1 from parameters where code = 'PRM-115');