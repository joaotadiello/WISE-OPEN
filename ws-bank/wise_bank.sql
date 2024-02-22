-- --------------------------------------------------------
-- Servidor:                     127.0.0.1
-- Versão do servidor:           10.4.13-MariaDB - mariadb.org binary distribution
-- OS do Servidor:               Win64
-- HeidiSQL Versão:              11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Copiando estrutura para tabela allstar.wise_multas
CREATE TABLE IF NOT EXISTS `wise_multas` (
  `user_id` int(11) DEFAULT NULL,
  `multa_id` int(11) DEFAULT NULL,
  `motivo` varchar(50) DEFAULT NULL,
  `valor` int(11) DEFAULT NULL,
  `time` varchar(50) DEFAULT NULL,
  `descricao` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Copiando dados para a tabela allstar.wise_multas: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `wise_multas` DISABLE KEYS */;
/*!40000 ALTER TABLE `wise_multas` ENABLE KEYS */;

-- Copiando estrutura para tabela allstar.wise_pix
CREATE TABLE IF NOT EXISTS `wise_pix` (
  `user_id` int(11) DEFAULT NULL,
  `chave` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Copiando dados para a tabela allstar.wise_pix: ~1 rows (aproximadamente)
/*!40000 ALTER TABLE `wise_pix` DISABLE KEYS */;
INSERT INTO `wise_pix` (`user_id`, `chave`) VALUES
	(1, 'muamba');
/*!40000 ALTER TABLE `wise_pix` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
