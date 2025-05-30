require 'json'
require_relative '../models/produto' # Ajuste o caminho
require_relative 'gerenciador_fornecedores' # Necessário para verificar o fornecedor

class GerenciadorProdutos
  def initialize(gerenciador_fornecedores, arquivo = 'data/produtos.json') # Altere o caminho do arquivo
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