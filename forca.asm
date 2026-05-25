.data
# global:
menu: .string "Bem vindo à forca\nPressione uma tecla\n"

# --- Variáveis para o desenho da forca ---
cabeca: .byte 32 
tronco: .byte 32 
bracoEsq: .byte 32 
bracoDir: .byte 32 
pernaEsq: .byte 32 
pernaDir: .byte 32 

forca_1: .string "\n___________\n|/ |\n|  "
forca_2: .string "\n| "
forca_3: .string "\n|  "
forca_4: .string "\n| "
forca_5: .string "\n|\n|___\n"

# --- Sistema de Novas Categorias Objetivas ---
categorias:
    .string "ANIMAIS"          # �?ndice 0  (palavras 0-9)
    .string "FLORES"           # �?ndice 1  (palavras 10-19)
    .string "FRUTAS"           # �?ndice 2  (palavras 20-29)
    .string "CORES"            # �?ndice 3  (palavras 30-39)
    .string "OBJETOS"          # �?ndice 4  (palavras 40-49)
    .string "PROFISSOES"       # �?ndice 5  (palavras 50-59)
    .string "PAISES"           # �?ndice 6  (palavras 60-69)
    .string "ESPORTES"         # �?ndice 7  (palavras 70-79)
    .string "ALIMENTOS"        # �?ndice 8  (palavras 80-89)
    .string "CORPO HUMANO"     # �?ndice 9  (palavras 90-99)
    .string "TRANSPORTES"      # �?ndice 10 (palavras 100-109)
    .string "INSTRUMENTOS"     # �?ndice 11 (palavras 110-119)

cat_buffer: .space 60  # Buffer temporário para a categoria atual
# -----------------------------------------

.include "forca120palavras.txt"
.include "macros.asm"

###############################################
#					 MAIN					  #
###############################################

.text
lui PALAVRA, 0x10000	# Endereço da palavra resposta
lui OCULTA, 0x10001	    # Endereço da palavra oculta

# Escolha da palavra resposta:
li a7, RANDINT
li a1, 120	# Alterado para 120 para abranger TODAS as palavras do arquivo
ecall

mv s4, a0   # Salva o índice sorteado em s4 para evitar conflito com o s3 do desenho

# Descobre o índice da categoria (índice da palavra / 10)
li t0, 10
div t1, s4, t0

# Busca o nome da categoria correspondente e salva no buffer
mv a0, t1
la a1, categorias
la a2, cat_buffer
jal searchInArray

# Busca a palavra secreta correspondente
mv a0, s4
la a1, palavras
mv a2, PALAVRA
jal searchInArray

mv a0, PALAVRA
jal lenStr	# retorna o tamanho da palavra em a0

mv a1, OCULTA
jal guardaUnderlines

# Início da interface de jogo:
print("Bem vindo à forca\nPressione uma tecla\n")

li a7, READCHAR
ecall	# inicia o jogo; retorno despresado
li a7, SLEEP
li a0, 250
ecall	# pausa a execução do programa por 250 milissegundos
jal printQuebra

# Exibe a dica da categoria logo no começo
print("DICA: A PALAVRA PERTENCE AO GRUPO - ")
li a7, STRING
la a0, cat_buffer
ecall
jal printQuebra

jal printOculta
jal printQuebra

li s0, 6	# QUANTIDADE INICIAL DE VIDAS (6 partes do corpo)

# game loop:
tryAgain: 
	jal readChar	# lê o primeiro chute | res em a0
	mv t0, a0
	jal printQuebra
	mv a0, t0
	jal strUpper
	beqz a0, tryAgain	# se a entrada for inválida ele solicita um novo input
	
	mv a1, OCULTA	# carrega o endereço do primeiro char da palavra oculta
	mv a2, PALAVRA	# carrega o endereço do primeiro char da resposta
	jal validaChute
	bnez a0, acertou	# caso o usuário não tenha acertado uma letra ele perde uma vida
	
	# === LÓGICA DE ERRO E DESENHO ===
	addi s0, s0, -1
	print("ERRADO! (CATEGORIA: ")
	li a7, STRING
	la a0, cat_buffer
	ecall
	print(") Vidas restantes: ")
	li a7, 1
	mv a0, s0
	ecall
	jal printQuebra

	li t1, 6
	sub s3, t1, s0      # s3 = 6 - vidas restantes (Conta os erros)
	jal atualiza_forca  # Atualiza partes do boneco
	jal desenha_aforcado # Desenha na tela

	beqz s0, perdeu	    # caso as vidas tenham chegado a 0 é game over
	j tryAgain          # se ainda tem vida, pede nova letra
	# ================================

acertou:	
	jal printQuebra
	jal printOculta
	jal printQuebra
	mv a0, OCULTA
	jal verificaAcerto
	bnez a0, ganhou	
	j tryAgain

ganhou:
	jal printQuebra
	print("Parabéns, você ganhou!!!")
	j exit

perdeu:
	jal printQuebra
	print("\nVocê perdeu... :(\nA palavra era ")
	li a7, STRING
	mv a0, PALAVRA
	ecall

exit:
	li a7, EXIT
	ecall

.include "functions.asm"
