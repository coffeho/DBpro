-- выполнять в базе Front
-- скопировать колонку sql и выполнить в PostgreSQL

set nocount on;
go

-- Свои организации
select ID, CompanyName, INN, KPP
from dbo.bm_Companies;

select 'insert into dim_comps(ext_id, name, inn, kpp) values ('
    + cast(c.ID as varchar(20)) + ', '
    + coalesce('''' + replace(c.CompanyName, '''', '''''') + '''', 'null') + ', '
    + coalesce('''' + replace(c.INN, '''', '''''') + '''', 'null') + ', '
    + coalesce('''' + replace(c.KPP, '''', '''''') + '''', 'null') + ');'
    as sql
from dbo.bm_Companies as c;

-- Единицы измерения
select id, sizeid, portionrate
from dbo.[size];

select 'insert into dim_ranges(ext_id, name, factor) values ('
    + cast(s.id as varchar(20)) + ', '
    + coalesce('''' + replace(s.sizeid, '''', '''''') + '''', 'null') + ', '
    + coalesce(cast(s.portionrate as varchar(20)), 'null') + ');'
    as sql
from dbo.[size] as s;

-- Категории
select id, description
from dbo.category;

select 'insert into dim_categs(ext_id, name) values ('
    + cast(c.id as varchar(20)) + ', '
    + coalesce('''' + replace(c.description, '''', '''''') + '''', 'null') + ');'
    as sql
from dbo.category as c;

-- Поставщики
select id, clientid, firstname
from dbo.vendors;

select 'insert into dim_vendors(ext_id, code, name) values ('
    + cast(v.id as varchar(20)) + ', '
    + coalesce('''' + replace(v.clientid, '''', '''''') + '''', 'null') + ', '
    + coalesce('''' + replace(v.firstname, '''', '''''') + '''', 'null') + ');'
    as sql
from dbo.vendors as v;

-- Продукты
select id, productid, description, flaging
from dbo.product;

select 'insert into dim_products(ext_id, article, name, prod_type, flag) values ('
    + cast(p.id as varchar(20)) + ', '
    + coalesce('''' + replace(p.productid, '''', '''''') + '''', 'null') + ', '
    + coalesce('''' + replace(p.description, '''', '''''') + '''', 'null') + ', '
    + '''' + case p.flaging
        when 0 then 'Блюдо'
        when 1 then 'Ингредиент'
        when 2 then 'Полуфабрикат'
        when 3 then 'Товар'
        when 4 then 'Изделие'
        else 'Блюдо'
    end + ''', '
    + coalesce(cast(p.flaging as varchar(10)), 'null') + ');'
    as sql
from dbo.product as p;

-- Сотрудники
select personid, lastname, firstname, middlename
from dbo.personnel;

select 'insert into dim_persons(ext_id, lastname, firstname, midname) values ('
    + cast(p.personid as varchar(20)) + ', '
    + coalesce('''' + replace(p.lastname, '''', '''''') + '''', 'null') + ', '
    + coalesce('''' + replace(p.firstname, '''', '''''') + '''', 'null') + ', '
    + coalesce('''' + replace(p.middlename, '''', '''''') + '''', 'null') + ');'
    as sql
from dbo.personnel as p;

-- Роли
select securityaccessid, description
from dbo.securityaccess;

select 'insert into dim_roles(ext_id, name) values ('
    + cast(r.securityaccessid as varchar(20)) + ', '
    + coalesce('''' + replace(r.description, '''', '''''') + '''', 'null') + ');'
    as sql
from dbo.securityaccess as r;

-- Склады
select id, description
from dbo.storages;

select 'insert into dim_storages(ext_id, name) values ('
    + cast(s.id as varchar(20)) + ', '
    + coalesce('''' + replace(s.description, '''', '''''') + '''', 'null') + ');'
    as sql
from dbo.storages as s;

-- Типы оплаты
select paymenttypeid, description, currencyid
from dbo.paymenttype;

select 'insert into dim_pay_types(ext_id, name, currency) values ('
    + cast(p.paymenttypeid as varchar(20)) + ', '
    + coalesce('''' + replace(p.description, '''', '''''') + '''', 'null') + ', '
    + coalesce('''' + replace(p.currencyid, '''', '''''') + '''', 'null') + ');'
    as sql
from dbo.paymenttype as p;

-- Виды складских операций
select ID, Description, Factor
from dbo.bm_StorageOperationsType;

select 'insert into dim_op_types(ext_id, name, factor) values ('
    + cast(o.ID as varchar(20)) + ', '
    + coalesce('''' + replace(o.Description, '''', '''''') + '''', 'null') + ', '
    + coalesce(cast(o.Factor as varchar(20)), 'null') + ');'
    as sql
from dbo.bm_StorageOperationsType as o;

-- Клиенты
select id, clientid, lastname, firstname, discount, bonus
from dbo.clients;

select 'insert into dim_clients(ext_id, code, name, discount, bonus) values ('
    + cast(c.id as varchar(20)) + ', '
    + coalesce('''' + replace(c.clientid, '''', '''''') + '''', 'null') + ', '
    + coalesce('''' + replace(ltrim(rtrim(coalesce(c.lastname, '') + ' ' + coalesce(c.firstname, ''))), '''', '''''') + '''', 'null') + ', '
    + coalesce(cast(c.discount as varchar(20)), 'null') + ', '
    + coalesce(cast(c.bonus as varchar(20)), 'null') + ');'
    as sql
from dbo.clients as c;

-- Причины списания
select ID, Description
from dbo.bm_ReasonDebit;

select 'insert into dim_reasons(ext_id, name) values ('
    + cast(r.ID as varchar(20)) + ', '
    + coalesce('''' + replace(r.Description, '''', '''''') + '''', 'null') + ');'
    as sql
from dbo.bm_ReasonDebit as r;

-- Типы транзакций
select transtypeid, description, PreviewGroupType
from dbo.transtype
where description is not null and description <> '';

select 'insert into dim_trans_types(ext_id, name, prev_group) values ('
    + cast(t.transtypeid as varchar(20)) + ', '
    + coalesce('''' + replace(t.description, '''', '''''') + '''', 'null') + ', '
    + coalesce('''' + replace(t.PreviewGroupType, '''', '''''') + '''', 'null') + ');'
    as sql
from dbo.transtype as t
where t.description is not null and t.description <> '';
