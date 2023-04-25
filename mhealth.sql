-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Apr 25, 2023 at 05:19 AM
-- Server version: 8.0.31
-- PHP Version: 8.0.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mhealth`
--

-- --------------------------------------------------------

--
-- Table structure for table `appointment`
--

DROP TABLE IF EXISTS `appointment`;
CREATE TABLE IF NOT EXISTS `appointment` (
  `appointment_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` int NOT NULL,
  `doctor_id` int NOT NULL,
  `appointment_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `location` varchar(10) NOT NULL,
  PRIMARY KEY (`appointment_id`),
  UNIQUE KEY `unique_patient_appointment` (`patient_id`,`appointment_date`,`start_time`),
  KEY `patient_id` (`patient_id`),
  KEY `doctor_id` (`doctor_id`)
) ;

--
-- Dumping data for table `appointment`
--

INSERT INTO `appointment` (`appointment_id`, `patient_id`, `doctor_id`, `appointment_date`, `start_time`, `end_time`, `location`) VALUES
(1, 1, 2, '2023-01-01', '09:00:00', '10:00:00', 'in-person');

--
-- Triggers `appointment`
--
DROP TRIGGER IF EXISTS `check_doctor_availability_trigger_insert`;
DELIMITER $$
CREATE TRIGGER `check_doctor_availability_trigger_insert` BEFORE INSERT ON `appointment` FOR EACH ROW BEGIN
    IF NOT EXISTS (
        SELECT *
        FROM doctor_availability
        WHERE doctor_id = NEW.doctor_id
        AND `availability_date` = NEW.appointment_date
        AND (
            (NEW.start_time BETWEEN start_time AND end_time)
            AND (NEW.end_time BETWEEN start_time AND end_time)

        )
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Doctor is not available at the given date and time.';
    END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `check_doctor_availability_trigger_update`;
DELIMITER $$
CREATE TRIGGER `check_doctor_availability_trigger_update` BEFORE UPDATE ON `appointment` FOR EACH ROW BEGIN
    IF NOT EXISTS (
        SELECT *
        FROM doctor_availability
        WHERE doctor_id = NEW.doctor_id
        AND `availability_date` = NEW.appointment_date
        AND (
            (NEW.start_time BETWEEN start_time AND end_time)
            AND (NEW.end_time BETWEEN start_time AND end_time)

        )
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Doctor is not available at the given date and time.';
    END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `prevent_double_booking_insert`;
DELIMITER $$
CREATE TRIGGER `prevent_double_booking_insert` BEFORE INSERT ON `appointment` FOR EACH ROW BEGIN
    DECLARE num_appointments INTEGER;
    SELECT COUNT(*) INTO num_appointments
    FROM appointment
    WHERE patient_id = NEW.patient_id
    AND `appointment_date` = NEW.`appointment_date`
    AND start_time <= NEW.end_time
    AND end_time >= NEW.start_time;
    IF num_appointments > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot make two appointments during the same time frame and date.';
    END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `prevent_double_booking_update`;
DELIMITER $$
CREATE TRIGGER `prevent_double_booking_update` BEFORE UPDATE ON `appointment` FOR EACH ROW BEGIN
    DECLARE num_appointments INTEGER;
    SELECT COUNT(*) INTO num_appointments
    FROM appointment
    WHERE patient_id = NEW.patient_id
    AND `appointment_date` = NEW.`appointment_date`
    AND start_time <= NEW.end_time
    AND end_time >= NEW.start_time;
    IF num_appointments > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot make two appointments during the same time frame and date.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `doctor`
--

DROP TABLE IF EXISTS `doctor`;
CREATE TABLE IF NOT EXISTS `doctor` (
  `doctor_id` int NOT NULL,
  `primary_email` varchar(50) NOT NULL,
  `secondary_email` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`doctor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `doctor`
--

INSERT INTO `doctor` (`doctor_id`, `primary_email`, `secondary_email`) VALUES
(2, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `doctor_availability`
--

DROP TABLE IF EXISTS `doctor_availability`;
CREATE TABLE IF NOT EXISTS `doctor_availability` (
  `availability_id` int NOT NULL AUTO_INCREMENT,
  `doctor_id` int NOT NULL,
  `availability_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  PRIMARY KEY (`availability_id`),
  KEY `doctor_id` (`doctor_id`)
) ;

--
-- Dumping data for table `doctor_availability`
--

INSERT INTO `doctor_availability` (`availability_id`, `doctor_id`, `availability_date`, `start_time`, `end_time`) VALUES
(4, 2, '2023-01-01', '09:00:00', '14:00:00');

--
-- Triggers `doctor_availability`
--
DROP TRIGGER IF EXISTS `prevent_availability_overlap_insert`;
DELIMITER $$
CREATE TRIGGER `prevent_availability_overlap_insert` BEFORE INSERT ON `doctor_availability` FOR EACH ROW BEGIN
    DECLARE overlap_count INT;
    SELECT COUNT(*) INTO overlap_count
    FROM doctor_availability 
    WHERE doctor_id = NEW.doctor_id 
    AND availability_date = NEW.availability_date 
    AND start_time < NEW.end_time 
    AND end_time > NEW.start_time;
    
    IF overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The availability time overlaps with an existing availability.';
    END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `prevent_availability_overlap_update`;
DELIMITER $$
CREATE TRIGGER `prevent_availability_overlap_update` BEFORE UPDATE ON `doctor_availability` FOR EACH ROW BEGIN
    DECLARE overlap_count INT;
    SELECT COUNT(*) INTO overlap_count
    FROM doctor_availability 
    WHERE doctor_id = NEW.doctor_id 
    AND availability_date = NEW.availability_date 
    AND start_time < NEW.end_time 
    AND end_time > NEW.start_time;
    
    IF overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The availability time overlaps with an existing availability.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `employee`
--

DROP TABLE IF EXISTS `employee`;
CREATE TABLE IF NOT EXISTS `employee` (
  `employee_id` int NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `job_title` varchar(50) NOT NULL,
  `primary_email` varchar(50) NOT NULL,
  `secondary_email` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `employee`
--

INSERT INTO `employee` (`employee_id`, `start_date`, `end_date`, `job_title`, `primary_email`, `secondary_email`) VALUES
(3, '2019-10-10', NULL, 'Secretary', '', '');

-- --------------------------------------------------------

--
-- Table structure for table `immunization`
--

DROP TABLE IF EXISTS `immunization`;
CREATE TABLE IF NOT EXISTS `immunization` (
  `immunization_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` int DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `immunization_date` date DEFAULT NULL,
  PRIMARY KEY (`immunization_id`),
  KEY `patient_id` (`patient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Triggers `immunization`
--
DROP TRIGGER IF EXISTS `immunization_date_trigger_insert`;
DELIMITER $$
CREATE TRIGGER `immunization_date_trigger_insert` BEFORE INSERT ON `immunization` FOR EACH ROW BEGIN
    IF NEW.immunization_date < '1950-01-01' OR NEW.immunization_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid immunization date. Only dates between January 1950 and the current date are allowed.';
    END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `immunization_date_trigger_update`;
DELIMITER $$
CREATE TRIGGER `immunization_date_trigger_update` BEFORE UPDATE ON `immunization` FOR EACH ROW BEGIN
    IF NEW.immunization_date < '1950-01-01' OR NEW.immunization_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid immunization date. Only dates between January 1950 and the current date are allowed.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `insurance`
--

DROP TABLE IF EXISTS `insurance`;
CREATE TABLE IF NOT EXISTS `insurance` (
  `insurance_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` int DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `policy_number` varchar(20) NOT NULL,
  `group_number` varchar(20) NOT NULL,
  PRIMARY KEY (`insurance_id`),
  UNIQUE KEY `policy_number` (`policy_number`,`group_number`),
  UNIQUE KEY `unique_insurance` (`policy_number`,`group_number`),
  UNIQUE KEY `policy_number_2` (`policy_number`,`group_number`),
  KEY `patient_id` (`patient_id`)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `medication`
--

DROP TABLE IF EXISTS `medication`;
CREATE TABLE IF NOT EXISTS `medication` (
  `medication_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` int NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  PRIMARY KEY (`medication_id`),
  KEY `patient_id` (`patient_id`)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `message`
--

DROP TABLE IF EXISTS `message`;
CREATE TABLE IF NOT EXISTS `message` (
  `message_id` int NOT NULL AUTO_INCREMENT,
  `sender_id` int NOT NULL,
  `receiver_id` int NOT NULL,
  `title` varchar(50) DEFAULT NULL,
  `body` text NOT NULL,
  PRIMARY KEY (`message_id`),
  KEY `sender_id` (`sender_id`),
  KEY `receiver_id` (`receiver_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `patient`
--

DROP TABLE IF EXISTS `patient`;
CREATE TABLE IF NOT EXISTS `patient` (
  `patient_id` int NOT NULL,
  `minor` tinyint(1) DEFAULT NULL,
  `password_hash` varchar(256) NOT NULL,
  `school_email` varchar(50) NOT NULL,
  PRIMARY KEY (`patient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `patient`
--

INSERT INTO `patient` (`patient_id`, `minor`, `password_hash`, `school_email`) VALUES
(1, 0, '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'etay1@brockport.edu');

-- --------------------------------------------------------

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
CREATE TABLE IF NOT EXISTS `person` (
  `person_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `middle_intial` char(1) DEFAULT NULL,
  `last_name` varchar(50) NOT NULL,
  `birth_date` date NOT NULL,
  PRIMARY KEY (`person_id`)
) ;

--
-- Dumping data for table `person`
--

INSERT INTO `person` (`person_id`, `first_name`, `middle_intial`, `last_name`, `birth_date`) VALUES
(1, 'Elijah', 'C', 'Tay', '1998-09-11'),
(2, 'Corey', 'J', 'Bright', '2002-11-14'),
(3, 'Angela', 'K', 'Gagnon', '2001-10-22'),
(4, 'Hapreet', NULL, 'Bains', '1995-10-21'),
(5, 'Adesh', NULL, 'Rai', '1993-01-01'),
(6, 'Hannah', NULL, 'Applebaum', '1995-01-01'),
(7, 'Faizan', NULL, 'Rafieuddin', '1996-01-01'),
(8, 'John', NULL, 'Doe', '1990-09-01'),
(9, 'Bob', NULL, 'Smith', '1985-09-21'),
(10, 'Alice', NULL, 'Johnson', '1988-11-30'),
(11, 'Mike', NULL, 'Williams', '1996-03-15'),
(12, 'Jane', NULL, 'Doe', '1992-05-12');

-- --------------------------------------------------------

--
-- Table structure for table `specialty`
--

DROP TABLE IF EXISTS `specialty`;
CREATE TABLE IF NOT EXISTS `specialty` (
  `doctor_id` int NOT NULL,
  `specialty` varchar(50) NOT NULL,
  PRIMARY KEY (`doctor_id`,`specialty`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `telephone`
--

DROP TABLE IF EXISTS `telephone`;
CREATE TABLE IF NOT EXISTS `telephone` (
  `person_id` int NOT NULL,
  `telephone` int NOT NULL,
  PRIMARY KEY (`person_id`,`telephone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
