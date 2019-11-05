# encoding: UTF-8
require_relative "jugador.rb"
module ModeloQytetet
  class Especulador < Jugador
    attr_accessor :fianza

    def self.copia(otro_jugador, una_fianza)
      e = super(otro_jugador)
      e.fianza=una_fianza
      e
    end
    
    def pagar_impuesto
      modificar_saldo(-casilla_actual.coste/2)
    end
    
    def debo_ir_a_carcel
      if super.debo_ir_a_carcel then
        !pagar_fianza
      else
        false
      end
    end
    
    def convertirme(una_fianza)
      return self
    end
    
    private
    def pagar_fianza
      if saldo>@fianza then
        modificar_saldo(-@fianza)
        true
      else
        false
      end
    end
    
    protected
    def puedo_edificar_casa(titulo)
      if (titulo.num_casas<8 && tengo_saldo(titulo.precio_edificar)) then
        true
      else
        false
      end
    end
    
    def puedo_edificar_hotel(titulo)
      if (titulo.num_hoteles<8 && tengo_saldo(titulo.precio_edificar) && titulo.num_casas>=4) then
        true
      else
        false
      end
    end
    
    public
    def to_s
      "Especulador fianza #{@fianza} #{super.to_s}"
    end
  end
end
