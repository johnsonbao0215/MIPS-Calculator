# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#


	.macro extract_nth_bit($regD, $regS, $regT)
	srlv	$regS, $regS, $regT		# Shift right
	li	$regD, 1			# regD = 1
	and	$regD, $regS, $regD		# Check the right most bit of $regS
	.end_macro

	.macro extract_n_bit($regD, $regS)
	li	$regD, 1			# regD = 1
	and	$regD, $regS, $regD		# Check the right most bit of $regS
	srl	$regS, $regS, 1			# Shift right by 1
	.end_macro

	.macro insert_to_nth_bit($regD, $regS, $regT, $maskReg)
	move	$maskReg, $regT			# Move 1 in regT into maskReg
	sllv	$maskReg, $maskReg, $regS	# Shift left
	or	$regD, $regD, $maskReg		# regD = regD or maskReg
	.end_macro

	.macro half_adder($bit_A, $bit_B, $answer, $carry)
	xor	$answer, $bit_A, $bit_B		# Answer = bit_A xor bit_B
	and	$carry, $bit_A, $bit_B		# Carry = bit_A and bit_B
	.end_macro

	.macro full_adder($bit_A, $bit_B, $answer, $AB, $carry_in, $carry_out)
	half_adder($bit_A, $bit_B, $answer, $AB)
	and	$carry_out, $carry_in, $answer	# Carry out = carry in and (bit_A xor bit_B)
	xor	$answer, $carry_in, $answer	# Answer = carry in xor (bit_A xor bit_B)
	xor	$carry_out, $carry_out, $AB	# Carry out = (carry in and (bit_A xor bit_B)) xor
						# (bit_A and bit_B)
	.end_macro

	.macro store_all_frame
	addi	$sp, $sp, -60
	sw	$fp, 60($sp)
	sw	$ra, 56($sp)
	sw	$a0, 52($sp)
	sw	$a1, 48($sp)
	sw	$a2, 44($sp)
	sw	$a3, 40($sp)
	sw	$s0, 36($sp)
	sw	$s1, 32($sp)
	sw	$s2, 28($sp)
	sw	$s3, 24($sp)
	sw	$s4, 20($sp)
	sw	$s5, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 60
	.end_macro
	
	.macro restore_all_frame
	lw	$fp, 60($sp)
	lw	$ra, 56($sp)
	lw	$a0, 52($sp)
	lw	$a1, 48($sp)
	lw	$a2, 44($sp)
	lw	$a3, 40($sp)
	lw	$s0, 36($sp)
	lw	$s1, 32($sp)
	lw	$s2, 28($sp)
	lw	$s3, 24($sp)
	lw	$s4, 20($sp)
	lw	$s5, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7, 8($sp)
	addi	$sp, $sp, 60
	.end_macro
