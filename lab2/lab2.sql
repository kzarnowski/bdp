-- 2
create database lab2;

-- 3
create extension postgis;

-- 4
create table buildings (
    id serial primary key,
    geom geometry,
    name varchar(20)
);

create table roads (
    id serial primary key,
    geom geometry,
    name varchar(20)
);

create table poi (
    id serial primary key,
    geom geometry,
    name varchar(20)
);

-- 5
insert into buildings(geom, name) values
    ('polygon((8 4, 8 1.5, 10.5 1.5, 10.5 4, 8 4))', 'BuildingA'),
    ('polygon((4 7, 4 5, 6 5, 6 7, 4 7))', 'BuildingB'),
    ('polygon((3 8, 5 8, 5 6, 3 6, 3 8))', 'BuildingC'),
    ('polygon((9 9, 9 8, 10 8, 10 9, 9 9))', 'BuildingD'),
    ('polygon((1 2, 2 2, 2 1, 1 1, 1 2))', 'BuildingF');

insert into roads(geom, name) values
    ('linestring(0 4.5, 12 4.5)' , 'RoadX'),
    ('linestring(7.5 10.5, 7.5 0)', 'RoadY');

insert into poi(geom, name) values
    ('point(1 3.5)', 'G'),
    ('point(5.5 1.5)', 'H'),
    ('point(9.5 6)', 'I'),
    ('point(6.5 6)', 'J'),
    ('point(6 9.5)', 'K');

-- 6

-- a
select sum(st_length(geom)) from roads;

-- b
select
    st_astext(geom) as geometry,
    st_area(geom) as area,
    st_perimeter(geom) as perimeter
from
    buildings
where
    name = 'BuildingA';

-- c
select
    name,
    st_area(geom) as area
from
    buildings
order by
    name;

-- d
select
    name,
    st_perimeter(geom) as perimeter
from
    buildings
order by
    st_area(geom) desc
limit 2;

-- e
select
    st_distance(b.geom, p.geom)
from
    buildings as b
cross join poi as p
where
    b.name = 'BuildingC' and
    p.name = 'K';

-- f
select
    st_area(c.geom)
        - st_area(ST_Intersection(c.geom, st_buffer(b.geom, 0.5)))
from
    (
        select geom from buildings where name = 'BuildingB'
    ) as b
    cross join (
        select geom from buildings where name = 'BuildingC'
    ) as c;

-- g
select
    b.name
from
    buildings as b
cross join (
        select geom from roads where name = 'RoadX'
    ) as rx
where
    st_y(st_centroid(b.geom)) > st_y(st_centroid(rx.geom));

-- h
select
    ST_Area(ST_SymDifference(geom,  ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')))
from
    buildings
where
    name = 'BuildingC';





