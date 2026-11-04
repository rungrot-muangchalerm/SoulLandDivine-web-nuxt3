-- Schema เสริมที่กำลังพัฒนาสำหรับฐานข้อมูล MariaDB/MySQL `gamedb` ใหม่หรือที่มีอยู่แล้ว
-- ใช้สร้างตาราง configuration ของเกมและเว็บแอดมิน โดยไม่ลบ แก้ไข หรือเพิ่มข้อมูลตั้งต้นลงในตารางเดิม
-- Schema นี้ยังไม่ครอบคลุมตาราง runtime ทั้งหมดที่ game server ใช้งานอยู่
-- ต้องสร้างฐานข้อมูล `gamedb` ก่อน
-- ขั้นตอนสร้างไฟล์นี้ไม่ได้เชื่อมต่อหรือรันคำสั่ง SQL
-- ข้อมูล NPC, จุดวาง/จุดเกิด และ configuration ของ Zone/Dungeon ยังคงใช้ XML ตามเดิม
USE `gamedb`;

CREATE TABLE IF NOT EXISTS `admin_user` (
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

CREATE TABLE IF NOT EXISTS `channel_list` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `index` varchar(255) DEFAULT NULL,
  `ip` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `operationlog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) DEFAULT NULL,
  `ip` varchar(255) DEFAULT NULL,
  `content` text,
  `time` datetime DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `broadcast` (
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

-- ตารางเก็บข้อความแปลแยกจากค่าตั้งต้นของเกม โดยอ้างอิงชุดข้อมูล, ID, ภาษา และชื่อฟิลด์
CREATE TABLE IF NOT EXISTS `game_config_localization` (
  `dataset_name` VARCHAR(128) NOT NULL,
  `config_id` VARCHAR(64) NOT NULL,
  `locale` VARCHAR(8) NOT NULL,
  `field_name` VARCHAR(128) NOT NULL,
  `localized_value` MEDIUMTEXT NOT NULL,
  PRIMARY KEY (`dataset_name`, `config_id`, `locale`, `field_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `game_config_schema_version` (
  `version` INT UNSIGNED NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `applied_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Career
CREATE TABLE IF NOT EXISTS `game_cfg_career` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `chapter` BIGINT UNSIGNED NULL,
  `content` VARCHAR(32) NULL,
  `stat` VARCHAR(223) NULL,
  `type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_348f0bfe0e61` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CareerConfig
CREATE TABLE IF NOT EXISTS `game_cfg_careerconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `chapter_to_show` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6e43dbd127b8` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CareerTitle
CREATE TABLE IF NOT EXISTS `game_cfg_careertitle` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `chapter` BIGINT UNSIGNED NULL,
  `title` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_bd3de1958285` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Action
CREATE TABLE IF NOT EXISTS `game_cfg_action` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ActionMainType` BIGINT UNSIGNED NULL,
  `ActionType` BIGINT UNSIGNED NULL,
  `CurrStep` BIGINT UNSIGNED NULL,
  `EndTime` VARCHAR(32) NULL,
  `Frequence` BIGINT UNSIGNED NULL,
  `Limit` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `Param1` BIGINT UNSIGNED NULL,
  `Param1Notice` VARCHAR(32) NULL,
  `Param2` BIGINT UNSIGNED NULL,
  `Param2Notice` VARCHAR(32) NULL,
  `SdkAction` BIGINT UNSIGNED NULL,
  `SdkActionParam` VARCHAR(32) NULL,
  `StartTime` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_97c89a4d6630` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ActionConfig
CREATE TABLE IF NOT EXISTS `game_cfg_actionconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BuyTimingGiftTypeAddWeightRatio` DECIMAL(2,1) NULL,
  `DailyTimingBagAddWeight` BIGINT UNSIGNED NULL,
  `MonthlyTimingBagAddWeight` BIGINT UNSIGNED NULL,
  `NotBuyTimingGiftTypeAddWeightRatio` DECIMAL(2,1) NULL,
  `PlayTypeCostDiamondDivideParam` BIGINT UNSIGNED NULL,
  `ResourceCurrDivideCostMax` DECIMAL(2,1) NULL,
  `ResourceCurrDivideCostMin` BIGINT UNSIGNED NULL,
  `ResourceCurrDivideCostRatio` DECIMAL(2,1) NULL,
  `ShopBuyAddWeight` BIGINT UNSIGNED NULL,
  `TodaySameTimingGiftTypeMaxCount` BIGINT UNSIGNED NULL,
  `WeeklyTimingBagAddWeight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f83230f7d3ae` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PlayType2TimingGiftType
CREATE TABLE IF NOT EXISTS `game_cfg_playtype2timinggifttype` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `TimingGiftType` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f4f49ea3b343` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TimingGiftDailyLimit
CREATE TABLE IF NOT EXISTS `game_cfg_timinggiftdailylimit` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Break` BIGINT UNSIGNED NULL,
  `Diamond` BIGINT UNSIGNED NULL,
  `EquipmentInject` BIGINT UNSIGNED NULL,
  `EquipmentUpgrade` BIGINT UNSIGNED NULL,
  `GainCharacter` BIGINT UNSIGNED NULL,
  `Gold` BIGINT UNSIGNED NULL,
  `LevelUp` BIGINT UNSIGNED NULL,
  `SoulBone` BIGINT UNSIGNED NULL,
  `SoulRing` BIGINT UNSIGNED NULL,
  `SoulRingBreak` BIGINT UNSIGNED NULL,
  `SoulRingLevelUp` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f277107dcc71` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TimingGiftLimit
CREATE TABLE IF NOT EXISTS `game_cfg_timinggiftlimit` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Break` BIGINT UNSIGNED NULL,
  `Diamond` BIGINT UNSIGNED NULL,
  `EquipmentInject` BIGINT UNSIGNED NULL,
  `EquipmentUpgrade` BIGINT UNSIGNED NULL,
  `GainCharacter` BIGINT UNSIGNED NULL,
  `Gold` BIGINT UNSIGNED NULL,
  `LevelUp` BIGINT UNSIGNED NULL,
  `SoulBone` BIGINT UNSIGNED NULL,
  `SoulRing` BIGINT UNSIGNED NULL,
  `SoulRingBreak` BIGINT UNSIGNED NULL,
  `SoulRingLevelUp` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e300e6cbb14d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TimingGiftRechargeItem
CREATE TABLE IF NOT EXISTS `game_cfg_timinggiftrechargeitem` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Break` BIGINT UNSIGNED NULL,
  `Diamond` BIGINT UNSIGNED NULL,
  `EquipmentInject` BIGINT UNSIGNED NULL,
  `EquipmentUpgrade` BIGINT UNSIGNED NULL,
  `GainCharacter` BIGINT UNSIGNED NULL,
  `Gold` BIGINT UNSIGNED NULL,
  `LevelUp` BIGINT UNSIGNED NULL,
  `Money` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `SoulBone` BIGINT UNSIGNED NULL,
  `SoulRing` BIGINT UNSIGNED NULL,
  `SoulRingBreak` BIGINT UNSIGNED NULL,
  `SoulRingLevelUp` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_051cd036744c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TimingGiftWeight
CREATE TABLE IF NOT EXISTS `game_cfg_timinggiftweight` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Break` BIGINT UNSIGNED NULL,
  `Diamond` BIGINT UNSIGNED NULL,
  `EquipmentInject` BIGINT UNSIGNED NULL,
  `EquipmentUpgrade` BIGINT UNSIGNED NULL,
  `GainCharacter` BIGINT UNSIGNED NULL,
  `Gold` BIGINT UNSIGNED NULL,
  `LevelUp` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `SoulBone` BIGINT UNSIGNED NULL,
  `SoulRing` BIGINT UNSIGNED NULL,
  `SoulRingBreak` BIGINT UNSIGNED NULL,
  `SoulRingLevelUp` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_cb05d3187ff3` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ActivityInfo
CREATE TABLE IF NOT EXISTS `game_cfg_activityinfo` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `EndDate` DATETIME(6) NULL,
  `EndTime` TIME NULL,
  `IsDailyRefresh` BIGINT UNSIGNED NULL,
  `Num` BIGINT UNSIGNED NULL,
  `OpenEnd` BIGINT UNSIGNED NULL,
  `OpenStart` BIGINT UNSIGNED NULL,
  `RelatedId` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(71) NULL,
  `RewardStar` VARCHAR(32) NULL,
  `StartDate` DATETIME(6) NULL,
  `StartTime` TIME NULL,
  `TipsId` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_cb47433eed0a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ActivityType
CREATE TABLE IF NOT EXISTS `game_cfg_activitytype` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Des` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6832e12a3f22` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DailyAccumulateGet
CREATE TABLE IF NOT EXISTS `game_cfg_dailyaccumulateget` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Day` BIGINT UNSIGNED NULL,
  `Good` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ed520ab9ee20` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DailySignInReward
CREATE TABLE IF NOT EXISTS `game_cfg_dailysigninreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Day` BIGINT UNSIGNED NULL,
  `Reward1` VARCHAR(32) NULL,
  `Reward2` VARCHAR(32) NULL,
  `Reward3` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4ae9ee6409df` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: OverSeasActivityTable
CREATE TABLE IF NOT EXISTS `game_cfg_overseasactivitytable` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ActivityEnd` VARCHAR(32) NULL,
  `ActivityStart` VARCHAR(32) NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Infos` VARCHAR(32) NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `MainType` BIGINT UNSIGNED NULL,
  `SubType` BIGINT UNSIGNED NULL,
  `TabShowEnd` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ef80bd05c599` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RunAwayActivityInfo
CREATE TABLE IF NOT EXISTS `game_cfg_runawayactivityinfo` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ActivityType` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Day` BIGINT UNSIGNED NULL,
  `Param` VARCHAR(32) NULL,
  `Reward` VARCHAR(32) NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_44bb05a937c9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RunAwayActivityType
CREATE TABLE IF NOT EXISTS `game_cfg_runawayactivitytype` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BusinessType` BIGINT UNSIGNED NULL,
  `InterveneId` BIGINT UNSIGNED NULL,
  `InterveneName` VARCHAR(32) NULL,
  `Remark` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_862253510002` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SpecialActivityInfo
CREATE TABLE IF NOT EXISTS `game_cfg_specialactivityinfo` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Num` BIGINT UNSIGNED NULL,
  `OpenEnd` VARCHAR(32) NULL,
  `OpenStart` VARCHAR(32) NULL,
  `Param` VARCHAR(32) NULL,
  `SpecialType` BIGINT UNSIGNED NULL,
  `TipsId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a956a8058281` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SpecialActivityTable
CREATE TABLE IF NOT EXISTS `game_cfg_specialactivitytable` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Infos` VARCHAR(32) NULL,
  `MainType` BIGINT UNSIGNED NULL,
  `ShowEnd` VARCHAR(32) NULL,
  `ShowStart` VARCHAR(32) NULL,
  `SubType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_2e07cf470848` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: WebPayRechargeRabate
CREATE TABLE IF NOT EXISTS `game_cfg_webpayrechargerabate` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ConditionParam` VARCHAR(32) NULL,
  `ConditionType` BIGINT UNSIGNED NULL,
  `GetRewardAfterEnd` BIGINT UNSIGNED NULL,
  `PayMode` BIGINT UNSIGNED NULL,
  `RebateParam` VARCHAR(32) NULL,
  `Rewards` VARCHAR(32) NULL,
  `SpecialType` BIGINT UNSIGNED NULL,
  `TipsId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_bf734a13b595` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Model
CREATE TABLE IF NOT EXISTS `game_cfg_model` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `base_model` VARCHAR(33) NULL,
  `col_center` VARCHAR(32) NULL,
  `col_size` VARCHAR(32) NULL,
  `dummy` VARCHAR(32) NULL,
  `hit_offset_y` VARCHAR(32) NULL,
  `label_offset_x` VARCHAR(32) NULL,
  `label_offset_y` VARCHAR(32) NULL,
  `model_loop_effect` TEXT NULL,
  `model_path` VARCHAR(32) NULL,
  `name` VARCHAR(33) NULL,
  `no_shadow` BIGINT UNSIGNED NULL,
  `Opacity` DECIMAL(3,2) NULL,
  `outlineColor` VARCHAR(32) NULL,
  `outlineSize` DECIMAL(4,3) NULL,
  `RimColor` VARCHAR(32) NULL,
  `scale` DECIMAL(2,1) NULL,
  `soul_loop_effect` VARCHAR(85) NULL,
  `title_offset_x` DECIMAL(2,1) NULL,
  `title_offset_y` DECIMAL(3,2) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_68c2cc7f0cea` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: AddictionType
CREATE TABLE IF NOT EXISTS `game_cfg_addictiontype` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `param` VARCHAR(32) NULL,
  `type` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ae00ff2a162b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Holiday
CREATE TABLE IF NOT EXISTS `game_cfg_holiday` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `date` DATE NULL,
  `name` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a15e435c9663` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Announce
CREATE TABLE IF NOT EXISTS `game_cfg_announce` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(34) NULL,
  `dec` VARCHAR(252) NULL,
  `displayinChat` BOOLEAN NULL,
  `priority` BIGINT UNSIGNED NULL,
  `type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b6e441520664` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Notes.xml
CREATE TABLE IF NOT EXISTS `game_cfg_notes.xml` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(35) NULL,
  `dec` VARCHAR(123) NULL,
  `SaveCount` BIGINT UNSIGNED NULL,
  `ShowCount` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9f35919a6254` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Question
CREATE TABLE IF NOT EXISTS `game_cfg_question` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `input` BIGINT UNSIGNED NULL,
  `option` VARCHAR(37) NULL,
  `param` VARCHAR(32) NULL,
  `type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_002ff598115d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Questionnaire
CREATE TABLE IF NOT EXISTS `game_cfg_questionnaire` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `award` VARCHAR(32) NULL,
  `day` BIGINT UNSIGNED NULL,
  `lv` BIGINT UNSIGNED NULL,
  `total` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_42d2c2bca9d8` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ArenaConfig
CREATE TABLE IF NOT EXISTS `game_cfg_arenaconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ChallengeLoseReward` VARCHAR(32) NULL,
  `ChallengerWalkPosY` BIGINT UNSIGNED NULL,
  `ChallengeWinReward` VARCHAR(32) NULL,
  `ChangeTimeCD` BIGINT UNSIGNED NULL,
  `DefenderWalkPosY` BIGINT NULL,
  `EnemyAngle` BIGINT NULL,
  `FightTimeCD` BIGINT UNSIGNED NULL,
  `FightTimeResetCostNum` BIGINT UNSIGNED NULL,
  `FightTimeResetCostType` BIGINT UNSIGNED NULL,
  `InfoRefreshTime` BIGINT UNSIGNED NULL,
  `LoseEmail` BIGINT UNSIGNED NULL,
  `LoseEmailRank` BIGINT UNSIGNED NULL,
  `LoseScore` BIGINT UNSIGNED NULL,
  `MapId` BIGINT UNSIGNED NULL,
  `PlayerAngle` BIGINT UNSIGNED NULL,
  `RankMax` BIGINT UNSIGNED NULL,
  `RankPerPage` BIGINT UNSIGNED NULL,
  `RankRefreshTime` BIGINT UNSIGNED NULL,
  `ShowRefreshTime` BIGINT UNSIGNED NULL,
  `TeamRedFormationLevel` BIGINT UNSIGNED NULL,
  `TeamRedHeroLevel` BIGINT UNSIGNED NULL,
  `VersusMapId` BIGINT UNSIGNED NULL,
  `WinScore` BIGINT UNSIGNED NULL,
  `WinStreakScore` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ff0b20e1173a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ArenaRankDailyReward
CREATE TABLE IF NOT EXISTS `game_cfg_arenarankdailyreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Rank` VARCHAR(32) NULL,
  `RankMax` BIGINT UNSIGNED NULL,
  `RankMin` BIGINT UNSIGNED NULL,
  `Rewards` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ddfb6c75eb4f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ArenaRankFirstReward
CREATE TABLE IF NOT EXISTS `game_cfg_arenarankfirstreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Rank` VARCHAR(32) NULL,
  `RankMax` BIGINT UNSIGNED NULL,
  `RankMin` BIGINT UNSIGNED NULL,
  `Rewards` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7981c19f1ccb` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RandomChallenge
CREATE TABLE IF NOT EXISTS `game_cfg_randomchallenge` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `FourthMax` BIGINT UNSIGNED NULL,
  `FourthMin` BIGINT UNSIGNED NULL,
  `FristMax` BIGINT UNSIGNED NULL,
  `FristMin` BIGINT UNSIGNED NULL,
  `RankMax` BIGINT UNSIGNED NULL,
  `RankMin` BIGINT UNSIGNED NULL,
  `SecondMax` BIGINT UNSIGNED NULL,
  `SecondMin` BIGINT UNSIGNED NULL,
  `ThirdMax` BIGINT UNSIGNED NULL,
  `ThirdMin` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_8cdcb068b654` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RankLevel
CREATE TABLE IF NOT EXISTS `game_cfg_ranklevel` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Atlas` VARCHAR(32) NULL,
  `CEHUA` VARCHAR(32) NULL,
  `EffDownName` VARCHAR(33) NULL,
  `IntegralCurrent` BIGINT UNSIGNED NULL,
  `IntegralNext` BIGINT UNSIGNED NULL,
  `LevelAtlas` VARCHAR(32) NULL,
  `LevelIcon` VARCHAR(32) NULL,
  `LevelIconSmall` VARCHAR(32) NULL,
  `Rewards` VARCHAR(39) NULL,
  `TextIcon` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_004c68e6243d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: BagConfig
CREATE TABLE IF NOT EXISTS `game_cfg_bagconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BagFullEmailId` BIGINT UNSIGNED NULL,
  `BagInitSpace` BIGINT UNSIGNED NULL,
  `BagMaxSpace` BIGINT UNSIGNED NULL,
  `BagTicketId` BIGINT UNSIGNED NULL,
  `BagTicketPrice` BIGINT UNSIGNED NULL,
  `BatchCountLimit` BIGINT UNSIGNED NULL,
  `ChangeNameDiamond` BIGINT UNSIGNED NULL,
  `ChangeNameTicket` VARCHAR(32) NULL,
  `GiftFlowerId` BIGINT UNSIGNED NULL,
  `GiftFlowerPopScore` BIGINT UNSIGNED NULL,
  `GiftFlowerPrice` BIGINT UNSIGNED NULL,
  `IncreaseSpacePerTicket` BIGINT UNSIGNED NULL,
  `MaxPrefix` BIGINT UNSIGNED NULL,
  `RandomEquipBoxMinQuality` BIGINT UNSIGNED NULL,
  `RandomSoulBoneBoxMinQuality` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_32dfa718dc8d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: BagSpace
CREATE TABLE IF NOT EXISTS `game_cfg_bagspace` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Ticket` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6e7a811a5793` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: FaceFrame
CREATE TABLE IF NOT EXISTS `game_cfg_faceframe` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `MainType` BIGINT UNSIGNED NULL,
  `name_cn` VARCHAR(32) NULL,
  `SubType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7a21580dd393` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Fashion
CREATE TABLE IF NOT EXISTS `game_cfg_fashion` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `MainType` BIGINT UNSIGNED NULL,
  `name_cn` VARCHAR(32) NULL,
  `Order` BIGINT UNSIGNED NULL,
  `SubType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4706640ad676` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroFragment
CREATE TABLE IF NOT EXISTS `game_cfg_herofragment` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Color` BIGINT UNSIGNED NULL,
  `HeroId` BIGINT UNSIGNED NULL,
  `Icon` VARCHAR(42) NULL,
  `IconAtlas` VARCHAR(32) NULL,
  `IsGod` BIGINT UNSIGNED NULL,
  `ItemEffName` VARCHAR(32) NULL,
  `MainType` BIGINT UNSIGNED NULL,
  `Order` BIGINT UNSIGNED NULL,
  `Quality` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_192415354f60` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Item
CREATE TABLE IF NOT EXISTS `game_cfg_item` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Atlas` VARCHAR(32) NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Color` BIGINT UNSIGNED NULL,
  `GetWayId` BIGINT UNSIGNED NULL,
  `Grade` BIGINT UNSIGNED NULL,
  `Icon` VARCHAR(58) NULL,
  `IsAdvance` BIGINT UNSIGNED NULL,
  `IsCompose` BIGINT UNSIGNED NULL,
  `IsResolve` BIGINT UNSIGNED NULL,
  `IsShowRedPoint` BIGINT UNSIGNED NULL,
  `IsUsable` BIGINT UNSIGNED NULL,
  `IsVisible` BIGINT UNSIGNED NULL,
  `ItemEffName` VARCHAR(33) NULL,
  `LevelLimit` BIGINT UNSIGNED NULL,
  `LevelUpNum` BIGINT UNSIGNED NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `MainType` BIGINT UNSIGNED NULL,
  `MiniAtlas` VARCHAR(32) NULL,
  `MiniIcon` VARCHAR(58) NULL,
  `OpenPanel` VARCHAR(39) NULL,
  `Order` BIGINT UNSIGNED NULL,
  `PileMax` BIGINT UNSIGNED NULL,
  `Quality` BIGINT UNSIGNED NULL,
  `Resume` BIGINT UNSIGNED NULL,
  `SellingPrice` VARCHAR(32) NULL,
  `SubType` BIGINT UNSIGNED NULL,
  `SubTypeText` BIGINT UNSIGNED NULL,
  `UsableNum` BIGINT UNSIGNED NULL,
  `Value` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ecdda59aea5e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ItemChange
CREATE TABLE IF NOT EXISTS `game_cfg_itemchange` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Change` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_dde82334e7ee` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ItemChangeExt
CREATE TABLE IF NOT EXISTS `game_cfg_itemchangeext` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `End` VARCHAR(32) NULL,
  `Reward` VARCHAR(32) NULL,
  `Start` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c88ea0e3aca1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ItemChooseBox
CREATE TABLE IF NOT EXISTS `game_cfg_itemchoosebox` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Grade` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c76a538da6cc` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ItemChooseBoxExt
CREATE TABLE IF NOT EXISTS `game_cfg_itemchooseboxext` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Count` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(141) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_fd6e68f286fc` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ItemExchangeReward
CREATE TABLE IF NOT EXISTS `game_cfg_itemexchangereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ActivityType` BIGINT UNSIGNED NULL,
  `CostItems` VARCHAR(43) NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d1b8a3f82ff0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ItemForge
CREATE TABLE IF NOT EXISTS `game_cfg_itemforge` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Material` VARCHAR(32) NULL,
  `Num` BIGINT UNSIGNED NULL,
  `Price` VARCHAR(32) NULL,
  `Product` VARCHAR(32) NULL,
  `ProductMainType` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e3cd099b959c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ItemReceive
CREATE TABLE IF NOT EXISTS `game_cfg_itemreceive` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `MainType` BIGINT UNSIGNED NULL,
  `Rewards` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9cc2eecb7d5c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ItemResolve
CREATE TABLE IF NOT EXISTS `game_cfg_itemresolve` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Price` VARCHAR(32) NULL,
  `RandomReward` VARCHAR(32) NULL,
  `Result` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c529e982dee1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ItemUsing
CREATE TABLE IF NOT EXISTS `game_cfg_itemusing` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(96) NULL,
  `Gain` TEXT NULL,
  `QualityLimit` BIGINT UNSIGNED NULL,
  `ShopItemRnage` VARCHAR(32) NULL,
  `SoulBone` VARCHAR(86) NULL,
  `SoulRing` TEXT NULL,
  `Type` BIGINT UNSIGNED NULL,
  `UpQuality` BIGINT NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1f60d49e742c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RecommendIcon
CREATE TABLE IF NOT EXISTS `game_cfg_recommendicon` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `atlas` VARCHAR(32) NULL,
  `icon` VARCHAR(32) NULL,
  `name` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9639ddc1dd95` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulRingResolve
CREATE TABLE IF NOT EXISTS `game_cfg_soulringresolve` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `MaxYear` BIGINT UNSIGNED NULL,
  `MinYear` BIGINT UNSIGNED NULL,
  `Price` VARCHAR(32) NULL,
  `Result` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_98fd9e0905bd` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SystemFashion
CREATE TABLE IF NOT EXISTS `game_cfg_systemfashion` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Fashions` VARCHAR(35) NULL,
  `H_ModelId` BIGINT UNSIGNED NULL,
  `ModelId` BIGINT UNSIGNED NULL,
  `name_des` VARCHAR(32) NULL,
  `Sex_Limit` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d168f5311581` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SystemHairStyle
CREATE TABLE IF NOT EXISTS `game_cfg_systemhairstyle` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `FaceIcon` BIGINT UNSIGNED NULL,
  `H_ModelId` BIGINT UNSIGNED NULL,
  `HeadId` BIGINT UNSIGNED NULL,
  `ModelId` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `name_des` VARCHAR(32) NULL,
  `Sex_Limit` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b6e1fe831614` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: BattlePowerConfig
CREATE TABLE IF NOT EXISTS `game_cfg_battlepowerconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `SoulBoneBattlePowerBasic` BIGINT UNSIGNED NULL,
  `SoulRingBattlePowerBasic` BIGINT UNSIGNED NULL,
  `SoulRingElementBattlePowerBasic` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7eec7dc6b5a7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: BattlePowerSuppress
CREATE TABLE IF NOT EXISTS `game_cfg_battlepowersuppress` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DisparityRatio` BIGINT UNSIGNED NULL,
  `PRO_CRI` BIGINT UNSIGNED NULL,
  `PRO_FLEE` BIGINT UNSIGNED NULL,
  `PRO_HIT` BIGINT UNSIGNED NULL,
  `PRO_RES` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_cf18f2a5532c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: BILogConfig
CREATE TABLE IF NOT EXISTS `game_cfg_bilogconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `FileSize` BIGINT UNSIGNED NULL,
  `RefreshTime` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_aa37a5d653c4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: BrothersConfig
CREATE TABLE IF NOT EXISTS `game_cfg_brothersconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BrotherFriendScore` BIGINT UNSIGNED NULL,
  `BrotherInviterListMaxCnt` BIGINT UNSIGNED NULL,
  `BrotherListMaxCnt` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_cfebcd9887f7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Buff
CREATE TABLE IF NOT EXISTS `game_cfg_buff` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BuffType` BIGINT UNSIGNED NULL,
  `c` VARCHAR(32) NULL,
  `CeHua` VARCHAR(65) NULL,
  `CleanUp` BOOLEAN NULL,
  `d` BIGINT UNSIGNED NULL,
  `Debuff` BOOLEAN NULL,
  `DeltaTime` DECIMAL(4,2) NULL,
  `DispatchCureSKillMsg` BOOLEAN NULL,
  `Dispel` BOOLEAN NULL,
  `m` VARCHAR(32) NULL,
  `MaxPileNum` BIGINT UNSIGNED NULL,
  `n` VARCHAR(32) NULL,
  `name` VARCHAR(32) NULL,
  `NatureRatio` VARCHAR(32) NULL,
  `Notify` BOOLEAN NULL,
  `OverlayType` BIGINT UNSIGNED NULL,
  `r` DECIMAL(2,1) NULL,
  `RefuseReplaceType` BIGINT UNSIGNED NULL,
  `s` VARCHAR(32) NULL,
  `SpecConType` BIGINT UNSIGNED NULL,
  `SpecParam` BIGINT UNSIGNED NULL,
  `x` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9921fdc70b22` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampActivityTimer
CREATE TABLE IF NOT EXISTS `game_cfg_campactivitytimer` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BeginTime` VARCHAR(32) NULL,
  `CampActivityType` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `EndTime` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_345ae904e58a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBattleAnnounce
CREATE TABLE IF NOT EXISTS `game_cfg_campbattleannounce` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `dec` VARCHAR(163) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_97c06872798e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBattleAttributeIntensify
CREATE TABLE IF NOT EXISTS `game_cfg_campbattleattributeintensify` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `atk` BIGINT UNSIGNED NULL,
  `def` BIGINT UNSIGNED NULL,
  `hp` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_19513a0c5bcd` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBattleBox
CREATE TABLE IF NOT EXISTS `game_cfg_campbattlebox` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` BIGINT UNSIGNED NULL,
  `Max` BIGINT UNSIGNED NULL,
  `Min` BIGINT UNSIGNED NULL,
  `Rewards` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9cefd5f373d1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBattleCollectionReward
CREATE TABLE IF NOT EXISTS `game_cfg_campbattlecollectionreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Max` BIGINT UNSIGNED NULL,
  `Min` BIGINT UNSIGNED NULL,
  `RewardsDeuce` VARCHAR(32) NULL,
  `RewardsLose` VARCHAR(32) NULL,
  `RewardsWin` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a4e7c61d5cf4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBattleConfig
CREATE TABLE IF NOT EXISTS `game_cfg_campbattleconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AnnounceMaxCount` BIGINT UNSIGNED NULL,
  `Attribute_One_Intensify_Value` BIGINT UNSIGNED NULL,
  `AttributeIntensifyTime` BIGINT UNSIGNED NULL,
  `BattleScoreToBox` BIGINT UNSIGNED NULL,
  `BattleSpecialEndTime` BIGINT UNSIGNED NULL,
  `BuyOneActionCount` BIGINT UNSIGNED NULL,
  `CampBattleAnnoucementListMaxCnt` BIGINT UNSIGNED NULL,
  `CampBattleBaseCampScore` BIGINT UNSIGNED NULL,
  `CollectionPointEexpend` VARCHAR(32) NULL,
  `FortDungeonHoldScoreUp` BIGINT UNSIGNED NULL,
  `FortDungeonLoseScoreUp` BIGINT UNSIGNED NULL,
  `FortHoldEmailId` BIGINT UNSIGNED NULL,
  `GiveUpTime` BIGINT UNSIGNED NULL,
  `GuardTime` BIGINT UNSIGNED NULL,
  `NeutralityPointDungeonId` VARCHAR(43) NULL,
  `NeutralityPointEexpend` VARCHAR(32) NULL,
  `StrongPointEexpend` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4142b750692c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBattleDifficulty
CREATE TABLE IF NOT EXISTS `game_cfg_campbattledifficulty` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattleValueGrowthRatio` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `GrowthRatio` BIGINT UNSIGNED NULL,
  `Max` BIGINT UNSIGNED NULL,
  `Min` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_dcd721bde5f9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBattleFightReward
CREATE TABLE IF NOT EXISTS `game_cfg_campbattlefightreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Max` BIGINT UNSIGNED NULL,
  `Min` BIGINT UNSIGNED NULL,
  `RewardsDeuce` VARCHAR(32) NULL,
  `RewardsLose` VARCHAR(32) NULL,
  `RewardsWin` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_18d6dc2183ea` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBattleLayout
CREATE TABLE IF NOT EXISTS `game_cfg_campbattlelayout` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddNature` VARCHAR(32) NULL,
  `BossDungeonId` BIGINT UNSIGNED NULL,
  `CampType` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `DefenderDungeonId` BIGINT UNSIGNED NULL,
  `FollowerDungeonId` VARCHAR(88) NULL,
  `IsStartOpen` BIGINT UNSIGNED NULL,
  `RelationForts` VARCHAR(32) NULL,
  `ScorePerMin` BIGINT UNSIGNED NULL,
  `Star` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d243f65073a9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBattleLeaderReward
CREATE TABLE IF NOT EXISTS `game_cfg_campbattleleaderreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` BIGINT UNSIGNED NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Max` BIGINT UNSIGNED NULL,
  `Min` BIGINT UNSIGNED NULL,
  `RewardsDeuce` VARCHAR(32) NULL,
  `RewardsLose` VARCHAR(32) NULL,
  `RewardsWin` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5a33858d8e74` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBattleNatureItem
CREATE TABLE IF NOT EXISTS `game_cfg_campbattlenatureitem` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `NatureAddRatio` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c9383dd474fd` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBattleScoreReward
CREATE TABLE IF NOT EXISTS `game_cfg_campbattlescorereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Max` BIGINT UNSIGNED NULL,
  `Min` BIGINT UNSIGNED NULL,
  `RewardsDeuce` VARCHAR(35) NULL,
  `RewardsLose` VARCHAR(37) NULL,
  `RewardsWin` VARCHAR(36) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ece6137a7329` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBattleStrongPointControlLimit
CREATE TABLE IF NOT EXISTS `game_cfg_campbattlestrongpointcontrollimit` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `score` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_dafe211f5725` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBattleTeamCount
CREATE TABLE IF NOT EXISTS `game_cfg_campbattleteamcount` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ResonanceCount` BIGINT UNSIGNED NULL,
  `TeamCount` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c9a1dcb5d4b3` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBlessing
CREATE TABLE IF NOT EXISTS `game_cfg_campblessing` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `MaxCount` BIGINT UNSIGNED NULL,
  `MaxGrowth` BIGINT UNSIGNED NULL,
  `MinGrowth` BIGINT UNSIGNED NULL,
  `SkipLevel` BIGINT UNSIGNED NULL,
  `TotalLevel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_abf33ab5fefa` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBuild
CREATE TABLE IF NOT EXISTS `game_cfg_campbuild` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `DoubleItemCount` BIGINT UNSIGNED NULL,
  `DoubleLeftStep` BIGINT UNSIGNED NULL,
  `FlagCount` BIGINT UNSIGNED NULL,
  `FlagReward` VARCHAR(32) NULL,
  `GoCount` BIGINT UNSIGNED NULL,
  `LeftStep` BIGINT UNSIGNED NULL,
  `PhaseValue` VARCHAR(32) NULL,
  `StepReward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b91e8f7933cc` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBuildBox
CREATE TABLE IF NOT EXISTS `game_cfg_campbuildbox` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BuildReward` VARCHAR(32) NULL,
  `BuildValue` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f49b0a6675dd` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBuildItemPool
CREATE TABLE IF NOT EXISTS `game_cfg_campbuilditempool` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Atlas` VARCHAR(32) NULL,
  `Icon` VARCHAR(32) NULL,
  `ItemCount` BIGINT UNSIGNED NULL,
  `ItemId` BIGINT UNSIGNED NULL,
  `ItemType` BIGINT UNSIGNED NULL,
  `Max` BIGINT UNSIGNED NULL,
  `Min` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_505c30a69f50` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampBuildRank
CREATE TABLE IF NOT EXISTS `game_cfg_campbuildrank` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ActivityNumber` VARCHAR(32) NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Rank` VARCHAR(32) NULL,
  `Rewards` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_226143c5a0ee` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampConfig
CREATE TABLE IF NOT EXISTS `game_cfg_campconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ActionInitCount` BIGINT UNSIGNED NULL,
  `BattleCollectionMax` BIGINT UNSIGNED NULL,
  `BattleFightMax` BIGINT UNSIGNED NULL,
  `BattleOpeningDate` VARCHAR(32) NULL,
  `BattlePerPage` BIGINT UNSIGNED NULL,
  `BattleRankRefreshTime` BIGINT UNSIGNED NULL,
  `ChangeCost` BIGINT UNSIGNED NULL,
  `CommanderSkill1` BIGINT UNSIGNED NULL,
  `Compensation` BIGINT UNSIGNED NULL,
  `GainDiamond` BIGINT UNSIGNED NULL,
  `GainExtraGrain` BIGINT UNSIGNED NULL,
  `InDebug` BOOLEAN NULL,
  `InitGrain` BIGINT UNSIGNED NULL,
  `IsDouble` BIGINT UNSIGNED NULL,
  `LeaderSkill1` BIGINT UNSIGNED NULL,
  `LeaderSkill2` BIGINT UNSIGNED NULL,
  `MarshalSkill1` BIGINT UNSIGNED NULL,
  `MarshalSkill2` BIGINT UNSIGNED NULL,
  `PopulationGap` BIGINT UNSIGNED NULL,
  `PowerGap` BIGINT UNSIGNED NULL,
  `PrestigeRankingDate` VARCHAR(32) NULL,
  `QualificationCost` BIGINT UNSIGNED NULL,
  `SaluteCommanderCost` BIGINT UNSIGNED NULL,
  `SaluteCommanderReward` VARCHAR(32) NULL,
  `SaluteLeaderCost` BIGINT UNSIGNED NULL,
  `SaluteLeaderReward` VARCHAR(32) NULL,
  `SaluteMarshalCost` BIGINT UNSIGNED NULL,
  `SaluteMarshalReward` VARCHAR(32) NULL,
  `VoteExpireDate` VARCHAR(32) NULL,
  `WorshipPos` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_52d406815ab8` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampGather
CREATE TABLE IF NOT EXISTS `game_cfg_campgather` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BasicReward` VARCHAR(32) NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  `ExtraReward` VARCHAR(32) NULL,
  `FailReward` VARCHAR(32) NULL,
  `SuccessReward` VARCHAR(32) NULL,
  `SuccessScore` BIGINT UNSIGNED NULL,
  `TextEmotion` BIGINT UNSIGNED NULL,
  `texture_path` VARCHAR(47) NULL,
  `Type` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_263d0c92e2d9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampPlay
CREATE TABLE IF NOT EXISTS `game_cfg_campplay` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `iconPath` VARCHAR(36) NULL,
  `limitId` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `time` TIME NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_0227236113d0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampPrestigeReward
CREATE TABLE IF NOT EXISTS `game_cfg_campprestigereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Rank` VARCHAR(32) NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4d4b72068992` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampScoreRule
CREATE TABLE IF NOT EXISTS `game_cfg_campscorerule` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattleLayoutScore` BIGINT UNSIGNED NULL,
  `CampBattleResult` VARCHAR(32) NULL,
  `GatherScore` BIGINT UNSIGNED NULL,
  `NeutralScore` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_bbdbe04d3f6a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampStarsUpdate
CREATE TABLE IF NOT EXISTS `game_cfg_campstarsupdate` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BlackTortoiseAttr` VARCHAR(32) NULL,
  `BlackTortoiseCost` VARCHAR(32) NULL,
  `BlackTortoiseFee` BIGINT UNSIGNED NULL,
  `CEHUA` TEXT NULL,
  `GreenDragonAttr` VARCHAR(32) NULL,
  `GreenDragonCost` VARCHAR(32) NULL,
  `GreenDragonFee` BIGINT UNSIGNED NULL,
  `Name` VARCHAR(32) NULL,
  `Notes` VARCHAR(32) NULL,
  `Rate` BIGINT UNSIGNED NULL,
  `RedPhoenixAttr` VARCHAR(32) NULL,
  `RedPhoenixCost` VARCHAR(32) NULL,
  `RedPhoenixFee` BIGINT UNSIGNED NULL,
  `TitleId` TEXT NULL,
  `WhiteTigerAttr` VARCHAR(32) NULL,
  `WhiteTigerCost` VARCHAR(32) NULL,
  `WhiteTigerFee` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e16b08bc2429` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampTitle
CREATE TABLE IF NOT EXISTS `game_cfg_camptitle` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Id` BIGINT UNSIGNED NULL,
  `AtlasName` VARCHAR(32) NULL,
  `Icon` VARCHAR(32) NULL,
  `Notes` VARCHAR(32) NULL,
  `PrestigeNum` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6f0479fd649c` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampVote
CREATE TABLE IF NOT EXISTS `game_cfg_campvote` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ticket` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c3bf4ec59c23` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CampWorship
CREATE TABLE IF NOT EXISTS `game_cfg_campworship` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `award` VARCHAR(32) NULL,
  `BattlePower` BIGINT UNSIGNED NULL,
  `heroId` BIGINT UNSIGNED NULL,
  `Icon` BIGINT UNSIGNED NULL,
  `isDouble` BOOLEAN NULL,
  `Level` BIGINT UNSIGNED NULL,
  `modelId` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `spend` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_bea44699afe8` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CanoeConfig
CREATE TABLE IF NOT EXISTS `game_cfg_canoeconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BasicDistance` BIGINT UNSIGNED NULL,
  `CostDiamond` VARCHAR(33) NULL,
  `CostTicket` BIGINT UNSIGNED NULL,
  `EndSecond` BIGINT UNSIGNED NULL,
  `MaxDelayTime` BIGINT UNSIGNED NULL,
  `MaxOperateCount` BIGINT UNSIGNED NULL,
  `MinDelayTime` BIGINT UNSIGNED NULL,
  `NpcDistance` TEXT NULL,
  `OnceMaxDistance` BIGINT UNSIGNED NULL,
  `SpeedUpDistance` BIGINT UNSIGNED NULL,
  `TicketId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_59af5514e696` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CanoeDirection
CREATE TABLE IF NOT EXISTS `game_cfg_canoedirection` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `Count` BIGINT UNSIGNED NULL,
  `DirectionGroup` VARCHAR(32) NULL,
  `Index` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_54b853e2ead0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CanoeMatchReward
CREATE TABLE IF NOT EXISTS `game_cfg_canoematchreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableDistance` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_614011c6e291` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CanoeOnceDistanceReward
CREATE TABLE IF NOT EXISTS `game_cfg_canoeoncedistancereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableDistance` BIGINT UNSIGNED NULL,
  `AvailableIndex` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `RacingType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1009f048b9ce` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CanoeRankReward
CREATE TABLE IF NOT EXISTS `game_cfg_canoerankreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Rank` VARCHAR(32) NULL,
  `Rewards` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c673f7e31096` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CarnivalBossConfig
CREATE TABLE IF NOT EXISTS `game_cfg_carnivalbossconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BossNpcId` BIGINT UNSIGNED NULL,
  `DefaultRankReward` VARCHAR(32) NULL,
  `MaxDegree` BIGINT UNSIGNED NULL,
  `MaxLevel` BIGINT UNSIGNED NULL,
  `QueueCount` BIGINT UNSIGNED NULL,
  `RankRewardCount` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a6c222fc98a6` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CarnivalBossDungeon
CREATE TABLE IF NOT EXISTS `game_cfg_carnivalbossdungeon` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e7d8bb2c54c6` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CarnivalBossRankReward
CREATE TABLE IF NOT EXISTS `game_cfg_carnivalbossrankreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Rank` VARCHAR(32) NULL,
  `Rewards` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7bf76b7325b0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CarnivalBossReward
CREATE TABLE IF NOT EXISTS `game_cfg_carnivalbossreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Degree` VARCHAR(32) NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(57) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9659cf9eb1b4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CharacterConfig
CREATE TABLE IF NOT EXISTS `game_cfg_characterconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ArenaCoin` BIGINT UNSIGNED NULL,
  `BeginAngle` BIGINT UNSIGNED NULL,
  `BeginPosX` DECIMAL(3,2) NULL,
  `BeginPosY` DECIMAL(2,1) NULL,
  `ChatFrame` BIGINT UNSIGNED NULL,
  `Diamond` BIGINT UNSIGNED NULL,
  `Exp` BIGINT UNSIGNED NULL,
  `FaceFrame` BIGINT UNSIGNED NULL,
  `FirstMainQueueNum` BIGINT UNSIGNED NULL,
  `FirstTask` BIGINT UNSIGNED NULL,
  `FriendlyHeart` BIGINT UNSIGNED NULL,
  `Gold` BIGINT UNSIGNED NULL,
  `InitHeroId` BIGINT UNSIGNED NULL,
  `InitHeros` TEXT NULL,
  `InitHeroSex` BIGINT UNSIGNED NULL,
  `InitItems` TEXT NULL,
  `InitJob` BIGINT UNSIGNED NULL,
  `InitName` VARCHAR(32) NULL,
  `Level` BIGINT UNSIGNED NULL,
  `MapId` BIGINT UNSIGNED NULL,
  `MaxLevel` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `SoulCrystal` BIGINT UNSIGNED NULL,
  `SoulPower` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_bacc937263cf` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CharacterLevel
CREATE TABLE IF NOT EXISTS `game_cfg_characterlevel` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Exp` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_abc66a1e9716` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: BubbleEffect
CREATE TABLE IF NOT EXISTS `game_cfg_bubbleeffect` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `description` VARCHAR(32) NULL,
  `effect` BIGINT UNSIGNED NULL,
  `textColor` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_13fe31d2a047` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ChatBubble
CREATE TABLE IF NOT EXISTS `game_cfg_chatbubble` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ActivateType` BIGINT UNSIGNED NULL,
  `currency` BIGINT UNSIGNED NULL,
  `discount` BIGINT UNSIGNED NULL,
  `disprice` BIGINT UNSIGNED NULL,
  `endDate` DATETIME(6) NULL,
  `expiryDate` BIGINT UNSIGNED NULL,
  `MainType` BIGINT UNSIGNED NULL,
  `maxNum` BIGINT UNSIGNED NULL,
  `notes` VARCHAR(32) NULL,
  `price` BIGINT UNSIGNED NULL,
  `startDate` DATETIME(6) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4bb448cdabde` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ChatConfig
CREATE TABLE IF NOT EXISTS `game_cfg_chatconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CampIntervalTime` BIGINT UNSIGNED NULL,
  `ChatIntervalTime` VARCHAR(32) NULL,
  `ChatMaxEmoji` BIGINT UNSIGNED NULL,
  `ChatParamMaxCount` BIGINT UNSIGNED NULL,
  `ChatQuickWordDestroyTime` BIGINT UNSIGNED NULL,
  `ChatTrumpetMaxCount` BIGINT UNSIGNED NULL,
  `ChatWordMaxCount` BIGINT UNSIGNED NULL,
  `ConscripeIntervalTime` BIGINT UNSIGNED NULL,
  `DefaultSilenceReason` VARCHAR(32) NULL,
  `FamilyIntervalTime` BIGINT UNSIGNED NULL,
  `GoldTrumpet` BIGINT UNSIGNED NULL,
  `GoldTrumpetDiamond` BIGINT UNSIGNED NULL,
  `MaxMsgCount` BIGINT UNSIGNED NULL,
  `MaxRecordTime` BIGINT UNSIGNED NULL,
  `PerPersonCount` BIGINT UNSIGNED NULL,
  `PersonIntervalTime` BIGINT UNSIGNED NULL,
  `RecruitIntervalTime` BIGINT UNSIGNED NULL,
  `SensitiveWordCountLimit` BIGINT UNSIGNED NULL,
  `SensitiveWordDuration` BIGINT UNSIGNED NULL,
  `SensitiveWordSilenceReason` VARCHAR(32) NULL,
  `SensitiveWordSilenceTime` BIGINT UNSIGNED NULL,
  `ShowTimeInterval` BIGINT UNSIGNED NULL,
  `SilverTrumpet` BIGINT UNSIGNED NULL,
  `SilverTrumpetDiamond` BIGINT UNSIGNED NULL,
  `TeamIntervalTime` BIGINT UNSIGNED NULL,
  `TipOffChatRecordEntry` BIGINT UNSIGNED NULL,
  `TipOffDescriptionLimit` BIGINT UNSIGNED NULL,
  `TrumpetDelayTime` BIGINT UNSIGNED NULL,
  `TrumpetMaxWordCnt` BIGINT UNSIGNED NULL,
  `WordMaxCount` BIGINT UNSIGNED NULL,
  `WorldIntervalTime` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_bfa6b71d126e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ChatTrumpet
CREATE TABLE IF NOT EXISTS `game_cfg_chattrumpet` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beFirst` BOOLEAN NULL,
  `beSecond` BOOLEAN NULL,
  `currency` BIGINT UNSIGNED NULL,
  `discount` BIGINT UNSIGNED NULL,
  `disprice` BIGINT UNSIGNED NULL,
  `endDate` TEXT NULL,
  `maxNum` BIGINT UNSIGNED NULL,
  `notes` VARCHAR(32) NULL,
  `notToSell` BIGINT UNSIGNED NULL,
  `passLevel` BIGINT UNSIGNED NULL,
  `price` BIGINT UNSIGNED NULL,
  `startDate` DATETIME(6) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e0c7f25d5ca2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ChatWhiteContent
CREATE TABLE IF NOT EXISTS `game_cfg_chatwhitecontent` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Content` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_69c27ec4952c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TrumpetEffect
CREATE TABLE IF NOT EXISTS `game_cfg_trumpeteffect` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `border` VARCHAR(32) NULL,
  `CEHUA` VARCHAR(32) NULL,
  `effect` VARCHAR(39) NULL,
  `textColor` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ea0671d2d20c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: WorldEmoticon
CREATE TABLE IF NOT EXISTS `game_cfg_worldemoticon` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `atlas` VARCHAR(32) NULL,
  `dec` VARCHAR(32) NULL,
  `emojiName` VARCHAR(32) NULL,
  `group` BIGINT UNSIGNED NULL,
  `sprite` VARCHAR(41) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b75fbbe2b1a1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ActivityConfig
CREATE TABLE IF NOT EXISTS `game_cfg_activityconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CheckRefreshTime` BIGINT UNSIGNED NULL,
  `DefaultTab` BIGINT UNSIGNED NULL,
  `RunawayActivityDurringTime` BIGINT UNSIGNED NULL,
  `RunawayActivityNextTime` BIGINT UNSIGNED NULL,
  `TabVisible` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5600cebbd0c0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: BattleConfig
CREATE TABLE IF NOT EXISTS `game_cfg_battleconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `EnergyCureRatio` BIGINT UNSIGNED NULL,
  `EnergyHitRatio` BIGINT UNSIGNED NULL,
  `EnergyMaxAdd` BIGINT UNSIGNED NULL,
  `EnergyOnHitRatio` BIGINT UNSIGNED NULL,
  `FleeCountLimit` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3d09f888cd62` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ConstConfig
CREATE TABLE IF NOT EXISTS `game_cfg_constconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AcceptDungeonFrame` BIGINT UNSIGNED NULL,
  `AdJustChannelFrame` BIGINT UNSIGNED NULL,
  `AuthCheck` BIGINT UNSIGNED NULL,
  `BlowFishEncrypt` BOOLEAN NULL,
  `BroadcastLimit` BIGINT UNSIGNED NULL,
  `CampChatSeconds` BIGINT UNSIGNED NULL,
  `CardResolveMaxCount` BIGINT UNSIGNED NULL,
  `CatchOfflinePeriod` BIGINT UNSIGNED NULL,
  `CatchOfflinePlayer` BIGINT UNSIGNED NULL,
  `ChackPassword` BIGINT UNSIGNED NULL,
  `ChangeNameCost` BIGINT UNSIGNED NULL,
  `DbQueueCount` BIGINT UNSIGNED NULL,
  `DbTransactionCount` BIGINT UNSIGNED NULL,
  `InitialBagLimit` BIGINT UNSIGNED NULL,
  `ItemUnravelEmailId` BIGINT UNSIGNED NULL,
  `JewelAdvanceMaxCount` BIGINT UNSIGNED NULL,
  `LogServerKey` VARCHAR(32) NULL,
  `OneKeyUpgradStepLevel` BIGINT UNSIGNED NULL,
  `OnlyWhiteList` BIGINT UNSIGNED NULL,
  `PageServerCount` BIGINT UNSIGNED NULL,
  `PlayerInfoDuration` BIGINT UNSIGNED NULL,
  `RegionSize` BIGINT UNSIGNED NULL,
  `SpeakerCost` BIGINT UNSIGNED NULL,
  `TrackingLogSwitch` BIGINT UNSIGNED NULL,
  `UnlockItemTimeCost` BIGINT UNSIGNED NULL,
  `UseDbServerList` BIGINT UNSIGNED NULL,
  `WaitStreamCounDisconnect` BIGINT UNSIGNED NULL,
  `WaitStreamCountHalf` BIGINT UNSIGNED NULL,
  `WaitStreamCountQuarter` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1d8d5bff1a7a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DataInfoConfig
CREATE TABLE IF NOT EXISTS `game_cfg_datainfoconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BaseInfoUpdateTime` BIGINT UNSIGNED NULL,
  `DetailedUpdateTime` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7252eb4f194c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DefaultName
CREATE TABLE IF NOT EXISTS `game_cfg_defaultname` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `HeroQueueName_0` VARCHAR(32) NULL,
  `HeroQueueName_1` VARCHAR(32) NULL,
  `HeroQueueName_2` VARCHAR(32) NULL,
  `HeroQueueName_3` VARCHAR(32) NULL,
  `HeroQueueName_4` VARCHAR(32) NULL,
  `SkillQueueName_0` VARCHAR(32) NULL,
  `SkillQueueName_1` BIGINT UNSIGNED NULL,
  `SkillQueueName_2` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1e52e390c064` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DungeonConfig
CREATE TABLE IF NOT EXISTS `game_cfg_dungeonconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `SkipBattleSpeedUp` BIGINT UNSIGNED NULL,
  `SpeedUpPerFpsAddTime` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7ae7591e68de` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: EquipConfig
CREATE TABLE IF NOT EXISTS `game_cfg_equipconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CostDiamond` BIGINT UNSIGNED NULL,
  `Discount1Num` DECIMAL(3,2) NULL,
  `Discount2Num` DECIMAL(2,1) NULL,
  `Discount3Num` DECIMAL(3,2) NULL,
  `Discount4Num` DECIMAL(2,1) NULL,
  `GoldMin` BIGINT UNSIGNED NULL,
  `GradeMin` BIGINT UNSIGNED NULL,
  `HighGrade` BIGINT UNSIGNED NULL,
  `InlayXuanyuLevel` BIGINT UNSIGNED NULL,
  `LimitNum` BIGINT UNSIGNED NULL,
  `MaterialCnt` BIGINT UNSIGNED NULL,
  `MaxOnkeyNum` BIGINT UNSIGNED NULL,
  `ResolveItem` BIGINT UNSIGNED NULL,
  `ReturnItem` BIGINT UNSIGNED NULL,
  `ReturnNum` DECIMAL(2,1) NULL,
  `Step1Num` BIGINT UNSIGNED NULL,
  `Step2Num` BIGINT UNSIGNED NULL,
  `Step3Num` BIGINT UNSIGNED NULL,
  `Step4Num` BIGINT UNSIGNED NULL,
  `UpgradeProtect` VARCHAR(32) NULL,
  `UpgradeToLevel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d9d854c2cb05` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HuntingConfig
CREATE TABLE IF NOT EXISTS `game_cfg_huntingconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `SweepingCardId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_832a203e0a30` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: InputLimit
CREATE TABLE IF NOT EXISTS `game_cfg_inputlimit` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `info` VARCHAR(32) NULL,
  `name` VARCHAR(35) NULL,
  `value` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_165dc0e28dc8` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: LiftConfig
CREATE TABLE IF NOT EXISTS `game_cfg_liftconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `closeTime` BIGINT UNSIGNED NULL,
  `DownPeriod` BIGINT UNSIGNED NULL,
  `GoingDownPeriod` BIGINT UNSIGNED NULL,
  `GoingUpPeriod` BIGINT UNSIGNED NULL,
  `LiftLength` BIGINT UNSIGNED NULL,
  `LiftWedth` BIGINT UNSIGNED NULL,
  `NpcId` BIGINT UNSIGNED NULL,
  `openTime` BIGINT UNSIGNED NULL,
  `UpPeriod` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e4fa730abb81` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: LineupConfig
CREATE TABLE IF NOT EXISTS `game_cfg_lineupconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `MaxSubCount` BIGINT UNSIGNED NULL,
  `SubAvailable` BIGINT UNSIGNED NULL,
  `SubButtonVisible` BIGINT UNSIGNED NULL,
  `SubLockCount` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1163ea794f45` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PathFindingConfig
CREATE TABLE IF NOT EXISTS `game_cfg_pathfindingconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `TaskFlyDisLimit` BIGINT UNSIGNED NULL,
  `TaskFlyRandomDis` DECIMAL(3,2) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_53269cce68e2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PushConfig
CREATE TABLE IF NOT EXISTS `game_cfg_pushconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Password` VARCHAR(32) NULL,
  `Username` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5098a5f6049b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: QuenchConfig
CREATE TABLE IF NOT EXISTS `game_cfg_quenchconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `HighQuality` BIGINT UNSIGNED NULL,
  `LockCost` VARCHAR(37) NULL,
  `QuenchCost` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_87131b04e923` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ServerListRedirect
CREATE TABLE IF NOT EXISTS `game_cfg_serverlistredirect` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `OpenRedirectTime` DATETIME(6) NULL,
  `Redirect` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_bd4139039310` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SpaceConfig
CREATE TABLE IF NOT EXISTS `game_cfg_spaceconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `faceMaxSize` BIGINT UNSIGNED NULL,
  `maxPhotoCount` BIGINT UNSIGNED NULL,
  `photoMaxSize` BIGINT UNSIGNED NULL,
  `token` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_510cd23e8377` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TeamConfig
CREATE TABLE IF NOT EXISTS `game_cfg_teamconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DelayEnterTime` BIGINT UNSIGNED NULL,
  `EnergyAddNum` BIGINT UNSIGNED NULL,
  `EnergyCanMaxNum` BIGINT UNSIGNED NULL,
  `EnergyMaxNum` BIGINT UNSIGNED NULL,
  `HelpCDTime` BIGINT UNSIGNED NULL,
  `HelpCount` BIGINT UNSIGNED NULL,
  `HelpDelayTime` BIGINT UNSIGNED NULL,
  `HelpLevelRange` BIGINT UNSIGNED NULL,
  `HelpSendTime` BIGINT UNSIGNED NULL,
  `HelpTime` BIGINT UNSIGNED NULL,
  `RepeatLevelRange` BIGINT UNSIGNED NULL,
  `RepeatSendTime` BIGINT UNSIGNED NULL,
  `ResearchRange` VARCHAR(32) NULL,
  `ReviveTime` BIGINT UNSIGNED NULL,
  `RobortTime` BIGINT UNSIGNED NULL,
  `TeamMemberCountLimit` BIGINT UNSIGNED NULL,
  `VerifyQuitTeam` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d52d2f297d79` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: VideoConfig
CREATE TABLE IF NOT EXISTS `game_cfg_videoconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `upload` BIGINT UNSIGNED NULL,
  `vedioFileSuffix` VARCHAR(32) NULL,
  `vedioInfoSuffix` VARCHAR(32) NULL,
  `VideoDungeonId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_66faaf980992` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Counter
CREATE TABLE IF NOT EXISTS `game_cfg_counter` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CeHua` VARCHAR(32) NULL,
  `DbColumn` BIGINT UNSIGNED NULL,
  `InitMax` BIGINT UNSIGNED NULL,
  `MaxCount` BIGINT UNSIGNED NULL,
  `name` VARCHAR(33) NULL,
  `NeedSync` BIGINT UNSIGNED NULL,
  `Price` TEXT NULL,
  `RefreshParam` VARCHAR(32) NULL,
  `RefreshType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f4018045cfb4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: MapTypeCounter
CREATE TABLE IF NOT EXISTS `game_cfg_maptypecounter` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(55) NULL,
  `CounterBuyType` BIGINT UNSIGNED NULL,
  `CounterType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f5d66121583d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossConfig
CREATE TABLE IF NOT EXISTS `game_cfg_crossconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ActiveNum` BIGINT UNSIGNED NULL,
  `BattleEmail16` BIGINT UNSIGNED NULL,
  `BattleEmail2` BIGINT UNSIGNED NULL,
  `BattleEmail32` BIGINT UNSIGNED NULL,
  `BattleEmail4` BIGINT UNSIGNED NULL,
  `BattleEmail64` BIGINT UNSIGNED NULL,
  `BattleEmail8` BIGINT UNSIGNED NULL,
  `BattleTime1` VARCHAR(32) NULL,
  `BattleTime2` VARCHAR(32) NULL,
  `BattleTime3` VARCHAR(32) NULL,
  `BattleTime4` VARCHAR(32) NULL,
  `BattleTime5` VARCHAR(32) NULL,
  `BattleTime6` VARCHAR(32) NULL,
  `BattleTimeSpan` TIME NULL,
  `ChallengeLoseReward` VARCHAR(32) NULL,
  `ChallengeWinReward` VARCHAR(32) NULL,
  `CrossInitPointOffsetDistance` BIGINT UNSIGNED NULL,
  `CrossQueueCount` BIGINT UNSIGNED NULL,
  `CrossWalkDistance` BIGINT UNSIGNED NULL,
  `End` VARCHAR(32) NULL,
  `FightPlayerCount` BIGINT UNSIGNED NULL,
  `FinalsReward` VARCHAR(32) NULL,
  `FinalsStart` VARCHAR(32) NULL,
  `GuessingEmail` BIGINT UNSIGNED NULL,
  `GuessingOnhookRatio` DECIMAL(2,1) NULL,
  `GuessingOnhookReward` BIGINT UNSIGNED NULL,
  `GuessingTimeSpan` TIME NULL,
  `InfoRefreshTime` BIGINT UNSIGNED NULL,
  `LoseStar` BIGINT UNSIGNED NULL,
  `MapId` BIGINT UNSIGNED NULL,
  `PrepareEmail` BIGINT UNSIGNED NULL,
  `PrepareTime` BIGINT UNSIGNED NULL,
  `PrepareTimeSpan` TIME NULL,
  `PushTime` TIME NULL,
  `RankMax` BIGINT UNSIGNED NULL,
  `RankPerPage` BIGINT UNSIGNED NULL,
  `RankRefreshTime` BIGINT UNSIGNED NULL,
  `ServerReward` VARCHAR(32) NULL,
  `ShowRefreshTime` BIGINT UNSIGNED NULL,
  `Start` VARCHAR(32) NULL,
  `WinStar` BIGINT UNSIGNED NULL,
  `WinStreakNum` BIGINT UNSIGNED NULL,
  `WinStreakStar` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e88842a12cd6` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossFightGroup
CREATE TABLE IF NOT EXISTS `game_cfg_crossfightgroup` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `rank` BIGINT UNSIGNED NULL,
  `server` BIGINT UNSIGNED NULL,
  `team` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d92143793393` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossFightIndex
CREATE TABLE IF NOT EXISTS `game_cfg_crossfightindex` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `fight1` BIGINT UNSIGNED NULL,
  `fight2` BIGINT UNSIGNED NULL,
  `fight3` BIGINT UNSIGNED NULL,
  `rank` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9224aa59e770` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossFinalsReward
CREATE TABLE IF NOT EXISTS `game_cfg_crossfinalsreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `RankMax` BIGINT UNSIGNED NULL,
  `RankMin` BIGINT UNSIGNED NULL,
  `Rewards` VARCHAR(65) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_fde1e4ce7df0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossLevel
CREATE TABLE IF NOT EXISTS `game_cfg_crosslevel` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ActiveReward` VARCHAR(40) NULL,
  `AddStar` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `CheckRange` VARCHAR(62) NULL,
  `LimitStar` BIGINT UNSIGNED NULL,
  `MinNum` BIGINT UNSIGNED NULL,
  `PreliminaryReward` VARCHAR(53) NULL,
  `ResetStar` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_0420390a23a5` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossBossConfig
CREATE TABLE IF NOT EXISTS `game_cfg_crossbossconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CrossBossOpenTime` BIGINT UNSIGNED NULL,
  `CrossBossQueueCount` BIGINT UNSIGNED NULL,
  `DefenseEmail` BIGINT UNSIGNED NULL,
  `DefenseMap` BIGINT UNSIGNED NULL,
  `InfoUpdateTime` BIGINT UNSIGNED NULL,
  `ScoreParamA` DECIMAL(7,6) NULL,
  `ScoreParamB` BIGINT UNSIGNED NULL,
  `ScoreParamC` DECIMAL(2,1) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3b337f0ee9a4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossBossDungeon
CREATE TABLE IF NOT EXISTS `game_cfg_crossbossdungeon` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `buffFrom` VARCHAR(32) NULL,
  `BuffId` BIGINT UNSIGNED NULL,
  `buffIntensity` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `chapter` BIGINT UNSIGNED NULL,
  `defenseTo` VARCHAR(48) NULL,
  `Email` BIGINT UNSIGNED NULL,
  `FristRankReward` VARCHAR(32) NULL,
  `GoldCoin` BIGINT UNSIGNED NULL,
  `GoldCoinGrowthFactor` DECIMAL(6,5) NULL,
  `MaxGold` BIGINT UNSIGNED NULL,
  `maxHp` BIGINT UNSIGNED NULL,
  `nodeType` BIGINT UNSIGNED NULL,
  `RankEmail` BIGINT UNSIGNED NULL,
  `RankRewards` VARCHAR(40) NULL,
  `Rewards` VARCHAR(36) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_15687e867a12` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossBossGroup
CREATE TABLE IF NOT EXISTS `game_cfg_crossbossgroup` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `dungeons` TEXT NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1d13399d6c81` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossBossRankReward
CREATE TABLE IF NOT EXISTS `game_cfg_crossbossrankreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ActivityNumber` VARCHAR(32) NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Rank` VARCHAR(32) NULL,
  `Rewards` VARCHAR(65) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f8a1d84a2600` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossChallengeConfig
CREATE TABLE IF NOT EXISTS `game_cfg_crosschallengeconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ActiveNum` BIGINT UNSIGNED NULL,
  `BattleEmail16` BIGINT UNSIGNED NULL,
  `BattleEmail2` BIGINT UNSIGNED NULL,
  `BattleEmail32` BIGINT UNSIGNED NULL,
  `BattleEmail4` BIGINT UNSIGNED NULL,
  `BattleEmail64` BIGINT UNSIGNED NULL,
  `BattleEmail8` BIGINT UNSIGNED NULL,
  `BattleTime1` VARCHAR(32) NULL,
  `BattleTime2` VARCHAR(32) NULL,
  `BattleTime3` VARCHAR(32) NULL,
  `BattleTime4` VARCHAR(32) NULL,
  `BattleTime5` VARCHAR(32) NULL,
  `BattleTime6` VARCHAR(32) NULL,
  `BattleTimeSpan` TIME NULL,
  `CrossInitPointOffsetDistance` BIGINT UNSIGNED NULL,
  `CrossQueueCount` BIGINT UNSIGNED NULL,
  `CrossWalkDistance` BIGINT UNSIGNED NULL,
  `End` VARCHAR(32) NULL,
  `FightPlayerCount` BIGINT UNSIGNED NULL,
  `FinalsReward` VARCHAR(32) NULL,
  `FinalsStart` VARCHAR(32) NULL,
  `GuessingEmail` BIGINT UNSIGNED NULL,
  `GuessingOnhookRatio` DECIMAL(2,1) NULL,
  `GuessingOnhookReward` BIGINT UNSIGNED NULL,
  `GuessingTimeSpan` TIME NULL,
  `InfoRefreshTime` BIGINT UNSIGNED NULL,
  `MapId` BIGINT UNSIGNED NULL,
  `PrepareEmail` BIGINT UNSIGNED NULL,
  `PrepareTime` BIGINT UNSIGNED NULL,
  `PrepareTimeSpan` TIME NULL,
  `PushTime` TIME NULL,
  `ServerReward` VARCHAR(32) NULL,
  `ShowRefreshTime` BIGINT UNSIGNED NULL,
  `Start` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_11c23f7b5689` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossChallengeFinalsReward
CREATE TABLE IF NOT EXISTS `game_cfg_crosschallengefinalsreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `RankMax` BIGINT UNSIGNED NULL,
  `RankMin` BIGINT UNSIGNED NULL,
  `Rewards` VARCHAR(52) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_58e5f41e694a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossChallengeGroup
CREATE TABLE IF NOT EXISTS `game_cfg_crosschallengegroup` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `rank` BIGINT UNSIGNED NULL,
  `server` BIGINT UNSIGNED NULL,
  `team` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3c12b190cfbf` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossChallengeIndex
CREATE TABLE IF NOT EXISTS `game_cfg_crosschallengeindex` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `fight1` BIGINT UNSIGNED NULL,
  `fight2` BIGINT UNSIGNED NULL,
  `fight3` BIGINT UNSIGNED NULL,
  `rank` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_99bf0732d6e5` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossChallengeLevel
CREATE TABLE IF NOT EXISTS `game_cfg_crosschallengelevel` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ActiveReward` VARCHAR(41) NULL,
  `AddStar` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `CheckRange` VARCHAR(62) NULL,
  `LimitStar` BIGINT UNSIGNED NULL,
  `MinNum` BIGINT UNSIGNED NULL,
  `PreliminaryReward` VARCHAR(52) NULL,
  `ResetStar` BIGINT UNSIGNED NULL,
  `WinReward` VARCHAR(32) NULL,
  `WinRewardDrop` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b1019f329b71` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Currencies
CREATE TABLE IF NOT EXISTS `game_cfg_currencies` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `atlas` VARCHAR(32) NULL,
  `atlasItem` VARCHAR(32) NULL,
  `beizhu` VARCHAR(32) NULL,
  `bigIcon` VARCHAR(37) NULL,
  `color` BIGINT UNSIGNED NULL,
  `detail` VARCHAR(32) NULL,
  `GetWayId` BIGINT UNSIGNED NULL,
  `icon` VARCHAR(36) NULL,
  `iconItem` VARCHAR(32) NULL,
  `ItemEffName` VARCHAR(32) NULL,
  `maxNum` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `Quality` BIGINT UNSIGNED NULL,
  `text` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a68898efa4d2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: WareHouseCurrencies
CREATE TABLE IF NOT EXISTS `game_cfg_warehousecurrencies` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `atlas` VARCHAR(32) NULL,
  `bigIcon` VARCHAR(33) NULL,
  `CarryMaxNum` BIGINT UNSIGNED NULL,
  `color` BIGINT UNSIGNED NULL,
  `detail` VARCHAR(32) NULL,
  `icon` VARCHAR(34) NULL,
  `isBank` BIGINT UNSIGNED NULL,
  `ItemEffName` VARCHAR(32) NULL,
  `itemtype` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `Quality` BIGINT UNSIGNED NULL,
  `text` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_2cf954c9172d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DaysRecharge
CREATE TABLE IF NOT EXISTS `game_cfg_daysrecharge` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Day` BIGINT UNSIGNED NULL,
  `GiftId` BIGINT UNSIGNED NULL,
  `LastGiftId` BIGINT UNSIGNED NULL,
  `Money` DECIMAL(4,2) NULL,
  `Order` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9509a367d69e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Delegation
CREATE TABLE IF NOT EXISTS `game_cfg_delegation` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BasicRatio` BIGINT UNSIGNED NULL,
  `BasicReward` VARCHAR(40) NULL,
  `Color` BIGINT UNSIGNED NULL,
  `ConditionDesc` BIGINT UNSIGNED NULL,
  `DispatchNum` BIGINT UNSIGNED NULL,
  `HeroJob` VARCHAR(32) NULL,
  `HeroLevel` VARCHAR(32) NULL,
  `Icon` VARCHAR(32) NULL,
  `MissionDuration` BIGINT UNSIGNED NULL,
  `Notes` VARCHAR(32) NULL,
  `Quality` BIGINT UNSIGNED NULL,
  `SkipProb` VARCHAR(42) NULL,
  `SpecialReward` VARCHAR(53) NULL,
  `TaskId` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_710ea31c1844` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DelegationConfig
CREATE TABLE IF NOT EXISTS `game_cfg_delegationconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AccelerateFee` BIGINT UNSIGNED NULL,
  `BuyTimes` BIGINT UNSIGNED NULL,
  `MaxQuality` BIGINT UNSIGNED NULL,
  `Price` VARCHAR(32) NULL,
  `RefreshTiming` BIGINT UNSIGNED NULL,
  `RenewFee` VARCHAR(32) NULL,
  `TimesPerDay` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3be9a9e731c5` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DelegationEvent
CREATE TABLE IF NOT EXISTS `game_cfg_delegationevent` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_dda00635a6e9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DelegationEventNum
CREATE TABLE IF NOT EXISTS `game_cfg_delegationeventnum` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Num` BIGINT UNSIGNED NULL,
  `TaskId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3c4d4ab9ea3d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DelegationGuarantee
CREATE TABLE IF NOT EXISTS `game_cfg_delegationguarantee` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `GuaranteeNum` BIGINT UNSIGNED NULL,
  `NewEventNum` BIGINT UNSIGNED NULL,
  `StarWeight` VARCHAR(32) NULL,
  `TaskId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a660134cfe86` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: AuthConfig
CREATE TABLE IF NOT EXISTS `game_cfg_authconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AntiAddiction` BOOLEAN NULL,
  `CheckBarrackToken` BOOLEAN NULL,
  `CheckSdkToken` BOOLEAN NULL,
  `CheckVersion` BOOLEAN NULL,
  `WhiteOnly` BOOLEAN NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4fc4c8d56d10` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: UrlConfig
CREATE TABLE IF NOT EXISTS `game_cfg_urlconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AnnounceURL` VARCHAR(117) NULL,
  `downDetailPhotoUrl` VARCHAR(66) NULL,
  `downFace` VARCHAR(57) NULL,
  `downGameVideoUrl` VARCHAR(61) NULL,
  `downPhotosUrl` VARCHAR(60) NULL,
  `downSound` VARCHAR(58) NULL,
  `giftSdkUrl` VARCHAR(70) NULL,
  `interveneSync` VARCHAR(82) NULL,
  `interveneSyncEnabled` BOOLEAN NULL,
  `interveneUrl` VARCHAR(87) NULL,
  `KTPlayBarackUrl` VARCHAR(38) NULL,
  `payUrl` VARCHAR(43) NULL,
  `RadioURL` VARCHAR(98) NULL,
  `rmPhotoUrl` VARCHAR(56) NULL,
  `TravelResURL` VARCHAR(73) NULL,
  `upFace` VARCHAR(55) NULL,
  `upPhotoUrl` VARCHAR(56) NULL,
  `upSound` VARCHAR(56) NULL,
  `videoUrl` VARCHAR(58) NULL,
  `videoUrlServer` VARCHAR(46) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_be90b5def980` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: VersionConfig
CREATE TABLE IF NOT EXISTS `game_cfg_versionconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `res` BIGINT UNSIGNED NULL,
  `Valid` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5b424a9f7e1f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: WhiteList
CREATE TABLE IF NOT EXISTS `game_cfg_whitelist` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `IP` VARCHAR(32) NULL,
  `MainId` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_32f2390c9a64` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DevilTraining
CREATE TABLE IF NOT EXISTS `game_cfg_deviltraining` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BuyMaxCount` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `ConfigType` BIGINT UNSIGNED NULL,
  `ConsecutiveCount` BIGINT UNSIGNED NULL,
  `CostDiamond` BIGINT UNSIGNED NULL,
  `CostItem` BIGINT UNSIGNED NULL,
  `HighRewardMaxNum` BIGINT UNSIGNED NULL,
  `HighRewardNumRatio` VARCHAR(32) NULL,
  `MidRewardMaxNum` BIGINT UNSIGNED NULL,
  `MidRewardNumRatio` VARCHAR(32) NULL,
  `ShowCurrency` VARCHAR(32) NULL,
  `SuperRewardMaxNum` BIGINT UNSIGNED NULL,
  `SuperRewardNumRatio` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9ecb930165aa` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DevilTrainingBuff
CREATE TABLE IF NOT EXISTS `game_cfg_deviltrainingbuff` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `After` BIGINT UNSIGNED NULL,
  `Before` BIGINT UNSIGNED NULL,
  `CurrentTimes` BIGINT UNSIGNED NULL,
  `Point` BIGINT UNSIGNED NULL,
  `Probability` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b0069620e5da` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DevilTrainingCumulativeReward
CREATE TABLE IF NOT EXISTS `game_cfg_deviltrainingcumulativereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Param` VARCHAR(50) NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Point` BIGINT UNSIGNED NULL,
  `ShowReward` VARCHAR(50) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_0913e4a095e0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DevilTrainingReward
CREATE TABLE IF NOT EXISTS `game_cfg_deviltrainingreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Grade` BIGINT UNSIGNED NULL,
  `Param` VARCHAR(32) NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Ratio` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_47bf50916689` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Domain
CREATE TABLE IF NOT EXISTS `game_cfg_domain` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `EventParam` BIGINT UNSIGNED NULL,
  `EventParam1` BIGINT UNSIGNED NULL,
  `EventParam2` BIGINT UNSIGNED NULL,
  `EventType` BIGINT UNSIGNED NULL,
  `EventType1` BIGINT UNSIGNED NULL,
  `EventType2` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `TargetType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9b10914d8b0a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DomainBenedictionConfig
CREATE TABLE IF NOT EXISTS `game_cfg_domainbenedictionconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DisCountMax` BIGINT UNSIGNED NULL,
  `DisCountMin` BIGINT UNSIGNED NULL,
  `FreeNumDay` BIGINT UNSIGNED NULL,
  `HalfFareNum` BIGINT UNSIGNED NULL,
  `MaxNum` BIGINT UNSIGNED NULL,
  `NoticeNum` BIGINT UNSIGNED NULL,
  `Probability` VARCHAR(61) NULL,
  `ReawardTitle` VARCHAR(32) NULL,
  `TitleSuccNum` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b90be16f2ac9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DomainBenedictionPrayProbBonus
CREATE TABLE IF NOT EXISTS `game_cfg_domainbenedictionprayprobbonus` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `ProbBonus` BIGINT UNSIGNED NULL,
  `ProbType` BIGINT UNSIGNED NULL,
  `RechargeDiamond` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_572450b1c9a1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DomainBenedictionStageAward
CREATE TABLE IF NOT EXISTS `game_cfg_domainbenedictionstageaward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AtlasName` VARCHAR(32) NULL,
  `Award` VARCHAR(48) NULL,
  `BoxIcon` VARCHAR(32) NULL,
  `BoxOpenIcon` VARCHAR(32) NULL,
  `IntegralNum` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5e8bff975f56` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DomainBenedictionType
CREATE TABLE IF NOT EXISTS `game_cfg_domainbenedictiontype` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Desc` VARCHAR(32) NULL,
  `DrawNum` BIGINT UNSIGNED NULL,
  `ExpendNum` BIGINT UNSIGNED NULL,
  `FixedAwardBase` VARCHAR(32) NULL,
  `IntegralNum` BIGINT UNSIGNED NULL,
  `RandomAward` VARCHAR(40) NULL,
  `RandomAwardNum` BIGINT UNSIGNED NULL,
  `Weights` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_362dd2c018d1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DragonBoatConfig
CREATE TABLE IF NOT EXISTS `game_cfg_dragonboatconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BasicDistance` BIGINT UNSIGNED NULL,
  `EndSecond` BIGINT UNSIGNED NULL,
  `MaxDelayTime` BIGINT UNSIGNED NULL,
  `MaxDistance` BIGINT UNSIGNED NULL,
  `MaxOperateCount` BIGINT UNSIGNED NULL,
  `MinDelayTime` BIGINT UNSIGNED NULL,
  `OnceTicketMaxBuyCount` BIGINT UNSIGNED NULL,
  `SpeedUpDistance` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_73bf75da79e6` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DragonBoatDirection
CREATE TABLE IF NOT EXISTS `game_cfg_dragonboatdirection` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `Count` BIGINT UNSIGNED NULL,
  `DirectionGroup` VARCHAR(32) NULL,
  `Index` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_825b6ff6ea1c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DragonBoatReward_1
CREATE TABLE IF NOT EXISTS `game_cfg_dragonboatreward_1` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableDistance` BIGINT UNSIGNED NULL,
  `AvailableIndex` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `RewardType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_02e6a7469494` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DragonBoatReward_2
CREATE TABLE IF NOT EXISTS `game_cfg_dragonboatreward_2` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableDistance` BIGINT UNSIGNED NULL,
  `AvailableIndex` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `RewardType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9947b34e4cc7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DragonBoatReward_3
CREATE TABLE IF NOT EXISTS `game_cfg_dragonboatreward_3` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableDistance` BIGINT UNSIGNED NULL,
  `AvailableIndex` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `RewardType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4bd575da1aec` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DragonBoatReward_4
CREATE TABLE IF NOT EXISTS `game_cfg_dragonboatreward_4` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableDistance` BIGINT UNSIGNED NULL,
  `AvailableIndex` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `RewardType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_fb8db3662c61` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DragonBoatReward_5
CREATE TABLE IF NOT EXISTS `game_cfg_dragonboatreward_5` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableDistance` BIGINT UNSIGNED NULL,
  `AvailableIndex` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `RewardType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_74284b14b68b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DragonBoatTicket
CREATE TABLE IF NOT EXISTS `game_cfg_dragonboatticket` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ConsumeCount` BIGINT UNSIGNED NULL,
  `GiveCount` BIGINT UNSIGNED NULL,
  `MaxBuyCount` BIGINT UNSIGNED NULL,
  `Ticket` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_8a596f802716` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Constellation
CREATE TABLE IF NOT EXISTS `game_cfg_constellation` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Coordinate` VARCHAR(201) NULL,
  `LinePos` VARCHAR(37) NULL,
  `Ratio` BIGINT UNSIGNED NULL,
  `RewardStar` VARCHAR(32) NULL,
  `SpecialContinuousRatio` VARCHAR(42) NULL,
  `SpecialHeroRatio` VARCHAR(32) NULL,
  `SpecialSingleRatio` VARCHAR(42) NULL,
  `SpecialStarNum` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_785bdcc85647` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DrawHeroRatio
CREATE TABLE IF NOT EXISTS `game_cfg_drawheroratio` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `OpenDay` BIGINT UNSIGNED NULL,
  `OpenWeek` BIGINT UNSIGNED NULL,
  `Quality1` BIGINT UNSIGNED NULL,
  `Quality10` BIGINT UNSIGNED NULL,
  `Quality10000` BIGINT UNSIGNED NULL,
  `Quality1001` BIGINT UNSIGNED NULL,
  `Quality1002` BIGINT UNSIGNED NULL,
  `Quality1003` BIGINT UNSIGNED NULL,
  `Quality1004` BIGINT UNSIGNED NULL,
  `Quality103` BIGINT UNSIGNED NULL,
  `Quality11` BIGINT UNSIGNED NULL,
  `Quality12` BIGINT UNSIGNED NULL,
  `Quality13` BIGINT UNSIGNED NULL,
  `Quality15` BIGINT UNSIGNED NULL,
  `Quality17` BIGINT UNSIGNED NULL,
  `Quality18` BIGINT UNSIGNED NULL,
  `Quality19` BIGINT UNSIGNED NULL,
  `Quality2` BIGINT UNSIGNED NULL,
  `Quality20` BIGINT UNSIGNED NULL,
  `Quality21` BIGINT UNSIGNED NULL,
  `Quality23` BIGINT UNSIGNED NULL,
  `Quality24` BIGINT UNSIGNED NULL,
  `Quality25` BIGINT UNSIGNED NULL,
  `Quality26` BIGINT UNSIGNED NULL,
  `Quality27` BIGINT UNSIGNED NULL,
  `Quality28` BIGINT UNSIGNED NULL,
  `Quality29` BIGINT UNSIGNED NULL,
  `Quality3` BIGINT UNSIGNED NULL,
  `Quality4` BIGINT UNSIGNED NULL,
  `Quality40` BIGINT UNSIGNED NULL,
  `Quality41` BIGINT UNSIGNED NULL,
  `Quality42` BIGINT UNSIGNED NULL,
  `Quality43` BIGINT UNSIGNED NULL,
  `Quality44` BIGINT UNSIGNED NULL,
  `Quality5` BIGINT UNSIGNED NULL,
  `Quality6` BIGINT UNSIGNED NULL,
  `Quality7` BIGINT UNSIGNED NULL,
  `Quality8` BIGINT UNSIGNED NULL,
  `Quality9` BIGINT UNSIGNED NULL,
  `Quality98` BIGINT UNSIGNED NULL,
  `Quality99` BIGINT UNSIGNED NULL,
  `Ratio1` BIGINT UNSIGNED NULL,
  `Ratio10` BIGINT UNSIGNED NULL,
  `Ratio10000` BIGINT UNSIGNED NULL,
  `Ratio1001` BIGINT UNSIGNED NULL,
  `Ratio1002` BIGINT UNSIGNED NULL,
  `Ratio1003` BIGINT UNSIGNED NULL,
  `Ratio1004` BIGINT UNSIGNED NULL,
  `Ratio103` BIGINT UNSIGNED NULL,
  `Ratio11` BIGINT UNSIGNED NULL,
  `Ratio12` BIGINT UNSIGNED NULL,
  `Ratio13` BIGINT UNSIGNED NULL,
  `Ratio15` BIGINT UNSIGNED NULL,
  `Ratio17` BIGINT UNSIGNED NULL,
  `Ratio18` BIGINT UNSIGNED NULL,
  `Ratio19` BIGINT UNSIGNED NULL,
  `Ratio2` BIGINT UNSIGNED NULL,
  `Ratio20` BIGINT UNSIGNED NULL,
  `Ratio21` BIGINT UNSIGNED NULL,
  `Ratio23` BIGINT UNSIGNED NULL,
  `Ratio24` BIGINT UNSIGNED NULL,
  `Ratio25` BIGINT UNSIGNED NULL,
  `Ratio26` BIGINT UNSIGNED NULL,
  `Ratio27` BIGINT UNSIGNED NULL,
  `Ratio28` BIGINT UNSIGNED NULL,
  `Ratio29` BIGINT UNSIGNED NULL,
  `Ratio3` BIGINT UNSIGNED NULL,
  `Ratio4` BIGINT UNSIGNED NULL,
  `Ratio40` BIGINT UNSIGNED NULL,
  `Ratio41` BIGINT UNSIGNED NULL,
  `Ratio42` BIGINT UNSIGNED NULL,
  `Ratio43` BIGINT UNSIGNED NULL,
  `Ratio44` BIGINT UNSIGNED NULL,
  `Ratio5` BIGINT UNSIGNED NULL,
  `Ratio6` BIGINT UNSIGNED NULL,
  `Ratio7` BIGINT UNSIGNED NULL,
  `Ratio8` BIGINT UNSIGNED NULL,
  `Ratio9` BIGINT UNSIGNED NULL,
  `Ratio98` BIGINT UNSIGNED NULL,
  `Ratio99` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3cf33b9dc3d7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DrawHeroReward
CREATE TABLE IF NOT EXISTS `game_cfg_drawheroreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4db9bd4d495e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DrawQualityRatio
CREATE TABLE IF NOT EXISTS `game_cfg_drawqualityratio` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Announce` VARCHAR(32) NULL,
  `BlessingHeroRatio` VARCHAR(32) NULL,
  `BlessingMax` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Continuous` BIGINT UNSIGNED NULL,
  `ContinuousDiscount` BIGINT UNSIGNED NULL,
  `ContinuousFirstHeroIds` VARCHAR(71) NULL,
  `ContinuousItem` BIGINT UNSIGNED NULL,
  `ContinuousNum` BIGINT UNSIGNED NULL,
  `CostRatio` VARCHAR(32) NULL,
  `CostType` BIGINT UNSIGNED NULL,
  `FirstHeroIds` VARCHAR(92) NULL,
  `FreeRatio` VARCHAR(32) NULL,
  `ItemRatio` VARCHAR(32) NULL,
  `MaxBlessingQuality` BIGINT UNSIGNED NULL,
  `MaxQuality` BIGINT UNSIGNED NULL,
  `MaxQualityCount` BIGINT UNSIGNED NULL,
  `MinQuality` BIGINT UNSIGNED NULL,
  `MinQualityCount` BIGINT UNSIGNED NULL,
  `NoSameQuality` BIGINT UNSIGNED NULL,
  `RefreshBlessing` TEXT NULL,
  `Single` BIGINT UNSIGNED NULL,
  `SingleDiscount` BIGINT UNSIGNED NULL,
  `SingleFree` BIGINT UNSIGNED NULL,
  `SingleItem` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1c730c1b22cc` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DrawRatioChange
CREATE TABLE IF NOT EXISTS `game_cfg_drawratiochange` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BeginTime` DATETIME(6) NULL,
  `CEHUA` VARCHAR(32) NULL,
  `ChangeId` BIGINT UNSIGNED NULL,
  `EndTime` DATETIME(6) NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7aa398bb578a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DrawTime
CREATE TABLE IF NOT EXISTS `game_cfg_drawtime` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BeginTime` DATETIME(6) NULL,
  `BeginWeekTime` VARCHAR(32) NULL,
  `CEHUA` VARCHAR(32) NULL,
  `DiscountBegin` VARCHAR(32) NULL,
  `DiscountEnd` VARCHAR(32) NULL,
  `EndTime` DATETIME(6) NULL,
  `EndWeekTime` VARCHAR(32) NULL,
  `OpenServerBeginTime` BIGINT UNSIGNED NULL,
  `OpenServerEndTime` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_bff560affb11` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DriftExploreConfig
CREATE TABLE IF NOT EXISTS `game_cfg_driftexploreconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `FinishNum` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(36) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9563179ec27b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DriftExploreTask_1
CREATE TABLE IF NOT EXISTS `game_cfg_driftexploretask_1` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ClientReward` VARCHAR(36) NULL,
  `ParentId` BIGINT UNSIGNED NULL,
  `Position` VARCHAR(32) NULL,
  `Reward` VARCHAR(36) NULL,
  `TaskName` VARCHAR(32) NULL,
  `TaskParam` VARCHAR(40) NULL,
  `TaskType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_91abac86e0fa` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DriftExploreTask_2
CREATE TABLE IF NOT EXISTS `game_cfg_driftexploretask_2` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ClientReward` VARCHAR(36) NULL,
  `ParentId` BIGINT UNSIGNED NULL,
  `Position` VARCHAR(32) NULL,
  `Reward` VARCHAR(36) NULL,
  `TaskName` VARCHAR(32) NULL,
  `TaskParam` VARCHAR(40) NULL,
  `TaskType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_df28a9af882e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DriftExploreTask_3
CREATE TABLE IF NOT EXISTS `game_cfg_driftexploretask_3` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ClientReward` VARCHAR(36) NULL,
  `ParentId` BIGINT UNSIGNED NULL,
  `Position` VARCHAR(32) NULL,
  `Reward` VARCHAR(36) NULL,
  `TaskName` VARCHAR(32) NULL,
  `TaskParam` VARCHAR(40) NULL,
  `TaskType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d68a169db14e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DriftExploreTask_4
CREATE TABLE IF NOT EXISTS `game_cfg_driftexploretask_4` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ClientReward` VARCHAR(36) NULL,
  `ParentId` BIGINT UNSIGNED NULL,
  `Position` VARCHAR(32) NULL,
  `Reward` VARCHAR(36) NULL,
  `TaskName` VARCHAR(32) NULL,
  `TaskParam` VARCHAR(40) NULL,
  `TaskType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c8e37bc0cc29` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RewardDrop
CREATE TABLE IF NOT EXISTS `game_cfg_rewarddrop` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `ClientShow` TEXT NULL,
  `DropItem` TEXT NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e9a7b873173b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TimeLimitRewardDrop
CREATE TABLE IF NOT EXISTS `game_cfg_timelimitrewarddrop` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `DropItem` VARCHAR(55) NULL,
  `End` VARCHAR(32) NULL,
  `Start` VARCHAR(32) NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6cc023151aa4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Email
CREATE TABLE IF NOT EXISTS `game_cfg_email` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Content` TEXT NULL,
  `EndText` VARCHAR(141) NULL,
  `Group` BIGINT UNSIGNED NULL,
  `isDelete` VARCHAR(32) NULL,
  `isTop` BOOLEAN NULL,
  `Reward` VARCHAR(103) NULL,
  `Title` VARCHAR(131) NULL,
  `Type` BIGINT UNSIGNED NULL,
  `ValidityDate` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_84add5b29527` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: EmailConfig
CREATE TABLE IF NOT EXISTS `game_cfg_emailconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ContributionEmail` BIGINT UNSIGNED NULL,
  `DeleteOverTime` BIGINT UNSIGNED NULL,
  `FireworkLuckyEmail` BIGINT UNSIGNED NULL,
  `GiftCodeRewardEmail` BIGINT UNSIGNED NULL,
  `HeroAppraiseEmail` BIGINT UNSIGNED NULL,
  `ItemGameLevelEmail` BIGINT UNSIGNED NULL,
  `ItemOverTimeEmail` BIGINT UNSIGNED NULL,
  `OnekeyCount` BIGINT UNSIGNED NULL,
  `OnePieceBattleEmail` BIGINT UNSIGNED NULL,
  `ShopGoldEmail` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_bcd2c60e91c7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: EmailLevel
CREATE TABLE IF NOT EXISTS `game_cfg_emaillevel` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`config_row_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: EmailTaskGroup
CREATE TABLE IF NOT EXISTS `game_cfg_emailtaskgroup` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Group` VARCHAR(47) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d526552f5b8a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: EquipAdvance
CREATE TABLE IF NOT EXISTS `game_cfg_equipadvance` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CostEquipId` BIGINT UNSIGNED NULL,
  `Material` VARCHAR(32) NULL,
  `Num` BIGINT UNSIGNED NULL,
  `OneKeyAdvance` BOOLEAN NULL,
  `OneKeyAdvanceCostNum` BIGINT UNSIGNED NULL,
  `Price` VARCHAR(32) NULL,
  `Product` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_edcac4e3338c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: EquipInjection
CREATE TABLE IF NOT EXISTS `game_cfg_equipinjection` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` TEXT NULL,
  `InjectSlot` BIGINT UNSIGNED NULL,
  `LevelLimit` BIGINT UNSIGNED NULL,
  `Nature` BIGINT UNSIGNED NULL,
  `NatureValue` BIGINT UNSIGNED NULL,
  `Part` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_66615eaa19cf` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: EquipInjectionLimit
CREATE TABLE IF NOT EXISTS `game_cfg_equipinjectionlimit` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  `PRO_ARM` BIGINT UNSIGNED NULL,
  `PRO_ATK` BIGINT UNSIGNED NULL,
  `PRO_CRI` BIGINT UNSIGNED NULL,
  `PRO_DEF` BIGINT UNSIGNED NULL,
  `PRO_FLEE` BIGINT UNSIGNED NULL,
  `PRO_HIT` BIGINT UNSIGNED NULL,
  `PRO_IMP` BIGINT UNSIGNED NULL,
  `PRO_MAX_HP` BIGINT UNSIGNED NULL,
  `PRO_RES` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1649adfdbbb9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: EquipLevelReward
CREATE TABLE IF NOT EXISTS `game_cfg_equiplevelreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4096dbc93e2d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Equipment
CREATE TABLE IF NOT EXISTS `game_cfg_equipment` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Color` BIGINT UNSIGNED NULL,
  `Grade` BIGINT UNSIGNED NULL,
  `Icon` VARCHAR(32) NULL,
  `IsEnchant` BOOLEAN NULL,
  `ItemEffName` VARCHAR(33) NULL,
  `Job` BIGINT UNSIGNED NULL,
  `LevelLimit` BIGINT UNSIGNED NULL,
  `MainType` BIGINT UNSIGNED NULL,
  `Order` BIGINT UNSIGNED NULL,
  `Part` BIGINT UNSIGNED NULL,
  `PRO_ARM` BIGINT UNSIGNED NULL,
  `PRO_ATK` BIGINT UNSIGNED NULL,
  `PRO_CRI` BIGINT UNSIGNED NULL,
  `PRO_DEF` BIGINT UNSIGNED NULL,
  `PRO_FLEE` BIGINT UNSIGNED NULL,
  `PRO_HIT` BIGINT UNSIGNED NULL,
  `PRO_IMP` BIGINT UNSIGNED NULL,
  `PRO_MAX_HP` BIGINT UNSIGNED NULL,
  `PRO_RES` BIGINT UNSIGNED NULL,
  `Score` BIGINT UNSIGNED NULL,
  `SellingPrice` VARCHAR(32) NULL,
  `Star` BIGINT UNSIGNED NULL,
  `SubType` BIGINT UNSIGNED NULL,
  `Suit` BIGINT UNSIGNED NULL,
  `UpgradeLimit` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_36155d48f460` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: EquipmentEnchantItem
CREATE TABLE IF NOT EXISTS `game_cfg_equipmentenchantitem` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Icon` VARCHAR(32) NULL,
  `JobType` BIGINT UNSIGNED NULL,
  `Part` VARCHAR(32) NULL,
  `SuitWeight` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_bbc55b16bfd7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: EquipmentSpec
CREATE TABLE IF NOT EXISTS `game_cfg_equipmentspec` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattlePower` BIGINT UNSIGNED NULL,
  `Cehua` VARCHAR(42) NULL,
  `Param_1` BIGINT UNSIGNED NULL,
  `Param_2` BIGINT UNSIGNED NULL,
  `SpecType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_081f4a6d7e04` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: EquipmentSuit
CREATE TABLE IF NOT EXISTS `game_cfg_equipmentsuit` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Icon` VARCHAR(32) NULL,
  `SpecialEffect2` BIGINT UNSIGNED NULL,
  `SpecialEffect4` BIGINT UNSIGNED NULL,
  `Suit` VARCHAR(39) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d0d49e79a705` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: EquipUpgrade
CREATE TABLE IF NOT EXISTS `game_cfg_equipupgrade` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BaseRate` BIGINT UNSIGNED NULL,
  `CostGold` BIGINT UNSIGNED NULL,
  `DestroyLimit` BIGINT UNSIGNED NULL,
  `LSCount` VARCHAR(32) NULL,
  `MaterialCnt` BIGINT UNSIGNED NULL,
  `MaterialCount` VARCHAR(32) NULL,
  `RollBackLevel` BIGINT UNSIGNED NULL,
  `SlotCount` BIGINT UNSIGNED NULL,
  `StrengthRatio` BIGINT UNSIGNED NULL,
  `UpgradeLevel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_fa7f7c02759a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ItemXuanyu
CREATE TABLE IF NOT EXISTS `game_cfg_itemxuanyu` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Level` BIGINT UNSIGNED NULL,
  `Percent` BIGINT UNSIGNED NULL,
  `PRO_ARM` BIGINT UNSIGNED NULL,
  `PRO_ATK` BIGINT UNSIGNED NULL,
  `PRO_CRI` BIGINT UNSIGNED NULL,
  `PRO_DEF` BIGINT UNSIGNED NULL,
  `PRO_FLEE` BIGINT UNSIGNED NULL,
  `PRO_HIT` BIGINT UNSIGNED NULL,
  `PRO_IMP` BIGINT UNSIGNED NULL,
  `PRO_MAX_HP` BIGINT UNSIGNED NULL,
  `PRO_RES` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4821e350e113` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: XuanyuAdvance
CREATE TABLE IF NOT EXISTS `game_cfg_xuanyuadvance` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CostItem` VARCHAR(32) NULL,
  `ProduceWeight` VARCHAR(46) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e93449dd31e6` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: XuanyuWeightBySecret
CREATE TABLE IF NOT EXISTS `game_cfg_xuanyuweightbysecret` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DropType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `SecretMax` BIGINT UNSIGNED NULL,
  `SecretMin` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_880891232b1c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: FlipCards
CREATE TABLE IF NOT EXISTS `game_cfg_flipcards` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddRatio` VARCHAR(32) NULL,
  `Announce` VARCHAR(32) NULL,
  `BuyMaxCount` BIGINT UNSIGNED NULL,
  `CardIds` VARCHAR(82) NULL,
  `CEHUA` VARCHAR(32) NULL,
  `ClientShow` VARCHAR(93) NULL,
  `ConfigType` BIGINT UNSIGNED NULL,
  `CostDiamond` BIGINT UNSIGNED NULL,
  `CostItem` BIGINT UNSIGNED NULL,
  `CostItemCount` VARCHAR(45) NULL,
  `Cumulative` VARCHAR(81) NULL,
  `FirstEmail` BIGINT UNSIGNED NULL,
  `FirstReward` VARCHAR(32) NULL,
  `luckilyEmail` BIGINT UNSIGNED NULL,
  `luckilyReward` VARCHAR(32) NULL,
  `MaxValue` BIGINT UNSIGNED NULL,
  `Notes` VARCHAR(32) NULL,
  `NotesId` BIGINT UNSIGNED NULL,
  `NotesTime` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(117) NULL,
  `RewardStar` VARCHAR(32) NULL,
  `ShowCurrency` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_adcd07f6f630` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: FlipCardsFettersReward
CREATE TABLE IF NOT EXISTS `game_cfg_flipcardsfettersreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Atlas` VARCHAR(32) NULL,
  `CEHUA` VARCHAR(32) NULL,
  `FettersId` BIGINT UNSIGNED NULL,
  `FettersReward` VARCHAR(32) NULL,
  `Icon` VARCHAR(47) NULL,
  `Reward` VARCHAR(32) NULL,
  `TexPath` VARCHAR(48) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c13d6d2b7b91` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: FlipCardsReward
CREATE TABLE IF NOT EXISTS `game_cfg_flipcardsreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CardId` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Parem` VARCHAR(32) NULL,
  `RewardId` BIGINT UNSIGNED NULL,
  `ShowReward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a066a268246d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: FriendConfig
CREATE TABLE IF NOT EXISTS `game_cfg_friendconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddFriendRefreshInterval` BIGINT UNSIGNED NULL,
  `BattleWaitTime` BIGINT UNSIGNED NULL,
  `BlackListMaxCnt` BIGINT UNSIGNED NULL,
  `FriendInviterListMaxCnt` BIGINT UNSIGNED NULL,
  `FriendListMaxCnt` BIGINT UNSIGNED NULL,
  `FriendListUpdateTime` BIGINT UNSIGNED NULL,
  `FriendRequestListMaxCnt` BIGINT UNSIGNED NULL,
  `InviteShowTime` BIGINT UNSIGNED NULL,
  `Name` BIGINT UNSIGNED NULL,
  `PickFriendScore` BIGINT UNSIGNED NULL,
  `PickListMaxCnt` BIGINT UNSIGNED NULL,
  `RecentListMaxCnt` BIGINT UNSIGNED NULL,
  `RecommendCount` BIGINT UNSIGNED NULL,
  `RecommendLevelMax` BIGINT UNSIGNED NULL,
  `RecommendLevelMin` BIGINT UNSIGNED NULL,
  `RequsetDefault` TEXT NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4dfe42302b45` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: FriendGift
CREATE TABLE IF NOT EXISTS `game_cfg_friendgift` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Score` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_07d936ac7213` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: FriendlyHeart
CREATE TABLE IF NOT EXISTS `game_cfg_friendlyheart` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `GiveHeartCntBuy` VARCHAR(32) NULL,
  `GiveHeartIntervalGrowthCnt` BIGINT UNSIGNED NULL,
  `GiveHeartIntervalGrowthTime` BIGINT UNSIGNED NULL,
  `GiveHeartMaxCnt` BIGINT UNSIGNED NULL,
  `GiveHeartTimingGrowthCnt` BIGINT UNSIGNED NULL,
  `GiveHeartTimingGrowthTime` TIME NULL,
  `Name` BIGINT UNSIGNED NULL,
  `TakeHeartCntBuy` VARCHAR(32) NULL,
  `TakeHeartIntervalGrowthCnt` BIGINT UNSIGNED NULL,
  `TakeHeartIntervalGrowthTime` BIGINT UNSIGNED NULL,
  `TakeHeartMaxCnt` BIGINT UNSIGNED NULL,
  `TakeHeartPersonSystemMsgId` BIGINT UNSIGNED NULL,
  `TakeHeartTimingGrowthCnt` BIGINT UNSIGNED NULL,
  `TakeHeartTimingGrowthTime` TIME NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d6889cb16a4b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GardenConfig
CREATE TABLE IF NOT EXISTS `game_cfg_gardenconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `HarverstFactor` DECIMAL(4,3) NULL,
  `PitCount` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a7aec3a479d0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GardenRankReward
CREATE TABLE IF NOT EXISTS `game_cfg_gardenrankreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Rank` VARCHAR(32) NULL,
  `Rewards` VARCHAR(36) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_caea5dcfc05b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GardenScoreReward
CREATE TABLE IF NOT EXISTS `game_cfg_gardenscorereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `Score` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6df988080e72` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GardenSeed
CREATE TABLE IF NOT EXISTS `game_cfg_gardenseed` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Diamond` BIGINT UNSIGNED NULL,
  `HarvestTime` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(35) NULL,
  `Score` BIGINT UNSIGNED NULL,
  `SeedId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_192f9de98c52` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GardenShop
CREATE TABLE IF NOT EXISTS `game_cfg_gardenshop` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Cost` VARCHAR(37) NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1172db5bc168` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CommonGiftCode
CREATE TABLE IF NOT EXISTS `game_cfg_commongiftcode` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BeginTime` VARCHAR(32) NULL,
  `Channel` BIGINT UNSIGNED NULL,
  `Code` VARCHAR(32) NULL,
  `Description` BIGINT UNSIGNED NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `EndTime` VARCHAR(32) NULL,
  `MaxUseCount` BIGINT UNSIGNED NULL,
  `Mode` BIGINT UNSIGNED NULL,
  `Rewards` VARCHAR(36) NULL,
  `SubType` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6d3c9eaa098a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GiftCodeInfo
CREATE TABLE IF NOT EXISTS `game_cfg_giftcodeinfo` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BeginTime` VARCHAR(32) NULL,
  `Channel` BIGINT UNSIGNED NULL,
  `CodeTop4` BIGINT UNSIGNED NULL,
  `Description` BIGINT UNSIGNED NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `EndTime` VARCHAR(32) NULL,
  `IsUniversal` BIGINT UNSIGNED NULL,
  `Mode` BIGINT UNSIGNED NULL,
  `Rewards` VARCHAR(47) NULL,
  `SubType` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_edee8d764c3e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GodPathAcrossOcean
CREATE TABLE IF NOT EXISTS `game_cfg_godpathacrossocean` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Extra` BIGINT UNSIGNED NULL,
  `HeroId` BIGINT UNSIGNED NULL,
  `Index` BIGINT UNSIGNED NULL,
  `Picture` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b9930e7eb144` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GodPathConfig
CREATE TABLE IF NOT EXISTS `game_cfg_godpathconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AcrossOceanDungeonId` VARCHAR(43) NULL,
  `AcrossOceanItemId` BIGINT UNSIGNED NULL,
  `AcrossOceanPuzzleCost` BIGINT UNSIGNED NULL,
  `AcrossOceanPuzzleCount` BIGINT UNSIGNED NULL,
  `AddAffinityItemId` VARCHAR(32) NULL,
  `Affinity` VARCHAR(43) NULL,
  `CardPrice` BIGINT UNSIGNED NULL,
  `DrugBigAddAffinity` BIGINT UNSIGNED NULL,
  `DrugNormalAddAffinity` BIGINT UNSIGNED NULL,
  `DrugSmallAddAffinity` BIGINT UNSIGNED NULL,
  `HeartBuyCountPrice` VARCHAR(32) NULL,
  `HeartMaxBuyCount` BIGINT UNSIGNED NULL,
  `HeartMaxValue` BIGINT UNSIGNED NULL,
  `HeartRewardDouble` BIGINT UNSIGNED NULL,
  `HeartRewardDoubleNum` BIGINT UNSIGNED NULL,
  `HeartRewardTreble` BIGINT UNSIGNED NULL,
  `HeartRewardTrebleNum` BIGINT UNSIGNED NULL,
  `HeartUseCount` BIGINT UNSIGNED NULL,
  `HeroOpenLevel` BIGINT UNSIGNED NULL,
  `SevenFightBuyPowerPrice` VARCHAR(32) NULL,
  `SevenFightCostPower` BIGINT UNSIGNED NULL,
  `SevenFightGivePower` BIGINT UNSIGNED NULL,
  `SevenFightMaxStage` BIGINT UNSIGNED NULL,
  `SevenFightNextStagePower` BIGINT UNSIGNED NULL,
  `SevenFightPower` BIGINT UNSIGNED NULL,
  `SevenFightWinCountToNextStage` BIGINT UNSIGNED NULL,
  `TrainBodyAddShield` BIGINT UNSIGNED NULL,
  `TrainBodyBasicShield` BIGINT UNSIGNED NULL,
  `TrainBodyBuyCost` BIGINT UNSIGNED NULL,
  `TrainBodyHP` BIGINT UNSIGNED NULL,
  `TrainBodyWaterPower` VARCHAR(38) NULL,
  `TridentBuyCountPrice` VARCHAR(32) NULL,
  `TridentCheckTime` BIGINT UNSIGNED NULL,
  `TridentFailAdd` BIGINT UNSIGNED NULL,
  `TridentGreatAdd` BIGINT UNSIGNED NULL,
  `TridentMaxBuyCount` BIGINT UNSIGNED NULL,
  `TridentMaxValue` BIGINT UNSIGNED NULL,
  `TridentPullRatioAdd` BIGINT UNSIGNED NULL,
  `TridentPullRatioOffset` BIGINT UNSIGNED NULL,
  `TridentPullRatioSub` BIGINT UNSIGNED NULL,
  `TridentRandomPrice` BIGINT UNSIGNED NULL,
  `TridentRandomPro` VARCHAR(32) NULL,
  `TridentRandomType` BIGINT UNSIGNED NULL,
  `TridentStrategyPrice` BIGINT UNSIGNED NULL,
  `TridentStrategyType` BIGINT UNSIGNED NULL,
  `TridentSuccessAdd` BIGINT UNSIGNED NULL,
  `TridentTime` BIGINT UNSIGNED NULL,
  `TridentUseCount` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_8fe60a88ae87` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GodPathHeartRepaint
CREATE TABLE IF NOT EXISTS `game_cfg_godpathheartrepaint` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` TEXT NULL,
  `Interval` BIGINT UNSIGNED NULL,
  `Rewards` VARCHAR(38) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3b919f759b48` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GodPathHeartReward
CREATE TABLE IF NOT EXISTS `game_cfg_godpathheartreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Atlas` VARCHAR(32) NULL,
  `CEHUA` TEXT NULL,
  `Icon` VARCHAR(32) NULL,
  `Value` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f07635a91f3d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GodPathHeroShield
CREATE TABLE IF NOT EXISTS `game_cfg_godpathheroshield` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `HeroId` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  `Shield` BIGINT UNSIGNED NULL,
  `StepsLevel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_acb195c0282a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GodPathSevenFightCard
CREATE TABLE IF NOT EXISTS `game_cfg_godpathsevenfightcard` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Card` VARCHAR(32) NULL,
  `Fight` BIGINT UNSIGNED NULL,
  `HeroId` BIGINT UNSIGNED NULL,
  `IsReward` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `Stage` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_438957fb6cd7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GodPathTask
CREATE TABLE IF NOT EXISTS `game_cfg_godpathtask` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  `HeroId` BIGINT UNSIGNED NULL,
  `HungingCount` BIGINT UNSIGNED NULL,
  `HungingDiffcute` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  `Position` BIGINT UNSIGNED NULL,
  `SecretAreaTireCount` BIGINT UNSIGNED NULL,
  `SoulRingMaxLevelCount` BIGINT UNSIGNED NULL,
  `Stage` BIGINT UNSIGNED NULL,
  `SuperSoulRingCount` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_938c12694507` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GodPathTrainBody
CREATE TABLE IF NOT EXISTS `game_cfg_godpathtrainbody` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Fight` BIGINT UNSIGNED NULL,
  `HeroId` BIGINT UNSIGNED NULL,
  `ShieldHero` VARCHAR(32) NULL,
  `Stage` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ce21e4b20f78` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GuildConfig
CREATE TABLE IF NOT EXISTS `game_cfg_guildconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CreateGuildCost` BIGINT UNSIGNED NULL,
  `name` BIGINT UNSIGNED NULL,
  `NameLenLimit` BIGINT UNSIGNED NULL,
  `SignatureDeafault` VARCHAR(32) NULL,
  `SignatureLenLimit` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b95e623138d9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroCard
CREATE TABLE IF NOT EXISTS `game_cfg_herocard` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AttackRange` DECIMAL(2,1) NULL,
  `BattleModelId` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `CollisionPriority` BIGINT UNSIGNED NULL,
  `DeadDelay` BIGINT UNSIGNED NULL,
  `FollowDistance` BIGINT UNSIGNED NULL,
  `FormationPosType` BIGINT UNSIGNED NULL,
  `HateRange` BIGINT UNSIGNED NULL,
  `HateRatio` BIGINT UNSIGNED NULL,
  `HateRefreshTime` DECIMAL(2,1) NULL,
  `HeroFragment` BIGINT UNSIGNED NULL,
  `HeroGodFragment` BIGINT UNSIGNED NULL,
  `InitAwakenLevel` BIGINT UNSIGNED NULL,
  `InitLevel` BIGINT UNSIGNED NULL,
  `IsPlayer` BIGINT UNSIGNED NULL,
  `ItemEffName` VARCHAR(32) NULL,
  `Job` BIGINT UNSIGNED NULL,
  `ModelId` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `Order` BIGINT UNSIGNED NULL,
  `PRO_RUN_IN_BATTLE` BIGINT UNSIGNED NULL,
  `PRO_RUN_OUT_BATTLE` BIGINT UNSIGNED NULL,
  `Quality` BIGINT UNSIGNED NULL,
  `Radius` BIGINT UNSIGNED NULL,
  `ResolveNum` BIGINT UNSIGNED NULL,
  `Skills` VARCHAR(103) NULL,
  `SoulRingSlot` BIGINT UNSIGNED NULL,
  `StepBattlePowerFactor` VARCHAR(111) NULL,
  `StepSpecial` VARCHAR(61) NULL,
  `TransmitDistance` BIGINT UNSIGNED NULL,
  `Triggers` VARCHAR(96) NULL,
  `UpSteps` VARCHAR(137) NULL,
  `WalkRange` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_59c7ca8f31b4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroCombo
CREATE TABLE IF NOT EXISTS `game_cfg_herocombo` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Group` BIGINT UNSIGNED NULL,
  `Member` VARCHAR(32) NULL,
  `NatureRatio` VARCHAR(32) NULL,
  `Next` BIGINT UNSIGNED NULL,
  `Steps` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6a229aa35b91` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroConfig
CREATE TABLE IF NOT EXISTS `game_cfg_heroconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattleQueueNameLength` BIGINT UNSIGNED NULL,
  `ExpToSoulPower` BIGINT UNSIGNED NULL,
  `HeroCollisionRadius` DECIMAL(2,1) NULL,
  `HeroEquipMax` BIGINT UNSIGNED NULL,
  `HeroGodFragmentNum` BIGINT UNSIGNED NULL,
  `HeroGodStepMax` BIGINT UNSIGNED NULL,
  `HeroGodStepUpCostItemId` BIGINT UNSIGNED NULL,
  `HeroGodTipsLv` BIGINT UNSIGNED NULL,
  `HeroInheritCostItem` VARCHAR(32) NULL,
  `HeroPosCollision` VARCHAR(45) NULL,
  `HeroPosCount` BIGINT UNSIGNED NULL,
  `HeroStepMax` BIGINT UNSIGNED NULL,
  `ResetTalentDiamond` BIGINT UNSIGNED NULL,
  `ResetTalentItem` BIGINT UNSIGNED NULL,
  `RevertHeroCurrenciesNum` BIGINT UNSIGNED NULL,
  `RevertHeroCurrenciesType` BIGINT UNSIGNED NULL,
  `SSRHeroQuality` BIGINT UNSIGNED NULL,
  `TalentMaxNum` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_264297498173` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroJob
CREATE TABLE IF NOT EXISTS `game_cfg_herojob` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Sex1FaceIcon` BIGINT UNSIGNED NULL,
  `Sex1HeroId` BIGINT UNSIGNED NULL,
  `Sex2FaceIcon` BIGINT UNSIGNED NULL,
  `Sex2HeroId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_be627bea0884` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroLevel
CREATE TABLE IF NOT EXISTS `game_cfg_herolevel` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Exp` BIGINT UNSIGNED NULL,
  `SoulCrystal` BIGINT UNSIGNED NULL,
  `SoulPower` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d43a07175b5c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroMainQueue
CREATE TABLE IF NOT EXISTS `game_cfg_heromainqueue` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CostDiamond` BIGINT UNSIGNED NULL,
  `DefaultName` VARCHAR(32) NULL,
  `LevelLimit` BIGINT UNSIGNED NULL,
  `LevelUnlock` BOOLEAN NULL,
  `UnlockAhead` BOOLEAN NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c167fff00ee1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroPos
CREATE TABLE IF NOT EXISTS `game_cfg_heropos` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Pos` BIGINT UNSIGNED NULL,
  `PosX` BIGINT NULL,
  `PosY` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_cebf2bdaca48` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroQuality
CREATE TABLE IF NOT EXISTS `game_cfg_heroquality` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `MaxLevel` BIGINT UNSIGNED NULL,
  `ReturnSoulCrystal` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e7844e5b2cc0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroStepSpecial
CREATE TABLE IF NOT EXISTS `game_cfg_herostepspecial` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Param_1` BIGINT UNSIGNED NULL,
  `Param_2` VARCHAR(32) NULL,
  `SpecType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_88db3174c235` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroTitle
CREATE TABLE IF NOT EXISTS `game_cfg_herotitle` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Nature` TEXT NULL,
  `Talent` BIGINT UNSIGNED NULL,
  `title` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b56f7d554941` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroGod
CREATE TABLE IF NOT EXISTS `game_cfg_herogod` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `GodType` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f116a75c4f82` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroGodDetail
CREATE TABLE IF NOT EXISTS `game_cfg_herogoddetail` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT NULL,
  `CEHUA` VARCHAR(32) NULL,
  `CostItem` VARCHAR(32) NULL,
  `GodLimit` BIGINT UNSIGNED NULL,
  `IsPrimaryGod` BIGINT UNSIGNED NULL,
  `LevelLimit` BIGINT UNSIGNED NULL,
  `OpenHeroGodTime` DATETIME(6) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ec4e71a3dae3` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroGodStepUp
CREATE TABLE IF NOT EXISTS `game_cfg_herogodstepup` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `GodLimit` BIGINT UNSIGNED NULL,
  `ItemCost` VARCHAR(150) NULL,
  `ShipCost` VARCHAR(180) NULL,
  `ShipId` BIGINT UNSIGNED NULL,
  `StepsLimit` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4ed1b3bc524c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroGodStepUpGrowth
CREATE TABLE IF NOT EXISTS `game_cfg_herogodstepupgrowth` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattlePowerFixValue` BIGINT UNSIGNED NULL,
  `BattlePowerRatio` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `GodType` BIGINT UNSIGNED NULL,
  `NatureRatio` BIGINT UNSIGNED NULL,
  `Step` BIGINT UNSIGNED NULL,
  `Trigger` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_0b5c8d166bc7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HiddenWeapon
CREATE TABLE IF NOT EXISTS `game_cfg_hiddenweapon` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Atlas` VARCHAR(32) NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Color` BIGINT UNSIGNED NULL,
  `Grade` BIGINT UNSIGNED NULL,
  `Icon` VARCHAR(32) NULL,
  `ItemEffName` VARCHAR(32) NULL,
  `MainType` BIGINT UNSIGNED NULL,
  `MaxLevelType` BIGINT UNSIGNED NULL,
  `Order` BIGINT UNSIGNED NULL,
  `Part` BIGINT UNSIGNED NULL,
  `PRO_AGI` BIGINT UNSIGNED NULL,
  `PRO_CON` BIGINT UNSIGNED NULL,
  `PRO_EXP` BIGINT UNSIGNED NULL,
  `PRO_POW` BIGINT UNSIGNED NULL,
  `Score` BIGINT UNSIGNED NULL,
  `SellingPrice` VARCHAR(32) NULL,
  `SmashReward` VARCHAR(32) NULL,
  `SpecList` VARCHAR(32) NULL,
  `StarCostItem` BIGINT UNSIGNED NULL,
  `UpgradeLimit` BIGINT UNSIGNED NULL,
  `UpgradePool` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6cf0a4d65703` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HiddenWeaponConfig
CREATE TABLE IF NOT EXISTS `game_cfg_hiddenweaponconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `HighGrade` BIGINT UNSIGNED NULL,
  `LockCost` VARCHAR(32) NULL,
  `LockCost10` VARCHAR(32) NULL,
  `ResolveItem` BIGINT UNSIGNED NULL,
  `StarWashNum` VARCHAR(32) NULL,
  `UpgradeMaxLevel` BIGINT UNSIGNED NULL,
  `WashCost` VARCHAR(32) NULL,
  `WashCost10` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b608717f75c3` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HiddenWeaponSpec
CREATE TABLE IF NOT EXISTS `game_cfg_hiddenweaponspec` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattlePower` BIGINT UNSIGNED NULL,
  `cehua` VARCHAR(67) NULL,
  `Param_1` BIGINT UNSIGNED NULL,
  `Param_2` BIGINT UNSIGNED NULL,
  `SpecType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_cd9201826519` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HiddenWeaponStar
CREATE TABLE IF NOT EXISTS `game_cfg_hiddenweaponstar` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattlePower` BIGINT UNSIGNED NULL,
  `NewSpec` BOOLEAN NULL,
  `PoolWeight` VARCHAR(32) NULL,
  `Quality` BIGINT UNSIGNED NULL,
  `SmashReward` BIGINT UNSIGNED NULL,
  `Star` BIGINT UNSIGNED NULL,
  `StarCostCount` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f55f1f2e2d83` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HiddenWeaponUpgrade
CREATE TABLE IF NOT EXISTS `game_cfg_hiddenweaponupgrade` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CostGold` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  `NeedStar` BOOLEAN NULL,
  `Pool` BIGINT UNSIGNED NULL,
  `PRO_AGI` BIGINT UNSIGNED NULL,
  `PRO_CON` BIGINT UNSIGNED NULL,
  `PRO_EXP` BIGINT UNSIGNED NULL,
  `PRO_POW` BIGINT UNSIGNED NULL,
  `ReturnGold` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_abdae2b4f66c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HiddenWeaponWashPool
CREATE TABLE IF NOT EXISTS `game_cfg_hiddenweaponwashpool` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattlePower` BIGINT UNSIGNED NULL,
  `Color` BIGINT UNSIGNED NULL,
  `MaxValue` BIGINT UNSIGNED NULL,
  `MinValue` BIGINT UNSIGNED NULL,
  `NatureType` BIGINT UNSIGNED NULL,
  `NatureValue` BIGINT UNSIGNED NULL,
  `Pool` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5216c88b9836` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HidderWeapon
CREATE TABLE IF NOT EXISTS `game_cfg_hidderweapon` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddRatio` VARCHAR(32) NULL,
  `Announce` VARCHAR(32) NULL,
  `BuyMaxCount` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `ClientShow` VARCHAR(110) NULL,
  `ConsecutiveCount` BIGINT UNSIGNED NULL,
  `CostDiamond` BIGINT UNSIGNED NULL,
  `CostItem` BIGINT UNSIGNED NULL,
  `FirstEmail` BIGINT UNSIGNED NULL,
  `FirstReward` VARCHAR(32) NULL,
  `GiftType` BIGINT UNSIGNED NULL,
  `luckilyEmail` BIGINT UNSIGNED NULL,
  `luckilyReward` VARCHAR(32) NULL,
  `MaxValue` BIGINT UNSIGNED NULL,
  `Notes` VARCHAR(32) NULL,
  `NotesId` BIGINT UNSIGNED NULL,
  `NotesTime` BIGINT UNSIGNED NULL,
  `NumReward` VARCHAR(90) NULL,
  `RewardStar` VARCHAR(32) NULL,
  `RingReward10` VARCHAR(105) NULL,
  `RingReward2` VARCHAR(32) NULL,
  `RingReward4` VARCHAR(32) NULL,
  `RingReward6` VARCHAR(32) NULL,
  `RingReward8` VARCHAR(32) NULL,
  `ShowCurrency` VARCHAR(32) NULL,
  `sliderTime` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_625574d50561` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HidderWeaponReward
CREATE TABLE IF NOT EXISTS `game_cfg_hidderweaponreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Parem` VARCHAR(32) NULL,
  `ShowReward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a36e7239d4ff` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SeaTreasure
CREATE TABLE IF NOT EXISTS `game_cfg_seatreasure` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddValue` BIGINT UNSIGNED NULL,
  `Announce` VARCHAR(32) NULL,
  `BuyMaxCount` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `ClientShow` VARCHAR(203) NULL,
  `ConsecutiveCount` BIGINT UNSIGNED NULL,
  `CostCount` TEXT NULL,
  `CostDiamond` BIGINT UNSIGNED NULL,
  `CostItem` BIGINT UNSIGNED NULL,
  `FirstEmail` BIGINT UNSIGNED NULL,
  `FirstReward` VARCHAR(32) NULL,
  `GiftType` BIGINT UNSIGNED NULL,
  `luckilyEmail` BIGINT UNSIGNED NULL,
  `luckilyReward` VARCHAR(32) NULL,
  `MaxValue` BIGINT UNSIGNED NULL,
  `Notes` VARCHAR(32) NULL,
  `NotesID` BIGINT UNSIGNED NULL,
  `NotesTime` BIGINT UNSIGNED NULL,
  `NumReward` VARCHAR(63) NULL,
  `RewardStar` VARCHAR(32) NULL,
  `RingReward` VARCHAR(145) NULL,
  `ShowCurrency` VARCHAR(32) NULL,
  `sliderTime` BIGINT UNSIGNED NULL,
  `SubRewardCount` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_52585ca78764` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SeaTreasureReward
CREATE TABLE IF NOT EXISTS `game_cfg_seatreasurereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Index` BIGINT UNSIGNED NULL,
  `Parem` VARCHAR(32) NULL,
  `ShowReward` VARCHAR(32) NULL,
  `SubReward` VARCHAR(96) NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_388cc8e3e3da` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HttpVMall
CREATE TABLE IF NOT EXISTS `game_cfg_httpvmall` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `key` VARCHAR(41) NULL,
  `timeout` BIGINT UNSIGNED NULL,
  `version` DECIMAL(2,1) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_33811bab52e5` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Hunting
CREATE TABLE IF NOT EXISTS `game_cfg_hunting` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattlePowerPercent` DECIMAL(2,1) NULL,
  `Discount` DECIMAL(2,1) NULL,
  `HuntingBuffStartTime` DATETIME(6) NULL,
  `HuntingIntrudeExistHour` BIGINT UNSIGNED NULL,
  `HuntingIntrudeNum` BIGINT UNSIGNED NULL,
  `HuntingIntrudeProbability` BIGINT UNSIGNED NULL,
  `HuntingIntrudeResearchLimit` BIGINT UNSIGNED NULL,
  `OfflineBrotherEmailId` BIGINT UNSIGNED NULL,
  `OfflineHelpEmailId` BIGINT UNSIGNED NULL,
  `OfflineHelpReward` VARCHAR(32) NULL,
  `PeriodBuffResearchLimit` BIGINT UNSIGNED NULL,
  `Research` BIGINT UNSIGNED NULL,
  `ResearchDevil` BIGINT UNSIGNED NULL,
  `ResearchEasy` BIGINT UNSIGNED NULL,
  `ResearchHard` BIGINT UNSIGNED NULL,
  `SweepItem` BIGINT UNSIGNED NULL,
  `UnlockSweepItem` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_52f5d9fedd47` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HuntingActivity
CREATE TABLE IF NOT EXISTS `game_cfg_huntingactivity` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `OpenTime` DATETIME(6) NULL,
  `Single` BIGINT UNSIGNED NULL,
  `Sort` BIGINT UNSIGNED NULL,
  `Team` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e66466d04081` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HuntingActivityUnlockCost
CREATE TABLE IF NOT EXISTS `game_cfg_huntingactivityunlockcost` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `UnlockCostItem` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1033786967ae` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HuntingBase
CREATE TABLE IF NOT EXISTS `game_cfg_huntingbase` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Devil` BIGINT UNSIGNED NULL,
  `Easy` BIGINT UNSIGNED NULL,
  `Hard` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `Position` BIGINT UNSIGNED NULL,
  `ResearchLimit` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_be31c4939bd0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HuntingBuffSuit
CREATE TABLE IF NOT EXISTS `game_cfg_huntingbuffsuit` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BuffList` VARCHAR(55) NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  `IsDebuff` BIGINT UNSIGNED NULL,
  `note` VARCHAR(32) NULL,
  `Week` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_822889b35d24` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HuntingDungeonGrowth
CREATE TABLE IF NOT EXISTS `game_cfg_huntingdungeongrowth` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Growth` DECIMAL(11,6) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_43353071c121` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HuntingIntrude
CREATE TABLE IF NOT EXISTS `game_cfg_huntingintrude` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BuffRange` VARCHAR(32) NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  `JobTypeLimit` VARCHAR(48) NULL,
  `name` VARCHAR(32) NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e908f3d9e58e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HuntingIntrudeBuffSuit
CREATE TABLE IF NOT EXISTS `game_cfg_huntingintrudebuffsuit` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `HeroBuffList` VARCHAR(34) NULL,
  `MonsterBuffList` VARCHAR(34) NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ba8f250e57fe` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HuntingIntrudeReward
CREATE TABLE IF NOT EXISTS `game_cfg_huntingintrudereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(60) NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b491aaaeb0ff` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: IntegralBossBase
CREATE TABLE IF NOT EXISTS `game_cfg_integralbossbase` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CeHua` VARCHAR(32) NULL,
  `Chapter` BIGINT UNSIGNED NULL,
  `NPCID` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9c9f175d4167` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: IntegralBossConfig
CREATE TABLE IF NOT EXISTS `game_cfg_integralbossconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Lastime` BIGINT UNSIGNED NULL,
  `LoopCount` BIGINT UNSIGNED NULL,
  `Opentime` VARCHAR(186) NULL,
  `PreStartTime` BIGINT UNSIGNED NULL,
  `StartChapter` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_48699feab1a7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: IslandChallengeConfig
CREATE TABLE IF NOT EXISTS `game_cfg_islandchallengeconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CloseDays` BIGINT UNSIGNED NULL,
  `FirstBattlePower` BIGINT UNSIGNED NULL,
  `FirstHeroLevel` BIGINT UNSIGNED NULL,
  `OpenDays` BIGINT UNSIGNED NULL,
  `RevivePrice` VARCHAR(32) NULL,
  `ShopItemCount` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_858361bef9dc` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: IslandChallengeDungeon
CREATE TABLE IF NOT EXISTS `game_cfg_islandchallengedungeon` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Difficulty` BIGINT UNSIGNED NULL,
  `DungeonList` VARCHAR(32) NULL,
  `MonsterHero` VARCHAR(148) NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_0b865b1ea323` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: IslandChallengeGroup
CREATE TABLE IF NOT EXISTS `game_cfg_islandchallengegroup` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `GroupId` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_bc3ef04ab6dc` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: IslandChallengeNodeReward
CREATE TABLE IF NOT EXISTS `game_cfg_islandchallengenodereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `GroupId` BIGINT UNSIGNED NULL,
  `Index` BIGINT UNSIGNED NULL,
  `NextTowerId` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `RewardLineHeight` BIGINT UNSIGNED NULL,
  `Stage` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_26b5ff7d2e52` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: IslandChallengeShopItem
CREATE TABLE IF NOT EXISTS `game_cfg_islandchallengeshopitem` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `QualityMax` BIGINT UNSIGNED NULL,
  `QualityMin` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c1ed0be763ec` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: IslandChallengeShopItemTypeRandom
CREATE TABLE IF NOT EXISTS `game_cfg_islandchallengeshopitemtyperandom` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `TaskLimit` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_071c4b8efa5f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: IslandChallengeTask
CREATE TABLE IF NOT EXISTS `game_cfg_islandchallengetask` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Chapter` BIGINT UNSIGNED NULL,
  `ChapterIdIndex` BIGINT UNSIGNED NULL,
  `Difficuty` BIGINT UNSIGNED NULL,
  `GroupId` BIGINT UNSIGNED NULL,
  `NodeId` BIGINT UNSIGNED NULL,
  `Quality` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(34) NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_201f75056a3d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: IslandHighConfig
CREATE TABLE IF NOT EXISTS `game_cfg_islandhighconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `HighControlNum` VARCHAR(32) NULL,
  `HighGridMaxIndex` BIGINT UNSIGNED NULL,
  `HighItemControl` BIGINT UNSIGNED NULL,
  `HighItemDouble` BIGINT UNSIGNED NULL,
  `HighItemNormal` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_08890400d531` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: IslandHighEvent
CREATE TABLE IF NOT EXISTS `game_cfg_islandhighevent` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Des` VARCHAR(32) NULL,
  `MainEvent` BIGINT UNSIGNED NULL,
  `Param` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f4c8380c37ef` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: IslandHighGrid
CREATE TABLE IF NOT EXISTS `game_cfg_islandhighgrid` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ArrowEffAngle` DECIMAL(5,2) NULL,
  `Des` VARCHAR(32) NULL,
  `Event` BIGINT UNSIGNED NULL,
  `Layer` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_af8f7c8e06b6` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: IslandHighRankFinalReward
CREATE TABLE IF NOT EXISTS `game_cfg_islandhighrankfinalreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Rank` VARCHAR(32) NULL,
  `Rewards` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_28d8c75d711d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: IslandHighRankReward
CREATE TABLE IF NOT EXISTS `game_cfg_islandhighrankreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Day` BIGINT UNSIGNED NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Notice` VARCHAR(32) NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Rank` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `Stage` BIGINT UNSIGNED NULL,
  `Time` TIME NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4af8e29e28db` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: IslandHighReward
CREATE TABLE IF NOT EXISTS `game_cfg_islandhighreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ExtraReward` VARCHAR(50) NULL,
  `Grid` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(36) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_81b78df050c2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: IslandHighStageReward
CREATE TABLE IF NOT EXISTS `game_cfg_islandhighstagereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Day` BIGINT UNSIGNED NULL,
  `Grid` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_69503a0bc1d4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: IslandHighTotalReward
CREATE TABLE IF NOT EXISTS `game_cfg_islandhightotalreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Grid` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_acd13ccd803c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Limit
CREATE TABLE IF NOT EXISTS `game_cfg_limit` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `branchTaskId` BIGINT UNSIGNED NULL,
  `level` BIGINT UNSIGNED NULL,
  `mainTaskId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_24d948e4bdbe` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Mark
CREATE TABLE IF NOT EXISTS `game_cfg_mark` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Atlas` VARCHAR(32) NULL,
  `CeHua` VARCHAR(32) NULL,
  `DivMark` BIGINT UNSIGNED NULL,
  `Effect` VARCHAR(51) NULL,
  `Icon` VARCHAR(32) NULL,
  `MaxCount` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `TimeToLive` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_31e9697d43a1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: MidAutumnConfig
CREATE TABLE IF NOT EXISTS `game_cfg_midautumnconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Character` VARCHAR(118) NULL,
  `ConsecutiveCount` BIGINT UNSIGNED NULL,
  `DefaultDiscount` BIGINT UNSIGNED NULL,
  `DiscountWeight` VARCHAR(35) NULL,
  `DrawFiveTimesDiamond` BIGINT UNSIGNED NULL,
  `DrawOnceDiamond` BIGINT UNSIGNED NULL,
  `DrawOnceScore` BIGINT UNSIGNED NULL,
  `IsShowRank` BIGINT UNSIGNED NULL,
  `PreviewReward` VARCHAR(241) NULL,
  `RewardPoolWeight` VARCHAR(32) NULL,
  `ShowCurrency` VARCHAR(32) NULL,
  `SpecialDiscountRatio` VARCHAR(51) NULL,
  `WordsPoolType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_04c4642b207c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: MidAutumnRandomReward
CREATE TABLE IF NOT EXISTS `game_cfg_midautumnrandomreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `RewardType` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_8828141d562f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: MidAutumnRankReward
CREATE TABLE IF NOT EXISTS `game_cfg_midautumnrankreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Rank` VARCHAR(32) NULL,
  `Rewards` VARCHAR(35) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c1f54e0108ef` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: MidAutumnScoreReward
CREATE TABLE IF NOT EXISTS `game_cfg_midautumnscorereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ClientReward` VARCHAR(32) NULL,
  `IsHighScore` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `Score` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_881ab5fe05cc` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: MixSkillHero
CREATE TABLE IF NOT EXISTS `game_cfg_mixskillhero` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CeHua` VARCHAR(32) NULL,
  `Hero_1` BIGINT UNSIGNED NULL,
  `Hero_2` BIGINT UNSIGNED NULL,
  `MixSkillEffect` VARCHAR(32) NULL,
  `MixSkillName` VARCHAR(32) NULL,
  `name` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6a587011d02d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: MixSkillPolicy
CREATE TABLE IF NOT EXISTS `game_cfg_mixskillpolicy` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Buffs` VARCHAR(32) NULL,
  `EnableLeftTime` BIGINT UNSIGNED NULL,
  `F` BIGINT UNSIGNED NULL,
  `K` DECIMAL(2,1) NULL,
  `L` BIGINT UNSIGNED NULL,
  `name` BIGINT UNSIGNED NULL,
  `S` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9cdb46bfd804` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Monster
CREATE TABLE IF NOT EXISTS `game_cfg_monster` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BackgroundColor` VARCHAR(32) NULL,
  `BloodSizeType` BIGINT UNSIGNED NULL,
  `BornCameraAnimId` VARCHAR(37) NULL,
  `BornTime` DECIMAL(4,3) NULL,
  `CEHUA` VARCHAR(32) NULL,
  `DeadCameraAnimId` BIGINT UNSIGNED NULL,
  `DeadDelay` BIGINT UNSIGNED NULL,
  `FollowRange` BIGINT UNSIGNED NULL,
  `ForgiveTime` DECIMAL(2,1) NULL,
  `HateRange` BIGINT UNSIGNED NULL,
  `HateRatio` DECIMAL(4,1) NULL,
  `HateRefreshTime` DECIMAL(2,1) NULL,
  `HitGlowColor` VARCHAR(32) NULL,
  `Hp_Layer_Num` BIGINT UNSIGNED NULL,
  `Icon` VARCHAR(38) NULL,
  `IsBoss` BIGINT UNSIGNED NULL,
  `IsShowTitle` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  `ModelID` BIGINT UNSIGNED NULL,
  `ModelSizeType` BIGINT UNSIGNED NULL,
  `PRO_ARM` BIGINT UNSIGNED NULL,
  `PRO_ATK` BIGINT UNSIGNED NULL,
  `PRO_CRI` BIGINT UNSIGNED NULL,
  `PRO_DEF` BIGINT UNSIGNED NULL,
  `PRO_FLEE` BIGINT UNSIGNED NULL,
  `PRO_HIT` BIGINT UNSIGNED NULL,
  `PRO_IMP` BIGINT UNSIGNED NULL,
  `PRO_MAX_HP` VARCHAR(32) NULL,
  `PRO_MUL_CRI` BIGINT UNSIGNED NULL,
  `PRO_RES` BIGINT UNSIGNED NULL,
  `PRO_SPD` BIGINT UNSIGNED NULL,
  `Radius` DECIMAL(3,2) NULL,
  `Scale` BIGINT UNSIGNED NULL,
  `SearchRange` BIGINT UNSIGNED NULL,
  `Skills` VARCHAR(133) NULL,
  `SlowMotionId` BIGINT UNSIGNED NULL,
  `Triggers` VARCHAR(130) NULL,
  `Weapon_L` BIGINT UNSIGNED NULL,
  `Weapon_R` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e63d88bd7bf3` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Monster_Drop
CREATE TABLE IF NOT EXISTS `game_cfg_monster_drop` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DropItem` TEXT NULL,
  `DropItemRandom` VARCHAR(47) NULL,
  `name` VARCHAR(32) NULL,
  `RewardDropId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9344e7f0f791` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: MonsterHero
CREATE TABLE IF NOT EXISTS `game_cfg_monsterhero` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `HeroId` BIGINT UNSIGNED NULL,
  `PosCollision` BIGINT UNSIGNED NULL,
  `PRO_ARM` BIGINT UNSIGNED NULL,
  `PRO_ATK` BIGINT UNSIGNED NULL,
  `PRO_CRI` BIGINT UNSIGNED NULL,
  `PRO_DEF` BIGINT UNSIGNED NULL,
  `PRO_FLEE` BIGINT UNSIGNED NULL,
  `PRO_HIT` BIGINT UNSIGNED NULL,
  `PRO_IMP` BIGINT UNSIGNED NULL,
  `PRO_MAX_HP` BIGINT UNSIGNED NULL,
  `PRO_RES` BIGINT UNSIGNED NULL,
  `SkillLevel` BIGINT UNSIGNED NULL,
  `SoulRingCount` BIGINT UNSIGNED NULL,
  `SoulRingYears` VARCHAR(61) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6fa5c87e2288` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ชุดข้อมูล configuration: BasicNatureIncreasement
CREATE TABLE IF NOT EXISTS `game_cfg_basicnatureincreasement` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `PRO_ARM` DECIMAL(6,2) NULL,
  `PRO_ATK` DECIMAL(6,2) NULL,
  `PRO_CRI` DECIMAL(6,2) NULL,
  `PRO_DEF` DECIMAL(6,2) NULL,
  `PRO_FLEE` DECIMAL(6,2) NULL,
  `PRO_HIT` DECIMAL(6,2) NULL,
  `PRO_IMP` DECIMAL(6,2) NULL,
  `PRO_MAX_HP` DECIMAL(6,2) NULL,
  `PRO_RES` DECIMAL(6,2) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_16e875124857` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: BasicNatureMapping
CREATE TABLE IF NOT EXISTS `game_cfg_basicnaturemapping` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `NatureType` VARCHAR(32) NULL,
  `PRO_ARM` BIGINT UNSIGNED NULL,
  `PRO_ATK` BIGINT UNSIGNED NULL,
  `PRO_CRI` BIGINT UNSIGNED NULL,
  `PRO_DEF` BIGINT UNSIGNED NULL,
  `PRO_FLEE` BIGINT UNSIGNED NULL,
  `PRO_HIT` BIGINT UNSIGNED NULL,
  `PRO_IMP` BIGINT UNSIGNED NULL,
  `PRO_MAX_HP` BIGINT UNSIGNED NULL,
  `PRO_RES` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4cba83ddf35d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GroValFactor
CREATE TABLE IF NOT EXISTS `game_cfg_grovalfactor` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AwakenC` DECIMAL(3,2) NULL,
  `AwakenLevel` BIGINT UNSIGNED NULL,
  `PlayerAwakenC` DECIMAL(3,2) NULL,
  `PlayerAwakenLevel` BIGINT UNSIGNED NULL,
  `StepsC` BIGINT UNSIGNED NULL,
  `StepsLevel` BIGINT UNSIGNED NULL,
  `StepsS` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_83103aeb4cbe` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroBasicAddAttribute
CREATE TABLE IF NOT EXISTS `game_cfg_herobasicaddattribute` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `PRO_AGI` BIGINT UNSIGNED NULL,
  `PRO_ARM` BIGINT UNSIGNED NULL,
  `PRO_ATK` BIGINT UNSIGNED NULL,
  `PRO_CON` BIGINT UNSIGNED NULL,
  `PRO_CRI` BIGINT UNSIGNED NULL,
  `PRO_DEF` BIGINT UNSIGNED NULL,
  `PRO_EXP` BIGINT UNSIGNED NULL,
  `PRO_FLEE` BIGINT UNSIGNED NULL,
  `PRO_HIT` BIGINT UNSIGNED NULL,
  `PRO_IMP` BIGINT UNSIGNED NULL,
  `PRO_MAX_HP` BIGINT UNSIGNED NULL,
  `PRO_MUL_CRI` BIGINT UNSIGNED NULL,
  `PRO_POW` BIGINT UNSIGNED NULL,
  `PRO_RES` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f2fd57831d5a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroBasicAttribute
CREATE TABLE IF NOT EXISTS `game_cfg_herobasicattribute` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `PRO_AGI` BIGINT UNSIGNED NULL,
  `PRO_ARM` DECIMAL(3,2) NULL,
  `PRO_ATK` DECIMAL(4,2) NULL,
  `PRO_CON` BIGINT UNSIGNED NULL,
  `PRO_CRI` DECIMAL(3,2) NULL,
  `PRO_DEF` DECIMAL(3,2) NULL,
  `PRO_EXP` BIGINT UNSIGNED NULL,
  `PRO_FLEE` DECIMAL(3,2) NULL,
  `PRO_HIT` DECIMAL(3,2) NULL,
  `PRO_IMP` DECIMAL(3,2) NULL,
  `PRO_MAX_HP` BIGINT UNSIGNED NULL,
  `PRO_MUL_CRI` BIGINT UNSIGNED NULL,
  `PRO_POW` BIGINT UNSIGNED NULL,
  `PRO_RES` DECIMAL(3,2) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_03e98e7f2b30` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroStepNature
CREATE TABLE IF NOT EXISTS `game_cfg_herostepnature` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CardQuality` BIGINT UNSIGNED NULL,
  `PRO_ARM` BIGINT UNSIGNED NULL,
  `PRO_ATK` BIGINT UNSIGNED NULL,
  `PRO_CRI` BIGINT UNSIGNED NULL,
  `PRO_DEF` BIGINT UNSIGNED NULL,
  `PRO_FLEE` BIGINT UNSIGNED NULL,
  `PRO_HIT` BIGINT UNSIGNED NULL,
  `PRO_IMP` BIGINT UNSIGNED NULL,
  `PRO_MAX_HP` BIGINT UNSIGNED NULL,
  `PRO_RES` BIGINT UNSIGNED NULL,
  `StepsLevel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_29dc1bff0037` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: NineTestConfig
CREATE TABLE IF NOT EXISTS `game_cfg_ninetestconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CostDiamond` VARCHAR(73) NULL,
  `GridCount` BIGINT UNSIGNED NULL,
  `IsShowRank` BIGINT UNSIGNED NULL,
  `OneScoreMappingDiamond` BIGINT UNSIGNED NULL,
  `PreviewReward` TEXT NULL,
  `RestDiamond` BIGINT UNSIGNED NULL,
  `RewardTypeCount` VARCHAR(32) NULL,
  `RewardTypeWeight` VARCHAR(34) NULL,
  `ShowCurrency` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_da8aaa2241de` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: NineTestRandomReward
CREATE TABLE IF NOT EXISTS `game_cfg_ninetestrandomreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `RewardType` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7a021b60285b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: NineTestRankReward
CREATE TABLE IF NOT EXISTS `game_cfg_ninetestrankreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Rank` VARCHAR(32) NULL,
  `Rewards` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3feaaa57101c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: NineTestScoreReward
CREATE TABLE IF NOT EXISTS `game_cfg_ninetestscorereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ClientReward` VARCHAR(32) NULL,
  `IsHighScore` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `Score` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_03b3b968edc8` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Onhook
CREATE TABLE IF NOT EXISTS `game_cfg_onhook` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ExpCardReward` VARCHAR(32) NULL,
  `GoldCardReward` VARCHAR(32) NULL,
  `MonsterList` VARCHAR(32) NULL,
  `RandomReward` TEXT NULL,
  `RewardDropId` BIGINT UNSIGNED NULL,
  `TaskId` BIGINT UNSIGNED NULL,
  `TexturePath` VARCHAR(40) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e51c41497727` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: OnhookCard
CREATE TABLE IF NOT EXISTS `game_cfg_onhookcard` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `TimeHourType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ad7d62d0ef09` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: OnhookConfig
CREATE TABLE IF NOT EXISTS `game_cfg_onhookconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `FastRewardTime` BIGINT UNSIGNED NULL,
  `MaxRewardTime` BIGINT UNSIGNED NULL,
  `OpenReward` VARCHAR(32) NULL,
  `PushTime` BIGINT UNSIGNED NULL,
  `RandomRewardTime` BIGINT UNSIGNED NULL,
  `RedTime` BIGINT UNSIGNED NULL,
  `RewardTime` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d7c8a1c1da85` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassConfig
CREATE TABLE IF NOT EXISTS `game_cfg_passconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DefaultBought` VARCHAR(32) NULL,
  `MaxPassLevel` BIGINT UNSIGNED NULL,
  `overflowLevelExp` BIGINT UNSIGNED NULL,
  `PeriodDays` BIGINT UNSIGNED NULL,
  `RechargeId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c21baff97cf4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassDailyReward_1
CREATE TABLE IF NOT EXISTS `game_cfg_passdailyreward_1` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddReward` VARCHAR(32) NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(41) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_0e8a46f14943` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassDailyReward_10
CREATE TABLE IF NOT EXISTS `game_cfg_passdailyreward_10` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddReward` VARCHAR(32) NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(41) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b943845b0f3d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassDailyReward_11
CREATE TABLE IF NOT EXISTS `game_cfg_passdailyreward_11` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddReward` VARCHAR(32) NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(41) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1de7c658614d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassDailyReward_12
CREATE TABLE IF NOT EXISTS `game_cfg_passdailyreward_12` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddReward` VARCHAR(32) NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(41) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_675580aeb100` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassDailyReward_2
CREATE TABLE IF NOT EXISTS `game_cfg_passdailyreward_2` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddReward` VARCHAR(32) NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(41) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a8e3fb5c1c82` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassDailyReward_3
CREATE TABLE IF NOT EXISTS `game_cfg_passdailyreward_3` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddReward` VARCHAR(32) NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(41) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_685cfc6a22b8` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassDailyReward_4
CREATE TABLE IF NOT EXISTS `game_cfg_passdailyreward_4` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddReward` VARCHAR(32) NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(41) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a0774700fe04` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassDailyReward_5
CREATE TABLE IF NOT EXISTS `game_cfg_passdailyreward_5` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddReward` VARCHAR(32) NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(41) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6398c8261186` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassDailyReward_6
CREATE TABLE IF NOT EXISTS `game_cfg_passdailyreward_6` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddReward` VARCHAR(32) NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(41) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_875255ca486d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassDailyReward_7
CREATE TABLE IF NOT EXISTS `game_cfg_passdailyreward_7` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddReward` VARCHAR(32) NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(41) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3d2f9592a92b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassDailyReward_8
CREATE TABLE IF NOT EXISTS `game_cfg_passdailyreward_8` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddReward` VARCHAR(32) NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(41) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_93f8f1f529c8` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassDailyReward_9
CREATE TABLE IF NOT EXISTS `game_cfg_passdailyreward_9` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddReward` VARCHAR(32) NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(41) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7c1d3b48b042` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassLevel
CREATE TABLE IF NOT EXISTS `game_cfg_passlevel` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DeltaExp` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e7c801c79d7a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassLevelReward_1
CREATE TABLE IF NOT EXISTS `game_cfg_passlevelreward_1` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c92603bc008c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassLevelReward_10
CREATE TABLE IF NOT EXISTS `game_cfg_passlevelreward_10` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_2d3636cc9f96` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassLevelReward_11
CREATE TABLE IF NOT EXISTS `game_cfg_passlevelreward_11` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_bfbca899068f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassLevelReward_12
CREATE TABLE IF NOT EXISTS `game_cfg_passlevelreward_12` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6acf49d7e22a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassLevelReward_2
CREATE TABLE IF NOT EXISTS `game_cfg_passlevelreward_2` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_92c5552656dc` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassLevelReward_3
CREATE TABLE IF NOT EXISTS `game_cfg_passlevelreward_3` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_8517c32d94bf` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassLevelReward_4
CREATE TABLE IF NOT EXISTS `game_cfg_passlevelreward_4` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_77e3091c50d6` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassLevelReward_5
CREATE TABLE IF NOT EXISTS `game_cfg_passlevelreward_5` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3697cb897105` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassLevelReward_6
CREATE TABLE IF NOT EXISTS `game_cfg_passlevelreward_6` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_8efcac20151a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassLevelReward_7
CREATE TABLE IF NOT EXISTS `game_cfg_passlevelreward_7` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5afb8c0d824c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassLevelReward_8
CREATE TABLE IF NOT EXISTS `game_cfg_passlevelreward_8` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_654e0f333bc0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassLevelReward_9
CREATE TABLE IF NOT EXISTS `game_cfg_passlevelreward_9` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `LoopGap` TEXT NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b4b9ab8e1898` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassRechargeLevel
CREATE TABLE IF NOT EXISTS `game_cfg_passrechargelevel` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddLevel` BIGINT UNSIGNED NULL,
  `RechargeId` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_45d0ac938172` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassTask_1
CREATE TABLE IF NOT EXISTS `game_cfg_passtask_1` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `LoopType` BIGINT UNSIGNED NULL,
  `NpcId` BIGINT UNSIGNED NULL,
  `OpenPanel` VARCHAR(37) NULL,
  `PassTaskType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(35) NULL,
  `TaskParam` VARCHAR(40) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_846ce57e4d2e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassTask_10
CREATE TABLE IF NOT EXISTS `game_cfg_passtask_10` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `LoopType` BIGINT UNSIGNED NULL,
  `NpcId` BIGINT UNSIGNED NULL,
  `OpenPanel` VARCHAR(37) NULL,
  `PassTaskType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(35) NULL,
  `TaskParam` VARCHAR(40) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c442f4ed3702` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassTask_11
CREATE TABLE IF NOT EXISTS `game_cfg_passtask_11` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `LoopType` BIGINT UNSIGNED NULL,
  `NpcId` BIGINT UNSIGNED NULL,
  `OpenPanel` VARCHAR(37) NULL,
  `PassTaskType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(35) NULL,
  `TaskParam` VARCHAR(40) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3d7a1ed95e54` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassTask_12
CREATE TABLE IF NOT EXISTS `game_cfg_passtask_12` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `LoopType` BIGINT UNSIGNED NULL,
  `NpcId` BIGINT UNSIGNED NULL,
  `OpenPanel` VARCHAR(37) NULL,
  `PassTaskType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(35) NULL,
  `TaskParam` VARCHAR(40) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7940119a9f0b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassTask_2
CREATE TABLE IF NOT EXISTS `game_cfg_passtask_2` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `LoopType` BIGINT UNSIGNED NULL,
  `NpcId` BIGINT UNSIGNED NULL,
  `OpenPanel` VARCHAR(37) NULL,
  `PassTaskType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(35) NULL,
  `TaskParam` VARCHAR(40) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_18ca8e640ae3` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassTask_3
CREATE TABLE IF NOT EXISTS `game_cfg_passtask_3` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `LoopType` BIGINT UNSIGNED NULL,
  `NpcId` BIGINT UNSIGNED NULL,
  `OpenPanel` VARCHAR(37) NULL,
  `PassTaskType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(35) NULL,
  `TaskParam` VARCHAR(40) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9d3a2d0ba69d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassTask_4
CREATE TABLE IF NOT EXISTS `game_cfg_passtask_4` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `LoopType` BIGINT UNSIGNED NULL,
  `NpcId` BIGINT UNSIGNED NULL,
  `OpenPanel` VARCHAR(37) NULL,
  `PassTaskType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(35) NULL,
  `TaskParam` VARCHAR(40) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_bcdf1ffb5e13` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassTask_5
CREATE TABLE IF NOT EXISTS `game_cfg_passtask_5` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `LoopType` BIGINT UNSIGNED NULL,
  `NpcId` BIGINT UNSIGNED NULL,
  `OpenPanel` VARCHAR(37) NULL,
  `PassTaskType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(35) NULL,
  `TaskParam` VARCHAR(40) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1153c77c73b5` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassTask_6
CREATE TABLE IF NOT EXISTS `game_cfg_passtask_6` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `LoopType` BIGINT UNSIGNED NULL,
  `NpcId` BIGINT UNSIGNED NULL,
  `OpenPanel` VARCHAR(37) NULL,
  `PassTaskType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(35) NULL,
  `TaskParam` VARCHAR(40) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ebefe12855c6` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassTask_7
CREATE TABLE IF NOT EXISTS `game_cfg_passtask_7` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `LoopType` BIGINT UNSIGNED NULL,
  `NpcId` BIGINT UNSIGNED NULL,
  `OpenPanel` VARCHAR(37) NULL,
  `PassTaskType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(35) NULL,
  `TaskParam` VARCHAR(40) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_552927a69e8a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassTask_8
CREATE TABLE IF NOT EXISTS `game_cfg_passtask_8` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `LoopType` BIGINT UNSIGNED NULL,
  `NpcId` BIGINT UNSIGNED NULL,
  `OpenPanel` VARCHAR(37) NULL,
  `PassTaskType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(35) NULL,
  `TaskParam` VARCHAR(40) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_61fb4be9de2f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassTask_9
CREATE TABLE IF NOT EXISTS `game_cfg_passtask_9` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `LoopType` BIGINT UNSIGNED NULL,
  `NpcId` BIGINT UNSIGNED NULL,
  `OpenPanel` VARCHAR(37) NULL,
  `PassTaskType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(35) NULL,
  `TaskParam` VARCHAR(40) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7e1495aa40e4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Pet
CREATE TABLE IF NOT EXISTS `game_cfg_pet` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AttackRange` DECIMAL(2,1) NULL,
  `CEHUA` VARCHAR(32) NULL,
  `FollowDistance` BIGINT UNSIGNED NULL,
  `FormationScale` DECIMAL(3,2) NULL,
  `HateRange` BIGINT UNSIGNED NULL,
  `HateRatio` BIGINT UNSIGNED NULL,
  `HateRefreshTime` DECIMAL(2,1) NULL,
  `InitLevel` BIGINT UNSIGNED NULL,
  `ModelId` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `NormalAttacks` VARCHAR(32) NULL,
  `Order` BIGINT UNSIGNED NULL,
  `PreviewScale` DECIMAL(3,2) NULL,
  `PRO_RUN_IN_BATTLE` BIGINT UNSIGNED NULL,
  `PRO_RUN_OUT_BATTLE` BIGINT UNSIGNED NULL,
  `Radius` BIGINT UNSIGNED NULL,
  `Scale` BIGINT UNSIGNED NULL,
  `SceneScale` DECIMAL(3,2) NULL,
  `Skills` VARCHAR(32) NULL,
  `title_offset_y` BIGINT UNSIGNED NULL,
  `TransmitDistance` BIGINT UNSIGNED NULL,
  `Triggers` VARCHAR(35) NULL,
  `Type` BIGINT UNSIGNED NULL,
  `WalkRange` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_df26241195d7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PetAptitudeBonusNature
CREATE TABLE IF NOT EXISTS `game_cfg_petaptitudebonusnature` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BonusRatio` BIGINT UNSIGNED NULL,
  `MaxAptitude` BIGINT UNSIGNED NULL,
  `MinAptitude` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_306b844e024e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PetBasicGrowthNature
CREATE TABLE IF NOT EXISTS `game_cfg_petbasicgrowthnature` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `PRO_ARM` BIGINT UNSIGNED NULL,
  `PRO_ATK` BIGINT UNSIGNED NULL,
  `PRO_CRI` BIGINT UNSIGNED NULL,
  `PRO_DEF` BIGINT UNSIGNED NULL,
  `PRO_FLEE` BIGINT UNSIGNED NULL,
  `PRO_HIT` BIGINT UNSIGNED NULL,
  `PRO_IMP` BIGINT UNSIGNED NULL,
  `PRO_MAX_HP` BIGINT UNSIGNED NULL,
  `PRO_RES` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_20feb599c505` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PetBasicNature
CREATE TABLE IF NOT EXISTS `game_cfg_petbasicnature` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `PRO_ARM` BIGINT UNSIGNED NULL,
  `PRO_ATK` BIGINT UNSIGNED NULL,
  `PRO_CRI` BIGINT UNSIGNED NULL,
  `PRO_DEF` BIGINT UNSIGNED NULL,
  `PRO_FLEE` BIGINT UNSIGNED NULL,
  `PRO_HIT` BIGINT UNSIGNED NULL,
  `PRO_IMP` BIGINT UNSIGNED NULL,
  `PRO_MAX_HP` BIGINT UNSIGNED NULL,
  `PRO_MUL_CRI` BIGINT UNSIGNED NULL,
  `PRO_RES` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_36ebb4385521` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PetBreak
CREATE TABLE IF NOT EXISTS `game_cfg_petbreak` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BreakConsumeNum` BIGINT UNSIGNED NULL,
  `ExtraPassiveSkillNum` BIGINT UNSIGNED NULL,
  `InbornSkillLevelUp` BIGINT UNSIGNED NULL,
  `UnlockInbornSkill` BIGINT UNSIGNED NULL,
  `UnlockPassiveSkill` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c8ca4328a522` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PetConfig
CREATE TABLE IF NOT EXISTS `game_cfg_petconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AppVersionLimit` VARCHAR(32) NULL,
  `BaptizeItemCost` VARCHAR(32) NULL,
  `BaptizeSoulDustCost` BIGINT UNSIGNED NULL,
  `BasicHatchNum` BIGINT UNSIGNED NULL,
  `BattleHitFactor` BIGINT UNSIGNED NULL,
  `BreakMaxLevel` BIGINT UNSIGNED NULL,
  `BreakOnceMaxNum` BIGINT UNSIGNED NULL,
  `BuyHatchNum` BIGINT UNSIGNED NULL,
  `BuySubHatchTimeRatio` BIGINT UNSIGNED NULL,
  `CollisionRadius` DECIMAL(2,1) NULL,
  `CountDown` BIGINT UNSIGNED NULL,
  `EggMaxNum` BIGINT UNSIGNED NULL,
  `HighAptitude` BIGINT UNSIGNED NULL,
  `HintAptitude` BIGINT UNSIGNED NULL,
  `HintBreakLevel` BIGINT UNSIGNED NULL,
  `HintLevel` BIGINT UNSIGNED NULL,
  `HintSkillQuality` BIGINT UNSIGNED NULL,
  `InheritCostItem` VARCHAR(32) NULL,
  `MaxLevel` BIGINT UNSIGNED NULL,
  `MaxSatiety` BIGINT UNSIGNED NULL,
  `MaxShape` BIGINT UNSIGNED NULL,
  `MinShape` DECIMAL(2,1) NULL,
  `PassiveSkillNum` BIGINT UNSIGNED NULL,
  `PetMaxNum` BIGINT UNSIGNED NULL,
  `PosX` BIGINT NULL,
  `PosY` BIGINT NULL,
  `PromoteMultiLevel` BIGINT UNSIGNED NULL,
  `SkillAptitudeNum` BIGINT UNSIGNED NULL,
  `SkillMaxNum` BIGINT UNSIGNED NULL,
  `SkillUnlockBreakLevel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c71670276d4f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PetDungeonQueueNum
CREATE TABLE IF NOT EXISTS `game_cfg_petdungeonqueuenum` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Beizhu` VARCHAR(32) NULL,
  `QueueNum` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b513383c95bb` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PetEgg
CREATE TABLE IF NOT EXISTS `game_cfg_petegg` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AptitudeRule` VARCHAR(71) NULL,
  `CEHUA` VARCHAR(33) NULL,
  `HatchTime` BIGINT UNSIGNED NULL,
  `InitBreakLevel` BIGINT UNSIGNED NULL,
  `PetTypeRule` VARCHAR(32) NULL,
  `Quality` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c98efee7e54f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PetFood
CREATE TABLE IF NOT EXISTS `game_cfg_petfood` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddSatiety` BIGINT UNSIGNED NULL,
  `ShapeChange` DECIMAL(3,2) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b2edd66ba344` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PetInbornSkill
CREATE TABLE IF NOT EXISTS `game_cfg_petinbornskill` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattlePower` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  `LevelUpWeight` BIGINT UNSIGNED NULL,
  `Slot` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6fe0e06bec02` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PetLevelUp
CREATE TABLE IF NOT EXISTS `game_cfg_petlevelup` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `SoulPower` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_05365b29d39a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PetNatureGrowthFactor
CREATE TABLE IF NOT EXISTS `game_cfg_petnaturegrowthfactor` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BreakLevel` BIGINT UNSIGNED NULL,
  `PetId` BIGINT UNSIGNED NULL,
  `PRO_ARM` DECIMAL(6,4) NULL,
  `PRO_ATK` DECIMAL(6,4) NULL,
  `PRO_CRI` DECIMAL(6,4) NULL,
  `PRO_DEF` DECIMAL(6,4) NULL,
  `PRO_FLEE` DECIMAL(6,4) NULL,
  `PRO_HIT` DECIMAL(6,4) NULL,
  `PRO_IMP` DECIMAL(6,4) NULL,
  `PRO_MAX_HP` DECIMAL(6,4) NULL,
  `PRO_RES` DECIMAL(6,4) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a8cf11450c01` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PetPassiveSkillLibrary
CREATE TABLE IF NOT EXISTS `game_cfg_petpassiveskilllibrary` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddNatureRatio` VARCHAR(32) NULL,
  `CEHUA` VARCHAR(32) NULL,
  `ExtraNatureRatio` VARCHAR(32) NULL,
  `Quality` BIGINT UNSIGNED NULL,
  `Slot` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_437eef5b742f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PetRelease
CREATE TABLE IF NOT EXISTS `game_cfg_petrelease` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BreakLevel` BIGINT UNSIGNED NULL,
  `Rewards` VARCHAR(32) NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_de7bedb0979a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PetSatiety
CREATE TABLE IF NOT EXISTS `game_cfg_petsatiety` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DeclinePerHour` BIGINT UNSIGNED NULL,
  `MaxSatiety` BIGINT UNSIGNED NULL,
  `MinSatiety` BIGINT UNSIGNED NULL,
  `NatureBonusRatio` BIGINT NULL,
  `ProtectionTime` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1e94bbd7959c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PetSkillGrowth
CREATE TABLE IF NOT EXISTS `game_cfg_petskillgrowth` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `InbornSkillGrowth` BIGINT UNSIGNED NULL,
  `PassiveSkillGrowth` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_27841fee3f7f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PetSkillNum
CREATE TABLE IF NOT EXISTS `game_cfg_petskillnum` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `MaxAptitude` BIGINT UNSIGNED NULL,
  `MinAptitude` BIGINT UNSIGNED NULL,
  `PassiveSkillNum` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f3f2124d599e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PushFigure
CREATE TABLE IF NOT EXISTS `game_cfg_pushfigure` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ChapterId` BIGINT UNSIGNED NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  `MapType` BIGINT UNSIGNED NULL,
  `NextId` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(53) NULL,
  `TaskLimit` BIGINT UNSIGNED NULL,
  `TextureType` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f0e76d802e59` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PushFigureConfig
CREATE TABLE IF NOT EXISTS `game_cfg_pushfigureconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `MonthCardQuickBattle` BIGINT UNSIGNED NULL,
  `SuperMonthCardQuickBattle` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_2c8f9c921565` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RadioCaster
CREATE TABLE IF NOT EXISTS `game_cfg_radiocaster` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `advanceEndTimeHour` BIGINT UNSIGNED NULL,
  `advanceEndTimeMinute` BIGINT UNSIGNED NULL,
  `advanceTimeText` VARCHAR(32) NULL,
  `background` VARCHAR(32) NULL,
  `backgroundUrl` VARCHAR(122) NULL,
  `faceBorderId` BIGINT UNSIGNED NULL,
  `faceIconId` BIGINT UNSIGNED NULL,
  `faceUrl` VARCHAR(115) NULL,
  `name` VARCHAR(32) NULL,
  `visible` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_861485452fe3` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RadioConfig
CREATE TABLE IF NOT EXISTS `game_cfg_radioconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `IntenvalTime` BIGINT UNSIGNED NULL,
  `ShowContributionRankCount` BIGINT UNSIGNED NULL,
  `ShowGiftSecond` BIGINT UNSIGNED NULL,
  `ShowTimeInterval` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_423f9934fbb3` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RadioContributionReward
CREATE TABLE IF NOT EXISTS `game_cfg_radiocontributionreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `Contribution` BIGINT UNSIGNED NULL,
  `ItemId` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d1613444d474` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RadioGift
CREATE TABLE IF NOT EXISTS `game_cfg_radiogift` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `add_contribution` BIGINT UNSIGNED NULL,
  `add_popularity` BIGINT UNSIGNED NULL,
  `announce` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `cost_num` BIGINT UNSIGNED NULL,
  `cost_type` BIGINT UNSIGNED NULL,
  `max_num` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d7d6f0ddc10c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Rank
CREATE TABLE IF NOT EXISTS `game_cfg_rank` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BeginTime` VARCHAR(32) NULL,
  `CEHUA` VARCHAR(32) NULL,
  `CountPerPage` BIGINT UNSIGNED NULL,
  `EndTime` VARCHAR(32) NULL,
  `InfoUpdateTimeSpan` TIME NULL,
  `RankType` BIGINT UNSIGNED NULL,
  `RankUpdateTimeSpan` TIME NULL,
  `ShowCount` BIGINT NULL,
  `SyncUpdate` BOOLEAN NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_dd48a1149548` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RankConfig
CREATE TABLE IF NOT EXISTS `game_cfg_rankconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `RewardPageCount` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_32dcd4ed8915` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RankReward
CREATE TABLE IF NOT EXISTS `game_cfg_rankreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `ClientShow` VARCHAR(32) NULL,
  `ConditionValue` BIGINT UNSIGNED NULL,
  `DropReward` VARCHAR(32) NULL,
  `RankType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5da3aef23085` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RechargeRebate
CREATE TABLE IF NOT EXISTS `game_cfg_rechargerebate` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Account` BIGINT UNSIGNED NULL,
  `Money` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(88) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_2375bb5d5dc4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RechargeRebateConfig
CREATE TABLE IF NOT EXISTS `game_cfg_rechargerebateconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `RebateServerLimit` TEXT NULL,
  `RewardEndDays` BIGINT UNSIGNED NULL,
  `RewardStartDays` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9d9b2c7e044d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: AccumulatedRecharge
CREATE TABLE IF NOT EXISTS `game_cfg_accumulatedrecharge` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Accumulated` DECIMAL(6,1) NULL,
  `AccumulateMoney` DECIMAL(5,1) NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Reward` VARCHAR(73) NULL,
  `RewardStar` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3b6d4e31ec03` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CarnivalMall
CREATE TABLE IF NOT EXISTS `game_cfg_carnivalmall` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `OriginalPrice` VARCHAR(32) NULL,
  `Price` VARCHAR(32) NULL,
  `Reward` VARCHAR(56) NULL,
  `RewardStar` VARCHAR(32) NULL,
  `Stage` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b2408454e10a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CarnivalRecharge
CREATE TABLE IF NOT EXISTS `game_cfg_carnivalrecharge` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AccumulateMoney` DECIMAL(6,2) NULL,
  `AccumulatePrice` DECIMAL(6,2) NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Reward` VARCHAR(51) NULL,
  `RewardStar` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_8463f5019ed8` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CultivateGift
CREATE TABLE IF NOT EXISTS `game_cfg_cultivategift` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `Duration` BIGINT UNSIGNED NULL,
  `OriginalPrice` VARCHAR(32) NULL,
  `Price` VARCHAR(32) NULL,
  `Reward` VARCHAR(133) NULL,
  `RewardStar` VARCHAR(66) NULL,
  `TriggerParam` BIGINT UNSIGNED NULL,
  `TriggerType` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a280cadfefae` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DailyRecharge
CREATE TABLE IF NOT EXISTS `game_cfg_dailyrecharge` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Days` BIGINT UNSIGNED NULL,
  `FinalRewards` VARCHAR(32) NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Rewards` VARCHAR(32) NULL,
  `RewardStar` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_8143260cca22` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DaysRewardsPeriodHero
CREATE TABLE IF NOT EXISTS `game_cfg_daysrewardsperiodhero` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Atlas` VARCHAR(32) NULL,
  `EffectName` VARCHAR(32) NULL,
  `Hero` BIGINT UNSIGNED NULL,
  `ImageTextLeft` VARCHAR(32) NULL,
  `ImageTextRight` VARCHAR(32) NULL,
  `RawImagePath` VARCHAR(35) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ea6e7fd86b95` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DiamondRatioChangeCard
CREATE TABLE IF NOT EXISTS `game_cfg_diamondratiochangecard` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Ratio` BIGINT UNSIGNED NULL,
  `RechargeId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_16686d2e53d4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DiamondRebate
CREATE TABLE IF NOT EXISTS `game_cfg_diamondrebate` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BasicClientRewards` VARCHAR(42) NULL,
  `DiamondLimit` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Rewards` VARCHAR(42) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1f13fd5c6a16` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DiamondRebateConfig
CREATE TABLE IF NOT EXISTS `game_cfg_diamondrebateconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `IgnoreConsumeWays` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_13e5a1857932` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DirectPurchaseTime
CREATE TABLE IF NOT EXISTS `game_cfg_directpurchasetime` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `GiftType` BIGINT UNSIGNED NULL,
  `ShowEnd` VARCHAR(32) NULL,
  `ShowStart` VARCHAR(32) NULL,
  `ShowWeekEnd` VARCHAR(32) NULL,
  `ShowWeekStart` VARCHAR(32) NULL,
  `SubType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b33ed5f24bf4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GetRechargeRewardCheck
CREATE TABLE IF NOT EXISTS `game_cfg_getrechargerewardcheck` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `GiftItems` VARCHAR(32) NULL,
  `Name` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a3f0281b9e4e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HeroDaysRewards
CREATE TABLE IF NOT EXISTS `game_cfg_herodaysrewards` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Day` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_240b89439b44` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: LuckyFlipCardCumulateReward
CREATE TABLE IF NOT EXISTS `game_cfg_luckyflipcardcumulatereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CumulateCount` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `RewardStar` VARCHAR(32) NULL,
  `ShowReward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6f24a016787a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: LuckyFlipCardRechargeCycle
CREATE TABLE IF NOT EXISTS `game_cfg_luckyflipcardrechargecycle` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `First` BIGINT UNSIGNED NULL,
  `NextId` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6ff4e13dfd13` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: LuckyFlipCardReward
CREATE TABLE IF NOT EXISTS `game_cfg_luckyflipcardreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BgImage` VARCHAR(32) NULL,
  `EffName` VARCHAR(32) NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Ratio` VARCHAR(32) NULL,
  `Reward1` VARCHAR(41) NULL,
  `Reward2` VARCHAR(42) NULL,
  `Reward3` VARCHAR(43) NULL,
  `RewardStar1` VARCHAR(32) NULL,
  `RewardStar2` VARCHAR(32) NULL,
  `RewardStar3` VARCHAR(32) NULL,
  `SubType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_dfa1bf4ca291` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: MonthCardActivate
CREATE TABLE IF NOT EXISTS `game_cfg_monthcardactivate` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `RechargeItemId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_df0e410a29dd` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: NewRechargeGift
CREATE TABLE IF NOT EXISTS `game_cfg_newrechargegift` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `IsLast` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(50) NULL,
  `Score` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7172fca4d0f3` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: NewRechargeGiftScore
CREATE TABLE IF NOT EXISTS `game_cfg_newrechargegiftscore` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Score` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5a02f7c4046f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: NewServerPromotion
CREATE TABLE IF NOT EXISTS `game_cfg_newserverpromotion` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Days` BIGINT UNSIGNED NULL,
  `FinalRewards` VARCHAR(32) NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Rewards` VARCHAR(32) NULL,
  `RewardStar` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ddec6251c1b1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PettyGift
CREATE TABLE IF NOT EXISTS `game_cfg_pettygift` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Duration` BIGINT UNSIGNED NULL,
  `IsFirst` BIGINT UNSIGNED NULL,
  `MainType` BIGINT UNSIGNED NULL,
  `NextGiftId` BIGINT UNSIGNED NULL,
  `NextOneRmbGift` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3158bb5d441e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RechargeConfig
CREATE TABLE IF NOT EXISTS `game_cfg_rechargeconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AccumulateRechargeMoney` BIGINT UNSIGNED NULL,
  `AccumulateRechargeOpenDay` BIGINT UNSIGNED NULL,
  `DailyRechargeAccumulateLimit` BIGINT UNSIGNED NULL,
  `FirstRechargeAccumulate` BIGINT UNSIGNED NULL,
  `GiftLimitTime` BIGINT UNSIGNED NULL,
  `IgnoreNewServerActivityTime` DATETIME(6) NULL,
  `MonthCardDays` BIGINT UNSIGNED NULL,
  `MusicAccumulateRechargeMoney` BIGINT UNSIGNED NULL,
  `OnhookGoldUp` BIGINT UNSIGNED NULL,
  `OnhookSoulPowerUp` BIGINT UNSIGNED NULL,
  `OrderPageCount` BIGINT UNSIGNED NULL,
  `PettyGiftTypeNum` BIGINT UNSIGNED NULL,
  `ShowFirstRecharge` BIGINT UNSIGNED NULL,
  `TreasureFlipCardMaxRound` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_25c086388298` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RechargeGiftItem
CREATE TABLE IF NOT EXISTS `game_cfg_rechargegiftitem` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AccumulateDiamond` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `BuyLimit` BIGINT UNSIGNED NULL,
  `Day` BIGINT UNSIGNED NULL,
  `DiscountRechargeId` BIGINT UNSIGNED NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `ExtraReward` VARCHAR(32) NULL,
  `GiftType` BIGINT UNSIGNED NULL,
  `Order` BIGINT UNSIGNED NULL,
  `ProductId` VARCHAR(34) NULL,
  `RechargeId` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(53) NULL,
  `SubType` BIGINT UNSIGNED NULL,
  `TimingGiftType` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b0564ad3dfc0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RechargeGiftPrice
CREATE TABLE IF NOT EXISTS `game_cfg_rechargegiftprice` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AndroidProductId` VARCHAR(34) NULL,
  `CeHua` VARCHAR(32) NULL,
  `Diamond` BIGINT UNSIGNED NULL,
  `iOSProductId` VARCHAR(34) NULL,
  `Money` BIGINT UNSIGNED NULL,
  `Price` DECIMAL(5,2) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c587a01e2971` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RechargeGiftTab
CREATE TABLE IF NOT EXISTS `game_cfg_rechargegifttab` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `GiftType` BIGINT UNSIGNED NULL,
  `GiftWidget` VARCHAR(36) NULL,
  `GiveReward` VARCHAR(32) NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `LoginRedPoint` BIGINT UNSIGNED NULL,
  `OneDayRedPoint` BIGINT UNSIGNED NULL,
  `OpenEnd` BIGINT UNSIGNED NULL,
  `OpenStart` BIGINT UNSIGNED NULL,
  `Order` BIGINT UNSIGNED NULL,
  `RefreshFreq` BIGINT UNSIGNED NULL,
  `SeparateTab` BIGINT UNSIGNED NULL,
  `ShowEnd` VARCHAR(32) NULL,
  `ShowShop` BOOLEAN NULL,
  `ShowStart` VARCHAR(32) NULL,
  `ShowWeekEnd` VARCHAR(32) NULL,
  `ShowWeekStart` VARCHAR(32) NULL,
  `SubType` BIGINT UNSIGNED NULL,
  `TabAtlas` VARCHAR(32) NULL,
  `TabIcon` VARCHAR(47) NULL,
  `TabShowEnd` VARCHAR(32) NULL,
  `TimingId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5c66960af4d9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RechargeGiftTime
CREATE TABLE IF NOT EXISTS `game_cfg_rechargegifttime` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `BGFontImageName` VARCHAR(42) NULL,
  `BGFontImageNameAtals` VARCHAR(32) NULL,
  `BGImagePath` VARCHAR(34) NULL,
  `EffecName` VARCHAR(37) NULL,
  `GiftType` BIGINT UNSIGNED NULL,
  `GiveReward` VARCHAR(32) NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `RefreshFreq` BIGINT UNSIGNED NULL,
  `RoleImagePath` VARCHAR(40) NULL,
  `ShowEffecName` VARCHAR(51) NULL,
  `ShowEnd` VARCHAR(32) NULL,
  `ShowStart` VARCHAR(32) NULL,
  `ShowWeekStart` VARCHAR(32) NULL,
  `SubType` BIGINT UNSIGNED NULL,
  `TabShowEnd` VARCHAR(32) NULL,
  `TimingId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ed80e100af6e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RechargeToken
CREATE TABLE IF NOT EXISTS `game_cfg_rechargetoken` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Price` DECIMAL(4,2) NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d517cd453db5` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SdkRechargeGiftItem
CREATE TABLE IF NOT EXISTS `game_cfg_sdkrechargegiftitem` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AccumulateDiamond` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `BuyLimit` BIGINT UNSIGNED NULL,
  `Day` BIGINT UNSIGNED NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `GiftType` BIGINT UNSIGNED NULL,
  `RechargeId` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(48) NULL,
  `SubType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f6882a6b42fc` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ServerContribution
CREATE TABLE IF NOT EXISTS `game_cfg_servercontribution` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `MaxValue` BIGINT UNSIGNED NULL,
  `OnhookReward` BIGINT UNSIGNED NULL,
  `RankReward` VARCHAR(186) NULL,
  `Reward` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1a0adb404541` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ServerContributionReward
CREATE TABLE IF NOT EXISTS `game_cfg_servercontributionreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_86d71f72f818` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ShrekInvitation
CREATE TABLE IF NOT EXISTS `game_cfg_shrekinvitation` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BasicClientRewards` VARCHAR(39) NULL,
  `BasicRewards` VARCHAR(39) NULL,
  `CostCoin` VARCHAR(32) NULL,
  `CountDownTime` BIGINT UNSIGNED NULL,
  `Days` BIGINT UNSIGNED NULL,
  `ExpressClientRewards` VARCHAR(32) NULL,
  `ExpressRewards` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_007eb7e05374` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SpecialGiftConfig
CREATE TABLE IF NOT EXISTS `game_cfg_specialgiftconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `FreeGiftId` BIGINT UNSIGNED NULL,
  `GiftMaxLevel` BIGINT UNSIGNED NULL,
  `GiftType` BIGINT UNSIGNED NULL,
  `SubType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_03b3fcca7468` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TreasureFlipCardCumulateReward
CREATE TABLE IF NOT EXISTS `game_cfg_treasureflipcardcumulatereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CumulateCount` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `RewardStar` VARCHAR(32) NULL,
  `ShowReward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3661d08eab63` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TreasureFlipCardFlipCardRatio
CREATE TABLE IF NOT EXISTS `game_cfg_treasureflipcardflipcardratio` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `First` BIGINT UNSIGNED NULL,
  `Probability` BIGINT UNSIGNED NULL,
  `Round` BIGINT UNSIGNED NULL,
  `ShowFirst` BIGINT UNSIGNED NULL,
  `Subtype` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f555939f93e3` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TreasureFlipCardRechargeCycle
CREATE TABLE IF NOT EXISTS `game_cfg_treasureflipcardrechargecycle` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `First` BIGINT UNSIGNED NULL,
  `NextId` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f14ab631339c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TreasureFlipCardReward
CREATE TABLE IF NOT EXISTS `game_cfg_treasureflipcardreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BgImage` VARCHAR(32) NULL,
  `EffName` VARCHAR(32) NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Ratio` VARCHAR(32) NULL,
  `Reward1` VARCHAR(41) NULL,
  `Reward2` VARCHAR(42) NULL,
  `Reward3` VARCHAR(43) NULL,
  `RewardStar1` VARCHAR(32) NULL,
  `RewardStar2` VARCHAR(32) NULL,
  `RewardStar3` VARCHAR(32) NULL,
  `SubType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e99c42ac7237` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ArenaRobot
CREATE TABLE IF NOT EXISTS `game_cfg_arenarobot` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattlePower` BIGINT UNSIGNED NULL,
  `Camp` BIGINT UNSIGNED NULL,
  `DefensiveRobot1` BIGINT UNSIGNED NULL,
  `DefensiveRobot2` BIGINT UNSIGNED NULL,
  `DefensiveRobot3` BIGINT UNSIGNED NULL,
  `DefensiveRobot4` BIGINT UNSIGNED NULL,
  `DefPos0` BIGINT UNSIGNED NULL,
  `DefPos1` BIGINT UNSIGNED NULL,
  `DefPos2` BIGINT UNSIGNED NULL,
  `DefPos3` BIGINT UNSIGNED NULL,
  `DefPos4` BIGINT UNSIGNED NULL,
  `Icon` BIGINT UNSIGNED NULL,
  `IconFrame` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  `Name` VARCHAR(32) NULL,
  `RankLevel` BIGINT UNSIGNED NULL,
  `RankMax` BIGINT UNSIGNED NULL,
  `RankMin` BIGINT UNSIGNED NULL,
  `RobotId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e79a88fdaac9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossChallengeFinalsRobot
CREATE TABLE IF NOT EXISTS `game_cfg_crosschallengefinalsrobot` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattlePower` BIGINT UNSIGNED NULL,
  `Camp` BIGINT UNSIGNED NULL,
  `CrossLevel` BIGINT UNSIGNED NULL,
  `CrossStar` BIGINT UNSIGNED NULL,
  `Icon` BIGINT UNSIGNED NULL,
  `IconFrame` BIGINT UNSIGNED NULL,
  `Index` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  `Name` VARCHAR(32) NULL,
  `Queue1Pos1` BIGINT UNSIGNED NULL,
  `Queue1Pos2` BIGINT UNSIGNED NULL,
  `Queue1Pos3` BIGINT UNSIGNED NULL,
  `Queue1Pos4` BIGINT UNSIGNED NULL,
  `Queue1Pos5` BIGINT UNSIGNED NULL,
  `Queue1Robot1` BIGINT UNSIGNED NULL,
  `Queue1Robot2` BIGINT UNSIGNED NULL,
  `Queue1Robot3` BIGINT UNSIGNED NULL,
  `Queue1Robot4` BIGINT UNSIGNED NULL,
  `Queue1Robot5` BIGINT UNSIGNED NULL,
  `Queue2Pos1` BIGINT UNSIGNED NULL,
  `Queue2Pos2` BIGINT UNSIGNED NULL,
  `Queue2Pos3` BIGINT UNSIGNED NULL,
  `Queue2Pos4` BIGINT UNSIGNED NULL,
  `Queue2Pos5` BIGINT UNSIGNED NULL,
  `Queue2Robot1` BIGINT UNSIGNED NULL,
  `Queue2Robot2` BIGINT UNSIGNED NULL,
  `Queue2Robot3` BIGINT UNSIGNED NULL,
  `Queue2Robot4` BIGINT UNSIGNED NULL,
  `Queue2Robot5` BIGINT UNSIGNED NULL,
  `Queue3Pos1` BIGINT UNSIGNED NULL,
  `Queue3Pos2` BIGINT UNSIGNED NULL,
  `Queue3Pos3` BIGINT UNSIGNED NULL,
  `Queue3Pos4` BIGINT UNSIGNED NULL,
  `Queue3Pos5` BIGINT UNSIGNED NULL,
  `Queue3Robot1` BIGINT UNSIGNED NULL,
  `Queue3Robot2` BIGINT UNSIGNED NULL,
  `Queue3Robot3` BIGINT UNSIGNED NULL,
  `Queue3Robot4` BIGINT UNSIGNED NULL,
  `Queue3Robot5` BIGINT UNSIGNED NULL,
  `Team` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e0581252d63f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossChallengeRobot
CREATE TABLE IF NOT EXISTS `game_cfg_crosschallengerobot` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattlePower` BIGINT UNSIGNED NULL,
  `Camp` BIGINT UNSIGNED NULL,
  `CrossLevel` BIGINT UNSIGNED NULL,
  `CrossStar` BIGINT UNSIGNED NULL,
  `Icon` BIGINT UNSIGNED NULL,
  `IconFrame` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  `Name` VARCHAR(32) NULL,
  `Queue1Pos1` BIGINT UNSIGNED NULL,
  `Queue1Pos2` BIGINT UNSIGNED NULL,
  `Queue1Pos3` BIGINT UNSIGNED NULL,
  `Queue1Pos4` BIGINT UNSIGNED NULL,
  `Queue1Pos5` BIGINT UNSIGNED NULL,
  `Queue1Robot1` BIGINT UNSIGNED NULL,
  `Queue1Robot2` BIGINT UNSIGNED NULL,
  `Queue1Robot3` BIGINT UNSIGNED NULL,
  `Queue1Robot4` BIGINT UNSIGNED NULL,
  `Queue1Robot5` BIGINT UNSIGNED NULL,
  `Queue2Pos1` BIGINT UNSIGNED NULL,
  `Queue2Pos2` BIGINT UNSIGNED NULL,
  `Queue2Pos3` BIGINT UNSIGNED NULL,
  `Queue2Pos4` BIGINT UNSIGNED NULL,
  `Queue2Pos5` BIGINT UNSIGNED NULL,
  `Queue2Robot1` BIGINT UNSIGNED NULL,
  `Queue2Robot2` BIGINT UNSIGNED NULL,
  `Queue2Robot3` BIGINT UNSIGNED NULL,
  `Queue2Robot4` BIGINT UNSIGNED NULL,
  `Queue2Robot5` BIGINT UNSIGNED NULL,
  `Queue3Pos1` BIGINT UNSIGNED NULL,
  `Queue3Pos2` BIGINT UNSIGNED NULL,
  `Queue3Pos3` BIGINT UNSIGNED NULL,
  `Queue3Pos4` BIGINT UNSIGNED NULL,
  `Queue3Pos5` BIGINT UNSIGNED NULL,
  `Queue3Robot1` BIGINT UNSIGNED NULL,
  `Queue3Robot2` BIGINT UNSIGNED NULL,
  `Queue3Robot3` BIGINT UNSIGNED NULL,
  `Queue3Robot4` BIGINT UNSIGNED NULL,
  `Queue3Robot5` BIGINT UNSIGNED NULL,
  `RankMax` BIGINT UNSIGNED NULL,
  `RankMin` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_283c8ba4bc59` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossFinalsRobot
CREATE TABLE IF NOT EXISTS `game_cfg_crossfinalsrobot` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattlePower` BIGINT UNSIGNED NULL,
  `Camp` BIGINT UNSIGNED NULL,
  `CrossLevel` BIGINT UNSIGNED NULL,
  `CrossStar` BIGINT UNSIGNED NULL,
  `Icon` BIGINT UNSIGNED NULL,
  `IconFrame` BIGINT UNSIGNED NULL,
  `Index` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  `Name` VARCHAR(32) NULL,
  `Queue1Pos1` BIGINT UNSIGNED NULL,
  `Queue1Pos2` BIGINT UNSIGNED NULL,
  `Queue1Pos3` BIGINT UNSIGNED NULL,
  `Queue1Pos4` BIGINT UNSIGNED NULL,
  `Queue1Pos5` BIGINT UNSIGNED NULL,
  `Queue1Robot1` BIGINT UNSIGNED NULL,
  `Queue1Robot2` BIGINT UNSIGNED NULL,
  `Queue1Robot3` BIGINT UNSIGNED NULL,
  `Queue1Robot4` BIGINT UNSIGNED NULL,
  `Queue1Robot5` BIGINT UNSIGNED NULL,
  `Queue2Pos1` BIGINT UNSIGNED NULL,
  `Queue2Pos2` BIGINT UNSIGNED NULL,
  `Queue2Pos3` BIGINT UNSIGNED NULL,
  `Queue2Pos4` BIGINT UNSIGNED NULL,
  `Queue2Pos5` BIGINT UNSIGNED NULL,
  `Queue2Robot1` BIGINT UNSIGNED NULL,
  `Queue2Robot2` BIGINT UNSIGNED NULL,
  `Queue2Robot3` BIGINT UNSIGNED NULL,
  `Queue2Robot4` BIGINT UNSIGNED NULL,
  `Queue2Robot5` BIGINT UNSIGNED NULL,
  `Team` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_0590f594dfc2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossRobot
CREATE TABLE IF NOT EXISTS `game_cfg_crossrobot` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattlePower` BIGINT UNSIGNED NULL,
  `Camp` BIGINT UNSIGNED NULL,
  `CrossLevel` BIGINT UNSIGNED NULL,
  `CrossStar` BIGINT UNSIGNED NULL,
  `Icon` BIGINT UNSIGNED NULL,
  `IconFrame` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  `Name` VARCHAR(32) NULL,
  `Queue1Pos1` BIGINT UNSIGNED NULL,
  `Queue1Pos2` BIGINT UNSIGNED NULL,
  `Queue1Pos3` BIGINT UNSIGNED NULL,
  `Queue1Pos4` BIGINT UNSIGNED NULL,
  `Queue1Pos5` BIGINT UNSIGNED NULL,
  `Queue1Robot1` BIGINT UNSIGNED NULL,
  `Queue1Robot2` BIGINT UNSIGNED NULL,
  `Queue1Robot3` BIGINT UNSIGNED NULL,
  `Queue1Robot4` BIGINT UNSIGNED NULL,
  `Queue1Robot5` BIGINT UNSIGNED NULL,
  `Queue2Pos1` BIGINT UNSIGNED NULL,
  `Queue2Pos2` BIGINT UNSIGNED NULL,
  `Queue2Pos3` BIGINT UNSIGNED NULL,
  `Queue2Pos4` BIGINT UNSIGNED NULL,
  `Queue2Pos5` BIGINT UNSIGNED NULL,
  `Queue2Robot1` BIGINT UNSIGNED NULL,
  `Queue2Robot2` BIGINT UNSIGNED NULL,
  `Queue2Robot3` BIGINT UNSIGNED NULL,
  `Queue2Robot4` BIGINT UNSIGNED NULL,
  `Queue2Robot5` BIGINT UNSIGNED NULL,
  `RankMax` BIGINT UNSIGNED NULL,
  `RankMin` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7932a1d34bf1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RobotConfig
CREATE TABLE IF NOT EXISTS `game_cfg_robotconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `SkillDelay` DECIMAL(2,1) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f630a5b7ddb7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RobotHero
CREATE TABLE IF NOT EXISTS `game_cfg_robothero` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AwakenLevel` BIGINT UNSIGNED NULL,
  `BattlePower` BIGINT UNSIGNED NULL,
  `HeroId` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  `PRO_ARM` BIGINT UNSIGNED NULL,
  `PRO_ATK` BIGINT UNSIGNED NULL,
  `PRO_CRI` BIGINT UNSIGNED NULL,
  `PRO_DEF` BIGINT UNSIGNED NULL,
  `PRO_FLEE` BIGINT UNSIGNED NULL,
  `PRO_HIT` BIGINT UNSIGNED NULL,
  `PRO_IMP` BIGINT UNSIGNED NULL,
  `PRO_MAX_HP` BIGINT UNSIGNED NULL,
  `PRO_RES` BIGINT UNSIGNED NULL,
  `SoulRings` VARCHAR(58) NULL,
  `SoulSkillLevel` BIGINT UNSIGNED NULL,
  `StepsLevel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_0a0625580cc1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TeamRobot
CREATE TABLE IF NOT EXISTS `game_cfg_teamrobot` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattlePower` BIGINT UNSIGNED NULL,
  `Camp` BIGINT UNSIGNED NULL,
  `DefensiveRobot1` BIGINT UNSIGNED NULL,
  `DefensiveRobot2` BIGINT UNSIGNED NULL,
  `DefensiveRobot3` BIGINT UNSIGNED NULL,
  `DefensiveRobot4` BIGINT UNSIGNED NULL,
  `DefPos0` BIGINT UNSIGNED NULL,
  `DefPos1` BIGINT UNSIGNED NULL,
  `DefPos2` BIGINT UNSIGNED NULL,
  `DefPos3` BIGINT UNSIGNED NULL,
  `DefPos4` BIGINT UNSIGNED NULL,
  `Icon` BIGINT UNSIGNED NULL,
  `IconFrame` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  `LevelMax` BIGINT UNSIGNED NULL,
  `LevelMin` BIGINT UNSIGNED NULL,
  `Name` VARCHAR(32) NULL,
  `NatureRatio` DECIMAL(8,4) NULL,
  `RobotId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ac1d9d208008` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TeamRobotName
CREATE TABLE IF NOT EXISTS `game_cfg_teamrobotname` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Name` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_571424371b04` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RouletteConfig
CREATE TABLE IF NOT EXISTS `game_cfg_rouletteconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CostItem` VARCHAR(32) NULL,
  `RefreshCost` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_bd47ef4354f6` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RouletteItem
CREATE TABLE IF NOT EXISTS `game_cfg_rouletteitem` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ActionParam` BIGINT UNSIGNED NULL,
  `ActionType` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Pool` BIGINT UNSIGNED NULL,
  `RandomWeight` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `Score` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_123d95329852` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RouletteRankReward
CREATE TABLE IF NOT EXISTS `game_cfg_rouletterankreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Rank` VARCHAR(32) NULL,
  `Rewards` VARCHAR(34) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7bbce22cfcdf` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RouletteScoreReward
CREATE TABLE IF NOT EXISTS `game_cfg_roulettescorereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(51) NULL,
  `Score` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_41edbfc8c288` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: AnswerQuestionConfig
CREATE TABLE IF NOT EXISTS `game_cfg_answerquestionconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CountDownTime` BIGINT UNSIGNED NULL,
  `DelayTime` BIGINT UNSIGNED NULL,
  `Email` BIGINT UNSIGNED NULL,
  `EndTime` TIME NULL,
  `QuestionsNum` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_df4bc52e8a8b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: AnswerQuestionInfo
CREATE TABLE IF NOT EXISTS `game_cfg_answerquestioninfo` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `QuestionInfoId` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `RightAnswer` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_fa25f8a0d4a6` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SchoolConfig
CREATE TABLE IF NOT EXISTS `game_cfg_schoolconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BuffValidTime` TIME NULL,
  `RandomSchoolReward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_81b353f4497f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SchoolPoolGrowth
CREATE TABLE IF NOT EXISTS `game_cfg_schoolpoolgrowth` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CostItem` VARCHAR(32) NULL,
  `Growth` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ef035948f817` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SchoolPoolItem
CREATE TABLE IF NOT EXISTS `game_cfg_schoolpoolitem` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Desc` VARCHAR(32) NULL,
  `ShiLaiKe` VARCHAR(32) NULL,
  `TianDou` VARCHAR(32) NULL,
  `XingLuo` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_043bd7437074` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SchoolSpec
CREATE TABLE IF NOT EXISTS `game_cfg_schoolspec` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattlePower` BIGINT UNSIGNED NULL,
  `cehua` VARCHAR(32) NULL,
  `Param_1` BIGINT UNSIGNED NULL,
  `Param_2` BIGINT UNSIGNED NULL,
  `SpecType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7cc06aa8af81` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SchoolTask
CREATE TABLE IF NOT EXISTS `game_cfg_schooltask` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `OpenPanel` VARCHAR(37) NULL,
  `Period` TEXT NULL,
  `Reward` VARCHAR(40) NULL,
  `TaskParam` VARCHAR(32) NULL,
  `TaskType` BIGINT UNSIGNED NULL,
  `TimeType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7e39ef7bc89c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SchoolTaskPeriod
CREATE TABLE IF NOT EXISTS `game_cfg_schooltaskperiod` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `EndTime` DATETIME(6) NULL,
  `StartTime` DATETIME(6) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_fe236ea429bb` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SchoolTaskReward
CREATE TABLE IF NOT EXISTS `game_cfg_schooltaskreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Index` BIGINT UNSIGNED NULL,
  `Num` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `TaskFinishType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_fb58b7b4413c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: BingoBonus
CREATE TABLE IF NOT EXISTS `game_cfg_bingobonus` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AtlasName` VARCHAR(32) NULL,
  `Bonusfigure` VARCHAR(32) NULL,
  `BonusType` BIGINT UNSIGNED NULL,
  `color` BIGINT UNSIGNED NULL,
  `Icon` VARCHAR(32) NULL,
  `name` BIGINT UNSIGNED NULL,
  `Ratio` BIGINT UNSIGNED NULL,
  `Tire` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_0d44b53edf6a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: BingoDrop
CREATE TABLE IF NOT EXISTS `game_cfg_bingodrop` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `Notice` VARCHAR(91) NULL,
  `PropertyNum` BIGINT UNSIGNED NULL,
  `SoulBone` VARCHAR(58) NULL,
  `Tire` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_42c70ceb484a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: BingoDropIcon
CREATE TABLE IF NOT EXISTS `game_cfg_bingodropicon` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Icon` VARCHAR(35) NULL,
  `IconBG` VARCHAR(32) NULL,
  `name` VARCHAR(32) NULL,
  `Tire` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_fcc32b606107` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SecretArea
CREATE TABLE IF NOT EXISTS `game_cfg_secretarea` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  `Icon` VARCHAR(36) NULL,
  `IconBg` VARCHAR(32) NULL,
  `IsBoss` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `NextDungeon` BIGINT UNSIGNED NULL,
  `Statge` BIGINT UNSIGNED NULL,
  `TimeOut` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b8da6734f5f6` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SecretAreaConfig
CREATE TABLE IF NOT EXISTS `game_cfg_secretareaconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BonusPrice` BIGINT UNSIGNED NULL,
  `HuntingPrice` BIGINT UNSIGNED NULL,
  `SpeedUpLimitId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_81d8a9060435` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: BarrackList
CREATE TABLE IF NOT EXISTS `game_cfg_barracklist` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ip` VARCHAR(32) NULL,
  `name` BIGINT UNSIGNED NULL,
  `port` BIGINT UNSIGNED NULL,
  `serverId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f602d5efa0c4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: AllGlobalInfo
CREATE TABLE IF NOT EXISTS `game_cfg_allglobalinfo` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `globalIp` VARCHAR(32) NULL,
  `mainId` BIGINT UNSIGNED NULL,
  `subId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_afe04937eff2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: AnalysisServer
CREATE TABLE IF NOT EXISTS `game_cfg_analysisserver` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e8c05afb4cbf` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: BarrackServer
CREATE TABLE IF NOT EXISTS `game_cfg_barrackserver` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `clientIp` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a9adc775f02c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CrossServer
CREATE TABLE IF NOT EXISTS `game_cfg_crossserver` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_89689fd0af13` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GateServer
CREATE TABLE IF NOT EXISTS `game_cfg_gateserver` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `clientIp` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d0da0f216402` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GlobalServer
CREATE TABLE IF NOT EXISTS `game_cfg_globalserver` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `controlPort` BIGINT UNSIGNED NULL,
  `controlWord` VARCHAR(32) NULL,
  `customPort` BIGINT UNSIGNED NULL,
  `globalIp` VARCHAR(32) NULL,
  `mainId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6a7df57ff881` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ManagerServer
CREATE TABLE IF NOT EXISTS `game_cfg_managerserver` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4ca7a883cd30` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PayServer
CREATE TABLE IF NOT EXISTS `game_cfg_payserver` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `mainId` BIGINT UNSIGNED NULL,
  `mallPort` BIGINT UNSIGNED NULL,
  `payIp` VARCHAR(33) NULL,
  `payPort` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1dcdbb5fff1b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RelationServer
CREATE TABLE IF NOT EXISTS `game_cfg_relationserver` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_8c17e06a93bb` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ServerPort
CREATE TABLE IF NOT EXISTS `game_cfg_serverport` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AnalysisServer` BIGINT UNSIGNED NULL,
  `BarrackServer` BIGINT UNSIGNED NULL,
  `ClientPort` BIGINT UNSIGNED NULL,
  `CrossServer` BIGINT UNSIGNED NULL,
  `GateServer` BIGINT UNSIGNED NULL,
  `ManagerServer` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `PayServer` BIGINT UNSIGNED NULL,
  `RelationServer` BIGINT UNSIGNED NULL,
  `ZoneServer` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_07a1a6dcfadd` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ZoneServer
CREATE TABLE IF NOT EXISTS `game_cfg_zoneserver` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5b9fbd6fe366` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DBConfig
CREATE TABLE IF NOT EXISTS `game_cfg_dbconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `account` VARCHAR(32) NULL,
  `db` VARCHAR(32) NULL,
  `ip` VARCHAR(32) NULL,
  `name` VARCHAR(32) NULL,
  `password` TEXT NULL,
  `port` BIGINT UNSIGNED NULL,
  `threads` BIGINT UNSIGNED NULL,
  `type` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d6896bf870cf` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Http163Check
CREATE TABLE IF NOT EXISTS `game_cfg_http163check` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `businessId` VARCHAR(40) NULL,
  `checkOpen` BIGINT UNSIGNED NULL,
  `secretId` VARCHAR(40) NULL,
  `secretKey` VARCHAR(40) NULL,
  `textCheckUrl` VARCHAR(45) NULL,
  `timeout` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_2d62ba446218` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HttpSensitiveCheck
CREATE TABLE IF NOT EXISTS `game_cfg_httpsensitivecheck` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `checkOpen` BIGINT UNSIGNED NULL,
  `gamename` VARCHAR(32) NULL,
  `key` VARCHAR(32) NULL,
  `packageSerial` VARCHAR(32) NULL,
  `textCheckUrl` VARCHAR(65) NULL,
  `timeout` BIGINT UNSIGNED NULL,
  `token` TEXT NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_796c3e5a07e4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: KomoeLogConfig
CREATE TABLE IF NOT EXISTS `game_cfg_komoelogconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `gameBaseId` BIGINT UNSIGNED NULL,
  `gameId` BIGINT UNSIGNED NULL,
  `platform` VARCHAR(32) NULL,
  `RankTime` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_feb8cf2170dd` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Zone_1
CREATE TABLE IF NOT EXISTS `game_cfg_zone_1` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `channel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_da4ce763e90f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Zone_2
CREATE TABLE IF NOT EXISTS `game_cfg_zone_2` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `channel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ad16271532f9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Zone_3
CREATE TABLE IF NOT EXISTS `game_cfg_zone_3` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `channel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ea584fc5518f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Zone_4
CREATE TABLE IF NOT EXISTS `game_cfg_zone_4` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `channel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7622a6e6c341` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Zone_5
CREATE TABLE IF NOT EXISTS `game_cfg_zone_5` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `channel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f0d539c0efb2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Zone_6
CREATE TABLE IF NOT EXISTS `game_cfg_zone_6` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `channel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4ee1c4613dde` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Zone_7
CREATE TABLE IF NOT EXISTS `game_cfg_zone_7` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `channel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_049c4f1104a5` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Zone_8
CREATE TABLE IF NOT EXISTS `game_cfg_zone_8` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `channel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5eb0a0164570` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: NetworkGraph
CREATE TABLE IF NOT EXISTS `game_cfg_networkgraph` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AnalysisServer` VARCHAR(32) NULL,
  `BarrackServer` VARCHAR(32) NULL,
  `CrossServer` VARCHAR(32) NULL,
  `GateServer` VARCHAR(32) NULL,
  `GlobalServer` VARCHAR(32) NULL,
  `ManagerServer` VARCHAR(32) NULL,
  `name` VARCHAR(32) NULL,
  `PayServer` VARCHAR(32) NULL,
  `RelationServer` VARCHAR(32) NULL,
  `ZoneServer` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_34befc1609d7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PersistentConfig
CREATE TABLE IF NOT EXISTS `game_cfg_persistentconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AccountDB` BOOLEAN NULL,
  `CrossRedis` BOOLEAN NULL,
  `GameDB` BOOLEAN NULL,
  `GameRedis` BOOLEAN NULL,
  `LogDB` BOOLEAN NULL,
  `LossIntervene` BOOLEAN NULL,
  `MySql` BOOLEAN NULL,
  `name` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_166b8d09fbe6` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: RedisConfig
CREATE TABLE IF NOT EXISTS `game_cfg_redisconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `dbnum` BIGINT UNSIGNED NULL,
  `ip` VARCHAR(32) NULL,
  `name` VARCHAR(32) NULL,
  `password` TEXT NULL,
  `port` BIGINT UNSIGNED NULL,
  `threadcount` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ba65cc4a2326` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ServerList
CREATE TABLE IF NOT EXISTS `game_cfg_serverlist` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `crossGroup` BIGINT UNSIGNED NULL,
  `IsLineUp` BOOLEAN NULL,
  `IsMaintaining` BOOLEAN NULL,
  `IsNew` BIGINT UNSIGNED NULL,
  `isOpen` BIGINT UNSIGNED NULL,
  `IsRecommend` BOOLEAN NULL,
  `name` VARCHAR(32) NULL,
  `openTime` VARCHAR(32) NULL,
  `RecommendLimit` BIGINT UNSIGNED NULL,
  `RegistLimit` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_fcf5bad5b65d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CommonShop
CREATE TABLE IF NOT EXISTS `game_cfg_commonshop` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `CounterId` BIGINT UNSIGNED NULL,
  `GroupCount` VARCHAR(32) NULL,
  `IsRegular` BOOLEAN NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `RefreshCurrency` BIGINT UNSIGNED NULL,
  `RefreshFreq` BIGINT UNSIGNED NULL,
  `RefreshPrice` VARCHAR(48) NULL,
  `RefreshType` BIGINT UNSIGNED NULL,
  `ShowCurrency` VARCHAR(32) NULL,
  `ShowEnd` VARCHAR(32) NULL,
  `ShowStart` VARCHAR(32) NULL,
  `ShowWeekStart` TEXT NULL,
  `TimingId` BIGINT UNSIGNED NULL,
  `UseCoupon` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4807b29da2d2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: CouponItem
CREATE TABLE IF NOT EXISTS `game_cfg_couponitem` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `Discount` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3a9ba79994f0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Shop
CREATE TABLE IF NOT EXISTS `game_cfg_shop` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `NPCImage` VARCHAR(39) NULL,
  `RefeshCurrency` BIGINT UNSIGNED NULL,
  `RefreshPrice` VARCHAR(32) NULL,
  `RefreshTime` TEXT NULL,
  `ShopRefeshType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_55de88709232` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ShopConfig
CREATE TABLE IF NOT EXISTS `game_cfg_shopconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `EquipmentMaxQuality` BIGINT UNSIGNED NULL,
  `SoulBoneMaxQuality` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1e4cdd9255a9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ShopItemInfo
CREATE TABLE IF NOT EXISTS `game_cfg_shopiteminfo` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AccumulateDiamond` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `BuyLimit` BIGINT UNSIGNED NULL,
  `BuyLimitId` BIGINT UNSIGNED NULL,
  `BuyLimitType` BIGINT UNSIGNED NULL,
  `CurrentPrice` VARCHAR(32) NULL,
  `EndDate` DATETIME(6) NULL,
  `GroupType` BIGINT UNSIGNED NULL,
  `HeroId` BIGINT UNSIGNED NULL,
  `MaxBattlePower` BIGINT UNSIGNED NULL,
  `MaxCount` BIGINT UNSIGNED NULL,
  `MaxQuality` BIGINT UNSIGNED NULL,
  `MinBattlePower` BIGINT UNSIGNED NULL,
  `MinQuality` BIGINT UNSIGNED NULL,
  `Order` BIGINT UNSIGNED NULL,
  `OriginalPrice` VARCHAR(32) NULL,
  `Reward` VARCHAR(32) NULL,
  `ShopType` BIGINT UNSIGNED NULL,
  `SpecialId` BIGINT UNSIGNED NULL,
  `StartDate` DATETIME(6) NULL,
  `SubScriptType` BIGINT UNSIGNED NULL,
  `TaskId` BIGINT UNSIGNED NULL,
  `TimingGiftType` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_97d6ff8b9417` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: JjgsawPuzzlePieces
CREATE TABLE IF NOT EXISTS `game_cfg_jjgsawpuzzlepieces` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Extra` BIGINT UNSIGNED NULL,
  `Index` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c34980b12e23` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PassCheckPointRewards
CREATE TABLE IF NOT EXISTS `game_cfg_passcheckpointrewards` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Quality` BIGINT UNSIGNED NULL,
  `Rewards` VARCHAR(34) NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f5f5646bf577` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ShovelRewards
CREATE TABLE IF NOT EXISTS `game_cfg_shovelrewards` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Atlas` VARCHAR(32) NULL,
  `Icon` VARCHAR(34) NULL,
  `Quality` BIGINT UNSIGNED NULL,
  `Rewards` VARCHAR(32) NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7acd54824dd5` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ShovelTreasureConfig
CREATE TABLE IF NOT EXISTS `game_cfg_shoveltreasureconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `GameReviveDiamond` BIGINT UNSIGNED NULL,
  `GameReviveDiamondDiff` BIGINT UNSIGNED NULL,
  `GameRewardMaxCount` BIGINT UNSIGNED NULL,
  `HighTrerasureMap` BIGINT UNSIGNED NULL,
  `PuzzleCost` BIGINT UNSIGNED NULL,
  `PuzzleFinishCount` BIGINT UNSIGNED NULL,
  `PuzzleItemId` BIGINT UNSIGNED NULL,
  `TreasureGameTime` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a114e2e0196c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ShovelTreasureGame
CREATE TABLE IF NOT EXISTS `game_cfg_shoveltreasuregame` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Quality` BIGINT UNSIGNED NULL,
  `RewardsCnt` BIGINT UNSIGNED NULL,
  `StartRewards` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ed91ae8a5669` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TreasurePuzzleReward
CREATE TABLE IF NOT EXISTS `game_cfg_treasurepuzzlereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(36) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_8727de5f5ff5` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ShreklandConfig
CREATE TABLE IF NOT EXISTS `game_cfg_shreklandconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ControlItem` BIGINT UNSIGNED NULL,
  `DoubleItem` BIGINT UNSIGNED NULL,
  `GridNum` BIGINT UNSIGNED NULL,
  `MaxRewardLevel` BIGINT UNSIGNED NULL,
  `MaxRewardType` BIGINT UNSIGNED NULL,
  `NormalItemCost` BIGINT UNSIGNED NULL,
  `RefreshCost` BIGINT UNSIGNED NULL,
  `StepNum` VARCHAR(32) NULL,
  `TrebleItem` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d4dfaec75680` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ShreklandRandReward
CREATE TABLE IF NOT EXISTS `game_cfg_shreklandrandreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `LevelUpRewardId` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `RewardType` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b0a5061a79d4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ShreklandRewardLevel
CREATE TABLE IF NOT EXISTS `game_cfg_shreklandrewardlevel` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `OnceScore` BIGINT UNSIGNED NULL,
  `RewardType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5cd06f3da16c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ShreklandScoreReward
CREATE TABLE IF NOT EXISTS `game_cfg_shreklandscorereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ClientReward` VARCHAR(52) NULL,
  `IsHighScore` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(52) NULL,
  `Score` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9fdf3dd2f0b0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Skill
CREATE TABLE IF NOT EXISTS `game_cfg_skill` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddEnergy` BIGINT UNSIGNED NULL,
  `Alarm` BIGINT UNSIGNED NULL,
  `Atlas` VARCHAR(32) NULL,
  `BattlePower` DECIMAL(5,2) NULL,
  `CastedByOwner` BIGINT UNSIGNED NULL,
  `CastRange` DECIMAL(3,1) NULL,
  `CEHUA` VARCHAR(117) NULL,
  `DelayTime` BIGINT UNSIGNED NULL,
  `DuringTime` DECIMAL(6,3) NULL,
  `EffectCount` BIGINT UNSIGNED NULL,
  `EffectList` VARCHAR(48) NULL,
  `EffectTime` DECIMAL(4,3) NULL,
  `EndAnimTime` DECIMAL(5,3) NULL,
  `Energy` BIGINT UNSIGNED NULL,
  `Icon` VARCHAR(36) NULL,
  `InitEnergy` BIGINT UNSIGNED NULL,
  `IsDomainSkill` VARCHAR(32) NULL,
  `IsShowInPanel` BIGINT UNSIGNED NULL,
  `MultipleTime` VARCHAR(43) NULL,
  `name` VARCHAR(32) NULL,
  `PositionFilterType` BIGINT UNSIGNED NULL,
  `PositionType` BIGINT UNSIGNED NULL,
  `Priority` BIGINT UNSIGNED NULL,
  `SkillPosRange` DECIMAL(3,1) NULL,
  `SoulRingPos` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ec9f630c8693` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SkillEffect
CREATE TABLE IF NOT EXISTS `game_cfg_skilleffect` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AfterEventParam` BIGINT UNSIGNED NULL,
  `AfterEventParam_2` BIGINT UNSIGNED NULL,
  `AfterEventType` BIGINT UNSIGNED NULL,
  `AfterProbability` BIGINT UNSIGNED NULL,
  `Alarm` BIGINT UNSIGNED NULL,
  `Alive` BOOLEAN NULL,
  `B` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(117) NULL,
  `ContainTarget` BOOLEAN NULL,
  `DoDamage` BOOLEAN NULL,
  `FixedPos` VARCHAR(32) NULL,
  `K` DECIMAL(6,1) NULL,
  `MultipleT` VARCHAR(63) NULL,
  `MustHit` BOOLEAN NULL,
  `name` VARCHAR(32) NULL,
  `Pan` BIGINT UNSIGNED NULL,
  `Range` DECIMAL(3,1) NULL,
  `SplashType` BIGINT UNSIGNED NULL,
  `StartType` BIGINT UNSIGNED NULL,
  `T` DECIMAL(6,4) NULL,
  `TargetFilterType` BIGINT UNSIGNED NULL,
  `TargetMaxCount` BIGINT UNSIGNED NULL,
  `TargetType` BIGINT UNSIGNED NULL,
  `Width` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e3e90fd781b7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SkillEffectEnhancePolicy
CREATE TABLE IF NOT EXISTS `game_cfg_skilleffectenhancepolicy` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BasicEffectId` BIGINT UNSIGNED NULL,
  `Condition` BIGINT UNSIGNED NULL,
  `EnhanceEffectId` BIGINT UNSIGNED NULL,
  `EnhanceParam` BIGINT UNSIGNED NULL,
  `name` BIGINT UNSIGNED NULL,
  `OnlyAfterEvent` BOOLEAN NULL,
  `ReplaceAfterEvent` BOOLEAN NULL,
  `SkillId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d9a2fc23484a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SkillGrowth
CREATE TABLE IF NOT EXISTS `game_cfg_skillgrowth` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattlePowerFactor` BIGINT UNSIGNED NULL,
  `Growth` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5b6e239604c4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulBoneAffix
CREATE TABLE IF NOT EXISTS `game_cfg_soulboneaffix` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `affixNum` BIGINT UNSIGNED NULL,
  `color` BIGINT UNSIGNED NULL,
  `nameId` BIGINT UNSIGNED NULL,
  `num` BIGINT UNSIGNED NULL,
  `section` VARCHAR(32) NULL,
  `SmeltReward` VARCHAR(32) NULL,
  `SpecialNum` BIGINT UNSIGNED NULL,
  `SpecSubTypeRange` VARCHAR(232) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3454156a5424` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulBoneAnimal
CREATE TABLE IF NOT EXISTS `game_cfg_soulboneanimal` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `job` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_feff5467d85f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulBoneBodyPart
CREATE TABLE IF NOT EXISTS `game_cfg_soulbonebodypart` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1c909673b088` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulBoneDrop
CREATE TABLE IF NOT EXISTS `game_cfg_soulbonedrop` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `rule` VARCHAR(32) NULL,
  `SpecList` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c024ba22b29c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulBoneItems
CREATE TABLE IF NOT EXISTS `game_cfg_soulboneitems` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `addiProperty1` BIGINT UNSIGNED NULL,
  `addiProperty2` BIGINT UNSIGNED NULL,
  `addiProperty3` BIGINT UNSIGNED NULL,
  `animalType` BIGINT UNSIGNED NULL,
  `atlas` VARCHAR(32) NULL,
  `CEHUA` VARCHAR(34) NULL,
  `Color` BIGINT UNSIGNED NULL,
  `Icon` VARCHAR(32) NULL,
  `ItemEffName` VARCHAR(33) NULL,
  `jobLimit` BIGINT UNSIGNED NULL,
  `mainProperty` BIGINT UNSIGNED NULL,
  `mainPropertyRange` VARCHAR(32) NULL,
  `order` BIGINT UNSIGNED NULL,
  `position` BIGINT UNSIGNED NULL,
  `SpecMainType` VARCHAR(110) NULL,
  `SpecSkill` VARCHAR(48) NULL,
  `titleLimit` BIGINT UNSIGNED NULL,
  `WearAble` BOOLEAN NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_971429714608` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulBoneSmeltCost
CREATE TABLE IF NOT EXISTS `game_cfg_soulbonesmeltcost` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `color` BIGINT UNSIGNED NULL,
  `cost` BIGINT UNSIGNED NULL,
  `section` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1bb9221311b9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulBoneSpec
CREATE TABLE IF NOT EXISTS `game_cfg_soulbonespec` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattlePower` BIGINT UNSIGNED NULL,
  `Cehua` VARCHAR(55) NULL,
  `MainType` BIGINT UNSIGNED NULL,
  `Param_1` BIGINT UNSIGNED NULL,
  `Param_2` BIGINT UNSIGNED NULL,
  `Quality` BIGINT UNSIGNED NULL,
  `SpecType` BIGINT UNSIGNED NULL,
  `SubType` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_20040a06dc91` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulBoneSuit
CREATE TABLE IF NOT EXISTS `game_cfg_soulbonesuit` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `natureType` VARCHAR(32) NULL,
  `param` VARCHAR(32) NULL,
  `partCount` BIGINT UNSIGNED NULL,
  `section` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7da9a77f645b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulBoneSuit2
CREATE TABLE IF NOT EXISTS `game_cfg_soulbonesuit2` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `affix` BIGINT UNSIGNED NULL,
  `animal` BIGINT UNSIGNED NULL,
  `Color` BIGINT UNSIGNED NULL,
  `natureType` VARCHAR(32) NULL,
  `param` BIGINT UNSIGNED NULL,
  `partCount` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d1e1009d4ef0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulRing
CREATE TABLE IF NOT EXISTS `game_cfg_soulring` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AdditionalNature` VARCHAR(32) NULL,
  `Atlas` VARCHAR(32) NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Color` BIGINT UNSIGNED NULL,
  `Element` VARCHAR(32) NULL,
  `Grade` BIGINT UNSIGNED NULL,
  `HuntingBaseId` BIGINT UNSIGNED NULL,
  `Icon` VARCHAR(32) NULL,
  `IconBG` VARCHAR(32) NULL,
  `IniLevel` BIGINT UNSIGNED NULL,
  `ItemEffName` VARCHAR(32) NULL,
  `MainAttrType` VARCHAR(34) NULL,
  `MainType` BIGINT UNSIGNED NULL,
  `MaxYear` BIGINT UNSIGNED NULL,
  `Order` BIGINT UNSIGNED NULL,
  `SoulRingType` BIGINT UNSIGNED NULL,
  `SPAttrType` BIGINT UNSIGNED NULL,
  `SubType` BIGINT UNSIGNED NULL,
  `UltAttrType` VARCHAR(32) NULL,
  `UltAttrValue` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f4540998824a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulRingAbsorbTime
CREATE TABLE IF NOT EXISTS `game_cfg_soulringabsorbtime` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AbsorbTime` BIGINT UNSIGNED NULL,
  `Max` BIGINT UNSIGNED NULL,
  `Min` BIGINT UNSIGNED NULL,
  `Name` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_dea5f5f741fd` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulRingAdditionalNatrue
CREATE TABLE IF NOT EXISTS `game_cfg_soulringadditionalnatrue` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BattlePower` BIGINT UNSIGNED NULL,
  `NatureType` BIGINT UNSIGNED NULL,
  `Ratio` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5f1ff771691c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulRingBasicAttribute
CREATE TABLE IF NOT EXISTS `game_cfg_soulringbasicattribute` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `PRO_AGI` BIGINT UNSIGNED NULL,
  `PRO_ARM` DECIMAL(4,3) NULL,
  `PRO_ATK` DECIMAL(4,3) NULL,
  `PRO_CON` BIGINT UNSIGNED NULL,
  `PRO_CRI` DECIMAL(4,3) NULL,
  `PRO_DEF` DECIMAL(3,2) NULL,
  `PRO_EXP` BIGINT UNSIGNED NULL,
  `PRO_FLEE` DECIMAL(4,3) NULL,
  `PRO_HIT` DECIMAL(4,3) NULL,
  `PRO_IMP` DECIMAL(4,3) NULL,
  `PRO_MAX_HP` DECIMAL(4,3) NULL,
  `PRO_POW` BIGINT UNSIGNED NULL,
  `PRO_RES` DECIMAL(4,3) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_67ca3fa90d9b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulRingBasicNatureIncreasement
CREATE TABLE IF NOT EXISTS `game_cfg_soulringbasicnatureincreasement` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `PRO_ARM` DECIMAL(8,2) NULL,
  `PRO_ATK` DECIMAL(8,2) NULL,
  `PRO_CRI` DECIMAL(8,2) NULL,
  `PRO_DEF` DECIMAL(8,2) NULL,
  `PRO_FLEE` DECIMAL(8,2) NULL,
  `PRO_HIT` DECIMAL(8,2) NULL,
  `PRO_IMP` DECIMAL(8,2) NULL,
  `PRO_MAX_HP` DECIMAL(8,2) NULL,
  `PRO_RES` DECIMAL(8,2) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_70001ef53628` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulRingBreak
CREATE TABLE IF NOT EXISTS `game_cfg_soulringbreak` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BreathCost` BIGINT UNSIGNED NULL,
  `GoldCost` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_883e5551aeb4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulRingConfig
CREATE TABLE IF NOT EXISTS `game_cfg_soulringconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AbsorbHelperMaxCount` BIGINT UNSIGNED NULL,
  `AbsorbHelpMinTime` BIGINT UNSIGNED NULL,
  `AbsorbTime` VARCHAR(51) NULL,
  `AdditionalNatureYearLimit` VARCHAR(32) NULL,
  `ElementYearLimit` BIGINT UNSIGNED NULL,
  `Name` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_90d47b8c8504` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulRingEffect
CREATE TABLE IF NOT EXISTS `game_cfg_soulringeffect` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9cc3980b99ba` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulRingElement
CREATE TABLE IF NOT EXISTS `game_cfg_soulringelement` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Param_1` BIGINT UNSIGNED NULL,
  `Param_2` VARCHAR(32) NULL,
  `SpecType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_59784a219726` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulRingElementBattlePower
CREATE TABLE IF NOT EXISTS `game_cfg_soulringelementbattlepower` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `SoulRingElementBattlePowerFactor` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_eeeaf5fd77b2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulRingEnhance
CREATE TABLE IF NOT EXISTS `game_cfg_soulringenhance` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DustCost` BIGINT UNSIGNED NULL,
  `GoldCost` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_53d9cf3d0e24` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulRingRevert
CREATE TABLE IF NOT EXISTS `game_cfg_soulringrevert` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6fd02570bb50` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulRingSlotUnlock
CREATE TABLE IF NOT EXISTS `game_cfg_soulringslotunlock` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AwakeLevel` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Level` BIGINT UNSIGNED NULL,
  `MaxYear` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_436099ecf21d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulRingSpec
CREATE TABLE IF NOT EXISTS `game_cfg_soulringspec` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Param_1` BIGINT UNSIGNED NULL,
  `Param_2` VARCHAR(32) NULL,
  `SpecType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c2f5f2b2974a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulSkillBasicNatureIncreasement
CREATE TABLE IF NOT EXISTS `game_cfg_soulskillbasicnatureincreasement` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `PRO_ARM` BIGINT UNSIGNED NULL,
  `PRO_ATK` BIGINT UNSIGNED NULL,
  `PRO_CRI` BIGINT UNSIGNED NULL,
  `PRO_DEF` BIGINT UNSIGNED NULL,
  `PRO_FLEE` BIGINT UNSIGNED NULL,
  `PRO_HIT` BIGINT UNSIGNED NULL,
  `PRO_IMP` BIGINT UNSIGNED NULL,
  `PRO_MAX_HP` BIGINT UNSIGNED NULL,
  `PRO_RES` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_0e9024107f82` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulSkillBreak
CREATE TABLE IF NOT EXISTS `game_cfg_soulskillbreak` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BreathCost` BIGINT UNSIGNED NULL,
  `GoldCost` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_88b2271818b7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulSkillConfig
CREATE TABLE IF NOT EXISTS `game_cfg_soulskillconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `soul_skill_level_max` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_88de253d3412` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulSkillEnhance
CREATE TABLE IF NOT EXISTS `game_cfg_soulskillenhance` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DustCost` BIGINT UNSIGNED NULL,
  `GoldCost` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5aa57b376c76` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SoulSkillLevel
CREATE TABLE IF NOT EXISTS `game_cfg_soulskilllevel` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `herolevel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f8d9aab407c0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PopConfig
CREATE TABLE IF NOT EXISTS `game_cfg_popconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `FlowerScore` BIGINT UNSIGNED NULL,
  `LikeSpaceScore` BIGINT UNSIGNED NULL,
  `PopRankCount` BIGINT UNSIGNED NULL,
  `RankPerPage` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_20e9fc602bea` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GuideSoulEffect
CREATE TABLE IF NOT EXISTS `game_cfg_guidesouleffect` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `cehua` VARCHAR(32) NULL,
  `Param_1` BIGINT UNSIGNED NULL,
  `SpecType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6873c0bb4dba` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: GuideSoulItems
CREATE TABLE IF NOT EXISTS `game_cfg_guidesoulitems` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `EffectCount` BIGINT UNSIGNED NULL,
  `EffectIdList` BIGINT UNSIGNED NULL,
  `SpaceTimeCoinRewards` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c399e41f50fc` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SpaceTimeHeroNature
CREATE TABLE IF NOT EXISTS `game_cfg_spacetimeheronature` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `PRO_ARM` BIGINT UNSIGNED NULL,
  `PRO_ATK` BIGINT UNSIGNED NULL,
  `PRO_CRI` BIGINT UNSIGNED NULL,
  `PRO_DEF` BIGINT UNSIGNED NULL,
  `PRO_FLEE` BIGINT UNSIGNED NULL,
  `PRO_HIT` BIGINT UNSIGNED NULL,
  `PRO_IMP` BIGINT UNSIGNED NULL,
  `PRO_MAX_HP` BIGINT UNSIGNED NULL,
  `PRO_MUL_CRI` BIGINT UNSIGNED NULL,
  `PRO_RES` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_2fff12fa817f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SpaceTimeHeroRandom
CREATE TABLE IF NOT EXISTS `game_cfg_spacetimeherorandom` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `GroupId` BIGINT UNSIGNED NULL,
  `HeroId` BIGINT UNSIGNED NULL,
  `Week` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_0cd06772e856` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SpaceTimeHeroStepGrowth
CREATE TABLE IF NOT EXISTS `game_cfg_spacetimeherostepgrowth` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `StepsC` BIGINT UNSIGNED NULL,
  `StepsLevel` BIGINT UNSIGNED NULL,
  `StepsS` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c90923ed4c07` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SpaceTimeHeroStepNature
CREATE TABLE IF NOT EXISTS `game_cfg_spacetimeherostepnature` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CardQuality` BIGINT UNSIGNED NULL,
  `PRO_ARM` BIGINT UNSIGNED NULL,
  `PRO_ATK` BIGINT UNSIGNED NULL,
  `PRO_CRI` BIGINT UNSIGNED NULL,
  `PRO_DEF` BIGINT UNSIGNED NULL,
  `PRO_FLEE` BIGINT UNSIGNED NULL,
  `PRO_HIT` BIGINT UNSIGNED NULL,
  `PRO_IMP` BIGINT UNSIGNED NULL,
  `PRO_MAX_HP` BIGINT UNSIGNED NULL,
  `PRO_RES` BIGINT UNSIGNED NULL,
  `StepsLevel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4a95046f9ae9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SpaceTimeMonsterNatureGrowth
CREATE TABLE IF NOT EXISTS `game_cfg_spacetimemonsternaturegrowth` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Growth` DECIMAL(5,2) NULL,
  `Period` BIGINT UNSIGNED NULL,
  `TowerLevel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_cb798250bcda` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SpaceTimeRecycleHeroReward
CREATE TABLE IF NOT EXISTS `game_cfg_spacetimerecycleheroreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `NHeroRewards` VARCHAR(32) NULL,
  `RHeroRewards` VARCHAR(32) NULL,
  `SRHeroRewards` VARCHAR(32) NULL,
  `SSRHeroRewards` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_47e178cf3a36` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SpaceTimeTowerConfig
CREATE TABLE IF NOT EXISTS `game_cfg_spacetimetowerconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BuyExpendType` BIGINT UNSIGNED NULL,
  `ChallengeMaxCount` BIGINT UNSIGNED NULL,
  `DropRewards` VARCHAR(76) NULL,
  `GrowthEffectMonsterNatures` VARCHAR(34) NULL,
  `HeroLevel` BIGINT UNSIGNED NULL,
  `HeroMaxNum` BIGINT UNSIGNED NULL,
  `InitSpaceTimeCoins` BIGINT UNSIGNED NULL,
  `MonsterDifficultyLimit` BIGINT UNSIGNED NULL,
  `OpenDays` BIGINT UNSIGNED NULL,
  `RefreshCardPoolExpend` VARCHAR(32) NULL,
  `RefreshCardPoolMaxNum` BIGINT UNSIGNED NULL,
  `RefreshHeroMaxNum` BIGINT UNSIGNED NULL,
  `SoulRingSkillLevel` BIGINT UNSIGNED NULL,
  `StartDateTime` VARCHAR(32) NULL,
  `StartWeekDay` BIGINT UNSIGNED NULL,
  `StartWeekTime` TIME NULL,
  `StepInitLevel` BIGINT UNSIGNED NULL,
  `StepMaxLevel` BIGINT UNSIGNED NULL,
  `TowerMaxLevel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_bc9b664cffa7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SpaceTimeTowerLevel
CREATE TABLE IF NOT EXISTS `game_cfg_spacetimetowerlevel` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BeastSettlementId` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `EventType` VARCHAR(32) NULL,
  `HeroQualityWeight` VARCHAR(35) NULL,
  `HouseId` BIGINT UNSIGNED NULL,
  `RandomDungeon` VARCHAR(86) NULL,
  `ShopId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7923be95988e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SpaceTimeTowerPastRewards
CREATE TABLE IF NOT EXISTS `game_cfg_spacetimetowerpastrewards` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Rewards` VARCHAR(52) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3c20231802d1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SpaceTimeTowerProduct
CREATE TABLE IF NOT EXISTS `game_cfg_spacetimetowerproduct` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Desc` VARCHAR(55) NULL,
  `Expend` BIGINT UNSIGNED NULL,
  `FuncParam` VARCHAR(168) NULL,
  `HouseMaxUseNum` BIGINT UNSIGNED NULL,
  `ProductType` BIGINT UNSIGNED NULL,
  `ShopMaxBuyNum` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c1f452f3ab2b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SpaceTimeTowerShop
CREATE TABLE IF NOT EXISTS `game_cfg_spacetimetowershop` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CeHua` VARCHAR(32) NULL,
  `HouseFilledProducts` VARCHAR(32) NULL,
  `ProductId` VARCHAR(168) NULL,
  `RandomNum` BIGINT UNSIGNED NULL,
  `ShopType` BIGINT UNSIGNED NULL,
  `Weight` VARCHAR(211) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_bf22695adcef` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: SpaceTimeTowerStageAward
CREATE TABLE IF NOT EXISTS `game_cfg_spacetimetowerstageaward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `award` VARCHAR(38) NULL,
  `page` BIGINT UNSIGNED NULL,
  `stage` BIGINT UNSIGNED NULL,
  `tier` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_28391eb9599c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: StoneWall
CREATE TABLE IF NOT EXISTS `game_cfg_stonewall` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AddRatio` VARCHAR(32) NULL,
  `Announce` VARCHAR(32) NULL,
  `BuyMaxCount` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `ClientShow` VARCHAR(57) NULL,
  `ConfigType` BIGINT UNSIGNED NULL,
  `CostDiamond` BIGINT UNSIGNED NULL,
  `CostItem` BIGINT UNSIGNED NULL,
  `CostItemCount` BIGINT UNSIGNED NULL,
  `FirstEmail` BIGINT UNSIGNED NULL,
  `FirstReward` VARCHAR(32) NULL,
  `luckilyEmail` BIGINT UNSIGNED NULL,
  `luckilyReward` VARCHAR(32) NULL,
  `MaxValue` BIGINT UNSIGNED NULL,
  `Notes` VARCHAR(32) NULL,
  `NotesId` BIGINT UNSIGNED NULL,
  `NotesTime` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(80) NULL,
  `RewardStar` VARCHAR(32) NULL,
  `ShowCurrency` VARCHAR(32) NULL,
  `ShowReward` VARCHAR(90) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b94c1353e4f4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: StoneWallLimit
CREATE TABLE IF NOT EXISTS `game_cfg_stonewalllimit` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `MaxColumn` BIGINT UNSIGNED NULL,
  `MaxLine` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c484ee8c115c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: StoneWallReward
CREATE TABLE IF NOT EXISTS `game_cfg_stonewallreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Parem` VARCHAR(32) NULL,
  `RewardId` BIGINT UNSIGNED NULL,
  `ShowReward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6235ef5e9870` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: StoneWallRewardPreview
CREATE TABLE IF NOT EXISTS `game_cfg_stonewallrewardpreview` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `ShowReward` VARCHAR(92) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_2d88b3a69030` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: StoneWallUnlockReward
CREATE TABLE IF NOT EXISTS `game_cfg_stonewallunlockreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Column` BIGINT UNSIGNED NULL,
  `FinalReward` BIGINT UNSIGNED NULL,
  `Line` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1215c74e2ca1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ChapterLevelLimit
CREATE TABLE IF NOT EXISTS `game_cfg_chapterlevellimit` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `levelLimit` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c6b47480051e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: PowerConfig
CREATE TABLE IF NOT EXISTS `game_cfg_powerconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Firstlevel` BIGINT UNSIGNED NULL,
  `GiveCount` BIGINT UNSIGNED NULL,
  `PowerLimit` VARCHAR(32) NULL,
  `Recover` BIGINT UNSIGNED NULL,
  `TaskId` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c4be9143e130` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: StoryLine
CREATE TABLE IF NOT EXISTS `game_cfg_storyline` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Cehua` VARCHAR(32) NULL,
  `Chapter` BIGINT UNSIGNED NULL,
  `DungeonAtlasName` VARCHAR(32) NULL,
  `DungeonIcon` VARCHAR(35) NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  `Function_atlas` VARCHAR(32) NULL,
  `Function_highlightIcon` VARCHAR(35) NULL,
  `Function_icon` VARCHAR(35) NULL,
  `Reward` VARCHAR(32) NULL,
  `TaskChain` BIGINT UNSIGNED NULL,
  `TaskId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_8755f9b18fb8` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: StoryReward
CREATE TABLE IF NOT EXISTS `game_cfg_storyreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Chapter` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `Order` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `TaskId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7f1cbf0925eb` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: WorldLevel
CREATE TABLE IF NOT EXISTS `game_cfg_worldlevel` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Chapter` BIGINT UNSIGNED NULL,
  `Day` BIGINT UNSIGNED NULL,
  `name` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_983b48d560b2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: OptionTaskEmotion
CREATE TABLE IF NOT EXISTS `game_cfg_optiontaskemotion` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Option1Dialogue` BIGINT UNSIGNED NULL,
  `Option2Dialogue` BIGINT UNSIGNED NULL,
  `Option3Dialogue` BIGINT UNSIGNED NULL,
  `Option4Dialogue` BIGINT UNSIGNED NULL,
  `OptionDialogue` BIGINT UNSIGNED NULL,
  `TurnToTask1` BIGINT UNSIGNED NULL,
  `TurnToTask2` BIGINT UNSIGNED NULL,
  `TurnToTask3` TEXT NULL,
  `TurnToTask4` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1dface51a0a0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Task
CREATE TABLE IF NOT EXISTS `game_cfg_task` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BranchTasks` VARCHAR(39) NULL,
  `CompleteNpcId` BIGINT UNSIGNED NULL,
  `CompletePercentage` BIGINT UNSIGNED NULL,
  `CompleteVanishNPC` BIGINT UNSIGNED NULL,
  `CurrentStep` BIGINT UNSIGNED NULL,
  `DetailReward` VARCHAR(98) NULL,
  `DoTaskNpcId` BIGINT UNSIGNED NULL,
  `IsAutoOpen` BIGINT UNSIGNED NULL,
  `IsOpenChapter` VARCHAR(32) NULL,
  `IsOpenComplete` BIGINT UNSIGNED NULL,
  `IsShowNum` BIGINT UNSIGNED NULL,
  `MainType` BIGINT UNSIGNED NULL,
  `NetOpenPanel` VARCHAR(32) NULL,
  `OpenPanel` VARCHAR(40) NULL,
  `ProgPrama` VARCHAR(39) NULL,
  `ProgType` BIGINT UNSIGNED NULL,
  `TaskChain` BIGINT UNSIGNED NULL,
  `TaskFly` BOOLEAN NULL,
  `TaskSubChain` BIGINT UNSIGNED NULL,
  `TextEmotion` BIGINT UNSIGNED NULL,
  `TotalStep` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7bb0ddf9221c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TaskChapter
CREATE TABLE IF NOT EXISTS `game_cfg_taskchapter` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Chapter` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_0a5b58d9a553` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TaskFinishReward
CREATE TABLE IF NOT EXISTS `game_cfg_taskfinishreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Index` BIGINT UNSIGNED NULL,
  `Num` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(34) NULL,
  `TaskFinishType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c2a0a7360198` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TaskFinshRewardPeriod
CREATE TABLE IF NOT EXISTS `game_cfg_taskfinshrewardperiod` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `EndTime` DATETIME(6) NULL,
  `StartTime` DATETIME(6) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_432b7651dad0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TextEmotion_Option
CREATE TABLE IF NOT EXISTS `game_cfg_textemotion_option` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `emotion_id` BIGINT UNSIGNED NULL,
  `is_true` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b165f0e39e5f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossBuff
CREATE TABLE IF NOT EXISTS `game_cfg_themebossbuff` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Buff` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f40892dc8650` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossBuffTime
CREATE TABLE IF NOT EXISTS `game_cfg_themebossbufftime` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `EndTime` TIME NULL,
  `StartTime` TIME NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d886fee7dd16` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossConfig
CREATE TABLE IF NOT EXISTS `game_cfg_themebossconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `MaxDegree` BIGINT UNSIGNED NULL,
  `RankRewardCount` BIGINT UNSIGNED NULL,
  `ThemeQueueCount` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_2b85e2587c39` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossDungeon_1
CREATE TABLE IF NOT EXISTS `game_cfg_themebossdungeon_1` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9f94f5738e2b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossDungeon_10
CREATE TABLE IF NOT EXISTS `game_cfg_themebossdungeon_10` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4783a558c96e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossDungeon_11
CREATE TABLE IF NOT EXISTS `game_cfg_themebossdungeon_11` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_39391baa114d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossDungeon_12
CREATE TABLE IF NOT EXISTS `game_cfg_themebossdungeon_12` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5b4f22b33712` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossDungeon_2
CREATE TABLE IF NOT EXISTS `game_cfg_themebossdungeon_2` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9819ca850cfb` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossDungeon_3
CREATE TABLE IF NOT EXISTS `game_cfg_themebossdungeon_3` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_95bd60715612` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossDungeon_4
CREATE TABLE IF NOT EXISTS `game_cfg_themebossdungeon_4` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6505a7faba47` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossDungeon_5
CREATE TABLE IF NOT EXISTS `game_cfg_themebossdungeon_5` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5f77de65fbbe` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossDungeon_6
CREATE TABLE IF NOT EXISTS `game_cfg_themebossdungeon_6` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c23f30ec9958` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossDungeon_7
CREATE TABLE IF NOT EXISTS `game_cfg_themebossdungeon_7` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_26a7aa12d21a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossDungeon_8
CREATE TABLE IF NOT EXISTS `game_cfg_themebossdungeon_8` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b3d1c1ec1f9b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossDungeon_9
CREATE TABLE IF NOT EXISTS `game_cfg_themebossdungeon_9` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DungeonId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_fe9949076ecd` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ชุดข้อมูล configuration: ThemeBossRankReward
CREATE TABLE IF NOT EXISTS `game_cfg_themebossrankreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Rank` VARCHAR(32) NULL,
  `RankMax` BIGINT UNSIGNED NULL,
  `RankMin` BIGINT UNSIGNED NULL,
  `Rewards` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_43cc98fd89c5` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossReward_1
CREATE TABLE IF NOT EXISTS `game_cfg_themebossreward_1` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Degree` VARCHAR(32) NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(67) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_61bc37b1e949` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossReward_10
CREATE TABLE IF NOT EXISTS `game_cfg_themebossreward_10` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Degree` VARCHAR(32) NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(68) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4aab2236ee49` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossReward_11
CREATE TABLE IF NOT EXISTS `game_cfg_themebossreward_11` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Degree` VARCHAR(32) NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(68) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_89cd73bff4a2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossReward_12
CREATE TABLE IF NOT EXISTS `game_cfg_themebossreward_12` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Degree` VARCHAR(32) NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(68) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_2665e4e257d7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossReward_2
CREATE TABLE IF NOT EXISTS `game_cfg_themebossreward_2` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Degree` VARCHAR(32) NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(67) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_209aecc5a86f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossReward_3
CREATE TABLE IF NOT EXISTS `game_cfg_themebossreward_3` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Degree` VARCHAR(32) NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(67) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1d71140102bd` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossReward_4
CREATE TABLE IF NOT EXISTS `game_cfg_themebossreward_4` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Degree` VARCHAR(32) NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(67) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1e6e4728c931` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossReward_5
CREATE TABLE IF NOT EXISTS `game_cfg_themebossreward_5` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Degree` VARCHAR(32) NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(67) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e12bf437b8a4` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossReward_6
CREATE TABLE IF NOT EXISTS `game_cfg_themebossreward_6` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Degree` VARCHAR(32) NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(67) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b8833deabd08` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossReward_7
CREATE TABLE IF NOT EXISTS `game_cfg_themebossreward_7` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Degree` VARCHAR(32) NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(67) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c8180a4b8abe` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossReward_8
CREATE TABLE IF NOT EXISTS `game_cfg_themebossreward_8` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Degree` VARCHAR(32) NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(68) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_694c6b534eae` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeBossReward_9
CREATE TABLE IF NOT EXISTS `game_cfg_themebossreward_9` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Degree` VARCHAR(32) NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(68) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_988cadb35531` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeFireworkAcumulateReward
CREATE TABLE IF NOT EXISTS `game_cfg_themefireworkacumulatereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `ClientReward` VARCHAR(32) NULL,
  `Count` BIGINT UNSIGNED NULL,
  `IsHighScore` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `RewardType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_83d8ec74ccb3` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeFireworkConfig
CREATE TABLE IF NOT EXISTS `game_cfg_themefireworkconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `FireworkItem` VARCHAR(39) NULL,
  `FireworkRewardList` VARCHAR(48) NULL,
  `GainScore` VARCHAR(32) NULL,
  `HighestFirework` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9505c763653c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeFireworkRandCoupon
CREATE TABLE IF NOT EXISTS `game_cfg_themefireworkrandcoupon` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `RewardType` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c295f7f0b518` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeFireworkRandFirework
CREATE TABLE IF NOT EXISTS `game_cfg_themefireworkrandfirework` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `RewardType` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_2a7d325c96c1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeFireworkRandReward
CREATE TABLE IF NOT EXISTS `game_cfg_themefireworkrandreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `RewardType` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_26ec8d4cd2b2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemeFireworkRankReward
CREATE TABLE IF NOT EXISTS `game_cfg_themefireworkrankreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Rank` VARCHAR(32) NULL,
  `Rewards` VARCHAR(33) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d61c446d447d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassConfig
CREATE TABLE IF NOT EXISTS `game_cfg_themepassconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ExpRatio` BIGINT UNSIGNED NULL,
  `MaxPassLevel` BIGINT UNSIGNED NULL,
  `OverTimeRewardEmail` BIGINT UNSIGNED NULL,
  `PerEmailRewardCount` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_7d498f7ea64c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassExpItem
CREATE TABLE IF NOT EXISTS `game_cfg_themepassexpitem` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ThemeType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b1484379ad19` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassLevel_1
CREATE TABLE IF NOT EXISTS `game_cfg_themepasslevel_1` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DeltaExp` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_150e02717e0a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassLevel_10
CREATE TABLE IF NOT EXISTS `game_cfg_themepasslevel_10` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DeltaExp` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_cda961aeff68` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassLevel_11
CREATE TABLE IF NOT EXISTS `game_cfg_themepasslevel_11` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DeltaExp` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_0ffd971579c3` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassLevel_12
CREATE TABLE IF NOT EXISTS `game_cfg_themepasslevel_12` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DeltaExp` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_0bbf2c57d2a9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassLevel_13
CREATE TABLE IF NOT EXISTS `game_cfg_themepasslevel_13` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DeltaExp` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_2d72d72428ad` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassLevel_2
CREATE TABLE IF NOT EXISTS `game_cfg_themepasslevel_2` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DeltaExp` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_68b3c6fe0b0d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassLevel_3
CREATE TABLE IF NOT EXISTS `game_cfg_themepasslevel_3` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DeltaExp` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_00d447ba87f5` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassLevel_4
CREATE TABLE IF NOT EXISTS `game_cfg_themepasslevel_4` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DeltaExp` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_0256a27614fa` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassLevel_5
CREATE TABLE IF NOT EXISTS `game_cfg_themepasslevel_5` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DeltaExp` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_008c17e2f098` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassLevel_6
CREATE TABLE IF NOT EXISTS `game_cfg_themepasslevel_6` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DeltaExp` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3b0497d0b838` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassLevel_7
CREATE TABLE IF NOT EXISTS `game_cfg_themepasslevel_7` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DeltaExp` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_84058860fb30` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassLevel_8
CREATE TABLE IF NOT EXISTS `game_cfg_themepasslevel_8` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DeltaExp` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_97d3c9864ad1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassLevel_9
CREATE TABLE IF NOT EXISTS `game_cfg_themepasslevel_9` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `DeltaExp` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b07d55048e82` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassLevelMapping
CREATE TABLE IF NOT EXISTS `game_cfg_themepasslevelmapping` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `GetWayId` BIGINT UNSIGNED NULL,
  `LevelXmlNameId` BIGINT UNSIGNED NULL,
  `Theme` VARCHAR(32) NULL,
  `ThemeItemId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_fd48b9b8c877` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassReward_1
CREATE TABLE IF NOT EXISTS `game_cfg_themepassreward_1` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d5504d4844db` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassReward_10
CREATE TABLE IF NOT EXISTS `game_cfg_themepassreward_10` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_dc8219b881d6` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassReward_11
CREATE TABLE IF NOT EXISTS `game_cfg_themepassreward_11` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_30f639b987b0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassReward_12
CREATE TABLE IF NOT EXISTS `game_cfg_themepassreward_12` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e9bae67e5742` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassReward_13
CREATE TABLE IF NOT EXISTS `game_cfg_themepassreward_13` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5843e98df38b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassReward_2
CREATE TABLE IF NOT EXISTS `game_cfg_themepassreward_2` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b8cabde7ee98` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassReward_3
CREATE TABLE IF NOT EXISTS `game_cfg_themepassreward_3` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_cd3be22d41a6` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassReward_4
CREATE TABLE IF NOT EXISTS `game_cfg_themepassreward_4` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_8e51cffe4381` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassReward_5
CREATE TABLE IF NOT EXISTS `game_cfg_themepassreward_5` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5c760e73bd2c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassReward_6
CREATE TABLE IF NOT EXISTS `game_cfg_themepassreward_6` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_620a93c14bf0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassReward_7
CREATE TABLE IF NOT EXISTS `game_cfg_themepassreward_7` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3e46f9a990dd` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassReward_8
CREATE TABLE IF NOT EXISTS `game_cfg_themepassreward_8` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_35139be58d73` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: ThemePassReward_9
CREATE TABLE IF NOT EXISTS `game_cfg_themepassreward_9` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `AvailableLevel` BIGINT UNSIGNED NULL,
  `IsLoop` BIGINT UNSIGNED NULL,
  `PassRewardType` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9d509bdeddfa` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DailyTiming
CREATE TABLE IF NOT EXISTS `game_cfg_dailytiming` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Desc` VARCHAR(32) NULL,
  `Relation` BIGINT UNSIGNED NULL,
  `Timing` VARCHAR(32) NULL,
  `Zone` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a370d15a271a` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: DateTiming
CREATE TABLE IF NOT EXISTS `game_cfg_datetiming` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Desc` VARCHAR(32) NULL,
  `Relation` BIGINT UNSIGNED NULL,
  `Timing` VARCHAR(32) NULL,
  `Zone` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4a68083305ab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: MonthTiming
CREATE TABLE IF NOT EXISTS `game_cfg_monthtiming` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Day` BIGINT UNSIGNED NULL,
  `Desc` VARCHAR(32) NULL,
  `Relation` BIGINT UNSIGNED NULL,
  `Timing` VARCHAR(32) NULL,
  `Zone` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f45b7843e904` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: WeekTiming
CREATE TABLE IF NOT EXISTS `game_cfg_weektiming` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Desc` VARCHAR(32) NULL,
  `Relation` BIGINT UNSIGNED NULL,
  `Timing` VARCHAR(32) NULL,
  `Week` VARCHAR(32) NULL,
  `Zone` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b038e8eec13c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Title
CREATE TABLE IF NOT EXISTS `game_cfg_title` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `conditionNumber` VARCHAR(32) NULL,
  `natureRatio` VARCHAR(32) NULL,
  `obtainCondition` BIGINT UNSIGNED NULL,
  `order` BIGINT UNSIGNED NULL,
  `quality` BIGINT UNSIGNED NULL,
  `reward` VARCHAR(32) NULL,
  `subType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_768e0c1c6957` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TitleCard
CREATE TABLE IF NOT EXISTS `game_cfg_titlecard` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `TitleId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_627f93a786a0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TitleConfig
CREATE TABLE IF NOT EXISTS `game_cfg_titleconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `EmailId` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_cc065911aa4d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TitleType
CREATE TABLE IF NOT EXISTS `game_cfg_titletype` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `beizhu` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3b25c1f473cf` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TowerBuff
CREATE TABLE IF NOT EXISTS `game_cfg_towerbuff` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BuffIcon` VARCHAR(32) NULL,
  `CeHua` VARCHAR(42) NULL,
  `Color` BIGINT UNSIGNED NULL,
  `EventParam` BIGINT UNSIGNED NULL,
  `EventParam1` BIGINT UNSIGNED NULL,
  `EventType` BIGINT UNSIGNED NULL,
  `EventType1` BIGINT UNSIGNED NULL,
  `JobLimit` BIGINT UNSIGNED NULL,
  `JobType` BIGINT UNSIGNED NULL,
  `LimitParam` BIGINT UNSIGNED NULL,
  `Property` BIGINT UNSIGNED NULL,
  `Quality` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_efb0e0e71ea8` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TowerConfig
CREATE TABLE IF NOT EXISTS `game_cfg_towerconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BuffFactor` VARCHAR(32) NULL,
  `CloseDays` BIGINT UNSIGNED NULL,
  `EquipMaxQuality` BIGINT UNSIGNED NULL,
  `FirstBattlePower` BIGINT UNSIGNED NULL,
  `FirstHeroLevel` BIGINT UNSIGNED NULL,
  `HpRatio` DECIMAL(2,1) NULL,
  `JobLimit` VARCHAR(32) NULL,
  `OpenDays` BIGINT UNSIGNED NULL,
  `RevivePrice` VARCHAR(32) NULL,
  `ShopItemCount` BIGINT UNSIGNED NULL,
  `SoulBoneMaxQuality` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_2c8258a99ffa` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TowerDungeon
CREATE TABLE IF NOT EXISTS `game_cfg_towerdungeon` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BuffWeight` VARCHAR(32) NULL,
  `Difficuty` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_b85d295cb4d2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TowerGroup
CREATE TABLE IF NOT EXISTS `game_cfg_towergroup` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `GroupId` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a2f753c6e7c6` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TowerNodeReward
CREATE TABLE IF NOT EXISTS `game_cfg_towernodereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `GroupId` BIGINT UNSIGNED NULL,
  `Index` BIGINT UNSIGNED NULL,
  `NextTowerId` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `RewardLineHeight` BIGINT UNSIGNED NULL,
  `Stage` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e5c7be895580` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TowerShopItem
CREATE TABLE IF NOT EXISTS `game_cfg_towershopitem` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `QualityMax` BIGINT UNSIGNED NULL,
  `QualityMin` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_21c6716e658f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TowerShopItemTypeRandom
CREATE TABLE IF NOT EXISTS `game_cfg_towershopitemtyperandom` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `TaskLimit` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_42759d4d25c7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TowerTask
CREATE TABLE IF NOT EXISTS `game_cfg_towertask` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Chapter` BIGINT UNSIGNED NULL,
  `ChapterIdIndex` BIGINT UNSIGNED NULL,
  `Difficuty` BIGINT UNSIGNED NULL,
  `GroupId` BIGINT UNSIGNED NULL,
  `NodeId` BIGINT UNSIGNED NULL,
  `Quality` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_729f37558414` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TravelCard
CREATE TABLE IF NOT EXISTS `game_cfg_travelcard` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `addExp` BIGINT UNSIGNED NULL,
  `battlePower` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `heroId` BIGINT UNSIGNED NULL,
  `level` BIGINT UNSIGNED NULL,
  `levelPower` BIGINT UNSIGNED NULL,
  `levelRatios` BIGINT UNSIGNED NULL,
  `levelValues` BIGINT UNSIGNED NULL,
  `natureRatios` VARCHAR(32) NULL,
  `natureValues` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_0cd22199473f` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TravelCardLevel
CREATE TABLE IF NOT EXISTS `game_cfg_travelcardlevel` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Exp` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_8642a801fda3` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TravelConfig
CREATE TABLE IF NOT EXISTS `game_cfg_travelconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `friendAddAffinity` BIGINT UNSIGNED NULL,
  `maxSlotCount` BIGINT UNSIGNED NULL,
  `OldCardLevel` BIGINT UNSIGNED NULL,
  `ShopItemCount` BIGINT UNSIGNED NULL,
  `slotCount` VARCHAR(39) NULL,
  `TravelFreeDialog` BIGINT UNSIGNED NULL,
  `TravelFreeHero` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_d636503bd736` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TravelEvent
CREATE TABLE IF NOT EXISTS `game_cfg_travelevent` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `eventRatio` VARCHAR(39) NULL,
  `eventTime` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_19596c6c06e9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TravelHero
CREATE TABLE IF NOT EXISTS `game_cfg_travelhero` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `cardList` VARCHAR(148) NULL,
  `CEHUA` VARCHAR(32) NULL,
  `itemId` BIGINT UNSIGNED NULL,
  `itemNum` BIGINT UNSIGNED NULL,
  `maxLevel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6643e83d0086` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TravelHeroEvent
CREATE TABLE IF NOT EXISTS `game_cfg_travelheroevent` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BoxReward` TEXT NULL,
  `cardRatio` VARCHAR(248) NULL,
  `friendRatio` VARCHAR(55) NULL,
  `heroId` BIGINT UNSIGNED NULL,
  `level` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a780f6afdf9e` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TravelItem
CREATE TABLE IF NOT EXISTS `game_cfg_travelitem` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `addAffinity` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_cedd9ebb5b2c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TravelLevel
CREATE TABLE IF NOT EXISTS `game_cfg_travellevel` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `affinity` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_44d3054e1874` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TravelShopItem
CREATE TABLE IF NOT EXISTS `game_cfg_travelshopitem` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `QualityMax` BIGINT UNSIGNED NULL,
  `QualityMin` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ed4fe3352347` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TravelShopItemTypeRandom
CREATE TABLE IF NOT EXISTS `game_cfg_travelshopitemtyperandom` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `TaskLimit` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9641ddc8989b` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TridentRecharge
CREATE TABLE IF NOT EXISTS `game_cfg_tridentrecharge` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `GiftId` BIGINT UNSIGNED NULL,
  `Loop` BOOLEAN NULL,
  `note` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Type` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_9f407245fd7d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TridentShovel
CREATE TABLE IF NOT EXISTS `game_cfg_tridentshovel` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ClientProbability` BIGINT UNSIGNED NULL,
  `ServerProbability` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_17c66071ae62` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TridentTierReward
CREATE TABLE IF NOT EXISTS `game_cfg_tridenttierreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Loop` BOOLEAN NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(51) NULL,
  `Tier` BIGINT UNSIGNED NULL,
  `UnlockReward` VARCHAR(32) NULL,
  `Weight` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ec872af3a697` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TridentTotalReward
CREATE TABLE IF NOT EXISTS `game_cfg_tridenttotalreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `PullCount` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(63) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_03bbf61949df` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TriggerCreatedByGod
CREATE TABLE IF NOT EXISTS `game_cfg_triggercreatedbygod` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CeHua` VARCHAR(72) NULL,
  `ConditionCombine` BIGINT UNSIGNED NULL,
  `ConditionParam_1` BIGINT UNSIGNED NULL,
  `ConditionParam_2` BIGINT UNSIGNED NULL,
  `ConditionParam_3` BIGINT UNSIGNED NULL,
  `CoolDowns` DECIMAL(2,1) NULL,
  `EffectiveTime` BIGINT UNSIGNED NULL,
  `HandleFrequence` BIGINT UNSIGNED NULL,
  `HandlerParam_1` VARCHAR(32) NULL,
  `HandlerParam_2` VARCHAR(32) NULL,
  `HandlerParam_3` BIGINT UNSIGNED NULL,
  `HandlerType_1` BIGINT UNSIGNED NULL,
  `HandlerType_2` BIGINT UNSIGNED NULL,
  `HandlerType_3` BIGINT UNSIGNED NULL,
  `MessageType` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `Probability` BIGINT UNSIGNED NULL,
  `TriggerCondition_1` BIGINT UNSIGNED NULL,
  `TriggerCondition_2` BIGINT UNSIGNED NULL,
  `TriggerCondition_3` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_ff9311fdac45` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TriggerCreatedByGuideSoulItem
CREATE TABLE IF NOT EXISTS `game_cfg_triggercreatedbyguidesoulitem` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CeHua` VARCHAR(36) NULL,
  `ConditionCombine` BIGINT UNSIGNED NULL,
  `ConditionParam_1` BIGINT UNSIGNED NULL,
  `ConditionParam_2` BIGINT UNSIGNED NULL,
  `ConditionParam_3` BIGINT UNSIGNED NULL,
  `CoolDowns` BIGINT UNSIGNED NULL,
  `HandleFrequence` BIGINT UNSIGNED NULL,
  `HandlerParam_1` VARCHAR(32) NULL,
  `HandlerParam_2` BIGINT UNSIGNED NULL,
  `HandlerParam_3` BIGINT UNSIGNED NULL,
  `HandlerType_1` BIGINT UNSIGNED NULL,
  `HandlerType_2` BIGINT UNSIGNED NULL,
  `HandlerType_3` BIGINT UNSIGNED NULL,
  `MessageType` BIGINT UNSIGNED NULL,
  `name` BIGINT UNSIGNED NULL,
  `Probability` BIGINT UNSIGNED NULL,
  `TriggerCondition_1` BIGINT UNSIGNED NULL,
  `TriggerCondition_2` BIGINT UNSIGNED NULL,
  `TriggerCondition_3` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_151f1202038d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TriggerCreatedBySkill
CREATE TABLE IF NOT EXISTS `game_cfg_triggercreatedbyskill` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CeHua` VARCHAR(97) NULL,
  `ConditionCombine` BIGINT UNSIGNED NULL,
  `ConditionParam_1` VARCHAR(32) NULL,
  `ConditionParam_2` VARCHAR(32) NULL,
  `ConditionParam_3` VARCHAR(32) NULL,
  `CoolDowns` DECIMAL(3,1) NULL,
  `EffectiveTime` BIGINT UNSIGNED NULL,
  `HandleFrequence` BIGINT UNSIGNED NULL,
  `HandlerParam_1` VARCHAR(51) NULL,
  `HandlerParam_2` VARCHAR(32) NULL,
  `HandlerParam_3` VARCHAR(32) NULL,
  `HandlerType_1` BIGINT UNSIGNED NULL,
  `HandlerType_2` BIGINT UNSIGNED NULL,
  `HandlerType_3` BIGINT UNSIGNED NULL,
  `MessageType` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `Probability` VARCHAR(32) NULL,
  `TriggerCondition_1` BIGINT UNSIGNED NULL,
  `TriggerCondition_2` BIGINT UNSIGNED NULL,
  `TriggerCondition_3` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3c8155d11439` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TriggerCreatedBySoulBone
CREATE TABLE IF NOT EXISTS `game_cfg_triggercreatedbysoulbone` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CeHua` VARCHAR(55) NULL,
  `ConditionCombine` BIGINT UNSIGNED NULL,
  `ConditionParam_1` BIGINT UNSIGNED NULL,
  `ConditionParam_2` BIGINT UNSIGNED NULL,
  `ConditionParam_3` BIGINT UNSIGNED NULL,
  `CoolDowns` DECIMAL(2,1) NULL,
  `EffectiveTime` BIGINT UNSIGNED NULL,
  `HandleFrequence` BIGINT UNSIGNED NULL,
  `HandlerParam_1` VARCHAR(32) NULL,
  `HandlerParam_2` BIGINT UNSIGNED NULL,
  `HandlerParam_3` BIGINT UNSIGNED NULL,
  `HandlerType_1` BIGINT UNSIGNED NULL,
  `HandlerType_2` BIGINT UNSIGNED NULL,
  `HandlerType_3` BIGINT UNSIGNED NULL,
  `MessageType` BIGINT UNSIGNED NULL,
  `name` BIGINT UNSIGNED NULL,
  `Probability` BIGINT UNSIGNED NULL,
  `TriggerCondition_1` BIGINT UNSIGNED NULL,
  `TriggerCondition_2` BIGINT UNSIGNED NULL,
  `TriggerCondition_3` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a5d322e20e76` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TriggerCreatedBySoulRing
CREATE TABLE IF NOT EXISTS `game_cfg_triggercreatedbysoulring` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CeHua` VARCHAR(66) NULL,
  `ConditionCombine` BIGINT UNSIGNED NULL,
  `ConditionParam_1` VARCHAR(32) NULL,
  `ConditionParam_2` BIGINT UNSIGNED NULL,
  `ConditionParam_3` BIGINT UNSIGNED NULL,
  `CoolDowns` DECIMAL(3,1) NULL,
  `EffectiveTime` BIGINT UNSIGNED NULL,
  `HandleFrequence` BIGINT UNSIGNED NULL,
  `HandlerParam_1` VARCHAR(32) NULL,
  `HandlerParam_2` VARCHAR(32) NULL,
  `HandlerParam_3` VARCHAR(32) NULL,
  `HandlerType_1` BIGINT UNSIGNED NULL,
  `HandlerType_2` BIGINT UNSIGNED NULL,
  `HandlerType_3` BIGINT UNSIGNED NULL,
  `MessageType` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `Probability` VARCHAR(32) NULL,
  `TriggerCondition_1` BIGINT UNSIGNED NULL,
  `TriggerCondition_2` BIGINT UNSIGNED NULL,
  `TriggerCondition_3` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c3c416ba8bdc` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TriggerCreatedByTower
CREATE TABLE IF NOT EXISTS `game_cfg_triggercreatedbytower` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CeHua` VARCHAR(50) NULL,
  `ConditionCombine` BIGINT UNSIGNED NULL,
  `ConditionParam_1` BIGINT UNSIGNED NULL,
  `ConditionParam_2` BIGINT UNSIGNED NULL,
  `ConditionParam_3` BIGINT UNSIGNED NULL,
  `HandleFrequence` BIGINT UNSIGNED NULL,
  `HandlerParam_1` VARCHAR(32) NULL,
  `HandlerParam_2` VARCHAR(32) NULL,
  `HandlerParam_3` BIGINT UNSIGNED NULL,
  `HandlerType_1` BIGINT UNSIGNED NULL,
  `HandlerType_2` BIGINT UNSIGNED NULL,
  `HandlerType_3` BIGINT UNSIGNED NULL,
  `MessageType` BIGINT UNSIGNED NULL,
  `name` BIGINT UNSIGNED NULL,
  `Probability` BIGINT UNSIGNED NULL,
  `TriggerCondition_1` BIGINT UNSIGNED NULL,
  `TriggerCondition_2` BIGINT UNSIGNED NULL,
  `TriggerCondition_3` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_1ae9d2d92eb0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TriggerInHero
CREATE TABLE IF NOT EXISTS `game_cfg_triggerinhero` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CeHua` VARCHAR(41) NULL,
  `ConditionCombine` BIGINT UNSIGNED NULL,
  `ConditionParam_1` VARCHAR(32) NULL,
  `ConditionParam_2` BIGINT UNSIGNED NULL,
  `ConditionParam_3` BIGINT UNSIGNED NULL,
  `CoolDowns` DECIMAL(3,1) NULL,
  `EffectiveTime` BIGINT UNSIGNED NULL,
  `HandleFrequence` BIGINT UNSIGNED NULL,
  `HandlerParam_1` VARCHAR(32) NULL,
  `HandlerParam_2` VARCHAR(32) NULL,
  `HandlerParam_3` BIGINT UNSIGNED NULL,
  `HandlerType_1` BIGINT UNSIGNED NULL,
  `HandlerType_2` BIGINT UNSIGNED NULL,
  `HandlerType_3` BIGINT UNSIGNED NULL,
  `MessageType` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `Probability` BIGINT UNSIGNED NULL,
  `TriggerCondition_1` BIGINT UNSIGNED NULL,
  `TriggerCondition_2` BIGINT UNSIGNED NULL,
  `TriggerCondition_3` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_4758d7e0e667` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TriggerInMap
CREATE TABLE IF NOT EXISTS `game_cfg_triggerinmap` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ConditionCombine` BIGINT UNSIGNED NULL,
  `ConditionParam_1` VARCHAR(73) NULL,
  `ConditionParam_2` VARCHAR(58) NULL,
  `ConditionParam_3` BIGINT UNSIGNED NULL,
  `HandleFrequence` BIGINT UNSIGNED NULL,
  `HandlerParam_1` BIGINT UNSIGNED NULL,
  `HandlerParam_2` BIGINT UNSIGNED NULL,
  `HandlerParam_3` BIGINT UNSIGNED NULL,
  `HandlerType_1` BIGINT UNSIGNED NULL,
  `HandlerType_2` BIGINT UNSIGNED NULL,
  `HandlerType_3` BIGINT UNSIGNED NULL,
  `MessageType` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `Probability` BIGINT UNSIGNED NULL,
  `TriggerCondition_1` BIGINT UNSIGNED NULL,
  `TriggerCondition_2` BIGINT UNSIGNED NULL,
  `TriggerCondition_3` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_a43645863277` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TriggerInMonster
CREATE TABLE IF NOT EXISTS `game_cfg_triggerinmonster` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CeHua` VARCHAR(43) NULL,
  `ConditionCombine` BIGINT UNSIGNED NULL,
  `ConditionParam_1` VARCHAR(32) NULL,
  `ConditionParam_2` DECIMAL(7,1) NULL,
  `ConditionParam_3` BIGINT UNSIGNED NULL,
  `CoolDowns` DECIMAL(3,1) NULL,
  `EffectiveTime` BIGINT UNSIGNED NULL,
  `HandleFrequence` BIGINT UNSIGNED NULL,
  `HandlerParam_1` VARCHAR(32) NULL,
  `HandlerParam_2` VARCHAR(32) NULL,
  `HandlerParam_3` VARCHAR(32) NULL,
  `HandlerType_1` BIGINT UNSIGNED NULL,
  `HandlerType_2` BIGINT UNSIGNED NULL,
  `HandlerType_3` BIGINT UNSIGNED NULL,
  `MessageType` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `Probability` BIGINT UNSIGNED NULL,
  `TriggerCondition_1` BIGINT UNSIGNED NULL,
  `TriggerCondition_2` BIGINT UNSIGNED NULL,
  `TriggerCondition_3` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c49122a976b2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: TriggerInPet
CREATE TABLE IF NOT EXISTS `game_cfg_triggerinpet` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CeHua` VARCHAR(32) NULL,
  `ConditionCombine` BIGINT UNSIGNED NULL,
  `ConditionParam_1` BIGINT UNSIGNED NULL,
  `ConditionParam_2` BIGINT UNSIGNED NULL,
  `ConditionParam_3` BIGINT UNSIGNED NULL,
  `HandleFrequence` BIGINT UNSIGNED NULL,
  `HandlerParam_1` BIGINT UNSIGNED NULL,
  `HandlerParam_2` BIGINT UNSIGNED NULL,
  `HandlerParam_3` BIGINT UNSIGNED NULL,
  `HandlerType_1` BIGINT UNSIGNED NULL,
  `HandlerType_2` BIGINT UNSIGNED NULL,
  `HandlerType_3` BIGINT UNSIGNED NULL,
  `MessageType` BIGINT UNSIGNED NULL,
  `name` VARCHAR(32) NULL,
  `Probability` BIGINT UNSIGNED NULL,
  `TriggerCondition_1` BIGINT UNSIGNED NULL,
  `TriggerCondition_2` BIGINT UNSIGNED NULL,
  `TriggerCondition_3` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_c5181274c413` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: Warehouse
CREATE TABLE IF NOT EXISTS `game_cfg_warehouse` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Content` VARCHAR(51) NULL,
  `OnceGetLimit` BIGINT UNSIGNED NULL,
  `PageCount` BIGINT UNSIGNED NULL,
  `StoreLimit` BIGINT UNSIGNED NULL,
  `WarehouseFullEmail` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_298dff72dae2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: WelfareTrigger
CREATE TABLE IF NOT EXISTS `game_cfg_welfaretrigger` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `ChannelLimit` VARCHAR(32) NULL,
  `CheckTime` BIGINT UNSIGNED NULL,
  `ConditionParam` BIGINT UNSIGNED NULL,
  `ConditionType` BIGINT UNSIGNED NULL,
  `EmailParam` VARCHAR(32) NULL,
  `Emails` BIGINT UNSIGNED NULL,
  `EndDays` BIGINT UNSIGNED NULL,
  `LimitId` BIGINT UNSIGNED NULL,
  `Name` VARCHAR(32) NULL,
  `Type` BIGINT UNSIGNED NULL,
  `Url` VARCHAR(118) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_3f37a9bfce40` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: WishLanternBoxItem
CREATE TABLE IF NOT EXISTS `game_cfg_wishlanternboxitem` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Index` BIGINT UNSIGNED NULL,
  `Order` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f42dd1aeaba0` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: WishLanternConfig
CREATE TABLE IF NOT EXISTS `game_cfg_wishlanternconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `ResetCost` VARCHAR(42) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_be2c0f059e60` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: WishLanternCost
CREATE TABLE IF NOT EXISTS `game_cfg_wishlanterncost` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Diamond` BIGINT UNSIGNED NULL,
  `Ratio` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_82fc235f782c` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: WishLanternItem
CREATE TABLE IF NOT EXISTS `game_cfg_wishlanternitem` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Order` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_6734279d137d` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: WishPoolItem1
CREATE TABLE IF NOT EXISTS `game_cfg_wishpoolitem1` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `Consume` VARCHAR(32) NULL,
  `EndDay` BIGINT UNSIGNED NULL,
  `Level` BIGINT UNSIGNED NULL,
  `Obtain` VARCHAR(32) NULL,
  `StageType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_03d79ba56343` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: WishPoolItem2
CREATE TABLE IF NOT EXISTS `game_cfg_wishpoolitem2` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `LimitDiamond` BIGINT UNSIGNED NULL,
  `Obtain` VARCHAR(32) NULL,
  `ObtainBase` BIGINT UNSIGNED NULL,
  `OpenTime` TIME NULL,
  `OverLimitObtain` VARCHAR(32) NULL,
  `StageType` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_bf38a3ddc839` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: BuyResonanceGridCost
CREATE TABLE IF NOT EXISTS `game_cfg_buyresonancegridcost` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CostCoin` VARCHAR(32) NULL,
  `Max` BIGINT UNSIGNED NULL,
  `Min` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_33ae6c3c9ab9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: WuhunResonanceConfig
CREATE TABLE IF NOT EXISTS `game_cfg_wuhunresonanceconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `GridCdTime` BIGINT UNSIGNED NULL,
  `ReferHeroCount` BIGINT UNSIGNED NULL,
  `ResonanceGridDefaultCount` BIGINT UNSIGNED NULL,
  `ResonanceGridMaxCount` BIGINT UNSIGNED NULL,
  `ResonanceUpLevel` BIGINT UNSIGNED NULL,
  `ResonanceUpMaxLevel` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_df88c7ade014` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: XuanBoxConfig
CREATE TABLE IF NOT EXISTS `game_cfg_xuanboxconfig` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CostOneItem` VARCHAR(32) NULL,
  `CostTenItem` VARCHAR(32) NULL,
  `FinalRewardShow` VARCHAR(32) NULL,
  `LuckyLimit` BIGINT UNSIGNED NULL,
  `LuckyPool` VARCHAR(32) NULL,
  `OpenCountLBtn` BIGINT UNSIGNED NULL,
  `OpenCountRBtn` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_38f361eee4b5` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: XuanBoxItem
CREATE TABLE IF NOT EXISTS `game_cfg_xuanboxitem` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Pool` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(32) NULL,
  `Score` VARCHAR(32) NULL,
  `Weight` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_f3a1184b45d2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: XuanBoxScoreReward
CREATE TABLE IF NOT EXISTS `game_cfg_xuanboxscorereward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `Period` BIGINT UNSIGNED NULL,
  `Reward` VARCHAR(50) NULL,
  `Score` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_e48c38e78aac` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ชุดข้อมูล configuration: Goods
CREATE TABLE IF NOT EXISTS `game_cfg_goods` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `CEHUA` VARCHAR(32) NULL,
  `model` BIGINT UNSIGNED NULL,
  `Radius` BIGINT UNSIGNED NULL,
  `text_collection` BIGINT UNSIGNED NULL,
  `text_name` TEXT NULL,
  `TotalTask` BIGINT UNSIGNED NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_297d709ebeb7` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ชุดข้อมูล configuration: HelpReward
CREATE TABLE IF NOT EXISTS `game_cfg_helpreward` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `level` VARCHAR(32) NULL,
  `reward` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_5bb0352a21ae` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ชุดข้อมูล configuration: TransferMap
CREATE TABLE IF NOT EXISTS `game_cfg_transfermap` (
  `config_row_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id` BIGINT UNSIGNED NULL,
  `BeginPosX` DECIMAL(4,2) NULL,
  `BeginPosY` DECIMAL(5,2) NULL,
  `CEHUA` VARCHAR(32) NULL,
  PRIMARY KEY (`config_row_id`),
  UNIQUE KEY `uq_game_cfg_id_fc1f9d0585d9` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
