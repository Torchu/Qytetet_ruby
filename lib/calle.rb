# encoding: UTF-8
module ModeloQytetet
  class Calle < Casilla
    attr_accessor :titulo
    
    def initialize(un_numero, un_titulo)
      super(un_numero, TipoCasilla::CALLE, un_titulo.precio_compra)
      @titulo=un_titulo
    end
    
    def asignar_propietario(jugador)
      @titulo.propietario=jugador
      @titulo
    end
    
    def pagar_alquiler
      @titulo.pagar_alquiler
    end
    
    def tengo_propietario
        @titulo.tengo_propietario
    end
    
    def soy_edificable
      true
    end
    
  end
end
