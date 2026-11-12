CREATE DATABASE IF NOT EXISTS `dlbackstage`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `dlbackstage`.`operationlog` (
  `id` int unsigned NOT NULL,
  `username` varchar(255) NOT NULL,
  `ip` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `time` datetime NOT NULL,
  `type` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `time` (`time`),
  KEY `username_type` (`username`, `type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `dlbackstage`.`broadcast` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `serverId` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `submitter` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `type` varchar(32) NOT NULL,
  `startTime` datetime NOT NULL,
  `stopTime` datetime NOT NULL,
  `intervalTime` int DEFAULT NULL,
  `triggerTime` datetime DEFAULT NULL,
  `channel` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `broadcast_schedule` (`startTime`, `stopTime`, `triggerTime`),
  KEY `broadcast_channel` (`channel`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
