# encoding: UTF-8
require_relative "titulo_propiedad.rb"
require_relative "tipo_casilla.rb"
module ModeloQytetet
  class Casilla
    #Genera los getters y setters
    attr_accessor :numero_casilla, :coste, :tipo
    
    def initialize(un_numero, un_tipo, coste)
      @numero_casilla=un_numero
      @tipo=un_tipo
      @coste = coste
    end
    
    def soy_edificable
      false
    end
  
    #Metodo to String
    def to_s
      "Casilla{numero de casilla: #{@numero_casilla}, coste: #{@coste}, tipo: #{@tipo}, titulo: #{@titulo}}"
    end 
  end
end