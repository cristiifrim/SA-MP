-- phpMyAdmin SQL Dump
-- version 4.8.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 12, 2018 at 03:44 PM
-- Server version: 10.1.31-MariaDB
-- PHP Version: 7.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `kingdomofstunt`
--

-- --------------------------------------------------------

--
-- Table structure for table `accounts`
--

CREATE TABLE `accounts` (
  `ID` int(7) NOT NULL,
  `Name` varchar(24) NOT NULL,
  `Password` varchar(42) NOT NULL,
  `IP` varchar(10) NOT NULL,
  `EMail` varchar(32) NOT NULL DEFAULT 'None',
  `Security` int(1) NOT NULL,
  `IsConfirmed` int(1) NOT NULL,
  `Level` int(4) NOT NULL,
  `Respect` int(5) NOT NULL,
  `ClanID` int(7) NOT NULL,
  `ClanRank` int(1) NOT NULL,
  `TagOption` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `accounts`
--

INSERT INTO `accounts` (`ID`, `Name`, `Password`, `IP`, `EMail`, `Security`, `IsConfirmed`, `Level`, `Respect`, `ClanID`, `ClanRank`, `TagOption`) VALUES
(10, '[KoS]NeaCristy', '5be0ee2cd114eb10462e9c4a8f8d086bc3a7d1bc', '127.0.0.1', 'None', 0, 0, 0, 0, 0, 0, 0),
(11, 'cristos.ViPERA', '924ce1dfe775a84817bb59b5b2858336d97747b5', '127.0.0.1', 'None', 0, 0, 0, 0, 0, 0, 0),
(12, 'actor', '7ee201fb09fb76dccb0dbcda2350e8c92711968d', '127.0.0.1', 'None', 0, 0, 1, 2, 0, 0, 0),
(13, 'rockstar', '3de4f901fffb30ac720b0e7eb654b4faa2dd03fa', '127.0.0.1', 'None', 0, 0, 0, 0, 0, 0, 0),
(14, 'hushina', '6dd0fe8001145bec4a12d0e22da711c4970d000b', '127.0.0.1', 'None', 0, 0, 0, 2, 0, 0, 0),
(15, 'xss.neacristy', 'ff4c8c0a2f8abc998cea6d21573cbe54a76a4478', '127.0.0.1', 'None', 0, 0, 0, 0, 0, 0, 0),
(16, 'CEADOINA', 'f72b8794d3f268f4f770e8aaa0a6e71f0ff06a56', '127.0.0.1', 'None', 0, 0, 0, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `clans`
--

CREATE TABLE `clans` (
  `ID` int(7) NOT NULL,
  `Name` varchar(24) NOT NULL,
  `Leader` varchar(24) NOT NULL,
  `Color` varchar(7) NOT NULL,
  `Tag` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `ID` int(2) NOT NULL,
  `Name` varchar(24) NOT NULL,
  `Skin` int(3) NOT NULL,
  `PosX` float NOT NULL,
  `PosY` float NOT NULL,
  `PosZ` float NOT NULL,
  `Rotation` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `jobs`
--

INSERT INTO `jobs` (`ID`, `Name`, `Skin`, `PosX`, `PosY`, `PosZ`, `Rotation`) VALUES
(1, 'Farmer', 161, -373.884, -1421.22, 25.727, 21.112),
(2, 'Trucker', 6, -156.556, -279.953, 3.905, 89.802),
(3, 'Pizza Delivery', 155, 2106.08, -1789.47, 13.561, 3.149),
(4, 'Courier', 91, -2665.05, -2.055, 6.133, 95.621),
(5, 'Drugs Manufacter', 134, -1444.4, -1543.34, 101.758, 13.109),
(6, 'Hunter', 179, -2410.12, -2189.77, 34.039, 269.843);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `clans`
--
ALTER TABLE `clans`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accounts`
--
ALTER TABLE `accounts`
  MODIFY `ID` int(7) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `clans`
--
ALTER TABLE `clans`
  MODIFY `ID` int(7) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `ID` int(2) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
