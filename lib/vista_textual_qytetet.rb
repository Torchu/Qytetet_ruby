# encoding: UTF-8
require_relative "controlador_qytetet.rb"
require_relative "qytetet.rb"
require_relative "opcion_menu.rb"
module VistaTextualQytetet
  class VistaTextualQytetet
    include ControladorQytetet
    @@controlador = ControladorQytetet.instance
    
    def initialize
    end
    
    def obtener_nombre_jugadores
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
    
    def elegir_casilla(opcion_menu)
      validas = @@controlador.obtener_casillas_validas(opcion_menu)
      if (validas.empty?)
        puts "No hay opciones validas"
      else
        validas_to_s = Array.new
        puts "Elige una opcion entre las de la lista"
        validas.each do |i|
          validas_to_s << i.to_s
          puts "#{i}"
        end
        leer_valor_correcto(validas_to_s).to_i
      end
    end
    
    def leer_valor_correcto(valores_correctos)
      begin
        valor = gets.chomp
      end while(!valores_correctos.include?(valor))
      valor
    end
    
    def elegir_operacion
      validas = Array.new
      puts "Elige una opcion entre las de la lista:"
      @@controlador.obtener_operaciones_juego_validas.each do |op|
        validas << op.to_s
        puts "#{op} - #{OpcionMenu.at(op)}"
      end
      leer_valor_correcto(validas).to_i
    end
    
    def self.main
      ui = VistaTextualQytetet.new
      @@controlador.set_nombre_jugadores(ui.obtener_nombre_jugadores)
      operacion_elegida = 0
      casilla_elegida = 0
      
      while(true) do
        operacion_elegida = ui.elegir_operacion
        necesita_elegir_casilla = @@controlador.necesita_elegir_casilla(operacion_elegida)
        if necesita_elegir_casilla
          casilla_elegida = ui.elegir_casilla(operacion_elegida)
        end
        if (!necesita_elegir_casilla || casilla_elegida >= 0)
          puts "#{@@controlador.realizar_operacion(operacion_elegida, casilla_elegida)}"
          if(OpcionMenu.at(operacion_elegida) == :OBTENERRANKING || OpcionMenu.at(operacion_elegida) == :TERMINARJUEGO)
            break
          end
        end
      end
    end
  end
  VistaTextualQytetet.main
end
