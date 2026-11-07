CREATE TABLE IF NOT EXISTS `gamedb_cmdl`.`channel_list`
LIKE `dlbackstage`.`channel_list`;

INSERT INTO `gamedb_cmdl`.`channel_list` (`id`, `name`, `index`, `ip`, `url`)
SELECT `id`, `name`, `index`, `ip`, `url`
FROM `dlbackstage`.`channel_list`
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `index` = VALUES(`index`),
  `ip` = VALUES(`ip`),
  `url` = VALUES(`url`);
