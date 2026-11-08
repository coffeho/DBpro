do $$
declare
    v_input pl_input_params;
begin
    -- заполняем тестовыми
    delete from temp_deviations;
    delete from wind_speed;

    -- Добавляем отклонения температуры для всех высот под тестовую температуру
    insert into temp_deviations (id, height_id, temp_deviation, val_neg, val_pos)
    values 
        (100, 1, 7.1, -1.0, 1.5),
        (101, 2, 7.1, -1.2, 1.8),
        (102, 3, 7.1, -1.5, 2.0),
        (103, 4, 7.1, -1.8, 2.5);

    -- Добавляем ветровые данные для всех высот под скорость ветра
    insert into wind_speed (height_id, device_id, input_value, wind_speed, angle_increment)
    values 
        (1, 1, 5.0, 10.0, 0.05),
        (2, 1, 5.0, 12.0, 0.10),
        (3, 1, 5.0, 14.0, 0.15),
        (4, 1, 5.0, 16.0, 0.20),
        (1, 2, 5.0, 10.0, 0.02),
        (2, 2, 5.0, 12.0, 0.04),
        (3, 2, 5.0, 14.0, 0.06),
        (4, 2, 5.0, 16.0, 0.08);

    -- входные параметры
    v_input.surface_temp       := 23.0;
    v_input.surface_pressure   := 750.0;
    v_input.surface_wind_speed := 5.0;
    v_input.surface_wind_dir   := 30.0;

    -- расчёт
    raise notice 'расчет для оборудования ДМК';
    call pl_calculate_meteo(v_input, 1);

    raise notice 'расчет для оборудования ВР';
    call pl_calculate_meteo(v_input, 2);
end $$;