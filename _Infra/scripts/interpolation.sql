do $$
begin
    if not exists (select 1 from pg_type where typname = 'interp_points') then
        execute $ddl$
            create type interp_points as (
                x0 numeric,
                y0 numeric,
                x1 numeric,
                y1 numeric
            )
        $ddl$;
    end if;

    -- Функция определения параметров интерполяции по температуре
    -- находит в pl_temp_corrections две ближайшие узловые точки
    execute $ddl$
        create or replace function get_temp_interpolation_params(p_temperature numeric)
        returns interp_points
        language plpgsql
        as $func$
        declare
            v_lower pl_temp_corrections%rowtype;
            v_upper pl_temp_corrections%rowtype;
            v_result interp_points;
        begin
            select * into v_lower
            from pl_temp_corrections
            where temp_to <= p_temperature
            order by temp_to desc
            limit 1;

            select * into v_upper
            from pl_temp_corrections
            where temp_to >= p_temperature
            order by temp_to asc
            limit 1;

            if v_lower.id is null then
                v_lower := v_upper;
            end if;
            if v_upper.id is null then
                v_upper := v_lower;
            end if;

            v_result.x0 := v_lower.temp_to;
            v_result.y0 := v_lower.correction;
            v_result.x1 := v_upper.temp_to;
            v_result.y1 := v_upper.correction;

            return v_result;
        end;
        $func$
    $ddl$;

    -- Функция расчёта линейной интерполяции:
    execute $ddl$
        create or replace function interpolate_linear(p_x numeric, p_points interp_points)
        returns numeric
        language plpgsql
        as $func$
        begin
            if p_points.x1 = p_points.x0 then
                return p_points.y0;
            end if;

            return p_points.y0
                 + (p_x - p_points.x0) * (p_points.y1 - p_points.y0)
                 / (p_points.x1 - p_points.x0);
        end;
        $func$
    $ddl$;
end $$;