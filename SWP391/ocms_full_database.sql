-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: ocms
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account`
--

DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(13) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `full_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gender` tinyint(1) DEFAULT NULL,
  `avatar` longtext COLLATE utf8mb4_unicode_ci,
  `is_active` bit(1) NOT NULL,
  `role_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username_UNIQUE` (`username`),
  KEY `role_reference_account_idx` (`role_id`),
  CONSTRAINT `role_reference_account` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account`
--

LOCK TABLES `account` WRITE;
/*!40000 ALTER TABLE `account` DISABLE KEYS */;
INSERT INTO `account` VALUES (1,'admin','1','admin@ocms.com',NULL,'Admin',NULL,NULL,_binary '',1),(2,'teacher1','1','t1@ocms.com',NULL,'Teacher 1',NULL,NULL,_binary '',2),(3,'teacher2','1','t2@ocms.com',NULL,'Teacher 2',NULL,NULL,_binary '',2),(4,'student1','1','s1@ocms.com',NULL,'Student 1',NULL,NULL,_binary '',3),(5,'student2','1','s2@ocms.com',NULL,'Student 2',NULL,NULL,_binary '',3),(6,'student3','1','s3@ocms.com',NULL,'Student 3',NULL,NULL,_binary '',3);
/*!40000 ALTER TABLE `account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archived_course`
--

DROP TABLE IF EXISTS `archived_course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `archived_course` (
  `id` int NOT NULL AUTO_INCREMENT,
  `account_id` int NOT NULL,
  `course_id` int NOT NULL,
  `created_date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_archive_account_course` (`account_id`,`course_id`),
  KEY `fk_archive_course` (`course_id`),
  CONSTRAINT `fk_archive_account` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_archive_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archived_course`
--

LOCK TABLES `archived_course` WRITE;
/*!40000 ALTER TABLE `archived_course` DISABLE KEYS */;
INSERT INTO `archived_course` VALUES (1,4,9,'2026-08-19 23:20:44');
/*!40000 ALTER TABLE `archived_course` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blog`
--

DROP TABLE IF EXISTS `blog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blog` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `thumbnail` text COLLATE utf8mb4_unicode_ci,
  `brief_info` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `category_id` int DEFAULT NULL,
  `author` int NOT NULL,
  `updated_date` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('Active','Inactive') COLLATE utf8mb4_unicode_ci DEFAULT 'Active',
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  KEY `blog_author_reference_account_id_idx` (`author`),
  CONSTRAINT `blog_author_reference_account_id` FOREIGN KEY (`author`) REFERENCES `account` (`id`),
  CONSTRAINT `blog_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `blog_category` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blog`
--

LOCK TABLES `blog` WRITE;
/*!40000 ALTER TABLE `blog` DISABLE KEYS */;
INSERT INTO `blog` VALUES (1,'Bài viết Blog số 1',NULL,'Tóm tắt bài viết 1','<p>Nội dung chi tiết của blog 1 về lập trình.</p>',2,2,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(2,'Bài viết Blog số 2',NULL,'Tóm tắt bài viết 2','<p>Nội dung chi tiết của blog 2 về lập trình.</p>',1,3,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(3,'Bài viết Blog số 3',NULL,'Tóm tắt bài viết 3','<p>Nội dung chi tiết của blog 3 về lập trình.</p>',2,3,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(4,'Bài viết Blog số 4',NULL,'Tóm tắt bài viết 4','<p>Nội dung chi tiết của blog 4 về lập trình.</p>',1,3,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(5,'Bài viết Blog số 5',NULL,'Tóm tắt bài viết 5','<p>Nội dung chi tiết của blog 5 về lập trình.</p>',2,2,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(6,'Bài viết Blog số 6',NULL,'Tóm tắt bài viết 6','<p>Nội dung chi tiết của blog 6 về lập trình.</p>',1,2,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(7,'Bài viết Blog số 7',NULL,'Tóm tắt bài viết 7','<p>Nội dung chi tiết của blog 7 về lập trình.</p>',2,3,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(8,'Bài viết Blog số 8',NULL,'Tóm tắt bài viết 8','<p>Nội dung chi tiết của blog 8 về lập trình.</p>',1,3,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(9,'Bài viết Blog số 9',NULL,'Tóm tắt bài viết 9','<p>Nội dung chi tiết của blog 9 về lập trình.</p>',2,3,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(10,'Bài viết Blog số 10',NULL,'Tóm tắt bài viết 10','<p>Nội dung chi tiết của blog 10 về lập trình.</p>',1,3,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(11,'Bài viết Blog số 11',NULL,'Tóm tắt bài viết 11','<p>Nội dung chi tiết của blog 11 về lập trình.</p>',2,3,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(12,'Bài viết Blog số 12',NULL,'Tóm tắt bài viết 12','<p>Nội dung chi tiết của blog 12 về lập trình.</p>',1,3,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(13,'Bài viết Blog số 13',NULL,'Tóm tắt bài viết 13','<p>Nội dung chi tiết của blog 13 về lập trình.</p>',2,2,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(14,'Bài viết Blog số 14',NULL,'Tóm tắt bài viết 14','<p>Nội dung chi tiết của blog 14 về lập trình.</p>',1,3,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(15,'Bài viết Blog số 15',NULL,'Tóm tắt bài viết 15','<p>Nội dung chi tiết của blog 15 về lập trình.</p>',2,3,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(16,'Bài viết Blog số 16',NULL,'Tóm tắt bài viết 16','<p>Nội dung chi tiết của blog 16 về lập trình.</p>',1,2,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(17,'Bài viết Blog số 17',NULL,'Tóm tắt bài viết 17','<p>Nội dung chi tiết của blog 17 về lập trình.</p>',2,2,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(18,'Bài viết Blog số 18',NULL,'Tóm tắt bài viết 18','<p>Nội dung chi tiết của blog 18 về lập trình.</p>',1,2,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(19,'Bài viết Blog số 19',NULL,'Tóm tắt bài viết 19','<p>Nội dung chi tiết của blog 19 về lập trình.</p>',2,2,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(20,'Bài viết Blog số 20',NULL,'Tóm tắt bài viết 20','<p>Nội dung chi tiết của blog 20 về lập trình.</p>',1,2,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(21,'Bài viết Blog số 21',NULL,'Tóm tắt bài viết 21','<p>Nội dung chi tiết của blog 21 về lập trình.</p>',2,3,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(22,'Bài viết Blog số 22',NULL,'Tóm tắt bài viết 22','<p>Nội dung chi tiết của blog 22 về lập trình.</p>',1,2,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(23,'Bài viết Blog số 23',NULL,'Tóm tắt bài viết 23','<p>Nội dung chi tiết của blog 23 về lập trình.</p>',2,3,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(24,'Bài viết Blog số 24',NULL,'Tóm tắt bài viết 24','<p>Nội dung chi tiết của blog 24 về lập trình.</p>',1,3,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(25,'Bài viết Blog số 25',NULL,'Tóm tắt bài viết 25','<p>Nội dung chi tiết của blog 25 về lập trình.</p>',2,3,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(26,'Bài viết Blog số 26',NULL,'Tóm tắt bài viết 26','<p>Nội dung chi tiết của blog 26 về lập trình.</p>',1,2,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(27,'Bài viết Blog số 27',NULL,'Tóm tắt bài viết 27','<p>Nội dung chi tiết của blog 27 về lập trình.</p>',2,2,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(28,'Bài viết Blog số 28',NULL,'Tóm tắt bài viết 28','<p>Nội dung chi tiết của blog 28 về lập trình.</p>',1,3,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(29,'Bài viết Blog số 29',NULL,'Tóm tắt bài viết 29','<p>Nội dung chi tiết của blog 29 về lập trình.</p>',2,3,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(30,'Bài viết Blog số 30',NULL,'Tóm tắt bài viết 30','<p>Nội dung chi tiết của blog 30 về lập trình.</p>',1,2,'2026-08-19 22:50:15','2026-08-19 22:50:15','Active'),(31,'111','https://tse4.mm.bing.net/th/id/OIP.MjsWX2__Rpd8MpFOtHsoTgHaEK?r=0&rs=1&pid=ImgDetMain&o=7&rm=3','111123456uiop[oiuytrewWERTYUIOPUYTREWRAFSDG','ƯERTYUIOKJHGFDSAfdafsgdfgjhkl;poyitretrsdtgcxhvbjklhkjpiu97;ltiu0897685rwetdgfsvzbkfnjhl;fiouy7t67rw6etdfsghkxjldoiru9',1,4,'2026-08-19 23:19:13','2026-08-19 23:19:13','Active');
/*!40000 ALTER TABLE `blog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blog_category`
--

DROP TABLE IF EXISTS `blog_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blog_category` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_category_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blog_category`
--

LOCK TABLES `blog_category` WRITE;
/*!40000 ALTER TABLE `blog_category` DISABLE KEYS */;
INSERT INTO `blog_category` VALUES (1,'Lập trình',NULL,'2026-08-19 22:50:15','2026-08-19 22:50:15'),(2,'Đời sống IT',NULL,'2026-08-19 22:50:15','2026-08-19 22:50:15');
/*!40000 ALTER TABLE `blog_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart`
--

DROP TABLE IF EXISTS `cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart` (
  `id` int NOT NULL AUTO_INCREMENT,
  `account_id` int NOT NULL,
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `cart_account_id_fk` (`account_id`),
  CONSTRAINT `cart_account_id_fk` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart`
--

LOCK TABLES `cart` WRITE;
/*!40000 ALTER TABLE `cart` DISABLE KEYS */;
INSERT INTO `cart` VALUES (1,2,'2026-08-19 23:16:12','2026-08-19 23:16:12'),(2,4,'2026-08-19 23:19:45','2026-08-19 23:19:45');
/*!40000 ALTER TABLE `cart` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart_item`
--

DROP TABLE IF EXISTS `cart_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart_item` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cart_id` int NOT NULL,
  `course_id` int NOT NULL,
  `price` decimal(20,2) NOT NULL,
  `added_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_cart_course` (`cart_id`,`course_id`),
  KEY `cart_item_cart_id_fk` (`cart_id`),
  KEY `cart_item_course_id_fk` (`course_id`),
  CONSTRAINT `cart_item_cart_id_fk` FOREIGN KEY (`cart_id`) REFERENCES `cart` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cart_item_course_id_fk` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_item`
--

LOCK TABLES `cart_item` WRITE;
/*!40000 ALTER TABLE `cart_item` DISABLE KEYS */;
INSERT INTO `cart_item` VALUES (3,2,8,170000.00,'2026-08-19 23:21:06');
/*!40000 ALTER TABLE `cart_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (3,'C#'),(2,'C++'),(1,'Java'),(5,'JavaScript'),(4,'Python');
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `certificate`
--

DROP TABLE IF EXISTS `certificate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `certificate` (
  `id` int NOT NULL AUTO_INCREMENT,
  `template_id` int DEFAULT NULL,
  `account_id` int NOT NULL,
  `course_id` int NOT NULL,
  `course_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `student_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `certificate_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `issued_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `certificate_code_unique` (`certificate_code`),
  UNIQUE KEY `certificate_account_course_unique` (`account_id`,`course_id`),
  KEY `certificate_course_idx` (`course_id`),
  KEY `certificate_template_idx` (`template_id`),
  CONSTRAINT `certificate_account_fk` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`) ON DELETE CASCADE,
  CONSTRAINT `certificate_course_fk` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE,
  CONSTRAINT `certificate_template_fk` FOREIGN KEY (`template_id`) REFERENCES `certificate_template` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `certificate`
--

LOCK TABLES `certificate` WRITE;
/*!40000 ALTER TABLE `certificate` DISABLE KEYS */;
/*!40000 ALTER TABLE `certificate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `certificate_template`
--

DROP TABLE IF EXISTS `certificate_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `certificate_template` (
  `id` int NOT NULL AUTO_INCREMENT,
  `course_id` int NOT NULL,
  `background_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Certificate of Completion',
  `created_by` int NOT NULL,
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `certificate_template_course_unique` (`course_id`),
  KEY `certificate_template_created_by_idx` (`created_by`),
  CONSTRAINT `certificate_template_course_fk` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE,
  CONSTRAINT `certificate_template_created_by_fk` FOREIGN KEY (`created_by`) REFERENCES `account` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `certificate_template`
--

LOCK TABLES `certificate_template` WRITE;
/*!40000 ALTER TABLE `certificate_template` DISABLE KEYS */;
/*!40000 ALTER TABLE `certificate_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course`
--

DROP TABLE IF EXISTS `course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext COLLATE utf8mb4_unicode_ci,
  `thumbnail` text COLLATE utf8mb4_unicode_ci,
  `rating` int NOT NULL DEFAULT '0',
  `price` float NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int NOT NULL,
  `category_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`),
  KEY `course_created_by_reference_account_id_idx` (`created_by`),
  KEY `course_category_id_reference_category_id_idx` (`category_id`),
  CONSTRAINT `course_category_id_reference_category_id` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE CASCADE,
  CONSTRAINT `course_created_by_reference_account_id` FOREIGN KEY (`created_by`) REFERENCES `account` (`id`) ON DELETE CASCADE,
  CONSTRAINT `course_chk_1` CHECK ((`rating` between 0 and 5)),
  CONSTRAINT `course_chk_2` CHECK ((`price` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course`
--

LOCK TABLES `course` WRITE;
/*!40000 ALTER TABLE `course` DISABLE KEYS */;
INSERT INTO `course` VALUES (1,'Khóa học lập trình 1','Khóa học lập trình chuyên sâu 1. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',5,390000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',3,2),(2,'Khóa học lập trình 2','Khóa học lập trình chuyên sâu 2. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,280000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',2,3),(3,'Khóa học lập trình 3','Khóa học lập trình chuyên sâu 3. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',3,260000,'active','2026-08-19 22:50:14','2026-08-20 09:56:43',3,4),(4,'Khóa học lập trình 4','Khóa học lập trình chuyên sâu 4. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,470000,'active','2026-08-19 22:50:14','2026-08-20 09:56:43',2,5),(5,'Khóa học lập trình 5','Khóa học lập trình chuyên sâu 5. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,340000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',3,1),(6,'Khóa học lập trình 6','Khóa học lập trình chuyên sâu 6. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,220000,'active','2026-08-19 22:50:14','2026-08-19 23:01:15',2,2),(7,'Khóa học lập trình 7','Khóa học lập trình chuyên sâu 7. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,230000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',3,3),(8,'Khóa học lập trình 8','Khóa học lập trình chuyên sâu 8. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,170000,'active','2026-08-19 22:50:14','2026-08-19 23:01:15',2,4),(9,'Khóa học lập trình 9','Khóa học lập trình chuyên sâu 9. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,260000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',3,5),(10,'Khóa học lập trình 10','Khóa học lập trình chuyên sâu 10. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',5,380000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',2,1),(11,'Khóa học lập trình 11','Khóa học lập trình chuyên sâu 11. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,100000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',3,2),(12,'Khóa học lập trình 12','Khóa học lập trình chuyên sâu 12. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,400000,'active','2026-08-19 22:50:14','2026-08-19 23:01:15',2,3),(13,'Khóa học lập trình 13','Khóa học lập trình chuyên sâu 13. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,100000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',3,4),(14,'Khóa học lập trình 14','Khóa học lập trình chuyên sâu 14. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',5,190000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',2,5),(15,'Khóa học lập trình 15','Khóa học lập trình chuyên sâu 15. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,110000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',3,1),(16,'Khóa học lập trình 16','Khóa học lập trình chuyên sâu 16. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',5,310000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',2,2),(17,'Khóa học lập trình 17','Khóa học lập trình chuyên sâu 17. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,430000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',3,3),(18,'Khóa học lập trình 18','Khóa học lập trình chuyên sâu 18. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,180000,'active','2026-08-19 22:50:14','2026-08-19 23:01:15',2,4),(19,'Khóa học lập trình 19','Khóa học lập trình chuyên sâu 19. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,130000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',3,5),(20,'Khóa học lập trình 20','Khóa học lập trình chuyên sâu 20. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',5,300000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',2,1),(21,'Khóa học lập trình 21','Khóa học lập trình chuyên sâu 21. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',3,370000,'active','2026-08-19 22:50:14','2026-08-19 23:01:15',3,2),(22,'Khóa học lập trình 22','Khóa học lập trình chuyên sâu 22. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,340000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',2,3),(23,'Khóa học lập trình 23','Khóa học lập trình chuyên sâu 23. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,170000,'active','2026-08-19 22:50:14','2026-08-20 09:56:43',3,4),(24,'Khóa học lập trình 24','Khóa học lập trình chuyên sâu 24. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,280000,'active','2026-08-19 22:50:14','2026-08-19 23:01:15',2,5),(25,'Khóa học lập trình 25','Khóa học lập trình chuyên sâu 25. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',3,100000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',3,1),(26,'Khóa học lập trình 26','Khóa học lập trình chuyên sâu 26. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,150000,'active','2026-08-19 22:50:14','2026-08-20 09:56:43',2,2),(27,'Khóa học lập trình 27','Khóa học lập trình chuyên sâu 27. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,250000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',3,3),(28,'Khóa học lập trình 28','Khóa học lập trình chuyên sâu 28. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,110000,'active','2026-08-19 22:50:14','2026-08-20 09:56:43',2,4),(29,'Khóa học lập trình 29','Khóa học lập trình chuyên sâu 29. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,440000,'active','2026-08-19 22:50:14','2026-08-20 15:40:14',3,5),(30,'Khóa học lập trình 30','Khóa học lập trình chuyên sâu 30. <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/eIrMbAQSU34\" frameborder=\"0\" allowfullscreen></iframe>','course_thumb.jpg',4,130000,'active','2026-08-19 22:50:14','2026-08-19 23:01:15',2,1),(31,'a khoa hoc a','nhớ ngày xưa','/SWP391/assets/css/img/OIP (1).webp',5,1,'active','2026-08-20 08:29:15','2026-08-20 09:56:43',2,3);
/*!40000 ALTER TABLE `course` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_approval_log`
--

DROP TABLE IF EXISTS `course_approval_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_approval_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `course_id` int NOT NULL,
  `action` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `old_status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `new_status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `actor_id` int NOT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_cal_actor` (`actor_id`),
  KEY `idx_cal_course` (`course_id`),
  KEY `idx_cal_created` (`created_date`),
  CONSTRAINT `fk_cal_actor` FOREIGN KEY (`actor_id`) REFERENCES `account` (`id`),
  CONSTRAINT `fk_cal_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_approval_log`
--

LOCK TABLES `course_approval_log` WRITE;
/*!40000 ALTER TABLE `course_approval_log` DISABLE KEYS */;
INSERT INTO `course_approval_log` VALUES (1,31,'SUBMIT','draft','pending',2,'','0:0:0:0:0:0:0:1','2026-08-20 08:29:14');
/*!40000 ALTER TABLE `course_approval_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lesson`
--

DROP TABLE IF EXISTS `lesson`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lesson` (
  `id` int NOT NULL AUTO_INCREMENT,
  `section_id` int DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `type` enum('video','document','quiz','file','text') COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_number` int NOT NULL DEFAULT '1',
  `duration_minutes` int DEFAULT NULL,
  `status` enum('active','inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `lesson_section_id_fk` (`section_id`),
  CONSTRAINT `lesson_section_id_fk` FOREIGN KEY (`section_id`) REFERENCES `section` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=304 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lesson`
--

LOCK TABLES `lesson` WRITE;
/*!40000 ALTER TABLE `lesson` DISABLE KEYS */;
INSERT INTO `lesson` VALUES (1,1,'Bài học Video 1',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(2,1,'Bài học Text 1',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(3,1,'Bài Quiz 1',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(4,2,'Bài học Video 2',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(5,2,'Bài học Text 2',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(6,2,'Bài Quiz 2',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(7,3,'Bài học Video 3',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(8,3,'Bài học Text 3',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(9,3,'Bài Quiz 3',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(10,4,'Bài học Video 4',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(11,4,'Bài học Text 4',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(12,4,'Bài Quiz 4',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(13,5,'Bài học Video 5',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(14,5,'Bài học Text 5',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(15,5,'Bài Quiz 5',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(16,6,'Bài học Video 6',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(17,6,'Bài học Text 6',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(18,6,'Bài Quiz 6',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(19,7,'Bài học Video 7',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(20,7,'Bài học Text 7',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(21,7,'Bài Quiz 7',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(22,8,'Bài học Video 8',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(23,8,'Bài học Text 8',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(24,8,'Bài Quiz 8',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(25,9,'Bài học Video 9',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(26,9,'Bài học Text 9',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(27,9,'Bài Quiz 9',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(28,10,'Bài học Video 10',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(29,10,'Bài học Text 10',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(30,10,'Bài Quiz 10',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(31,11,'Bài học Video 11',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(32,11,'Bài học Text 11',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(33,11,'Bài Quiz 11',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(34,12,'Bài học Video 12',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(35,12,'Bài học Text 12',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(36,12,'Bài Quiz 12',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(37,13,'Bài học Video 13',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(38,13,'Bài học Text 13',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(39,13,'Bài Quiz 13',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(40,14,'Bài học Video 14',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(41,14,'Bài học Text 14',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(42,14,'Bài Quiz 14',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(43,15,'Bài học Video 15',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(44,15,'Bài học Text 15',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(45,15,'Bài Quiz 15',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(46,16,'Bài học Video 16',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(47,16,'Bài học Text 16',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(48,16,'Bài Quiz 16',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(49,17,'Bài học Video 17',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(50,17,'Bài học Text 17',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(51,17,'Bài Quiz 17',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(52,18,'Bài học Video 18',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(53,18,'Bài học Text 18',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(54,18,'Bài Quiz 18',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(55,19,'Bài học Video 19',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(56,19,'Bài học Text 19',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(57,19,'Bài Quiz 19',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(58,20,'Bài học Video 20',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(59,20,'Bài học Text 20',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(60,20,'Bài Quiz 20',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(61,21,'Bài học Video 21',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(62,21,'Bài học Text 21',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(63,21,'Bài Quiz 21',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(64,22,'Bài học Video 22',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(65,22,'Bài học Text 22',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(66,22,'Bài Quiz 22',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(67,23,'Bài học Video 23',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(68,23,'Bài học Text 23',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(69,23,'Bài Quiz 23',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(70,24,'Bài học Video 24',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(71,24,'Bài học Text 24',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(72,24,'Bài Quiz 24',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(73,25,'Bài học Video 25',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(74,25,'Bài học Text 25',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(75,25,'Bài Quiz 25',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(76,26,'Bài học Video 26',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(77,26,'Bài học Text 26',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(78,26,'Bài Quiz 26',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(79,27,'Bài học Video 27',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(80,27,'Bài học Text 27',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(81,27,'Bài Quiz 27',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(82,28,'Bài học Video 28',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(83,28,'Bài học Text 28',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(84,28,'Bài Quiz 28',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(85,29,'Bài học Video 29',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(86,29,'Bài học Text 29',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(87,29,'Bài Quiz 29',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(88,30,'Bài học Video 30',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(89,30,'Bài học Text 30',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(90,30,'Bài Quiz 30',NULL,'quiz',3,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(91,31,'Bài học Video 31',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(92,31,'Bài học Text 31',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(93,32,'Bài học Video 32',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(94,32,'Bài học Text 32',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(95,33,'Bài học Video 33',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(96,33,'Bài học Text 33',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(97,34,'Bài học Video 34',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(98,34,'Bài học Text 34',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(99,35,'Bài học Video 35',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(100,35,'Bài học Text 35',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(101,36,'Bài học Video 36',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(102,36,'Bài học Text 36',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(103,37,'Bài học Video 37',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(104,37,'Bài học Text 37',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(105,38,'Bài học Video 38',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(106,38,'Bài học Text 38',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(107,39,'Bài học Video 39',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(108,39,'Bài học Text 39',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(109,40,'Bài học Video 40',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(110,40,'Bài học Text 40',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(111,41,'Bài học Video 41',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(112,41,'Bài học Text 41',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(113,42,'Bài học Video 42',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(114,42,'Bài học Text 42',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(115,43,'Bài học Video 43',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(116,43,'Bài học Text 43',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(117,44,'Bài học Video 44',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(118,44,'Bài học Text 44',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(119,45,'Bài học Video 45',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(120,45,'Bài học Text 45',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(121,46,'Bài học Video 46',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(122,46,'Bài học Text 46',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(123,47,'Bài học Video 47',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(124,47,'Bài học Text 47',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(125,48,'Bài học Video 48',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(126,48,'Bài học Text 48',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(127,49,'Bài học Video 49',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(128,49,'Bài học Text 49',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(129,50,'Bài học Video 50',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(130,50,'Bài học Text 50',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(131,51,'Bài học Video 51',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(132,51,'Bài học Text 51',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(133,52,'Bài học Video 52',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(134,52,'Bài học Text 52',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(135,53,'Bài học Video 53',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(136,53,'Bài học Text 53',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(137,54,'Bài học Video 54',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(138,54,'Bài học Text 54',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(139,55,'Bài học Video 55',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(140,55,'Bài học Text 55',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(141,56,'Bài học Video 56',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(142,56,'Bài học Text 56',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(143,57,'Bài học Video 57',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(144,57,'Bài học Text 57',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(145,58,'Bài học Video 58',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(146,58,'Bài học Text 58',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(147,59,'Bài học Video 59',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(148,59,'Bài học Text 59',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(149,60,'Bài học Video 60',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(150,60,'Bài học Text 60',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(151,61,'Bài học Video 61',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(152,61,'Bài học Text 61',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(153,62,'Bài học Video 62',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(154,62,'Bài học Text 62',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(155,63,'Bài học Video 63',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(156,63,'Bài học Text 63',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(157,64,'Bài học Video 64',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(158,64,'Bài học Text 64',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(159,65,'Bài học Video 65',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(160,65,'Bài học Text 65',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(161,66,'Bài học Video 66',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(162,66,'Bài học Text 66',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(163,67,'Bài học Video 67',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(164,67,'Bài học Text 67',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(165,68,'Bài học Video 68',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(166,68,'Bài học Text 68',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(167,69,'Bài học Video 69',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(168,69,'Bài học Text 69',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(169,70,'Bài học Video 70',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(170,70,'Bài học Text 70',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(171,71,'Bài học Video 71',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(172,71,'Bài học Text 71',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(173,72,'Bài học Video 72',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(174,72,'Bài học Text 72',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(175,73,'Bài học Video 73',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(176,73,'Bài học Text 73',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(177,74,'Bài học Video 74',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(178,74,'Bài học Text 74',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(179,75,'Bài học Video 75',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(180,75,'Bài học Text 75',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(181,76,'Bài học Video 76',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(182,76,'Bài học Text 76',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(183,77,'Bài học Video 77',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(184,77,'Bài học Text 77',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(185,78,'Bài học Video 78',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(186,78,'Bài học Text 78',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(187,79,'Bài học Video 79',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(188,79,'Bài học Text 79',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(189,80,'Bài học Video 80',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(190,80,'Bài học Text 80',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(191,81,'Bài học Video 81',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(192,81,'Bài học Text 81',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(193,82,'Bài học Video 82',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(194,82,'Bài học Text 82',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(195,83,'Bài học Video 83',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(196,83,'Bài học Text 83',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(197,84,'Bài học Video 84',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(198,84,'Bài học Text 84',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(199,85,'Bài học Video 85',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(200,85,'Bài học Text 85',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(201,86,'Bài học Video 86',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(202,86,'Bài học Text 86',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(203,87,'Bài học Video 87',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(204,87,'Bài học Text 87',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(205,88,'Bài học Video 88',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(206,88,'Bài học Text 88',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(207,89,'Bài học Video 89',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(208,89,'Bài học Text 89',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(209,90,'Bài học Video 90',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(210,90,'Bài học Text 90',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(211,91,'Bài học Video 91',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(212,91,'Bài học Text 91',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(213,92,'Bài học Video 92',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(214,92,'Bài học Text 92',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(215,93,'Bài học Video 93',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(216,93,'Bài học Text 93',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(217,94,'Bài học Video 94',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(218,94,'Bài học Text 94',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(219,95,'Bài học Video 95',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(220,95,'Bài học Text 95',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(221,96,'Bài học Video 96',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(222,96,'Bài học Text 96',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(223,97,'Bài học Video 97',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(224,97,'Bài học Text 97',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(225,98,'Bài học Video 98',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(226,98,'Bài học Text 98',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(227,99,'Bài học Video 99',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(228,99,'Bài học Text 99',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(229,100,'Bài học Video 100',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(230,100,'Bài học Text 100',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(231,101,'Bài học Video 101',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(232,101,'Bài học Text 101',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(233,102,'Bài học Video 102',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(234,102,'Bài học Text 102',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(235,103,'Bài học Video 103',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(236,103,'Bài học Text 103',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(237,104,'Bài học Video 104',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(238,104,'Bài học Text 104',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(239,105,'Bài học Video 105',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(240,105,'Bài học Text 105',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(241,106,'Bài học Video 106',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(242,106,'Bài học Text 106',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(243,107,'Bài học Video 107',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(244,107,'Bài học Text 107',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(245,108,'Bài học Video 108',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(246,108,'Bài học Text 108',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(247,109,'Bài học Video 109',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(248,109,'Bài học Text 109',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(249,110,'Bài học Video 110',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(250,110,'Bài học Text 110',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(251,111,'Bài học Video 111',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(252,111,'Bài học Text 111',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(253,112,'Bài học Video 112',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(254,112,'Bài học Text 112',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(255,113,'Bài học Video 113',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(256,113,'Bài học Text 113',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(257,114,'Bài học Video 114',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(258,114,'Bài học Text 114',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(259,115,'Bài học Video 115',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(260,115,'Bài học Text 115',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(261,116,'Bài học Video 116',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(262,116,'Bài học Text 116',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(263,117,'Bài học Video 117',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(264,117,'Bài học Text 117',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(265,118,'Bài học Video 118',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(266,118,'Bài học Text 118',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(267,119,'Bài học Video 119',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(268,119,'Bài học Text 119',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(269,120,'Bài học Video 120',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(270,120,'Bài học Text 120',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(271,121,'Bài học Video 121',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(272,121,'Bài học Text 121',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(273,122,'Bài học Video 122',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(274,122,'Bài học Text 122',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(275,123,'Bài học Video 123',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(276,123,'Bài học Text 123',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(277,124,'Bài học Video 124',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(278,124,'Bài học Text 124',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(279,125,'Bài học Video 125',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(280,125,'Bài học Text 125',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(281,126,'Bài học Video 126',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(282,126,'Bài học Text 126',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(283,127,'Bài học Video 127',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(284,127,'Bài học Text 127',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(285,128,'Bài học Video 128',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(286,128,'Bài học Text 128',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(287,129,'Bài học Video 129',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(288,129,'Bài học Text 129',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(289,130,'Bài học Video 130',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(290,130,'Bài học Text 130',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(291,131,'Bài học Video 131',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(292,131,'Bài học Text 131',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(293,132,'Bài học Video 132',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(294,132,'Bài học Text 132',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(295,133,'Bài học Video 133',NULL,'video',1,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(296,133,'Bài học Text 133',NULL,'text',2,NULL,'active','2026-08-19 22:50:15','2026-08-19 22:50:15',NULL),(297,NULL,'1','1','quiz',1,7,'active','2026-08-19 23:16:07','2026-08-19 23:16:07',2),(298,NULL,'IQ test','không dùng điện thoại','quiz',1,4,'active','2026-08-20 08:06:47','2026-08-20 08:06:47',2),(300,134,'bánh mì video',NULL,'video',1,NULL,'active','2026-08-20 09:02:31','2026-08-20 09:02:31',NULL),(301,134,'test',NULL,'quiz',2,NULL,'active','2026-08-20 09:02:31','2026-08-20 09:02:31',NULL),(302,134,'Bài Quiz ',NULL,'quiz',3,NULL,'active','2026-08-20 09:02:31','2026-08-20 09:02:31',NULL),(303,135,'Bài học ',NULL,'text',1,NULL,'active','2026-08-20 09:31:00','2026-08-20 09:31:00',NULL);
/*!40000 ALTER TABLE `lesson` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lesson_document`
--

DROP TABLE IF EXISTS `lesson_document`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lesson_document` (
  `lesson_id` int NOT NULL,
  `document_url` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `document_type` enum('pdf','doc','ppt','other') COLLATE utf8mb4_unicode_ci DEFAULT 'pdf',
  `page_count` int DEFAULT NULL,
  `download_allowed` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`lesson_id`),
  CONSTRAINT `document_lesson_id_fk` FOREIGN KEY (`lesson_id`) REFERENCES `lesson` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lesson_document`
--

LOCK TABLES `lesson_document` WRITE;
/*!40000 ALTER TABLE `lesson_document` DISABLE KEYS */;
/*!40000 ALTER TABLE `lesson_document` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lesson_file`
--

DROP TABLE IF EXISTS `lesson_file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lesson_file` (
  `lesson_id` int NOT NULL,
  `file_url` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_size` int DEFAULT NULL,
  PRIMARY KEY (`lesson_id`),
  CONSTRAINT `file_lesson_id_fk` FOREIGN KEY (`lesson_id`) REFERENCES `lesson` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lesson_file`
--

LOCK TABLES `lesson_file` WRITE;
/*!40000 ALTER TABLE `lesson_file` DISABLE KEYS */;
/*!40000 ALTER TABLE `lesson_file` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lesson_progress`
--

DROP TABLE IF EXISTS `lesson_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lesson_progress` (
  `id` int NOT NULL AUTO_INCREMENT,
  `account_id` int NOT NULL,
  `lesson_id` int NOT NULL,
  `completed` tinyint(1) NOT NULL DEFAULT '0',
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_lesson_progress` (`account_id`,`lesson_id`),
  KEY `fk_progress_lesson` (`lesson_id`),
  CONSTRAINT `fk_progress_account` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_progress_lesson` FOREIGN KEY (`lesson_id`) REFERENCES `lesson` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lesson_progress`
--

LOCK TABLES `lesson_progress` WRITE;
/*!40000 ALTER TABLE `lesson_progress` DISABLE KEYS */;
INSERT INTO `lesson_progress` VALUES (1,4,105,1,'2026-08-19 23:20:36'),(2,4,106,1,'2026-08-19 23:20:38'),(3,4,107,1,'2026-08-19 23:20:40'),(4,4,108,1,'2026-08-19 23:20:42');
/*!40000 ALTER TABLE `lesson_progress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lesson_quiz`
--

DROP TABLE IF EXISTS `lesson_quiz`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lesson_quiz` (
  `id` int NOT NULL AUTO_INCREMENT,
  `lesson_id` int DEFAULT NULL,
  `number_of_questions` int NOT NULL DEFAULT '10' COMMENT 'Số lượng câu hỏi',
  `time_limit_minutes` int NOT NULL DEFAULT '15' COMMENT 'Thời gian làm bài',
  `max_retakes` int DEFAULT NULL,
  `passing_score` int NOT NULL DEFAULT '50',
  `question_group_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `quiz_lesson_id_fk_idx` (`lesson_id`),
  KEY `question_group_id` (`question_group_id`),
  CONSTRAINT `lesson_quiz_ibfk_1` FOREIGN KEY (`question_group_id`) REFERENCES `question_group` (`id`) ON DELETE SET NULL,
  CONSTRAINT `quiz_lesson_id_fk` FOREIGN KEY (`lesson_id`) REFERENCES `lesson` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lesson_quiz`
--

LOCK TABLES `lesson_quiz` WRITE;
/*!40000 ALTER TABLE `lesson_quiz` DISABLE KEYS */;
INSERT INTO `lesson_quiz` VALUES (1,3,20,30,2,80,NULL),(2,6,20,30,-1,80,NULL),(3,9,18,30,2,80,NULL),(4,12,17,30,-1,80,NULL),(5,15,18,30,3,80,NULL),(6,18,15,30,-1,80,NULL),(7,21,17,30,1,80,NULL),(8,24,19,30,-1,80,NULL),(9,27,19,30,1,80,NULL),(10,30,18,30,-1,80,NULL),(11,33,20,30,3,80,NULL),(12,36,20,30,-1,80,NULL),(13,39,15,30,2,80,NULL),(14,42,15,30,-1,80,NULL),(15,45,16,30,2,80,NULL),(16,48,17,30,-1,80,NULL),(17,51,20,30,1,80,NULL),(18,54,15,30,-1,80,NULL),(19,57,17,30,2,80,NULL),(20,60,18,30,-1,80,NULL),(21,63,19,30,3,80,NULL),(22,66,15,30,-1,80,NULL),(23,69,16,30,1,80,NULL),(24,72,19,30,-1,80,NULL),(25,75,15,30,3,80,NULL),(26,78,20,30,-1,80,NULL),(27,81,20,30,2,80,NULL),(28,84,15,30,-1,80,NULL),(29,87,20,30,2,80,NULL),(30,90,18,30,-1,80,NULL),(31,297,10,15,1,50,NULL),(32,298,10,15,1,80,NULL);
/*!40000 ALTER TABLE `lesson_quiz` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lesson_text`
--

DROP TABLE IF EXISTS `lesson_text`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lesson_text` (
  `lesson_id` int NOT NULL,
  `content` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`lesson_id`),
  CONSTRAINT `text_lesson_id_fk` FOREIGN KEY (`lesson_id`) REFERENCES `lesson` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lesson_text`
--

LOCK TABLES `lesson_text` WRITE;
/*!40000 ALTER TABLE `lesson_text` DISABLE KEYS */;
INSERT INTO `lesson_text` VALUES (2,'<p>Nội dung bài học 2 chi tiết...</p>'),(4,'<p>Nội dung bài học 4 chi tiết...</p>'),(8,'<p>Nội dung bài học 8 chi tiết...</p>'),(10,'<p>Nội dung bài học 10 chi tiết...</p>'),(14,'<p>Nội dung bài học 14 chi tiết...</p>'),(16,'<p>Nội dung bài học 16 chi tiết...</p>'),(20,'<p>Nội dung bài học 20 chi tiết...</p>'),(22,'<p>Nội dung bài học 22 chi tiết...</p>'),(26,'<p>Nội dung bài học 26 chi tiết...</p>'),(28,'<p>Nội dung bài học 28 chi tiết...</p>'),(32,'<p>Nội dung bài học 32 chi tiết...</p>'),(34,'<p>Nội dung bài học 34 chi tiết...</p>'),(38,'<p>Nội dung bài học 38 chi tiết...</p>'),(40,'<p>Nội dung bài học 40 chi tiết...</p>'),(44,'<p>Nội dung bài học 44 chi tiết...</p>'),(46,'<p>Nội dung bài học 46 chi tiết...</p>'),(50,'<p>Nội dung bài học 50 chi tiết...</p>'),(52,'<p>Nội dung bài học 52 chi tiết...</p>'),(56,'<p>Nội dung bài học 56 chi tiết...</p>'),(58,'<p>Nội dung bài học 58 chi tiết...</p>'),(62,'<p>Nội dung bài học 62 chi tiết...</p>'),(64,'<p>Nội dung bài học 64 chi tiết...</p>'),(68,'<p>Nội dung bài học 68 chi tiết...</p>'),(70,'<p>Nội dung bài học 70 chi tiết...</p>'),(74,'<p>Nội dung bài học 74 chi tiết...</p>'),(76,'<p>Nội dung bài học 76 chi tiết...</p>'),(80,'<p>Nội dung bài học 80 chi tiết...</p>'),(82,'<p>Nội dung bài học 82 chi tiết...</p>'),(86,'<p>Nội dung bài học 86 chi tiết...</p>'),(88,'<p>Nội dung bài học 88 chi tiết...</p>'),(92,'<p>Nội dung bài học 92 chi tiết...</p>'),(94,'<p>Nội dung bài học 94 chi tiết...</p>'),(96,'<p>Nội dung bài học 96 chi tiết...</p>'),(98,'<p>Nội dung bài học 98 chi tiết...</p>'),(100,'<p>Nội dung bài học 100 chi tiết...</p>'),(102,'<p>Nội dung bài học 102 chi tiết...</p>'),(104,'<p>Nội dung bài học 104 chi tiết...</p>'),(106,'<p>Nội dung bài học 106 chi tiết...</p>'),(108,'<p>Nội dung bài học 108 chi tiết...</p>'),(110,'<p>Nội dung bài học 110 chi tiết...</p>'),(112,'<p>Nội dung bài học 112 chi tiết...</p>'),(114,'<p>Nội dung bài học 114 chi tiết...</p>'),(116,'<p>Nội dung bài học 116 chi tiết...</p>'),(118,'<p>Nội dung bài học 118 chi tiết...</p>'),(120,'<p>Nội dung bài học 120 chi tiết...</p>'),(122,'<p>Nội dung bài học 122 chi tiết...</p>'),(124,'<p>Nội dung bài học 124 chi tiết...</p>'),(126,'<p>Nội dung bài học 126 chi tiết...</p>'),(128,'<p>Nội dung bài học 128 chi tiết...</p>'),(130,'<p>Nội dung bài học 130 chi tiết...</p>'),(132,'<p>Nội dung bài học 132 chi tiết...</p>'),(134,'<p>Nội dung bài học 134 chi tiết...</p>'),(136,'<p>Nội dung bài học 136 chi tiết...</p>'),(138,'<p>Nội dung bài học 138 chi tiết...</p>'),(140,'<p>Nội dung bài học 140 chi tiết...</p>'),(142,'<p>Nội dung bài học 142 chi tiết...</p>'),(144,'<p>Nội dung bài học 144 chi tiết...</p>'),(146,'<p>Nội dung bài học 146 chi tiết...</p>'),(148,'<p>Nội dung bài học 148 chi tiết...</p>'),(150,'<p>Nội dung bài học 150 chi tiết...</p>'),(152,'<p>Nội dung bài học 152 chi tiết...</p>'),(154,'<p>Nội dung bài học 154 chi tiết...</p>'),(156,'<p>Nội dung bài học 156 chi tiết...</p>'),(158,'<p>Nội dung bài học 158 chi tiết...</p>'),(160,'<p>Nội dung bài học 160 chi tiết...</p>'),(162,'<p>Nội dung bài học 162 chi tiết...</p>'),(164,'<p>Nội dung bài học 164 chi tiết...</p>'),(166,'<p>Nội dung bài học 166 chi tiết...</p>'),(168,'<p>Nội dung bài học 168 chi tiết...</p>'),(170,'<p>Nội dung bài học 170 chi tiết...</p>'),(172,'<p>Nội dung bài học 172 chi tiết...</p>'),(174,'<p>Nội dung bài học 174 chi tiết...</p>'),(176,'<p>Nội dung bài học 176 chi tiết...</p>'),(178,'<p>Nội dung bài học 178 chi tiết...</p>'),(180,'<p>Nội dung bài học 180 chi tiết...</p>'),(182,'<p>Nội dung bài học 182 chi tiết...</p>'),(184,'<p>Nội dung bài học 184 chi tiết...</p>'),(186,'<p>Nội dung bài học 186 chi tiết...</p>'),(188,'<p>Nội dung bài học 188 chi tiết...</p>'),(190,'<p>Nội dung bài học 190 chi tiết...</p>'),(192,'<p>Nội dung bài học 192 chi tiết...</p>'),(194,'<p>Nội dung bài học 194 chi tiết...</p>'),(196,'<p>Nội dung bài học 196 chi tiết...</p>'),(198,'<p>Nội dung bài học 198 chi tiết...</p>'),(200,'<p>Nội dung bài học 200 chi tiết...</p>'),(202,'<p>Nội dung bài học 202 chi tiết...</p>'),(204,'<p>Nội dung bài học 204 chi tiết...</p>'),(206,'<p>Nội dung bài học 206 chi tiết...</p>'),(208,'<p>Nội dung bài học 208 chi tiết...</p>'),(210,'<p>Nội dung bài học 210 chi tiết...</p>'),(212,'<p>Nội dung bài học 212 chi tiết...</p>'),(214,'<p>Nội dung bài học 214 chi tiết...</p>'),(216,'<p>Nội dung bài học 216 chi tiết...</p>'),(218,'<p>Nội dung bài học 218 chi tiết...</p>'),(220,'<p>Nội dung bài học 220 chi tiết...</p>'),(222,'<p>Nội dung bài học 222 chi tiết...</p>'),(224,'<p>Nội dung bài học 224 chi tiết...</p>'),(226,'<p>Nội dung bài học 226 chi tiết...</p>'),(228,'<p>Nội dung bài học 228 chi tiết...</p>'),(230,'<p>Nội dung bài học 230 chi tiết...</p>'),(232,'<p>Nội dung bài học 232 chi tiết...</p>'),(234,'<p>Nội dung bài học 234 chi tiết...</p>'),(236,'<p>Nội dung bài học 236 chi tiết...</p>'),(238,'<p>Nội dung bài học 238 chi tiết...</p>'),(240,'<p>Nội dung bài học 240 chi tiết...</p>'),(242,'<p>Nội dung bài học 242 chi tiết...</p>'),(244,'<p>Nội dung bài học 244 chi tiết...</p>'),(246,'<p>Nội dung bài học 246 chi tiết...</p>'),(248,'<p>Nội dung bài học 248 chi tiết...</p>'),(250,'<p>Nội dung bài học 250 chi tiết...</p>'),(252,'<p>Nội dung bài học 252 chi tiết...</p>'),(254,'<p>Nội dung bài học 254 chi tiết...</p>'),(256,'<p>Nội dung bài học 256 chi tiết...</p>'),(258,'<p>Nội dung bài học 258 chi tiết...</p>'),(260,'<p>Nội dung bài học 260 chi tiết...</p>'),(262,'<p>Nội dung bài học 262 chi tiết...</p>'),(264,'<p>Nội dung bài học 264 chi tiết...</p>'),(266,'<p>Nội dung bài học 266 chi tiết...</p>'),(268,'<p>Nội dung bài học 268 chi tiết...</p>'),(270,'<p>Nội dung bài học 270 chi tiết...</p>'),(272,'<p>Nội dung bài học 272 chi tiết...</p>'),(274,'<p>Nội dung bài học 274 chi tiết...</p>'),(276,'<p>Nội dung bài học 276 chi tiết...</p>'),(278,'<p>Nội dung bài học 278 chi tiết...</p>'),(280,'<p>Nội dung bài học 280 chi tiết...</p>'),(282,'<p>Nội dung bài học 282 chi tiết...</p>'),(284,'<p>Nội dung bài học 284 chi tiết...</p>'),(286,'<p>Nội dung bài học 286 chi tiết...</p>'),(288,'<p>Nội dung bài học 288 chi tiết...</p>'),(290,'<p>Nội dung bài học 290 chi tiết...</p>'),(292,'<p>Nội dung bài học 292 chi tiết...</p>'),(294,'<p>Nội dung bài học 294 chi tiết...</p>'),(296,'<p>Nội dung bài học 296 chi tiết...</p>'),(301,'Quiz ID: 32'),(302,'Quiz ID: 33'),(303,'<div class=\'lesson-text-block\' style=\'margin-bottom: 20px; font-size: 16px; line-height: 1.6;\'>wwwwwwww</div><div class=\'lesson-img-block\' style=\'text-align: center; margin-bottom: 20px;\'><img src=\'/SWP391/assets/css/img/OIP (1).webp\' style=\'max-width: 100%; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);\'></div>');
/*!40000 ALTER TABLE `lesson_text` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lesson_video`
--

DROP TABLE IF EXISTS `lesson_video`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lesson_video` (
  `id` int NOT NULL AUTO_INCREMENT,
  `lesson_id` int NOT NULL,
  `video_url` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `video_provider` enum('youtube','vimeo','local','other') COLLATE utf8mb4_unicode_ci DEFAULT 'youtube',
  `video_duration` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `lesson_video_id_idx` (`lesson_id`),
  CONSTRAINT `lesson_video_id` FOREIGN KEY (`lesson_id`) REFERENCES `lesson` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=135 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lesson_video`
--

LOCK TABLES `lesson_video` WRITE;
/*!40000 ALTER TABLE `lesson_video` DISABLE KEYS */;
INSERT INTO `lesson_video` VALUES (1,1,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(2,5,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(3,7,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(4,11,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(5,13,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(6,17,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(7,19,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(8,23,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(9,25,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(10,29,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(11,31,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(12,35,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(13,37,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(14,41,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(15,43,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(16,47,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(17,49,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(18,53,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(19,55,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(20,59,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(21,61,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(22,65,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(23,67,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(24,71,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(25,73,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(26,77,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(27,79,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(28,83,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(29,85,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(30,89,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(31,91,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(32,93,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(33,95,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(34,97,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(35,99,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(36,101,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(37,103,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(38,105,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(39,107,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(40,109,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(41,111,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(42,113,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(43,115,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(44,117,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(45,119,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(46,121,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(47,123,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(48,125,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(49,127,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(50,129,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(51,131,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(52,133,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(53,135,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(54,137,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(55,139,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(56,141,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(57,143,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(58,145,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(59,147,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(60,149,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(61,151,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(62,153,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(63,155,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(64,157,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(65,159,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(66,161,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(67,163,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(68,165,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(69,167,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(70,169,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(71,171,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(72,173,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(73,175,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(74,177,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(75,179,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(76,181,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(77,183,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(78,185,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(79,187,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(80,189,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(81,191,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(82,193,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(83,195,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(84,197,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(85,199,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(86,201,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(87,203,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(88,205,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(89,207,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(90,209,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(91,211,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(92,213,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(93,215,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(94,217,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(95,219,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(96,221,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(97,223,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(98,225,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(99,227,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(100,229,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(101,231,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(102,233,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(103,235,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(104,237,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(105,239,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(106,241,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(107,243,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(108,245,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(109,247,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(110,249,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(111,251,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(112,253,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(113,255,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(114,257,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(115,259,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(116,261,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(117,263,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(118,265,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(119,267,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(120,269,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(121,271,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(122,273,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(123,275,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(124,277,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(125,279,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(126,281,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(127,283,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(128,285,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(129,287,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(130,289,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(131,291,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(132,293,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(133,295,'https://www.youtube.com/watch?v=eIrMbAQSU34','youtube',NULL),(134,300,'BXBcYFPhOp8','youtube',NULL);
/*!40000 ALTER TABLE `lesson_video` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payout_request`
--

DROP TABLE IF EXISTS `payout_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payout_request` (
  `id` int NOT NULL AUTO_INCREMENT,
  `teacher_id` int NOT NULL,
  `bank_account_id` int NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `admin_note` text COLLATE utf8mb4_unicode_ci,
  `transaction_code` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `processed_by` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `processed_at` datetime DEFAULT NULL,
  `bank_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bank_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `account_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `account_holder` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_payout_teacher` (`teacher_id`),
  KEY `idx_payout_bank` (`bank_account_id`),
  KEY `idx_payout_admin` (`processed_by`),
  CONSTRAINT `fk_payout_admin` FOREIGN KEY (`processed_by`) REFERENCES `account` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_payout_bank` FOREIGN KEY (`bank_account_id`) REFERENCES `teacher_bank_account` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_payout_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `account` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payout_request`
--

LOCK TABLES `payout_request` WRITE;
/*!40000 ALTER TABLE `payout_request` DISABLE KEYS */;
/*!40000 ALTER TABLE `payout_request` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `question_bank`
--

DROP TABLE IF EXISTS `question_bank`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `question_bank` (
  `id` int NOT NULL AUTO_INCREMENT,
  `course_id` int DEFAULT NULL,
  `lesson_id` int DEFAULT NULL COMMENT 'Gắn với bài học cụ thể (nếu có)',
  `question_text` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `points` int DEFAULT '1',
  `status` enum('active','inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `group_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_qb_course` (`course_id`),
  KEY `fk_qb_lesson` (`lesson_id`),
  KEY `group_id` (`group_id`),
  CONSTRAINT `fk_qb_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_qb_lesson` FOREIGN KEY (`lesson_id`) REFERENCES `lesson` (`id`) ON DELETE CASCADE,
  CONSTRAINT `question_bank_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `question_group` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `question_bank`
--

LOCK TABLES `question_bank` WRITE;
/*!40000 ALTER TABLE `question_bank` DISABLE KEYS */;
INSERT INTO `question_bank` VALUES (1,1,3,'Câu hỏi số 1 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(2,1,3,'Câu hỏi số 2 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(3,1,3,'Câu hỏi số 3 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(4,1,3,'Câu hỏi số 4 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(5,1,3,'Câu hỏi số 5 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(6,1,3,'Câu hỏi số 6 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(7,1,3,'Câu hỏi số 7 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(8,1,3,'Câu hỏi số 8 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(9,1,3,'Câu hỏi số 9 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(10,1,3,'Câu hỏi số 10 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(11,1,3,'Câu hỏi số 11 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(12,1,3,'Câu hỏi số 12 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(13,1,3,'Câu hỏi số 13 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(14,1,3,'Câu hỏi số 14 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(15,1,3,'Câu hỏi số 15 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(16,2,6,'Câu hỏi số 1 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(17,2,6,'Câu hỏi số 2 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(18,2,6,'Câu hỏi số 3 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(19,2,6,'Câu hỏi số 4 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(20,2,6,'Câu hỏi số 5 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(21,2,6,'Câu hỏi số 6 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(22,2,6,'Câu hỏi số 7 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(23,2,6,'Câu hỏi số 8 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(24,2,6,'Câu hỏi số 9 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(25,2,6,'Câu hỏi số 10 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(26,2,6,'Câu hỏi số 11 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(27,2,6,'Câu hỏi số 12 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(28,2,6,'Câu hỏi số 13 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(29,2,6,'Câu hỏi số 14 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(30,2,6,'Câu hỏi số 15 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(31,3,9,'Câu hỏi số 1 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(32,3,9,'Câu hỏi số 2 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(33,3,9,'Câu hỏi số 3 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(34,3,9,'Câu hỏi số 4 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(35,3,9,'Câu hỏi số 5 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(36,3,9,'Câu hỏi số 6 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(37,3,9,'Câu hỏi số 7 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(38,3,9,'Câu hỏi số 8 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(39,3,9,'Câu hỏi số 9 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(40,3,9,'Câu hỏi số 10 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(41,3,9,'Câu hỏi số 11 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(42,3,9,'Câu hỏi số 12 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(43,3,9,'Câu hỏi số 13 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(44,3,9,'Câu hỏi số 14 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(45,3,9,'Câu hỏi số 15 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(46,4,12,'Câu hỏi số 1 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(47,4,12,'Câu hỏi số 2 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(48,4,12,'Câu hỏi số 3 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(49,4,12,'Câu hỏi số 4 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(50,4,12,'Câu hỏi số 5 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(51,4,12,'Câu hỏi số 6 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(52,4,12,'Câu hỏi số 7 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(53,4,12,'Câu hỏi số 8 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(54,4,12,'Câu hỏi số 9 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(55,4,12,'Câu hỏi số 10 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(56,4,12,'Câu hỏi số 11 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(57,4,12,'Câu hỏi số 12 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(58,4,12,'Câu hỏi số 13 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(59,4,12,'Câu hỏi số 14 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(60,4,12,'Câu hỏi số 15 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(61,5,15,'Câu hỏi số 1 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(62,5,15,'Câu hỏi số 2 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(63,5,15,'Câu hỏi số 3 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(64,5,15,'Câu hỏi số 4 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(65,5,15,'Câu hỏi số 5 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(66,5,15,'Câu hỏi số 6 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(67,5,15,'Câu hỏi số 7 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(68,5,15,'Câu hỏi số 8 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(69,5,15,'Câu hỏi số 9 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(70,5,15,'Câu hỏi số 10 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(71,5,15,'Câu hỏi số 11 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(72,5,15,'Câu hỏi số 12 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(73,5,15,'Câu hỏi số 13 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(74,5,15,'Câu hỏi số 14 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(75,5,15,'Câu hỏi số 15 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(76,6,18,'Câu hỏi số 1 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(77,6,18,'Câu hỏi số 2 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(78,6,18,'Câu hỏi số 3 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(79,6,18,'Câu hỏi số 4 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(80,6,18,'Câu hỏi số 5 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(81,6,18,'Câu hỏi số 6 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(82,6,18,'Câu hỏi số 7 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(83,6,18,'Câu hỏi số 8 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(84,6,18,'Câu hỏi số 9 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(85,6,18,'Câu hỏi số 10 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(86,6,18,'Câu hỏi số 11 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(87,6,18,'Câu hỏi số 12 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(88,6,18,'Câu hỏi số 13 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(89,6,18,'Câu hỏi số 14 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(90,6,18,'Câu hỏi số 15 của Quiz ',1,'active','2026-08-19 22:50:15',NULL),(91,NULL,297,'1',1,'active','2026-08-19 23:16:07',NULL),(92,NULL,298,'1+1 = ?',1,'active','2026-08-20 08:06:47',NULL),(93,NULL,298,'tại sao con gà qua đường',1,'active','2026-08-20 08:06:47',NULL),(94,NULL,298,'cách học giỏi lên',1,'active','2026-08-20 08:06:47',NULL),(95,NULL,298,'có mấy con gà đang nhìn ',1,'active','2026-08-20 08:06:47',NULL),(96,NULL,298,'người bình thường ngủ như nào',1,'active','2026-08-20 08:06:47',NULL);
/*!40000 ALTER TABLE `question_bank` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `question_bank_answer`
--

DROP TABLE IF EXISTS `question_bank_answer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `question_bank_answer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_bank_id` int NOT NULL,
  `answer_text` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_correct` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_qba_question` (`question_bank_id`),
  CONSTRAINT `fk_qba_question` FOREIGN KEY (`question_bank_id`) REFERENCES `question_bank` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=405 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `question_bank_answer`
--

LOCK TABLES `question_bank_answer` WRITE;
/*!40000 ALTER TABLE `question_bank_answer` DISABLE KEYS */;
INSERT INTO `question_bank_answer` VALUES (1,1,'Đáp án đúng',1),(2,1,'Đáp án sai 1',0),(3,1,'Đáp án sai 2',0),(4,1,'Đáp án sai 3',0),(5,2,'Đáp án đúng',1),(6,2,'Đáp án sai 1',0),(7,2,'Đáp án sai 2',0),(8,2,'Đáp án sai 3',0),(9,3,'Đáp án đúng',1),(10,3,'Đáp án sai 1',0),(11,3,'Đáp án sai 2',0),(12,3,'Đáp án sai 3',0),(13,4,'Đáp án đúng',1),(14,4,'Đáp án sai 1',0),(15,4,'Đáp án sai 2',0),(16,4,'Đáp án sai 3',0),(17,5,'Đáp án đúng',1),(18,5,'Đáp án sai 1',0),(19,5,'Đáp án sai 2',0),(20,5,'Đáp án sai 3',0),(21,6,'Đáp án đúng',1),(22,6,'Đáp án sai 1',0),(23,6,'Đáp án sai 2',0),(24,6,'Đáp án sai 3',0),(25,7,'Đáp án đúng',1),(26,7,'Đáp án sai 1',0),(27,7,'Đáp án sai 2',0),(28,7,'Đáp án sai 3',0),(29,8,'Đáp án đúng',1),(30,8,'Đáp án sai 1',0),(31,8,'Đáp án sai 2',0),(32,8,'Đáp án sai 3',0),(33,9,'Đáp án đúng',1),(34,9,'Đáp án sai 1',0),(35,9,'Đáp án sai 2',0),(36,9,'Đáp án sai 3',0),(37,10,'Đáp án đúng',1),(38,10,'Đáp án sai 1',0),(39,10,'Đáp án sai 2',0),(40,10,'Đáp án sai 3',0),(41,11,'Đáp án đúng',1),(42,11,'Đáp án sai 1',0),(43,11,'Đáp án sai 2',0),(44,11,'Đáp án sai 3',0),(45,12,'Đáp án đúng',1),(46,12,'Đáp án sai 1',0),(47,12,'Đáp án sai 2',0),(48,12,'Đáp án sai 3',0),(49,13,'Đáp án đúng',1),(50,13,'Đáp án sai 1',0),(51,13,'Đáp án sai 2',0),(52,13,'Đáp án sai 3',0),(53,14,'Đáp án đúng',1),(54,14,'Đáp án sai 1',0),(55,14,'Đáp án sai 2',0),(56,14,'Đáp án sai 3',0),(57,15,'Đáp án đúng',1),(58,15,'Đáp án sai 1',0),(59,15,'Đáp án sai 2',0),(60,15,'Đáp án sai 3',0),(61,16,'Đáp án đúng',1),(62,16,'Đáp án sai 1',0),(63,16,'Đáp án sai 2',0),(64,16,'Đáp án sai 3',0),(65,17,'Đáp án đúng',1),(66,17,'Đáp án sai 1',0),(67,17,'Đáp án sai 2',0),(68,17,'Đáp án sai 3',0),(69,18,'Đáp án đúng',1),(70,18,'Đáp án sai 1',0),(71,18,'Đáp án sai 2',0),(72,18,'Đáp án sai 3',0),(73,19,'Đáp án đúng',1),(74,19,'Đáp án sai 1',0),(75,19,'Đáp án sai 2',0),(76,19,'Đáp án sai 3',0),(77,20,'Đáp án đúng',1),(78,20,'Đáp án sai 1',0),(79,20,'Đáp án sai 2',0),(80,20,'Đáp án sai 3',0),(81,21,'Đáp án đúng',1),(82,21,'Đáp án sai 1',0),(83,21,'Đáp án sai 2',0),(84,21,'Đáp án sai 3',0),(85,22,'Đáp án đúng',1),(86,22,'Đáp án sai 1',0),(87,22,'Đáp án sai 2',0),(88,22,'Đáp án sai 3',0),(89,23,'Đáp án đúng',1),(90,23,'Đáp án sai 1',0),(91,23,'Đáp án sai 2',0),(92,23,'Đáp án sai 3',0),(93,24,'Đáp án đúng',1),(94,24,'Đáp án sai 1',0),(95,24,'Đáp án sai 2',0),(96,24,'Đáp án sai 3',0),(97,25,'Đáp án đúng',1),(98,25,'Đáp án sai 1',0),(99,25,'Đáp án sai 2',0),(100,25,'Đáp án sai 3',0),(101,26,'Đáp án đúng',1),(102,26,'Đáp án sai 1',0),(103,26,'Đáp án sai 2',0),(104,26,'Đáp án sai 3',0),(105,27,'Đáp án đúng',1),(106,27,'Đáp án sai 1',0),(107,27,'Đáp án sai 2',0),(108,27,'Đáp án sai 3',0),(109,28,'Đáp án đúng',1),(110,28,'Đáp án sai 1',0),(111,28,'Đáp án sai 2',0),(112,28,'Đáp án sai 3',0),(113,29,'Đáp án đúng',1),(114,29,'Đáp án sai 1',0),(115,29,'Đáp án sai 2',0),(116,29,'Đáp án sai 3',0),(117,30,'Đáp án đúng',1),(118,30,'Đáp án sai 1',0),(119,30,'Đáp án sai 2',0),(120,30,'Đáp án sai 3',0),(121,31,'Đáp án đúng',1),(122,31,'Đáp án sai 1',0),(123,31,'Đáp án sai 2',0),(124,31,'Đáp án sai 3',0),(125,32,'Đáp án đúng',1),(126,32,'Đáp án sai 1',0),(127,32,'Đáp án sai 2',0),(128,32,'Đáp án sai 3',0),(129,33,'Đáp án đúng',1),(130,33,'Đáp án sai 1',0),(131,33,'Đáp án sai 2',0),(132,33,'Đáp án sai 3',0),(133,34,'Đáp án đúng',1),(134,34,'Đáp án sai 1',0),(135,34,'Đáp án sai 2',0),(136,34,'Đáp án sai 3',0),(137,35,'Đáp án đúng',1),(138,35,'Đáp án sai 1',0),(139,35,'Đáp án sai 2',0),(140,35,'Đáp án sai 3',0),(141,36,'Đáp án đúng',1),(142,36,'Đáp án sai 1',0),(143,36,'Đáp án sai 2',0),(144,36,'Đáp án sai 3',0),(145,37,'Đáp án đúng',1),(146,37,'Đáp án sai 1',0),(147,37,'Đáp án sai 2',0),(148,37,'Đáp án sai 3',0),(149,38,'Đáp án đúng',1),(150,38,'Đáp án sai 1',0),(151,38,'Đáp án sai 2',0),(152,38,'Đáp án sai 3',0),(153,39,'Đáp án đúng',1),(154,39,'Đáp án sai 1',0),(155,39,'Đáp án sai 2',0),(156,39,'Đáp án sai 3',0),(157,40,'Đáp án đúng',1),(158,40,'Đáp án sai 1',0),(159,40,'Đáp án sai 2',0),(160,40,'Đáp án sai 3',0),(161,41,'Đáp án đúng',1),(162,41,'Đáp án sai 1',0),(163,41,'Đáp án sai 2',0),(164,41,'Đáp án sai 3',0),(165,42,'Đáp án đúng',1),(166,42,'Đáp án sai 1',0),(167,42,'Đáp án sai 2',0),(168,42,'Đáp án sai 3',0),(169,43,'Đáp án đúng',1),(170,43,'Đáp án sai 1',0),(171,43,'Đáp án sai 2',0),(172,43,'Đáp án sai 3',0),(173,44,'Đáp án đúng',1),(174,44,'Đáp án sai 1',0),(175,44,'Đáp án sai 2',0),(176,44,'Đáp án sai 3',0),(177,45,'Đáp án đúng',1),(178,45,'Đáp án sai 1',0),(179,45,'Đáp án sai 2',0),(180,45,'Đáp án sai 3',0),(181,46,'Đáp án đúng',1),(182,46,'Đáp án sai 1',0),(183,46,'Đáp án sai 2',0),(184,46,'Đáp án sai 3',0),(185,47,'Đáp án đúng',1),(186,47,'Đáp án sai 1',0),(187,47,'Đáp án sai 2',0),(188,47,'Đáp án sai 3',0),(189,48,'Đáp án đúng',1),(190,48,'Đáp án sai 1',0),(191,48,'Đáp án sai 2',0),(192,48,'Đáp án sai 3',0),(193,49,'Đáp án đúng',1),(194,49,'Đáp án sai 1',0),(195,49,'Đáp án sai 2',0),(196,49,'Đáp án sai 3',0),(197,50,'Đáp án đúng',1),(198,50,'Đáp án sai 1',0),(199,50,'Đáp án sai 2',0),(200,50,'Đáp án sai 3',0),(201,51,'Đáp án đúng',1),(202,51,'Đáp án sai 1',0),(203,51,'Đáp án sai 2',0),(204,51,'Đáp án sai 3',0),(205,52,'Đáp án đúng',1),(206,52,'Đáp án sai 1',0),(207,52,'Đáp án sai 2',0),(208,52,'Đáp án sai 3',0),(209,53,'Đáp án đúng',1),(210,53,'Đáp án sai 1',0),(211,53,'Đáp án sai 2',0),(212,53,'Đáp án sai 3',0),(213,54,'Đáp án đúng',1),(214,54,'Đáp án sai 1',0),(215,54,'Đáp án sai 2',0),(216,54,'Đáp án sai 3',0),(217,55,'Đáp án đúng',1),(218,55,'Đáp án sai 1',0),(219,55,'Đáp án sai 2',0),(220,55,'Đáp án sai 3',0),(221,56,'Đáp án đúng',1),(222,56,'Đáp án sai 1',0),(223,56,'Đáp án sai 2',0),(224,56,'Đáp án sai 3',0),(225,57,'Đáp án đúng',1),(226,57,'Đáp án sai 1',0),(227,57,'Đáp án sai 2',0),(228,57,'Đáp án sai 3',0),(229,58,'Đáp án đúng',1),(230,58,'Đáp án sai 1',0),(231,58,'Đáp án sai 2',0),(232,58,'Đáp án sai 3',0),(233,59,'Đáp án đúng',1),(234,59,'Đáp án sai 1',0),(235,59,'Đáp án sai 2',0),(236,59,'Đáp án sai 3',0),(237,60,'Đáp án đúng',1),(238,60,'Đáp án sai 1',0),(239,60,'Đáp án sai 2',0),(240,60,'Đáp án sai 3',0),(241,61,'Đáp án đúng',1),(242,61,'Đáp án sai 1',0),(243,61,'Đáp án sai 2',0),(244,61,'Đáp án sai 3',0),(245,62,'Đáp án đúng',1),(246,62,'Đáp án sai 1',0),(247,62,'Đáp án sai 2',0),(248,62,'Đáp án sai 3',0),(249,63,'Đáp án đúng',1),(250,63,'Đáp án sai 1',0),(251,63,'Đáp án sai 2',0),(252,63,'Đáp án sai 3',0),(253,64,'Đáp án đúng',1),(254,64,'Đáp án sai 1',0),(255,64,'Đáp án sai 2',0),(256,64,'Đáp án sai 3',0),(257,65,'Đáp án đúng',1),(258,65,'Đáp án sai 1',0),(259,65,'Đáp án sai 2',0),(260,65,'Đáp án sai 3',0),(261,66,'Đáp án đúng',1),(262,66,'Đáp án sai 1',0),(263,66,'Đáp án sai 2',0),(264,66,'Đáp án sai 3',0),(265,67,'Đáp án đúng',1),(266,67,'Đáp án sai 1',0),(267,67,'Đáp án sai 2',0),(268,67,'Đáp án sai 3',0),(269,68,'Đáp án đúng',1),(270,68,'Đáp án sai 1',0),(271,68,'Đáp án sai 2',0),(272,68,'Đáp án sai 3',0),(273,69,'Đáp án đúng',1),(274,69,'Đáp án sai 1',0),(275,69,'Đáp án sai 2',0),(276,69,'Đáp án sai 3',0),(277,70,'Đáp án đúng',1),(278,70,'Đáp án sai 1',0),(279,70,'Đáp án sai 2',0),(280,70,'Đáp án sai 3',0),(281,71,'Đáp án đúng',1),(282,71,'Đáp án sai 1',0),(283,71,'Đáp án sai 2',0),(284,71,'Đáp án sai 3',0),(285,72,'Đáp án đúng',1),(286,72,'Đáp án sai 1',0),(287,72,'Đáp án sai 2',0),(288,72,'Đáp án sai 3',0),(289,73,'Đáp án đúng',1),(290,73,'Đáp án sai 1',0),(291,73,'Đáp án sai 2',0),(292,73,'Đáp án sai 3',0),(293,74,'Đáp án đúng',1),(294,74,'Đáp án sai 1',0),(295,74,'Đáp án sai 2',0),(296,74,'Đáp án sai 3',0),(297,75,'Đáp án đúng',1),(298,75,'Đáp án sai 1',0),(299,75,'Đáp án sai 2',0),(300,75,'Đáp án sai 3',0),(301,76,'Đáp án đúng',1),(302,76,'Đáp án sai 1',0),(303,76,'Đáp án sai 2',0),(304,76,'Đáp án sai 3',0),(305,77,'Đáp án đúng',1),(306,77,'Đáp án sai 1',0),(307,77,'Đáp án sai 2',0),(308,77,'Đáp án sai 3',0),(309,78,'Đáp án đúng',1),(310,78,'Đáp án sai 1',0),(311,78,'Đáp án sai 2',0),(312,78,'Đáp án sai 3',0),(313,79,'Đáp án đúng',1),(314,79,'Đáp án sai 1',0),(315,79,'Đáp án sai 2',0),(316,79,'Đáp án sai 3',0),(317,80,'Đáp án đúng',1),(318,80,'Đáp án sai 1',0),(319,80,'Đáp án sai 2',0),(320,80,'Đáp án sai 3',0),(321,81,'Đáp án đúng',1),(322,81,'Đáp án sai 1',0),(323,81,'Đáp án sai 2',0),(324,81,'Đáp án sai 3',0),(325,82,'Đáp án đúng',1),(326,82,'Đáp án sai 1',0),(327,82,'Đáp án sai 2',0),(328,82,'Đáp án sai 3',0),(329,83,'Đáp án đúng',1),(330,83,'Đáp án sai 1',0),(331,83,'Đáp án sai 2',0),(332,83,'Đáp án sai 3',0),(333,84,'Đáp án đúng',1),(334,84,'Đáp án sai 1',0),(335,84,'Đáp án sai 2',0),(336,84,'Đáp án sai 3',0),(337,85,'Đáp án đúng',1),(338,85,'Đáp án sai 1',0),(339,85,'Đáp án sai 2',0),(340,85,'Đáp án sai 3',0),(341,86,'Đáp án đúng',1),(342,86,'Đáp án sai 1',0),(343,86,'Đáp án sai 2',0),(344,86,'Đáp án sai 3',0),(345,87,'Đáp án đúng',1),(346,87,'Đáp án sai 1',0),(347,87,'Đáp án sai 2',0),(348,87,'Đáp án sai 3',0),(349,88,'Đáp án đúng',1),(350,88,'Đáp án sai 1',0),(351,88,'Đáp án sai 2',0),(352,88,'Đáp án sai 3',0),(353,89,'Đáp án đúng',1),(354,89,'Đáp án sai 1',0),(355,89,'Đáp án sai 2',0),(356,89,'Đáp án sai 3',0),(357,90,'Đáp án đúng',1),(358,90,'Đáp án sai 1',0),(359,90,'Đáp án sai 2',0),(360,90,'Đáp án sai 3',0),(361,91,'1',1),(362,91,'2',0),(363,91,'222',0),(364,91,'2222',0),(365,92,'1',0),(366,92,'2',1),(367,92,'222',0),(368,92,'2222',0),(369,93,'nhà đối diện',1),(370,93,' đi kfc',0),(371,93,'đói ',0),(372,93,'buồn ngủ',0),(373,94,'học',1),(374,94,'ngủ',0),(375,95,'bỏ qua',0),(376,95,'troll',0),(377,95,'2',1),(378,95,'0',0),(379,96,' 6 tiếng buổi sáng',1),(380,96,'ko ngủ ',0),(381,96,'ngủ 3 tiếng như 8 tiếng',0),(382,96,'ngủ thêm 30 p',0);
/*!40000 ALTER TABLE `question_bank_answer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `question_group`
--

DROP TABLE IF EXISTS `question_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `question_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `course_id` int NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `question_group_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `question_group`
--

LOCK TABLES `question_group` WRITE;
/*!40000 ALTER TABLE `question_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `question_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quiz_attempt`
--

DROP TABLE IF EXISTS `quiz_attempt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quiz_attempt` (
  `id` int NOT NULL AUTO_INCREMENT,
  `account_id` int NOT NULL,
  `quiz_id` int NOT NULL COMMENT 'Tham chiếu đến lesson_quiz',
  `attempt_number` int NOT NULL DEFAULT '1' COMMENT 'Lần làm bài thứ mấy',
  `score` decimal(5,2) DEFAULT NULL,
  `passed` tinyint(1) DEFAULT NULL,
  `start_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `end_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `attempt_account_id_fk` (`account_id`),
  KEY `attempt_quiz_id_fk_idx` (`quiz_id`),
  CONSTRAINT `attempt_account_id_fk` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`) ON DELETE CASCADE,
  CONSTRAINT `attempt_quiz_id_fk` FOREIGN KEY (`quiz_id`) REFERENCES `lesson_quiz` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quiz_attempt`
--

LOCK TABLES `quiz_attempt` WRITE;
/*!40000 ALTER TABLE `quiz_attempt` DISABLE KEYS */;
INSERT INTO `quiz_attempt` VALUES (1,2,3,1,100.00,1,'2026-08-19 21:02:33','2026-08-19 21:02:33'),(2,3,3,1,100.00,1,'2026-08-19 21:22:13','2026-08-19 21:22:13'),(3,2,3,2,100.00,1,'2026-08-19 21:33:10','2026-08-19 21:33:10'),(4,2,3,3,100.00,1,'2026-08-19 21:33:56','2026-08-19 21:33:56'),(5,2,3,4,100.00,1,'2026-08-19 21:41:32','2026-08-19 21:41:32'),(6,2,3,5,100.00,1,'2026-08-19 21:42:57','2026-08-19 21:42:57'),(7,2,3,6,100.00,1,'2026-08-19 21:48:04','2026-08-19 21:48:04'),(8,3,3,2,100.00,1,'2026-08-19 21:56:38','2026-08-19 21:56:38'),(9,2,7,1,0.00,0,'2026-08-20 08:03:34','2026-08-20 08:03:34'),(10,2,32,1,80.00,1,'2026-08-20 09:06:04','2026-08-20 09:06:04');
/*!40000 ALTER TABLE `quiz_attempt` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quiz_attempt_answer`
--

DROP TABLE IF EXISTS `quiz_attempt_answer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quiz_attempt_answer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `attempt_id` int NOT NULL,
  `question_bank_id` int NOT NULL COMMENT 'Câu hỏi được bốc từ ngân hàng',
  `selected_answer_id` int NOT NULL COMMENT 'Đáp án học viên chọn từ ngân hàng',
  PRIMARY KEY (`id`),
  KEY `attempt_id` (`attempt_id`),
  KEY `question_bank_id` (`question_bank_id`),
  KEY `selected_answer_id` (`selected_answer_id`),
  CONSTRAINT `qaa_answer_bank_fk` FOREIGN KEY (`selected_answer_id`) REFERENCES `question_bank_answer` (`id`) ON DELETE CASCADE,
  CONSTRAINT `qaa_attempt_fk` FOREIGN KEY (`attempt_id`) REFERENCES `quiz_attempt` (`id`) ON DELETE CASCADE,
  CONSTRAINT `qaa_question_bank_fk` FOREIGN KEY (`question_bank_id`) REFERENCES `question_bank` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quiz_attempt_answer`
--

LOCK TABLES `quiz_attempt_answer` WRITE;
/*!40000 ALTER TABLE `quiz_attempt_answer` DISABLE KEYS */;
INSERT INTO `quiz_attempt_answer` VALUES (1,1,10,29),(2,2,10,29),(3,3,10,29),(4,4,10,29),(5,5,10,29),(6,6,10,29),(7,7,10,29),(8,8,10,29),(9,10,92,366),(10,10,93,371),(11,10,94,373),(12,10,95,377),(13,10,96,379);
/*!40000 ALTER TABLE `quiz_attempt_answer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `registration`
--

DROP TABLE IF EXISTS `registration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `registration` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `account_id` int DEFAULT NULL,
  `registration_time` date NOT NULL,
  `course_id` int NOT NULL,
  `package` enum('Basic','Standard','Premium') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Standard',
  `total_cost` decimal(20,2) NOT NULL,
  `status` enum('Pending','Approved') COLLATE utf8mb4_unicode_ci DEFAULT 'Pending',
  `valid_from` timestamp NOT NULL,
  `valid_to` timestamp NOT NULL,
  `last_updated_by` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `registration_account_id_fk` (`account_id`),
  KEY `registration_updated_by_fk` (`last_updated_by`),
  CONSTRAINT `registration_account_id_fk` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`) ON DELETE SET NULL,
  CONSTRAINT `registration_course_id_fk` FOREIGN KEY (`id`) REFERENCES `course` (`id`) ON DELETE CASCADE,
  CONSTRAINT `registration_updated_by_fk` FOREIGN KEY (`last_updated_by`) REFERENCES `account` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `registration`
--

LOCK TABLES `registration` WRITE;
/*!40000 ALTER TABLE `registration` DISABLE KEYS */;
INSERT INTO `registration` VALUES (1,'s1@ocms.com',4,'2026-08-19',9,'Standard',260000.00,'Approved','2026-08-19 16:20:10','2027-08-19 16:20:10',4);
/*!40000 ALTER TABLE `registration` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `review`
--

DROP TABLE IF EXISTS `review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `review` (
  `id` int NOT NULL AUTO_INCREMENT,
  `course_id` int NOT NULL,
  `account_id` int NOT NULL,
  `rating` int NOT NULL,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `review_course_id_idx` (`course_id`),
  KEY `review_account_id_idx` (`account_id`),
  CONSTRAINT `review_account_id_fk` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`) ON DELETE CASCADE,
  CONSTRAINT `review_course_id_fk` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE,
  CONSTRAINT `review_rating_chk` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review`
--

LOCK TABLES `review` WRITE;
/*!40000 ALTER TABLE `review` DISABLE KEYS */;
INSERT INTO `review` VALUES (1,1,6,5,'Khóa học số 1 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(2,1,4,5,'Khóa học số 1 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(3,1,5,4,'Khóa học số 1 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(4,2,5,4,'Khóa học số 2 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(5,2,4,3,'Khóa học số 2 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(6,3,4,3,'Khóa học số 3 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(7,4,6,5,'Khóa học số 4 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(8,4,4,3,'Khóa học số 4 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(9,4,6,5,'Khóa học số 4 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(10,4,6,3,'Khóa học số 4 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(11,5,5,3,'Khóa học số 5 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(12,5,6,4,'Khóa học số 5 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(13,5,4,4,'Khóa học số 5 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(14,6,4,3,'Khóa học số 6 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(15,6,6,5,'Khóa học số 6 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(16,6,5,4,'Khóa học số 6 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(17,7,6,3,'Khóa học số 7 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(18,7,5,4,'Khóa học số 7 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(19,7,4,4,'Khóa học số 7 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(20,7,6,3,'Khóa học số 7 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(21,8,4,3,'Khóa học số 8 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(22,8,6,4,'Khóa học số 8 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(23,8,6,4,'Khóa học số 8 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(24,8,4,4,'Khóa học số 8 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(25,9,4,3,'Khóa học số 9 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(26,9,6,5,'Khóa học số 9 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(27,9,4,4,'Khóa học số 9 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(28,9,5,4,'Khóa học số 9 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(29,10,6,5,'Khóa học số 10 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(30,10,6,5,'Khóa học số 10 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(31,11,6,3,'Khóa học số 11 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(32,11,4,4,'Khóa học số 11 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(33,12,5,5,'Khóa học số 12 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(34,12,6,3,'Khóa học số 12 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(35,12,4,3,'Khóa học số 12 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(36,13,4,3,'Khóa học số 13 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(37,13,5,5,'Khóa học số 13 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(38,13,5,3,'Khóa học số 13 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(39,14,4,4,'Khóa học số 14 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(40,14,4,5,'Khóa học số 14 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(41,15,6,4,'Khóa học số 15 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(42,15,6,4,'Khóa học số 15 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(43,15,4,5,'Khóa học số 15 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(44,16,4,5,'Khóa học số 16 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(45,16,6,3,'Khóa học số 16 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(46,16,5,5,'Khóa học số 16 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(47,16,6,5,'Khóa học số 16 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(48,17,5,4,'Khóa học số 17 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(49,18,5,3,'Khóa học số 18 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(50,18,4,4,'Khóa học số 18 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(51,18,5,3,'Khóa học số 18 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(52,18,4,4,'Khóa học số 18 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(53,19,6,5,'Khóa học số 19 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(54,19,5,3,'Khóa học số 19 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(55,20,5,5,'Khóa học số 20 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(56,21,4,3,'Khóa học số 21 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(57,21,6,3,'Khóa học số 21 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(58,21,4,3,'Khóa học số 21 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(59,21,5,3,'Khóa học số 21 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(60,22,4,5,'Khóa học số 22 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(61,22,6,4,'Khóa học số 22 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(62,22,6,3,'Khóa học số 22 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(63,22,6,5,'Khóa học số 22 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(64,23,5,4,'Khóa học số 23 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(65,24,6,4,'Khóa học số 24 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(66,25,4,3,'Khóa học số 25 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(67,25,4,3,'Khóa học số 25 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(68,26,5,3,'Khóa học số 26 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(69,26,6,4,'Khóa học số 26 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(70,26,5,5,'Khóa học số 26 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(71,27,5,4,'Khóa học số 27 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(72,27,4,4,'Khóa học số 27 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(73,27,4,3,'Khóa học số 27 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(74,27,4,5,'Khóa học số 27 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(75,28,4,3,'Khóa học số 28 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(76,28,6,4,'Khóa học số 28 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(77,29,4,4,'Khóa học số 29 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(78,29,6,3,'Khóa học số 29 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(79,29,5,3,'Khóa học số 29 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(80,29,4,4,'Khóa học số 29 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(81,30,4,4,'Khóa học số 30 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(82,30,4,4,'Khóa học số 30 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15'),(83,30,4,3,'Khóa học số 30 rất tốt, giảng viên giảng chi tiết.','2026-08-19 22:50:15');
/*!40000 ALTER TABLE `review` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
INSERT INTO `role` VALUES (1,'Admin'),(2,'Teacher'),(3,'Student');
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `section`
--

DROP TABLE IF EXISTS `section`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `section` (
  `id` int NOT NULL AUTO_INCREMENT,
  `course_id` int NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_number` int DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `fk_section_course` (`course_id`),
  CONSTRAINT `fk_section_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=136 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `section`
--

LOCK TABLES `section` WRITE;
/*!40000 ALTER TABLE `section` DISABLE KEYS */;
INSERT INTO `section` VALUES (1,1,'Chương 1 của Khóa 1',1),(2,1,'Chương 2 của Khóa 1',2),(3,1,'Chương 3 của Khóa 1',3),(4,1,'Chương 4 của Khóa 1',4),(5,1,'Chương 5 của Khóa 1',5),(6,1,'Chương 6 của Khóa 1',6),(7,2,'Chương 1 của Khóa 2',1),(8,2,'Chương 2 của Khóa 2',2),(9,2,'Chương 3 của Khóa 2',3),(10,2,'Chương 4 của Khóa 2',4),(11,2,'Chương 5 của Khóa 2',5),(12,2,'Chương 6 của Khóa 2',6),(13,2,'Chương 7 của Khóa 2',7),(14,3,'Chương 1 của Khóa 3',1),(15,3,'Chương 2 của Khóa 3',2),(16,3,'Chương 3 của Khóa 3',3),(17,4,'Chương 1 của Khóa 4',1),(18,4,'Chương 2 của Khóa 4',2),(19,4,'Chương 3 của Khóa 4',3),(20,5,'Chương 1 của Khóa 5',1),(21,5,'Chương 2 của Khóa 5',2),(22,5,'Chương 3 của Khóa 5',3),(23,5,'Chương 4 của Khóa 5',4),(24,5,'Chương 5 của Khóa 5',5),(25,5,'Chương 6 của Khóa 5',6),(26,5,'Chương 7 của Khóa 5',7),(27,6,'Chương 1 của Khóa 6',1),(28,6,'Chương 2 của Khóa 6',2),(29,6,'Chương 3 của Khóa 6',3),(30,6,'Chương 4 của Khóa 6',4),(31,6,'Chương 5 của Khóa 6',5),(32,6,'Chương 6 của Khóa 6',6),(33,6,'Chương 7 của Khóa 6',7),(34,7,'Chương 1 của Khóa 7',1),(35,7,'Chương 2 của Khóa 7',2),(36,8,'Chương 1 của Khóa 8',1),(37,8,'Chương 2 của Khóa 8',2),(38,9,'Chương 1 của Khóa 9',1),(39,9,'Chương 2 của Khóa 9',2),(40,10,'Chương 1 của Khóa 10',1),(41,10,'Chương 2 của Khóa 10',2),(42,11,'Chương 1 của Khóa 11',1),(43,11,'Chương 2 của Khóa 11',2),(44,11,'Chương 3 của Khóa 11',3),(45,11,'Chương 4 của Khóa 11',4),(46,11,'Chương 5 của Khóa 11',5),(47,11,'Chương 6 của Khóa 11',6),(48,12,'Chương 1 của Khóa 12',1),(49,12,'Chương 2 của Khóa 12',2),(50,13,'Chương 1 của Khóa 13',1),(51,13,'Chương 2 của Khóa 13',2),(52,13,'Chương 3 của Khóa 13',3),(53,14,'Chương 1 của Khóa 14',1),(54,14,'Chương 2 của Khóa 14',2),(55,14,'Chương 3 của Khóa 14',3),(56,15,'Chương 1 của Khóa 15',1),(57,15,'Chương 2 của Khóa 15',2),(58,15,'Chương 3 của Khóa 15',3),(59,15,'Chương 4 của Khóa 15',4),(60,15,'Chương 5 của Khóa 15',5),(61,15,'Chương 6 của Khóa 15',6),(62,15,'Chương 7 của Khóa 15',7),(63,16,'Chương 1 của Khóa 16',1),(64,16,'Chương 2 của Khóa 16',2),(65,16,'Chương 3 của Khóa 16',3),(66,17,'Chương 1 của Khóa 17',1),(67,17,'Chương 2 của Khóa 17',2),(68,17,'Chương 3 của Khóa 17',3),(69,18,'Chương 1 của Khóa 18',1),(70,18,'Chương 2 của Khóa 18',2),(71,18,'Chương 3 của Khóa 18',3),(72,18,'Chương 4 của Khóa 18',4),(73,18,'Chương 5 của Khóa 18',5),(74,18,'Chương 6 của Khóa 18',6),(75,18,'Chương 7 của Khóa 18',7),(76,19,'Chương 1 của Khóa 19',1),(77,19,'Chương 2 của Khóa 19',2),(78,19,'Chương 3 của Khóa 19',3),(79,19,'Chương 4 của Khóa 19',4),(80,19,'Chương 5 của Khóa 19',5),(81,19,'Chương 6 của Khóa 19',6),(82,19,'Chương 7 của Khóa 19',7),(83,20,'Chương 1 của Khóa 20',1),(84,20,'Chương 2 của Khóa 20',2),(85,20,'Chương 3 của Khóa 20',3),(86,20,'Chương 4 của Khóa 20',4),(87,20,'Chương 5 của Khóa 20',5),(88,21,'Chương 1 của Khóa 21',1),(89,21,'Chương 2 của Khóa 21',2),(90,21,'Chương 3 của Khóa 21',3),(91,21,'Chương 4 của Khóa 21',4),(92,21,'Chương 5 của Khóa 21',5),(93,22,'Chương 1 của Khóa 22',1),(94,22,'Chương 2 của Khóa 22',2),(95,22,'Chương 3 của Khóa 22',3),(96,22,'Chương 4 của Khóa 22',4),(97,22,'Chương 5 của Khóa 22',5),(98,22,'Chương 6 của Khóa 22',6),(99,22,'Chương 7 của Khóa 22',7),(100,23,'Chương 1 của Khóa 23',1),(101,23,'Chương 2 của Khóa 23',2),(102,23,'Chương 3 của Khóa 23',3),(103,23,'Chương 4 của Khóa 23',4),(104,24,'Chương 1 của Khóa 24',1),(105,24,'Chương 2 của Khóa 24',2),(106,24,'Chương 3 của Khóa 24',3),(107,24,'Chương 4 của Khóa 24',4),(108,25,'Chương 1 của Khóa 25',1),(109,25,'Chương 2 của Khóa 25',2),(110,25,'Chương 3 của Khóa 25',3),(111,25,'Chương 4 của Khóa 25',4),(112,25,'Chương 5 của Khóa 25',5),(113,26,'Chương 1 của Khóa 26',1),(114,26,'Chương 2 của Khóa 26',2),(115,26,'Chương 3 của Khóa 26',3),(116,26,'Chương 4 của Khóa 26',4),(117,27,'Chương 1 của Khóa 27',1),(118,27,'Chương 2 của Khóa 27',2),(119,27,'Chương 3 của Khóa 27',3),(120,27,'Chương 4 của Khóa 27',4),(121,28,'Chương 1 của Khóa 28',1),(122,28,'Chương 2 của Khóa 28',2),(123,28,'Chương 3 của Khóa 28',3),(124,29,'Chương 1 của Khóa 29',1),(125,29,'Chương 2 của Khóa 29',2),(126,29,'Chương 3 của Khóa 29',3),(127,29,'Chương 4 của Khóa 29',4),(128,29,'Chương 5 của Khóa 29',5),(129,29,'Chương 6 của Khóa 29',6),(130,30,'Chương 1 của Khóa 30',1),(131,30,'Chương 2 của Khóa 30',2),(132,30,'Chương 3 của Khóa 30',3),(133,30,'Chương 4 của Khóa 30',4),(134,31,'tiệm bánh số 1',1),(135,31,'Chương 2 ',2);
/*!40000 ALTER TABLE `section` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teacher_bank_account`
--

DROP TABLE IF EXISTS `teacher_bank_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teacher_bank_account` (
  `id` int NOT NULL AUTO_INCREMENT,
  `teacher_id` int NOT NULL,
  `bank_code` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `bank_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `account_number` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `account_holder` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tax_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_teacher_bank_teacher_id` (`teacher_id`),
  CONSTRAINT `fk_teacher_bank_account` FOREIGN KEY (`teacher_id`) REFERENCES `account` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teacher_bank_account`
--

LOCK TABLES `teacher_bank_account` WRITE;
/*!40000 ALTER TABLE `teacher_bank_account` DISABLE KEYS */;
/*!40000 ALTER TABLE `teacher_bank_account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teacher_wallet`
--

DROP TABLE IF EXISTS `teacher_wallet`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teacher_wallet` (
  `id` int NOT NULL AUTO_INCREMENT,
  `teacher_id` int NOT NULL,
  `balance` decimal(15,2) NOT NULL DEFAULT '0.00',
  `total_earned` decimal(15,2) NOT NULL DEFAULT '0.00',
  `total_withdrawn` decimal(15,2) NOT NULL DEFAULT '0.00',
  `status` enum('active','frozen') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_teacher_wallet` (`teacher_id`),
  CONSTRAINT `fk_wallet_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `account` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teacher_wallet`
--

LOCK TABLES `teacher_wallet` WRITE;
/*!40000 ALTER TABLE `teacher_wallet` DISABLE KEYS */;
INSERT INTO `teacher_wallet` VALUES (1,2,0.00,0.00,0.00,'active','2026-08-19 23:16:17'),(2,3,182000.00,182000.00,0.00,'active','2026-08-19 23:20:10');
/*!40000 ALTER TABLE `teacher_wallet` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_learning_list`
--

DROP TABLE IF EXISTS `user_learning_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_learning_list` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_ull_user` (`user_id`),
  CONSTRAINT `fk_ull_user` FOREIGN KEY (`user_id`) REFERENCES `account` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_learning_list`
--

LOCK TABLES `user_learning_list` WRITE;
/*!40000 ALTER TABLE `user_learning_list` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_learning_list` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_learning_list_course`
--

DROP TABLE IF EXISTS `user_learning_list_course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_learning_list_course` (
  `list_id` int NOT NULL,
  `course_id` int NOT NULL,
  PRIMARY KEY (`list_id`,`course_id`),
  KEY `fk_list_course` (`course_id`),
  CONSTRAINT `fk_list_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_list_learning` FOREIGN KEY (`list_id`) REFERENCES `user_learning_list` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_learning_list_course`
--

LOCK TABLES `user_learning_list_course` WRITE;
/*!40000 ALTER TABLE `user_learning_list_course` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_learning_list_course` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wallet_transaction`
--

DROP TABLE IF EXISTS `wallet_transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallet_transaction` (
  `id` int NOT NULL AUTO_INCREMENT,
  `wallet_id` int NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `balance_after` decimal(15,2) NOT NULL,
  `type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reference_id` int DEFAULT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_transaction_wallet` (`wallet_id`),
  CONSTRAINT `fk_transaction_wallet` FOREIGN KEY (`wallet_id`) REFERENCES `teacher_wallet` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallet_transaction`
--

LOCK TABLES `wallet_transaction` WRITE;
/*!40000 ALTER TABLE `wallet_transaction` DISABLE KEYS */;
INSERT INTO `wallet_transaction` VALUES (1,2,182000.00,182000.00,'course_sale',1,'Hoa hồng 70% từ bán khóa học: Khóa học lập trình 9 (Đơn #1)','2026-08-19 23:20:10');
/*!40000 ALTER TABLE `wallet_transaction` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wishlist`
--

DROP TABLE IF EXISTS `wishlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wishlist` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `course_id` int NOT NULL,
  `created_date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_wishlist_user_course` (`user_id`,`course_id`),
  KEY `fk_wishlist_course` (`course_id`),
  CONSTRAINT `fk_wishlist_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_wishlist_user` FOREIGN KEY (`user_id`) REFERENCES `account` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wishlist`
--

LOCK TABLES `wishlist` WRITE;
/*!40000 ALTER TABLE `wishlist` DISABLE KEYS */;
/*!40000 ALTER TABLE `wishlist` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-20 16:09:13

DROP TABLE IF EXISTS `teacher_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teacher_profiles` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `account_id` INT NOT NULL,
  `bio` TEXT DEFAULT NULL,
  `specialization` VARCHAR(255) DEFAULT NULL,
  `experience_years` INT DEFAULT 0,
  `cv_url` VARCHAR(500) DEFAULT NULL,
  `portfolio_url` VARCHAR(500) DEFAULT NULL,
  `approval_status` ENUM('PENDING', 'APPROVED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
  `rejected_reason` VARCHAR(500) DEFAULT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_account_id` (`account_id`),
  CONSTRAINT `fk_instructor_account` 
    FOREIGN KEY (`account_id`) 
    REFERENCES `Account` (`id`) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;