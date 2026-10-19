do $do$
begin

    drop type if exists interp_points cascade;

    create type interp_points as (
        x0 numeric, y0 numeric, x1 numeric, y1 numeric
    );

    create or replace function public.get_temp_interpolation_params(p_temperature numeric)
    returns public.interp_points
    language plpgsql
    as $func1$
    declare
        v_result public.interp_points;
    begin
        -- По ТЗ: температура ниже нуля, поправка 0
        if p_temperature < 0 then
            v_result.x0 := p_temperature;
            v_result.y0 := 0;
            v_result.x1 := p_temperature;
            v_result.y1 := 0;
            return v_result;
        end if;

        select temp_to, correction
        into v_result.x0, v_result.y0
        from public.pl_temp_corrections
        where temp_to <= p_temperature
        order by temp_to desc
        limit 1;

        select temp_to, correction
        into v_result.x1, v_result.y1
        from public.pl_temp_corrections
        where temp_to >= p_temperature
        order by temp_to asc
        limit 1;

        if v_result.x0 is null and v_result.x1 is null then
            raise exception 'Нет данных для интерполяции температуры';
        end if;

        -- Выше верхней границы таблицы
        if v_result.x1 is null then
            v_result.x1 := v_result.x0;
            v_result.y1 := v_result.y0;
        end if;

        return v_result;
    end;
    $func1$;

    create or replace function public.interpolate_linear(
        p_x numeric,
        p_points public.interp_points
    )
    returns numeric
    language plpgsql
    as $func2$
    begin
        if p_points.x1 = p_points.x0 then
            return p_points.y0;
        end if;

        return p_points.y0 + (p_x - p_points.x0)
             * (p_points.y1 - p_points.y0) / (p_points.x1 - p_points.x0);
    end;
    $func2$;

end $do$;