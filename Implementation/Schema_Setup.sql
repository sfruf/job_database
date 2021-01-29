CREATE SCHEMA IF NOT EXISTS job_db; 


CREATE TABLE IF NOT EXISTS job_db.company (
ID INT NOT NULL AUTO_INCREMENT, 
Name VARCHAR(50) NOT NULL, 
Notes TEXT,
PRIMARY KEY(ID)) ; 


CREATE TABLE IF NOT EXISTS job_db.position (
ID INT NOT NULL AUTO_INCREMENT, 
Name VARCHAR(50) NOT NULL, 
Company_id INT,
PRIMARY KEY(ID),
FOREIGN KEY(company_id) REFERENCES job_db.company(ID)) ; 


CREATE TABLE IF NOT EXISTS job_db.application (
ID INT NOT NULL AUTO_INCREMENT, 
Applied DATE,
Outcome VARCHAR(12),
Next_Action_Date DATE,
Next_Action  VARCHAR(60),
Position_ID INT,
PRIMARY KEY(ID),
FOREIGN KEY(position_id) references job_db.position(ID)) ; 


CREATE TABLE IF NOT EXISTS job_db.interview (
ID INT NOT NULL AUTO_INCREMENT, 
Interview_Date DATE,
Notes TEXT,
Application_ID INT,
PRIMARY KEY(ID),
FOREIGN KEY(Application_ID) references job_db.application(ID)); 

