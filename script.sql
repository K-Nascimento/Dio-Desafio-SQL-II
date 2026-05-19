-- =================================================================
-- CARGA DE DADOS (MASSA DE TESTE ALINHADA COM INTEGRIDADE DINÂMICA)
-- =================================================================

-- Carga inicial (Gera ID para Cliente e Veículo)
INSERT INTO CLIENTE (nome, telefone, endereco) VALUES ('André Mendoza', '11988887777', 'Av Paulista, 1000 - SP');
INSERT INTO VEICULO (id_cliente, placa, modelo, marca) VALUES (1, 'ABC1D23', 'Civic Touring', 'Honda');

-- Estrutura de Equipe e Mecânicos
INSERT INTO MECANICO (codigo_mecanico, nome, endereco, especialidade) VALUES 
('MEC01', 'Marcos Proença', 'Rua Augusta, 500 - SP', 'Injeção Eletrônica'),
('MEC02', 'Julio Cezar', 'Rua Consolação, 1200 - SP', 'Suspensão e Freios');

INSERT INTO EQUIPE (nome_equipe) VALUES ('Equipe Diagnóstico e Performance');

-- Amarração da Equipe com os Mecânicos
INSERT INTO MECANICO_EQUIPE (id_mecanico, id_equipe) VALUES (1, 1), (2, 1);

-- Abertura da Ordem de Serviço (O ID é gerado automaticamente pelo banco)
INSERT INTO ORDEM_SERVICO (id_veiculo, id_equipe, numero_os, data_emissao, data_conclusao, valor_total, status_os) 
VALUES (1, 1, 2026001, '2026-05-15', '2026-05-18', 1450.00, 'Autorizado');

-- CAPTURA DINÂMICA DO ID DA OS RECÉM-CRIADA
SET @os_id = LAST_INSERT_ID();

-- Lançamentos de Itens e Serviços Vinculados dinamicamente à OS correta
INSERT INTO SERVICO_OS (id_os, descricao_servico, valor_mao_de_obra) VALUES 
(@os_id, 'Alinhamento 3D e Balanceamento', 150.00),
(@os_id, 'Troca de Amortecedores Dianteiros', 300.00);

INSERT INTO PECA_OS (id_os, nome_peca, quantidade, valor_unitario) VALUES 
(@os_id, 'Kit Amortecedor (Par)', 1, 1000.00);
