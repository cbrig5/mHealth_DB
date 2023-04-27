ALTER TABLE appointment
  ADD CONSTRAINT location_domain CHECK (location IN ("online", "in-person", "Online", "In-person"));

ALTER TABLE doctor_availability 
	ADD CONSTRAINT start_time_domain CHECK (start_time BETWEEN "08:00:00" AND "18:00:00"),
    ADD CONSTRAINT end_time_domain CHECK(end_time BETWEEN "08:00:00" AND "18:00:00"),
    ADD CONSTRAINT time_overlap CHECK (end_time > start_time);

ALTER TABLE insurance
	ADD CONSTRAINT policy_group_chk CHECK (policy_number != group_number);

ALTER TABLE medication 
	ADD CONSTRAINT end_date_chk CHECK (start_date < end_date);
	
ALTER TABLE person
	ADD CONSTRAINT birth_date_domain CHECK (birth_date BETWEEN "1900-01-01" AND "2014-01-31");
	
ALTER TABLE employee
	ADD CONSTRAINT employee_end_date_chk CHECK (start_date < end_date);

ALTER TABLE telephone
	ADD CONSTRAINT len_number_chk CHECK (LENGTH(telephone) = 10);
