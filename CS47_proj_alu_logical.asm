.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
	store_all_frame

	li	$t0, '+'				# Stores '+' into $t0
	beq	$t0, $a2, addition_logical		# If $t0 == $a2, then move to addition
	li	$t0, '-'				# Stores '-' into $t0
	beq	$t0, $a2, subtraction_logical		# If $t0 == $a2, then move to subtraction
	li	$t0, '*'				# Stores '*' into $t0
	beq	$t0, $a2, multiplication_logical	# If $t0 == $a2, then move to multiplication
	li	$t0, '/'				# Stores '/' into $t0
	beq	$t0, $a2, division_logical		# If $t0 == $a2, then move to division
	j	exit					
	
addition_logical:
	jal	add_logical
	j	exit
	
subtraction_logical:
	jal	sub_logical
	j	exit
	
multiplication_logical:
	jal	mul_signed
	j	exit
	
division_logical:
	jal	div_signed
	j	exit
	
exit:
	restore_all_frame
	jr 	$ra


add_logical:
	store_all_frame
	
	li	$t0, 0					# Make $t0 = 0 to hold $a2
	li	$t1, 0					# Make $t1 = 0 to hold $a1
	li	$t2, 0					# Position pointer = $s1
	li	$t4, 0					# Carry holder
	li	$t5, 0					# Bit answer holder = $s2
	li	$t6, 0					# carry in for full adder = $s3
	add	$s0, $zero, $zero			# Saving the final outcome = $s0
	
addition_loop:
	beq	$t2, 32, end_addition_loop
	extract_n_bit($t0, $a0)				# $t0 = first bit of $a2
	extract_n_bit($t1, $a1)				# $t1 = first bit of $a1
	full_adder($t0, $t1, $t5, $t4, $t6, $t8) 	# Full adder: $t5: bit answer, $t8: carry out
	insert_to_nth_bit($s0, $t2, $t5, $t6) 	 	# Insert $s2 at $s1 position of $s0
	move	$t6, $t8 				# Make carry in ($t6) be carry out ($t8)
	addi	$t2, $t2, 1				# Increment $s1
	j	addition_loop
	
end_addition_loop:
	move	$v0, $s0
	move	$v1, $t8				# Holds the overflow
	
	restore_all_frame
	jr	$ra


sub_logical:
	store_all_frame
	
	neg	$a1, $a1				# Negate $a1
	jal	add_logical
	
	restore_all_frame
	jr	$ra

mul_unsigned:
	store_all_frame
	
	move	$s6, $a1 				# $s6 = $a1
	li	$s0, 0 					# $s0 for Hi section of product
	li	$s1, 0 					# $s1 for Lo section of product
	li	$s2, 0 					# $s2 for Hi of multiplicand
	jal	twos_complement_if_neg			# Unsigned mul = |multiplicand|
	move	$s3, $v0 				# $s3 for Lo of multiplicand
	move	$a0, $s6
	jal	twos_complement_if_neg			# Unsigned mul -> |multiplier|
	move	$s5, $v0 				# Holder for multiplier ($a1 changes)
	li	$s4, 0   				# $s4 = loop counter
	
unsigned_mul_loop:
	beq	$s4, 32, stop_unsigned_mul
	beqz	$s5, stop_unsigned_mul			# If no multiplicand -> exit
	extract_n_bit($t0, $s5)				# Check for LSB of multiplicand
	beqz	$t0, shift_1
	move	$a0, $s0				# Add product and multiplicand in 64 bit
	move	$a1, $s1
	move	$a2, $s2
	move	$a3, $s3
	jal	adder_64bit
	move	$s0, $v0
	move	$s1, $v1

shift_1:
	move	$a0, $s2				# shift MCND left by 1
	move	$a1, $s3
	jal	multiplicand_64_shift_left
	move	$s2, $v0
	move	$s3, $v1
	
	addi	$s4, $s4, 1
	j	unsigned_mul_loop

stop_unsigned_mul:
	move	$v0, $s1
	move	$v1, $s0
	
	restore_all_frame
	jr	$ra

mul_signed:
	store_all_frame
	move	$t1, $a0				# Get the MSB for both $a0, $a1
	move	$t2, $a1
	li	$t3, 31
	extract_nth_bit($t0, $t1, $t3)
	extract_nth_bit($t4, $t2, $t3)
							
	
	# Compare signs, same = positive; Different = 2's comp
	xor	$s6, $t0, $t4				# $s6 save the result
	jal	mul_unsigned
	move	$s0, $v0				# Lo
	move	$s1, $v1				# Hi
	
	beqz	$s6, end_mul_signed
	move	$a0, $s0
	move	$a1, $s1
	jal	twos_complement_64bit
	move	$s0, $v0
	move	$s1, $v1
	
end_mul_signed:
	move	$v0, $s0
	move	$v1, $s1
	
	restore_all_frame
	jr	$ra

div_unsigned:

	store_all_frame
	
	move	$s1, $a1				# $s1 = $a1 for divisor
	jal	twos_complement_if_neg
	move	$s0, $v0				# $s0 = $v0(|$a0|) for dividend
	move	$a0, $s1
	jal	twos_complement_if_neg
	move	$s1, $v0				# $s1 = $v0(|$a1|) for divisor
	li	$s2, 0					# $s2 = quotient
	li	$s3, 0					# $s3 = remainder
	li	$s4, 0					# $s4 = loop counter
	
	move	$s2, $s0				# Quotient = dividend
	
div_loop:
	beq	$s4, 32, stop_div
	sll	$s3, $s3, 1				# remainder shift left by 1
	li	$t1, 31					# $t1 = 31
	move	$t2, $s2				# $t2 = $s2
	
	# Get the MSB from dividend, insert at LSB of remainder
	extract_nth_bit($t0, $t2, $t1)
	insert_to_nth_bit($s3, $zero, $t0, $t3)
	sll	$s2, $s2, 1				# Shift left 1
	
	move	$a0, $s3				# $t3 = remainder - divisor
	move	$a1, $s1
	jal	sub_logical
	move	$t3, $v0
	
	bltz	$t3, cont
	move	$s3, $t3				# remainder = $t3, remainder > divisor = no longer remainder
							# insert one to the quotient at the MSB
	li	$t0, 1					# $t0 = 1
	insert_to_nth_bit($s2, $zero, $t0, $t2)
	
cont:
	addi	$s4, $s4, 1
	j	div_loop
	
stop_div:
	move	$v0, $s2 				# $v0 = quotient
	move	$v1, $s3				# $v1 = remainder
	
	restore_all_frame
	jr	$ra

div_signed:
	store_all_frame
	
	move	$t1, $a0
	move	$t2, $a1
	li	$t3, 31
	extract_nth_bit($s3, $t1, $t3)
	extract_nth_bit($s4, $t2, $t3)
							# Compare signs
							# Same = positive; Different = 2's comp
	xor	$s0, $s3, $s4				# $s0 saves result
	
	jal	div_unsigned
	move	$s1, $v0				# Quotient
	move	$s2, $v1				# Remainder
	
	beqz	$s0, check_remainder
	move	$a0, $s1
	jal	twos_complement
	move	$s1, $v0				# 2's comp quotient, then $s1 = $v0
	
check_remainder:
	beqz	$s3, stop_div_signed
	move	$a0, $s2
	jal	twos_complement
	move	$s2, $v0				# 2's comp remainder, then $s2 = $v0
	
stop_div_signed:
	move	$v0, $s1 				# $v0 = quotient
	move	$v1, $s2				# $v1 = remainder
	
	restore_all_frame
	jr	$ra

twos_complement:
	store_all_frame
	
	not	$a0, $a0
	li	$a1, 1
	jal	add_logical
	
	restore_all_frame
	jr	$ra

twos_complement_if_neg:
	store_all_frame
	
	li	$t1, 31
	move	$t2, $a0
	extract_nth_bit($t0, $t2, $t1)
	beqz	$t0, greater_than
	jal	twos_complement
	j	done
	
greater_than:
	move	$v0, $a0
	
done:
	restore_all_frame
	jr	$ra

twos_complement_64bit:
	store_all_frame
	
	not	$a0, $a0				# Invert $a0
	not	$a1, $a1				# Invert $a1
	move	$s0, $a1				# $s0 = $a1
	li	$a1, 1
	jal	add_logical
	# First add
	move	$a0, $v1				# Set $a0 to the overflow bit
	move	$a1, $s0				# $a1 = $s0
	move	$s1, $v0				# Save Lo of 64bit 2'complement in $s1
	jal	add_logical
	# Second add
	move	$v1, $v0				# Move Hi of 64bit 2'complement in $v1
	move	$v0, $s1
	
	restore_all_frame
	jr	$ra

adder_64bit:
	store_all_frame
	
	move	$s0, $a0				# $s0 for Lo
	move	$s1, $a1				# $s1 for Hi
	move	$s2, $a2				# $s2 for Lo result
	move	$s3, $a3				# $s3 for Hi result
	
	# add Los
	move	$a0, $s2
	move	$a1, $s0
	jal	add_logical
	move	$s2, $v0				# $s2 = Lo result
	move	$t0, $v1				# Carry out
	
	# first add Hi with carry out
	move 	$a0, $s3
	move	$a1, $t0
	jal	add_logical
	move	$s3, $v0				# Temp result
	
	# add hi part
	move 	$a0, $s3
	move	$a1, $s1
	jal	add_logical
	move	$s3, $v0				# $s3 = Hi result
	
	# end
	move	$v0, $s2
	move	$v1, $s3
	
	restore_all_frame
	jr 	$ra

multiplicand_64_shift_left:
	store_all_frame

	# get MSB of low
	move	$s0, $a1				# Set $s0 = low part
	li	$t1, 31					# Shift by 31 to get the last bit
	extract_nth_bit($t0, $s0, $t1)
	sll	$a0, $a0, 1 				# Shift high part (make room)
	insert_to_nth_bit($a0, $zero, $t0, $t1)		# Shift high register, then insert MSB from low
	sll	$a1, $a1, 1 				# Shift low register
	
	move	$v0, $a0
	move	$v1, $a1
	
	restore_all_frame
	jr	$ra
