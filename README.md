# Engenharia de Dados: Sistema Transacional para Oficina Mecânica
Documentação do esquema conceitual desenvolvido para automação, precificação e auditoria de Ordens de Serviço (OS).

## Arquitetura de Negócio
O modelo estrutura o fluxo operacional garantindo rastreabilidade financeira e otimização de recursos técnicos:

* **Desacoplamento de Equipes:** A relação entre mecânicos e ordens de serviço é intermediada por uma entidade `EQUIPE`. Isso viabiliza a alocação de equipes multidisciplinares a um único ativo, mitigando gargalos de pessoal.
* **Faturamento Composto:** Separação rígida na camada de custos entre Insumos (Peças) e Homem-Hora (Mão de Obra baseada em tabela de referência), consolidando o cálculo final diretamente no fechamento da OS.
* **Ciclo de Vida Controlado:** Estados transacionais (`Pendente`, `Autorizado`, `Em Execução`, `Concluído`) mapeados para permitir auditoria de tempos de pátio e eficiência operacional.

## Modelo Relacional (ERD)

```mermaid
erDiagram
    CLIENTE {
        int id_cliente PK
        string nome
        string telefone
        string endereco
    }
    VEICULO {
        int id_veiculo PK
        int id_cliente FK
        string placa UK
        string modelo
        string marca
    }
    MECANICO {
        int id_mecanico PK
        string codigo_mecanico UK
        string nome
        string endereco
        string especialidade
    }
    EQUIPE {
        int id_equipe PK
        string nome_equipe
    }
    MECANICO_EQUIPE {
        int id_mecanico PK, FK
        int id_equipe PK, FK
    }
    ORDEM_SERVICO {
        int id_os PK
        int id_veiculo FK
        int id_equipe FK
        int numero_os UK
        date data_emissao
        date data_conclusao
        decimal valor_total
        string status_os
    }
    SERVICO_OS {
        int id_os PK, FK
        string descricao_servico PK
        decimal valor_mao_de_obra
    }
    PECA_OS {
        int id_os PK, FK
        string nome_peca PK
        int quantidade
        decimal valor_unitario
    }

    CLIENTE ||--o{ VEICULO : "1:N"
    VEICULO ||--o{ ORDEM_SERVICO : "1:N"
    EQUIPE ||--o{ ORDEM_SERVICO : "1:N"
    MECANICO ||--o{ MECANICO_EQUIPE : "1:N"
    EQUIPE ||--o{ MECANICO_EQUIPE : "1:N"
    ORDEM_SERVICO ||--o{ SERVICO_OS : "1:N"
    ORDEM_SERVICO ||--o{ PECA_OS : "1:N"
