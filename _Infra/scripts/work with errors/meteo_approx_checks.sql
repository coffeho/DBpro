-- Проверка функций расчёта метео приближенный по примерам из ТЗ.
do $$
declare
    var_result   text;
    var_expected text;
begin
    -- 1: ДДЧЧМ = '24093'
    var_result   := public.calc_ddchchm(timestamp '2026-09-24 09:30:00');
    var_expected := '24093';
    raise notice 'ДДЧЧМ (24, 09:30): результат = %, ожидалось % -> %',
        var_result, var_expected,
        case when var_result = var_expected then 'сошлось' else 'не сошлось' end;

    -- 2: ВВВВ = '0100'
    var_result   := public.calc_vvvv(100);
    var_expected := '0100';
    raise notice 'ВВВВ (высота=100): результат = %, ожидалось % -> %',
        var_result, var_expected,
        case when var_result = var_expected then 'сошлось' else 'не сошлось' end;

    -- 3: БББ = '007'
    var_result   := public.calc_bbb(757);
    var_expected := '007';
    raise notice 'БББ (давление=757): результат = %, ожидалось % -> %',
        var_result, var_expected,
        case when var_result = var_expected then 'сошлось' else 'не сошлось' end;

    -- 4: БББ = '507'
    var_result   := public.calc_bbb(743);
    var_expected := '507';
    raise notice 'БББ (давление=743): результат = %, ожидалось % -> %',
        var_result, var_expected,
        case when var_result = var_expected then 'сошлось' else 'не сошлось' end;

    -- 5: ТТ = '09'
    var_result   := public.calc_tt(23);
    var_expected := '09';
    raise notice 'ТТ (температура=23): результат = %, ожидалось % -> %',
        var_result, var_expected,
        case when var_result = var_expected then 'сошлось' else 'не сошлось' end;

    -- 6: БББТТ = '01511'
    var_result   := public.get_bbbtt(765, 25);
    var_expected := '01511';
    raise notice 'БББТТ (давление=765, температура=25): результат = %, ожидалось % -> %',
        var_result, var_expected,
        case when var_result = var_expected then 'сошлось' else 'не сошлось' end;
end $$;