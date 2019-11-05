# encoding: UTF-8
require_relative "sorpresa.rb"
require_relative "casilla.rb"
require_relative "titulo_propiedad.rb"
require_relative "especulador.rb"
module ModeloQytetet
  class Jugador
    attr_accessor :encarcelado, :nombre, :saldo, :carta_libertad, :casilla_actual, :propiedades 
    def initialize(carcel, un_nombre, un_saldo, una_carta_libertad, una_casilla_actual, unas_propiedades)
      @encarcelado=carcel
      @nombre=un_nombre
      @saldo=un_saldo
      @carta_libertad=una_carta_libertad
      @casilla_actual=una_casilla_actual
      @propiedades=unas_propiedades
    end
    
    def self.nuevo(un_nombre)
      self.new(false, un_nombre, 7500, nil, nil, Array.new)
    end
    
    def self.copia (otro_jugador)
        new(otro_jugador.encarcelado, otro_jugador.nombre, otro_jugador.saldo, otro_jugador.carta_libertad, otro_jugador.casilla_actual, otro_jugador.propiedades)
    end
    
    def cancelar_hipoteca(titulo)
      coste_cancelar=titulo.calcular_coste_cancelar
      if @saldo>coste_cancelar
        modificar_saldo(-coste_cancelar)
        titulo.cancelar_hipoteca
        true
      else
        false
      end
    end
    
    def comprar_titulo_propiedad
      comprado=false
      coste_compra=@casilla_actual.coste
      if coste_compra<@saldo
        comprado=true
        titulo=@casilla_actual.asignar_propietario(self)
        @propiedades<<titulo
        modificar_saldo(-coste_compra)
      end
      comprado
    end
    
    def convertirme(fianza)
      esp=Especulador.copia(self, fianza)
    end
    
    def cuantas_casas_hoteles_tengo
      num_casas_hoteles=0
      @propiedades.each do |p|
        num_casas_hoteles+=(p.num_casas+p.num_hoteles)
      end
      num_casas_hoteles
    end
    
    def debo_ir_a_carcel
      !tengo_carta_libertad
    end
    
    def debo_pagar_alquiler
      titulo=@casilla_actual.titulo
      if(!es_de_mi_propiedad(titulo) && titulo.tengo_propietario && !titulo.propietario_encarcelado && !titulo.hipotecada)
        true
      else
        false
      end
    end
    
    def devolver_carta_libertad
      aux=@carta_libertad
      carta_libertad=nil
      aux
    end
    
    def edificar_casa(titulo)
      if puedo_edificar_casa(titulo) then
        titulo.edificar_casa
        modificar_saldo(-titulo.precio_edificar)
        true
      else
        false
      end
    end
    
    def edificar_hotel(titulo)
      if puedo_edificar_hotel(titulo) then
        titulo.edificar_hotel
        modificar_saldo(-titulo.precio_edificar)
        true
      else
        false
      end
    end
    
    private
    def eliminar_de_mis_propiedades(titulo)
      @propiedades.delete(titulo)
      titulo.propietario=nil
    end
    
    def es_de_mi_propiedad(titulo)
      @propiedades.include?(titulo)
    end
    
    public
    def estoy_en_calle_libre
      !@encarcelado
    end
    
    def hipotecar_propiedad(titulo)
      coste_hipoteca=titulo.hipotecar
      modificar_saldo(coste_hipoteca)
    end
    
    def ir_a_carcel(casilla)
      @casilla_actual=casilla
      @encarcelado=true
    end
    
    def modificar_saldo(cantidad)
      @saldo+=cantidad
    end
    
    def obtener_capital
      capital=@saldo
      @propiedades.each do |p|
        capital+=(p.precio_compra+cuantas_casas_hoteles_tengo*p.precio_edificar)
        if p.hipotecada
          capital-=p.hipoteca_base
        end
      end
      capital
    end
    
    def obtener_propiedades(hipotecada)
      aux=Array.new
      @propiedades.each do |p|
        if p.hipotecada==hipotecada
          aux<<p
        end
      end
      aux
    end
    
    def pagar_alquiler
      coste_alquiler=@casilla_actual.pagar_alquiler
      modificar_saldo(-coste_alquiler)
    end
    
    def pagar_impuesto
      @saldo-=@casilla_actual.coste
    end
    protected :pagar_impuesto
    
    def pagar_libertad(cantidad)
      tengo_saldo=tengo_saldo(cantidad)
      if tengo_saldo
        @encarcelado=false
        modificar_saldo(-cantidad)
      end
    end
    
    protected
    def puedo_edificar_casa(titulo)
      if (titulo.num_casas<4 && tengo_saldo(titulo.precio_edificar)) then
        true
      else
        false
      end
    end
    
    def puedo_edificar_hotel(titulo)
      if (titulo.num_hoteles<4 && tengo_saldo(titulo.precio_edificar) && titulo.num_casas>=4) then
        true
      else
        false
      end
    end
    
    public
    def tengo_carta_libertad
      @carta_libertad!=nil
    end
    
    private
    def tengo_saldo(cantidad)
      @saldo>cantidad
    end
    protected :tengo_saldo
    
    public
    def vender_propiedad(casilla)
      titulo=casilla.titulo
      eliminar_de_mis_propiedades(titulo)
      precio_venta=titulo.calcular_precio_venta
      modificar_saldo(precio_venta)
    end
    
    def <=>(otroJugador)
      otroJugador.obtener_capital <=> obtener_capital
    end
    
    def to_s
      "Jugador{encarcelado: encarcelado, nombre: #{@nombre}, saldo: #{@saldo}, cartaLibertad: #{@carta_libertad}, casilla actual: #{@casilla_actual}, propiedades: #{@propiedades}}"
    end
  end
end
