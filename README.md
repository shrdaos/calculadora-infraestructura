#Creadoras 
Sharon Dahiana Ospina Osorio
Nikoll Morales Londoño
## Compilación
nasm -f elf64 calculator.asm &&  ld -s -o calculator calculator.o
## Ejecución
./calculator
## Compilador en sistemas linux
En sistemas linux se debe instalar el compilador nasm con el comando sudo apt install as31 nasm
