import numpy as np
g_matrix_values = np . array ([[1 , 1 , 1 , 0 , 1 , 1 , 0 , 1 , 1 , 0 , 1 , 1 , 1 , 0 , 0 , 0 , 1 ,
g_matrix_values . shape
zero_col_top_left = np . zeros ((31 ,1))
iden_top_left = np . eye (31)
iden_top_left . shape
join_zero_ide_upper_left = np . hstack (( zero_col_top_left , iden_top_left ))
join_zero_ide_upper_left . shape
join_upper_left = np . vstack (( join_zero_ide_upper_left , g_matrix_values ))
join_upper_left
zero_col_top_right = np . zeros ((32 ,8))
zero_col_top_right . shape
join_upper_right_to_upper_left = np . hstack (( join_upper_left , zero_col_top_right ))
top_half = join_upper_right_to_upper_left
zero_bottom_left = np . zeros ((8 ,32))
zero_bottom_left . shape
zero_bottom_left [0 ,0] = 1
zero_bottom_left . shape
iden_bottom_right = np . eye (7)
row_zeros_col = np . zeros ((1 ,7))
bot_right_7x7 = np . vstack (( row_zeros_col , iden_bottom_right ))
bot_right_7x7 . shape
bot_right_zeros_row = np . zeros ((8 ,1))
stack_bot_right = np . hstack (( bot_right_7x7 , bot_right_zeros_row ))
stack_bot_right
stack_bot_right [0 ,7] = 1
bottom_half = np . hstack (( zero_bottom_left , stack_bot_right ))
bottom_half . shape
full_matrix = np . vstack (( top_half , bottom_half ))
full_matrix . shape
# Compute A ^8 and mod 2
full_matrix_power = np . linalg . matrix_power ( full_matrix , 8) % 2
num_cols = full_matrix_power . shape [1]
for x in range ( num_cols ):
if x > 31: # Stop after 32 registers
break
shift_memx = []
print ( f ’ shift_mem ({ x }) ␣ <= ␣ ’ , end = ’ ’)
for y in range ( full_matrix_power . shape [0]): # Iterate over rows
if full_matrix_power [y , x ]: # If the element is 1
if y > 31:
shift_memx . append ( f ’ NOT ( DATA_IN ({ y ␣ -␣ 32})) ’)
else :
shift_memx . append ( f ’ shift_mem ({ y }) ’)
print ( ’␣ xor ␣ ’. join ( shift_memx ) + ’; ’) # Print the XOR boolean expression