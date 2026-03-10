/* ============================================================
PROJECT: Netfula Primary School Student Performance Analysis
GOAL: EDA, Data Cleaning, and Feature Engineering
AUTHOR: Olanrewaju Oyebanji
============================================================
*/

-- 1. DATABASE SETUP
CREATE DATABASE IF NOT EXISTS School_project;
USE School_Project;

-- 2. INITIAL EXPLORATION (EDA)
SELECT * FROM `netfula primary school student performance` LIMIT 10;
DESCRIBE `netfula primary school student performance`;

-- Checking Unique Values for Categorical Columns
SELECT DISTINCT gender FROM `netfula primary school student performance`;
SELECT DISTINCT `race/ethnicity` FROM `netfula primary school student performance`;
SELECT DISTINCT `parental level of education` FROM `netfula primary school student performance`;

-- 3. DATA CLEANING: Checking for Nulls & Blanks
SELECT 
    COUNT(CASE WHEN gender IS NULL OR gender = '' THEN 1 END) AS missing_gender,
    COUNT(CASE WHEN `math score` IS NULL THEN 1 END) AS missing_math
FROM `netfula primary school student performance`;

-- 4. DATA TRANSFORMATION: Mapping Race/Ethnicity Groups
START TRANSACTION;
UPDATE `netfula primary school student performance` SET `race/ethnicity` = 'Asian' WHERE `race/ethnicity` = 'group A';
UPDATE `netfula primary school student performance` SET `race/ethnicity` = 'Black or African American' WHERE `race/ethnicity` = 'group B';
UPDATE `netfula primary school student performance` SET `race/ethnicity` = 'White' WHERE `race/ethnicity` = 'group C';
UPDATE `netfula primary school student performance` SET `race/ethnicity` = 'Hispanic or Latino' WHERE `race/ethnicity` = 'group D';
UPDATE `netfula primary school student performance` SET `race/ethnicity` = 'Other' WHERE `race/ethnicity` = 'group E';
COMMIT;

-- 5. FEATURE ENGINEERING: Creating Scores & Grades
ALTER TABLE `netfula primary school student performance`
ADD COLUMN Total_Score INT,
ADD COLUMN AVG_Score DECIMAL(5, 2),
ADD COLUMN Grade CHAR(1);

UPDATE `netfula primary school student performance`
SET Total_Score = `math score` + `reading score` + `writing score`,
    AVG_Score = (Total_Score / 3);

UPDATE `netfula primary school student performance`
SET Grade = CASE
    WHEN AVG_Score >= 75 THEN 'A'
    WHEN AVG_Score >= 65 THEN 'B'
    WHEN AVG_Score >= 49 THEN 'C'
    ELSE 'F'
END;

-- 6. ADVANCED SQL: JOINS & REPORTING
-- Example: Creating a lookup table for Education Levels
CREATE TABLE IF NOT EXISTS Education_Levels (
    level_name VARCHAR(50),
    education_rank INT
);

INSERT INTO Education_Levels VALUES 
('some high school', 1), ('high school', 2), ('some college', 3), 
("associate's degree", 4), ("bachelor's degree", 5), ("master's degree", 6);

-- LEFT JOIN: Show student performance alongside their parent's education rank
SELECT 
    s.gender, 
    s.`parental level of education`, 
    e.education_rank,
    s.AVG_Score
FROM `netfula primary school student performance` s
LEFT JOIN Education_Levels e 
    ON s.`parental level of education` = e.level_name
ORDER BY e.education_rank DESC;

-- INNER JOIN: Show only students who have a matching education rank in our system
SELECT 
    s.`race/ethnicity`, 
    AVG(s.Total_Score) as Avg_Total
FROM `netfula primary school student performance` s
INNER JOIN Education_Levels e 
    ON s.`parental level of education` = e.level_name

GROUP BY s.`race/ethnicity`;
