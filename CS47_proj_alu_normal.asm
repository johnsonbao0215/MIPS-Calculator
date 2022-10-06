.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes: This function uses normal math operation
#####################################################################
au_normal:
	store_all_frame	
	li	$t0, '+'				# Stores '+' into $t0
	beq	$t0, $a2, addition_normal		# If $t0 == $a2, then move to addition
	li	$t0, '-'				# Stores '-' into $t0
	beq	$t0, $a2, subtraction_normal		# If $t0 == $a2, then move to subtraction
	li	$t0, '*'				# Stores '*' into $t0
	beq	$t0, $a2, multiplication_normal		# If $t0 == $a2, then move to multiplication
	li	$t0, '/'				# Stores '/' into $t0
	beq	$t0, $a2, division_normal		# If $t0 == $a2, then move to division
	
addition_normal:
	add	$v0, $a0, $a1
	j	exit
	
subtraction_normal:
	sub	$v0, $a0, $a1
	j	exit
	
multiplication_normal:
	mult	$a0, $a1
	mflo	$v0
	mfhi	$v1
	j	exit
	
division_normal:
	div	$a0, $a1
	mflo	$v0
	mfhi	$v1
	j	exit
	
exit:
	restore_all_frame
	jr	$ra
