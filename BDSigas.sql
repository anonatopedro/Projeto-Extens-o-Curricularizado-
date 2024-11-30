create database BD_Sigas

USE BD_Sigas;

CREATE LOGIN Admin WITH PASSWORD = 'Admin2024'; 
CREATE LOGIN Operacional1 WITH PASSWORD = 'Operacional2024'; 

CREATE USER Admin FOR LOGIN Admin;
CREATE USER Operacional1 FOR LOGIN Operacional1;

CREATE ROLE Role_Administrador;
CREATE ROLE Role_Operacional;

GRANT SELECT, INSERT, UPDATE, DELETE ON pessoas TO Role_Administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON produtos TO Role_Administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON categorias TO Role_Administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON operacoes TO Role_Administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON itens_operacao TO Role_Administrador;
GRANT EXECUTE ON SCHEMA::dbo TO Role_Administrador; 


select * from produtos
select * from categorias
select * from operacoes


GRANT SELECT, INSERT ON pessoas TO Role_Operacional;
GRANT SELECT, INSERT ON produtos TO Role_Operacional;
GRANT SELECT, INSERT ON categorias TO Role_Operacional;
GRANT SELECT, INSERT ON operacoes TO Role_Operacional;
GRANT SELECT, INSERT ON itens_operacao TO Role_Operacional;=
GRANT EXECUTE ON inserir_pessoa_fisica TO Role_Operacional;
GRANT EXECUTE ON inserir_pessoa_juridica TO Role_Operacional;
GRANT EXECUTE ON inserir_produto TO Role_Operacional;
GRANT EXECUTE ON inserir_operacao TO Role_Operacional;

EXEC sp_addrolemember 'Role_Administrador', 'Admin';
EXEC sp_addrolemember 'Role_Operacional', 'Operacional1';
EXEC sp_helprolemember 'Role_Administrador';
EXEC sp_helprolemember 'Role_Operacional';

CREATE TABLE pessoas (
    id_pessoa BIGINT IDENTITY PRIMARY KEY,
    tipo_pessoa CHAR(1),
    nome_pessoa NVARCHAR(100) NOT NULL,
    email_pessoa NVARCHAR(60),
    endereco_pessoa NVARCHAR(200),
    tel1_pessoa NVARCHAR(15) NOT NULL,
    tel2_pessoa NVARCHAR(15),
    is_active BIT NOT NULL DEFAULT 1,
    data_criacao DATETIME2 NOT NULL DEFAULT GETDATE(),
    data_modificacao DATETIME2 NULL,
    data_nascimento DATE NOT NULL, -- Adicionando a coluna data de nascimento
    idade AS (
        DATEDIFF(YEAR, data_nascimento, GETDATE()) -
        CASE
            WHEN MONTH(data_nascimento) > MONTH(GETDATE()) OR 
                 (MONTH(data_nascimento) = MONTH(GETDATE()) AND DAY(data_nascimento) > DAY(GETDATE()))
            THEN 1
            ELSE 0
        END
    ) 
);

CREATE TABLE pessoas_fisicas (
    id_pessoa BIGINT PRIMARY KEY,
    cpf NVARCHAR(14) NOT NULL UNIQUE,
    FOREIGN KEY (id_pessoa) REFERENCES pessoas(id_pessoa)
);

CREATE TABLE pessoas_juridicas (
    id_pessoa BIGINT PRIMARY KEY,
    cnpj NVARCHAR(18) NOT NULL UNIQUE,
    razao_social NVARCHAR(100) NOT NULL,
    FOREIGN KEY (id_pessoa) REFERENCES pessoas(id_pessoa)
);

CREATE TABLE categorias (
    id_categoria BIGINT IDENTITY PRIMARY KEY,
    nome_categoria NVARCHAR(100) NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    data_criacao DATETIME2 NOT NULL DEFAULT GETDATE(),
    data_modificacao DATETIME2 NULL
);

CREATE TABLE produtos (
    id_produto BIGINT IDENTITY PRIMARY KEY,
    nome_produto NVARCHAR(50) NOT NULL,
    descricao TEXT NOT NULL,
    unidade NVARCHAR(10) NOT NULL,
    preco_unidade DECIMAL(10, 2) NOT NULL,
    qtd_estoque INT NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    data_criacao DATETIME2 NOT NULL DEFAULT GETDATE(),
    data_modificacao DATETIME2 NULL,
    id_categoria BIGINT NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

CREATE TABLE operacoes (
    id_operacao BIGINT IDENTITY PRIMARY KEY,
    id_pessoa BIGINT NOT NULL,              
    tipo_operacao CHAR(1) NOT NULL,      
    data_operacao DATE NOT NULL,        
    valor_total DECIMAL(10, 2) DEFAULT 0,
    FOREIGN KEY (id_pessoa) REFERENCES pessoas(id_pessoa) 
);


ALTER TABLE pessoas ADD CONSTRAINT DF_is_active DEFAULT 1 FOR is_active;



CREATE TABLE itens_operacao (
    id_item_operacao BIGINT IDENTITY PRIMARY KEY,
    id_operacao BIGINT NOT NULL,                 
    id_produto BIGINT NOT NULL,                 
    quantidade INT NOT NULL,                  
    preco_unitario DECIMAL(10, 2) NOT NULL,  
    valor_total DECIMAL(10, 2) DEFAULT 0, 
    FOREIGN KEY (id_operacao) REFERENCES operacoes(id_operacao), 
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)      
);

CREATE VIEW vw_operacoes_com_valor_total AS
SELECT 
    o.id_operacao,
    o.id_pessoa,
    o.tipo_operacao,
    o.data_operacao,
    SUM(io.valor_total) AS valor_total
FROM 
    operacoes o
LEFT JOIN 
    itens_operacao io ON o.id_operacao = io.id_operacao
GROUP BY 
    o.id_operacao, o.id_pessoa, o.tipo_operacao, o.data_operacao;


CREATE VIEW vw_estoque_atual AS
SELECT 
    P.id_produto,
    P.nome_produto,
    P.qtd_estoque,
    P.unidade,
    P.preco_unidade
FROM Produtos P
WHERE P.qtd_estoque > 0;



CREATE VIEW vw_produtos_estoque_baixo AS
SELECT 
    p.id_produto,
    p.nome_produto,
    p.qtd_estoque,
    p.unidade,
    p.preco_unidade
FROM produtos p
WHERE p.qtd_estoque < 10;


CREATE VIEW vw_operacoes_periodo AS
SELECT 
    o.id_operacao,
    o.tipo_operacao,
    o.data_operacao,
    p.nome_pessoa AS pessoa_nome,
    p.tipo_pessoa
FROM operacoes o
JOIN pessoas p ON o.id_pessoa = p.id_pessoa;


CREATE VIEW vw_resumo_financeiro AS
SELECT 
    o.tipo_operacao,
    SUM(io.valor_total) AS total_valor,
    COUNT(o.id_operacao) AS total_operacoes,
    o.data_operacao
FROM operacoes o
JOIN itens_operacao io ON o.id_operacao = io.id_operacao
GROUP BY o.tipo_operacao, o.data_operacao;


CREATE VIEW vw_pessoas_fisicas AS
SELECT 
    pf.id_pessoa,
    p.nome_pessoa,
    p.email_pessoa,
    pf.cpf,
    p.tel1_pessoa,
    p.tel2_pessoa,
    p.endereco_pessoa
FROM pessoas p
JOIN pessoas_fisicas pf ON p.id_pessoa = pf.id_pessoa;


CREATE VIEW vw_pessoas_juridicas AS
SELECT 
    pj.id_pessoa,
    p.nome_pessoa,
    p.email_pessoa,
    pj.cnpj,
    pj.razao_social,
    p.tel1_pessoa,
    p.tel2_pessoa,
    p.endereco_pessoa
FROM pessoas p
JOIN pessoas_juridicas pj ON p.id_pessoa = pj.id_pessoa;


CREATE FUNCTION calcular_total_vendas(@inicio DATE, @fim DATE)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @total DECIMAL(10, 2);
    SELECT @total = SUM(io.valor_total)
    FROM operacoes o
    JOIN itens_operacao io ON o.id_operacao = io.id_operacao
    WHERE o.tipo_operacao = 'V' AND o.data_operacao BETWEEN @inicio AND @fim;
    RETURN @total;
END;


CREATE FUNCTION calcular_total_compras(@inicio DATE, @fim DATE)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @total DECIMAL(10, 2);
    SELECT @total = SUM(io.valor_total)
    FROM operacoes o
    JOIN itens_operacao io ON o.id_operacao = io.id_operacao
    WHERE o.tipo_operacao = 'C' AND o.data_operacao BETWEEN @inicio AND @fim;
    RETURN @total;
END;


CREATE FUNCTION produtos_mais_vendidos(@inicio DATE, @fim DATE)
RETURNS TABLE
AS
RETURN (
    SELECT 
        p.id_produto,
        p.nome_produto,
        SUM(io.quantidade) AS total_vendido
    FROM itens_operacao io
    JOIN produtos p ON io.id_produto = p.id_produto
    JOIN operacoes o ON io.id_operacao = o.id_operacao
    WHERE o.tipo_operacao = 'V' AND o.data_operacao BETWEEN @inicio AND @fim
    GROUP BY p.id_produto, p.nome_produto
);


CREATE PROCEDURE inserir_categoria
    @nome_categoria NVARCHAR(100)
AS
BEGIN
    INSERT INTO categorias (nome_categoria, is_active, data_criacao)
    VALUES (@nome_categoria, 1, GETDATE());
END;


CREATE PROCEDURE atualizar_categoria
    @id_categoria INT,
    @nome_categoria NVARCHAR(100)
AS
BEGIN
    UPDATE categorias
    SET nome_categoria = @nome_categoria,
        data_modificacao = GETDATE()
    WHERE id_categoria = @id_categoria;
END;


CREATE PROCEDURE deletar_categoria
    @id_categoria INT
AS
BEGIN
    UPDATE categorias
    SET is_active = 0,
        data_modificacao = GETDATE()
    WHERE id_categoria = @id_categoria;
END;


CREATE PROCEDURE inserir_produto
    @nome_produto NVARCHAR(50),
    @descricao NVARCHAR(MAX),
    @unidade NVARCHAR(10),
    @preco_unidade DECIMAL(10, 2),
    @qtd_estoque INT,
    @id_categoria BIGINT
AS
BEGIN
    INSERT INTO produtos (nome_produto, descricao, unidade, preco_unidade, qtd_estoque, id_categoria, is_active, data_criacao)
    VALUES (@nome_produto, @descricao, @unidade, @preco_unidade, @qtd_estoque, @id_categoria, 1, GETDATE());
END;


CREATE PROCEDURE atualizar_produto
    @id_produto BIGINT,
    @nome_produto NVARCHAR(50),
    @descricao NVARCHAR(MAX),
    @unidade NVARCHAR(10),
    @preco_unidade DECIMAL(10, 2),
    @qtd_estoque INT
AS
BEGIN
    UPDATE produtos
    SET nome_produto = @nome_produto,
        descricao = @descricao,
        unidade = @unidade,
        preco_unidade = @preco_unidade,
        qtd_estoque = @qtd_estoque,
        data_modificacao = GETDATE()
    WHERE id_produto = @id_produto;
END;


CREATE PROCEDURE deletar_produto
    @id_produto INT
AS
BEGIN
    UPDATE produtos
    SET is_active = 0,
        data_modificacao = GETDATE()
    WHERE id_produto = @id_produto;
END;


CREATE PROCEDURE inserir_operacao
    @id_pessoa BIGINT,
    @tipo_operacao CHAR(1),
    @data_operacao DATE
AS
BEGIN
    INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao)
    VALUES (@id_pessoa, @tipo_operacao, @data_operacao);
END;

CREATE PROCEDURE atualizar_operacao
    @id_operacao BIGINT,
    @id_pessoa BIGINT,
    @tipo_operacao CHAR(1),
    @data_operacao DATE
AS
BEGIN
    UPDATE operacoes
    SET id_pessoa = @id_pessoa,
        tipo_operacao = @tipo_operacao,
        data_operacao = @data_operacao
    WHERE id_operacao = @id_operacao;
END;


CREATE PROCEDURE deletar_operacao
    @id_operacao BIGINT
AS
BEGIN
    DELETE FROM operacoes
    WHERE id_operacao = @id_operacao;
END;


CREATE TRIGGER trg_atualizar_estoque
ON itens_operacao
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @id_produto BIGINT, @quantidade INT, @tipo_operacao CHAR(1);

    SELECT 
        @id_produto = i.id_produto,
        @quantidade = i.quantidade,
        @tipo_operacao = o.tipo_operacao
    FROM inserted i
    INNER JOIN operacoes o ON i.id_operacao = o.id_operacao;

    IF @tipo_operacao = 'C' -- Compra
    BEGIN
        UPDATE produtos
        SET qtd_estoque = qtd_estoque + @quantidade
        WHERE id_produto = @id_produto;
    END
    ELSE IF @tipo_operacao = 'V' -- Venda
    BEGIN
        UPDATE produtos
        SET qtd_estoque = qtd_estoque - @quantidade
        WHERE id_produto = @id_produto;
    END
END;


CREATE TRIGGER trg_atualizar_valor_total
ON itens_operacao
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE o
    SET o.valor_total = (
        SELECT ISNULL(SUM(io.quantidade * io.preco_unitario), 0)  -- Usando a fórmula diretamente
        FROM itens_operacao io
        WHERE io.id_operacao = o.id_operacao
    )
    FROM operacoes o
    WHERE o.id_operacao IN (
        SELECT DISTINCT id_operacao FROM inserted
        UNION
        SELECT DISTINCT id_operacao FROM deleted
    );
END;




CREATE TRIGGER trg_garantir_estoque_positivo
ON itens_operacao
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @id_produto BIGINT, @quantidade INT, @tipo_operacao CHAR(1);

    SELECT 
        @id_produto = i.id_produto,
        @quantidade = i.quantidade,
        @tipo_operacao = o.tipo_operacao
    FROM inserted i
    INNER JOIN operacoes o ON i.id_operacao = o.id_operacao;

    IF @tipo_operacao = 'V' -- Venda
    BEGIN
        IF EXISTS (
            SELECT 1 
            FROM produtos 
            WHERE id_produto = @id_produto AND qtd_estoque < @quantidade
        )
        BEGIN
            RAISERROR ('Estoque insuficiente para a venda.', 16, 1);
            ROLLBACK TRANSACTION;
        END
    END
END;


CREATE TRIGGER trg_atualizar_data_modificacao_categorias
ON categorias
AFTER UPDATE
AS
BEGIN
    UPDATE categorias
    SET data_modificacao = GETDATE()
    WHERE id_categoria IN (SELECT id_categoria FROM inserted);
END;


CREATE TRIGGER trg_atualizar_data_modificacao_produtos
ON produtos
AFTER UPDATE
AS
BEGIN
    UPDATE produtos
    SET data_modificacao = GETDATE()
    WHERE id_produto IN (SELECT id_produto FROM inserted);
END;


CREATE TRIGGER trg_atualizar_data_modificacao_pessoas
ON pessoas
AFTER UPDATE
AS
BEGIN
    UPDATE pessoas
    SET data_modificacao = GETDATE()
    WHERE id_pessoa IN (SELECT id_pessoa FROM inserted);
END;


CREATE TABLE log_alteracoes (
    id_log INT IDENTITY(1,1) PRIMARY KEY,
    tabela_alterada NVARCHAR(100) NOT NULL,
    id_registro INT NOT NULL,
    campo_alterado NVARCHAR(100) NOT NULL,
    valor_antigo NVARCHAR(MAX),
    valor_novo NVARCHAR(MAX),
    data_alteracao DATETIME DEFAULT GETDATE(),
    alterado_por NVARCHAR(100) NULL -- Opcional: Para armazenar o nome ou ID do usuário que fez a alteração
);


CREATE TRIGGER trg_log_alteracoes_categorias
ON categorias
AFTER UPDATE
AS
BEGIN
    DECLARE @id_categoria BIGINT, @nome_categoria_old NVARCHAR(100), @nome_categoria_new NVARCHAR(100);

    SELECT @id_categoria = i.id_categoria, 
           @nome_categoria_old = d.nome_categoria, 
           @nome_categoria_new = i.nome_categoria
    FROM inserted i
    INNER JOIN deleted d ON i.id_categoria = d.id_categoria;

    IF @nome_categoria_old <> @nome_categoria_new
    BEGIN
        INSERT INTO log_alteracoes (tabela_alterada, id_registro, campo_alterado, valor_antigo, valor_novo)
        VALUES ('categorias', @id_categoria, 'nome_categoria', @nome_categoria_old, @nome_categoria_new);
    END
END;


CREATE TRIGGER trg_log_alteracoes_produtos
ON produtos
AFTER UPDATE
AS
BEGIN
    DECLARE @id_produto BIGINT, @nome_produto_old NVARCHAR(50), @nome_produto_new NVARCHAR(50);

    SELECT @id_produto = i.id_produto, 
           @nome_produto_old = d.nome_produto, 
           @nome_produto_new = i.nome_produto
    FROM inserted i
    INNER JOIN deleted d ON i.id_produto = d.id_produto;

    IF @nome_produto_old <> @nome_produto_new
    BEGIN
        INSERT INTO log_alteracoes (tabela_alterada, id_registro, campo_alterado, valor_antigo, valor_novo)
        VALUES ('produtos', @id_produto, 'nome_produto', @nome_produto_old, @nome_produto_new);
    END
END;


CREATE TRIGGER trg_log_alteracoes_pessoas
ON pessoas
AFTER UPDATE
AS
BEGIN
    DECLARE @id_pessoa BIGINT, @nome_pessoa_old NVARCHAR(100), @nome_pessoa_new NVARCHAR(100);

    SELECT @id_pessoa = i.id_pessoa, 
           @nome_pessoa_old = d.nome_pessoa, 
           @nome_pessoa_new = i.nome_pessoa
    FROM inserted i
    INNER JOIN deleted d ON i.id_pessoa = d.id_pessoa;

    IF @nome_pessoa_old <> @nome_pessoa_new
    BEGIN
        INSERT INTO log_alteracoes (tabela_alterada, id_registro, campo_alterado, valor_antigo, valor_novo)
        VALUES ('pessoas', @id_pessoa, 'nome_pessoa', @nome_pessoa_old, @nome_pessoa_new);
    END
END;


CREATE TRIGGER trg_log_alteracoes_pessoas_fisicas
ON pessoas_fisicas
AFTER UPDATE
AS
BEGIN
    DECLARE @id_pessoa BIGINT, @cpf_old NVARCHAR(14), @cpf_new NVARCHAR(14);

    SELECT @id_pessoa = i.id_pessoa, 
           @cpf_old = d.cpf, 
           @cpf_new = i.cpf
    FROM inserted i
    INNER JOIN deleted d ON i.id_pessoa = d.id_pessoa;

    IF @cpf_old <> @cpf_new
    BEGIN
        INSERT INTO log_alteracoes (tabela_alterada, id_registro, campo_alterado, valor_antigo, valor_novo)
        VALUES ('pessoas_fisicas', @id_pessoa, 'cpf', @cpf_old, @cpf_new);
    END
END;


CREATE TRIGGER trg_log_alteracoes_pessoas_juridicas
ON pessoas_juridicas
AFTER UPDATE
AS
BEGIN
    DECLARE @id_pessoa BIGINT, @cnpj_old NVARCHAR(18), @cnpj_new NVARCHAR(18);

    SELECT @id_pessoa = i.id_pessoa, 
           @cnpj_old = d.cnpj, 
           @cnpj_new = i.cnpj
    FROM inserted i
    INNER JOIN deleted d ON i.id_pessoa = d.id_pessoa;

    IF @cnpj_old <> @cnpj_new
    BEGIN
        INSERT INTO log_alteracoes (tabela_alterada, id_registro, campo_alterado, valor_antigo, valor_novo)
        VALUES ('pessoas_juridicas', @id_pessoa, 'cnpj', @cnpj_old, @cnpj_new);
    END
END;


CREATE TRIGGER trg_log_alteracoes_operacoes
ON operacoes
AFTER UPDATE
AS
BEGIN
    DECLARE @id_operacao BIGINT, @tipo_operacao_old CHAR(1), @tipo_operacao_new CHAR(1);

    SELECT @id_operacao = i.id_operacao, 
           @tipo_operacao_old = d.tipo_operacao, 
           @tipo_operacao_new = i.tipo_operacao
    FROM inserted i
    INNER JOIN deleted d ON i.id_operacao = d.id_operacao;

    IF @tipo_operacao_old <> @tipo_operacao_new
    BEGIN
        INSERT INTO log_alteracoes (tabela_alterada, id_registro, campo_alterado, valor_antigo, valor_novo)
        VALUES ('operacoes', @id_operacao, 'tipo_operacao', @tipo_operacao_old, @tipo_operacao_new);
    END
END;


CREATE TRIGGER trg_log_alteracoes_itens_operacao
ON itens_operacao
AFTER UPDATE
AS
BEGIN
    DECLARE @id_item_operacao BIGINT, @quantidade_old INT, @quantidade_new INT;

    SELECT @id_item_operacao = i.id_item_operacao, 
           @quantidade_old = d.quantidade, 
           @quantidade_new = i.quantidade
    FROM inserted i
    INNER JOIN deleted d ON i.id_item_operacao = d.id_item_operacao;

    IF @quantidade_old <> @quantidade_new
    BEGIN
        INSERT INTO log_alteracoes (tabela_alterada, id_registro, campo_alterado, valor_antigo, valor_novo)
        VALUES ('itens_operacao', @id_item_operacao, 'quantidade', CAST(@quantidade_old AS NVARCHAR(MAX)), CAST(@quantidade_new AS NVARCHAR(MAX)));
    END
END;


select * from pessoas_fisicas
select * from pessoas

CREATE PROCEDURE inserir_pessoa_fisica
    @tipo_pessoa CHAR(1),
    @nome_pessoa NVARCHAR(100),
    @email_pessoa NVARCHAR(60),
    @endereco_pessoa NVARCHAR(200),
    @tel1_pessoa NVARCHAR(13),
    @tel2_pessoa NVARCHAR(13),
    @data_nascimento DATE,
    @cpf NVARCHAR(14)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @id_pessoa INT;

        INSERT INTO pessoas (
            tipo_pessoa, nome_pessoa, email_pessoa, endereco_pessoa, tel1_pessoa, tel2_pessoa, data_nascimento, is_active, data_criacao
        )
        VALUES (
            @tipo_pessoa, @nome_pessoa, @email_pessoa, @endereco_pessoa, @tel1_pessoa, @tel2_pessoa, @data_nascimento, 1, GETDATE()
        );

        SET @id_pessoa = SCOPE_IDENTITY();

        INSERT INTO pessoas_fisicas (
            id_pessoa, cpf
        )
        VALUES (
            @id_pessoa, @cpf
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;


CREATE PROCEDURE atualizar_pessoa_fisica
    @id_pessoa BIGINT,
    @cpf NVARCHAR(14),
    @nome NVARCHAR(100),
    @email NVARCHAR(60),
    @endereco NVARCHAR(200),
    @tel1 NVARCHAR(13),
    @tel2 NVARCHAR(13),
    @data_nascimento DATE
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE pessoas_fisicas
        SET cpf = @cpf
        WHERE id_pessoa = @id_pessoa;

        UPDATE pessoas
        SET 
            nome_pessoa = @nome, email_pessoa = @email, endereco_pessoa = @endereco, tel1_pessoa = @tel1, tel2_pessoa = @tel2,
            data_nascimento = @data_nascimento, data_modificacao = GETDATE()
        WHERE id_pessoa = @id_pessoa;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;




CREATE PROCEDURE deletar_pessoa_fisica
    @id_pessoa BIGINT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE pessoas
        SET is_active = 0,
            data_modificacao = GETDATE()
        WHERE id_pessoa = @id_pessoa;

        IF NOT EXISTS (SELECT 1 FROM pessoas_fisicas WHERE id_pessoa = @id_pessoa)
        BEGIN
            THROW 50000, 'Pessoa Física não encontrada.', 1;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;


CREATE PROCEDURE inserir_pessoa_juridica
    @tipo_pessoa CHAR(1),
    @nome_pessoa NVARCHAR(100),
    @email_pessoa NVARCHAR(60),
    @endereco_pessoa NVARCHAR(200),
    @tel1_pessoa NVARCHAR(13),
    @tel2_pessoa NVARCHAR(13),
    @data_nascimento DATE,
    @cnpj NVARCHAR(18),
    @razao_social NVARCHAR(100)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @id_pessoa INT;

        -- Insere na tabela "pessoas"
        INSERT INTO pessoas (
            tipo_pessoa, nome_pessoa, email_pessoa, endereco_pessoa, tel1_pessoa, tel2_pessoa, data_nascimento,is_active, data_criacao
        )
        VALUES (
            @tipo_pessoa, @nome_pessoa, @email_pessoa, @endereco_pessoa, @tel1_pessoa, @tel2_pessoa, @data_nascimento, 1, GETDATE()
        );

        SET @id_pessoa = SCOPE_IDENTITY();

        -- Insere na tabela "pessoas_juridicas"
        INSERT INTO pessoas_juridicas (
            id_pessoa, cnpj, razao_social
        )
        VALUES (
            @id_pessoa, @cnpj, @razao_social
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;


CREATE PROCEDURE atualizar_pessoa_juridica
    @id_pessoa BIGINT,
    @nome_pessoa NVARCHAR(100),
    @email_pessoa NVARCHAR(60),
    @endereco_pessoa NVARCHAR(200),
    @tel1_pessoa NVARCHAR(13),
    @tel2_pessoa NVARCHAR(13),
    @data_nascimento DATE,
    @cnpj NVARCHAR(18),
    @razao_social NVARCHAR(100)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Atualiza a tabela "pessoas"
        UPDATE pessoas
        SET 
            nome_pessoa = @nome_pessoa,
            email_pessoa = @email_pessoa,
            endereco_pessoa = @endereco_pessoa,
            tel1_pessoa = @tel1_pessoa,
            tel2_pessoa = @tel2_pessoa,
            data_nascimento = @data_nascimento,
            data_modificacao = GETDATE()
        WHERE id_pessoa = @id_pessoa;

        -- Atualiza a tabela "pessoas_juridicas"
        UPDATE pessoas_juridicas
        SET 
            cnpj = @cnpj,
            razao_social = @razao_social
        WHERE id_pessoa = @id_pessoa;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;


select * from pessoas

CREATE PROCEDURE deletar_pessoa_juridica
    @id_pessoa BIGINT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Atualiza a tabela "pessoas" para marcar como inativa
        UPDATE pessoas
        SET is_active = 0,
            data_modificacao = GETDATE()
        WHERE id_pessoa = @id_pessoa;

        -- Verifica se a pessoa jurídica existe
        IF NOT EXISTS (SELECT 1 FROM pessoas_juridicas WHERE id_pessoa = @id_pessoa)
        BEGIN
            THROW 50000, 'Pessoa Jurídica não encontrada.', 1;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;



INSERT INTO categorias (nome_categoria, is_active, data_criacao)
VALUES 
('Shampoo Artesanal', 1, GETDATE()),
('Condicionador', 1, GETDATE()),
('Sabonete Artesanal Líquido', 1, GETDATE()),
('Sabonete Artesanal em Barra', 1, GETDATE()),
('Rapé Artesanal', 1, GETDATE()),
('Santo Cruzeiro', 1, GETDATE()),
('Guia', 1, GETDATE()),
('Difusor de Ambiente', 1, GETDATE()),
('Creme Hidratante', 1, GETDATE()),
('Mistura de Ervas (Jurema)', 1, GETDATE()),
('Terço', 1, GETDATE()),
('Kuripe', 1, GETDATE()),
('Tepi', 1, GETDATE());

select * from categorias


-- Inserir Produtos para Shampoo Artesanal
INSERT INTO produtos (nome_produto, descricao, unidade, preco_unidade, qtd_estoque, is_active, data_criacao, id_categoria)
VALUES
('Shampoo Artesanal Maracujá', 'Shampoo artesanal de maracujá', 'unidade', 25.50, 50, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Shampoo Artesanal')),
('Shampoo Artesanal Banana', 'Shampoo artesanal de banana', 'unidade', 26.00, 50, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Shampoo Artesanal')),
('Shampoo Artesanal Alecrim', 'Shampoo artesanal de alecrim', 'unidade', 24.90, 50, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Shampoo Artesanal'));

-- Inserir Produtos para Condicionador
INSERT INTO produtos (nome_produto, descricao, unidade, preco_unidade, qtd_estoque, is_active, data_criacao, id_categoria)
VALUES
('Condicionador Manteiga de Karité', 'Condicionador com manteiga de karité', 'unidade', 30.00, 40, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Condicionador')),
('Condicionador Olibano', 'Condicionador com óleo essencial de olibano', 'unidade', 32.00, 40, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Condicionador')),
('Condicionador Samaúma', 'Condicionador de Samaúma', 'unidade', 28.50, 40, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Condicionador'));

-- Inserir Produtos para Sabonete Artesanal Líquido
INSERT INTO produtos (nome_produto, descricao, unidade, preco_unidade, qtd_estoque, is_active, data_criacao, id_categoria)
VALUES
('Sabonete Líquido Alecrim', 'Sabonete artesanal líquido de alecrim', 'unidade', 18.00, 60, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Sabonete Artesanal Líquido')),
('Sabonete Líquido Arruda com Sal Grosso', 'Sabonete artesanal líquido de arruda com sal grosso', 'unidade', 20.00, 60, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Sabonete Artesanal Líquido')),
('Sabonete Líquido Lavanda', 'Sabonete artesanal líquido de lavanda', 'unidade', 19.50, 60, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Sabonete Artesanal Líquido')),
('Sabonete Líquido Camomila', 'Sabonete artesanal líquido de camomila', 'unidade', 19.00, 60, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Sabonete Artesanal Líquido'));

-- Inserir Produtos para Sabonete Artesanal em Barra
INSERT INTO produtos (nome_produto, descricao, unidade, preco_unidade, qtd_estoque, is_active, data_criacao, id_categoria)
VALUES
('Sabonete Barra Alecrim', 'Sabonete artesanal em barra de alecrim', 'unidade', 10.00, 70, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Sabonete Artesanal em Barra')),
('Sabonete Barra Arruda com Sal Grosso', 'Sabonete artesanal em barra de arruda com sal grosso', 'unidade', 12.00, 70, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Sabonete Artesanal em Barra')),
('Sabonete Barra Lavanda', 'Sabonete artesanal em barra de lavanda', 'unidade', 11.50, 70, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Sabonete Artesanal em Barra')),
('Sabonete Barra Camomila', 'Sabonete artesanal em barra de camomila', 'unidade', 11.00, 70, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Sabonete Artesanal em Barra'));

-- Inserir Produtos para Rapé Artesanal
INSERT INTO produtos (nome_produto, descricao, unidade, preco_unidade, qtd_estoque, is_active, data_criacao, id_categoria)
VALUES
('Rapé Samaúma', 'Rapé artesanal de Samaúma', 'unidade', 15.00, 100, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Rapé Artesanal')),
('Rapé Sansara', 'Rapé artesanal de Sansara', 'unidade', 16.00, 100, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Rapé Artesanal')),
('Rapé 3 Ervas', 'Rapé artesanal de 3 ervas', 'unidade', 17.00, 100, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Rapé Artesanal')),
('Rapé Cumaru', 'Rapé artesanal de Cumaru', 'unidade', 14.50, 100, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Rapé Artesanal')),
('Rapé Mulateiro', 'Rapé artesanal de Mulateiro', 'unidade', 16.50, 100, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Rapé Artesanal')),
('Rapé Tsunu', 'Rapé artesanal de Tsunu', 'unidade', 18.00, 100, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Rapé Artesanal')),
('Rapé Jurema Preta', 'Rapé artesanal de Jurema Preta', 'unidade', 19.00, 100, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Rapé Artesanal')),
('Rapé Copaíba', 'Rapé artesanal de Copaíba', 'unidade', 20.00, 100, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Rapé Artesanal'));

-- Inserir Produtos para Santo Cruzeiro
INSERT INTO produtos (nome_produto, descricao, unidade, preco_unidade, qtd_estoque, is_active, data_criacao, id_categoria)
VALUES
('Santo Cruzeiro Oxum', 'Santo Cruzeiro dedicado a Oxum', 'unidade', 25.00, 30, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Santo Cruzeiro')),
('Santo Cruzeiro Xangô', 'Santo Cruzeiro dedicado a Xangô', 'unidade', 26.00, 30, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Santo Cruzeiro')),
('Santo Cruzeiro Yemanjá', 'Santo Cruzeiro dedicado a Yemanjá', 'unidade', 27.00, 30, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Santo Cruzeiro')),
('Santo Cruzeiro Yansã', 'Santo Cruzeiro dedicado a Yansã', 'unidade', 28.00, 30, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Santo Cruzeiro')),
('Santo Cruzeiro Omollu', 'Santo Cruzeiro dedicado a Omollu', 'unidade', 29.00, 30, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Santo Cruzeiro')),
('Santo Cruzeiro Exu', 'Santo Cruzeiro dedicado a Exu', 'unidade', 30.00, 30, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Santo Cruzeiro'));

-- Inserir Produtos para Guia
INSERT INTO produtos (nome_produto, descricao, unidade, preco_unidade, qtd_estoque, is_active, data_criacao, id_categoria)
VALUES
('Guia Caboclo', 'Guia artesanal dedicada ao Caboclo', 'unidade', 20.00, 40, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Guia')),
('Guia Exu', 'Guia artesanal dedicada a Exu', 'unidade', 22.00, 40, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Guia')),
('Guia Boiadeiro', 'Guia artesanal dedicada ao Boiadeiro', 'unidade', 24.00, 40, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Guia')),
('Guia Pombo Gira', 'Guia artesanal dedicada a Pombo Gira', 'unidade', 23.00, 40, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Guia')),
('Guia Preto Velho', 'Guia artesanal dedicada ao Preto Velho', 'unidade', 25.00, 40, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Guia')),
('Guia Cigano', 'Guia artesanal dedicada ao Cigano', 'unidade', 26.00, 40, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Guia'));

-- Inserir Produtos para Difusor de Ambiente
INSERT INTO produtos (nome_produto, descricao, unidade, preco_unidade, qtd_estoque, is_active, data_criacao, id_categoria)
VALUES
('Difusor Eucalipto', 'Difusor de ambiente com essência de eucalipto', 'unidade', 30.00, 50, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Difusor de Ambiente')),
('Difusor Cascas e Folhas Secas', 'Difusor de ambiente com cascas e folhas secas', 'unidade', 32.00, 50, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Difusor de Ambiente')),
('Difusor Jaboticaba', 'Difusor de ambiente com essência de jaboticaba', 'unidade', 33.00, 50, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Difusor de Ambiente')),
('Difusor Alecrim', 'Difusor de ambiente com essência de alecrim', 'unidade', 34.00, 50, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Difusor de Ambiente')),
('Difusor Arruda', 'Difusor de ambiente com essência de arruda', 'unidade', 35.00, 50, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Difusor de Ambiente'));

-- Inserir Produtos para Creme Hidratante
INSERT INTO produtos (nome_produto, descricao, unidade, preco_unidade, qtd_estoque, is_active, data_criacao, id_categoria)
VALUES
('Creme Hidratante Lavanda', 'Creme hidratante com essência de lavanda', 'unidade', 40.00, 60, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Creme Hidratante')),
('Creme Hidratante Alecrim', 'Creme hidratante com essência de alecrim', 'unidade', 42.00, 60, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Creme Hidratante')),
('Creme Hidratante Arruda', 'Creme hidratante com essência de arruda', 'unidade', 41.50, 60, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Creme Hidratante')),
('Creme Hidratante Camomila', 'Creme hidratante com essência de camomila', 'unidade', 43.00, 60, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Creme Hidratante'));

-- Inserir Produtos para Mistura de Ervas
INSERT INTO produtos (nome_produto, descricao, unidade, preco_unidade, qtd_estoque, is_active, data_criacao, id_categoria)
VALUES
('Mistura de Ervas Jurema', 'Mistura de ervas artesanais de Jurema', 'unidade', 50.00, 70, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Mistura de Ervas (Jurema)'));

-- Inserir Produtos para Terço
INSERT INTO produtos (nome_produto, descricao, unidade, preco_unidade, qtd_estoque, is_active, data_criacao, id_categoria)
VALUES
('Terço Preto Velho', 'Terço artesanal dedicado ao Preto Velho', 'unidade', 15.00, 80, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Terço')),
('Terço São Bento', 'Terço artesanal dedicado a São Bento', 'unidade', 16.00, 80, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Terço')),
('Terço Sagrada Família', 'Terço artesanal dedicado à Sagrada Família', 'unidade', 17.00, 80, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Terço')),
('Terço São Jorge', 'Terço artesanal dedicado a São Jorge', 'unidade', 18.00, 80, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Terço')),
('Terço Imaculado Coração de Maria', 'Terço artesanal dedicado ao Imaculado Coração de Maria', 'unidade', 19.00, 80, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Terço'));

-- Inserir Produtos para Kuripe
INSERT INTO produtos (nome_produto, descricao, unidade, preco_unidade, qtd_estoque, is_active, data_criacao, id_categoria)
VALUES
('Kuripe', 'Kuripe artesanal para aplicação de rapé', 'unidade', 25.00, 90, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Kuripe'));

-- Inserir Produtos para Tepi
INSERT INTO produtos (nome_produto, descricao, unidade, preco_unidade, qtd_estoque, is_active, data_criacao, id_categoria)
VALUES
('Tepi', 'Tepi artesanal para aplicação de rapé', 'unidade', 30.00, 90, 1, GETDATE(), (SELECT id_categoria FROM categorias WHERE nome_categoria = 'Tepi'));


select* from produtos
select * from categorias


-- Alterar o tamanho das colunas de telefone para 15 caracteres
ALTER TABLE pessoas
ALTER COLUMN tel1_pessoa NVARCHAR(16) NOT NULL;

ALTER TABLE pessoas
ALTER COLUMN tel2_pessoa NVARCHAR(16);



INSERT INTO pessoas (tipo_pessoa, nome_pessoa, email_pessoa, endereco_pessoa, tel1_pessoa, tel2_pessoa, data_nascimento)
VALUES
('F', 'Carlos Souza', 'carlos.souza@example.com', 'Av. Paulista, 101', '(12) 91000-1001', '(12) 92000-1001', '1981-02-12'),
('F', 'Fernanda Oliveira', 'fernanda.oliveira@example.com', 'Rua Bela Vista, 102', '(13) 91000-1002', '(13) 92000-1002', '1982-03-13'),
('F', 'João Almeida', 'joão.almeida@example.com', 'Rua Nova, 103', '(14) 91000-1003', '(14) 92000-1003', '1983-04-14'),
('F', 'Mariana Santos', 'mariana.santos@example.com', 'Av. Central, 104', '(15) 91000-1004', '(15) 92000-1004', '1984-05-15'),
('F', 'Rodrigo Batista', 'rodrigo.batista@example.com', 'Rua das Palmeiras, 105', '(16) 91000-1005', '(16) 92000-1005', '1985-06-16'),
('F', 'Tatiana Castro', 'tatiana.castro@example.com', 'Rua Aurora, 106', '(17) 91000-1006', '(17) 92000-1006', '1986-07-17'),
('F', 'Gabriel Ferreira', 'gabriel.ferreira@example.com', 'Av. do Sol, 107', '(18) 91000-1007', '(18) 92000-1007', '1987-08-18'),
('F', 'Luciana Pereira', 'luciana.pereira@example.com', 'Rua Verde, 108', '(19) 91000-1008', '(19) 92000-1008', '1988-09-19'),
('F', 'Bruno Lima', 'bruno.lima@example.com', 'Av. Azul, 109', '(20) 91000-1009', '(20) 92000-1009', '1989-01-11'),
('F', 'Juliana Alves', 'juliana.alves@example.com', 'Rua dos Pinhais, 110', '(11) 91000-1010', '(11) 92000-1010', '1980-02-12'),
('F', 'Pedro Henrique', 'pedro.henrique@example.com', 'Av. Independência, 111', '(12) 91000-1011', '(12) 92000-1011', '1981-03-13'),
('F', 'Bianca Monteiro', 'bianca.monteiro@example.com', 'Rua Nova Esperança, 112', '(13) 91000-1012', '(13) 92000-1012', '1982-04-14'),
('F', 'Ricardo Lopes', 'ricardo.lopes@example.com', 'Rua da Alegria, 113', '(14) 91000-1013', '(14) 92000-1013', '1983-05-15'),
('F', 'Patrícia Mendes', 'patrícia.mendes@example.com', 'Av. Brasil, 114', '(15) 91000-1014', '(15) 92000-1014', '1984-06-16'),
('F', 'Leonardo Martins', 'leonardo.martins@example.com', 'Rua Estrela, 115', '(16) 91000-1015', '(16) 92000-1015', '1985-07-17'),
('F', 'Sofia Vieira', 'sofia.vieira@example.com', 'Rua do Campo, 116', '(17) 91000-1016', '(17) 92000-1016', '1986-08-18'),
('F', 'Caio Moreira', 'caio.moreira@example.com', 'Av. Europa, 117', '(18) 91000-1017', '(18) 92000-1017', '1987-09-19'),
('F', 'Eduarda Barros', 'eduarda.barros@example.com', 'Rua Esperança, 118', '(19) 91000-1018', '(19) 92000-1018', '1988-01-11'),
('F', 'Rafael Gomes', 'rafael.gomes@example.com', 'Av. América, 119', '(20) 91000-1019', '(20) 92000-1019', '1989-02-12'),
('F', 'Ana Silva', 'ana.silva@example.com', 'Rua das Flores, 120', '(11) 91000-1020', '(11) 92000-1020', '1980-03-13'),
('F', 'Carlos Souza', 'carlos.souza@example.com', 'Av. Paulista, 121', '(12) 91000-1021', '(12) 92000-1021', '1981-04-14'),
('F', 'Fernanda Oliveira', 'fernanda.oliveira@example.com', 'Rua Bela Vista, 122', '(13) 91000-1022', '(13) 92000-1022', '1982-05-15'),
('F', 'João Almeida', 'joão.almeida@example.com', 'Rua Nova, 123', '(14) 91000-1023', '(14) 92000-1023', '1983-06-16'),
('F', 'Mariana Santos', 'mariana.santos@example.com', 'Av. Central, 124', '(15) 91000-1024', '(15) 92000-1024', '1984-07-17'),
('F', 'Rodrigo Batista', 'rodrigo.batista@example.com', 'Rua das Palmeiras, 125', '(16) 91000-1025', '(16) 92000-1025', '1985-08-18'),
('F', 'Tatiana Castro', 'tatiana.castro@example.com', 'Rua Aurora, 126', '(17) 91000-1026', '(17) 92000-1026', '1986-09-19'),
('F', 'Gabriel Ferreira', 'gabriel.ferreira@example.com', 'Av. do Sol, 127', '(18) 91000-1027', '(18) 92000-1027', '1987-01-11'),
('F', 'Luciana Pereira', 'luciana.pereira@example.com', 'Rua Verde, 128', '(19) 91000-1028', '(19) 92000-1028', '1988-02-12'),
('F', 'Bruno Lima', 'bruno.lima@example.com', 'Av. Azul, 129', '(20) 91000-1029', '(20) 92000-1029', '1989-03-13'),
('F', 'Juliana Alves', 'juliana.alves@example.com', 'Rua dos Pinhais, 130', '(11) 91000-1030', '(11) 92000-1030', '1980-04-14'),
('F', 'Pedro Henrique', 'pedro.henrique@example.com', 'Av. Independência, 131', '(12) 91000-1031', '(12) 92000-1031', '1981-05-15'),
('F', 'Bianca Monteiro', 'bianca.monteiro@example.com', 'Rua Nova Esperança, 132', '(13) 91000-1032', '(13) 92000-1032', '1982-06-16'),
('F', 'Ricardo Lopes', 'ricardo.lopes@example.com', 'Rua da Alegria, 133', '(14) 91000-1033', '(14) 92000-1033', '1983-07-17'),
('F', 'Patrícia Mendes', 'patrícia.mendes@example.com', 'Av. Brasil, 134', '(15) 91000-1034', '(15) 92000-1034', '1984-08-18'),
('F', 'Leonardo Martins', 'leonardo.martins@example.com', 'Rua Estrela, 135', '(16) 91000-1035', '(16) 92000-1035', '1985-09-19'),
('F', 'Sofia Vieira', 'sofia.vieira@example.com', 'Rua do Campo, 136', '(17) 91000-1036', '(17) 92000-1036', '1986-01-11'),
('F', 'Caio Moreira', 'caio.moreira@example.com', 'Av. Europa, 137', '(18) 91000-1037', '(18) 92000-1037', '1987-02-12'),
('F', 'Eduarda Barros', 'eduarda.barros@example.com', 'Rua Esperança, 138', '(19) 91000-1038', '(19) 92000-1038', '1988-03-13'),
('F', 'Rafael Gomes', 'rafael.gomes@example.com', 'Av. América, 139', '(20) 91000-1039', '(20) 92000-1039', '1989-04-14'),
('F', 'Ana Silva', 'ana.silva@example.com', 'Rua das Flores, 140', '(11) 91000-1040', '(11) 92000-1040', '1980-05-15'),
('F', 'Carlos Souza', 'carlos.souza@example.com', 'Av. Paulista, 141', '(12) 91000-1041', '(12) 92000-1041', '1981-06-16'),
('F', 'Fernanda Oliveira', 'fernanda.oliveira@example.com', 'Rua Bela Vista, 142', '(13) 91000-1042', '(13) 92000-1042', '1982-07-17'),
('F', 'João Almeida', 'joão.almeida@example.com', 'Rua Nova, 143', '(14) 91000-1043', '(14) 92000-1043', '1983-08-18'),
('F', 'Mariana Santos', 'mariana.santos@example.com', 'Av. Central, 144', '(15) 91000-1044', '(15) 92000-1044', '1984-09-19'),
('F', 'Rodrigo Batista', 'rodrigo.batista@example.com', 'Rua das Palmeiras, 145', '(16) 91000-1045', '(16) 92000-1045', '1985-01-11'),
('F', 'Tatiana Castro', 'tatiana.castro@example.com', 'Rua Aurora, 146', '(17) 91000-1046', '(17) 92000-1046', '1986-02-12'),
('F', 'Gabriel Ferreira', 'gabriel.ferreira@example.com', 'Av. do Sol, 147', '(18) 91000-1047', '(18) 92000-1047', '1987-03-13'),
('F', 'Luciana Pereira', 'luciana.pereira@example.com', 'Rua Verde, 148', '(19) 91000-1048', '(19) 92000-1048', '1988-04-14'),
('F', 'Bruno Lima', 'bruno.lima@example.com', 'Av. Azul, 149', '(20) 91000-1049', '(20) 92000-1049', '1989-05-15'),
('F', 'Juliana Alves', 'juliana.alves@example.com', 'Rua dos Pinhais, 150', '(11) 91000-1050', '(11) 92000-1050', '1980-06-16'),
('F', 'Pedro Henrique', 'pedro.henrique@example.com', 'Av. Independência, 151', '(12) 91000-1051', '(12) 92000-1051', '1981-07-17'),
('F', 'Bianca Monteiro', 'bianca.monteiro@example.com', 'Rua Nova Esperança, 152', '(13) 91000-1052', '(13) 92000-1052', '1982-08-18'),
('F', 'Ricardo Lopes', 'ricardo.lopes@example.com', 'Rua da Alegria, 153', '(14) 91000-1053', '(14) 92000-1053', '1983-09-19'),
('F', 'Patrícia Mendes', 'patrícia.mendes@example.com', 'Av. Brasil, 154', '(15) 91000-1054', '(15) 92000-1054', '1984-01-11'),
('F', 'Leonardo Martins', 'leonardo.martins@example.com', 'Rua Estrela, 155', '(16) 91000-1055', '(16) 92000-1055', '1985-02-12'),
('F', 'Sofia Vieira', 'sofia.vieira@example.com', 'Rua do Campo, 156', '(17) 91000-1056', '(17) 92000-1056', '1986-03-13'),
('F', 'Caio Moreira', 'caio.moreira@example.com', 'Av. Europa, 157', '(18) 91000-1057', '(18) 92000-1057', '1987-04-14'),
('F', 'Eduarda Barros', 'eduarda.barros@example.com', 'Rua Esperança, 158', '(19) 91000-1058', '(19) 92000-1058', '1988-05-15'),
('F', 'Rafael Gomes', 'rafael.gomes@example.com', 'Av. América, 159', '(20) 91000-1059', '(20) 92000-1059', '1989-06-16'),
('F', 'Ana Silva', 'ana.silva@example.com', 'Rua das Flores, 160', '(11) 91000-1060', '(11) 92000-1060', '1980-07-17'),
('F', 'Carlos Souza', 'carlos.souza@example.com', 'Av. Paulista, 161', '(12) 91000-1061', '(12) 92000-1061', '1981-08-18'),
('F', 'Fernanda Oliveira', 'fernanda.oliveira@example.com', 'Rua Bela Vista, 162', '(13) 91000-1062', '(13) 92000-1062', '1982-09-19'),
('F', 'João Almeida', 'joão.almeida@example.com', 'Rua Nova, 163', '(14) 91000-1063', '(14) 92000-1063', '1983-01-11'),
('F', 'Mariana Santos', 'mariana.santos@example.com', 'Av. Central, 164', '(15) 91000-1064', '(15) 92000-1064', '1984-02-12'),
('F', 'Rodrigo Batista', 'rodrigo.batista@example.com', 'Rua das Palmeiras, 165', '(16) 91000-1065', '(16) 92000-1065', '1985-03-13'),
('F', 'Tatiana Castro', 'tatiana.castro@example.com', 'Rua Aurora, 166', '(17) 91000-1066', '(17) 92000-1066', '1986-04-14'),
('F', 'Gabriel Ferreira', 'gabriel.ferreira@example.com', 'Av. do Sol, 167', '(18) 91000-1067', '(18) 92000-1067', '1987-05-15'),
('F', 'Luciana Pereira', 'luciana.pereira@example.com', 'Rua Verde, 168', '(19) 91000-1068', '(19) 92000-1068', '1988-06-16'),
('F', 'Bruno Lima', 'bruno.lima@example.com', 'Av. Azul, 169', '(20) 91000-1069', '(20) 92000-1069', '1989-07-17'),
('F', 'Juliana Alves', 'juliana.alves@example.com', 'Rua dos Pinhais, 170', '(11) 91000-1070', '(11) 92000-1070', '1980-08-18'),
('F', 'Pedro Henrique', 'pedro.henrique@example.com', 'Av. Independência, 171', '(12) 91000-1071', '(12) 92000-1071', '1981-09-19'),
('F', 'Bianca Monteiro', 'bianca.monteiro@example.com', 'Rua Nova Esperança, 172', '(13) 91000-1072', '(13) 92000-1072', '1982-01-11'),
('F', 'Ricardo Lopes', 'ricardo.lopes@example.com', 'Rua da Alegria, 173', '(14) 91000-1073', '(14) 92000-1073', '1983-02-12'),
('F', 'Patrícia Mendes', 'patrícia.mendes@example.com', 'Av. Brasil, 174', '(15) 91000-1074', '(15) 92000-1074', '1984-03-13'),
('F', 'Leonardo Martins', 'leonardo.martins@example.com', 'Rua Estrela, 175', '(16) 91000-1075', '(16) 92000-1075', '1985-04-14'),
('F', 'Sofia Vieira', 'sofia.vieira@example.com', 'Rua do Campo, 176', '(17) 91000-1076', '(17) 92000-1076', '1986-05-15'),
('F', 'Caio Moreira', 'caio.moreira@example.com', 'Av. Europa, 177', '(18) 91000-1077', '(18) 92000-1077', '1987-06-16'),
('F', 'Eduarda Barros', 'eduarda.barros@example.com', 'Rua Esperança, 178', '(19) 91000-1078', '(19) 92000-1078', '1988-07-17'),
('F', 'Rafael Gomes', 'rafael.gomes@example.com', 'Av. América, 179', '(20) 91000-1079', '(20) 92000-1079', '1989-08-18'),
('F', 'Ana Silva', 'ana.silva@example.com', 'Rua das Flores, 180', '(11) 91000-1080', '(11) 92000-1080', '1980-09-19'),
('F', 'Carlos Souza', 'carlos.souza@example.com', 'Av. Paulista, 181', '(12) 91000-1081', '(12) 92000-1081', '1981-01-11'),
('F', 'Fernanda Oliveira', 'fernanda.oliveira@example.com', 'Rua Bela Vista, 182', '(13) 91000-1082', '(13) 92000-1082', '1982-02-12'),
('F', 'João Almeida', 'joão.almeida@example.com', 'Rua Nova, 183', '(14) 91000-1083', '(14) 92000-1083', '1983-03-13'),
('F', 'Mariana Santos', 'mariana.santos@example.com', 'Av. Central, 184', '(15) 91000-1084', '(15) 92000-1084', '1984-04-14'),
('F', 'Rodrigo Batista', 'rodrigo.batista@example.com', 'Rua das Palmeiras, 185', '(16) 91000-1085', '(16) 92000-1085', '1985-05-15'),
('F', 'Tatiana Castro', 'tatiana.castro@example.com', 'Rua Aurora, 186', '(17) 91000-1086', '(17) 92000-1086', '1986-06-16'),
('F', 'Gabriel Ferreira', 'gabriel.ferreira@example.com', 'Av. do Sol, 187', '(18) 91000-1087', '(18) 92000-1087', '1987-07-17'),
('F', 'Luciana Pereira', 'luciana.pereira@example.com', 'Rua Verde, 188', '(19) 91000-1088', '(19) 92000-1088', '1988-08-18'),
('F', 'Bruno Lima', 'bruno.lima@example.com', 'Av. Azul, 189', '(20) 91000-1089', '(20) 92000-1089', '1989-09-19'),
('F', 'Juliana Alves', 'juliana.alves@example.com', 'Rua dos Pinhais, 190', '(11) 91000-1090', '(11) 92000-1090', '1980-01-11'),
('F', 'Pedro Henrique', 'pedro.henrique@example.com', 'Av. Independência, 191', '(12) 91000-1091', '(12) 92000-1091', '1981-02-12'),
('F', 'Bianca Monteiro', 'bianca.monteiro@example.com', 'Rua Nova Esperança, 192', '(13) 91000-1092', '(13) 92000-1092', '1982-03-13'),
('F', 'Ricardo Lopes', 'ricardo.lopes@example.com', 'Rua da Alegria, 193', '(14) 91000-1093', '(14) 92000-1093', '1983-04-14'),
('F', 'Patrícia Mendes', 'patrícia.mendes@example.com', 'Av. Brasil, 194', '(15) 91000-1094', '(15) 92000-1094', '1984-05-15'),
('F', 'Leonardo Martins', 'leonardo.martins@example.com', 'Rua Estrela, 195', '(16) 91000-1095', '(16) 92000-1095', '1985-06-16'),
('F', 'Sofia Vieira', 'sofia.vieira@example.com', 'Rua do Campo, 196', '(17) 91000-1096', '(17) 92000-1096', '1986-07-17'),
('F', 'Caio Moreira', 'caio.moreira@example.com', 'Av. Europa, 197', '(18) 91000-1097', '(18) 92000-1097', '1987-08-18'),
('F', 'Eduarda Barros', 'eduarda.barros@example.com', 'Rua Esperança, 198', '(19) 91000-1098', '(19) 92000-1098', '1988-09-19'),
('F', 'Rafael Gomes', 'rafael.gomes@example.com', 'Av. América, 199', '(20) 91000-1099', '(20) 92000-1099', '1989-01-11'),
('F', 'Ana Silva', 'ana.silva@example.com', 'Rua das Flores, 200', '(11) 91000-1100', '(11) 92000-1100', '1980-02-12'),
('F', 'Carlos Souza', 'carlos.souza@example.com', 'Av. Paulista, 201', '(12) 91000-1101', '(12) 92000-1101', '1981-03-13'),
('F', 'Fernanda Oliveira', 'fernanda.oliveira@example.com', 'Rua Bela Vista, 202', '(13) 91000-1102', '(13) 92000-1102', '1982-04-14'),
('F', 'João Almeida', 'joão.almeida@example.com', 'Rua Nova, 203', '(14) 91000-1103', '(14) 92000-1103', '1983-05-15'),
('F', 'Mariana Santos', 'mariana.santos@example.com', 'Av. Central, 204', '(15) 91000-1104', '(15) 92000-1104', '1984-06-16'),
('F', 'Rodrigo Batista', 'rodrigo.batista@example.com', 'Rua das Palmeiras, 205', '(16) 91000-1105', '(16) 92000-1105', '1985-07-17'),
('F', 'Tatiana Castro', 'tatiana.castro@example.com', 'Rua Aurora, 206', '(17) 91000-1106', '(17) 92000-1106', '1986-08-18'),
('F', 'Gabriel Ferreira', 'gabriel.ferreira@example.com', 'Av. do Sol, 207', '(18) 91000-1107', '(18) 92000-1107', '1987-09-19'),
('F', 'Luciana Pereira', 'luciana.pereira@example.com', 'Rua Verde, 208', '(19) 91000-1108', '(19) 92000-1108', '1988-01-11'),
('F', 'Bruno Lima', 'bruno.lima@example.com', 'Av. Azul, 209', '(20) 91000-1109', '(20) 92000-1109', '1989-02-12'),
('F', 'Juliana Alves', 'juliana.alves@example.com', 'Rua dos Pinhais, 210', '(11) 91000-1110', '(11) 92000-1110', '1980-03-13'),
('F', 'Pedro Henrique', 'pedro.henrique@example.com', 'Av. Independência, 211', '(12) 91000-1111', '(12) 92000-1111', '1981-04-14'),
('F', 'Bianca Monteiro', 'bianca.monteiro@example.com', 'Rua Nova Esperança, 212', '(13) 91000-1112', '(13) 92000-1112', '1982-05-15'),
('F', 'Ricardo Lopes', 'ricardo.lopes@example.com', 'Rua da Alegria, 213', '(14) 91000-1113', '(14) 92000-1113', '1983-06-16'),
('F', 'Patrícia Mendes', 'patrícia.mendes@example.com', 'Av. Brasil, 214', '(15) 91000-1114', '(15) 92000-1114', '1984-07-17'),
('F', 'Leonardo Martins', 'leonardo.martins@example.com', 'Rua Estrela, 215', '(16) 91000-1115', '(16) 92000-1115', '1985-08-18'),
('F', 'Sofia Vieira', 'sofia.vieira@example.com', 'Rua do Campo, 216', '(17) 91000-1116', '(17) 92000-1116', '1986-09-19'),
('F', 'Caio Moreira', 'caio.moreira@example.com', 'Av. Europa, 217', '(18) 91000-1117', '(18) 92000-1117', '1987-01-11'),
('F', 'Eduarda Barros', 'eduarda.barros@example.com', 'Rua Esperança, 218', '(19) 91000-1118', '(19) 92000-1118', '1988-02-12'),
('F', 'Rafael Gomes', 'rafael.gomes@example.com', 'Av. América, 219', '(20) 91000-1119', '(20) 92000-1119', '1989-03-13'),
('F', 'Ana Silva', 'ana.silva@example.com', 'Rua das Flores, 220', '(11) 91000-1120', '(11) 92000-1120', '1980-04-14'),
('F', 'Carlos Souza', 'carlos.souza@example.com', 'Av. Paulista, 221', '(12) 91000-1121', '(12) 92000-1121', '1981-05-15'),
('F', 'Fernanda Oliveira', 'fernanda.oliveira@example.com', 'Rua Bela Vista, 222', '(13) 91000-1122', '(13) 92000-1122', '1982-06-16'),
('F', 'João Almeida', 'joão.almeida@example.com', 'Rua Nova, 223', '(14) 91000-1123', '(14) 92000-1123', '1983-07-17'),
('F', 'Mariana Santos', 'mariana.santos@example.com', 'Av. Central, 224', '(15) 91000-1124', '(15) 92000-1124', '1984-08-18'),
('F', 'Rodrigo Batista', 'rodrigo.batista@example.com', 'Rua das Palmeiras, 225', '(16) 91000-1125', '(16) 92000-1125', '1985-09-19'),
('F', 'Tatiana Castro', 'tatiana.castro@example.com', 'Rua Aurora, 226', '(17) 91000-1126', '(17) 92000-1126', '1986-01-11'),
('F', 'Gabriel Ferreira', 'gabriel.ferreira@example.com', 'Av. do Sol, 227', '(18) 91000-1127', '(18) 92000-1127', '1987-02-12'),
('F', 'Luciana Pereira', 'luciana.pereira@example.com', 'Rua Verde, 228', '(19) 91000-1128', '(19) 92000-1128', '1988-03-13'),
('F', 'Bruno Lima', 'bruno.lima@example.com', 'Av. Azul, 229', '(20) 91000-1129', '(20) 92000-1129', '1989-04-14'),
('F', 'Juliana Alves', 'juliana.alves@example.com', 'Rua dos Pinhais, 230', '(11) 91000-1130', '(11) 92000-1130', '1980-05-15'),
('F', 'Pedro Henrique', 'pedro.henrique@example.com', 'Av. Independência, 231', '(12) 91000-1131', '(12) 92000-1131', '1981-06-16'),
('F', 'Bianca Monteiro', 'bianca.monteiro@example.com', 'Rua Nova Esperança, 232', '(13) 91000-1132', '(13) 92000-1132', '1982-07-17'),
('F', 'Ricardo Lopes', 'ricardo.lopes@example.com', 'Rua da Alegria, 233', '(14) 91000-1133', '(14) 92000-1133', '1983-08-18'),
('F', 'Patrícia Mendes', 'patrícia.mendes@example.com', 'Av. Brasil, 234', '(15) 91000-1134', '(15) 92000-1134', '1984-09-19'),
('F', 'Leonardo Martins', 'leonardo.martins@example.com', 'Rua Estrela, 235', '(16) 91000-1135', '(16) 92000-1135', '1985-01-11'),
('F', 'Sofia Vieira', 'sofia.vieira@example.com', 'Rua do Campo, 236', '(17) 91000-1136', '(17) 92000-1136', '1986-02-12'),
('F', 'Caio Moreira', 'caio.moreira@example.com', 'Av. Europa, 237', '(18) 91000-1137', '(18) 92000-1137', '1987-03-13'),
('F', 'Eduarda Barros', 'eduarda.barros@example.com', 'Rua Esperança, 238', '(19) 91000-1138', '(19) 92000-1138', '1988-04-14'),
('F', 'Rafael Gomes', 'rafael.gomes@example.com', 'Av. América, 239', '(20) 91000-1139', '(20) 92000-1139', '1989-05-15'),
('F', 'Ana Silva', 'ana.silva@example.com', 'Rua das Flores, 240', '(11) 91000-1140', '(11) 92000-1140', '1980-06-16'),
('F', 'Carlos Souza', 'carlos.souza@example.com', 'Av. Paulista, 241', '(12) 91000-1141', '(12) 92000-1141', '1981-07-17'),
('F', 'Fernanda Oliveira', 'fernanda.oliveira@example.com', 'Rua Bela Vista, 242', '(13) 91000-1142', '(13) 92000-1142', '1982-08-18'),
('F', 'João Almeida', 'joão.almeida@example.com', 'Rua Nova, 243', '(14) 91000-1143', '(14) 92000-1143', '1983-09-19'),
('F', 'Mariana Santos', 'mariana.santos@example.com', 'Av. Central, 244', '(15) 91000-1144', '(15) 92000-1144', '1984-01-11'),
('F', 'Rodrigo Batista', 'rodrigo.batista@example.com', 'Rua das Palmeiras, 245', '(16) 91000-1145', '(16) 92000-1145', '1985-02-12'),
('F', 'Tatiana Castro', 'tatiana.castro@example.com', 'Rua Aurora, 246', '(17) 91000-1146', '(17) 92000-1146', '1986-03-13'),
('F', 'Gabriel Ferreira', 'gabriel.ferreira@example.com', 'Av. do Sol, 247', '(18) 91000-1147', '(18) 92000-1147', '1987-04-14'),
('F', 'Luciana Pereira', 'luciana.pereira@example.com', 'Rua Verde, 248', '(19) 91000-1148', '(19) 92000-1148', '1988-05-15'),
('F', 'Bruno Lima', 'bruno.lima@example.com', 'Av. Azul, 249', '(20) 91000-1149', '(20) 92000-1149', '1989-06-16'),
('F', 'Juliana Alves', 'juliana.alves@example.com', 'Rua dos Pinhais, 250', '(11) 91000-1150', '(11) 92000-1150', '1980-07-17');

select * from pessoas

-- Inserir na tabela pessoas_fisicas
INSERT INTO pessoas_fisicas (id_pessoa, cpf)
VALUES
(1, '001.002.003-07'),
(2, '002.004.006-14'),
(3, '003.006.009-21'),
(4, '004.008.012-28'),
(5, '005.010.015-35'),
(6, '006.012.018-42'),
(7, '007.014.021-49'),
(8, '008.016.024-56'),
(9, '009.018.027-63'),
(10, '010.020.030-70'),
(11, '011.022.033-77'),
(12, '012.024.036-84'),
(13, '013.026.039-91'),
(14, '014.028.042-98'),
(15, '015.030.045-05'),
(16, '016.032.048-12'),
(17, '017.034.051-19'),
(18, '018.036.054-26'),
(19, '019.038.057-33'),
(20, '020.040.060-40'),
(21, '021.042.063-47'),
(22, '022.044.066-54'),
(23, '023.046.069-61'),
(24, '024.048.072-68'),
(25, '025.050.075-75'),
(26, '026.052.078-82'),
(27, '027.054.081-89'),
(28, '028.056.084-96'),
(29, '029.058.087-03'),
(30, '030.060.090-10'),
(31, '031.062.093-17'),
(32, '032.064.096-24'),
(33, '033.066.099-31'),
(34, '034.068.102-38'),
(35, '035.070.105-45'),
(36, '036.072.108-52'),
(37, '037.074.111-59'),
(38, '038.076.114-66'),
(39, '039.078.117-73'),
(40, '040.080.120-80'),
(41, '041.082.123-87'),
(42, '042.084.126-94'),
(43, '043.086.129-01'),
(44, '044.088.132-08'),
(45, '045.090.135-15'),
(46, '046.092.138-22'),
(47, '047.094.141-29'),
(48, '048.096.144-36'),
(49, '049.098.147-43'),
(50, '050.100.150-50'),
(51, '051.102.153-57'),
(52, '052.104.156-64'),
(53, '053.106.159-71'),
(54, '054.108.162-78'),
(55, '055.110.165-85'),
(56, '056.112.168-92'),
(57, '057.114.171-99'),
(58, '058.116.174-06'),
(59, '059.118.177-13'),
(60, '060.120.180-20'),
(61, '061.122.183-27'),
(62, '062.124.186-34'),
(63, '063.126.189-41'),
(64, '064.128.192-48'),
(65, '065.130.195-55'),
(66, '066.132.198-62'),
(67, '067.134.201-69'),
(68, '068.136.204-76'),
(69, '069.138.207-83'),
(70, '070.140.210-90'),
(71, '071.142.213-97'),
(72, '072.144.216-04'),
(73, '073.146.219-11'),
(74, '074.148.222-18'),
(75, '075.150.225-25'),
(76, '076.152.228-32'),
(77, '077.154.231-39'),
(78, '078.156.234-46'),
(79, '079.158.237-53'),
(80, '080.160.240-60'),
(81, '081.162.243-67'),
(82, '082.164.246-74'),
(83, '083.166.249-81'),
(84, '084.168.252-88'),
(85, '085.170.255-95'),
(86, '086.172.258-02'),
(87, '087.174.261-09'),
(88, '088.176.264-16'),
(89, '089.178.267-23'),
(90, '090.180.270-30'),
(91, '091.182.273-37'),
(92, '092.184.276-44'),
(93, '093.186.279-51'),
(94, '094.188.282-58'),
(95, '095.190.285-65'),
(96, '096.192.288-72'),
(97, '097.194.291-79'),
(98, '098.196.294-86'),
(99, '099.198.297-93'),
(100, '100.200.300-00'),
(101, '101.202.303-07'),
(102, '102.204.306-14'),
(103, '103.206.309-21'),
(104, '104.208.312-28'),
(105, '105.210.315-35'),
(106, '106.212.318-42'),
(107, '107.214.321-49'),
(108, '108.216.324-56'),
(109, '109.218.327-63'),
(110, '110.220.330-70'),
(111, '111.222.333-77'),
(112, '112.224.336-84'),
(113, '113.226.339-91'),
(114, '114.228.342-98'),
(115, '115.230.345-05'),
(116, '116.232.348-12'),
(117, '117.234.351-19'),
(118, '118.236.354-26'),
(119, '119.238.357-33'),
(120, '120.240.360-40'),
(121, '121.242.363-47'),
(122, '122.244.366-54'),
(123, '123.246.369-61'),
(124, '124.248.372-68'),
(125, '125.250.375-75'),
(126, '126.252.378-82'),
(127, '127.254.381-89'),
(128, '128.256.384-96'),
(129, '129.258.387-03'),
(130, '130.260.390-10'),
(131, '131.262.393-17'),
(132, '132.264.396-24'),
(133, '133.266.399-31'),
(134, '134.268.402-38'),
(135, '135.270.405-45'),
(136, '136.272.408-52'),
(137, '137.274.411-59'),
(138, '138.276.414-66'),
(139, '139.278.417-73'),
(140, '140.280.420-80'),
(141, '141.282.423-87'),
(142, '142.284.426-94'),
(143, '143.286.429-01'),
(144, '144.288.432-08'),
(145, '145.290.435-15'),
(146, '146.292.438-22'),
(147, '147.294.441-29'),
(148, '148.296.444-36'),
(149, '149.298.447-43'),
(150, '150.300.450-50');

-- Inserir na tabela pessoas (contato da empresa como nome_pessoa)
INSERT INTO pessoas (tipo_pessoa, nome_pessoa, email_pessoa, endereco_pessoa, tel1_pessoa, tel2_pessoa, data_nascimento)
VALUES
('J', 'Alessandro Nunes', 'alessandro.nunes@grupoexcel.com', 'Av. dos Bandeirantes, 123', '(11) 91001-1001', '(11) 92001-1001', '1982-02-14'),
('J', 'Camila Ribeiro', 'camila.ribeiro@futuroverde.com', 'Rua das Árvores, 456', '(21) 91002-2002', '(21) 92002-2002', '1987-06-08'),
('J', 'Renato Lima', 'renato.lima@logexpress.com', 'Av. Industrial, 789', '(31) 91003-3003', '(31) 92003-3003', '1990-11-30'),
('J', 'Jéssica Souza', 'jessica.souza@mundonovo.com', 'Rua Nova Esperança, 101', '(41) 91004-4004', '(41) 92004-4004', '1985-09-15'),
('J', 'Pedro Henrique', 'pedro.henrique@megaeng.com', 'Av. das Indústrias, 222', '(51) 91005-5005', '(51) 92005-5005', '1992-01-01'),
('J', 'Letícia Alves', 'leticia.alves@vidamais.com', 'Rua Bem Estar, 333', '(61) 91006-6006', '(61) 92006-6006', '1983-08-22'),
('J', 'Vinícius Carvalho', 'vinicius.carvalho@techworld.com', 'Av. do Conhecimento, 444', '(71) 91007-7007', '(71) 92007-7007', '1980-12-12'),
('J', 'Patrícia Mendes', 'patricia.mendes@beautyshop.com', 'Rua da Beleza, 555', '(81) 91008-8008', '(81) 92008-8008', '1988-05-09'),
('J', 'Lucas Barros', 'lucas.barros@novaconstrucao.com', 'Av. Nova, 666', '(91) 91009-9009', '(91) 92009-9009', '1981-03-03'),
('J', 'Mariana Oliveira', 'mariana.oliveira@ecoplan.com', 'Rua Sustentável, 777', '(31) 91010-0010', '(31) 92010-0010', '1989-07-19');

-- Inserir na tabela pessoas_juridicas
INSERT INTO pessoas_juridicas (id_pessoa, cnpj, razao_social)
VALUES
(151, '01.123.456/0001-11', 'Grupo Excel Contabilidade LTDA'),
(152, '01.234.567/0002-22', 'Futuro Verde Sustentabilidade ME'),
(153, '01.345.678/0003-33', 'LogExpress Transporte e Logística LTDA'),
(154, '01.456.789/0004-44', 'Mundo Novo Comércio de Produtos LTDA'),
(155, '01.567.890/0005-55', 'MegaEng Engenharia e Projetos SA'),
(156, '01.678.901/0006-66', 'Vida Mais Plano de Saúde LTDA'),
(157, '01.789.012/0007-77', 'TechWorld Soluções em TI EIRELI'),
(158, '01.890.123/0008-88', 'BeautyShop Cosméticos LTDA'),
(159, '01.901.234/0009-99', 'Nova Construção Engenharia LTDA'),
(160, '01.012.345/0010-10', 'EcoPlan Consultoria Ambiental SA');

-- Continue até atingir 40 registros adicionais
INSERT INTO pessoas (tipo_pessoa, nome_pessoa, email_pessoa, endereco_pessoa, tel1_pessoa, tel2_pessoa, data_nascimento)
VALUES
('J', 'Thiago Martins', 'thiago.martins@autopecasbrasil.com', 'Rua Principal, 888', '(11) 91011-1111', '(11) 92011-1111', '1991-11-11'),
('J', 'Fabiana Duarte', 'fabiana.duarte@medicare.com', 'Av. Saúde, 999', '(21) 91012-1212', '(21) 92012-1212', '1986-12-25');

INSERT INTO pessoas_juridicas (id_pessoa, cnpj, razao_social)
VALUES
(161, '02.123.456/0011-11', 'AutoPeças Brasil LTDA'),
(162, '02.234.567/0012-22', 'MediCare Planos de Saúde ME');


-- Inserir na tabela pessoas (contato da empresa como nome_pessoa)
INSERT INTO pessoas (tipo_pessoa, nome_pessoa, email_pessoa, endereco_pessoa, tel1_pessoa, tel2_pessoa, data_nascimento)
VALUES
('J', 'Eduardo Faria', 'eduardo.faria@logisticaavancada.com', 'Rua do Progresso, 102', '(31) 91013-1313', '(31) 92013-1313', '1985-08-18'),
('J', 'Juliana Alves', 'juliana.alves@fastsolutions.com', 'Av. das Nações, 203', '(41) 91014-1414', '(41) 92014-1414', '1993-09-27'),
('J', 'Felipe Costa', 'felipe.costa@redetrans.com', 'Rua do Comércio, 304', '(51) 91015-1515', '(51) 92015-1515', '1987-06-14'),
('J', 'Carolina Soares', 'carolina.soares@eletrotec.com', 'Av. do Trabalho, 405', '(61) 91016-1616', '(61) 92016-1616', '1991-12-07'),
('J', 'Rafael Teixeira', 'rafael.teixeira@megatools.com', 'Rua das Ferramentas, 506', '(71) 91017-1717', '(71) 92017-1717', '1989-03-21'),
('J', 'Bianca Nogueira', 'bianca.nogueira@industriabr.com', 'Av. da Produção, 607', '(81) 91018-1818', '(81) 92018-1818', '1984-10-15'),
('J', 'Gustavo Pereira', 'gustavo.pereira@servicosglobais.com', 'Rua Global, 708', '(91) 91019-1919', '(91) 92019-1919', '1982-05-20'),
('J', 'Fernanda Rocha', 'fernanda.rocha@novainformatica.com', 'Av. Tecnologia, 809', '(11) 91020-2020', '(11) 92020-2020', '1990-07-13'),
('J', 'Ricardo Monteiro', 'ricardo.monteiro@armazensbrasil.com', 'Rua dos Armazéns, 910', '(21) 91021-2121', '(21) 92021-2121', '1983-04-25'),
('J', 'Sofia Menezes', 'sofia.menezes@comercialprime.com', 'Av. Principal, 101', '(31) 91022-2222', '(31) 92022-2222', '1986-02-10'),
('J', 'Leonardo Vieira', 'leonardo.vieira@transportetech.com', 'Rua Nova, 202', '(41) 91023-2323', '(41) 92023-2323', '1988-06-30'),
('J', 'Isabela Duarte', 'isabela.duarte@consultingbr.com', 'Av. do Sucesso, 303', '(51) 91024-2424', '(51) 92024-2424', '1992-11-18'),
('J', 'Daniel Almeida', 'daniel.almeida@solucoesltda.com', 'Rua da Empresa, 404', '(61) 91025-2525', '(61) 92025-2525', '1980-03-04'),
('J', 'Aline Martins', 'aline.martins@automotiveltda.com', 'Av. das Máquinas, 505', '(71) 91026-2626', '(71) 92026-2626', '1984-08-29'),
('J', 'Victor Carvalho', 'victor.carvalho@constructionbr.com', 'Rua Construtora, 606', '(81) 91027-2727', '(81) 92027-2727', '1991-01-01'),
('J', 'Beatriz Souza', 'beatriz.souza@logisbrasil.com', 'Av. Transporte, 707', '(91) 91028-2828', '(91) 92028-2828', '1987-05-15'),
('J', 'Alexandre Lima', 'alexandre.lima@industriamega.com', 'Rua das Indústrias, 808', '(11) 91029-2929', '(11) 92029-2929', '1985-09-09'),
('J', 'Mariana Batista', 'mariana.batista@fastcommerce.com', 'Av. Comercial, 909', '(21) 91030-3030', '(21) 92030-3030', '1989-12-31'),
('J', 'Henrique Silva', 'henrique.silva@produtotop.com', 'Rua da Produção, 111', '(31) 91031-3131', '(31) 92031-3131', '1993-07-07');

-- Inserir na tabela pessoas_juridicas
INSERT INTO pessoas_juridicas (id_pessoa, cnpj, razao_social)
VALUES
(163, '02.345.678/0013-33', 'Logística Avançada LTDA'),
(164, '02.456.789/0014-44', 'Fast Solutions TI EIRELI'),
(165, '02.567.890/0015-55', 'RedeTrans Transporte SA'),
(166, '02.678.901/0016-66', 'Eletrotec Eletrônicos LTDA'),
(167, '02.789.012/0017-77', 'MegaTools Ferramentas LTDA'),
(168, '02.890.123/0018-88', 'Indústria Brasil S/A'),
(169, '02.901.234/0019-99', 'Serviços Globais LTDA'),
(170, '02.012.345/0020-00', 'Nova Informática LTDA'),
(171, '02.123.456/0021-11', 'Armazéns Brasil S/A'),
(172, '02.234.567/0022-22', 'Comercial Prime Comércio LTDA'),
(173, '02.345.678/0023-33', 'TransporteTech LTDA'),
(174, '02.456.789/0024-44', 'Consulting Brasil ME'),
(175, '02.567.890/0025-55', 'Soluções LTDA'),
(176, '02.678.901/0026-66', 'Automotiva Máquinas LTDA'),
(177, '02.789.012/0027-77', 'Construction Brasil SA'),
(178, '02.890.123/0028-88', 'Logis Brasil EIRELI'),
(179, '02.901.234/0029-99', 'Indústria Mega LTDA'),
(180, '02.012.345/0030-00', 'Fast Commerce LTDA'),
(181, '02.123.456/0031-11', 'Produto Top Comércio ME');

-- Inserir na tabela pessoas (contato da empresa como nome_pessoa)
INSERT INTO pessoas (tipo_pessoa, nome_pessoa, email_pessoa, endereco_pessoa, tel1_pessoa, tel2_pessoa, data_nascimento)
VALUES
('J', 'Paulo Henrique', 'paulo.henrique@supertech.com', 'Rua do Futuro, 112', '(31) 91032-3232', '(31) 92032-3232', '1984-02-25'),
('J', 'Renata Lima', 'renata.lima@greenenergy.com', 'Av. das Águas, 213', '(41) 91033-3333', '(41) 92033-3333', '1990-08-12'),
('J', 'Sérgio Nogueira', 'sergio.nogueira@brasilfood.com', 'Rua da Alimentação, 314', '(51) 91034-3434', '(51) 92034-3434', '1987-01-18'),
('J', 'Camila Rodrigues', 'camila.rodrigues@meditech.com', 'Av. Saúde, 415', '(61) 91035-3535', '(61) 92035-3535', '1993-11-03'),
('J', 'Diego Ribeiro', 'diego.ribeiro@seguranet.com', 'Rua Proteção, 516', '(71) 91036-3636', '(71) 92036-3636', '1989-05-22'),
('J', 'Larissa Carvalho', 'larissa.carvalho@brasilmovel.com', 'Av. Design, 617', '(81) 91037-3737', '(81) 92037-3737', '1991-10-16'),
('J', 'Marcelo Almeida', 'marcelo.almeida@petrolbrasil.com', 'Rua Energia, 718', '(91) 91038-3838', '(91) 92038-3838', '1985-07-27'),
('J', 'Patrícia Souza', 'patricia.souza@cosmeticosbrasil.com', 'Av. Beleza, 819', '(11) 91039-3939', '(11) 92039-3939', '1988-09-11'),
('J', 'Lucas Barbosa', 'lucas.barbosa@brtecno.com', 'Rua Inovação, 920', '(21) 91040-4040', '(21) 92040-4040', '1983-06-05'),
('J', 'Juliana Mendes', 'juliana.mendes@telecombr.com', 'Av. Comunicação, 101', '(31) 91041-4141', '(31) 92041-4141', '1992-03-22'),
('J', 'Rafael Moreira', 'rafael.moreira@infobrasil.com', 'Rua Dados, 202', '(41) 91042-4242', '(41) 92042-4242', '1986-08-30'),
('J', 'Simone Lopes', 'simone.lopes@megaeventos.com', 'Av. Alegria, 303', '(51) 91043-4343', '(51) 92043-4343', '1994-01-15'),
('J', 'Thiago Santos', 'thiago.santos@construtoragiga.com', 'Rua Edificação, 404', '(61) 91044-4444', '(61) 92044-4444', '1982-04-10'),
('J', 'Isabela Rocha', 'isabela.rocha@agrobrasil.com', 'Av. Campo Verde, 505', '(71) 91045-4545', '(71) 92045-4545', '1989-11-25'),
('J', 'Vinícius Martins', 'vinicius.martins@brasilviagens.com', 'Rua Descobertas, 606', '(81) 91046-4646', '(81) 92046-4646', '1990-12-31'),
('J', 'Natália Costa', 'natalia.costa@financeirobr.com', 'Av. Investimentos, 707', '(91) 91047-4747', '(91) 92047-4747', '1987-09-18'),
('J', 'Rodrigo Vieira', 'rodrigo.vieira@saudedobrasil.com', 'Rua Bem Estar, 808', '(11) 91048-4848', '(11) 92048-4848', '1984-02-01'),
('J', 'Adriana Teixeira', 'adriana.teixeira@modatech.com', 'Av. Estilo, 909', '(21) 91049-4949', '(21) 92049-4949', '1995-03-11'),
('J', 'Fernando Silva', 'fernando.silva@brasilenergia.com', 'Rua Sustentável, 101', '(31) 91050-5050', '(31) 92050-5050', '1991-10-07');

-- Inserir na tabela pessoas_juridicas
INSERT INTO pessoas_juridicas (id_pessoa, cnpj, razao_social)
VALUES
(182, '03.345.678/0032-33', 'SuperTech Inovações LTDA'),
(183, '03.456.789/0033-44', 'Green Energy Sustentável LTDA'),
(184, '03.567.890/0034-55', 'Brasil Food Distribuição EIRELI'),
(185, '03.678.901/0035-66', 'MediTech Saúde EIRELI'),
(186, '03.789.012/0036-77', 'SeguraNet Segurança LTDA'),
(187, '03.890.123/0037-88', 'Brasil Móveis e Design SA'),
(188, '03.901.234/0038-99', 'Petrol Brasil Energia EIRELI'),
(189, '03.012.345/0039-00', 'Cosméticos Brasil ME'),
(190, '03.123.456/0040-11', 'BR Tecno Tecnologia LTDA'),
(191, '03.234.567/0041-22', 'Telecom BR LTDA'),
(192, '03.345.678/0042-33', 'Info Brasil SA'),
(193, '03.456.789/0043-44', 'Mega Eventos LTDA'),
(194, '03.567.890/0044-55', 'Construtora Giga EIRELI'),
(195, '03.678.901/0045-66', 'Agro Brasil Agricultura LTDA'),
(196, '03.789.012/0046-77', 'Brasil Viagens SA'),
(197, '03.890.123/0047-88', 'Financeiro BR Investimentos LTDA'),
(198, '03.901.234/0048-99', 'Saúde do Brasil LTDA'),
(199, '03.012.345/0049-00', 'ModaTech Estilo EIRELI'),
(200, '03.123.456/0050-11', 'Brasil Energia Sustentável LTDA');


SELECT COUNT(*) AS TotalPessoas FROM pessoas;
SELECT COUNT(*) AS TotalPessoasFisicas FROM pessoas_fisicas;
SELECT COUNT(*) AS TotalPessoasJuridicas FROM pessoas_juridicas;


-- Inserindo a operação de compra
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (34, 'C', '2024-11-29', 0);
DECLARE @id_operacao BIGINT = SCOPE_IDENTITY();

-- Inserindo os itens da operação
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 1, 30, 25.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 2, 30, 26.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 3, 30, 24.90);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 4, 30, 30.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 5, 30, 32.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 6, 30, 28.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 7, 30, 18.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 8, 30, 20.00);


select * from vw_produtos_estoque_baixo

select * from vw_estoque_atual

select * from operacoes
-------------------------------------------------------------------------------

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (1, 'V', '2024-11-29', 0); -- id_pessoa = 1

DECLARE @id_operacao_1 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_1, 1, 2, 25.50), -- Shampoo Artesanal Maracujá
(@id_operacao_1, 3, 1, 18.00), -- Sabonete Líquido Alecrim
(@id_operacao_1, 5, 1, 15.00); -- Rapé Samaúma

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (2, 'V', '2024-11-28', 0); -- id_pessoa = 2

DECLARE @id_operacao_2 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_2, 2, 1, 26.00), -- Shampoo Artesanal Banana
(@id_operacao_2, 4, 2, 20.00), -- Sabonete Líquido Arruda com Sal Grosso
(@id_operacao_2, 6, 3, 16.00); -- Rapé Sansara

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (3, 'V', '2024-11-27', 0); -- id_pessoa = 3

DECLARE @id_operacao_3 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_3, 7, 2, 17.00), -- Rapé 3 Ervas
(@id_operacao_3, 8, 1, 14.50), -- Rapé Cumaru
(@id_operacao_3, 9, 1, 16.50); -- Rapé Mulateiro

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (4, 'V', '2024-11-09', 0);
DECLARE @id_operacao_4 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_4, 3, 5, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_4, 4, 2, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_4, 2, 4, 13.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (5, 'V', '2024-11-30', 0);
DECLARE @id_operacao_5 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_5, 2, 3, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_5, 4, 4, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_5, 5, 3, 17.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (6, 'V', '2024-11-09', 0);
DECLARE @id_operacao_6 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_6, 1, 3, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_6, 5, 2, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_6, 2, 5, 13.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (7, 'V', '2024-11-29', 0);
DECLARE @id_operacao_7 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_7, 8, 4, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_7, 5, 2, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_7, 4, 3, 16.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (8, 'V', '2024-11-11', 0);
DECLARE @id_operacao_8 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_8, 6, 4, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_8, 9, 2, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_8, 5, 1, 17.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (9, 'V', '2024-11-18', 0);
DECLARE @id_operacao_9 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_9, 3, 5, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_9, 7, 2, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_9, 6, 5, 19.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (10, 'V', '2024-11-21', 0);
DECLARE @id_operacao_10 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_10, 7, 5, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_10, 1, 4, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_10, 4, 4, 16.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (11, 'V', '2024-11-18', 0);
DECLARE @id_operacao_11 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_11, 9, 3, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_11, 2, 1, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_11, 6, 1, 19.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (12, 'V', '2024-11-15', 0);
DECLARE @id_operacao_12 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_12, 8, 3, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_12, 2, 2, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_12, 3, 3, 14.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (13, 'V', '2024-11-28', 0);
DECLARE @id_operacao_13 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_13, 7, 2, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_13, 1, 1, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_13, 9, 5, 23.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (14, 'V', '2024-11-08', 0);
DECLARE @id_operacao_14 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_14, 4, 5, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_14, 5, 5, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_14, 2, 4, 13.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (15, 'V', '2024-11-19', 0);
DECLARE @id_operacao_15 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_15, 1, 2, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_15, 2, 5, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_15, 6, 4, 19.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (16, 'V', '2024-11-12', 0);
DECLARE @id_operacao_16 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_16, 2, 2, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_16, 4, 1, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_16, 8, 5, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (17, 'V', '2024-11-20', 0);
DECLARE @id_operacao_17 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_17, 9, 2, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_17, 2, 5, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_17, 7, 4, 20.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (18, 'V', '2024-11-15', 0);
DECLARE @id_operacao_18 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_18, 1, 2, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_18, 3, 2, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_18, 9, 3, 23.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (19, 'V', '2024-11-16', 0);
DECLARE @id_operacao_19 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_19, 4, 5, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_19, 6, 4, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_19, 1, 4, 11.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (20, 'V', '2024-11-07', 0);
DECLARE @id_operacao_20 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_20, 7, 3, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_20, 5, 5, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_20, 9, 2, 23.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (21, 'V', '2024-11-10', 0);
DECLARE @id_operacao_21 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_21, 9, 5, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_21, 5, 1, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_21, 3, 4, 14.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (22, 'V', '2024-11-01', 0);
DECLARE @id_operacao_22 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_22, 1, 4, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_22, 3, 1, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_22, 2, 1, 13.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (23, 'V', '2024-11-06', 0);
DECLARE @id_operacao_23 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_23, 1, 5, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_23, 2, 4, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_23, 8, 2, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (24, 'V', '2024-11-08', 0);
DECLARE @id_operacao_24 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_24, 3, 3, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_24, 9, 1, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_24, 8, 1, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (25, 'V', '2024-11-06', 0);
DECLARE @id_operacao_25 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_25, 3, 1, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_25, 9, 3, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_25, 1, 4, 11.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (26, 'V', '2024-11-21', 0);
DECLARE @id_operacao_26 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_26, 5, 3, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_26, 7, 1, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_26, 8, 5, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (27, 'V', '2024-11-17', 0);
DECLARE @id_operacao_27 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_27, 3, 1, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_27, 5, 3, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_27, 9, 3, 23.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (28, 'V', '2024-11-30', 0);
DECLARE @id_operacao_28 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_28, 2, 5, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_28, 5, 4, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_28, 6, 3, 19.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (29, 'V', '2024-11-10', 0);
DECLARE @id_operacao_29 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_29, 7, 2, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_29, 5, 4, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_29, 9, 4, 23.50);

---------------------------------------------------------

-- Inserindo a operação de compra
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (34, 'C', '2024-11-29', 0);
DECLARE @id_operacao BIGINT = SCOPE_IDENTITY();

-- Inserindo os itens da operação
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 2, 80, 26.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 5, 80, 32.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 6, 80, 28.50);


select * from vw_produtos_estoque_baixo

select * from operacoes
-------------------------------------------------------------------------------

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (30, 'V', '2024-11-20', 0);
DECLARE @id_operacao_30 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_30, 3, 2, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_30, 6, 2, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_30, 5, 2, 17.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (31, 'V', '2024-11-02', 0);
DECLARE @id_operacao_31 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_31, 4, 3, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_31, 9, 3, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_31, 7, 5, 20.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (32, 'V', '2024-11-14', 0);
DECLARE @id_operacao_32 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_32, 5, 2, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_32, 3, 5, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_32, 6, 5, 19.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (33, 'V', '2024-11-21', 0);
DECLARE @id_operacao_33 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_33, 1, 3, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_33, 6, 3, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_33, 8, 5, 22.00);

--------------------------------

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (34, 'V', '2024-11-20', 0);
DECLARE @id_operacao_34 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_34, 5, 5, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_34, 6, 5, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_34, 8, 2, 22.00);


INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (35, 'V', '2024-11-24', 0);
DECLARE @id_operacao_35 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_35, 9, 4, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_35, 3, 3, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_35, 1, 3, 11.50);

---------------------------------------------

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (36, 'V', '2024-11-03', 0);
DECLARE @id_operacao_36 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_36, 3, 1, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_36, 1, 5, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_36, 6, 4, 19.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (37, 'V', '2024-11-04', 0);
DECLARE @id_operacao_37 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_37, 9, 2, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_37, 4, 5, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_37, 7, 1, 20.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (38, 'V', '2024-11-04', 0);
DECLARE @id_operacao_38 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_38, 8, 2, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_38, 5, 3, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_38, 1, 2, 11.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (39, 'V', '2024-11-23', 0);
DECLARE @id_operacao_39 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_39, 2, 5, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_39, 4, 4, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_39, 3, 2, 14.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (40, 'V', '2024-11-28', 0);
DECLARE @id_operacao_40 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_40, 1, 1, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_40, 7, 5, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_40, 3, 5, 14.50);



select * from vw_produtos_estoque_baixo

select * from operacoes

-- Inserindo a operação de compra
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (34, 'C', '2024-11-29', 0);
DECLARE @id_operacao BIGINT = SCOPE_IDENTITY();

-- Inserindo os itens da operação
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 1, 70, 25.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 3, 70, 24.90);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 4, 70, 30.00);

select * from vw_estoque_atual


INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (41, 'V', '2024-11-12', 0);
DECLARE @id_operacao_41 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_41, 3, 5, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_41, 7, 5, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_41, 2, 1, 13.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (42, 'V', '2024-11-08', 0);
DECLARE @id_operacao_42 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_42, 5, 2, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_42, 3, 1, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_42, 4, 3, 16.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (43, 'V', '2024-11-24', 0);
DECLARE @id_operacao_43 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_43, 1, 3, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_43, 8, 2, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_43, 3, 4, 14.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (44, 'V', '2024-11-17', 0);
DECLARE @id_operacao_44 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_44, 4, 2, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_44, 6, 4, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_44, 1, 4, 11.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (45, 'V', '2024-11-19', 0);
DECLARE @id_operacao_45 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_45, 3, 5, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_45, 9, 1, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_45, 2, 5, 13.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (46, 'V', '2024-11-25', 0);
DECLARE @id_operacao_46 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_46, 2, 1, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_46, 5, 2, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_46, 3, 5, 14.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (47, 'V', '2024-11-01', 0);
DECLARE @id_operacao_47 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_47, 3, 5, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_47, 2, 1, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_47, 1, 3, 11.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (48, 'V', '2024-11-07', 0);
DECLARE @id_operacao_48 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_48, 2, 2, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_48, 9, 1, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_48, 7, 1, 20.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (49, 'V', '2024-11-08', 0);
DECLARE @id_operacao_49 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_49, 4, 1, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_49, 6, 3, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_49, 7, 1, 20.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (50, 'V', '2024-11-06', 0);
DECLARE @id_operacao_50 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_50, 6, 2, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_50, 4, 5, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_50, 1, 4, 11.50);

select * from vw_estoque_atual

select * from vw_produtos_estoque_baixo

-- Inserindo a operação de compra
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (34, 'C', '2024-11-29', 0);
DECLARE @id_operacao BIGINT = SCOPE_IDENTITY();

-- Inserindo os itens da operação
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 2, 41, 26.00); -- Shampoo Artesanal Banana

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 5, 39, 32.00); -- Condicionador Olíbano

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 6, 43, 28.50); -- Condicionador Samaúma

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 8, 32, 20.00); -- Sabonete Líquido Arruda com Sal Grosso

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 9, 34, 19.50); -- Sabonete Líquido Lavanda

select * from operacoes


INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (51, 'V', '2024-11-11', 0);
DECLARE @id_operacao_51 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_51, 6, 1, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_51, 9, 5, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_51, 3, 3, 14.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (52, 'V', '2024-11-20', 0);
DECLARE @id_operacao_52 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_52, 4, 3, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_52, 3, 4, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_52, 1, 4, 11.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (53, 'V', '2024-11-13', 0);
DECLARE @id_operacao_53 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_53, 4, 3, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_53, 1, 5, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_53, 5, 4, 17.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (54, 'V', '2024-11-28', 0);
DECLARE @id_operacao_54 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_54, 4, 3, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_54, 7, 5, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_54, 8, 5, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (55, 'V', '2024-11-27', 0);
DECLARE @id_operacao_55 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_55, 6, 1, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_55, 8, 1, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_55, 4, 4, 16.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (56, 'V', '2024-11-04', 0);
DECLARE @id_operacao_56 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_56, 7, 2, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_56, 3, 5, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_56, 6, 5, 19.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (57, 'V', '2024-11-30', 0);
DECLARE @id_operacao_57 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_57, 4, 4, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_57, 6, 2, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_57, 8, 3, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (58, 'V', '2024-11-12', 0);
DECLARE @id_operacao_58 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_58, 8, 4, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_58, 9, 5, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_58, 3, 4, 14.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (59, 'V', '2024-11-18', 0);
DECLARE @id_operacao_59 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_59, 7, 5, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_59, 9, 5, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_59, 8, 4, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (60, 'V', '2024-11-18', 0);
DECLARE @id_operacao_60 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_60, 6, 1, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_60, 4, 3, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_60, 2, 3, 13.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (61, 'V', '2024-11-18', 0);
DECLARE @id_operacao_61 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_61, 9, 4, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_61, 2, 1, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_61, 5, 1, 17.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (62, 'V', '2024-11-19', 0);
DECLARE @id_operacao_62 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_62, 3, 2, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_62, 4, 3, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_62, 6, 5, 19.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (63, 'V', '2024-11-21', 0);
DECLARE @id_operacao_63 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_63, 1, 3, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_63, 2, 5, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_63, 5, 2, 17.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (64, 'V', '2024-11-25', 0);
DECLARE @id_operacao_64 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_64, 1, 4, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_64, 7, 5, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_64, 8, 3, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (65, 'V', '2024-11-21', 0);
DECLARE @id_operacao_65 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_65, 3, 3, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_65, 9, 5, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_65, 5, 5, 17.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (66, 'V', '2024-11-09', 0);
DECLARE @id_operacao_66 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_66, 7, 3, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_66, 2, 2, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_66, 6, 3, 19.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (67, 'V', '2024-11-10', 0);
DECLARE @id_operacao_67 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_67, 7, 5, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_67, 3, 5, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_67, 5, 5, 17.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (68, 'V', '2024-11-30', 0);
DECLARE @id_operacao_68 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_68, 7, 1, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_68, 2, 2, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_68, 8, 4, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (69, 'V', '2024-11-09', 0);
DECLARE @id_operacao_69 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_69, 6, 2, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_69, 9, 5, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_69, 1, 3, 11.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (70, 'V', '2024-11-12', 0);
DECLARE @id_operacao_70 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_70, 1, 1, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_70, 2, 5, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_70, 5, 4, 17.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (71, 'V', '2024-11-13', 0);
DECLARE @id_operacao_71 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_71, 6, 4, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_71, 1, 2, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_71, 8, 4, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (72, 'V', '2024-11-10', 0);
DECLARE @id_operacao_72 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_72, 6, 2, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_72, 7, 5, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_72, 9, 3, 23.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (73, 'V', '2024-11-06', 0);
DECLARE @id_operacao_73 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_73, 8, 5, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_73, 5, 4, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_73, 6, 2, 19.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (74, 'V', '2024-11-22', 0);
DECLARE @id_operacao_74 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_74, 4, 1, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_74, 9, 2, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_74, 6, 1, 19.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (75, 'V', '2024-11-04', 0);
DECLARE @id_operacao_75 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_75, 8, 5, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_75, 7, 5, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_75, 5, 1, 17.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (76, 'V', '2024-11-21', 0);
DECLARE @id_operacao_76 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_76, 4, 2, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_76, 6, 4, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_76, 3, 5, 14.50);

select * from vw_estoque_atual
select * from vw_produtos_estoque_baixo

---------------------------------------------------------------------------------------------

-- Inserindo a operação de compra
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (34, 'C', '2024-11-29', 0);
DECLARE @id_operacao BIGINT = SCOPE_IDENTITY();

-- Inserindo os itens da operação (apenas produtos com estoque abaixo de 50)
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 1, 25, 25.50); -- Shampoo Artesanal Maracujá (50 - 25)

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 2, 9, 26.00); -- Shampoo Artesanal Banana (50 - 41)

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 3, 34, 24.90); -- Shampoo Artesanal Alecrim (50 - 16)

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 4, 30, 30.00); -- Condicionador Manteiga de Karité (50 - 20)

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 6, 15, 28.50); -- Condicionador Samaúma (50 - 35)

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 7, 44, 18.00); -- Sabonete Líquido Alecrim (50 - 6)

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 8, 6, 20.00); -- Sabonete Líquido Arruda com Sal Grosso (50 - 44)

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 9, 19, 19.50); -- Sabonete Líquido Lavanda (50 - 31)

---------------------------------------------------------------------------------------


INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (77, 'V', '2024-11-05', 0);
DECLARE @id_operacao_77 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_77, 8, 3, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_77, 9, 4, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_77, 7, 2, 20.50);

-------------------------------------------------------------------------------------
select * from vw_estoque_atual
select * from operacoes


INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (78, 'V', '2024-11-22', 0);
DECLARE @id_operacao_78 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_78, 7, 3, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_78, 6, 4, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_78, 2, 4, 13.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (79, 'V', '2024-11-25', 0);
DECLARE @id_operacao_79 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_79, 3, 3, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_79, 2, 4, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_79, 8, 1, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (80, 'V', '2024-11-07', 0);
DECLARE @id_operacao_80 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_80, 9, 1, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_80, 3, 1, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_80, 2, 5, 13.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (81, 'V', '2024-11-29', 0);
DECLARE @id_operacao_81 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_81, 3, 2, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_81, 2, 2, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_81, 8, 5, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (82, 'V', '2024-11-05', 0);
DECLARE @id_operacao_82 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_82, 3, 4, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_82, 6, 3, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_82, 8, 4, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (83, 'V', '2024-11-22', 0);
DECLARE @id_operacao_83 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_83, 3, 3, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_83, 5, 5, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_83, 2, 5, 13.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (84, 'V', '2024-11-17', 0);
DECLARE @id_operacao_84 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_84, 2, 2, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_84, 6, 3, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_84, 4, 3, 16.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (85, 'V', '2024-11-22', 0);
DECLARE @id_operacao_85 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_85, 3, 1, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_85, 4, 5, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_85, 6, 2, 19.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (86, 'V', '2024-11-14', 0);
DECLARE @id_operacao_86 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_86, 9, 1, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_86, 6, 2, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_86, 3, 5, 14.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (87, 'V', '2024-11-30', 0);
DECLARE @id_operacao_87 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_87, 9, 3, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_87, 6, 5, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_87, 7, 2, 20.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (88, 'V', '2024-11-20', 0);
DECLARE @id_operacao_88 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_88, 3, 1, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_88, 8, 5, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_88, 9, 1, 23.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (89, 'V', '2024-11-25', 0);
DECLARE @id_operacao_89 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_89, 2, 2, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_89, 9, 1, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_89, 7, 1, 20.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (90, 'V', '2024-11-19', 0);
DECLARE @id_operacao_90 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_90, 4, 4, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_90, 5, 2, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_90, 2, 3, 13.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (91, 'V', '2024-11-26', 0);
DECLARE @id_operacao_91 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_91, 9, 4, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_91, 1, 2, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_91, 3, 3, 14.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (92, 'V', '2024-11-21', 0);
DECLARE @id_operacao_92 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_92, 8, 1, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_92, 7, 5, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_92, 2, 5, 13.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (93, 'V', '2024-11-02', 0);
DECLARE @id_operacao_93 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_93, 3, 2, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_93, 5, 5, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_93, 4, 2, 16.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (94, 'V', '2024-11-04', 0);
DECLARE @id_operacao_94 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_94, 1, 4, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_94, 6, 1, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_94, 4, 3, 16.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (95, 'V', '2024-11-08', 0);
DECLARE @id_operacao_95 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_95, 2, 3, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_95, 9, 3, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_95, 5, 3, 17.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (96, 'V', '2024-11-11', 0);
DECLARE @id_operacao_96 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_96, 4, 1, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_96, 2, 3, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_96, 5, 3, 17.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (97, 'V', '2024-11-20', 0);
DECLARE @id_operacao_97 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_97, 3, 2, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_97, 9, 1, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_97, 7, 1, 20.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (98, 'V', '2024-11-20', 0);
DECLARE @id_operacao_98 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_98, 4, 3, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_98, 9, 3, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_98, 6, 5, 19.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (99, 'V', '2024-11-10', 0);
DECLARE @id_operacao_99 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_99, 9, 2, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_99, 5, 2, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_99, 3, 3, 14.50);

------------------------------------------------------
select * from vw_estoque_atual

-- Inserindo a operação de compra
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (34, 'C', '2024-11-29', 0);
DECLARE @id_operacao BIGINT = SCOPE_IDENTITY();

-- Inserindo os itens da operação (somente para produtos com estoque abaixo de 50)
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 2, 39, 26.00); -- Shampoo Artesanal Banana (50 - 11)

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 3, 40, 24.90); -- Shampoo Artesanal Alecrim (50 - 10)

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 4, 24, 30.00); -- Condicionador Manteiga de Karité (50 - 26)

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 5, 46, 32.00); -- Condicionador Olíbano (50 - 4)

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 6, 15, 28.50); -- Condicionador Samaúma (50 - 35)

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 7, 30, 18.00); -- Sabonete Líquido Alecrim (50 - 20)

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 8, 30, 20.00); -- Sabonete Líquido Arruda com Sal Grosso (50 - 20)

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao, 9, 39, 19.50); -- Sabonete Líquido Lavanda (50 - 11)




INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (100, 'V', '2024-11-21', 0);
DECLARE @id_operacao_100 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_100, 3, 5, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_100, 8, 2, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_100, 5, 4, 17.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (101, 'V', '2024-11-01', 0);
DECLARE @id_operacao_101 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_101, 6, 2, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_101, 8, 5, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_101, 1, 5, 11.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (102, 'V', '2024-11-03', 0);
DECLARE @id_operacao_102 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_102, 9, 3, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_102, 5, 3, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_102, 1, 5, 11.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (103, 'V', '2024-11-07', 0);
DECLARE @id_operacao_103 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_103, 8, 4, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_103, 1, 4, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_103, 3, 3, 14.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (104, 'V', '2024-11-09', 0);
DECLARE @id_operacao_104 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_104, 9, 4, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_104, 6, 5, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_104, 8, 3, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (105, 'V', '2024-11-30', 0);
DECLARE @id_operacao_105 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_105, 3, 4, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_105, 4, 1, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_105, 8, 2, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (106, 'V', '2024-11-15', 0);
DECLARE @id_operacao_106 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_106, 2, 5, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_106, 8, 2, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_106, 4, 3, 16.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (107, 'V', '2024-11-02', 0);
DECLARE @id_operacao_107 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_107, 7, 3, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_107, 9, 3, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_107, 6, 3, 19.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (108, 'V', '2024-11-30', 0);
DECLARE @id_operacao_108 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_108, 3, 4, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_108, 1, 4, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_108, 4, 5, 16.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (109, 'V', '2024-11-04', 0);
DECLARE @id_operacao_109 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_109, 9, 2, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_109, 8, 4, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_109, 3, 3, 14.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (110, 'V', '2024-11-15', 0);
DECLARE @id_operacao_110 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_110, 8, 5, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_110, 2, 1, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_110, 4, 5, 16.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (111, 'V', '2024-11-06', 0);
DECLARE @id_operacao_111 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_111, 3, 2, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_111, 1, 5, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_111, 2, 5, 13.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (112, 'V', '2024-11-30', 0);
DECLARE @id_operacao_112 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_112, 4, 2, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_112, 8, 2, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_112, 6, 5, 19.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (113, 'V', '2024-11-26', 0);
DECLARE @id_operacao_113 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_113, 9, 4, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_113, 2, 3, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_113, 8, 2, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (114, 'V', '2024-11-20', 0);
DECLARE @id_operacao_114 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_114, 3, 4, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_114, 8, 5, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_114, 4, 1, 16.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (115, 'V', '2024-11-09', 0);
DECLARE @id_operacao_115 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_115, 7, 5, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_115, 9, 5, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_115, 4, 4, 16.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (116, 'V', '2024-11-26', 0);
DECLARE @id_operacao_116 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_116, 9, 2, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_116, 4, 5, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_116, 2, 2, 13.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (117, 'V', '2024-11-02', 0);
DECLARE @id_operacao_117 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_117, 5, 2, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_117, 3, 3, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_117, 6, 4, 19.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (118, 'V', '2024-11-10', 0);
DECLARE @id_operacao_118 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_118, 1, 3, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_118, 9, 1, 23.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_118, 3, 1, 14.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (119, 'V', '2024-11-30', 0);
DECLARE @id_operacao_119 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_119, 5, 3, 17.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_119, 8, 2, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_119, 3, 4, 14.50);

-------------------------------------------------------

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (120, 'V', '2024-11-29', 0);
DECLARE @id_operacao_120 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_120, 1, 3, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_120, 7, 2, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_120, 8, 2, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (121, 'V', '2024-11-06', 0);
DECLARE @id_operacao_121 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_121, 2, 4, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_121, 8, 5, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_121, 5, 4, 17.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (122, 'V', '2024-11-10', 0);
DECLARE @id_operacao_122 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_122, 8, 4, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_122, 1, 2, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_122, 4, 4, 16.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (123, 'V', '2024-11-22', 0);
DECLARE @id_operacao_123 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_123, 7, 2, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_123, 8, 1, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_123, 1, 2, 11.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (124, 'V', '2024-11-02', 0);
DECLARE @id_operacao_124 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_124, 2, 3, 13.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_124, 3, 5, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_124, 5, 4, 17.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (125, 'V', '2024-11-20', 0);
DECLARE @id_operacao_125 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_125, 3, 5, 14.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_125, 7, 4, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_125, 8, 2, 22.00);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (126, 'V', '2024-11-12', 0);
DECLARE @id_operacao_126 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_126, 4, 4, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_126, 6, 5, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_126, 3, 1, 14.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (127, 'V', '2024-11-25', 0);
DECLARE @id_operacao_127 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_127, 7, 2, 20.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_127, 1, 4, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_127, 3, 1, 14.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (128, 'V', '2024-11-02', 0);
DECLARE @id_operacao_128 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_128, 4, 4, 16.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_128, 8, 1, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_128, 1, 3, 11.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (129, 'V', '2024-11-26', 0);
DECLARE @id_operacao_129 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_129, 6, 4, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_129, 8, 5, 22.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_129, 7, 1, 20.50);

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (130, 'V', '2024-11-16', 0);
DECLARE @id_operacao_130 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_130, 1, 4, 11.50);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_130, 6, 2, 19.00);

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_130, 5, 5, 17.50);

select * from operacoes
select * from vw_estoque_atual
select * from vw_produtos_estoque_baixo

INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (131, 'V', '2024-11-27', 0);
DECLARE @id_operacao_131 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_131, 15, 2, 15.00); -- Rapé Samaúma

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_131, 16, 1, 25.00); -- Guia X

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_131, 17, 2, 30.00); -- Santo Cruzeiro

-- Operação 132 (Substituir pelos produtos desejados)
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (132, 'V', '2024-11-18', 0);
DECLARE @id_operacao_132 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_132, 15, 4, 15.00); -- Rapé Samaúma

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_132, 16, 5, 25.00); -- Guia X

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_132, 17, 1, 30.00); -- Santo Cruzeiro

-- Operação 133 (Substituir pelos produtos desejados)
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (133, 'V', '2024-11-16', 0);
DECLARE @id_operacao_133 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_133, 18, 3, 40.00); -- Kuripe

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_133, 15, 1, 15.00); -- Rapé Samaúma

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_133, 19, 5, 50.00); -- Tepí


-- Operação 134
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (134, 'V', '2024-11-30', 0);
DECLARE @id_operacao_134 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_134, 15, 2, 15.00); -- Rapé Samaúma

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_134, 19, 3, 50.00); -- Tepí

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_134, 16, 2, 25.00); -- Guia X

-- Operação 135
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (135, 'V', '2024-11-16', 0);
DECLARE @id_operacao_135 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_135, 17, 3, 30.00); -- Santo Cruzeiro

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_135, 18, 1, 40.00); -- Kuripe

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_135, 19, 5, 50.00); -- Tepí

-- Operação 136
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (136, 'V', '2024-11-22', 0);
DECLARE @id_operacao_136 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_136, 16, 2, 25.00); -- Guia X

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_136, 18, 5, 40.00); -- Kuripe

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_136, 15, 3, 15.00); -- Rapé Samaúma

-- Operação 137
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (137, 'V', '2024-11-24', 0);
DECLARE @id_operacao_137 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_137, 19, 5, 50.00); -- Tepí

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_137, 16, 2, 25.00); -- Guia X

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_137, 17, 3, 30.00); -- Santo Cruzeiro

-- Operação 138
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (138, 'V', '2024-11-11', 0);
DECLARE @id_operacao_138 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_138, 18, 5, 40.00); -- Kuripe

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_138, 16, 1, 25.00); -- Guia X

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_138, 15, 1, 15.00); -- Rapé Samaúma

-- Operação 139
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (139, 'V', '2024-11-01', 0);
DECLARE @id_operacao_139 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_139, 17, 3, 30.00); -- Santo Cruzeiro

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_139, 18, 1, 40.00); -- Kuripe

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_139, 19, 5, 50.00); -- Tepí


select * from produtos


-- Operação 140
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (140, 'V', '2024-11-02', 0);
DECLARE @id_operacao_140 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_140, 16, 3, 16.00); -- Rapé Sansara

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_140, 18, 2, 14.50); -- Rapé Cumaru

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_140, 24, 1, 26.00); -- Santo Cruzeiro Xangô

-- Operação 141
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (141, 'V', '2024-11-07', 0);
DECLARE @id_operacao_141 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_141, 17, 5, 18.00); -- Rapé 3 Ervas

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_141, 27, 2, 29.00); -- Santo Cruzeiro Omolu

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_141, 30, 1, 25.00); -- Guia Preto Velho

-- Operação 142
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (142, 'V', '2024-11-04', 0);
DECLARE @id_operacao_142 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_142, 19, 2, 16.50); -- Rapé Mulateiro

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_142, 28, 1, 30.00); -- Santo Cruzeiro Exu

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_142, 45, 3, 50.00); -- Terço Preto Velho

-- Operação 143
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (143, 'V', '2024-11-16', 0);
DECLARE @id_operacao_143 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_143, 20, 4, 18.00); -- Rapé Tsunu

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_143, 26, 2, 28.00); -- Santo Cruzeiro Yansã

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_143, 46, 1, 16.00); -- Terço São Bento

-- Operação 144
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (144, 'V', '2024-11-07', 0);
DECLARE @id_operacao_144 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_144, 16, 2, 16.00); -- Rapé Sansara

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_144, 29, 3, 22.00); -- Guia Exu

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_144, 48, 2, 19.00); -- Terço Sagrada Família

-- Operação 145
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (145, 'V', '2024-11-27', 0);
DECLARE @id_operacao_145 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_145, 19, 3, 16.50); -- Rapé Mulateiro

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_145, 25, 2, 27.00); -- Santo Cruzeiro Yemanjá

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_145, 49, 1, 19.00); -- Terço Imaculado Coração de Maria

-- Operação 146
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (146, 'V', '2024-11-20', 0);
DECLARE @id_operacao_146 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_146, 18, 5, 14.50); -- Rapé Cumaru

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_146, 27, 2, 29.00); -- Santo Cruzeiro Omolu

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_146, 47, 3, 17.00); -- Terço São Jorge

-- Operação 147
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (147, 'V', '2024-11-16', 0);
DECLARE @id_operacao_147 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_147, 17, 2, 18.00); -- Rapé 3 Ervas

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_147, 23, 1, 25.00); -- Guia Caboclo

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_147, 45, 4, 50.00); -- Terço Preto Velho

-- Operação 148
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (148, 'V', '2024-11-25', 0);
DECLARE @id_operacao_148 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_148, 20, 2, 18.00); -- Rapé Tsunu

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_148, 29, 1, 22.00); -- Guia Exu

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_148, 49, 3, 19.00); -- Terço Imaculado Coração de Maria

-- Operação 149
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (149, 'V', '2024-11-18', 0);
DECLARE @id_operacao_149 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_149, 16, 2, 16.00); -- Rapé Sansara

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_149, 24, 3, 26.00); -- Santo Cruzeiro Xangô

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_149, 46, 2, 16.00); -- Terço São Bento

-- Operação 150
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (150, 'V', '2024-11-27', 0);
DECLARE @id_operacao_150 BIGINT = SCOPE_IDENTITY();

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_150, 18, 4, 14.50); -- Rapé Cumaru

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_150, 26, 3, 28.00); -- Santo Cruzeiro Yansã

INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES (@id_operacao_150, 48, 1, 19.00); -- Terço Sagrada Família


INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (151, 'V', '2024-05-02', 0);

DECLARE @id_operacao_151 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_151, 16, 2, 16.00), -- Rapé Sansara
(@id_operacao_151, 30, 1, 25.00), -- Guia Preto Velho
(@id_operacao_151, 25, 3, 27.00); -- Santo Cruzeiro Yemanjá

-- Operação para pessoa jurídica ID 152
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (152, 'V', '2024-03-06', 0);

DECLARE @id_operacao_152 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_152, 19, 3, 16.50), -- Rapé Mulateiro
(@id_operacao_152, 23, 1, 20.00), -- Guia Caboclo
(@id_operacao_152, 45, 5, 50.00); -- Terço Preto Velho

-- Operação para pessoa jurídica ID 153
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (153, 'V', '2024-08-03', 0);

DECLARE @id_operacao_153 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_153, 18, 5, 14.50), -- Rapé Cumaru
(@id_operacao_153, 26, 5, 28.00), -- Santo Cruzeiro Yansã
(@id_operacao_153, 43, 4, 39.85), -- Difusor Jaboticaba
(@id_operacao_153, 48, 3, 19.00), -- Terço Sagrada Família
(@id_operacao_153, 38, 1, 24.46); -- Difusor Alecrim

-- Operação para pessoa jurídica ID 154
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (154, 'V', '2024-09-23', 0);

DECLARE @id_operacao_154 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_154, 20, 5, 18.00), -- Rapé Tsunu
(@id_operacao_154, 29, 5, 22.00), -- Guia Exu
(@id_operacao_154, 50, 3, 19.00), -- Terço São Jorge
(@id_operacao_154, 39, 2, 55.52), -- Difusor Arruda
(@id_operacao_154, 25, 3, 27.00); -- Santo Cruzeiro Yemanjá

-- Operação para pessoa jurídica ID 155
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (155, 'V', '2024-01-14', 0);

DECLARE @id_operacao_155 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_155, 19, 1, 16.50), -- Rapé Mulateiro
(@id_operacao_155, 28, 1, 30.00), -- Santo Cruzeiro Exu
(@id_operacao_155, 45, 1, 50.00); -- Terço Preto Velho

-- Operação para pessoa jurídica ID 156
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (156, 'V', '2024-08-01', 0);

DECLARE @id_operacao_156 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_156, 18, 2, 14.50), -- Rapé Cumaru
(@id_operacao_156, 23, 5, 20.00), -- Guia Caboclo
(@id_operacao_156, 29, 1, 22.00), -- Guia Exu
(@id_operacao_156, 50, 4, 19.00); -- Terço São Jorge

-- Operação para pessoa jurídica ID 157
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (157, 'V', '2024-09-02', 0);

DECLARE @id_operacao_157 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_157, 17, 5, 18.00), -- Rapé 3 Ervas
(@id_operacao_157, 29, 1, 22.00), -- Guia Exu
(@id_operacao_157, 47, 5, 17.00), -- Terço São Jorge
(@id_operacao_157, 39, 5, 55.52), -- Difusor Arruda
(@id_operacao_157, 45, 4, 50.00); -- Terço Preto Velho

-- Operação para pessoa jurídica ID 158
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (158, 'V', '2024-04-01', 0);

DECLARE @id_operacao_158 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_158, 16, 1, 16.00), -- Rapé Sansara
(@id_operacao_158, 26, 4, 28.00), -- Santo Cruzeiro Yansã
(@id_operacao_158, 48, 2, 19.00); -- Terço Sagrada Família

-- Operação para pessoa jurídica ID 159
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (159, 'V', '2024-03-22', 0);

DECLARE @id_operacao_159 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_159, 19, 3, 16.50), -- Rapé Mulateiro
(@id_operacao_159, 30, 4, 25.00), -- Guia Preto Velho
(@id_operacao_159, 29, 2, 22.00), -- Guia Exu
(@id_operacao_159, 45, 5, 50.00), -- Terço Preto Velho
(@id_operacao_159, 39, 4, 55.52); -- Difusor Arruda

-- Operação para pessoa jurídica ID 160
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (160, 'V', '2024-06-18', 0);

DECLARE @id_operacao_160 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_160, 18, 3, 14.50), -- Rapé Cumaru
(@id_operacao_160, 23, 2, 20.00), -- Guia Caboclo
(@id_operacao_160, 25, 5, 27.00); -- Santo Cruzeiro Yemanjá

-- Operação para pessoa jurídica ID 161
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (161, 'V', '2024-08-23', 0);

DECLARE @id_operacao_161 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_161, 16, 4, 16.00), -- Rapé Sansara
(@id_operacao_161, 29, 5, 22.00), -- Guia Exu
(@id_operacao_161, 48, 3, 19.00), -- Terço Sagrada Família
(@id_operacao_161, 50, 3, 19.00), -- Terço São Jorge
(@id_operacao_161, 39, 1, 55.52); -- Difusor Arruda


select* from vw_estoque_atual

-- Operação para pessoa jurídica ID 162
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (162, 'V', '2024-10-21', 0);

DECLARE @id_operacao_162 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_162, 17, 2, 17.00), -- Rapé 3 Ervas
(@id_operacao_162, 26, 4, 29.00), -- Santo Cruzeiro Omolu
(@id_operacao_162, 29, 2, 22.00), -- Guia Exu
(@id_operacao_162, 10, 4, 19.00), -- Sabonete Líquido Camomila
(@id_operacao_162, 33, 5, 23.00); -- Guia Pombo Gira

-- Operação para pessoa jurídica ID 163
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (163, 'V', '2024-02-27', 0);

DECLARE @id_operacao_163 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_163, 16, 3, 16.00), -- Rapé Sansara
(@id_operacao_163, 27, 2, 28.00), -- Santo Cruzeiro Yansã
(@id_operacao_163, 34, 3, 26.00), -- Guia Cigano
(@id_operacao_163, 18, 1, 14.50), -- Rapé Cumaru
(@id_operacao_163, 11, 2, 10.00); -- Sabonete Barra Alecrim

-- Operação para pessoa jurídica ID 164
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (164, 'V', '2024-09-09', 0);

DECLARE @id_operacao_164 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_164, 22, 3, 20.00), -- Rapé Copaíba
(@id_operacao_164, 25, 4, 27.00), -- Santo Cruzeiro Yemanjá
(@id_operacao_164, 36, 2, 32.00); -- Difusor Cascas e Folhas Secas

-- Operação para pessoa jurídica ID 165
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (165, 'V', '2024-05-24', 0);

DECLARE @id_operacao_165 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_165, 29, 2, 22.00), -- Guia Exu
(@id_operacao_165, 10, 3, 19.00), -- Sabonete Líquido Camomila
(@id_operacao_165, 23, 1, 20.00); -- Guia Caboclo

-- Operação para pessoa jurídica ID 166
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (166, 'V', '2024-04-09', 0);

DECLARE @id_operacao_166 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_166, 18, 1, 14.50), -- Rapé Cumaru
(@id_operacao_166, 24, 1, 26.00), -- Santo Cruzeiro Xangô
(@id_operacao_166, 33, 2, 23.00); -- Guia Pombo Gira

-- Operação para pessoa jurídica ID 167
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (167, 'V', '2024-08-17', 0);

DECLARE @id_operacao_167 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_167, 20, 5, 18.00), -- Rapé Tsunu
(@id_operacao_167, 25, 1, 27.00), -- Santo Cruzeiro Yemanjá
(@id_operacao_167, 32, 2, 24.00); -- Guia Boiadeiro

-- Operação para pessoa jurídica ID 168
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (168, 'V', '2024-02-27', 0);

DECLARE @id_operacao_168 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_168, 18, 2, 14.50), -- Rapé Cumaru
(@id_operacao_168, 29, 5, 22.00), -- Guia Exu
(@id_operacao_168, 27, 3, 28.00); -- Santo Cruzeiro Yansã

-- Operação para pessoa jurídica ID 169
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (169, 'V', '2024-07-22', 0);

DECLARE @id_operacao_169 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_169, 17, 4, 17.00), -- Rapé 3 Ervas
(@id_operacao_169, 26, 2, 29.00), -- Santo Cruzeiro Omolu
(@id_operacao_169, 33, 2, 23.00); -- Guia Pombo Gira

-- Operação para pessoa jurídica ID 170
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (170, 'V', '2023-12-07', 0);

DECLARE @id_operacao_170 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_170, 18, 5, 14.50), -- Rapé Cumaru
(@id_operacao_170, 23, 3, 20.00), -- Guia Caboclo
(@id_operacao_170, 26, 2, 29.00); -- Santo Cruzeiro Omolu

-- Operação para pessoa jurídica ID 171
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (171, 'V', '2024-11-12', 0);

DECLARE @id_operacao_171 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_171, 20, 4, 18.00), -- Rapé Tsunu
(@id_operacao_171, 25, 5, 27.00), -- Santo Cruzeiro Yemanjá
(@id_operacao_171, 36, 2, 32.00); -- Difusor Cascas e Folhas Secas

-- Operação para pessoa jurídica ID 172
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (172, 'V', '2024-04-05', 0);

DECLARE @id_operacao_172 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_172, 16, 1, 16.00), -- Rapé Sansara
(@id_operacao_172, 10, 5, 19.00), -- Sabonete Líquido Camomila
(@id_operacao_172, 29, 3, 22.00), -- Guia Exu
(@id_operacao_172, 27, 2, 28.00), -- Santo Cruzeiro Yansã
(@id_operacao_172, 36, 4, 32.00); -- Difusor Cascas e Folhas Secas

-- Operação para pessoa jurídica ID 173
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (173, 'V', '2024-08-30', 0);

DECLARE @id_operacao_173 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_173, 17, 5, 17.00), -- Rapé 3 Ervas
(@id_operacao_173, 20, 4, 18.00), -- Rapé Tsunu
(@id_operacao_173, 25, 3, 27.00); -- Santo Cruzeiro Yemanjá


select * from operacoes

-- Operação para pessoa jurídica ID 174
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (174, 'V', '2024-01-04', 0);

DECLARE @id_operacao_174 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_174, 29, 3, 22.00), -- Guia Exu
(@id_operacao_174, 33, 4, 23.00), -- Guia Pombo Gira
(@id_operacao_174, 26, 4, 29.00); -- Santo Cruzeiro Omolu

-- Operação para pessoa jurídica ID 175
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (175, 'V', '2024-11-12', 0);

DECLARE @id_operacao_175 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_175, 20, 2, 18.00), -- Rapé Tsunu
(@id_operacao_175, 24, 2, 26.00), -- Santo Cruzeiro Xangô
(@id_operacao_175, 36, 1, 32.00); -- Difusor Cascas e Folhas Secas

-- Operação para pessoa jurídica ID 176
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (176, 'V', '2024-10-21', 0);

DECLARE @id_operacao_176 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_176, 17, 2, 17.00), -- Rapé 3 Ervas
(@id_operacao_176, 27, 1, 28.00), -- Santo Cruzeiro Yansã
(@id_operacao_176, 34, 4, 26.00); -- Guia Cigano

-- Operação para pessoa jurídica ID 177
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (177, 'V', '2024-06-23', 0);

DECLARE @id_operacao_177 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_177, 18, 5, 14.50), -- Rapé Cumaru
(@id_operacao_177, 29, 4, 22.00), -- Guia Exu
(@id_operacao_177, 25, 3, 27.00); -- Santo Cruzeiro Yemanjá

-- Operação para pessoa jurídica ID 178
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (178, 'V', '2024-08-05', 0);

DECLARE @id_operacao_178 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_178, 17, 5, 17.00), -- Rapé 3 Ervas
(@id_operacao_178, 33, 2, 23.00), -- Guia Pombo Gira
(@id_operacao_178, 36, 4, 32.00); -- Difusor Cascas e Folhas Secas

-- Operação para pessoa jurídica ID 179
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (179, 'V', '2024-02-03', 0);

DECLARE @id_operacao_179 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_179, 16, 2, 16.00), -- Rapé Sansara
(@id_operacao_179, 26, 3, 29.00), -- Santo Cruzeiro Omolu
(@id_operacao_179, 36, 5, 32.00); -- Difusor Cascas e Folhas Secas

-- Operação para pessoa jurídica ID 180
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (180, 'V', '2024-09-06', 0);

DECLARE @id_operacao_180 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_180, 18, 1, 14.50), -- Rapé Cumaru
(@id_operacao_180, 23, 2, 20.00), -- Guia Caboclo
(@id_operacao_180, 29, 4, 22.00); -- Guia Exu

----------------------------------------------------------

select * from operacoes
select*from vw_estoque_atual

-- Operação para pessoa jurídica ID 181
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (181, 'V', '2024-06-30', 0);

DECLARE @id_operacao_181 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_181, 16, 3, 16.00), -- Rapé Sansara
(@id_operacao_181, 17, 3, 17.00), -- Rapé 3 Ervas
(@id_operacao_181, 20, 1, 18.00); -- Rapé Tsunu

-- Operação para pessoa jurídica ID 182
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (182, 'V', '2024-03-25', 0);

DECLARE @id_operacao_182 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_182, 21, 4, 20.00), -- Rapé Jurema Preta
(@id_operacao_182, 10, 3, 19.00), -- Sabonete Líquido Camomila
(@id_operacao_182, 22, 2, 20.00); -- Rapé Copaíba

-- Operação para pessoa jurídica ID 183
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (183, 'V', '2024-02-18', 0);

DECLARE @id_operacao_183 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_183, 13, 1, 11.50), -- Sabonete Barra Lavanda
(@id_operacao_183, 14, 2, 11.00), -- Sabonete Barra Camomila
(@id_operacao_183, 19, 4, 16.50); -- Rapé Mulateiro

-- Operação para pessoa jurídica ID 184
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (184, 'V', '2024-04-26', 0);

DECLARE @id_operacao_184 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_184, 10, 1, 19.00), -- Sabonete Líquido Camomila
(@id_operacao_184, 12, 3, 12.00), -- Sabonete Barra Arruda com Sal Grosso
(@id_operacao_184, 22, 1, 20.00), -- Rapé Copaíba
(@id_operacao_184, 20, 4, 18.00); -- Rapé Tsunu

-- Operação para pessoa jurídica ID 185
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (185, 'V', '2024-06-04', 0);

DECLARE @id_operacao_185 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_185, 16, 3, 16.00), -- Rapé Sansara
(@id_operacao_185, 17, 5, 17.00), -- Rapé 3 Ervas
(@id_operacao_185, 18, 5, 14.50); -- Rapé Cumaru

-- Operação para pessoa jurídica ID 186
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (186, 'V', '2023-12-20', 0);

DECLARE @id_operacao_186 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_186, 19, 1, 16.50), -- Rapé Mulateiro
(@id_operacao_186, 20, 1, 18.00), -- Rapé Tsunu
(@id_operacao_186, 21, 3, 20.00); -- Rapé Jurema Preta

-- Operação para pessoa jurídica ID 187
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (187, 'V', '2024-09-16', 0);

DECLARE @id_operacao_187 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_187, 10, 2, 19.00), -- Sabonete Líquido Camomila
(@id_operacao_187, 11, 3, 10.00), -- Sabonete Barra Alecrim
(@id_operacao_187, 22, 3, 20.00); -- Rapé Copaíba

-- Operação para pessoa jurídica ID 188
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (188, 'V', '2023-12-26', 0);

DECLARE @id_operacao_188 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_188, 20, 2, 18.00), -- Rapé Tsunu
(@id_operacao_188, 17, 1, 17.00), -- Rapé 3 Ervas
(@id_operacao_188, 18, 2, 14.50); -- Rapé Cumaru

-- Operação para pessoa jurídica ID 189
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (189, 'V', '2024-01-24', 0);

DECLARE @id_operacao_189 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_189, 22, 3, 20.00), -- Rapé Copaíba
(@id_operacao_189, 19, 3, 16.50), -- Rapé Mulateiro
(@id_operacao_189, 18, 3, 14.50); -- Rapé Cumaru

-- Operação para pessoa jurídica ID 190
INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (190, 'V', '2024-10-07', 0);

DECLARE @id_operacao_190 BIGINT = SCOPE_IDENTITY();
INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario)
VALUES
(@id_operacao_190, 16, 4, 16.00), -- Rapé Sansara
(@id_operacao_190, 21, 4, 20.00), -- Rapé Jurema Preta
(@id_operacao_190, 10, 3, 19.00); -- Sabonete Líquido Camomila


select * from operacoes

-- Para teste de Usuário
-- Deletar (inativar) um registro em pessoas
UPDATE pessoas SET is_active = 0 WHERE id_pessoa = 1;
Update pessoas set is_active = 1 where id_pessoa = 1;

select * from pessoas

CREATE VIEW vw_valor_gasto_por_categoria AS
SELECT 
    c.id_categoria,
    c.nome_categoria,
    SUM(io.quantidade * io.preco_unitario) AS valor_total_gasto
FROM 
    itens_operacao io
INNER JOIN 
    produtos p ON io.id_produto = p.id_produto
INNER JOIN 
    categorias c ON p.id_categoria = c.id_categoria
INNER JOIN 
    operacoes o ON io.id_operacao = o.id_operacao
WHERE 
    o.tipo_operacao = 'V' -- Apenas operações de compra
GROUP BY 
    c.id_categoria, c.nome_categoria;



CREATE VIEW vw_quantidade_produtos_por_categoria AS
SELECT 
    c.id_categoria,
    c.nome_categoria,
    COUNT(p.id_produto) AS quantidade_produtos
FROM 
    categorias c
LEFT JOIN 
    produtos p ON c.id_categoria = p.id_categoria
GROUP BY 
    c.id_categoria, c.nome_categoria;


select * from operacoes

select * from vw_valor_gasto_por_categoria

select * from vw_quantidade_produtos_por_categoria
	
select * from pessoas

select * from operacoes

select p.nome_pessoa as CLIENTES, op.tipo_operacao AS OPERACAO, op.data_operacao AS DATA_OPERACAO, op.valor_total AS VALOR_TOTAL from operacoes op
	inner join pessoas p on (op.id_pessoa = p.id_pessoa);




	select * from categorias
	select * from produtos


	INSERT INTO operacoes (id_pessoa, tipo_operacao, data_operacao, valor_total)
VALUES (34, 'C', '2024-11-29', 0.00);
