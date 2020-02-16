#!/usr/bin/env ruby

option = ARGV[0]
filename = ARGV[1]

def check(pack)
    status = `whereis #{pack[0]} | grep bin | wc -l`.to_i
      if status == 0
        puts "#{pack[0]} desinstalado."
      elsif status == 1
        puts "#{pack[0]} instalado."
      end
end

def install(pack)
  status = `whereis #{pack[0]} | grep bin | wc -l`.to_i
  action = "#{pack[1]}".to_s
  if action == "install"
    if status == 0
      `apt-get install -y #{pack[0]}`
      puts "#{pack[0]} instalado."
    elsif status == 1
      puts "#{pack[0]} El programa ya está instalado."
    end

  elsif action == "remove"
      if status == 1
        `apt-get remove -y  #{pack[0]}`
        puts "#{pack[0]} desinstalado."
      elsif status == 0
        puts "#{pack[0]} El programa no está instalado."
      end
  end
end

if option.nil?
    puts "Se recomienda usar --help para visualizar ayuda útil."

elsif option == "--help"
    print ("Usage:
        systemctml [OPTIONS] [FILENAME]
Options:
        --help, mostrar esta ayuda.
        --version, mostrar información sobre el autor del script
                   y fecha de creacion.
        --status FILENAME, comprueba si puede instalar/desintalar.
        --run FILENAME, instala/desinstala el software indicado.
Description:
        Este script se encarga de instalar/desinstalar
        el software indicado en el fichero FILENAME.
        Ejemplo de FILENAME:
        tree:install
        nmap:install
        atomix:remove\n\n")

elsif option == '--option'
    puts "Autor: Daniel de Jesús Álvarez Miranda - Fecha: 16/02/2020"

elsif option == "--status"
    f = `cat #{filename} `
    f_lines = f.split("\n")
    f_lines.each do |a|
      as = a.split(":")
      check(as)
    end

elsif option == "--run"
    user = `id -u`.to_i
    if user == 0
      f = `cat #{filename} `
      f_lines = f.split("\n")
      f_lines.each do |a|
        as = a.split(":")
        install(as)
      end
    elsif user != 0
      puts "Se necesitan permisos de administrador"
      exit 1
    end
end
