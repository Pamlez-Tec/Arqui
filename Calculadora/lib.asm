include macrosP.pgl ;Incluimos macro

datosLibreria segment ;Asignamos un segmento de datos, inicio

    AvisoMSJ db 10,13,"Numero o resultado se sobrepasa del limite de 16 bits$"
    mensaje db 10,13,"ESCRIBA UN NUMERO: $"
    resultadoMsj db 10,13," -> -> Resultado es: $"
    potenciaVar db 00h ;variable para controlar lista y algunos ciclos
    Entrada2 db "1.Suma 2.Resta 3.Multiplicacion 4.Division ", 10,13,
             db "DIGITE EL NUMERO DE LA OPERACION A REALIZAR -> $"
    num1 dw 0000h ;Guarda numero digitado 1
    num2 dw 0000h ;Guarda numero digitado 2
    residuo dw 0000h ;residuo de la division
    multi dw 0001h,000Ah,0064h,03E8h,2710h ;10^0,10^1,10^2,10^3,10^4
    DiviEntre0 db 10,13,"No se puede dividir entre 0 $"
    MsjDecimalesSobrepasados db 10,13,"No se pueden mostrar los decimales restantes porque el calculo sobrepasa los 16 bits $"
    avisoEntrada db 10,13, "Debe ingresar solo numeros$"

datosLibreria ends ;Final del segmento de datos

codigo segment ;Inicio del segmento de codigo

    ;Asignamos como publicos los procedimiento que vamos a llamar desde otros archivos
    public Resta
    public Suma
    public ImprimirEnPantalla
    public Multi_Proc
    public Divi_Proc
    public InicioOperacion
    public InicioInput
    public asignar
    public RevisarDivision
    public Decimales

	assume cs:codigo,ds:datosLibreria ;Le indicamos cual registro pertenece un segmento

AvisoInput proc far
    InputMensaje avisoEntrada;Macro que imprime 
    Finalizar;Macro que finaliza
endP

PrimerInput Proc Far
    cmp bl, 10 ;bl guarda los digitos ingresados. Solo se pueden ingresar 5 digitos. Enciende la bandera zf si bl es igual a 5
    je ConvertirNumero_1 ;Salto condicional, salta si zf está activada
    Input ;Macro que toma el digito ingresado y lo guarda en al
    cmp al, 221 ;Para saber si es un ENTER
    je ConvertirNumero_1 ;Si es enter salta a esta función

    cmp al, 0 ;Compara digito ingresado con 0
    jb AvisoInput; Salta si es A<0
    cmp al, 9;Compara digito ingresado con 9
    ja AvisoInput; Salta si A>9

    mov ah,0 ;Nos aseguramos que ah tenga un 0
    push ax ;Guarda el digito en pila
    ;add bl,al ;Incrementa el digito ingresado para el control del ciclo
    add bl,2 ; Sumamos 2 control de los digitos ingresados y la lista de potencias que esta definida como dw
    mov cl, bl; Igualamos el cl con el bl, para usarlo tambien como control
	jmp PrimerInput ;Salta a la misma función para seguir ingresando digitos. Sin importar banderas
EndP

limpiar_Imprimir Proc Far
    xor bx, bx ;Limpiamos bx para que el contador de digitos ingresados vuelva a 0
    mov ch,0;Nos aeguramos que ch este limpio
    mov potenciaVar,0 ;Limpiamos la variable para usarla con el segundo digito ingresado 
    InputMensaje mensaje; Macro que imprime mensaje "Digite numero"
    jmp SegundoInput ;Salta a esta funcion para que ahora se ingrese el segundo numero
EndP	

SegundoInput Proc Far
    cmp bl, 10 ;bl guarda los digitos ingresados. Solo se pueden ingresar 5 digitos. Enciende la bandera zf si bl es igual a 5
    je ConvertirNumero_2 ;Salto condicional, salta si zf está activada
    Input ;Macro que toma el digito ingresado y lo guarda en al
    cmp al, 221 ;Para saber si es un ENTER
    je ConvertirNumero_2 ;Si es enter salta a esta función
    mov ah,0 ;Aseguramos que ah este limpio
    push ax ;Guarda el digito en pila
    add bl,2; CL controla el número de digitos del primer numero. 
    mov ch, bl ;Igualamos 
	jmp SegundoInput ;Salta a la misma función para seguir ingresando digitos. Sin importar banderas	
EndP

ConvertirNumero_1 proc far
    xor dx, dx ;Limpiamos registro
    xor bx,bx ;Limpiamos registro
    cmp potenciaVar, cl ;Ciclo finaliza cuando la variable potencia llegue a la misma cantidad de digitos del primer numero
    je limpiar_Imprimir ;Salta si potenciaVar es igual que la cantidad de digitos
    pop ax ;Sacamos de la pila el numero y lo dejamos en ax
    mov bl,potenciaVar ;Movemos lo que tiene potenciaVar a la parte baja del bl
    mov si, bx ;Metemos el numero del digito que tiene bx al registro indice fuente
    mov dx, multi+si; Metemos en dx el numero del indice segun el digito por el que vamos, para que se vaya formando el numero
    mov bx,dx; Movemos el numero que nos sacamos de la lista multi
    mul bx ; Multiplicamos, Resultado de la multiplicación está en ax
    jc Aviso ; Si al multiplicar el numero es demasiado grande, salta bandera carry y avisamos que se sobrepasa 
    add num1, ax ;Vamos formando el numero
    jc Aviso; Si a la hora de formar el numero, se sobrepasa y bandera carry se activa, avisamos que se sobrepasa
    add potenciaVar,2 ;Sumamos dos a la variable de control de la lista, pues la lista es de dw.
    jmp ConvertirNumero_1  ;Volvemos a ejecutar el procedimiento
EndP

ConvertirNumero_2 proc far
    xor dx, dx ;Limpiamos registro
    xor bx,bx;Limpiamos registro para asegurarnos que no tenga basura
    cmp potenciaVar, ch ;Ciclo finaliza cuando la variable potencia llegue a la misma cantidad de digitos del segundo numero
    je Fin1; Salta si es igual la comparacion anterior.
    pop ax ;Sacamos de la pila el numero a multiplicar
    mov bl,potenciaVar ;Pasamos a la parte baja del bx la variable de control del digito 
    mov dx, multi+bx ; Metemos en dx el numero del indice segun el digito por el que vamos, para que se vaya formando el numero 
    mov bx,dx ;Movemos el numero que nos sacamos de la lista multi
    mul bx ; Resultado de la multiplicación está en ax
    jc Aviso ;Salta si la multiplicacion hace acarreo bandera C se activa
    add num2, ax ;Vamos guardando el numero 
    jc Aviso ;Salta su la suma anterior hace acarreo. Si se sobrepasa de los 16 bits
    add potenciaVar,2 ;Sumo dos porque controlMulti está definida como dw
    mov ax, num2; Guardamos numero2 en ax
jmp ConvertirNumero_2 ;vuelve a ejecutar el procedimiento.
EndP

Aviso proc far 
    InputMensaje AvisoMSJ ;Macro que imprime el mensaje de aviso 
    Finalizar ;Macro que finaliza el programa.
endP

Suma proc far
    mov ax, num1; Pasamor el numero 1 guardado en la variable, se pasa al registro ax
    add ax, num2; Sumamos ambos numero y suma queda guardada en el registro ax
    mov num1,ax ;La suma la guardamos en la variable num1
    jc Aviso ;Si al sumar se activa la bandera del carry, salta a la funcion que avisa que no se puede representar el numero
    xor cx,cx ; Limpiamos cx
    xor si,si;Limpiamos si
    mov si,2; Movemos un 2 a si. Si servirá para guardar cuantos caracteres tiene la suma en este caso inicia con un caracter
    InputMensaje resultadoMsj ;Macro que imprime el mensaje "Resultado" de la operacion
    mov ax,num1 ; Guardamos el num1 el resultado de la suma en ax
    jmp Digitos ;saltamos al procedimiento que cuenta los digitos, En este caso cuenta los digitos de la suma
endP

Fin1 proc far
    retf ;devuelve el control  segmento y offset
endP

ImprimirEnPantalla proc far
    cmp si, 0 ;Se compara si la cantidad de digitos ya es cero
    je Fin1 ; Si son iguales, salta a la funcion que devuelve control al so
    sub si,2 ;Disminuimos la cantidad de digitos
    mov dx, multi+si ;Indexamos la lista para saber cual numero debemos dividir y sacar el numero a imprimir
    mov bx, dx;Pasamos el numero a dividir a bx
    xor dx,dx ;Se limpia dx porque aqui se guarda el residuo de la division
    div bx ;Ax tiene el resultado de la resta, y se divide entre bx. Ax tiene resultado del numero a imprimir 
    mov bx, dx ;Movemos residuo
    mov dl, al;Movemos lo que tiene al al dl, pues ahí es donde se lee el caracter 
    mov ah, 02h ;Codigo para imprimir un caracter
    add dl, 30h ;Ajustamos el numero para que aparezca correctamente en codigo ASCII
    int 21h ;Aplicamos la interrupcion que lee lo que tiene ah
    mov ax,bx;Se pasa el residuo de la division a ax, los numeros faltantes a imprimir
    jmp ImprimirEnPantalla ;Salta a la misma funcion para seguir con el ciclo
endP

Resta proc far
    mov ax, num2 
    mov cx, num1
    cmp ax,cx ;Compara y altera banderas
    ja RestaSigno ; num2 > num1, eso quiere decir que el resultado sera negativo
    ;Si resultado no sera negativo entonces continua
    mov ax,num1 ;movemos ahora el primer numero ingresado a ax
    sub ax,num2 ;Restamos el numero 1 con el numero dos.
    mov num1, ax ;Resultado de la resta esta en ax, lo guardamos en la variable num1
    xor cx,cx ;Limpiamos registro
    ;xor bx,bx;Limpiamos registro
    ;mov bx,2 ;
    xor si, si;
    mov si, 2 ;ponemos un 2 en si indicando un primer digito del resultado. Nos sirve para la lista de exponentes para imprimir digito x digito
    InputMensaje resultadoMsj ;Macro que imprime el mensaje de resultado
    mov ax,num1 ;Movemos de nuevo el resultado a ax pues la macro de arriba afecta el registro ax para imprimir
    jmp Digitos ;Saltadmos a la funcion que cuenta los digitos del resultado
endP

RestaSigno proc far
    mov ax,num2
    sub ax,num1 ;como el numero dos que está en ax es mayor al num1, restamos num2 - num1
    mov num1, ax ;Movemos resultado de la resta a num1
    xor cx,cx ;Limpiamos registro
    xor si,si;Limpiamos registro
    mov si,2 ;ponemos un 2 en si indicando un primer digito del resultado. Nos sirve para la lista de exponentes para imprimir digito x digito
    InputMensaje resultadoMsj ;Macro que imprime mensaje de resultado
    mov dl, 45;Movemos un 45 (codigo ASCII) a dl para que se imprima un guion en señal de numero negativo
    mov ah, 02h ;Codigo para imprimir un caracter
    int 21h ;Aplicamos la interrupcion que lee el codigo de ah
    mov ax,num1 ;Volvemos a mover resultado que esta en num1 a ax, pues para imprimir el guion se afecta el ah
    jmp digitos; Saltamos al procedimiento para contar los digitos del resultado
endP

Aviso2 proc far 
    InputMensaje AvisoMSJ ;Macro que imprime mensaje de aviso si el resultado se sobrepasa de los 65535
    Finalizar ;Macro que finaliza el programa
endP

Multi_Proc proc far
    xor dx,dx
    mov ax, num1 ;Pasamos el primer numero digitado a ax para multiplicarlo
    mov cx, num2 ;Movemos el segundo digito ingresado a cx, para multiplicarlo contra ax
    mul cx ;Multiplicacion se hace ax * cx, num1 * num2
    jc Aviso2 ; Salta si bandera del acarreo se activa, si la multiplicacion se sobrepasa de los 65535
    mov num1,ax ;Movemos resultado de la multiplicacion a num1
    xor cx,cx ;Limpiamos cx
    xor si,si ;Limpiamos si
    mov si,2 ;ponemos un 2 en si indicando un primer digito del resultado. Nos sirve para la lista de exponentes para imprimir digito x digito
    InputMensaje resultadoMsj ;Macro que imprime el mensaje "Resultado"
    mov ax,num1 ;Volvemos a mover el resultado a ax pues la anterior macro afecta ah para imprimir mensaje
    jmp Digitos ;Saltamos al procedimiento que cuenta los digitos del resultado
endP

Divi_Proc proc far
    ProcesoDivision num1, num2, residuo ;Macro que hace la division de num1 / num2, guarda el residuo en variable "residuo"
    InputMensaje resultadoMsj ;Imprime mensaje de resultado
    mov ax, num1 ;Resultado de la division entera se pasa a ax pues anterior macro afecta registro ax para imprimir
    jmp Digitos ;Llamamos funcion que cuenta los digitos del resultado de la division
endP

AvisoDecimales proc Far
    InputMensaje MsjDecimalesSobrepasados ;Macro que imprime mensaje
    Finalizar;Macro que finaliza programa
endP

Digitos proc far
    mov num1,ax ;Volvemos a mover el resultado a num1, para asegurarnos
    cmp num1,10 ;Comparamos resultado con el 10, afecta banderas
    jb Fin_ ;num1 < 10, quiere decir que solo tiene un digito, salta a funcion que devuelve el control so
    ;Continua si es mayor
    add si,2 ;Aumentamos el si en 2 para indicar que tiene un digito más el resultado si = 4

    cmp num1,100 ;Comparamos resultado con 100
    jb Fin_ ;num1 < 100 , quiere decir que tiene dos digitos y salta a funcion que devuelve control
    ;Continua si es mayor
    add si,2; ;Se le suma otros dos más indicando que tiene 3 digitos el resultado, por el momento si = 6

    cmp num1,1000 ;Volvemos a comparar si resultado es menor a 1000
    jb Fin_;Salta si es menor, quiere decir que tiene 3 digitos el resultado
    ;Continua si es mayor
    add si,2 ;Se suma 2 a si, indicando que resultado tiene 4 digitos a imprimir si = 8

    cmp num1,10000 ;Comparamos por ultima vez con 10000
    jb Fin_ ;Si resultado es menor a 10.000, quiere decir que resultado tiene 4 digitos
    ;Continua si es mayor
    add si,2;Se suma por ultima vez a si, indicando que resultado tiene 5 digitos a imprimir si = 10

    retf ;Devolvemos control al SO
endP


Decimales proc far
    xor si,si ;Limpiamos si 
    xor dx,dx;Limpiamos dx
    mov ax, residuo ;Le paso el residuo de la division a ax pues ahora es lo que debemos dividir
    mov bx,10 ;Pasamos un 10 a bx para poder multiplicarlo con ax que es el residuo.Ej: Residuo 3 * 10, ahora sera 30, ese 30 / num2 para deci
    mul bx ; Resultado de la multiplicación está en ax
    jo AvisoDecimales ; salta si bandera del overflow se activa. Si ax se pasa de los 65535
    mov num1, ax ;Pasamos resultado de la multiplicacion
    ProcesoDivision num1,num2, residuo ;Macro que hace la division de num1 / num2, guarda el residuo en variable "residuo"
    call Digitos ;Llamamos funcion que cuenta los digitos del resultado de la division
    jmp ImprimirEnPantalla ;Imprimimos resultado de la division entera
endP

Fin_ proc far
    retf ;Devuelve control SO
endP

InicioOperacion proc far
    InputMensaje mensaje ;Macro que imprime "Escriba numero"
    jmp PrimerInput ;Salta para escribir el primer numero
endP

InicioInput proc far
     InputMensaje Entrada2 ;Macro que imprime mensaje "Digite operacion"
     Input ;Macro que lee el digito ingresado y lo convierte a numero
     retf;Devuelve control al SO
endP

asignar proc far
    xor ax, ax ;Limpiamos registro
    mov ax, datosLibreria ;Pasamos direccion del seg datos al registro xq ds apunta al PSP
    mov ds, ax ;Pasamos direccion del seg datos al registro ds
    retf ;Deuelve control SO
endP

AvisoDivi proc far
    InputMensaje DiviEntre0 ;Macro que avisa si la division se hace entre 0
    Finalizar ;Macro que finaliza
endP

RevisarDivision proc far
    cmp ax,0 ;Hace comparacion si numero 2 ingresado es 0. Afecta banderas
    je AvisoDivi ;Si son iguales, salta a al procedimiento que imprime el mensaje de aviso
    ;Si no son iguales sigue procedimiento
    retf;Devuelve control al SO
endP

codigo ends ;Final del segmento de codigo
end ;Final del programa
