create database cw3;
create extension postgis;

-- shp2pgsql -D -I C:\Users\krzys\Desktop\bdp\cw3\T2018_KAR_GERMANY\T2018_KAR_BUILDINGS.shp t2018_kar_buildings | psql -U postgres -h localhost -p 5432 -d cw3
-- shp2pgsql -D -I C:\Users\krzys\Desktop\bdp\cw3\T2019_KAR_GERMANY\T2019_KAR_BUILDINGS.shp t2019_kar_buildings | psql -U postgres -h localhost -p 5432 -d cw3

-- zad 1
create view new_bui as (
    select geom, name from t2019_kar_buildings
    except
    select geom, name from t2018_kar_buildings
);

select * from new_bui;

-- zad 2
-- shp2pgsql -D -I C:\Users\krzys\Desktop\bdp\cw3\T2018_KAR_GERMANY\T2018_KAR_POI_TABLE.shp t2018_kar_poi | psql -U postgres -h localhost -p 5432 -d cw3
-- shp2pgsql -D -I C:\Users\krzys\Desktop\bdp\cw3\T2019_KAR_GERMANY\T2019_KAR_POI_TABLE.shp t2019_kar_poi | psql -U postgres -h localhost -p 5432 -d cw3


create view new_poi as (
    select geom, type from t2019_kar_poi
    except
    select geom, type from t2018_kar_poi
);

select count(new_poi.geom), new_poi.type
from new_poi
join new_bui new_b on st_within( new_poi.geom, st_buffer(new_b.geom, 0.005))
group by new_poi.type;


-- zad 3

-- shp2pgsql -D -I C:\Users\krzys\Desktop\bdp\cw3\T2019_KAR_GERMANY\T2019_KAR_STREETS.shp t2019_kar_streets | psql -U postgres -h localhost -p 5432 -d cw3
create table streets_reprojected as (
    select * from t2019_kar_streets
);

select UpdateGeometrySRID('streets_reprojected', 'geom', 3068);

-- zad 4
create table input_points(
    id serial primary key,
    geom geometry
);

insert into input_points(geom) values ('POINT(8.36093 49.03174)');
insert into input_points(geom) values ('POINT(8.39876 49.00644)');

-- zad 5
select UpdateGeometrySRID('input_points','geom', 3068);

-- zad 6
-- shp2pgsql -D -I C:\Users\krzys\Desktop\bdp\cw3\T2019_KAR_GERMANY\T2019_KAR_STREET_NODE.shp t2019_kar_street_node | psql -U postgres -h localhost -p 5432 -d cw3
select UpdateGeometrySRID('t2019_kar_street_node','geom', 3068);

select * from t2019_kar_street_node
join (select st_makeline(geom) as line
      from input_points) as ip
on ST_DWITHIN(t2019_kar_street_node.geom,ip.line, 200);


-- zad 7
-- shp2pgsql -D -I C:\Users\krzys\Desktop\bdp\cw3\T2019_KAR_GERMANY\T2019_KAR_LAND_USE_A.shp t2019_kar_land_use_a | psql -U postgres -h localhost -p 5432 -d cw3

select
    count(distinct stores.gid)
from
    (select * from t2019_kar_poi where type = 'Sporting Goods Store') as stores
join t2019_kar_land_use_a as parks
on st_dwithin(stores.geom, parks.geom, 300);

-- zad 8

-- shp2pgsql -D -I C:\Users\krzys\Desktop\bdp\cw3\T2019_KAR_GERMANY\T2019_KAR_RAILWAYS.shp t2019_kar_railways | psql -U postgres -h localhost -p 5432 -d cw3
-- shp2pgsql -D -I C:\Users\krzys\Desktop\bdp\cw3\T2019_KAR_GERMANY\T2019_KAR_WATER_LINES.shp t2019_kar_water_lines | psql -U postgres -h localhost -p 5432 -d cw3
select
    st_intersection(t2019_kar_railways.geom, t2019_kar_water_lines.geom) into T2019_KAR_BRIDGES
from t2019_kar_railways
join t2019_kar_water_lines
    on st_intersects(t2019_kar_railways .geom, t2019_kar_water_lines.geom);

select * from T2019_KAR_BRIDGES;