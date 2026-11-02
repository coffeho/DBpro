-- Намеренно портит несколько значений в уже посеянных данных
-- для проверки работоспособности запросов и функций.

-- Температура вне диапазона (-58..58) у первой пачки на ДМК
update pl_parameters
set value = '99'
where pack_id = (
    select pk.id
    from pl_packs pk
    join pl_equipment_types et on et.id = pk.equipment_type_id
    where et.code = 'EQP-DMK'
    order by pk.code
    limit 1
)
and param_type_id = (select id from pl_param_types where code = 'TEMPERATURE');

-- Отсутствует скорость ветра у второй пачки на ДМК (поле обязательно для ДМК)
delete from pl_parameters
where pack_id = (
    select pk.id
    from pl_packs pk
    join pl_equipment_types et on et.id = pk.equipment_type_id
    where et.code = 'EQP-DMK'
    order by pk.code
    offset 1 limit 1
)
and param_type_id = (select id from pl_param_types where code = 'WIND_SPEED');

-- Дальность сноса пуль вне диапазона (0..150) у первой пачки на ВР
update pl_parameters
set value = '999'
where pack_id = (
    select pk.id
    from pl_packs pk
    join pl_equipment_types et on et.id = pk.equipment_type_id
    where et.code = 'EQP-VR'
    order by pk.code
    limit 1
)
and param_type_id = (select id from pl_param_types where code = 'BULLET_DRIFT');

-- Лишняя скорость ветра у второй пачки на ВР (поле не должно заполняться для ВР)
insert into pl_parameters (code, pack_id, value, param_type_id)
select
    'PL-PRM-ERR-001',
    pk.id,
    '5',
    (select id from pl_param_types where code = 'WIND_SPEED')
from pl_packs pk
join pl_equipment_types et on et.id = pk.equipment_type_id
where et.code = 'EQP-VR'
order by pk.code
offset 1 limit 1;