-- =================================================================
-- SCHEMA: OFICINA MECÂNICA TRANSACIONAL (ALINHAMENTO EXECUTIVO)
-- =================================================================

DROP DATABASE IF EXISTS oficina_mecanica;
CREATE DATABASE oficina_mecanica;
USE oficina_mecanica;

-- 1. Núcleo de Ativos e Clientes
CREATE TABLE CLIENTE (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    endereco VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE VEICULO (
    id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    placa CHAR(7) NOT NULL UNIQUE,
    modelo VARCHAR(50) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 2. Recursos Humanos e Estrutura de Equipes
CREATE TABLE MECANICO (
    id_mecanico INT AUTO_INCREMENT PRIMARY KEY,
    codigo_mecanico VARCHAR(20) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(255),
    especialidade VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE EQUIPE (
    id_equipe INT AUTO_INCREMENT PRIMARY KEY,
    nome_equipe VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- Tabela Associativa N:M com Chave Composta
CREATE TABLE MECANICO_EQUIPE (
    id_mecanico INT NOT NULL,
    id_equipe INT NOT NULL,
    PRIMARY KEY (id_mecanico, id_equipe),
    FOREIGN KEY (id_mecanico) REFERENCES MECANICO(id_mecanico) ON DELETE CASCADE,
    FOREIGN KEY (id_equipe) REFERENCES EQUIPE(id_equipe) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. Camada de Controle de Ordens de Serviço
CREATE TABLE ORDEM_SERVICO (
    id_os INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo INT NOT NULL,
    id_equipe INT NOT NULL,
    numero_os INT NOT NULL UNIQUE,
    data_emissao DATE NOT NULL,
    data_conclusao DATE,
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    status_os VARCHAR(30) NOT NULL,
    FOREIGN KEY (id_veiculo) REFERENCES VEICULO(id_veiculo) ON DELETE RESTRICT,
    FOREIGN KEY (id_equipe) REFERENCES EQUIPE(id_equipe) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 4. Detalhes Financeiros Compartilhados (Chaves Compostas)
CREATE TABLE SERVICO_OS (
    id_os INT NOT NULL,
    descricao_servico VARCHAR(150) NOT NULL,
    valor_mao_de_obra DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_os, descricao_servico),
    FOREIGN KEY (id_os) REFERENCES ORDEM_SERVICO(id_os) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE PECA_OS (
    id_os INT NOT NULL,
    nome_peca VARCHAR(100) NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    valor_unitario DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_os, nome_peca),
    FOREIGN KEY (id_os) REFERENCES ORDEM_SERVICO(id_os) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =================================================================
-- CARGA DE DADOS (MASSA DE TESTE ALINHADA VIA IDs FIXOS)
-- =================================================================

-- Carga inicial (Gera ID 1 para Cliente e Veículo)
INSERT INTO CLIENTE (nome, telefone, endereco) VALUES ('André Mendoza', '11988887777', 'Av Paulista, 1000 - SP');
INSERT INTO VEICULO (id_cliente, placa, modelo, marca) VALUES (1, 'ABC1D23', 'Civic Touring', 'Honda');

-- Estrutura de Equipe (Gera IDs 1 e 2 para Mecânicos, ID 1 para Equipe)
INSERT INTO MECANICO (codigo_mecanico, nome, endereco, especialidade) VALUES 
('MEC01', 'Marcos Proença', 'Rua Augusta, 500 - SP', 'Injeção Eletrônica'),
('MEC02', 'Julio Cezar', 'Rua Consolação, 1200 - SP', 'Suspensão e Freios');

INSERT INTO EQUIPE (nome_equipe) VALUES ('Equipe Diagnóstico e Performance');

-- Amarração da Equipe 1 com os Mecânicos 1 e 2
INSERT INTO MECANICO_EQUIPE (id_mecanico, id_equipe) VALUES (1, 1), (2, 1);

-- Abertura da Ordem de Serviço (Gera ID 1 vinculado ao Veículo 1 e Equipe 1)
INSERT INTO ORDEM_SERVICO (id_veiculo, id_equipe, numero_os, data_emissao, data_conclusao, valor_total, status_os) 
VALUES (1, 1, 2026001, '2026-05-15', '2026-05-18', 1450.00, 'Autorizado');

-- Lançamentos de Itens e Serviços Vinculados estritamente à OS ID 1
INSERT INTO SERVICO_OS (id_os, descricao_servico, valor_mao_de_obra) VALUES 
(1, 'Alinhamento 3D e Balanceamento', 150.00),
(1, 'Troca de Amortecedores Dianteiros', 300.00);

INSERT INTO PECA_OS (id_os, nome_peca, quantidade, valor_unitario) VALUES 
(1, 'Kit Amortecedor (Par)', 1, 1000.00);
