
-- 1. у всех ли пользователей одинаковое кол-во измерений
select users.code, users.name, count(packs.id)
from users
left join packs on packs.user_id = users.id
group by users.code, users.name
order by users.code;


-- 2. есть ли пачки без параметров (пустые) если запрос пустой - пустых пачек нет
select packs.code
from packs
left join parameters on parameters.pack_id = packs.id
where parameters.id is null;


-- 3. проверка что в каждой пачке ровно 5 параметров
select packs.code, count(*) as param_cnt
from packs, parameters
where parameters.pack_id = packs.id
group by packs.code
having count(*) <> 5;


-- 4. проверка диапазонов значений
select parameters.code, param_types.code, parameters.value
from parameters, param_types
where parameters.param_type_id = param_types.id
and (
  (param_types.code = 'TEMPERATURE' and cast(parameters.value as numeric) not between -58 and 58)
  or (param_types.code = 'PRESSURE' and cast(parameters.value as numeric) not between 500 and 900)
  or (param_types.code = 'WIND_DIRECTION' and cast(parameters.value as numeric) not between 0 and 59)
  or (param_types.code = 'WIND_SPEED' and cast(parameters.value as numeric) not between 0 and 15)
  or (param_types.code = 'BULLET_DRIFT' and cast(parameters.value as numeric) not between 0 and 150)
);


-- 5. проверка единиц измерения (у каждого параметра должна быть своя единица)
select param_types.code as param, units.code as unit
from param_types, units
where param_types.unit_id = units.id
and not (
     (param_types.code = 'HEIGHT' and units.code = 'M')
  or (param_types.code = 'TEMPERATURE' and units.code = 'C')
  or (param_types.code = 'PRESSURE' and units.code = 'MMHG')
  or (param_types.code = 'WIND_DIRECTION' and units.code = 'MIL')
  or (param_types.code = 'WIND_SPEED' and units.code = 'MPS')
  or (param_types.code = 'BULLET_DRIFT' and units.code = 'M')
);