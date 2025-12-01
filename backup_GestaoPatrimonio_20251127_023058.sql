/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-12.0.2-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: GestaoPatrimonio
-- ------------------------------------------------------
-- Server version	12.0.2-MariaDB-ubu2404

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Current Database: `GestaoPatrimonio`
--

/*!40000 DROP DATABASE IF EXISTS `GestaoPatrimonio`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `GestaoPatrimonio` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci */;

USE `GestaoPatrimonio`;

--
-- Table structure for table `Dispositivo`
--

DROP TABLE IF EXISTS `Dispositivo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Dispositivo` (
  `id_dispositivo` int(11) NOT NULL AUTO_INCREMENT,
  `identificador` varchar(100) NOT NULL,
  `descricao` varchar(200) DEFAULT NULL,
  `tipo` varchar(30) NOT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `fk_id_local` int(11) NOT NULL,
  PRIMARY KEY (`id_dispositivo`),
  UNIQUE KEY `identificador` (`identificador`),
  KEY `fk_id_local` (`fk_id_local`),
  CONSTRAINT `Dispositivo_ibfk_1` FOREIGN KEY (`fk_id_local`) REFERENCES `Localizacao` (`id_local`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Dispositivo`
--

LOCK TABLES `Dispositivo` WRITE;
/*!40000 ALTER TABLE `Dispositivo` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `Dispositivo` VALUES
(1,'DEV-A','Leitor Sala A','RFID_READER',1,'2025-11-27 06:30:17',1),
(2,'DEV-B','Leitor Sala B','RFID_READER',1,'2025-11-27 06:30:17',2),
(3,'DEV-COR','Leitor Corredor','RFID_READER',1,'2025-11-27 06:30:17',3),
(4,'DEV-EXT','Leitor Externo','RFID_READER',1,'2025-11-27 06:30:17',4);
/*!40000 ALTER TABLE `Dispositivo` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `Item`
--

DROP TABLE IF EXISTS `Item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Item` (
  `id_item` int(11) NOT NULL AUTO_INCREMENT,
  `tag_codigo` varchar(100) DEFAULT NULL,
  `nome` varchar(100) NOT NULL,
  `descricao` text DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `fk_id_local_origem` int(11) NOT NULL,
  PRIMARY KEY (`id_item`),
  UNIQUE KEY `tag_codigo` (`tag_codigo`),
  KEY `fk_id_local_origem` (`fk_id_local_origem`),
  CONSTRAINT `Item_ibfk_1` FOREIGN KEY (`fk_id_local_origem`) REFERENCES `Localizacao` (`id_local`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Item`
--

LOCK TABLES `Item` WRITE;
/*!40000 ALTER TABLE `Item` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `Item` VALUES
(1,'TAG-ITEM1','item1',NULL,1,'2025-11-27 06:30:17',2),
(2,'TAG-ITEM2','item2',NULL,1,'2025-11-27 06:30:17',1),
(3,'TAG-ITEM3','item3',NULL,1,'2025-11-27 06:30:17',1);
/*!40000 ALTER TABLE `Item` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `Leitura`
--

DROP TABLE IF EXISTS `Leitura`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Leitura` (
  `id_leitura` bigint(20) NOT NULL AUTO_INCREMENT,
  `tag_codigo` varchar(100) NOT NULL,
  `lido_em` datetime NOT NULL DEFAULT current_timestamp(),
  `rssi` decimal(6,2) DEFAULT NULL,
  `payload_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`payload_json`)),
  `fk_id_dispositivo` int(11) NOT NULL,
  PRIMARY KEY (`id_leitura`),
  KEY `fk_id_dispositivo` (`fk_id_dispositivo`),
  CONSTRAINT `Leitura_ibfk_1` FOREIGN KEY (`fk_id_dispositivo`) REFERENCES `Dispositivo` (`id_dispositivo`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Leitura`
--

LOCK TABLES `Leitura` WRITE;
/*!40000 ALTER TABLE `Leitura` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `Leitura` VALUES
(1,'TAG-ITEM1','2025-11-27 04:30:17',NULL,NULL,2),
(2,'TAG-ITEM2','2025-11-27 04:30:17',NULL,NULL,1),
(3,'TAG-ITEM3','2025-11-27 04:30:17',NULL,NULL,1),
(4,'TAG-ITEM3','2025-11-27 06:00:17',NULL,NULL,2),
(5,'TAG-ITEM2','2025-11-27 06:10:17',NULL,NULL,3),
(6,'TAG-ITEM1','2025-11-27 06:20:17',NULL,NULL,4);
/*!40000 ALTER TABLE `Leitura` ENABLE KEYS */;
UNLOCK TABLES;
commit;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_leitura_movimento_ai
AFTER INSERT ON Leitura
FOR EACH ROW
trg: BEGIN
  DECLARE v_item_id INT;
  DECLARE v_local_atual INT;
  DECLARE v_local_anterior INT;
  DECLARE v_local_origem_inicial INT;
  DECLARE v_local_corredor INT;

  
  SELECT id_item, fk_id_local_origem INTO v_item_id, v_local_origem_inicial 
  FROM Item
  WHERE tag_codigo = NEW.tag_codigo
  LIMIT 1;

  
  IF v_item_id IS NULL THEN
    LEAVE trg;
  END IF;

  
  SELECT fk_id_local INTO v_local_atual
  FROM Dispositivo
  WHERE id_dispositivo = NEW.fk_id_dispositivo
  LIMIT 1;

  
  SELECT loc.id_local INTO v_local_corredor
  FROM Localizacao loc
  JOIN TipoLocal tl ON tl.id_tipolocal = loc.fk_id_tipolocal
  WHERE tl.descricao = 'CORREDOR'
  LIMIT 1;

  
  SELECT m.fk_id_local_destino INTO v_local_anterior
  FROM Movimento m
  WHERE m.fk_id_item = v_item_id
  ORDER BY m.movido_em DESC, m.id_movimento DESC
  LIMIT 1;

  
  IF v_local_anterior IS NULL THEN
    SET v_local_anterior = v_local_origem_inicial;
  END IF;

  
  
  

  
  IF v_local_anterior = v_local_atual AND v_local_corredor IS NOT NULL THEN
    INSERT INTO Movimento(fk_id_item, fk_id_local_origem, fk_id_local_destino, fk_id_dispositivo, movido_em)
    VALUES (v_item_id, v_local_anterior, v_local_corredor, NEW.fk_id_dispositivo, NEW.lido_em);

  
  ELSEIF v_local_anterior = v_local_corredor AND v_local_atual <> v_local_corredor THEN
    INSERT INTO Movimento(fk_id_item, fk_id_local_origem, fk_id_local_destino, fk_id_dispositivo, movido_em)
    VALUES (v_item_id, v_local_corredor, v_local_atual, NEW.fk_id_dispositivo, NEW.lido_em);

  
  ELSEIF v_local_anterior <> v_local_atual THEN
	INSERT INTO Movimento(fk_id_item, fk_id_local_origem, fk_id_local_destino, fk_id_dispositivo, movido_em)
	VALUES (v_item_id, v_local_anterior, v_local_atual, NEW.fk_id_dispositivo, NEW.lido_em);
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Localizacao`
--

DROP TABLE IF EXISTS `Localizacao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Localizacao` (
  `id_local` int(11) NOT NULL AUTO_INCREMENT,
  `fk_id_tipolocal` int(11) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_local`),
  KEY `fk_id_tipolocal` (`fk_id_tipolocal`),
  CONSTRAINT `Localizacao_ibfk_1` FOREIGN KEY (`fk_id_tipolocal`) REFERENCES `TipoLocal` (`id_tipolocal`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Localizacao`
--

LOCK TABLES `Localizacao` WRITE;
/*!40000 ALTER TABLE `Localizacao` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `Localizacao` VALUES
(1,1,'Sala A',1),
(2,1,'Sala B',1),
(3,2,'Corredor Principal',1),
(4,3,'Área Externa/Saída',1);
/*!40000 ALTER TABLE `Localizacao` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `Movimento`
--

DROP TABLE IF EXISTS `Movimento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Movimento` (
  `id_movimento` bigint(20) NOT NULL AUTO_INCREMENT,
  `movido_em` datetime NOT NULL,
  `observacoes` text DEFAULT NULL,
  `fk_id_item` int(11) NOT NULL,
  `fk_id_local_origem` int(11) DEFAULT NULL,
  `fk_id_local_destino` int(11) NOT NULL,
  `fk_id_dispositivo` int(11) NOT NULL,
  PRIMARY KEY (`id_movimento`),
  KEY `fk_id_item` (`fk_id_item`),
  KEY `fk_id_local_origem` (`fk_id_local_origem`),
  KEY `fk_id_local_destino` (`fk_id_local_destino`),
  KEY `fk_id_dispositivo` (`fk_id_dispositivo`),
  CONSTRAINT `Movimento_ibfk_1` FOREIGN KEY (`fk_id_item`) REFERENCES `Item` (`id_item`),
  CONSTRAINT `Movimento_ibfk_2` FOREIGN KEY (`fk_id_local_origem`) REFERENCES `Localizacao` (`id_local`),
  CONSTRAINT `Movimento_ibfk_3` FOREIGN KEY (`fk_id_local_destino`) REFERENCES `Localizacao` (`id_local`),
  CONSTRAINT `Movimento_ibfk_4` FOREIGN KEY (`fk_id_dispositivo`) REFERENCES `Dispositivo` (`id_dispositivo`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Movimento`
--

LOCK TABLES `Movimento` WRITE;
/*!40000 ALTER TABLE `Movimento` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `Movimento` VALUES
(1,'2025-11-27 04:30:17',NULL,1,2,3,2),
(2,'2025-11-27 04:30:17',NULL,2,1,3,1),
(3,'2025-11-27 04:30:17',NULL,3,1,3,1),
(4,'2025-11-27 06:00:17',NULL,3,3,2,2),
(5,'2025-11-27 06:10:17',NULL,2,3,3,3),
(6,'2025-11-27 06:20:17',NULL,1,3,4,4);
/*!40000 ALTER TABLE `Movimento` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `TipoLocal`
--

DROP TABLE IF EXISTS `TipoLocal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `TipoLocal` (
  `id_tipolocal` int(11) NOT NULL AUTO_INCREMENT,
  `descricao` varchar(50) NOT NULL,
  PRIMARY KEY (`id_tipolocal`),
  UNIQUE KEY `descricao` (`descricao`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `TipoLocal`
--

LOCK TABLES `TipoLocal` WRITE;
/*!40000 ALTER TABLE `TipoLocal` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `TipoLocal` VALUES
(2,'CORREDOR'),
(3,'EXTERNO'),
(1,'SALA');
/*!40000 ALTER TABLE `TipoLocal` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Temporary table structure for view `v_entradas_em_salas`
--

DROP TABLE IF EXISTS `v_entradas_em_salas`;
/*!50001 DROP VIEW IF EXISTS `v_entradas_em_salas`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `v_entradas_em_salas` AS SELECT
 1 AS `id_sala_destino`,
  1 AS `sala_destino`,
  1 AS `id_item`,
  1 AS `item`,
  1 AS `tag_codigo`,
  1 AS `local_origem`,
  1 AS `movido_em` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_itens_atuais_por_sala`
--

DROP TABLE IF EXISTS `v_itens_atuais_por_sala`;
/*!50001 DROP VIEW IF EXISTS `v_itens_atuais_por_sala`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `v_itens_atuais_por_sala` AS SELECT
 1 AS `id_sala`,
  1 AS `sala`,
  1 AS `id_item`,
  1 AS `item`,
  1 AS `tag_codigo`,
  1 AS `ultima_leitura` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_movimentacao_por_itens`
--

DROP TABLE IF EXISTS `v_movimentacao_por_itens`;
/*!50001 DROP VIEW IF EXISTS `v_movimentacao_por_itens`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `v_movimentacao_por_itens` AS SELECT
 1 AS `id_item`,
  1 AS `item`,
  1 AS `tag_codigo`,
  1 AS `origem`,
  1 AS `destino`,
  1 AS `tipo_origem`,
  1 AS `tipo_destino`,
  1 AS `movido_em` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_movimentacao_por_sala`
--

DROP TABLE IF EXISTS `v_movimentacao_por_sala`;
/*!50001 DROP VIEW IF EXISTS `v_movimentacao_por_sala`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `v_movimentacao_por_sala` AS SELECT
 1 AS `id_item`,
  1 AS `item`,
  1 AS `tag_codigo`,
  1 AS `origem`,
  1 AS `destino`,
  1 AS `movido_em`,
  1 AS `sala_envolvida_destino`,
  1 AS `sala_envolvida_origem` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_resumo_atual_por_sala`
--

DROP TABLE IF EXISTS `v_resumo_atual_por_sala`;
/*!50001 DROP VIEW IF EXISTS `v_resumo_atual_por_sala`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `v_resumo_atual_por_sala` AS SELECT
 1 AS `id_sala`,
  1 AS `sala`,
  1 AS `quantidade_itens` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_saidas_de_salas`
--

DROP TABLE IF EXISTS `v_saidas_de_salas`;
/*!50001 DROP VIEW IF EXISTS `v_saidas_de_salas`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `v_saidas_de_salas` AS SELECT
 1 AS `id_sala_origem`,
  1 AS `sala_origem`,
  1 AS `id_item`,
  1 AS `item`,
  1 AS `tag_codigo`,
  1 AS `local_destino`,
  1 AS `movido_em` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_status_atual_de_cada_item`
--

DROP TABLE IF EXISTS `v_status_atual_de_cada_item`;
/*!50001 DROP VIEW IF EXISTS `v_status_atual_de_cada_item`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `v_status_atual_de_cada_item` AS SELECT
 1 AS `id_item`,
  1 AS `item`,
  1 AS `tag_codigo`,
  1 AS `id_local_origem`,
  1 AS `local_origem`,
  1 AS `id_local_atual`,
  1 AS `local_atual`,
  1 AS `tipo_local_atual`,
  1 AS `referencia_em` */;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'GestaoPatrimonio'
--

--
-- Current Database: `GestaoPatrimonio`
--

USE `GestaoPatrimonio`;

--
-- Final view structure for view `v_entradas_em_salas`
--

/*!50001 DROP VIEW IF EXISTS `v_entradas_em_salas`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_entradas_em_salas` AS select `ld`.`id_local` AS `id_sala_destino`,`ld`.`nome` AS `sala_destino`,`i`.`id_item` AS `id_item`,`i`.`nome` AS `item`,`i`.`tag_codigo` AS `tag_codigo`,coalesce(`lo`.`nome`,'(sem origem)') AS `local_origem`,`m`.`movido_em` AS `movido_em` from ((((`Movimento` `m` left join `Localizacao` `lo` on(`lo`.`id_local` = `m`.`fk_id_local_origem`)) join `Localizacao` `ld` on(`ld`.`id_local` = `m`.`fk_id_local_destino`)) join `TipoLocal` `tld` on(`tld`.`id_tipolocal` = `ld`.`fk_id_tipolocal`)) join `Item` `i` on(`i`.`id_item` = `m`.`fk_id_item`)) where `tld`.`descricao` = 'SALA' order by `m`.`movido_em` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_itens_atuais_por_sala`
--

/*!50001 DROP VIEW IF EXISTS `v_itens_atuais_por_sala`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_itens_atuais_por_sala` AS select `loc`.`id_local` AS `id_sala`,`loc`.`nome` AS `sala`,`v`.`id_item` AS `id_item`,`v`.`item` AS `item`,`v`.`tag_codigo` AS `tag_codigo`,`v`.`referencia_em` AS `ultima_leitura` from ((`v_status_atual_de_cada_item` `v` join `Localizacao` `loc` on(`loc`.`id_local` = `v`.`id_local_atual`)) join `TipoLocal` `tl` on(`tl`.`id_tipolocal` = `loc`.`fk_id_tipolocal`)) where `tl`.`descricao` = 'SALA' order by `loc`.`nome`,`v`.`item` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_movimentacao_por_itens`
--

/*!50001 DROP VIEW IF EXISTS `v_movimentacao_por_itens`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_movimentacao_por_itens` AS select `i`.`id_item` AS `id_item`,`i`.`nome` AS `item`,`i`.`tag_codigo` AS `tag_codigo`,coalesce(`lo`.`nome`,'(sem origem)') AS `origem`,`ld`.`nome` AS `destino`,`tlo`.`descricao` AS `tipo_origem`,`tld`.`descricao` AS `tipo_destino`,`m`.`movido_em` AS `movido_em` from (((((`Movimento` `m` left join `Localizacao` `lo` on(`lo`.`id_local` = `m`.`fk_id_local_origem`)) left join `TipoLocal` `tlo` on(`tlo`.`id_tipolocal` = `lo`.`fk_id_tipolocal`)) join `Localizacao` `ld` on(`ld`.`id_local` = `m`.`fk_id_local_destino`)) join `TipoLocal` `tld` on(`tld`.`id_tipolocal` = `ld`.`fk_id_tipolocal`)) join `Item` `i` on(`i`.`id_item` = `m`.`fk_id_item`)) order by `i`.`nome` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_movimentacao_por_sala`
--

/*!50001 DROP VIEW IF EXISTS `v_movimentacao_por_sala`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_movimentacao_por_sala` AS select `i`.`id_item` AS `id_item`,`i`.`nome` AS `item`,`i`.`tag_codigo` AS `tag_codigo`,coalesce(`lo`.`nome`,'(sem origem)') AS `origem`,`ld`.`nome` AS `destino`,`m`.`movido_em` AS `movido_em`,case when `tld`.`descricao` = 'SALA' then `ld`.`nome` end AS `sala_envolvida_destino`,case when `tlo`.`descricao` = 'SALA' then `lo`.`nome` end AS `sala_envolvida_origem` from (((((`Movimento` `m` left join `Localizacao` `lo` on(`lo`.`id_local` = `m`.`fk_id_local_origem`)) left join `TipoLocal` `tlo` on(`tlo`.`id_tipolocal` = `lo`.`fk_id_tipolocal`)) join `Localizacao` `ld` on(`ld`.`id_local` = `m`.`fk_id_local_destino`)) join `TipoLocal` `tld` on(`tld`.`id_tipolocal` = `ld`.`fk_id_tipolocal`)) join `Item` `i` on(`i`.`id_item` = `m`.`fk_id_item`)) where `tlo`.`descricao` = 'SALA' or `tld`.`descricao` = 'SALA' order by `i`.`nome`,`m`.`movido_em` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_resumo_atual_por_sala`
--

/*!50001 DROP VIEW IF EXISTS `v_resumo_atual_por_sala`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_resumo_atual_por_sala` AS select `loc`.`id_local` AS `id_sala`,`loc`.`nome` AS `sala`,count(0) AS `quantidade_itens` from ((`v_status_atual_de_cada_item` `v` join `Localizacao` `loc` on(`loc`.`id_local` = `v`.`id_local_atual`)) join `TipoLocal` `tl` on(`tl`.`id_tipolocal` = `loc`.`fk_id_tipolocal`)) where `tl`.`descricao` = 'SALA' group by `loc`.`id_local`,`loc`.`nome` order by `loc`.`nome` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_saidas_de_salas`
--

/*!50001 DROP VIEW IF EXISTS `v_saidas_de_salas`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_saidas_de_salas` AS select `lo`.`id_local` AS `id_sala_origem`,`lo`.`nome` AS `sala_origem`,`i`.`id_item` AS `id_item`,`i`.`nome` AS `item`,`i`.`tag_codigo` AS `tag_codigo`,`ld`.`nome` AS `local_destino`,`m`.`movido_em` AS `movido_em` from ((((`Movimento` `m` join `Localizacao` `lo` on(`lo`.`id_local` = `m`.`fk_id_local_origem`)) join `TipoLocal` `tlo` on(`tlo`.`id_tipolocal` = `lo`.`fk_id_tipolocal`)) join `Localizacao` `ld` on(`ld`.`id_local` = `m`.`fk_id_local_destino`)) join `Item` `i` on(`i`.`id_item` = `m`.`fk_id_item`)) where `tlo`.`descricao` = 'SALA' order by `m`.`movido_em` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_status_atual_de_cada_item`
--

/*!50001 DROP VIEW IF EXISTS `v_status_atual_de_cada_item`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_status_atual_de_cada_item` AS select `i`.`id_item` AS `id_item`,`i`.`nome` AS `item`,`i`.`tag_codigo` AS `tag_codigo`,`loc_origem`.`id_local` AS `id_local_origem`,`loc_origem`.`nome` AS `local_origem`,`loc_atual`.`id_local` AS `id_local_atual`,`loc_atual`.`nome` AS `local_atual`,`tl_atual`.`descricao` AS `tipo_local_atual`,coalesce(`ult`.`movido_em`,`i`.`criado_em`) AS `referencia_em` from ((((`Item` `i` join `Localizacao` `loc_origem` on(`loc_origem`.`id_local` = `i`.`fk_id_local_origem`)) left join (select `m1`.`id_movimento` AS `id_movimento`,`m1`.`movido_em` AS `movido_em`,`m1`.`observacoes` AS `observacoes`,`m1`.`fk_id_item` AS `fk_id_item`,`m1`.`fk_id_local_origem` AS `fk_id_local_origem`,`m1`.`fk_id_local_destino` AS `fk_id_local_destino`,`m1`.`fk_id_dispositivo` AS `fk_id_dispositivo` from (`Movimento` `m1` join (select `Movimento`.`fk_id_item` AS `fk_id_item`,max(`Movimento`.`movido_em`) AS `movido_em`,max(`Movimento`.`id_movimento`) AS `id_movimento` from `Movimento` group by `Movimento`.`fk_id_item`) `ult` on(`ult`.`fk_id_item` = `m1`.`fk_id_item` and `ult`.`movido_em` = `m1`.`movido_em` and `ult`.`id_movimento` = `m1`.`id_movimento`))) `ult` on(`ult`.`fk_id_item` = `i`.`id_item`)) left join `Localizacao` `loc_atual` on(`loc_atual`.`id_local` = coalesce(`ult`.`fk_id_local_destino`,`i`.`fk_id_local_origem`))) left join `TipoLocal` `tl_atual` on(`tl_atual`.`id_tipolocal` = `loc_atual`.`fk_id_tipolocal`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2025-11-27  6:30:58
