#!/usr/bin/env ruby

puts 'Bienvenido a la Configuación automática de red.'

while loop = true
puts '
-------------------------------
1. Elegir interfaz de red.
2. Mostrar interfaces de red.
3. Salir.
-------------------------------
'
intro1 = gets.chop
  if intro1 == '1'
    puts'¿Qué interfaz va a usar?[0, 1, 2, ...]'
    interface = gets.chop

    puts '
    ||=============================================||
    ||                                             ||
    ||                    Menú                     ||
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
    items01 = %x[ip a | grep eth#{interface} | grep inet].split()
    ip01 = items01[1]

    if intro2 == '1'
      system('sudo ifdown eth' + interface)
      system('sudo ifup eth' + interface)
      system("ip a | grep eth#{interface} | grep inet")
    elsif intro2 == '2'
      puts "Se ha elegido la interfaz: eth#{interface}"
      system("sudo ip addr del #{ip01} dev eth#{interface}")
      system('sudo ip addr add 172.19.18.50/16 dev eth' + interface)
      system("ip a | grep eth#{interface} | grep inet")
    elsif intro2 == '3'
      puts "[DEBUG] ip01=#{ip01} interface=#{interface}"
      system("sudo ip addr del #{ip01} dev eth#{interface}")
      system('sudo ip addr add 192.168.1.18/24 dev eth' + interface)
      puts "[INFO] " + %x[ip a | grep eth#{interface} | grep inet]
    end
  elsif intro1 == '2'
    system('ip a')
  elsif intro1 == '3'
    break
  end
end
