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

-- Copiando estrutura para tabela allstar.ws_conce
CREATE TABLE IF NOT EXISTS `ws_conce` (
  `vehicle` varchar(50) DEFAULT NULL,
  `estoque` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Copiando dados para a tabela allstar.ws_conce: ~7 rows (aproximadamente)
/*!40000 ALTER TABLE `ws_conce` DISABLE KEYS */;
INSERT INTO `ws_conce` (`vehicle`, `estoque`) VALUES
	('nissangtr', 81),
	('ferrariitalia', 60),
	('audirs6', 1000),
	('bmwm4gts', 992),
	('adder', 989),
	('akuma', 993),
	('lamborghinihuracan', 993),
	('bmwm3f80', 989);
/*!40000 ALTER TABLE `ws_conce` ENABLE KEYS */;

-- Copiando estrutura para tabela allstar.ws_rent
CREATE TABLE IF NOT EXISTS `ws_rent` (
  `user_id` int(11) DEFAULT NULL,
  `vehicle` varchar(50) DEFAULT NULL,
  `time` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Copiando dados para a tabela allstar.ws_rent: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `ws_rent` DISABLE KEYS */;
/*!40000 ALTER TABLE `ws_rent` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
