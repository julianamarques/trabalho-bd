--- BANCO ---

CREATE TABLE IF NOT EXISTS usuario(
    id SERIAL PRIMARY KEY NOT NULL,
    nome VARCHAR(200) NOT NULL,
    contato VARCHAR(12) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
	data_desativacao DATE,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS bandeira(
	id SERIAL PRIMARY KEY NOT NULL,
	nome VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS cartao(
    id SERIAL PRIMARY KEY NOT NULL,
    numero VARCHAR(16) NOT NULL UNIQUE,
    codigo VARCHAR(3) NOT NULL,
    bandeira VARCHAR(50) NOT NULL,
    data_desativacao DATE,
    ativo BOOLEAN DEFAULT TRUE,
    fk_usuario INT NOT NULL,
    FOREIGN KEY (fk_usuario) REFERENCES usuario(id),
	fk_bandeira INT NOT NULL,
    FOREIGN KEY (fk_bandeira) REFERENCES bandeira(id)
);

CREATE TABLE IF NOT EXISTS loja(
    id SERIAL PRIMARY KEY NOT NULL,
    nome VARCHAR(50) NOT NULL,
    descricao VARCHAR(500) NOT NULL,
    data_desativacao DATE,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS endereco(
    id SERIAL PRIMARY KEY NOT NULL,
    cep VARCHAR(9) NOT NULL,
    rua VARCHAR(100) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    latitude VARCHAR(7) NULL,
    longitude VARCHAR(7) NULL,
    complemento VARCHAR(50) NULL,
    data_desativacao DATE,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS enderecamento(
    id SERIAL PRIMARY KEY NOT NULL,
    data_desativacao DATE,
    ativo BOOLEAN DEFAULT TRUE,
    fk_usuario INT NOT NULL,
    FOREIGN KEY (fk_usuario) REFERENCES usuario(id),
    fk_loja INT NOT NULL,
    FOREIGN KEY (fk_loja) REFERENCES loja(id)
);

CREATE TABLE IF NOT EXISTS preco_entrega(
    id SERIAL PRIMARY KEY NOT NULL,
    valor FLOAT NOT NULL,
    data_desativacao DATE,
    ativo BOOLEAN DEFAULT TRUE,
    fk_loja INT NOT NULL,
    FOREIGN KEY (fk_loja) REFERENCES loja(id)
);

CREATE TABLE IF NOT EXISTS entregador(
    id SERIAL PRIMARY KEY NOT NULL,
    nome VARCHAR(50) NOT NULL,
    contato VARCHAR(12) NOT NULL,
    data_desativacao DATE,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS entregabilidade(
    id SERIAL PRIMARY KEY NOT NULL,
    data_entrega DATE NOT NULL,
    valor FLOAT NOT NULL,
    data_desativacao DATE,
    ativo BOOLEAN DEFAULT TRUE,
    fk_usuario INT NOT NULL,
    FOREIGN KEY (fk_usuario) REFERENCES usuario(id),
    fk_loja INT NOT NULL,
    FOREIGN KEY (fk_loja) REFERENCES loja(id),
    fk_endereco INT NOT NULL,
    FOREIGN KEY (fk_endereco) REFERENCES endereco(id),
    fk_entregador INT NOT NULL,
    FOREIGN KEY (fk_entregador) REFERENCES entregador(id),
	fk_pedido INT NOT NULL,
    FOREIGN KEY (fk_pedido) REFERENCES pedido(id)
);

CREATE TYPE TIPO_DESCONTO AS ENUM('porcentagem', 'valor');

CREATE TABLE IF NOT EXISTS desconto(
    id SERIAL PRIMARY KEY NOT NULL,
    valor FLOAT NOT NULL,
    tipo TIPO_DESCONTO DEFAULT 'porcentagem',
    quant_maxima_uso INT NOT NULL,
    codigo VARCHAR(5) NOT NULL UNIQUE,
    data_desativacao DATE,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS produto(
    id SERIAL PRIMARY KEY NOT NULL,
    nome VARCHAR(50) NOT NULL,
    descricao VARCHAR(500) NOT NULL,
    valor FLOAT NOT NULL,
    data_desativacao DATE,
    ativo BOOLEAN DEFAULT TRUE,
    fk_loja INT NOT NULL,
    FOREIGN KEY (fk_loja) REFERENCES loja(id)
);

CREATE TABLE IF NOT EXISTS pedido(
    id SERIAL PRIMARY KEY NOT NULL,
    data_pedido DATE NOT NULL,
    valor FLOAT NOT NULL,
    valor_liquido FLOAT NOT NULL,
    fk_usuario INT NOT NULL,
    status VARCHAR(2) NOT NULL,
    data_desativacao DATE,
    ativo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (fk_usuario) REFERENCES usuario(id),
    fk_desconto INT NULL,
    FOREIGN KEY (fk_desconto) REFERENCES desconto(id)
);

CREATE TABLE IF NOT EXISTS item_pedido(
    id SERIAL PRIMARY KEY NOT NULL,
    data_desativacao DATE,
    ativo BOOLEAN DEFAULT TRUE,
    fk_pedido INT NOT NULL,
    FOREIGN KEY (fk_pedido) REFERENCES pedido(id),
    fk_produto INT NOT NULL,
    FOREIGN KEY (fk_produto) REFERENCES produto(id)
);

CREATE TABLE IF NOT EXISTS combo(
    id SERIAL PRIMARY KEY NOT NULL,
    fk_produto INT NOT NULL,
    data_desativacao DATE,
    ativo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (fk_produto) REFERENCES produto(id),
    fk_produto_combo INT NOT NULL,
    FOREIGN KEY (fk_produto_combo) REFERENCES produto(id)
);

--- TRIGGERS ---

--- INSERT TRIGGERS ---

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

CREATE TRIGGER gatilho_adicionar_enderecamento BEFORE INSERT ON enderecamento
FOR EACH ROW EXECUTE PROCEDURE validar_adicionar_enderecamento();

CREATE TRIGGER gatilho_adicionar_bandeira BEFORE INSERT ON bandeira
FOR EACH ROW EXECUTE PROCEDURE validar_adicionar_bandeira();

CREATE TRIGGER gatilho_adicionar_entregabilidade BEFORE INSERT ON entregabilidade
FOR EACH ROW EXECUTE PROCEDURE validar_adicionar_entregabilidade();

CREATE TRIGGER gatilho_adicionar_combo BEFORE INSERT ON combo
FOR EACH ROW EXECUTE PROCEDURE validar_adicionar_combo();

CREATE TRIGGER gatilho_adicionar_item_pedido BEFORE INSERT ON item_pedido
FOR EACH ROW EXECUTE PROCEDURE validar_adicionar_item_pedido();

--- DELETE TRIGGERS ---

CREATE TRIGGER gatilho_ao_deletar INSTEAD OF DELETE ON usuario
FOR EACH ROW EXECUTE PROCEDURE ao_inves_deletar();

CREATE TRIGGER gatilho_ao_deletar INSTEAD OF DELETE ON pedido 
FOR EACH ROW EXECUTE PROCEDURE ao_inves_deletar();

CREATE TRIGGER gatilho_ao_deletar INSTEAD OF DELETE ON item_pedido
FOR EACH ROW EXECUTE PROCEDURE ao_inves_deletar();

CREATE TRIGGER gatilho_ao_deletar INSTEAD OF DELETE ON loja 
FOR EACH ROW EXECUTE PROCEDURE ao_inves_deletar();

CREATE TRIGGER gatilho_ao_deletar INSTEAD OF DELETE ON combo
FOR EACH ROW EXECUTE PROCEDURE ao_inves_deletar();

CREATE TRIGGER gatilho_ao_deletar INSTEAD OF DELETE ON entregador
FOR EACH ROW EXECUTE PROCEDURE ao_inves_deletar();

CREATE TRIGGER gatilho_ao_deletar INSTEAD OF DELETE ON entregabilidade
FOR EACH ROW EXECUTE PROCEDURE ao_inves_deletar();

CREATE TRIGGER gatilho_ao_deletar INSTEAD OF DELETE ON endereco
FOR EACH ROW EXECUTE PROCEDURE ao_inves_deletar();

CREATE TRIGGER gatilho_ao_deletar INSTEAD OF DELETE ON enderecamento
FOR EACH ROW EXECUTE PROCEDURE ao_inves_deletar();

CREATE TRIGGER gatilho_ao_deletar INSTEAD OF DELETE ON bandeira
FOR EACH ROW EXECUTE PROCEDURE ao_inves_deletar();

CREATE TRIGGER gatilho_ao_deletar INSTEAD OF DELETE ON preco_entrega
FOR EACH ROW EXECUTE PROCEDURE ao_inves_deletar();

CREATE TRIGGER gatilho_ao_deletar INSTEAD OF DELETE ON cartao
FOR EACH ROW EXECUTE PROCEDURE ao_inves_deletar();

CREATE TRIGGER gatilho_ao_deletar INSTEAD OF DELETE ON desconto 
FOR EACH ROW EXECUTE PROCEDURE ao_inves_deletar();

--- FUNÇÕES ---

CREATE OR REPLACE FUNCTION cadastrar_usuario(nome TEXT, contato TEXT, email TEXT) RETURNS VOID AS $cadastrar_usuario$
BEGIN 
	INSERT INTO usuario VALUES(DEFAULT, nome, contato, email);
END;
$cadastrar_usuario$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validar_cadastro_usuario() RETURNS TRIGGER AS $validar_cadastro_usuario$
BEGIN
	IF NEW.nome = '' OR NEW.nome IS NULL THEN
		RAISE EXCEPTION 'O usuário não pode ser cadastrado sem nome';
	END IF;
	
	IF NEW.email = '' OR NEW.email IS NULL THEN
		RAISE EXCEPTION 'O usuário não pode ser cadastrado sem email';
	END IF;
	
	IF NEW.email IN (SELECT email FROM usuario) THEN
		RAISE EXCEPTION 'O email já está cadastrado';
	END IF;
	
	IF NEW.contato = '' OR NEW.contato IS NULL THEN
		RAISE EXCEPTION 'O usuario não pode ser cadastrado sem um contato';
	END IF;

	EXECUTE cadastrar_usuario(NEW.nome, NEW.contato, NEW.email);
	
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
	IF NEW.nome = '' OR NEW.nome IS NULL THEN
		RAISE EXCEPTION 'A loja não pode ser cadastrada sem nome';
	END IF;
		
	IF NEW.descricao = '' OR NEW.descricao IS NULL THEN
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
	IF NEW.nome = '' OR NEW.nome IS NULL THEN
		RAISE EXCEPTION 'O entregador não pode ser cadastrado sem nome';
	END IF;
		
	IF NEW.contato = '' OR NEW.contato IS NULL THEN
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
	IF NEW.nome = '' OR NEW.nome IS NULL THEN
		RAISE EXCEPTION 'O produto não pode ser cadastrado sem nome';
	END IF;
		
	IF NEW.descricao = '' OR NEW.descricao IS NULL THEN
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

CREATE OR REPLACE FUNCTION cadastrar_bandeira(nome TEXT) RETURNS VOID AS $cadastrar_bandeira$
BEGIN
	INSERT INTO bandeira VALUES(DEFAULT, nome);
END;
$cadastrar_bandeira$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validar_cadastro_bandeira() RETURNS TRIGGER AS $validar_cadastro_bandeira$
BEGIN
	IF NEW.nome = '' OR NEW.nome IS NULL THEN
		RAISE EXCEPTION 'A bandeira não pode ser cadastrada sem nome';
	END IF;
END;
$validar_cadastro_bandeira$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cadastrar_cartao(numero TEXT, codigo TEXT, id_bandeira INT, id_usuario INT) RETURNS VOID AS $cadastrar_cartao$
BEGIN
	INSERT INTO cartao VALUES(DEFAULT, numero, codigo, id_bandeira, id_usuario);
END;
$cadastrar_cartao$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validar_cadastro_cartao() RETURNS TRIGGER AS $validar_cadastro_cartao$
BEGIN
	IF NEW.numero = '' OR NEW.numero IS NULL THEN
		RAISE EXCEPTION 'O cartão não pode ser cadastrado sem um número';
	END IF;
	
	IF NEW.numero IN (SELECT numero FROM cartao) THEN
		RAISE EXCEPTION 'Já existe um cartão com esse numero';
	END IF;
		
	IF NEW.codigo = '' OR NEW.codigo THEN
		RAISE EXCEPTION 'O cartão não pode ser cadastrado sem um código';
	END IF;
		
	IF NEW.fk_bandeira IS NULL THEN
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

CREATE OR REPLACE FUNCTION cadastrar_desconto(valor FLOAT, tipo TEXT, quant_maxima_uso INT, codigo TEXT) RETURNS VOID AS $cadastrar_desconto$
BEGIN
	INSERT INTO desconto VALUES(DEFAULT, valor, tipo, quant_maxima_uso, codigo);
END;
$cadastrar_desconto$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validar_cadastro_desconto() RETURNS TRIGGER AS $validar_cadastro_desconto$
BEGIN
	IF NEW.valor IS NULL OR NEW.valor = 0.0 THEN
		RAISE EXCEPTION 'Valor de desconto é necessário';
	END IF;
	
	IF NEW.quant_max_uso IS NULL THEN
		RAISE EXCEPTION 'O desconto não pode ser cadastrado sem a quantidade maxima de uso';
	END IF;
	
	IF NEW.codigo = '' OR NEW.codigo IS NULL THEN
		RAISE EXCEPTION 'O desconto não pode ser cadastrado sem um código';
	END IF;
	
	IF NEW.codigo IN (SELECT codigo FROM desconto) THEN
		RAISE EXCEPTION 'Já existe um desconto com esse código';
	END IF;
	
	EXECUTE cadastrar_desconto(NEW.valor, NEW.tipo, NEW.quant_maxima_uso, NEW.codigo);
	
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
	IF NEW.cep = '' OR NEW.cep IS NULL THEN
		RAISE EXCEPTION 'Um endereco não pode ser cadastrado sem um CEP';
	END IF;
	
	IF NEW.rua = '' OR NEW.rua IS NULL THEN
		RAISE EXCEPTION 'Um endereco não pode ser cadastrado sem uma rua';
	END IF;
	
	IF NEW.numero = '' OR NEW.numero IS NULL THEN
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

CREATE OR REPLACE validar_pedido() RETURNS TRIGGER AS $validar_pedido$
BEGIN 
	IF NEW.fk_usuario IS NULL THEN
		RAISE EXCEPTION 'O pedido deve estar associado a um usuario';
	END IF;
END;
$validar_pedido$ LANGUAGE plpgsql;

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

CREATE OR REPLACE FUNCTION cadastrar_preco_entrega(valor FLOAT, id_loja INT) RETURNS VOID AS $cadastrar_preco_entrega$
BEGIN
	INSERT INTO preco_entrega(valor, fk_loja) VALUES(valor, id_loja);
END;
$cadastrar_preco_entrega$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validar_cadastro_preco_entrega() RETURNS TRIGGER AS $validar_cadastro_preco_entrega$
BEGIN
	IF NEW.valor IS NULL OR NEW.valor = 0.0 THEN
		RAISE EXCEPTION 'Valor inválido';
	END IF;
	
	IF NEW.fk_loja IS NULL THEN
		RAISE EXCEPTION 'O preço deve estar associada a uma loja';
	END IF;
	
	IF NEW.fk_loja NOT IN (SELECT id FROM loja) THEN
		RAISE EXCEPTION 'A loja não está cadastrada';
	END IF;
END
$validar_cadastro_preco_entrega$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION realizar_entrega(id_usuario INT, id_loja INT, id_endereco INT, id_entregador INT, id_pedido INT) RETURNS VOID AS $realizar_entrega$
DECLARE 
	valor_entrega FLOAT;
BEGIN
	EXECUTE 'SELECT valor FROM loja l WHERE id = ' || id_loja INTO valor_entrega;
	INSERT INTO entregabilidade(data_entrega, valor, fk_usuario, fk_loja, fk_endereco, fk_entregador, fk_pedido) 
	VALUES(DEFAULT, CURRENT_DATE, valor_entrega, id_usuario, id_loja, id_endereco, id_entregador, id_pedido);
END;
$realizar_entrega$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION atualizar_valor_pedido_com_desconto(pedido_id INT, codigo_desconto VARCHAR)
RETURNS VOID AS $$
DECLARE
	valor_desconto FLOAT;
	tipo TIPO_DESCONTO;
BEGIN
	tipo, valor_desconto := SELECT tipo, valor FROM desconto WHERE codigo = codigo_deconto;
	IF pedido_id NOT IN (SELECT id FROM pedido) THEN
		RAISE EXCEPTION 'Pedido não cadastrado';
	END IF;
	
	IF pedido_id IS NULL THEN
		RAISE EXCEPTION 'Pedido não pode ser nulo';
	END IF;
	
	IF codigo_desconto NOT IN (SELECT codigo FROM desconto) THEN
		RAISE EXCEPTION 'Desconto não cadastrado';
	END IF;
	
	IF TIPO = 'porcentagem' THEN
	 	UPDATE pedido SET valor_liquido = (valor * (0 + valor_desconto)) WHERE id = pedido_id;
	ELSE
		UPDATE pedido SET valor_liquido = (valor - valor_desconto) WHERE id = pedido_id;
	END IF;
END
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION atualiza_valor_pedido(id_pedido INT, id_desconto INT) RETURNS VOID AS $atualiza_valor_pedido$
DECLARE
	valor FLOAT;
BEGIN
	valor := (SELECT SUM(valor) FROM produto
					 LEFT JOIN item_pedido ON fk_produto = id_produto
					 WHERE fk_pedido = id_pedido);
	
	IF id_pedido NOT IN (SELECT id FROM pedido) THEN
		RAISE EXCEPTION 'Pedido não cadastrado';
	END IF;
	
	UPDATE pedido pd SET pd.valor = valor WHERE id = id_pedido;
END;
$atualiza_valor_pedido$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION adicionar_combo(id_produto INT, id_produto_combo INT) RETURNS VOID AS $adicionar_combo$
BEGIN
	INSERT INTO combo(id, fk_produto, fk_produto_combo) VALUES(DEFAULT, id_produto, id_produto_combo);
END;	
$adicionar_combo$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validar_adicionar_combo() RETURNS TRIGGER AS $validar_adicionar_combo$
BEGIN
	IF NEW.fk_produto IS NULL THEN
		RAISE EXCEPTION 'O produto deve ser digitado';
	END IF;
	
	IF NEW.fk_produto NOT IN (SELECT id FROM produto) THEN
		RAISE EXCEPTION 'Produto não cadastrado'
	END IF;
	
	IF NEW.fk_produto_combo IS NULL THEN
		RAISE EXCEPTION 'O produto que faz parte do combo deve ser inserido';
	
	IF NEW.fk_produto_combo NOT IN (SELECT id FROM produto) THEN
		RAISE EXCEPTION 'Produto não cadastrado'
	END IF;
$validar_adicionar_combo$ LANGUAGE plpgsql;
