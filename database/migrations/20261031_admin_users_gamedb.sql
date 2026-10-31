CREATE TABLE IF NOT EXISTS `gamedb`.`admin_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `userRandom` varchar(255) DEFAULT NULL,
  `authorization` varchar(255) NOT NULL,
  `channel` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `userRandom` (`userRandom`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `gamedb`.`admin_user` (`id`, `username`, `password`, `authorization`, `channel`)
SELECT `id`, `username`, `password`, `authorization`, `channel`
FROM `dlbackstage`.`user`
ON DUPLICATE KEY UPDATE
  `password` = VALUES(`password`),
  `authorization` = VALUES(`authorization`),
  `channel` = VALUES(`channel`);
