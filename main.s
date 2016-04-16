;Don't Panic 1K Main




detect_keys
move_sprite


move_sprite
	ldx sprite_x
	ldy sprite_y
	jsr delete_sprite
	ldx sprite_x
	ldy sprite_y
	iny
	jsr check_22loc
	bcs collision_code
	inc sprite_y
plot_sprite
	ldx sprite_x
	ldy sprite_y
	jsr calc_screen_address
	lda sprite_first_char
plotsp_01	ldy screen_offset,x
	sta ($10),y
	adc #01
	dex
	bpl plotsp_01
	rts

collision_code
	lda sprite_roll_flag
	beq check_lineage
roll_sprite
	;always roll right
	ldx sprite_x
	ldy sprite_y
	jsr delete_sprite
	ldx sprite_x
	ldy sprite_y
	inx
	inx
	iny
	iny
	jsr check_22loc
	bcs rollsp_01
	ldx sprite_x
	ldy sprite_y
	inc sprite_x
	inc sprite_x
	inc sprite_y
	inc sprite_y
	jsr plot_sprite
	jsr runtime_delay
	jmp roll_sprite
rollsp_01	jmp plot_sprite

check_lineage
	ldx #07
	lda sprite_x
	sec
	sbc negative_x_steps,x
	clc
	adc positive_x_steps,x
	sta chlg_01+1
	lda sprite_y
	sec
	sbc negative_y_steps,x
	clc
	adc positive_y_steps,x
	tay
	stx
chlg_01	ldx #00
	lda sprite_first_char
	jsr check_11loc
	bcs
check_22loc
	jsr calc_screen_address
c22loc_01	ldy screen_offset,x
	lda ($10),y
	cmp #33
	bcs c22loc_02
	dex
	bpl c22loc_01
c22loc_02	rts

screen_offset
 .byt 0,1,40,41


;Store result of x/y in $10-11, set x to 3 and clear carry
calc_screen_address

	ldx #03
	rts




	clc
	ldx #02
loop_01	stx map_index
	ldy #03
	;Get first object to compare against
loop_02	ldx map_index
	lda object_map,x
	cmp #32
	beq no_link_found	;Ignore white spaces and borders
	sta last_object
	;Get second object to compare against
	lda map_index
	adc offset_1,y
	tax
	lda object_map,x
	cmp last_object
	bne no_link_found
	;get third object to compare against
	lda map_index
	adc offset_2,y
	tax
	lda object_map,x
	cmp last_object
	bne no_link_found
	;Found a line of 3 objects, so Clear the line
	ldx map_index	;Clear First and drop anything above
	lda #32	;Empty
	sta object_map,x
	jsr drop_above
	lda map_index	;Clear Second and drop anything above
	adc offset_1,y
	tax
	lda #32	;Empty
	sta object_map,x
	jsr drop_above
	lda map_index	;Clear Third and drop anything above
	adc offset_1,y
	tax
	lda #32	;Empty
	sta object_map,x
	jsr drop_above
	;Replot map
	jsr plot_map
	;Restart from beginning of map - to find any links caused by dropping
	ldx #00
	beq loop_01

no_link_found
	dey
	bpl loop_02
	ldx map_index
	inx
	cpx #130
	bcc loop_01
	rts

drop_above
	txa
loop_01	sec
	sbc #12	;Look at object space immediately above
	tax
	bmi exit_01	;Quit if reached top
	lda object_map,x
	cmp #32
	beq exit_01	;Quit if space (Nothing will be above nothing)
	sta object_map+12,x
	txa
	jmp loop_01
exit_01	clc
	rts

plot_map
	ldy #10
loop_03	ldx #11
	;calculate map position
loop_02	tya
	;multiply y by 12
	asl
	asl
	sta entry_01+1
	asl
entry_01	adc #00
	stx entry_02+1
entry_02	adc #00
	tax
	lda object_map,x
	sta map_object
	;calculate screen position
	lda entry_02+1
	asl
	adc scn_ylocl,y
	sta $10
	lda scn_yloch,y
	adc #00
	sta $11
	stx entry_03+1
	sty entry_04+1
	lda map_object
	ldx #03
loop_01	ldy 22offset,x
	sta ($10),y
	adc #01
	dex
	bpl loop_01
entry_03	ldx #00
entry_04	ldy #00
	dex
	bpl loop_02
	dey
	bpl loop_03
	rts



offset_1
 .byt 1	;r
 .byt 13	;dr
 .byt 12	;d
 .byt 11	;dl
offset_2
 .byt 2
 .byt 26
 .byt 24
 .byt 22
