-- zad 1
drop table if exists obiekty;
create table obiekty(id serial primary key, geom geometry, name varchar);

-- a
insert into obiekty(geom, name)
values
  (
    ST_Collect(
      ARRAY[
        ST_GeomFromText('LINESTRING(0 1 ,1 1)'),
        ST_CurveToLine(ST_GeomFromText('CIRCULARSTRING(1 1,2 0, 3 1)')),
        ST_CurveToLine(ST_GeomFromText('CIRCULARSTRING(3 1,4 2, 5 1)')),
        ST_GeomFromText('LINESTRING(5 1 ,6 1)')
      ]
    ),
    'obiekt1'
  );

-- b
insert into obiekty(geom, name)
values
    (
      ST_Collect(
        ARRAY[
          ST_GeomFromText('LINESTRING(10 6 ,14 6)'),
          ST_CurveToLine(ST_GeomFromText('CIRCULARSTRING(14 6,16 4, 14 2)')),
          ST_CurveToLine(ST_GeomFromText('CIRCULARSTRING(14 2,12 0, 10 2)')),
          ST_GeomFromText('LINESTRING(10 2 ,10 6)'),
          ST_CurveToLine(ST_GeomFromText('CIRCULARSTRING(11 2,12 3, 13 2, 12 1, 11 2)'))
        ]
      ),
      'obiekt2'
    );

-- c
insert into obiekty(geom, name)
values
  (
    ST_MakePolygon(ST_GeomFromText('LINESTRING(7 15, 10 17, 12 13, 7 15)')),
    'obiekt3'
  );

-- d
insert into obiekty(geom, name)
values
  (
    ST_LineFromMultiPoint(St_GeomFromText('MULTIPOINT(20 20, 25 25,27 24, 25 22, 26 21, 22 19, 20.5 19.5)')),
    'obiekt4'
  );

-- e
insert into obiekty(geom, name)
values
  (
    ST_Collect(ST_GeomFromText('POINT(30 30 59)'), ST_GeomFromText('POINT(38 32 234)')),
    'obiekt5'
  );

-- f
insert into obiekty(geom, name)
values
  (
    ST_Collect(ST_GeomFromText('LINESTRING(1 1, 3 2)'), ST_GeomFromText('POINT(4 2)')),
    'obiekt6'
  );

select * from obiekty;

-- zad 2
select
  ST_Area(ST_Buffer(ST_ShortestLine(o3.geom, o4.geom), 5))
from
  (select geom from obiekty where name = 'obiekt3') as o3,
  (select geom from obiekty where name = 'obiekt4') as o4;

-- zad 3
update
  obiekty
set
  geom = ST_MakePolygon(ST_MakeLine(ST_LineMerge(geom), ST_PointN(ST_LineMerge(geom), 1)))
where
  name = 'obiekt4';

-- zad 4
insert into obiekty(geom, name)
  (
    select
      St_Collect(o3.geom, o4.geom), 'obiekt7'
    from
      (select geom from obiekty where name = 'obiekt3') as o3,
      (select geom from obiekty where name = 'obiekt4') as o4
  );

select * from obiekty where name = 'obiekt7';

-- zad 5
select
  name,
  ST_Area(ST_Buffer(geom, 5))
from
  obiekty
where
  ST_HasArc(ST_LineToCurve(geom)) = false;