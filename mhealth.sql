-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Apr 27, 2023 at 01:43 AM
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
(1, 21, 1, '2023-10-02', '10:00:00', '11:00:00', 'in-person'),
(2, 23, 4, '2023-10-02', '09:00:00', '10:30:00', 'online'),
(3, 26, 6, '2023-10-06', '10:00:00', '11:00:00', 'in-person'),
(4, 29, 8, '2023-10-04', '14:00:00', '15:00:00', 'online'),
(5, 30, 10, '2023-10-04', '09:00:00', '11:00:00', 'in-person');

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
-- Stand-in structure for view `current_employee`
-- (See below for the actual view)
--
CREATE TABLE `current_employee` (
`FullName` varchar(103)
,`JobTitle` varchar(50)
,`YearsWorked` varchar(65)
,`PrimaryEmail` varchar(50)
,`SecondaryEmail` varchar(50)
,`PhoneNumbers` longtext
);

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
(1, 'elijah.tay@outlook.com', 'null'),
(2, 'corey.bright@gmail.com', 'corey.bright.other@gmail.com'),
(3, 'angela.gagnon@yahoo.com', 'angela.gagnon.assist@yahoo.com'),
(4, 'hapreet.bains@hotmail.com', 'null'),
(5, 'adesh.rai@icloud.com', 'adesh.rai.contact@icloud.com'),
(6, 'hannah.applebaum@protonmail.com', 'hannah.applebaum.alt@protonmail.com'),
(7, 'faizan.rafieuddin@aol.com', 'faizan.rafieuddin.support@aol.com'),
(8, 'john.doe@mail.com', 'null'),
(9, 'bob.smith@yandex.com', 'bob.smith.contact@yandex.com'),
(10, 'alice.johnson@live.com', 'alice.johnson.assist@live.com');

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
(1, 1, '2023-10-02', '09:00:00', '13:00:00'),
(2, 1, '2023-10-04', '12:00:00', '16:00:00'),
(3, 1, '2023-10-06', '08:00:00', '12:00:00'),
(4, 2, '2023-10-02', '14:00:00', '18:00:00'),
(5, 2, '2023-10-04', '09:00:00', '13:00:00'),
(6, 2, '2023-10-06', '11:00:00', '15:00:00'),
(7, 3, '2023-10-02', '11:00:00', '15:00:00'),
(8, 3, '2023-10-04', '14:00:00', '18:00:00'),
(9, 3, '2023-10-06', '10:00:00', '14:00:00'),
(10, 4, '2023-10-02', '09:00:00', '13:00:00'),
(11, 4, '2023-10-04', '11:00:00', '15:00:00'),
(12, 4, '2023-10-06', '12:00:00', '16:00:00'),
(13, 5, '2023-10-02', '08:00:00', '12:00:00'),
(14, 5, '2023-10-04', '13:00:00', '17:00:00'),
(15, 5, '2023-10-06', '10:00:00', '14:00:00'),
(16, 6, '2023-10-02', '11:00:00', '15:00:00'),
(17, 6, '2023-10-04', '14:00:00', '18:00:00'),
(18, 6, '2023-10-06', '08:00:00', '12:00:00'),
(19, 7, '2023-10-02', '12:00:00', '16:00:00'),
(20, 7, '2023-10-04', '10:00:00', '14:00:00'),
(21, 7, '2023-10-06', '13:00:00', '17:00:00'),
(22, 8, '2023-10-02', '08:00:00', '12:00:00'),
(23, 8, '2023-10-04', '09:00:00', '15:00:00'),
(24, 8, '2023-10-06', '13:00:00', '17:00:00'),
(25, 9, '2023-10-02', '09:00:00', '15:00:00'),
(26, 9, '2023-10-04', '10:00:00', '16:00:00'),
(27, 9, '2023-10-06', '12:00:00', '16:00:00'),
(28, 10, '2023-10-02', '11:00:00', '15:00:00'),
(29, 10, '2023-10-04', '08:00:00', '14:00:00'),
(30, 10, '2023-10-06', '13:00:00', '18:00:00');

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
-- Stand-in structure for view `doctor_info`
-- (See below for the actual view)
--
CREATE TABLE `doctor_info` (
`FullName` varchar(107)
,`Specialties` mediumtext
,`AvailabilityDate` varchar(10)
,`AvailabilityTime` varchar(19)
,`PrimaryEmail` varchar(50)
,`TelephoneNumbers` longtext
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `doctor_upcoming_appts`
-- (See below for the actual view)
--
CREATE TABLE `doctor_upcoming_appts` (
`AppointmentDate` date
,`AppointmentTime` varchar(23)
,`AppointmentLocation` varchar(10)
,`Name_exp_4` varchar(101)
);

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
(11, '1990-05-11', '1991-11-30', 'Nurse', 'nurse11@example.com', 'nurse11_secondary@example.com'),
(12, '2018-07-01', NULL, 'Receptionist', 'receptionist12@example.com', NULL),
(13, '2020-02-15', NULL, 'Medical Assistant', 'assistant13@example.com', 'assistant13_secondary@example.com'),
(14, '2015-09-01', '2020-02-29', 'Billing Specialist', 'billing14@example.com', 'billing14_secondary@example.com'),
(15, '1988-12-24', '2001-08-31', 'Medical Coder', 'coder15@example.com', NULL),
(16, '2017-02-01', NULL, 'Medical Transcriptionist', 'transcriptionist16@example.com', NULL),
(17, '2010-01-15', '2011-06-30', 'Medical Records Clerk', 'records17@example.com', 'records17_secondary@example.com'),
(18, '1986-06-20', '1989-05-01', 'Medical Billing Specialist', 'billing18@example.com', NULL),
(19, '1995-11-01', '2000-04-30', 'Medical Assistant', 'assistant19@example.com', 'assistant19_secondary@example.com'),
(20, '2019-10-15', NULL, 'Receptionist', 'receptionist20@example.com', NULL);

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
-- Stand-in structure for view `formatted_telephone`
-- (See below for the actual view)
--
CREATE TABLE `formatted_telephone` (
`person_id` int(11)
,`formatted_telephone` mediumtext
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `full_name`
-- (See below for the actual view)
--
CREATE TABLE `full_name` (
`person_id` int(11)
,`FullName` varchar(103)
);

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
-- Stand-in structure for view `message_details`
-- (See below for the actual view)
--
CREATE TABLE `message_details` (
`MessageID` int(11)
,`SenderID` int(11)
,`Name_exp_3` varchar(101)
,`SenderEmail` varchar(50)
,`SenderPhoneNumber` varchar(15)
,`Title` varchar(50)
,`Body` text
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `minor_status`
-- (See below for the actual view)
--
CREATE TABLE `minor_status` (
`Name_exp_1` varchar(103)
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
(21, 0x31663665326139636463383166393366633962666566653838376534623864663161616362333334353264346235393232636666333738353834363061306238, 'user1@brockport.edu'),
(22, 0x38356235663331353134663133363465626563656562383737386633383037333833396464323138306465393935656566613931363366656366626664616333, 'user2@brockport.edu'),
(23, 0x30376538613664393063646564323765396666623734663039383564366232316662666138663534383361663135633133303064346361666331333836643566, 'user3@brockport.edu'),
(24, 0x35393361336165663330363665663336643734373764306662303534396461623135343766396563613737333435393630383765653736343233396130613733, 'user4@brockport.edu'),
(25, 0x65343230373730656438663462373935643961366338306634663931646336383532633131633166643232353138333933346236656332373233383732653636, 'user5@brockport.edu'),
(26, 0x37613562393239633036613561363639386339313536396664633164346332393332633032376664363636313738313534363536336264366237656139626130, 'user6@brockport.edu'),
(27, 0x62386534313536306637663932663032343739353535343137306466393130313830366537626136313738303431653037633262373834666565343365336564, 'user7@brockport.edu'),
(28, 0x61613636386636363061393466326661643437653139643134393566373564303637646161343736366465303861373237313039333830616139353230333231, 'user8@brockport.edu'),
(29, 0x64663763623430373265313265366635623233666438346262383930656365623734356164653064373531626434643938303064383564313863376331663137, 'user9@brockport.edu'),
(30, 0x33383530623239386338333361633339303865616138373636663135616134343535313736356530626363336163383435643263303934326139633236633561, 'user10@brockport.edu');

-- --------------------------------------------------------

--
-- Stand-in structure for view `patientinfo`
-- (See below for the actual view)
--
CREATE TABLE `patientinfo` (
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `patient_appointment`
-- (See below for the actual view)
--
CREATE TABLE `patient_appointment` (
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `patient_medical_records`
-- (See below for the actual view)
--
CREATE TABLE `patient_medical_records` (
);

-- --------------------------------------------------------

--
-- Table structure for table `person`
--

CREATE TABLE `person` (
  `person_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `middle_initial` char(1) DEFAULT NULL,
  `last_name` varchar(50) NOT NULL,
  `birth_date` date NOT NULL
) ;

--
-- Dumping data for table `person`
--

INSERT INTO `person` (`person_id`, `first_name`, `middle_initial`, `last_name`, `birth_date`) VALUES
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
(11, 'John', 'A', 'Smith', '1990-07-12'),
(12, 'Jane', 'B', 'Doe', '1985-05-24'),
(13, 'Robert', 'C', 'Johnson', '1978-11-03'),
(14, 'Sarah', NULL, 'Lee', '1956-02-18'),
(15, 'Michael', 'J', 'Brown', '1962-09-07'),
(16, 'Lisa', 'K', 'Davis', '1972-12-31'),
(17, 'Christopher', 'M', 'Wilson', '1968-06-21'),
(18, 'Amanda', 'L', 'Rodriguez', '1995-04-02'),
(19, 'David', 'E', 'Martinez', '1980-08-14'),
(20, 'Jennifer', 'F', 'Thompson', '1987-10-09'),
(21, 'James', NULL, 'Anderson', '1965-07-28'),
(22, 'Elizabeth', 'G', 'Wright', '1992-03-11'),
(23, 'Matthew', 'H', 'Turner', '1974-12-08'),
(24, 'Ashley', 'I', 'Perez', '1998-01-23'),
(25, 'Ryan', 'J', 'Jackson', '1982-05-15'),
(26, 'Nicole', 'K', 'Lewis', '2003-09-22'),
(27, 'Brian', 'L', 'Green', '2013-04-26'),
(28, 'Samantha', 'M', 'King', '1983-11-17'),
(29, 'Daniel', 'N', 'Baker', '2010-02-09'),
(30, 'Lauren', 'O', 'Nelson', '2008-08-03');

-- --------------------------------------------------------

--
-- Stand-in structure for view `prior_employees`
-- (See below for the actual view)
--
CREATE TABLE `prior_employees` (
`FullName` varchar(103)
,`JobTitle` varchar(50)
,`YearsWorked` varchar(65)
,`PrimaryEmail` varchar(50)
,`SecondaryEmail` varchar(50)
,`PhoneNumbers` longtext
);

-- --------------------------------------------------------

--
-- Table structure for table `specialty`
--

CREATE TABLE `specialty` (
  `doctor_id` int(11) NOT NULL,
  `specialty` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `specialty`
--

INSERT INTO `specialty` (`doctor_id`, `specialty`) VALUES
(1, 'Internal Medicine'),
(1, 'Pediatrics'),
(2, 'Cardiology'),
(2, 'Neurology'),
(2, 'Pulmonology'),
(3, 'Orthopedics'),
(4, 'Obstetrics and Gynecology'),
(5, 'Dermatology'),
(6, 'Endocrinology'),
(6, 'Gastroenterology'),
(7, 'Pediatrics'),
(8, 'Psychiatry'),
(9, 'Neurology'),
(10, 'Family Medicine'),
(10, 'Internal Medicine'),
(10, 'Pediatrics');

-- --------------------------------------------------------

--
-- Table structure for table `telephone`
--

CREATE TABLE `telephone` (
  `person_id` int(11) NOT NULL,
  `telephone` varchar(15) NOT NULL
) ;

--
-- Dumping data for table `telephone`
--

INSERT INTO `telephone` (`person_id`, `telephone`) VALUES
(1, '5853452243'),
(1, '7318490250'),
(2, '4281973659'),
(3, '7840965123'),
(4, '6194075823'),
(5, '4978302161'),
(6, '2175960843'),
(7, '5612397480'),
(8, '9184056237'),
(9, '6803721459'),
(10, '3609287415'),
(11, '7401698352'),
(12, '5038179642'),
(13, '2916083740'),
(14, '7901346852'),
(15, '6102834979'),
(16, '9302856417'),
(17, '4671209385'),
(18, '1398562740'),
(19, '5201843769'),
(20, '8215940367'),
(21, '3195684072'),
(22, '8701564392'),
(23, '3570682419'),
(24, '4957320681'),
(25, '1584739026'),
(26, '8740352169'),
(27, '9720846351'),
(28, '3205468719'),
(29, '2189574063'),
(30, '8407621953');

-- --------------------------------------------------------

--
-- Structure for view `current_employee`
--
DROP TABLE IF EXISTS `current_employee`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `current_employee`  AS SELECT (select `f`.`FullName` from `full_name` `F` where `f`.`person_id` = `employee`.`employee_id`) AS `FullName`, `employee`.`job_title` AS `JobTitle`, concat(timestampdiff(YEAR,`employee`.`start_date`,`employee`.`end_date`),' year(s) and ',timestampdiff(MONTH,`employee`.`start_date`,`employee`.`end_date`) MOD 12,' months(s)') AS `YearsWorked`, `employee`.`primary_email` AS `PrimaryEmail`, `employee`.`secondary_email` AS `SecondaryEmail`, (select `ft`.`formatted_telephone` from `formatted_telephone` `FT` where `ft`.`person_id` = `employee`.`employee_id`) AS `PhoneNumbers` FROM (`employee` join `person` `P` on(`employee`.`employee_id` = `P`.`person_id`)) WHERE `employee`.`end_date` is null GROUP BY `P`.`last_name`, `employee`.`start_date` ;

-- --------------------------------------------------------

--
-- Structure for view `doctor_info`
--
DROP TABLE IF EXISTS `doctor_info`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `doctor_info`  AS SELECT (select concat('Dr. ',`f`.`FullName`) from `full_name` `F` where `f`.`person_id` = `DA`.`doctor_id`) AS `FullName`, group_concat(`S`.`specialty` separator ', ') AS `Specialties`, date_format(`DA`.`availability_date`,'%m/%d/%Y') AS `AvailabilityDate`, concat(date_format(`DA`.`start_time`,'%h:%i %p'),' - ',date_format(`DA`.`end_time`,'%h:%i %p')) AS `AvailabilityTime`, `D`.`primary_email` AS `PrimaryEmail`, (select `ft`.`formatted_telephone` from `formatted_telephone` `FT` where `ft`.`person_id` = `DA`.`doctor_id`) AS `TelephoneNumbers` FROM (((`doctor_availability` `DA` join `doctor` `D` on(`D`.`doctor_id` = `DA`.`doctor_id`)) join `person` `P` on(`P`.`person_id` = `D`.`doctor_id`)) join `specialty` `S` on(`S`.`doctor_id` = `D`.`doctor_id`)) GROUP BY `DA`.`availability_id` ORDER BY `P`.`last_name` ASC ;

-- --------------------------------------------------------

--
-- Structure for view `doctor_upcoming_appts`
--
DROP TABLE IF EXISTS `doctor_upcoming_appts`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `doctor_upcoming_appts`  AS SELECT `appointment`.`appointment_date` AS `AppointmentDate`, concat(`appointment`.`start_time`,' - ',`appointment`.`end_time`) AS `AppointmentTime`, `appointment`.`location` AS `AppointmentLocation`, (select concat(`person`.`first_name`,' ',`person`.`last_name`) AS `PatientFullName` from `person` where `appointment`.`patient_id` = `person`.`person_id`) AS `Name_exp_4` FROM (`doctor` join `appointment` on(`doctor`.`doctor_id` = `appointment`.`doctor_id`)) WHERE `appointment`.`appointment_date` >= curdate() ORDER BY `appointment`.`appointment_date` ASC, `appointment`.`start_time` ASC ;

-- --------------------------------------------------------

--
-- Structure for view `formatted_telephone`
--
DROP TABLE IF EXISTS `formatted_telephone`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `formatted_telephone`  AS SELECT `telephone`.`person_id` AS `person_id`, group_concat('(',substr(`telephone`.`telephone`,1,3),') ',substr(`telephone`.`telephone`,4,3),'-',substr(`telephone`.`telephone`,7) separator ', ') AS `formatted_telephone` FROM `telephone` GROUP BY `telephone`.`person_id` ;

-- --------------------------------------------------------

--
-- Structure for view `full_name`
--
DROP TABLE IF EXISTS `full_name`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `full_name`  AS SELECT `P`.`person_id` AS `person_id`, if(`P`.`middle_initial` is null,concat(`P`.`first_name`,' ',`P`.`last_name`),concat(`P`.`first_name`,' ',`P`.`middle_initial`,' ',`P`.`last_name`)) AS `FullName` FROM `person` AS `P` ;

-- --------------------------------------------------------

--
-- Structure for view `message_details`
--
DROP TABLE IF EXISTS `message_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `message_details`  AS SELECT `message`.`message_id` AS `MessageID`, `message`.`sender_id` AS `SenderID`, (select concat(`person`.`first_name`,' ',`person`.`last_name`) AS `SenderFullName` from `person` where `message`.`sender_id` = `person`.`person_id`) AS `Name_exp_3`, (select `employee`.`primary_email` from `employee` where `message`.`sender_id` = `employee`.`employee_id`) AS `SenderEmail`, (select `telephone`.`telephone` from `telephone` where `message`.`sender_id` = `telephone`.`person_id`) AS `SenderPhoneNumber`, `message`.`title` AS `Title`, `message`.`body` AS `Body` FROM `message` ;

-- --------------------------------------------------------

--
-- Structure for view `minor_status`
--
DROP TABLE IF EXISTS `minor_status`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `minor_status`  AS SELECT (select `f`.`FullName` from `full_name` `F` where `f`.`person_id` = `person`.`person_id`) AS `Name_exp_1`, `person`.`birth_date` AS `birth_date`, CASE WHEN to_days(curdate()) - to_days(`person`.`birth_date`) < 6570 THEN 'Minor' ELSE 'Adult' END AS `status` FROM `person` ORDER BY `person`.`last_name` ASC, `person`.`birth_date` ASC ;

-- --------------------------------------------------------

--
-- Structure for view `patientinfo`
--
DROP TABLE IF EXISTS `patientinfo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `patientinfo`  AS SELECT concat(`person`.`first_name`,' ',`person`.`middle_intial`,' ',`person`.`last_name`) AS `FullName`, `person`.`birth_date` AS `DateOfBirth`, `telephone`.`telephone` AS `PhoneNumber`, `patient`.`school_email` AS `Email` FROM ((`patient` join `person` on(`patient`.`patient_id` = `person`.`person_id`)) join `telephone` on(`patient`.`patient_id` = `telephone`.`person_id`)) GROUP BY `patient`.`patient_id` ORDER BY `person`.`last_name` ASC ;

-- --------------------------------------------------------

--
-- Structure for view `patient_appointment`
--
DROP TABLE IF EXISTS `patient_appointment`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `patient_appointment`  AS SELECT concat(`person`.`first_name`,' ',`person`.`middle_intial`,' ',`person`.`last_name`) AS `FullName`, `person`.`birth_date` AS `DateOfBirth`, `appointment`.`appointment_date` AS `ApptDate`, `appointment`.`start_time` AS `ApptStartTime`, `appointment`.`end_time` AS `ApptEndTime`, `appointment`.`location` AS `ApptLocation`, (select concat('Dr. ',`person`.`last_name`) AS `DrName` from `person` where `person`.`person_id` = `appointment`.`doctor_id`) AS `Name_exp_7` FROM ((`patient` join `person` on(`patient`.`patient_id` = `person`.`person_id`)) join `appointment` on(`patient`.`patient_id` = `appointment`.`patient_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `patient_medical_records`
--
DROP TABLE IF EXISTS `patient_medical_records`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `patient_medical_records`  AS SELECT concat(`person`.`first_name`,' ',`person`.`middle_intial`,' ',`person`.`last_name`) AS `FullName`, `person`.`birth_date` AS `DateOfBirth`, `immunization`.`name` AS `ImmunizationName`, `immunization`.`immunization_date` AS `DateOfImmunization`, `insurance`.`name` AS `InsuranceName`, `insurance`.`policy_number` AS `InsurancePolicyNumber`, `insurance`.`group_number` AS `InsuranceGroupNumber`, `medication`.`medication_id` AS `MedicationID`, `medication`.`start_date` AS `MedicationStartDate`, `medication`.`end_date` AS `MedicationEndDate` FROM ((((`patient` join `person` on(`patient`.`patient_id` = `person`.`person_id`)) join `immunization` on(`patient`.`patient_id` = `immunization`.`patient_id`)) join `insurance` on(`patient`.`patient_id` = `insurance`.`patient_id`)) join `medication` on(`patient`.`patient_id` = `medication`.`patient_id`)) GROUP BY `patient`.`patient_id` ORDER BY `person`.`last_name` ASC ;

-- --------------------------------------------------------

--
-- Structure for view `prior_employees`
--
DROP TABLE IF EXISTS `prior_employees`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `prior_employees`  AS SELECT (select `f`.`FullName` from `full_name` `F` where `f`.`person_id` = `employee`.`employee_id`) AS `FullName`, `employee`.`job_title` AS `JobTitle`, concat(timestampdiff(YEAR,`employee`.`start_date`,`employee`.`end_date`),' year(s) and ',timestampdiff(MONTH,`employee`.`start_date`,`employee`.`end_date`) MOD 12,' months(s)') AS `YearsWorked`, `employee`.`primary_email` AS `PrimaryEmail`, `employee`.`secondary_email` AS `SecondaryEmail`, (select `ft`.`formatted_telephone` from `formatted_telephone` `FT` where `ft`.`person_id` = `employee`.`employee_id`) AS `PhoneNumbers` FROM (`employee` join `person` `P` on(`employee`.`employee_id` = `P`.`person_id`)) WHERE `employee`.`end_date` is not null GROUP BY `P`.`last_name`, `employee`.`start_date` ;

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
