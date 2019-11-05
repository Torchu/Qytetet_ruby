# encoding: UTF-8
require_relative "sorpresa"
require_relative "qytetet"
require_relative "metodo_salir_carcel"
module ModeloQytetet
  class PruebaQytetet
    #Se define juego
    @@juego=Qytetet.instance
    def self.juego
      @@juego
    end
    
    #Devuelve una lista con las sorpresas cuyo valor es mayor a cero
    def self.get_mayor_cero
      @@juego.mazo.select { |sorpresa| sorpresa.valor>0 }
    end
    
    #Devuelve una lista con las sorpresas de tipo IRACASILLA
    def self.get_ir_a_casilla
      @@juego.mazo.select { |sorpresa| sorpresa.tipo==TipoSorpresa::IRACASILLA }
    end
  
    #Devuelve una lista con las sorpresas del tipo especificado en el argumento
    def self.get_sorpresa_tipo(tipo)
      @@juego.mazo.select { |sorpresa| sorpresa.tipo==TipoSorpresa.const_get(tipo) }
    end
    
    def self.get_nombre_jugadores
      jugadores=Array.new
      puts "Introduce el numero de jugadores: "
      numero_jugadores=gets.chomp.to_i
      numero_jugadores.times do
        puts "Introduce el nombre del jugador: "
        nombre=gets.chomp
        jugadores<<nombre
      end
      jugadores
    end
    private_class_method :get_mayor_cero, :get_ir_a_casilla, :get_sorpresa_tipo, :get_nombre_jugadores
    
    #MAIN
    def self.main
      #Inicializar el juego
      players=Array.new
      players<<"Pacopepe"
      players<<"Eufemia"
      @@juego.inicializar_juego(players)
      #Player 1
      @@juego.jugar
      puts "El jugador #{@@juego.jugador_actual.nombre} se mueve a la casilla #{@@juego.jugador_actual.casilla_actual.numero_casilla}"
      if @@juego.estado_juego == EstadoJuego::JA_PUEDECOMPRARGESTIONAR
        @@juego.comprar_titulo_propiedad
        puts "Se compra una propiedad"
        @@juego.edificar_casa(@@juego.jugador_actual.casilla_actual.numero_casilla)
        puts "Edifica una casa en su propiedad"
      end
      puts @@juego.jugador_actual
      #Player 2
      @@juego.siguiente_jugador
      @@juego.mover(3)
      puts "El jugador #{@@juego.jugador_actual.nombre} se mueve a la casilla #{@@juego.jugador_actual.casilla_actual.numero_casilla}"
      @@juego.aplicar_sorpresa
      puts "Se aplica la sorpresa #{@@juego.carta_actual.texto}"
      puts @@juego.jugador_actual
      #Player 1
      @@juego.siguiente_jugador
      puts "Las propiedades del jugador son\n"
      @@juego.obtener_propiedades_jugador.each do |p|
        puts p
      end
      puts "Las hipotecadas son\n"
      @@juego.obtener_propiedades_jugador_segun_estado_hipoteca(true).each do |p|
        puts p
      end
      if !@@juego.jugador_actual.propiedades.empty? then
        @@juego.hipotecar_propiedad(@@juego.jugador_actual.casilla_actual.numero_casilla)
        puts "Ahora:\n"
        @@juego.obtener_propiedades_jugador_segun_estado_hipoteca(true).each do |p|
          puts p
        end
        @@juego.cancelar_hipoteca(@@juego.jugador_actual.casilla_actual.numero_casilla)
        puts "Ahora:\n"
        @@juego.obtener_propiedades_jugador_segun_estado_hipoteca(true).each do |p|
          puts p
        end
        @@juego.vender_propiedad(@@juego.jugador_actual.casilla_actual.numero_casilla)
        puts "Ahora:\n"
        @@juego.obtener_propiedades_jugador.each do |p|
          puts p
        end
      end
      #Player 2
      @@juego.mover(15)
      if @@juego.intentar_salir_carcel(MetodoSalirCarcel::TIRANDODADO)
        puts "Se ha conseguido salir con el dado"
      else
        @@juego.intentar_salir_carcel(MetodoSalirCarcel::PAGANDOLIBERTAD)
        puts "Se ha pagado la fianza"
      end
      @@juego.obtener_ranking
      puts "Ha ganado el jugador #{@@juego.jugadores[0].nombre}"
    end
  end
  PruebaQytetet.main
end