-- =================================================================
-- SCHEMA: OFICINA MECÂNICA TRANSACIONAL
-- DATA REVISÃO: MAIO DE 2026
-- =================================================================

CREATE DATABASE IF NOT EXISTS oficina_mecanica;
USE oficina_mecanica;

-- Núcleo de Ativos e Clientes
CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    endereco VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE veiculo (
    id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    placa CHAR(7) NOT NULL UNIQUE,
    modelo VARCHAR(50) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Estrutura de Alocação de Recursos Humanos
CREATE TABLE mecanico (
    id_mecanico INT AUTO_INCREMENT PRIMARY KEY,
    codigo_mecanico VARCHAR(20) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(255),
    especialidade VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE equipe (
    id_equipe INT AUTO_INCREMENT PRIMARY KEY,
    nome_equipe VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- Associação N:M para Equipes Multidisciplinares
CREATE TABLE mecanico_equipe (
    id_mecanico INT,
    id_equipe INT,
    PRIMARY KEY (id_mecanico, id_equipe),
    FOREIGN KEY (id_mecanico) REFERENCES mecanico(id_mecanico) ON DELETE CASCADE,
    FOREIGN KEY (id_equipe) REFERENCES equipe(id_equipe) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Camada de Controle de Ordens de Serviço
CREATE TABLE ordem_servico (
    id_os INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo INT NOT NULL,
    id_equipe INT NOT NULL,
    numero_os INT NOT NULL UNIQUE,
    data_emissao DATE NOT NULL,
    data_conclusao DATE,
    valor_total DECIMAL(10,2) DEFAULT 0.00,
    status_os ENUM('Pendente', 'Autorizado', 'Em Execução', 'Concluído', 'Cancelado') DEFAULT 'Pendente',
    FOREIGN KEY (id_veiculo) REFERENCES veiculo(id_veiculo) ON DELETE RESTRICT,
    FOREIGN KEY (id_equipe) REFERENCES equipe(id_equipe) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Detalhamento de Custos Homem-Hora e Insumos
CREATE TABLE servico_os (
    id_os INT,
    descricao_servico VARCHAR(150),
    valor_mao_de_obra DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_os, descricao_servico),
    FOREIGN KEY (id_os) REFERENCES ordem_servico(id_os) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE peca_os (
    id_os INT,
    nome_peca VARCHAR(100),
    quantidade INT NOT NULL DEFAULT 1,
    valor_unitario DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_os, nome_peca),
    FOREIGN KEY (id_os) REFERENCES ordem_servico(id_os) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =================================================================
-- CARGA DE DADOS (MASSA DE TESTE COM INTEGRIDADE DINÂMICA)
-- =================================================================

-- 1. Registro de Clientes e Veículos (IDs gerados sequencialmente: 1)
INSERT INTO cliente (nome, telefone, endereco) VALUES ('André Mendoza', '11988887777', 'Av Paulista, 1000 - SP');
INSERT INTO veiculo (id_cliente, placa, modelo, marca) VALUES (LAST_INSERT_ID(), 'ABC1D23', 'Civic Touring', 'Honda');

-- 2. Corpo Técnico e Criação de Equipe (IDs gerados sequencialmente: 1 e 2)
INSERT INTO mecanico (codigo_mecanico, nome, especialidade) VALUES ('MEC01', 'Marcos Proença', 'Injeção Eletrônica');
SET @mecanico_1 = LAST_INSERT_ID();

INSERT INTO mecanico (codigo_mecanico, nome, especialidade) VALUES ('MEC02', 'Julio Cezar', 'Suspensão e Freios');
SET @mecanico_2 = LAST_INSERT_ID();

INSERT INTO equipe (nome_equipe) VALUES ('Equipe Diagnóstico e Performance');
SET @equipe_id = LAST_INSERT_ID();

-- Associação na tabela pivô utilizando as variáveis de escopo
INSERT INTO mecanico_equipe (id_mecanico, id_equipe) VALUES (@mecanico_1, @equipe_id), (@mecanico_2, @equipe_id);

-- 3. Fluxo de Ordem de Serviço
-- Deixamos o ID ser gerado pelo AUTO_INCREMENT para respeitar a DDL
INSERT INTO ordem_servico (id_veiculo, id_equipe, numero_os, data_emissao, data_conclusao, valor_total, status_os) 
VALUES (1, 1, 2026001, '2026-05-15', '2026-05-18', 1450.00, 'Autorizado');

-- Armazena o ID da OS recém-criada para os lançamentos filhos
SET @os_id = LAST_INSERT_ID();

-- Serviços aplicados vinculados dinamicamente
INSERT INTO servico_os (id_os, descricao_servico, valor_mao_de_obra) VALUES 
(@os_id, 'Alinhamento 3D e Balanceamento', 150.00),
(@os_id, 'Troca de Amortecedores Dianteiros', 300.00);

-- Peças consumidas vinculadas dinamicamente
INSERT INTO peca_os (id_os, nome_peca, quantidade, valor_unitario) VALUES 
(@os_id, 'Kit Amortecedor (Par)', 1, 1000.00);
