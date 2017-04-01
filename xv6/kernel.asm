
kernel: formato do arquivo elf32-i386


Desmontagem da seção .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 74 38 10 80       	mov    $0x80103874,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 08 85 10 80       	push   $0x80108508
80100042:	68 60 c6 10 80       	push   $0x8010c660
80100047:	e8 76 4f 00 00       	call   80104fc2 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 70 05 11 80 64 	movl   $0x80110564,0x80110570
80100056:	05 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 74 05 11 80 64 	movl   $0x80110564,0x80110574
80100060:	05 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 74 05 11 80       	mov    0x80110574,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 74 05 11 80       	mov    %eax,0x80110574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 64 05 11 80       	mov    $0x80110564,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 60 c6 10 80       	push   $0x8010c660
801000c1:	e8 1e 4f 00 00       	call   80104fe4 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 74 05 11 80       	mov    0x80110574,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 60 c6 10 80       	push   $0x8010c660
8010010c:	e8 3a 4f 00 00       	call   8010504b <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 60 c6 10 80       	push   $0x8010c660
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 bf 4b 00 00       	call   80104ceb <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 70 05 11 80       	mov    0x80110570,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 60 c6 10 80       	push   $0x8010c660
80100188:	e8 be 4e 00 00       	call   8010504b <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 0f 85 10 80       	push   $0x8010850f
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 0b 27 00 00       	call   801028f2 <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 20 85 10 80       	push   $0x80108520
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 ca 26 00 00       	call   801028f2 <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 27 85 10 80       	push   $0x80108527
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 60 c6 10 80       	push   $0x8010c660
80100255:	e8 8a 4d 00 00       	call   80104fe4 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 74 05 11 80       	mov    0x80110574,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 74 05 11 80       	mov    %eax,0x80110574

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 18 4b 00 00       	call   80104dd6 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 60 c6 10 80       	push   $0x8010c660
801002c9:	e8 7d 4d 00 00       	call   8010504b <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 c3 03 00 00       	call   80100776 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 c0 b5 10 80       	push   $0x8010b5c0
801003e2:	e8 fd 4b 00 00       	call   80104fe4 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 2e 85 10 80       	push   $0x8010852e
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 55 03 00 00       	call   80100776 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec 37 85 10 80 	movl   $0x80108537,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 8e 02 00 00       	call   80100776 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 71 02 00 00       	call   80100776 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 62 02 00 00       	call   80100776 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 54 02 00 00       	call   80100776 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 c0 b5 10 80       	push   $0x8010b5c0
8010055b:	e8 eb 4a 00 00       	call   8010504b <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 3e 85 10 80       	push   $0x8010853e
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 4d 85 10 80       	push   $0x8010854d
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 d6 4a 00 00       	call   8010509d <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 4f 85 10 80       	push   $0x8010854f
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)
  
  if((pos/80) >= 24){  // Scroll up.
801006b8:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006bf:	7e 4c                	jle    8010070d <cgaputc+0x10c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006c1:	a1 00 90 10 80       	mov    0x80109000,%eax
801006c6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006cc:	a1 00 90 10 80       	mov    0x80109000,%eax
801006d1:	83 ec 04             	sub    $0x4,%esp
801006d4:	68 60 0e 00 00       	push   $0xe60
801006d9:	52                   	push   %edx
801006da:	50                   	push   %eax
801006db:	e8 26 4c 00 00       	call   80105306 <memmove>
801006e0:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006e3:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006e7:	b8 80 07 00 00       	mov    $0x780,%eax
801006ec:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006ef:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006f2:	a1 00 90 10 80       	mov    0x80109000,%eax
801006f7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006fa:	01 c9                	add    %ecx,%ecx
801006fc:	01 c8                	add    %ecx,%eax
801006fe:	83 ec 04             	sub    $0x4,%esp
80100701:	52                   	push   %edx
80100702:	6a 00                	push   $0x0
80100704:	50                   	push   %eax
80100705:	e8 3d 4b 00 00       	call   80105247 <memset>
8010070a:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
8010070d:	83 ec 08             	sub    $0x8,%esp
80100710:	6a 0e                	push   $0xe
80100712:	68 d4 03 00 00       	push   $0x3d4
80100717:	e8 d5 fb ff ff       	call   801002f1 <outb>
8010071c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010071f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100722:	c1 f8 08             	sar    $0x8,%eax
80100725:	0f b6 c0             	movzbl %al,%eax
80100728:	83 ec 08             	sub    $0x8,%esp
8010072b:	50                   	push   %eax
8010072c:	68 d5 03 00 00       	push   $0x3d5
80100731:	e8 bb fb ff ff       	call   801002f1 <outb>
80100736:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100739:	83 ec 08             	sub    $0x8,%esp
8010073c:	6a 0f                	push   $0xf
8010073e:	68 d4 03 00 00       	push   $0x3d4
80100743:	e8 a9 fb ff ff       	call   801002f1 <outb>
80100748:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010074b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010074e:	0f b6 c0             	movzbl %al,%eax
80100751:	83 ec 08             	sub    $0x8,%esp
80100754:	50                   	push   %eax
80100755:	68 d5 03 00 00       	push   $0x3d5
8010075a:	e8 92 fb ff ff       	call   801002f1 <outb>
8010075f:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100762:	a1 00 90 10 80       	mov    0x80109000,%eax
80100767:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010076a:	01 d2                	add    %edx,%edx
8010076c:	01 d0                	add    %edx,%eax
8010076e:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100773:	90                   	nop
80100774:	c9                   	leave  
80100775:	c3                   	ret    

80100776 <consputc>:

void
consputc(int c)
{
80100776:	55                   	push   %ebp
80100777:	89 e5                	mov    %esp,%ebp
80100779:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
8010077c:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
80100781:	85 c0                	test   %eax,%eax
80100783:	74 07                	je     8010078c <consputc+0x16>
    cli();
80100785:	e8 86 fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
8010078a:	eb fe                	jmp    8010078a <consputc+0x14>
  }

  if(c == BACKSPACE){
8010078c:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100793:	75 29                	jne    801007be <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100795:	83 ec 0c             	sub    $0xc,%esp
80100798:	6a 08                	push   $0x8
8010079a:	e8 f2 63 00 00       	call   80106b91 <uartputc>
8010079f:	83 c4 10             	add    $0x10,%esp
801007a2:	83 ec 0c             	sub    $0xc,%esp
801007a5:	6a 20                	push   $0x20
801007a7:	e8 e5 63 00 00       	call   80106b91 <uartputc>
801007ac:	83 c4 10             	add    $0x10,%esp
801007af:	83 ec 0c             	sub    $0xc,%esp
801007b2:	6a 08                	push   $0x8
801007b4:	e8 d8 63 00 00       	call   80106b91 <uartputc>
801007b9:	83 c4 10             	add    $0x10,%esp
801007bc:	eb 0e                	jmp    801007cc <consputc+0x56>
  } else
    uartputc(c);
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	ff 75 08             	pushl  0x8(%ebp)
801007c4:	e8 c8 63 00 00       	call   80106b91 <uartputc>
801007c9:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007cc:	83 ec 0c             	sub    $0xc,%esp
801007cf:	ff 75 08             	pushl  0x8(%ebp)
801007d2:	e8 2a fe ff ff       	call   80100601 <cgaputc>
801007d7:	83 c4 10             	add    $0x10,%esp
}
801007da:	90                   	nop
801007db:	c9                   	leave  
801007dc:	c3                   	ret    

801007dd <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007dd:	55                   	push   %ebp
801007de:	89 e5                	mov    %esp,%ebp
801007e0:	83 ec 18             	sub    $0x18,%esp
  int c;

  acquire(&input.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 80 07 11 80       	push   $0x80110780
801007eb:	e8 f4 47 00 00       	call   80104fe4 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 42 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    switch(c){
801007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007fb:	83 f8 10             	cmp    $0x10,%eax
801007fe:	74 1e                	je     8010081e <consoleintr+0x41>
80100800:	83 f8 10             	cmp    $0x10,%eax
80100803:	7f 0a                	jg     8010080f <consoleintr+0x32>
80100805:	83 f8 08             	cmp    $0x8,%eax
80100808:	74 69                	je     80100873 <consoleintr+0x96>
8010080a:	e9 99 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
8010080f:	83 f8 15             	cmp    $0x15,%eax
80100812:	74 31                	je     80100845 <consoleintr+0x68>
80100814:	83 f8 7f             	cmp    $0x7f,%eax
80100817:	74 5a                	je     80100873 <consoleintr+0x96>
80100819:	e9 8a 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
    case C('P'):  // Process listing.
      procdump();
8010081e:	e8 6e 46 00 00       	call   80104e91 <procdump>
      break;
80100823:	e9 12 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100828:	a1 3c 08 11 80       	mov    0x8011083c,%eax
8010082d:	83 e8 01             	sub    $0x1,%eax
80100830:	a3 3c 08 11 80       	mov    %eax,0x8011083c
        consputc(BACKSPACE);
80100835:	83 ec 0c             	sub    $0xc,%esp
80100838:	68 00 01 00 00       	push   $0x100
8010083d:	e8 34 ff ff ff       	call   80100776 <consputc>
80100842:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100845:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
8010084b:	a1 38 08 11 80       	mov    0x80110838,%eax
80100850:	39 c2                	cmp    %eax,%edx
80100852:	0f 84 e2 00 00 00    	je     8010093a <consoleintr+0x15d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100858:	a1 3c 08 11 80       	mov    0x8011083c,%eax
8010085d:	83 e8 01             	sub    $0x1,%eax
80100860:	83 e0 7f             	and    $0x7f,%eax
80100863:	0f b6 80 b4 07 11 80 	movzbl -0x7feef84c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010086a:	3c 0a                	cmp    $0xa,%al
8010086c:	75 ba                	jne    80100828 <consoleintr+0x4b>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010086e:	e9 c7 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100873:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
80100879:	a1 38 08 11 80       	mov    0x80110838,%eax
8010087e:	39 c2                	cmp    %eax,%edx
80100880:	0f 84 b4 00 00 00    	je     8010093a <consoleintr+0x15d>
        input.e--;
80100886:	a1 3c 08 11 80       	mov    0x8011083c,%eax
8010088b:	83 e8 01             	sub    $0x1,%eax
8010088e:	a3 3c 08 11 80       	mov    %eax,0x8011083c
        consputc(BACKSPACE);
80100893:	83 ec 0c             	sub    $0xc,%esp
80100896:	68 00 01 00 00       	push   $0x100
8010089b:	e8 d6 fe ff ff       	call   80100776 <consputc>
801008a0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008a3:	e9 92 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801008ac:	0f 84 87 00 00 00    	je     80100939 <consoleintr+0x15c>
801008b2:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
801008b8:	a1 34 08 11 80       	mov    0x80110834,%eax
801008bd:	29 c2                	sub    %eax,%edx
801008bf:	89 d0                	mov    %edx,%eax
801008c1:	83 f8 7f             	cmp    $0x7f,%eax
801008c4:	77 73                	ja     80100939 <consoleintr+0x15c>
        c = (c == '\r') ? '\n' : c;
801008c6:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
801008ca:	74 05                	je     801008d1 <consoleintr+0xf4>
801008cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008cf:	eb 05                	jmp    801008d6 <consoleintr+0xf9>
801008d1:	b8 0a 00 00 00       	mov    $0xa,%eax
801008d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008d9:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801008de:	8d 50 01             	lea    0x1(%eax),%edx
801008e1:	89 15 3c 08 11 80    	mov    %edx,0x8011083c
801008e7:	83 e0 7f             	and    $0x7f,%eax
801008ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008ed:	88 90 b4 07 11 80    	mov    %dl,-0x7feef84c(%eax)
        consputc(c);
801008f3:	83 ec 0c             	sub    $0xc,%esp
801008f6:	ff 75 f4             	pushl  -0xc(%ebp)
801008f9:	e8 78 fe ff ff       	call   80100776 <consputc>
801008fe:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100901:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
80100905:	74 18                	je     8010091f <consoleintr+0x142>
80100907:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
8010090b:	74 12                	je     8010091f <consoleintr+0x142>
8010090d:	a1 3c 08 11 80       	mov    0x8011083c,%eax
80100912:	8b 15 34 08 11 80    	mov    0x80110834,%edx
80100918:	83 ea 80             	sub    $0xffffff80,%edx
8010091b:	39 d0                	cmp    %edx,%eax
8010091d:	75 1a                	jne    80100939 <consoleintr+0x15c>
          input.w = input.e;
8010091f:	a1 3c 08 11 80       	mov    0x8011083c,%eax
80100924:	a3 38 08 11 80       	mov    %eax,0x80110838
          wakeup(&input.r);
80100929:	83 ec 0c             	sub    $0xc,%esp
8010092c:	68 34 08 11 80       	push   $0x80110834
80100931:	e8 a0 44 00 00       	call   80104dd6 <wakeup>
80100936:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100939:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
8010093a:	8b 45 08             	mov    0x8(%ebp),%eax
8010093d:	ff d0                	call   *%eax
8010093f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100942:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100946:	0f 89 ac fe ff ff    	jns    801007f8 <consoleintr+0x1b>
        }
      }
      break;
    }
  }
  release(&input.lock);
8010094c:	83 ec 0c             	sub    $0xc,%esp
8010094f:	68 80 07 11 80       	push   $0x80110780
80100954:	e8 f2 46 00 00       	call   8010504b <release>
80100959:	83 c4 10             	add    $0x10,%esp
}
8010095c:	90                   	nop
8010095d:	c9                   	leave  
8010095e:	c3                   	ret    

8010095f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010095f:	55                   	push   %ebp
80100960:	89 e5                	mov    %esp,%ebp
80100962:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100965:	83 ec 0c             	sub    $0xc,%esp
80100968:	ff 75 08             	pushl  0x8(%ebp)
8010096b:	e8 3d 11 00 00       	call   80101aad <iunlock>
80100970:	83 c4 10             	add    $0x10,%esp
  target = n;
80100973:	8b 45 10             	mov    0x10(%ebp),%eax
80100976:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 80 07 11 80       	push   $0x80110780
80100981:	e8 5e 46 00 00       	call   80104fe4 <acquire>
80100986:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100989:	e9 ac 00 00 00       	jmp    80100a3a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
8010098e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100994:	8b 40 24             	mov    0x24(%eax),%eax
80100997:	85 c0                	test   %eax,%eax
80100999:	74 28                	je     801009c3 <consoleread+0x64>
        release(&input.lock);
8010099b:	83 ec 0c             	sub    $0xc,%esp
8010099e:	68 80 07 11 80       	push   $0x80110780
801009a3:	e8 a3 46 00 00       	call   8010504b <release>
801009a8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009ab:	83 ec 0c             	sub    $0xc,%esp
801009ae:	ff 75 08             	pushl  0x8(%ebp)
801009b1:	e8 99 0f 00 00       	call   8010194f <ilock>
801009b6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009be:	e9 ab 00 00 00       	jmp    80100a6e <consoleread+0x10f>
      }
      sleep(&input.r, &input.lock);
801009c3:	83 ec 08             	sub    $0x8,%esp
801009c6:	68 80 07 11 80       	push   $0x80110780
801009cb:	68 34 08 11 80       	push   $0x80110834
801009d0:	e8 16 43 00 00       	call   80104ceb <sleep>
801009d5:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
801009d8:	8b 15 34 08 11 80    	mov    0x80110834,%edx
801009de:	a1 38 08 11 80       	mov    0x80110838,%eax
801009e3:	39 c2                	cmp    %eax,%edx
801009e5:	74 a7                	je     8010098e <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009e7:	a1 34 08 11 80       	mov    0x80110834,%eax
801009ec:	8d 50 01             	lea    0x1(%eax),%edx
801009ef:	89 15 34 08 11 80    	mov    %edx,0x80110834
801009f5:	83 e0 7f             	and    $0x7f,%eax
801009f8:	0f b6 80 b4 07 11 80 	movzbl -0x7feef84c(%eax),%eax
801009ff:	0f be c0             	movsbl %al,%eax
80100a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a05:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a09:	75 17                	jne    80100a22 <consoleread+0xc3>
      if(n < target){
80100a0b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a0e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a11:	73 2f                	jae    80100a42 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a13:	a1 34 08 11 80       	mov    0x80110834,%eax
80100a18:	83 e8 01             	sub    $0x1,%eax
80100a1b:	a3 34 08 11 80       	mov    %eax,0x80110834
      }
      break;
80100a20:	eb 20                	jmp    80100a42 <consoleread+0xe3>
    }
    *dst++ = c;
80100a22:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a25:	8d 50 01             	lea    0x1(%eax),%edx
80100a28:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a2b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a2e:	88 10                	mov    %dl,(%eax)
    --n;
80100a30:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a34:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a38:	74 0b                	je     80100a45 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100a3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a3e:	7f 98                	jg     801009d8 <consoleread+0x79>
80100a40:	eb 04                	jmp    80100a46 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a42:	90                   	nop
80100a43:	eb 01                	jmp    80100a46 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a45:	90                   	nop
  }
  release(&input.lock);
80100a46:	83 ec 0c             	sub    $0xc,%esp
80100a49:	68 80 07 11 80       	push   $0x80110780
80100a4e:	e8 f8 45 00 00       	call   8010504b <release>
80100a53:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a56:	83 ec 0c             	sub    $0xc,%esp
80100a59:	ff 75 08             	pushl  0x8(%ebp)
80100a5c:	e8 ee 0e 00 00       	call   8010194f <ilock>
80100a61:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a64:	8b 45 10             	mov    0x10(%ebp),%eax
80100a67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a6a:	29 c2                	sub    %eax,%edx
80100a6c:	89 d0                	mov    %edx,%eax
}
80100a6e:	c9                   	leave  
80100a6f:	c3                   	ret    

80100a70 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a70:	55                   	push   %ebp
80100a71:	89 e5                	mov    %esp,%ebp
80100a73:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	ff 75 08             	pushl  0x8(%ebp)
80100a7c:	e8 2c 10 00 00       	call   80101aad <iunlock>
80100a81:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a84:	83 ec 0c             	sub    $0xc,%esp
80100a87:	68 c0 b5 10 80       	push   $0x8010b5c0
80100a8c:	e8 53 45 00 00       	call   80104fe4 <acquire>
80100a91:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100a94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a9b:	eb 21                	jmp    80100abe <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100a9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100aa3:	01 d0                	add    %edx,%eax
80100aa5:	0f b6 00             	movzbl (%eax),%eax
80100aa8:	0f be c0             	movsbl %al,%eax
80100aab:	0f b6 c0             	movzbl %al,%eax
80100aae:	83 ec 0c             	sub    $0xc,%esp
80100ab1:	50                   	push   %eax
80100ab2:	e8 bf fc ff ff       	call   80100776 <consputc>
80100ab7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ac1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ac4:	7c d7                	jl     80100a9d <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100ac6:	83 ec 0c             	sub    $0xc,%esp
80100ac9:	68 c0 b5 10 80       	push   $0x8010b5c0
80100ace:	e8 78 45 00 00       	call   8010504b <release>
80100ad3:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ad6:	83 ec 0c             	sub    $0xc,%esp
80100ad9:	ff 75 08             	pushl  0x8(%ebp)
80100adc:	e8 6e 0e 00 00       	call   8010194f <ilock>
80100ae1:	83 c4 10             	add    $0x10,%esp

  return n;
80100ae4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100ae7:	c9                   	leave  
80100ae8:	c3                   	ret    

80100ae9 <consoleinit>:

void
consoleinit(void)
{
80100ae9:	55                   	push   %ebp
80100aea:	89 e5                	mov    %esp,%ebp
80100aec:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100aef:	83 ec 08             	sub    $0x8,%esp
80100af2:	68 53 85 10 80       	push   $0x80108553
80100af7:	68 c0 b5 10 80       	push   $0x8010b5c0
80100afc:	e8 c1 44 00 00       	call   80104fc2 <initlock>
80100b01:	83 c4 10             	add    $0x10,%esp
  initlock(&input.lock, "input");
80100b04:	83 ec 08             	sub    $0x8,%esp
80100b07:	68 5b 85 10 80       	push   $0x8010855b
80100b0c:	68 80 07 11 80       	push   $0x80110780
80100b11:	e8 ac 44 00 00       	call   80104fc2 <initlock>
80100b16:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b19:	c7 05 ec 11 11 80 70 	movl   $0x80100a70,0x801111ec
80100b20:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b23:	c7 05 e8 11 11 80 5f 	movl   $0x8010095f,0x801111e8
80100b2a:	09 10 80 
  cons.locking = 1;
80100b2d:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100b34:	00 00 00 

  picenable(IRQ_KBD);
80100b37:	83 ec 0c             	sub    $0xc,%esp
80100b3a:	6a 01                	push   $0x1
80100b3c:	e8 cf 33 00 00       	call   80103f10 <picenable>
80100b41:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b44:	83 ec 08             	sub    $0x8,%esp
80100b47:	6a 00                	push   $0x0
80100b49:	6a 01                	push   $0x1
80100b4b:	e8 6f 1f 00 00       	call   80102abf <ioapicenable>
80100b50:	83 c4 10             	add    $0x10,%esp
}
80100b53:	90                   	nop
80100b54:	c9                   	leave  
80100b55:	c3                   	ret    

80100b56 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b56:	55                   	push   %ebp
80100b57:	89 e5                	mov    %esp,%ebp
80100b59:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b5f:	e8 ce 29 00 00       	call   80103532 <begin_op>
  if((ip = namei(path)) == 0){
80100b64:	83 ec 0c             	sub    $0xc,%esp
80100b67:	ff 75 08             	pushl  0x8(%ebp)
80100b6a:	e8 9e 19 00 00       	call   8010250d <namei>
80100b6f:	83 c4 10             	add    $0x10,%esp
80100b72:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b75:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b79:	75 0f                	jne    80100b8a <exec+0x34>
    end_op();
80100b7b:	e8 3e 2a 00 00       	call   801035be <end_op>
    return -1;
80100b80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b85:	e9 ce 03 00 00       	jmp    80100f58 <exec+0x402>
  }
  ilock(ip);
80100b8a:	83 ec 0c             	sub    $0xc,%esp
80100b8d:	ff 75 d8             	pushl  -0x28(%ebp)
80100b90:	e8 ba 0d 00 00       	call   8010194f <ilock>
80100b95:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100b98:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b9f:	6a 34                	push   $0x34
80100ba1:	6a 00                	push   $0x0
80100ba3:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100ba9:	50                   	push   %eax
80100baa:	ff 75 d8             	pushl  -0x28(%ebp)
80100bad:	e8 0b 13 00 00       	call   80101ebd <readi>
80100bb2:	83 c4 10             	add    $0x10,%esp
80100bb5:	83 f8 33             	cmp    $0x33,%eax
80100bb8:	0f 86 49 03 00 00    	jbe    80100f07 <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bbe:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bc4:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100bc9:	0f 85 3b 03 00 00    	jne    80100f0a <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bcf:	e8 12 71 00 00       	call   80107ce6 <setupkvm>
80100bd4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bd7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bdb:	0f 84 2c 03 00 00    	je     80100f0d <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100be1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100be8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100bef:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100bf5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bf8:	e9 ab 00 00 00       	jmp    80100ca8 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bfd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c00:	6a 20                	push   $0x20
80100c02:	50                   	push   %eax
80100c03:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c09:	50                   	push   %eax
80100c0a:	ff 75 d8             	pushl  -0x28(%ebp)
80100c0d:	e8 ab 12 00 00       	call   80101ebd <readi>
80100c12:	83 c4 10             	add    $0x10,%esp
80100c15:	83 f8 20             	cmp    $0x20,%eax
80100c18:	0f 85 f2 02 00 00    	jne    80100f10 <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c1e:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c24:	83 f8 01             	cmp    $0x1,%eax
80100c27:	75 71                	jne    80100c9a <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c29:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c2f:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c35:	39 c2                	cmp    %eax,%edx
80100c37:	0f 82 d6 02 00 00    	jb     80100f13 <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c3d:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c43:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c49:	01 d0                	add    %edx,%eax
80100c4b:	83 ec 04             	sub    $0x4,%esp
80100c4e:	50                   	push   %eax
80100c4f:	ff 75 e0             	pushl  -0x20(%ebp)
80100c52:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c55:	e8 33 74 00 00       	call   8010808d <allocuvm>
80100c5a:	83 c4 10             	add    $0x10,%esp
80100c5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c60:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c64:	0f 84 ac 02 00 00    	je     80100f16 <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c6a:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c70:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c76:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c7c:	83 ec 0c             	sub    $0xc,%esp
80100c7f:	52                   	push   %edx
80100c80:	50                   	push   %eax
80100c81:	ff 75 d8             	pushl  -0x28(%ebp)
80100c84:	51                   	push   %ecx
80100c85:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c88:	e8 29 73 00 00       	call   80107fb6 <loaduvm>
80100c8d:	83 c4 20             	add    $0x20,%esp
80100c90:	85 c0                	test   %eax,%eax
80100c92:	0f 88 81 02 00 00    	js     80100f19 <exec+0x3c3>
80100c98:	eb 01                	jmp    80100c9b <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100c9a:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c9b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ca2:	83 c0 20             	add    $0x20,%eax
80100ca5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ca8:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100caf:	0f b7 c0             	movzwl %ax,%eax
80100cb2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cb5:	0f 8f 42 ff ff ff    	jg     80100bfd <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cbb:	83 ec 0c             	sub    $0xc,%esp
80100cbe:	ff 75 d8             	pushl  -0x28(%ebp)
80100cc1:	e8 49 0f 00 00       	call   80101c0f <iunlockput>
80100cc6:	83 c4 10             	add    $0x10,%esp
  end_op();
80100cc9:	e8 f0 28 00 00       	call   801035be <end_op>
  ip = 0;
80100cce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd8:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cdd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ce2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ce5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ce8:	05 00 20 00 00       	add    $0x2000,%eax
80100ced:	83 ec 04             	sub    $0x4,%esp
80100cf0:	50                   	push   %eax
80100cf1:	ff 75 e0             	pushl  -0x20(%ebp)
80100cf4:	ff 75 d4             	pushl  -0x2c(%ebp)
80100cf7:	e8 91 73 00 00       	call   8010808d <allocuvm>
80100cfc:	83 c4 10             	add    $0x10,%esp
80100cff:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d02:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d06:	0f 84 10 02 00 00    	je     80100f1c <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d0f:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d14:	83 ec 08             	sub    $0x8,%esp
80100d17:	50                   	push   %eax
80100d18:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d1b:	e8 93 75 00 00       	call   801082b3 <clearpteu>
80100d20:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d23:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d26:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d29:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d30:	e9 96 00 00 00       	jmp    80100dcb <exec+0x275>
    if(argc >= MAXARG)
80100d35:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d39:	0f 87 e0 01 00 00    	ja     80100f1f <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d42:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d49:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d4c:	01 d0                	add    %edx,%eax
80100d4e:	8b 00                	mov    (%eax),%eax
80100d50:	83 ec 0c             	sub    $0xc,%esp
80100d53:	50                   	push   %eax
80100d54:	e8 3b 47 00 00       	call   80105494 <strlen>
80100d59:	83 c4 10             	add    $0x10,%esp
80100d5c:	89 c2                	mov    %eax,%edx
80100d5e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d61:	29 d0                	sub    %edx,%eax
80100d63:	83 e8 01             	sub    $0x1,%eax
80100d66:	83 e0 fc             	and    $0xfffffffc,%eax
80100d69:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d6f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d76:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d79:	01 d0                	add    %edx,%eax
80100d7b:	8b 00                	mov    (%eax),%eax
80100d7d:	83 ec 0c             	sub    $0xc,%esp
80100d80:	50                   	push   %eax
80100d81:	e8 0e 47 00 00       	call   80105494 <strlen>
80100d86:	83 c4 10             	add    $0x10,%esp
80100d89:	83 c0 01             	add    $0x1,%eax
80100d8c:	89 c1                	mov    %eax,%ecx
80100d8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d91:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d98:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d9b:	01 d0                	add    %edx,%eax
80100d9d:	8b 00                	mov    (%eax),%eax
80100d9f:	51                   	push   %ecx
80100da0:	50                   	push   %eax
80100da1:	ff 75 dc             	pushl  -0x24(%ebp)
80100da4:	ff 75 d4             	pushl  -0x2c(%ebp)
80100da7:	e8 be 76 00 00       	call   8010846a <copyout>
80100dac:	83 c4 10             	add    $0x10,%esp
80100daf:	85 c0                	test   %eax,%eax
80100db1:	0f 88 6b 01 00 00    	js     80100f22 <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100db7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dba:	8d 50 03             	lea    0x3(%eax),%edx
80100dbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dc0:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dc7:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100dcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dce:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dd8:	01 d0                	add    %edx,%eax
80100dda:	8b 00                	mov    (%eax),%eax
80100ddc:	85 c0                	test   %eax,%eax
80100dde:	0f 85 51 ff ff ff    	jne    80100d35 <exec+0x1df>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100de4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de7:	83 c0 03             	add    $0x3,%eax
80100dea:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100df1:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100df5:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100dfc:	ff ff ff 
  ustack[1] = argc;
80100dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e02:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e0b:	83 c0 01             	add    $0x1,%eax
80100e0e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e15:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e18:	29 d0                	sub    %edx,%eax
80100e1a:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e23:	83 c0 04             	add    $0x4,%eax
80100e26:	c1 e0 02             	shl    $0x2,%eax
80100e29:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	83 c0 04             	add    $0x4,%eax
80100e32:	c1 e0 02             	shl    $0x2,%eax
80100e35:	50                   	push   %eax
80100e36:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e3c:	50                   	push   %eax
80100e3d:	ff 75 dc             	pushl  -0x24(%ebp)
80100e40:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e43:	e8 22 76 00 00       	call   8010846a <copyout>
80100e48:	83 c4 10             	add    $0x10,%esp
80100e4b:	85 c0                	test   %eax,%eax
80100e4d:	0f 88 d2 00 00 00    	js     80100f25 <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e53:	8b 45 08             	mov    0x8(%ebp),%eax
80100e56:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e5f:	eb 17                	jmp    80100e78 <exec+0x322>
    if(*s == '/')
80100e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e64:	0f b6 00             	movzbl (%eax),%eax
80100e67:	3c 2f                	cmp    $0x2f,%al
80100e69:	75 09                	jne    80100e74 <exec+0x31e>
      last = s+1;
80100e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6e:	83 c0 01             	add    $0x1,%eax
80100e71:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e74:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e7b:	0f b6 00             	movzbl (%eax),%eax
80100e7e:	84 c0                	test   %al,%al
80100e80:	75 df                	jne    80100e61 <exec+0x30b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e82:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e88:	83 c0 6c             	add    $0x6c,%eax
80100e8b:	83 ec 04             	sub    $0x4,%esp
80100e8e:	6a 10                	push   $0x10
80100e90:	ff 75 f0             	pushl  -0x10(%ebp)
80100e93:	50                   	push   %eax
80100e94:	e8 b1 45 00 00       	call   8010544a <safestrcpy>
80100e99:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e9c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea2:	8b 40 04             	mov    0x4(%eax),%eax
80100ea5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ea8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100eb1:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100eb4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eba:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ebd:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100ebf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec5:	8b 40 18             	mov    0x18(%eax),%eax
80100ec8:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ece:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ed1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed7:	8b 40 18             	mov    0x18(%eax),%eax
80100eda:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100edd:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ee0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee6:	83 ec 0c             	sub    $0xc,%esp
80100ee9:	50                   	push   %eax
80100eea:	e8 de 6e 00 00       	call   80107dcd <switchuvm>
80100eef:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100ef2:	83 ec 0c             	sub    $0xc,%esp
80100ef5:	ff 75 d0             	pushl  -0x30(%ebp)
80100ef8:	e8 16 73 00 00       	call   80108213 <freevm>
80100efd:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f00:	b8 00 00 00 00       	mov    $0x0,%eax
80100f05:	eb 51                	jmp    80100f58 <exec+0x402>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100f07:	90                   	nop
80100f08:	eb 1c                	jmp    80100f26 <exec+0x3d0>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100f0a:	90                   	nop
80100f0b:	eb 19                	jmp    80100f26 <exec+0x3d0>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100f0d:	90                   	nop
80100f0e:	eb 16                	jmp    80100f26 <exec+0x3d0>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f10:	90                   	nop
80100f11:	eb 13                	jmp    80100f26 <exec+0x3d0>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f13:	90                   	nop
80100f14:	eb 10                	jmp    80100f26 <exec+0x3d0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f16:	90                   	nop
80100f17:	eb 0d                	jmp    80100f26 <exec+0x3d0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f19:	90                   	nop
80100f1a:	eb 0a                	jmp    80100f26 <exec+0x3d0>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100f1c:	90                   	nop
80100f1d:	eb 07                	jmp    80100f26 <exec+0x3d0>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f1f:	90                   	nop
80100f20:	eb 04                	jmp    80100f26 <exec+0x3d0>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f22:	90                   	nop
80100f23:	eb 01                	jmp    80100f26 <exec+0x3d0>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f25:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f26:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f2a:	74 0e                	je     80100f3a <exec+0x3e4>
    freevm(pgdir);
80100f2c:	83 ec 0c             	sub    $0xc,%esp
80100f2f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f32:	e8 dc 72 00 00       	call   80108213 <freevm>
80100f37:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f3a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f3e:	74 13                	je     80100f53 <exec+0x3fd>
    iunlockput(ip);
80100f40:	83 ec 0c             	sub    $0xc,%esp
80100f43:	ff 75 d8             	pushl  -0x28(%ebp)
80100f46:	e8 c4 0c 00 00       	call   80101c0f <iunlockput>
80100f4b:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f4e:	e8 6b 26 00 00       	call   801035be <end_op>
  }
  return -1;
80100f53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f58:	c9                   	leave  
80100f59:	c3                   	ret    

80100f5a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f5a:	55                   	push   %ebp
80100f5b:	89 e5                	mov    %esp,%ebp
80100f5d:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f60:	83 ec 08             	sub    $0x8,%esp
80100f63:	68 61 85 10 80       	push   $0x80108561
80100f68:	68 40 08 11 80       	push   $0x80110840
80100f6d:	e8 50 40 00 00       	call   80104fc2 <initlock>
80100f72:	83 c4 10             	add    $0x10,%esp
}
80100f75:	90                   	nop
80100f76:	c9                   	leave  
80100f77:	c3                   	ret    

80100f78 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f78:	55                   	push   %ebp
80100f79:	89 e5                	mov    %esp,%ebp
80100f7b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f7e:	83 ec 0c             	sub    $0xc,%esp
80100f81:	68 40 08 11 80       	push   $0x80110840
80100f86:	e8 59 40 00 00       	call   80104fe4 <acquire>
80100f8b:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f8e:	c7 45 f4 74 08 11 80 	movl   $0x80110874,-0xc(%ebp)
80100f95:	eb 2d                	jmp    80100fc4 <filealloc+0x4c>
    if(f->ref == 0){
80100f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f9a:	8b 40 04             	mov    0x4(%eax),%eax
80100f9d:	85 c0                	test   %eax,%eax
80100f9f:	75 1f                	jne    80100fc0 <filealloc+0x48>
      f->ref = 1;
80100fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa4:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100fab:	83 ec 0c             	sub    $0xc,%esp
80100fae:	68 40 08 11 80       	push   $0x80110840
80100fb3:	e8 93 40 00 00       	call   8010504b <release>
80100fb8:	83 c4 10             	add    $0x10,%esp
      return f;
80100fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fbe:	eb 23                	jmp    80100fe3 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fc0:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fc4:	b8 d4 11 11 80       	mov    $0x801111d4,%eax
80100fc9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100fcc:	72 c9                	jb     80100f97 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fce:	83 ec 0c             	sub    $0xc,%esp
80100fd1:	68 40 08 11 80       	push   $0x80110840
80100fd6:	e8 70 40 00 00       	call   8010504b <release>
80100fdb:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fde:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fe3:	c9                   	leave  
80100fe4:	c3                   	ret    

80100fe5 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fe5:	55                   	push   %ebp
80100fe6:	89 e5                	mov    %esp,%ebp
80100fe8:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80100feb:	83 ec 0c             	sub    $0xc,%esp
80100fee:	68 40 08 11 80       	push   $0x80110840
80100ff3:	e8 ec 3f 00 00       	call   80104fe4 <acquire>
80100ff8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80100ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffe:	8b 40 04             	mov    0x4(%eax),%eax
80101001:	85 c0                	test   %eax,%eax
80101003:	7f 0d                	jg     80101012 <filedup+0x2d>
    panic("filedup");
80101005:	83 ec 0c             	sub    $0xc,%esp
80101008:	68 68 85 10 80       	push   $0x80108568
8010100d:	e8 54 f5 ff ff       	call   80100566 <panic>
  f->ref++;
80101012:	8b 45 08             	mov    0x8(%ebp),%eax
80101015:	8b 40 04             	mov    0x4(%eax),%eax
80101018:	8d 50 01             	lea    0x1(%eax),%edx
8010101b:	8b 45 08             	mov    0x8(%ebp),%eax
8010101e:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101021:	83 ec 0c             	sub    $0xc,%esp
80101024:	68 40 08 11 80       	push   $0x80110840
80101029:	e8 1d 40 00 00       	call   8010504b <release>
8010102e:	83 c4 10             	add    $0x10,%esp
  return f;
80101031:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101034:	c9                   	leave  
80101035:	c3                   	ret    

80101036 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101036:	55                   	push   %ebp
80101037:	89 e5                	mov    %esp,%ebp
80101039:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
8010103c:	83 ec 0c             	sub    $0xc,%esp
8010103f:	68 40 08 11 80       	push   $0x80110840
80101044:	e8 9b 3f 00 00       	call   80104fe4 <acquire>
80101049:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010104c:	8b 45 08             	mov    0x8(%ebp),%eax
8010104f:	8b 40 04             	mov    0x4(%eax),%eax
80101052:	85 c0                	test   %eax,%eax
80101054:	7f 0d                	jg     80101063 <fileclose+0x2d>
    panic("fileclose");
80101056:	83 ec 0c             	sub    $0xc,%esp
80101059:	68 70 85 10 80       	push   $0x80108570
8010105e:	e8 03 f5 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
80101063:	8b 45 08             	mov    0x8(%ebp),%eax
80101066:	8b 40 04             	mov    0x4(%eax),%eax
80101069:	8d 50 ff             	lea    -0x1(%eax),%edx
8010106c:	8b 45 08             	mov    0x8(%ebp),%eax
8010106f:	89 50 04             	mov    %edx,0x4(%eax)
80101072:	8b 45 08             	mov    0x8(%ebp),%eax
80101075:	8b 40 04             	mov    0x4(%eax),%eax
80101078:	85 c0                	test   %eax,%eax
8010107a:	7e 15                	jle    80101091 <fileclose+0x5b>
    release(&ftable.lock);
8010107c:	83 ec 0c             	sub    $0xc,%esp
8010107f:	68 40 08 11 80       	push   $0x80110840
80101084:	e8 c2 3f 00 00       	call   8010504b <release>
80101089:	83 c4 10             	add    $0x10,%esp
8010108c:	e9 8b 00 00 00       	jmp    8010111c <fileclose+0xe6>
    return;
  }
  ff = *f;
80101091:	8b 45 08             	mov    0x8(%ebp),%eax
80101094:	8b 10                	mov    (%eax),%edx
80101096:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101099:	8b 50 04             	mov    0x4(%eax),%edx
8010109c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010109f:	8b 50 08             	mov    0x8(%eax),%edx
801010a2:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010a5:	8b 50 0c             	mov    0xc(%eax),%edx
801010a8:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010ab:	8b 50 10             	mov    0x10(%eax),%edx
801010ae:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010b1:	8b 40 14             	mov    0x14(%eax),%eax
801010b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010b7:	8b 45 08             	mov    0x8(%ebp),%eax
801010ba:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010c1:	8b 45 08             	mov    0x8(%ebp),%eax
801010c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010ca:	83 ec 0c             	sub    $0xc,%esp
801010cd:	68 40 08 11 80       	push   $0x80110840
801010d2:	e8 74 3f 00 00       	call   8010504b <release>
801010d7:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801010da:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010dd:	83 f8 01             	cmp    $0x1,%eax
801010e0:	75 19                	jne    801010fb <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801010e2:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801010e6:	0f be d0             	movsbl %al,%edx
801010e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801010ec:	83 ec 08             	sub    $0x8,%esp
801010ef:	52                   	push   %edx
801010f0:	50                   	push   %eax
801010f1:	e8 83 30 00 00       	call   80104179 <pipeclose>
801010f6:	83 c4 10             	add    $0x10,%esp
801010f9:	eb 21                	jmp    8010111c <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801010fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010fe:	83 f8 02             	cmp    $0x2,%eax
80101101:	75 19                	jne    8010111c <fileclose+0xe6>
    begin_op();
80101103:	e8 2a 24 00 00       	call   80103532 <begin_op>
    iput(ff.ip);
80101108:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010110b:	83 ec 0c             	sub    $0xc,%esp
8010110e:	50                   	push   %eax
8010110f:	e8 0b 0a 00 00       	call   80101b1f <iput>
80101114:	83 c4 10             	add    $0x10,%esp
    end_op();
80101117:	e8 a2 24 00 00       	call   801035be <end_op>
  }
}
8010111c:	c9                   	leave  
8010111d:	c3                   	ret    

8010111e <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010111e:	55                   	push   %ebp
8010111f:	89 e5                	mov    %esp,%ebp
80101121:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101124:	8b 45 08             	mov    0x8(%ebp),%eax
80101127:	8b 00                	mov    (%eax),%eax
80101129:	83 f8 02             	cmp    $0x2,%eax
8010112c:	75 40                	jne    8010116e <filestat+0x50>
    ilock(f->ip);
8010112e:	8b 45 08             	mov    0x8(%ebp),%eax
80101131:	8b 40 10             	mov    0x10(%eax),%eax
80101134:	83 ec 0c             	sub    $0xc,%esp
80101137:	50                   	push   %eax
80101138:	e8 12 08 00 00       	call   8010194f <ilock>
8010113d:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101140:	8b 45 08             	mov    0x8(%ebp),%eax
80101143:	8b 40 10             	mov    0x10(%eax),%eax
80101146:	83 ec 08             	sub    $0x8,%esp
80101149:	ff 75 0c             	pushl  0xc(%ebp)
8010114c:	50                   	push   %eax
8010114d:	e8 25 0d 00 00       	call   80101e77 <stati>
80101152:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101155:	8b 45 08             	mov    0x8(%ebp),%eax
80101158:	8b 40 10             	mov    0x10(%eax),%eax
8010115b:	83 ec 0c             	sub    $0xc,%esp
8010115e:	50                   	push   %eax
8010115f:	e8 49 09 00 00       	call   80101aad <iunlock>
80101164:	83 c4 10             	add    $0x10,%esp
    return 0;
80101167:	b8 00 00 00 00       	mov    $0x0,%eax
8010116c:	eb 05                	jmp    80101173 <filestat+0x55>
  }
  return -1;
8010116e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101173:	c9                   	leave  
80101174:	c3                   	ret    

80101175 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101175:	55                   	push   %ebp
80101176:	89 e5                	mov    %esp,%ebp
80101178:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010117b:	8b 45 08             	mov    0x8(%ebp),%eax
8010117e:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101182:	84 c0                	test   %al,%al
80101184:	75 0a                	jne    80101190 <fileread+0x1b>
    return -1;
80101186:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010118b:	e9 9b 00 00 00       	jmp    8010122b <fileread+0xb6>
  if(f->type == FD_PIPE)
80101190:	8b 45 08             	mov    0x8(%ebp),%eax
80101193:	8b 00                	mov    (%eax),%eax
80101195:	83 f8 01             	cmp    $0x1,%eax
80101198:	75 1a                	jne    801011b4 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
8010119a:	8b 45 08             	mov    0x8(%ebp),%eax
8010119d:	8b 40 0c             	mov    0xc(%eax),%eax
801011a0:	83 ec 04             	sub    $0x4,%esp
801011a3:	ff 75 10             	pushl  0x10(%ebp)
801011a6:	ff 75 0c             	pushl  0xc(%ebp)
801011a9:	50                   	push   %eax
801011aa:	e8 72 31 00 00       	call   80104321 <piperead>
801011af:	83 c4 10             	add    $0x10,%esp
801011b2:	eb 77                	jmp    8010122b <fileread+0xb6>
  if(f->type == FD_INODE){
801011b4:	8b 45 08             	mov    0x8(%ebp),%eax
801011b7:	8b 00                	mov    (%eax),%eax
801011b9:	83 f8 02             	cmp    $0x2,%eax
801011bc:	75 60                	jne    8010121e <fileread+0xa9>
    ilock(f->ip);
801011be:	8b 45 08             	mov    0x8(%ebp),%eax
801011c1:	8b 40 10             	mov    0x10(%eax),%eax
801011c4:	83 ec 0c             	sub    $0xc,%esp
801011c7:	50                   	push   %eax
801011c8:	e8 82 07 00 00       	call   8010194f <ilock>
801011cd:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011d3:	8b 45 08             	mov    0x8(%ebp),%eax
801011d6:	8b 50 14             	mov    0x14(%eax),%edx
801011d9:	8b 45 08             	mov    0x8(%ebp),%eax
801011dc:	8b 40 10             	mov    0x10(%eax),%eax
801011df:	51                   	push   %ecx
801011e0:	52                   	push   %edx
801011e1:	ff 75 0c             	pushl  0xc(%ebp)
801011e4:	50                   	push   %eax
801011e5:	e8 d3 0c 00 00       	call   80101ebd <readi>
801011ea:	83 c4 10             	add    $0x10,%esp
801011ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801011f4:	7e 11                	jle    80101207 <fileread+0x92>
      f->off += r;
801011f6:	8b 45 08             	mov    0x8(%ebp),%eax
801011f9:	8b 50 14             	mov    0x14(%eax),%edx
801011fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011ff:	01 c2                	add    %eax,%edx
80101201:	8b 45 08             	mov    0x8(%ebp),%eax
80101204:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101207:	8b 45 08             	mov    0x8(%ebp),%eax
8010120a:	8b 40 10             	mov    0x10(%eax),%eax
8010120d:	83 ec 0c             	sub    $0xc,%esp
80101210:	50                   	push   %eax
80101211:	e8 97 08 00 00       	call   80101aad <iunlock>
80101216:	83 c4 10             	add    $0x10,%esp
    return r;
80101219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010121c:	eb 0d                	jmp    8010122b <fileread+0xb6>
  }
  panic("fileread");
8010121e:	83 ec 0c             	sub    $0xc,%esp
80101221:	68 7a 85 10 80       	push   $0x8010857a
80101226:	e8 3b f3 ff ff       	call   80100566 <panic>
}
8010122b:	c9                   	leave  
8010122c:	c3                   	ret    

8010122d <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010122d:	55                   	push   %ebp
8010122e:	89 e5                	mov    %esp,%ebp
80101230:	53                   	push   %ebx
80101231:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101234:	8b 45 08             	mov    0x8(%ebp),%eax
80101237:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010123b:	84 c0                	test   %al,%al
8010123d:	75 0a                	jne    80101249 <filewrite+0x1c>
    return -1;
8010123f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101244:	e9 1b 01 00 00       	jmp    80101364 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101249:	8b 45 08             	mov    0x8(%ebp),%eax
8010124c:	8b 00                	mov    (%eax),%eax
8010124e:	83 f8 01             	cmp    $0x1,%eax
80101251:	75 1d                	jne    80101270 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101253:	8b 45 08             	mov    0x8(%ebp),%eax
80101256:	8b 40 0c             	mov    0xc(%eax),%eax
80101259:	83 ec 04             	sub    $0x4,%esp
8010125c:	ff 75 10             	pushl  0x10(%ebp)
8010125f:	ff 75 0c             	pushl  0xc(%ebp)
80101262:	50                   	push   %eax
80101263:	e8 bb 2f 00 00       	call   80104223 <pipewrite>
80101268:	83 c4 10             	add    $0x10,%esp
8010126b:	e9 f4 00 00 00       	jmp    80101364 <filewrite+0x137>
  if(f->type == FD_INODE){
80101270:	8b 45 08             	mov    0x8(%ebp),%eax
80101273:	8b 00                	mov    (%eax),%eax
80101275:	83 f8 02             	cmp    $0x2,%eax
80101278:	0f 85 d9 00 00 00    	jne    80101357 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010127e:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101285:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010128c:	e9 a3 00 00 00       	jmp    80101334 <filewrite+0x107>
      int n1 = n - i;
80101291:	8b 45 10             	mov    0x10(%ebp),%eax
80101294:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101297:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010129a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010129d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012a0:	7e 06                	jle    801012a8 <filewrite+0x7b>
        n1 = max;
801012a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012a5:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012a8:	e8 85 22 00 00       	call   80103532 <begin_op>
      ilock(f->ip);
801012ad:	8b 45 08             	mov    0x8(%ebp),%eax
801012b0:	8b 40 10             	mov    0x10(%eax),%eax
801012b3:	83 ec 0c             	sub    $0xc,%esp
801012b6:	50                   	push   %eax
801012b7:	e8 93 06 00 00       	call   8010194f <ilock>
801012bc:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012bf:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012c2:	8b 45 08             	mov    0x8(%ebp),%eax
801012c5:	8b 50 14             	mov    0x14(%eax),%edx
801012c8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801012ce:	01 c3                	add    %eax,%ebx
801012d0:	8b 45 08             	mov    0x8(%ebp),%eax
801012d3:	8b 40 10             	mov    0x10(%eax),%eax
801012d6:	51                   	push   %ecx
801012d7:	52                   	push   %edx
801012d8:	53                   	push   %ebx
801012d9:	50                   	push   %eax
801012da:	e8 35 0d 00 00       	call   80102014 <writei>
801012df:	83 c4 10             	add    $0x10,%esp
801012e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012e5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012e9:	7e 11                	jle    801012fc <filewrite+0xcf>
        f->off += r;
801012eb:	8b 45 08             	mov    0x8(%ebp),%eax
801012ee:	8b 50 14             	mov    0x14(%eax),%edx
801012f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012f4:	01 c2                	add    %eax,%edx
801012f6:	8b 45 08             	mov    0x8(%ebp),%eax
801012f9:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012fc:	8b 45 08             	mov    0x8(%ebp),%eax
801012ff:	8b 40 10             	mov    0x10(%eax),%eax
80101302:	83 ec 0c             	sub    $0xc,%esp
80101305:	50                   	push   %eax
80101306:	e8 a2 07 00 00       	call   80101aad <iunlock>
8010130b:	83 c4 10             	add    $0x10,%esp
      end_op();
8010130e:	e8 ab 22 00 00       	call   801035be <end_op>

      if(r < 0)
80101313:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101317:	78 29                	js     80101342 <filewrite+0x115>
        break;
      if(r != n1)
80101319:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010131c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010131f:	74 0d                	je     8010132e <filewrite+0x101>
        panic("short filewrite");
80101321:	83 ec 0c             	sub    $0xc,%esp
80101324:	68 83 85 10 80       	push   $0x80108583
80101329:	e8 38 f2 ff ff       	call   80100566 <panic>
      i += r;
8010132e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101331:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101337:	3b 45 10             	cmp    0x10(%ebp),%eax
8010133a:	0f 8c 51 ff ff ff    	jl     80101291 <filewrite+0x64>
80101340:	eb 01                	jmp    80101343 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
80101342:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101346:	3b 45 10             	cmp    0x10(%ebp),%eax
80101349:	75 05                	jne    80101350 <filewrite+0x123>
8010134b:	8b 45 10             	mov    0x10(%ebp),%eax
8010134e:	eb 14                	jmp    80101364 <filewrite+0x137>
80101350:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101355:	eb 0d                	jmp    80101364 <filewrite+0x137>
  }
  panic("filewrite");
80101357:	83 ec 0c             	sub    $0xc,%esp
8010135a:	68 93 85 10 80       	push   $0x80108593
8010135f:	e8 02 f2 ff ff       	call   80100566 <panic>
}
80101364:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101367:	c9                   	leave  
80101368:	c3                   	ret    

80101369 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101369:	55                   	push   %ebp
8010136a:	89 e5                	mov    %esp,%ebp
8010136c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010136f:	8b 45 08             	mov    0x8(%ebp),%eax
80101372:	83 ec 08             	sub    $0x8,%esp
80101375:	6a 01                	push   $0x1
80101377:	50                   	push   %eax
80101378:	e8 39 ee ff ff       	call   801001b6 <bread>
8010137d:	83 c4 10             	add    $0x10,%esp
80101380:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101386:	83 c0 18             	add    $0x18,%eax
80101389:	83 ec 04             	sub    $0x4,%esp
8010138c:	6a 1c                	push   $0x1c
8010138e:	50                   	push   %eax
8010138f:	ff 75 0c             	pushl  0xc(%ebp)
80101392:	e8 6f 3f 00 00       	call   80105306 <memmove>
80101397:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010139a:	83 ec 0c             	sub    $0xc,%esp
8010139d:	ff 75 f4             	pushl  -0xc(%ebp)
801013a0:	e8 89 ee ff ff       	call   8010022e <brelse>
801013a5:	83 c4 10             	add    $0x10,%esp
}
801013a8:	90                   	nop
801013a9:	c9                   	leave  
801013aa:	c3                   	ret    

801013ab <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013ab:	55                   	push   %ebp
801013ac:	89 e5                	mov    %esp,%ebp
801013ae:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801013b4:	8b 45 08             	mov    0x8(%ebp),%eax
801013b7:	83 ec 08             	sub    $0x8,%esp
801013ba:	52                   	push   %edx
801013bb:	50                   	push   %eax
801013bc:	e8 f5 ed ff ff       	call   801001b6 <bread>
801013c1:	83 c4 10             	add    $0x10,%esp
801013c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801013c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ca:	83 c0 18             	add    $0x18,%eax
801013cd:	83 ec 04             	sub    $0x4,%esp
801013d0:	68 00 02 00 00       	push   $0x200
801013d5:	6a 00                	push   $0x0
801013d7:	50                   	push   %eax
801013d8:	e8 6a 3e 00 00       	call   80105247 <memset>
801013dd:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801013e0:	83 ec 0c             	sub    $0xc,%esp
801013e3:	ff 75 f4             	pushl  -0xc(%ebp)
801013e6:	e8 7f 23 00 00       	call   8010376a <log_write>
801013eb:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013ee:	83 ec 0c             	sub    $0xc,%esp
801013f1:	ff 75 f4             	pushl  -0xc(%ebp)
801013f4:	e8 35 ee ff ff       	call   8010022e <brelse>
801013f9:	83 c4 10             	add    $0x10,%esp
}
801013fc:	90                   	nop
801013fd:	c9                   	leave  
801013fe:	c3                   	ret    

801013ff <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013ff:	55                   	push   %ebp
80101400:	89 e5                	mov    %esp,%ebp
80101402:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101405:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010140c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101413:	e9 13 01 00 00       	jmp    8010152b <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
80101418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010141b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101421:	85 c0                	test   %eax,%eax
80101423:	0f 48 c2             	cmovs  %edx,%eax
80101426:	c1 f8 0c             	sar    $0xc,%eax
80101429:	89 c2                	mov    %eax,%edx
8010142b:	a1 58 12 11 80       	mov    0x80111258,%eax
80101430:	01 d0                	add    %edx,%eax
80101432:	83 ec 08             	sub    $0x8,%esp
80101435:	50                   	push   %eax
80101436:	ff 75 08             	pushl  0x8(%ebp)
80101439:	e8 78 ed ff ff       	call   801001b6 <bread>
8010143e:	83 c4 10             	add    $0x10,%esp
80101441:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101444:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010144b:	e9 a6 00 00 00       	jmp    801014f6 <balloc+0xf7>
      m = 1 << (bi % 8);
80101450:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101453:	99                   	cltd   
80101454:	c1 ea 1d             	shr    $0x1d,%edx
80101457:	01 d0                	add    %edx,%eax
80101459:	83 e0 07             	and    $0x7,%eax
8010145c:	29 d0                	sub    %edx,%eax
8010145e:	ba 01 00 00 00       	mov    $0x1,%edx
80101463:	89 c1                	mov    %eax,%ecx
80101465:	d3 e2                	shl    %cl,%edx
80101467:	89 d0                	mov    %edx,%eax
80101469:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010146c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010146f:	8d 50 07             	lea    0x7(%eax),%edx
80101472:	85 c0                	test   %eax,%eax
80101474:	0f 48 c2             	cmovs  %edx,%eax
80101477:	c1 f8 03             	sar    $0x3,%eax
8010147a:	89 c2                	mov    %eax,%edx
8010147c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010147f:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101484:	0f b6 c0             	movzbl %al,%eax
80101487:	23 45 e8             	and    -0x18(%ebp),%eax
8010148a:	85 c0                	test   %eax,%eax
8010148c:	75 64                	jne    801014f2 <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
8010148e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101491:	8d 50 07             	lea    0x7(%eax),%edx
80101494:	85 c0                	test   %eax,%eax
80101496:	0f 48 c2             	cmovs  %edx,%eax
80101499:	c1 f8 03             	sar    $0x3,%eax
8010149c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010149f:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014a4:	89 d1                	mov    %edx,%ecx
801014a6:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014a9:	09 ca                	or     %ecx,%edx
801014ab:	89 d1                	mov    %edx,%ecx
801014ad:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014b0:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014b4:	83 ec 0c             	sub    $0xc,%esp
801014b7:	ff 75 ec             	pushl  -0x14(%ebp)
801014ba:	e8 ab 22 00 00       	call   8010376a <log_write>
801014bf:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801014c2:	83 ec 0c             	sub    $0xc,%esp
801014c5:	ff 75 ec             	pushl  -0x14(%ebp)
801014c8:	e8 61 ed ff ff       	call   8010022e <brelse>
801014cd:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801014d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d6:	01 c2                	add    %eax,%edx
801014d8:	8b 45 08             	mov    0x8(%ebp),%eax
801014db:	83 ec 08             	sub    $0x8,%esp
801014de:	52                   	push   %edx
801014df:	50                   	push   %eax
801014e0:	e8 c6 fe ff ff       	call   801013ab <bzero>
801014e5:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801014e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ee:	01 d0                	add    %edx,%eax
801014f0:	eb 57                	jmp    80101549 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014f2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801014f6:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014fd:	7f 17                	jg     80101516 <balloc+0x117>
801014ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101502:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101505:	01 d0                	add    %edx,%eax
80101507:	89 c2                	mov    %eax,%edx
80101509:	a1 40 12 11 80       	mov    0x80111240,%eax
8010150e:	39 c2                	cmp    %eax,%edx
80101510:	0f 82 3a ff ff ff    	jb     80101450 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101516:	83 ec 0c             	sub    $0xc,%esp
80101519:	ff 75 ec             	pushl  -0x14(%ebp)
8010151c:	e8 0d ed ff ff       	call   8010022e <brelse>
80101521:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101524:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010152b:	8b 15 40 12 11 80    	mov    0x80111240,%edx
80101531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101534:	39 c2                	cmp    %eax,%edx
80101536:	0f 87 dc fe ff ff    	ja     80101418 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010153c:	83 ec 0c             	sub    $0xc,%esp
8010153f:	68 a0 85 10 80       	push   $0x801085a0
80101544:	e8 1d f0 ff ff       	call   80100566 <panic>
}
80101549:	c9                   	leave  
8010154a:	c3                   	ret    

8010154b <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010154b:	55                   	push   %ebp
8010154c:	89 e5                	mov    %esp,%ebp
8010154e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101551:	83 ec 08             	sub    $0x8,%esp
80101554:	68 40 12 11 80       	push   $0x80111240
80101559:	ff 75 08             	pushl  0x8(%ebp)
8010155c:	e8 08 fe ff ff       	call   80101369 <readsb>
80101561:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101564:	8b 45 0c             	mov    0xc(%ebp),%eax
80101567:	c1 e8 0c             	shr    $0xc,%eax
8010156a:	89 c2                	mov    %eax,%edx
8010156c:	a1 58 12 11 80       	mov    0x80111258,%eax
80101571:	01 c2                	add    %eax,%edx
80101573:	8b 45 08             	mov    0x8(%ebp),%eax
80101576:	83 ec 08             	sub    $0x8,%esp
80101579:	52                   	push   %edx
8010157a:	50                   	push   %eax
8010157b:	e8 36 ec ff ff       	call   801001b6 <bread>
80101580:	83 c4 10             	add    $0x10,%esp
80101583:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101586:	8b 45 0c             	mov    0xc(%ebp),%eax
80101589:	25 ff 0f 00 00       	and    $0xfff,%eax
8010158e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101591:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101594:	99                   	cltd   
80101595:	c1 ea 1d             	shr    $0x1d,%edx
80101598:	01 d0                	add    %edx,%eax
8010159a:	83 e0 07             	and    $0x7,%eax
8010159d:	29 d0                	sub    %edx,%eax
8010159f:	ba 01 00 00 00       	mov    $0x1,%edx
801015a4:	89 c1                	mov    %eax,%ecx
801015a6:	d3 e2                	shl    %cl,%edx
801015a8:	89 d0                	mov    %edx,%eax
801015aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b0:	8d 50 07             	lea    0x7(%eax),%edx
801015b3:	85 c0                	test   %eax,%eax
801015b5:	0f 48 c2             	cmovs  %edx,%eax
801015b8:	c1 f8 03             	sar    $0x3,%eax
801015bb:	89 c2                	mov    %eax,%edx
801015bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015c0:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015c5:	0f b6 c0             	movzbl %al,%eax
801015c8:	23 45 ec             	and    -0x14(%ebp),%eax
801015cb:	85 c0                	test   %eax,%eax
801015cd:	75 0d                	jne    801015dc <bfree+0x91>
    panic("freeing free block");
801015cf:	83 ec 0c             	sub    $0xc,%esp
801015d2:	68 b6 85 10 80       	push   $0x801085b6
801015d7:	e8 8a ef ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
801015dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015df:	8d 50 07             	lea    0x7(%eax),%edx
801015e2:	85 c0                	test   %eax,%eax
801015e4:	0f 48 c2             	cmovs  %edx,%eax
801015e7:	c1 f8 03             	sar    $0x3,%eax
801015ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015ed:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801015f2:	89 d1                	mov    %edx,%ecx
801015f4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015f7:	f7 d2                	not    %edx
801015f9:	21 ca                	and    %ecx,%edx
801015fb:	89 d1                	mov    %edx,%ecx
801015fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101600:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101604:	83 ec 0c             	sub    $0xc,%esp
80101607:	ff 75 f4             	pushl  -0xc(%ebp)
8010160a:	e8 5b 21 00 00       	call   8010376a <log_write>
8010160f:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101612:	83 ec 0c             	sub    $0xc,%esp
80101615:	ff 75 f4             	pushl  -0xc(%ebp)
80101618:	e8 11 ec ff ff       	call   8010022e <brelse>
8010161d:	83 c4 10             	add    $0x10,%esp
}
80101620:	90                   	nop
80101621:	c9                   	leave  
80101622:	c3                   	ret    

80101623 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101623:	55                   	push   %ebp
80101624:	89 e5                	mov    %esp,%ebp
80101626:	57                   	push   %edi
80101627:	56                   	push   %esi
80101628:	53                   	push   %ebx
80101629:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
8010162c:	83 ec 08             	sub    $0x8,%esp
8010162f:	68 c9 85 10 80       	push   $0x801085c9
80101634:	68 60 12 11 80       	push   $0x80111260
80101639:	e8 84 39 00 00       	call   80104fc2 <initlock>
8010163e:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80101641:	83 ec 08             	sub    $0x8,%esp
80101644:	68 40 12 11 80       	push   $0x80111240
80101649:	ff 75 08             	pushl  0x8(%ebp)
8010164c:	e8 18 fd ff ff       	call   80101369 <readsb>
80101651:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101654:	a1 58 12 11 80       	mov    0x80111258,%eax
80101659:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010165c:	8b 3d 54 12 11 80    	mov    0x80111254,%edi
80101662:	8b 35 50 12 11 80    	mov    0x80111250,%esi
80101668:	8b 1d 4c 12 11 80    	mov    0x8011124c,%ebx
8010166e:	8b 0d 48 12 11 80    	mov    0x80111248,%ecx
80101674:	8b 15 44 12 11 80    	mov    0x80111244,%edx
8010167a:	a1 40 12 11 80       	mov    0x80111240,%eax
8010167f:	ff 75 e4             	pushl  -0x1c(%ebp)
80101682:	57                   	push   %edi
80101683:	56                   	push   %esi
80101684:	53                   	push   %ebx
80101685:	51                   	push   %ecx
80101686:	52                   	push   %edx
80101687:	50                   	push   %eax
80101688:	68 d0 85 10 80       	push   $0x801085d0
8010168d:	e8 34 ed ff ff       	call   801003c6 <cprintf>
80101692:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
80101695:	90                   	nop
80101696:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101699:	5b                   	pop    %ebx
8010169a:	5e                   	pop    %esi
8010169b:	5f                   	pop    %edi
8010169c:	5d                   	pop    %ebp
8010169d:	c3                   	ret    

8010169e <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
8010169e:	55                   	push   %ebp
8010169f:	89 e5                	mov    %esp,%ebp
801016a1:	83 ec 28             	sub    $0x28,%esp
801016a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801016a7:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016ab:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016b2:	e9 9e 00 00 00       	jmp    80101755 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016ba:	c1 e8 03             	shr    $0x3,%eax
801016bd:	89 c2                	mov    %eax,%edx
801016bf:	a1 54 12 11 80       	mov    0x80111254,%eax
801016c4:	01 d0                	add    %edx,%eax
801016c6:	83 ec 08             	sub    $0x8,%esp
801016c9:	50                   	push   %eax
801016ca:	ff 75 08             	pushl  0x8(%ebp)
801016cd:	e8 e4 ea ff ff       	call   801001b6 <bread>
801016d2:	83 c4 10             	add    $0x10,%esp
801016d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801016d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016db:	8d 50 18             	lea    0x18(%eax),%edx
801016de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016e1:	83 e0 07             	and    $0x7,%eax
801016e4:	c1 e0 06             	shl    $0x6,%eax
801016e7:	01 d0                	add    %edx,%eax
801016e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801016ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016ef:	0f b7 00             	movzwl (%eax),%eax
801016f2:	66 85 c0             	test   %ax,%ax
801016f5:	75 4c                	jne    80101743 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
801016f7:	83 ec 04             	sub    $0x4,%esp
801016fa:	6a 40                	push   $0x40
801016fc:	6a 00                	push   $0x0
801016fe:	ff 75 ec             	pushl  -0x14(%ebp)
80101701:	e8 41 3b 00 00       	call   80105247 <memset>
80101706:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101709:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010170c:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101710:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101713:	83 ec 0c             	sub    $0xc,%esp
80101716:	ff 75 f0             	pushl  -0x10(%ebp)
80101719:	e8 4c 20 00 00       	call   8010376a <log_write>
8010171e:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101721:	83 ec 0c             	sub    $0xc,%esp
80101724:	ff 75 f0             	pushl  -0x10(%ebp)
80101727:	e8 02 eb ff ff       	call   8010022e <brelse>
8010172c:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010172f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101732:	83 ec 08             	sub    $0x8,%esp
80101735:	50                   	push   %eax
80101736:	ff 75 08             	pushl  0x8(%ebp)
80101739:	e8 f8 00 00 00       	call   80101836 <iget>
8010173e:	83 c4 10             	add    $0x10,%esp
80101741:	eb 30                	jmp    80101773 <ialloc+0xd5>
    }
    brelse(bp);
80101743:	83 ec 0c             	sub    $0xc,%esp
80101746:	ff 75 f0             	pushl  -0x10(%ebp)
80101749:	e8 e0 ea ff ff       	call   8010022e <brelse>
8010174e:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101751:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101755:	8b 15 48 12 11 80    	mov    0x80111248,%edx
8010175b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175e:	39 c2                	cmp    %eax,%edx
80101760:	0f 87 51 ff ff ff    	ja     801016b7 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101766:	83 ec 0c             	sub    $0xc,%esp
80101769:	68 23 86 10 80       	push   $0x80108623
8010176e:	e8 f3 ed ff ff       	call   80100566 <panic>
}
80101773:	c9                   	leave  
80101774:	c3                   	ret    

80101775 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101775:	55                   	push   %ebp
80101776:	89 e5                	mov    %esp,%ebp
80101778:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010177b:	8b 45 08             	mov    0x8(%ebp),%eax
8010177e:	8b 40 04             	mov    0x4(%eax),%eax
80101781:	c1 e8 03             	shr    $0x3,%eax
80101784:	89 c2                	mov    %eax,%edx
80101786:	a1 54 12 11 80       	mov    0x80111254,%eax
8010178b:	01 c2                	add    %eax,%edx
8010178d:	8b 45 08             	mov    0x8(%ebp),%eax
80101790:	8b 00                	mov    (%eax),%eax
80101792:	83 ec 08             	sub    $0x8,%esp
80101795:	52                   	push   %edx
80101796:	50                   	push   %eax
80101797:	e8 1a ea ff ff       	call   801001b6 <bread>
8010179c:	83 c4 10             	add    $0x10,%esp
8010179f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a5:	8d 50 18             	lea    0x18(%eax),%edx
801017a8:	8b 45 08             	mov    0x8(%ebp),%eax
801017ab:	8b 40 04             	mov    0x4(%eax),%eax
801017ae:	83 e0 07             	and    $0x7,%eax
801017b1:	c1 e0 06             	shl    $0x6,%eax
801017b4:	01 d0                	add    %edx,%eax
801017b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017b9:	8b 45 08             	mov    0x8(%ebp),%eax
801017bc:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017c3:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017c6:	8b 45 08             	mov    0x8(%ebp),%eax
801017c9:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801017cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017d0:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801017d4:	8b 45 08             	mov    0x8(%ebp),%eax
801017d7:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801017db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017de:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801017e2:	8b 45 08             	mov    0x8(%ebp),%eax
801017e5:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801017e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017ec:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801017f0:	8b 45 08             	mov    0x8(%ebp),%eax
801017f3:	8b 50 18             	mov    0x18(%eax),%edx
801017f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f9:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801017fc:	8b 45 08             	mov    0x8(%ebp),%eax
801017ff:	8d 50 1c             	lea    0x1c(%eax),%edx
80101802:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101805:	83 c0 0c             	add    $0xc,%eax
80101808:	83 ec 04             	sub    $0x4,%esp
8010180b:	6a 34                	push   $0x34
8010180d:	52                   	push   %edx
8010180e:	50                   	push   %eax
8010180f:	e8 f2 3a 00 00       	call   80105306 <memmove>
80101814:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101817:	83 ec 0c             	sub    $0xc,%esp
8010181a:	ff 75 f4             	pushl  -0xc(%ebp)
8010181d:	e8 48 1f 00 00       	call   8010376a <log_write>
80101822:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101825:	83 ec 0c             	sub    $0xc,%esp
80101828:	ff 75 f4             	pushl  -0xc(%ebp)
8010182b:	e8 fe e9 ff ff       	call   8010022e <brelse>
80101830:	83 c4 10             	add    $0x10,%esp
}
80101833:	90                   	nop
80101834:	c9                   	leave  
80101835:	c3                   	ret    

80101836 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101836:	55                   	push   %ebp
80101837:	89 e5                	mov    %esp,%ebp
80101839:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010183c:	83 ec 0c             	sub    $0xc,%esp
8010183f:	68 60 12 11 80       	push   $0x80111260
80101844:	e8 9b 37 00 00       	call   80104fe4 <acquire>
80101849:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
8010184c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101853:	c7 45 f4 94 12 11 80 	movl   $0x80111294,-0xc(%ebp)
8010185a:	eb 5d                	jmp    801018b9 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010185c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010185f:	8b 40 08             	mov    0x8(%eax),%eax
80101862:	85 c0                	test   %eax,%eax
80101864:	7e 39                	jle    8010189f <iget+0x69>
80101866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101869:	8b 00                	mov    (%eax),%eax
8010186b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010186e:	75 2f                	jne    8010189f <iget+0x69>
80101870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101873:	8b 40 04             	mov    0x4(%eax),%eax
80101876:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101879:	75 24                	jne    8010189f <iget+0x69>
      ip->ref++;
8010187b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187e:	8b 40 08             	mov    0x8(%eax),%eax
80101881:	8d 50 01             	lea    0x1(%eax),%edx
80101884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101887:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010188a:	83 ec 0c             	sub    $0xc,%esp
8010188d:	68 60 12 11 80       	push   $0x80111260
80101892:	e8 b4 37 00 00       	call   8010504b <release>
80101897:	83 c4 10             	add    $0x10,%esp
      return ip;
8010189a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010189d:	eb 74                	jmp    80101913 <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010189f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018a3:	75 10                	jne    801018b5 <iget+0x7f>
801018a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a8:	8b 40 08             	mov    0x8(%eax),%eax
801018ab:	85 c0                	test   %eax,%eax
801018ad:	75 06                	jne    801018b5 <iget+0x7f>
      empty = ip;
801018af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018b5:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018b9:	81 7d f4 34 22 11 80 	cmpl   $0x80112234,-0xc(%ebp)
801018c0:	72 9a                	jb     8010185c <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018c2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018c6:	75 0d                	jne    801018d5 <iget+0x9f>
    panic("iget: no inodes");
801018c8:	83 ec 0c             	sub    $0xc,%esp
801018cb:	68 35 86 10 80       	push   $0x80108635
801018d0:	e8 91 ec ff ff       	call   80100566 <panic>

  ip = empty;
801018d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801018db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018de:	8b 55 08             	mov    0x8(%ebp),%edx
801018e1:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801018e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e6:	8b 55 0c             	mov    0xc(%ebp),%edx
801018e9:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801018ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ef:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801018f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101900:	83 ec 0c             	sub    $0xc,%esp
80101903:	68 60 12 11 80       	push   $0x80111260
80101908:	e8 3e 37 00 00       	call   8010504b <release>
8010190d:	83 c4 10             	add    $0x10,%esp

  return ip;
80101910:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101913:	c9                   	leave  
80101914:	c3                   	ret    

80101915 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101915:	55                   	push   %ebp
80101916:	89 e5                	mov    %esp,%ebp
80101918:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
8010191b:	83 ec 0c             	sub    $0xc,%esp
8010191e:	68 60 12 11 80       	push   $0x80111260
80101923:	e8 bc 36 00 00       	call   80104fe4 <acquire>
80101928:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
8010192b:	8b 45 08             	mov    0x8(%ebp),%eax
8010192e:	8b 40 08             	mov    0x8(%eax),%eax
80101931:	8d 50 01             	lea    0x1(%eax),%edx
80101934:	8b 45 08             	mov    0x8(%ebp),%eax
80101937:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010193a:	83 ec 0c             	sub    $0xc,%esp
8010193d:	68 60 12 11 80       	push   $0x80111260
80101942:	e8 04 37 00 00       	call   8010504b <release>
80101947:	83 c4 10             	add    $0x10,%esp
  return ip;
8010194a:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010194d:	c9                   	leave  
8010194e:	c3                   	ret    

8010194f <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010194f:	55                   	push   %ebp
80101950:	89 e5                	mov    %esp,%ebp
80101952:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101955:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101959:	74 0a                	je     80101965 <ilock+0x16>
8010195b:	8b 45 08             	mov    0x8(%ebp),%eax
8010195e:	8b 40 08             	mov    0x8(%eax),%eax
80101961:	85 c0                	test   %eax,%eax
80101963:	7f 0d                	jg     80101972 <ilock+0x23>
    panic("ilock");
80101965:	83 ec 0c             	sub    $0xc,%esp
80101968:	68 45 86 10 80       	push   $0x80108645
8010196d:	e8 f4 eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101972:	83 ec 0c             	sub    $0xc,%esp
80101975:	68 60 12 11 80       	push   $0x80111260
8010197a:	e8 65 36 00 00       	call   80104fe4 <acquire>
8010197f:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101982:	eb 13                	jmp    80101997 <ilock+0x48>
    sleep(ip, &icache.lock);
80101984:	83 ec 08             	sub    $0x8,%esp
80101987:	68 60 12 11 80       	push   $0x80111260
8010198c:	ff 75 08             	pushl  0x8(%ebp)
8010198f:	e8 57 33 00 00       	call   80104ceb <sleep>
80101994:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101997:	8b 45 08             	mov    0x8(%ebp),%eax
8010199a:	8b 40 0c             	mov    0xc(%eax),%eax
8010199d:	83 e0 01             	and    $0x1,%eax
801019a0:	85 c0                	test   %eax,%eax
801019a2:	75 e0                	jne    80101984 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801019a4:	8b 45 08             	mov    0x8(%ebp),%eax
801019a7:	8b 40 0c             	mov    0xc(%eax),%eax
801019aa:	83 c8 01             	or     $0x1,%eax
801019ad:	89 c2                	mov    %eax,%edx
801019af:	8b 45 08             	mov    0x8(%ebp),%eax
801019b2:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019b5:	83 ec 0c             	sub    $0xc,%esp
801019b8:	68 60 12 11 80       	push   $0x80111260
801019bd:	e8 89 36 00 00       	call   8010504b <release>
801019c2:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
801019c5:	8b 45 08             	mov    0x8(%ebp),%eax
801019c8:	8b 40 0c             	mov    0xc(%eax),%eax
801019cb:	83 e0 02             	and    $0x2,%eax
801019ce:	85 c0                	test   %eax,%eax
801019d0:	0f 85 d4 00 00 00    	jne    80101aaa <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801019d6:	8b 45 08             	mov    0x8(%ebp),%eax
801019d9:	8b 40 04             	mov    0x4(%eax),%eax
801019dc:	c1 e8 03             	shr    $0x3,%eax
801019df:	89 c2                	mov    %eax,%edx
801019e1:	a1 54 12 11 80       	mov    0x80111254,%eax
801019e6:	01 c2                	add    %eax,%edx
801019e8:	8b 45 08             	mov    0x8(%ebp),%eax
801019eb:	8b 00                	mov    (%eax),%eax
801019ed:	83 ec 08             	sub    $0x8,%esp
801019f0:	52                   	push   %edx
801019f1:	50                   	push   %eax
801019f2:	e8 bf e7 ff ff       	call   801001b6 <bread>
801019f7:	83 c4 10             	add    $0x10,%esp
801019fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801019fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a00:	8d 50 18             	lea    0x18(%eax),%edx
80101a03:	8b 45 08             	mov    0x8(%ebp),%eax
80101a06:	8b 40 04             	mov    0x4(%eax),%eax
80101a09:	83 e0 07             	and    $0x7,%eax
80101a0c:	c1 e0 06             	shl    $0x6,%eax
80101a0f:	01 d0                	add    %edx,%eax
80101a11:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a17:	0f b7 10             	movzwl (%eax),%edx
80101a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1d:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a24:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a28:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2b:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a32:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a36:	8b 45 08             	mov    0x8(%ebp),%eax
80101a39:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a40:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a44:	8b 45 08             	mov    0x8(%ebp),%eax
80101a47:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a4e:	8b 50 08             	mov    0x8(%eax),%edx
80101a51:	8b 45 08             	mov    0x8(%ebp),%eax
80101a54:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5a:	8d 50 0c             	lea    0xc(%eax),%edx
80101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a60:	83 c0 1c             	add    $0x1c,%eax
80101a63:	83 ec 04             	sub    $0x4,%esp
80101a66:	6a 34                	push   $0x34
80101a68:	52                   	push   %edx
80101a69:	50                   	push   %eax
80101a6a:	e8 97 38 00 00       	call   80105306 <memmove>
80101a6f:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101a72:	83 ec 0c             	sub    $0xc,%esp
80101a75:	ff 75 f4             	pushl  -0xc(%ebp)
80101a78:	e8 b1 e7 ff ff       	call   8010022e <brelse>
80101a7d:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a80:	8b 45 08             	mov    0x8(%ebp),%eax
80101a83:	8b 40 0c             	mov    0xc(%eax),%eax
80101a86:	83 c8 02             	or     $0x2,%eax
80101a89:	89 c2                	mov    %eax,%edx
80101a8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8e:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101a91:	8b 45 08             	mov    0x8(%ebp),%eax
80101a94:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101a98:	66 85 c0             	test   %ax,%ax
80101a9b:	75 0d                	jne    80101aaa <ilock+0x15b>
      panic("ilock: no type");
80101a9d:	83 ec 0c             	sub    $0xc,%esp
80101aa0:	68 4b 86 10 80       	push   $0x8010864b
80101aa5:	e8 bc ea ff ff       	call   80100566 <panic>
  }
}
80101aaa:	90                   	nop
80101aab:	c9                   	leave  
80101aac:	c3                   	ret    

80101aad <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101aad:	55                   	push   %ebp
80101aae:	89 e5                	mov    %esp,%ebp
80101ab0:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101ab3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ab7:	74 17                	je     80101ad0 <iunlock+0x23>
80101ab9:	8b 45 08             	mov    0x8(%ebp),%eax
80101abc:	8b 40 0c             	mov    0xc(%eax),%eax
80101abf:	83 e0 01             	and    $0x1,%eax
80101ac2:	85 c0                	test   %eax,%eax
80101ac4:	74 0a                	je     80101ad0 <iunlock+0x23>
80101ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac9:	8b 40 08             	mov    0x8(%eax),%eax
80101acc:	85 c0                	test   %eax,%eax
80101ace:	7f 0d                	jg     80101add <iunlock+0x30>
    panic("iunlock");
80101ad0:	83 ec 0c             	sub    $0xc,%esp
80101ad3:	68 5a 86 10 80       	push   $0x8010865a
80101ad8:	e8 89 ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101add:	83 ec 0c             	sub    $0xc,%esp
80101ae0:	68 60 12 11 80       	push   $0x80111260
80101ae5:	e8 fa 34 00 00       	call   80104fe4 <acquire>
80101aea:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101aed:	8b 45 08             	mov    0x8(%ebp),%eax
80101af0:	8b 40 0c             	mov    0xc(%eax),%eax
80101af3:	83 e0 fe             	and    $0xfffffffe,%eax
80101af6:	89 c2                	mov    %eax,%edx
80101af8:	8b 45 08             	mov    0x8(%ebp),%eax
80101afb:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101afe:	83 ec 0c             	sub    $0xc,%esp
80101b01:	ff 75 08             	pushl  0x8(%ebp)
80101b04:	e8 cd 32 00 00       	call   80104dd6 <wakeup>
80101b09:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b0c:	83 ec 0c             	sub    $0xc,%esp
80101b0f:	68 60 12 11 80       	push   $0x80111260
80101b14:	e8 32 35 00 00       	call   8010504b <release>
80101b19:	83 c4 10             	add    $0x10,%esp
}
80101b1c:	90                   	nop
80101b1d:	c9                   	leave  
80101b1e:	c3                   	ret    

80101b1f <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b1f:	55                   	push   %ebp
80101b20:	89 e5                	mov    %esp,%ebp
80101b22:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b25:	83 ec 0c             	sub    $0xc,%esp
80101b28:	68 60 12 11 80       	push   $0x80111260
80101b2d:	e8 b2 34 00 00       	call   80104fe4 <acquire>
80101b32:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b35:	8b 45 08             	mov    0x8(%ebp),%eax
80101b38:	8b 40 08             	mov    0x8(%eax),%eax
80101b3b:	83 f8 01             	cmp    $0x1,%eax
80101b3e:	0f 85 a9 00 00 00    	jne    80101bed <iput+0xce>
80101b44:	8b 45 08             	mov    0x8(%ebp),%eax
80101b47:	8b 40 0c             	mov    0xc(%eax),%eax
80101b4a:	83 e0 02             	and    $0x2,%eax
80101b4d:	85 c0                	test   %eax,%eax
80101b4f:	0f 84 98 00 00 00    	je     80101bed <iput+0xce>
80101b55:	8b 45 08             	mov    0x8(%ebp),%eax
80101b58:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b5c:	66 85 c0             	test   %ax,%ax
80101b5f:	0f 85 88 00 00 00    	jne    80101bed <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b65:	8b 45 08             	mov    0x8(%ebp),%eax
80101b68:	8b 40 0c             	mov    0xc(%eax),%eax
80101b6b:	83 e0 01             	and    $0x1,%eax
80101b6e:	85 c0                	test   %eax,%eax
80101b70:	74 0d                	je     80101b7f <iput+0x60>
      panic("iput busy");
80101b72:	83 ec 0c             	sub    $0xc,%esp
80101b75:	68 62 86 10 80       	push   $0x80108662
80101b7a:	e8 e7 e9 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b82:	8b 40 0c             	mov    0xc(%eax),%eax
80101b85:	83 c8 01             	or     $0x1,%eax
80101b88:	89 c2                	mov    %eax,%edx
80101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8d:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101b90:	83 ec 0c             	sub    $0xc,%esp
80101b93:	68 60 12 11 80       	push   $0x80111260
80101b98:	e8 ae 34 00 00       	call   8010504b <release>
80101b9d:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101ba0:	83 ec 0c             	sub    $0xc,%esp
80101ba3:	ff 75 08             	pushl  0x8(%ebp)
80101ba6:	e8 a8 01 00 00       	call   80101d53 <itrunc>
80101bab:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101bae:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb1:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bb7:	83 ec 0c             	sub    $0xc,%esp
80101bba:	ff 75 08             	pushl  0x8(%ebp)
80101bbd:	e8 b3 fb ff ff       	call   80101775 <iupdate>
80101bc2:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101bc5:	83 ec 0c             	sub    $0xc,%esp
80101bc8:	68 60 12 11 80       	push   $0x80111260
80101bcd:	e8 12 34 00 00       	call   80104fe4 <acquire>
80101bd2:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101bdf:	83 ec 0c             	sub    $0xc,%esp
80101be2:	ff 75 08             	pushl  0x8(%ebp)
80101be5:	e8 ec 31 00 00       	call   80104dd6 <wakeup>
80101bea:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101bed:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf0:	8b 40 08             	mov    0x8(%eax),%eax
80101bf3:	8d 50 ff             	lea    -0x1(%eax),%edx
80101bf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf9:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bfc:	83 ec 0c             	sub    $0xc,%esp
80101bff:	68 60 12 11 80       	push   $0x80111260
80101c04:	e8 42 34 00 00       	call   8010504b <release>
80101c09:	83 c4 10             	add    $0x10,%esp
}
80101c0c:	90                   	nop
80101c0d:	c9                   	leave  
80101c0e:	c3                   	ret    

80101c0f <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c0f:	55                   	push   %ebp
80101c10:	89 e5                	mov    %esp,%ebp
80101c12:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c15:	83 ec 0c             	sub    $0xc,%esp
80101c18:	ff 75 08             	pushl  0x8(%ebp)
80101c1b:	e8 8d fe ff ff       	call   80101aad <iunlock>
80101c20:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c23:	83 ec 0c             	sub    $0xc,%esp
80101c26:	ff 75 08             	pushl  0x8(%ebp)
80101c29:	e8 f1 fe ff ff       	call   80101b1f <iput>
80101c2e:	83 c4 10             	add    $0x10,%esp
}
80101c31:	90                   	nop
80101c32:	c9                   	leave  
80101c33:	c3                   	ret    

80101c34 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c34:	55                   	push   %ebp
80101c35:	89 e5                	mov    %esp,%ebp
80101c37:	53                   	push   %ebx
80101c38:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c3b:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c3f:	77 42                	ja     80101c83 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101c41:	8b 45 08             	mov    0x8(%ebp),%eax
80101c44:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c47:	83 c2 04             	add    $0x4,%edx
80101c4a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c55:	75 24                	jne    80101c7b <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c57:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5a:	8b 00                	mov    (%eax),%eax
80101c5c:	83 ec 0c             	sub    $0xc,%esp
80101c5f:	50                   	push   %eax
80101c60:	e8 9a f7 ff ff       	call   801013ff <balloc>
80101c65:	83 c4 10             	add    $0x10,%esp
80101c68:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c71:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c74:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c77:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c7e:	e9 cb 00 00 00       	jmp    80101d4e <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c83:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c87:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c8b:	0f 87 b0 00 00 00    	ja     80101d41 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c91:	8b 45 08             	mov    0x8(%ebp),%eax
80101c94:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c97:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c9e:	75 1d                	jne    80101cbd <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca3:	8b 00                	mov    (%eax),%eax
80101ca5:	83 ec 0c             	sub    $0xc,%esp
80101ca8:	50                   	push   %eax
80101ca9:	e8 51 f7 ff ff       	call   801013ff <balloc>
80101cae:	83 c4 10             	add    $0x10,%esp
80101cb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cba:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc0:	8b 00                	mov    (%eax),%eax
80101cc2:	83 ec 08             	sub    $0x8,%esp
80101cc5:	ff 75 f4             	pushl  -0xc(%ebp)
80101cc8:	50                   	push   %eax
80101cc9:	e8 e8 e4 ff ff       	call   801001b6 <bread>
80101cce:	83 c4 10             	add    $0x10,%esp
80101cd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101cd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cd7:	83 c0 18             	add    $0x18,%eax
80101cda:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ce0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ce7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cea:	01 d0                	add    %edx,%eax
80101cec:	8b 00                	mov    (%eax),%eax
80101cee:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cf1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cf5:	75 37                	jne    80101d2e <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101cf7:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cfa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d04:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d07:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0a:	8b 00                	mov    (%eax),%eax
80101d0c:	83 ec 0c             	sub    $0xc,%esp
80101d0f:	50                   	push   %eax
80101d10:	e8 ea f6 ff ff       	call   801013ff <balloc>
80101d15:	83 c4 10             	add    $0x10,%esp
80101d18:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d1e:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101d20:	83 ec 0c             	sub    $0xc,%esp
80101d23:	ff 75 f0             	pushl  -0x10(%ebp)
80101d26:	e8 3f 1a 00 00       	call   8010376a <log_write>
80101d2b:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d2e:	83 ec 0c             	sub    $0xc,%esp
80101d31:	ff 75 f0             	pushl  -0x10(%ebp)
80101d34:	e8 f5 e4 ff ff       	call   8010022e <brelse>
80101d39:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d3f:	eb 0d                	jmp    80101d4e <bmap+0x11a>
  }

  panic("bmap: out of range");
80101d41:	83 ec 0c             	sub    $0xc,%esp
80101d44:	68 6c 86 10 80       	push   $0x8010866c
80101d49:	e8 18 e8 ff ff       	call   80100566 <panic>
}
80101d4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d51:	c9                   	leave  
80101d52:	c3                   	ret    

80101d53 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d53:	55                   	push   %ebp
80101d54:	89 e5                	mov    %esp,%ebp
80101d56:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d60:	eb 45                	jmp    80101da7 <itrunc+0x54>
    if(ip->addrs[i]){
80101d62:	8b 45 08             	mov    0x8(%ebp),%eax
80101d65:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d68:	83 c2 04             	add    $0x4,%edx
80101d6b:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d6f:	85 c0                	test   %eax,%eax
80101d71:	74 30                	je     80101da3 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d73:	8b 45 08             	mov    0x8(%ebp),%eax
80101d76:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d79:	83 c2 04             	add    $0x4,%edx
80101d7c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d80:	8b 55 08             	mov    0x8(%ebp),%edx
80101d83:	8b 12                	mov    (%edx),%edx
80101d85:	83 ec 08             	sub    $0x8,%esp
80101d88:	50                   	push   %eax
80101d89:	52                   	push   %edx
80101d8a:	e8 bc f7 ff ff       	call   8010154b <bfree>
80101d8f:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d92:	8b 45 08             	mov    0x8(%ebp),%eax
80101d95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d98:	83 c2 04             	add    $0x4,%edx
80101d9b:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101da2:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101da3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101da7:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dab:	7e b5                	jle    80101d62 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101dad:	8b 45 08             	mov    0x8(%ebp),%eax
80101db0:	8b 40 4c             	mov    0x4c(%eax),%eax
80101db3:	85 c0                	test   %eax,%eax
80101db5:	0f 84 a1 00 00 00    	je     80101e5c <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbe:	8b 50 4c             	mov    0x4c(%eax),%edx
80101dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc4:	8b 00                	mov    (%eax),%eax
80101dc6:	83 ec 08             	sub    $0x8,%esp
80101dc9:	52                   	push   %edx
80101dca:	50                   	push   %eax
80101dcb:	e8 e6 e3 ff ff       	call   801001b6 <bread>
80101dd0:	83 c4 10             	add    $0x10,%esp
80101dd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101dd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dd9:	83 c0 18             	add    $0x18,%eax
80101ddc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ddf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101de6:	eb 3c                	jmp    80101e24 <itrunc+0xd1>
      if(a[j])
80101de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101deb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101df2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101df5:	01 d0                	add    %edx,%eax
80101df7:	8b 00                	mov    (%eax),%eax
80101df9:	85 c0                	test   %eax,%eax
80101dfb:	74 23                	je     80101e20 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e00:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e07:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e0a:	01 d0                	add    %edx,%eax
80101e0c:	8b 00                	mov    (%eax),%eax
80101e0e:	8b 55 08             	mov    0x8(%ebp),%edx
80101e11:	8b 12                	mov    (%edx),%edx
80101e13:	83 ec 08             	sub    $0x8,%esp
80101e16:	50                   	push   %eax
80101e17:	52                   	push   %edx
80101e18:	e8 2e f7 ff ff       	call   8010154b <bfree>
80101e1d:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101e20:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e27:	83 f8 7f             	cmp    $0x7f,%eax
80101e2a:	76 bc                	jbe    80101de8 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101e2c:	83 ec 0c             	sub    $0xc,%esp
80101e2f:	ff 75 ec             	pushl  -0x14(%ebp)
80101e32:	e8 f7 e3 ff ff       	call   8010022e <brelse>
80101e37:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3d:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e40:	8b 55 08             	mov    0x8(%ebp),%edx
80101e43:	8b 12                	mov    (%edx),%edx
80101e45:	83 ec 08             	sub    $0x8,%esp
80101e48:	50                   	push   %eax
80101e49:	52                   	push   %edx
80101e4a:	e8 fc f6 ff ff       	call   8010154b <bfree>
80101e4f:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e52:	8b 45 08             	mov    0x8(%ebp),%eax
80101e55:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5f:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e66:	83 ec 0c             	sub    $0xc,%esp
80101e69:	ff 75 08             	pushl  0x8(%ebp)
80101e6c:	e8 04 f9 ff ff       	call   80101775 <iupdate>
80101e71:	83 c4 10             	add    $0x10,%esp
}
80101e74:	90                   	nop
80101e75:	c9                   	leave  
80101e76:	c3                   	ret    

80101e77 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e77:	55                   	push   %ebp
80101e78:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7d:	8b 00                	mov    (%eax),%eax
80101e7f:	89 c2                	mov    %eax,%edx
80101e81:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e84:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e87:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8a:	8b 50 04             	mov    0x4(%eax),%edx
80101e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e90:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e93:	8b 45 08             	mov    0x8(%ebp),%eax
80101e96:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9d:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea3:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eaa:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101eae:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb1:	8b 50 18             	mov    0x18(%eax),%edx
80101eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb7:	89 50 10             	mov    %edx,0x10(%eax)
}
80101eba:	90                   	nop
80101ebb:	5d                   	pop    %ebp
80101ebc:	c3                   	ret    

80101ebd <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ebd:	55                   	push   %ebp
80101ebe:	89 e5                	mov    %esp,%ebp
80101ec0:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101eca:	66 83 f8 03          	cmp    $0x3,%ax
80101ece:	75 5c                	jne    80101f2c <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ed0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ed7:	66 85 c0             	test   %ax,%ax
80101eda:	78 20                	js     80101efc <readi+0x3f>
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ee3:	66 83 f8 09          	cmp    $0x9,%ax
80101ee7:	7f 13                	jg     80101efc <readi+0x3f>
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef0:	98                   	cwtl   
80101ef1:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101ef8:	85 c0                	test   %eax,%eax
80101efa:	75 0a                	jne    80101f06 <readi+0x49>
      return -1;
80101efc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f01:	e9 0c 01 00 00       	jmp    80102012 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101f06:	8b 45 08             	mov    0x8(%ebp),%eax
80101f09:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f0d:	98                   	cwtl   
80101f0e:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101f15:	8b 55 14             	mov    0x14(%ebp),%edx
80101f18:	83 ec 04             	sub    $0x4,%esp
80101f1b:	52                   	push   %edx
80101f1c:	ff 75 0c             	pushl  0xc(%ebp)
80101f1f:	ff 75 08             	pushl  0x8(%ebp)
80101f22:	ff d0                	call   *%eax
80101f24:	83 c4 10             	add    $0x10,%esp
80101f27:	e9 e6 00 00 00       	jmp    80102012 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101f2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2f:	8b 40 18             	mov    0x18(%eax),%eax
80101f32:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f35:	72 0d                	jb     80101f44 <readi+0x87>
80101f37:	8b 55 10             	mov    0x10(%ebp),%edx
80101f3a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f3d:	01 d0                	add    %edx,%eax
80101f3f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f42:	73 0a                	jae    80101f4e <readi+0x91>
    return -1;
80101f44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f49:	e9 c4 00 00 00       	jmp    80102012 <readi+0x155>
  if(off + n > ip->size)
80101f4e:	8b 55 10             	mov    0x10(%ebp),%edx
80101f51:	8b 45 14             	mov    0x14(%ebp),%eax
80101f54:	01 c2                	add    %eax,%edx
80101f56:	8b 45 08             	mov    0x8(%ebp),%eax
80101f59:	8b 40 18             	mov    0x18(%eax),%eax
80101f5c:	39 c2                	cmp    %eax,%edx
80101f5e:	76 0c                	jbe    80101f6c <readi+0xaf>
    n = ip->size - off;
80101f60:	8b 45 08             	mov    0x8(%ebp),%eax
80101f63:	8b 40 18             	mov    0x18(%eax),%eax
80101f66:	2b 45 10             	sub    0x10(%ebp),%eax
80101f69:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f73:	e9 8b 00 00 00       	jmp    80102003 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f78:	8b 45 10             	mov    0x10(%ebp),%eax
80101f7b:	c1 e8 09             	shr    $0x9,%eax
80101f7e:	83 ec 08             	sub    $0x8,%esp
80101f81:	50                   	push   %eax
80101f82:	ff 75 08             	pushl  0x8(%ebp)
80101f85:	e8 aa fc ff ff       	call   80101c34 <bmap>
80101f8a:	83 c4 10             	add    $0x10,%esp
80101f8d:	89 c2                	mov    %eax,%edx
80101f8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f92:	8b 00                	mov    (%eax),%eax
80101f94:	83 ec 08             	sub    $0x8,%esp
80101f97:	52                   	push   %edx
80101f98:	50                   	push   %eax
80101f99:	e8 18 e2 ff ff       	call   801001b6 <bread>
80101f9e:	83 c4 10             	add    $0x10,%esp
80101fa1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fa4:	8b 45 10             	mov    0x10(%ebp),%eax
80101fa7:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fac:	ba 00 02 00 00       	mov    $0x200,%edx
80101fb1:	29 c2                	sub    %eax,%edx
80101fb3:	8b 45 14             	mov    0x14(%ebp),%eax
80101fb6:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fb9:	39 c2                	cmp    %eax,%edx
80101fbb:	0f 46 c2             	cmovbe %edx,%eax
80101fbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fc4:	8d 50 18             	lea    0x18(%eax),%edx
80101fc7:	8b 45 10             	mov    0x10(%ebp),%eax
80101fca:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fcf:	01 d0                	add    %edx,%eax
80101fd1:	83 ec 04             	sub    $0x4,%esp
80101fd4:	ff 75 ec             	pushl  -0x14(%ebp)
80101fd7:	50                   	push   %eax
80101fd8:	ff 75 0c             	pushl  0xc(%ebp)
80101fdb:	e8 26 33 00 00       	call   80105306 <memmove>
80101fe0:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101fe3:	83 ec 0c             	sub    $0xc,%esp
80101fe6:	ff 75 f0             	pushl  -0x10(%ebp)
80101fe9:	e8 40 e2 ff ff       	call   8010022e <brelse>
80101fee:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ff1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ff4:	01 45 f4             	add    %eax,-0xc(%ebp)
80101ff7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ffa:	01 45 10             	add    %eax,0x10(%ebp)
80101ffd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102000:	01 45 0c             	add    %eax,0xc(%ebp)
80102003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102006:	3b 45 14             	cmp    0x14(%ebp),%eax
80102009:	0f 82 69 ff ff ff    	jb     80101f78 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010200f:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102012:	c9                   	leave  
80102013:	c3                   	ret    

80102014 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102014:	55                   	push   %ebp
80102015:	89 e5                	mov    %esp,%ebp
80102017:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010201a:	8b 45 08             	mov    0x8(%ebp),%eax
8010201d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102021:	66 83 f8 03          	cmp    $0x3,%ax
80102025:	75 5c                	jne    80102083 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102027:	8b 45 08             	mov    0x8(%ebp),%eax
8010202a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010202e:	66 85 c0             	test   %ax,%ax
80102031:	78 20                	js     80102053 <writei+0x3f>
80102033:	8b 45 08             	mov    0x8(%ebp),%eax
80102036:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010203a:	66 83 f8 09          	cmp    $0x9,%ax
8010203e:	7f 13                	jg     80102053 <writei+0x3f>
80102040:	8b 45 08             	mov    0x8(%ebp),%eax
80102043:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102047:	98                   	cwtl   
80102048:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
8010204f:	85 c0                	test   %eax,%eax
80102051:	75 0a                	jne    8010205d <writei+0x49>
      return -1;
80102053:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102058:	e9 3d 01 00 00       	jmp    8010219a <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
8010205d:	8b 45 08             	mov    0x8(%ebp),%eax
80102060:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102064:	98                   	cwtl   
80102065:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
8010206c:	8b 55 14             	mov    0x14(%ebp),%edx
8010206f:	83 ec 04             	sub    $0x4,%esp
80102072:	52                   	push   %edx
80102073:	ff 75 0c             	pushl  0xc(%ebp)
80102076:	ff 75 08             	pushl  0x8(%ebp)
80102079:	ff d0                	call   *%eax
8010207b:	83 c4 10             	add    $0x10,%esp
8010207e:	e9 17 01 00 00       	jmp    8010219a <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102083:	8b 45 08             	mov    0x8(%ebp),%eax
80102086:	8b 40 18             	mov    0x18(%eax),%eax
80102089:	3b 45 10             	cmp    0x10(%ebp),%eax
8010208c:	72 0d                	jb     8010209b <writei+0x87>
8010208e:	8b 55 10             	mov    0x10(%ebp),%edx
80102091:	8b 45 14             	mov    0x14(%ebp),%eax
80102094:	01 d0                	add    %edx,%eax
80102096:	3b 45 10             	cmp    0x10(%ebp),%eax
80102099:	73 0a                	jae    801020a5 <writei+0x91>
    return -1;
8010209b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020a0:	e9 f5 00 00 00       	jmp    8010219a <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801020a5:	8b 55 10             	mov    0x10(%ebp),%edx
801020a8:	8b 45 14             	mov    0x14(%ebp),%eax
801020ab:	01 d0                	add    %edx,%eax
801020ad:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020b2:	76 0a                	jbe    801020be <writei+0xaa>
    return -1;
801020b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b9:	e9 dc 00 00 00       	jmp    8010219a <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020c5:	e9 99 00 00 00       	jmp    80102163 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020ca:	8b 45 10             	mov    0x10(%ebp),%eax
801020cd:	c1 e8 09             	shr    $0x9,%eax
801020d0:	83 ec 08             	sub    $0x8,%esp
801020d3:	50                   	push   %eax
801020d4:	ff 75 08             	pushl  0x8(%ebp)
801020d7:	e8 58 fb ff ff       	call   80101c34 <bmap>
801020dc:	83 c4 10             	add    $0x10,%esp
801020df:	89 c2                	mov    %eax,%edx
801020e1:	8b 45 08             	mov    0x8(%ebp),%eax
801020e4:	8b 00                	mov    (%eax),%eax
801020e6:	83 ec 08             	sub    $0x8,%esp
801020e9:	52                   	push   %edx
801020ea:	50                   	push   %eax
801020eb:	e8 c6 e0 ff ff       	call   801001b6 <bread>
801020f0:	83 c4 10             	add    $0x10,%esp
801020f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020f6:	8b 45 10             	mov    0x10(%ebp),%eax
801020f9:	25 ff 01 00 00       	and    $0x1ff,%eax
801020fe:	ba 00 02 00 00       	mov    $0x200,%edx
80102103:	29 c2                	sub    %eax,%edx
80102105:	8b 45 14             	mov    0x14(%ebp),%eax
80102108:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010210b:	39 c2                	cmp    %eax,%edx
8010210d:	0f 46 c2             	cmovbe %edx,%eax
80102110:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102113:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102116:	8d 50 18             	lea    0x18(%eax),%edx
80102119:	8b 45 10             	mov    0x10(%ebp),%eax
8010211c:	25 ff 01 00 00       	and    $0x1ff,%eax
80102121:	01 d0                	add    %edx,%eax
80102123:	83 ec 04             	sub    $0x4,%esp
80102126:	ff 75 ec             	pushl  -0x14(%ebp)
80102129:	ff 75 0c             	pushl  0xc(%ebp)
8010212c:	50                   	push   %eax
8010212d:	e8 d4 31 00 00       	call   80105306 <memmove>
80102132:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102135:	83 ec 0c             	sub    $0xc,%esp
80102138:	ff 75 f0             	pushl  -0x10(%ebp)
8010213b:	e8 2a 16 00 00       	call   8010376a <log_write>
80102140:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102143:	83 ec 0c             	sub    $0xc,%esp
80102146:	ff 75 f0             	pushl  -0x10(%ebp)
80102149:	e8 e0 e0 ff ff       	call   8010022e <brelse>
8010214e:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102151:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102154:	01 45 f4             	add    %eax,-0xc(%ebp)
80102157:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010215a:	01 45 10             	add    %eax,0x10(%ebp)
8010215d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102160:	01 45 0c             	add    %eax,0xc(%ebp)
80102163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102166:	3b 45 14             	cmp    0x14(%ebp),%eax
80102169:	0f 82 5b ff ff ff    	jb     801020ca <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010216f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102173:	74 22                	je     80102197 <writei+0x183>
80102175:	8b 45 08             	mov    0x8(%ebp),%eax
80102178:	8b 40 18             	mov    0x18(%eax),%eax
8010217b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010217e:	73 17                	jae    80102197 <writei+0x183>
    ip->size = off;
80102180:	8b 45 08             	mov    0x8(%ebp),%eax
80102183:	8b 55 10             	mov    0x10(%ebp),%edx
80102186:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102189:	83 ec 0c             	sub    $0xc,%esp
8010218c:	ff 75 08             	pushl  0x8(%ebp)
8010218f:	e8 e1 f5 ff ff       	call   80101775 <iupdate>
80102194:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102197:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010219a:	c9                   	leave  
8010219b:	c3                   	ret    

8010219c <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010219c:	55                   	push   %ebp
8010219d:	89 e5                	mov    %esp,%ebp
8010219f:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021a2:	83 ec 04             	sub    $0x4,%esp
801021a5:	6a 0e                	push   $0xe
801021a7:	ff 75 0c             	pushl  0xc(%ebp)
801021aa:	ff 75 08             	pushl  0x8(%ebp)
801021ad:	e8 ea 31 00 00       	call   8010539c <strncmp>
801021b2:	83 c4 10             	add    $0x10,%esp
}
801021b5:	c9                   	leave  
801021b6:	c3                   	ret    

801021b7 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021b7:	55                   	push   %ebp
801021b8:	89 e5                	mov    %esp,%ebp
801021ba:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021bd:	8b 45 08             	mov    0x8(%ebp),%eax
801021c0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021c4:	66 83 f8 01          	cmp    $0x1,%ax
801021c8:	74 0d                	je     801021d7 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021ca:	83 ec 0c             	sub    $0xc,%esp
801021cd:	68 7f 86 10 80       	push   $0x8010867f
801021d2:	e8 8f e3 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021de:	eb 7b                	jmp    8010225b <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021e0:	6a 10                	push   $0x10
801021e2:	ff 75 f4             	pushl  -0xc(%ebp)
801021e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021e8:	50                   	push   %eax
801021e9:	ff 75 08             	pushl  0x8(%ebp)
801021ec:	e8 cc fc ff ff       	call   80101ebd <readi>
801021f1:	83 c4 10             	add    $0x10,%esp
801021f4:	83 f8 10             	cmp    $0x10,%eax
801021f7:	74 0d                	je     80102206 <dirlookup+0x4f>
      panic("dirlink read");
801021f9:	83 ec 0c             	sub    $0xc,%esp
801021fc:	68 91 86 10 80       	push   $0x80108691
80102201:	e8 60 e3 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102206:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010220a:	66 85 c0             	test   %ax,%ax
8010220d:	74 47                	je     80102256 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010220f:	83 ec 08             	sub    $0x8,%esp
80102212:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102215:	83 c0 02             	add    $0x2,%eax
80102218:	50                   	push   %eax
80102219:	ff 75 0c             	pushl  0xc(%ebp)
8010221c:	e8 7b ff ff ff       	call   8010219c <namecmp>
80102221:	83 c4 10             	add    $0x10,%esp
80102224:	85 c0                	test   %eax,%eax
80102226:	75 2f                	jne    80102257 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102228:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010222c:	74 08                	je     80102236 <dirlookup+0x7f>
        *poff = off;
8010222e:	8b 45 10             	mov    0x10(%ebp),%eax
80102231:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102234:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102236:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010223a:	0f b7 c0             	movzwl %ax,%eax
8010223d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102240:	8b 45 08             	mov    0x8(%ebp),%eax
80102243:	8b 00                	mov    (%eax),%eax
80102245:	83 ec 08             	sub    $0x8,%esp
80102248:	ff 75 f0             	pushl  -0x10(%ebp)
8010224b:	50                   	push   %eax
8010224c:	e8 e5 f5 ff ff       	call   80101836 <iget>
80102251:	83 c4 10             	add    $0x10,%esp
80102254:	eb 19                	jmp    8010226f <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102256:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102257:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010225b:	8b 45 08             	mov    0x8(%ebp),%eax
8010225e:	8b 40 18             	mov    0x18(%eax),%eax
80102261:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102264:	0f 87 76 ff ff ff    	ja     801021e0 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010226a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010226f:	c9                   	leave  
80102270:	c3                   	ret    

80102271 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102271:	55                   	push   %ebp
80102272:	89 e5                	mov    %esp,%ebp
80102274:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102277:	83 ec 04             	sub    $0x4,%esp
8010227a:	6a 00                	push   $0x0
8010227c:	ff 75 0c             	pushl  0xc(%ebp)
8010227f:	ff 75 08             	pushl  0x8(%ebp)
80102282:	e8 30 ff ff ff       	call   801021b7 <dirlookup>
80102287:	83 c4 10             	add    $0x10,%esp
8010228a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010228d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102291:	74 18                	je     801022ab <dirlink+0x3a>
    iput(ip);
80102293:	83 ec 0c             	sub    $0xc,%esp
80102296:	ff 75 f0             	pushl  -0x10(%ebp)
80102299:	e8 81 f8 ff ff       	call   80101b1f <iput>
8010229e:	83 c4 10             	add    $0x10,%esp
    return -1;
801022a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022a6:	e9 9c 00 00 00       	jmp    80102347 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022b2:	eb 39                	jmp    801022ed <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022b7:	6a 10                	push   $0x10
801022b9:	50                   	push   %eax
801022ba:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022bd:	50                   	push   %eax
801022be:	ff 75 08             	pushl  0x8(%ebp)
801022c1:	e8 f7 fb ff ff       	call   80101ebd <readi>
801022c6:	83 c4 10             	add    $0x10,%esp
801022c9:	83 f8 10             	cmp    $0x10,%eax
801022cc:	74 0d                	je     801022db <dirlink+0x6a>
      panic("dirlink read");
801022ce:	83 ec 0c             	sub    $0xc,%esp
801022d1:	68 91 86 10 80       	push   $0x80108691
801022d6:	e8 8b e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801022db:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022df:	66 85 c0             	test   %ax,%ax
801022e2:	74 18                	je     801022fc <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e7:	83 c0 10             	add    $0x10,%eax
801022ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022ed:	8b 45 08             	mov    0x8(%ebp),%eax
801022f0:	8b 50 18             	mov    0x18(%eax),%edx
801022f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f6:	39 c2                	cmp    %eax,%edx
801022f8:	77 ba                	ja     801022b4 <dirlink+0x43>
801022fa:	eb 01                	jmp    801022fd <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801022fc:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801022fd:	83 ec 04             	sub    $0x4,%esp
80102300:	6a 0e                	push   $0xe
80102302:	ff 75 0c             	pushl  0xc(%ebp)
80102305:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102308:	83 c0 02             	add    $0x2,%eax
8010230b:	50                   	push   %eax
8010230c:	e8 e1 30 00 00       	call   801053f2 <strncpy>
80102311:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102314:	8b 45 10             	mov    0x10(%ebp),%eax
80102317:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010231b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010231e:	6a 10                	push   $0x10
80102320:	50                   	push   %eax
80102321:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102324:	50                   	push   %eax
80102325:	ff 75 08             	pushl  0x8(%ebp)
80102328:	e8 e7 fc ff ff       	call   80102014 <writei>
8010232d:	83 c4 10             	add    $0x10,%esp
80102330:	83 f8 10             	cmp    $0x10,%eax
80102333:	74 0d                	je     80102342 <dirlink+0xd1>
    panic("dirlink");
80102335:	83 ec 0c             	sub    $0xc,%esp
80102338:	68 9e 86 10 80       	push   $0x8010869e
8010233d:	e8 24 e2 ff ff       	call   80100566 <panic>
  
  return 0;
80102342:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102347:	c9                   	leave  
80102348:	c3                   	ret    

80102349 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102349:	55                   	push   %ebp
8010234a:	89 e5                	mov    %esp,%ebp
8010234c:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010234f:	eb 04                	jmp    80102355 <skipelem+0xc>
    path++;
80102351:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102355:	8b 45 08             	mov    0x8(%ebp),%eax
80102358:	0f b6 00             	movzbl (%eax),%eax
8010235b:	3c 2f                	cmp    $0x2f,%al
8010235d:	74 f2                	je     80102351 <skipelem+0x8>
    path++;
  if(*path == 0)
8010235f:	8b 45 08             	mov    0x8(%ebp),%eax
80102362:	0f b6 00             	movzbl (%eax),%eax
80102365:	84 c0                	test   %al,%al
80102367:	75 07                	jne    80102370 <skipelem+0x27>
    return 0;
80102369:	b8 00 00 00 00       	mov    $0x0,%eax
8010236e:	eb 7b                	jmp    801023eb <skipelem+0xa2>
  s = path;
80102370:	8b 45 08             	mov    0x8(%ebp),%eax
80102373:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102376:	eb 04                	jmp    8010237c <skipelem+0x33>
    path++;
80102378:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010237c:	8b 45 08             	mov    0x8(%ebp),%eax
8010237f:	0f b6 00             	movzbl (%eax),%eax
80102382:	3c 2f                	cmp    $0x2f,%al
80102384:	74 0a                	je     80102390 <skipelem+0x47>
80102386:	8b 45 08             	mov    0x8(%ebp),%eax
80102389:	0f b6 00             	movzbl (%eax),%eax
8010238c:	84 c0                	test   %al,%al
8010238e:	75 e8                	jne    80102378 <skipelem+0x2f>
    path++;
  len = path - s;
80102390:	8b 55 08             	mov    0x8(%ebp),%edx
80102393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102396:	29 c2                	sub    %eax,%edx
80102398:	89 d0                	mov    %edx,%eax
8010239a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010239d:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023a1:	7e 15                	jle    801023b8 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801023a3:	83 ec 04             	sub    $0x4,%esp
801023a6:	6a 0e                	push   $0xe
801023a8:	ff 75 f4             	pushl  -0xc(%ebp)
801023ab:	ff 75 0c             	pushl  0xc(%ebp)
801023ae:	e8 53 2f 00 00       	call   80105306 <memmove>
801023b3:	83 c4 10             	add    $0x10,%esp
801023b6:	eb 26                	jmp    801023de <skipelem+0x95>
  else {
    memmove(name, s, len);
801023b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023bb:	83 ec 04             	sub    $0x4,%esp
801023be:	50                   	push   %eax
801023bf:	ff 75 f4             	pushl  -0xc(%ebp)
801023c2:	ff 75 0c             	pushl  0xc(%ebp)
801023c5:	e8 3c 2f 00 00       	call   80105306 <memmove>
801023ca:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801023d3:	01 d0                	add    %edx,%eax
801023d5:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023d8:	eb 04                	jmp    801023de <skipelem+0x95>
    path++;
801023da:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801023de:	8b 45 08             	mov    0x8(%ebp),%eax
801023e1:	0f b6 00             	movzbl (%eax),%eax
801023e4:	3c 2f                	cmp    $0x2f,%al
801023e6:	74 f2                	je     801023da <skipelem+0x91>
    path++;
  return path;
801023e8:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023eb:	c9                   	leave  
801023ec:	c3                   	ret    

801023ed <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023ed:	55                   	push   %ebp
801023ee:	89 e5                	mov    %esp,%ebp
801023f0:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801023f3:	8b 45 08             	mov    0x8(%ebp),%eax
801023f6:	0f b6 00             	movzbl (%eax),%eax
801023f9:	3c 2f                	cmp    $0x2f,%al
801023fb:	75 17                	jne    80102414 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801023fd:	83 ec 08             	sub    $0x8,%esp
80102400:	6a 01                	push   $0x1
80102402:	6a 01                	push   $0x1
80102404:	e8 2d f4 ff ff       	call   80101836 <iget>
80102409:	83 c4 10             	add    $0x10,%esp
8010240c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010240f:	e9 bb 00 00 00       	jmp    801024cf <namex+0xe2>
  else
    ip = idup(proc->cwd);
80102414:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010241a:	8b 40 68             	mov    0x68(%eax),%eax
8010241d:	83 ec 0c             	sub    $0xc,%esp
80102420:	50                   	push   %eax
80102421:	e8 ef f4 ff ff       	call   80101915 <idup>
80102426:	83 c4 10             	add    $0x10,%esp
80102429:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010242c:	e9 9e 00 00 00       	jmp    801024cf <namex+0xe2>
    ilock(ip);
80102431:	83 ec 0c             	sub    $0xc,%esp
80102434:	ff 75 f4             	pushl  -0xc(%ebp)
80102437:	e8 13 f5 ff ff       	call   8010194f <ilock>
8010243c:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010243f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102442:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102446:	66 83 f8 01          	cmp    $0x1,%ax
8010244a:	74 18                	je     80102464 <namex+0x77>
      iunlockput(ip);
8010244c:	83 ec 0c             	sub    $0xc,%esp
8010244f:	ff 75 f4             	pushl  -0xc(%ebp)
80102452:	e8 b8 f7 ff ff       	call   80101c0f <iunlockput>
80102457:	83 c4 10             	add    $0x10,%esp
      return 0;
8010245a:	b8 00 00 00 00       	mov    $0x0,%eax
8010245f:	e9 a7 00 00 00       	jmp    8010250b <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102464:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102468:	74 20                	je     8010248a <namex+0x9d>
8010246a:	8b 45 08             	mov    0x8(%ebp),%eax
8010246d:	0f b6 00             	movzbl (%eax),%eax
80102470:	84 c0                	test   %al,%al
80102472:	75 16                	jne    8010248a <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
80102474:	83 ec 0c             	sub    $0xc,%esp
80102477:	ff 75 f4             	pushl  -0xc(%ebp)
8010247a:	e8 2e f6 ff ff       	call   80101aad <iunlock>
8010247f:	83 c4 10             	add    $0x10,%esp
      return ip;
80102482:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102485:	e9 81 00 00 00       	jmp    8010250b <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010248a:	83 ec 04             	sub    $0x4,%esp
8010248d:	6a 00                	push   $0x0
8010248f:	ff 75 10             	pushl  0x10(%ebp)
80102492:	ff 75 f4             	pushl  -0xc(%ebp)
80102495:	e8 1d fd ff ff       	call   801021b7 <dirlookup>
8010249a:	83 c4 10             	add    $0x10,%esp
8010249d:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024a4:	75 15                	jne    801024bb <namex+0xce>
      iunlockput(ip);
801024a6:	83 ec 0c             	sub    $0xc,%esp
801024a9:	ff 75 f4             	pushl  -0xc(%ebp)
801024ac:	e8 5e f7 ff ff       	call   80101c0f <iunlockput>
801024b1:	83 c4 10             	add    $0x10,%esp
      return 0;
801024b4:	b8 00 00 00 00       	mov    $0x0,%eax
801024b9:	eb 50                	jmp    8010250b <namex+0x11e>
    }
    iunlockput(ip);
801024bb:	83 ec 0c             	sub    $0xc,%esp
801024be:	ff 75 f4             	pushl  -0xc(%ebp)
801024c1:	e8 49 f7 ff ff       	call   80101c0f <iunlockput>
801024c6:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801024cf:	83 ec 08             	sub    $0x8,%esp
801024d2:	ff 75 10             	pushl  0x10(%ebp)
801024d5:	ff 75 08             	pushl  0x8(%ebp)
801024d8:	e8 6c fe ff ff       	call   80102349 <skipelem>
801024dd:	83 c4 10             	add    $0x10,%esp
801024e0:	89 45 08             	mov    %eax,0x8(%ebp)
801024e3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024e7:	0f 85 44 ff ff ff    	jne    80102431 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801024ed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024f1:	74 15                	je     80102508 <namex+0x11b>
    iput(ip);
801024f3:	83 ec 0c             	sub    $0xc,%esp
801024f6:	ff 75 f4             	pushl  -0xc(%ebp)
801024f9:	e8 21 f6 ff ff       	call   80101b1f <iput>
801024fe:	83 c4 10             	add    $0x10,%esp
    return 0;
80102501:	b8 00 00 00 00       	mov    $0x0,%eax
80102506:	eb 03                	jmp    8010250b <namex+0x11e>
  }
  return ip;
80102508:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010250b:	c9                   	leave  
8010250c:	c3                   	ret    

8010250d <namei>:

struct inode*
namei(char *path)
{
8010250d:	55                   	push   %ebp
8010250e:	89 e5                	mov    %esp,%ebp
80102510:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102513:	83 ec 04             	sub    $0x4,%esp
80102516:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102519:	50                   	push   %eax
8010251a:	6a 00                	push   $0x0
8010251c:	ff 75 08             	pushl  0x8(%ebp)
8010251f:	e8 c9 fe ff ff       	call   801023ed <namex>
80102524:	83 c4 10             	add    $0x10,%esp
}
80102527:	c9                   	leave  
80102528:	c3                   	ret    

80102529 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102529:	55                   	push   %ebp
8010252a:	89 e5                	mov    %esp,%ebp
8010252c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010252f:	83 ec 04             	sub    $0x4,%esp
80102532:	ff 75 0c             	pushl  0xc(%ebp)
80102535:	6a 01                	push   $0x1
80102537:	ff 75 08             	pushl  0x8(%ebp)
8010253a:	e8 ae fe ff ff       	call   801023ed <namex>
8010253f:	83 c4 10             	add    $0x10,%esp
}
80102542:	c9                   	leave  
80102543:	c3                   	ret    

80102544 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102544:	55                   	push   %ebp
80102545:	89 e5                	mov    %esp,%ebp
80102547:	83 ec 14             	sub    $0x14,%esp
8010254a:	8b 45 08             	mov    0x8(%ebp),%eax
8010254d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102551:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102555:	89 c2                	mov    %eax,%edx
80102557:	ec                   	in     (%dx),%al
80102558:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010255b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010255f:	c9                   	leave  
80102560:	c3                   	ret    

80102561 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102561:	55                   	push   %ebp
80102562:	89 e5                	mov    %esp,%ebp
80102564:	57                   	push   %edi
80102565:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102566:	8b 55 08             	mov    0x8(%ebp),%edx
80102569:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010256c:	8b 45 10             	mov    0x10(%ebp),%eax
8010256f:	89 cb                	mov    %ecx,%ebx
80102571:	89 df                	mov    %ebx,%edi
80102573:	89 c1                	mov    %eax,%ecx
80102575:	fc                   	cld    
80102576:	f3 6d                	rep insl (%dx),%es:(%edi)
80102578:	89 c8                	mov    %ecx,%eax
8010257a:	89 fb                	mov    %edi,%ebx
8010257c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010257f:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102582:	90                   	nop
80102583:	5b                   	pop    %ebx
80102584:	5f                   	pop    %edi
80102585:	5d                   	pop    %ebp
80102586:	c3                   	ret    

80102587 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102587:	55                   	push   %ebp
80102588:	89 e5                	mov    %esp,%ebp
8010258a:	83 ec 08             	sub    $0x8,%esp
8010258d:	8b 55 08             	mov    0x8(%ebp),%edx
80102590:	8b 45 0c             	mov    0xc(%ebp),%eax
80102593:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102597:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010259a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010259e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025a2:	ee                   	out    %al,(%dx)
}
801025a3:	90                   	nop
801025a4:	c9                   	leave  
801025a5:	c3                   	ret    

801025a6 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801025a6:	55                   	push   %ebp
801025a7:	89 e5                	mov    %esp,%ebp
801025a9:	56                   	push   %esi
801025aa:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025ab:	8b 55 08             	mov    0x8(%ebp),%edx
801025ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025b1:	8b 45 10             	mov    0x10(%ebp),%eax
801025b4:	89 cb                	mov    %ecx,%ebx
801025b6:	89 de                	mov    %ebx,%esi
801025b8:	89 c1                	mov    %eax,%ecx
801025ba:	fc                   	cld    
801025bb:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025bd:	89 c8                	mov    %ecx,%eax
801025bf:	89 f3                	mov    %esi,%ebx
801025c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025c4:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801025c7:	90                   	nop
801025c8:	5b                   	pop    %ebx
801025c9:	5e                   	pop    %esi
801025ca:	5d                   	pop    %ebp
801025cb:	c3                   	ret    

801025cc <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025cc:	55                   	push   %ebp
801025cd:	89 e5                	mov    %esp,%ebp
801025cf:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801025d2:	90                   	nop
801025d3:	68 f7 01 00 00       	push   $0x1f7
801025d8:	e8 67 ff ff ff       	call   80102544 <inb>
801025dd:	83 c4 04             	add    $0x4,%esp
801025e0:	0f b6 c0             	movzbl %al,%eax
801025e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
801025e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025e9:	25 c0 00 00 00       	and    $0xc0,%eax
801025ee:	83 f8 40             	cmp    $0x40,%eax
801025f1:	75 e0                	jne    801025d3 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801025f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025f7:	74 11                	je     8010260a <idewait+0x3e>
801025f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025fc:	83 e0 21             	and    $0x21,%eax
801025ff:	85 c0                	test   %eax,%eax
80102601:	74 07                	je     8010260a <idewait+0x3e>
    return -1;
80102603:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102608:	eb 05                	jmp    8010260f <idewait+0x43>
  return 0;
8010260a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010260f:	c9                   	leave  
80102610:	c3                   	ret    

80102611 <ideinit>:

void
ideinit(void)
{
80102611:	55                   	push   %ebp
80102612:	89 e5                	mov    %esp,%ebp
80102614:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102617:	83 ec 08             	sub    $0x8,%esp
8010261a:	68 a6 86 10 80       	push   $0x801086a6
8010261f:	68 00 b6 10 80       	push   $0x8010b600
80102624:	e8 99 29 00 00       	call   80104fc2 <initlock>
80102629:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
8010262c:	83 ec 0c             	sub    $0xc,%esp
8010262f:	6a 0e                	push   $0xe
80102631:	e8 da 18 00 00       	call   80103f10 <picenable>
80102636:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102639:	a1 60 29 11 80       	mov    0x80112960,%eax
8010263e:	83 e8 01             	sub    $0x1,%eax
80102641:	83 ec 08             	sub    $0x8,%esp
80102644:	50                   	push   %eax
80102645:	6a 0e                	push   $0xe
80102647:	e8 73 04 00 00       	call   80102abf <ioapicenable>
8010264c:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010264f:	83 ec 0c             	sub    $0xc,%esp
80102652:	6a 00                	push   $0x0
80102654:	e8 73 ff ff ff       	call   801025cc <idewait>
80102659:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010265c:	83 ec 08             	sub    $0x8,%esp
8010265f:	68 f0 00 00 00       	push   $0xf0
80102664:	68 f6 01 00 00       	push   $0x1f6
80102669:	e8 19 ff ff ff       	call   80102587 <outb>
8010266e:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102671:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102678:	eb 24                	jmp    8010269e <ideinit+0x8d>
    if(inb(0x1f7) != 0){
8010267a:	83 ec 0c             	sub    $0xc,%esp
8010267d:	68 f7 01 00 00       	push   $0x1f7
80102682:	e8 bd fe ff ff       	call   80102544 <inb>
80102687:	83 c4 10             	add    $0x10,%esp
8010268a:	84 c0                	test   %al,%al
8010268c:	74 0c                	je     8010269a <ideinit+0x89>
      havedisk1 = 1;
8010268e:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
80102695:	00 00 00 
      break;
80102698:	eb 0d                	jmp    801026a7 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
8010269a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010269e:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026a5:	7e d3                	jle    8010267a <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026a7:	83 ec 08             	sub    $0x8,%esp
801026aa:	68 e0 00 00 00       	push   $0xe0
801026af:	68 f6 01 00 00       	push   $0x1f6
801026b4:	e8 ce fe ff ff       	call   80102587 <outb>
801026b9:	83 c4 10             	add    $0x10,%esp
}
801026bc:	90                   	nop
801026bd:	c9                   	leave  
801026be:	c3                   	ret    

801026bf <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026bf:	55                   	push   %ebp
801026c0:	89 e5                	mov    %esp,%ebp
801026c2:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026c5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026c9:	75 0d                	jne    801026d8 <idestart+0x19>
    panic("idestart");
801026cb:	83 ec 0c             	sub    $0xc,%esp
801026ce:	68 aa 86 10 80       	push   $0x801086aa
801026d3:	e8 8e de ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
801026d8:	8b 45 08             	mov    0x8(%ebp),%eax
801026db:	8b 40 08             	mov    0x8(%eax),%eax
801026de:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026e3:	76 0d                	jbe    801026f2 <idestart+0x33>
    panic("incorrect blockno");
801026e5:	83 ec 0c             	sub    $0xc,%esp
801026e8:	68 b3 86 10 80       	push   $0x801086b3
801026ed:	e8 74 de ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801026f2:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801026f9:	8b 45 08             	mov    0x8(%ebp),%eax
801026fc:	8b 50 08             	mov    0x8(%eax),%edx
801026ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102702:	0f af c2             	imul   %edx,%eax
80102705:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102708:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010270c:	7e 0d                	jle    8010271b <idestart+0x5c>
8010270e:	83 ec 0c             	sub    $0xc,%esp
80102711:	68 aa 86 10 80       	push   $0x801086aa
80102716:	e8 4b de ff ff       	call   80100566 <panic>
  
  idewait(0);
8010271b:	83 ec 0c             	sub    $0xc,%esp
8010271e:	6a 00                	push   $0x0
80102720:	e8 a7 fe ff ff       	call   801025cc <idewait>
80102725:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102728:	83 ec 08             	sub    $0x8,%esp
8010272b:	6a 00                	push   $0x0
8010272d:	68 f6 03 00 00       	push   $0x3f6
80102732:	e8 50 fe ff ff       	call   80102587 <outb>
80102737:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
8010273a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010273d:	0f b6 c0             	movzbl %al,%eax
80102740:	83 ec 08             	sub    $0x8,%esp
80102743:	50                   	push   %eax
80102744:	68 f2 01 00 00       	push   $0x1f2
80102749:	e8 39 fe ff ff       	call   80102587 <outb>
8010274e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102751:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102754:	0f b6 c0             	movzbl %al,%eax
80102757:	83 ec 08             	sub    $0x8,%esp
8010275a:	50                   	push   %eax
8010275b:	68 f3 01 00 00       	push   $0x1f3
80102760:	e8 22 fe ff ff       	call   80102587 <outb>
80102765:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102768:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010276b:	c1 f8 08             	sar    $0x8,%eax
8010276e:	0f b6 c0             	movzbl %al,%eax
80102771:	83 ec 08             	sub    $0x8,%esp
80102774:	50                   	push   %eax
80102775:	68 f4 01 00 00       	push   $0x1f4
8010277a:	e8 08 fe ff ff       	call   80102587 <outb>
8010277f:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102782:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102785:	c1 f8 10             	sar    $0x10,%eax
80102788:	0f b6 c0             	movzbl %al,%eax
8010278b:	83 ec 08             	sub    $0x8,%esp
8010278e:	50                   	push   %eax
8010278f:	68 f5 01 00 00       	push   $0x1f5
80102794:	e8 ee fd ff ff       	call   80102587 <outb>
80102799:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010279c:	8b 45 08             	mov    0x8(%ebp),%eax
8010279f:	8b 40 04             	mov    0x4(%eax),%eax
801027a2:	83 e0 01             	and    $0x1,%eax
801027a5:	c1 e0 04             	shl    $0x4,%eax
801027a8:	89 c2                	mov    %eax,%edx
801027aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027ad:	c1 f8 18             	sar    $0x18,%eax
801027b0:	83 e0 0f             	and    $0xf,%eax
801027b3:	09 d0                	or     %edx,%eax
801027b5:	83 c8 e0             	or     $0xffffffe0,%eax
801027b8:	0f b6 c0             	movzbl %al,%eax
801027bb:	83 ec 08             	sub    $0x8,%esp
801027be:	50                   	push   %eax
801027bf:	68 f6 01 00 00       	push   $0x1f6
801027c4:	e8 be fd ff ff       	call   80102587 <outb>
801027c9:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027cc:	8b 45 08             	mov    0x8(%ebp),%eax
801027cf:	8b 00                	mov    (%eax),%eax
801027d1:	83 e0 04             	and    $0x4,%eax
801027d4:	85 c0                	test   %eax,%eax
801027d6:	74 30                	je     80102808 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
801027d8:	83 ec 08             	sub    $0x8,%esp
801027db:	6a 30                	push   $0x30
801027dd:	68 f7 01 00 00       	push   $0x1f7
801027e2:	e8 a0 fd ff ff       	call   80102587 <outb>
801027e7:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801027ea:	8b 45 08             	mov    0x8(%ebp),%eax
801027ed:	83 c0 18             	add    $0x18,%eax
801027f0:	83 ec 04             	sub    $0x4,%esp
801027f3:	68 80 00 00 00       	push   $0x80
801027f8:	50                   	push   %eax
801027f9:	68 f0 01 00 00       	push   $0x1f0
801027fe:	e8 a3 fd ff ff       	call   801025a6 <outsl>
80102803:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102806:	eb 12                	jmp    8010281a <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102808:	83 ec 08             	sub    $0x8,%esp
8010280b:	6a 20                	push   $0x20
8010280d:	68 f7 01 00 00       	push   $0x1f7
80102812:	e8 70 fd ff ff       	call   80102587 <outb>
80102817:	83 c4 10             	add    $0x10,%esp
  }
}
8010281a:	90                   	nop
8010281b:	c9                   	leave  
8010281c:	c3                   	ret    

8010281d <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010281d:	55                   	push   %ebp
8010281e:	89 e5                	mov    %esp,%ebp
80102820:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102823:	83 ec 0c             	sub    $0xc,%esp
80102826:	68 00 b6 10 80       	push   $0x8010b600
8010282b:	e8 b4 27 00 00       	call   80104fe4 <acquire>
80102830:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102833:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102838:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010283b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010283f:	75 15                	jne    80102856 <ideintr+0x39>
    release(&idelock);
80102841:	83 ec 0c             	sub    $0xc,%esp
80102844:	68 00 b6 10 80       	push   $0x8010b600
80102849:	e8 fd 27 00 00       	call   8010504b <release>
8010284e:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102851:	e9 9a 00 00 00       	jmp    801028f0 <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102859:	8b 40 14             	mov    0x14(%eax),%eax
8010285c:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102864:	8b 00                	mov    (%eax),%eax
80102866:	83 e0 04             	and    $0x4,%eax
80102869:	85 c0                	test   %eax,%eax
8010286b:	75 2d                	jne    8010289a <ideintr+0x7d>
8010286d:	83 ec 0c             	sub    $0xc,%esp
80102870:	6a 01                	push   $0x1
80102872:	e8 55 fd ff ff       	call   801025cc <idewait>
80102877:	83 c4 10             	add    $0x10,%esp
8010287a:	85 c0                	test   %eax,%eax
8010287c:	78 1c                	js     8010289a <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
8010287e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102881:	83 c0 18             	add    $0x18,%eax
80102884:	83 ec 04             	sub    $0x4,%esp
80102887:	68 80 00 00 00       	push   $0x80
8010288c:	50                   	push   %eax
8010288d:	68 f0 01 00 00       	push   $0x1f0
80102892:	e8 ca fc ff ff       	call   80102561 <insl>
80102897:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010289a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010289d:	8b 00                	mov    (%eax),%eax
8010289f:	83 c8 02             	or     $0x2,%eax
801028a2:	89 c2                	mov    %eax,%edx
801028a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028a7:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ac:	8b 00                	mov    (%eax),%eax
801028ae:	83 e0 fb             	and    $0xfffffffb,%eax
801028b1:	89 c2                	mov    %eax,%edx
801028b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b6:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028b8:	83 ec 0c             	sub    $0xc,%esp
801028bb:	ff 75 f4             	pushl  -0xc(%ebp)
801028be:	e8 13 25 00 00       	call   80104dd6 <wakeup>
801028c3:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801028c6:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801028cb:	85 c0                	test   %eax,%eax
801028cd:	74 11                	je     801028e0 <ideintr+0xc3>
    idestart(idequeue);
801028cf:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801028d4:	83 ec 0c             	sub    $0xc,%esp
801028d7:	50                   	push   %eax
801028d8:	e8 e2 fd ff ff       	call   801026bf <idestart>
801028dd:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801028e0:	83 ec 0c             	sub    $0xc,%esp
801028e3:	68 00 b6 10 80       	push   $0x8010b600
801028e8:	e8 5e 27 00 00       	call   8010504b <release>
801028ed:	83 c4 10             	add    $0x10,%esp
}
801028f0:	c9                   	leave  
801028f1:	c3                   	ret    

801028f2 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801028f2:	55                   	push   %ebp
801028f3:	89 e5                	mov    %esp,%ebp
801028f5:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801028f8:	8b 45 08             	mov    0x8(%ebp),%eax
801028fb:	8b 00                	mov    (%eax),%eax
801028fd:	83 e0 01             	and    $0x1,%eax
80102900:	85 c0                	test   %eax,%eax
80102902:	75 0d                	jne    80102911 <iderw+0x1f>
    panic("iderw: buf not busy");
80102904:	83 ec 0c             	sub    $0xc,%esp
80102907:	68 c5 86 10 80       	push   $0x801086c5
8010290c:	e8 55 dc ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102911:	8b 45 08             	mov    0x8(%ebp),%eax
80102914:	8b 00                	mov    (%eax),%eax
80102916:	83 e0 06             	and    $0x6,%eax
80102919:	83 f8 02             	cmp    $0x2,%eax
8010291c:	75 0d                	jne    8010292b <iderw+0x39>
    panic("iderw: nothing to do");
8010291e:	83 ec 0c             	sub    $0xc,%esp
80102921:	68 d9 86 10 80       	push   $0x801086d9
80102926:	e8 3b dc ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
8010292b:	8b 45 08             	mov    0x8(%ebp),%eax
8010292e:	8b 40 04             	mov    0x4(%eax),%eax
80102931:	85 c0                	test   %eax,%eax
80102933:	74 16                	je     8010294b <iderw+0x59>
80102935:	a1 38 b6 10 80       	mov    0x8010b638,%eax
8010293a:	85 c0                	test   %eax,%eax
8010293c:	75 0d                	jne    8010294b <iderw+0x59>
    panic("iderw: ide disk 1 not present");
8010293e:	83 ec 0c             	sub    $0xc,%esp
80102941:	68 ee 86 10 80       	push   $0x801086ee
80102946:	e8 1b dc ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
8010294b:	83 ec 0c             	sub    $0xc,%esp
8010294e:	68 00 b6 10 80       	push   $0x8010b600
80102953:	e8 8c 26 00 00       	call   80104fe4 <acquire>
80102958:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
8010295b:	8b 45 08             	mov    0x8(%ebp),%eax
8010295e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102965:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
8010296c:	eb 0b                	jmp    80102979 <iderw+0x87>
8010296e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102971:	8b 00                	mov    (%eax),%eax
80102973:	83 c0 14             	add    $0x14,%eax
80102976:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010297c:	8b 00                	mov    (%eax),%eax
8010297e:	85 c0                	test   %eax,%eax
80102980:	75 ec                	jne    8010296e <iderw+0x7c>
    ;
  *pp = b;
80102982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102985:	8b 55 08             	mov    0x8(%ebp),%edx
80102988:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
8010298a:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010298f:	3b 45 08             	cmp    0x8(%ebp),%eax
80102992:	75 23                	jne    801029b7 <iderw+0xc5>
    idestart(b);
80102994:	83 ec 0c             	sub    $0xc,%esp
80102997:	ff 75 08             	pushl  0x8(%ebp)
8010299a:	e8 20 fd ff ff       	call   801026bf <idestart>
8010299f:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029a2:	eb 13                	jmp    801029b7 <iderw+0xc5>
    sleep(b, &idelock);
801029a4:	83 ec 08             	sub    $0x8,%esp
801029a7:	68 00 b6 10 80       	push   $0x8010b600
801029ac:	ff 75 08             	pushl  0x8(%ebp)
801029af:	e8 37 23 00 00       	call   80104ceb <sleep>
801029b4:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029b7:	8b 45 08             	mov    0x8(%ebp),%eax
801029ba:	8b 00                	mov    (%eax),%eax
801029bc:	83 e0 06             	and    $0x6,%eax
801029bf:	83 f8 02             	cmp    $0x2,%eax
801029c2:	75 e0                	jne    801029a4 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
801029c4:	83 ec 0c             	sub    $0xc,%esp
801029c7:	68 00 b6 10 80       	push   $0x8010b600
801029cc:	e8 7a 26 00 00       	call   8010504b <release>
801029d1:	83 c4 10             	add    $0x10,%esp
}
801029d4:	90                   	nop
801029d5:	c9                   	leave  
801029d6:	c3                   	ret    

801029d7 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801029d7:	55                   	push   %ebp
801029d8:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029da:	a1 34 22 11 80       	mov    0x80112234,%eax
801029df:	8b 55 08             	mov    0x8(%ebp),%edx
801029e2:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801029e4:	a1 34 22 11 80       	mov    0x80112234,%eax
801029e9:	8b 40 10             	mov    0x10(%eax),%eax
}
801029ec:	5d                   	pop    %ebp
801029ed:	c3                   	ret    

801029ee <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801029ee:	55                   	push   %ebp
801029ef:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029f1:	a1 34 22 11 80       	mov    0x80112234,%eax
801029f6:	8b 55 08             	mov    0x8(%ebp),%edx
801029f9:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801029fb:	a1 34 22 11 80       	mov    0x80112234,%eax
80102a00:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a03:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a06:	90                   	nop
80102a07:	5d                   	pop    %ebp
80102a08:	c3                   	ret    

80102a09 <ioapicinit>:

void
ioapicinit(void)
{
80102a09:	55                   	push   %ebp
80102a0a:	89 e5                	mov    %esp,%ebp
80102a0c:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102a0f:	a1 64 23 11 80       	mov    0x80112364,%eax
80102a14:	85 c0                	test   %eax,%eax
80102a16:	0f 84 a0 00 00 00    	je     80102abc <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a1c:	c7 05 34 22 11 80 00 	movl   $0xfec00000,0x80112234
80102a23:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a26:	6a 01                	push   $0x1
80102a28:	e8 aa ff ff ff       	call   801029d7 <ioapicread>
80102a2d:	83 c4 04             	add    $0x4,%esp
80102a30:	c1 e8 10             	shr    $0x10,%eax
80102a33:	25 ff 00 00 00       	and    $0xff,%eax
80102a38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a3b:	6a 00                	push   $0x0
80102a3d:	e8 95 ff ff ff       	call   801029d7 <ioapicread>
80102a42:	83 c4 04             	add    $0x4,%esp
80102a45:	c1 e8 18             	shr    $0x18,%eax
80102a48:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a4b:	0f b6 05 60 23 11 80 	movzbl 0x80112360,%eax
80102a52:	0f b6 c0             	movzbl %al,%eax
80102a55:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102a58:	74 10                	je     80102a6a <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a5a:	83 ec 0c             	sub    $0xc,%esp
80102a5d:	68 0c 87 10 80       	push   $0x8010870c
80102a62:	e8 5f d9 ff ff       	call   801003c6 <cprintf>
80102a67:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a71:	eb 3f                	jmp    80102ab2 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a76:	83 c0 20             	add    $0x20,%eax
80102a79:	0d 00 00 01 00       	or     $0x10000,%eax
80102a7e:	89 c2                	mov    %eax,%edx
80102a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a83:	83 c0 08             	add    $0x8,%eax
80102a86:	01 c0                	add    %eax,%eax
80102a88:	83 ec 08             	sub    $0x8,%esp
80102a8b:	52                   	push   %edx
80102a8c:	50                   	push   %eax
80102a8d:	e8 5c ff ff ff       	call   801029ee <ioapicwrite>
80102a92:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a98:	83 c0 08             	add    $0x8,%eax
80102a9b:	01 c0                	add    %eax,%eax
80102a9d:	83 c0 01             	add    $0x1,%eax
80102aa0:	83 ec 08             	sub    $0x8,%esp
80102aa3:	6a 00                	push   $0x0
80102aa5:	50                   	push   %eax
80102aa6:	e8 43 ff ff ff       	call   801029ee <ioapicwrite>
80102aab:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102aae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ab8:	7e b9                	jle    80102a73 <ioapicinit+0x6a>
80102aba:	eb 01                	jmp    80102abd <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102abc:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102abd:	c9                   	leave  
80102abe:	c3                   	ret    

80102abf <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102abf:	55                   	push   %ebp
80102ac0:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102ac2:	a1 64 23 11 80       	mov    0x80112364,%eax
80102ac7:	85 c0                	test   %eax,%eax
80102ac9:	74 39                	je     80102b04 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102acb:	8b 45 08             	mov    0x8(%ebp),%eax
80102ace:	83 c0 20             	add    $0x20,%eax
80102ad1:	89 c2                	mov    %eax,%edx
80102ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ad6:	83 c0 08             	add    $0x8,%eax
80102ad9:	01 c0                	add    %eax,%eax
80102adb:	52                   	push   %edx
80102adc:	50                   	push   %eax
80102add:	e8 0c ff ff ff       	call   801029ee <ioapicwrite>
80102ae2:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ae8:	c1 e0 18             	shl    $0x18,%eax
80102aeb:	89 c2                	mov    %eax,%edx
80102aed:	8b 45 08             	mov    0x8(%ebp),%eax
80102af0:	83 c0 08             	add    $0x8,%eax
80102af3:	01 c0                	add    %eax,%eax
80102af5:	83 c0 01             	add    $0x1,%eax
80102af8:	52                   	push   %edx
80102af9:	50                   	push   %eax
80102afa:	e8 ef fe ff ff       	call   801029ee <ioapicwrite>
80102aff:	83 c4 08             	add    $0x8,%esp
80102b02:	eb 01                	jmp    80102b05 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102b04:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102b05:	c9                   	leave  
80102b06:	c3                   	ret    

80102b07 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102b07:	55                   	push   %ebp
80102b08:	89 e5                	mov    %esp,%ebp
80102b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0d:	05 00 00 00 80       	add    $0x80000000,%eax
80102b12:	5d                   	pop    %ebp
80102b13:	c3                   	ret    

80102b14 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b14:	55                   	push   %ebp
80102b15:	89 e5                	mov    %esp,%ebp
80102b17:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b1a:	83 ec 08             	sub    $0x8,%esp
80102b1d:	68 3e 87 10 80       	push   $0x8010873e
80102b22:	68 40 22 11 80       	push   $0x80112240
80102b27:	e8 96 24 00 00       	call   80104fc2 <initlock>
80102b2c:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b2f:	c7 05 74 22 11 80 00 	movl   $0x0,0x80112274
80102b36:	00 00 00 
  freerange(vstart, vend);
80102b39:	83 ec 08             	sub    $0x8,%esp
80102b3c:	ff 75 0c             	pushl  0xc(%ebp)
80102b3f:	ff 75 08             	pushl  0x8(%ebp)
80102b42:	e8 2a 00 00 00       	call   80102b71 <freerange>
80102b47:	83 c4 10             	add    $0x10,%esp
}
80102b4a:	90                   	nop
80102b4b:	c9                   	leave  
80102b4c:	c3                   	ret    

80102b4d <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b4d:	55                   	push   %ebp
80102b4e:	89 e5                	mov    %esp,%ebp
80102b50:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b53:	83 ec 08             	sub    $0x8,%esp
80102b56:	ff 75 0c             	pushl  0xc(%ebp)
80102b59:	ff 75 08             	pushl  0x8(%ebp)
80102b5c:	e8 10 00 00 00       	call   80102b71 <freerange>
80102b61:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b64:	c7 05 74 22 11 80 01 	movl   $0x1,0x80112274
80102b6b:	00 00 00 
}
80102b6e:	90                   	nop
80102b6f:	c9                   	leave  
80102b70:	c3                   	ret    

80102b71 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b71:	55                   	push   %ebp
80102b72:	89 e5                	mov    %esp,%ebp
80102b74:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102b77:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7a:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b7f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102b84:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b87:	eb 15                	jmp    80102b9e <freerange+0x2d>
    kfree(p);
80102b89:	83 ec 0c             	sub    $0xc,%esp
80102b8c:	ff 75 f4             	pushl  -0xc(%ebp)
80102b8f:	e8 1a 00 00 00       	call   80102bae <kfree>
80102b94:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b97:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba1:	05 00 10 00 00       	add    $0x1000,%eax
80102ba6:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102ba9:	76 de                	jbe    80102b89 <freerange+0x18>
    kfree(p);
}
80102bab:	90                   	nop
80102bac:	c9                   	leave  
80102bad:	c3                   	ret    

80102bae <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bae:	55                   	push   %ebp
80102baf:	89 e5                	mov    %esp,%ebp
80102bb1:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb7:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bbc:	85 c0                	test   %eax,%eax
80102bbe:	75 1b                	jne    80102bdb <kfree+0x2d>
80102bc0:	81 7d 08 5c 51 11 80 	cmpl   $0x8011515c,0x8(%ebp)
80102bc7:	72 12                	jb     80102bdb <kfree+0x2d>
80102bc9:	ff 75 08             	pushl  0x8(%ebp)
80102bcc:	e8 36 ff ff ff       	call   80102b07 <v2p>
80102bd1:	83 c4 04             	add    $0x4,%esp
80102bd4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102bd9:	76 0d                	jbe    80102be8 <kfree+0x3a>
    panic("kfree");
80102bdb:	83 ec 0c             	sub    $0xc,%esp
80102bde:	68 43 87 10 80       	push   $0x80108743
80102be3:	e8 7e d9 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102be8:	83 ec 04             	sub    $0x4,%esp
80102beb:	68 00 10 00 00       	push   $0x1000
80102bf0:	6a 01                	push   $0x1
80102bf2:	ff 75 08             	pushl  0x8(%ebp)
80102bf5:	e8 4d 26 00 00       	call   80105247 <memset>
80102bfa:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102bfd:	a1 74 22 11 80       	mov    0x80112274,%eax
80102c02:	85 c0                	test   %eax,%eax
80102c04:	74 10                	je     80102c16 <kfree+0x68>
    acquire(&kmem.lock);
80102c06:	83 ec 0c             	sub    $0xc,%esp
80102c09:	68 40 22 11 80       	push   $0x80112240
80102c0e:	e8 d1 23 00 00       	call   80104fe4 <acquire>
80102c13:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c16:	8b 45 08             	mov    0x8(%ebp),%eax
80102c19:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c1c:	8b 15 78 22 11 80    	mov    0x80112278,%edx
80102c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c25:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c2a:	a3 78 22 11 80       	mov    %eax,0x80112278
  if(kmem.use_lock)
80102c2f:	a1 74 22 11 80       	mov    0x80112274,%eax
80102c34:	85 c0                	test   %eax,%eax
80102c36:	74 10                	je     80102c48 <kfree+0x9a>
    release(&kmem.lock);
80102c38:	83 ec 0c             	sub    $0xc,%esp
80102c3b:	68 40 22 11 80       	push   $0x80112240
80102c40:	e8 06 24 00 00       	call   8010504b <release>
80102c45:	83 c4 10             	add    $0x10,%esp
}
80102c48:	90                   	nop
80102c49:	c9                   	leave  
80102c4a:	c3                   	ret    

80102c4b <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c4b:	55                   	push   %ebp
80102c4c:	89 e5                	mov    %esp,%ebp
80102c4e:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c51:	a1 74 22 11 80       	mov    0x80112274,%eax
80102c56:	85 c0                	test   %eax,%eax
80102c58:	74 10                	je     80102c6a <kalloc+0x1f>
    acquire(&kmem.lock);
80102c5a:	83 ec 0c             	sub    $0xc,%esp
80102c5d:	68 40 22 11 80       	push   $0x80112240
80102c62:	e8 7d 23 00 00       	call   80104fe4 <acquire>
80102c67:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102c6a:	a1 78 22 11 80       	mov    0x80112278,%eax
80102c6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102c72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c76:	74 0a                	je     80102c82 <kalloc+0x37>
    kmem.freelist = r->next;
80102c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c7b:	8b 00                	mov    (%eax),%eax
80102c7d:	a3 78 22 11 80       	mov    %eax,0x80112278
  if(kmem.use_lock)
80102c82:	a1 74 22 11 80       	mov    0x80112274,%eax
80102c87:	85 c0                	test   %eax,%eax
80102c89:	74 10                	je     80102c9b <kalloc+0x50>
    release(&kmem.lock);
80102c8b:	83 ec 0c             	sub    $0xc,%esp
80102c8e:	68 40 22 11 80       	push   $0x80112240
80102c93:	e8 b3 23 00 00       	call   8010504b <release>
80102c98:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102c9e:	c9                   	leave  
80102c9f:	c3                   	ret    

80102ca0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102ca0:	55                   	push   %ebp
80102ca1:	89 e5                	mov    %esp,%ebp
80102ca3:	83 ec 14             	sub    $0x14,%esp
80102ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ca9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cad:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cb1:	89 c2                	mov    %eax,%edx
80102cb3:	ec                   	in     (%dx),%al
80102cb4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cb7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cbb:	c9                   	leave  
80102cbc:	c3                   	ret    

80102cbd <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cbd:	55                   	push   %ebp
80102cbe:	89 e5                	mov    %esp,%ebp
80102cc0:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102cc3:	6a 64                	push   $0x64
80102cc5:	e8 d6 ff ff ff       	call   80102ca0 <inb>
80102cca:	83 c4 04             	add    $0x4,%esp
80102ccd:	0f b6 c0             	movzbl %al,%eax
80102cd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cd6:	83 e0 01             	and    $0x1,%eax
80102cd9:	85 c0                	test   %eax,%eax
80102cdb:	75 0a                	jne    80102ce7 <kbdgetc+0x2a>
    return -1;
80102cdd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ce2:	e9 23 01 00 00       	jmp    80102e0a <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102ce7:	6a 60                	push   $0x60
80102ce9:	e8 b2 ff ff ff       	call   80102ca0 <inb>
80102cee:	83 c4 04             	add    $0x4,%esp
80102cf1:	0f b6 c0             	movzbl %al,%eax
80102cf4:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102cf7:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102cfe:	75 17                	jne    80102d17 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d00:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d05:	83 c8 40             	or     $0x40,%eax
80102d08:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102d0d:	b8 00 00 00 00       	mov    $0x0,%eax
80102d12:	e9 f3 00 00 00       	jmp    80102e0a <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d17:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d1a:	25 80 00 00 00       	and    $0x80,%eax
80102d1f:	85 c0                	test   %eax,%eax
80102d21:	74 45                	je     80102d68 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d23:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d28:	83 e0 40             	and    $0x40,%eax
80102d2b:	85 c0                	test   %eax,%eax
80102d2d:	75 08                	jne    80102d37 <kbdgetc+0x7a>
80102d2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d32:	83 e0 7f             	and    $0x7f,%eax
80102d35:	eb 03                	jmp    80102d3a <kbdgetc+0x7d>
80102d37:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d3a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d40:	05 20 90 10 80       	add    $0x80109020,%eax
80102d45:	0f b6 00             	movzbl (%eax),%eax
80102d48:	83 c8 40             	or     $0x40,%eax
80102d4b:	0f b6 c0             	movzbl %al,%eax
80102d4e:	f7 d0                	not    %eax
80102d50:	89 c2                	mov    %eax,%edx
80102d52:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d57:	21 d0                	and    %edx,%eax
80102d59:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102d5e:	b8 00 00 00 00       	mov    $0x0,%eax
80102d63:	e9 a2 00 00 00       	jmp    80102e0a <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d68:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d6d:	83 e0 40             	and    $0x40,%eax
80102d70:	85 c0                	test   %eax,%eax
80102d72:	74 14                	je     80102d88 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102d74:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102d7b:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d80:	83 e0 bf             	and    $0xffffffbf,%eax
80102d83:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102d88:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d8b:	05 20 90 10 80       	add    $0x80109020,%eax
80102d90:	0f b6 00             	movzbl (%eax),%eax
80102d93:	0f b6 d0             	movzbl %al,%edx
80102d96:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d9b:	09 d0                	or     %edx,%eax
80102d9d:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102da2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102da5:	05 20 91 10 80       	add    $0x80109120,%eax
80102daa:	0f b6 00             	movzbl (%eax),%eax
80102dad:	0f b6 d0             	movzbl %al,%edx
80102db0:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102db5:	31 d0                	xor    %edx,%eax
80102db7:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102dbc:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102dc1:	83 e0 03             	and    $0x3,%eax
80102dc4:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102dcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dce:	01 d0                	add    %edx,%eax
80102dd0:	0f b6 00             	movzbl (%eax),%eax
80102dd3:	0f b6 c0             	movzbl %al,%eax
80102dd6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102dd9:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102dde:	83 e0 08             	and    $0x8,%eax
80102de1:	85 c0                	test   %eax,%eax
80102de3:	74 22                	je     80102e07 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102de5:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102de9:	76 0c                	jbe    80102df7 <kbdgetc+0x13a>
80102deb:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102def:	77 06                	ja     80102df7 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102df1:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102df5:	eb 10                	jmp    80102e07 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102df7:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102dfb:	76 0a                	jbe    80102e07 <kbdgetc+0x14a>
80102dfd:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e01:	77 04                	ja     80102e07 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e03:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e07:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e0a:	c9                   	leave  
80102e0b:	c3                   	ret    

80102e0c <kbdintr>:

void
kbdintr(void)
{
80102e0c:	55                   	push   %ebp
80102e0d:	89 e5                	mov    %esp,%ebp
80102e0f:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e12:	83 ec 0c             	sub    $0xc,%esp
80102e15:	68 bd 2c 10 80       	push   $0x80102cbd
80102e1a:	e8 be d9 ff ff       	call   801007dd <consoleintr>
80102e1f:	83 c4 10             	add    $0x10,%esp
}
80102e22:	90                   	nop
80102e23:	c9                   	leave  
80102e24:	c3                   	ret    

80102e25 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e25:	55                   	push   %ebp
80102e26:	89 e5                	mov    %esp,%ebp
80102e28:	83 ec 14             	sub    $0x14,%esp
80102e2b:	8b 45 08             	mov    0x8(%ebp),%eax
80102e2e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e32:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e36:	89 c2                	mov    %eax,%edx
80102e38:	ec                   	in     (%dx),%al
80102e39:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e3c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e40:	c9                   	leave  
80102e41:	c3                   	ret    

80102e42 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102e42:	55                   	push   %ebp
80102e43:	89 e5                	mov    %esp,%ebp
80102e45:	83 ec 08             	sub    $0x8,%esp
80102e48:	8b 55 08             	mov    0x8(%ebp),%edx
80102e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e4e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e52:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e55:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e59:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e5d:	ee                   	out    %al,(%dx)
}
80102e5e:	90                   	nop
80102e5f:	c9                   	leave  
80102e60:	c3                   	ret    

80102e61 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102e61:	55                   	push   %ebp
80102e62:	89 e5                	mov    %esp,%ebp
80102e64:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102e67:	9c                   	pushf  
80102e68:	58                   	pop    %eax
80102e69:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102e6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102e6f:	c9                   	leave  
80102e70:	c3                   	ret    

80102e71 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102e71:	55                   	push   %ebp
80102e72:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e74:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102e79:	8b 55 08             	mov    0x8(%ebp),%edx
80102e7c:	c1 e2 02             	shl    $0x2,%edx
80102e7f:	01 c2                	add    %eax,%edx
80102e81:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e84:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102e86:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102e8b:	83 c0 20             	add    $0x20,%eax
80102e8e:	8b 00                	mov    (%eax),%eax
}
80102e90:	90                   	nop
80102e91:	5d                   	pop    %ebp
80102e92:	c3                   	ret    

80102e93 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102e93:	55                   	push   %ebp
80102e94:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102e96:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102e9b:	85 c0                	test   %eax,%eax
80102e9d:	0f 84 0b 01 00 00    	je     80102fae <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ea3:	68 3f 01 00 00       	push   $0x13f
80102ea8:	6a 3c                	push   $0x3c
80102eaa:	e8 c2 ff ff ff       	call   80102e71 <lapicw>
80102eaf:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102eb2:	6a 0b                	push   $0xb
80102eb4:	68 f8 00 00 00       	push   $0xf8
80102eb9:	e8 b3 ff ff ff       	call   80102e71 <lapicw>
80102ebe:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102ec1:	68 20 00 02 00       	push   $0x20020
80102ec6:	68 c8 00 00 00       	push   $0xc8
80102ecb:	e8 a1 ff ff ff       	call   80102e71 <lapicw>
80102ed0:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102ed3:	68 80 96 98 00       	push   $0x989680
80102ed8:	68 e0 00 00 00       	push   $0xe0
80102edd:	e8 8f ff ff ff       	call   80102e71 <lapicw>
80102ee2:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102ee5:	68 00 00 01 00       	push   $0x10000
80102eea:	68 d4 00 00 00       	push   $0xd4
80102eef:	e8 7d ff ff ff       	call   80102e71 <lapicw>
80102ef4:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102ef7:	68 00 00 01 00       	push   $0x10000
80102efc:	68 d8 00 00 00       	push   $0xd8
80102f01:	e8 6b ff ff ff       	call   80102e71 <lapicw>
80102f06:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f09:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102f0e:	83 c0 30             	add    $0x30,%eax
80102f11:	8b 00                	mov    (%eax),%eax
80102f13:	c1 e8 10             	shr    $0x10,%eax
80102f16:	0f b6 c0             	movzbl %al,%eax
80102f19:	83 f8 03             	cmp    $0x3,%eax
80102f1c:	76 12                	jbe    80102f30 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102f1e:	68 00 00 01 00       	push   $0x10000
80102f23:	68 d0 00 00 00       	push   $0xd0
80102f28:	e8 44 ff ff ff       	call   80102e71 <lapicw>
80102f2d:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f30:	6a 33                	push   $0x33
80102f32:	68 dc 00 00 00       	push   $0xdc
80102f37:	e8 35 ff ff ff       	call   80102e71 <lapicw>
80102f3c:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f3f:	6a 00                	push   $0x0
80102f41:	68 a0 00 00 00       	push   $0xa0
80102f46:	e8 26 ff ff ff       	call   80102e71 <lapicw>
80102f4b:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f4e:	6a 00                	push   $0x0
80102f50:	68 a0 00 00 00       	push   $0xa0
80102f55:	e8 17 ff ff ff       	call   80102e71 <lapicw>
80102f5a:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f5d:	6a 00                	push   $0x0
80102f5f:	6a 2c                	push   $0x2c
80102f61:	e8 0b ff ff ff       	call   80102e71 <lapicw>
80102f66:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f69:	6a 00                	push   $0x0
80102f6b:	68 c4 00 00 00       	push   $0xc4
80102f70:	e8 fc fe ff ff       	call   80102e71 <lapicw>
80102f75:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f78:	68 00 85 08 00       	push   $0x88500
80102f7d:	68 c0 00 00 00       	push   $0xc0
80102f82:	e8 ea fe ff ff       	call   80102e71 <lapicw>
80102f87:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102f8a:	90                   	nop
80102f8b:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102f90:	05 00 03 00 00       	add    $0x300,%eax
80102f95:	8b 00                	mov    (%eax),%eax
80102f97:	25 00 10 00 00       	and    $0x1000,%eax
80102f9c:	85 c0                	test   %eax,%eax
80102f9e:	75 eb                	jne    80102f8b <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fa0:	6a 00                	push   $0x0
80102fa2:	6a 20                	push   $0x20
80102fa4:	e8 c8 fe ff ff       	call   80102e71 <lapicw>
80102fa9:	83 c4 08             	add    $0x8,%esp
80102fac:	eb 01                	jmp    80102faf <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102fae:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102faf:	c9                   	leave  
80102fb0:	c3                   	ret    

80102fb1 <cpunum>:

int
cpunum(void)
{
80102fb1:	55                   	push   %ebp
80102fb2:	89 e5                	mov    %esp,%ebp
80102fb4:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102fb7:	e8 a5 fe ff ff       	call   80102e61 <readeflags>
80102fbc:	25 00 02 00 00       	and    $0x200,%eax
80102fc1:	85 c0                	test   %eax,%eax
80102fc3:	74 26                	je     80102feb <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102fc5:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102fca:	8d 50 01             	lea    0x1(%eax),%edx
80102fcd:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
80102fd3:	85 c0                	test   %eax,%eax
80102fd5:	75 14                	jne    80102feb <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80102fd7:	8b 45 04             	mov    0x4(%ebp),%eax
80102fda:	83 ec 08             	sub    $0x8,%esp
80102fdd:	50                   	push   %eax
80102fde:	68 4c 87 10 80       	push   $0x8010874c
80102fe3:	e8 de d3 ff ff       	call   801003c6 <cprintf>
80102fe8:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80102feb:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102ff0:	85 c0                	test   %eax,%eax
80102ff2:	74 0f                	je     80103003 <cpunum+0x52>
    return lapic[ID]>>24;
80102ff4:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102ff9:	83 c0 20             	add    $0x20,%eax
80102ffc:	8b 00                	mov    (%eax),%eax
80102ffe:	c1 e8 18             	shr    $0x18,%eax
80103001:	eb 05                	jmp    80103008 <cpunum+0x57>
  return 0;
80103003:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103008:	c9                   	leave  
80103009:	c3                   	ret    

8010300a <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010300a:	55                   	push   %ebp
8010300b:	89 e5                	mov    %esp,%ebp
  if(lapic)
8010300d:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80103012:	85 c0                	test   %eax,%eax
80103014:	74 0c                	je     80103022 <lapiceoi+0x18>
    lapicw(EOI, 0);
80103016:	6a 00                	push   $0x0
80103018:	6a 2c                	push   $0x2c
8010301a:	e8 52 fe ff ff       	call   80102e71 <lapicw>
8010301f:	83 c4 08             	add    $0x8,%esp
}
80103022:	90                   	nop
80103023:	c9                   	leave  
80103024:	c3                   	ret    

80103025 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103025:	55                   	push   %ebp
80103026:	89 e5                	mov    %esp,%ebp
}
80103028:	90                   	nop
80103029:	5d                   	pop    %ebp
8010302a:	c3                   	ret    

8010302b <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010302b:	55                   	push   %ebp
8010302c:	89 e5                	mov    %esp,%ebp
8010302e:	83 ec 14             	sub    $0x14,%esp
80103031:	8b 45 08             	mov    0x8(%ebp),%eax
80103034:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103037:	6a 0f                	push   $0xf
80103039:	6a 70                	push   $0x70
8010303b:	e8 02 fe ff ff       	call   80102e42 <outb>
80103040:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103043:	6a 0a                	push   $0xa
80103045:	6a 71                	push   $0x71
80103047:	e8 f6 fd ff ff       	call   80102e42 <outb>
8010304c:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010304f:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103056:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103059:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010305e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103061:	83 c0 02             	add    $0x2,%eax
80103064:	8b 55 0c             	mov    0xc(%ebp),%edx
80103067:	c1 ea 04             	shr    $0x4,%edx
8010306a:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010306d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103071:	c1 e0 18             	shl    $0x18,%eax
80103074:	50                   	push   %eax
80103075:	68 c4 00 00 00       	push   $0xc4
8010307a:	e8 f2 fd ff ff       	call   80102e71 <lapicw>
8010307f:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103082:	68 00 c5 00 00       	push   $0xc500
80103087:	68 c0 00 00 00       	push   $0xc0
8010308c:	e8 e0 fd ff ff       	call   80102e71 <lapicw>
80103091:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103094:	68 c8 00 00 00       	push   $0xc8
80103099:	e8 87 ff ff ff       	call   80103025 <microdelay>
8010309e:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030a1:	68 00 85 00 00       	push   $0x8500
801030a6:	68 c0 00 00 00       	push   $0xc0
801030ab:	e8 c1 fd ff ff       	call   80102e71 <lapicw>
801030b0:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030b3:	6a 64                	push   $0x64
801030b5:	e8 6b ff ff ff       	call   80103025 <microdelay>
801030ba:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030bd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030c4:	eb 3d                	jmp    80103103 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801030c6:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030ca:	c1 e0 18             	shl    $0x18,%eax
801030cd:	50                   	push   %eax
801030ce:	68 c4 00 00 00       	push   $0xc4
801030d3:	e8 99 fd ff ff       	call   80102e71 <lapicw>
801030d8:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030db:	8b 45 0c             	mov    0xc(%ebp),%eax
801030de:	c1 e8 0c             	shr    $0xc,%eax
801030e1:	80 cc 06             	or     $0x6,%ah
801030e4:	50                   	push   %eax
801030e5:	68 c0 00 00 00       	push   $0xc0
801030ea:	e8 82 fd ff ff       	call   80102e71 <lapicw>
801030ef:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801030f2:	68 c8 00 00 00       	push   $0xc8
801030f7:	e8 29 ff ff ff       	call   80103025 <microdelay>
801030fc:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030ff:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103103:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103107:	7e bd                	jle    801030c6 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103109:	90                   	nop
8010310a:	c9                   	leave  
8010310b:	c3                   	ret    

8010310c <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010310c:	55                   	push   %ebp
8010310d:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010310f:	8b 45 08             	mov    0x8(%ebp),%eax
80103112:	0f b6 c0             	movzbl %al,%eax
80103115:	50                   	push   %eax
80103116:	6a 70                	push   $0x70
80103118:	e8 25 fd ff ff       	call   80102e42 <outb>
8010311d:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103120:	68 c8 00 00 00       	push   $0xc8
80103125:	e8 fb fe ff ff       	call   80103025 <microdelay>
8010312a:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010312d:	6a 71                	push   $0x71
8010312f:	e8 f1 fc ff ff       	call   80102e25 <inb>
80103134:	83 c4 04             	add    $0x4,%esp
80103137:	0f b6 c0             	movzbl %al,%eax
}
8010313a:	c9                   	leave  
8010313b:	c3                   	ret    

8010313c <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010313c:	55                   	push   %ebp
8010313d:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010313f:	6a 00                	push   $0x0
80103141:	e8 c6 ff ff ff       	call   8010310c <cmos_read>
80103146:	83 c4 04             	add    $0x4,%esp
80103149:	89 c2                	mov    %eax,%edx
8010314b:	8b 45 08             	mov    0x8(%ebp),%eax
8010314e:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103150:	6a 02                	push   $0x2
80103152:	e8 b5 ff ff ff       	call   8010310c <cmos_read>
80103157:	83 c4 04             	add    $0x4,%esp
8010315a:	89 c2                	mov    %eax,%edx
8010315c:	8b 45 08             	mov    0x8(%ebp),%eax
8010315f:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103162:	6a 04                	push   $0x4
80103164:	e8 a3 ff ff ff       	call   8010310c <cmos_read>
80103169:	83 c4 04             	add    $0x4,%esp
8010316c:	89 c2                	mov    %eax,%edx
8010316e:	8b 45 08             	mov    0x8(%ebp),%eax
80103171:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103174:	6a 07                	push   $0x7
80103176:	e8 91 ff ff ff       	call   8010310c <cmos_read>
8010317b:	83 c4 04             	add    $0x4,%esp
8010317e:	89 c2                	mov    %eax,%edx
80103180:	8b 45 08             	mov    0x8(%ebp),%eax
80103183:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103186:	6a 08                	push   $0x8
80103188:	e8 7f ff ff ff       	call   8010310c <cmos_read>
8010318d:	83 c4 04             	add    $0x4,%esp
80103190:	89 c2                	mov    %eax,%edx
80103192:	8b 45 08             	mov    0x8(%ebp),%eax
80103195:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103198:	6a 09                	push   $0x9
8010319a:	e8 6d ff ff ff       	call   8010310c <cmos_read>
8010319f:	83 c4 04             	add    $0x4,%esp
801031a2:	89 c2                	mov    %eax,%edx
801031a4:	8b 45 08             	mov    0x8(%ebp),%eax
801031a7:	89 50 14             	mov    %edx,0x14(%eax)
}
801031aa:	90                   	nop
801031ab:	c9                   	leave  
801031ac:	c3                   	ret    

801031ad <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031ad:	55                   	push   %ebp
801031ae:	89 e5                	mov    %esp,%ebp
801031b0:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031b3:	6a 0b                	push   $0xb
801031b5:	e8 52 ff ff ff       	call   8010310c <cmos_read>
801031ba:	83 c4 04             	add    $0x4,%esp
801031bd:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c3:	83 e0 04             	and    $0x4,%eax
801031c6:	85 c0                	test   %eax,%eax
801031c8:	0f 94 c0             	sete   %al
801031cb:	0f b6 c0             	movzbl %al,%eax
801031ce:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801031d1:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031d4:	50                   	push   %eax
801031d5:	e8 62 ff ff ff       	call   8010313c <fill_rtcdate>
801031da:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801031dd:	6a 0a                	push   $0xa
801031df:	e8 28 ff ff ff       	call   8010310c <cmos_read>
801031e4:	83 c4 04             	add    $0x4,%esp
801031e7:	25 80 00 00 00       	and    $0x80,%eax
801031ec:	85 c0                	test   %eax,%eax
801031ee:	75 27                	jne    80103217 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801031f0:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031f3:	50                   	push   %eax
801031f4:	e8 43 ff ff ff       	call   8010313c <fill_rtcdate>
801031f9:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801031fc:	83 ec 04             	sub    $0x4,%esp
801031ff:	6a 18                	push   $0x18
80103201:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103204:	50                   	push   %eax
80103205:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103208:	50                   	push   %eax
80103209:	e8 a0 20 00 00       	call   801052ae <memcmp>
8010320e:	83 c4 10             	add    $0x10,%esp
80103211:	85 c0                	test   %eax,%eax
80103213:	74 05                	je     8010321a <cmostime+0x6d>
80103215:	eb ba                	jmp    801031d1 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103217:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103218:	eb b7                	jmp    801031d1 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
8010321a:	90                   	nop
  }

  // convert
  if (bcd) {
8010321b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010321f:	0f 84 b4 00 00 00    	je     801032d9 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103225:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103228:	c1 e8 04             	shr    $0x4,%eax
8010322b:	89 c2                	mov    %eax,%edx
8010322d:	89 d0                	mov    %edx,%eax
8010322f:	c1 e0 02             	shl    $0x2,%eax
80103232:	01 d0                	add    %edx,%eax
80103234:	01 c0                	add    %eax,%eax
80103236:	89 c2                	mov    %eax,%edx
80103238:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010323b:	83 e0 0f             	and    $0xf,%eax
8010323e:	01 d0                	add    %edx,%eax
80103240:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103243:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103246:	c1 e8 04             	shr    $0x4,%eax
80103249:	89 c2                	mov    %eax,%edx
8010324b:	89 d0                	mov    %edx,%eax
8010324d:	c1 e0 02             	shl    $0x2,%eax
80103250:	01 d0                	add    %edx,%eax
80103252:	01 c0                	add    %eax,%eax
80103254:	89 c2                	mov    %eax,%edx
80103256:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103259:	83 e0 0f             	and    $0xf,%eax
8010325c:	01 d0                	add    %edx,%eax
8010325e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103261:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103264:	c1 e8 04             	shr    $0x4,%eax
80103267:	89 c2                	mov    %eax,%edx
80103269:	89 d0                	mov    %edx,%eax
8010326b:	c1 e0 02             	shl    $0x2,%eax
8010326e:	01 d0                	add    %edx,%eax
80103270:	01 c0                	add    %eax,%eax
80103272:	89 c2                	mov    %eax,%edx
80103274:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103277:	83 e0 0f             	and    $0xf,%eax
8010327a:	01 d0                	add    %edx,%eax
8010327c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010327f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103282:	c1 e8 04             	shr    $0x4,%eax
80103285:	89 c2                	mov    %eax,%edx
80103287:	89 d0                	mov    %edx,%eax
80103289:	c1 e0 02             	shl    $0x2,%eax
8010328c:	01 d0                	add    %edx,%eax
8010328e:	01 c0                	add    %eax,%eax
80103290:	89 c2                	mov    %eax,%edx
80103292:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103295:	83 e0 0f             	and    $0xf,%eax
80103298:	01 d0                	add    %edx,%eax
8010329a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010329d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032a0:	c1 e8 04             	shr    $0x4,%eax
801032a3:	89 c2                	mov    %eax,%edx
801032a5:	89 d0                	mov    %edx,%eax
801032a7:	c1 e0 02             	shl    $0x2,%eax
801032aa:	01 d0                	add    %edx,%eax
801032ac:	01 c0                	add    %eax,%eax
801032ae:	89 c2                	mov    %eax,%edx
801032b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032b3:	83 e0 0f             	and    $0xf,%eax
801032b6:	01 d0                	add    %edx,%eax
801032b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032be:	c1 e8 04             	shr    $0x4,%eax
801032c1:	89 c2                	mov    %eax,%edx
801032c3:	89 d0                	mov    %edx,%eax
801032c5:	c1 e0 02             	shl    $0x2,%eax
801032c8:	01 d0                	add    %edx,%eax
801032ca:	01 c0                	add    %eax,%eax
801032cc:	89 c2                	mov    %eax,%edx
801032ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032d1:	83 e0 0f             	and    $0xf,%eax
801032d4:	01 d0                	add    %edx,%eax
801032d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032d9:	8b 45 08             	mov    0x8(%ebp),%eax
801032dc:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032df:	89 10                	mov    %edx,(%eax)
801032e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032e4:	89 50 04             	mov    %edx,0x4(%eax)
801032e7:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032ea:	89 50 08             	mov    %edx,0x8(%eax)
801032ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032f0:	89 50 0c             	mov    %edx,0xc(%eax)
801032f3:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032f6:	89 50 10             	mov    %edx,0x10(%eax)
801032f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032fc:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032ff:	8b 45 08             	mov    0x8(%ebp),%eax
80103302:	8b 40 14             	mov    0x14(%eax),%eax
80103305:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010330b:	8b 45 08             	mov    0x8(%ebp),%eax
8010330e:	89 50 14             	mov    %edx,0x14(%eax)
}
80103311:	90                   	nop
80103312:	c9                   	leave  
80103313:	c3                   	ret    

80103314 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103314:	55                   	push   %ebp
80103315:	89 e5                	mov    %esp,%ebp
80103317:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010331a:	83 ec 08             	sub    $0x8,%esp
8010331d:	68 78 87 10 80       	push   $0x80108778
80103322:	68 80 22 11 80       	push   $0x80112280
80103327:	e8 96 1c 00 00       	call   80104fc2 <initlock>
8010332c:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010332f:	83 ec 08             	sub    $0x8,%esp
80103332:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103335:	50                   	push   %eax
80103336:	ff 75 08             	pushl  0x8(%ebp)
80103339:	e8 2b e0 ff ff       	call   80101369 <readsb>
8010333e:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103341:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103344:	a3 b4 22 11 80       	mov    %eax,0x801122b4
  log.size = sb.nlog;
80103349:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010334c:	a3 b8 22 11 80       	mov    %eax,0x801122b8
  log.dev = dev;
80103351:	8b 45 08             	mov    0x8(%ebp),%eax
80103354:	a3 c4 22 11 80       	mov    %eax,0x801122c4
  recover_from_log();
80103359:	e8 b2 01 00 00       	call   80103510 <recover_from_log>
}
8010335e:	90                   	nop
8010335f:	c9                   	leave  
80103360:	c3                   	ret    

80103361 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103361:	55                   	push   %ebp
80103362:	89 e5                	mov    %esp,%ebp
80103364:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103367:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010336e:	e9 95 00 00 00       	jmp    80103408 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103373:	8b 15 b4 22 11 80    	mov    0x801122b4,%edx
80103379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010337c:	01 d0                	add    %edx,%eax
8010337e:	83 c0 01             	add    $0x1,%eax
80103381:	89 c2                	mov    %eax,%edx
80103383:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80103388:	83 ec 08             	sub    $0x8,%esp
8010338b:	52                   	push   %edx
8010338c:	50                   	push   %eax
8010338d:	e8 24 ce ff ff       	call   801001b6 <bread>
80103392:	83 c4 10             	add    $0x10,%esp
80103395:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010339b:	83 c0 10             	add    $0x10,%eax
8010339e:	8b 04 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%eax
801033a5:	89 c2                	mov    %eax,%edx
801033a7:	a1 c4 22 11 80       	mov    0x801122c4,%eax
801033ac:	83 ec 08             	sub    $0x8,%esp
801033af:	52                   	push   %edx
801033b0:	50                   	push   %eax
801033b1:	e8 00 ce ff ff       	call   801001b6 <bread>
801033b6:	83 c4 10             	add    $0x10,%esp
801033b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033bf:	8d 50 18             	lea    0x18(%eax),%edx
801033c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033c5:	83 c0 18             	add    $0x18,%eax
801033c8:	83 ec 04             	sub    $0x4,%esp
801033cb:	68 00 02 00 00       	push   $0x200
801033d0:	52                   	push   %edx
801033d1:	50                   	push   %eax
801033d2:	e8 2f 1f 00 00       	call   80105306 <memmove>
801033d7:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033da:	83 ec 0c             	sub    $0xc,%esp
801033dd:	ff 75 ec             	pushl  -0x14(%ebp)
801033e0:	e8 0a ce ff ff       	call   801001ef <bwrite>
801033e5:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
801033e8:	83 ec 0c             	sub    $0xc,%esp
801033eb:	ff 75 f0             	pushl  -0x10(%ebp)
801033ee:	e8 3b ce ff ff       	call   8010022e <brelse>
801033f3:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801033f6:	83 ec 0c             	sub    $0xc,%esp
801033f9:	ff 75 ec             	pushl  -0x14(%ebp)
801033fc:	e8 2d ce ff ff       	call   8010022e <brelse>
80103401:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103404:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103408:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010340d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103410:	0f 8f 5d ff ff ff    	jg     80103373 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103416:	90                   	nop
80103417:	c9                   	leave  
80103418:	c3                   	ret    

80103419 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103419:	55                   	push   %ebp
8010341a:	89 e5                	mov    %esp,%ebp
8010341c:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010341f:	a1 b4 22 11 80       	mov    0x801122b4,%eax
80103424:	89 c2                	mov    %eax,%edx
80103426:	a1 c4 22 11 80       	mov    0x801122c4,%eax
8010342b:	83 ec 08             	sub    $0x8,%esp
8010342e:	52                   	push   %edx
8010342f:	50                   	push   %eax
80103430:	e8 81 cd ff ff       	call   801001b6 <bread>
80103435:	83 c4 10             	add    $0x10,%esp
80103438:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010343b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010343e:	83 c0 18             	add    $0x18,%eax
80103441:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103444:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103447:	8b 00                	mov    (%eax),%eax
80103449:	a3 c8 22 11 80       	mov    %eax,0x801122c8
  for (i = 0; i < log.lh.n; i++) {
8010344e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103455:	eb 1b                	jmp    80103472 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103457:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010345a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010345d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103461:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103464:	83 c2 10             	add    $0x10,%edx
80103467:	89 04 95 8c 22 11 80 	mov    %eax,-0x7feedd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010346e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103472:	a1 c8 22 11 80       	mov    0x801122c8,%eax
80103477:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010347a:	7f db                	jg     80103457 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
8010347c:	83 ec 0c             	sub    $0xc,%esp
8010347f:	ff 75 f0             	pushl  -0x10(%ebp)
80103482:	e8 a7 cd ff ff       	call   8010022e <brelse>
80103487:	83 c4 10             	add    $0x10,%esp
}
8010348a:	90                   	nop
8010348b:	c9                   	leave  
8010348c:	c3                   	ret    

8010348d <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010348d:	55                   	push   %ebp
8010348e:	89 e5                	mov    %esp,%ebp
80103490:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103493:	a1 b4 22 11 80       	mov    0x801122b4,%eax
80103498:	89 c2                	mov    %eax,%edx
8010349a:	a1 c4 22 11 80       	mov    0x801122c4,%eax
8010349f:	83 ec 08             	sub    $0x8,%esp
801034a2:	52                   	push   %edx
801034a3:	50                   	push   %eax
801034a4:	e8 0d cd ff ff       	call   801001b6 <bread>
801034a9:	83 c4 10             	add    $0x10,%esp
801034ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b2:	83 c0 18             	add    $0x18,%eax
801034b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034b8:	8b 15 c8 22 11 80    	mov    0x801122c8,%edx
801034be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034c1:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034ca:	eb 1b                	jmp    801034e7 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034cf:	83 c0 10             	add    $0x10,%eax
801034d2:	8b 0c 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%ecx
801034d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034df:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801034e3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034e7:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801034ec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034ef:	7f db                	jg     801034cc <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801034f1:	83 ec 0c             	sub    $0xc,%esp
801034f4:	ff 75 f0             	pushl  -0x10(%ebp)
801034f7:	e8 f3 cc ff ff       	call   801001ef <bwrite>
801034fc:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034ff:	83 ec 0c             	sub    $0xc,%esp
80103502:	ff 75 f0             	pushl  -0x10(%ebp)
80103505:	e8 24 cd ff ff       	call   8010022e <brelse>
8010350a:	83 c4 10             	add    $0x10,%esp
}
8010350d:	90                   	nop
8010350e:	c9                   	leave  
8010350f:	c3                   	ret    

80103510 <recover_from_log>:

static void
recover_from_log(void)
{
80103510:	55                   	push   %ebp
80103511:	89 e5                	mov    %esp,%ebp
80103513:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103516:	e8 fe fe ff ff       	call   80103419 <read_head>
  install_trans(); // if committed, copy from log to disk
8010351b:	e8 41 fe ff ff       	call   80103361 <install_trans>
  log.lh.n = 0;
80103520:	c7 05 c8 22 11 80 00 	movl   $0x0,0x801122c8
80103527:	00 00 00 
  write_head(); // clear the log
8010352a:	e8 5e ff ff ff       	call   8010348d <write_head>
}
8010352f:	90                   	nop
80103530:	c9                   	leave  
80103531:	c3                   	ret    

80103532 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103532:	55                   	push   %ebp
80103533:	89 e5                	mov    %esp,%ebp
80103535:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103538:	83 ec 0c             	sub    $0xc,%esp
8010353b:	68 80 22 11 80       	push   $0x80112280
80103540:	e8 9f 1a 00 00       	call   80104fe4 <acquire>
80103545:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103548:	a1 c0 22 11 80       	mov    0x801122c0,%eax
8010354d:	85 c0                	test   %eax,%eax
8010354f:	74 17                	je     80103568 <begin_op+0x36>
      sleep(&log, &log.lock);
80103551:	83 ec 08             	sub    $0x8,%esp
80103554:	68 80 22 11 80       	push   $0x80112280
80103559:	68 80 22 11 80       	push   $0x80112280
8010355e:	e8 88 17 00 00       	call   80104ceb <sleep>
80103563:	83 c4 10             	add    $0x10,%esp
80103566:	eb e0                	jmp    80103548 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103568:	8b 0d c8 22 11 80    	mov    0x801122c8,%ecx
8010356e:	a1 bc 22 11 80       	mov    0x801122bc,%eax
80103573:	8d 50 01             	lea    0x1(%eax),%edx
80103576:	89 d0                	mov    %edx,%eax
80103578:	c1 e0 02             	shl    $0x2,%eax
8010357b:	01 d0                	add    %edx,%eax
8010357d:	01 c0                	add    %eax,%eax
8010357f:	01 c8                	add    %ecx,%eax
80103581:	83 f8 1e             	cmp    $0x1e,%eax
80103584:	7e 17                	jle    8010359d <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103586:	83 ec 08             	sub    $0x8,%esp
80103589:	68 80 22 11 80       	push   $0x80112280
8010358e:	68 80 22 11 80       	push   $0x80112280
80103593:	e8 53 17 00 00       	call   80104ceb <sleep>
80103598:	83 c4 10             	add    $0x10,%esp
8010359b:	eb ab                	jmp    80103548 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010359d:	a1 bc 22 11 80       	mov    0x801122bc,%eax
801035a2:	83 c0 01             	add    $0x1,%eax
801035a5:	a3 bc 22 11 80       	mov    %eax,0x801122bc
      release(&log.lock);
801035aa:	83 ec 0c             	sub    $0xc,%esp
801035ad:	68 80 22 11 80       	push   $0x80112280
801035b2:	e8 94 1a 00 00       	call   8010504b <release>
801035b7:	83 c4 10             	add    $0x10,%esp
      break;
801035ba:	90                   	nop
    }
  }
}
801035bb:	90                   	nop
801035bc:	c9                   	leave  
801035bd:	c3                   	ret    

801035be <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035be:	55                   	push   %ebp
801035bf:	89 e5                	mov    %esp,%ebp
801035c1:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035cb:	83 ec 0c             	sub    $0xc,%esp
801035ce:	68 80 22 11 80       	push   $0x80112280
801035d3:	e8 0c 1a 00 00       	call   80104fe4 <acquire>
801035d8:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035db:	a1 bc 22 11 80       	mov    0x801122bc,%eax
801035e0:	83 e8 01             	sub    $0x1,%eax
801035e3:	a3 bc 22 11 80       	mov    %eax,0x801122bc
  if(log.committing)
801035e8:	a1 c0 22 11 80       	mov    0x801122c0,%eax
801035ed:	85 c0                	test   %eax,%eax
801035ef:	74 0d                	je     801035fe <end_op+0x40>
    panic("log.committing");
801035f1:	83 ec 0c             	sub    $0xc,%esp
801035f4:	68 7c 87 10 80       	push   $0x8010877c
801035f9:	e8 68 cf ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
801035fe:	a1 bc 22 11 80       	mov    0x801122bc,%eax
80103603:	85 c0                	test   %eax,%eax
80103605:	75 13                	jne    8010361a <end_op+0x5c>
    do_commit = 1;
80103607:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010360e:	c7 05 c0 22 11 80 01 	movl   $0x1,0x801122c0
80103615:	00 00 00 
80103618:	eb 10                	jmp    8010362a <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
8010361a:	83 ec 0c             	sub    $0xc,%esp
8010361d:	68 80 22 11 80       	push   $0x80112280
80103622:	e8 af 17 00 00       	call   80104dd6 <wakeup>
80103627:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010362a:	83 ec 0c             	sub    $0xc,%esp
8010362d:	68 80 22 11 80       	push   $0x80112280
80103632:	e8 14 1a 00 00       	call   8010504b <release>
80103637:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010363a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010363e:	74 3f                	je     8010367f <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103640:	e8 f5 00 00 00       	call   8010373a <commit>
    acquire(&log.lock);
80103645:	83 ec 0c             	sub    $0xc,%esp
80103648:	68 80 22 11 80       	push   $0x80112280
8010364d:	e8 92 19 00 00       	call   80104fe4 <acquire>
80103652:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103655:	c7 05 c0 22 11 80 00 	movl   $0x0,0x801122c0
8010365c:	00 00 00 
    wakeup(&log);
8010365f:	83 ec 0c             	sub    $0xc,%esp
80103662:	68 80 22 11 80       	push   $0x80112280
80103667:	e8 6a 17 00 00       	call   80104dd6 <wakeup>
8010366c:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010366f:	83 ec 0c             	sub    $0xc,%esp
80103672:	68 80 22 11 80       	push   $0x80112280
80103677:	e8 cf 19 00 00       	call   8010504b <release>
8010367c:	83 c4 10             	add    $0x10,%esp
  }
}
8010367f:	90                   	nop
80103680:	c9                   	leave  
80103681:	c3                   	ret    

80103682 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103682:	55                   	push   %ebp
80103683:	89 e5                	mov    %esp,%ebp
80103685:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103688:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010368f:	e9 95 00 00 00       	jmp    80103729 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103694:	8b 15 b4 22 11 80    	mov    0x801122b4,%edx
8010369a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010369d:	01 d0                	add    %edx,%eax
8010369f:	83 c0 01             	add    $0x1,%eax
801036a2:	89 c2                	mov    %eax,%edx
801036a4:	a1 c4 22 11 80       	mov    0x801122c4,%eax
801036a9:	83 ec 08             	sub    $0x8,%esp
801036ac:	52                   	push   %edx
801036ad:	50                   	push   %eax
801036ae:	e8 03 cb ff ff       	call   801001b6 <bread>
801036b3:	83 c4 10             	add    $0x10,%esp
801036b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036bc:	83 c0 10             	add    $0x10,%eax
801036bf:	8b 04 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%eax
801036c6:	89 c2                	mov    %eax,%edx
801036c8:	a1 c4 22 11 80       	mov    0x801122c4,%eax
801036cd:	83 ec 08             	sub    $0x8,%esp
801036d0:	52                   	push   %edx
801036d1:	50                   	push   %eax
801036d2:	e8 df ca ff ff       	call   801001b6 <bread>
801036d7:	83 c4 10             	add    $0x10,%esp
801036da:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036e0:	8d 50 18             	lea    0x18(%eax),%edx
801036e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036e6:	83 c0 18             	add    $0x18,%eax
801036e9:	83 ec 04             	sub    $0x4,%esp
801036ec:	68 00 02 00 00       	push   $0x200
801036f1:	52                   	push   %edx
801036f2:	50                   	push   %eax
801036f3:	e8 0e 1c 00 00       	call   80105306 <memmove>
801036f8:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801036fb:	83 ec 0c             	sub    $0xc,%esp
801036fe:	ff 75 f0             	pushl  -0x10(%ebp)
80103701:	e8 e9 ca ff ff       	call   801001ef <bwrite>
80103706:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103709:	83 ec 0c             	sub    $0xc,%esp
8010370c:	ff 75 ec             	pushl  -0x14(%ebp)
8010370f:	e8 1a cb ff ff       	call   8010022e <brelse>
80103714:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103717:	83 ec 0c             	sub    $0xc,%esp
8010371a:	ff 75 f0             	pushl  -0x10(%ebp)
8010371d:	e8 0c cb ff ff       	call   8010022e <brelse>
80103722:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103725:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103729:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010372e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103731:	0f 8f 5d ff ff ff    	jg     80103694 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103737:	90                   	nop
80103738:	c9                   	leave  
80103739:	c3                   	ret    

8010373a <commit>:

static void
commit()
{
8010373a:	55                   	push   %ebp
8010373b:	89 e5                	mov    %esp,%ebp
8010373d:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103740:	a1 c8 22 11 80       	mov    0x801122c8,%eax
80103745:	85 c0                	test   %eax,%eax
80103747:	7e 1e                	jle    80103767 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103749:	e8 34 ff ff ff       	call   80103682 <write_log>
    write_head();    // Write header to disk -- the real commit
8010374e:	e8 3a fd ff ff       	call   8010348d <write_head>
    install_trans(); // Now install writes to home locations
80103753:	e8 09 fc ff ff       	call   80103361 <install_trans>
    log.lh.n = 0; 
80103758:	c7 05 c8 22 11 80 00 	movl   $0x0,0x801122c8
8010375f:	00 00 00 
    write_head();    // Erase the transaction from the log
80103762:	e8 26 fd ff ff       	call   8010348d <write_head>
  }
}
80103767:	90                   	nop
80103768:	c9                   	leave  
80103769:	c3                   	ret    

8010376a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010376a:	55                   	push   %ebp
8010376b:	89 e5                	mov    %esp,%ebp
8010376d:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103770:	a1 c8 22 11 80       	mov    0x801122c8,%eax
80103775:	83 f8 1d             	cmp    $0x1d,%eax
80103778:	7f 12                	jg     8010378c <log_write+0x22>
8010377a:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010377f:	8b 15 b8 22 11 80    	mov    0x801122b8,%edx
80103785:	83 ea 01             	sub    $0x1,%edx
80103788:	39 d0                	cmp    %edx,%eax
8010378a:	7c 0d                	jl     80103799 <log_write+0x2f>
    panic("too big a transaction");
8010378c:	83 ec 0c             	sub    $0xc,%esp
8010378f:	68 8b 87 10 80       	push   $0x8010878b
80103794:	e8 cd cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103799:	a1 bc 22 11 80       	mov    0x801122bc,%eax
8010379e:	85 c0                	test   %eax,%eax
801037a0:	7f 0d                	jg     801037af <log_write+0x45>
    panic("log_write outside of trans");
801037a2:	83 ec 0c             	sub    $0xc,%esp
801037a5:	68 a1 87 10 80       	push   $0x801087a1
801037aa:	e8 b7 cd ff ff       	call   80100566 <panic>

  acquire(&log.lock);
801037af:	83 ec 0c             	sub    $0xc,%esp
801037b2:	68 80 22 11 80       	push   $0x80112280
801037b7:	e8 28 18 00 00       	call   80104fe4 <acquire>
801037bc:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037c6:	eb 1d                	jmp    801037e5 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037cb:	83 c0 10             	add    $0x10,%eax
801037ce:	8b 04 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%eax
801037d5:	89 c2                	mov    %eax,%edx
801037d7:	8b 45 08             	mov    0x8(%ebp),%eax
801037da:	8b 40 08             	mov    0x8(%eax),%eax
801037dd:	39 c2                	cmp    %eax,%edx
801037df:	74 10                	je     801037f1 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801037e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037e5:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801037ea:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037ed:	7f d9                	jg     801037c8 <log_write+0x5e>
801037ef:	eb 01                	jmp    801037f2 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
801037f1:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801037f2:	8b 45 08             	mov    0x8(%ebp),%eax
801037f5:	8b 40 08             	mov    0x8(%eax),%eax
801037f8:	89 c2                	mov    %eax,%edx
801037fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037fd:	83 c0 10             	add    $0x10,%eax
80103800:	89 14 85 8c 22 11 80 	mov    %edx,-0x7feedd74(,%eax,4)
  if (i == log.lh.n)
80103807:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010380c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010380f:	75 0d                	jne    8010381e <log_write+0xb4>
    log.lh.n++;
80103811:	a1 c8 22 11 80       	mov    0x801122c8,%eax
80103816:	83 c0 01             	add    $0x1,%eax
80103819:	a3 c8 22 11 80       	mov    %eax,0x801122c8
  b->flags |= B_DIRTY; // prevent eviction
8010381e:	8b 45 08             	mov    0x8(%ebp),%eax
80103821:	8b 00                	mov    (%eax),%eax
80103823:	83 c8 04             	or     $0x4,%eax
80103826:	89 c2                	mov    %eax,%edx
80103828:	8b 45 08             	mov    0x8(%ebp),%eax
8010382b:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010382d:	83 ec 0c             	sub    $0xc,%esp
80103830:	68 80 22 11 80       	push   $0x80112280
80103835:	e8 11 18 00 00       	call   8010504b <release>
8010383a:	83 c4 10             	add    $0x10,%esp
}
8010383d:	90                   	nop
8010383e:	c9                   	leave  
8010383f:	c3                   	ret    

80103840 <v2p>:
80103840:	55                   	push   %ebp
80103841:	89 e5                	mov    %esp,%ebp
80103843:	8b 45 08             	mov    0x8(%ebp),%eax
80103846:	05 00 00 00 80       	add    $0x80000000,%eax
8010384b:	5d                   	pop    %ebp
8010384c:	c3                   	ret    

8010384d <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010384d:	55                   	push   %ebp
8010384e:	89 e5                	mov    %esp,%ebp
80103850:	8b 45 08             	mov    0x8(%ebp),%eax
80103853:	05 00 00 00 80       	add    $0x80000000,%eax
80103858:	5d                   	pop    %ebp
80103859:	c3                   	ret    

8010385a <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010385a:	55                   	push   %ebp
8010385b:	89 e5                	mov    %esp,%ebp
8010385d:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103860:	8b 55 08             	mov    0x8(%ebp),%edx
80103863:	8b 45 0c             	mov    0xc(%ebp),%eax
80103866:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103869:	f0 87 02             	lock xchg %eax,(%edx)
8010386c:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010386f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103872:	c9                   	leave  
80103873:	c3                   	ret    

80103874 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103874:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103878:	83 e4 f0             	and    $0xfffffff0,%esp
8010387b:	ff 71 fc             	pushl  -0x4(%ecx)
8010387e:	55                   	push   %ebp
8010387f:	89 e5                	mov    %esp,%ebp
80103881:	51                   	push   %ecx
80103882:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103885:	83 ec 08             	sub    $0x8,%esp
80103888:	68 00 00 40 80       	push   $0x80400000
8010388d:	68 5c 51 11 80       	push   $0x8011515c
80103892:	e8 7d f2 ff ff       	call   80102b14 <kinit1>
80103897:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010389a:	e8 f9 44 00 00       	call   80107d98 <kvmalloc>
  mpinit();        // collect info about this machine
8010389f:	e8 43 04 00 00       	call   80103ce7 <mpinit>
  lapicinit();
801038a4:	e8 ea f5 ff ff       	call   80102e93 <lapicinit>
  seginit();       // set up segments
801038a9:	e8 93 3e 00 00       	call   80107741 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801038ae:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038b4:	0f b6 00             	movzbl (%eax),%eax
801038b7:	0f b6 c0             	movzbl %al,%eax
801038ba:	83 ec 08             	sub    $0x8,%esp
801038bd:	50                   	push   %eax
801038be:	68 bc 87 10 80       	push   $0x801087bc
801038c3:	e8 fe ca ff ff       	call   801003c6 <cprintf>
801038c8:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801038cb:	e8 6d 06 00 00       	call   80103f3d <picinit>
  ioapicinit();    // another interrupt controller
801038d0:	e8 34 f1 ff ff       	call   80102a09 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801038d5:	e8 0f d2 ff ff       	call   80100ae9 <consoleinit>
  uartinit();      // serial port
801038da:	e8 be 31 00 00       	call   80106a9d <uartinit>
  pinit();         // process table
801038df:	e8 56 0b 00 00       	call   8010443a <pinit>
  tvinit();        // trap vectors
801038e4:	e8 7e 2d 00 00       	call   80106667 <tvinit>
  binit();         // buffer cache
801038e9:	e8 46 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801038ee:	e8 67 d6 ff ff       	call   80100f5a <fileinit>
  ideinit();       // disk
801038f3:	e8 19 ed ff ff       	call   80102611 <ideinit>
  if(!ismp)
801038f8:	a1 64 23 11 80       	mov    0x80112364,%eax
801038fd:	85 c0                	test   %eax,%eax
801038ff:	75 05                	jne    80103906 <main+0x92>
    timerinit();   // uniprocessor timer
80103901:	e8 be 2c 00 00       	call   801065c4 <timerinit>
  startothers();   // start other processors
80103906:	e8 7f 00 00 00       	call   8010398a <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010390b:	83 ec 08             	sub    $0x8,%esp
8010390e:	68 00 00 00 8e       	push   $0x8e000000
80103913:	68 00 00 40 80       	push   $0x80400000
80103918:	e8 30 f2 ff ff       	call   80102b4d <kinit2>
8010391d:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103920:	e8 39 0c 00 00       	call   8010455e <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103925:	e8 1a 00 00 00       	call   80103944 <mpmain>

8010392a <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010392a:	55                   	push   %ebp
8010392b:	89 e5                	mov    %esp,%ebp
8010392d:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103930:	e8 7b 44 00 00       	call   80107db0 <switchkvm>
  seginit();
80103935:	e8 07 3e 00 00       	call   80107741 <seginit>
  lapicinit();
8010393a:	e8 54 f5 ff ff       	call   80102e93 <lapicinit>
  mpmain();
8010393f:	e8 00 00 00 00       	call   80103944 <mpmain>

80103944 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103944:	55                   	push   %ebp
80103945:	89 e5                	mov    %esp,%ebp
80103947:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010394a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103950:	0f b6 00             	movzbl (%eax),%eax
80103953:	0f b6 c0             	movzbl %al,%eax
80103956:	83 ec 08             	sub    $0x8,%esp
80103959:	50                   	push   %eax
8010395a:	68 d3 87 10 80       	push   $0x801087d3
8010395f:	e8 62 ca ff ff       	call   801003c6 <cprintf>
80103964:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103967:	e8 71 2e 00 00       	call   801067dd <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010396c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103972:	05 a8 00 00 00       	add    $0xa8,%eax
80103977:	83 ec 08             	sub    $0x8,%esp
8010397a:	6a 01                	push   $0x1
8010397c:	50                   	push   %eax
8010397d:	e8 d8 fe ff ff       	call   8010385a <xchg>
80103982:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103985:	e8 7f 11 00 00       	call   80104b09 <scheduler>

8010398a <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010398a:	55                   	push   %ebp
8010398b:	89 e5                	mov    %esp,%ebp
8010398d:	53                   	push   %ebx
8010398e:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103991:	68 00 70 00 00       	push   $0x7000
80103996:	e8 b2 fe ff ff       	call   8010384d <p2v>
8010399b:	83 c4 04             	add    $0x4,%esp
8010399e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039a1:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039a6:	83 ec 04             	sub    $0x4,%esp
801039a9:	50                   	push   %eax
801039aa:	68 0c b5 10 80       	push   $0x8010b50c
801039af:	ff 75 f0             	pushl  -0x10(%ebp)
801039b2:	e8 4f 19 00 00       	call   80105306 <memmove>
801039b7:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801039ba:	c7 45 f4 80 23 11 80 	movl   $0x80112380,-0xc(%ebp)
801039c1:	e9 90 00 00 00       	jmp    80103a56 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
801039c6:	e8 e6 f5 ff ff       	call   80102fb1 <cpunum>
801039cb:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039d1:	05 80 23 11 80       	add    $0x80112380,%eax
801039d6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039d9:	74 73                	je     80103a4e <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801039db:	e8 6b f2 ff ff       	call   80102c4b <kalloc>
801039e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801039e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039e6:	83 e8 04             	sub    $0x4,%eax
801039e9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801039ec:	81 c2 00 10 00 00    	add    $0x1000,%edx
801039f2:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801039f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039f7:	83 e8 08             	sub    $0x8,%eax
801039fa:	c7 00 2a 39 10 80    	movl   $0x8010392a,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a03:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103a06:	83 ec 0c             	sub    $0xc,%esp
80103a09:	68 00 a0 10 80       	push   $0x8010a000
80103a0e:	e8 2d fe ff ff       	call   80103840 <v2p>
80103a13:	83 c4 10             	add    $0x10,%esp
80103a16:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103a18:	83 ec 0c             	sub    $0xc,%esp
80103a1b:	ff 75 f0             	pushl  -0x10(%ebp)
80103a1e:	e8 1d fe ff ff       	call   80103840 <v2p>
80103a23:	83 c4 10             	add    $0x10,%esp
80103a26:	89 c2                	mov    %eax,%edx
80103a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a2b:	0f b6 00             	movzbl (%eax),%eax
80103a2e:	0f b6 c0             	movzbl %al,%eax
80103a31:	83 ec 08             	sub    $0x8,%esp
80103a34:	52                   	push   %edx
80103a35:	50                   	push   %eax
80103a36:	e8 f0 f5 ff ff       	call   8010302b <lapicstartap>
80103a3b:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a3e:	90                   	nop
80103a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a42:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103a48:	85 c0                	test   %eax,%eax
80103a4a:	74 f3                	je     80103a3f <startothers+0xb5>
80103a4c:	eb 01                	jmp    80103a4f <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103a4e:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103a4f:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103a56:	a1 60 29 11 80       	mov    0x80112960,%eax
80103a5b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a61:	05 80 23 11 80       	add    $0x80112380,%eax
80103a66:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a69:	0f 87 57 ff ff ff    	ja     801039c6 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103a6f:	90                   	nop
80103a70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a73:	c9                   	leave  
80103a74:	c3                   	ret    

80103a75 <p2v>:
80103a75:	55                   	push   %ebp
80103a76:	89 e5                	mov    %esp,%ebp
80103a78:	8b 45 08             	mov    0x8(%ebp),%eax
80103a7b:	05 00 00 00 80       	add    $0x80000000,%eax
80103a80:	5d                   	pop    %ebp
80103a81:	c3                   	ret    

80103a82 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103a82:	55                   	push   %ebp
80103a83:	89 e5                	mov    %esp,%ebp
80103a85:	83 ec 14             	sub    $0x14,%esp
80103a88:	8b 45 08             	mov    0x8(%ebp),%eax
80103a8b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103a8f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103a93:	89 c2                	mov    %eax,%edx
80103a95:	ec                   	in     (%dx),%al
80103a96:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103a99:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103a9d:	c9                   	leave  
80103a9e:	c3                   	ret    

80103a9f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a9f:	55                   	push   %ebp
80103aa0:	89 e5                	mov    %esp,%ebp
80103aa2:	83 ec 08             	sub    $0x8,%esp
80103aa5:	8b 55 08             	mov    0x8(%ebp),%edx
80103aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103aab:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103aaf:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ab2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ab6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103aba:	ee                   	out    %al,(%dx)
}
80103abb:	90                   	nop
80103abc:	c9                   	leave  
80103abd:	c3                   	ret    

80103abe <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103abe:	55                   	push   %ebp
80103abf:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103ac1:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103ac6:	89 c2                	mov    %eax,%edx
80103ac8:	b8 80 23 11 80       	mov    $0x80112380,%eax
80103acd:	29 c2                	sub    %eax,%edx
80103acf:	89 d0                	mov    %edx,%eax
80103ad1:	c1 f8 02             	sar    $0x2,%eax
80103ad4:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103ada:	5d                   	pop    %ebp
80103adb:	c3                   	ret    

80103adc <sum>:

static uchar
sum(uchar *addr, int len)
{
80103adc:	55                   	push   %ebp
80103add:	89 e5                	mov    %esp,%ebp
80103adf:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103ae2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103ae9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103af0:	eb 15                	jmp    80103b07 <sum+0x2b>
    sum += addr[i];
80103af2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103af5:	8b 45 08             	mov    0x8(%ebp),%eax
80103af8:	01 d0                	add    %edx,%eax
80103afa:	0f b6 00             	movzbl (%eax),%eax
80103afd:	0f b6 c0             	movzbl %al,%eax
80103b00:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103b03:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b07:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b0a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b0d:	7c e3                	jl     80103af2 <sum+0x16>
    sum += addr[i];
  return sum;
80103b0f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b12:	c9                   	leave  
80103b13:	c3                   	ret    

80103b14 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b14:	55                   	push   %ebp
80103b15:	89 e5                	mov    %esp,%ebp
80103b17:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103b1a:	ff 75 08             	pushl  0x8(%ebp)
80103b1d:	e8 53 ff ff ff       	call   80103a75 <p2v>
80103b22:	83 c4 04             	add    $0x4,%esp
80103b25:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b28:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b2e:	01 d0                	add    %edx,%eax
80103b30:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b36:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b39:	eb 36                	jmp    80103b71 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b3b:	83 ec 04             	sub    $0x4,%esp
80103b3e:	6a 04                	push   $0x4
80103b40:	68 e4 87 10 80       	push   $0x801087e4
80103b45:	ff 75 f4             	pushl  -0xc(%ebp)
80103b48:	e8 61 17 00 00       	call   801052ae <memcmp>
80103b4d:	83 c4 10             	add    $0x10,%esp
80103b50:	85 c0                	test   %eax,%eax
80103b52:	75 19                	jne    80103b6d <mpsearch1+0x59>
80103b54:	83 ec 08             	sub    $0x8,%esp
80103b57:	6a 10                	push   $0x10
80103b59:	ff 75 f4             	pushl  -0xc(%ebp)
80103b5c:	e8 7b ff ff ff       	call   80103adc <sum>
80103b61:	83 c4 10             	add    $0x10,%esp
80103b64:	84 c0                	test   %al,%al
80103b66:	75 05                	jne    80103b6d <mpsearch1+0x59>
      return (struct mp*)p;
80103b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6b:	eb 11                	jmp    80103b7e <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103b6d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b74:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b77:	72 c2                	jb     80103b3b <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103b79:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b7e:	c9                   	leave  
80103b7f:	c3                   	ret    

80103b80 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b80:	55                   	push   %ebp
80103b81:	89 e5                	mov    %esp,%ebp
80103b83:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103b86:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b90:	83 c0 0f             	add    $0xf,%eax
80103b93:	0f b6 00             	movzbl (%eax),%eax
80103b96:	0f b6 c0             	movzbl %al,%eax
80103b99:	c1 e0 08             	shl    $0x8,%eax
80103b9c:	89 c2                	mov    %eax,%edx
80103b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba1:	83 c0 0e             	add    $0xe,%eax
80103ba4:	0f b6 00             	movzbl (%eax),%eax
80103ba7:	0f b6 c0             	movzbl %al,%eax
80103baa:	09 d0                	or     %edx,%eax
80103bac:	c1 e0 04             	shl    $0x4,%eax
80103baf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bb2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bb6:	74 21                	je     80103bd9 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103bb8:	83 ec 08             	sub    $0x8,%esp
80103bbb:	68 00 04 00 00       	push   $0x400
80103bc0:	ff 75 f0             	pushl  -0x10(%ebp)
80103bc3:	e8 4c ff ff ff       	call   80103b14 <mpsearch1>
80103bc8:	83 c4 10             	add    $0x10,%esp
80103bcb:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bce:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bd2:	74 51                	je     80103c25 <mpsearch+0xa5>
      return mp;
80103bd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bd7:	eb 61                	jmp    80103c3a <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bdc:	83 c0 14             	add    $0x14,%eax
80103bdf:	0f b6 00             	movzbl (%eax),%eax
80103be2:	0f b6 c0             	movzbl %al,%eax
80103be5:	c1 e0 08             	shl    $0x8,%eax
80103be8:	89 c2                	mov    %eax,%edx
80103bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bed:	83 c0 13             	add    $0x13,%eax
80103bf0:	0f b6 00             	movzbl (%eax),%eax
80103bf3:	0f b6 c0             	movzbl %al,%eax
80103bf6:	09 d0                	or     %edx,%eax
80103bf8:	c1 e0 0a             	shl    $0xa,%eax
80103bfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c01:	2d 00 04 00 00       	sub    $0x400,%eax
80103c06:	83 ec 08             	sub    $0x8,%esp
80103c09:	68 00 04 00 00       	push   $0x400
80103c0e:	50                   	push   %eax
80103c0f:	e8 00 ff ff ff       	call   80103b14 <mpsearch1>
80103c14:	83 c4 10             	add    $0x10,%esp
80103c17:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c1a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c1e:	74 05                	je     80103c25 <mpsearch+0xa5>
      return mp;
80103c20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c23:	eb 15                	jmp    80103c3a <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c25:	83 ec 08             	sub    $0x8,%esp
80103c28:	68 00 00 01 00       	push   $0x10000
80103c2d:	68 00 00 0f 00       	push   $0xf0000
80103c32:	e8 dd fe ff ff       	call   80103b14 <mpsearch1>
80103c37:	83 c4 10             	add    $0x10,%esp
}
80103c3a:	c9                   	leave  
80103c3b:	c3                   	ret    

80103c3c <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c3c:	55                   	push   %ebp
80103c3d:	89 e5                	mov    %esp,%ebp
80103c3f:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c42:	e8 39 ff ff ff       	call   80103b80 <mpsearch>
80103c47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c4e:	74 0a                	je     80103c5a <mpconfig+0x1e>
80103c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c53:	8b 40 04             	mov    0x4(%eax),%eax
80103c56:	85 c0                	test   %eax,%eax
80103c58:	75 0a                	jne    80103c64 <mpconfig+0x28>
    return 0;
80103c5a:	b8 00 00 00 00       	mov    $0x0,%eax
80103c5f:	e9 81 00 00 00       	jmp    80103ce5 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c67:	8b 40 04             	mov    0x4(%eax),%eax
80103c6a:	83 ec 0c             	sub    $0xc,%esp
80103c6d:	50                   	push   %eax
80103c6e:	e8 02 fe ff ff       	call   80103a75 <p2v>
80103c73:	83 c4 10             	add    $0x10,%esp
80103c76:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c79:	83 ec 04             	sub    $0x4,%esp
80103c7c:	6a 04                	push   $0x4
80103c7e:	68 e9 87 10 80       	push   $0x801087e9
80103c83:	ff 75 f0             	pushl  -0x10(%ebp)
80103c86:	e8 23 16 00 00       	call   801052ae <memcmp>
80103c8b:	83 c4 10             	add    $0x10,%esp
80103c8e:	85 c0                	test   %eax,%eax
80103c90:	74 07                	je     80103c99 <mpconfig+0x5d>
    return 0;
80103c92:	b8 00 00 00 00       	mov    $0x0,%eax
80103c97:	eb 4c                	jmp    80103ce5 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c9c:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103ca0:	3c 01                	cmp    $0x1,%al
80103ca2:	74 12                	je     80103cb6 <mpconfig+0x7a>
80103ca4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca7:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cab:	3c 04                	cmp    $0x4,%al
80103cad:	74 07                	je     80103cb6 <mpconfig+0x7a>
    return 0;
80103caf:	b8 00 00 00 00       	mov    $0x0,%eax
80103cb4:	eb 2f                	jmp    80103ce5 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103cb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb9:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cbd:	0f b7 c0             	movzwl %ax,%eax
80103cc0:	83 ec 08             	sub    $0x8,%esp
80103cc3:	50                   	push   %eax
80103cc4:	ff 75 f0             	pushl  -0x10(%ebp)
80103cc7:	e8 10 fe ff ff       	call   80103adc <sum>
80103ccc:	83 c4 10             	add    $0x10,%esp
80103ccf:	84 c0                	test   %al,%al
80103cd1:	74 07                	je     80103cda <mpconfig+0x9e>
    return 0;
80103cd3:	b8 00 00 00 00       	mov    $0x0,%eax
80103cd8:	eb 0b                	jmp    80103ce5 <mpconfig+0xa9>
  *pmp = mp;
80103cda:	8b 45 08             	mov    0x8(%ebp),%eax
80103cdd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ce0:	89 10                	mov    %edx,(%eax)
  return conf;
80103ce2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103ce5:	c9                   	leave  
80103ce6:	c3                   	ret    

80103ce7 <mpinit>:

void
mpinit(void)
{
80103ce7:	55                   	push   %ebp
80103ce8:	89 e5                	mov    %esp,%ebp
80103cea:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103ced:	c7 05 44 b6 10 80 80 	movl   $0x80112380,0x8010b644
80103cf4:	23 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103cf7:	83 ec 0c             	sub    $0xc,%esp
80103cfa:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103cfd:	50                   	push   %eax
80103cfe:	e8 39 ff ff ff       	call   80103c3c <mpconfig>
80103d03:	83 c4 10             	add    $0x10,%esp
80103d06:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d09:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d0d:	0f 84 96 01 00 00    	je     80103ea9 <mpinit+0x1c2>
    return;
  ismp = 1;
80103d13:	c7 05 64 23 11 80 01 	movl   $0x1,0x80112364
80103d1a:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103d1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d20:	8b 40 24             	mov    0x24(%eax),%eax
80103d23:	a3 7c 22 11 80       	mov    %eax,0x8011227c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d2b:	83 c0 2c             	add    $0x2c,%eax
80103d2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d34:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d38:	0f b7 d0             	movzwl %ax,%edx
80103d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d3e:	01 d0                	add    %edx,%eax
80103d40:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d43:	e9 f2 00 00 00       	jmp    80103e3a <mpinit+0x153>
    switch(*p){
80103d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d4b:	0f b6 00             	movzbl (%eax),%eax
80103d4e:	0f b6 c0             	movzbl %al,%eax
80103d51:	83 f8 04             	cmp    $0x4,%eax
80103d54:	0f 87 bc 00 00 00    	ja     80103e16 <mpinit+0x12f>
80103d5a:	8b 04 85 2c 88 10 80 	mov    -0x7fef77d4(,%eax,4),%eax
80103d61:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d66:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103d69:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d6c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d70:	0f b6 d0             	movzbl %al,%edx
80103d73:	a1 60 29 11 80       	mov    0x80112960,%eax
80103d78:	39 c2                	cmp    %eax,%edx
80103d7a:	74 2b                	je     80103da7 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103d7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d7f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d83:	0f b6 d0             	movzbl %al,%edx
80103d86:	a1 60 29 11 80       	mov    0x80112960,%eax
80103d8b:	83 ec 04             	sub    $0x4,%esp
80103d8e:	52                   	push   %edx
80103d8f:	50                   	push   %eax
80103d90:	68 ee 87 10 80       	push   $0x801087ee
80103d95:	e8 2c c6 ff ff       	call   801003c6 <cprintf>
80103d9a:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103d9d:	c7 05 64 23 11 80 00 	movl   $0x0,0x80112364
80103da4:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103da7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103daa:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103dae:	0f b6 c0             	movzbl %al,%eax
80103db1:	83 e0 02             	and    $0x2,%eax
80103db4:	85 c0                	test   %eax,%eax
80103db6:	74 15                	je     80103dcd <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103db8:	a1 60 29 11 80       	mov    0x80112960,%eax
80103dbd:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103dc3:	05 80 23 11 80       	add    $0x80112380,%eax
80103dc8:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103dcd:	a1 60 29 11 80       	mov    0x80112960,%eax
80103dd2:	8b 15 60 29 11 80    	mov    0x80112960,%edx
80103dd8:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103dde:	05 80 23 11 80       	add    $0x80112380,%eax
80103de3:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103de5:	a1 60 29 11 80       	mov    0x80112960,%eax
80103dea:	83 c0 01             	add    $0x1,%eax
80103ded:	a3 60 29 11 80       	mov    %eax,0x80112960
      p += sizeof(struct mpproc);
80103df2:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103df6:	eb 42                	jmp    80103e3a <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dfb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103dfe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e01:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e05:	a2 60 23 11 80       	mov    %al,0x80112360
      p += sizeof(struct mpioapic);
80103e0a:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e0e:	eb 2a                	jmp    80103e3a <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e10:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e14:	eb 24                	jmp    80103e3a <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e19:	0f b6 00             	movzbl (%eax),%eax
80103e1c:	0f b6 c0             	movzbl %al,%eax
80103e1f:	83 ec 08             	sub    $0x8,%esp
80103e22:	50                   	push   %eax
80103e23:	68 0c 88 10 80       	push   $0x8010880c
80103e28:	e8 99 c5 ff ff       	call   801003c6 <cprintf>
80103e2d:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103e30:	c7 05 64 23 11 80 00 	movl   $0x0,0x80112364
80103e37:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e3d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e40:	0f 82 02 ff ff ff    	jb     80103d48 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103e46:	a1 64 23 11 80       	mov    0x80112364,%eax
80103e4b:	85 c0                	test   %eax,%eax
80103e4d:	75 1d                	jne    80103e6c <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103e4f:	c7 05 60 29 11 80 01 	movl   $0x1,0x80112960
80103e56:	00 00 00 
    lapic = 0;
80103e59:	c7 05 7c 22 11 80 00 	movl   $0x0,0x8011227c
80103e60:	00 00 00 
    ioapicid = 0;
80103e63:	c6 05 60 23 11 80 00 	movb   $0x0,0x80112360
    return;
80103e6a:	eb 3e                	jmp    80103eaa <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103e6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e6f:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103e73:	84 c0                	test   %al,%al
80103e75:	74 33                	je     80103eaa <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103e77:	83 ec 08             	sub    $0x8,%esp
80103e7a:	6a 70                	push   $0x70
80103e7c:	6a 22                	push   $0x22
80103e7e:	e8 1c fc ff ff       	call   80103a9f <outb>
80103e83:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103e86:	83 ec 0c             	sub    $0xc,%esp
80103e89:	6a 23                	push   $0x23
80103e8b:	e8 f2 fb ff ff       	call   80103a82 <inb>
80103e90:	83 c4 10             	add    $0x10,%esp
80103e93:	83 c8 01             	or     $0x1,%eax
80103e96:	0f b6 c0             	movzbl %al,%eax
80103e99:	83 ec 08             	sub    $0x8,%esp
80103e9c:	50                   	push   %eax
80103e9d:	6a 23                	push   $0x23
80103e9f:	e8 fb fb ff ff       	call   80103a9f <outb>
80103ea4:	83 c4 10             	add    $0x10,%esp
80103ea7:	eb 01                	jmp    80103eaa <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103ea9:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103eaa:	c9                   	leave  
80103eab:	c3                   	ret    

80103eac <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103eac:	55                   	push   %ebp
80103ead:	89 e5                	mov    %esp,%ebp
80103eaf:	83 ec 08             	sub    $0x8,%esp
80103eb2:	8b 55 08             	mov    0x8(%ebp),%edx
80103eb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103eb8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103ebc:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ebf:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ec3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ec7:	ee                   	out    %al,(%dx)
}
80103ec8:	90                   	nop
80103ec9:	c9                   	leave  
80103eca:	c3                   	ret    

80103ecb <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103ecb:	55                   	push   %ebp
80103ecc:	89 e5                	mov    %esp,%ebp
80103ece:	83 ec 04             	sub    $0x4,%esp
80103ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103ed8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103edc:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103ee2:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103ee6:	0f b6 c0             	movzbl %al,%eax
80103ee9:	50                   	push   %eax
80103eea:	6a 21                	push   $0x21
80103eec:	e8 bb ff ff ff       	call   80103eac <outb>
80103ef1:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103ef4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103ef8:	66 c1 e8 08          	shr    $0x8,%ax
80103efc:	0f b6 c0             	movzbl %al,%eax
80103eff:	50                   	push   %eax
80103f00:	68 a1 00 00 00       	push   $0xa1
80103f05:	e8 a2 ff ff ff       	call   80103eac <outb>
80103f0a:	83 c4 08             	add    $0x8,%esp
}
80103f0d:	90                   	nop
80103f0e:	c9                   	leave  
80103f0f:	c3                   	ret    

80103f10 <picenable>:

void
picenable(int irq)
{
80103f10:	55                   	push   %ebp
80103f11:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103f13:	8b 45 08             	mov    0x8(%ebp),%eax
80103f16:	ba 01 00 00 00       	mov    $0x1,%edx
80103f1b:	89 c1                	mov    %eax,%ecx
80103f1d:	d3 e2                	shl    %cl,%edx
80103f1f:	89 d0                	mov    %edx,%eax
80103f21:	f7 d0                	not    %eax
80103f23:	89 c2                	mov    %eax,%edx
80103f25:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f2c:	21 d0                	and    %edx,%eax
80103f2e:	0f b7 c0             	movzwl %ax,%eax
80103f31:	50                   	push   %eax
80103f32:	e8 94 ff ff ff       	call   80103ecb <picsetmask>
80103f37:	83 c4 04             	add    $0x4,%esp
}
80103f3a:	90                   	nop
80103f3b:	c9                   	leave  
80103f3c:	c3                   	ret    

80103f3d <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103f3d:	55                   	push   %ebp
80103f3e:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f40:	68 ff 00 00 00       	push   $0xff
80103f45:	6a 21                	push   $0x21
80103f47:	e8 60 ff ff ff       	call   80103eac <outb>
80103f4c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103f4f:	68 ff 00 00 00       	push   $0xff
80103f54:	68 a1 00 00 00       	push   $0xa1
80103f59:	e8 4e ff ff ff       	call   80103eac <outb>
80103f5e:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103f61:	6a 11                	push   $0x11
80103f63:	6a 20                	push   $0x20
80103f65:	e8 42 ff ff ff       	call   80103eac <outb>
80103f6a:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103f6d:	6a 20                	push   $0x20
80103f6f:	6a 21                	push   $0x21
80103f71:	e8 36 ff ff ff       	call   80103eac <outb>
80103f76:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103f79:	6a 04                	push   $0x4
80103f7b:	6a 21                	push   $0x21
80103f7d:	e8 2a ff ff ff       	call   80103eac <outb>
80103f82:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103f85:	6a 03                	push   $0x3
80103f87:	6a 21                	push   $0x21
80103f89:	e8 1e ff ff ff       	call   80103eac <outb>
80103f8e:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103f91:	6a 11                	push   $0x11
80103f93:	68 a0 00 00 00       	push   $0xa0
80103f98:	e8 0f ff ff ff       	call   80103eac <outb>
80103f9d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103fa0:	6a 28                	push   $0x28
80103fa2:	68 a1 00 00 00       	push   $0xa1
80103fa7:	e8 00 ff ff ff       	call   80103eac <outb>
80103fac:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103faf:	6a 02                	push   $0x2
80103fb1:	68 a1 00 00 00       	push   $0xa1
80103fb6:	e8 f1 fe ff ff       	call   80103eac <outb>
80103fbb:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103fbe:	6a 03                	push   $0x3
80103fc0:	68 a1 00 00 00       	push   $0xa1
80103fc5:	e8 e2 fe ff ff       	call   80103eac <outb>
80103fca:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103fcd:	6a 68                	push   $0x68
80103fcf:	6a 20                	push   $0x20
80103fd1:	e8 d6 fe ff ff       	call   80103eac <outb>
80103fd6:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103fd9:	6a 0a                	push   $0xa
80103fdb:	6a 20                	push   $0x20
80103fdd:	e8 ca fe ff ff       	call   80103eac <outb>
80103fe2:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80103fe5:	6a 68                	push   $0x68
80103fe7:	68 a0 00 00 00       	push   $0xa0
80103fec:	e8 bb fe ff ff       	call   80103eac <outb>
80103ff1:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80103ff4:	6a 0a                	push   $0xa
80103ff6:	68 a0 00 00 00       	push   $0xa0
80103ffb:	e8 ac fe ff ff       	call   80103eac <outb>
80104000:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104003:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
8010400a:	66 83 f8 ff          	cmp    $0xffff,%ax
8010400e:	74 13                	je     80104023 <picinit+0xe6>
    picsetmask(irqmask);
80104010:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104017:	0f b7 c0             	movzwl %ax,%eax
8010401a:	50                   	push   %eax
8010401b:	e8 ab fe ff ff       	call   80103ecb <picsetmask>
80104020:	83 c4 04             	add    $0x4,%esp
}
80104023:	90                   	nop
80104024:	c9                   	leave  
80104025:	c3                   	ret    

80104026 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104026:	55                   	push   %ebp
80104027:	89 e5                	mov    %esp,%ebp
80104029:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010402c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104033:	8b 45 0c             	mov    0xc(%ebp),%eax
80104036:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010403c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010403f:	8b 10                	mov    (%eax),%edx
80104041:	8b 45 08             	mov    0x8(%ebp),%eax
80104044:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104046:	e8 2d cf ff ff       	call   80100f78 <filealloc>
8010404b:	89 c2                	mov    %eax,%edx
8010404d:	8b 45 08             	mov    0x8(%ebp),%eax
80104050:	89 10                	mov    %edx,(%eax)
80104052:	8b 45 08             	mov    0x8(%ebp),%eax
80104055:	8b 00                	mov    (%eax),%eax
80104057:	85 c0                	test   %eax,%eax
80104059:	0f 84 cb 00 00 00    	je     8010412a <pipealloc+0x104>
8010405f:	e8 14 cf ff ff       	call   80100f78 <filealloc>
80104064:	89 c2                	mov    %eax,%edx
80104066:	8b 45 0c             	mov    0xc(%ebp),%eax
80104069:	89 10                	mov    %edx,(%eax)
8010406b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010406e:	8b 00                	mov    (%eax),%eax
80104070:	85 c0                	test   %eax,%eax
80104072:	0f 84 b2 00 00 00    	je     8010412a <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104078:	e8 ce eb ff ff       	call   80102c4b <kalloc>
8010407d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104080:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104084:	0f 84 9f 00 00 00    	je     80104129 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
8010408a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010408d:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104094:	00 00 00 
  p->writeopen = 1;
80104097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409a:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040a1:	00 00 00 
  p->nwrite = 0;
801040a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a7:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801040ae:	00 00 00 
  p->nread = 0;
801040b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b4:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801040bb:	00 00 00 
  initlock(&p->lock, "pipe");
801040be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c1:	83 ec 08             	sub    $0x8,%esp
801040c4:	68 40 88 10 80       	push   $0x80108840
801040c9:	50                   	push   %eax
801040ca:	e8 f3 0e 00 00       	call   80104fc2 <initlock>
801040cf:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801040d2:	8b 45 08             	mov    0x8(%ebp),%eax
801040d5:	8b 00                	mov    (%eax),%eax
801040d7:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801040dd:	8b 45 08             	mov    0x8(%ebp),%eax
801040e0:	8b 00                	mov    (%eax),%eax
801040e2:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801040e6:	8b 45 08             	mov    0x8(%ebp),%eax
801040e9:	8b 00                	mov    (%eax),%eax
801040eb:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801040ef:	8b 45 08             	mov    0x8(%ebp),%eax
801040f2:	8b 00                	mov    (%eax),%eax
801040f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040f7:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801040fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801040fd:	8b 00                	mov    (%eax),%eax
801040ff:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104105:	8b 45 0c             	mov    0xc(%ebp),%eax
80104108:	8b 00                	mov    (%eax),%eax
8010410a:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010410e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104111:	8b 00                	mov    (%eax),%eax
80104113:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104117:	8b 45 0c             	mov    0xc(%ebp),%eax
8010411a:	8b 00                	mov    (%eax),%eax
8010411c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010411f:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104122:	b8 00 00 00 00       	mov    $0x0,%eax
80104127:	eb 4e                	jmp    80104177 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104129:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
8010412a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010412e:	74 0e                	je     8010413e <pipealloc+0x118>
    kfree((char*)p);
80104130:	83 ec 0c             	sub    $0xc,%esp
80104133:	ff 75 f4             	pushl  -0xc(%ebp)
80104136:	e8 73 ea ff ff       	call   80102bae <kfree>
8010413b:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010413e:	8b 45 08             	mov    0x8(%ebp),%eax
80104141:	8b 00                	mov    (%eax),%eax
80104143:	85 c0                	test   %eax,%eax
80104145:	74 11                	je     80104158 <pipealloc+0x132>
    fileclose(*f0);
80104147:	8b 45 08             	mov    0x8(%ebp),%eax
8010414a:	8b 00                	mov    (%eax),%eax
8010414c:	83 ec 0c             	sub    $0xc,%esp
8010414f:	50                   	push   %eax
80104150:	e8 e1 ce ff ff       	call   80101036 <fileclose>
80104155:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104158:	8b 45 0c             	mov    0xc(%ebp),%eax
8010415b:	8b 00                	mov    (%eax),%eax
8010415d:	85 c0                	test   %eax,%eax
8010415f:	74 11                	je     80104172 <pipealloc+0x14c>
    fileclose(*f1);
80104161:	8b 45 0c             	mov    0xc(%ebp),%eax
80104164:	8b 00                	mov    (%eax),%eax
80104166:	83 ec 0c             	sub    $0xc,%esp
80104169:	50                   	push   %eax
8010416a:	e8 c7 ce ff ff       	call   80101036 <fileclose>
8010416f:	83 c4 10             	add    $0x10,%esp
  return -1;
80104172:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104177:	c9                   	leave  
80104178:	c3                   	ret    

80104179 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104179:	55                   	push   %ebp
8010417a:	89 e5                	mov    %esp,%ebp
8010417c:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010417f:	8b 45 08             	mov    0x8(%ebp),%eax
80104182:	83 ec 0c             	sub    $0xc,%esp
80104185:	50                   	push   %eax
80104186:	e8 59 0e 00 00       	call   80104fe4 <acquire>
8010418b:	83 c4 10             	add    $0x10,%esp
  if(writable){
8010418e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104192:	74 23                	je     801041b7 <pipeclose+0x3e>
    p->writeopen = 0;
80104194:	8b 45 08             	mov    0x8(%ebp),%eax
80104197:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010419e:	00 00 00 
    wakeup(&p->nread);
801041a1:	8b 45 08             	mov    0x8(%ebp),%eax
801041a4:	05 34 02 00 00       	add    $0x234,%eax
801041a9:	83 ec 0c             	sub    $0xc,%esp
801041ac:	50                   	push   %eax
801041ad:	e8 24 0c 00 00       	call   80104dd6 <wakeup>
801041b2:	83 c4 10             	add    $0x10,%esp
801041b5:	eb 21                	jmp    801041d8 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801041b7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ba:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801041c1:	00 00 00 
    wakeup(&p->nwrite);
801041c4:	8b 45 08             	mov    0x8(%ebp),%eax
801041c7:	05 38 02 00 00       	add    $0x238,%eax
801041cc:	83 ec 0c             	sub    $0xc,%esp
801041cf:	50                   	push   %eax
801041d0:	e8 01 0c 00 00       	call   80104dd6 <wakeup>
801041d5:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801041d8:	8b 45 08             	mov    0x8(%ebp),%eax
801041db:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041e1:	85 c0                	test   %eax,%eax
801041e3:	75 2c                	jne    80104211 <pipeclose+0x98>
801041e5:	8b 45 08             	mov    0x8(%ebp),%eax
801041e8:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801041ee:	85 c0                	test   %eax,%eax
801041f0:	75 1f                	jne    80104211 <pipeclose+0x98>
    release(&p->lock);
801041f2:	8b 45 08             	mov    0x8(%ebp),%eax
801041f5:	83 ec 0c             	sub    $0xc,%esp
801041f8:	50                   	push   %eax
801041f9:	e8 4d 0e 00 00       	call   8010504b <release>
801041fe:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104201:	83 ec 0c             	sub    $0xc,%esp
80104204:	ff 75 08             	pushl  0x8(%ebp)
80104207:	e8 a2 e9 ff ff       	call   80102bae <kfree>
8010420c:	83 c4 10             	add    $0x10,%esp
8010420f:	eb 0f                	jmp    80104220 <pipeclose+0xa7>
  } else
    release(&p->lock);
80104211:	8b 45 08             	mov    0x8(%ebp),%eax
80104214:	83 ec 0c             	sub    $0xc,%esp
80104217:	50                   	push   %eax
80104218:	e8 2e 0e 00 00       	call   8010504b <release>
8010421d:	83 c4 10             	add    $0x10,%esp
}
80104220:	90                   	nop
80104221:	c9                   	leave  
80104222:	c3                   	ret    

80104223 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104223:	55                   	push   %ebp
80104224:	89 e5                	mov    %esp,%ebp
80104226:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104229:	8b 45 08             	mov    0x8(%ebp),%eax
8010422c:	83 ec 0c             	sub    $0xc,%esp
8010422f:	50                   	push   %eax
80104230:	e8 af 0d 00 00       	call   80104fe4 <acquire>
80104235:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104238:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010423f:	e9 ad 00 00 00       	jmp    801042f1 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104244:	8b 45 08             	mov    0x8(%ebp),%eax
80104247:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010424d:	85 c0                	test   %eax,%eax
8010424f:	74 0d                	je     8010425e <pipewrite+0x3b>
80104251:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104257:	8b 40 24             	mov    0x24(%eax),%eax
8010425a:	85 c0                	test   %eax,%eax
8010425c:	74 19                	je     80104277 <pipewrite+0x54>
        release(&p->lock);
8010425e:	8b 45 08             	mov    0x8(%ebp),%eax
80104261:	83 ec 0c             	sub    $0xc,%esp
80104264:	50                   	push   %eax
80104265:	e8 e1 0d 00 00       	call   8010504b <release>
8010426a:	83 c4 10             	add    $0x10,%esp
        return -1;
8010426d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104272:	e9 a8 00 00 00       	jmp    8010431f <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104277:	8b 45 08             	mov    0x8(%ebp),%eax
8010427a:	05 34 02 00 00       	add    $0x234,%eax
8010427f:	83 ec 0c             	sub    $0xc,%esp
80104282:	50                   	push   %eax
80104283:	e8 4e 0b 00 00       	call   80104dd6 <wakeup>
80104288:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010428b:	8b 45 08             	mov    0x8(%ebp),%eax
8010428e:	8b 55 08             	mov    0x8(%ebp),%edx
80104291:	81 c2 38 02 00 00    	add    $0x238,%edx
80104297:	83 ec 08             	sub    $0x8,%esp
8010429a:	50                   	push   %eax
8010429b:	52                   	push   %edx
8010429c:	e8 4a 0a 00 00       	call   80104ceb <sleep>
801042a1:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042a4:	8b 45 08             	mov    0x8(%ebp),%eax
801042a7:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801042ad:	8b 45 08             	mov    0x8(%ebp),%eax
801042b0:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042b6:	05 00 02 00 00       	add    $0x200,%eax
801042bb:	39 c2                	cmp    %eax,%edx
801042bd:	74 85                	je     80104244 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801042bf:	8b 45 08             	mov    0x8(%ebp),%eax
801042c2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042c8:	8d 48 01             	lea    0x1(%eax),%ecx
801042cb:	8b 55 08             	mov    0x8(%ebp),%edx
801042ce:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801042d4:	25 ff 01 00 00       	and    $0x1ff,%eax
801042d9:	89 c1                	mov    %eax,%ecx
801042db:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042de:	8b 45 0c             	mov    0xc(%ebp),%eax
801042e1:	01 d0                	add    %edx,%eax
801042e3:	0f b6 10             	movzbl (%eax),%edx
801042e6:	8b 45 08             	mov    0x8(%ebp),%eax
801042e9:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801042ed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f4:	3b 45 10             	cmp    0x10(%ebp),%eax
801042f7:	7c ab                	jl     801042a4 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801042f9:	8b 45 08             	mov    0x8(%ebp),%eax
801042fc:	05 34 02 00 00       	add    $0x234,%eax
80104301:	83 ec 0c             	sub    $0xc,%esp
80104304:	50                   	push   %eax
80104305:	e8 cc 0a 00 00       	call   80104dd6 <wakeup>
8010430a:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010430d:	8b 45 08             	mov    0x8(%ebp),%eax
80104310:	83 ec 0c             	sub    $0xc,%esp
80104313:	50                   	push   %eax
80104314:	e8 32 0d 00 00       	call   8010504b <release>
80104319:	83 c4 10             	add    $0x10,%esp
  return n;
8010431c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010431f:	c9                   	leave  
80104320:	c3                   	ret    

80104321 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104321:	55                   	push   %ebp
80104322:	89 e5                	mov    %esp,%ebp
80104324:	53                   	push   %ebx
80104325:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104328:	8b 45 08             	mov    0x8(%ebp),%eax
8010432b:	83 ec 0c             	sub    $0xc,%esp
8010432e:	50                   	push   %eax
8010432f:	e8 b0 0c 00 00       	call   80104fe4 <acquire>
80104334:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104337:	eb 3f                	jmp    80104378 <piperead+0x57>
    if(proc->killed){
80104339:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010433f:	8b 40 24             	mov    0x24(%eax),%eax
80104342:	85 c0                	test   %eax,%eax
80104344:	74 19                	je     8010435f <piperead+0x3e>
      release(&p->lock);
80104346:	8b 45 08             	mov    0x8(%ebp),%eax
80104349:	83 ec 0c             	sub    $0xc,%esp
8010434c:	50                   	push   %eax
8010434d:	e8 f9 0c 00 00       	call   8010504b <release>
80104352:	83 c4 10             	add    $0x10,%esp
      return -1;
80104355:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010435a:	e9 bf 00 00 00       	jmp    8010441e <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010435f:	8b 45 08             	mov    0x8(%ebp),%eax
80104362:	8b 55 08             	mov    0x8(%ebp),%edx
80104365:	81 c2 34 02 00 00    	add    $0x234,%edx
8010436b:	83 ec 08             	sub    $0x8,%esp
8010436e:	50                   	push   %eax
8010436f:	52                   	push   %edx
80104370:	e8 76 09 00 00       	call   80104ceb <sleep>
80104375:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104378:	8b 45 08             	mov    0x8(%ebp),%eax
8010437b:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104381:	8b 45 08             	mov    0x8(%ebp),%eax
80104384:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010438a:	39 c2                	cmp    %eax,%edx
8010438c:	75 0d                	jne    8010439b <piperead+0x7a>
8010438e:	8b 45 08             	mov    0x8(%ebp),%eax
80104391:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104397:	85 c0                	test   %eax,%eax
80104399:	75 9e                	jne    80104339 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010439b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043a2:	eb 49                	jmp    801043ed <piperead+0xcc>
    if(p->nread == p->nwrite)
801043a4:	8b 45 08             	mov    0x8(%ebp),%eax
801043a7:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043ad:	8b 45 08             	mov    0x8(%ebp),%eax
801043b0:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043b6:	39 c2                	cmp    %eax,%edx
801043b8:	74 3d                	je     801043f7 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801043ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801043c0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801043c3:	8b 45 08             	mov    0x8(%ebp),%eax
801043c6:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043cc:	8d 48 01             	lea    0x1(%eax),%ecx
801043cf:	8b 55 08             	mov    0x8(%ebp),%edx
801043d2:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801043d8:	25 ff 01 00 00       	and    $0x1ff,%eax
801043dd:	89 c2                	mov    %eax,%edx
801043df:	8b 45 08             	mov    0x8(%ebp),%eax
801043e2:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801043e7:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801043ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f0:	3b 45 10             	cmp    0x10(%ebp),%eax
801043f3:	7c af                	jl     801043a4 <piperead+0x83>
801043f5:	eb 01                	jmp    801043f8 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
801043f7:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801043f8:	8b 45 08             	mov    0x8(%ebp),%eax
801043fb:	05 38 02 00 00       	add    $0x238,%eax
80104400:	83 ec 0c             	sub    $0xc,%esp
80104403:	50                   	push   %eax
80104404:	e8 cd 09 00 00       	call   80104dd6 <wakeup>
80104409:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010440c:	8b 45 08             	mov    0x8(%ebp),%eax
8010440f:	83 ec 0c             	sub    $0xc,%esp
80104412:	50                   	push   %eax
80104413:	e8 33 0c 00 00       	call   8010504b <release>
80104418:	83 c4 10             	add    $0x10,%esp
  return i;
8010441b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010441e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104421:	c9                   	leave  
80104422:	c3                   	ret    

80104423 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104423:	55                   	push   %ebp
80104424:	89 e5                	mov    %esp,%ebp
80104426:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104429:	9c                   	pushf  
8010442a:	58                   	pop    %eax
8010442b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010442e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104431:	c9                   	leave  
80104432:	c3                   	ret    

80104433 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104433:	55                   	push   %ebp
80104434:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104436:	fb                   	sti    
}
80104437:	90                   	nop
80104438:	5d                   	pop    %ebp
80104439:	c3                   	ret    

8010443a <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010443a:	55                   	push   %ebp
8010443b:	89 e5                	mov    %esp,%ebp
8010443d:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104440:	83 ec 08             	sub    $0x8,%esp
80104443:	68 45 88 10 80       	push   $0x80108845
80104448:	68 80 29 11 80       	push   $0x80112980
8010444d:	e8 70 0b 00 00       	call   80104fc2 <initlock>
80104452:	83 c4 10             	add    $0x10,%esp
}
80104455:	90                   	nop
80104456:	c9                   	leave  
80104457:	c3                   	ret    

80104458 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104458:	55                   	push   %ebp
80104459:	89 e5                	mov    %esp,%ebp
8010445b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010445e:	83 ec 0c             	sub    $0xc,%esp
80104461:	68 80 29 11 80       	push   $0x80112980
80104466:	e8 79 0b 00 00       	call   80104fe4 <acquire>
8010446b:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010446e:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104475:	eb 0e                	jmp    80104485 <allocproc+0x2d>
    if(p->state == UNUSED)
80104477:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447a:	8b 40 0c             	mov    0xc(%eax),%eax
8010447d:	85 c0                	test   %eax,%eax
8010447f:	74 27                	je     801044a8 <allocproc+0x50>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104481:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104485:	81 7d f4 b4 48 11 80 	cmpl   $0x801148b4,-0xc(%ebp)
8010448c:	72 e9                	jb     80104477 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
8010448e:	83 ec 0c             	sub    $0xc,%esp
80104491:	68 80 29 11 80       	push   $0x80112980
80104496:	e8 b0 0b 00 00       	call   8010504b <release>
8010449b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010449e:	b8 00 00 00 00       	mov    $0x0,%eax
801044a3:	e9 b4 00 00 00       	jmp    8010455c <allocproc+0x104>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801044a8:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801044a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ac:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801044b3:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801044b8:	8d 50 01             	lea    0x1(%eax),%edx
801044bb:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
801044c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044c4:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
801044c7:	83 ec 0c             	sub    $0xc,%esp
801044ca:	68 80 29 11 80       	push   $0x80112980
801044cf:	e8 77 0b 00 00       	call   8010504b <release>
801044d4:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801044d7:	e8 6f e7 ff ff       	call   80102c4b <kalloc>
801044dc:	89 c2                	mov    %eax,%edx
801044de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e1:	89 50 08             	mov    %edx,0x8(%eax)
801044e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e7:	8b 40 08             	mov    0x8(%eax),%eax
801044ea:	85 c0                	test   %eax,%eax
801044ec:	75 11                	jne    801044ff <allocproc+0xa7>
    p->state = UNUSED;
801044ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801044f8:	b8 00 00 00 00       	mov    $0x0,%eax
801044fd:	eb 5d                	jmp    8010455c <allocproc+0x104>
  }
  sp = p->kstack + KSTACKSIZE;
801044ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104502:	8b 40 08             	mov    0x8(%eax),%eax
80104505:	05 00 10 00 00       	add    $0x1000,%eax
8010450a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010450d:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104514:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104517:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010451a:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010451e:	ba 21 66 10 80       	mov    $0x80106621,%edx
80104523:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104526:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104528:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010452c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104532:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104538:	8b 40 1c             	mov    0x1c(%eax),%eax
8010453b:	83 ec 04             	sub    $0x4,%esp
8010453e:	6a 14                	push   $0x14
80104540:	6a 00                	push   $0x0
80104542:	50                   	push   %eax
80104543:	e8 ff 0c 00 00       	call   80105247 <memset>
80104548:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010454b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104551:	ba a5 4c 10 80       	mov    $0x80104ca5,%edx
80104556:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104559:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010455c:	c9                   	leave  
8010455d:	c3                   	ret    

8010455e <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010455e:	55                   	push   %ebp
8010455f:	89 e5                	mov    %esp,%ebp
80104561:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104564:	e8 ef fe ff ff       	call   80104458 <allocproc>
80104569:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010456c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456f:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm()) == 0)
80104574:	e8 6d 37 00 00       	call   80107ce6 <setupkvm>
80104579:	89 c2                	mov    %eax,%edx
8010457b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457e:	89 50 04             	mov    %edx,0x4(%eax)
80104581:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104584:	8b 40 04             	mov    0x4(%eax),%eax
80104587:	85 c0                	test   %eax,%eax
80104589:	75 0d                	jne    80104598 <userinit+0x3a>
    panic("userinit: out of memory?");
8010458b:	83 ec 0c             	sub    $0xc,%esp
8010458e:	68 4c 88 10 80       	push   $0x8010884c
80104593:	e8 ce bf ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104598:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010459d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a0:	8b 40 04             	mov    0x4(%eax),%eax
801045a3:	83 ec 04             	sub    $0x4,%esp
801045a6:	52                   	push   %edx
801045a7:	68 e0 b4 10 80       	push   $0x8010b4e0
801045ac:	50                   	push   %eax
801045ad:	e8 8e 39 00 00       	call   80107f40 <inituvm>
801045b2:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801045b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b8:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801045be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c1:	8b 40 18             	mov    0x18(%eax),%eax
801045c4:	83 ec 04             	sub    $0x4,%esp
801045c7:	6a 4c                	push   $0x4c
801045c9:	6a 00                	push   $0x0
801045cb:	50                   	push   %eax
801045cc:	e8 76 0c 00 00       	call   80105247 <memset>
801045d1:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801045d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d7:	8b 40 18             	mov    0x18(%eax),%eax
801045da:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801045e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e3:	8b 40 18             	mov    0x18(%eax),%eax
801045e6:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801045ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ef:	8b 40 18             	mov    0x18(%eax),%eax
801045f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045f5:	8b 52 18             	mov    0x18(%edx),%edx
801045f8:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801045fc:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104603:	8b 40 18             	mov    0x18(%eax),%eax
80104606:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104609:	8b 52 18             	mov    0x18(%edx),%edx
8010460c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104610:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104617:	8b 40 18             	mov    0x18(%eax),%eax
8010461a:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104624:	8b 40 18             	mov    0x18(%eax),%eax
80104627:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010462e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104631:	8b 40 18             	mov    0x18(%eax),%eax
80104634:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010463b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463e:	83 c0 6c             	add    $0x6c,%eax
80104641:	83 ec 04             	sub    $0x4,%esp
80104644:	6a 10                	push   $0x10
80104646:	68 65 88 10 80       	push   $0x80108865
8010464b:	50                   	push   %eax
8010464c:	e8 f9 0d 00 00       	call   8010544a <safestrcpy>
80104651:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104654:	83 ec 0c             	sub    $0xc,%esp
80104657:	68 6e 88 10 80       	push   $0x8010886e
8010465c:	e8 ac de ff ff       	call   8010250d <namei>
80104661:	83 c4 10             	add    $0x10,%esp
80104664:	89 c2                	mov    %eax,%edx
80104666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104669:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
8010466c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010466f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104676:	90                   	nop
80104677:	c9                   	leave  
80104678:	c3                   	ret    

80104679 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104679:	55                   	push   %ebp
8010467a:	89 e5                	mov    %esp,%ebp
8010467c:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
8010467f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104685:	8b 00                	mov    (%eax),%eax
80104687:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010468a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010468e:	7e 31                	jle    801046c1 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104690:	8b 55 08             	mov    0x8(%ebp),%edx
80104693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104696:	01 c2                	add    %eax,%edx
80104698:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010469e:	8b 40 04             	mov    0x4(%eax),%eax
801046a1:	83 ec 04             	sub    $0x4,%esp
801046a4:	52                   	push   %edx
801046a5:	ff 75 f4             	pushl  -0xc(%ebp)
801046a8:	50                   	push   %eax
801046a9:	e8 df 39 00 00       	call   8010808d <allocuvm>
801046ae:	83 c4 10             	add    $0x10,%esp
801046b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801046b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046b8:	75 3e                	jne    801046f8 <growproc+0x7f>
      return -1;
801046ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046bf:	eb 59                	jmp    8010471a <growproc+0xa1>
  } else if(n < 0){
801046c1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046c5:	79 31                	jns    801046f8 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801046c7:	8b 55 08             	mov    0x8(%ebp),%edx
801046ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cd:	01 c2                	add    %eax,%edx
801046cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046d5:	8b 40 04             	mov    0x4(%eax),%eax
801046d8:	83 ec 04             	sub    $0x4,%esp
801046db:	52                   	push   %edx
801046dc:	ff 75 f4             	pushl  -0xc(%ebp)
801046df:	50                   	push   %eax
801046e0:	e8 71 3a 00 00       	call   80108156 <deallocuvm>
801046e5:	83 c4 10             	add    $0x10,%esp
801046e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801046eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046ef:	75 07                	jne    801046f8 <growproc+0x7f>
      return -1;
801046f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046f6:	eb 22                	jmp    8010471a <growproc+0xa1>
  }
  proc->sz = sz;
801046f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104701:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104703:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104709:	83 ec 0c             	sub    $0xc,%esp
8010470c:	50                   	push   %eax
8010470d:	e8 bb 36 00 00       	call   80107dcd <switchuvm>
80104712:	83 c4 10             	add    $0x10,%esp
  return 0;
80104715:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010471a:	c9                   	leave  
8010471b:	c3                   	ret    

8010471c <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010471c:	55                   	push   %ebp
8010471d:	89 e5                	mov    %esp,%ebp
8010471f:	57                   	push   %edi
80104720:	56                   	push   %esi
80104721:	53                   	push   %ebx
80104722:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104725:	e8 2e fd ff ff       	call   80104458 <allocproc>
8010472a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010472d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104731:	75 0a                	jne    8010473d <fork+0x21>
    return -1;
80104733:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104738:	e9 68 01 00 00       	jmp    801048a5 <fork+0x189>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010473d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104743:	8b 10                	mov    (%eax),%edx
80104745:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010474b:	8b 40 04             	mov    0x4(%eax),%eax
8010474e:	83 ec 08             	sub    $0x8,%esp
80104751:	52                   	push   %edx
80104752:	50                   	push   %eax
80104753:	e8 9c 3b 00 00       	call   801082f4 <copyuvm>
80104758:	83 c4 10             	add    $0x10,%esp
8010475b:	89 c2                	mov    %eax,%edx
8010475d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104760:	89 50 04             	mov    %edx,0x4(%eax)
80104763:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104766:	8b 40 04             	mov    0x4(%eax),%eax
80104769:	85 c0                	test   %eax,%eax
8010476b:	75 30                	jne    8010479d <fork+0x81>
    kfree(np->kstack);
8010476d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104770:	8b 40 08             	mov    0x8(%eax),%eax
80104773:	83 ec 0c             	sub    $0xc,%esp
80104776:	50                   	push   %eax
80104777:	e8 32 e4 ff ff       	call   80102bae <kfree>
8010477c:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010477f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104782:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104789:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104793:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104798:	e9 08 01 00 00       	jmp    801048a5 <fork+0x189>
  }
  np->sz = proc->sz;
8010479d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047a3:	8b 10                	mov    (%eax),%edx
801047a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047a8:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801047aa:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b4:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801047b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ba:	8b 50 18             	mov    0x18(%eax),%edx
801047bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047c3:	8b 40 18             	mov    0x18(%eax),%eax
801047c6:	89 c3                	mov    %eax,%ebx
801047c8:	b8 13 00 00 00       	mov    $0x13,%eax
801047cd:	89 d7                	mov    %edx,%edi
801047cf:	89 de                	mov    %ebx,%esi
801047d1:	89 c1                	mov    %eax,%ecx
801047d3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801047d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047d8:	8b 40 18             	mov    0x18(%eax),%eax
801047db:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801047e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801047e9:	eb 43                	jmp    8010482e <fork+0x112>
    if(proc->ofile[i])
801047eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801047f4:	83 c2 08             	add    $0x8,%edx
801047f7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047fb:	85 c0                	test   %eax,%eax
801047fd:	74 2b                	je     8010482a <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
801047ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104805:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104808:	83 c2 08             	add    $0x8,%edx
8010480b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010480f:	83 ec 0c             	sub    $0xc,%esp
80104812:	50                   	push   %eax
80104813:	e8 cd c7 ff ff       	call   80100fe5 <filedup>
80104818:	83 c4 10             	add    $0x10,%esp
8010481b:	89 c1                	mov    %eax,%ecx
8010481d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104820:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104823:	83 c2 08             	add    $0x8,%edx
80104826:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010482a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010482e:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104832:	7e b7                	jle    801047eb <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104834:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483a:	8b 40 68             	mov    0x68(%eax),%eax
8010483d:	83 ec 0c             	sub    $0xc,%esp
80104840:	50                   	push   %eax
80104841:	e8 cf d0 ff ff       	call   80101915 <idup>
80104846:	83 c4 10             	add    $0x10,%esp
80104849:	89 c2                	mov    %eax,%edx
8010484b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010484e:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104851:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104857:	8d 50 6c             	lea    0x6c(%eax),%edx
8010485a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010485d:	83 c0 6c             	add    $0x6c,%eax
80104860:	83 ec 04             	sub    $0x4,%esp
80104863:	6a 10                	push   $0x10
80104865:	52                   	push   %edx
80104866:	50                   	push   %eax
80104867:	e8 de 0b 00 00       	call   8010544a <safestrcpy>
8010486c:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
8010486f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104872:	8b 40 10             	mov    0x10(%eax),%eax
80104875:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104878:	83 ec 0c             	sub    $0xc,%esp
8010487b:	68 80 29 11 80       	push   $0x80112980
80104880:	e8 5f 07 00 00       	call   80104fe4 <acquire>
80104885:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
80104888:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010488b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80104892:	83 ec 0c             	sub    $0xc,%esp
80104895:	68 80 29 11 80       	push   $0x80112980
8010489a:	e8 ac 07 00 00       	call   8010504b <release>
8010489f:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801048a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801048a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048a8:	5b                   	pop    %ebx
801048a9:	5e                   	pop    %esi
801048aa:	5f                   	pop    %edi
801048ab:	5d                   	pop    %ebp
801048ac:	c3                   	ret    

801048ad <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801048ad:	55                   	push   %ebp
801048ae:	89 e5                	mov    %esp,%ebp
801048b0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801048b3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801048ba:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801048bf:	39 c2                	cmp    %eax,%edx
801048c1:	75 0d                	jne    801048d0 <exit+0x23>
    panic("init exiting");
801048c3:	83 ec 0c             	sub    $0xc,%esp
801048c6:	68 70 88 10 80       	push   $0x80108870
801048cb:	e8 96 bc ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801048d0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801048d7:	eb 48                	jmp    80104921 <exit+0x74>
    if(proc->ofile[fd]){
801048d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048df:	8b 55 f0             	mov    -0x10(%ebp),%edx
801048e2:	83 c2 08             	add    $0x8,%edx
801048e5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048e9:	85 c0                	test   %eax,%eax
801048eb:	74 30                	je     8010491d <exit+0x70>
      fileclose(proc->ofile[fd]);
801048ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801048f6:	83 c2 08             	add    $0x8,%edx
801048f9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048fd:	83 ec 0c             	sub    $0xc,%esp
80104900:	50                   	push   %eax
80104901:	e8 30 c7 ff ff       	call   80101036 <fileclose>
80104906:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104909:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010490f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104912:	83 c2 08             	add    $0x8,%edx
80104915:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010491c:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010491d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104921:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104925:	7e b2                	jle    801048d9 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104927:	e8 06 ec ff ff       	call   80103532 <begin_op>
  iput(proc->cwd);
8010492c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104932:	8b 40 68             	mov    0x68(%eax),%eax
80104935:	83 ec 0c             	sub    $0xc,%esp
80104938:	50                   	push   %eax
80104939:	e8 e1 d1 ff ff       	call   80101b1f <iput>
8010493e:	83 c4 10             	add    $0x10,%esp
  end_op();
80104941:	e8 78 ec ff ff       	call   801035be <end_op>
  proc->cwd = 0;
80104946:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010494c:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104953:	83 ec 0c             	sub    $0xc,%esp
80104956:	68 80 29 11 80       	push   $0x80112980
8010495b:	e8 84 06 00 00       	call   80104fe4 <acquire>
80104960:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104963:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104969:	8b 40 14             	mov    0x14(%eax),%eax
8010496c:	83 ec 0c             	sub    $0xc,%esp
8010496f:	50                   	push   %eax
80104970:	e8 22 04 00 00       	call   80104d97 <wakeup1>
80104975:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104978:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
8010497f:	eb 3c                	jmp    801049bd <exit+0x110>
    if(p->parent == proc){
80104981:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104984:	8b 50 14             	mov    0x14(%eax),%edx
80104987:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010498d:	39 c2                	cmp    %eax,%edx
8010498f:	75 28                	jne    801049b9 <exit+0x10c>
      p->parent = initproc;
80104991:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
80104997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499a:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010499d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a0:	8b 40 0c             	mov    0xc(%eax),%eax
801049a3:	83 f8 05             	cmp    $0x5,%eax
801049a6:	75 11                	jne    801049b9 <exit+0x10c>
        wakeup1(initproc);
801049a8:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801049ad:	83 ec 0c             	sub    $0xc,%esp
801049b0:	50                   	push   %eax
801049b1:	e8 e1 03 00 00       	call   80104d97 <wakeup1>
801049b6:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049b9:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801049bd:	81 7d f4 b4 48 11 80 	cmpl   $0x801148b4,-0xc(%ebp)
801049c4:	72 bb                	jb     80104981 <exit+0xd4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801049c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049cc:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801049d3:	e8 d6 01 00 00       	call   80104bae <sched>
  panic("zombie exit");
801049d8:	83 ec 0c             	sub    $0xc,%esp
801049db:	68 7d 88 10 80       	push   $0x8010887d
801049e0:	e8 81 bb ff ff       	call   80100566 <panic>

801049e5 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801049e5:	55                   	push   %ebp
801049e6:	89 e5                	mov    %esp,%ebp
801049e8:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801049eb:	83 ec 0c             	sub    $0xc,%esp
801049ee:	68 80 29 11 80       	push   $0x80112980
801049f3:	e8 ec 05 00 00       	call   80104fe4 <acquire>
801049f8:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801049fb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a02:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104a09:	e9 a6 00 00 00       	jmp    80104ab4 <wait+0xcf>
      if(p->parent != proc)
80104a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a11:	8b 50 14             	mov    0x14(%eax),%edx
80104a14:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a1a:	39 c2                	cmp    %eax,%edx
80104a1c:	0f 85 8d 00 00 00    	jne    80104aaf <wait+0xca>
        continue;
      havekids = 1;
80104a22:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a2c:	8b 40 0c             	mov    0xc(%eax),%eax
80104a2f:	83 f8 05             	cmp    $0x5,%eax
80104a32:	75 7c                	jne    80104ab0 <wait+0xcb>
        // Found one.
        pid = p->pid;
80104a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a37:	8b 40 10             	mov    0x10(%eax),%eax
80104a3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a40:	8b 40 08             	mov    0x8(%eax),%eax
80104a43:	83 ec 0c             	sub    $0xc,%esp
80104a46:	50                   	push   %eax
80104a47:	e8 62 e1 ff ff       	call   80102bae <kfree>
80104a4c:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a52:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a5c:	8b 40 04             	mov    0x4(%eax),%eax
80104a5f:	83 ec 0c             	sub    $0xc,%esp
80104a62:	50                   	push   %eax
80104a63:	e8 ab 37 00 00       	call   80108213 <freevm>
80104a68:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a6e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a78:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a82:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8c:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a93:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104a9a:	83 ec 0c             	sub    $0xc,%esp
80104a9d:	68 80 29 11 80       	push   $0x80112980
80104aa2:	e8 a4 05 00 00       	call   8010504b <release>
80104aa7:	83 c4 10             	add    $0x10,%esp
        return pid;
80104aaa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aad:	eb 58                	jmp    80104b07 <wait+0x122>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104aaf:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ab0:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104ab4:	81 7d f4 b4 48 11 80 	cmpl   $0x801148b4,-0xc(%ebp)
80104abb:	0f 82 4d ff ff ff    	jb     80104a0e <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104ac1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104ac5:	74 0d                	je     80104ad4 <wait+0xef>
80104ac7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104acd:	8b 40 24             	mov    0x24(%eax),%eax
80104ad0:	85 c0                	test   %eax,%eax
80104ad2:	74 17                	je     80104aeb <wait+0x106>
      release(&ptable.lock);
80104ad4:	83 ec 0c             	sub    $0xc,%esp
80104ad7:	68 80 29 11 80       	push   $0x80112980
80104adc:	e8 6a 05 00 00       	call   8010504b <release>
80104ae1:	83 c4 10             	add    $0x10,%esp
      return -1;
80104ae4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ae9:	eb 1c                	jmp    80104b07 <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104aeb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104af1:	83 ec 08             	sub    $0x8,%esp
80104af4:	68 80 29 11 80       	push   $0x80112980
80104af9:	50                   	push   %eax
80104afa:	e8 ec 01 00 00       	call   80104ceb <sleep>
80104aff:	83 c4 10             	add    $0x10,%esp
  }
80104b02:	e9 f4 fe ff ff       	jmp    801049fb <wait+0x16>
}
80104b07:	c9                   	leave  
80104b08:	c3                   	ret    

80104b09 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b09:	55                   	push   %ebp
80104b0a:	89 e5                	mov    %esp,%ebp
80104b0c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b0f:	e8 1f f9 ff ff       	call   80104433 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b14:	83 ec 0c             	sub    $0xc,%esp
80104b17:	68 80 29 11 80       	push   $0x80112980
80104b1c:	e8 c3 04 00 00       	call   80104fe4 <acquire>
80104b21:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b24:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104b2b:	eb 63                	jmp    80104b90 <scheduler+0x87>
      if(p->state != RUNNABLE)
80104b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b30:	8b 40 0c             	mov    0xc(%eax),%eax
80104b33:	83 f8 03             	cmp    $0x3,%eax
80104b36:	75 53                	jne    80104b8b <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b3b:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104b41:	83 ec 0c             	sub    $0xc,%esp
80104b44:	ff 75 f4             	pushl  -0xc(%ebp)
80104b47:	e8 81 32 00 00       	call   80107dcd <switchuvm>
80104b4c:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b52:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104b59:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b5f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104b62:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104b69:	83 c2 04             	add    $0x4,%edx
80104b6c:	83 ec 08             	sub    $0x8,%esp
80104b6f:	50                   	push   %eax
80104b70:	52                   	push   %edx
80104b71:	e8 45 09 00 00       	call   801054bb <swtch>
80104b76:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104b79:	e8 32 32 00 00       	call   80107db0 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104b7e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104b85:	00 00 00 00 
80104b89:	eb 01                	jmp    80104b8c <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104b8b:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b8c:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104b90:	81 7d f4 b4 48 11 80 	cmpl   $0x801148b4,-0xc(%ebp)
80104b97:	72 94                	jb     80104b2d <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104b99:	83 ec 0c             	sub    $0xc,%esp
80104b9c:	68 80 29 11 80       	push   $0x80112980
80104ba1:	e8 a5 04 00 00       	call   8010504b <release>
80104ba6:	83 c4 10             	add    $0x10,%esp

  }
80104ba9:	e9 61 ff ff ff       	jmp    80104b0f <scheduler+0x6>

80104bae <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104bae:	55                   	push   %ebp
80104baf:	89 e5                	mov    %esp,%ebp
80104bb1:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104bb4:	83 ec 0c             	sub    $0xc,%esp
80104bb7:	68 80 29 11 80       	push   $0x80112980
80104bbc:	e8 56 05 00 00       	call   80105117 <holding>
80104bc1:	83 c4 10             	add    $0x10,%esp
80104bc4:	85 c0                	test   %eax,%eax
80104bc6:	75 0d                	jne    80104bd5 <sched+0x27>
    panic("sched ptable.lock");
80104bc8:	83 ec 0c             	sub    $0xc,%esp
80104bcb:	68 89 88 10 80       	push   $0x80108889
80104bd0:	e8 91 b9 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80104bd5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104bdb:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104be1:	83 f8 01             	cmp    $0x1,%eax
80104be4:	74 0d                	je     80104bf3 <sched+0x45>
    panic("sched locks");
80104be6:	83 ec 0c             	sub    $0xc,%esp
80104be9:	68 9b 88 10 80       	push   $0x8010889b
80104bee:	e8 73 b9 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80104bf3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bf9:	8b 40 0c             	mov    0xc(%eax),%eax
80104bfc:	83 f8 04             	cmp    $0x4,%eax
80104bff:	75 0d                	jne    80104c0e <sched+0x60>
    panic("sched running");
80104c01:	83 ec 0c             	sub    $0xc,%esp
80104c04:	68 a7 88 10 80       	push   $0x801088a7
80104c09:	e8 58 b9 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80104c0e:	e8 10 f8 ff ff       	call   80104423 <readeflags>
80104c13:	25 00 02 00 00       	and    $0x200,%eax
80104c18:	85 c0                	test   %eax,%eax
80104c1a:	74 0d                	je     80104c29 <sched+0x7b>
    panic("sched interruptible");
80104c1c:	83 ec 0c             	sub    $0xc,%esp
80104c1f:	68 b5 88 10 80       	push   $0x801088b5
80104c24:	e8 3d b9 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80104c29:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c2f:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104c35:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104c38:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c3e:	8b 40 04             	mov    0x4(%eax),%eax
80104c41:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104c48:	83 c2 1c             	add    $0x1c,%edx
80104c4b:	83 ec 08             	sub    $0x8,%esp
80104c4e:	50                   	push   %eax
80104c4f:	52                   	push   %edx
80104c50:	e8 66 08 00 00       	call   801054bb <swtch>
80104c55:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104c58:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c61:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104c67:	90                   	nop
80104c68:	c9                   	leave  
80104c69:	c3                   	ret    

80104c6a <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104c6a:	55                   	push   %ebp
80104c6b:	89 e5                	mov    %esp,%ebp
80104c6d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104c70:	83 ec 0c             	sub    $0xc,%esp
80104c73:	68 80 29 11 80       	push   $0x80112980
80104c78:	e8 67 03 00 00       	call   80104fe4 <acquire>
80104c7d:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104c80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c86:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104c8d:	e8 1c ff ff ff       	call   80104bae <sched>
  release(&ptable.lock);
80104c92:	83 ec 0c             	sub    $0xc,%esp
80104c95:	68 80 29 11 80       	push   $0x80112980
80104c9a:	e8 ac 03 00 00       	call   8010504b <release>
80104c9f:	83 c4 10             	add    $0x10,%esp
}
80104ca2:	90                   	nop
80104ca3:	c9                   	leave  
80104ca4:	c3                   	ret    

80104ca5 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104ca5:	55                   	push   %ebp
80104ca6:	89 e5                	mov    %esp,%ebp
80104ca8:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104cab:	83 ec 0c             	sub    $0xc,%esp
80104cae:	68 80 29 11 80       	push   $0x80112980
80104cb3:	e8 93 03 00 00       	call   8010504b <release>
80104cb8:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104cbb:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104cc0:	85 c0                	test   %eax,%eax
80104cc2:	74 24                	je     80104ce8 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104cc4:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104ccb:	00 00 00 
    iinit(ROOTDEV);
80104cce:	83 ec 0c             	sub    $0xc,%esp
80104cd1:	6a 01                	push   $0x1
80104cd3:	e8 4b c9 ff ff       	call   80101623 <iinit>
80104cd8:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104cdb:	83 ec 0c             	sub    $0xc,%esp
80104cde:	6a 01                	push   $0x1
80104ce0:	e8 2f e6 ff ff       	call   80103314 <initlog>
80104ce5:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104ce8:	90                   	nop
80104ce9:	c9                   	leave  
80104cea:	c3                   	ret    

80104ceb <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104ceb:	55                   	push   %ebp
80104cec:	89 e5                	mov    %esp,%ebp
80104cee:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104cf1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cf7:	85 c0                	test   %eax,%eax
80104cf9:	75 0d                	jne    80104d08 <sleep+0x1d>
    panic("sleep");
80104cfb:	83 ec 0c             	sub    $0xc,%esp
80104cfe:	68 c9 88 10 80       	push   $0x801088c9
80104d03:	e8 5e b8 ff ff       	call   80100566 <panic>

  if(lk == 0)
80104d08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d0c:	75 0d                	jne    80104d1b <sleep+0x30>
    panic("sleep without lk");
80104d0e:	83 ec 0c             	sub    $0xc,%esp
80104d11:	68 cf 88 10 80       	push   $0x801088cf
80104d16:	e8 4b b8 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104d1b:	81 7d 0c 80 29 11 80 	cmpl   $0x80112980,0xc(%ebp)
80104d22:	74 1e                	je     80104d42 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104d24:	83 ec 0c             	sub    $0xc,%esp
80104d27:	68 80 29 11 80       	push   $0x80112980
80104d2c:	e8 b3 02 00 00       	call   80104fe4 <acquire>
80104d31:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104d34:	83 ec 0c             	sub    $0xc,%esp
80104d37:	ff 75 0c             	pushl  0xc(%ebp)
80104d3a:	e8 0c 03 00 00       	call   8010504b <release>
80104d3f:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104d42:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d48:	8b 55 08             	mov    0x8(%ebp),%edx
80104d4b:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104d4e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d54:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104d5b:	e8 4e fe ff ff       	call   80104bae <sched>

  // Tidy up.
  proc->chan = 0;
80104d60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d66:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104d6d:	81 7d 0c 80 29 11 80 	cmpl   $0x80112980,0xc(%ebp)
80104d74:	74 1e                	je     80104d94 <sleep+0xa9>
    release(&ptable.lock);
80104d76:	83 ec 0c             	sub    $0xc,%esp
80104d79:	68 80 29 11 80       	push   $0x80112980
80104d7e:	e8 c8 02 00 00       	call   8010504b <release>
80104d83:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104d86:	83 ec 0c             	sub    $0xc,%esp
80104d89:	ff 75 0c             	pushl  0xc(%ebp)
80104d8c:	e8 53 02 00 00       	call   80104fe4 <acquire>
80104d91:	83 c4 10             	add    $0x10,%esp
  }
}
80104d94:	90                   	nop
80104d95:	c9                   	leave  
80104d96:	c3                   	ret    

80104d97 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104d97:	55                   	push   %ebp
80104d98:	89 e5                	mov    %esp,%ebp
80104d9a:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104d9d:	c7 45 fc b4 29 11 80 	movl   $0x801129b4,-0x4(%ebp)
80104da4:	eb 24                	jmp    80104dca <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104da6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104da9:	8b 40 0c             	mov    0xc(%eax),%eax
80104dac:	83 f8 02             	cmp    $0x2,%eax
80104daf:	75 15                	jne    80104dc6 <wakeup1+0x2f>
80104db1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104db4:	8b 40 20             	mov    0x20(%eax),%eax
80104db7:	3b 45 08             	cmp    0x8(%ebp),%eax
80104dba:	75 0a                	jne    80104dc6 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104dbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dbf:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104dc6:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104dca:	81 7d fc b4 48 11 80 	cmpl   $0x801148b4,-0x4(%ebp)
80104dd1:	72 d3                	jb     80104da6 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104dd3:	90                   	nop
80104dd4:	c9                   	leave  
80104dd5:	c3                   	ret    

80104dd6 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104dd6:	55                   	push   %ebp
80104dd7:	89 e5                	mov    %esp,%ebp
80104dd9:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104ddc:	83 ec 0c             	sub    $0xc,%esp
80104ddf:	68 80 29 11 80       	push   $0x80112980
80104de4:	e8 fb 01 00 00       	call   80104fe4 <acquire>
80104de9:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104dec:	83 ec 0c             	sub    $0xc,%esp
80104def:	ff 75 08             	pushl  0x8(%ebp)
80104df2:	e8 a0 ff ff ff       	call   80104d97 <wakeup1>
80104df7:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104dfa:	83 ec 0c             	sub    $0xc,%esp
80104dfd:	68 80 29 11 80       	push   $0x80112980
80104e02:	e8 44 02 00 00       	call   8010504b <release>
80104e07:	83 c4 10             	add    $0x10,%esp
}
80104e0a:	90                   	nop
80104e0b:	c9                   	leave  
80104e0c:	c3                   	ret    

80104e0d <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104e0d:	55                   	push   %ebp
80104e0e:	89 e5                	mov    %esp,%ebp
80104e10:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e13:	83 ec 0c             	sub    $0xc,%esp
80104e16:	68 80 29 11 80       	push   $0x80112980
80104e1b:	e8 c4 01 00 00       	call   80104fe4 <acquire>
80104e20:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e23:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104e2a:	eb 45                	jmp    80104e71 <kill+0x64>
    if(p->pid == pid){
80104e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e2f:	8b 40 10             	mov    0x10(%eax),%eax
80104e32:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e35:	75 36                	jne    80104e6d <kill+0x60>
      p->killed = 1;
80104e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e3a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e44:	8b 40 0c             	mov    0xc(%eax),%eax
80104e47:	83 f8 02             	cmp    $0x2,%eax
80104e4a:	75 0a                	jne    80104e56 <kill+0x49>
        p->state = RUNNABLE;
80104e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104e56:	83 ec 0c             	sub    $0xc,%esp
80104e59:	68 80 29 11 80       	push   $0x80112980
80104e5e:	e8 e8 01 00 00       	call   8010504b <release>
80104e63:	83 c4 10             	add    $0x10,%esp
      return 0;
80104e66:	b8 00 00 00 00       	mov    $0x0,%eax
80104e6b:	eb 22                	jmp    80104e8f <kill+0x82>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e6d:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104e71:	81 7d f4 b4 48 11 80 	cmpl   $0x801148b4,-0xc(%ebp)
80104e78:	72 b2                	jb     80104e2c <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104e7a:	83 ec 0c             	sub    $0xc,%esp
80104e7d:	68 80 29 11 80       	push   $0x80112980
80104e82:	e8 c4 01 00 00       	call   8010504b <release>
80104e87:	83 c4 10             	add    $0x10,%esp
  return -1;
80104e8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104e8f:	c9                   	leave  
80104e90:	c3                   	ret    

80104e91 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104e91:	55                   	push   %ebp
80104e92:	89 e5                	mov    %esp,%ebp
80104e94:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e97:	c7 45 f0 b4 29 11 80 	movl   $0x801129b4,-0x10(%ebp)
80104e9e:	e9 d7 00 00 00       	jmp    80104f7a <procdump+0xe9>
    if(p->state == UNUSED)
80104ea3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ea6:	8b 40 0c             	mov    0xc(%eax),%eax
80104ea9:	85 c0                	test   %eax,%eax
80104eab:	0f 84 c4 00 00 00    	je     80104f75 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104eb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eb4:	8b 40 0c             	mov    0xc(%eax),%eax
80104eb7:	83 f8 05             	cmp    $0x5,%eax
80104eba:	77 23                	ja     80104edf <procdump+0x4e>
80104ebc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ebf:	8b 40 0c             	mov    0xc(%eax),%eax
80104ec2:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104ec9:	85 c0                	test   %eax,%eax
80104ecb:	74 12                	je     80104edf <procdump+0x4e>
      state = states[p->state];
80104ecd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ed0:	8b 40 0c             	mov    0xc(%eax),%eax
80104ed3:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104eda:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104edd:	eb 07                	jmp    80104ee6 <procdump+0x55>
    else
      state = "???";
80104edf:	c7 45 ec e0 88 10 80 	movl   $0x801088e0,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ee9:	8d 50 6c             	lea    0x6c(%eax),%edx
80104eec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eef:	8b 40 10             	mov    0x10(%eax),%eax
80104ef2:	52                   	push   %edx
80104ef3:	ff 75 ec             	pushl  -0x14(%ebp)
80104ef6:	50                   	push   %eax
80104ef7:	68 e4 88 10 80       	push   $0x801088e4
80104efc:	e8 c5 b4 ff ff       	call   801003c6 <cprintf>
80104f01:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f07:	8b 40 0c             	mov    0xc(%eax),%eax
80104f0a:	83 f8 02             	cmp    $0x2,%eax
80104f0d:	75 54                	jne    80104f63 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104f0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f12:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f15:	8b 40 0c             	mov    0xc(%eax),%eax
80104f18:	83 c0 08             	add    $0x8,%eax
80104f1b:	89 c2                	mov    %eax,%edx
80104f1d:	83 ec 08             	sub    $0x8,%esp
80104f20:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104f23:	50                   	push   %eax
80104f24:	52                   	push   %edx
80104f25:	e8 73 01 00 00       	call   8010509d <getcallerpcs>
80104f2a:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104f2d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f34:	eb 1c                	jmp    80104f52 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f39:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f3d:	83 ec 08             	sub    $0x8,%esp
80104f40:	50                   	push   %eax
80104f41:	68 ed 88 10 80       	push   $0x801088ed
80104f46:	e8 7b b4 ff ff       	call   801003c6 <cprintf>
80104f4b:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104f4e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f52:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104f56:	7f 0b                	jg     80104f63 <procdump+0xd2>
80104f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f5b:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f5f:	85 c0                	test   %eax,%eax
80104f61:	75 d3                	jne    80104f36 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104f63:	83 ec 0c             	sub    $0xc,%esp
80104f66:	68 f1 88 10 80       	push   $0x801088f1
80104f6b:	e8 56 b4 ff ff       	call   801003c6 <cprintf>
80104f70:	83 c4 10             	add    $0x10,%esp
80104f73:	eb 01                	jmp    80104f76 <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104f75:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f76:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104f7a:	81 7d f0 b4 48 11 80 	cmpl   $0x801148b4,-0x10(%ebp)
80104f81:	0f 82 1c ff ff ff    	jb     80104ea3 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104f87:	90                   	nop
80104f88:	c9                   	leave  
80104f89:	c3                   	ret    

80104f8a <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104f8a:	55                   	push   %ebp
80104f8b:	89 e5                	mov    %esp,%ebp
80104f8d:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104f90:	9c                   	pushf  
80104f91:	58                   	pop    %eax
80104f92:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104f95:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f98:	c9                   	leave  
80104f99:	c3                   	ret    

80104f9a <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104f9a:	55                   	push   %ebp
80104f9b:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104f9d:	fa                   	cli    
}
80104f9e:	90                   	nop
80104f9f:	5d                   	pop    %ebp
80104fa0:	c3                   	ret    

80104fa1 <sti>:

static inline void
sti(void)
{
80104fa1:	55                   	push   %ebp
80104fa2:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104fa4:	fb                   	sti    
}
80104fa5:	90                   	nop
80104fa6:	5d                   	pop    %ebp
80104fa7:	c3                   	ret    

80104fa8 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104fa8:	55                   	push   %ebp
80104fa9:	89 e5                	mov    %esp,%ebp
80104fab:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104fae:	8b 55 08             	mov    0x8(%ebp),%edx
80104fb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fb4:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104fb7:	f0 87 02             	lock xchg %eax,(%edx)
80104fba:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104fbd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fc0:	c9                   	leave  
80104fc1:	c3                   	ret    

80104fc2 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104fc2:	55                   	push   %ebp
80104fc3:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104fc5:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc8:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fcb:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104fce:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104fd7:	8b 45 08             	mov    0x8(%ebp),%eax
80104fda:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104fe1:	90                   	nop
80104fe2:	5d                   	pop    %ebp
80104fe3:	c3                   	ret    

80104fe4 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104fe4:	55                   	push   %ebp
80104fe5:	89 e5                	mov    %esp,%ebp
80104fe7:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104fea:	e8 52 01 00 00       	call   80105141 <pushcli>
  if(holding(lk))
80104fef:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff2:	83 ec 0c             	sub    $0xc,%esp
80104ff5:	50                   	push   %eax
80104ff6:	e8 1c 01 00 00       	call   80105117 <holding>
80104ffb:	83 c4 10             	add    $0x10,%esp
80104ffe:	85 c0                	test   %eax,%eax
80105000:	74 0d                	je     8010500f <acquire+0x2b>
    panic("acquire");
80105002:	83 ec 0c             	sub    $0xc,%esp
80105005:	68 1d 89 10 80       	push   $0x8010891d
8010500a:	e8 57 b5 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
8010500f:	90                   	nop
80105010:	8b 45 08             	mov    0x8(%ebp),%eax
80105013:	83 ec 08             	sub    $0x8,%esp
80105016:	6a 01                	push   $0x1
80105018:	50                   	push   %eax
80105019:	e8 8a ff ff ff       	call   80104fa8 <xchg>
8010501e:	83 c4 10             	add    $0x10,%esp
80105021:	85 c0                	test   %eax,%eax
80105023:	75 eb                	jne    80105010 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105025:	8b 45 08             	mov    0x8(%ebp),%eax
80105028:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010502f:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105032:	8b 45 08             	mov    0x8(%ebp),%eax
80105035:	83 c0 0c             	add    $0xc,%eax
80105038:	83 ec 08             	sub    $0x8,%esp
8010503b:	50                   	push   %eax
8010503c:	8d 45 08             	lea    0x8(%ebp),%eax
8010503f:	50                   	push   %eax
80105040:	e8 58 00 00 00       	call   8010509d <getcallerpcs>
80105045:	83 c4 10             	add    $0x10,%esp
}
80105048:	90                   	nop
80105049:	c9                   	leave  
8010504a:	c3                   	ret    

8010504b <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010504b:	55                   	push   %ebp
8010504c:	89 e5                	mov    %esp,%ebp
8010504e:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105051:	83 ec 0c             	sub    $0xc,%esp
80105054:	ff 75 08             	pushl  0x8(%ebp)
80105057:	e8 bb 00 00 00       	call   80105117 <holding>
8010505c:	83 c4 10             	add    $0x10,%esp
8010505f:	85 c0                	test   %eax,%eax
80105061:	75 0d                	jne    80105070 <release+0x25>
    panic("release");
80105063:	83 ec 0c             	sub    $0xc,%esp
80105066:	68 25 89 10 80       	push   $0x80108925
8010506b:	e8 f6 b4 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105070:	8b 45 08             	mov    0x8(%ebp),%eax
80105073:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010507a:	8b 45 08             	mov    0x8(%ebp),%eax
8010507d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105084:	8b 45 08             	mov    0x8(%ebp),%eax
80105087:	83 ec 08             	sub    $0x8,%esp
8010508a:	6a 00                	push   $0x0
8010508c:	50                   	push   %eax
8010508d:	e8 16 ff ff ff       	call   80104fa8 <xchg>
80105092:	83 c4 10             	add    $0x10,%esp

  popcli();
80105095:	e8 ec 00 00 00       	call   80105186 <popcli>
}
8010509a:	90                   	nop
8010509b:	c9                   	leave  
8010509c:	c3                   	ret    

8010509d <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010509d:	55                   	push   %ebp
8010509e:	89 e5                	mov    %esp,%ebp
801050a0:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801050a3:	8b 45 08             	mov    0x8(%ebp),%eax
801050a6:	83 e8 08             	sub    $0x8,%eax
801050a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801050ac:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801050b3:	eb 38                	jmp    801050ed <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801050b5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801050b9:	74 53                	je     8010510e <getcallerpcs+0x71>
801050bb:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801050c2:	76 4a                	jbe    8010510e <getcallerpcs+0x71>
801050c4:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801050c8:	74 44                	je     8010510e <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801050ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801050d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801050d7:	01 c2                	add    %eax,%edx
801050d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050dc:	8b 40 04             	mov    0x4(%eax),%eax
801050df:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801050e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050e4:	8b 00                	mov    (%eax),%eax
801050e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801050e9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801050ed:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801050f1:	7e c2                	jle    801050b5 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801050f3:	eb 19                	jmp    8010510e <getcallerpcs+0x71>
    pcs[i] = 0;
801050f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801050ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105102:	01 d0                	add    %edx,%eax
80105104:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010510a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010510e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105112:	7e e1                	jle    801050f5 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105114:	90                   	nop
80105115:	c9                   	leave  
80105116:	c3                   	ret    

80105117 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105117:	55                   	push   %ebp
80105118:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010511a:	8b 45 08             	mov    0x8(%ebp),%eax
8010511d:	8b 00                	mov    (%eax),%eax
8010511f:	85 c0                	test   %eax,%eax
80105121:	74 17                	je     8010513a <holding+0x23>
80105123:	8b 45 08             	mov    0x8(%ebp),%eax
80105126:	8b 50 08             	mov    0x8(%eax),%edx
80105129:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010512f:	39 c2                	cmp    %eax,%edx
80105131:	75 07                	jne    8010513a <holding+0x23>
80105133:	b8 01 00 00 00       	mov    $0x1,%eax
80105138:	eb 05                	jmp    8010513f <holding+0x28>
8010513a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010513f:	5d                   	pop    %ebp
80105140:	c3                   	ret    

80105141 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105141:	55                   	push   %ebp
80105142:	89 e5                	mov    %esp,%ebp
80105144:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105147:	e8 3e fe ff ff       	call   80104f8a <readeflags>
8010514c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010514f:	e8 46 fe ff ff       	call   80104f9a <cli>
  if(cpu->ncli++ == 0)
80105154:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010515b:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105161:	8d 48 01             	lea    0x1(%eax),%ecx
80105164:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
8010516a:	85 c0                	test   %eax,%eax
8010516c:	75 15                	jne    80105183 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
8010516e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105174:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105177:	81 e2 00 02 00 00    	and    $0x200,%edx
8010517d:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105183:	90                   	nop
80105184:	c9                   	leave  
80105185:	c3                   	ret    

80105186 <popcli>:

void
popcli(void)
{
80105186:	55                   	push   %ebp
80105187:	89 e5                	mov    %esp,%ebp
80105189:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010518c:	e8 f9 fd ff ff       	call   80104f8a <readeflags>
80105191:	25 00 02 00 00       	and    $0x200,%eax
80105196:	85 c0                	test   %eax,%eax
80105198:	74 0d                	je     801051a7 <popcli+0x21>
    panic("popcli - interruptible");
8010519a:	83 ec 0c             	sub    $0xc,%esp
8010519d:	68 2d 89 10 80       	push   $0x8010892d
801051a2:	e8 bf b3 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
801051a7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051ad:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801051b3:	83 ea 01             	sub    $0x1,%edx
801051b6:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801051bc:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801051c2:	85 c0                	test   %eax,%eax
801051c4:	79 0d                	jns    801051d3 <popcli+0x4d>
    panic("popcli");
801051c6:	83 ec 0c             	sub    $0xc,%esp
801051c9:	68 44 89 10 80       	push   $0x80108944
801051ce:	e8 93 b3 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
801051d3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051d9:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801051df:	85 c0                	test   %eax,%eax
801051e1:	75 15                	jne    801051f8 <popcli+0x72>
801051e3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051e9:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801051ef:	85 c0                	test   %eax,%eax
801051f1:	74 05                	je     801051f8 <popcli+0x72>
    sti();
801051f3:	e8 a9 fd ff ff       	call   80104fa1 <sti>
}
801051f8:	90                   	nop
801051f9:	c9                   	leave  
801051fa:	c3                   	ret    

801051fb <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801051fb:	55                   	push   %ebp
801051fc:	89 e5                	mov    %esp,%ebp
801051fe:	57                   	push   %edi
801051ff:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105200:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105203:	8b 55 10             	mov    0x10(%ebp),%edx
80105206:	8b 45 0c             	mov    0xc(%ebp),%eax
80105209:	89 cb                	mov    %ecx,%ebx
8010520b:	89 df                	mov    %ebx,%edi
8010520d:	89 d1                	mov    %edx,%ecx
8010520f:	fc                   	cld    
80105210:	f3 aa                	rep stos %al,%es:(%edi)
80105212:	89 ca                	mov    %ecx,%edx
80105214:	89 fb                	mov    %edi,%ebx
80105216:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105219:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010521c:	90                   	nop
8010521d:	5b                   	pop    %ebx
8010521e:	5f                   	pop    %edi
8010521f:	5d                   	pop    %ebp
80105220:	c3                   	ret    

80105221 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105221:	55                   	push   %ebp
80105222:	89 e5                	mov    %esp,%ebp
80105224:	57                   	push   %edi
80105225:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105226:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105229:	8b 55 10             	mov    0x10(%ebp),%edx
8010522c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010522f:	89 cb                	mov    %ecx,%ebx
80105231:	89 df                	mov    %ebx,%edi
80105233:	89 d1                	mov    %edx,%ecx
80105235:	fc                   	cld    
80105236:	f3 ab                	rep stos %eax,%es:(%edi)
80105238:	89 ca                	mov    %ecx,%edx
8010523a:	89 fb                	mov    %edi,%ebx
8010523c:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010523f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105242:	90                   	nop
80105243:	5b                   	pop    %ebx
80105244:	5f                   	pop    %edi
80105245:	5d                   	pop    %ebp
80105246:	c3                   	ret    

80105247 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105247:	55                   	push   %ebp
80105248:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010524a:	8b 45 08             	mov    0x8(%ebp),%eax
8010524d:	83 e0 03             	and    $0x3,%eax
80105250:	85 c0                	test   %eax,%eax
80105252:	75 43                	jne    80105297 <memset+0x50>
80105254:	8b 45 10             	mov    0x10(%ebp),%eax
80105257:	83 e0 03             	and    $0x3,%eax
8010525a:	85 c0                	test   %eax,%eax
8010525c:	75 39                	jne    80105297 <memset+0x50>
    c &= 0xFF;
8010525e:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105265:	8b 45 10             	mov    0x10(%ebp),%eax
80105268:	c1 e8 02             	shr    $0x2,%eax
8010526b:	89 c1                	mov    %eax,%ecx
8010526d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105270:	c1 e0 18             	shl    $0x18,%eax
80105273:	89 c2                	mov    %eax,%edx
80105275:	8b 45 0c             	mov    0xc(%ebp),%eax
80105278:	c1 e0 10             	shl    $0x10,%eax
8010527b:	09 c2                	or     %eax,%edx
8010527d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105280:	c1 e0 08             	shl    $0x8,%eax
80105283:	09 d0                	or     %edx,%eax
80105285:	0b 45 0c             	or     0xc(%ebp),%eax
80105288:	51                   	push   %ecx
80105289:	50                   	push   %eax
8010528a:	ff 75 08             	pushl  0x8(%ebp)
8010528d:	e8 8f ff ff ff       	call   80105221 <stosl>
80105292:	83 c4 0c             	add    $0xc,%esp
80105295:	eb 12                	jmp    801052a9 <memset+0x62>
  } else
    stosb(dst, c, n);
80105297:	8b 45 10             	mov    0x10(%ebp),%eax
8010529a:	50                   	push   %eax
8010529b:	ff 75 0c             	pushl  0xc(%ebp)
8010529e:	ff 75 08             	pushl  0x8(%ebp)
801052a1:	e8 55 ff ff ff       	call   801051fb <stosb>
801052a6:	83 c4 0c             	add    $0xc,%esp
  return dst;
801052a9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801052ac:	c9                   	leave  
801052ad:	c3                   	ret    

801052ae <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801052ae:	55                   	push   %ebp
801052af:	89 e5                	mov    %esp,%ebp
801052b1:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801052b4:	8b 45 08             	mov    0x8(%ebp),%eax
801052b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801052ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801052bd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801052c0:	eb 30                	jmp    801052f2 <memcmp+0x44>
    if(*s1 != *s2)
801052c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052c5:	0f b6 10             	movzbl (%eax),%edx
801052c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052cb:	0f b6 00             	movzbl (%eax),%eax
801052ce:	38 c2                	cmp    %al,%dl
801052d0:	74 18                	je     801052ea <memcmp+0x3c>
      return *s1 - *s2;
801052d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052d5:	0f b6 00             	movzbl (%eax),%eax
801052d8:	0f b6 d0             	movzbl %al,%edx
801052db:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052de:	0f b6 00             	movzbl (%eax),%eax
801052e1:	0f b6 c0             	movzbl %al,%eax
801052e4:	29 c2                	sub    %eax,%edx
801052e6:	89 d0                	mov    %edx,%eax
801052e8:	eb 1a                	jmp    80105304 <memcmp+0x56>
    s1++, s2++;
801052ea:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801052ee:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801052f2:	8b 45 10             	mov    0x10(%ebp),%eax
801052f5:	8d 50 ff             	lea    -0x1(%eax),%edx
801052f8:	89 55 10             	mov    %edx,0x10(%ebp)
801052fb:	85 c0                	test   %eax,%eax
801052fd:	75 c3                	jne    801052c2 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801052ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105304:	c9                   	leave  
80105305:	c3                   	ret    

80105306 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105306:	55                   	push   %ebp
80105307:	89 e5                	mov    %esp,%ebp
80105309:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010530c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010530f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105312:	8b 45 08             	mov    0x8(%ebp),%eax
80105315:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105318:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010531b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010531e:	73 54                	jae    80105374 <memmove+0x6e>
80105320:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105323:	8b 45 10             	mov    0x10(%ebp),%eax
80105326:	01 d0                	add    %edx,%eax
80105328:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010532b:	76 47                	jbe    80105374 <memmove+0x6e>
    s += n;
8010532d:	8b 45 10             	mov    0x10(%ebp),%eax
80105330:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105333:	8b 45 10             	mov    0x10(%ebp),%eax
80105336:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105339:	eb 13                	jmp    8010534e <memmove+0x48>
      *--d = *--s;
8010533b:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010533f:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105343:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105346:	0f b6 10             	movzbl (%eax),%edx
80105349:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010534c:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010534e:	8b 45 10             	mov    0x10(%ebp),%eax
80105351:	8d 50 ff             	lea    -0x1(%eax),%edx
80105354:	89 55 10             	mov    %edx,0x10(%ebp)
80105357:	85 c0                	test   %eax,%eax
80105359:	75 e0                	jne    8010533b <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010535b:	eb 24                	jmp    80105381 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010535d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105360:	8d 50 01             	lea    0x1(%eax),%edx
80105363:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105366:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105369:	8d 4a 01             	lea    0x1(%edx),%ecx
8010536c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010536f:	0f b6 12             	movzbl (%edx),%edx
80105372:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105374:	8b 45 10             	mov    0x10(%ebp),%eax
80105377:	8d 50 ff             	lea    -0x1(%eax),%edx
8010537a:	89 55 10             	mov    %edx,0x10(%ebp)
8010537d:	85 c0                	test   %eax,%eax
8010537f:	75 dc                	jne    8010535d <memmove+0x57>
      *d++ = *s++;

  return dst;
80105381:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105384:	c9                   	leave  
80105385:	c3                   	ret    

80105386 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105386:	55                   	push   %ebp
80105387:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105389:	ff 75 10             	pushl  0x10(%ebp)
8010538c:	ff 75 0c             	pushl  0xc(%ebp)
8010538f:	ff 75 08             	pushl  0x8(%ebp)
80105392:	e8 6f ff ff ff       	call   80105306 <memmove>
80105397:	83 c4 0c             	add    $0xc,%esp
}
8010539a:	c9                   	leave  
8010539b:	c3                   	ret    

8010539c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010539c:	55                   	push   %ebp
8010539d:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010539f:	eb 0c                	jmp    801053ad <strncmp+0x11>
    n--, p++, q++;
801053a1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801053a5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801053a9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801053ad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053b1:	74 1a                	je     801053cd <strncmp+0x31>
801053b3:	8b 45 08             	mov    0x8(%ebp),%eax
801053b6:	0f b6 00             	movzbl (%eax),%eax
801053b9:	84 c0                	test   %al,%al
801053bb:	74 10                	je     801053cd <strncmp+0x31>
801053bd:	8b 45 08             	mov    0x8(%ebp),%eax
801053c0:	0f b6 10             	movzbl (%eax),%edx
801053c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801053c6:	0f b6 00             	movzbl (%eax),%eax
801053c9:	38 c2                	cmp    %al,%dl
801053cb:	74 d4                	je     801053a1 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801053cd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053d1:	75 07                	jne    801053da <strncmp+0x3e>
    return 0;
801053d3:	b8 00 00 00 00       	mov    $0x0,%eax
801053d8:	eb 16                	jmp    801053f0 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801053da:	8b 45 08             	mov    0x8(%ebp),%eax
801053dd:	0f b6 00             	movzbl (%eax),%eax
801053e0:	0f b6 d0             	movzbl %al,%edx
801053e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801053e6:	0f b6 00             	movzbl (%eax),%eax
801053e9:	0f b6 c0             	movzbl %al,%eax
801053ec:	29 c2                	sub    %eax,%edx
801053ee:	89 d0                	mov    %edx,%eax
}
801053f0:	5d                   	pop    %ebp
801053f1:	c3                   	ret    

801053f2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801053f2:	55                   	push   %ebp
801053f3:	89 e5                	mov    %esp,%ebp
801053f5:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801053f8:	8b 45 08             	mov    0x8(%ebp),%eax
801053fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801053fe:	90                   	nop
801053ff:	8b 45 10             	mov    0x10(%ebp),%eax
80105402:	8d 50 ff             	lea    -0x1(%eax),%edx
80105405:	89 55 10             	mov    %edx,0x10(%ebp)
80105408:	85 c0                	test   %eax,%eax
8010540a:	7e 2c                	jle    80105438 <strncpy+0x46>
8010540c:	8b 45 08             	mov    0x8(%ebp),%eax
8010540f:	8d 50 01             	lea    0x1(%eax),%edx
80105412:	89 55 08             	mov    %edx,0x8(%ebp)
80105415:	8b 55 0c             	mov    0xc(%ebp),%edx
80105418:	8d 4a 01             	lea    0x1(%edx),%ecx
8010541b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010541e:	0f b6 12             	movzbl (%edx),%edx
80105421:	88 10                	mov    %dl,(%eax)
80105423:	0f b6 00             	movzbl (%eax),%eax
80105426:	84 c0                	test   %al,%al
80105428:	75 d5                	jne    801053ff <strncpy+0xd>
    ;
  while(n-- > 0)
8010542a:	eb 0c                	jmp    80105438 <strncpy+0x46>
    *s++ = 0;
8010542c:	8b 45 08             	mov    0x8(%ebp),%eax
8010542f:	8d 50 01             	lea    0x1(%eax),%edx
80105432:	89 55 08             	mov    %edx,0x8(%ebp)
80105435:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105438:	8b 45 10             	mov    0x10(%ebp),%eax
8010543b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010543e:	89 55 10             	mov    %edx,0x10(%ebp)
80105441:	85 c0                	test   %eax,%eax
80105443:	7f e7                	jg     8010542c <strncpy+0x3a>
    *s++ = 0;
  return os;
80105445:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105448:	c9                   	leave  
80105449:	c3                   	ret    

8010544a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010544a:	55                   	push   %ebp
8010544b:	89 e5                	mov    %esp,%ebp
8010544d:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105450:	8b 45 08             	mov    0x8(%ebp),%eax
80105453:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105456:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010545a:	7f 05                	jg     80105461 <safestrcpy+0x17>
    return os;
8010545c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010545f:	eb 31                	jmp    80105492 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105461:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105465:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105469:	7e 1e                	jle    80105489 <safestrcpy+0x3f>
8010546b:	8b 45 08             	mov    0x8(%ebp),%eax
8010546e:	8d 50 01             	lea    0x1(%eax),%edx
80105471:	89 55 08             	mov    %edx,0x8(%ebp)
80105474:	8b 55 0c             	mov    0xc(%ebp),%edx
80105477:	8d 4a 01             	lea    0x1(%edx),%ecx
8010547a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010547d:	0f b6 12             	movzbl (%edx),%edx
80105480:	88 10                	mov    %dl,(%eax)
80105482:	0f b6 00             	movzbl (%eax),%eax
80105485:	84 c0                	test   %al,%al
80105487:	75 d8                	jne    80105461 <safestrcpy+0x17>
    ;
  *s = 0;
80105489:	8b 45 08             	mov    0x8(%ebp),%eax
8010548c:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010548f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105492:	c9                   	leave  
80105493:	c3                   	ret    

80105494 <strlen>:

int
strlen(const char *s)
{
80105494:	55                   	push   %ebp
80105495:	89 e5                	mov    %esp,%ebp
80105497:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010549a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801054a1:	eb 04                	jmp    801054a7 <strlen+0x13>
801054a3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054a7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054aa:	8b 45 08             	mov    0x8(%ebp),%eax
801054ad:	01 d0                	add    %edx,%eax
801054af:	0f b6 00             	movzbl (%eax),%eax
801054b2:	84 c0                	test   %al,%al
801054b4:	75 ed                	jne    801054a3 <strlen+0xf>
    ;
  return n;
801054b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054b9:	c9                   	leave  
801054ba:	c3                   	ret    

801054bb <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801054bb:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801054bf:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801054c3:	55                   	push   %ebp
  pushl %ebx
801054c4:	53                   	push   %ebx
  pushl %esi
801054c5:	56                   	push   %esi
  pushl %edi
801054c6:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801054c7:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801054c9:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801054cb:	5f                   	pop    %edi
  popl %esi
801054cc:	5e                   	pop    %esi
  popl %ebx
801054cd:	5b                   	pop    %ebx
  popl %ebp
801054ce:	5d                   	pop    %ebp
  ret
801054cf:	c3                   	ret    

801054d0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801054d0:	55                   	push   %ebp
801054d1:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801054d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054d9:	8b 00                	mov    (%eax),%eax
801054db:	3b 45 08             	cmp    0x8(%ebp),%eax
801054de:	76 12                	jbe    801054f2 <fetchint+0x22>
801054e0:	8b 45 08             	mov    0x8(%ebp),%eax
801054e3:	8d 50 04             	lea    0x4(%eax),%edx
801054e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054ec:	8b 00                	mov    (%eax),%eax
801054ee:	39 c2                	cmp    %eax,%edx
801054f0:	76 07                	jbe    801054f9 <fetchint+0x29>
    return -1;
801054f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054f7:	eb 0f                	jmp    80105508 <fetchint+0x38>
  *ip = *(int*)(addr);
801054f9:	8b 45 08             	mov    0x8(%ebp),%eax
801054fc:	8b 10                	mov    (%eax),%edx
801054fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105501:	89 10                	mov    %edx,(%eax)
  return 0;
80105503:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105508:	5d                   	pop    %ebp
80105509:	c3                   	ret    

8010550a <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010550a:	55                   	push   %ebp
8010550b:	89 e5                	mov    %esp,%ebp
8010550d:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105510:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105516:	8b 00                	mov    (%eax),%eax
80105518:	3b 45 08             	cmp    0x8(%ebp),%eax
8010551b:	77 07                	ja     80105524 <fetchstr+0x1a>
    return -1;
8010551d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105522:	eb 46                	jmp    8010556a <fetchstr+0x60>
  *pp = (char*)addr;
80105524:	8b 55 08             	mov    0x8(%ebp),%edx
80105527:	8b 45 0c             	mov    0xc(%ebp),%eax
8010552a:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
8010552c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105532:	8b 00                	mov    (%eax),%eax
80105534:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105537:	8b 45 0c             	mov    0xc(%ebp),%eax
8010553a:	8b 00                	mov    (%eax),%eax
8010553c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010553f:	eb 1c                	jmp    8010555d <fetchstr+0x53>
    if(*s == 0)
80105541:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105544:	0f b6 00             	movzbl (%eax),%eax
80105547:	84 c0                	test   %al,%al
80105549:	75 0e                	jne    80105559 <fetchstr+0x4f>
      return s - *pp;
8010554b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010554e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105551:	8b 00                	mov    (%eax),%eax
80105553:	29 c2                	sub    %eax,%edx
80105555:	89 d0                	mov    %edx,%eax
80105557:	eb 11                	jmp    8010556a <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105559:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010555d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105560:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105563:	72 dc                	jb     80105541 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105565:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010556a:	c9                   	leave  
8010556b:	c3                   	ret    

8010556c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010556c:	55                   	push   %ebp
8010556d:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010556f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105575:	8b 40 18             	mov    0x18(%eax),%eax
80105578:	8b 40 44             	mov    0x44(%eax),%eax
8010557b:	8b 55 08             	mov    0x8(%ebp),%edx
8010557e:	c1 e2 02             	shl    $0x2,%edx
80105581:	01 d0                	add    %edx,%eax
80105583:	83 c0 04             	add    $0x4,%eax
80105586:	ff 75 0c             	pushl  0xc(%ebp)
80105589:	50                   	push   %eax
8010558a:	e8 41 ff ff ff       	call   801054d0 <fetchint>
8010558f:	83 c4 08             	add    $0x8,%esp
}
80105592:	c9                   	leave  
80105593:	c3                   	ret    

80105594 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105594:	55                   	push   %ebp
80105595:	89 e5                	mov    %esp,%ebp
80105597:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010559a:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010559d:	50                   	push   %eax
8010559e:	ff 75 08             	pushl  0x8(%ebp)
801055a1:	e8 c6 ff ff ff       	call   8010556c <argint>
801055a6:	83 c4 08             	add    $0x8,%esp
801055a9:	85 c0                	test   %eax,%eax
801055ab:	79 07                	jns    801055b4 <argptr+0x20>
    return -1;
801055ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055b2:	eb 3b                	jmp    801055ef <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801055b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055ba:	8b 00                	mov    (%eax),%eax
801055bc:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055bf:	39 d0                	cmp    %edx,%eax
801055c1:	76 16                	jbe    801055d9 <argptr+0x45>
801055c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055c6:	89 c2                	mov    %eax,%edx
801055c8:	8b 45 10             	mov    0x10(%ebp),%eax
801055cb:	01 c2                	add    %eax,%edx
801055cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055d3:	8b 00                	mov    (%eax),%eax
801055d5:	39 c2                	cmp    %eax,%edx
801055d7:	76 07                	jbe    801055e0 <argptr+0x4c>
    return -1;
801055d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055de:	eb 0f                	jmp    801055ef <argptr+0x5b>
  *pp = (char*)i;
801055e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055e3:	89 c2                	mov    %eax,%edx
801055e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801055e8:	89 10                	mov    %edx,(%eax)
  return 0;
801055ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055ef:	c9                   	leave  
801055f0:	c3                   	ret    

801055f1 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801055f1:	55                   	push   %ebp
801055f2:	89 e5                	mov    %esp,%ebp
801055f4:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
801055f7:	8d 45 fc             	lea    -0x4(%ebp),%eax
801055fa:	50                   	push   %eax
801055fb:	ff 75 08             	pushl  0x8(%ebp)
801055fe:	e8 69 ff ff ff       	call   8010556c <argint>
80105603:	83 c4 08             	add    $0x8,%esp
80105606:	85 c0                	test   %eax,%eax
80105608:	79 07                	jns    80105611 <argstr+0x20>
    return -1;
8010560a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010560f:	eb 0f                	jmp    80105620 <argstr+0x2f>
  return fetchstr(addr, pp);
80105611:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105614:	ff 75 0c             	pushl  0xc(%ebp)
80105617:	50                   	push   %eax
80105618:	e8 ed fe ff ff       	call   8010550a <fetchstr>
8010561d:	83 c4 08             	add    $0x8,%esp
}
80105620:	c9                   	leave  
80105621:	c3                   	ret    

80105622 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80105622:	55                   	push   %ebp
80105623:	89 e5                	mov    %esp,%ebp
80105625:	53                   	push   %ebx
80105626:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80105629:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010562f:	8b 40 18             	mov    0x18(%eax),%eax
80105632:	8b 40 1c             	mov    0x1c(%eax),%eax
80105635:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105638:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010563c:	7e 30                	jle    8010566e <syscall+0x4c>
8010563e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105641:	83 f8 15             	cmp    $0x15,%eax
80105644:	77 28                	ja     8010566e <syscall+0x4c>
80105646:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105649:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105650:	85 c0                	test   %eax,%eax
80105652:	74 1a                	je     8010566e <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105654:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010565a:	8b 58 18             	mov    0x18(%eax),%ebx
8010565d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105660:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105667:	ff d0                	call   *%eax
80105669:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010566c:	eb 34                	jmp    801056a2 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010566e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105674:	8d 50 6c             	lea    0x6c(%eax),%edx
80105677:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010567d:	8b 40 10             	mov    0x10(%eax),%eax
80105680:	ff 75 f4             	pushl  -0xc(%ebp)
80105683:	52                   	push   %edx
80105684:	50                   	push   %eax
80105685:	68 4b 89 10 80       	push   $0x8010894b
8010568a:	e8 37 ad ff ff       	call   801003c6 <cprintf>
8010568f:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105692:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105698:	8b 40 18             	mov    0x18(%eax),%eax
8010569b:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801056a2:	90                   	nop
801056a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801056a6:	c9                   	leave  
801056a7:	c3                   	ret    

801056a8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801056a8:	55                   	push   %ebp
801056a9:	89 e5                	mov    %esp,%ebp
801056ab:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801056ae:	83 ec 08             	sub    $0x8,%esp
801056b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056b4:	50                   	push   %eax
801056b5:	ff 75 08             	pushl  0x8(%ebp)
801056b8:	e8 af fe ff ff       	call   8010556c <argint>
801056bd:	83 c4 10             	add    $0x10,%esp
801056c0:	85 c0                	test   %eax,%eax
801056c2:	79 07                	jns    801056cb <argfd+0x23>
    return -1;
801056c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c9:	eb 50                	jmp    8010571b <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801056cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056ce:	85 c0                	test   %eax,%eax
801056d0:	78 21                	js     801056f3 <argfd+0x4b>
801056d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d5:	83 f8 0f             	cmp    $0xf,%eax
801056d8:	7f 19                	jg     801056f3 <argfd+0x4b>
801056da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056e3:	83 c2 08             	add    $0x8,%edx
801056e6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801056ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056f1:	75 07                	jne    801056fa <argfd+0x52>
    return -1;
801056f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f8:	eb 21                	jmp    8010571b <argfd+0x73>
  if(pfd)
801056fa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801056fe:	74 08                	je     80105708 <argfd+0x60>
    *pfd = fd;
80105700:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105703:	8b 45 0c             	mov    0xc(%ebp),%eax
80105706:	89 10                	mov    %edx,(%eax)
  if(pf)
80105708:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010570c:	74 08                	je     80105716 <argfd+0x6e>
    *pf = f;
8010570e:	8b 45 10             	mov    0x10(%ebp),%eax
80105711:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105714:	89 10                	mov    %edx,(%eax)
  return 0;
80105716:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010571b:	c9                   	leave  
8010571c:	c3                   	ret    

8010571d <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010571d:	55                   	push   %ebp
8010571e:	89 e5                	mov    %esp,%ebp
80105720:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105723:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010572a:	eb 30                	jmp    8010575c <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
8010572c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105732:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105735:	83 c2 08             	add    $0x8,%edx
80105738:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010573c:	85 c0                	test   %eax,%eax
8010573e:	75 18                	jne    80105758 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105740:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105746:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105749:	8d 4a 08             	lea    0x8(%edx),%ecx
8010574c:	8b 55 08             	mov    0x8(%ebp),%edx
8010574f:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105753:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105756:	eb 0f                	jmp    80105767 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105758:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010575c:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105760:	7e ca                	jle    8010572c <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105762:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105767:	c9                   	leave  
80105768:	c3                   	ret    

80105769 <sys_dup>:

int
sys_dup(void)
{
80105769:	55                   	push   %ebp
8010576a:	89 e5                	mov    %esp,%ebp
8010576c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010576f:	83 ec 04             	sub    $0x4,%esp
80105772:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105775:	50                   	push   %eax
80105776:	6a 00                	push   $0x0
80105778:	6a 00                	push   $0x0
8010577a:	e8 29 ff ff ff       	call   801056a8 <argfd>
8010577f:	83 c4 10             	add    $0x10,%esp
80105782:	85 c0                	test   %eax,%eax
80105784:	79 07                	jns    8010578d <sys_dup+0x24>
    return -1;
80105786:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010578b:	eb 31                	jmp    801057be <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010578d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105790:	83 ec 0c             	sub    $0xc,%esp
80105793:	50                   	push   %eax
80105794:	e8 84 ff ff ff       	call   8010571d <fdalloc>
80105799:	83 c4 10             	add    $0x10,%esp
8010579c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010579f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057a3:	79 07                	jns    801057ac <sys_dup+0x43>
    return -1;
801057a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057aa:	eb 12                	jmp    801057be <sys_dup+0x55>
  filedup(f);
801057ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057af:	83 ec 0c             	sub    $0xc,%esp
801057b2:	50                   	push   %eax
801057b3:	e8 2d b8 ff ff       	call   80100fe5 <filedup>
801057b8:	83 c4 10             	add    $0x10,%esp
  return fd;
801057bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801057be:	c9                   	leave  
801057bf:	c3                   	ret    

801057c0 <sys_read>:

int
sys_read(void)
{
801057c0:	55                   	push   %ebp
801057c1:	89 e5                	mov    %esp,%ebp
801057c3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801057c6:	83 ec 04             	sub    $0x4,%esp
801057c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057cc:	50                   	push   %eax
801057cd:	6a 00                	push   $0x0
801057cf:	6a 00                	push   $0x0
801057d1:	e8 d2 fe ff ff       	call   801056a8 <argfd>
801057d6:	83 c4 10             	add    $0x10,%esp
801057d9:	85 c0                	test   %eax,%eax
801057db:	78 2e                	js     8010580b <sys_read+0x4b>
801057dd:	83 ec 08             	sub    $0x8,%esp
801057e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057e3:	50                   	push   %eax
801057e4:	6a 02                	push   $0x2
801057e6:	e8 81 fd ff ff       	call   8010556c <argint>
801057eb:	83 c4 10             	add    $0x10,%esp
801057ee:	85 c0                	test   %eax,%eax
801057f0:	78 19                	js     8010580b <sys_read+0x4b>
801057f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f5:	83 ec 04             	sub    $0x4,%esp
801057f8:	50                   	push   %eax
801057f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801057fc:	50                   	push   %eax
801057fd:	6a 01                	push   $0x1
801057ff:	e8 90 fd ff ff       	call   80105594 <argptr>
80105804:	83 c4 10             	add    $0x10,%esp
80105807:	85 c0                	test   %eax,%eax
80105809:	79 07                	jns    80105812 <sys_read+0x52>
    return -1;
8010580b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105810:	eb 17                	jmp    80105829 <sys_read+0x69>
  return fileread(f, p, n);
80105812:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105815:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010581b:	83 ec 04             	sub    $0x4,%esp
8010581e:	51                   	push   %ecx
8010581f:	52                   	push   %edx
80105820:	50                   	push   %eax
80105821:	e8 4f b9 ff ff       	call   80101175 <fileread>
80105826:	83 c4 10             	add    $0x10,%esp
}
80105829:	c9                   	leave  
8010582a:	c3                   	ret    

8010582b <sys_write>:

int
sys_write(void)
{
8010582b:	55                   	push   %ebp
8010582c:	89 e5                	mov    %esp,%ebp
8010582e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105831:	83 ec 04             	sub    $0x4,%esp
80105834:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105837:	50                   	push   %eax
80105838:	6a 00                	push   $0x0
8010583a:	6a 00                	push   $0x0
8010583c:	e8 67 fe ff ff       	call   801056a8 <argfd>
80105841:	83 c4 10             	add    $0x10,%esp
80105844:	85 c0                	test   %eax,%eax
80105846:	78 2e                	js     80105876 <sys_write+0x4b>
80105848:	83 ec 08             	sub    $0x8,%esp
8010584b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010584e:	50                   	push   %eax
8010584f:	6a 02                	push   $0x2
80105851:	e8 16 fd ff ff       	call   8010556c <argint>
80105856:	83 c4 10             	add    $0x10,%esp
80105859:	85 c0                	test   %eax,%eax
8010585b:	78 19                	js     80105876 <sys_write+0x4b>
8010585d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105860:	83 ec 04             	sub    $0x4,%esp
80105863:	50                   	push   %eax
80105864:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105867:	50                   	push   %eax
80105868:	6a 01                	push   $0x1
8010586a:	e8 25 fd ff ff       	call   80105594 <argptr>
8010586f:	83 c4 10             	add    $0x10,%esp
80105872:	85 c0                	test   %eax,%eax
80105874:	79 07                	jns    8010587d <sys_write+0x52>
    return -1;
80105876:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010587b:	eb 17                	jmp    80105894 <sys_write+0x69>
  return filewrite(f, p, n);
8010587d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105880:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105886:	83 ec 04             	sub    $0x4,%esp
80105889:	51                   	push   %ecx
8010588a:	52                   	push   %edx
8010588b:	50                   	push   %eax
8010588c:	e8 9c b9 ff ff       	call   8010122d <filewrite>
80105891:	83 c4 10             	add    $0x10,%esp
}
80105894:	c9                   	leave  
80105895:	c3                   	ret    

80105896 <sys_close>:

int
sys_close(void)
{
80105896:	55                   	push   %ebp
80105897:	89 e5                	mov    %esp,%ebp
80105899:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010589c:	83 ec 04             	sub    $0x4,%esp
8010589f:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058a2:	50                   	push   %eax
801058a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058a6:	50                   	push   %eax
801058a7:	6a 00                	push   $0x0
801058a9:	e8 fa fd ff ff       	call   801056a8 <argfd>
801058ae:	83 c4 10             	add    $0x10,%esp
801058b1:	85 c0                	test   %eax,%eax
801058b3:	79 07                	jns    801058bc <sys_close+0x26>
    return -1;
801058b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058ba:	eb 28                	jmp    801058e4 <sys_close+0x4e>
  proc->ofile[fd] = 0;
801058bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058c5:	83 c2 08             	add    $0x8,%edx
801058c8:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801058cf:	00 
  fileclose(f);
801058d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058d3:	83 ec 0c             	sub    $0xc,%esp
801058d6:	50                   	push   %eax
801058d7:	e8 5a b7 ff ff       	call   80101036 <fileclose>
801058dc:	83 c4 10             	add    $0x10,%esp
  return 0;
801058df:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058e4:	c9                   	leave  
801058e5:	c3                   	ret    

801058e6 <sys_fstat>:

int
sys_fstat(void)
{
801058e6:	55                   	push   %ebp
801058e7:	89 e5                	mov    %esp,%ebp
801058e9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801058ec:	83 ec 04             	sub    $0x4,%esp
801058ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058f2:	50                   	push   %eax
801058f3:	6a 00                	push   $0x0
801058f5:	6a 00                	push   $0x0
801058f7:	e8 ac fd ff ff       	call   801056a8 <argfd>
801058fc:	83 c4 10             	add    $0x10,%esp
801058ff:	85 c0                	test   %eax,%eax
80105901:	78 17                	js     8010591a <sys_fstat+0x34>
80105903:	83 ec 04             	sub    $0x4,%esp
80105906:	6a 14                	push   $0x14
80105908:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010590b:	50                   	push   %eax
8010590c:	6a 01                	push   $0x1
8010590e:	e8 81 fc ff ff       	call   80105594 <argptr>
80105913:	83 c4 10             	add    $0x10,%esp
80105916:	85 c0                	test   %eax,%eax
80105918:	79 07                	jns    80105921 <sys_fstat+0x3b>
    return -1;
8010591a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591f:	eb 13                	jmp    80105934 <sys_fstat+0x4e>
  return filestat(f, st);
80105921:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105927:	83 ec 08             	sub    $0x8,%esp
8010592a:	52                   	push   %edx
8010592b:	50                   	push   %eax
8010592c:	e8 ed b7 ff ff       	call   8010111e <filestat>
80105931:	83 c4 10             	add    $0x10,%esp
}
80105934:	c9                   	leave  
80105935:	c3                   	ret    

80105936 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105936:	55                   	push   %ebp
80105937:	89 e5                	mov    %esp,%ebp
80105939:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010593c:	83 ec 08             	sub    $0x8,%esp
8010593f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105942:	50                   	push   %eax
80105943:	6a 00                	push   $0x0
80105945:	e8 a7 fc ff ff       	call   801055f1 <argstr>
8010594a:	83 c4 10             	add    $0x10,%esp
8010594d:	85 c0                	test   %eax,%eax
8010594f:	78 15                	js     80105966 <sys_link+0x30>
80105951:	83 ec 08             	sub    $0x8,%esp
80105954:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105957:	50                   	push   %eax
80105958:	6a 01                	push   $0x1
8010595a:	e8 92 fc ff ff       	call   801055f1 <argstr>
8010595f:	83 c4 10             	add    $0x10,%esp
80105962:	85 c0                	test   %eax,%eax
80105964:	79 0a                	jns    80105970 <sys_link+0x3a>
    return -1;
80105966:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010596b:	e9 68 01 00 00       	jmp    80105ad8 <sys_link+0x1a2>

  begin_op();
80105970:	e8 bd db ff ff       	call   80103532 <begin_op>
  if((ip = namei(old)) == 0){
80105975:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105978:	83 ec 0c             	sub    $0xc,%esp
8010597b:	50                   	push   %eax
8010597c:	e8 8c cb ff ff       	call   8010250d <namei>
80105981:	83 c4 10             	add    $0x10,%esp
80105984:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105987:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010598b:	75 0f                	jne    8010599c <sys_link+0x66>
    end_op();
8010598d:	e8 2c dc ff ff       	call   801035be <end_op>
    return -1;
80105992:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105997:	e9 3c 01 00 00       	jmp    80105ad8 <sys_link+0x1a2>
  }

  ilock(ip);
8010599c:	83 ec 0c             	sub    $0xc,%esp
8010599f:	ff 75 f4             	pushl  -0xc(%ebp)
801059a2:	e8 a8 bf ff ff       	call   8010194f <ilock>
801059a7:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801059aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ad:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801059b1:	66 83 f8 01          	cmp    $0x1,%ax
801059b5:	75 1d                	jne    801059d4 <sys_link+0x9e>
    iunlockput(ip);
801059b7:	83 ec 0c             	sub    $0xc,%esp
801059ba:	ff 75 f4             	pushl  -0xc(%ebp)
801059bd:	e8 4d c2 ff ff       	call   80101c0f <iunlockput>
801059c2:	83 c4 10             	add    $0x10,%esp
    end_op();
801059c5:	e8 f4 db ff ff       	call   801035be <end_op>
    return -1;
801059ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059cf:	e9 04 01 00 00       	jmp    80105ad8 <sys_link+0x1a2>
  }

  ip->nlink++;
801059d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801059db:	83 c0 01             	add    $0x1,%eax
801059de:	89 c2                	mov    %eax,%edx
801059e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e3:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801059e7:	83 ec 0c             	sub    $0xc,%esp
801059ea:	ff 75 f4             	pushl  -0xc(%ebp)
801059ed:	e8 83 bd ff ff       	call   80101775 <iupdate>
801059f2:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801059f5:	83 ec 0c             	sub    $0xc,%esp
801059f8:	ff 75 f4             	pushl  -0xc(%ebp)
801059fb:	e8 ad c0 ff ff       	call   80101aad <iunlock>
80105a00:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105a03:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a06:	83 ec 08             	sub    $0x8,%esp
80105a09:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105a0c:	52                   	push   %edx
80105a0d:	50                   	push   %eax
80105a0e:	e8 16 cb ff ff       	call   80102529 <nameiparent>
80105a13:	83 c4 10             	add    $0x10,%esp
80105a16:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a19:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a1d:	74 71                	je     80105a90 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105a1f:	83 ec 0c             	sub    $0xc,%esp
80105a22:	ff 75 f0             	pushl  -0x10(%ebp)
80105a25:	e8 25 bf ff ff       	call   8010194f <ilock>
80105a2a:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105a2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a30:	8b 10                	mov    (%eax),%edx
80105a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a35:	8b 00                	mov    (%eax),%eax
80105a37:	39 c2                	cmp    %eax,%edx
80105a39:	75 1d                	jne    80105a58 <sys_link+0x122>
80105a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3e:	8b 40 04             	mov    0x4(%eax),%eax
80105a41:	83 ec 04             	sub    $0x4,%esp
80105a44:	50                   	push   %eax
80105a45:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105a48:	50                   	push   %eax
80105a49:	ff 75 f0             	pushl  -0x10(%ebp)
80105a4c:	e8 20 c8 ff ff       	call   80102271 <dirlink>
80105a51:	83 c4 10             	add    $0x10,%esp
80105a54:	85 c0                	test   %eax,%eax
80105a56:	79 10                	jns    80105a68 <sys_link+0x132>
    iunlockput(dp);
80105a58:	83 ec 0c             	sub    $0xc,%esp
80105a5b:	ff 75 f0             	pushl  -0x10(%ebp)
80105a5e:	e8 ac c1 ff ff       	call   80101c0f <iunlockput>
80105a63:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105a66:	eb 29                	jmp    80105a91 <sys_link+0x15b>
  }
  iunlockput(dp);
80105a68:	83 ec 0c             	sub    $0xc,%esp
80105a6b:	ff 75 f0             	pushl  -0x10(%ebp)
80105a6e:	e8 9c c1 ff ff       	call   80101c0f <iunlockput>
80105a73:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105a76:	83 ec 0c             	sub    $0xc,%esp
80105a79:	ff 75 f4             	pushl  -0xc(%ebp)
80105a7c:	e8 9e c0 ff ff       	call   80101b1f <iput>
80105a81:	83 c4 10             	add    $0x10,%esp

  end_op();
80105a84:	e8 35 db ff ff       	call   801035be <end_op>

  return 0;
80105a89:	b8 00 00 00 00       	mov    $0x0,%eax
80105a8e:	eb 48                	jmp    80105ad8 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105a90:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105a91:	83 ec 0c             	sub    $0xc,%esp
80105a94:	ff 75 f4             	pushl  -0xc(%ebp)
80105a97:	e8 b3 be ff ff       	call   8010194f <ilock>
80105a9c:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105aa6:	83 e8 01             	sub    $0x1,%eax
80105aa9:	89 c2                	mov    %eax,%edx
80105aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aae:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105ab2:	83 ec 0c             	sub    $0xc,%esp
80105ab5:	ff 75 f4             	pushl  -0xc(%ebp)
80105ab8:	e8 b8 bc ff ff       	call   80101775 <iupdate>
80105abd:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105ac0:	83 ec 0c             	sub    $0xc,%esp
80105ac3:	ff 75 f4             	pushl  -0xc(%ebp)
80105ac6:	e8 44 c1 ff ff       	call   80101c0f <iunlockput>
80105acb:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ace:	e8 eb da ff ff       	call   801035be <end_op>
  return -1;
80105ad3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ad8:	c9                   	leave  
80105ad9:	c3                   	ret    

80105ada <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105ada:	55                   	push   %ebp
80105adb:	89 e5                	mov    %esp,%ebp
80105add:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ae0:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105ae7:	eb 40                	jmp    80105b29 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aec:	6a 10                	push   $0x10
80105aee:	50                   	push   %eax
80105aef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105af2:	50                   	push   %eax
80105af3:	ff 75 08             	pushl  0x8(%ebp)
80105af6:	e8 c2 c3 ff ff       	call   80101ebd <readi>
80105afb:	83 c4 10             	add    $0x10,%esp
80105afe:	83 f8 10             	cmp    $0x10,%eax
80105b01:	74 0d                	je     80105b10 <isdirempty+0x36>
      panic("isdirempty: readi");
80105b03:	83 ec 0c             	sub    $0xc,%esp
80105b06:	68 67 89 10 80       	push   $0x80108967
80105b0b:	e8 56 aa ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80105b10:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105b14:	66 85 c0             	test   %ax,%ax
80105b17:	74 07                	je     80105b20 <isdirempty+0x46>
      return 0;
80105b19:	b8 00 00 00 00       	mov    $0x0,%eax
80105b1e:	eb 1b                	jmp    80105b3b <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b23:	83 c0 10             	add    $0x10,%eax
80105b26:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b29:	8b 45 08             	mov    0x8(%ebp),%eax
80105b2c:	8b 50 18             	mov    0x18(%eax),%edx
80105b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b32:	39 c2                	cmp    %eax,%edx
80105b34:	77 b3                	ja     80105ae9 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105b36:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105b3b:	c9                   	leave  
80105b3c:	c3                   	ret    

80105b3d <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105b3d:	55                   	push   %ebp
80105b3e:	89 e5                	mov    %esp,%ebp
80105b40:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105b43:	83 ec 08             	sub    $0x8,%esp
80105b46:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105b49:	50                   	push   %eax
80105b4a:	6a 00                	push   $0x0
80105b4c:	e8 a0 fa ff ff       	call   801055f1 <argstr>
80105b51:	83 c4 10             	add    $0x10,%esp
80105b54:	85 c0                	test   %eax,%eax
80105b56:	79 0a                	jns    80105b62 <sys_unlink+0x25>
    return -1;
80105b58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b5d:	e9 bc 01 00 00       	jmp    80105d1e <sys_unlink+0x1e1>

  begin_op();
80105b62:	e8 cb d9 ff ff       	call   80103532 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105b67:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105b6a:	83 ec 08             	sub    $0x8,%esp
80105b6d:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105b70:	52                   	push   %edx
80105b71:	50                   	push   %eax
80105b72:	e8 b2 c9 ff ff       	call   80102529 <nameiparent>
80105b77:	83 c4 10             	add    $0x10,%esp
80105b7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b81:	75 0f                	jne    80105b92 <sys_unlink+0x55>
    end_op();
80105b83:	e8 36 da ff ff       	call   801035be <end_op>
    return -1;
80105b88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b8d:	e9 8c 01 00 00       	jmp    80105d1e <sys_unlink+0x1e1>
  }

  ilock(dp);
80105b92:	83 ec 0c             	sub    $0xc,%esp
80105b95:	ff 75 f4             	pushl  -0xc(%ebp)
80105b98:	e8 b2 bd ff ff       	call   8010194f <ilock>
80105b9d:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105ba0:	83 ec 08             	sub    $0x8,%esp
80105ba3:	68 79 89 10 80       	push   $0x80108979
80105ba8:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105bab:	50                   	push   %eax
80105bac:	e8 eb c5 ff ff       	call   8010219c <namecmp>
80105bb1:	83 c4 10             	add    $0x10,%esp
80105bb4:	85 c0                	test   %eax,%eax
80105bb6:	0f 84 4a 01 00 00    	je     80105d06 <sys_unlink+0x1c9>
80105bbc:	83 ec 08             	sub    $0x8,%esp
80105bbf:	68 7b 89 10 80       	push   $0x8010897b
80105bc4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105bc7:	50                   	push   %eax
80105bc8:	e8 cf c5 ff ff       	call   8010219c <namecmp>
80105bcd:	83 c4 10             	add    $0x10,%esp
80105bd0:	85 c0                	test   %eax,%eax
80105bd2:	0f 84 2e 01 00 00    	je     80105d06 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105bd8:	83 ec 04             	sub    $0x4,%esp
80105bdb:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105bde:	50                   	push   %eax
80105bdf:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105be2:	50                   	push   %eax
80105be3:	ff 75 f4             	pushl  -0xc(%ebp)
80105be6:	e8 cc c5 ff ff       	call   801021b7 <dirlookup>
80105beb:	83 c4 10             	add    $0x10,%esp
80105bee:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bf1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bf5:	0f 84 0a 01 00 00    	je     80105d05 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80105bfb:	83 ec 0c             	sub    $0xc,%esp
80105bfe:	ff 75 f0             	pushl  -0x10(%ebp)
80105c01:	e8 49 bd ff ff       	call   8010194f <ilock>
80105c06:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105c09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c0c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c10:	66 85 c0             	test   %ax,%ax
80105c13:	7f 0d                	jg     80105c22 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105c15:	83 ec 0c             	sub    $0xc,%esp
80105c18:	68 7e 89 10 80       	push   $0x8010897e
80105c1d:	e8 44 a9 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c25:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105c29:	66 83 f8 01          	cmp    $0x1,%ax
80105c2d:	75 25                	jne    80105c54 <sys_unlink+0x117>
80105c2f:	83 ec 0c             	sub    $0xc,%esp
80105c32:	ff 75 f0             	pushl  -0x10(%ebp)
80105c35:	e8 a0 fe ff ff       	call   80105ada <isdirempty>
80105c3a:	83 c4 10             	add    $0x10,%esp
80105c3d:	85 c0                	test   %eax,%eax
80105c3f:	75 13                	jne    80105c54 <sys_unlink+0x117>
    iunlockput(ip);
80105c41:	83 ec 0c             	sub    $0xc,%esp
80105c44:	ff 75 f0             	pushl  -0x10(%ebp)
80105c47:	e8 c3 bf ff ff       	call   80101c0f <iunlockput>
80105c4c:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105c4f:	e9 b2 00 00 00       	jmp    80105d06 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80105c54:	83 ec 04             	sub    $0x4,%esp
80105c57:	6a 10                	push   $0x10
80105c59:	6a 00                	push   $0x0
80105c5b:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105c5e:	50                   	push   %eax
80105c5f:	e8 e3 f5 ff ff       	call   80105247 <memset>
80105c64:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105c67:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105c6a:	6a 10                	push   $0x10
80105c6c:	50                   	push   %eax
80105c6d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105c70:	50                   	push   %eax
80105c71:	ff 75 f4             	pushl  -0xc(%ebp)
80105c74:	e8 9b c3 ff ff       	call   80102014 <writei>
80105c79:	83 c4 10             	add    $0x10,%esp
80105c7c:	83 f8 10             	cmp    $0x10,%eax
80105c7f:	74 0d                	je     80105c8e <sys_unlink+0x151>
    panic("unlink: writei");
80105c81:	83 ec 0c             	sub    $0xc,%esp
80105c84:	68 90 89 10 80       	push   $0x80108990
80105c89:	e8 d8 a8 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80105c8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c91:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105c95:	66 83 f8 01          	cmp    $0x1,%ax
80105c99:	75 21                	jne    80105cbc <sys_unlink+0x17f>
    dp->nlink--;
80105c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c9e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ca2:	83 e8 01             	sub    $0x1,%eax
80105ca5:	89 c2                	mov    %eax,%edx
80105ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105caa:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105cae:	83 ec 0c             	sub    $0xc,%esp
80105cb1:	ff 75 f4             	pushl  -0xc(%ebp)
80105cb4:	e8 bc ba ff ff       	call   80101775 <iupdate>
80105cb9:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105cbc:	83 ec 0c             	sub    $0xc,%esp
80105cbf:	ff 75 f4             	pushl  -0xc(%ebp)
80105cc2:	e8 48 bf ff ff       	call   80101c0f <iunlockput>
80105cc7:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105cca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ccd:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105cd1:	83 e8 01             	sub    $0x1,%eax
80105cd4:	89 c2                	mov    %eax,%edx
80105cd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd9:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105cdd:	83 ec 0c             	sub    $0xc,%esp
80105ce0:	ff 75 f0             	pushl  -0x10(%ebp)
80105ce3:	e8 8d ba ff ff       	call   80101775 <iupdate>
80105ce8:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105ceb:	83 ec 0c             	sub    $0xc,%esp
80105cee:	ff 75 f0             	pushl  -0x10(%ebp)
80105cf1:	e8 19 bf ff ff       	call   80101c0f <iunlockput>
80105cf6:	83 c4 10             	add    $0x10,%esp

  end_op();
80105cf9:	e8 c0 d8 ff ff       	call   801035be <end_op>

  return 0;
80105cfe:	b8 00 00 00 00       	mov    $0x0,%eax
80105d03:	eb 19                	jmp    80105d1e <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105d05:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80105d06:	83 ec 0c             	sub    $0xc,%esp
80105d09:	ff 75 f4             	pushl  -0xc(%ebp)
80105d0c:	e8 fe be ff ff       	call   80101c0f <iunlockput>
80105d11:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d14:	e8 a5 d8 ff ff       	call   801035be <end_op>
  return -1;
80105d19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d1e:	c9                   	leave  
80105d1f:	c3                   	ret    

80105d20 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105d20:	55                   	push   %ebp
80105d21:	89 e5                	mov    %esp,%ebp
80105d23:	83 ec 38             	sub    $0x38,%esp
80105d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105d29:	8b 55 10             	mov    0x10(%ebp),%edx
80105d2c:	8b 45 14             	mov    0x14(%ebp),%eax
80105d2f:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105d33:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105d37:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105d3b:	83 ec 08             	sub    $0x8,%esp
80105d3e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d41:	50                   	push   %eax
80105d42:	ff 75 08             	pushl  0x8(%ebp)
80105d45:	e8 df c7 ff ff       	call   80102529 <nameiparent>
80105d4a:	83 c4 10             	add    $0x10,%esp
80105d4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d50:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d54:	75 0a                	jne    80105d60 <create+0x40>
    return 0;
80105d56:	b8 00 00 00 00       	mov    $0x0,%eax
80105d5b:	e9 90 01 00 00       	jmp    80105ef0 <create+0x1d0>
  ilock(dp);
80105d60:	83 ec 0c             	sub    $0xc,%esp
80105d63:	ff 75 f4             	pushl  -0xc(%ebp)
80105d66:	e8 e4 bb ff ff       	call   8010194f <ilock>
80105d6b:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105d6e:	83 ec 04             	sub    $0x4,%esp
80105d71:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d74:	50                   	push   %eax
80105d75:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d78:	50                   	push   %eax
80105d79:	ff 75 f4             	pushl  -0xc(%ebp)
80105d7c:	e8 36 c4 ff ff       	call   801021b7 <dirlookup>
80105d81:	83 c4 10             	add    $0x10,%esp
80105d84:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d87:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d8b:	74 50                	je     80105ddd <create+0xbd>
    iunlockput(dp);
80105d8d:	83 ec 0c             	sub    $0xc,%esp
80105d90:	ff 75 f4             	pushl  -0xc(%ebp)
80105d93:	e8 77 be ff ff       	call   80101c0f <iunlockput>
80105d98:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105d9b:	83 ec 0c             	sub    $0xc,%esp
80105d9e:	ff 75 f0             	pushl  -0x10(%ebp)
80105da1:	e8 a9 bb ff ff       	call   8010194f <ilock>
80105da6:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105da9:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105dae:	75 15                	jne    80105dc5 <create+0xa5>
80105db0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105db3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105db7:	66 83 f8 02          	cmp    $0x2,%ax
80105dbb:	75 08                	jne    80105dc5 <create+0xa5>
      return ip;
80105dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc0:	e9 2b 01 00 00       	jmp    80105ef0 <create+0x1d0>
    iunlockput(ip);
80105dc5:	83 ec 0c             	sub    $0xc,%esp
80105dc8:	ff 75 f0             	pushl  -0x10(%ebp)
80105dcb:	e8 3f be ff ff       	call   80101c0f <iunlockput>
80105dd0:	83 c4 10             	add    $0x10,%esp
    return 0;
80105dd3:	b8 00 00 00 00       	mov    $0x0,%eax
80105dd8:	e9 13 01 00 00       	jmp    80105ef0 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105ddd:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de4:	8b 00                	mov    (%eax),%eax
80105de6:	83 ec 08             	sub    $0x8,%esp
80105de9:	52                   	push   %edx
80105dea:	50                   	push   %eax
80105deb:	e8 ae b8 ff ff       	call   8010169e <ialloc>
80105df0:	83 c4 10             	add    $0x10,%esp
80105df3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105df6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dfa:	75 0d                	jne    80105e09 <create+0xe9>
    panic("create: ialloc");
80105dfc:	83 ec 0c             	sub    $0xc,%esp
80105dff:	68 9f 89 10 80       	push   $0x8010899f
80105e04:	e8 5d a7 ff ff       	call   80100566 <panic>

  ilock(ip);
80105e09:	83 ec 0c             	sub    $0xc,%esp
80105e0c:	ff 75 f0             	pushl  -0x10(%ebp)
80105e0f:	e8 3b bb ff ff       	call   8010194f <ilock>
80105e14:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105e17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e1a:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105e1e:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e25:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105e29:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e30:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105e36:	83 ec 0c             	sub    $0xc,%esp
80105e39:	ff 75 f0             	pushl  -0x10(%ebp)
80105e3c:	e8 34 b9 ff ff       	call   80101775 <iupdate>
80105e41:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105e44:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105e49:	75 6a                	jne    80105eb5 <create+0x195>
    dp->nlink++;  // for ".."
80105e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e52:	83 c0 01             	add    $0x1,%eax
80105e55:	89 c2                	mov    %eax,%edx
80105e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e5a:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105e5e:	83 ec 0c             	sub    $0xc,%esp
80105e61:	ff 75 f4             	pushl  -0xc(%ebp)
80105e64:	e8 0c b9 ff ff       	call   80101775 <iupdate>
80105e69:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105e6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e6f:	8b 40 04             	mov    0x4(%eax),%eax
80105e72:	83 ec 04             	sub    $0x4,%esp
80105e75:	50                   	push   %eax
80105e76:	68 79 89 10 80       	push   $0x80108979
80105e7b:	ff 75 f0             	pushl  -0x10(%ebp)
80105e7e:	e8 ee c3 ff ff       	call   80102271 <dirlink>
80105e83:	83 c4 10             	add    $0x10,%esp
80105e86:	85 c0                	test   %eax,%eax
80105e88:	78 1e                	js     80105ea8 <create+0x188>
80105e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8d:	8b 40 04             	mov    0x4(%eax),%eax
80105e90:	83 ec 04             	sub    $0x4,%esp
80105e93:	50                   	push   %eax
80105e94:	68 7b 89 10 80       	push   $0x8010897b
80105e99:	ff 75 f0             	pushl  -0x10(%ebp)
80105e9c:	e8 d0 c3 ff ff       	call   80102271 <dirlink>
80105ea1:	83 c4 10             	add    $0x10,%esp
80105ea4:	85 c0                	test   %eax,%eax
80105ea6:	79 0d                	jns    80105eb5 <create+0x195>
      panic("create dots");
80105ea8:	83 ec 0c             	sub    $0xc,%esp
80105eab:	68 ae 89 10 80       	push   $0x801089ae
80105eb0:	e8 b1 a6 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb8:	8b 40 04             	mov    0x4(%eax),%eax
80105ebb:	83 ec 04             	sub    $0x4,%esp
80105ebe:	50                   	push   %eax
80105ebf:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ec2:	50                   	push   %eax
80105ec3:	ff 75 f4             	pushl  -0xc(%ebp)
80105ec6:	e8 a6 c3 ff ff       	call   80102271 <dirlink>
80105ecb:	83 c4 10             	add    $0x10,%esp
80105ece:	85 c0                	test   %eax,%eax
80105ed0:	79 0d                	jns    80105edf <create+0x1bf>
    panic("create: dirlink");
80105ed2:	83 ec 0c             	sub    $0xc,%esp
80105ed5:	68 ba 89 10 80       	push   $0x801089ba
80105eda:	e8 87 a6 ff ff       	call   80100566 <panic>

  iunlockput(dp);
80105edf:	83 ec 0c             	sub    $0xc,%esp
80105ee2:	ff 75 f4             	pushl  -0xc(%ebp)
80105ee5:	e8 25 bd ff ff       	call   80101c0f <iunlockput>
80105eea:	83 c4 10             	add    $0x10,%esp

  return ip;
80105eed:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105ef0:	c9                   	leave  
80105ef1:	c3                   	ret    

80105ef2 <sys_open>:

int
sys_open(void)
{
80105ef2:	55                   	push   %ebp
80105ef3:	89 e5                	mov    %esp,%ebp
80105ef5:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105ef8:	83 ec 08             	sub    $0x8,%esp
80105efb:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105efe:	50                   	push   %eax
80105eff:	6a 00                	push   $0x0
80105f01:	e8 eb f6 ff ff       	call   801055f1 <argstr>
80105f06:	83 c4 10             	add    $0x10,%esp
80105f09:	85 c0                	test   %eax,%eax
80105f0b:	78 15                	js     80105f22 <sys_open+0x30>
80105f0d:	83 ec 08             	sub    $0x8,%esp
80105f10:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f13:	50                   	push   %eax
80105f14:	6a 01                	push   $0x1
80105f16:	e8 51 f6 ff ff       	call   8010556c <argint>
80105f1b:	83 c4 10             	add    $0x10,%esp
80105f1e:	85 c0                	test   %eax,%eax
80105f20:	79 0a                	jns    80105f2c <sys_open+0x3a>
    return -1;
80105f22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f27:	e9 61 01 00 00       	jmp    8010608d <sys_open+0x19b>

  begin_op();
80105f2c:	e8 01 d6 ff ff       	call   80103532 <begin_op>

  if(omode & O_CREATE){
80105f31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f34:	25 00 02 00 00       	and    $0x200,%eax
80105f39:	85 c0                	test   %eax,%eax
80105f3b:	74 2a                	je     80105f67 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105f3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f40:	6a 00                	push   $0x0
80105f42:	6a 00                	push   $0x0
80105f44:	6a 02                	push   $0x2
80105f46:	50                   	push   %eax
80105f47:	e8 d4 fd ff ff       	call   80105d20 <create>
80105f4c:	83 c4 10             	add    $0x10,%esp
80105f4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105f52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f56:	75 75                	jne    80105fcd <sys_open+0xdb>
      end_op();
80105f58:	e8 61 d6 ff ff       	call   801035be <end_op>
      return -1;
80105f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f62:	e9 26 01 00 00       	jmp    8010608d <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105f67:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f6a:	83 ec 0c             	sub    $0xc,%esp
80105f6d:	50                   	push   %eax
80105f6e:	e8 9a c5 ff ff       	call   8010250d <namei>
80105f73:	83 c4 10             	add    $0x10,%esp
80105f76:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f79:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f7d:	75 0f                	jne    80105f8e <sys_open+0x9c>
      end_op();
80105f7f:	e8 3a d6 ff ff       	call   801035be <end_op>
      return -1;
80105f84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f89:	e9 ff 00 00 00       	jmp    8010608d <sys_open+0x19b>
    }
    ilock(ip);
80105f8e:	83 ec 0c             	sub    $0xc,%esp
80105f91:	ff 75 f4             	pushl  -0xc(%ebp)
80105f94:	e8 b6 b9 ff ff       	call   8010194f <ilock>
80105f99:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f9f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105fa3:	66 83 f8 01          	cmp    $0x1,%ax
80105fa7:	75 24                	jne    80105fcd <sys_open+0xdb>
80105fa9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fac:	85 c0                	test   %eax,%eax
80105fae:	74 1d                	je     80105fcd <sys_open+0xdb>
      iunlockput(ip);
80105fb0:	83 ec 0c             	sub    $0xc,%esp
80105fb3:	ff 75 f4             	pushl  -0xc(%ebp)
80105fb6:	e8 54 bc ff ff       	call   80101c0f <iunlockput>
80105fbb:	83 c4 10             	add    $0x10,%esp
      end_op();
80105fbe:	e8 fb d5 ff ff       	call   801035be <end_op>
      return -1;
80105fc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fc8:	e9 c0 00 00 00       	jmp    8010608d <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105fcd:	e8 a6 af ff ff       	call   80100f78 <filealloc>
80105fd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fd5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fd9:	74 17                	je     80105ff2 <sys_open+0x100>
80105fdb:	83 ec 0c             	sub    $0xc,%esp
80105fde:	ff 75 f0             	pushl  -0x10(%ebp)
80105fe1:	e8 37 f7 ff ff       	call   8010571d <fdalloc>
80105fe6:	83 c4 10             	add    $0x10,%esp
80105fe9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105fec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105ff0:	79 2e                	jns    80106020 <sys_open+0x12e>
    if(f)
80105ff2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ff6:	74 0e                	je     80106006 <sys_open+0x114>
      fileclose(f);
80105ff8:	83 ec 0c             	sub    $0xc,%esp
80105ffb:	ff 75 f0             	pushl  -0x10(%ebp)
80105ffe:	e8 33 b0 ff ff       	call   80101036 <fileclose>
80106003:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106006:	83 ec 0c             	sub    $0xc,%esp
80106009:	ff 75 f4             	pushl  -0xc(%ebp)
8010600c:	e8 fe bb ff ff       	call   80101c0f <iunlockput>
80106011:	83 c4 10             	add    $0x10,%esp
    end_op();
80106014:	e8 a5 d5 ff ff       	call   801035be <end_op>
    return -1;
80106019:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010601e:	eb 6d                	jmp    8010608d <sys_open+0x19b>
  }
  iunlock(ip);
80106020:	83 ec 0c             	sub    $0xc,%esp
80106023:	ff 75 f4             	pushl  -0xc(%ebp)
80106026:	e8 82 ba ff ff       	call   80101aad <iunlock>
8010602b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010602e:	e8 8b d5 ff ff       	call   801035be <end_op>

  f->type = FD_INODE;
80106033:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106036:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010603c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106042:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106045:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106048:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010604f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106052:	83 e0 01             	and    $0x1,%eax
80106055:	85 c0                	test   %eax,%eax
80106057:	0f 94 c0             	sete   %al
8010605a:	89 c2                	mov    %eax,%edx
8010605c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010605f:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106062:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106065:	83 e0 01             	and    $0x1,%eax
80106068:	85 c0                	test   %eax,%eax
8010606a:	75 0a                	jne    80106076 <sys_open+0x184>
8010606c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010606f:	83 e0 02             	and    $0x2,%eax
80106072:	85 c0                	test   %eax,%eax
80106074:	74 07                	je     8010607d <sys_open+0x18b>
80106076:	b8 01 00 00 00       	mov    $0x1,%eax
8010607b:	eb 05                	jmp    80106082 <sys_open+0x190>
8010607d:	b8 00 00 00 00       	mov    $0x0,%eax
80106082:	89 c2                	mov    %eax,%edx
80106084:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106087:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010608a:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010608d:	c9                   	leave  
8010608e:	c3                   	ret    

8010608f <sys_mkdir>:

int
sys_mkdir(void)
{
8010608f:	55                   	push   %ebp
80106090:	89 e5                	mov    %esp,%ebp
80106092:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106095:	e8 98 d4 ff ff       	call   80103532 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010609a:	83 ec 08             	sub    $0x8,%esp
8010609d:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060a0:	50                   	push   %eax
801060a1:	6a 00                	push   $0x0
801060a3:	e8 49 f5 ff ff       	call   801055f1 <argstr>
801060a8:	83 c4 10             	add    $0x10,%esp
801060ab:	85 c0                	test   %eax,%eax
801060ad:	78 1b                	js     801060ca <sys_mkdir+0x3b>
801060af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b2:	6a 00                	push   $0x0
801060b4:	6a 00                	push   $0x0
801060b6:	6a 01                	push   $0x1
801060b8:	50                   	push   %eax
801060b9:	e8 62 fc ff ff       	call   80105d20 <create>
801060be:	83 c4 10             	add    $0x10,%esp
801060c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060c8:	75 0c                	jne    801060d6 <sys_mkdir+0x47>
    end_op();
801060ca:	e8 ef d4 ff ff       	call   801035be <end_op>
    return -1;
801060cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d4:	eb 18                	jmp    801060ee <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801060d6:	83 ec 0c             	sub    $0xc,%esp
801060d9:	ff 75 f4             	pushl  -0xc(%ebp)
801060dc:	e8 2e bb ff ff       	call   80101c0f <iunlockput>
801060e1:	83 c4 10             	add    $0x10,%esp
  end_op();
801060e4:	e8 d5 d4 ff ff       	call   801035be <end_op>
  return 0;
801060e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060ee:	c9                   	leave  
801060ef:	c3                   	ret    

801060f0 <sys_mknod>:

int
sys_mknod(void)
{
801060f0:	55                   	push   %ebp
801060f1:	89 e5                	mov    %esp,%ebp
801060f3:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
801060f6:	e8 37 d4 ff ff       	call   80103532 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
801060fb:	83 ec 08             	sub    $0x8,%esp
801060fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106101:	50                   	push   %eax
80106102:	6a 00                	push   $0x0
80106104:	e8 e8 f4 ff ff       	call   801055f1 <argstr>
80106109:	83 c4 10             	add    $0x10,%esp
8010610c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010610f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106113:	78 4f                	js     80106164 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106115:	83 ec 08             	sub    $0x8,%esp
80106118:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010611b:	50                   	push   %eax
8010611c:	6a 01                	push   $0x1
8010611e:	e8 49 f4 ff ff       	call   8010556c <argint>
80106123:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106126:	85 c0                	test   %eax,%eax
80106128:	78 3a                	js     80106164 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010612a:	83 ec 08             	sub    $0x8,%esp
8010612d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106130:	50                   	push   %eax
80106131:	6a 02                	push   $0x2
80106133:	e8 34 f4 ff ff       	call   8010556c <argint>
80106138:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010613b:	85 c0                	test   %eax,%eax
8010613d:	78 25                	js     80106164 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010613f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106142:	0f bf c8             	movswl %ax,%ecx
80106145:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106148:	0f bf d0             	movswl %ax,%edx
8010614b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010614e:	51                   	push   %ecx
8010614f:	52                   	push   %edx
80106150:	6a 03                	push   $0x3
80106152:	50                   	push   %eax
80106153:	e8 c8 fb ff ff       	call   80105d20 <create>
80106158:	83 c4 10             	add    $0x10,%esp
8010615b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010615e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106162:	75 0c                	jne    80106170 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106164:	e8 55 d4 ff ff       	call   801035be <end_op>
    return -1;
80106169:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010616e:	eb 18                	jmp    80106188 <sys_mknod+0x98>
  }
  iunlockput(ip);
80106170:	83 ec 0c             	sub    $0xc,%esp
80106173:	ff 75 f0             	pushl  -0x10(%ebp)
80106176:	e8 94 ba ff ff       	call   80101c0f <iunlockput>
8010617b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010617e:	e8 3b d4 ff ff       	call   801035be <end_op>
  return 0;
80106183:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106188:	c9                   	leave  
80106189:	c3                   	ret    

8010618a <sys_chdir>:

int
sys_chdir(void)
{
8010618a:	55                   	push   %ebp
8010618b:	89 e5                	mov    %esp,%ebp
8010618d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106190:	e8 9d d3 ff ff       	call   80103532 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106195:	83 ec 08             	sub    $0x8,%esp
80106198:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010619b:	50                   	push   %eax
8010619c:	6a 00                	push   $0x0
8010619e:	e8 4e f4 ff ff       	call   801055f1 <argstr>
801061a3:	83 c4 10             	add    $0x10,%esp
801061a6:	85 c0                	test   %eax,%eax
801061a8:	78 18                	js     801061c2 <sys_chdir+0x38>
801061aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ad:	83 ec 0c             	sub    $0xc,%esp
801061b0:	50                   	push   %eax
801061b1:	e8 57 c3 ff ff       	call   8010250d <namei>
801061b6:	83 c4 10             	add    $0x10,%esp
801061b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061c0:	75 0c                	jne    801061ce <sys_chdir+0x44>
    end_op();
801061c2:	e8 f7 d3 ff ff       	call   801035be <end_op>
    return -1;
801061c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061cc:	eb 6e                	jmp    8010623c <sys_chdir+0xb2>
  }
  ilock(ip);
801061ce:	83 ec 0c             	sub    $0xc,%esp
801061d1:	ff 75 f4             	pushl  -0xc(%ebp)
801061d4:	e8 76 b7 ff ff       	call   8010194f <ilock>
801061d9:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801061dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061df:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801061e3:	66 83 f8 01          	cmp    $0x1,%ax
801061e7:	74 1a                	je     80106203 <sys_chdir+0x79>
    iunlockput(ip);
801061e9:	83 ec 0c             	sub    $0xc,%esp
801061ec:	ff 75 f4             	pushl  -0xc(%ebp)
801061ef:	e8 1b ba ff ff       	call   80101c0f <iunlockput>
801061f4:	83 c4 10             	add    $0x10,%esp
    end_op();
801061f7:	e8 c2 d3 ff ff       	call   801035be <end_op>
    return -1;
801061fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106201:	eb 39                	jmp    8010623c <sys_chdir+0xb2>
  }
  iunlock(ip);
80106203:	83 ec 0c             	sub    $0xc,%esp
80106206:	ff 75 f4             	pushl  -0xc(%ebp)
80106209:	e8 9f b8 ff ff       	call   80101aad <iunlock>
8010620e:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106211:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106217:	8b 40 68             	mov    0x68(%eax),%eax
8010621a:	83 ec 0c             	sub    $0xc,%esp
8010621d:	50                   	push   %eax
8010621e:	e8 fc b8 ff ff       	call   80101b1f <iput>
80106223:	83 c4 10             	add    $0x10,%esp
  end_op();
80106226:	e8 93 d3 ff ff       	call   801035be <end_op>
  proc->cwd = ip;
8010622b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106231:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106234:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106237:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010623c:	c9                   	leave  
8010623d:	c3                   	ret    

8010623e <sys_exec>:

int
sys_exec(void)
{
8010623e:	55                   	push   %ebp
8010623f:	89 e5                	mov    %esp,%ebp
80106241:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106247:	83 ec 08             	sub    $0x8,%esp
8010624a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010624d:	50                   	push   %eax
8010624e:	6a 00                	push   $0x0
80106250:	e8 9c f3 ff ff       	call   801055f1 <argstr>
80106255:	83 c4 10             	add    $0x10,%esp
80106258:	85 c0                	test   %eax,%eax
8010625a:	78 18                	js     80106274 <sys_exec+0x36>
8010625c:	83 ec 08             	sub    $0x8,%esp
8010625f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106265:	50                   	push   %eax
80106266:	6a 01                	push   $0x1
80106268:	e8 ff f2 ff ff       	call   8010556c <argint>
8010626d:	83 c4 10             	add    $0x10,%esp
80106270:	85 c0                	test   %eax,%eax
80106272:	79 0a                	jns    8010627e <sys_exec+0x40>
    return -1;
80106274:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106279:	e9 c6 00 00 00       	jmp    80106344 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
8010627e:	83 ec 04             	sub    $0x4,%esp
80106281:	68 80 00 00 00       	push   $0x80
80106286:	6a 00                	push   $0x0
80106288:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010628e:	50                   	push   %eax
8010628f:	e8 b3 ef ff ff       	call   80105247 <memset>
80106294:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106297:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010629e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a1:	83 f8 1f             	cmp    $0x1f,%eax
801062a4:	76 0a                	jbe    801062b0 <sys_exec+0x72>
      return -1;
801062a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ab:	e9 94 00 00 00       	jmp    80106344 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801062b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b3:	c1 e0 02             	shl    $0x2,%eax
801062b6:	89 c2                	mov    %eax,%edx
801062b8:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801062be:	01 c2                	add    %eax,%edx
801062c0:	83 ec 08             	sub    $0x8,%esp
801062c3:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801062c9:	50                   	push   %eax
801062ca:	52                   	push   %edx
801062cb:	e8 00 f2 ff ff       	call   801054d0 <fetchint>
801062d0:	83 c4 10             	add    $0x10,%esp
801062d3:	85 c0                	test   %eax,%eax
801062d5:	79 07                	jns    801062de <sys_exec+0xa0>
      return -1;
801062d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062dc:	eb 66                	jmp    80106344 <sys_exec+0x106>
    if(uarg == 0){
801062de:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801062e4:	85 c0                	test   %eax,%eax
801062e6:	75 27                	jne    8010630f <sys_exec+0xd1>
      argv[i] = 0;
801062e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062eb:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801062f2:	00 00 00 00 
      break;
801062f6:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801062f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062fa:	83 ec 08             	sub    $0x8,%esp
801062fd:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106303:	52                   	push   %edx
80106304:	50                   	push   %eax
80106305:	e8 4c a8 ff ff       	call   80100b56 <exec>
8010630a:	83 c4 10             	add    $0x10,%esp
8010630d:	eb 35                	jmp    80106344 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010630f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106315:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106318:	c1 e2 02             	shl    $0x2,%edx
8010631b:	01 c2                	add    %eax,%edx
8010631d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106323:	83 ec 08             	sub    $0x8,%esp
80106326:	52                   	push   %edx
80106327:	50                   	push   %eax
80106328:	e8 dd f1 ff ff       	call   8010550a <fetchstr>
8010632d:	83 c4 10             	add    $0x10,%esp
80106330:	85 c0                	test   %eax,%eax
80106332:	79 07                	jns    8010633b <sys_exec+0xfd>
      return -1;
80106334:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106339:	eb 09                	jmp    80106344 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010633b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010633f:	e9 5a ff ff ff       	jmp    8010629e <sys_exec+0x60>
  return exec(path, argv);
}
80106344:	c9                   	leave  
80106345:	c3                   	ret    

80106346 <sys_pipe>:

int
sys_pipe(void)
{
80106346:	55                   	push   %ebp
80106347:	89 e5                	mov    %esp,%ebp
80106349:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010634c:	83 ec 04             	sub    $0x4,%esp
8010634f:	6a 08                	push   $0x8
80106351:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106354:	50                   	push   %eax
80106355:	6a 00                	push   $0x0
80106357:	e8 38 f2 ff ff       	call   80105594 <argptr>
8010635c:	83 c4 10             	add    $0x10,%esp
8010635f:	85 c0                	test   %eax,%eax
80106361:	79 0a                	jns    8010636d <sys_pipe+0x27>
    return -1;
80106363:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106368:	e9 af 00 00 00       	jmp    8010641c <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
8010636d:	83 ec 08             	sub    $0x8,%esp
80106370:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106373:	50                   	push   %eax
80106374:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106377:	50                   	push   %eax
80106378:	e8 a9 dc ff ff       	call   80104026 <pipealloc>
8010637d:	83 c4 10             	add    $0x10,%esp
80106380:	85 c0                	test   %eax,%eax
80106382:	79 0a                	jns    8010638e <sys_pipe+0x48>
    return -1;
80106384:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106389:	e9 8e 00 00 00       	jmp    8010641c <sys_pipe+0xd6>
  fd0 = -1;
8010638e:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106395:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106398:	83 ec 0c             	sub    $0xc,%esp
8010639b:	50                   	push   %eax
8010639c:	e8 7c f3 ff ff       	call   8010571d <fdalloc>
801063a1:	83 c4 10             	add    $0x10,%esp
801063a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063ab:	78 18                	js     801063c5 <sys_pipe+0x7f>
801063ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063b0:	83 ec 0c             	sub    $0xc,%esp
801063b3:	50                   	push   %eax
801063b4:	e8 64 f3 ff ff       	call   8010571d <fdalloc>
801063b9:	83 c4 10             	add    $0x10,%esp
801063bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063c3:	79 3f                	jns    80106404 <sys_pipe+0xbe>
    if(fd0 >= 0)
801063c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063c9:	78 14                	js     801063df <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
801063cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063d4:	83 c2 08             	add    $0x8,%edx
801063d7:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801063de:	00 
    fileclose(rf);
801063df:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063e2:	83 ec 0c             	sub    $0xc,%esp
801063e5:	50                   	push   %eax
801063e6:	e8 4b ac ff ff       	call   80101036 <fileclose>
801063eb:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801063ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063f1:	83 ec 0c             	sub    $0xc,%esp
801063f4:	50                   	push   %eax
801063f5:	e8 3c ac ff ff       	call   80101036 <fileclose>
801063fa:	83 c4 10             	add    $0x10,%esp
    return -1;
801063fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106402:	eb 18                	jmp    8010641c <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106404:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106407:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010640a:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010640c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010640f:	8d 50 04             	lea    0x4(%eax),%edx
80106412:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106415:	89 02                	mov    %eax,(%edx)
  return 0;
80106417:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010641c:	c9                   	leave  
8010641d:	c3                   	ret    

8010641e <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010641e:	55                   	push   %ebp
8010641f:	89 e5                	mov    %esp,%ebp
80106421:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106424:	e8 f3 e2 ff ff       	call   8010471c <fork>
}
80106429:	c9                   	leave  
8010642a:	c3                   	ret    

8010642b <sys_exit>:

int
sys_exit(void)
{
8010642b:	55                   	push   %ebp
8010642c:	89 e5                	mov    %esp,%ebp
8010642e:	83 ec 08             	sub    $0x8,%esp
  exit();
80106431:	e8 77 e4 ff ff       	call   801048ad <exit>
  return 0;  // not reached
80106436:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010643b:	c9                   	leave  
8010643c:	c3                   	ret    

8010643d <sys_wait>:

int
sys_wait(void)
{
8010643d:	55                   	push   %ebp
8010643e:	89 e5                	mov    %esp,%ebp
80106440:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106443:	e8 9d e5 ff ff       	call   801049e5 <wait>
}
80106448:	c9                   	leave  
80106449:	c3                   	ret    

8010644a <sys_kill>:

int
sys_kill(void)
{
8010644a:	55                   	push   %ebp
8010644b:	89 e5                	mov    %esp,%ebp
8010644d:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106450:	83 ec 08             	sub    $0x8,%esp
80106453:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106456:	50                   	push   %eax
80106457:	6a 00                	push   $0x0
80106459:	e8 0e f1 ff ff       	call   8010556c <argint>
8010645e:	83 c4 10             	add    $0x10,%esp
80106461:	85 c0                	test   %eax,%eax
80106463:	79 07                	jns    8010646c <sys_kill+0x22>
    return -1;
80106465:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010646a:	eb 0f                	jmp    8010647b <sys_kill+0x31>
  return kill(pid);
8010646c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010646f:	83 ec 0c             	sub    $0xc,%esp
80106472:	50                   	push   %eax
80106473:	e8 95 e9 ff ff       	call   80104e0d <kill>
80106478:	83 c4 10             	add    $0x10,%esp
}
8010647b:	c9                   	leave  
8010647c:	c3                   	ret    

8010647d <sys_getpid>:

int
sys_getpid(void)
{
8010647d:	55                   	push   %ebp
8010647e:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106480:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106486:	8b 40 10             	mov    0x10(%eax),%eax
}
80106489:	5d                   	pop    %ebp
8010648a:	c3                   	ret    

8010648b <sys_sbrk>:

int
sys_sbrk(void)
{
8010648b:	55                   	push   %ebp
8010648c:	89 e5                	mov    %esp,%ebp
8010648e:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106491:	83 ec 08             	sub    $0x8,%esp
80106494:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106497:	50                   	push   %eax
80106498:	6a 00                	push   $0x0
8010649a:	e8 cd f0 ff ff       	call   8010556c <argint>
8010649f:	83 c4 10             	add    $0x10,%esp
801064a2:	85 c0                	test   %eax,%eax
801064a4:	79 07                	jns    801064ad <sys_sbrk+0x22>
    return -1;
801064a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ab:	eb 28                	jmp    801064d5 <sys_sbrk+0x4a>
  addr = proc->sz;
801064ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064b3:	8b 00                	mov    (%eax),%eax
801064b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801064b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064bb:	83 ec 0c             	sub    $0xc,%esp
801064be:	50                   	push   %eax
801064bf:	e8 b5 e1 ff ff       	call   80104679 <growproc>
801064c4:	83 c4 10             	add    $0x10,%esp
801064c7:	85 c0                	test   %eax,%eax
801064c9:	79 07                	jns    801064d2 <sys_sbrk+0x47>
    return -1;
801064cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064d0:	eb 03                	jmp    801064d5 <sys_sbrk+0x4a>
  return addr;
801064d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801064d5:	c9                   	leave  
801064d6:	c3                   	ret    

801064d7 <sys_sleep>:

int
sys_sleep(void)
{
801064d7:	55                   	push   %ebp
801064d8:	89 e5                	mov    %esp,%ebp
801064da:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801064dd:	83 ec 08             	sub    $0x8,%esp
801064e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064e3:	50                   	push   %eax
801064e4:	6a 00                	push   $0x0
801064e6:	e8 81 f0 ff ff       	call   8010556c <argint>
801064eb:	83 c4 10             	add    $0x10,%esp
801064ee:	85 c0                	test   %eax,%eax
801064f0:	79 07                	jns    801064f9 <sys_sleep+0x22>
    return -1;
801064f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064f7:	eb 77                	jmp    80106570 <sys_sleep+0x99>
  acquire(&tickslock);
801064f9:	83 ec 0c             	sub    $0xc,%esp
801064fc:	68 c0 48 11 80       	push   $0x801148c0
80106501:	e8 de ea ff ff       	call   80104fe4 <acquire>
80106506:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106509:	a1 00 51 11 80       	mov    0x80115100,%eax
8010650e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106511:	eb 39                	jmp    8010654c <sys_sleep+0x75>
    if(proc->killed){
80106513:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106519:	8b 40 24             	mov    0x24(%eax),%eax
8010651c:	85 c0                	test   %eax,%eax
8010651e:	74 17                	je     80106537 <sys_sleep+0x60>
      release(&tickslock);
80106520:	83 ec 0c             	sub    $0xc,%esp
80106523:	68 c0 48 11 80       	push   $0x801148c0
80106528:	e8 1e eb ff ff       	call   8010504b <release>
8010652d:	83 c4 10             	add    $0x10,%esp
      return -1;
80106530:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106535:	eb 39                	jmp    80106570 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80106537:	83 ec 08             	sub    $0x8,%esp
8010653a:	68 c0 48 11 80       	push   $0x801148c0
8010653f:	68 00 51 11 80       	push   $0x80115100
80106544:	e8 a2 e7 ff ff       	call   80104ceb <sleep>
80106549:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010654c:	a1 00 51 11 80       	mov    0x80115100,%eax
80106551:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106554:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106557:	39 d0                	cmp    %edx,%eax
80106559:	72 b8                	jb     80106513 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
8010655b:	83 ec 0c             	sub    $0xc,%esp
8010655e:	68 c0 48 11 80       	push   $0x801148c0
80106563:	e8 e3 ea ff ff       	call   8010504b <release>
80106568:	83 c4 10             	add    $0x10,%esp
  return 0;
8010656b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106570:	c9                   	leave  
80106571:	c3                   	ret    

80106572 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106572:	55                   	push   %ebp
80106573:	89 e5                	mov    %esp,%ebp
80106575:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80106578:	83 ec 0c             	sub    $0xc,%esp
8010657b:	68 c0 48 11 80       	push   $0x801148c0
80106580:	e8 5f ea ff ff       	call   80104fe4 <acquire>
80106585:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106588:	a1 00 51 11 80       	mov    0x80115100,%eax
8010658d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106590:	83 ec 0c             	sub    $0xc,%esp
80106593:	68 c0 48 11 80       	push   $0x801148c0
80106598:	e8 ae ea ff ff       	call   8010504b <release>
8010659d:	83 c4 10             	add    $0x10,%esp
  return xticks;
801065a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065a3:	c9                   	leave  
801065a4:	c3                   	ret    

801065a5 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801065a5:	55                   	push   %ebp
801065a6:	89 e5                	mov    %esp,%ebp
801065a8:	83 ec 08             	sub    $0x8,%esp
801065ab:	8b 55 08             	mov    0x8(%ebp),%edx
801065ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801065b1:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801065b5:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801065b8:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801065bc:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801065c0:	ee                   	out    %al,(%dx)
}
801065c1:	90                   	nop
801065c2:	c9                   	leave  
801065c3:	c3                   	ret    

801065c4 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801065c4:	55                   	push   %ebp
801065c5:	89 e5                	mov    %esp,%ebp
801065c7:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801065ca:	6a 34                	push   $0x34
801065cc:	6a 43                	push   $0x43
801065ce:	e8 d2 ff ff ff       	call   801065a5 <outb>
801065d3:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801065d6:	68 9c 00 00 00       	push   $0x9c
801065db:	6a 40                	push   $0x40
801065dd:	e8 c3 ff ff ff       	call   801065a5 <outb>
801065e2:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801065e5:	6a 2e                	push   $0x2e
801065e7:	6a 40                	push   $0x40
801065e9:	e8 b7 ff ff ff       	call   801065a5 <outb>
801065ee:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
801065f1:	83 ec 0c             	sub    $0xc,%esp
801065f4:	6a 00                	push   $0x0
801065f6:	e8 15 d9 ff ff       	call   80103f10 <picenable>
801065fb:	83 c4 10             	add    $0x10,%esp
}
801065fe:	90                   	nop
801065ff:	c9                   	leave  
80106600:	c3                   	ret    

80106601 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106601:	1e                   	push   %ds
  pushl %es
80106602:	06                   	push   %es
  pushl %fs
80106603:	0f a0                	push   %fs
  pushl %gs
80106605:	0f a8                	push   %gs
  pushal
80106607:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106608:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010660c:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010660e:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106610:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106614:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106616:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106618:	54                   	push   %esp
  call trap
80106619:	e8 d7 01 00 00       	call   801067f5 <trap>
  addl $4, %esp
8010661e:	83 c4 04             	add    $0x4,%esp

80106621 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106621:	61                   	popa   
  popl %gs
80106622:	0f a9                	pop    %gs
  popl %fs
80106624:	0f a1                	pop    %fs
  popl %es
80106626:	07                   	pop    %es
  popl %ds
80106627:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106628:	83 c4 08             	add    $0x8,%esp
  iret
8010662b:	cf                   	iret   

8010662c <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010662c:	55                   	push   %ebp
8010662d:	89 e5                	mov    %esp,%ebp
8010662f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106632:	8b 45 0c             	mov    0xc(%ebp),%eax
80106635:	83 e8 01             	sub    $0x1,%eax
80106638:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010663c:	8b 45 08             	mov    0x8(%ebp),%eax
8010663f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106643:	8b 45 08             	mov    0x8(%ebp),%eax
80106646:	c1 e8 10             	shr    $0x10,%eax
80106649:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010664d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106650:	0f 01 18             	lidtl  (%eax)
}
80106653:	90                   	nop
80106654:	c9                   	leave  
80106655:	c3                   	ret    

80106656 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106656:	55                   	push   %ebp
80106657:	89 e5                	mov    %esp,%ebp
80106659:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010665c:	0f 20 d0             	mov    %cr2,%eax
8010665f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106662:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106665:	c9                   	leave  
80106666:	c3                   	ret    

80106667 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106667:	55                   	push   %ebp
80106668:	89 e5                	mov    %esp,%ebp
8010666a:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
8010666d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106674:	e9 c3 00 00 00       	jmp    8010673c <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010667c:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
80106683:	89 c2                	mov    %eax,%edx
80106685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106688:	66 89 14 c5 00 49 11 	mov    %dx,-0x7feeb700(,%eax,8)
8010668f:	80 
80106690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106693:	66 c7 04 c5 02 49 11 	movw   $0x8,-0x7feeb6fe(,%eax,8)
8010669a:	80 08 00 
8010669d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a0:	0f b6 14 c5 04 49 11 	movzbl -0x7feeb6fc(,%eax,8),%edx
801066a7:	80 
801066a8:	83 e2 e0             	and    $0xffffffe0,%edx
801066ab:	88 14 c5 04 49 11 80 	mov    %dl,-0x7feeb6fc(,%eax,8)
801066b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b5:	0f b6 14 c5 04 49 11 	movzbl -0x7feeb6fc(,%eax,8),%edx
801066bc:	80 
801066bd:	83 e2 1f             	and    $0x1f,%edx
801066c0:	88 14 c5 04 49 11 80 	mov    %dl,-0x7feeb6fc(,%eax,8)
801066c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ca:	0f b6 14 c5 05 49 11 	movzbl -0x7feeb6fb(,%eax,8),%edx
801066d1:	80 
801066d2:	83 e2 f0             	and    $0xfffffff0,%edx
801066d5:	83 ca 0e             	or     $0xe,%edx
801066d8:	88 14 c5 05 49 11 80 	mov    %dl,-0x7feeb6fb(,%eax,8)
801066df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e2:	0f b6 14 c5 05 49 11 	movzbl -0x7feeb6fb(,%eax,8),%edx
801066e9:	80 
801066ea:	83 e2 ef             	and    $0xffffffef,%edx
801066ed:	88 14 c5 05 49 11 80 	mov    %dl,-0x7feeb6fb(,%eax,8)
801066f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066f7:	0f b6 14 c5 05 49 11 	movzbl -0x7feeb6fb(,%eax,8),%edx
801066fe:	80 
801066ff:	83 e2 9f             	and    $0xffffff9f,%edx
80106702:	88 14 c5 05 49 11 80 	mov    %dl,-0x7feeb6fb(,%eax,8)
80106709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010670c:	0f b6 14 c5 05 49 11 	movzbl -0x7feeb6fb(,%eax,8),%edx
80106713:	80 
80106714:	83 ca 80             	or     $0xffffff80,%edx
80106717:	88 14 c5 05 49 11 80 	mov    %dl,-0x7feeb6fb(,%eax,8)
8010671e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106721:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
80106728:	c1 e8 10             	shr    $0x10,%eax
8010672b:	89 c2                	mov    %eax,%edx
8010672d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106730:	66 89 14 c5 06 49 11 	mov    %dx,-0x7feeb6fa(,%eax,8)
80106737:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106738:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010673c:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106743:	0f 8e 30 ff ff ff    	jle    80106679 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106749:	a1 98 b1 10 80       	mov    0x8010b198,%eax
8010674e:	66 a3 00 4b 11 80    	mov    %ax,0x80114b00
80106754:	66 c7 05 02 4b 11 80 	movw   $0x8,0x80114b02
8010675b:	08 00 
8010675d:	0f b6 05 04 4b 11 80 	movzbl 0x80114b04,%eax
80106764:	83 e0 e0             	and    $0xffffffe0,%eax
80106767:	a2 04 4b 11 80       	mov    %al,0x80114b04
8010676c:	0f b6 05 04 4b 11 80 	movzbl 0x80114b04,%eax
80106773:	83 e0 1f             	and    $0x1f,%eax
80106776:	a2 04 4b 11 80       	mov    %al,0x80114b04
8010677b:	0f b6 05 05 4b 11 80 	movzbl 0x80114b05,%eax
80106782:	83 c8 0f             	or     $0xf,%eax
80106785:	a2 05 4b 11 80       	mov    %al,0x80114b05
8010678a:	0f b6 05 05 4b 11 80 	movzbl 0x80114b05,%eax
80106791:	83 e0 ef             	and    $0xffffffef,%eax
80106794:	a2 05 4b 11 80       	mov    %al,0x80114b05
80106799:	0f b6 05 05 4b 11 80 	movzbl 0x80114b05,%eax
801067a0:	83 c8 60             	or     $0x60,%eax
801067a3:	a2 05 4b 11 80       	mov    %al,0x80114b05
801067a8:	0f b6 05 05 4b 11 80 	movzbl 0x80114b05,%eax
801067af:	83 c8 80             	or     $0xffffff80,%eax
801067b2:	a2 05 4b 11 80       	mov    %al,0x80114b05
801067b7:	a1 98 b1 10 80       	mov    0x8010b198,%eax
801067bc:	c1 e8 10             	shr    $0x10,%eax
801067bf:	66 a3 06 4b 11 80    	mov    %ax,0x80114b06
  
  initlock(&tickslock, "time");
801067c5:	83 ec 08             	sub    $0x8,%esp
801067c8:	68 cc 89 10 80       	push   $0x801089cc
801067cd:	68 c0 48 11 80       	push   $0x801148c0
801067d2:	e8 eb e7 ff ff       	call   80104fc2 <initlock>
801067d7:	83 c4 10             	add    $0x10,%esp
}
801067da:	90                   	nop
801067db:	c9                   	leave  
801067dc:	c3                   	ret    

801067dd <idtinit>:

void
idtinit(void)
{
801067dd:	55                   	push   %ebp
801067de:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801067e0:	68 00 08 00 00       	push   $0x800
801067e5:	68 00 49 11 80       	push   $0x80114900
801067ea:	e8 3d fe ff ff       	call   8010662c <lidt>
801067ef:	83 c4 08             	add    $0x8,%esp
}
801067f2:	90                   	nop
801067f3:	c9                   	leave  
801067f4:	c3                   	ret    

801067f5 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801067f5:	55                   	push   %ebp
801067f6:	89 e5                	mov    %esp,%ebp
801067f8:	57                   	push   %edi
801067f9:	56                   	push   %esi
801067fa:	53                   	push   %ebx
801067fb:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
801067fe:	8b 45 08             	mov    0x8(%ebp),%eax
80106801:	8b 40 30             	mov    0x30(%eax),%eax
80106804:	83 f8 40             	cmp    $0x40,%eax
80106807:	75 3e                	jne    80106847 <trap+0x52>
    if(proc->killed)
80106809:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010680f:	8b 40 24             	mov    0x24(%eax),%eax
80106812:	85 c0                	test   %eax,%eax
80106814:	74 05                	je     8010681b <trap+0x26>
      exit();
80106816:	e8 92 e0 ff ff       	call   801048ad <exit>
    proc->tf = tf;
8010681b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106821:	8b 55 08             	mov    0x8(%ebp),%edx
80106824:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106827:	e8 f6 ed ff ff       	call   80105622 <syscall>
    if(proc->killed)
8010682c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106832:	8b 40 24             	mov    0x24(%eax),%eax
80106835:	85 c0                	test   %eax,%eax
80106837:	0f 84 1b 02 00 00    	je     80106a58 <trap+0x263>
      exit();
8010683d:	e8 6b e0 ff ff       	call   801048ad <exit>
    return;
80106842:	e9 11 02 00 00       	jmp    80106a58 <trap+0x263>
  }

  switch(tf->trapno){
80106847:	8b 45 08             	mov    0x8(%ebp),%eax
8010684a:	8b 40 30             	mov    0x30(%eax),%eax
8010684d:	83 e8 20             	sub    $0x20,%eax
80106850:	83 f8 1f             	cmp    $0x1f,%eax
80106853:	0f 87 c0 00 00 00    	ja     80106919 <trap+0x124>
80106859:	8b 04 85 74 8a 10 80 	mov    -0x7fef758c(,%eax,4),%eax
80106860:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106862:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106868:	0f b6 00             	movzbl (%eax),%eax
8010686b:	84 c0                	test   %al,%al
8010686d:	75 3d                	jne    801068ac <trap+0xb7>
      acquire(&tickslock);
8010686f:	83 ec 0c             	sub    $0xc,%esp
80106872:	68 c0 48 11 80       	push   $0x801148c0
80106877:	e8 68 e7 ff ff       	call   80104fe4 <acquire>
8010687c:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010687f:	a1 00 51 11 80       	mov    0x80115100,%eax
80106884:	83 c0 01             	add    $0x1,%eax
80106887:	a3 00 51 11 80       	mov    %eax,0x80115100
      wakeup(&ticks);
8010688c:	83 ec 0c             	sub    $0xc,%esp
8010688f:	68 00 51 11 80       	push   $0x80115100
80106894:	e8 3d e5 ff ff       	call   80104dd6 <wakeup>
80106899:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
8010689c:	83 ec 0c             	sub    $0xc,%esp
8010689f:	68 c0 48 11 80       	push   $0x801148c0
801068a4:	e8 a2 e7 ff ff       	call   8010504b <release>
801068a9:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801068ac:	e8 59 c7 ff ff       	call   8010300a <lapiceoi>
    break;
801068b1:	e9 1c 01 00 00       	jmp    801069d2 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801068b6:	e8 62 bf ff ff       	call   8010281d <ideintr>
    lapiceoi();
801068bb:	e8 4a c7 ff ff       	call   8010300a <lapiceoi>
    break;
801068c0:	e9 0d 01 00 00       	jmp    801069d2 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801068c5:	e8 42 c5 ff ff       	call   80102e0c <kbdintr>
    lapiceoi();
801068ca:	e8 3b c7 ff ff       	call   8010300a <lapiceoi>
    break;
801068cf:	e9 fe 00 00 00       	jmp    801069d2 <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801068d4:	e8 60 03 00 00       	call   80106c39 <uartintr>
    lapiceoi();
801068d9:	e8 2c c7 ff ff       	call   8010300a <lapiceoi>
    break;
801068de:	e9 ef 00 00 00       	jmp    801069d2 <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801068e3:	8b 45 08             	mov    0x8(%ebp),%eax
801068e6:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801068e9:	8b 45 08             	mov    0x8(%ebp),%eax
801068ec:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801068f0:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801068f3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801068f9:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801068fc:	0f b6 c0             	movzbl %al,%eax
801068ff:	51                   	push   %ecx
80106900:	52                   	push   %edx
80106901:	50                   	push   %eax
80106902:	68 d4 89 10 80       	push   $0x801089d4
80106907:	e8 ba 9a ff ff       	call   801003c6 <cprintf>
8010690c:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
8010690f:	e8 f6 c6 ff ff       	call   8010300a <lapiceoi>
    break;
80106914:	e9 b9 00 00 00       	jmp    801069d2 <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106919:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010691f:	85 c0                	test   %eax,%eax
80106921:	74 11                	je     80106934 <trap+0x13f>
80106923:	8b 45 08             	mov    0x8(%ebp),%eax
80106926:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010692a:	0f b7 c0             	movzwl %ax,%eax
8010692d:	83 e0 03             	and    $0x3,%eax
80106930:	85 c0                	test   %eax,%eax
80106932:	75 40                	jne    80106974 <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106934:	e8 1d fd ff ff       	call   80106656 <rcr2>
80106939:	89 c3                	mov    %eax,%ebx
8010693b:	8b 45 08             	mov    0x8(%ebp),%eax
8010693e:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106941:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106947:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010694a:	0f b6 d0             	movzbl %al,%edx
8010694d:	8b 45 08             	mov    0x8(%ebp),%eax
80106950:	8b 40 30             	mov    0x30(%eax),%eax
80106953:	83 ec 0c             	sub    $0xc,%esp
80106956:	53                   	push   %ebx
80106957:	51                   	push   %ecx
80106958:	52                   	push   %edx
80106959:	50                   	push   %eax
8010695a:	68 f8 89 10 80       	push   $0x801089f8
8010695f:	e8 62 9a ff ff       	call   801003c6 <cprintf>
80106964:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106967:	83 ec 0c             	sub    $0xc,%esp
8010696a:	68 2a 8a 10 80       	push   $0x80108a2a
8010696f:	e8 f2 9b ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106974:	e8 dd fc ff ff       	call   80106656 <rcr2>
80106979:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010697c:	8b 45 08             	mov    0x8(%ebp),%eax
8010697f:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106982:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106988:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010698b:	0f b6 d8             	movzbl %al,%ebx
8010698e:	8b 45 08             	mov    0x8(%ebp),%eax
80106991:	8b 48 34             	mov    0x34(%eax),%ecx
80106994:	8b 45 08             	mov    0x8(%ebp),%eax
80106997:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010699a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069a0:	8d 78 6c             	lea    0x6c(%eax),%edi
801069a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069a9:	8b 40 10             	mov    0x10(%eax),%eax
801069ac:	ff 75 e4             	pushl  -0x1c(%ebp)
801069af:	56                   	push   %esi
801069b0:	53                   	push   %ebx
801069b1:	51                   	push   %ecx
801069b2:	52                   	push   %edx
801069b3:	57                   	push   %edi
801069b4:	50                   	push   %eax
801069b5:	68 30 8a 10 80       	push   $0x80108a30
801069ba:	e8 07 9a ff ff       	call   801003c6 <cprintf>
801069bf:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801069c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069c8:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801069cf:	eb 01                	jmp    801069d2 <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801069d1:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801069d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069d8:	85 c0                	test   %eax,%eax
801069da:	74 24                	je     80106a00 <trap+0x20b>
801069dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069e2:	8b 40 24             	mov    0x24(%eax),%eax
801069e5:	85 c0                	test   %eax,%eax
801069e7:	74 17                	je     80106a00 <trap+0x20b>
801069e9:	8b 45 08             	mov    0x8(%ebp),%eax
801069ec:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801069f0:	0f b7 c0             	movzwl %ax,%eax
801069f3:	83 e0 03             	and    $0x3,%eax
801069f6:	83 f8 03             	cmp    $0x3,%eax
801069f9:	75 05                	jne    80106a00 <trap+0x20b>
    exit();
801069fb:	e8 ad de ff ff       	call   801048ad <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106a00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a06:	85 c0                	test   %eax,%eax
80106a08:	74 1e                	je     80106a28 <trap+0x233>
80106a0a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a10:	8b 40 0c             	mov    0xc(%eax),%eax
80106a13:	83 f8 04             	cmp    $0x4,%eax
80106a16:	75 10                	jne    80106a28 <trap+0x233>
80106a18:	8b 45 08             	mov    0x8(%ebp),%eax
80106a1b:	8b 40 30             	mov    0x30(%eax),%eax
80106a1e:	83 f8 20             	cmp    $0x20,%eax
80106a21:	75 05                	jne    80106a28 <trap+0x233>
    yield();
80106a23:	e8 42 e2 ff ff       	call   80104c6a <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106a28:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a2e:	85 c0                	test   %eax,%eax
80106a30:	74 27                	je     80106a59 <trap+0x264>
80106a32:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a38:	8b 40 24             	mov    0x24(%eax),%eax
80106a3b:	85 c0                	test   %eax,%eax
80106a3d:	74 1a                	je     80106a59 <trap+0x264>
80106a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80106a42:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a46:	0f b7 c0             	movzwl %ax,%eax
80106a49:	83 e0 03             	and    $0x3,%eax
80106a4c:	83 f8 03             	cmp    $0x3,%eax
80106a4f:	75 08                	jne    80106a59 <trap+0x264>
    exit();
80106a51:	e8 57 de ff ff       	call   801048ad <exit>
80106a56:	eb 01                	jmp    80106a59 <trap+0x264>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106a58:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106a59:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106a5c:	5b                   	pop    %ebx
80106a5d:	5e                   	pop    %esi
80106a5e:	5f                   	pop    %edi
80106a5f:	5d                   	pop    %ebp
80106a60:	c3                   	ret    

80106a61 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106a61:	55                   	push   %ebp
80106a62:	89 e5                	mov    %esp,%ebp
80106a64:	83 ec 14             	sub    $0x14,%esp
80106a67:	8b 45 08             	mov    0x8(%ebp),%eax
80106a6a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106a6e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106a72:	89 c2                	mov    %eax,%edx
80106a74:	ec                   	in     (%dx),%al
80106a75:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106a78:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106a7c:	c9                   	leave  
80106a7d:	c3                   	ret    

80106a7e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106a7e:	55                   	push   %ebp
80106a7f:	89 e5                	mov    %esp,%ebp
80106a81:	83 ec 08             	sub    $0x8,%esp
80106a84:	8b 55 08             	mov    0x8(%ebp),%edx
80106a87:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a8a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106a8e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106a91:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106a95:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106a99:	ee                   	out    %al,(%dx)
}
80106a9a:	90                   	nop
80106a9b:	c9                   	leave  
80106a9c:	c3                   	ret    

80106a9d <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106a9d:	55                   	push   %ebp
80106a9e:	89 e5                	mov    %esp,%ebp
80106aa0:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106aa3:	6a 00                	push   $0x0
80106aa5:	68 fa 03 00 00       	push   $0x3fa
80106aaa:	e8 cf ff ff ff       	call   80106a7e <outb>
80106aaf:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106ab2:	68 80 00 00 00       	push   $0x80
80106ab7:	68 fb 03 00 00       	push   $0x3fb
80106abc:	e8 bd ff ff ff       	call   80106a7e <outb>
80106ac1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106ac4:	6a 0c                	push   $0xc
80106ac6:	68 f8 03 00 00       	push   $0x3f8
80106acb:	e8 ae ff ff ff       	call   80106a7e <outb>
80106ad0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106ad3:	6a 00                	push   $0x0
80106ad5:	68 f9 03 00 00       	push   $0x3f9
80106ada:	e8 9f ff ff ff       	call   80106a7e <outb>
80106adf:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106ae2:	6a 03                	push   $0x3
80106ae4:	68 fb 03 00 00       	push   $0x3fb
80106ae9:	e8 90 ff ff ff       	call   80106a7e <outb>
80106aee:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106af1:	6a 00                	push   $0x0
80106af3:	68 fc 03 00 00       	push   $0x3fc
80106af8:	e8 81 ff ff ff       	call   80106a7e <outb>
80106afd:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106b00:	6a 01                	push   $0x1
80106b02:	68 f9 03 00 00       	push   $0x3f9
80106b07:	e8 72 ff ff ff       	call   80106a7e <outb>
80106b0c:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106b0f:	68 fd 03 00 00       	push   $0x3fd
80106b14:	e8 48 ff ff ff       	call   80106a61 <inb>
80106b19:	83 c4 04             	add    $0x4,%esp
80106b1c:	3c ff                	cmp    $0xff,%al
80106b1e:	74 6e                	je     80106b8e <uartinit+0xf1>
    return;
  uart = 1;
80106b20:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106b27:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106b2a:	68 fa 03 00 00       	push   $0x3fa
80106b2f:	e8 2d ff ff ff       	call   80106a61 <inb>
80106b34:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106b37:	68 f8 03 00 00       	push   $0x3f8
80106b3c:	e8 20 ff ff ff       	call   80106a61 <inb>
80106b41:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80106b44:	83 ec 0c             	sub    $0xc,%esp
80106b47:	6a 04                	push   $0x4
80106b49:	e8 c2 d3 ff ff       	call   80103f10 <picenable>
80106b4e:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80106b51:	83 ec 08             	sub    $0x8,%esp
80106b54:	6a 00                	push   $0x0
80106b56:	6a 04                	push   $0x4
80106b58:	e8 62 bf ff ff       	call   80102abf <ioapicenable>
80106b5d:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106b60:	c7 45 f4 f4 8a 10 80 	movl   $0x80108af4,-0xc(%ebp)
80106b67:	eb 19                	jmp    80106b82 <uartinit+0xe5>
    uartputc(*p);
80106b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b6c:	0f b6 00             	movzbl (%eax),%eax
80106b6f:	0f be c0             	movsbl %al,%eax
80106b72:	83 ec 0c             	sub    $0xc,%esp
80106b75:	50                   	push   %eax
80106b76:	e8 16 00 00 00       	call   80106b91 <uartputc>
80106b7b:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106b7e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b85:	0f b6 00             	movzbl (%eax),%eax
80106b88:	84 c0                	test   %al,%al
80106b8a:	75 dd                	jne    80106b69 <uartinit+0xcc>
80106b8c:	eb 01                	jmp    80106b8f <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106b8e:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106b8f:	c9                   	leave  
80106b90:	c3                   	ret    

80106b91 <uartputc>:

void
uartputc(int c)
{
80106b91:	55                   	push   %ebp
80106b92:	89 e5                	mov    %esp,%ebp
80106b94:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106b97:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106b9c:	85 c0                	test   %eax,%eax
80106b9e:	74 53                	je     80106bf3 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ba0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ba7:	eb 11                	jmp    80106bba <uartputc+0x29>
    microdelay(10);
80106ba9:	83 ec 0c             	sub    $0xc,%esp
80106bac:	6a 0a                	push   $0xa
80106bae:	e8 72 c4 ff ff       	call   80103025 <microdelay>
80106bb3:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106bb6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106bba:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106bbe:	7f 1a                	jg     80106bda <uartputc+0x49>
80106bc0:	83 ec 0c             	sub    $0xc,%esp
80106bc3:	68 fd 03 00 00       	push   $0x3fd
80106bc8:	e8 94 fe ff ff       	call   80106a61 <inb>
80106bcd:	83 c4 10             	add    $0x10,%esp
80106bd0:	0f b6 c0             	movzbl %al,%eax
80106bd3:	83 e0 20             	and    $0x20,%eax
80106bd6:	85 c0                	test   %eax,%eax
80106bd8:	74 cf                	je     80106ba9 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106bda:	8b 45 08             	mov    0x8(%ebp),%eax
80106bdd:	0f b6 c0             	movzbl %al,%eax
80106be0:	83 ec 08             	sub    $0x8,%esp
80106be3:	50                   	push   %eax
80106be4:	68 f8 03 00 00       	push   $0x3f8
80106be9:	e8 90 fe ff ff       	call   80106a7e <outb>
80106bee:	83 c4 10             	add    $0x10,%esp
80106bf1:	eb 01                	jmp    80106bf4 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106bf3:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106bf4:	c9                   	leave  
80106bf5:	c3                   	ret    

80106bf6 <uartgetc>:

static int
uartgetc(void)
{
80106bf6:	55                   	push   %ebp
80106bf7:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106bf9:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106bfe:	85 c0                	test   %eax,%eax
80106c00:	75 07                	jne    80106c09 <uartgetc+0x13>
    return -1;
80106c02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c07:	eb 2e                	jmp    80106c37 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106c09:	68 fd 03 00 00       	push   $0x3fd
80106c0e:	e8 4e fe ff ff       	call   80106a61 <inb>
80106c13:	83 c4 04             	add    $0x4,%esp
80106c16:	0f b6 c0             	movzbl %al,%eax
80106c19:	83 e0 01             	and    $0x1,%eax
80106c1c:	85 c0                	test   %eax,%eax
80106c1e:	75 07                	jne    80106c27 <uartgetc+0x31>
    return -1;
80106c20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c25:	eb 10                	jmp    80106c37 <uartgetc+0x41>
  return inb(COM1+0);
80106c27:	68 f8 03 00 00       	push   $0x3f8
80106c2c:	e8 30 fe ff ff       	call   80106a61 <inb>
80106c31:	83 c4 04             	add    $0x4,%esp
80106c34:	0f b6 c0             	movzbl %al,%eax
}
80106c37:	c9                   	leave  
80106c38:	c3                   	ret    

80106c39 <uartintr>:

void
uartintr(void)
{
80106c39:	55                   	push   %ebp
80106c3a:	89 e5                	mov    %esp,%ebp
80106c3c:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106c3f:	83 ec 0c             	sub    $0xc,%esp
80106c42:	68 f6 6b 10 80       	push   $0x80106bf6
80106c47:	e8 91 9b ff ff       	call   801007dd <consoleintr>
80106c4c:	83 c4 10             	add    $0x10,%esp
}
80106c4f:	90                   	nop
80106c50:	c9                   	leave  
80106c51:	c3                   	ret    

80106c52 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106c52:	6a 00                	push   $0x0
  pushl $0
80106c54:	6a 00                	push   $0x0
  jmp alltraps
80106c56:	e9 a6 f9 ff ff       	jmp    80106601 <alltraps>

80106c5b <vector1>:
.globl vector1
vector1:
  pushl $0
80106c5b:	6a 00                	push   $0x0
  pushl $1
80106c5d:	6a 01                	push   $0x1
  jmp alltraps
80106c5f:	e9 9d f9 ff ff       	jmp    80106601 <alltraps>

80106c64 <vector2>:
.globl vector2
vector2:
  pushl $0
80106c64:	6a 00                	push   $0x0
  pushl $2
80106c66:	6a 02                	push   $0x2
  jmp alltraps
80106c68:	e9 94 f9 ff ff       	jmp    80106601 <alltraps>

80106c6d <vector3>:
.globl vector3
vector3:
  pushl $0
80106c6d:	6a 00                	push   $0x0
  pushl $3
80106c6f:	6a 03                	push   $0x3
  jmp alltraps
80106c71:	e9 8b f9 ff ff       	jmp    80106601 <alltraps>

80106c76 <vector4>:
.globl vector4
vector4:
  pushl $0
80106c76:	6a 00                	push   $0x0
  pushl $4
80106c78:	6a 04                	push   $0x4
  jmp alltraps
80106c7a:	e9 82 f9 ff ff       	jmp    80106601 <alltraps>

80106c7f <vector5>:
.globl vector5
vector5:
  pushl $0
80106c7f:	6a 00                	push   $0x0
  pushl $5
80106c81:	6a 05                	push   $0x5
  jmp alltraps
80106c83:	e9 79 f9 ff ff       	jmp    80106601 <alltraps>

80106c88 <vector6>:
.globl vector6
vector6:
  pushl $0
80106c88:	6a 00                	push   $0x0
  pushl $6
80106c8a:	6a 06                	push   $0x6
  jmp alltraps
80106c8c:	e9 70 f9 ff ff       	jmp    80106601 <alltraps>

80106c91 <vector7>:
.globl vector7
vector7:
  pushl $0
80106c91:	6a 00                	push   $0x0
  pushl $7
80106c93:	6a 07                	push   $0x7
  jmp alltraps
80106c95:	e9 67 f9 ff ff       	jmp    80106601 <alltraps>

80106c9a <vector8>:
.globl vector8
vector8:
  pushl $8
80106c9a:	6a 08                	push   $0x8
  jmp alltraps
80106c9c:	e9 60 f9 ff ff       	jmp    80106601 <alltraps>

80106ca1 <vector9>:
.globl vector9
vector9:
  pushl $0
80106ca1:	6a 00                	push   $0x0
  pushl $9
80106ca3:	6a 09                	push   $0x9
  jmp alltraps
80106ca5:	e9 57 f9 ff ff       	jmp    80106601 <alltraps>

80106caa <vector10>:
.globl vector10
vector10:
  pushl $10
80106caa:	6a 0a                	push   $0xa
  jmp alltraps
80106cac:	e9 50 f9 ff ff       	jmp    80106601 <alltraps>

80106cb1 <vector11>:
.globl vector11
vector11:
  pushl $11
80106cb1:	6a 0b                	push   $0xb
  jmp alltraps
80106cb3:	e9 49 f9 ff ff       	jmp    80106601 <alltraps>

80106cb8 <vector12>:
.globl vector12
vector12:
  pushl $12
80106cb8:	6a 0c                	push   $0xc
  jmp alltraps
80106cba:	e9 42 f9 ff ff       	jmp    80106601 <alltraps>

80106cbf <vector13>:
.globl vector13
vector13:
  pushl $13
80106cbf:	6a 0d                	push   $0xd
  jmp alltraps
80106cc1:	e9 3b f9 ff ff       	jmp    80106601 <alltraps>

80106cc6 <vector14>:
.globl vector14
vector14:
  pushl $14
80106cc6:	6a 0e                	push   $0xe
  jmp alltraps
80106cc8:	e9 34 f9 ff ff       	jmp    80106601 <alltraps>

80106ccd <vector15>:
.globl vector15
vector15:
  pushl $0
80106ccd:	6a 00                	push   $0x0
  pushl $15
80106ccf:	6a 0f                	push   $0xf
  jmp alltraps
80106cd1:	e9 2b f9 ff ff       	jmp    80106601 <alltraps>

80106cd6 <vector16>:
.globl vector16
vector16:
  pushl $0
80106cd6:	6a 00                	push   $0x0
  pushl $16
80106cd8:	6a 10                	push   $0x10
  jmp alltraps
80106cda:	e9 22 f9 ff ff       	jmp    80106601 <alltraps>

80106cdf <vector17>:
.globl vector17
vector17:
  pushl $17
80106cdf:	6a 11                	push   $0x11
  jmp alltraps
80106ce1:	e9 1b f9 ff ff       	jmp    80106601 <alltraps>

80106ce6 <vector18>:
.globl vector18
vector18:
  pushl $0
80106ce6:	6a 00                	push   $0x0
  pushl $18
80106ce8:	6a 12                	push   $0x12
  jmp alltraps
80106cea:	e9 12 f9 ff ff       	jmp    80106601 <alltraps>

80106cef <vector19>:
.globl vector19
vector19:
  pushl $0
80106cef:	6a 00                	push   $0x0
  pushl $19
80106cf1:	6a 13                	push   $0x13
  jmp alltraps
80106cf3:	e9 09 f9 ff ff       	jmp    80106601 <alltraps>

80106cf8 <vector20>:
.globl vector20
vector20:
  pushl $0
80106cf8:	6a 00                	push   $0x0
  pushl $20
80106cfa:	6a 14                	push   $0x14
  jmp alltraps
80106cfc:	e9 00 f9 ff ff       	jmp    80106601 <alltraps>

80106d01 <vector21>:
.globl vector21
vector21:
  pushl $0
80106d01:	6a 00                	push   $0x0
  pushl $21
80106d03:	6a 15                	push   $0x15
  jmp alltraps
80106d05:	e9 f7 f8 ff ff       	jmp    80106601 <alltraps>

80106d0a <vector22>:
.globl vector22
vector22:
  pushl $0
80106d0a:	6a 00                	push   $0x0
  pushl $22
80106d0c:	6a 16                	push   $0x16
  jmp alltraps
80106d0e:	e9 ee f8 ff ff       	jmp    80106601 <alltraps>

80106d13 <vector23>:
.globl vector23
vector23:
  pushl $0
80106d13:	6a 00                	push   $0x0
  pushl $23
80106d15:	6a 17                	push   $0x17
  jmp alltraps
80106d17:	e9 e5 f8 ff ff       	jmp    80106601 <alltraps>

80106d1c <vector24>:
.globl vector24
vector24:
  pushl $0
80106d1c:	6a 00                	push   $0x0
  pushl $24
80106d1e:	6a 18                	push   $0x18
  jmp alltraps
80106d20:	e9 dc f8 ff ff       	jmp    80106601 <alltraps>

80106d25 <vector25>:
.globl vector25
vector25:
  pushl $0
80106d25:	6a 00                	push   $0x0
  pushl $25
80106d27:	6a 19                	push   $0x19
  jmp alltraps
80106d29:	e9 d3 f8 ff ff       	jmp    80106601 <alltraps>

80106d2e <vector26>:
.globl vector26
vector26:
  pushl $0
80106d2e:	6a 00                	push   $0x0
  pushl $26
80106d30:	6a 1a                	push   $0x1a
  jmp alltraps
80106d32:	e9 ca f8 ff ff       	jmp    80106601 <alltraps>

80106d37 <vector27>:
.globl vector27
vector27:
  pushl $0
80106d37:	6a 00                	push   $0x0
  pushl $27
80106d39:	6a 1b                	push   $0x1b
  jmp alltraps
80106d3b:	e9 c1 f8 ff ff       	jmp    80106601 <alltraps>

80106d40 <vector28>:
.globl vector28
vector28:
  pushl $0
80106d40:	6a 00                	push   $0x0
  pushl $28
80106d42:	6a 1c                	push   $0x1c
  jmp alltraps
80106d44:	e9 b8 f8 ff ff       	jmp    80106601 <alltraps>

80106d49 <vector29>:
.globl vector29
vector29:
  pushl $0
80106d49:	6a 00                	push   $0x0
  pushl $29
80106d4b:	6a 1d                	push   $0x1d
  jmp alltraps
80106d4d:	e9 af f8 ff ff       	jmp    80106601 <alltraps>

80106d52 <vector30>:
.globl vector30
vector30:
  pushl $0
80106d52:	6a 00                	push   $0x0
  pushl $30
80106d54:	6a 1e                	push   $0x1e
  jmp alltraps
80106d56:	e9 a6 f8 ff ff       	jmp    80106601 <alltraps>

80106d5b <vector31>:
.globl vector31
vector31:
  pushl $0
80106d5b:	6a 00                	push   $0x0
  pushl $31
80106d5d:	6a 1f                	push   $0x1f
  jmp alltraps
80106d5f:	e9 9d f8 ff ff       	jmp    80106601 <alltraps>

80106d64 <vector32>:
.globl vector32
vector32:
  pushl $0
80106d64:	6a 00                	push   $0x0
  pushl $32
80106d66:	6a 20                	push   $0x20
  jmp alltraps
80106d68:	e9 94 f8 ff ff       	jmp    80106601 <alltraps>

80106d6d <vector33>:
.globl vector33
vector33:
  pushl $0
80106d6d:	6a 00                	push   $0x0
  pushl $33
80106d6f:	6a 21                	push   $0x21
  jmp alltraps
80106d71:	e9 8b f8 ff ff       	jmp    80106601 <alltraps>

80106d76 <vector34>:
.globl vector34
vector34:
  pushl $0
80106d76:	6a 00                	push   $0x0
  pushl $34
80106d78:	6a 22                	push   $0x22
  jmp alltraps
80106d7a:	e9 82 f8 ff ff       	jmp    80106601 <alltraps>

80106d7f <vector35>:
.globl vector35
vector35:
  pushl $0
80106d7f:	6a 00                	push   $0x0
  pushl $35
80106d81:	6a 23                	push   $0x23
  jmp alltraps
80106d83:	e9 79 f8 ff ff       	jmp    80106601 <alltraps>

80106d88 <vector36>:
.globl vector36
vector36:
  pushl $0
80106d88:	6a 00                	push   $0x0
  pushl $36
80106d8a:	6a 24                	push   $0x24
  jmp alltraps
80106d8c:	e9 70 f8 ff ff       	jmp    80106601 <alltraps>

80106d91 <vector37>:
.globl vector37
vector37:
  pushl $0
80106d91:	6a 00                	push   $0x0
  pushl $37
80106d93:	6a 25                	push   $0x25
  jmp alltraps
80106d95:	e9 67 f8 ff ff       	jmp    80106601 <alltraps>

80106d9a <vector38>:
.globl vector38
vector38:
  pushl $0
80106d9a:	6a 00                	push   $0x0
  pushl $38
80106d9c:	6a 26                	push   $0x26
  jmp alltraps
80106d9e:	e9 5e f8 ff ff       	jmp    80106601 <alltraps>

80106da3 <vector39>:
.globl vector39
vector39:
  pushl $0
80106da3:	6a 00                	push   $0x0
  pushl $39
80106da5:	6a 27                	push   $0x27
  jmp alltraps
80106da7:	e9 55 f8 ff ff       	jmp    80106601 <alltraps>

80106dac <vector40>:
.globl vector40
vector40:
  pushl $0
80106dac:	6a 00                	push   $0x0
  pushl $40
80106dae:	6a 28                	push   $0x28
  jmp alltraps
80106db0:	e9 4c f8 ff ff       	jmp    80106601 <alltraps>

80106db5 <vector41>:
.globl vector41
vector41:
  pushl $0
80106db5:	6a 00                	push   $0x0
  pushl $41
80106db7:	6a 29                	push   $0x29
  jmp alltraps
80106db9:	e9 43 f8 ff ff       	jmp    80106601 <alltraps>

80106dbe <vector42>:
.globl vector42
vector42:
  pushl $0
80106dbe:	6a 00                	push   $0x0
  pushl $42
80106dc0:	6a 2a                	push   $0x2a
  jmp alltraps
80106dc2:	e9 3a f8 ff ff       	jmp    80106601 <alltraps>

80106dc7 <vector43>:
.globl vector43
vector43:
  pushl $0
80106dc7:	6a 00                	push   $0x0
  pushl $43
80106dc9:	6a 2b                	push   $0x2b
  jmp alltraps
80106dcb:	e9 31 f8 ff ff       	jmp    80106601 <alltraps>

80106dd0 <vector44>:
.globl vector44
vector44:
  pushl $0
80106dd0:	6a 00                	push   $0x0
  pushl $44
80106dd2:	6a 2c                	push   $0x2c
  jmp alltraps
80106dd4:	e9 28 f8 ff ff       	jmp    80106601 <alltraps>

80106dd9 <vector45>:
.globl vector45
vector45:
  pushl $0
80106dd9:	6a 00                	push   $0x0
  pushl $45
80106ddb:	6a 2d                	push   $0x2d
  jmp alltraps
80106ddd:	e9 1f f8 ff ff       	jmp    80106601 <alltraps>

80106de2 <vector46>:
.globl vector46
vector46:
  pushl $0
80106de2:	6a 00                	push   $0x0
  pushl $46
80106de4:	6a 2e                	push   $0x2e
  jmp alltraps
80106de6:	e9 16 f8 ff ff       	jmp    80106601 <alltraps>

80106deb <vector47>:
.globl vector47
vector47:
  pushl $0
80106deb:	6a 00                	push   $0x0
  pushl $47
80106ded:	6a 2f                	push   $0x2f
  jmp alltraps
80106def:	e9 0d f8 ff ff       	jmp    80106601 <alltraps>

80106df4 <vector48>:
.globl vector48
vector48:
  pushl $0
80106df4:	6a 00                	push   $0x0
  pushl $48
80106df6:	6a 30                	push   $0x30
  jmp alltraps
80106df8:	e9 04 f8 ff ff       	jmp    80106601 <alltraps>

80106dfd <vector49>:
.globl vector49
vector49:
  pushl $0
80106dfd:	6a 00                	push   $0x0
  pushl $49
80106dff:	6a 31                	push   $0x31
  jmp alltraps
80106e01:	e9 fb f7 ff ff       	jmp    80106601 <alltraps>

80106e06 <vector50>:
.globl vector50
vector50:
  pushl $0
80106e06:	6a 00                	push   $0x0
  pushl $50
80106e08:	6a 32                	push   $0x32
  jmp alltraps
80106e0a:	e9 f2 f7 ff ff       	jmp    80106601 <alltraps>

80106e0f <vector51>:
.globl vector51
vector51:
  pushl $0
80106e0f:	6a 00                	push   $0x0
  pushl $51
80106e11:	6a 33                	push   $0x33
  jmp alltraps
80106e13:	e9 e9 f7 ff ff       	jmp    80106601 <alltraps>

80106e18 <vector52>:
.globl vector52
vector52:
  pushl $0
80106e18:	6a 00                	push   $0x0
  pushl $52
80106e1a:	6a 34                	push   $0x34
  jmp alltraps
80106e1c:	e9 e0 f7 ff ff       	jmp    80106601 <alltraps>

80106e21 <vector53>:
.globl vector53
vector53:
  pushl $0
80106e21:	6a 00                	push   $0x0
  pushl $53
80106e23:	6a 35                	push   $0x35
  jmp alltraps
80106e25:	e9 d7 f7 ff ff       	jmp    80106601 <alltraps>

80106e2a <vector54>:
.globl vector54
vector54:
  pushl $0
80106e2a:	6a 00                	push   $0x0
  pushl $54
80106e2c:	6a 36                	push   $0x36
  jmp alltraps
80106e2e:	e9 ce f7 ff ff       	jmp    80106601 <alltraps>

80106e33 <vector55>:
.globl vector55
vector55:
  pushl $0
80106e33:	6a 00                	push   $0x0
  pushl $55
80106e35:	6a 37                	push   $0x37
  jmp alltraps
80106e37:	e9 c5 f7 ff ff       	jmp    80106601 <alltraps>

80106e3c <vector56>:
.globl vector56
vector56:
  pushl $0
80106e3c:	6a 00                	push   $0x0
  pushl $56
80106e3e:	6a 38                	push   $0x38
  jmp alltraps
80106e40:	e9 bc f7 ff ff       	jmp    80106601 <alltraps>

80106e45 <vector57>:
.globl vector57
vector57:
  pushl $0
80106e45:	6a 00                	push   $0x0
  pushl $57
80106e47:	6a 39                	push   $0x39
  jmp alltraps
80106e49:	e9 b3 f7 ff ff       	jmp    80106601 <alltraps>

80106e4e <vector58>:
.globl vector58
vector58:
  pushl $0
80106e4e:	6a 00                	push   $0x0
  pushl $58
80106e50:	6a 3a                	push   $0x3a
  jmp alltraps
80106e52:	e9 aa f7 ff ff       	jmp    80106601 <alltraps>

80106e57 <vector59>:
.globl vector59
vector59:
  pushl $0
80106e57:	6a 00                	push   $0x0
  pushl $59
80106e59:	6a 3b                	push   $0x3b
  jmp alltraps
80106e5b:	e9 a1 f7 ff ff       	jmp    80106601 <alltraps>

80106e60 <vector60>:
.globl vector60
vector60:
  pushl $0
80106e60:	6a 00                	push   $0x0
  pushl $60
80106e62:	6a 3c                	push   $0x3c
  jmp alltraps
80106e64:	e9 98 f7 ff ff       	jmp    80106601 <alltraps>

80106e69 <vector61>:
.globl vector61
vector61:
  pushl $0
80106e69:	6a 00                	push   $0x0
  pushl $61
80106e6b:	6a 3d                	push   $0x3d
  jmp alltraps
80106e6d:	e9 8f f7 ff ff       	jmp    80106601 <alltraps>

80106e72 <vector62>:
.globl vector62
vector62:
  pushl $0
80106e72:	6a 00                	push   $0x0
  pushl $62
80106e74:	6a 3e                	push   $0x3e
  jmp alltraps
80106e76:	e9 86 f7 ff ff       	jmp    80106601 <alltraps>

80106e7b <vector63>:
.globl vector63
vector63:
  pushl $0
80106e7b:	6a 00                	push   $0x0
  pushl $63
80106e7d:	6a 3f                	push   $0x3f
  jmp alltraps
80106e7f:	e9 7d f7 ff ff       	jmp    80106601 <alltraps>

80106e84 <vector64>:
.globl vector64
vector64:
  pushl $0
80106e84:	6a 00                	push   $0x0
  pushl $64
80106e86:	6a 40                	push   $0x40
  jmp alltraps
80106e88:	e9 74 f7 ff ff       	jmp    80106601 <alltraps>

80106e8d <vector65>:
.globl vector65
vector65:
  pushl $0
80106e8d:	6a 00                	push   $0x0
  pushl $65
80106e8f:	6a 41                	push   $0x41
  jmp alltraps
80106e91:	e9 6b f7 ff ff       	jmp    80106601 <alltraps>

80106e96 <vector66>:
.globl vector66
vector66:
  pushl $0
80106e96:	6a 00                	push   $0x0
  pushl $66
80106e98:	6a 42                	push   $0x42
  jmp alltraps
80106e9a:	e9 62 f7 ff ff       	jmp    80106601 <alltraps>

80106e9f <vector67>:
.globl vector67
vector67:
  pushl $0
80106e9f:	6a 00                	push   $0x0
  pushl $67
80106ea1:	6a 43                	push   $0x43
  jmp alltraps
80106ea3:	e9 59 f7 ff ff       	jmp    80106601 <alltraps>

80106ea8 <vector68>:
.globl vector68
vector68:
  pushl $0
80106ea8:	6a 00                	push   $0x0
  pushl $68
80106eaa:	6a 44                	push   $0x44
  jmp alltraps
80106eac:	e9 50 f7 ff ff       	jmp    80106601 <alltraps>

80106eb1 <vector69>:
.globl vector69
vector69:
  pushl $0
80106eb1:	6a 00                	push   $0x0
  pushl $69
80106eb3:	6a 45                	push   $0x45
  jmp alltraps
80106eb5:	e9 47 f7 ff ff       	jmp    80106601 <alltraps>

80106eba <vector70>:
.globl vector70
vector70:
  pushl $0
80106eba:	6a 00                	push   $0x0
  pushl $70
80106ebc:	6a 46                	push   $0x46
  jmp alltraps
80106ebe:	e9 3e f7 ff ff       	jmp    80106601 <alltraps>

80106ec3 <vector71>:
.globl vector71
vector71:
  pushl $0
80106ec3:	6a 00                	push   $0x0
  pushl $71
80106ec5:	6a 47                	push   $0x47
  jmp alltraps
80106ec7:	e9 35 f7 ff ff       	jmp    80106601 <alltraps>

80106ecc <vector72>:
.globl vector72
vector72:
  pushl $0
80106ecc:	6a 00                	push   $0x0
  pushl $72
80106ece:	6a 48                	push   $0x48
  jmp alltraps
80106ed0:	e9 2c f7 ff ff       	jmp    80106601 <alltraps>

80106ed5 <vector73>:
.globl vector73
vector73:
  pushl $0
80106ed5:	6a 00                	push   $0x0
  pushl $73
80106ed7:	6a 49                	push   $0x49
  jmp alltraps
80106ed9:	e9 23 f7 ff ff       	jmp    80106601 <alltraps>

80106ede <vector74>:
.globl vector74
vector74:
  pushl $0
80106ede:	6a 00                	push   $0x0
  pushl $74
80106ee0:	6a 4a                	push   $0x4a
  jmp alltraps
80106ee2:	e9 1a f7 ff ff       	jmp    80106601 <alltraps>

80106ee7 <vector75>:
.globl vector75
vector75:
  pushl $0
80106ee7:	6a 00                	push   $0x0
  pushl $75
80106ee9:	6a 4b                	push   $0x4b
  jmp alltraps
80106eeb:	e9 11 f7 ff ff       	jmp    80106601 <alltraps>

80106ef0 <vector76>:
.globl vector76
vector76:
  pushl $0
80106ef0:	6a 00                	push   $0x0
  pushl $76
80106ef2:	6a 4c                	push   $0x4c
  jmp alltraps
80106ef4:	e9 08 f7 ff ff       	jmp    80106601 <alltraps>

80106ef9 <vector77>:
.globl vector77
vector77:
  pushl $0
80106ef9:	6a 00                	push   $0x0
  pushl $77
80106efb:	6a 4d                	push   $0x4d
  jmp alltraps
80106efd:	e9 ff f6 ff ff       	jmp    80106601 <alltraps>

80106f02 <vector78>:
.globl vector78
vector78:
  pushl $0
80106f02:	6a 00                	push   $0x0
  pushl $78
80106f04:	6a 4e                	push   $0x4e
  jmp alltraps
80106f06:	e9 f6 f6 ff ff       	jmp    80106601 <alltraps>

80106f0b <vector79>:
.globl vector79
vector79:
  pushl $0
80106f0b:	6a 00                	push   $0x0
  pushl $79
80106f0d:	6a 4f                	push   $0x4f
  jmp alltraps
80106f0f:	e9 ed f6 ff ff       	jmp    80106601 <alltraps>

80106f14 <vector80>:
.globl vector80
vector80:
  pushl $0
80106f14:	6a 00                	push   $0x0
  pushl $80
80106f16:	6a 50                	push   $0x50
  jmp alltraps
80106f18:	e9 e4 f6 ff ff       	jmp    80106601 <alltraps>

80106f1d <vector81>:
.globl vector81
vector81:
  pushl $0
80106f1d:	6a 00                	push   $0x0
  pushl $81
80106f1f:	6a 51                	push   $0x51
  jmp alltraps
80106f21:	e9 db f6 ff ff       	jmp    80106601 <alltraps>

80106f26 <vector82>:
.globl vector82
vector82:
  pushl $0
80106f26:	6a 00                	push   $0x0
  pushl $82
80106f28:	6a 52                	push   $0x52
  jmp alltraps
80106f2a:	e9 d2 f6 ff ff       	jmp    80106601 <alltraps>

80106f2f <vector83>:
.globl vector83
vector83:
  pushl $0
80106f2f:	6a 00                	push   $0x0
  pushl $83
80106f31:	6a 53                	push   $0x53
  jmp alltraps
80106f33:	e9 c9 f6 ff ff       	jmp    80106601 <alltraps>

80106f38 <vector84>:
.globl vector84
vector84:
  pushl $0
80106f38:	6a 00                	push   $0x0
  pushl $84
80106f3a:	6a 54                	push   $0x54
  jmp alltraps
80106f3c:	e9 c0 f6 ff ff       	jmp    80106601 <alltraps>

80106f41 <vector85>:
.globl vector85
vector85:
  pushl $0
80106f41:	6a 00                	push   $0x0
  pushl $85
80106f43:	6a 55                	push   $0x55
  jmp alltraps
80106f45:	e9 b7 f6 ff ff       	jmp    80106601 <alltraps>

80106f4a <vector86>:
.globl vector86
vector86:
  pushl $0
80106f4a:	6a 00                	push   $0x0
  pushl $86
80106f4c:	6a 56                	push   $0x56
  jmp alltraps
80106f4e:	e9 ae f6 ff ff       	jmp    80106601 <alltraps>

80106f53 <vector87>:
.globl vector87
vector87:
  pushl $0
80106f53:	6a 00                	push   $0x0
  pushl $87
80106f55:	6a 57                	push   $0x57
  jmp alltraps
80106f57:	e9 a5 f6 ff ff       	jmp    80106601 <alltraps>

80106f5c <vector88>:
.globl vector88
vector88:
  pushl $0
80106f5c:	6a 00                	push   $0x0
  pushl $88
80106f5e:	6a 58                	push   $0x58
  jmp alltraps
80106f60:	e9 9c f6 ff ff       	jmp    80106601 <alltraps>

80106f65 <vector89>:
.globl vector89
vector89:
  pushl $0
80106f65:	6a 00                	push   $0x0
  pushl $89
80106f67:	6a 59                	push   $0x59
  jmp alltraps
80106f69:	e9 93 f6 ff ff       	jmp    80106601 <alltraps>

80106f6e <vector90>:
.globl vector90
vector90:
  pushl $0
80106f6e:	6a 00                	push   $0x0
  pushl $90
80106f70:	6a 5a                	push   $0x5a
  jmp alltraps
80106f72:	e9 8a f6 ff ff       	jmp    80106601 <alltraps>

80106f77 <vector91>:
.globl vector91
vector91:
  pushl $0
80106f77:	6a 00                	push   $0x0
  pushl $91
80106f79:	6a 5b                	push   $0x5b
  jmp alltraps
80106f7b:	e9 81 f6 ff ff       	jmp    80106601 <alltraps>

80106f80 <vector92>:
.globl vector92
vector92:
  pushl $0
80106f80:	6a 00                	push   $0x0
  pushl $92
80106f82:	6a 5c                	push   $0x5c
  jmp alltraps
80106f84:	e9 78 f6 ff ff       	jmp    80106601 <alltraps>

80106f89 <vector93>:
.globl vector93
vector93:
  pushl $0
80106f89:	6a 00                	push   $0x0
  pushl $93
80106f8b:	6a 5d                	push   $0x5d
  jmp alltraps
80106f8d:	e9 6f f6 ff ff       	jmp    80106601 <alltraps>

80106f92 <vector94>:
.globl vector94
vector94:
  pushl $0
80106f92:	6a 00                	push   $0x0
  pushl $94
80106f94:	6a 5e                	push   $0x5e
  jmp alltraps
80106f96:	e9 66 f6 ff ff       	jmp    80106601 <alltraps>

80106f9b <vector95>:
.globl vector95
vector95:
  pushl $0
80106f9b:	6a 00                	push   $0x0
  pushl $95
80106f9d:	6a 5f                	push   $0x5f
  jmp alltraps
80106f9f:	e9 5d f6 ff ff       	jmp    80106601 <alltraps>

80106fa4 <vector96>:
.globl vector96
vector96:
  pushl $0
80106fa4:	6a 00                	push   $0x0
  pushl $96
80106fa6:	6a 60                	push   $0x60
  jmp alltraps
80106fa8:	e9 54 f6 ff ff       	jmp    80106601 <alltraps>

80106fad <vector97>:
.globl vector97
vector97:
  pushl $0
80106fad:	6a 00                	push   $0x0
  pushl $97
80106faf:	6a 61                	push   $0x61
  jmp alltraps
80106fb1:	e9 4b f6 ff ff       	jmp    80106601 <alltraps>

80106fb6 <vector98>:
.globl vector98
vector98:
  pushl $0
80106fb6:	6a 00                	push   $0x0
  pushl $98
80106fb8:	6a 62                	push   $0x62
  jmp alltraps
80106fba:	e9 42 f6 ff ff       	jmp    80106601 <alltraps>

80106fbf <vector99>:
.globl vector99
vector99:
  pushl $0
80106fbf:	6a 00                	push   $0x0
  pushl $99
80106fc1:	6a 63                	push   $0x63
  jmp alltraps
80106fc3:	e9 39 f6 ff ff       	jmp    80106601 <alltraps>

80106fc8 <vector100>:
.globl vector100
vector100:
  pushl $0
80106fc8:	6a 00                	push   $0x0
  pushl $100
80106fca:	6a 64                	push   $0x64
  jmp alltraps
80106fcc:	e9 30 f6 ff ff       	jmp    80106601 <alltraps>

80106fd1 <vector101>:
.globl vector101
vector101:
  pushl $0
80106fd1:	6a 00                	push   $0x0
  pushl $101
80106fd3:	6a 65                	push   $0x65
  jmp alltraps
80106fd5:	e9 27 f6 ff ff       	jmp    80106601 <alltraps>

80106fda <vector102>:
.globl vector102
vector102:
  pushl $0
80106fda:	6a 00                	push   $0x0
  pushl $102
80106fdc:	6a 66                	push   $0x66
  jmp alltraps
80106fde:	e9 1e f6 ff ff       	jmp    80106601 <alltraps>

80106fe3 <vector103>:
.globl vector103
vector103:
  pushl $0
80106fe3:	6a 00                	push   $0x0
  pushl $103
80106fe5:	6a 67                	push   $0x67
  jmp alltraps
80106fe7:	e9 15 f6 ff ff       	jmp    80106601 <alltraps>

80106fec <vector104>:
.globl vector104
vector104:
  pushl $0
80106fec:	6a 00                	push   $0x0
  pushl $104
80106fee:	6a 68                	push   $0x68
  jmp alltraps
80106ff0:	e9 0c f6 ff ff       	jmp    80106601 <alltraps>

80106ff5 <vector105>:
.globl vector105
vector105:
  pushl $0
80106ff5:	6a 00                	push   $0x0
  pushl $105
80106ff7:	6a 69                	push   $0x69
  jmp alltraps
80106ff9:	e9 03 f6 ff ff       	jmp    80106601 <alltraps>

80106ffe <vector106>:
.globl vector106
vector106:
  pushl $0
80106ffe:	6a 00                	push   $0x0
  pushl $106
80107000:	6a 6a                	push   $0x6a
  jmp alltraps
80107002:	e9 fa f5 ff ff       	jmp    80106601 <alltraps>

80107007 <vector107>:
.globl vector107
vector107:
  pushl $0
80107007:	6a 00                	push   $0x0
  pushl $107
80107009:	6a 6b                	push   $0x6b
  jmp alltraps
8010700b:	e9 f1 f5 ff ff       	jmp    80106601 <alltraps>

80107010 <vector108>:
.globl vector108
vector108:
  pushl $0
80107010:	6a 00                	push   $0x0
  pushl $108
80107012:	6a 6c                	push   $0x6c
  jmp alltraps
80107014:	e9 e8 f5 ff ff       	jmp    80106601 <alltraps>

80107019 <vector109>:
.globl vector109
vector109:
  pushl $0
80107019:	6a 00                	push   $0x0
  pushl $109
8010701b:	6a 6d                	push   $0x6d
  jmp alltraps
8010701d:	e9 df f5 ff ff       	jmp    80106601 <alltraps>

80107022 <vector110>:
.globl vector110
vector110:
  pushl $0
80107022:	6a 00                	push   $0x0
  pushl $110
80107024:	6a 6e                	push   $0x6e
  jmp alltraps
80107026:	e9 d6 f5 ff ff       	jmp    80106601 <alltraps>

8010702b <vector111>:
.globl vector111
vector111:
  pushl $0
8010702b:	6a 00                	push   $0x0
  pushl $111
8010702d:	6a 6f                	push   $0x6f
  jmp alltraps
8010702f:	e9 cd f5 ff ff       	jmp    80106601 <alltraps>

80107034 <vector112>:
.globl vector112
vector112:
  pushl $0
80107034:	6a 00                	push   $0x0
  pushl $112
80107036:	6a 70                	push   $0x70
  jmp alltraps
80107038:	e9 c4 f5 ff ff       	jmp    80106601 <alltraps>

8010703d <vector113>:
.globl vector113
vector113:
  pushl $0
8010703d:	6a 00                	push   $0x0
  pushl $113
8010703f:	6a 71                	push   $0x71
  jmp alltraps
80107041:	e9 bb f5 ff ff       	jmp    80106601 <alltraps>

80107046 <vector114>:
.globl vector114
vector114:
  pushl $0
80107046:	6a 00                	push   $0x0
  pushl $114
80107048:	6a 72                	push   $0x72
  jmp alltraps
8010704a:	e9 b2 f5 ff ff       	jmp    80106601 <alltraps>

8010704f <vector115>:
.globl vector115
vector115:
  pushl $0
8010704f:	6a 00                	push   $0x0
  pushl $115
80107051:	6a 73                	push   $0x73
  jmp alltraps
80107053:	e9 a9 f5 ff ff       	jmp    80106601 <alltraps>

80107058 <vector116>:
.globl vector116
vector116:
  pushl $0
80107058:	6a 00                	push   $0x0
  pushl $116
8010705a:	6a 74                	push   $0x74
  jmp alltraps
8010705c:	e9 a0 f5 ff ff       	jmp    80106601 <alltraps>

80107061 <vector117>:
.globl vector117
vector117:
  pushl $0
80107061:	6a 00                	push   $0x0
  pushl $117
80107063:	6a 75                	push   $0x75
  jmp alltraps
80107065:	e9 97 f5 ff ff       	jmp    80106601 <alltraps>

8010706a <vector118>:
.globl vector118
vector118:
  pushl $0
8010706a:	6a 00                	push   $0x0
  pushl $118
8010706c:	6a 76                	push   $0x76
  jmp alltraps
8010706e:	e9 8e f5 ff ff       	jmp    80106601 <alltraps>

80107073 <vector119>:
.globl vector119
vector119:
  pushl $0
80107073:	6a 00                	push   $0x0
  pushl $119
80107075:	6a 77                	push   $0x77
  jmp alltraps
80107077:	e9 85 f5 ff ff       	jmp    80106601 <alltraps>

8010707c <vector120>:
.globl vector120
vector120:
  pushl $0
8010707c:	6a 00                	push   $0x0
  pushl $120
8010707e:	6a 78                	push   $0x78
  jmp alltraps
80107080:	e9 7c f5 ff ff       	jmp    80106601 <alltraps>

80107085 <vector121>:
.globl vector121
vector121:
  pushl $0
80107085:	6a 00                	push   $0x0
  pushl $121
80107087:	6a 79                	push   $0x79
  jmp alltraps
80107089:	e9 73 f5 ff ff       	jmp    80106601 <alltraps>

8010708e <vector122>:
.globl vector122
vector122:
  pushl $0
8010708e:	6a 00                	push   $0x0
  pushl $122
80107090:	6a 7a                	push   $0x7a
  jmp alltraps
80107092:	e9 6a f5 ff ff       	jmp    80106601 <alltraps>

80107097 <vector123>:
.globl vector123
vector123:
  pushl $0
80107097:	6a 00                	push   $0x0
  pushl $123
80107099:	6a 7b                	push   $0x7b
  jmp alltraps
8010709b:	e9 61 f5 ff ff       	jmp    80106601 <alltraps>

801070a0 <vector124>:
.globl vector124
vector124:
  pushl $0
801070a0:	6a 00                	push   $0x0
  pushl $124
801070a2:	6a 7c                	push   $0x7c
  jmp alltraps
801070a4:	e9 58 f5 ff ff       	jmp    80106601 <alltraps>

801070a9 <vector125>:
.globl vector125
vector125:
  pushl $0
801070a9:	6a 00                	push   $0x0
  pushl $125
801070ab:	6a 7d                	push   $0x7d
  jmp alltraps
801070ad:	e9 4f f5 ff ff       	jmp    80106601 <alltraps>

801070b2 <vector126>:
.globl vector126
vector126:
  pushl $0
801070b2:	6a 00                	push   $0x0
  pushl $126
801070b4:	6a 7e                	push   $0x7e
  jmp alltraps
801070b6:	e9 46 f5 ff ff       	jmp    80106601 <alltraps>

801070bb <vector127>:
.globl vector127
vector127:
  pushl $0
801070bb:	6a 00                	push   $0x0
  pushl $127
801070bd:	6a 7f                	push   $0x7f
  jmp alltraps
801070bf:	e9 3d f5 ff ff       	jmp    80106601 <alltraps>

801070c4 <vector128>:
.globl vector128
vector128:
  pushl $0
801070c4:	6a 00                	push   $0x0
  pushl $128
801070c6:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801070cb:	e9 31 f5 ff ff       	jmp    80106601 <alltraps>

801070d0 <vector129>:
.globl vector129
vector129:
  pushl $0
801070d0:	6a 00                	push   $0x0
  pushl $129
801070d2:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801070d7:	e9 25 f5 ff ff       	jmp    80106601 <alltraps>

801070dc <vector130>:
.globl vector130
vector130:
  pushl $0
801070dc:	6a 00                	push   $0x0
  pushl $130
801070de:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801070e3:	e9 19 f5 ff ff       	jmp    80106601 <alltraps>

801070e8 <vector131>:
.globl vector131
vector131:
  pushl $0
801070e8:	6a 00                	push   $0x0
  pushl $131
801070ea:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801070ef:	e9 0d f5 ff ff       	jmp    80106601 <alltraps>

801070f4 <vector132>:
.globl vector132
vector132:
  pushl $0
801070f4:	6a 00                	push   $0x0
  pushl $132
801070f6:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801070fb:	e9 01 f5 ff ff       	jmp    80106601 <alltraps>

80107100 <vector133>:
.globl vector133
vector133:
  pushl $0
80107100:	6a 00                	push   $0x0
  pushl $133
80107102:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107107:	e9 f5 f4 ff ff       	jmp    80106601 <alltraps>

8010710c <vector134>:
.globl vector134
vector134:
  pushl $0
8010710c:	6a 00                	push   $0x0
  pushl $134
8010710e:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107113:	e9 e9 f4 ff ff       	jmp    80106601 <alltraps>

80107118 <vector135>:
.globl vector135
vector135:
  pushl $0
80107118:	6a 00                	push   $0x0
  pushl $135
8010711a:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010711f:	e9 dd f4 ff ff       	jmp    80106601 <alltraps>

80107124 <vector136>:
.globl vector136
vector136:
  pushl $0
80107124:	6a 00                	push   $0x0
  pushl $136
80107126:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010712b:	e9 d1 f4 ff ff       	jmp    80106601 <alltraps>

80107130 <vector137>:
.globl vector137
vector137:
  pushl $0
80107130:	6a 00                	push   $0x0
  pushl $137
80107132:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107137:	e9 c5 f4 ff ff       	jmp    80106601 <alltraps>

8010713c <vector138>:
.globl vector138
vector138:
  pushl $0
8010713c:	6a 00                	push   $0x0
  pushl $138
8010713e:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107143:	e9 b9 f4 ff ff       	jmp    80106601 <alltraps>

80107148 <vector139>:
.globl vector139
vector139:
  pushl $0
80107148:	6a 00                	push   $0x0
  pushl $139
8010714a:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010714f:	e9 ad f4 ff ff       	jmp    80106601 <alltraps>

80107154 <vector140>:
.globl vector140
vector140:
  pushl $0
80107154:	6a 00                	push   $0x0
  pushl $140
80107156:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010715b:	e9 a1 f4 ff ff       	jmp    80106601 <alltraps>

80107160 <vector141>:
.globl vector141
vector141:
  pushl $0
80107160:	6a 00                	push   $0x0
  pushl $141
80107162:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107167:	e9 95 f4 ff ff       	jmp    80106601 <alltraps>

8010716c <vector142>:
.globl vector142
vector142:
  pushl $0
8010716c:	6a 00                	push   $0x0
  pushl $142
8010716e:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107173:	e9 89 f4 ff ff       	jmp    80106601 <alltraps>

80107178 <vector143>:
.globl vector143
vector143:
  pushl $0
80107178:	6a 00                	push   $0x0
  pushl $143
8010717a:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010717f:	e9 7d f4 ff ff       	jmp    80106601 <alltraps>

80107184 <vector144>:
.globl vector144
vector144:
  pushl $0
80107184:	6a 00                	push   $0x0
  pushl $144
80107186:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010718b:	e9 71 f4 ff ff       	jmp    80106601 <alltraps>

80107190 <vector145>:
.globl vector145
vector145:
  pushl $0
80107190:	6a 00                	push   $0x0
  pushl $145
80107192:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107197:	e9 65 f4 ff ff       	jmp    80106601 <alltraps>

8010719c <vector146>:
.globl vector146
vector146:
  pushl $0
8010719c:	6a 00                	push   $0x0
  pushl $146
8010719e:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801071a3:	e9 59 f4 ff ff       	jmp    80106601 <alltraps>

801071a8 <vector147>:
.globl vector147
vector147:
  pushl $0
801071a8:	6a 00                	push   $0x0
  pushl $147
801071aa:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801071af:	e9 4d f4 ff ff       	jmp    80106601 <alltraps>

801071b4 <vector148>:
.globl vector148
vector148:
  pushl $0
801071b4:	6a 00                	push   $0x0
  pushl $148
801071b6:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801071bb:	e9 41 f4 ff ff       	jmp    80106601 <alltraps>

801071c0 <vector149>:
.globl vector149
vector149:
  pushl $0
801071c0:	6a 00                	push   $0x0
  pushl $149
801071c2:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801071c7:	e9 35 f4 ff ff       	jmp    80106601 <alltraps>

801071cc <vector150>:
.globl vector150
vector150:
  pushl $0
801071cc:	6a 00                	push   $0x0
  pushl $150
801071ce:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801071d3:	e9 29 f4 ff ff       	jmp    80106601 <alltraps>

801071d8 <vector151>:
.globl vector151
vector151:
  pushl $0
801071d8:	6a 00                	push   $0x0
  pushl $151
801071da:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801071df:	e9 1d f4 ff ff       	jmp    80106601 <alltraps>

801071e4 <vector152>:
.globl vector152
vector152:
  pushl $0
801071e4:	6a 00                	push   $0x0
  pushl $152
801071e6:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801071eb:	e9 11 f4 ff ff       	jmp    80106601 <alltraps>

801071f0 <vector153>:
.globl vector153
vector153:
  pushl $0
801071f0:	6a 00                	push   $0x0
  pushl $153
801071f2:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801071f7:	e9 05 f4 ff ff       	jmp    80106601 <alltraps>

801071fc <vector154>:
.globl vector154
vector154:
  pushl $0
801071fc:	6a 00                	push   $0x0
  pushl $154
801071fe:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107203:	e9 f9 f3 ff ff       	jmp    80106601 <alltraps>

80107208 <vector155>:
.globl vector155
vector155:
  pushl $0
80107208:	6a 00                	push   $0x0
  pushl $155
8010720a:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010720f:	e9 ed f3 ff ff       	jmp    80106601 <alltraps>

80107214 <vector156>:
.globl vector156
vector156:
  pushl $0
80107214:	6a 00                	push   $0x0
  pushl $156
80107216:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010721b:	e9 e1 f3 ff ff       	jmp    80106601 <alltraps>

80107220 <vector157>:
.globl vector157
vector157:
  pushl $0
80107220:	6a 00                	push   $0x0
  pushl $157
80107222:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107227:	e9 d5 f3 ff ff       	jmp    80106601 <alltraps>

8010722c <vector158>:
.globl vector158
vector158:
  pushl $0
8010722c:	6a 00                	push   $0x0
  pushl $158
8010722e:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107233:	e9 c9 f3 ff ff       	jmp    80106601 <alltraps>

80107238 <vector159>:
.globl vector159
vector159:
  pushl $0
80107238:	6a 00                	push   $0x0
  pushl $159
8010723a:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010723f:	e9 bd f3 ff ff       	jmp    80106601 <alltraps>

80107244 <vector160>:
.globl vector160
vector160:
  pushl $0
80107244:	6a 00                	push   $0x0
  pushl $160
80107246:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010724b:	e9 b1 f3 ff ff       	jmp    80106601 <alltraps>

80107250 <vector161>:
.globl vector161
vector161:
  pushl $0
80107250:	6a 00                	push   $0x0
  pushl $161
80107252:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107257:	e9 a5 f3 ff ff       	jmp    80106601 <alltraps>

8010725c <vector162>:
.globl vector162
vector162:
  pushl $0
8010725c:	6a 00                	push   $0x0
  pushl $162
8010725e:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107263:	e9 99 f3 ff ff       	jmp    80106601 <alltraps>

80107268 <vector163>:
.globl vector163
vector163:
  pushl $0
80107268:	6a 00                	push   $0x0
  pushl $163
8010726a:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010726f:	e9 8d f3 ff ff       	jmp    80106601 <alltraps>

80107274 <vector164>:
.globl vector164
vector164:
  pushl $0
80107274:	6a 00                	push   $0x0
  pushl $164
80107276:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010727b:	e9 81 f3 ff ff       	jmp    80106601 <alltraps>

80107280 <vector165>:
.globl vector165
vector165:
  pushl $0
80107280:	6a 00                	push   $0x0
  pushl $165
80107282:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107287:	e9 75 f3 ff ff       	jmp    80106601 <alltraps>

8010728c <vector166>:
.globl vector166
vector166:
  pushl $0
8010728c:	6a 00                	push   $0x0
  pushl $166
8010728e:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107293:	e9 69 f3 ff ff       	jmp    80106601 <alltraps>

80107298 <vector167>:
.globl vector167
vector167:
  pushl $0
80107298:	6a 00                	push   $0x0
  pushl $167
8010729a:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010729f:	e9 5d f3 ff ff       	jmp    80106601 <alltraps>

801072a4 <vector168>:
.globl vector168
vector168:
  pushl $0
801072a4:	6a 00                	push   $0x0
  pushl $168
801072a6:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801072ab:	e9 51 f3 ff ff       	jmp    80106601 <alltraps>

801072b0 <vector169>:
.globl vector169
vector169:
  pushl $0
801072b0:	6a 00                	push   $0x0
  pushl $169
801072b2:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801072b7:	e9 45 f3 ff ff       	jmp    80106601 <alltraps>

801072bc <vector170>:
.globl vector170
vector170:
  pushl $0
801072bc:	6a 00                	push   $0x0
  pushl $170
801072be:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801072c3:	e9 39 f3 ff ff       	jmp    80106601 <alltraps>

801072c8 <vector171>:
.globl vector171
vector171:
  pushl $0
801072c8:	6a 00                	push   $0x0
  pushl $171
801072ca:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801072cf:	e9 2d f3 ff ff       	jmp    80106601 <alltraps>

801072d4 <vector172>:
.globl vector172
vector172:
  pushl $0
801072d4:	6a 00                	push   $0x0
  pushl $172
801072d6:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801072db:	e9 21 f3 ff ff       	jmp    80106601 <alltraps>

801072e0 <vector173>:
.globl vector173
vector173:
  pushl $0
801072e0:	6a 00                	push   $0x0
  pushl $173
801072e2:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801072e7:	e9 15 f3 ff ff       	jmp    80106601 <alltraps>

801072ec <vector174>:
.globl vector174
vector174:
  pushl $0
801072ec:	6a 00                	push   $0x0
  pushl $174
801072ee:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801072f3:	e9 09 f3 ff ff       	jmp    80106601 <alltraps>

801072f8 <vector175>:
.globl vector175
vector175:
  pushl $0
801072f8:	6a 00                	push   $0x0
  pushl $175
801072fa:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801072ff:	e9 fd f2 ff ff       	jmp    80106601 <alltraps>

80107304 <vector176>:
.globl vector176
vector176:
  pushl $0
80107304:	6a 00                	push   $0x0
  pushl $176
80107306:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010730b:	e9 f1 f2 ff ff       	jmp    80106601 <alltraps>

80107310 <vector177>:
.globl vector177
vector177:
  pushl $0
80107310:	6a 00                	push   $0x0
  pushl $177
80107312:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107317:	e9 e5 f2 ff ff       	jmp    80106601 <alltraps>

8010731c <vector178>:
.globl vector178
vector178:
  pushl $0
8010731c:	6a 00                	push   $0x0
  pushl $178
8010731e:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107323:	e9 d9 f2 ff ff       	jmp    80106601 <alltraps>

80107328 <vector179>:
.globl vector179
vector179:
  pushl $0
80107328:	6a 00                	push   $0x0
  pushl $179
8010732a:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010732f:	e9 cd f2 ff ff       	jmp    80106601 <alltraps>

80107334 <vector180>:
.globl vector180
vector180:
  pushl $0
80107334:	6a 00                	push   $0x0
  pushl $180
80107336:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010733b:	e9 c1 f2 ff ff       	jmp    80106601 <alltraps>

80107340 <vector181>:
.globl vector181
vector181:
  pushl $0
80107340:	6a 00                	push   $0x0
  pushl $181
80107342:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107347:	e9 b5 f2 ff ff       	jmp    80106601 <alltraps>

8010734c <vector182>:
.globl vector182
vector182:
  pushl $0
8010734c:	6a 00                	push   $0x0
  pushl $182
8010734e:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107353:	e9 a9 f2 ff ff       	jmp    80106601 <alltraps>

80107358 <vector183>:
.globl vector183
vector183:
  pushl $0
80107358:	6a 00                	push   $0x0
  pushl $183
8010735a:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010735f:	e9 9d f2 ff ff       	jmp    80106601 <alltraps>

80107364 <vector184>:
.globl vector184
vector184:
  pushl $0
80107364:	6a 00                	push   $0x0
  pushl $184
80107366:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010736b:	e9 91 f2 ff ff       	jmp    80106601 <alltraps>

80107370 <vector185>:
.globl vector185
vector185:
  pushl $0
80107370:	6a 00                	push   $0x0
  pushl $185
80107372:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107377:	e9 85 f2 ff ff       	jmp    80106601 <alltraps>

8010737c <vector186>:
.globl vector186
vector186:
  pushl $0
8010737c:	6a 00                	push   $0x0
  pushl $186
8010737e:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107383:	e9 79 f2 ff ff       	jmp    80106601 <alltraps>

80107388 <vector187>:
.globl vector187
vector187:
  pushl $0
80107388:	6a 00                	push   $0x0
  pushl $187
8010738a:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010738f:	e9 6d f2 ff ff       	jmp    80106601 <alltraps>

80107394 <vector188>:
.globl vector188
vector188:
  pushl $0
80107394:	6a 00                	push   $0x0
  pushl $188
80107396:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010739b:	e9 61 f2 ff ff       	jmp    80106601 <alltraps>

801073a0 <vector189>:
.globl vector189
vector189:
  pushl $0
801073a0:	6a 00                	push   $0x0
  pushl $189
801073a2:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801073a7:	e9 55 f2 ff ff       	jmp    80106601 <alltraps>

801073ac <vector190>:
.globl vector190
vector190:
  pushl $0
801073ac:	6a 00                	push   $0x0
  pushl $190
801073ae:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801073b3:	e9 49 f2 ff ff       	jmp    80106601 <alltraps>

801073b8 <vector191>:
.globl vector191
vector191:
  pushl $0
801073b8:	6a 00                	push   $0x0
  pushl $191
801073ba:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801073bf:	e9 3d f2 ff ff       	jmp    80106601 <alltraps>

801073c4 <vector192>:
.globl vector192
vector192:
  pushl $0
801073c4:	6a 00                	push   $0x0
  pushl $192
801073c6:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801073cb:	e9 31 f2 ff ff       	jmp    80106601 <alltraps>

801073d0 <vector193>:
.globl vector193
vector193:
  pushl $0
801073d0:	6a 00                	push   $0x0
  pushl $193
801073d2:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801073d7:	e9 25 f2 ff ff       	jmp    80106601 <alltraps>

801073dc <vector194>:
.globl vector194
vector194:
  pushl $0
801073dc:	6a 00                	push   $0x0
  pushl $194
801073de:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801073e3:	e9 19 f2 ff ff       	jmp    80106601 <alltraps>

801073e8 <vector195>:
.globl vector195
vector195:
  pushl $0
801073e8:	6a 00                	push   $0x0
  pushl $195
801073ea:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801073ef:	e9 0d f2 ff ff       	jmp    80106601 <alltraps>

801073f4 <vector196>:
.globl vector196
vector196:
  pushl $0
801073f4:	6a 00                	push   $0x0
  pushl $196
801073f6:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801073fb:	e9 01 f2 ff ff       	jmp    80106601 <alltraps>

80107400 <vector197>:
.globl vector197
vector197:
  pushl $0
80107400:	6a 00                	push   $0x0
  pushl $197
80107402:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107407:	e9 f5 f1 ff ff       	jmp    80106601 <alltraps>

8010740c <vector198>:
.globl vector198
vector198:
  pushl $0
8010740c:	6a 00                	push   $0x0
  pushl $198
8010740e:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107413:	e9 e9 f1 ff ff       	jmp    80106601 <alltraps>

80107418 <vector199>:
.globl vector199
vector199:
  pushl $0
80107418:	6a 00                	push   $0x0
  pushl $199
8010741a:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010741f:	e9 dd f1 ff ff       	jmp    80106601 <alltraps>

80107424 <vector200>:
.globl vector200
vector200:
  pushl $0
80107424:	6a 00                	push   $0x0
  pushl $200
80107426:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010742b:	e9 d1 f1 ff ff       	jmp    80106601 <alltraps>

80107430 <vector201>:
.globl vector201
vector201:
  pushl $0
80107430:	6a 00                	push   $0x0
  pushl $201
80107432:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107437:	e9 c5 f1 ff ff       	jmp    80106601 <alltraps>

8010743c <vector202>:
.globl vector202
vector202:
  pushl $0
8010743c:	6a 00                	push   $0x0
  pushl $202
8010743e:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107443:	e9 b9 f1 ff ff       	jmp    80106601 <alltraps>

80107448 <vector203>:
.globl vector203
vector203:
  pushl $0
80107448:	6a 00                	push   $0x0
  pushl $203
8010744a:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010744f:	e9 ad f1 ff ff       	jmp    80106601 <alltraps>

80107454 <vector204>:
.globl vector204
vector204:
  pushl $0
80107454:	6a 00                	push   $0x0
  pushl $204
80107456:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010745b:	e9 a1 f1 ff ff       	jmp    80106601 <alltraps>

80107460 <vector205>:
.globl vector205
vector205:
  pushl $0
80107460:	6a 00                	push   $0x0
  pushl $205
80107462:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107467:	e9 95 f1 ff ff       	jmp    80106601 <alltraps>

8010746c <vector206>:
.globl vector206
vector206:
  pushl $0
8010746c:	6a 00                	push   $0x0
  pushl $206
8010746e:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107473:	e9 89 f1 ff ff       	jmp    80106601 <alltraps>

80107478 <vector207>:
.globl vector207
vector207:
  pushl $0
80107478:	6a 00                	push   $0x0
  pushl $207
8010747a:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010747f:	e9 7d f1 ff ff       	jmp    80106601 <alltraps>

80107484 <vector208>:
.globl vector208
vector208:
  pushl $0
80107484:	6a 00                	push   $0x0
  pushl $208
80107486:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010748b:	e9 71 f1 ff ff       	jmp    80106601 <alltraps>

80107490 <vector209>:
.globl vector209
vector209:
  pushl $0
80107490:	6a 00                	push   $0x0
  pushl $209
80107492:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107497:	e9 65 f1 ff ff       	jmp    80106601 <alltraps>

8010749c <vector210>:
.globl vector210
vector210:
  pushl $0
8010749c:	6a 00                	push   $0x0
  pushl $210
8010749e:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801074a3:	e9 59 f1 ff ff       	jmp    80106601 <alltraps>

801074a8 <vector211>:
.globl vector211
vector211:
  pushl $0
801074a8:	6a 00                	push   $0x0
  pushl $211
801074aa:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801074af:	e9 4d f1 ff ff       	jmp    80106601 <alltraps>

801074b4 <vector212>:
.globl vector212
vector212:
  pushl $0
801074b4:	6a 00                	push   $0x0
  pushl $212
801074b6:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801074bb:	e9 41 f1 ff ff       	jmp    80106601 <alltraps>

801074c0 <vector213>:
.globl vector213
vector213:
  pushl $0
801074c0:	6a 00                	push   $0x0
  pushl $213
801074c2:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801074c7:	e9 35 f1 ff ff       	jmp    80106601 <alltraps>

801074cc <vector214>:
.globl vector214
vector214:
  pushl $0
801074cc:	6a 00                	push   $0x0
  pushl $214
801074ce:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801074d3:	e9 29 f1 ff ff       	jmp    80106601 <alltraps>

801074d8 <vector215>:
.globl vector215
vector215:
  pushl $0
801074d8:	6a 00                	push   $0x0
  pushl $215
801074da:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801074df:	e9 1d f1 ff ff       	jmp    80106601 <alltraps>

801074e4 <vector216>:
.globl vector216
vector216:
  pushl $0
801074e4:	6a 00                	push   $0x0
  pushl $216
801074e6:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801074eb:	e9 11 f1 ff ff       	jmp    80106601 <alltraps>

801074f0 <vector217>:
.globl vector217
vector217:
  pushl $0
801074f0:	6a 00                	push   $0x0
  pushl $217
801074f2:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801074f7:	e9 05 f1 ff ff       	jmp    80106601 <alltraps>

801074fc <vector218>:
.globl vector218
vector218:
  pushl $0
801074fc:	6a 00                	push   $0x0
  pushl $218
801074fe:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107503:	e9 f9 f0 ff ff       	jmp    80106601 <alltraps>

80107508 <vector219>:
.globl vector219
vector219:
  pushl $0
80107508:	6a 00                	push   $0x0
  pushl $219
8010750a:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010750f:	e9 ed f0 ff ff       	jmp    80106601 <alltraps>

80107514 <vector220>:
.globl vector220
vector220:
  pushl $0
80107514:	6a 00                	push   $0x0
  pushl $220
80107516:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010751b:	e9 e1 f0 ff ff       	jmp    80106601 <alltraps>

80107520 <vector221>:
.globl vector221
vector221:
  pushl $0
80107520:	6a 00                	push   $0x0
  pushl $221
80107522:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107527:	e9 d5 f0 ff ff       	jmp    80106601 <alltraps>

8010752c <vector222>:
.globl vector222
vector222:
  pushl $0
8010752c:	6a 00                	push   $0x0
  pushl $222
8010752e:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107533:	e9 c9 f0 ff ff       	jmp    80106601 <alltraps>

80107538 <vector223>:
.globl vector223
vector223:
  pushl $0
80107538:	6a 00                	push   $0x0
  pushl $223
8010753a:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010753f:	e9 bd f0 ff ff       	jmp    80106601 <alltraps>

80107544 <vector224>:
.globl vector224
vector224:
  pushl $0
80107544:	6a 00                	push   $0x0
  pushl $224
80107546:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010754b:	e9 b1 f0 ff ff       	jmp    80106601 <alltraps>

80107550 <vector225>:
.globl vector225
vector225:
  pushl $0
80107550:	6a 00                	push   $0x0
  pushl $225
80107552:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107557:	e9 a5 f0 ff ff       	jmp    80106601 <alltraps>

8010755c <vector226>:
.globl vector226
vector226:
  pushl $0
8010755c:	6a 00                	push   $0x0
  pushl $226
8010755e:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107563:	e9 99 f0 ff ff       	jmp    80106601 <alltraps>

80107568 <vector227>:
.globl vector227
vector227:
  pushl $0
80107568:	6a 00                	push   $0x0
  pushl $227
8010756a:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010756f:	e9 8d f0 ff ff       	jmp    80106601 <alltraps>

80107574 <vector228>:
.globl vector228
vector228:
  pushl $0
80107574:	6a 00                	push   $0x0
  pushl $228
80107576:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010757b:	e9 81 f0 ff ff       	jmp    80106601 <alltraps>

80107580 <vector229>:
.globl vector229
vector229:
  pushl $0
80107580:	6a 00                	push   $0x0
  pushl $229
80107582:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107587:	e9 75 f0 ff ff       	jmp    80106601 <alltraps>

8010758c <vector230>:
.globl vector230
vector230:
  pushl $0
8010758c:	6a 00                	push   $0x0
  pushl $230
8010758e:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107593:	e9 69 f0 ff ff       	jmp    80106601 <alltraps>

80107598 <vector231>:
.globl vector231
vector231:
  pushl $0
80107598:	6a 00                	push   $0x0
  pushl $231
8010759a:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010759f:	e9 5d f0 ff ff       	jmp    80106601 <alltraps>

801075a4 <vector232>:
.globl vector232
vector232:
  pushl $0
801075a4:	6a 00                	push   $0x0
  pushl $232
801075a6:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801075ab:	e9 51 f0 ff ff       	jmp    80106601 <alltraps>

801075b0 <vector233>:
.globl vector233
vector233:
  pushl $0
801075b0:	6a 00                	push   $0x0
  pushl $233
801075b2:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801075b7:	e9 45 f0 ff ff       	jmp    80106601 <alltraps>

801075bc <vector234>:
.globl vector234
vector234:
  pushl $0
801075bc:	6a 00                	push   $0x0
  pushl $234
801075be:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801075c3:	e9 39 f0 ff ff       	jmp    80106601 <alltraps>

801075c8 <vector235>:
.globl vector235
vector235:
  pushl $0
801075c8:	6a 00                	push   $0x0
  pushl $235
801075ca:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801075cf:	e9 2d f0 ff ff       	jmp    80106601 <alltraps>

801075d4 <vector236>:
.globl vector236
vector236:
  pushl $0
801075d4:	6a 00                	push   $0x0
  pushl $236
801075d6:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801075db:	e9 21 f0 ff ff       	jmp    80106601 <alltraps>

801075e0 <vector237>:
.globl vector237
vector237:
  pushl $0
801075e0:	6a 00                	push   $0x0
  pushl $237
801075e2:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801075e7:	e9 15 f0 ff ff       	jmp    80106601 <alltraps>

801075ec <vector238>:
.globl vector238
vector238:
  pushl $0
801075ec:	6a 00                	push   $0x0
  pushl $238
801075ee:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801075f3:	e9 09 f0 ff ff       	jmp    80106601 <alltraps>

801075f8 <vector239>:
.globl vector239
vector239:
  pushl $0
801075f8:	6a 00                	push   $0x0
  pushl $239
801075fa:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801075ff:	e9 fd ef ff ff       	jmp    80106601 <alltraps>

80107604 <vector240>:
.globl vector240
vector240:
  pushl $0
80107604:	6a 00                	push   $0x0
  pushl $240
80107606:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010760b:	e9 f1 ef ff ff       	jmp    80106601 <alltraps>

80107610 <vector241>:
.globl vector241
vector241:
  pushl $0
80107610:	6a 00                	push   $0x0
  pushl $241
80107612:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107617:	e9 e5 ef ff ff       	jmp    80106601 <alltraps>

8010761c <vector242>:
.globl vector242
vector242:
  pushl $0
8010761c:	6a 00                	push   $0x0
  pushl $242
8010761e:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107623:	e9 d9 ef ff ff       	jmp    80106601 <alltraps>

80107628 <vector243>:
.globl vector243
vector243:
  pushl $0
80107628:	6a 00                	push   $0x0
  pushl $243
8010762a:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010762f:	e9 cd ef ff ff       	jmp    80106601 <alltraps>

80107634 <vector244>:
.globl vector244
vector244:
  pushl $0
80107634:	6a 00                	push   $0x0
  pushl $244
80107636:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010763b:	e9 c1 ef ff ff       	jmp    80106601 <alltraps>

80107640 <vector245>:
.globl vector245
vector245:
  pushl $0
80107640:	6a 00                	push   $0x0
  pushl $245
80107642:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107647:	e9 b5 ef ff ff       	jmp    80106601 <alltraps>

8010764c <vector246>:
.globl vector246
vector246:
  pushl $0
8010764c:	6a 00                	push   $0x0
  pushl $246
8010764e:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107653:	e9 a9 ef ff ff       	jmp    80106601 <alltraps>

80107658 <vector247>:
.globl vector247
vector247:
  pushl $0
80107658:	6a 00                	push   $0x0
  pushl $247
8010765a:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010765f:	e9 9d ef ff ff       	jmp    80106601 <alltraps>

80107664 <vector248>:
.globl vector248
vector248:
  pushl $0
80107664:	6a 00                	push   $0x0
  pushl $248
80107666:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010766b:	e9 91 ef ff ff       	jmp    80106601 <alltraps>

80107670 <vector249>:
.globl vector249
vector249:
  pushl $0
80107670:	6a 00                	push   $0x0
  pushl $249
80107672:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107677:	e9 85 ef ff ff       	jmp    80106601 <alltraps>

8010767c <vector250>:
.globl vector250
vector250:
  pushl $0
8010767c:	6a 00                	push   $0x0
  pushl $250
8010767e:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107683:	e9 79 ef ff ff       	jmp    80106601 <alltraps>

80107688 <vector251>:
.globl vector251
vector251:
  pushl $0
80107688:	6a 00                	push   $0x0
  pushl $251
8010768a:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010768f:	e9 6d ef ff ff       	jmp    80106601 <alltraps>

80107694 <vector252>:
.globl vector252
vector252:
  pushl $0
80107694:	6a 00                	push   $0x0
  pushl $252
80107696:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010769b:	e9 61 ef ff ff       	jmp    80106601 <alltraps>

801076a0 <vector253>:
.globl vector253
vector253:
  pushl $0
801076a0:	6a 00                	push   $0x0
  pushl $253
801076a2:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801076a7:	e9 55 ef ff ff       	jmp    80106601 <alltraps>

801076ac <vector254>:
.globl vector254
vector254:
  pushl $0
801076ac:	6a 00                	push   $0x0
  pushl $254
801076ae:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801076b3:	e9 49 ef ff ff       	jmp    80106601 <alltraps>

801076b8 <vector255>:
.globl vector255
vector255:
  pushl $0
801076b8:	6a 00                	push   $0x0
  pushl $255
801076ba:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801076bf:	e9 3d ef ff ff       	jmp    80106601 <alltraps>

801076c4 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801076c4:	55                   	push   %ebp
801076c5:	89 e5                	mov    %esp,%ebp
801076c7:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801076ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801076cd:	83 e8 01             	sub    $0x1,%eax
801076d0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801076d4:	8b 45 08             	mov    0x8(%ebp),%eax
801076d7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801076db:	8b 45 08             	mov    0x8(%ebp),%eax
801076de:	c1 e8 10             	shr    $0x10,%eax
801076e1:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801076e5:	8d 45 fa             	lea    -0x6(%ebp),%eax
801076e8:	0f 01 10             	lgdtl  (%eax)
}
801076eb:	90                   	nop
801076ec:	c9                   	leave  
801076ed:	c3                   	ret    

801076ee <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801076ee:	55                   	push   %ebp
801076ef:	89 e5                	mov    %esp,%ebp
801076f1:	83 ec 04             	sub    $0x4,%esp
801076f4:	8b 45 08             	mov    0x8(%ebp),%eax
801076f7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801076fb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801076ff:	0f 00 d8             	ltr    %ax
}
80107702:	90                   	nop
80107703:	c9                   	leave  
80107704:	c3                   	ret    

80107705 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107705:	55                   	push   %ebp
80107706:	89 e5                	mov    %esp,%ebp
80107708:	83 ec 04             	sub    $0x4,%esp
8010770b:	8b 45 08             	mov    0x8(%ebp),%eax
8010770e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107712:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107716:	8e e8                	mov    %eax,%gs
}
80107718:	90                   	nop
80107719:	c9                   	leave  
8010771a:	c3                   	ret    

8010771b <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010771b:	55                   	push   %ebp
8010771c:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010771e:	8b 45 08             	mov    0x8(%ebp),%eax
80107721:	0f 22 d8             	mov    %eax,%cr3
}
80107724:	90                   	nop
80107725:	5d                   	pop    %ebp
80107726:	c3                   	ret    

80107727 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107727:	55                   	push   %ebp
80107728:	89 e5                	mov    %esp,%ebp
8010772a:	8b 45 08             	mov    0x8(%ebp),%eax
8010772d:	05 00 00 00 80       	add    $0x80000000,%eax
80107732:	5d                   	pop    %ebp
80107733:	c3                   	ret    

80107734 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107734:	55                   	push   %ebp
80107735:	89 e5                	mov    %esp,%ebp
80107737:	8b 45 08             	mov    0x8(%ebp),%eax
8010773a:	05 00 00 00 80       	add    $0x80000000,%eax
8010773f:	5d                   	pop    %ebp
80107740:	c3                   	ret    

80107741 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107741:	55                   	push   %ebp
80107742:	89 e5                	mov    %esp,%ebp
80107744:	53                   	push   %ebx
80107745:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107748:	e8 64 b8 ff ff       	call   80102fb1 <cpunum>
8010774d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107753:	05 80 23 11 80       	add    $0x80112380,%eax
80107758:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010775b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775e:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107767:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010776d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107770:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107777:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010777b:	83 e2 f0             	and    $0xfffffff0,%edx
8010777e:	83 ca 0a             	or     $0xa,%edx
80107781:	88 50 7d             	mov    %dl,0x7d(%eax)
80107784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107787:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010778b:	83 ca 10             	or     $0x10,%edx
8010778e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107794:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107798:	83 e2 9f             	and    $0xffffff9f,%edx
8010779b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010779e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801077a5:	83 ca 80             	or     $0xffffff80,%edx
801077a8:	88 50 7d             	mov    %dl,0x7d(%eax)
801077ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ae:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077b2:	83 ca 0f             	or     $0xf,%edx
801077b5:	88 50 7e             	mov    %dl,0x7e(%eax)
801077b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077bb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077bf:	83 e2 ef             	and    $0xffffffef,%edx
801077c2:	88 50 7e             	mov    %dl,0x7e(%eax)
801077c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077cc:	83 e2 df             	and    $0xffffffdf,%edx
801077cf:	88 50 7e             	mov    %dl,0x7e(%eax)
801077d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077d9:	83 ca 40             	or     $0x40,%edx
801077dc:	88 50 7e             	mov    %dl,0x7e(%eax)
801077df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077e6:	83 ca 80             	or     $0xffffff80,%edx
801077e9:	88 50 7e             	mov    %dl,0x7e(%eax)
801077ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ef:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801077f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f6:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801077fd:	ff ff 
801077ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107802:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107809:	00 00 
8010780b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780e:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107818:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010781f:	83 e2 f0             	and    $0xfffffff0,%edx
80107822:	83 ca 02             	or     $0x2,%edx
80107825:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010782b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107835:	83 ca 10             	or     $0x10,%edx
80107838:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010783e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107841:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107848:	83 e2 9f             	and    $0xffffff9f,%edx
8010784b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107851:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107854:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010785b:	83 ca 80             	or     $0xffffff80,%edx
8010785e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107864:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107867:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010786e:	83 ca 0f             	or     $0xf,%edx
80107871:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107881:	83 e2 ef             	and    $0xffffffef,%edx
80107884:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010788a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107894:	83 e2 df             	and    $0xffffffdf,%edx
80107897:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010789d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078a7:	83 ca 40             	or     $0x40,%edx
801078aa:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078ba:	83 ca 80             	or     $0xffffff80,%edx
801078bd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c6:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801078cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d0:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801078d7:	ff ff 
801078d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078dc:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801078e3:	00 00 
801078e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e8:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801078ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801078f9:	83 e2 f0             	and    $0xfffffff0,%edx
801078fc:	83 ca 0a             	or     $0xa,%edx
801078ff:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107908:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010790f:	83 ca 10             	or     $0x10,%edx
80107912:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107922:	83 ca 60             	or     $0x60,%edx
80107925:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010792b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107935:	83 ca 80             	or     $0xffffff80,%edx
80107938:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010793e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107941:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107948:	83 ca 0f             	or     $0xf,%edx
8010794b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107951:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107954:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010795b:	83 e2 ef             	and    $0xffffffef,%edx
8010795e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107964:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107967:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010796e:	83 e2 df             	and    $0xffffffdf,%edx
80107971:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107981:	83 ca 40             	or     $0x40,%edx
80107984:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010798a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107994:	83 ca 80             	or     $0xffffff80,%edx
80107997:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010799d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a0:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801079a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079aa:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801079b1:	ff ff 
801079b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b6:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801079bd:	00 00 
801079bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c2:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801079c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cc:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801079d3:	83 e2 f0             	and    $0xfffffff0,%edx
801079d6:	83 ca 02             	or     $0x2,%edx
801079d9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801079df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e2:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801079e9:	83 ca 10             	or     $0x10,%edx
801079ec:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801079f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f5:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801079fc:	83 ca 60             	or     $0x60,%edx
801079ff:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a08:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a0f:	83 ca 80             	or     $0xffffff80,%edx
80107a12:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107a22:	83 ca 0f             	or     $0xf,%edx
80107a25:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107a35:	83 e2 ef             	and    $0xffffffef,%edx
80107a38:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a41:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107a48:	83 e2 df             	and    $0xffffffdf,%edx
80107a4b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a54:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107a5b:	83 ca 40             	or     $0x40,%edx
80107a5e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a67:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107a6e:	83 ca 80             	or     $0xffffff80,%edx
80107a71:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7a:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a84:	05 b4 00 00 00       	add    $0xb4,%eax
80107a89:	89 c3                	mov    %eax,%ebx
80107a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8e:	05 b4 00 00 00       	add    $0xb4,%eax
80107a93:	c1 e8 10             	shr    $0x10,%eax
80107a96:	89 c2                	mov    %eax,%edx
80107a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9b:	05 b4 00 00 00       	add    $0xb4,%eax
80107aa0:	c1 e8 18             	shr    $0x18,%eax
80107aa3:	89 c1                	mov    %eax,%ecx
80107aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa8:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107aaf:	00 00 
80107ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab4:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abe:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac7:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ace:	83 e2 f0             	and    $0xfffffff0,%edx
80107ad1:	83 ca 02             	or     $0x2,%edx
80107ad4:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107add:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ae4:	83 ca 10             	or     $0x10,%edx
80107ae7:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107af7:	83 e2 9f             	and    $0xffffff9f,%edx
80107afa:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b03:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b0a:	83 ca 80             	or     $0xffffff80,%edx
80107b0d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b16:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b1d:	83 e2 f0             	and    $0xfffffff0,%edx
80107b20:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b29:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b30:	83 e2 ef             	and    $0xffffffef,%edx
80107b33:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b43:	83 e2 df             	and    $0xffffffdf,%edx
80107b46:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b56:	83 ca 40             	or     $0x40,%edx
80107b59:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b62:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b69:	83 ca 80             	or     $0xffffff80,%edx
80107b6c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b75:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7e:	83 c0 70             	add    $0x70,%eax
80107b81:	83 ec 08             	sub    $0x8,%esp
80107b84:	6a 38                	push   $0x38
80107b86:	50                   	push   %eax
80107b87:	e8 38 fb ff ff       	call   801076c4 <lgdt>
80107b8c:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80107b8f:	83 ec 0c             	sub    $0xc,%esp
80107b92:	6a 18                	push   $0x18
80107b94:	e8 6c fb ff ff       	call   80107705 <loadgs>
80107b99:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80107b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9f:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107ba5:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107bac:	00 00 00 00 
}
80107bb0:	90                   	nop
80107bb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107bb4:	c9                   	leave  
80107bb5:	c3                   	ret    

80107bb6 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107bb6:	55                   	push   %ebp
80107bb7:	89 e5                	mov    %esp,%ebp
80107bb9:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bbf:	c1 e8 16             	shr    $0x16,%eax
80107bc2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80107bcc:	01 d0                	add    %edx,%eax
80107bce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bd4:	8b 00                	mov    (%eax),%eax
80107bd6:	83 e0 01             	and    $0x1,%eax
80107bd9:	85 c0                	test   %eax,%eax
80107bdb:	74 18                	je     80107bf5 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107be0:	8b 00                	mov    (%eax),%eax
80107be2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107be7:	50                   	push   %eax
80107be8:	e8 47 fb ff ff       	call   80107734 <p2v>
80107bed:	83 c4 04             	add    $0x4,%esp
80107bf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107bf3:	eb 48                	jmp    80107c3d <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107bf5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107bf9:	74 0e                	je     80107c09 <walkpgdir+0x53>
80107bfb:	e8 4b b0 ff ff       	call   80102c4b <kalloc>
80107c00:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c07:	75 07                	jne    80107c10 <walkpgdir+0x5a>
      return 0;
80107c09:	b8 00 00 00 00       	mov    $0x0,%eax
80107c0e:	eb 44                	jmp    80107c54 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107c10:	83 ec 04             	sub    $0x4,%esp
80107c13:	68 00 10 00 00       	push   $0x1000
80107c18:	6a 00                	push   $0x0
80107c1a:	ff 75 f4             	pushl  -0xc(%ebp)
80107c1d:	e8 25 d6 ff ff       	call   80105247 <memset>
80107c22:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107c25:	83 ec 0c             	sub    $0xc,%esp
80107c28:	ff 75 f4             	pushl  -0xc(%ebp)
80107c2b:	e8 f7 fa ff ff       	call   80107727 <v2p>
80107c30:	83 c4 10             	add    $0x10,%esp
80107c33:	83 c8 07             	or     $0x7,%eax
80107c36:	89 c2                	mov    %eax,%edx
80107c38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c3b:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107c3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c40:	c1 e8 0c             	shr    $0xc,%eax
80107c43:	25 ff 03 00 00       	and    $0x3ff,%eax
80107c48:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c52:	01 d0                	add    %edx,%eax
}
80107c54:	c9                   	leave  
80107c55:	c3                   	ret    

80107c56 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107c56:	55                   	push   %ebp
80107c57:	89 e5                	mov    %esp,%ebp
80107c59:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c5f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107c67:	8b 55 0c             	mov    0xc(%ebp),%edx
80107c6a:	8b 45 10             	mov    0x10(%ebp),%eax
80107c6d:	01 d0                	add    %edx,%eax
80107c6f:	83 e8 01             	sub    $0x1,%eax
80107c72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c77:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107c7a:	83 ec 04             	sub    $0x4,%esp
80107c7d:	6a 01                	push   $0x1
80107c7f:	ff 75 f4             	pushl  -0xc(%ebp)
80107c82:	ff 75 08             	pushl  0x8(%ebp)
80107c85:	e8 2c ff ff ff       	call   80107bb6 <walkpgdir>
80107c8a:	83 c4 10             	add    $0x10,%esp
80107c8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c90:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c94:	75 07                	jne    80107c9d <mappages+0x47>
      return -1;
80107c96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c9b:	eb 47                	jmp    80107ce4 <mappages+0x8e>
    if(*pte & PTE_P)
80107c9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ca0:	8b 00                	mov    (%eax),%eax
80107ca2:	83 e0 01             	and    $0x1,%eax
80107ca5:	85 c0                	test   %eax,%eax
80107ca7:	74 0d                	je     80107cb6 <mappages+0x60>
      panic("remap");
80107ca9:	83 ec 0c             	sub    $0xc,%esp
80107cac:	68 fc 8a 10 80       	push   $0x80108afc
80107cb1:	e8 b0 88 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80107cb6:	8b 45 18             	mov    0x18(%ebp),%eax
80107cb9:	0b 45 14             	or     0x14(%ebp),%eax
80107cbc:	83 c8 01             	or     $0x1,%eax
80107cbf:	89 c2                	mov    %eax,%edx
80107cc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cc4:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107ccc:	74 10                	je     80107cde <mappages+0x88>
      break;
    a += PGSIZE;
80107cce:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107cd5:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107cdc:	eb 9c                	jmp    80107c7a <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107cde:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107cdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ce4:	c9                   	leave  
80107ce5:	c3                   	ret    

80107ce6 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107ce6:	55                   	push   %ebp
80107ce7:	89 e5                	mov    %esp,%ebp
80107ce9:	53                   	push   %ebx
80107cea:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107ced:	e8 59 af ff ff       	call   80102c4b <kalloc>
80107cf2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107cf5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107cf9:	75 0a                	jne    80107d05 <setupkvm+0x1f>
    return 0;
80107cfb:	b8 00 00 00 00       	mov    $0x0,%eax
80107d00:	e9 8e 00 00 00       	jmp    80107d93 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80107d05:	83 ec 04             	sub    $0x4,%esp
80107d08:	68 00 10 00 00       	push   $0x1000
80107d0d:	6a 00                	push   $0x0
80107d0f:	ff 75 f0             	pushl  -0x10(%ebp)
80107d12:	e8 30 d5 ff ff       	call   80105247 <memset>
80107d17:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107d1a:	83 ec 0c             	sub    $0xc,%esp
80107d1d:	68 00 00 00 0e       	push   $0xe000000
80107d22:	e8 0d fa ff ff       	call   80107734 <p2v>
80107d27:	83 c4 10             	add    $0x10,%esp
80107d2a:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107d2f:	76 0d                	jbe    80107d3e <setupkvm+0x58>
    panic("PHYSTOP too high");
80107d31:	83 ec 0c             	sub    $0xc,%esp
80107d34:	68 02 8b 10 80       	push   $0x80108b02
80107d39:	e8 28 88 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d3e:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107d45:	eb 40                	jmp    80107d87 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4a:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d50:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d56:	8b 58 08             	mov    0x8(%eax),%ebx
80107d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5c:	8b 40 04             	mov    0x4(%eax),%eax
80107d5f:	29 c3                	sub    %eax,%ebx
80107d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d64:	8b 00                	mov    (%eax),%eax
80107d66:	83 ec 0c             	sub    $0xc,%esp
80107d69:	51                   	push   %ecx
80107d6a:	52                   	push   %edx
80107d6b:	53                   	push   %ebx
80107d6c:	50                   	push   %eax
80107d6d:	ff 75 f0             	pushl  -0x10(%ebp)
80107d70:	e8 e1 fe ff ff       	call   80107c56 <mappages>
80107d75:	83 c4 20             	add    $0x20,%esp
80107d78:	85 c0                	test   %eax,%eax
80107d7a:	79 07                	jns    80107d83 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107d7c:	b8 00 00 00 00       	mov    $0x0,%eax
80107d81:	eb 10                	jmp    80107d93 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d83:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107d87:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107d8e:	72 b7                	jb     80107d47 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107d90:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107d93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107d96:	c9                   	leave  
80107d97:	c3                   	ret    

80107d98 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107d98:	55                   	push   %ebp
80107d99:	89 e5                	mov    %esp,%ebp
80107d9b:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107d9e:	e8 43 ff ff ff       	call   80107ce6 <setupkvm>
80107da3:	a3 58 51 11 80       	mov    %eax,0x80115158
  switchkvm();
80107da8:	e8 03 00 00 00       	call   80107db0 <switchkvm>
}
80107dad:	90                   	nop
80107dae:	c9                   	leave  
80107daf:	c3                   	ret    

80107db0 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107db0:	55                   	push   %ebp
80107db1:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107db3:	a1 58 51 11 80       	mov    0x80115158,%eax
80107db8:	50                   	push   %eax
80107db9:	e8 69 f9 ff ff       	call   80107727 <v2p>
80107dbe:	83 c4 04             	add    $0x4,%esp
80107dc1:	50                   	push   %eax
80107dc2:	e8 54 f9 ff ff       	call   8010771b <lcr3>
80107dc7:	83 c4 04             	add    $0x4,%esp
}
80107dca:	90                   	nop
80107dcb:	c9                   	leave  
80107dcc:	c3                   	ret    

80107dcd <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107dcd:	55                   	push   %ebp
80107dce:	89 e5                	mov    %esp,%ebp
80107dd0:	56                   	push   %esi
80107dd1:	53                   	push   %ebx
  pushcli();
80107dd2:	e8 6a d3 ff ff       	call   80105141 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107dd7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107ddd:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107de4:	83 c2 08             	add    $0x8,%edx
80107de7:	89 d6                	mov    %edx,%esi
80107de9:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107df0:	83 c2 08             	add    $0x8,%edx
80107df3:	c1 ea 10             	shr    $0x10,%edx
80107df6:	89 d3                	mov    %edx,%ebx
80107df8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107dff:	83 c2 08             	add    $0x8,%edx
80107e02:	c1 ea 18             	shr    $0x18,%edx
80107e05:	89 d1                	mov    %edx,%ecx
80107e07:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107e0e:	67 00 
80107e10:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80107e17:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80107e1d:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107e24:	83 e2 f0             	and    $0xfffffff0,%edx
80107e27:	83 ca 09             	or     $0x9,%edx
80107e2a:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107e30:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107e37:	83 ca 10             	or     $0x10,%edx
80107e3a:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107e40:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107e47:	83 e2 9f             	and    $0xffffff9f,%edx
80107e4a:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107e50:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107e57:	83 ca 80             	or     $0xffffff80,%edx
80107e5a:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107e60:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107e67:	83 e2 f0             	and    $0xfffffff0,%edx
80107e6a:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107e70:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107e77:	83 e2 ef             	and    $0xffffffef,%edx
80107e7a:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107e80:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107e87:	83 e2 df             	and    $0xffffffdf,%edx
80107e8a:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107e90:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107e97:	83 ca 40             	or     $0x40,%edx
80107e9a:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107ea0:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107ea7:	83 e2 7f             	and    $0x7f,%edx
80107eaa:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107eb0:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107eb6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107ebc:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107ec3:	83 e2 ef             	and    $0xffffffef,%edx
80107ec6:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107ecc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107ed2:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107ed8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107ede:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107ee5:	8b 52 08             	mov    0x8(%edx),%edx
80107ee8:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107eee:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107ef1:	83 ec 0c             	sub    $0xc,%esp
80107ef4:	6a 30                	push   $0x30
80107ef6:	e8 f3 f7 ff ff       	call   801076ee <ltr>
80107efb:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80107efe:	8b 45 08             	mov    0x8(%ebp),%eax
80107f01:	8b 40 04             	mov    0x4(%eax),%eax
80107f04:	85 c0                	test   %eax,%eax
80107f06:	75 0d                	jne    80107f15 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80107f08:	83 ec 0c             	sub    $0xc,%esp
80107f0b:	68 13 8b 10 80       	push   $0x80108b13
80107f10:	e8 51 86 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107f15:	8b 45 08             	mov    0x8(%ebp),%eax
80107f18:	8b 40 04             	mov    0x4(%eax),%eax
80107f1b:	83 ec 0c             	sub    $0xc,%esp
80107f1e:	50                   	push   %eax
80107f1f:	e8 03 f8 ff ff       	call   80107727 <v2p>
80107f24:	83 c4 10             	add    $0x10,%esp
80107f27:	83 ec 0c             	sub    $0xc,%esp
80107f2a:	50                   	push   %eax
80107f2b:	e8 eb f7 ff ff       	call   8010771b <lcr3>
80107f30:	83 c4 10             	add    $0x10,%esp
  popcli();
80107f33:	e8 4e d2 ff ff       	call   80105186 <popcli>
}
80107f38:	90                   	nop
80107f39:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107f3c:	5b                   	pop    %ebx
80107f3d:	5e                   	pop    %esi
80107f3e:	5d                   	pop    %ebp
80107f3f:	c3                   	ret    

80107f40 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107f40:	55                   	push   %ebp
80107f41:	89 e5                	mov    %esp,%ebp
80107f43:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107f46:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107f4d:	76 0d                	jbe    80107f5c <inituvm+0x1c>
    panic("inituvm: more than a page");
80107f4f:	83 ec 0c             	sub    $0xc,%esp
80107f52:	68 27 8b 10 80       	push   $0x80108b27
80107f57:	e8 0a 86 ff ff       	call   80100566 <panic>
  mem = kalloc();
80107f5c:	e8 ea ac ff ff       	call   80102c4b <kalloc>
80107f61:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107f64:	83 ec 04             	sub    $0x4,%esp
80107f67:	68 00 10 00 00       	push   $0x1000
80107f6c:	6a 00                	push   $0x0
80107f6e:	ff 75 f4             	pushl  -0xc(%ebp)
80107f71:	e8 d1 d2 ff ff       	call   80105247 <memset>
80107f76:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107f79:	83 ec 0c             	sub    $0xc,%esp
80107f7c:	ff 75 f4             	pushl  -0xc(%ebp)
80107f7f:	e8 a3 f7 ff ff       	call   80107727 <v2p>
80107f84:	83 c4 10             	add    $0x10,%esp
80107f87:	83 ec 0c             	sub    $0xc,%esp
80107f8a:	6a 06                	push   $0x6
80107f8c:	50                   	push   %eax
80107f8d:	68 00 10 00 00       	push   $0x1000
80107f92:	6a 00                	push   $0x0
80107f94:	ff 75 08             	pushl  0x8(%ebp)
80107f97:	e8 ba fc ff ff       	call   80107c56 <mappages>
80107f9c:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107f9f:	83 ec 04             	sub    $0x4,%esp
80107fa2:	ff 75 10             	pushl  0x10(%ebp)
80107fa5:	ff 75 0c             	pushl  0xc(%ebp)
80107fa8:	ff 75 f4             	pushl  -0xc(%ebp)
80107fab:	e8 56 d3 ff ff       	call   80105306 <memmove>
80107fb0:	83 c4 10             	add    $0x10,%esp
}
80107fb3:	90                   	nop
80107fb4:	c9                   	leave  
80107fb5:	c3                   	ret    

80107fb6 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107fb6:	55                   	push   %ebp
80107fb7:	89 e5                	mov    %esp,%ebp
80107fb9:	53                   	push   %ebx
80107fba:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107fbd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fc0:	25 ff 0f 00 00       	and    $0xfff,%eax
80107fc5:	85 c0                	test   %eax,%eax
80107fc7:	74 0d                	je     80107fd6 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80107fc9:	83 ec 0c             	sub    $0xc,%esp
80107fcc:	68 44 8b 10 80       	push   $0x80108b44
80107fd1:	e8 90 85 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107fd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fdd:	e9 95 00 00 00       	jmp    80108077 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107fe2:	8b 55 0c             	mov    0xc(%ebp),%edx
80107fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe8:	01 d0                	add    %edx,%eax
80107fea:	83 ec 04             	sub    $0x4,%esp
80107fed:	6a 00                	push   $0x0
80107fef:	50                   	push   %eax
80107ff0:	ff 75 08             	pushl  0x8(%ebp)
80107ff3:	e8 be fb ff ff       	call   80107bb6 <walkpgdir>
80107ff8:	83 c4 10             	add    $0x10,%esp
80107ffb:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ffe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108002:	75 0d                	jne    80108011 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108004:	83 ec 0c             	sub    $0xc,%esp
80108007:	68 67 8b 10 80       	push   $0x80108b67
8010800c:	e8 55 85 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108011:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108014:	8b 00                	mov    (%eax),%eax
80108016:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010801b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010801e:	8b 45 18             	mov    0x18(%ebp),%eax
80108021:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108024:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108029:	77 0b                	ja     80108036 <loaduvm+0x80>
      n = sz - i;
8010802b:	8b 45 18             	mov    0x18(%ebp),%eax
8010802e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108031:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108034:	eb 07                	jmp    8010803d <loaduvm+0x87>
    else
      n = PGSIZE;
80108036:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010803d:	8b 55 14             	mov    0x14(%ebp),%edx
80108040:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108043:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108046:	83 ec 0c             	sub    $0xc,%esp
80108049:	ff 75 e8             	pushl  -0x18(%ebp)
8010804c:	e8 e3 f6 ff ff       	call   80107734 <p2v>
80108051:	83 c4 10             	add    $0x10,%esp
80108054:	ff 75 f0             	pushl  -0x10(%ebp)
80108057:	53                   	push   %ebx
80108058:	50                   	push   %eax
80108059:	ff 75 10             	pushl  0x10(%ebp)
8010805c:	e8 5c 9e ff ff       	call   80101ebd <readi>
80108061:	83 c4 10             	add    $0x10,%esp
80108064:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108067:	74 07                	je     80108070 <loaduvm+0xba>
      return -1;
80108069:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010806e:	eb 18                	jmp    80108088 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108070:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010807a:	3b 45 18             	cmp    0x18(%ebp),%eax
8010807d:	0f 82 5f ff ff ff    	jb     80107fe2 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108083:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108088:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010808b:	c9                   	leave  
8010808c:	c3                   	ret    

8010808d <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010808d:	55                   	push   %ebp
8010808e:	89 e5                	mov    %esp,%ebp
80108090:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108093:	8b 45 10             	mov    0x10(%ebp),%eax
80108096:	85 c0                	test   %eax,%eax
80108098:	79 0a                	jns    801080a4 <allocuvm+0x17>
    return 0;
8010809a:	b8 00 00 00 00       	mov    $0x0,%eax
8010809f:	e9 b0 00 00 00       	jmp    80108154 <allocuvm+0xc7>
  if(newsz < oldsz)
801080a4:	8b 45 10             	mov    0x10(%ebp),%eax
801080a7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801080aa:	73 08                	jae    801080b4 <allocuvm+0x27>
    return oldsz;
801080ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801080af:	e9 a0 00 00 00       	jmp    80108154 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
801080b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801080b7:	05 ff 0f 00 00       	add    $0xfff,%eax
801080bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801080c4:	eb 7f                	jmp    80108145 <allocuvm+0xb8>
    mem = kalloc();
801080c6:	e8 80 ab ff ff       	call   80102c4b <kalloc>
801080cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801080ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080d2:	75 2b                	jne    801080ff <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
801080d4:	83 ec 0c             	sub    $0xc,%esp
801080d7:	68 85 8b 10 80       	push   $0x80108b85
801080dc:	e8 e5 82 ff ff       	call   801003c6 <cprintf>
801080e1:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801080e4:	83 ec 04             	sub    $0x4,%esp
801080e7:	ff 75 0c             	pushl  0xc(%ebp)
801080ea:	ff 75 10             	pushl  0x10(%ebp)
801080ed:	ff 75 08             	pushl  0x8(%ebp)
801080f0:	e8 61 00 00 00       	call   80108156 <deallocuvm>
801080f5:	83 c4 10             	add    $0x10,%esp
      return 0;
801080f8:	b8 00 00 00 00       	mov    $0x0,%eax
801080fd:	eb 55                	jmp    80108154 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
801080ff:	83 ec 04             	sub    $0x4,%esp
80108102:	68 00 10 00 00       	push   $0x1000
80108107:	6a 00                	push   $0x0
80108109:	ff 75 f0             	pushl  -0x10(%ebp)
8010810c:	e8 36 d1 ff ff       	call   80105247 <memset>
80108111:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108114:	83 ec 0c             	sub    $0xc,%esp
80108117:	ff 75 f0             	pushl  -0x10(%ebp)
8010811a:	e8 08 f6 ff ff       	call   80107727 <v2p>
8010811f:	83 c4 10             	add    $0x10,%esp
80108122:	89 c2                	mov    %eax,%edx
80108124:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108127:	83 ec 0c             	sub    $0xc,%esp
8010812a:	6a 06                	push   $0x6
8010812c:	52                   	push   %edx
8010812d:	68 00 10 00 00       	push   $0x1000
80108132:	50                   	push   %eax
80108133:	ff 75 08             	pushl  0x8(%ebp)
80108136:	e8 1b fb ff ff       	call   80107c56 <mappages>
8010813b:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
8010813e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108148:	3b 45 10             	cmp    0x10(%ebp),%eax
8010814b:	0f 82 75 ff ff ff    	jb     801080c6 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108151:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108154:	c9                   	leave  
80108155:	c3                   	ret    

80108156 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108156:	55                   	push   %ebp
80108157:	89 e5                	mov    %esp,%ebp
80108159:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010815c:	8b 45 10             	mov    0x10(%ebp),%eax
8010815f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108162:	72 08                	jb     8010816c <deallocuvm+0x16>
    return oldsz;
80108164:	8b 45 0c             	mov    0xc(%ebp),%eax
80108167:	e9 a5 00 00 00       	jmp    80108211 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
8010816c:	8b 45 10             	mov    0x10(%ebp),%eax
8010816f:	05 ff 0f 00 00       	add    $0xfff,%eax
80108174:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108179:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010817c:	e9 81 00 00 00       	jmp    80108202 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108184:	83 ec 04             	sub    $0x4,%esp
80108187:	6a 00                	push   $0x0
80108189:	50                   	push   %eax
8010818a:	ff 75 08             	pushl  0x8(%ebp)
8010818d:	e8 24 fa ff ff       	call   80107bb6 <walkpgdir>
80108192:	83 c4 10             	add    $0x10,%esp
80108195:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108198:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010819c:	75 09                	jne    801081a7 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
8010819e:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801081a5:	eb 54                	jmp    801081fb <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
801081a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081aa:	8b 00                	mov    (%eax),%eax
801081ac:	83 e0 01             	and    $0x1,%eax
801081af:	85 c0                	test   %eax,%eax
801081b1:	74 48                	je     801081fb <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
801081b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081b6:	8b 00                	mov    (%eax),%eax
801081b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801081c0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081c4:	75 0d                	jne    801081d3 <deallocuvm+0x7d>
        panic("kfree");
801081c6:	83 ec 0c             	sub    $0xc,%esp
801081c9:	68 9d 8b 10 80       	push   $0x80108b9d
801081ce:	e8 93 83 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
801081d3:	83 ec 0c             	sub    $0xc,%esp
801081d6:	ff 75 ec             	pushl  -0x14(%ebp)
801081d9:	e8 56 f5 ff ff       	call   80107734 <p2v>
801081de:	83 c4 10             	add    $0x10,%esp
801081e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801081e4:	83 ec 0c             	sub    $0xc,%esp
801081e7:	ff 75 e8             	pushl  -0x18(%ebp)
801081ea:	e8 bf a9 ff ff       	call   80102bae <kfree>
801081ef:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801081f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801081fb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108205:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108208:	0f 82 73 ff ff ff    	jb     80108181 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010820e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108211:	c9                   	leave  
80108212:	c3                   	ret    

80108213 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108213:	55                   	push   %ebp
80108214:	89 e5                	mov    %esp,%ebp
80108216:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108219:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010821d:	75 0d                	jne    8010822c <freevm+0x19>
    panic("freevm: no pgdir");
8010821f:	83 ec 0c             	sub    $0xc,%esp
80108222:	68 a3 8b 10 80       	push   $0x80108ba3
80108227:	e8 3a 83 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010822c:	83 ec 04             	sub    $0x4,%esp
8010822f:	6a 00                	push   $0x0
80108231:	68 00 00 00 80       	push   $0x80000000
80108236:	ff 75 08             	pushl  0x8(%ebp)
80108239:	e8 18 ff ff ff       	call   80108156 <deallocuvm>
8010823e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108241:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108248:	eb 4f                	jmp    80108299 <freevm+0x86>
    if(pgdir[i] & PTE_P){
8010824a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108254:	8b 45 08             	mov    0x8(%ebp),%eax
80108257:	01 d0                	add    %edx,%eax
80108259:	8b 00                	mov    (%eax),%eax
8010825b:	83 e0 01             	and    $0x1,%eax
8010825e:	85 c0                	test   %eax,%eax
80108260:	74 33                	je     80108295 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108265:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010826c:	8b 45 08             	mov    0x8(%ebp),%eax
8010826f:	01 d0                	add    %edx,%eax
80108271:	8b 00                	mov    (%eax),%eax
80108273:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108278:	83 ec 0c             	sub    $0xc,%esp
8010827b:	50                   	push   %eax
8010827c:	e8 b3 f4 ff ff       	call   80107734 <p2v>
80108281:	83 c4 10             	add    $0x10,%esp
80108284:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108287:	83 ec 0c             	sub    $0xc,%esp
8010828a:	ff 75 f0             	pushl  -0x10(%ebp)
8010828d:	e8 1c a9 ff ff       	call   80102bae <kfree>
80108292:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108295:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108299:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801082a0:	76 a8                	jbe    8010824a <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801082a2:	83 ec 0c             	sub    $0xc,%esp
801082a5:	ff 75 08             	pushl  0x8(%ebp)
801082a8:	e8 01 a9 ff ff       	call   80102bae <kfree>
801082ad:	83 c4 10             	add    $0x10,%esp
}
801082b0:	90                   	nop
801082b1:	c9                   	leave  
801082b2:	c3                   	ret    

801082b3 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801082b3:	55                   	push   %ebp
801082b4:	89 e5                	mov    %esp,%ebp
801082b6:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801082b9:	83 ec 04             	sub    $0x4,%esp
801082bc:	6a 00                	push   $0x0
801082be:	ff 75 0c             	pushl  0xc(%ebp)
801082c1:	ff 75 08             	pushl  0x8(%ebp)
801082c4:	e8 ed f8 ff ff       	call   80107bb6 <walkpgdir>
801082c9:	83 c4 10             	add    $0x10,%esp
801082cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801082cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801082d3:	75 0d                	jne    801082e2 <clearpteu+0x2f>
    panic("clearpteu");
801082d5:	83 ec 0c             	sub    $0xc,%esp
801082d8:	68 b4 8b 10 80       	push   $0x80108bb4
801082dd:	e8 84 82 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
801082e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e5:	8b 00                	mov    (%eax),%eax
801082e7:	83 e0 fb             	and    $0xfffffffb,%eax
801082ea:	89 c2                	mov    %eax,%edx
801082ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ef:	89 10                	mov    %edx,(%eax)
}
801082f1:	90                   	nop
801082f2:	c9                   	leave  
801082f3:	c3                   	ret    

801082f4 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801082f4:	55                   	push   %ebp
801082f5:	89 e5                	mov    %esp,%ebp
801082f7:	53                   	push   %ebx
801082f8:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801082fb:	e8 e6 f9 ff ff       	call   80107ce6 <setupkvm>
80108300:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108303:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108307:	75 0a                	jne    80108313 <copyuvm+0x1f>
    return 0;
80108309:	b8 00 00 00 00       	mov    $0x0,%eax
8010830e:	e9 f8 00 00 00       	jmp    8010840b <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
80108313:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010831a:	e9 c4 00 00 00       	jmp    801083e3 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010831f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108322:	83 ec 04             	sub    $0x4,%esp
80108325:	6a 00                	push   $0x0
80108327:	50                   	push   %eax
80108328:	ff 75 08             	pushl  0x8(%ebp)
8010832b:	e8 86 f8 ff ff       	call   80107bb6 <walkpgdir>
80108330:	83 c4 10             	add    $0x10,%esp
80108333:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108336:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010833a:	75 0d                	jne    80108349 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
8010833c:	83 ec 0c             	sub    $0xc,%esp
8010833f:	68 be 8b 10 80       	push   $0x80108bbe
80108344:	e8 1d 82 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80108349:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010834c:	8b 00                	mov    (%eax),%eax
8010834e:	83 e0 01             	and    $0x1,%eax
80108351:	85 c0                	test   %eax,%eax
80108353:	75 0d                	jne    80108362 <copyuvm+0x6e>
      panic("copyuvm: page not present");
80108355:	83 ec 0c             	sub    $0xc,%esp
80108358:	68 d8 8b 10 80       	push   $0x80108bd8
8010835d:	e8 04 82 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108362:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108365:	8b 00                	mov    (%eax),%eax
80108367:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010836c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010836f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108372:	8b 00                	mov    (%eax),%eax
80108374:	25 ff 0f 00 00       	and    $0xfff,%eax
80108379:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010837c:	e8 ca a8 ff ff       	call   80102c4b <kalloc>
80108381:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108384:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108388:	74 6a                	je     801083f4 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010838a:	83 ec 0c             	sub    $0xc,%esp
8010838d:	ff 75 e8             	pushl  -0x18(%ebp)
80108390:	e8 9f f3 ff ff       	call   80107734 <p2v>
80108395:	83 c4 10             	add    $0x10,%esp
80108398:	83 ec 04             	sub    $0x4,%esp
8010839b:	68 00 10 00 00       	push   $0x1000
801083a0:	50                   	push   %eax
801083a1:	ff 75 e0             	pushl  -0x20(%ebp)
801083a4:	e8 5d cf ff ff       	call   80105306 <memmove>
801083a9:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801083ac:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801083af:	83 ec 0c             	sub    $0xc,%esp
801083b2:	ff 75 e0             	pushl  -0x20(%ebp)
801083b5:	e8 6d f3 ff ff       	call   80107727 <v2p>
801083ba:	83 c4 10             	add    $0x10,%esp
801083bd:	89 c2                	mov    %eax,%edx
801083bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c2:	83 ec 0c             	sub    $0xc,%esp
801083c5:	53                   	push   %ebx
801083c6:	52                   	push   %edx
801083c7:	68 00 10 00 00       	push   $0x1000
801083cc:	50                   	push   %eax
801083cd:	ff 75 f0             	pushl  -0x10(%ebp)
801083d0:	e8 81 f8 ff ff       	call   80107c56 <mappages>
801083d5:	83 c4 20             	add    $0x20,%esp
801083d8:	85 c0                	test   %eax,%eax
801083da:	78 1b                	js     801083f7 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801083dc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e6:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083e9:	0f 82 30 ff ff ff    	jb     8010831f <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801083ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083f2:	eb 17                	jmp    8010840b <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801083f4:	90                   	nop
801083f5:	eb 01                	jmp    801083f8 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801083f7:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801083f8:	83 ec 0c             	sub    $0xc,%esp
801083fb:	ff 75 f0             	pushl  -0x10(%ebp)
801083fe:	e8 10 fe ff ff       	call   80108213 <freevm>
80108403:	83 c4 10             	add    $0x10,%esp
  return 0;
80108406:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010840b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010840e:	c9                   	leave  
8010840f:	c3                   	ret    

80108410 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108410:	55                   	push   %ebp
80108411:	89 e5                	mov    %esp,%ebp
80108413:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108416:	83 ec 04             	sub    $0x4,%esp
80108419:	6a 00                	push   $0x0
8010841b:	ff 75 0c             	pushl  0xc(%ebp)
8010841e:	ff 75 08             	pushl  0x8(%ebp)
80108421:	e8 90 f7 ff ff       	call   80107bb6 <walkpgdir>
80108426:	83 c4 10             	add    $0x10,%esp
80108429:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010842c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842f:	8b 00                	mov    (%eax),%eax
80108431:	83 e0 01             	and    $0x1,%eax
80108434:	85 c0                	test   %eax,%eax
80108436:	75 07                	jne    8010843f <uva2ka+0x2f>
    return 0;
80108438:	b8 00 00 00 00       	mov    $0x0,%eax
8010843d:	eb 29                	jmp    80108468 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010843f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108442:	8b 00                	mov    (%eax),%eax
80108444:	83 e0 04             	and    $0x4,%eax
80108447:	85 c0                	test   %eax,%eax
80108449:	75 07                	jne    80108452 <uva2ka+0x42>
    return 0;
8010844b:	b8 00 00 00 00       	mov    $0x0,%eax
80108450:	eb 16                	jmp    80108468 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80108452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108455:	8b 00                	mov    (%eax),%eax
80108457:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010845c:	83 ec 0c             	sub    $0xc,%esp
8010845f:	50                   	push   %eax
80108460:	e8 cf f2 ff ff       	call   80107734 <p2v>
80108465:	83 c4 10             	add    $0x10,%esp
}
80108468:	c9                   	leave  
80108469:	c3                   	ret    

8010846a <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010846a:	55                   	push   %ebp
8010846b:	89 e5                	mov    %esp,%ebp
8010846d:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108470:	8b 45 10             	mov    0x10(%ebp),%eax
80108473:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108476:	eb 7f                	jmp    801084f7 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108478:	8b 45 0c             	mov    0xc(%ebp),%eax
8010847b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108480:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108483:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108486:	83 ec 08             	sub    $0x8,%esp
80108489:	50                   	push   %eax
8010848a:	ff 75 08             	pushl  0x8(%ebp)
8010848d:	e8 7e ff ff ff       	call   80108410 <uva2ka>
80108492:	83 c4 10             	add    $0x10,%esp
80108495:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108498:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010849c:	75 07                	jne    801084a5 <copyout+0x3b>
      return -1;
8010849e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801084a3:	eb 61                	jmp    80108506 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801084a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084a8:	2b 45 0c             	sub    0xc(%ebp),%eax
801084ab:	05 00 10 00 00       	add    $0x1000,%eax
801084b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801084b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084b6:	3b 45 14             	cmp    0x14(%ebp),%eax
801084b9:	76 06                	jbe    801084c1 <copyout+0x57>
      n = len;
801084bb:	8b 45 14             	mov    0x14(%ebp),%eax
801084be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801084c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801084c4:	2b 45 ec             	sub    -0x14(%ebp),%eax
801084c7:	89 c2                	mov    %eax,%edx
801084c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801084cc:	01 d0                	add    %edx,%eax
801084ce:	83 ec 04             	sub    $0x4,%esp
801084d1:	ff 75 f0             	pushl  -0x10(%ebp)
801084d4:	ff 75 f4             	pushl  -0xc(%ebp)
801084d7:	50                   	push   %eax
801084d8:	e8 29 ce ff ff       	call   80105306 <memmove>
801084dd:	83 c4 10             	add    $0x10,%esp
    len -= n;
801084e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084e3:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801084e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084e9:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801084ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084ef:	05 00 10 00 00       	add    $0x1000,%eax
801084f4:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801084f7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801084fb:	0f 85 77 ff ff ff    	jne    80108478 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108501:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108506:	c9                   	leave  
80108507:	c3                   	ret    
