-- Проверочный скрипт: тесты расчёта интерполяции.
-- Результаты выводятся через RAISE NOTICE во вкладку Messages.

do $$
declare
    v_points   interp_points;
    v_result   numeric;
    v_expected numeric;
begin
    -- Пример 1 из ТЗ: t0 = 23 (интерполяция между узлами 20 и 25
    v_points   := get_temp_interpolation_params(23);
    v_result   := round(interpolate_linear(23, v_points), 1);
    v_expected := 1.8;
    raise notice 'Пример 1 из ТЗ, t=23: точки (%,%)-(%,%), результат = %, ожидалось % -> %',
        v_points.x0, v_points.y0, v_points.x1, v_points.y1,
        v_result, v_expected,
        case when v_result = v_expected then 'сошлось' else 'не сошлось' end;

    -- Полная цепочка из примера 1: T0 = t0 + дельта, далее T0мп = T0 - 15,9 (ожидается округление до 9)
    raise notice 'Пример 1, полный расчёт: T0 = %, T0мп = % (ожидается округление до 9)',
        23 + v_result, round(23 + v_result - 15.9, 1);

    -- Попадание точно в узел таблицы: t = 20
    v_points   := get_temp_interpolation_params(20);
    v_result   := round(interpolate_linear(20, v_points), 1);
    v_expected := 1.5;
    raise notice 't=20 (узел таблицы): результат = %, ожидалось % -> %',
        v_result, v_expected, case when v_result = v_expected then 'сошлось' else 'не сошлось' end;

    -- Ниже нижней границы таблицы: t = -10
    v_points   := get_temp_interpolation_params(-10);
    v_result   := round(interpolate_linear(-10, v_points), 1);
    v_expected := 0.0;
    raise notice 't=-10 (ниже таблицы): результат = %, ожидалось % -> %',
        v_result, v_expected, case when v_result = v_expected then 'сошлось' else 'не сошлось' end;

    -- Выше верхней границы таблицы: t = 50
    v_points   := get_temp_interpolation_params(50);
    v_result   := round(interpolate_linear(50, v_points), 1);
    v_expected := 4.5;
    raise notice 't=50 (выше таблицы): результат = %, ожидалось % -> %',
        v_result, v_expected, case when v_result = v_expected then 'сошлось' else 'не сошлось' end;

    -- Промежуточная интерполяция между узлами 5 и 15
    v_points   := get_temp_interpolation_params(12);
    v_result   := round(interpolate_linear(12, v_points), 1);
    v_expected := 0.9;
    raise notice 't=12: точки (%,%)-(%,%), результат = %, ожидалось % -> %',
        v_points.x0, v_points.y0, v_points.x1, v_points.y1,
        v_result, v_expected,
        case when v_result = v_expected then 'сошлось' else 'не сошлось' end;
end $$;