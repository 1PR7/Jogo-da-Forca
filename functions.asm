# =================================================================
# FUNÇÕES DE DESENHO DA FORCA
# =================================================================

# Print line break
printQuebra:
	li a7, CHAR
	li a0, '\n'
	ecall
	ret

# Printa a palavra oculta
printOculta:
	li a7, STRING
	mv a0, OCULTA
	ecall
	ret

# lê um char do teclado
readChar:
	print("Digite uma letra:\n")
	li a7, READCHAR
	ecall
	mv t0, a0
	delay(250)
	mv a0, t0
	ret

# coloca um char em maiúsculo
strUpper:
	li t0, 'A'	
	blt a0, t0, noAlpha 	
	li t0, 'Z'	
	bge a0, t0, entradaErrada	
	ret
	
	entradaErrada:
	li t0, 'a'
	blt a0, t0, noAlpha	
	li t0, 'z'
	bgt a0, t0, noAlpha	
	addi a0, a0, -32 
	ret
	
	noAlpha:
	li a0, 0
	ret
	
# verifica se o usuário acertou uma letra da palavra
validaChute:
	li t1, '_'
	li t3, '\0'
	li t4, 0	
	loopVC:
	lb t0, (a1)	
	lb t2, (a2)	
	beq t0, t3, endVC	
		bne t0, t1, else	
			bne a0, t2, else	
				sb a0, (a1)	
				li t4, 1	
	else:
	addi a1, a1, 1
	addi a2, a2, 1	
	j loopVC

	endVC: 
	mv a0, t4	
	ret

# Verifica se o usuário acertou a palavra oculta
verificaAcerto:
	li t0, '_'
	li t2, '\0'
	loopVA:	
		lb t1, (a0)
		beq t1, t0, errado	
		beq t1, t2, certo	
		addi a0, a0, 1	
		j loopVA
		
	errado:
		li a0, 0
		ret
	certo:
		li a0, 1
		ret

# Retorna a string no índice correto sem pular a primeira letra do índice 0
searchInArray:
	li t0, '\0'	
	li t1, 0	
	
	# Se for o índice 0, recua o ponteiro em 1 para anular o primeiro avanço de 'achei'
	bnez a0, loopSIA
	addi a1, a1, -1
	
	loopSIA: beq t1, a0, achei	
		addi a1, a1, 1	
		lb t2, (a1)	
		bne t2, t0, pass	
			addi t1, t1, 1	
		
		pass: j loopSIA
	
	achei:
		addi a1, a1, 1	
		lb t1, (a1)
		sb t1, (a2)
		
		beq t1, t0, return
		addi a2, a2, 1	
		j achei
		
	return: ret

# Retorna o tamanho de uma string
lenStr:
	li t0, '\0'
	li t1, 0	
	lb t2, (a0)	
	
	loopLS:	beq t2, t0, returnLS
		addi a0, a0, 1	
		lb t2, (a0)	
		addi t1, t1, 1	
		j loopLS
	
	returnLS:
		mv a0, t1
		ret	

# Coloca na memória os underscores
guardaUnderlines:
	li t0, '_'
	loopGU: beqz a0, returnGU
		sb t0, (a1)
		addi a0, a0, -1	
		addi a1, a1, 1	
		j loopGU
	
	returnGU: ret

atualiza_forca:
    li t1, 1
    beq s3, t1, set_cabeca
    li t1, 2
    beq s3, t1, set_tronco
    li t1, 3
    beq s3, t1, set_braco_esq
    li t1, 4
    beq s3, t1, set_braco_dir
    li t1, 5
    beq s3, t1, set_perna_esq
    li t1, 6
    beq s3, t1, set_perna_dir
    ret

set_cabeca:
    la t2, cabeca
    li t3, 48       
    sb t3, 0(t2)
    ret
set_tronco:
    la t2, tronco
    li t3, 124      
    sb t3, 0(t2)
    ret
set_braco_esq:
    la t2, bracoEsq
    li t3, 47       
    sb t3, 0(t2)
    ret
set_braco_dir:
    la t2, bracoDir
    li t3, 92       
    sb t3, 0(t2)
    ret
set_perna_esq:
    la t2, pernaEsq
    li t3, 47       
    sb t3, 0(t2)
    ret
set_perna_dir:
    la t2, pernaDir
    li t3, 92       
    sb t3, 0(t2)
    ret

desenha_aforcado:
    la a0, forca_1
    li a7, 4        
    ecall
    la t1, cabeca
    lb a0, 0(t1)
    li a7, 11       
    ecall
    la a0, forca_2
    li a7, 4
    ecall
    la t1, bracoEsq
    lb a0, 0(t1)
    li a7, 11
    ecall
    li a0, 32       
    li a7, 11
    ecall
    la t1, bracoDir
    lb a0, 0(t1)
    li a7, 11
    ecall
    la a0, forca_3
    li a7, 4
    ecall
    la t1, tronco
    lb a0, 0(t1)
    li a7, 11
    ecall
    la a0, forca_4
    li a7, 4
    ecall
    la t1, pernaEsq
    lb a0, 0(t1)
    li a7, 11
    ecall
    li a0, 32
    li a7, 11
    ecall
    la t1, pernaDir
    lb a0, 0(t1)
    li a7, 11
    ecall
    la a0, forca_5
    li a7, 4
    ecall
    ret
