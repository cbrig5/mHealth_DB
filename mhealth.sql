-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
domain-trigger-and-minor-view
-- Host: localhost
-- Generation Time: Apr 25, 2023 at 08:01 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4



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

CREATE TABLE `appointment` (
  `appointment_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `appointment_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `location` varchar(10) NOT NULL
) ;

--
-- Dumping data for table `appointment`
--

INSERT INTO `appointment` (`appointment_id`, `patient_id`, `doctor_id`, `appointment_date`, `start_time`, `end_time`, `location`) VALUES
(1, 1, 2, '2023-01-01', '09:00:00', '10:00:00', 'in-person');

--
-- Triggers `appointment`
--
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

CREATE TABLE `doctor` (
  `doctor_id` int(11) NOT NULL,
  `primary_email` varchar(50) NOT NULL,
  `secondary_email` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `doctor`
--

INSERT INTO `doctor` (`doctor_id`, `primary_email`, `secondary_email`) VALUES
(2, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `doctor_availability`
--

CREATE TABLE `doctor_availability` (
  `availability_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `availability_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL
) ;

--
-- Dumping data for table `doctor_availability`
--

INSERT INTO `doctor_availability` (`availability_id`, `doctor_id`, `availability_date`, `start_time`, `end_time`) VALUES
(4, 2, '2023-01-01', '09:00:00', '14:00:00');

--
-- Triggers `doctor_availability`
--
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

CREATE TABLE `employee` (
  `employee_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `job_title` varchar(50) NOT NULL,
  `primary_email` varchar(50) NOT NULL,
  `secondary_email` varchar(50) DEFAULT NULL
) ;

--
-- Dumping data for table `employee`
--

INSERT INTO `employee` (`employee_id`, `start_date`, `end_date`, `job_title`, `primary_email`, `secondary_email`) VALUES
(3, '2019-10-10', NULL, 'Secretary', '', ''),
(6, '2019-10-10', NULL, 'Secretary', 'jlkn', NULL);

--
-- Triggers `employee`
--
DELIMITER $$
CREATE TRIGGER `employee_date_trigger_insert` BEFORE INSERT ON `employee` FOR EACH ROW BEGIN
    IF (NEW.start_date NOT BETWEEN 1950-01-01 AND CURDATE()) 
  THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid start or end date.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `employee_date_trigger_update` BEFORE UPDATE ON `employee` FOR EACH ROW BEGIN
    IF (NEW.start_date BETWEEN '1950-01-01' AND CURDATE()) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid start date. Only dates between January 1950 and the current date are allowed.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `immunization`
--

CREATE TABLE `immunization` (
  `immunization_id` int(11) NOT NULL,
  `patient_id` int(11) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `immunization_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Triggers `immunization`
--
DELIMITER $$
CREATE TRIGGER `immunization_date_trigger_insert` BEFORE INSERT ON `immunization` FOR EACH ROW BEGIN
    IF NEW.immunization_date < '1950-01-01' OR NEW.immunization_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid immunization date. Only dates between January 1950 and the current date are allowed.';
    END IF;
END
$$
DELIMITER ;
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

CREATE TABLE `insurance` (
  `insurance_id` int(11) NOT NULL,
  `patient_id` int(11) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `policy_number` varchar(20) NOT NULL,
  `group_number` varchar(20) NOT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `medication`
--

CREATE TABLE `medication` (
  `medication_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL
) ;

--
-- Triggers `medication`
--
DELIMITER $$
CREATE TRIGGER `medication_date_trigger_insert` BEFORE INSERT ON `medication` FOR EACH ROW BEGIN
    IF (NEW.start_date BETWEEN '1950-01-01' AND CURDATE()) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid start date. Only dates between January 1950 and the current date are allowed.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `medication_date_trigger_update` BEFORE UPDATE ON `medication` FOR EACH ROW BEGIN
    IF (NEW.start_date BETWEEN '1950-01-01' AND CURDATE()) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid start date. Only dates between January 1950 and the current date are allowed.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `message`
--

CREATE TABLE `message` (
  `message_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `title` varchar(50) DEFAULT NULL,
  `body` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `minor_status`
-- (See below for the actual view)
--
CREATE TABLE `minor_status` (
`name` varchar(101)
,`birth_date` date
,`status` varchar(5)
);

-- --------------------------------------------------------

--
-- Table structure for table `patient`
--


CREATE TABLE `patient` (
  `patient_id` int(11) NOT NULL,
  `password_hash` binary(64) NOT NULL,
  `school_email` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;


--
-- Dumping data for table `patient`
--



INSERT INTO `patient` (`patient_id`, `password_hash`, `school_email`) VALUES
(1,'5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'etay1@brockport.edu');


-- --------------------------------------------------------

--
-- Table structure for table `person`
--

CREATE TABLE `person` (
  `person_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `middle_intial` char(1) DEFAULT NULL,
  `last_name` varchar(50) NOT NULL,
  `birth_date` date NOT NULL
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
(12, 'Jane', NULL, 'Doe', '1992-05-12'),
(13, 'ima', NULL, 'minor', '2013-01-01');

-- --------------------------------------------------------

--
-- Table structure for table `specialty`
--

CREATE TABLE `specialty` (
  `doctor_id` int(11) NOT NULL,
  `specialty` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `telephone`
--

CREATE TABLE `telephone` (
  `person_id` int(11) NOT NULL,
  `telephone` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure for view `minor_status`
--
DROP TABLE IF EXISTS `minor_status`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `minor_status`  AS SELECT concat(`person`.`first_name`,' ',`person`.`last_name`) AS `name`, `person`.`birth_date` AS `birth_date`, CASE WHEN to_days(curdate()) - to_days(`person`.`birth_date`) < 6570 THEN 'Minor' ELSE 'Adult' END AS `status` FROM `person` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `appointment`
--
ALTER TABLE `appointment`
  ADD PRIMARY KEY (`appointment_id`),
  ADD UNIQUE KEY `unique_patient_appointment` (`patient_id`,`appointment_date`,`start_time`),
  ADD KEY `patient_id` (`patient_id`),
  ADD KEY `doctor_id` (`doctor_id`);

--
-- Indexes for table `doctor`
--
ALTER TABLE `doctor`
  ADD PRIMARY KEY (`doctor_id`);

--
-- Indexes for table `doctor_availability`
--
ALTER TABLE `doctor_availability`
  ADD PRIMARY KEY (`availability_id`),
  ADD KEY `doctor_id` (`doctor_id`);

--
-- Indexes for table `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`employee_id`);

--
-- Indexes for table `immunization`
--
ALTER TABLE `immunization`
  ADD PRIMARY KEY (`immunization_id`),
  ADD KEY `patient_id` (`patient_id`);

--
-- Indexes for table `insurance`
--
ALTER TABLE `insurance`
  ADD PRIMARY KEY (`insurance_id`),
  ADD UNIQUE KEY `policy_number` (`policy_number`,`group_number`),
  ADD UNIQUE KEY `unique_insurance` (`policy_number`,`group_number`),
  ADD UNIQUE KEY `policy_number_2` (`policy_number`,`group_number`),
  ADD KEY `patient_id` (`patient_id`);

--
-- Indexes for table `medication`
--
ALTER TABLE `medication`
  ADD PRIMARY KEY (`medication_id`),
  ADD KEY `patient_id` (`patient_id`);

--
-- Indexes for table `message`
--
ALTER TABLE `message`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `sender_id` (`sender_id`),
  ADD KEY `receiver_id` (`receiver_id`);

--
-- Indexes for table `patient`
--
ALTER TABLE `patient`
  ADD PRIMARY KEY (`patient_id`);

--
-- Indexes for table `person`
--
ALTER TABLE `person`
  ADD PRIMARY KEY (`person_id`);

--
-- Indexes for table `specialty`
--
ALTER TABLE `specialty`
  ADD PRIMARY KEY (`doctor_id`,`specialty`);

--
-- Indexes for table `telephone`
--
ALTER TABLE `telephone`
  ADD PRIMARY KEY (`person_id`,`telephone`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `appointment`
--
ALTER TABLE `appointment`
  MODIFY `appointment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `doctor_availability`
--
ALTER TABLE `doctor_availability`
  MODIFY `availability_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `immunization`
--
ALTER TABLE `immunization`
  MODIFY `immunization_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `insurance`
--
ALTER TABLE `insurance`
  MODIFY `insurance_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `medication`
--
ALTER TABLE `medication`
  MODIFY `medication_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `message`
--
ALTER TABLE `message`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `person`
--
ALTER TABLE `person`
  MODIFY `person_id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
