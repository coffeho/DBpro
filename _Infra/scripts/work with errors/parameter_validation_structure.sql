-- Структуры для проверки корректности параметров метеобюллетеня.
do $do$
begin

    -- 1. Справочник ошибок
    execute $sql$ create sequence if not exists seq_pl_parameter_errors $sql$;

    execute $sql$
        create table if not exists pl_parameter_errors (
            id          integer primary key default nextval('seq_pl_parameter_errors'),
            code        varchar(40) not null unique,
            description text not null
        )
    $sql$;
    execute $sql$ alter sequence seq_pl_parameter_errors owned by pl_parameter_errors.id $sql$;

    comment on table pl_parameter_errors is
        'Справочник ошибок валидации параметров метеобюллетеня';

    -- 2. Допустимые диапазоны значений
    execute $sql$
        create table if not exists pl_parameter_limits (
            param_type_code varchar(30) primary key,
            min_value       numeric not null,
            max_value       numeric not null
        )
    $sql$;

    comment on table pl_parameter_limits is
        'Допустимые диапазоны значений параметров';

    -- 3. Новый тип данных — комплект параметров одной пачки
    execute $sql$ drop type if exists parameter_set cascade $sql$;

    execute $sql$
        create type parameter_set as (
            height         numeric,
            temperature    numeric,
            pressure       numeric,
            wind_direction numeric,
            wind_speed     numeric,
            bullet_drift   numeric,
            equipment_code varchar(30)
        )
    $sql$;

    comment on type parameter_set is
        'Комплект параметров одной пачки для проверки корректности';

    -- 4. Функция проверки
    execute $sql$
        create or replace function public.validate_parameters(par_set parameter_set)
        returns text
        language plpgsql
        as $func$
        declare
            var_errors text := '';
            var_min    numeric;
            var_max    numeric;
            var_text   text;
        begin
            -- Обязательные поля
            if par_set.height is null
               or par_set.temperature is null
               or par_set.pressure is null
               or par_set.wind_direction is null
               or par_set.equipment_code is null then
                select description into var_text
                from public.pl_parameter_errors
                where code = 'NULL_VALUE';
                var_errors := var_errors || var_text || '; ';
            end if;

            -- Диапазон температуры
            select min_value, max_value into var_min, var_max
            from public.pl_parameter_limits
            where param_type_code = 'TEMPERATURE';

            if par_set.temperature is not null
               and (par_set.temperature < var_min or par_set.temperature > var_max) then
                select description into var_text
                from public.pl_parameter_errors
                where code = 'TEMPERATURE_RANGE';
                var_errors := var_errors || var_text || ' (' || var_min || '..' || var_max || '); ';
            end if;

            -- Диапазон давления
            select min_value, max_value into var_min, var_max
            from public.pl_parameter_limits
            where param_type_code = 'PRESSURE';

            if par_set.pressure is not null
               and (par_set.pressure < var_min or par_set.pressure > var_max) then
                select description into var_text
                from public.pl_parameter_errors
                where code = 'PRESSURE_RANGE';
                var_errors := var_errors || var_text || ' (' || var_min || '..' || var_max || '); ';
            end if;

            -- Диапазон направления ветра
            select min_value, max_value into var_min, var_max
            from public.pl_parameter_limits
            where param_type_code = 'WIND_DIRECTION';

            if par_set.wind_direction is not null
               and (par_set.wind_direction < var_min or par_set.wind_direction > var_max) then
                select description into var_text
                from public.pl_parameter_errors
                where code = 'WIND_DIRECTION_RANGE';
                var_errors := var_errors || var_text || ' (' || var_min || '..' || var_max || '); ';
            end if;

            -- Логика по типу оборудования
            if par_set.equipment_code = 'EQP-DMK' then
                if par_set.wind_speed is null then
                    select description into var_text
                    from public.pl_parameter_errors
                    where code = 'WIND_SPEED_MISSING';
                    var_errors := var_errors || var_text || '; ';
                else
                    select min_value, max_value into var_min, var_max
                    from public.pl_parameter_limits
                    where param_type_code = 'WIND_SPEED';

                    if par_set.wind_speed < var_min or par_set.wind_speed > var_max then
                        select description into var_text
                        from public.pl_parameter_errors
                        where code = 'WIND_SPEED_RANGE';
                        var_errors := var_errors || var_text || ' (' || var_min || '..' || var_max || '); ';
                    end if;
                end if;

                if par_set.bullet_drift is not null then
                    select description into var_text
                    from public.pl_parameter_errors
                    where code = 'BULLET_NOT_EXPECTED';
                    var_errors := var_errors || var_text || '; ';
                end if;

            elsif par_set.equipment_code = 'EQP-VR' then
                if par_set.bullet_drift is null then
                    select description into var_text
                    from public.pl_parameter_errors
                    where code = 'BULLET_MISSING';
                    var_errors := var_errors || var_text || '; ';
                else
                    select min_value, max_value into var_min, var_max
                    from public.pl_parameter_limits
                    where param_type_code = 'BULLET_DRIFT';

                    if par_set.bullet_drift < var_min or par_set.bullet_drift > var_max then
                        select description into var_text
                        from public.pl_parameter_errors
                        where code = 'BULLET_RANGE';
                        var_errors := var_errors || var_text || ' (' || var_min || '..' || var_max || '); ';
                    end if;
                end if;

                if par_set.wind_speed is not null then
                    select description into var_text
                    from public.pl_parameter_errors
                    where code = 'WIND_SPEED_NOT_EXPECTED';
                    var_errors := var_errors || var_text || '; ';
                end if;

            else
                select description into var_text
                from public.pl_parameter_errors
                where code = 'BAD_EQUIPMENT';
                var_errors := var_errors || var_text || '; ';
            end if;

            if var_errors = '' then
                return null;
            else
                return rtrim(var_errors, '; ');
            end if;
        end;
        $func$;
    $sql$;

    comment on function public.validate_parameters(parameter_set) is
        'Проверяет комплект параметров пачки, возвращает список найденных ошибок или null';

end $do$;


-- Наполнение справочников
insert into pl_parameter_errors (code, description)
select v.code, v.description
from (values 
    ('NULL_VALUE',              'Отсутствует обязательное значение параметра'),
    ('TEMPERATURE_RANGE',       'Температура вне допустимого диапазона'),
    ('PRESSURE_RANGE',          'Давление вне допустимого диапазона'),
    ('WIND_DIRECTION_RANGE',    'Направление ветра вне допустимого диапазона'),
    ('WIND_SPEED_RANGE',        'Скорость ветра вне допустимого диапазона'),
    ('BULLET_RANGE',            'Дальность сноса пуль вне допустимого диапазона'),
    ('BAD_EQUIPMENT',           'Неизвестный тип оборудования'),
    ('WIND_SPEED_MISSING',      'Не указана скорость ветра для ДМК'),
    ('BULLET_NOT_EXPECTED',     'Дальность сноса пуль не должна заполняться для ДМК'),
    ('BULLET_MISSING',          'Не указана дальность сноса пуль для ВР'),
    ('WIND_SPEED_NOT_EXPECTED', 'Скорость ветра не должна заполняться для ВР')
) as v(code, description)
where not exists (select 1 from pl_parameter_errors where pl_parameter_errors.code = v.code);


insert into pl_parameter_limits (param_type_code, min_value, max_value)
select v.param_type_code, v.min_value, v.max_value
from (values 
    ('TEMPERATURE',    -58::numeric, 58::numeric),
    ('PRESSURE',        500::numeric, 900::numeric),
    ('WIND_DIRECTION',  0::numeric,   59::numeric),
    ('WIND_SPEED',      0::numeric,   15::numeric),
    ('BULLET_DRIFT',    0::numeric,   150::numeric)
) as v(param_type_code, min_value, max_value)
where not exists (select 1 from pl_parameter_limits where pl_parameter_limits.param_type_code = v.param_type_code);