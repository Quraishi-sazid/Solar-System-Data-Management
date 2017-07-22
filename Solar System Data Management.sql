drop table rotation_of_satellite;
drop table planet;
drop table satellite;

create table planet(
	p_id   int,
	p_name varchar(8) not null,
	p_radius int,
	p_weight int,
	p_temp 	int,
	p_ring  varchar(1) check (p_ring='Y' or p_ring='N'),
	p_no_of_satellite int,
	p_size varchar(18),
	p_to_be_deleted int
	--primary key (p_name)
	);
create table satellite(
	s_id   int,
	s_name varchar(10) not null,
	p_id   int,
	s_radius int check(s_radius>0),
	s_weight int check(s_weight>0),
	s_temp   int,
	primary key (s_name)
);
--alter
alter table planet add rotation_around_sun integer;
alter table planet drop column p_to_be_deleted;
alter table planet modify p_name varchar(9);
alter table planet add constraint planet_pk primary key(p_name);

create table rotation_of_satellite(
	p_name varchar(8),
	s_name varchar(10),
	days_needed_to_rotate integer,
	foreign key (p_name) references planet (p_name) on delete cascade,
	foreign key (s_name) references satellite (s_name) on delete cascade
);
--trigger
create or replace trigger tr_rad
before update or insert on planet
for each row
begin
if :new.p_radius<4000 then
	:new.p_size:='mini planet';
elsif :new.p_radius>=4000 and :new.p_radius<=6000 then
	:new.p_size:='medium planet';
else
	:new.p_size:='mega planet';
end if;
end tr_rad;
/
--trigger
create or replace trigger check_rad
before insert or update on planet
for each row
begin
if (:new.p_radius<=0) then
RAISE_APPLICATION_ERROR(-20000,'Radius can not be 0 or negative');
end if;
end check_rad;
/

--describe
describe planet;
describe satellite;
describe rotation_of_satellite;

insert into planet values(1,'MERCURY',3200,325456,400,'N',0,232,null);
insert into planet values(2,'VENUS',4000,45670,100,'N',0,432,null);
insert into planet values(3,'EARTH',6279,325456,31,'N',1,365,null);
insert into planet values(4,'MARS',5000,32344,40,'N',2,344,null);
insert into planet values(5,'JUPITAR',3200545,325456,250,'N',21,546,null);
insert into planet values(6,'SATURN',423546,789657,189,'Y',17,547,null);
insert into planet values(7,'URANUS',6548736,875674564,-43,'Y',14,765,null);
insert into planet values(8,'NEPTUNE',7456834,498594983,-64,'N',12,876,null);

insert into satellite values(1,'Moon',3,10,34523,10);
insert into satellite values(2,'Deimos',4,343,24234,23);
insert into satellite values(3,'Phobos',4,132,23231,21);
insert into satellite values(4,'Europa',5,34332,2332,12);
insert into satellite values(5,'Ganimade',5,343,24234,23);
insert into satellite values(6,'Lo',6,343,24234,23);
insert into satellite values(7,'Xml',7,324,765,53);
insert into satellite values(8,'Abc',8,365,876,23);


insert into rotation_of_satellite values('EARTH','Moon',1);
insert into rotation_of_satellite values('MARS','Deimos',5);
insert into rotation_of_satellite values('MARS','Phobos',7);
commit;
--select all

select * from planet;
select * from satellite;
select * from rotation_of_satellite;


--some simple query

--where:
select * from planet where p_name='EARTH';
select * from rotation_of_satellite where p_name='EARTH';
select * from satellite where s_id=1;
--in
select p_radius from planet where p_name in('EARTH','MARS');
select * from satellite where s_id in(1,2,3);
--set
update planet set rotation_around_sun=rotation_around_sun+10 where p_name='MARS';
--between
select p_name from planet where p_radius between 3000 and 5000;
select * from planet where p_temp between 200 and 500;
--and
select * from planet where p_temp<0 and p_radius>7000000;
--or
select p_name from planet where p_temp<0 or p_ring='Y';
--not
select p_name from planet where p_radius not between 3000 and 4000;
--order by
select p_id,p_name from planet order by p_radius;
--order by desc
select p_id,p_name from planet order by rotation_around_sun desc;
--group by
select p_ring,count(p_ring) from planet group by p_ring;
--having
select p_ring,count(p_ring) from planet group by (p_ring) having count(p_ring)>3;
--max
select max(p_weight) from planet;
--min
select min(p_weight) from planet;
--subquery
select s_radius from satellite where s_name in (select s_name from satellite where p_id=4);
--subquery for the planet who doesn't have ring
select p_name from planet where p_name not in(select p_name from planet where p_ring='Y');
--subquery of subquery:
select p_radius from planet where p_name in(select p_name from planet where p_name not in(select p_name from planet where p_ring='Y'));
--join
--inner join
select p_name,s_name from planet inner join satellite on planet.p_id=satellite.p_id;
--left join 
select p_name,s_name from planet left join satellite on planet.p_id=satellite.p_id;
--right join
select p_name,s_name from planet right join satellite on planet.p_id=satellite.p_id;
--full join
select p_name,s_name from planet full outer join satellite on planet.p_id=satellite.p_id;
--savepoint
savepoint save1;
update planet set p_weight=100 where p_id=3;
select p_weight from planet where p_id=3;
rollback to save1;
select p_weight from planet where p_id=3;

--pl/sql
set serveroutput on
declare
sum_of_weight planet.p_weight%type :=0;
pl_weight planet.p_weight%type;
i integer :=1;
begin
for i in 1..8
loop
	select p_weight into pl_weight from planet where p_id=i;
	sum_of_weight :=sum_of_weight+pl_weight;
end loop;
dbms_output.put_line('sum of weight '|| sum_of_weight);
end;
/

--pl/sql
declare
i integer :=1;
pl_temp planet.p_id%type;
begin
for  i in 1..8
loop
select p_temp into pl_temp  from planet where p_id =i;
if (pl_temp<0) then
pl_temp:=pl_temp+100;
update planet set p_temp=pl_temp where p_id =i;
end if;
end loop;
end;
/
--pl/sql procedure
DECLARE
   t1 planet.rotation_around_sun%type;
   t2 planet.rotation_around_sun%type;
	t3 planet.rotation_around_sun%type;
PROCEDURE maximum(x IN number, y IN number, z OUT number) IS
BEGIN
   IF x > y THEN
      z:= x;
   ELSE
      z:= y;
   END IF;
END; 

BEGIN
  select rotation_around_sun into t1 from planet where p_name='EARTH';
  select rotation_around_sun into t2 from planet where p_name='MARS';
   maximum(t1, t2, t3);
   if (t3=t1) then
   dbms_output.put_line('Time is more required for earth to rotate the sun ');
   else 
   dbms_output.put_line('Time is more required for mars to rotate the sun ');
   end if;
END;
/

create or replace FUNCTION planet_name(x in int) 
RETURN varchar
IS
    z varchar(18);
BEGIN
   select p_name into z from planet where x=p_temp;
   RETURN z;
END;
/
DECLARE
v varchar(20);
begin
v:=planet_name(400);
dbms_output.put_line(v);
end;
/


--pl sql cursor

DECLARE 
   number_of_rows integer;
BEGIN
   UPDATE planet set p_radius=p_radius+100 where p_name='EARTH';
   if (sql%notfound) then
   dbms_output.put_line('no planet found');
   ELSIF sql%found THEN
      number_of_rows:=sql%rowcount;
      dbms_output.put_line( number_of_rows || ' planet updated ');
   END IF; 
END;
/
