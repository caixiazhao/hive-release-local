SELECT 'Upgrading MetaStore schema from 1.2.1000 to 2.0.0' AS ' ';

-- SOURCE 021-HIVE-7018.mysql.sql;
SELECT '< HIVE-7018 Remove Table and Partition tables column LINK_TARGET_ID from Mysql for other DBs do not have it >' AS ' ';

DELIMITER $$
DROP PROCEDURE IF EXISTS RM_TLBS_LINKID $$
DROP PROCEDURE IF EXISTS RM_PARTITIONS_LINKID $$
DROP PROCEDURE IF EXISTS RM_LINKID $$

/* Call this procedure to drop column LINK_TARGET_ID for TBLS */
CREATE PROCEDURE RM_TLBS_LINKID()
  BEGIN
    IF EXISTS (SELECT * FROM `INFORMATION_SCHEMA`.`COLUMNS` WHERE `TABLE_NAME` = 'TBLS' AND `COLUMN_NAME` = 'LINK_TARGET_ID') THEN
      ALTER TABLE `TBLS`
        DROP FOREIGN KEY `TBLS_FK3`
      ;
      ALTER TABLE `TBLS`
        DROP KEY `TBLS_N51`
      ;
      ALTER TABLE `TBLS`
        DROP COLUMN `LINK_TARGET_ID`
      ;
    END IF;
  END $$

/* Call this procedure to drop column LINK_TARGET_ID for PARTITIONS */
CREATE PROCEDURE RM_PARTITIONS_LINKID()
  BEGIN
    IF EXISTS (SELECT * FROM `INFORMATION_SCHEMA`.`COLUMNS` WHERE `TABLE_NAME` = 'PARTITIONS' AND `COLUMN_NAME` = 'LINK_TARGET_ID') THEN
      ALTER TABLE `PARTITIONS`
        DROP FOREIGN KEY `PARTITIONS_FK3`
      ;
      ALTER TABLE `PARTITIONS`
        DROP KEY `PARTITIONS_N51`
      ;
      ALTER TABLE `PARTITIONS`
        DROP COLUMN `LINK_TARGET_ID`
      ;
    END IF;
  END $$

/*
 * Check and drop column LINK_TARGET_ID
 */
CREATE PROCEDURE RM_LINKID()
  BEGIN
    call RM_PARTITIONS_LINKID();
    call RM_TLBS_LINKID();
    SELECT 'Completed remove LINK_TARGET_ID';
  END $$


DELIMITER ;

-- SOURCE 022-HIVE-11970.mysql.sql;
ALTER TABLE `COLUMNS_V2` MODIFY `COLUMN_NAME` varchar(767) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL;
ALTER TABLE `PART_COL_PRIVS` MODIFY `COLUMN_NAME` varchar(767) CHARACTER SET latin1 COLLATE latin1_bin DEFAULT NULL;
ALTER TABLE `TBL_COL_PRIVS` MODIFY `COLUMN_NAME` varchar(767) CHARACTER SET latin1 COLLATE latin1_bin DEFAULT NULL;
ALTER TABLE `SORT_COLS` MODIFY `COLUMN_NAME` varchar(767) CHARACTER SET latin1 COLLATE latin1_bin DEFAULT NULL;
ALTER TABLE `TAB_COL_STATS` MODIFY `COLUMN_NAME` varchar(767) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL;
ALTER TABLE `PART_COL_STATS` MODIFY `COLUMN_NAME` varchar(767) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL;

UPDATE VERSION SET SCHEMA_VERSION='2.0.0', VERSION_COMMENT='Hive release version 2.0.0' where VER_ID=1;
SELECT 'Finished upgrading MetaStore schema from 1.2.1000 to 2.0.0' AS ' ';
