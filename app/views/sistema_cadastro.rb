require_relative '../managers/gerenciador_fornecedores'
require_relative '../managers/gerenciador_produtos'
require_relative '../models/fornecedor'
require_relative '../models/produto'

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