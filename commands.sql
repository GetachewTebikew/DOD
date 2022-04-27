create database LMS;
CREATE TABLE person(
  sex varchar(5),
  email varchar(50),
  phone varchar(15) primary key not null,
  first_name varchar(20),
  last_name varchar(20));

CREATE TABLE Student (
  user_id varchar(15) primary key not null,
  batch      int  NOT NULL,
  expiration      timestamp  NOT NULL
) INHERITS (person);

CREATE TABLE Teacher(
  user_id varchar(15) primary key not null,
  experience      int  NOT NULL
) INHERITS (person);

CREATE TABLE Publisher(
  publisher_id int primary key not null generated always as identity,
  address varchar(50),
  name varchar(50));

CREATE TABLE Item(
  price int not null,
  item_id int primary key not null generated always as identity,
  category varchar(50),
	title varchar(50) not null;
  publisher_id int not null,
  teachers_ony boolean not null,
 foreign key(publisher_id) references Publisher(publisher_id) );
 
 
 CREATE TABLE Book(
  isbn int primary key not null, 
  edition int not null ) INHERITS (item);

CREATE TABLE Records(
  type varchar(50) not null,
  issn int primary key not null, 
  edition int not null ) INHERITS (item);
  

CREATE TABLE Borrow(
id serial primary key,
  borrow_date timestamp not null,
  return_date timestamp not null,
  fine int,
	user_id varchar(15) not null,
	item_id int not null
	 );
  
-- INSERINTIONS
INSERT INTO Student (first_name, last_name, sex, user_id, phone, batch,email )
VALUES ('Abebech', 'Abebe' , 'm', 'atr/9090/10', '0942424242', 4, 'Emergency@ema.com');
INSERT INTO Student (first_name, last_name, sex, user_id, phone, batch,email )
VALUES ('banede', 'Abebe' , 'm', 'atr/9091/10', '0942424122', 4, 'ndmfn@ema.com');
INSERT INTO Student (first_name, last_name, sex, user_id, phone, batch,email )
VALUES ('belewwa', 'Abebe' , 'm', 'atr/9092/10', '0942412242', 4, 'fdmfn@ema.com');
INSERT INTO Student (first_name, last_name, sex, user_id, phone, batch,email )
VALUES ('bontu', 'Abebe' , 'm', 'atr/9093/10', '0942424242', 4, 'ee@ema.com');
INSERT INTO Student (first_name, last_name, sex, user_id, phone, batch,email )
VALUES ('Ayantu', 'Abebe' , 'm', 'atr/9094/10', '0941224242', 4, 'eeiw@ema.com');
-- teachers
INSERT INTO Teacher (first_name, last_name, sex, user_id, phone, experience,email )
VALUES ('Abebech', 'Abebe' , 'm', 'itsc/9090/10', '0942424242', 4, 'Emergency@ema.com');
INSERT INTO Teacher (first_name, last_name, sex, user_id, phone, experience,email )
VALUES ('banede', 'Abebe' , 'm', 'elec/9091/10', '0942424122', 4, 'banede@ema.com');
INSERT INTO Teacher (first_name, last_name, sex, user_id, phone, experience,email )
VALUES ('belewwa', 'Abebe' , 'm', 'elec/9092/10', '0942412242', 4, 'belewwa@ema.com');
INSERT INTO Teacher (first_name, last_name, sex, user_id, phone, experience,email )
VALUES ('bontu', 'Abebe' , 'm', 'itsc/9093/10', '0942424242', 4, 'bontu@ema.com');
INSERT INTO Teacher (first_name, last_name, sex, user_id, phone, experience,email )
VALUES ('Ayantu', 'Abebe' , 'm', 'mec/9094/10', '0941224242', 4, 'Ayantu@ema.com');

-- publishers
INSERT INTO Publisher (name, address)
VALUES ('Aster nega', 'Addis ababa, 4kilo' );
INSERT INTO Publisher (name, address)
VALUES ('Mega', 'Addis ababa, piassa' );
INSERT INTO Publisher (name, address)
VALUES ('Press', 'Addis ababa, bole' );

-- FUNTIONS
CREATE OR REPLACE FUNCTION getBooks() RETURNS SETOF book AS $$
 SELECT * FROM booK;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getBooks(title varchar(50)) RETURNS SETOF book AS $$
 SELECT * FROM booK WHERE name=title;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getBooks(title varchar(50), category_name varchar(50)) RETURNS SETOF book AS $$
 SELECT * FROM booK WHERE name=title AND category=category_name;
$$ LANGUAGE sql;

-- RECORDS
CREATE OR REPLACE FUNCTION getRecords() RETURNS SETOF record AS $$
 SELECT * FROM records;
$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION getRecords(title varchar(50)) RETURNS SETOF record AS $$
 SELECT * FROM records WHERE name=title;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getRecords(title varchar(50), category_name varchar(50)) RETURNS SETOF record AS $$
 SELECT * FROM records WHERE name=title AND category=category_name;
$$ LANGUAGE sql;

select * from getRecords('Fikir Eske Mekabir', 'Fiction');
select * from getRecords();

-----------------------------------------------------------------------

-- -- -- book partition
CREATE TABLE teacher_books (
CHECK ( teachers_only = true )
) INHERITS (book);

CREATE TABLE student_books (
  CHECK ( teachers_only = false )
) INHERITS (book);

create or replace function partition_book() returns trigger as $$
begin 
  if (New.teachers_only = false) then
    insert into student_books values (New.*);
  else
    insert into teacher_books values(New.*);
  end if;
return null;
end;
$$ language  plpgsql;

create  trigger partition_bookkTb_trigger
before insert on book 
for each row execute procedure partition_book();

INSERT INTO Book (price, category, name, publisher_id,edition, isbn,teachers_only )
VALUES (100.0, 'Fiction' , 'Fikir Eske Mekabir', 1, 1, '1122235435435', false);

INSERT INTO Book (price, category, name, publisher_id,edition, isbn,teachers_only )
VALUES ( 550.0, 'Mathematics' , 'The endless dkam', 1, 1, '111212787878','f');

INSERT INTO Book (price, category, name, publisher_id,edition, isbn,teachers_only )
VALUES ( 59.80, 'Philosophy' , 'The endless dkam', 1, 1, '546546565465','f');

INSERT INTO Book (price, category, name, publisher_id,edition, isbn,teachers_only )
VALUES ( 880.75, 'Science Fiction' , 'The endless dkam', 1, 1, '879867546545','t');

INSERT INTO Book (price, category, name, publisher_id,edition, isbn,teachers_only )
VALUES ( 89.50, 'Drama' , 'Despit', 1, 1, '54684564654','t');

-- -- -- record partition

CREATE TABLE teacher_records (
  CHECK ( teachers_only = true )
) INHERITS (records);

CREATE TABLE student_records (
  CHECK ( teachers_only = false )
) INHERITS (records);

create or replace function partition_records() returns trigger as $$
begin 
  if (New.teachers_only = false) then
    insert into student_records values (New.*);
  else
    insert into teacher_records values(New.*);
  end if;
return null;
end;
$$ language plpgsql;

create  trigger partition_recordInsert_trigger
before insert on records 
for each row execute procedure partition_records();

INSERT INTO Records (type,price, category, name, publisher_id,edition, issn,teachers_only )
VALUES ('Audio', 50.75, 'Research' , 'What is dream', 2, 9, '545635435435', 'f');

INSERT INTO Records (type,price, category, name, publisher_id,edition, issn, teachers_only)
VALUES ('Video', 71.05, 'Documentary' , 'Animal World', 3, 4, '1234546847846', 't');

INSERT INTO Records (type,price, category, name, publisher_id,edition, issn,teachers_only )
VALUES ('Audio', 89.50, 'Drama' , 'Despit', 1, 1, '546845646548493', 'f');

INSERT INTO Records (type,price, category, name, publisher_id,edition, issn, teachers_only)
VALUES ('Video', 89.50, 'Drama' , 'mathematics algebra', 1, 1, '4545646546', 't');

-- -- -- overriding
create function getBorrowAmmount( person ) returns int as '
begin
	return 1;
end;
' language 'plpgsql';

create or replace function getBorrowAmmount( student ) returns int as '
begin
	return 2;
end;
' language 'plpgsql';

create or replace function getBorrowAmmount( teacher ) returns int as '
begin
	return 5;
end;
' language 'plpgsql';

-- select getBorrowAmmount(person) from person;
--  select getBorrowAmmount(student) from student;
--  select getBorrowAmmount(teacher) from teacher;

