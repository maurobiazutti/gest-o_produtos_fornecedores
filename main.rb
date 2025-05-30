# main.rb
require_relative 'app/views/sistema_cadastro'

# Execução do sistema
if __FILE__ == $0
  sistema = SistemaCadastro.new
  sistema.executar
end