require 'json'
require 'date'

# Classe para representar um Fornecedor
class Fornecedor
  attr_accessor :id, :nome, :cnpj, :email, :telefone, :endereco, :data_cadastro

  def initialize(nome, cnpj, email, telefone, endereco)
    @id = generate_id
    @nome = nome
    @cnpj = cnpj
    @email = email
    @telefone = telefone
    @endereco = endereco
    @data_cadastro = Date.today
  end

  def to_hash
    {
      id: @id,
      nome: @nome,
      cnpj: @cnpj,
      email: @email,
      telefone: @telefone,
      endereco: @endereco,
      data_cadastro: @data_cadastro.to_s
    }
  end

  def self.from_hash(hash)
    fornecedor = allocate
    fornecedor.id = hash['id']
    fornecedor.nome = hash['nome']
    fornecedor.cnpj = hash['cnpj']
    fornecedor.email = hash['email']
    fornecedor.telefone = hash['telefone']
    fornecedor.endereco = hash['endereco']
    fornecedor.data_cadastro = Date.parse(hash['data_cadastro'])
    fornecedor
  end

  def valido?
    !@nome.empty? && !@cnpj.empty? && cnpj_valido? && email_valido?
  end

  private

  def generate_id
    Time.now.to_f.to_s.gsub('.', '')
  end

  def cnpj_valido?
    # Validação básica de CNPJ (apenas formato)
    @cnpj.gsub(/\D/, '').length == 14
  end

  def email_valido?
    @email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end
end

# Classe para representar um Produto
class Produto
  attr_accessor :id, :nome, :descricao, :preco, :categoria, :fornecedor_id, :estoque, :data_cadastro

  def initialize(nome, descricao, preco, categoria, fornecedor_id, estoque = 0)
    @id = generate_id
    @nome = nome
    @descricao = descricao
    @preco = preco.to_f
    @categoria = categoria
    @fornecedor_id = fornecedor_id
    @estoque = estoque.to_i
    @data_cadastro = Date.today
  end

  def to_hash
    {
      id: @id,
      nome: @nome,
      descricao: @descricao,
      preco: @preco,
      categoria: @categoria,
      fornecedor_id: @fornecedor_id,
      estoque: @estoque,
      data_cadastro: @data_cadastro.to_s
    }
  end

  def self.from_hash(hash)
    produto = allocate
    produto.id = hash['id']
    produto.nome = hash['nome']
    produto.descricao = hash['descricao']
    produto.preco = hash['preco'].to_f
    produto.categoria = hash['categoria']
    produto.fornecedor_id = hash['fornecedor_id']
    produto.estoque = hash['estoque'].to_i
    produto.data_cadastro = Date.parse(hash['data_cadastro'])
    produto
  end

  def valido?
    !@nome.empty? && @preco > 0 && !@categoria.empty? && !@fornecedor_id.nil?
  end

  def preco_formatado
    "R$ %.2f" % @preco
  end

  private

  def generate_id
    Time.now.to_f.to_s.gsub('.', '')
  end
end

# Classe para gerenciar fornecedores
class GerenciadorFornecedores
  def initialize(arquivo = 'fornecedores.json')
    @arquivo = arquivo
    @fornecedores = carregar_fornecedores
  end

  def adicionar(fornecedor)
    if fornecedor.valido?
      @fornecedores << fornecedor
      salvar_fornecedores
      puts "Fornecedor '#{fornecedor.nome}' cadastrado com sucesso!"
      true
    else
      puts "Erro: Dados do fornecedor são inválidos!"
      false
    end
  end

  def listar
    if @fornecedores.empty?
      puts "Nenhum fornecedor cadastrado."
      return
    end

    puts "\n=== LISTA DE FORNECEDORES ==="
    @fornecedores.each do |f|
      puts "-" * 50
      puts "ID: #{f.id}"
      puts "Nome: #{f.nome}"
      puts "CNPJ: #{f.cnpj}"
      puts "Email: #{f.email}"
      puts "Telefone: #{f.telefone}"
      puts "Endereço: #{f.endereco}"
      puts "Data de Cadastro: #{f.data_cadastro}"
    end
    puts "-" * 50
  end

  def buscar_por_id(id)
    @fornecedores.find { |f| f.id == id }
  end

  def buscar_por_nome(nome)
    @fornecedores.select { |f| f.nome.downcase.include?(nome.downcase) }
  end

  def remover(id)
    fornecedor = buscar_por_id(id)
    if fornecedor
      @fornecedores.delete(fornecedor)
      salvar_fornecedores
      puts "Fornecedor '#{fornecedor.nome}' removido com sucesso!"
      true
    else
      puts "Fornecedor não encontrado!"
      false
    end
  end

  def todos
    @fornecedores
  end

  private

  def carregar_fornecedores
    return [] unless File.exist?(@arquivo)
    
    begin
      dados = JSON.parse(File.read(@arquivo))
      dados.map { |f| Fornecedor.from_hash(f) }
    rescue JSON::ParserError
      puts "Erro ao carregar arquivo de fornecedores. Iniciando com lista vazia."
      []
    end
  end

  def salvar_fornecedores
    File.write(@arquivo, JSON.pretty_generate(@fornecedores.map(&:to_hash)))
  end
end

# Classe para gerenciar produtos
class GerenciadorProdutos
  def initialize(gerenciador_fornecedores, arquivo = 'produtos.json')
    @arquivo = arquivo
    @produtos = carregar_produtos
    @gerenciador_fornecedores = gerenciador_fornecedores
  end

  def adicionar(produto)
    # Verificar se o fornecedor existe
    fornecedor = @gerenciador_fornecedores.buscar_por_id(produto.fornecedor_id)
    unless fornecedor
      puts "Erro: Fornecedor não encontrado!"
      return false
    end

    if produto.valido?
      @produtos << produto
      salvar_produtos
      puts "Produto '#{produto.nome}' cadastrado com sucesso!"
      true
    else
      puts "Erro: Dados do produto são inválidos!"
      false
    end
  end

  def listar
    if @produtos.empty?
      puts "Nenhum produto cadastrado."
      return
    end

    puts "\n=== LISTA DE PRODUTOS ==="
    @produtos.each do |p|
      fornecedor = @gerenciador_fornecedores.buscar_por_id(p.fornecedor_id)
      puts "-" * 50
      puts "ID: #{p.id}"
      puts "Nome: #{p.nome}"
      puts "Descrição: #{p.descricao}"
      puts "Preço: #{p.preco_formatado}"
      puts "Categoria: #{p.categoria}"
      puts "Fornecedor: #{fornecedor ? fornecedor.nome : 'N/A'}"
      puts "Estoque: #{p.estoque} unidades"
      puts "Data de Cadastro: #{p.data_cadastro}"
    end
    puts "-" * 50
  end

  def buscar_por_id(id)
    @produtos.find { |p| p.id == id }
  end

  def buscar_por_nome(nome)
    @produtos.select { |p| p.nome.downcase.include?(nome.downcase) }
  end

  def buscar_por_categoria(categoria)
    @produtos.select { |p| p.categoria.downcase.include?(categoria.downcase) }
  end

  def buscar_por_fornecedor(fornecedor_id)
    @produtos.select { |p| p.fornecedor_id == fornecedor_id }
  end

  def remover(id)
    produto = buscar_por_id(id)
    if produto
      @produtos.delete(produto)
      salvar_produtos
      puts "Produto '#{produto.nome}' removido com sucesso!"
      true
    else
      puts "Produto não encontrado!"
      false
    end
  end

  def atualizar_estoque(id, nova_quantidade)
    produto = buscar_por_id(id)
    if produto
      produto.estoque = nova_quantidade.to_i
      salvar_produtos
      puts "Estoque do produto '#{produto.nome}' atualizado para #{produto.estoque} unidades!"
      true
    else
      puts "Produto não encontrado!"
      false
    end
  end

  def todos
    @produtos
  end

  private

  def carregar_produtos
    return [] unless File.exist?(@arquivo)
    
    begin
      dados = JSON.parse(File.read(@arquivo))
      dados.map { |p| Produto.from_hash(p) }
    rescue JSON::ParserError
      puts "Erro ao carregar arquivo de produtos. Iniciando com lista vazia."
      []
    end
  end

  def salvar_produtos
    File.write(@arquivo, JSON.pretty_generate(@produtos.map(&:to_hash)))
  end
end

# Classe principal do sistema
class SistemaCadastro
  def initialize
    @gerenciador_fornecedores = GerenciadorFornecedores.new
    @gerenciador_produtos = GerenciadorProdutos.new(@gerenciador_fornecedores)
  end

  def executar
    loop do
      mostrar_menu
      opcao = gets.chomp.to_i

      case opcao
      when 1
        cadastrar_fornecedor
      when 2
        listar_fornecedores
      when 3
        buscar_fornecedor
      when 4
        remover_fornecedor
      when 5
        cadastrar_produto
      when 6
        listar_produtos
      when 7
        buscar_produto
      when 8
        remover_produto
      when 9
        atualizar_estoque
      when 10
        relatorios
      when 0
        puts "Encerrando o sistema..."
        break
      else
        puts "Opção inválida! Tente novamente."
      end

      puts "\nPressione Enter para continuar..."
      gets
    end
  end

  private

  def mostrar_menu
    system('clear') || system('cls')
    puts "=" * 60
    puts "           SISTEMA DE CADASTRO DE PRODUTOS E FORNECEDORES"
    puts "=" * 60
    puts "1.  Cadastrar Fornecedor"
    puts "2.  Listar Fornecedores"
    puts "3.  Buscar Fornecedor"
    puts "4.  Remover Fornecedor"
    puts "5.  Cadastrar Produto"
    puts "6.  Listar Produtos"
    puts "7.  Buscar Produto"
    puts "8.  Remover Produto"
    puts "9.  Atualizar Estoque"
    puts "10. Relatórios"
    puts "0.  Sair"
    puts "=" * 60
    print "Escolha uma opção: "
  end

  def cadastrar_fornecedor
    puts "\n=== CADASTRO DE FORNECEDOR ==="
    print "Nome: "
    nome = gets.chomp
    print "CNPJ: "
    cnpj = gets.chomp
    print "Email: "
    email = gets.chomp
    print "Telefone: "
    telefone = gets.chomp
    print "Endereço: "
    endereco = gets.chomp

    fornecedor = Fornecedor.new(nome, cnpj, email, telefone, endereco)
    @gerenciador_fornecedores.adicionar(fornecedor)
  end

  def listar_fornecedores
    @gerenciador_fornecedores.listar
  end

  def buscar_fornecedor
    puts "\n=== BUSCAR FORNECEDOR ==="
    puts "1. Buscar por nome"
    puts "2. Buscar por ID"
    print "Escolha: "
    
    case gets.chomp.to_i
    when 1
      print "Digite o nome: "
      nome = gets.chomp
      fornecedores = @gerenciador_fornecedores.buscar_por_nome(nome)
      if fornecedores.empty?
        puts "Nenhum fornecedor encontrado."
      else
        fornecedores.each { |f| puts "#{f.id} - #{f.nome}" }
      end
    when 2
      print "Digite o ID: "
      id = gets.chomp
      fornecedor = @gerenciador_fornecedores.buscar_por_id(id)
      if fornecedor
        puts "Encontrado: #{fornecedor.nome} - #{fornecedor.email}"
      else
        puts "Fornecedor não encontrado."
      end
    end
  end

  def remover_fornecedor
    puts "\n=== REMOVER FORNECEDOR ==="
    listar_fornecedores
    print "\nDigite o ID do fornecedor a ser removido: "
    id = gets.chomp
    @gerenciador_fornecedores.remover(id)
  end

  def cadastrar_produto
    puts "\n=== CADASTRO DE PRODUTO ==="
    
    # Mostrar fornecedores disponíveis
    if @gerenciador_fornecedores.todos.empty?
      puts "Não há fornecedores cadastrados! Cadastre um fornecedor primeiro."
      return
    end

    puts "Fornecedores disponíveis:"
    @gerenciador_fornecedores.todos.each { |f| puts "#{f.id} - #{f.nome}" }
    
    print "\nNome do produto: "
    nome = gets.chomp
    print "Descrição: "
    descricao = gets.chomp
    print "Preço: R$ "
    preco = gets.chomp.to_f
    print "Categoria: "
    categoria = gets.chomp
    print "ID do Fornecedor: "
    fornecedor_id = gets.chomp
    print "Estoque inicial: "
    estoque = gets.chomp.to_i

    produto = Produto.new(nome, descricao, preco, categoria, fornecedor_id, estoque)
    @gerenciador_produtos.adicionar(produto)
  end

  def listar_produtos
    @gerenciador_produtos.listar
  end

  def buscar_produto
    puts "\n=== BUSCAR PRODUTO ==="
    puts "1. Buscar por nome"
    puts "2. Buscar por categoria"
    puts "3. Buscar por fornecedor"
    print "Escolha: "
    
    case gets.chomp.to_i
    when 1
      print "Digite o nome: "
      nome = gets.chomp
      produtos = @gerenciador_produtos.buscar_por_nome(nome)
      mostrar_produtos_encontrados(produtos)
    when 2
      print "Digite a categoria: "
      categoria = gets.chomp
      produtos = @gerenciador_produtos.buscar_por_categoria(categoria)
      mostrar_produtos_encontrados(produtos)
    when 3
      listar_fornecedores
      print "\nDigite o ID do fornecedor: "
      fornecedor_id = gets.chomp
      produtos = @gerenciador_produtos.buscar_por_fornecedor(fornecedor_id)
      mostrar_produtos_encontrados(produtos)
    end
  end

  def mostrar_produtos_encontrados(produtos)
    if produtos.empty?
      puts "Nenhum produto encontrado."
    else
      produtos.each { |p| puts "#{p.id} - #{p.nome} - #{p.preco_formatado}" }
    end
  end

  def remover_produto
    puts "\n=== REMOVER PRODUTO ==="
    listar_produtos
    print "\nDigite o ID do produto a ser removido: "
    id = gets.chomp
    @gerenciador_produtos.remover(id)
  end

  def atualizar_estoque
    puts "\n=== ATUALIZAR ESTOQUE ==="
    listar_produtos
    print "\nDigite o ID do produto: "
    id = gets.chomp
    print "Nova quantidade em estoque: "
    quantidade = gets.chomp.to_i
    @gerenciador_produtos.atualizar_estoque(id, quantidade)
  end

  def relatorios
    puts "\n=== RELATÓRIOS ==="
    puts "1. Total de fornecedores: #{@gerenciador_fornecedores.todos.length}"
    puts "2. Total de produtos: #{@gerenciador_produtos.todos.length}"
    
    if @gerenciador_produtos.todos.any?
      valor_total = @gerenciador_produtos.todos.sum { |p| p.preco * p.estoque }
      puts "3. Valor total do estoque: R$ %.2f" % valor_total
      
      # Produtos com estoque baixo
      produtos_baixo_estoque = @gerenciador_produtos.todos.select { |p| p.estoque < 10 }
      if produtos_baixo_estoque.any?
        puts "\n4. Produtos com estoque baixo (< 10 unidades):"
        produtos_baixo_estoque.each { |p| puts "   - #{p.nome}: #{p.estoque} unidades" }
      end
    end
  end
end

# Execução do sistema
if __FILE__ == $0
  sistema = SistemaCadastro.new
  sistema.executar
end