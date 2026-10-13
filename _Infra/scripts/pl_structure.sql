--Структура таблиц и счётчики

begin;

do $$
begin
    execute $sql$ create sequence if not exists seq_pl_positions $sql$;
    execute $sql$ create sequence if not exists seq_pl_equipment_types $sql$;
    execute $sql$ create sequence if not exists seq_pl_users $sql$;
    execute $sql$ create sequence if not exists seq_pl_packs $sql$;
    execute $sql$ create sequence if not exists seq_pl_base_units $sql$;
    execute $sql$ create sequence if not exists seq_pl_units $sql$;
    execute $sql$ create sequence if not exists seq_pl_param_types $sql$;
    execute $sql$ create sequence if not exists seq_pl_parameters $sql$;
    execute $sql$ create sequence if not exists seq_pl_temp_corrections $sql$;

    execute $sql$
        create table if not exists pl_positions (
            id integer primary key default nextval('seq_pl_positions'),
            code varchar(30) not null unique,
            name varchar(100) not null
        )
    $sql$;

    execute $sql$
        create table if not exists pl_equipment_types (
            id integer primary key default nextval('seq_pl_equipment_types'),
            code varchar(30) not null unique,
            name varchar(100) not null
        )
    $sql$;

    execute $sql$
        create table if not exists pl_users (
            id integer primary key default nextval('seq_pl_users'),
            code varchar(30) not null unique,
            name varchar(150) not null,
            position_id integer not null
        )
    $sql$;

    execute $sql$
        create table if not exists pl_packs (
            id integer primary key default nextval('seq_pl_packs'),
            code varchar(30) not null unique,
            user_id integer not null,
            equipment_type_id integer not null,
            measured_at timestamp not null
        )
    $sql$;

    execute $sql$
        create table if not exists pl_base_units (
            id integer primary key default nextval('seq_pl_base_units'),
            code varchar(30) not null unique,
            name varchar(100) not null
        )
    $sql$;

    execute $sql$
        create table if not exists pl_units (
            id integer primary key default nextval('seq_pl_units'),
            code varchar(30) not null unique,
            name varchar(50) not null,
            base_unit_id integer not null
        )
    $sql$;

    execute $sql$
        create table if not exists pl_param_types (
            id integer primary key default nextval('seq_pl_param_types'),
            code varchar(30) not null unique,
            name varchar(100) not null,
            unit_id integer not null
        )
    $sql$;

    execute $sql$
        create table if not exists pl_parameters (
            id integer primary key default nextval('seq_pl_parameters'),
            code varchar(30) not null unique,
            pack_id integer not null,
            value varchar(10) not null,
            param_type_id integer not null
        )
    $sql$;

    execute $sql$
        create table if not exists pl_temp_corrections (
            id integer primary key default nextval('seq_pl_temp_corrections'),
            code varchar(30) not null unique,
            range_label varchar(20) not null,
            temp_from numeric(5,1),
            temp_to numeric(5,1),
            correction numeric(3,1) not null
        )
    $sql$;

    execute $sql$ alter sequence seq_pl_positions owned by pl_positions.id $sql$;
    execute $sql$ alter sequence seq_pl_equipment_types owned by pl_equipment_types.id $sql$;
    execute $sql$ alter sequence seq_pl_users owned by pl_users.id $sql$;
    execute $sql$ alter sequence seq_pl_packs owned by pl_packs.id $sql$;
    execute $sql$ alter sequence seq_pl_base_units owned by pl_base_units.id $sql$;
    execute $sql$ alter sequence seq_pl_units owned by pl_units.id $sql$;
    execute $sql$ alter sequence seq_pl_param_types owned by pl_param_types.id $sql$;
    execute $sql$ alter sequence seq_pl_parameters owned by pl_parameters.id $sql$;
    execute $sql$ alter sequence seq_pl_temp_corrections owned by pl_temp_corrections.id $sql$;
end $$;

commit;


-- Тестовые данные

begin;

do $$
declare
    v_user_ids   integer[];
    v_user_id    integer;
    v_equip_id   integer;
    v_pack_id    integer;
    v_pack_code  varchar(30);
    v_height     integer;
    v_temp       numeric(4,1);
    v_pressure   integer;
    v_wind_dir   integer;
    v_wind_speed integer;
    v_bullet     integer;
    i            integer;
begin
    -- Справочники (выполняются как обычные SQL-команды внутри PL/pgSQL-блока)

    insert into pl_positions (code, name)
    select 'POS-001', 'Начальник метеопоста'
    where not exists (select 1 from pl_positions where code = 'POS-001');

    insert into pl_positions (code, name)
    select 'POS-002', 'Метеоролог-наблюдатель'
    where not exists (select 1 from pl_positions where code = 'POS-002');

    insert into pl_positions (code, name)
    select 'POS-003', 'Расчетчик'
    where not exists (select 1 from pl_positions where code = 'POS-003');

    insert into pl_equipment_types (code, name)
    select 'EQP-DMK', 'ДМК'
    where not exists (select 1 from pl_equipment_types where code = 'EQP-DMK');

    insert into pl_equipment_types (code, name)
    select 'EQP-VR', 'ВР'
    where not exists (select 1 from pl_equipment_types where code = 'EQP-VR');

    insert into pl_base_units (code, name)
    select v.code, v.name
    from (values ('LENGTH','Длина'),('TEMPERATURE','Температура'),('PRESSURE','Давление'),
                 ('ANGLE','Угол'),('SPEED','Скорость')) as v(code, name)
    where not exists (select 1 from pl_base_units where pl_base_units.code = v.code);

    insert into pl_units (code, name, base_unit_id)
    select v.code, v.name, (select id from pl_base_units where code = v.base_code)
    from (values ('M','метр','LENGTH'),
                 ('C','градус Цельсия','TEMPERATURE'),
                 ('MMHG','мм рт. ст.','PRESSURE'),
                 ('MIL','деление угломера','ANGLE'),
                 ('MPS','метр в секунду','SPEED')) as v(code, name, base_code)
    where not exists (select 1 from pl_units where pl_units.code = v.code);

    insert into pl_param_types (code, name, unit_id)
    select v.code, v.name, (select id from pl_units where code = v.unit_code)
    from (values ('HEIGHT','Высота метеопоста','M'),
                 ('TEMPERATURE','Температура','C'),
                 ('PRESSURE','Давление','MMHG'),
                 ('WIND_DIRECTION','Направление ветра','MIL'),
                 ('WIND_SPEED','Скорость ветра','MPS'),
                 ('BULLET_DRIFT','Дальность сноса пуль','M')) as v(code, name, unit_code)
    where not exists (select 1 from pl_param_types where pl_param_types.code = v.code);

    insert into pl_temp_corrections (code, range_label, temp_from, temp_to, correction)
    select v.code, v.range_label, v.temp_from, v.temp_to, v.correction
    from (values
        ('TV-01', 'Ниже 0', null,  0,    0.0),
        ('TV-02', '0-5',    0,     5,    0.5),
        ('TV-03', '10-15',  10,    15,   1.0),
        ('TV-04', '20',     20,    20,   1.5),
        ('TV-05', '25',     25,    25,   2.0),
        ('TV-06', '30',     30,    30,   3.5),
        ('TV-07', '40',     40,    40,   4.5)
    ) as v(code, range_label, temp_from, temp_to, correction)
    where not exists (select 1 from pl_temp_corrections where pl_temp_corrections.code = v.code);

    -- Пользователи (минимум 3)
    insert into pl_users (code, name, position_id)
    select v.code, v.name, (select id from pl_positions where code = v.pos_code)
    from (values ('USR-001','Волков Егор','POS-001'),
                 ('USR-002','Морозова Анна','POS-002'),
                 ('USR-003','Зайцев Павел','POS-003')) as v(code, name, pos_code)
    where not exists (select 1 from pl_users where pl_users.code = v.code);

    -- Пачки и параметры (минимум 20 пачек, по 5 параметров)
    select array_agg(id) into v_user_ids from pl_users;

    for i in 1..20 loop
        v_pack_code := 'PL-PCK-' || lpad(i::text, 3, '0');

        -- если пачка уже есть (повторный запуск скрипта) - пропускаем
        continue when exists (select 1 from pl_packs where code = v_pack_code);

        v_user_id  := v_user_ids[1 + floor(random() * array_length(v_user_ids, 1))::int];
        v_equip_id := case when random() < 0.5
                           then (select id from pl_equipment_types where code = 'EQP-DMK')
                           else (select id from pl_equipment_types where code = 'EQP-VR')
                      end;

        insert into pl_packs (code, user_id, equipment_type_id, measured_at)
        values (v_pack_code, v_user_id, v_equip_id,
                timestamp '2026-10-01 08:00:00' + (i || ' hours')::interval)
        returning id into v_pack_id;

        v_height   := floor(random() * 450)::int - 50;
        v_temp     := round((random() * 116 - 58)::numeric, 1);
        v_pressure := 500 + floor(random() * 401)::int;
        v_wind_dir := floor(random() * 60)::int;

        insert into pl_parameters (code, pack_id, value, param_type_id)
        values ('PL-PRM-' || lpad((i * 10 + 1)::text, 4, '0'), v_pack_id, v_height::text,
                (select id from pl_param_types where code = 'HEIGHT'));

        insert into pl_parameters (code, pack_id, value, param_type_id)
        values ('PL-PRM-' || lpad((i * 10 + 2)::text, 4, '0'), v_pack_id, v_temp::text,
                (select id from pl_param_types where code = 'TEMPERATURE'));

        insert into pl_parameters (code, pack_id, value, param_type_id)
        values ('PL-PRM-' || lpad((i * 10 + 3)::text, 4, '0'), v_pack_id, v_pressure::text,
                (select id from pl_param_types where code = 'PRESSURE'));

        insert into pl_parameters (code, pack_id, value, param_type_id)
        values ('PL-PRM-' || lpad((i * 10 + 4)::text, 4, '0'), v_pack_id, lpad(v_wind_dir::text, 2, '0'),
                (select id from pl_param_types where code = 'WIND_DIRECTION'));

        if v_equip_id = (select id from pl_equipment_types where code = 'EQP-DMK') then
            v_wind_speed := floor(random() * 16)::int;
            insert into pl_parameters (code, pack_id, value, param_type_id)
            values ('PL-PRM-' || lpad((i * 10 + 5)::text, 4, '0'), v_pack_id, v_wind_speed::text,
                    (select id from pl_param_types where code = 'WIND_SPEED'));
        else
            v_bullet := floor(random() * 151)::int;
            insert into pl_parameters (code, pack_id, value, param_type_id)
            values ('PL-PRM-' || lpad((i * 10 + 5)::text, 4, '0'), v_pack_id, v_bullet::text,
                    (select id from pl_param_types where code = 'BULLET_DRIFT'));
        end if;
    end loop;
end $$;

commit;

-- Связи между таблицами и ограничения

begin;

-- alter table add constraint не поддерживает if not exists,
-- поэтому каждое ограничение добавляется через проверку по pg_constraint

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'fk_pl_users_position') then
        alter table pl_users
            add constraint fk_pl_users_position
            foreign key (position_id) references pl_positions (id);
    end if;

    if not exists (select 1 from pg_constraint where conname = 'fk_pl_packs_user') then
        alter table pl_packs
            add constraint fk_pl_packs_user
            foreign key (user_id) references pl_users (id);
    end if;

    if not exists (select 1 from pg_constraint where conname = 'fk_pl_packs_equipment') then
        alter table pl_packs
            add constraint fk_pl_packs_equipment
            foreign key (equipment_type_id) references pl_equipment_types (id);
    end if;

    if not exists (select 1 from pg_constraint where conname = 'fk_pl_units_base_unit') then
        alter table pl_units
            add constraint fk_pl_units_base_unit
            foreign key (base_unit_id) references pl_base_units (id);
    end if;

    if not exists (select 1 from pg_constraint where conname = 'fk_pl_param_types_unit') then
        alter table pl_param_types
            add constraint fk_pl_param_types_unit
            foreign key (unit_id) references pl_units (id);
    end if;

    if not exists (select 1 from pg_constraint where conname = 'fk_pl_parameters_pack') then
        alter table pl_parameters
            add constraint fk_pl_parameters_pack
            foreign key (pack_id) references pl_packs (id);
    end if;

    if not exists (select 1 from pg_constraint where conname = 'fk_pl_parameters_param_type') then
        alter table pl_parameters
            add constraint fk_pl_parameters_param_type
            foreign key (param_type_id) references pl_param_types (id);
    end if;

    if not exists (select 1 from pg_constraint where conname = 'chk_pl_temp_corrections_correction') then
        alter table pl_temp_corrections
            add constraint chk_pl_temp_corrections_correction
            check (correction >= 0);
    end if;
end $$;

commit;