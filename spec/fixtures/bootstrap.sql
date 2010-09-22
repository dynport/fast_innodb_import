CREATE DATABASE IF NOT EXISTS `fast_innodb_import_test` CHARACTER SET utf8;
CREATE TABLE IF NOT EXISTS `albums` (
  id SERIAL,
  artist_name VARCHAR(255),
  title VARCHAR(255),
  
  KEY `index_artist_name_title_on_tracks` (`artist_name`, `title`)
) ENGINE=InnoDB;
