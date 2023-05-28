--Deletar database se existir um com o nome igual.
DROP DATABASE IF EXISTS uvv;

--Deletar usuario se já existir um com nome igual.
DROP USER IF EXISTS enzozon;

--Criar usuário com permissões e senha criptografada.
CREATE USER enzozon WITH 
SUPERUSER
	
inherit
		
CREATEDB
		
CREATEROLE
		
REPLICATION

ENCRYPTED PASSWORD 'enzo123'; 


-- Criar o banco de dados uvv.
CREATE DATABASE uvv 
    
owner = enzozon
    
encoding = 'UTF8'
    
lc_collate = 'pt_BR.UTF-8'
    
lc_ctype = 'pt_BR.UTF-8'
   
template = template0
    
allow_connections = true;

-- Conectar com o usuário criado anteriormente.
\c "dbname=uvv user=enzozon password=enzo123";

-- Deletar tabela produtos se existir.
DROP TABLE IF EXISTS lojas.produtos;

-- Criar esquema lojas.
CREATE SCHEMA lojas;

-- Ajustando o esquema padrão.
ALTER USER enzozon SET SEARCH_PATH TO lojas, "$user", public;

-- Criar tabela produtos.
CREATE TABLE lojas.produtos (
	produto_id NUMERIC(38) NOT NULL,
	nome VARCHAR(255) NOT NULL,
	preco_unitario NUMERIC(10,2),
	detalhes BYTEA,
	imagem BYTEA,
	imagem_mime_type VARCHAR(512),
	imagem_arquivo VARCHAR(512),
	imagem_charset VARCHAR(512),
	imagem_ultima_atualizacao DATE,
	CONSTRAINT produto_id PRIMARY KEY (produto_id)
);

-- Criar restrições para tabela produtos.
ALTER TABLE lojas.produtos
ADD CONSTRAINT cc_produtos_preco_unitario CHECK (preco_unitario > 0);

-- Criar comentários para tabela produtos.
COMMENT ON TABLE lojas.produtos IS 'Tabela produtos do banco de dados uvv do esquema lojas.';
COMMENT ON COLUMN lojas.produtos.produto_id IS 'Primary Key da tabela produtos que faz ligação com 2 FK.';
COMMENT ON COLUMN lojas.produtos.nome IS 'Nome do produto.';
COMMENT ON COLUMN lojas.produtos.preco_unitario IS 'Preço unitário do produto.';
COMMENT ON COLUMN lojas.produtos.detalhes IS 'Detalhes do produto.';
COMMENT ON COLUMN lojas.produtos.imagem IS 'Imagem do produto.';
COMMENT ON COLUMN lojas.produtos.imagem_mime_type IS 'Padrão de identificação de tipos de arquivos na Internet da imagem do produto.';
COMMENT ON COLUMN lojas.produtos.imagem_arquivo IS 'Arquivo de imagem do produto.';
COMMENT ON COLUMN lojas.produtos.imagem_charset IS 'Charset da imagem do produto.';
COMMENT ON COLUMN lojas.produtos.imagem_ultima_atualizacao IS 'Última atualização da imagem.';

-- Deletar tabela lojas se existir.
DROP TABLE IF EXISTS lojas.lojas;

-- Criar tabela lojas.
CREATE TABLE lojas.lojas (
	loja_id NUMERIC(38) NOT NULL,
	nome VARCHAR(255) NOT NULL,
	endereco_web VARCHAR(100),
	endereco_fisico VARCHAR(512),
	latitude NUMERIC,
	longitude NUMERIC,
	logo BYTEA,
	logo_mime_type VARCHAR(512),
	logo_arquivo VARCHAR(512),
	logo_charset VARCHAR(512),
	logo_ultima_atualizacao DATE,
	CONSTRAINT loja_id PRIMARY KEY (loja_id)
);


-- Criar restrições para tabela lojas para que pelo menos um dos dois endereços esteja preenchido.
ALTER TABLE lojas.lojas
ADD CONSTRAINT endereco_preenchido CHECK ((endereco_web IS NOT NULL) OR (endereco_fisico IS NOT NULL));


--Criar comentarios para a tabela lojas.
COMMENT ON TABLE lojas.lojas IS 'Tabela lojas do banco de dados uvv do esquema lojas.';
COMMENT ON COLUMN lojas.lojas.loja_id IS 'Primary key da tabela lojas.';
COMMENT ON COLUMN lojas.lojas.nome IS 'Nome das lojas.';
COMMENT ON COLUMN lojas.lojas.endereco_web IS 'endero do site da loja.';
COMMENT ON COLUMN lojas.lojas.endereco_fisico IS 'endereco fisico da loja.';
COMMENT ON COLUMN lojas.lojas.latitude IS 'latitude da loja.';
COMMENT ON COLUMN lojas.lojas.longitude IS 'longitude da loja.';
COMMENT ON COLUMN lojas.lojas.logo IS 'logo da loja.';
COMMENT ON COLUMN lojas.lojas.logo_mime_type IS 'padrão de identificação de tipos de arquivos na Internet da logo';
COMMENT ON COLUMN lojas.lojas.logo_arquivo IS ' arquivo da logo da loja.';
COMMENT ON COLUMN lojas.lojas.logo_charset IS 'charset da logo da loja.';
COMMENT ON COLUMN lojas.lojas.logo_ultima_atualizacao IS 'ultima atualização da logo da loja.';


--Criar tabela estoques.
CREATE TABLE lojas.estoques (
                estoque_id NUMERIC(38) NOT NULL,
                loja_id NUMERIC(38) NOT NULL,
                produto_id NUMERIC(38) NOT NULL,
                quantidade NUMERIC(38) NOT NULL,
                CONSTRAINT estoque_id PRIMARY KEY (estoque_id)
);


--Criar comentarios para tabela estoques.
COMMENT ON TABLE lojas.estoques IS 'Tabela estoques do banco de dados uvv do esquema lojas.';
COMMENT ON COLUMN lojas.estoques.estoque_id IS 'id do estoque da tabela estoques.';
COMMENT ON COLUMN lojas.estoques.loja_id IS 'id da loja nos estoques.';
COMMENT ON COLUMN lojas.estoques.produto_id IS 'id do produto nos estoques.';
COMMENT ON COLUMN lojas.estoques.quantidade IS 'quantidade dos estoques.';


--Criar tabela clientes.
CREATE TABLE lojas.clientes (
                cliente_id NUMERIC(38) NOT NULL,
                email VARCHAR(255) NOT NULL,
                nome VARCHAR(255) NOT NULL,
                telefone1 VARCHAR(20),
                telefone2 VARCHAR(20),
                telefone3 VARCHAR(20),
                CONSTRAINT client_id PRIMARY KEY (cliente_id)
);

--Criar comentarios para tabela clientes.
COMMENT ON TABLE lojas.clientes IS 'Tabela clientes do banco de dados uvv do esquema lojas.';
COMMENT ON COLUMN lojas.clientes.cliente_id IS 'Primary Key da tabela clientes.';
COMMENT ON COLUMN lojas.clientes.email IS 'Email do cliente.';
COMMENT ON COLUMN lojas.clientes.nome IS 'Nome do cliente.';
COMMENT ON COLUMN lojas.clientes.telefone1 IS 'Primeiro telefone do cliente.';
COMMENT ON COLUMN lojas.clientes.telefone2 IS 'Segundo telefone do cliente.';
COMMENT ON COLUMN lojas.clientes.telefone3 IS 'Terceiro telefone do cliente.';


--Criar tabela pedidos.
CREATE TABLE lojas.pedidos (
                pedido_id NUMERIC(38) NOT NULL,
                data_hora TIMESTAMP NOT NULL,
                cliente_id NUMERIC(38) NOT NULL,
                status VARCHAR(15) NOT NULL,
                loja_id NUMERIC(38) NOT NULL,
                CONSTRAINT pedido_id PRIMARY KEY (pedido_id)
);

--Criar restrições para tabela pedidos.
ALTER TABLE lojas.pedidos
add constraint pedidos_status_check
check (status in ('CANCELADO', 'COMPLETO', 'ABERTO', 'PAGO', 'REEMBOLSADO', 'ENVIADO'));

--Criar comentarios para tabela pedidos.
COMMENT ON TABLE lojas.pedidos IS 'Tabela pedidos do banco de dados uvv do esquema lojas.';
COMMENT ON COLUMN lojas.pedidos.pedido_id IS 'Primary key da tabela pedidos.';
COMMENT ON COLUMN lojas.pedidos.data_hora IS 'Timestamp que mostra data e hora dos pedidos.';
COMMENT ON COLUMN lojas.pedidos.cliente_id IS 'Foreign Key da tabela pedidos fazedo ligação com a PK cliente_id da tabela clientes.';
COMMENT ON COLUMN lojas.pedidos.status IS 'Status do pedido.';
COMMENT ON COLUMN lojas.pedidos.loja_id IS 'Foreign Key da tabela pedidos fazedo ligação com a PK           loja_id da tabela lojas.';


--Criar tabela envios.
CREATE TABLE lojas.envios (
                envio_id NUMERIC(38) NOT NULL,
                loja_id NUMERIC(38) NOT NULL,
                cliente_id NUMERIC(38) NOT NULL,
                endereco_entrega VARCHAR(512) NOT NULL,
                status VARCHAR(15) NOT NULL,
                CONSTRAINT envio_id PRIMARY KEY (envio_id)
);

--Criar restrições para tabela envios.
ALTER TABLE lojas.envios
ADD constraint cc_envios_status
CHECK (status IN ('CRIADO', 'ENVIADO', 'TRANSITO', 'ENTREGUE'));

--Criar comentarios para tabela envios.
COMMENT ON TABLE lojas.envios IS 'Tabela envios do banco de dados uvv do esquema lojas.';
COMMENT ON COLUMN lojas.envios.envio_id IS 'id do envio da tabela envios.';
COMMENT ON COLUMN lojas.envios.loja_id IS 'id da loja na tabela envios.';
COMMENT ON COLUMN lojas.envios.cliente_id IS 'id do cliente na tabela envios.';
COMMENT ON COLUMN lojas.envios.endereco_entrega IS 'endereco da entrega na tabela envios.';
COMMENT ON COLUMN lojas.envios.status IS 'status do envio.';


--Criar tabela pedidos_itens.
CREATE TABLE lojas.pedidos_itens (
                pedido_id NUMERIC(38) NOT NULL,
                produto_id NUMERIC(38) NOT NULL,
                numero_da_linha NUMERIC(38) NOT NULL,
                preco_unitario NUMERIC(10,2) NOT NULL,
                quantidade NUMERIC(38) NOT NULL,
                envio_id NUMERIC(38) ,
                CONSTRAINT pedido_itens_pk PRIMARY KEY (pedido_id, produto_id)
);



--Criar comentarios para tabela pedidos_itens.
COMMENT ON TABLE lojas.pedidos_itens IS 'Tabela pedidos_itens do banco de dados uvv do esquema lojas.';
COMMENT ON COLUMN lojas.pedidos_itens.pedido_id IS 'Primary key da tabela pedidos_itens';
COMMENT ON COLUMN lojas.pedidos_itens.produto_id IS 'id do produto dos pedidos do itens.';
COMMENT ON COLUMN lojas.pedidos_itens.numero_da_linha IS 'numero da linha dos pedidos dos itens.';
COMMENT ON COLUMN lojas.pedidos_itens.preco_unitario IS 'preco unitario dos pedidos dos itens.';
COMMENT ON COLUMN lojas.pedidos_itens.quantidade IS 'quantidade de pedidos dos itens.';
COMMENT ON COLUMN lojas.pedidos_itens.envio_id IS 'id do envio dos pedidos dos itens';



--Criar FK para tabela envios.
ALTER TABLE lojas.envios 
ADD CONSTRAINT lojas_envios_fk
FOREIGN KEY (loja_id)
REFERENCES lojas.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.envios 
ADD CONSTRAINT clientes_envios_fk
FOREIGN KEY (cliente_id)
REFERENCES lojas.clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;


--Criar FK da tabela pedidos itens.
ALTER TABLE lojas.pedidos_itens
ADD CONSTRAINT produtos_pedidos_itens_fk
FOREIGN KEY (produto_id)
REFERENCES lojas.produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.pedidos_itens
ADD CONSTRAINT pedidos_pedidos_itens_fk
FOREIGN KEY (pedido_id)
REFERENCES lojas.pedidos (pedido_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.pedidos_itens 
ADD CONSTRAINT envios_pedidos_itens_fk
FOREIGN KEY (envio_id)
REFERENCES lojas.envios (envio_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--Criar FK para tabela estoques.
ALTER TABLE lojas.estoques 
ADD CONSTRAINT produtos_estoques_fk
FOREIGN KEY (produto_id)
REFERENCES lojas.produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.estoques 
ADD CONSTRAINT lojas_estoques_fk
FOREIGN KEY (loja_id)
REFERENCES lojas.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;


--Criar FK para tabela pedidos.
ALTER TABLE lojas.pedidos 
ADD CONSTRAINT lojas_pedidos_fk
FOREIGN KEY (loja_id)
REFERENCES lojas.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.pedidos 
ADD CONSTRAINT clientes_pedidos_fk
FOREIGN KEY (cliente_id)
REFERENCES lojas.clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;


