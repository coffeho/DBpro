-- Вспомогательный тип для входных параметров
drop type if exists pl_input_params cascade;
create type pl_input_params as (
    surface_temp        numeric,
    surface_pressure    numeric,
    surface_wind_speed  numeric,
    surface_wind_dir    numeric
);

-- Хранимая процедура
create or replace procedure pl_calculate_meteo(
    p_input     pl_input_params,
    p_device_id integer
)
language plpgsql
as $proc$
declare
    v_height        record;
    v_temp_dev      record;
    v_wind          record;
    v_result_temp   numeric;
    v_result_angle  numeric;
begin
    for v_height in select * from ref_heights order by height_value loop
        
        -- Расчет температурного отклонения
        select * into v_temp_dev
        from temp_deviations
        where height_id = v_height.id
        order by abs(temp_deviation - (p_input.surface_temp - 15.9))
        limit 1;

        if found then
            if (p_input.surface_temp - 15.9) < 0 then
                v_result_temp := v_temp_dev.val_neg;
            else
                v_result_temp := v_temp_dev.val_pos;
            end if;
        else
            v_result_temp := null;
        end if;

        -- Расчет ветровых параметров
        -- Входное значение зависит от прибора
        if p_device_id = 1 then
            select * into v_wind
            from wind_speed
            where height_id = v_height.id
              and device_id = 1
              and input_value = p_input.surface_wind_speed
            limit 1;
        else
            select * into v_wind
            from wind_speed
            where height_id = v_height.id
              and device_id = 2
              and input_value = p_input.surface_wind_speed
            limit 1;
        end if;

        if found then
            v_result_angle := v_wind.angle_increment;
        else
            v_result_angle := null;
        end if;

        raise notice 'Высота: % м | Откл. темп.: % | Приращ. угла: %',
            v_height.height_value, v_result_temp, v_result_angle;
            
    end loop;
end;
$proc$;