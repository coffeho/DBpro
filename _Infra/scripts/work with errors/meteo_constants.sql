-- Константы для расчёта метео приближенный (ДДЧЧМ, ВВВВ, БББТТ).
do $do$
begin
    execute $sql$ create sequence if not exists seq_pl_meteo_constants $sql$;

    execute $sql$
        create table if not exists pl_meteo_constants (
            id          integer primary key default nextval('seq_pl_meteo_constants'),
            code        varchar(40) not null unique,
            value       numeric not null,
            description text
        )
    $sql$;

    execute $sql$ alter sequence seq_pl_meteo_constants owned by pl_meteo_constants.id $sql$;

    comment on table pl_meteo_constants is 'Константы для расчёта метео приближенный';
    comment on column pl_meteo_constants.code is 'Уникальный код константы';
    comment on column pl_meteo_constants.value is 'Значение константы';
    comment on column pl_meteo_constants.description is 'Описание константы';
end $do$;

insert into pl_meteo_constants (code, value, description)
select v.code, v.value, v.description
from (values 
    ('TABLE_PRESSURE',    750::numeric,  'Табличное наземное давление, мм рт. ст.'),
    ('TABLE_TEMPERATURE', 15.9::numeric, 'Табличная приземная виртуальная температура, °C'),
    ('NEGATIVE_PREFIX',   5::numeric,    'Цифра-признак отрицательного значения в БББ/ТТ/ВВВВ')
) as v(code, value, description)
where not exists (select 1 from pl_meteo_constants where pl_meteo_constants.code = v.code);