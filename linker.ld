OUTPUT_FORMAT("binary")
ENTRY(_start)
SECTIONS
{
  .text : {
    *(.text)
  }
  .data  : {
    *(.data)
  }
  .bss :
  {      
    *(.bss)
  }
}
