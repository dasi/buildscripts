OUTPUT_FORMAT("elf32-v810", "elf32-v810", "elf32-v810")
OUTPUT_ARCH(v810)
ENTRY(_start)

MEMORY {

	wram (!r) : ORIGIN = 0x05000000, LENGTH = 64K
	rom	(rx) : ORIGIN = 0x07000000, LENGTH = 16M
}

__text_start = ORIGIN(rom);
__data_start = ORIGIN(wram);
__wram_top = ORIGIN(wram) + LENGTH(wram);
__stack = __wram_top - 0x30;
__gp = __data_start + 0x8000;

SECTIONS
{
	. = __text_start;
	.text : {
		*(.text)
		*(.text.*)
		/* .gnu.warning sections are handled specially by elf32.em.  */
		*(.gnu.warning)
		*(.gnu.linkonce.t*)
	} >rom = 0xFF

	__text_end = .;

	.rodata : {
		*(.rodata)
		*all.rodata*(*)
		*(.roda)
		*(.rodata.*)
		*(.gnu.linkonce.r*)
		/* SORT(CONSTRUCTORS) */
	} >rom = 0xFF

	.rosdata ALIGN(4) : {
		*(.rosdata)
	} >rom = 0xFF
  
	__data_lma = .;

	.data __data_start : AT ( __data_lma ) {
		__data_start = ABSOLUTE(.);
		*(.data)
		*(.data.*)
		*(.gnu.linkonce.d*)
		/* CONSTRUCTORS */
	} >wram = 0xFF

	.sdata ALIGN(4) : {
		*(.sdata)
	} >wram = 0xFF

	__data_end = .;

	.sbss ALIGN(4) (NOLOAD) : {
		*(.sbss)
		*(.scommon)
	} >wram

	.bss ALIGN(4) (NOLOAD) : {
		*(.dynbss)
		*(.bss)
		*(COMMON)
	} >wram

	/* Place vector table at end of rom */

	__vectors_lma = __data_lma + (__data_end - __data_start);

	.vectors 0x07FFFDE0 : AT ( __vectors_lma ) {
		KEEP (*(.vectors))
	} >rom = 0xFF
}
