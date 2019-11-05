# encoding: UTF-8
require "singleton"
module ModeloQytetet
  class Dado
    include Singleton
    attr_accessor :valor
    def initialize
      @valor=0
    end
    
    def tirar
      @valor=1+rand(6)
    end
    
    #Metodo to String
    def to_s
      "Dado{valor: #{@valor}"
    end 
  end
end
