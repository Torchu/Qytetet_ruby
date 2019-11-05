# encoding: UTF-8
require "singleton"
require_relative "opcion_menu.rb"
require_relative "qytetet.rb"
require_relative "estado_juego.rb"
require_relative "metodo_salir_carcel.rb"

module ControladorQytetet
  class ControladorQytetet
    attr_accessor :nombre_jugadores, :modelo
    include Singleton
    include ModeloQytetet
    
    def initialize
      @nombre_jugadores = Array.new
      @modelo = Qytetet.instance
    end
    
    def set_nombre_jugadores(nombres)
      @nombre_jugadores = nombres
    end
    
    def obtener_operaciones_juego_validas
      validas = Array.new
      if(@modelo.jugadores.empty?)
        validas << OpcionMenu.index(:INICIARJUEGO)
      else
        if (@modelo.estado_juego == ModeloQytetet::EstadoJuego::ALGUNJUGADORENBANCARROTA)
          validas << OpcionMenu.index(:OBTENERRANKING)
        elsif (@modelo.estado_juego == ModeloQytetet::EstadoJuego::JA_CONSORPRESA)
          validas << OpcionMenu.index(:APLICARSORPRESA)
        elsif (@modelo.estado_juego == ModeloQytetet::EstadoJuego::JA_ENCARCELADO)
          validas << OpcionMenu.index(:PASARTURNO)
        elsif (@modelo.estado_juego == ModeloQytetet::EstadoJuego::JA_ENCARCELADOCONOPCIONDELIBERTAD) then
          validas << OpcionMenu.index(:INTENTARSALIRCARCELPAGANDOLIBERTAD)
          validas << OpcionMenu.index(:INTENTARSALIRCARCELTIRANDODADO)
        elsif (@modelo.estado_juego == ModeloQytetet::EstadoJuego::JA_PREPARADO)
          validas << OpcionMenu.index(:JUGAR)
        elsif (@modelo.estado_juego == ModeloQytetet::EstadoJuego::JA_PUEDECOMPRARGESTIONAR) then
          validas << OpcionMenu.index(:COMPRARTITULOPROPIEDAD)
          validas << OpcionMenu.index(:HIPOTECARPROPIEDAD)
          validas << OpcionMenu.index(:CANCELARHIPOTECA)
          validas << OpcionMenu.index(:EDIFICARCASA)
          validas << OpcionMenu.index(:EDIFICARHOTEL)
          validas << OpcionMenu.index(:VENDERPROPIEDAD)
          validas << OpcionMenu.index(:PASARTURNO)
        else
          validas << OpcionMenu.index(:HIPOTECARPROPIEDAD)
          validas << OpcionMenu.index(:CANCELARHIPOTECA)
          validas << OpcionMenu.index(:EDIFICARCASA)
          validas << OpcionMenu.index(:EDIFICARHOTEL)
          validas << OpcionMenu.index(:VENDERPROPIEDAD)
          validas << OpcionMenu.index(:PASARTURNO)
        end
        validas << OpcionMenu.index(:TERMINARJUEGO)
        validas << OpcionMenu.index(:MOSTRARJUGADORACTUAL)
        validas << OpcionMenu.index(:MOSTRARJUGADORES)
        validas << OpcionMenu.index(:MOSTRARTABLERO)
      end
      validas
    end
    
    def necesita_elegir_casilla(opcion_menu)
      if(OpcionMenu.at(opcion_menu) == :EDIFICARCASA || OpcionMenu.at(opcion_menu) == :EDIFICARHOTEL || 
         OpcionMenu.at(opcion_menu) == :HIPOTECARPROPIEDAD || OpcionMenu.at(opcion_menu) == :CANCELARHIPOTECA || 
         OpcionMenu.at(opcion_menu) == :VENDERPROPIEDAD)
         true
      else
        false
      end
    end
    
    def obtener_casillas_validas(opcion_menu)
      if(OpcionMenu[opcion_menu] == :CANCELARHIPOTECA)
        @modelo.obtener_propiedades_jugador_segun_estado_hipoteca(true)
      else
        @modelo.obtener_propiedades_jugador_segun_estado_hipoteca(false)
      end
    end
    
    def realizar_operacion(opcion_elegida, casilla_elegida)
      if(OpcionMenu.at(opcion_elegida) == :INICIARJUEGO) then
        @modelo.inicializar_juego(@nombre_jugadores)
        "Comieza el juego"
      elsif(OpcionMenu.at(opcion_elegida) == :APLICARSORPRESA) then
        aux = @modelo.carta_actual
        @modelo.aplicar_sorpresa
        "Se aplica la sorpresa: #{aux.to_s}"
      elsif(OpcionMenu.at(opcion_elegida) == :CANCELARHIPOTECA) then
        if(@modelo.cancelar_hipoteca(casilla_elegida))
          "El jugador cancela la hipoteca de la casilla #{casilla_elegida}"
        else
          "No tienes suficiente dinero para eso"
        end
      elsif(OpcionMenu.at(opcion_elegida) == :COMPRARTITULOPROPIEDAD) then
        if(@modelo.comprar_titulo_propiedad)
          "El jugador compra la propiedad"
        else
          "No tienes suficiente dinero para eso"
        end
      elsif(OpcionMenu.at(opcion_elegida) == :EDIFICARCASA) then
        if(@modelo.edificar_casa(casilla_elegida))
          "El jugador construye una casa en la casilla #{casilla_elegida}"
        else
          "No tienes suficiente dinero para eso"
        end
      elsif(OpcionMenu.at(opcion_elegida) == :EDIFICARHOTEL) then
        if(@modelo.edificar_hotel(casilla_elegida))
          "El jugador construye un hotel en la casilla #{casilla_elegida}"
        else
          "No tienes suficiente dinero para eso o no suficientes casas"
        end
      elsif(OpcionMenu.at(opcion_elegida) == :HIPOTECARPROPIEDAD) then
        @modelo.hipotecar_propiedad(casilla_elegida)
        "¡Qué dura es la crisis! El jugador hipoteca la propiedad de la casilla #{casilla_elegida}"
      elsif(OpcionMenu.at(opcion_elegida) == :INTENTARSALIRCARCELPAGANDOFIANZA) then
        @modelo.intentar_salir_carcel(MetodoSalirCarcel::PAGANDOFIANZA)
        "El jugador ha pagado la fianza y sale de la carcel"
      elsif(OpcionMenu.at(opcion_elegida) == :INTENTARSALIRCARCELTIRANDODADO) then
        if(@modelo.intentar_salir_carcel(MetodoSalirCarcel::TIRANDODADO))
          "El jugador se ve con suerte, va a probar con los dados y lo consigue. Siguiente parada: el Codere"
        else
          "El jugador se ve con suerte, va a probar con los dados y pasa esto. *Sale mal*"
        end
      elsif(OpcionMenu.at(opcion_elegida) == :JUGAR) then
        @modelo.jugar
        "Has sacado un #{@modelo.obtener_valor_dado} y te vas a la casilla #{@modelo.obtener_casilla_jugador_actual.to_s}"
      elsif(OpcionMenu.at(opcion_elegida) == :OBTENERRANKING) then
        @modelo.obtener_ranking
        "¡Se acabo!\nEsta es la clasificacion actual: #{@modelo.jugadores.to_s}"
      elsif(OpcionMenu.at(opcion_elegida) == :PASARTURNO) then
        @modelo.siguiente_jugador
        "¡Cambio de turno! #{@modelo.jugador_actual.nombre}, es tu momento de brillar"
      elsif(OpcionMenu.at(opcion_elegida) == :VENDERPROPIEDAD) then
        @modelo.vender_propiedad(casilla_elegida)
        "La crisis se lo lleva todo. El jugador vende la propiedad de la casilla #{casilla_elegida}"
      elsif(OpcionMenu.at(opcion_elegida) == :MOSTRARJUGADORACTUAL) then
        @modelo.jugador_actual.to_s
      elsif(OpcionMenu.at(opcion_elegida) == :MOSTRARJUGADORES) then
        str = String.new
        @modelo.jugadores.each do |jugador|
          str << "#{jugador.to_s}, "
        end
        str
      elsif(OpcionMenu.at(opcion_elegida) == :MOSTRARTABLERO) then
        @modelo.tablero.to_s
      else
        "Juego finalizado"
      end
    end
  end
end
