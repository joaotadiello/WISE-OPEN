-- --------------------------------------------------------
-- Servidor:                     127.0.0.1
-- Versão do servidor:           10.4.17-MariaDB - mariadb.org binary distribution
-- OS do Servidor:               Win64
-- HeidiSQL Versão:              11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Copiando estrutura do banco de dados para allstar
CREATE DATABASE IF NOT EXISTS `allstar` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
USE `allstar`;

-- Copiando estrutura para tabela allstar.ws_deepweb_shops
CREATE TABLE IF NOT EXISTS `ws_deepweb_shops` (
  `token` varchar(8) DEFAULT NULL,
  `owner` int(11) DEFAULT NULL,
  `senha` varchar(10) DEFAULT NULL,
  `nome` text DEFAULT NULL,
  `wallet` int(11) DEFAULT 0,
  `produtos` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `police` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Copiando dados para a tabela allstar.ws_deepweb_shops: ~1 rows (aproximadamente)
/*!40000 ALTER TABLE `ws_deepweb_shops` DISABLE KEYS */;
/*!40000 ALTER TABLE `ws_deepweb_shops` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
