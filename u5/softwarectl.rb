#!/usr/bin/env ruby

puts 'Bienvenido a softwarectl'

filename = ARGV[1]

if ARGV[0] == ''
  "Recomendamos el uso de --help"
elsif ARGV[0] == '--help'
  puts '
Usage:
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
   atomix:remove

  '
elsif ARGV[0] == '--version'
  puts '
  Daniel de Jesús Álvarez Miranda
  08-01-20
  version 0.01a
  '
elsif ARGV[0] == '--status' and ARGV[1]
  filename_splited = filename.split("\n")
  filename_splited2 = filename_splited.split(":")
  para1 = system("whereis #{filename_splited2[0]} |grep bin |wc -l")
  if para1 == 1
  puts 'Está instalado'
  elsif
    puts 'No está instalado'
elsif ARGV[0] == '--run'
  para1 = system('whoami')
  if para1 == 'root'
    while loop = true
      puts '
      1. Instalar
      2. Desinstalar
      3. Salir

      Elige (1), (2) o (3).
      '
      intro1 = gets.chop
      if intro1 == 1
        system("zypper install -y #{ARGV[1]}")
      elsif intro1 == 2
        system("zypper remove -y #{ARGV[1]}")
      elsif intro == 3
        loop = false
  elsif
    puts "Usted no tiene permisos de administrador"
    exit 1
