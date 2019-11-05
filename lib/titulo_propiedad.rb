# encoding: UTF-8
module ModeloQytetet
  class TituloPropiedad
    #attr_accessor genera los getters y setters
    attr_accessor :nombre, :hipotecada, :precio_compra, :alquiler_base, :factor_revalorizacion, :hipoteca_base, :precio_edificar, :num_casas, :num_hoteles, :propietario
    #initialize inicializa todos los atributos(Default: hipotecada=false, numCasas=0 & numHoteles=0)
    def initialize( un_nombre,  un_precio_compra,  un_alquiler_base,  un_factor_revalorizacion,  una_hipoteca_base,  un_precio_edificar)
      @nombre=un_nombre
      @hipotecada=false
      @precio_compra=un_precio_compra
      @alquiler_base=un_alquiler_base
      @factor_revalorizacion=un_factor_revalorizacion
      @hipoteca_base=una_hipoteca_base
      @precio_edificar=un_precio_edificar
      @num_casas=0
      @num_hoteles=0
      @propietario=nil
    end
    
    def calcular_coste_cancelar
      calcular_coste_hipotecar*1.1
    end
    
    def calcular_coste_hipotecar
      @hipoteca_base*(1+@num_casas/2+@num_hoteles*2)
    end
    
    def calcular_importe_alquiler
      @alquiler_base*(@num_casas/2+@num_hoteles*2)
    end
    
    def calcular_precio_venta
      @precio_compra+(@num_casas+@num_hoteles)*@precio_edificar*@factor_revalorizacion
    end
    
    def cancelar_hipoteca
      @hipotecada=false
    end
    
    def edificar_casa
      @num_casas+=1
    end
    
    def edificar_hotel
      @num_casas-=4
      @num_hoteles+=1
    end
    
    def hipotecar
      @hipotecada=true
      calcular_coste_hipotecar
    end
    
    def pagar_alquiler
      coste_alquiler=calcular_importe_alquiler
      @propietario.modificar_saldo(coste_alquiler)
      coste_alquiler
    end
    
    def propietario_encarcelado
      @propietario.encarcelado
    end
    
    def tengo_propietario
      @propietario!=nil
    end
  
    #Metodo to String
    def to_s
      "Propiedad{ nombre: #{@nombre}, hipotecada: #{@hipotecada}, precio de compra: #{@precio_compra}, alquiler: #{@alquiler_base}, revalorizacion: #{@factor_revalorizacion}, hipoteca: #{@hipoteca_base}, precio de edificar: #{@precio_edificar}, casas: #{@num_casas}, hoteles: #{@num_hoteles} }"
    end
  end
end