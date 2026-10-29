-- Запрос "Лучший стрелок": список пользователей и количество
-- допущенных ошибок в параметрах по всем их пачкам.
-- rank() - оконная функция для места в рейтинге (меньше ошибок - выше место).

with pack_values as (
    select
        pk.id                as pack_id,
        pk.user_id,
        et.code              as equipment_code,
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
    group by pk.id, pk.user_id, et.code
),
pack_errors as (
    select
        user_id,
        public.validate_parameters(
            row(height, temperature, pressure, wind_direction, wind_speed, bullet_drift, equipment_code)::parameter_set
        ) as error_text
    from pack_values
),
user_stats as (
    select
        user_id,
        count(*) as packs_count,
        sum(
            case
                when error_text is null then 0
                -- число найденных ошибок = число "; " в строке + 1
                else (length(error_text) - length(replace(error_text, '; ', '')) + 1)
            end
        ) as errors_count
    from pack_errors
    group by user_id
)

select
    u.code                                      as "Личный номер",
    u.name                                      as "ФИО",
    st.packs_count                              as "Пачек всего",
    st.errors_count                             as "Количество ошибок",
    rank() over (order by st.errors_count asc)   as "Место"
from user_stats st
join pl_users u on u.id = st.user_id
order by "Место", u.code;