-- Запрос "Список параметров с ошибками".
with pack_values as (
    select
        pk.id                as pack_id,
        pk.code              as pack_code,
        et.code              as equipment_code,
        et.name              as equipment_name,
        max(case when pt.code = 'HEIGHT'         then pr.value::numeric end) as height,
        max(case when pt.code = 'TEMPERATURE'    then pr.value::numeric end) as temperature,
        max(case when pt.code = 'PRESSURE'       then pr.value::numeric end) as pressure,
        max(case when pt.code = 'WIND_DIRECTION' then pr.value::numeric end) as wind_direction,
        max(case when pt.code = 'WIND_SPEED'     then pr.value::numeric end) as wind_speed,
        max(case when pt.code = 'BULLET_DRIFT'   then pr.value::numeric end) as bullet_drift
    from pl_packs pk
    join pl_equipment_types et on et.id = pk.equipment_type_id
    left join pl_parameters pr on pr.pack_id = pk.id
    left join pl_param_types pt on pt.id = pr.param_type_id
    group by pk.id, pk.code, et.code, et.name
),
validated as (
    select
        pack_id,
        pack_code,
        equipment_name,
        height,
        temperature,
        pressure,
        wind_direction,
        wind_speed,
        bullet_drift,
        public.validate_parameters(
            row(height, temperature, pressure, wind_direction, wind_speed, bullet_drift, equipment_code)::parameter_set
        ) as error_text
    from pack_values
)

select
    pack_code                                               as "№",
    equipment_name                                          as "Тип оборудования",
    height                                                  as "Высота метеопоста",
    temperature                                             as "Температура",
    pressure                                                as "Давление",
    wind_direction                                          as "Направление ветра",
    wind_speed                                              as "Скорость ветра",
    bullet_drift                                            as "Дальность сноса пуль",
    case when error_text is not null then 'Да' else 'Нет' end as "Флаг: Есть ошибка",
    coalesce(error_text, '')                                as "Описание ошибки"
from validated
order by "№";