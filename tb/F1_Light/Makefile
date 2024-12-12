# Make file to assembly RISC-V assembly language program(s) in myprog folder
#   ... relocate instruction to start at 0xBFC00000
#   ... output hex file ready to be read into instruction memory
SHELL := /bin/bash

clean:
	@rm -f *.hex *.asm *.out *.bin

F1_Light: F1_Light.s
	@riscv64-unknown-elf-as -R -march=rv32im -mabi=ilp32 -o F1_Light.out F1_Light.s
	@riscv64-unknown-elf-ld -melf32lriscv -e 0xBFC00000 -Ttext 0xBFC00000 -o F1_Light.out.reloc F1_Light.out
	@riscv64-unknown-elf-objcopy -O binary -j .text F1_Light.out.reloc F1_Light.bin
	@riscv64-unknown-elf-objdump -D -S -l -F -Mno-aliases F1_Light.out.reloc > F1_Light.asm
	@set -euo pipefail
	@od -v -An -t x1 F1_Light.bin | tr -s '\n' | awk '{F1_Light=F1_Light};1' > F1_Light.hex
	@rm F1_Light.out
	@rm F1_Light.out.reloc
	@rm F1_Light.bin
