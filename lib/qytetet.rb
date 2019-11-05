# encoding: UTF-8
module ModeloQytetet
require_relative "tipo_sorpresa"
require_relative "tablero"
require_relative "jugador"
require_relative "dado"
require_relative "estado_juego"
require "singleton"
  class Qytetet
    #attr_accessor genera los getters y setters
    attr_accessor :carta_actual, :mazo, :jugadores, :jugador_actual, :tablero, :dado, :estado_juego
    include Singleton
    
    MAX_JUGADORES=4
    NUM_SORPRESAS=10
    NUM_CASILLAS=20
    PRECIO_LIBERTAD=200
    SALDO_SALIDA=1000
    
    #initialize inicializa los atributos
    def initialize
      @carta_actual=nil
      @mazo=Array.new
      @jugadores=Array.new
      @jugador_actual=nil
      @tablero=nil
      @dado=Dado.instance
      @estado_juego=nil
    end
    
    def actuar_si_en_casilla_edificable
      debo_pagar=@jugador_actual.debo_pagar_alquiler
      if debo_pagar
        @jugador_actual.pagar_alquiler
        if @jugador_actual.saldo<=0
          @estado_juego=EstadoJuego::ALGUNJUGADORENBANCARROTA
        end
      end
      casilla=obtener_casilla_jugador_actual
      tengo_propietario=casilla.tengo_propietario
      if @estado_juego!=EstadoJuego::ALGUNJUGADORENBANCARROTA
        if tengo_propietario
          @estado_juego=EstadoJuego::JA_PUEDEGESTIONAR
        else
          @estado_juego=EstadoJuego::JA_PUEDECOMPRARGESTIONAR
        end
      end
    end
    
    def actuar_si_en_casilla_no_edificable
      @estado=EstadoJuego::JA_PUEDEGESTIONAR
      casilla_actual=@jugador_actual.casilla_actual
      if casilla_actual.tipo==TipoCasilla::IMPUESTO
        @jugador_actual.pagar_impuesto
      elsif casilla_actual.tipo==TipoCasilla::JUEZ
        encarcelar_jugador
      elsif casilla_actual.tipo==TipoCasilla::SORPRESA
        @carta_actual=@mazo.delete_at(0)
        @estado_juego=EstadoJuego::JA_CONSORPRESA
      end
    end
    
    def aplicar_sorpresa
      @estado_juego=EstadoJuego::JA_PUEDEGESTIONAR
      if @carta_actual.tipo==TipoSorpresa::SALIRCARCEL
        @jugador_actual.carta_libertad=@carta_actual
      else
        @mazo<<@carta_actual
      end
      if @carta_actual.tipo==TipoSorpresa::PAGARCOBRAR
        @jugador_actual.modificar_saldo(@carta_actual.valor)
        if @jugador_actual.saldo<=0
          @estado_juego=EstadoJuego::ALGUNJUGADORENBANCARROTA
        end
      elsif @carta_actual.tipo==TipoSorpresa::CONVERTIRME
        esp=@jugador_actual.convertirme(@carta_actual.valor)
        @jugadores[@jugadores.index(@jugador_actual)]=esp
        @jugador_actual=esp
      elsif @cartal_actual.tipo==TipoSorpresa::IRACASILLA
        valor=@carta_actual.valor
        casilla_carcel=@tablero.es_casilla_carcel(valor)
        if(casilla_carcel)
          encarcelar_jugador
        else
          mover(valor)
        end
      elsif @carta_actual.tipo==TipoSorpresa::PORCASAHOTEL
        cantidad=@carta_actual.valor
        numero_total=@jugador_actual.cuantas_casas_hoteles_tengo
        @jugador_actual.modificar_saldo(cantidad*numero_total)
        if @jugador_actual.saldo<=0
          @estado_juego=ALGUNJUGADORENBANCARROTA
        end
      elsif @carta_actual.tipo=TipoSorpresa::PORJUGADOR
        @jugadores.each do |jugador|
          if jugador!=@jugador_actual
            jugador.modificar_saldo(@carta_actual.valor)
            if jugador.saldo<=0
              @estado_juego=EstadoJuego::ALGUNJUGADORENBANCARROTA
            end
            @jugador_actual.modificar_saldo(-@carta_actual.valor)
            if @jugador_actual.saldo<=0
              @estado_juego=EstadoJuego::ALGUNJUGADORENBANCARROTA
            end
          end
        end
      end
    end
    
    def cancelar_hipoteca(numero_casilla)
      casilla=@tablero.obtener_casilla_numero(numero_casilla)
      titulo=casilla.titulo
      cancelada=@jugador_actual.cancelar_hipoteca(titulo)
      @estado_juego=EstadoJuego::JA_PUEDEGESTIONAR
      cancelada
    end
    
    def comprar_titulo_propiedad
      comprado=@jugador_actual.comprar_titulo_propiedad
      if comprado
        @estado_juego=EstadoJuego::JA_PUEDEGESTIONAR
      end
      comprado
    end
    
    def edificar_casa(numero_casilla)
      casilla=@tablero.obtener_casilla_numero(numero_casilla)
      titulo=casilla.titulo
      edificada=@jugador_actual.edificar_casa(titulo)
      if edificada
        @estado_juego=EstadoJuego::JA_PUEDEGESTIONAR
      end
      edificada
    end
    
    def edificar_hotel(numero_casilla)
      casilla=@tablero.obtener_casilla_numero(numero_casilla)
      titulo=casilla.titulo
      edificado=@jugador_actual.edificar_hotel(titulo)
      if edificado
        @estado_juego=EstadoJuego::JA_PUEDEGESTIONAR
      end
      edificado
    end
    
    def encarcelar_jugador
      if @jugador_actual.debo_ir_a_carcel then
        casilla_carcel=@tablero.carcel
        @jugador_actual.ir_a_carcel(casilla_carcel)
        @estado_juego=EstadoJuego::JA_ENCARCELADO
      else
        if @jugador_actual.tengo_carta_libertad then
          carta=@jugador_actual.devolver_carta_libertad
          @mazo<<carta
        end
        @estado_juego=EstadoJuego::JA_PUEDEGESTIONAR
      end
    end
    private :encarcelar_jugador
    
    def hipotecar_propiedad(numero_casilla)
      casilla=@tablero.obtener_casilla_numero(numero_casilla)
      titulo=casilla.titulo
      @jugador_actual.hipotecar_propiedad(titulo)
      @estado_juego=EstadoJuego::JA_PUEDEGESTIONAR
    end
    
    #Inicializa todas las cartas sorpresa del mazo
    def inicializar_cartas_sorpresa
      #CONVERTIRME
      @mazo<<Sorpresa.new("Has sido ascendido, conviertete en especulador", 3000, TipoSorpresa::CONVERTIRME)
      @mazo<<Sorpresa.new("Has sido ascendido, conviertete en especulador", 5000, TipoSorpresa::CONVERTIRME)
      #PAGARCOBRAR
      @mazo<<Sorpresa.new("Hoy es tu dia de suerte cobras 1000 sin tener que pasar por la salida", 1000, TipoSorpresa::PAGARCOBRAR)
      @mazo<<Sorpresa.new("No todo iba a ser bueno, pierdes 1000", 1000, TipoSorpresa::PAGARCOBRAR)
      #IRACASILLA
      @mazo<<Sorpresa.new("Ve a la casilla 7, si pasas por la salida cobra", 7, TipoSorpresa::IRACASILLA)
      @mazo<<Sorpresa.new("Ve a la casilla 14, si pasas por la salida cobra", 14, TipoSorpresa::IRACASILLA)
      @mazo<<Sorpresa.new("Ve a la carcel sin pasar por la salida", 9, TipoSorpresa::IRACASILLA)
      #PORCASAHOTEL
      @mazo<<Sorpresa.new("Eres una persona afortunada, cobra 250 por cada casa y hotel en tu propiedad", 250, TipoSorpresa::PORCASAHOTEL)
      @mazo<<Sorpresa.new("La desgracia cae sobre ti, paga 500 por cada casa y hotel en tu propiedad", 500, TipoSorpresa::PORCASAHOTEL)
      #PORJUGADOR
      @mazo<<Sorpresa.new("Hoy es tu cumpleanos, recibe 250 de cada jugador", 250, TipoSorpresa::PORJUGADOR)
      @mazo<<Sorpresa.new("Hoy invitas tu, paga 250 a cada jugador", 250, TipoSorpresa::PORJUGADOR)
      #SALIRCARCEL
      @mazo<<Sorpresa.new("Esta es la llave maestra, usala para salir de la carcel", 0, TipoSorpresa::SALIRCARCEL)
      #Mezclar
      #@mazo.shuffle
    end
    private :inicializar_cartas_sorpresa
    
    def inicializar_juego(nombres)
      
      inicializar_jugadores(nombres)
      inicializar_tablero
      inicializar_cartas_sorpresa
      salida_jugadores
    end
    
    private
    def inicializar_jugadores(nombres)
      for item in nombres do
        @jugadores<<Jugador.nuevo(item)
      end
    end
    
    def inicializar_tablero
      @tablero=Tablero.new
    end
    
    public
    def intentar_salir_carcel(metodo)
      if metodo==MetodoSalirCarcel::TIRANDODADO
        resultado=tirar_dado
        if resultado>=5
          @jugador_actual.encarcelado=false
        end
      elsif metodo==MetodoSalirCarcel::PAGANDOLIBERTAD
        @jugador_actual.pagar_libertad(PRECIO_LIBERTAD)
      end
      encarcelado=@jugador_actual.encarcelado
      if encarcelado
        @estado_juego=EstadoJuego::JA_ENCARCELADO
      else
        @estado_juego=EstadoJuego::JA_PREPARADO
      end
      !encarcelado
    end
    
    def jugar
      valor_dado=tirar_dado
      destino=@tablero.obtener_casilla_final(obtener_casilla_jugador_actual, valor_dado)
      mover(destino.numero_casilla)
    end
    
    def mover(num_casilla_destino)
        casilla_inicial=@jugador_actual.casilla_actual
        casilla_final=@tablero.obtener_casilla_numero(num_casilla_destino)
        @jugador_actual.casilla_actual=casilla_final
        if num_casilla_destino<casilla_inicial.numero_casilla
          @jugador_actual.modificar_saldo(SALDO_SALIDA)
        end
        if casilla_final.soy_edificable
          actuar_si_en_casilla_edificable
        else
          actuar_si_en_casilla_no_edificable
        end
    end
    
    def obtener_casilla_jugador_actual
      @jugador_actual.casilla_actual
    end
    
    def obtener_casillas_tablero
      @tablero.casillas
    end
    
    def obtener_propiedades_jugador
      propiedades=Array.new
      @tablero.casillas.each do |c|
        if c.tipo==TipoCasilla::CALLE then
          if @jugador_actual.propiedades.include?(c.titulo) then
            propiedades<<c.numero_casilla
          end
        end
      end
      propiedades
    end
    
    def obtener_propiedades_jugador_segun_estado_hipoteca(estado_hipoteca)
      propiedades=Array.new
      @tablero.casillas.each do |c|
        if c.tipo==TipoCasilla::CALLE then
          if @jugador_actual.propiedades.include?(c.titulo) then
            propiedades<<c.numero_casilla
          end
        end
      end
      propiedades
    end
    
    def obtener_ranking
      @jugadores=@jugadores.sort
    end
    
    def obtener_saldo_jugador_actual
      @jugador_actual.saldo
    end
    
    def obtener_valor_dado
      @dado.valor
    end
    
    def salida_jugadores
      @jugadores.each do |j|
        j.casilla_actual=@tablero.casillas[0]
      end
      @jugador_actual=@jugadores[rand(@jugadores.size)]
      @estado_juego=EstadoJuego::JA_PREPARADO
    end
    private :salida_jugadores
    
    def siguiente_jugador
      @jugador_actual=@jugadores[(@jugadores.find_index(@jugador_actual)+1)%@jugadores.size]
      if @jugador_actual.encarcelado
        @estado_juego=EstadoJuego::JA_ENCARCELADO
      else
        @estado_juego=EstadoJuego::JA_PREPARADO
      end
    end
    
    def tirar_dado
      @dado.tirar
    end
    
    def vender_propiedad(numero_casilla)
      casilla=@tablero.obtener_casilla_numero(numero_casilla)
      @jugador_actual.vender_propiedad(casilla)
      @estado_juego=EstadoJuego::JA_PUEDEGESTIONAR
    end
    
    def to_s
      "Qytetet{Maximo de jugadores: #{MAX_JUGADORES}, numero de sorpresas: #{NUM_SORPRESAS}, numero de casillas: #{NUM_CASILLAS}, precio de libertad: #{PRECIO_LIBERTAD}, saldo de salida: #{SALDO_SALIDA}, carta actual: #{@carta_actual}, mazo: #{@mazo}, jugadores: #{@jugadores}, jugador actual: #{@jugador_actual}, tablero: #{@tablero}, dado: #{@dado}}"
    end
    
    private :inicializar_cartas_sorpresa, :inicializar_jugadores
  end
end