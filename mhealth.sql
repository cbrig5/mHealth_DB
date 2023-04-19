-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: Apr 19, 2023 at 06:31 PM
-- Server version: 5.7.39
-- PHP Version: 7.4.33

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
  `patient_id` int(11) DEFAULT NULL,
  `doctor_id` int(11) DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `location` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `availability`
--

CREATE TABLE `availability` (
  `doctor_id` int(11) NOT NULL,
  `available` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `doctor`
--

CREATE TABLE `doctor` (
  `doctor_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `doctor`
--

INSERT INTO `doctor` (`doctor_id`) VALUES
(2);

-- --------------------------------------------------------

--
-- Table structure for table `email`
--

CREATE TABLE `email` (
  `person_id` int(11) NOT NULL,
  `email` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `employee`
--

CREATE TABLE `employee` (
  `employee_id` int(11) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `job_title` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `employee`
--

INSERT INTO `employee` (`employee_id`, `start_date`, `end_date`, `job_title`) VALUES
(3, '2019-10-10', NULL, 'Secretary');

-- --------------------------------------------------------

--
-- Table structure for table `immunization`
--

CREATE TABLE `immunization` (
  `immunization_id` int(11) NOT NULL,
  `patient_id` int(11) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `date_given` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `medication`
--

CREATE TABLE `medication` (
  `medication_id` int(11) NOT NULL,
  `patient_id` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `message`
--

CREATE TABLE `message` (
  `message_id` int(11) NOT NULL,
  `sender_id` int(11) DEFAULT NULL,
  `receiver_id` int(11) DEFAULT NULL,
  `title` varchar(50) DEFAULT NULL,
  `body` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `patient`
--

CREATE TABLE `patient` (
  `patient_id` int(11) NOT NULL,
  `minor` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `patient`
--

INSERT INTO `patient` (`patient_id`, `minor`) VALUES
(1, 0);

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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

CREATE TABLE `specialty` (
  `doctor_id` int(11) NOT NULL,
  `specialty` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `telephone`
--

CREATE TABLE `telephone` (
  `person_id` int(11) NOT NULL,
  `telephone` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `appointment`
--
ALTER TABLE `appointment`
  ADD PRIMARY KEY (`appointment_id`),
  ADD KEY `patient_id` (`patient_id`),
  ADD KEY `doctor_id` (`doctor_id`);

--
-- Indexes for table `availability`
--
ALTER TABLE `availability`
  ADD PRIMARY KEY (`doctor_id`,`available`);

--
-- Indexes for table `doctor`
--
ALTER TABLE `doctor`
  ADD PRIMARY KEY (`doctor_id`);

--
-- Indexes for table `email`
--
ALTER TABLE `email`
  ADD PRIMARY KEY (`person_id`,`email`),
  ADD UNIQUE KEY `email` (`email`);

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
  MODIFY `person_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appointment`
--
ALTER TABLE `appointment`
  ADD CONSTRAINT `appointment_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`),
  ADD CONSTRAINT `appointment_ibfk_2` FOREIGN KEY (`doctor_id`) REFERENCES `doctor` (`doctor_id`);

--
-- Constraints for table `availability`
--
ALTER TABLE `availability`
  ADD CONSTRAINT `availability_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `doctor` (`doctor_id`);

--
-- Constraints for table `doctor`
--
ALTER TABLE `doctor`
  ADD CONSTRAINT `doctor_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `person` (`person_id`);

--
-- Constraints for table `email`
--
ALTER TABLE `email`
  ADD CONSTRAINT `email_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`person_id`);

--
-- Constraints for table `employee`
--
ALTER TABLE `employee`
  ADD CONSTRAINT `employee_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `person` (`person_id`);

--
-- Constraints for table `immunization`
--
ALTER TABLE `immunization`
  ADD CONSTRAINT `immunization_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`);

--
-- Constraints for table `insurance`
--
ALTER TABLE `insurance`
  ADD CONSTRAINT `insurance_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`);

--
-- Constraints for table `medication`
--
ALTER TABLE `medication`
  ADD CONSTRAINT `medication_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`);

--
-- Constraints for table `message`
--
ALTER TABLE `message`
  ADD CONSTRAINT `message_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `employee` (`employee_id`),
  ADD CONSTRAINT `message_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `patient` (`patient_id`);

--
-- Constraints for table `patient`
--
ALTER TABLE `patient`
  ADD CONSTRAINT `patient_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `person` (`person_id`);

--
-- Constraints for table `specialty`
--
ALTER TABLE `specialty`
  ADD CONSTRAINT `specialty_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `doctor` (`doctor_id`);

--
-- Constraints for table `telephone`
--
ALTER TABLE `telephone`
  ADD CONSTRAINT `telephone_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`person_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
