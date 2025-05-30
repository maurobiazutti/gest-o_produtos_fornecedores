require 'date'

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