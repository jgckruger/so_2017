
_ls2: formato do arquivo elf32-i386


Desmontagem da seção .text:

00000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 14             	sub    $0x14,%esp
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   7:	83 ec 0c             	sub    $0xc,%esp
   a:	ff 75 08             	pushl  0x8(%ebp)
   d:	e8 db 03 00 00       	call   3ed <strlen>
  12:	83 c4 10             	add    $0x10,%esp
  15:	89 c2                	mov    %eax,%edx
  17:	8b 45 08             	mov    0x8(%ebp),%eax
  1a:	01 d0                	add    %edx,%eax
  1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1f:	eb 04                	jmp    25 <fmtname+0x25>
  21:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  28:	3b 45 08             	cmp    0x8(%ebp),%eax
  2b:	72 0a                	jb     37 <fmtname+0x37>
  2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  30:	0f b6 00             	movzbl (%eax),%eax
  33:	3c 2f                	cmp    $0x2f,%al
  35:	75 ea                	jne    21 <fmtname+0x21>
    ;
  p++;
  37:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  3b:	83 ec 0c             	sub    $0xc,%esp
  3e:	ff 75 f4             	pushl  -0xc(%ebp)
  41:	e8 a7 03 00 00       	call   3ed <strlen>
  46:	83 c4 10             	add    $0x10,%esp
  49:	83 f8 0d             	cmp    $0xd,%eax
  4c:	76 05                	jbe    53 <fmtname+0x53>
    return p;
  4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  51:	eb 60                	jmp    b3 <fmtname+0xb3>
  memmove(buf, p, strlen(p));
  53:	83 ec 0c             	sub    $0xc,%esp
  56:	ff 75 f4             	pushl  -0xc(%ebp)
  59:	e8 8f 03 00 00       	call   3ed <strlen>
  5e:	83 c4 10             	add    $0x10,%esp
  61:	83 ec 04             	sub    $0x4,%esp
  64:	50                   	push   %eax
  65:	ff 75 f4             	pushl  -0xc(%ebp)
  68:	68 00 0e 00 00       	push   $0xe00
  6d:	e8 f8 04 00 00       	call   56a <memmove>
  72:	83 c4 10             	add    $0x10,%esp
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  75:	83 ec 0c             	sub    $0xc,%esp
  78:	ff 75 f4             	pushl  -0xc(%ebp)
  7b:	e8 6d 03 00 00       	call   3ed <strlen>
  80:	83 c4 10             	add    $0x10,%esp
  83:	ba 0e 00 00 00       	mov    $0xe,%edx
  88:	89 d3                	mov    %edx,%ebx
  8a:	29 c3                	sub    %eax,%ebx
  8c:	83 ec 0c             	sub    $0xc,%esp
  8f:	ff 75 f4             	pushl  -0xc(%ebp)
  92:	e8 56 03 00 00       	call   3ed <strlen>
  97:	83 c4 10             	add    $0x10,%esp
  9a:	05 00 0e 00 00       	add    $0xe00,%eax
  9f:	83 ec 04             	sub    $0x4,%esp
  a2:	53                   	push   %ebx
  a3:	6a 20                	push   $0x20
  a5:	50                   	push   %eax
  a6:	e8 69 03 00 00       	call   414 <memset>
  ab:	83 c4 10             	add    $0x10,%esp
  return buf;
  ae:	b8 00 0e 00 00       	mov    $0xe00,%eax
}
  b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  b6:	c9                   	leave  
  b7:	c3                   	ret    

000000b8 <ls>:

void
ls(char *path)
{
  b8:	55                   	push   %ebp
  b9:	89 e5                	mov    %esp,%ebp
  bb:	57                   	push   %edi
  bc:	56                   	push   %esi
  bd:	53                   	push   %ebx
  be:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  c4:	83 ec 08             	sub    $0x8,%esp
  c7:	6a 00                	push   $0x0
  c9:	ff 75 08             	pushl  0x8(%ebp)
  cc:	e8 1e 05 00 00       	call   5ef <open>
  d1:	83 c4 10             	add    $0x10,%esp
  d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  db:	79 1a                	jns    f7 <ls+0x3f>
    printf(2, "ls: cannot open %s\n", path);
  dd:	83 ec 04             	sub    $0x4,%esp
  e0:	ff 75 08             	pushl  0x8(%ebp)
  e3:	68 dc 0a 00 00       	push   $0xadc
  e8:	6a 02                	push   $0x2
  ea:	e8 37 06 00 00       	call   726 <printf>
  ef:	83 c4 10             	add    $0x10,%esp
    return;
  f2:	e9 e3 01 00 00       	jmp    2da <ls+0x222>
  }

  if(fstat(fd, &st) < 0){
  f7:	83 ec 08             	sub    $0x8,%esp
  fa:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 100:	50                   	push   %eax
 101:	ff 75 e4             	pushl  -0x1c(%ebp)
 104:	e8 fe 04 00 00       	call   607 <fstat>
 109:	83 c4 10             	add    $0x10,%esp
 10c:	85 c0                	test   %eax,%eax
 10e:	79 28                	jns    138 <ls+0x80>
    printf(2, "ls: cannot stat %s\n", path);
 110:	83 ec 04             	sub    $0x4,%esp
 113:	ff 75 08             	pushl  0x8(%ebp)
 116:	68 f0 0a 00 00       	push   $0xaf0
 11b:	6a 02                	push   $0x2
 11d:	e8 04 06 00 00       	call   726 <printf>
 122:	83 c4 10             	add    $0x10,%esp
    close(fd);
 125:	83 ec 0c             	sub    $0xc,%esp
 128:	ff 75 e4             	pushl  -0x1c(%ebp)
 12b:	e8 a7 04 00 00       	call   5d7 <close>
 130:	83 c4 10             	add    $0x10,%esp
    return;
 133:	e9 a2 01 00 00       	jmp    2da <ls+0x222>
  }

  switch(st.type){
 138:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 13f:	98                   	cwtl   
 140:	83 f8 01             	cmp    $0x1,%eax
 143:	74 48                	je     18d <ls+0xd5>
 145:	83 f8 02             	cmp    $0x2,%eax
 148:	0f 85 7e 01 00 00    	jne    2cc <ls+0x214>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
 14e:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 154:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 15a:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 161:	0f bf d8             	movswl %ax,%ebx
 164:	83 ec 0c             	sub    $0xc,%esp
 167:	ff 75 08             	pushl  0x8(%ebp)
 16a:	e8 91 fe ff ff       	call   0 <fmtname>
 16f:	83 c4 10             	add    $0x10,%esp
 172:	83 ec 08             	sub    $0x8,%esp
 175:	57                   	push   %edi
 176:	56                   	push   %esi
 177:	53                   	push   %ebx
 178:	50                   	push   %eax
 179:	68 04 0b 00 00       	push   $0xb04
 17e:	6a 01                	push   $0x1
 180:	e8 a1 05 00 00       	call   726 <printf>
 185:	83 c4 20             	add    $0x20,%esp
    break;
 188:	e9 3f 01 00 00       	jmp    2cc <ls+0x214>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 18d:	83 ec 0c             	sub    $0xc,%esp
 190:	ff 75 08             	pushl  0x8(%ebp)
 193:	e8 55 02 00 00       	call   3ed <strlen>
 198:	83 c4 10             	add    $0x10,%esp
 19b:	83 c0 10             	add    $0x10,%eax
 19e:	3d 00 02 00 00       	cmp    $0x200,%eax
 1a3:	76 17                	jbe    1bc <ls+0x104>
      printf(1, "ls: path too long\n");
 1a5:	83 ec 08             	sub    $0x8,%esp
 1a8:	68 11 0b 00 00       	push   $0xb11
 1ad:	6a 01                	push   $0x1
 1af:	e8 72 05 00 00       	call   726 <printf>
 1b4:	83 c4 10             	add    $0x10,%esp
      break;
 1b7:	e9 10 01 00 00       	jmp    2cc <ls+0x214>
    }
    strcpy(buf, path);
 1bc:	83 ec 08             	sub    $0x8,%esp
 1bf:	ff 75 08             	pushl  0x8(%ebp)
 1c2:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1c8:	50                   	push   %eax
 1c9:	e8 b0 01 00 00       	call   37e <strcpy>
 1ce:	83 c4 10             	add    $0x10,%esp
    p = buf+strlen(buf);
 1d1:	83 ec 0c             	sub    $0xc,%esp
 1d4:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1da:	50                   	push   %eax
 1db:	e8 0d 02 00 00       	call   3ed <strlen>
 1e0:	83 c4 10             	add    $0x10,%esp
 1e3:	89 c2                	mov    %eax,%edx
 1e5:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1eb:	01 d0                	add    %edx,%eax
 1ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
 1f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1f3:	8d 50 01             	lea    0x1(%eax),%edx
 1f6:	89 55 e0             	mov    %edx,-0x20(%ebp)
 1f9:	c6 00 2f             	movb   $0x2f,(%eax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1fc:	e9 aa 00 00 00       	jmp    2ab <ls+0x1f3>
      if(de.inum == 0)
 201:	0f b7 85 d0 fd ff ff 	movzwl -0x230(%ebp),%eax
 208:	66 85 c0             	test   %ax,%ax
 20b:	75 05                	jne    212 <ls+0x15a>
        continue;
 20d:	e9 99 00 00 00       	jmp    2ab <ls+0x1f3>
      memmove(p, de.name, DIRSIZ);
 212:	83 ec 04             	sub    $0x4,%esp
 215:	6a 0e                	push   $0xe
 217:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 21d:	83 c0 02             	add    $0x2,%eax
 220:	50                   	push   %eax
 221:	ff 75 e0             	pushl  -0x20(%ebp)
 224:	e8 41 03 00 00       	call   56a <memmove>
 229:	83 c4 10             	add    $0x10,%esp
      p[DIRSIZ] = 0;
 22c:	8b 45 e0             	mov    -0x20(%ebp),%eax
 22f:	83 c0 0e             	add    $0xe,%eax
 232:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
 235:	83 ec 08             	sub    $0x8,%esp
 238:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 23e:	50                   	push   %eax
 23f:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 245:	50                   	push   %eax
 246:	e8 85 02 00 00       	call   4d0 <stat>
 24b:	83 c4 10             	add    $0x10,%esp
 24e:	85 c0                	test   %eax,%eax
 250:	79 1b                	jns    26d <ls+0x1b5>
        printf(1, "ls: cannot stat %s\n", buf);
 252:	83 ec 04             	sub    $0x4,%esp
 255:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 25b:	50                   	push   %eax
 25c:	68 f0 0a 00 00       	push   $0xaf0
 261:	6a 01                	push   $0x1
 263:	e8 be 04 00 00       	call   726 <printf>
 268:	83 c4 10             	add    $0x10,%esp
        continue;
 26b:	eb 3e                	jmp    2ab <ls+0x1f3>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 26d:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 273:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 279:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 280:	0f bf d8             	movswl %ax,%ebx
 283:	83 ec 0c             	sub    $0xc,%esp
 286:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 28c:	50                   	push   %eax
 28d:	e8 6e fd ff ff       	call   0 <fmtname>
 292:	83 c4 10             	add    $0x10,%esp
 295:	83 ec 08             	sub    $0x8,%esp
 298:	57                   	push   %edi
 299:	56                   	push   %esi
 29a:	53                   	push   %ebx
 29b:	50                   	push   %eax
 29c:	68 04 0b 00 00       	push   $0xb04
 2a1:	6a 01                	push   $0x1
 2a3:	e8 7e 04 00 00       	call   726 <printf>
 2a8:	83 c4 20             	add    $0x20,%esp
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 2ab:	83 ec 04             	sub    $0x4,%esp
 2ae:	6a 10                	push   $0x10
 2b0:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 2b6:	50                   	push   %eax
 2b7:	ff 75 e4             	pushl  -0x1c(%ebp)
 2ba:	e8 08 03 00 00       	call   5c7 <read>
 2bf:	83 c4 10             	add    $0x10,%esp
 2c2:	83 f8 10             	cmp    $0x10,%eax
 2c5:	0f 84 36 ff ff ff    	je     201 <ls+0x149>
        printf(1, "ls: cannot stat %s\n", buf);
        continue;
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
 2cb:	90                   	nop
  }
  close(fd);
 2cc:	83 ec 0c             	sub    $0xc,%esp
 2cf:	ff 75 e4             	pushl  -0x1c(%ebp)
 2d2:	e8 00 03 00 00       	call   5d7 <close>
 2d7:	83 c4 10             	add    $0x10,%esp
}
 2da:	8d 65 f4             	lea    -0xc(%ebp),%esp
 2dd:	5b                   	pop    %ebx
 2de:	5e                   	pop    %esi
 2df:	5f                   	pop    %edi
 2e0:	5d                   	pop    %ebp
 2e1:	c3                   	ret    

000002e2 <main>:

int
main(int argc, char *argv[])
{
 2e2:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 2e6:	83 e4 f0             	and    $0xfffffff0,%esp
 2e9:	ff 71 fc             	pushl  -0x4(%ecx)
 2ec:	55                   	push   %ebp
 2ed:	89 e5                	mov    %esp,%ebp
 2ef:	53                   	push   %ebx
 2f0:	51                   	push   %ecx
 2f1:	83 ec 10             	sub    $0x10,%esp
 2f4:	89 cb                	mov    %ecx,%ebx
  int i;
  printf(1, "Esse programa foi modificado");
 2f6:	83 ec 08             	sub    $0x8,%esp
 2f9:	68 24 0b 00 00       	push   $0xb24
 2fe:	6a 01                	push   $0x1
 300:	e8 21 04 00 00       	call   726 <printf>
 305:	83 c4 10             	add    $0x10,%esp
  if(argc < 2){
 308:	83 3b 01             	cmpl   $0x1,(%ebx)
 30b:	7f 15                	jg     322 <main+0x40>
    ls(".");
 30d:	83 ec 0c             	sub    $0xc,%esp
 310:	68 41 0b 00 00       	push   $0xb41
 315:	e8 9e fd ff ff       	call   b8 <ls>
 31a:	83 c4 10             	add    $0x10,%esp
    exit();
 31d:	e8 8d 02 00 00       	call   5af <exit>
  }
  for(i=1; i<argc; i++)
 322:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
 329:	eb 21                	jmp    34c <main+0x6a>
    ls(argv[i]);
 32b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 32e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 335:	8b 43 04             	mov    0x4(%ebx),%eax
 338:	01 d0                	add    %edx,%eax
 33a:	8b 00                	mov    (%eax),%eax
 33c:	83 ec 0c             	sub    $0xc,%esp
 33f:	50                   	push   %eax
 340:	e8 73 fd ff ff       	call   b8 <ls>
 345:	83 c4 10             	add    $0x10,%esp
  printf(1, "Esse programa foi modificado");
  if(argc < 2){
    ls(".");
    exit();
  }
  for(i=1; i<argc; i++)
 348:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 34c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 34f:	3b 03                	cmp    (%ebx),%eax
 351:	7c d8                	jl     32b <main+0x49>
    ls(argv[i]);
  exit();
 353:	e8 57 02 00 00       	call   5af <exit>

00000358 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 358:	55                   	push   %ebp
 359:	89 e5                	mov    %esp,%ebp
 35b:	57                   	push   %edi
 35c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 35d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 360:	8b 55 10             	mov    0x10(%ebp),%edx
 363:	8b 45 0c             	mov    0xc(%ebp),%eax
 366:	89 cb                	mov    %ecx,%ebx
 368:	89 df                	mov    %ebx,%edi
 36a:	89 d1                	mov    %edx,%ecx
 36c:	fc                   	cld    
 36d:	f3 aa                	rep stos %al,%es:(%edi)
 36f:	89 ca                	mov    %ecx,%edx
 371:	89 fb                	mov    %edi,%ebx
 373:	89 5d 08             	mov    %ebx,0x8(%ebp)
 376:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 379:	90                   	nop
 37a:	5b                   	pop    %ebx
 37b:	5f                   	pop    %edi
 37c:	5d                   	pop    %ebp
 37d:	c3                   	ret    

0000037e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 37e:	55                   	push   %ebp
 37f:	89 e5                	mov    %esp,%ebp
 381:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 384:	8b 45 08             	mov    0x8(%ebp),%eax
 387:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 38a:	90                   	nop
 38b:	8b 45 08             	mov    0x8(%ebp),%eax
 38e:	8d 50 01             	lea    0x1(%eax),%edx
 391:	89 55 08             	mov    %edx,0x8(%ebp)
 394:	8b 55 0c             	mov    0xc(%ebp),%edx
 397:	8d 4a 01             	lea    0x1(%edx),%ecx
 39a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 39d:	0f b6 12             	movzbl (%edx),%edx
 3a0:	88 10                	mov    %dl,(%eax)
 3a2:	0f b6 00             	movzbl (%eax),%eax
 3a5:	84 c0                	test   %al,%al
 3a7:	75 e2                	jne    38b <strcpy+0xd>
    ;
  return os;
 3a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3ac:	c9                   	leave  
 3ad:	c3                   	ret    

000003ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3ae:	55                   	push   %ebp
 3af:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3b1:	eb 08                	jmp    3bb <strcmp+0xd>
    p++, q++;
 3b3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3b7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3bb:	8b 45 08             	mov    0x8(%ebp),%eax
 3be:	0f b6 00             	movzbl (%eax),%eax
 3c1:	84 c0                	test   %al,%al
 3c3:	74 10                	je     3d5 <strcmp+0x27>
 3c5:	8b 45 08             	mov    0x8(%ebp),%eax
 3c8:	0f b6 10             	movzbl (%eax),%edx
 3cb:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ce:	0f b6 00             	movzbl (%eax),%eax
 3d1:	38 c2                	cmp    %al,%dl
 3d3:	74 de                	je     3b3 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3d5:	8b 45 08             	mov    0x8(%ebp),%eax
 3d8:	0f b6 00             	movzbl (%eax),%eax
 3db:	0f b6 d0             	movzbl %al,%edx
 3de:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e1:	0f b6 00             	movzbl (%eax),%eax
 3e4:	0f b6 c0             	movzbl %al,%eax
 3e7:	29 c2                	sub    %eax,%edx
 3e9:	89 d0                	mov    %edx,%eax
}
 3eb:	5d                   	pop    %ebp
 3ec:	c3                   	ret    

000003ed <strlen>:

uint
strlen(char *s)
{
 3ed:	55                   	push   %ebp
 3ee:	89 e5                	mov    %esp,%ebp
 3f0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3f3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3fa:	eb 04                	jmp    400 <strlen+0x13>
 3fc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 400:	8b 55 fc             	mov    -0x4(%ebp),%edx
 403:	8b 45 08             	mov    0x8(%ebp),%eax
 406:	01 d0                	add    %edx,%eax
 408:	0f b6 00             	movzbl (%eax),%eax
 40b:	84 c0                	test   %al,%al
 40d:	75 ed                	jne    3fc <strlen+0xf>
    ;
  return n;
 40f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 412:	c9                   	leave  
 413:	c3                   	ret    

00000414 <memset>:

void*
memset(void *dst, int c, uint n)
{
 414:	55                   	push   %ebp
 415:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 417:	8b 45 10             	mov    0x10(%ebp),%eax
 41a:	50                   	push   %eax
 41b:	ff 75 0c             	pushl  0xc(%ebp)
 41e:	ff 75 08             	pushl  0x8(%ebp)
 421:	e8 32 ff ff ff       	call   358 <stosb>
 426:	83 c4 0c             	add    $0xc,%esp
  return dst;
 429:	8b 45 08             	mov    0x8(%ebp),%eax
}
 42c:	c9                   	leave  
 42d:	c3                   	ret    

0000042e <strchr>:

char*
strchr(const char *s, char c)
{
 42e:	55                   	push   %ebp
 42f:	89 e5                	mov    %esp,%ebp
 431:	83 ec 04             	sub    $0x4,%esp
 434:	8b 45 0c             	mov    0xc(%ebp),%eax
 437:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 43a:	eb 14                	jmp    450 <strchr+0x22>
    if(*s == c)
 43c:	8b 45 08             	mov    0x8(%ebp),%eax
 43f:	0f b6 00             	movzbl (%eax),%eax
 442:	3a 45 fc             	cmp    -0x4(%ebp),%al
 445:	75 05                	jne    44c <strchr+0x1e>
      return (char*)s;
 447:	8b 45 08             	mov    0x8(%ebp),%eax
 44a:	eb 13                	jmp    45f <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 44c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 450:	8b 45 08             	mov    0x8(%ebp),%eax
 453:	0f b6 00             	movzbl (%eax),%eax
 456:	84 c0                	test   %al,%al
 458:	75 e2                	jne    43c <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 45a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 45f:	c9                   	leave  
 460:	c3                   	ret    

00000461 <gets>:

char*
gets(char *buf, int max)
{
 461:	55                   	push   %ebp
 462:	89 e5                	mov    %esp,%ebp
 464:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 467:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 46e:	eb 42                	jmp    4b2 <gets+0x51>
    cc = read(0, &c, 1);
 470:	83 ec 04             	sub    $0x4,%esp
 473:	6a 01                	push   $0x1
 475:	8d 45 ef             	lea    -0x11(%ebp),%eax
 478:	50                   	push   %eax
 479:	6a 00                	push   $0x0
 47b:	e8 47 01 00 00       	call   5c7 <read>
 480:	83 c4 10             	add    $0x10,%esp
 483:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 486:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 48a:	7e 33                	jle    4bf <gets+0x5e>
      break;
    buf[i++] = c;
 48c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 48f:	8d 50 01             	lea    0x1(%eax),%edx
 492:	89 55 f4             	mov    %edx,-0xc(%ebp)
 495:	89 c2                	mov    %eax,%edx
 497:	8b 45 08             	mov    0x8(%ebp),%eax
 49a:	01 c2                	add    %eax,%edx
 49c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4a0:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4a2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4a6:	3c 0a                	cmp    $0xa,%al
 4a8:	74 16                	je     4c0 <gets+0x5f>
 4aa:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4ae:	3c 0d                	cmp    $0xd,%al
 4b0:	74 0e                	je     4c0 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b5:	83 c0 01             	add    $0x1,%eax
 4b8:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4bb:	7c b3                	jl     470 <gets+0xf>
 4bd:	eb 01                	jmp    4c0 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 4bf:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4c3:	8b 45 08             	mov    0x8(%ebp),%eax
 4c6:	01 d0                	add    %edx,%eax
 4c8:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4cb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4ce:	c9                   	leave  
 4cf:	c3                   	ret    

000004d0 <stat>:

int
stat(char *n, struct stat *st)
{
 4d0:	55                   	push   %ebp
 4d1:	89 e5                	mov    %esp,%ebp
 4d3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4d6:	83 ec 08             	sub    $0x8,%esp
 4d9:	6a 00                	push   $0x0
 4db:	ff 75 08             	pushl  0x8(%ebp)
 4de:	e8 0c 01 00 00       	call   5ef <open>
 4e3:	83 c4 10             	add    $0x10,%esp
 4e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4ed:	79 07                	jns    4f6 <stat+0x26>
    return -1;
 4ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4f4:	eb 25                	jmp    51b <stat+0x4b>
  r = fstat(fd, st);
 4f6:	83 ec 08             	sub    $0x8,%esp
 4f9:	ff 75 0c             	pushl  0xc(%ebp)
 4fc:	ff 75 f4             	pushl  -0xc(%ebp)
 4ff:	e8 03 01 00 00       	call   607 <fstat>
 504:	83 c4 10             	add    $0x10,%esp
 507:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 50a:	83 ec 0c             	sub    $0xc,%esp
 50d:	ff 75 f4             	pushl  -0xc(%ebp)
 510:	e8 c2 00 00 00       	call   5d7 <close>
 515:	83 c4 10             	add    $0x10,%esp
  return r;
 518:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 51b:	c9                   	leave  
 51c:	c3                   	ret    

0000051d <atoi>:

int
atoi(const char *s)
{
 51d:	55                   	push   %ebp
 51e:	89 e5                	mov    %esp,%ebp
 520:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 523:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 52a:	eb 25                	jmp    551 <atoi+0x34>
    n = n*10 + *s++ - '0';
 52c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 52f:	89 d0                	mov    %edx,%eax
 531:	c1 e0 02             	shl    $0x2,%eax
 534:	01 d0                	add    %edx,%eax
 536:	01 c0                	add    %eax,%eax
 538:	89 c1                	mov    %eax,%ecx
 53a:	8b 45 08             	mov    0x8(%ebp),%eax
 53d:	8d 50 01             	lea    0x1(%eax),%edx
 540:	89 55 08             	mov    %edx,0x8(%ebp)
 543:	0f b6 00             	movzbl (%eax),%eax
 546:	0f be c0             	movsbl %al,%eax
 549:	01 c8                	add    %ecx,%eax
 54b:	83 e8 30             	sub    $0x30,%eax
 54e:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 551:	8b 45 08             	mov    0x8(%ebp),%eax
 554:	0f b6 00             	movzbl (%eax),%eax
 557:	3c 2f                	cmp    $0x2f,%al
 559:	7e 0a                	jle    565 <atoi+0x48>
 55b:	8b 45 08             	mov    0x8(%ebp),%eax
 55e:	0f b6 00             	movzbl (%eax),%eax
 561:	3c 39                	cmp    $0x39,%al
 563:	7e c7                	jle    52c <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 565:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 568:	c9                   	leave  
 569:	c3                   	ret    

0000056a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 56a:	55                   	push   %ebp
 56b:	89 e5                	mov    %esp,%ebp
 56d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 570:	8b 45 08             	mov    0x8(%ebp),%eax
 573:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 576:	8b 45 0c             	mov    0xc(%ebp),%eax
 579:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 57c:	eb 17                	jmp    595 <memmove+0x2b>
    *dst++ = *src++;
 57e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 581:	8d 50 01             	lea    0x1(%eax),%edx
 584:	89 55 fc             	mov    %edx,-0x4(%ebp)
 587:	8b 55 f8             	mov    -0x8(%ebp),%edx
 58a:	8d 4a 01             	lea    0x1(%edx),%ecx
 58d:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 590:	0f b6 12             	movzbl (%edx),%edx
 593:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 595:	8b 45 10             	mov    0x10(%ebp),%eax
 598:	8d 50 ff             	lea    -0x1(%eax),%edx
 59b:	89 55 10             	mov    %edx,0x10(%ebp)
 59e:	85 c0                	test   %eax,%eax
 5a0:	7f dc                	jg     57e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5a2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5a5:	c9                   	leave  
 5a6:	c3                   	ret    

000005a7 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5a7:	b8 01 00 00 00       	mov    $0x1,%eax
 5ac:	cd 40                	int    $0x40
 5ae:	c3                   	ret    

000005af <exit>:
SYSCALL(exit)
 5af:	b8 02 00 00 00       	mov    $0x2,%eax
 5b4:	cd 40                	int    $0x40
 5b6:	c3                   	ret    

000005b7 <wait>:
SYSCALL(wait)
 5b7:	b8 03 00 00 00       	mov    $0x3,%eax
 5bc:	cd 40                	int    $0x40
 5be:	c3                   	ret    

000005bf <pipe>:
SYSCALL(pipe)
 5bf:	b8 04 00 00 00       	mov    $0x4,%eax
 5c4:	cd 40                	int    $0x40
 5c6:	c3                   	ret    

000005c7 <read>:
SYSCALL(read)
 5c7:	b8 05 00 00 00       	mov    $0x5,%eax
 5cc:	cd 40                	int    $0x40
 5ce:	c3                   	ret    

000005cf <write>:
SYSCALL(write)
 5cf:	b8 10 00 00 00       	mov    $0x10,%eax
 5d4:	cd 40                	int    $0x40
 5d6:	c3                   	ret    

000005d7 <close>:
SYSCALL(close)
 5d7:	b8 15 00 00 00       	mov    $0x15,%eax
 5dc:	cd 40                	int    $0x40
 5de:	c3                   	ret    

000005df <kill>:
SYSCALL(kill)
 5df:	b8 06 00 00 00       	mov    $0x6,%eax
 5e4:	cd 40                	int    $0x40
 5e6:	c3                   	ret    

000005e7 <exec>:
SYSCALL(exec)
 5e7:	b8 07 00 00 00       	mov    $0x7,%eax
 5ec:	cd 40                	int    $0x40
 5ee:	c3                   	ret    

000005ef <open>:
SYSCALL(open)
 5ef:	b8 0f 00 00 00       	mov    $0xf,%eax
 5f4:	cd 40                	int    $0x40
 5f6:	c3                   	ret    

000005f7 <mknod>:
SYSCALL(mknod)
 5f7:	b8 11 00 00 00       	mov    $0x11,%eax
 5fc:	cd 40                	int    $0x40
 5fe:	c3                   	ret    

000005ff <unlink>:
SYSCALL(unlink)
 5ff:	b8 12 00 00 00       	mov    $0x12,%eax
 604:	cd 40                	int    $0x40
 606:	c3                   	ret    

00000607 <fstat>:
SYSCALL(fstat)
 607:	b8 08 00 00 00       	mov    $0x8,%eax
 60c:	cd 40                	int    $0x40
 60e:	c3                   	ret    

0000060f <link>:
SYSCALL(link)
 60f:	b8 13 00 00 00       	mov    $0x13,%eax
 614:	cd 40                	int    $0x40
 616:	c3                   	ret    

00000617 <mkdir>:
SYSCALL(mkdir)
 617:	b8 14 00 00 00       	mov    $0x14,%eax
 61c:	cd 40                	int    $0x40
 61e:	c3                   	ret    

0000061f <chdir>:
SYSCALL(chdir)
 61f:	b8 09 00 00 00       	mov    $0x9,%eax
 624:	cd 40                	int    $0x40
 626:	c3                   	ret    

00000627 <dup>:
SYSCALL(dup)
 627:	b8 0a 00 00 00       	mov    $0xa,%eax
 62c:	cd 40                	int    $0x40
 62e:	c3                   	ret    

0000062f <getpid>:
SYSCALL(getpid)
 62f:	b8 0b 00 00 00       	mov    $0xb,%eax
 634:	cd 40                	int    $0x40
 636:	c3                   	ret    

00000637 <sbrk>:
SYSCALL(sbrk)
 637:	b8 0c 00 00 00       	mov    $0xc,%eax
 63c:	cd 40                	int    $0x40
 63e:	c3                   	ret    

0000063f <sleep>:
SYSCALL(sleep)
 63f:	b8 0d 00 00 00       	mov    $0xd,%eax
 644:	cd 40                	int    $0x40
 646:	c3                   	ret    

00000647 <uptime>:
SYSCALL(uptime)
 647:	b8 0e 00 00 00       	mov    $0xe,%eax
 64c:	cd 40                	int    $0x40
 64e:	c3                   	ret    

0000064f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 64f:	55                   	push   %ebp
 650:	89 e5                	mov    %esp,%ebp
 652:	83 ec 18             	sub    $0x18,%esp
 655:	8b 45 0c             	mov    0xc(%ebp),%eax
 658:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 65b:	83 ec 04             	sub    $0x4,%esp
 65e:	6a 01                	push   $0x1
 660:	8d 45 f4             	lea    -0xc(%ebp),%eax
 663:	50                   	push   %eax
 664:	ff 75 08             	pushl  0x8(%ebp)
 667:	e8 63 ff ff ff       	call   5cf <write>
 66c:	83 c4 10             	add    $0x10,%esp
}
 66f:	90                   	nop
 670:	c9                   	leave  
 671:	c3                   	ret    

00000672 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 672:	55                   	push   %ebp
 673:	89 e5                	mov    %esp,%ebp
 675:	53                   	push   %ebx
 676:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 679:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 680:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 684:	74 17                	je     69d <printint+0x2b>
 686:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 68a:	79 11                	jns    69d <printint+0x2b>
    neg = 1;
 68c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 693:	8b 45 0c             	mov    0xc(%ebp),%eax
 696:	f7 d8                	neg    %eax
 698:	89 45 ec             	mov    %eax,-0x14(%ebp)
 69b:	eb 06                	jmp    6a3 <printint+0x31>
  } else {
    x = xx;
 69d:	8b 45 0c             	mov    0xc(%ebp),%eax
 6a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6aa:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 6ad:	8d 41 01             	lea    0x1(%ecx),%eax
 6b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6b9:	ba 00 00 00 00       	mov    $0x0,%edx
 6be:	f7 f3                	div    %ebx
 6c0:	89 d0                	mov    %edx,%eax
 6c2:	0f b6 80 ec 0d 00 00 	movzbl 0xdec(%eax),%eax
 6c9:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 6cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6d3:	ba 00 00 00 00       	mov    $0x0,%edx
 6d8:	f7 f3                	div    %ebx
 6da:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6dd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6e1:	75 c7                	jne    6aa <printint+0x38>
  if(neg)
 6e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6e7:	74 2d                	je     716 <printint+0xa4>
    buf[i++] = '-';
 6e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ec:	8d 50 01             	lea    0x1(%eax),%edx
 6ef:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6f2:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6f7:	eb 1d                	jmp    716 <printint+0xa4>
    putc(fd, buf[i]);
 6f9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ff:	01 d0                	add    %edx,%eax
 701:	0f b6 00             	movzbl (%eax),%eax
 704:	0f be c0             	movsbl %al,%eax
 707:	83 ec 08             	sub    $0x8,%esp
 70a:	50                   	push   %eax
 70b:	ff 75 08             	pushl  0x8(%ebp)
 70e:	e8 3c ff ff ff       	call   64f <putc>
 713:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 716:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 71a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 71e:	79 d9                	jns    6f9 <printint+0x87>
    putc(fd, buf[i]);
}
 720:	90                   	nop
 721:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 724:	c9                   	leave  
 725:	c3                   	ret    

00000726 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 726:	55                   	push   %ebp
 727:	89 e5                	mov    %esp,%ebp
 729:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 72c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 733:	8d 45 0c             	lea    0xc(%ebp),%eax
 736:	83 c0 04             	add    $0x4,%eax
 739:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 73c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 743:	e9 59 01 00 00       	jmp    8a1 <printf+0x17b>
    c = fmt[i] & 0xff;
 748:	8b 55 0c             	mov    0xc(%ebp),%edx
 74b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74e:	01 d0                	add    %edx,%eax
 750:	0f b6 00             	movzbl (%eax),%eax
 753:	0f be c0             	movsbl %al,%eax
 756:	25 ff 00 00 00       	and    $0xff,%eax
 75b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 75e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 762:	75 2c                	jne    790 <printf+0x6a>
      if(c == '%'){
 764:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 768:	75 0c                	jne    776 <printf+0x50>
        state = '%';
 76a:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 771:	e9 27 01 00 00       	jmp    89d <printf+0x177>
      } else {
        putc(fd, c);
 776:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 779:	0f be c0             	movsbl %al,%eax
 77c:	83 ec 08             	sub    $0x8,%esp
 77f:	50                   	push   %eax
 780:	ff 75 08             	pushl  0x8(%ebp)
 783:	e8 c7 fe ff ff       	call   64f <putc>
 788:	83 c4 10             	add    $0x10,%esp
 78b:	e9 0d 01 00 00       	jmp    89d <printf+0x177>
      }
    } else if(state == '%'){
 790:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 794:	0f 85 03 01 00 00    	jne    89d <printf+0x177>
      if(c == 'd'){
 79a:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 79e:	75 1e                	jne    7be <printf+0x98>
        printint(fd, *ap, 10, 1);
 7a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7a3:	8b 00                	mov    (%eax),%eax
 7a5:	6a 01                	push   $0x1
 7a7:	6a 0a                	push   $0xa
 7a9:	50                   	push   %eax
 7aa:	ff 75 08             	pushl  0x8(%ebp)
 7ad:	e8 c0 fe ff ff       	call   672 <printint>
 7b2:	83 c4 10             	add    $0x10,%esp
        ap++;
 7b5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7b9:	e9 d8 00 00 00       	jmp    896 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7be:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7c2:	74 06                	je     7ca <printf+0xa4>
 7c4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7c8:	75 1e                	jne    7e8 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7cd:	8b 00                	mov    (%eax),%eax
 7cf:	6a 00                	push   $0x0
 7d1:	6a 10                	push   $0x10
 7d3:	50                   	push   %eax
 7d4:	ff 75 08             	pushl  0x8(%ebp)
 7d7:	e8 96 fe ff ff       	call   672 <printint>
 7dc:	83 c4 10             	add    $0x10,%esp
        ap++;
 7df:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e3:	e9 ae 00 00 00       	jmp    896 <printf+0x170>
      } else if(c == 's'){
 7e8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7ec:	75 43                	jne    831 <printf+0x10b>
        s = (char*)*ap;
 7ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f1:	8b 00                	mov    (%eax),%eax
 7f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7f6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7fe:	75 25                	jne    825 <printf+0xff>
          s = "(null)";
 800:	c7 45 f4 43 0b 00 00 	movl   $0xb43,-0xc(%ebp)
        while(*s != 0){
 807:	eb 1c                	jmp    825 <printf+0xff>
          putc(fd, *s);
 809:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80c:	0f b6 00             	movzbl (%eax),%eax
 80f:	0f be c0             	movsbl %al,%eax
 812:	83 ec 08             	sub    $0x8,%esp
 815:	50                   	push   %eax
 816:	ff 75 08             	pushl  0x8(%ebp)
 819:	e8 31 fe ff ff       	call   64f <putc>
 81e:	83 c4 10             	add    $0x10,%esp
          s++;
 821:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 825:	8b 45 f4             	mov    -0xc(%ebp),%eax
 828:	0f b6 00             	movzbl (%eax),%eax
 82b:	84 c0                	test   %al,%al
 82d:	75 da                	jne    809 <printf+0xe3>
 82f:	eb 65                	jmp    896 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 831:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 835:	75 1d                	jne    854 <printf+0x12e>
        putc(fd, *ap);
 837:	8b 45 e8             	mov    -0x18(%ebp),%eax
 83a:	8b 00                	mov    (%eax),%eax
 83c:	0f be c0             	movsbl %al,%eax
 83f:	83 ec 08             	sub    $0x8,%esp
 842:	50                   	push   %eax
 843:	ff 75 08             	pushl  0x8(%ebp)
 846:	e8 04 fe ff ff       	call   64f <putc>
 84b:	83 c4 10             	add    $0x10,%esp
        ap++;
 84e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 852:	eb 42                	jmp    896 <printf+0x170>
      } else if(c == '%'){
 854:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 858:	75 17                	jne    871 <printf+0x14b>
        putc(fd, c);
 85a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 85d:	0f be c0             	movsbl %al,%eax
 860:	83 ec 08             	sub    $0x8,%esp
 863:	50                   	push   %eax
 864:	ff 75 08             	pushl  0x8(%ebp)
 867:	e8 e3 fd ff ff       	call   64f <putc>
 86c:	83 c4 10             	add    $0x10,%esp
 86f:	eb 25                	jmp    896 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 871:	83 ec 08             	sub    $0x8,%esp
 874:	6a 25                	push   $0x25
 876:	ff 75 08             	pushl  0x8(%ebp)
 879:	e8 d1 fd ff ff       	call   64f <putc>
 87e:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 881:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 884:	0f be c0             	movsbl %al,%eax
 887:	83 ec 08             	sub    $0x8,%esp
 88a:	50                   	push   %eax
 88b:	ff 75 08             	pushl  0x8(%ebp)
 88e:	e8 bc fd ff ff       	call   64f <putc>
 893:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 896:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 89d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8a1:	8b 55 0c             	mov    0xc(%ebp),%edx
 8a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a7:	01 d0                	add    %edx,%eax
 8a9:	0f b6 00             	movzbl (%eax),%eax
 8ac:	84 c0                	test   %al,%al
 8ae:	0f 85 94 fe ff ff    	jne    748 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8b4:	90                   	nop
 8b5:	c9                   	leave  
 8b6:	c3                   	ret    

000008b7 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8b7:	55                   	push   %ebp
 8b8:	89 e5                	mov    %esp,%ebp
 8ba:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8bd:	8b 45 08             	mov    0x8(%ebp),%eax
 8c0:	83 e8 08             	sub    $0x8,%eax
 8c3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c6:	a1 18 0e 00 00       	mov    0xe18,%eax
 8cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8ce:	eb 24                	jmp    8f4 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d3:	8b 00                	mov    (%eax),%eax
 8d5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8d8:	77 12                	ja     8ec <free+0x35>
 8da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8dd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8e0:	77 24                	ja     906 <free+0x4f>
 8e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e5:	8b 00                	mov    (%eax),%eax
 8e7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8ea:	77 1a                	ja     906 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ef:	8b 00                	mov    (%eax),%eax
 8f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8fa:	76 d4                	jbe    8d0 <free+0x19>
 8fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ff:	8b 00                	mov    (%eax),%eax
 901:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 904:	76 ca                	jbe    8d0 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 906:	8b 45 f8             	mov    -0x8(%ebp),%eax
 909:	8b 40 04             	mov    0x4(%eax),%eax
 90c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 913:	8b 45 f8             	mov    -0x8(%ebp),%eax
 916:	01 c2                	add    %eax,%edx
 918:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91b:	8b 00                	mov    (%eax),%eax
 91d:	39 c2                	cmp    %eax,%edx
 91f:	75 24                	jne    945 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 921:	8b 45 f8             	mov    -0x8(%ebp),%eax
 924:	8b 50 04             	mov    0x4(%eax),%edx
 927:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92a:	8b 00                	mov    (%eax),%eax
 92c:	8b 40 04             	mov    0x4(%eax),%eax
 92f:	01 c2                	add    %eax,%edx
 931:	8b 45 f8             	mov    -0x8(%ebp),%eax
 934:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 937:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93a:	8b 00                	mov    (%eax),%eax
 93c:	8b 10                	mov    (%eax),%edx
 93e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 941:	89 10                	mov    %edx,(%eax)
 943:	eb 0a                	jmp    94f <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 945:	8b 45 fc             	mov    -0x4(%ebp),%eax
 948:	8b 10                	mov    (%eax),%edx
 94a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 94f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 952:	8b 40 04             	mov    0x4(%eax),%eax
 955:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 95c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95f:	01 d0                	add    %edx,%eax
 961:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 964:	75 20                	jne    986 <free+0xcf>
    p->s.size += bp->s.size;
 966:	8b 45 fc             	mov    -0x4(%ebp),%eax
 969:	8b 50 04             	mov    0x4(%eax),%edx
 96c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96f:	8b 40 04             	mov    0x4(%eax),%eax
 972:	01 c2                	add    %eax,%edx
 974:	8b 45 fc             	mov    -0x4(%ebp),%eax
 977:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 97a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97d:	8b 10                	mov    (%eax),%edx
 97f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 982:	89 10                	mov    %edx,(%eax)
 984:	eb 08                	jmp    98e <free+0xd7>
  } else
    p->s.ptr = bp;
 986:	8b 45 fc             	mov    -0x4(%ebp),%eax
 989:	8b 55 f8             	mov    -0x8(%ebp),%edx
 98c:	89 10                	mov    %edx,(%eax)
  freep = p;
 98e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 991:	a3 18 0e 00 00       	mov    %eax,0xe18
}
 996:	90                   	nop
 997:	c9                   	leave  
 998:	c3                   	ret    

00000999 <morecore>:

static Header*
morecore(uint nu)
{
 999:	55                   	push   %ebp
 99a:	89 e5                	mov    %esp,%ebp
 99c:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 99f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9a6:	77 07                	ja     9af <morecore+0x16>
    nu = 4096;
 9a8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9af:	8b 45 08             	mov    0x8(%ebp),%eax
 9b2:	c1 e0 03             	shl    $0x3,%eax
 9b5:	83 ec 0c             	sub    $0xc,%esp
 9b8:	50                   	push   %eax
 9b9:	e8 79 fc ff ff       	call   637 <sbrk>
 9be:	83 c4 10             	add    $0x10,%esp
 9c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9c4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9c8:	75 07                	jne    9d1 <morecore+0x38>
    return 0;
 9ca:	b8 00 00 00 00       	mov    $0x0,%eax
 9cf:	eb 26                	jmp    9f7 <morecore+0x5e>
  hp = (Header*)p;
 9d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9da:	8b 55 08             	mov    0x8(%ebp),%edx
 9dd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e3:	83 c0 08             	add    $0x8,%eax
 9e6:	83 ec 0c             	sub    $0xc,%esp
 9e9:	50                   	push   %eax
 9ea:	e8 c8 fe ff ff       	call   8b7 <free>
 9ef:	83 c4 10             	add    $0x10,%esp
  return freep;
 9f2:	a1 18 0e 00 00       	mov    0xe18,%eax
}
 9f7:	c9                   	leave  
 9f8:	c3                   	ret    

000009f9 <malloc>:

void*
malloc(uint nbytes)
{
 9f9:	55                   	push   %ebp
 9fa:	89 e5                	mov    %esp,%ebp
 9fc:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9ff:	8b 45 08             	mov    0x8(%ebp),%eax
 a02:	83 c0 07             	add    $0x7,%eax
 a05:	c1 e8 03             	shr    $0x3,%eax
 a08:	83 c0 01             	add    $0x1,%eax
 a0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a0e:	a1 18 0e 00 00       	mov    0xe18,%eax
 a13:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a1a:	75 23                	jne    a3f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a1c:	c7 45 f0 10 0e 00 00 	movl   $0xe10,-0x10(%ebp)
 a23:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a26:	a3 18 0e 00 00       	mov    %eax,0xe18
 a2b:	a1 18 0e 00 00       	mov    0xe18,%eax
 a30:	a3 10 0e 00 00       	mov    %eax,0xe10
    base.s.size = 0;
 a35:	c7 05 14 0e 00 00 00 	movl   $0x0,0xe14
 a3c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a42:	8b 00                	mov    (%eax),%eax
 a44:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4a:	8b 40 04             	mov    0x4(%eax),%eax
 a4d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a50:	72 4d                	jb     a9f <malloc+0xa6>
      if(p->s.size == nunits)
 a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a55:	8b 40 04             	mov    0x4(%eax),%eax
 a58:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a5b:	75 0c                	jne    a69 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a60:	8b 10                	mov    (%eax),%edx
 a62:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a65:	89 10                	mov    %edx,(%eax)
 a67:	eb 26                	jmp    a8f <malloc+0x96>
      else {
        p->s.size -= nunits;
 a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6c:	8b 40 04             	mov    0x4(%eax),%eax
 a6f:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a72:	89 c2                	mov    %eax,%edx
 a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a77:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7d:	8b 40 04             	mov    0x4(%eax),%eax
 a80:	c1 e0 03             	shl    $0x3,%eax
 a83:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a89:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a8c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a92:	a3 18 0e 00 00       	mov    %eax,0xe18
      return (void*)(p + 1);
 a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9a:	83 c0 08             	add    $0x8,%eax
 a9d:	eb 3b                	jmp    ada <malloc+0xe1>
    }
    if(p == freep)
 a9f:	a1 18 0e 00 00       	mov    0xe18,%eax
 aa4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 aa7:	75 1e                	jne    ac7 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 aa9:	83 ec 0c             	sub    $0xc,%esp
 aac:	ff 75 ec             	pushl  -0x14(%ebp)
 aaf:	e8 e5 fe ff ff       	call   999 <morecore>
 ab4:	83 c4 10             	add    $0x10,%esp
 ab7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 aba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 abe:	75 07                	jne    ac7 <malloc+0xce>
        return 0;
 ac0:	b8 00 00 00 00       	mov    $0x0,%eax
 ac5:	eb 13                	jmp    ada <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aca:	89 45 f0             	mov    %eax,-0x10(%ebp)
 acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad0:	8b 00                	mov    (%eax),%eax
 ad2:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ad5:	e9 6d ff ff ff       	jmp    a47 <malloc+0x4e>
}
 ada:	c9                   	leave  
 adb:	c3                   	ret    
