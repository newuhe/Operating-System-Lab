.code16	
.global start
start:
	#初始化DS ES SS SP
	xor  %ax,%ax
	movw %ax,%ds
	movw %ax,%es
	movw %ax,%ss
	
	data32 addr32 lgdt gdtDesc      #加载GDTR
	
	cli				#关中断
	
	inb $0x92, %al                  #启动A20总线
        orb $0x02, %al
        outb %al, $0x92

        movl %cr0, %eax                 #启动保护模式
        orb  $0x01, %al
        movl %eax, %cr0
        data32 ljmp $0x08, $start32     #长跳转切换至保护模式

.code32
start32:
	# 初始化DS，ES，FS，GS，SS，栈顶指针ESP
    	
	mov  $SelectorData,%ax
	movw %ax, %ds
	movw %ax, %es                                   # -> ES: Extra Segment
	movw %ax, %fs                                   # -> FS
	movw %ax, %ss                                   # -> SS: Stack Segment
	
	# Set up the stack pointer and call into C. 
	movl $0x0, %ebp
    	movl $0x8000, %esp

	mov  $SelectorVideo,%ax
	mov  %ax,%gs
	movl $((80*10+0)*2), %edi                #在第5行第0列打印
	movb $0x0c, %ah                         #黑底红字
	mov $'H', %al                 #42为H的ASCII码
	movw %ax, %gs:(%edi)                    #写显存
	movl $((80*10+1)*2), %edi                #在第5行第0列打印
	mov $'e', %al                  #42为H的ASCII码
	movw %ax, %gs:(%edi)                    #写显存
	movl $((80*10+2)*2), %edi                #在第5行第0列打印
	mov $'l', %al                  #42为H的ASCII码
	movw %ax, %gs:(%edi)                    #写显存
	movl $((80*10+3)*2), %edi                #在第5行第0列打印
	mov $'l', %al                  #42为H的ASCII码
	movw %ax, %gs:(%edi)                    #写显存
	movl $((80*10+4)*2), %edi                #在第5行第0列打印
	mov $'o', %al                  #42为H的ASCII码
	movw %ax, %gs:(%edi)                    #写显存
	jmp bootmain

	spin:
	jmp spin	


.p2align 2
gdt:
	.word 0,0 			# GDT第一个表项必须为空
	.byte 0,0,0,0
LABEL_DESC_CODE:
	.word 0xffff,0                  #代码段描述符
        .byte 0,0x9a,0xcf,0
LABEL_DESC_DATA:
        .word 0xffff,0                  #数据段描述符
        .byte 0,0x92,0xcf,0
LABEL_DESC_VIDEO:        
        .word 0xffff,0x8000             #视频段描述符
        .byte 0x0b,0x92,0xcf,0

gdtDesc:
	.word (gdtDesc - gdt -1)
	.long gdt

SelectorCode=LABEL_DESC_CODE-gdt
SelectorData=LABEL_DESC_DATA-gdt
SelectorVideo=LABEL_DESC_VIDEO-gdt
