.macro hdmaGradiente source, transferMode, channel
	ldxStx transferMode, DMAPx+channel
	ldxStx #.loword(source), A1TxL+channel
	ldaSta #.bankbyte(source), A1Bx+channel
.endmacro


.macro hdmaBg3 source, transferMode, channel
	ldaSta transferMode, f:DMAPx+channel
	ldaSta #.lobyte(CGADD), f:BBADx+channel
	ldaSta #.bankbyte(source), f:A1Bx+channel
	ldaSta #.lobyte(source), f:A1TxL+channel
.endmacro