-- STATUS DO PEDIDO NP - Não Pago, PG - PAGO

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
    porcentagem INT NOT NULL,
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

--- FUNÇÕES E TRIGGERS ---

CREATE TRIGGER gatilho_cadastro_usuario BEFORE INSERT ON usuario 
FOR EACH ROW EXECUTE PROCEDURE validar_cadastro_usuario();

CREATE TRIGGER gatilho_cadastro_loja BEFORE INSERT ON loja 
FOR EACH ROW EXECUTE PROCEDURE validar_cadastro_loja();

CREATE TRIGGER gatilho_cadastro_produto BEFORE INSERT OR UPDATE ON produto 
FOR EACH ROW EXECUTE PROCEDURE validar_cadastro_produto();

CREATE TRIGGER gatilho_cadastro_entregador BEFORE INSERT OR UPDATE ON entregador 
FOR EACH ROW EXECUTE PROCEDURE validar_cadastro_entregador();

CREATE TRIGGER gatilho_cadastro_desconto BEFORE INSERT ON desconto 
FOR EACH ROW EXECUTE PROCEDURE validar_cadastro_desconto();

CREATE TRIGGER gatilho_cadastro_cartao BEFORE INSERT ON cartao 
FOR EACH ROW EXECUTE PROCEDURE validar_cadastro_cartao();

CREATE TRIGGER gatilho_cadastro_endereco BEFORE INSERT ON endereco 
FOR EACH ROW EXECUTE PROCEDURE validar_cadastro_endereco();

CREATE TRIGGER gatilho_adicionar_item_pedido BEFORE INSERT ON item_pedido
FOR EACH ROW EXECUTE PROCEDURE validar_adicionar_item_pedido();

--- CADASTROS E VALIDAÇÕES DE CADASTRO ---

CREATE OR REPLACE FUNCTION cadastrar_usuario(nome TEXT, contato TEXT) RETURNS VOID AS $cadastrar_usuario$
BEGIN 
	INSERT INTO usuario VALUES(DEFAULT, nome, contato);
END;
$cadastrar_usuario$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validar_cadastro_usuario() RETURNS TRIGGER AS $validar_cadastro_usuario$
BEGIN
	IF NEW.nome = '' or NEW.nome = NULL THEN
		RAISE EXCEPTION 'O usuário não pode ser cadastrado sem nome';
	END IF;
		
	IF NEW.contato = '' OR NEW.contato = NULL THEN
		RAISE EXCEPTION 'O usuario não pode ser cadastrado sem um contato';
	END IF;

	EXECUTE cadastrar_usuario(NEW.nome, NEW.contato);
	
	RETURN NEW;
END;
$validar_cadastro_usuario$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cadastrar_loja(nome TEXT, descricao TEXT) RETURNS VOID AS $cadastrar_loja$
BEGIN 
	INSERT INTO loja VALUES(DEFAULT, nome, descricao);
END;
$cadastrar_loja$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validar_cadastro_loja() RETURNS TRIGGER AS $validar_cadastro_loja$
BEGIN 
	IF NEW.nome = '' or NEW.nome = NULL THEN
		RAISE EXCEPTION 'A loja não pode ser cadastrada sem nome';
	END IF;
		
	IF NEW.descricao = '' OR NEW.descricao = NULL THEN
		RAISE EXCEPTION 'A loja não pode ser cadastrada sem desrição';
	END IF;
		
	EXECUTE cadastrar_loja(NEW.nome, NEW.descricao);
	
	RETURN NEW;
END;
$validar_cadastro_loja$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cadastrar_entregador(nome TEXT, contato TEXT) RETURNS VOID AS $cadastrar_entregador$
BEGIN
	INSERT INTO entregador VALUES(DEFAULT, nome, contato);
END;
$cadastrar_entregador$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validar_cadastro_entregador() RETURNS TRIGGER AS $validar_cadastro_entregador$
BEGIN
	IF NEW.nome = '' or NEW.nome = NULL THEN
		RAISE EXCEPTION 'O entregador não pode ser cadastrado sem nome';
	END IF;
		
	IF NEW.contato = '' or NEW.contato THEN
		RAISE EXCEPTION 'O entregador não pode ser cadastrado sem contato';
	END IF;
	
	EXECUTE cadastrar_entregador(NEW.nome, NEW.contato);
	
	RETURN NEW;
END;
$validar_cadastro_entregador$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cadastrar_produto(nome TEXT, descricao TEXT, valor FLOAT, id_loja INT) RETURNS VOID AS $cadastrar_produto$
BEGIN
	INSERT INTO produto VALUES(DEFAULT, nome, descricao, valor, id_loja);
END;
$cadastrar_produto$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validar_cadastro_produto() RETURNS TRIGGER AS $validar_cadastro_produto$
BEGIN
	IF NEW.nome = '' THEN
		RAISE EXCEPTION 'O produto não pode ser cadastrado sem nome';
	END IF;
		
	IF NEW.descricao = '' THEN
		RAISE EXCEPTION 'O produto não pode ser cadastrado sem descrição';
	END IF;
		
	IF NEW.valor IS NULL THEN
		RAISE EXCEPTION 'O produto não pode ser cadastrado sem um valor';
	END IF;
		
	IF NEW.fk_loja NOT IN (SELECT id_loja FROM loja) THEN
		RAISE EXCEPTION 'A loja informada não foi cadastrada';
	END IF;
		
	IF NEW.fk_loja IS NULL THEN
		RAISE EXCEPTION 'O produto não pode ser cadastrado sem uma loja';
	END IF;
	
	EXECUTE cadastrar_produto(NEW.nome, NEW.descricao, NEW.valor, NEW.fk_loja);
	
	RETURN NEW;
END;
$validar_cadastro_produto$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cadastrar_cartao(numero TEXT, codigo TEXT, bandeira TEXT, id_usuario INT) RETURNS VOID AS $cadastrar_cartao$
BEGIN
	INSERT INTO cartao VALUES(DEFAULT, numero, codigo, bandeira, id_usuario);
END;
$cadastrar_cartao$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validar_cadastro_cartao() RETURNS TRIGGER AS $validar_cadastro_cartao$
BEGIN
	IF NEW.numero = '' or NEW.numero = NULL THEN
		RAISE EXCEPTION 'O cartão não pode ser cadastrado sem um número';
	END IF;
	
	IF NEW.numero IN (SELECT numero FROM cartao) THEN
		RAISE EXCEPTION 'Já existe um cartão com esse numero';
	END IF;
		
	IF NEW.codigo = '' or NEW.condigo = NULL THEN
		RAISE EXCEPTION 'O cartão não pode ser cadastrado sem um código';
	END IF;
		
	IF NEW.bandeira = '' or NEW.bandeira = NULL THEN
		RAISE EXCEPTION 'O cartão não pode ser cadastrado sem uma bandeira';
	END IF;
		
	IF NEW.fk_usuario NOT IN (SELECT id_usuario FROM usuario) THEN
		RAISE EXCEPTION 'O usuario informado para o cadastro do cartão não é valido';
	END IF;
		
	IF NEW.fk_usuario IS NULL THEN
		RAISE EXCEPTION 'O cartão não pode ser cadastrado sem um usuário';
	END IF;

	EXECUTE cadastrar_cartao(NEW.numero, NEW.codigo, NEW.bandeira, NEW.fk_usuario);
	
	RETURN NEW;
END;
$validar_cadastro_cartao$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cadastrar_desconto(porcentagem INT, tipo TEXT, quant_maxima_uso INT, codigo TEXT) RETURNS VOID AS $cadastrar_desconto$
BEGIN
	INSERT INTO desconto VALUES(DEFAULT, porcentagem, tipo, quant_maxima_uso, codigo);
END;
$cadastrar_desconto$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validar_cadastro_desconto() RETURNS TRIGGER AS $validar_cadastro_desconto$
BEGIN
	IF NEW.porcentagem IS NULL THEN
		RAISE EXCEPTION 'O desconto não pode ser cadastrado sem porcentagem';
	END IF;
	
	IF NEW.tipo = '' or NEW.tipo = NULL THEN
		RAISE EXCEPTION 'O desconto não pode ser cadastrado sem um tipo';
	END IF;
	
	IF NEW.quant_max_uso IS NULL THEN
		RAISE EXCEPTION 'O desconto não pode ser cadastrado sem a quantidade maxima de uso';
	END IF;
	
	IF NEW.codigo = '' or NEW.codigo = NULL THEN
		RAISE EXCEPTION 'O desconto não pode ser cadastrado sem um código';
	END IF;
	
	IF NEW.codigo IN (SELECT codigo FROM desconto) THEN
		RAISE EXCEPTION 'Já existe um desconto com esse código';
	END IF;
	
	EXECUTE cadastrar_desconto(NEW.porcentagem, NEW.tipo, NEW.quant_maxima_uso, NEW.codigo);
	
	RETURN NEW;
END;
$validar_cadastro_desconto$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cadastrar_endereco(cep TEXT, rua TEXT, numero TEXT, latitude TEXT, longitude TEXT, complemento TEXT) RETURNS VOID AS $cadastrar_endereco$
BEGIN
	INSERT INTO endereco VALUES(DEFAULT, cep, rua, numero, latitude, longitude, complemento);
END;
$cadastrar_endereco$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validar_cadastro_endereco() RETURNS TRIGGER AS $validar_cadastro_endereco$
BEGIN
	IF NEW.cep = '' or NEW.cep = NULL THEN
		RAISE EXCEPTION 'Um endereco não pode ser cadastrado sem um CEP';
	END IF;
	
	IF NEW.rua = '' or NEW.rua = NULL THEN
		RAISE EXCEPTION 'Um endereco não pode ser cadastrado sem uma rua';
	END IF;
	
	IF NEW.numero = '' or NEW.numero = NULL THEN
		RAISE EXCEPTION 'Um endereco não pode ser cadastrado sem um número';
	END IF;
	
	EXECUTE cadastrar_endereco(NEW.cep, NEW.rua, NEW.numero, NEW.latutude, NEW.longitude, NEW.complemento);
	
	RETURN NEW;
END;
$validar_cadastro_endereco$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION realizar_pedido(id_usuario INT) RETURNS VOID AS $realizar_pedido$
BEGIN
	INSERT INTO pedido(DEFAULT, CURRENT_DATE, 0, 0, id_usuario);
END;
$realizar_pedido$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION adicionar_item_pedido(id_produto INT, id_pedido INT) RETURNS VOID AS $adicionar_item_pedido$
BEGIN
	INSERT INTO item_pedido VALUES(DEFAULT, id_pedido, id_produto);
END;
$adicionar_item_pedido$ LANGUAGE plpgsql;

CREATE FUNCTION validar_adicionar_item_pedido() RETURNS TRIGGER AS $validar_adicionar_item_pedido$
BEGIN
	IF NEW.fk_pedido NOT IN (SELECT id_pedido FROM pedido) THEN
		RAISE EXCEPTION	'Pedido não cadastrado';
	END IF;
	
	IF NEW.fk_pedido IS NULL THEN
		RAISE EXCEPTION 'O item não pode ser cadastrado sem estar asociado ao pedido';
	END IF;
	
	IF NEW.fk_produto IS NULL THEN
		RAISE EXCEPTION 'O item deve ter o produto associado';
	END IF;
	
	IF NEW.fk_produto NOT IN (SELECT id_produto FROM produto) THEN
		RAISE EXCEPTION 'Produto não cadastrado';
	END IF;
	
	EXECUTE adicionar_item_pedido(NEW.fk_pedido, NEW.fk_produto);
	
	RETURN NEW;
END;
$validar_adicionar_item_pedido$ LANGUAGE plpgsql;

--- RECUPERA VALOR DA TABELA DESCONTO, PORCENTAGEM
CREATE OR REPLACE FUNCTION get_valor_desconto(id_desconto INT, valor_liquido FLOAT) RETURNS FLOAT AS $get_valor_desconto$
DECLARE porcentagem INT;
		valor FLOAT;
BEGIN
    EXECUTE 'SELECT valor FROM desconto d WHERE d.id_desconto = ' || id_desconto INTO porcentagem;
	valor := (valor_liquido * porcentagem) / 100;
END;
$get_valor_desconto$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION atualiza_valor_pedido(id_pedido INT) RETURNS VOID AS $atualiza_valor_pedido$
DECLARE
	valor_liquido FLOAT;
BEGIN
	valor_liquido := (SELECT SUM(valor) FROM produto
					 LEFT JOIN item_pedido ON fk_produto = id_produto
					 WHERE fk_pedido = id_pedido);
	UPDATE pedido pd SET pd.valor_liquido = valor_liquido;
END;
$atualiza_valor_pedido$ LANGUAGE plpgsql;
