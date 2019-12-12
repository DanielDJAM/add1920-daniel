#!/usr/bin/env ruby

puts 'Bienvenido a la Configuación automática de red.'

puts '
-------------------------------
1. Elegir interfaz de red.
2. Mostrar interfaces de red.
-------------------------------
'

intro1 = gets.chop

if intro1 == '1'
  puts'¿Qué interfaz va a usar?[0, 1, 2, ...]'
  interface = gets.chop

puts '
||=============================================||
||                                             ||
||                      Menú                   ||
||                                             ||
||=============================================||
||                                             ||
||    1. Reset.                                ||
||    2. Configuación estática para clase.     ||
||    3. Configuración estática para casa.     ||
||                                             ||
||=============================================||
'

intro2 = gets.chop

if intro2 == '1'
    system('sudo ifdown eth' + interface)
    system('sudo ifup eth' + interface)
    system('ip a | grep eth' + interface)
  elsif intro2 == '2'
    puts " interfaz : #{interface}"
    items01 = %x[('ip a | grep eth' + interface + ' | grep inet | grep -v brd')].split()
    print(items01)
    ip01 = items01[1]
    system('sudo ip addr del' + ip01 + ' dev eth' + interface)
    system('sudo ip addr add 172.19.18.50/16 dev eth' + interface)
  elsif intro2 == '3'
    system('sudo ip addr add 192.168.1.18/24 dev eth' + interface)
 end

elsif
  system('ip a')
end
