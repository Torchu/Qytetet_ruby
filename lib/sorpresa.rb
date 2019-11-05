# encoding: UTF-8
module ModeloQytetet
  class Sorpresa
    #attr_accessor genera los getters y setters
    attr_accessor :texto, :valor, :tipo
  
    #initialize inicializa los atributos
    def initialize(un_texto, un_valor, un_tipo)
      @texto=un_texto
      @valor=un_valor
      @tipo=un_tipo
    end

    #Metodo to String
    def to_s
      "Texto: #{@texto} \n Valor: #{@valor} \n Tipo: #{@tipo}"
    end
  end
end