CREATE TABLE IF NOT EXISTS `gamedb`.`operationlog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) DEFAULT NULL,
  `ip` varchar(255) DEFAULT NULL,
  `content` text,
  `time` datetime DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO `gamedb`.`operationlog`
  (`id`, `username`, `ip`, `content`, `time`, `type`)
SELECT `id`, `username`, `ip`, `content`, `time`, `type`
FROM `dlbackstage`.`operationlog`;

CREATE TABLE IF NOT EXISTS `gamedb`.`broadcast` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `serverId` varchar(255) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `submitter` varchar(255) DEFAULT NULL,
  `content` mediumtext,
  `type` varchar(255) DEFAULT NULL,
  `startTime` datetime DEFAULT NULL,
  `stopTime` datetime DEFAULT NULL,
  `intervalTime` int(11) DEFAULT NULL,
  `triggerTime` datetime DEFAULT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `channel` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO `gamedb`.`broadcast`
  (`id`, `serverId`, `title`, `submitter`, `content`, `type`, `startTime`,
   `stopTime`, `intervalTime`, `triggerTime`, `createdAt`, `updatedAt`, `channel`)
SELECT `id`, `serverId`, `title`, `submitter`, `content`, `type`, `startTime`,
       `stopTime`, `intervalTime`, `triggerTime`, `createdAt`, `updatedAt`, `channel`
FROM `dlbackstage`.`broadcast`;
