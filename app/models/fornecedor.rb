require 'date'

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