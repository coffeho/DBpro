-- ресурс время
-- месяцы и недели

do $$
declare
    v_start date := date '2015-01-01';
    v_end   date := date '2027-12-31';
    v_date  date;
    v_week  date;
    v_m_code integer;
begin
    drop table if exists dim_time;

    create table dim_time
    (
        id integer primary key,
        code integer,
        m_start date,
        m_end date,
        m_name varchar(20),
        year integer,
        q_num integer,
        q_name varchar(20),
        hy_no integer,
        hy_name varchar(20)
    );

    -- Месяцы
    v_date := date_trunc('month', date_trunc('week', v_start)::date)::date;

    while v_date <= date_trunc('month', v_end)::date loop
        insert into dim_time (
            id, code, m_start, m_end, m_name,
            year, q_num, q_name,
            hy_no, hy_name
        )
        values (
            extract(year from v_date)::int * 100 + extract(month from v_date)::int,
            extract(year from v_date)::int * 100 + extract(month from v_date)::int,
            v_date,
            (v_date + interval '1 month - 1 day')::date,
            case extract(month from v_date)::int
                when 1  then 'Январь'
                when 2  then 'Февраль'
                when 3  then 'Март'
                when 4  then 'Апрель'
                when 5  then 'Май'
                when 6  then 'Июнь'
                when 7  then 'Июль'
                when 8  then 'Август'
                when 9  then 'Сентябрь'
                when 10 then 'Октябрь'
                when 11 then 'Ноябрь'
                when 12 then 'Декабрь'
            end,
            extract(year from v_date)::int,
            extract(quarter from v_date)::int,
            extract(quarter from v_date)::int || ' квартал',
            case when extract(quarter from v_date)::int <= 2 then 1 else 2 end,
            case when extract(quarter from v_date)::int <= 2 then '1 полугодие' else '2 полугодие' end
        );

        v_date := (v_date + interval '1 month')::date;
    end loop;

    drop table if exists dim_week;

    create table dim_week
    (
        id integer primary key,
        code integer,
        w_start date,
        w_end date,
        iso_w integer,
        iso_y integer,
        m_code integer,
        m_name varchar(20),
        q_num integer,
        year integer
    );

    -- Недели
    v_week := date_trunc('week', v_start)::date;

    while v_week <= v_end loop
        v_m_code := extract(year from v_week)::int * 100 + extract(month from v_week)::int;

        insert into dim_week (
            id, code, w_start, w_end,
            iso_w, iso_y, m_code,
            m_name, q_num, year
        )
        values (
            extract(isoyear from v_week)::int * 100 + extract(week from v_week)::int,
            extract(isoyear from v_week)::int * 100 + extract(week from v_week)::int,
            v_week,
            (v_week + interval '6 days')::date,
            extract(week from v_week)::int,
            extract(isoyear from v_week)::int,
            v_m_code,
            (select m_name from dim_time where code = v_m_code),
            (select q_num from dim_time where code = v_m_code),
            extract(year from v_week)::int
        );

        v_week := (v_week + interval '1 week')::date;
    end loop;
end $$;


-- Проверка

select
    (select count(*) from dim_time) as months,
    (select count(*) from dim_week) as weeks;

select code, m_start, m_end, m_name, year, q_num, q_name
from dim_time
order by code
limit 12;
