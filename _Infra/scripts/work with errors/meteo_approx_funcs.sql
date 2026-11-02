-- Функции расчёта метео приближенный: ДДЧЧМ, ВВВВ, БББТТ.
do $do$
begin

    -- ДДЧЧМ: день, часы и десятки минут измерения.
    create or replace function public.calc_ddchchm(par_time timestamp)
    returns text
    language plpgsql
    as $func1$
    begin
        return lpad(extract(day from par_time)::int::text, 2, '0')
            || lpad(extract(hour from par_time)::int::text, 2, '0')
            || floor(extract(minute from par_time) / 10)::int::text;
    end;
    $func1$;

    comment on function public.calc_ddchchm(timestamp) is
        'ДДЧЧМ: день, часы и десятки минут измерения';

    -- ВВВВ: высота метеопоста относительно уровня моря, 4 знака.
    create or replace function public.calc_vvvv(par_height numeric)
    returns text
    language plpgsql
    as $func2$
    declare
        var_neg_prefix numeric;
    begin
        if par_height >= 0 then
            return lpad(par_height::int::text, 4, '0');
        else
            select value into var_neg_prefix
            from public.pl_meteo_constants
            where code = 'NEGATIVE_PREFIX';
            return var_neg_prefix::text || lpad(abs(par_height)::int::text, 3, '0');
        end if;
    end;
    $func2$;

    comment on function public.calc_vvvv(numeric) is
        'ВВВВ: высота метеопоста относительно уровня моря';

    -- БББ: отклонение наземного давления от табличного, 3 знака.
    create or replace function public.calc_bbb(par_pressure numeric)
    returns text
    language plpgsql
    as $func3$
    declare
        var_table_pressure numeric;
        var_neg_prefix     numeric;
        var_diff           numeric;
    begin
        select value into var_table_pressure
        from public.pl_meteo_constants
        where code = 'TABLE_PRESSURE';

        select value into var_neg_prefix
        from public.pl_meteo_constants
        where code = 'NEGATIVE_PREFIX';

        var_diff := par_pressure - var_table_pressure;

        if var_diff >= 0 then
            return lpad(var_diff::int::text, 3, '0');
        else
            return var_neg_prefix::text || lpad(abs(var_diff)::int::text, 2, '0');
        end if;
    end;
    $func3$;

    comment on function public.calc_bbb(numeric) is
        'БББ: отклонение наземного давления от табличного';

    -- ТТ: отклонение приземной виртуальной температуры от табличной, 2 знака.
    create or replace function public.calc_tt(par_temperature numeric)
    returns text
    language plpgsql
    as $func4$
    declare
        var_table_temp numeric;
        var_neg_prefix numeric;
        var_delta_tv   numeric;
        var_t0         numeric;
        var_delta_t    numeric;
    begin
        select value into var_table_temp
        from public.pl_meteo_constants
        where code = 'TABLE_TEMPERATURE';

        select value into var_neg_prefix
        from public.pl_meteo_constants
        where code = 'NEGATIVE_PREFIX';

        var_delta_tv := public.interpolate_linear(
            par_temperature,
            public.get_temp_interpolation_params(par_temperature)
        );

        var_t0      := par_temperature + var_delta_tv;
        var_delta_t := round(var_t0 - var_table_temp);

        if var_delta_t >= 0 then
            return lpad(var_delta_t::int::text, 2, '0');
        else
            return var_neg_prefix::text || lpad(abs(var_delta_t)::int::text, 1, '0');
        end if;
    end;
    $func4$;

    comment on function public.calc_tt(numeric) is
        'ТТ: отклонение приземной виртуальной температуры от табличной';

    -- БББТТ: сборка двух блоков заголовка метеобюллетеня.
    create or replace function public.get_bbbtt(par_pressure numeric, par_temperature numeric)
    returns text
    language plpgsql
    as $func5$
    begin
        return public.calc_bbb(par_pressure) || public.calc_tt(par_temperature);
    end;
    $func5$;

    comment on function public.get_bbbtt(numeric, numeric) is
        'БББТТ: отклонение давления и температуры одной строкой';

end $do$;