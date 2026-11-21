do $$
begin
    -- Свои организации
    drop table if exists dim_comps;
    drop sequence if exists seq_dim_comps;

    create sequence seq_dim_comps;

    create table dim_comps (
        id integer primary key default nextval('seq_dim_comps'),
        ext_id integer not null,
        name varchar(150) not null,
        inn varchar(20),
        kpp varchar(20)
    );

    -- Единицы измерения
    drop table if exists dim_ranges;
    drop sequence if exists seq_dim_ranges;

    create sequence seq_dim_ranges;

    create table dim_ranges (
        id integer primary key default nextval('seq_dim_ranges'),
        ext_id integer not null,
        name varchar(100) not null,
        factor numeric(18,3)
    );

    -- Категории
    drop table if exists dim_categs;
    drop sequence if exists seq_dim_categs;

    create sequence seq_dim_categs;

    create table dim_categs (
        id integer primary key default nextval('seq_dim_categs'),
        ext_id integer not null,
        name varchar(150) not null
    );

    -- Поставщики
    drop table if exists dim_vendors;
    drop sequence if exists seq_dim_vendors;

    create sequence seq_dim_vendors;

    create table dim_vendors (
        id integer primary key default nextval('seq_dim_vendors'),
        ext_id integer not null,
        code varchar(30),
        name varchar(150) not null
    );

    -- Продукты
    drop table if exists dim_products;
    drop sequence if exists seq_dim_products;

    create sequence seq_dim_products;

    create table dim_products (
        id integer primary key default nextval('seq_dim_products'),
        ext_id integer not null,
        article varchar(50),
        name varchar(150) not null,
        prod_type varchar(30),
        flag smallint
    );

    -- Сотрудники
    drop table if exists dim_persons;
    drop sequence if exists seq_dim_persons;

    create sequence seq_dim_persons;

    create table dim_persons (
        id integer primary key default nextval('seq_dim_persons'),
        ext_id integer not null,
        lastname varchar(100),
        firstname varchar(100),
        midname varchar(100)
    );

    -- Роли
    drop table if exists dim_roles;
    drop sequence if exists seq_dim_roles;

    create sequence seq_dim_roles;

    create table dim_roles (
        id integer primary key default nextval('seq_dim_roles'),
        ext_id integer not null,
        name varchar(100) not null
    );

    -- Склады
    drop table if exists dim_storages;
    drop sequence if exists seq_dim_storages;

    create sequence seq_dim_storages;

    create table dim_storages (
        id integer primary key default nextval('seq_dim_storages'),
        ext_id integer not null,
        name varchar(150) not null
    );

    -- Типы оплаты
    drop table if exists dim_pay_types;
    drop sequence if exists seq_dim_pay_types;

    create sequence seq_dim_pay_types;

    create table dim_pay_types (
        id integer primary key default nextval('seq_dim_pay_types'),
        ext_id integer not null,
        name varchar(100) not null,
        currency varchar(20)
    );

    -- Виды складских операций
    drop table if exists dim_op_types;
    drop sequence if exists seq_dim_op_types;

    create sequence seq_dim_op_types;

    create table dim_op_types (
        id integer primary key default nextval('seq_dim_op_types'),
        ext_id integer not null,
        name varchar(100) not null,
        factor numeric(10,3)
    );

    -- Клиенты
    drop table if exists dim_clients;
    drop sequence if exists seq_dim_clients;

    create sequence seq_dim_clients;

    create table dim_clients (
        id integer primary key default nextval('seq_dim_clients'),
        ext_id integer not null,
        code varchar(30),
        name varchar(150) not null,
        discount numeric(10,2),
        bonus numeric(18,2)
    );

    -- Причины списания
    drop table if exists dim_reasons;
    drop sequence if exists seq_dim_reasons;

    create sequence seq_dim_reasons;

    create table dim_reasons (
        id integer primary key default nextval('seq_dim_reasons'),
        ext_id integer not null,
        name varchar(150) not null
    );

    -- Типы транзакций
    drop table if exists dim_trans_types;
    drop sequence if exists seq_dim_trans_types;

    create sequence seq_dim_trans_types;

    create table dim_trans_types (
        id integer primary key default nextval('seq_dim_trans_types'),
        ext_id integer not null,
        name varchar(100) not null,
        prev_group varchar(30)
    );
end $$;
