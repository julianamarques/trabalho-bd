--- BANCO ---

CREATE TABLE IF NOT EXISTS usuario(
    id_usuario SERIAL PRIMARY KEY NOT NULL,
    nome VARCHAR(200) NOT NULL,
    contato VARCHAR(12) NOT NULL
);

CREATE TABLE IF NOT EXISTS cartao(
    id_cartao SERIAL PRIMARY KEY NOT NULL,
    numero VARCHAR(16) NOT NULL,
    codigo VARCHAR(3) NOT NULL,
    bandeira VARCHAR(50) NOT NULL,
    fk_usuario INT NOT NULL,
    FOREIGN KEY (fk_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE IF NOT EXISTS loja(
    id_loja SERIAL PRIMARY KEY NOT NULL,
    nome VARCHAR(50) NOT NULL,
    descricao VARCHAR(500) NOT NULL
);

CREATE TABLE IF NOT EXISTS entregador(
  id_entregador SERIAL PRIMARY KEY NOT NULL,
  nome VARCHAR(50) NOT NULL,
  contato VARCHAR(12) NOT NULL
);

CREATE TABLE IF NOT EXISTS entregabilidade(
    id_entregabilidade SERIAL PRIMARY KEY NOT NULL,
    fk_usuario INT NOT NULL,
    FOREIGN KEY (fk_usuario) REFERENCES usuario(id_usuario),
    fk_loja INT NOT NULL,
    FOREIGN KEY (fk_loja) REFERENCES loja(id_loja)
);

CREATE TABLE IF NOT EXISTS endereco(
    id_endereco SERIAL PRIMARY KEY NOT NULL,
    cep VARCHAR(9) NOT NULL,
    rua VARCHAR(100) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    latitude VARCHAR(7) NULL,
    longitude VARCHAR(7) NULL,
    complemento VARCHAR(50) NULL
);

CREATE TABLE IF NOT EXISTS enderecamento(
    id_enderecamento SERIAL PRIMARY KEY NOT NULL,
    fk_usuario INT NOT NULL,
    FOREIGN KEY (fk_usuario) REFERENCES usuario(id_usuario),
    fk_loja INT NOT NULL,
    FOREIGN KEY (fk_loja) REFERENCES loja(id_loja)
);

CREATE TABLE IF NOT EXISTS desconto(
    id_desconto SERIAL PRIMARY KEY NOT NULL,
    valor FLOAT NOT NULL,
    tipo VARCHAR(1),
    quant_maxima_uso INT NOT NULL,
    codigo VARCHAR(5) NOT NULL
);

CREATE TABLE IF NOT EXISTS produto(
    id_produto SERIAL PRIMARY KEY NOT NULL,
    nome VARCHAR(50) NOT NULL,
    descricao VARCHAR(500) NOT NULL,
    valor FLOAT NOT NULL,
    fk_loja INT NOT NULL,
    FOREIGN KEY (fk_loja) REFERENCES loja(id_loja)
);

CREATE TABLE IF NOT EXISTS pedido(
    id_pedido SERIAL PRIMARY KEY NOT NULL,
    data_pedido DATE NOT NULL,
    valor FLOAT NOT NULL,
    valor_liquido FLOAT NOT NULL,
    fk_usuario INT NOT NULL,
	status VARCHAR(2) NOT NULL,
    FOREIGN KEY (fk_usuario) REFERENCES usuario(id_usuario),
    fk_desconto INT NULL,
    FOREIGN KEY (fk_desconto) REFERENCES desconto(id_desconto)
);

CREATE TABLE IF NOT EXISTS item_pedido(
    id_item_pedido SERIAL PRIMARY KEY NOT NULL,
    fk_pedido INT NOT NULL,
    FOREIGN KEY (fk_pedido) REFERENCES pedido(id_pedido),
	fk_produto INT NOT NULL,
    FOREIGN KEY (fk_produto) REFERENCES produto(id_produto)
);

CREATE TABLE IF NOT EXISTS combo(
    id_combo SERIAL PRIMARY KEY NOT NULL,
    fk_produto INT NOT NULL,
    FOREIGN KEY (fk_produto) REFERENCES produto(id_produto),
    fk_produto_combo INT NOT NULL,
    FOREIGN KEY (fk_produto_combo) REFERENCES produto(id_produto)
);

--- INSERTS ---

INSERT INTO loja VALUES(DEFAULT, 'MacDonalds', 'sdsds');
INSERT INTO loja VALUES(DEFAULT, 'Bobs', 'ddsddddsds');

INSERT INTO usuario VALUES(DEFAULT, 'Juliana', 'ddsddddsds');
INSERT INTO usuario VALUES(DEFAULT, 'Darshan', 'ddsdddddddddsds');

INSERT INTO produto VALUES(DEFAULT, 'Coca-cola', 'Refri', 15, 1);
INSERT INTO produto VALUES(DEFAULT, 'Pizza', 'Massa', 25, 1);

INSERT INTO desconto VALUES(DEFAULT, 3, 'A', 3, 'TRES');
INSERT INTO desconto VALUES(DEFAULT, 1, 'B', 2, 'UM');

--- FUNÇÕES E TRIGGERS ---

-- VERIFICA SE O PRODUTO EXISTE NO BD
CREATE OR REPLACE FUNCTION produto_existe(id_produto INT) RETURNS BOOLEAN AS $produto_existe$
DECLARE id_produto_temp INT;
BEGIN
    EXECUTE 'SELECT id_produto FROM produto p WHERE p.id_produto = ' || id_produto INTO id_produto_temp;
    IF id_produto_temp IS NOT NULL THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END
$produto_existe$ LANGUAGE plpgsql;

SELECT produto_existe(1);

--- RECUPERA VALOR DA TABELA DESCONTO, OS DESCONTOS SÃO EM REAIS
CREATE OR REPLACE FUNCTION get_valor_desconto(id_desconto INT) RETURNS FLOAT AS $get_valor_desconto$
DECLARE valor FLOAT;
BEGIN
    EXECUTE 'SELECT valor FROM desconto d WHERE d.id_desconto = ' || id_desconto INTO valor;
END;
$get_valor_desconto$ LANGUAGE plpgsql;

SELECT get_valor_desconto(1);

--- REALIZAR PEDIDO
CREATE OR REPLACE FUNCTION inserir_pedido(valor FLOAT, valor_liquido FLOAT, id_usuario INT, id_desconto INT) RETURNS INT AS $inserir_pedido$
BEGIN
	INSERT INTO pedido VALUES(DEFAULT, CURRENT_DATE, valor, valor_liquido, id_usuario, 'NP', id_desconto);
	RETURN cod_pedido;
END;
$inserir_pedido$ LANGUAGE plpgsql;

--- ADICIONAR ITEM AO PEDIDO
CREATE OR REPLACE FUNCTION adicionar_itens_pedido(id_pedido INT, id_produto INT) RETURNS INT AS $adicionar_itens_pedido$
DECLARE
	pedido INT;
	item_pedido INT,
	
BEGIN
	INSERT INTO item_pedido VALUES(DEFAULT, id_pedido, id_produto);
	RETURN id_item_pedido;
END;
$adicionar_itens_pedido$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION realizar_pedido(valor FLOAT, valor_liquido FLOAT, id_usuario INT, id_desconto INT, id_pedido INT, id_produto INT) RETURNS VOID AS $realizar_pedido$
BEGIN
	IF produto_existe($6) = TRUE THEN
		pedido := inserir_pedido(id_usuario, id_desconto)
		item_pedido := adicionar_item_pedido(id_pedido, id_produto);
	ELSE
		RAISE EXCEPTION 'Não foi possivel realizar o pedido. produto não existe'
	END IF;
END;

$realizar_pedido$ LANGUAGE plpgsql;
