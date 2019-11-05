# encoding: UTF-8
module ModeloQytetet
require_relative "casilla"
require_relative "calle"
require_relative "tipo_casilla"
require_relative "titulo_propiedad"
  class Tablero
    #attr_accessor
    attr_accessor :casillas, :carcel
  
    #initialize llama al metodo inicializar_tablero
    def initialize
      inicializar_tablero
    end
    
    def es_casilla_carcel(numero_casilla)
      numero_casilla==@carcel.numero_casilla
    end
    
    #Inicializa todas las casillas del tablero y hace que carcel apunte a la casilla de la carcel
    def inicializar_tablero
      @casillas=Array.new
      @casillas<<Casilla.new(0,TipoCasilla::SALIDA, 0);
      @casillas<<Calle.new(1, TituloPropiedad.new("The Ramones", 500, 250, 10, 50, 250));
      @casillas<<Calle.new(2, TituloPropiedad.new("Bon Jovi", 500, 250, 10, 50, 250));
      @casillas<<Casilla.new(3,TipoCasilla::SORPRESA, 0);
      @casillas<<Calle.new(4, TituloPropiedad.new("Led Zeppelin", 550, 300, 11, 55, 275));
      @casillas<<Casilla.new(5,TipoCasilla::CARCEL, 0);
      @casillas<<Calle.new(6, TituloPropiedad.new("Queen", 650, 400, 13, 65, 325));
      @casillas<<Calle.new(7, TituloPropiedad.new("ACDC", 650, 400, 13, 65, 325));
      @casillas<<Casilla.new(8,TipoCasilla::IMPUESTO, 0);
      @casillas<<Calle.new(9, TituloPropiedad.new("Iron Maiden", 700, 450, 14, 70, 350));
      @casillas<<Casilla.new(10,TipoCasilla::PARKING, 0);   #COSTE¿?
      @casillas<<Calle.new(11, TituloPropiedad.new("Metallica", 800, 550, 16, 80, 400));
      @casillas<<Calle.new(12, TituloPropiedad.new("Warcry", 800, 550, 16, 80, 400));
      @casillas<<Casilla.new(13,TipoCasilla::SORPRESA, 0);
      @casillas<<Calle.new(14, TituloPropiedad.new("Crazy Lixx", 850, 600, 17, 85, 425));
      @casillas<<Casilla.new(15,TipoCasilla::JUEZ, 0);
      @casillas<<Calle.new(16, TituloPropiedad.new("Scorpions", 950, 700, 19, 95, 475));
      @casillas<<Calle.new(17, TituloPropiedad.new("Van Halen", 950, 700, 19, 95, 475));
      @casillas<<Casilla.new(18,TipoCasilla::SORPRESA, 0);
      @casillas<<Calle.new(19, TituloPropiedad.new("Guns N Roses", 1000, 750, 20, 100, 500));
      @carcel=casillas[5]
    end
    
    def obtener_casilla_final(casilla, desplazamiento)
      obtener_casilla_numero((casilla.numero_casilla+desplazamiento)%@casillas.size)
    end
    
    def obtener_casilla_numero(numero_casilla)
      @casillas[numero_casilla]
    end
    
    def to_s
      str = String.new
      str << "Tablero{casillas: "
      @casillas.each do |c|
        str << "#{c}, "
      end
      str << "carcel: #{@carcel}}"
      str
    end
    
    private :inicializar_tablero
  end
end