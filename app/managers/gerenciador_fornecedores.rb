require 'json'
require_relative '../models/fornecedor' # Ajuste o caminho

class GerenciadorFornecedores
  def initialize(arquivo = 'data/fornecedores.json') # Altere o caminho do arquivo
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