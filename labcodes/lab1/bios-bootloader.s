# **************************************************************************
#      从答案导出的qumu执行的bios和bootloader指令
# **************************************************************************


# ************************* 注意事项 ****************************************
#  1.bootloader的起始地址为 0x00007c00 ,大约在19000行附近,可与bootams.S对比
#  2.BIOS启动过程:https://chyyuu.gitbooks.io/ucore_os_docs/content/lab1/lab1_3_1_bios_booting.html
#
# **************************************************************************


----------------
IN:
# 这是80386下
# 注意第一条指令地址0xfffffff0,这段空间属于BIOS ROM
# 虽然刚开机处于实模式,但是仍然按照32位保护模式的方式计算
# 第一条长跳转指令,触发CS寄存器的隐藏部分被修改,开始使用16为位保护模式的地址计算方式16*CS+IP 
# ...之后回到早期的8086初始化控制流,从而向下兼容
# 更多参考lab1文档 => BIOS启动过程:https://chyyuu.gitbooks.io/ucore_os_docs/content/lab1/lab1_3_1_bios_booting.html
0xfffffff0:  ljmp   $0xf000,$0xe05b 

----------------
IN: 
0x000fe05b:  cmpl   $0x0,%cs:0x6c48
0x000fe062:  jne    0xfd2e1

----------------
IN: 
0x000fe066:  xor    %dx,%dx
0x000fe068:  mov    %dx,%ss

----------------
IN: 
0x000fe06a:  mov    $0x7000,%esp

----------------
IN: 
0x000fe070:  mov    $0xf3691,%edx
0x000fe076:  jmp    0xfd165

----------------
IN: 
0x000fd165:  mov    %eax,%ecx
0x000fd168:  cli    
0x000fd169:  cld    
0x000fd16a:  mov    $0x8f,%eax
0x000fd170:  out    %al,$0x70
0x000fd172:  in     $0x71,%al
0x000fd174:  in     $0x92,%al
0x000fd176:  or     $0x2,%al
0x000fd178:  out    %al,$0x92
0x000fd17a:  lidtw  %cs:0x6c38
0x000fd180:  lgdtw  %cs:0x6bf4
0x000fd186:  mov    %cr0,%eax
0x000fd189:  or     $0x1,%eax
0x000fd18d:  mov    %eax,%cr0

----------------
IN: 
0x000fd190:  ljmpl  $0x8,$0xfd198

----------------
IN: 
0x000fd198:  mov    $0x10,%eax
0x000fd19d:  mov    %eax,%ds

----------------
IN: 
0x000fd19f:  mov    %eax,%es

----------------
IN: 
0x000fd1a1:  mov    %eax,%ss

----------------
IN: 
0x000fd1a3:  mov    %eax,%fs

----------------
IN: 
0x000fd1a5:  mov    %eax,%gs
0x000fd1a7:  mov    %ecx,%eax
0x000fd1a9:  jmp    *%edx

----------------
IN: 
0x000f3691:  push   %ebx
0x000f3692:  sub    $0x20,%esp
0x000f3695:  push   $0xf5cf8
0x000f369a:  push   $0xf4770
0x000f369f:  call   0xf0cc9

----------------
IN: 
0x000f0cc9:  lea    0x8(%esp),%ecx
0x000f0ccd:  mov    0x4(%esp),%edx
0x000f0cd1:  mov    $0xf5cf4,%eax
0x000f0cd6:  call   0xf0854

----------------
IN: 
0x000f0854:  push   %ebp
0x000f0855:  push   %edi
0x000f0856:  push   %esi
0x000f0857:  push   %ebx
0x000f0858:  sub    $0x8,%esp
0x000f085b:  mov    %eax,%edi
0x000f085d:  mov    %edx,%esi
0x000f085f:  mov    %ecx,%ebp
0x000f0861:  movsbl (%esi),%edx
0x000f0864:  test   %dl,%dl
0x000f0866:  je     0xf0a72

----------------
IN: 
0x000f086c:  cmp    $0x25,%dl
0x000f086f:  jne    0xf0991

----------------
IN: 
0x000f0991:  mov    %edi,%eax
0x000f0993:  call   0xeff40

----------------
IN: 
0x000eff40:  mov    %eax,%ecx
0x000eff42:  movsbl %dl,%edx
0x000eff45:  call   *(%ecx)

----------------
IN: 
0x000eff35:  mov    %edx,%eax
0x000eff37:  mov    0xf6abc,%dx
0x000eff3e:  out    %al,(%dx)
0x000eff3f:  ret    

----------------
IN: 
0x000eff47:  ret    

----------------
IN: 
0x000f0998:  jmp    0xf099c

----------------
IN: 
0x000f099c:  inc    %esi
0x000f099d:  jmp    0xf0861

----------------
IN: 
0x000f0861:  movsbl (%esi),%edx
0x000f0864:  test   %dl,%dl
0x000f0866:  je     0xf0a72

----------------
IN: 
0x000f0875:  lea    0x1(%esi),%ebx
0x000f0878:  movb   $0x20,(%esp)
0x000f087c:  xor    %ecx,%ecx
0x000f087e:  movsbl (%ebx),%eax
0x000f0881:  lea    -0x30(%eax),%edx
0x000f0884:  cmp    $0x9,%dl
0x000f0887:  ja     0xf08a3

----------------
IN: 
0x000f08a3:  mov    %ebx,%edx
0x000f08a5:  cmp    $0x6c,%al
0x000f08a7:  jne    0xf09a2

----------------
IN: 
0x000f09a2:  cmp    $0x64,%al
0x000f09a4:  jne    0xf08f2

----------------
IN: 
0x000f08f2:  jle    0xf09c9

----------------
IN: 
0x000f08f8:  cmp    $0x73,%al
0x000f08fa:  je     0xf0972

----------------
IN: 
0x000f0972:  mov    %ebx,%esi
0x000f0974:  lea    0x4(%ebp),%ebx
0x000f0977:  mov    0x0(%ebp),%ebp
0x000f097a:  movsbl 0x0(%ebp),%edx
0x000f097e:  test   %dl,%dl
0x000f0980:  je     0xf099a

----------------
IN: 
0x000f0982:  mov    %edi,%eax
0x000f0984:  call   0xeff40

----------------
IN: 
0x000f0989:  inc    %ebp
0x000f098a:  jmp    0xf097a

----------------
IN: 
0x000f097a:  movsbl 0x0(%ebp),%edx
0x000f097e:  test   %dl,%dl
0x000f0980:  je     0xf099a

----------------
IN: 
0x000f099a:  mov    %ebx,%ebp
0x000f099c:  inc    %esi
0x000f099d:  jmp    0xf0861

----------------
IN: 
0x000f0a72:  add    $0x8,%esp
0x000f0a75:  pop    %ebx
0x000f0a76:  pop    %esi
0x000f0a77:  pop    %edi
0x000f0a78:  pop    %ebp
0x000f0a79:  ret    

----------------
IN: 
0x000f0cdb:  ret    

----------------
IN: 
0x000f36a4:  pop    %ebx
0x000f36a5:  pop    %eax
0x000f36a6:  mov    $0x40000000,%ebx
0x000f36ab:  lea    0xc(%esp),%eax
0x000f36af:  push   %eax
0x000f36b0:  lea    0xc(%esp),%eax
0x000f36b4:  push   %eax
0x000f36b5:  lea    0xc(%esp),%ecx
0x000f36b9:  lea    0x8(%esp),%edx
0x000f36bd:  mov    %ebx,%eax
0x000f36bf:  call   0xf01be

----------------
IN: 
0x000f01be:  push   %ebp
0x000f01bf:  push   %edi
0x000f01c0:  push   %esi
0x000f01c1:  push   %ebx
0x000f01c2:  mov    %edx,%esi
0x000f01c4:  mov    %ecx,%edi
0x000f01c6:  mov    0x14(%esp),%ebp
0x000f01ca:  pushf  
0x000f01cb:  pop    %edx
0x000f01cc:  mov    %edx,%ecx
0x000f01ce:  xor    $0x200000,%ecx
0x000f01d4:  push   %ecx
0x000f01d5:  popf   

----------------
IN: 
0x000f01d6:  pushf  
0x000f01d7:  pop    %ecx
0x000f01d8:  push   %edx
0x000f01d9:  popf   

----------------
IN: 
0x000f01da:  xor    %ecx,%edx
0x000f01dc:  and    $0x200000,%edx
0x000f01e2:  jne    0xf0203

----------------
IN: 
0x000f0203:  cpuid  
0x000f0205:  mov    %eax,(%esi)
0x000f0207:  mov    %ebx,(%edi)
0x000f0209:  mov    %ecx,0x0(%ebp)
0x000f020c:  mov    0x18(%esp),%eax
0x000f0210:  mov    %edx,(%eax)
0x000f0212:  pop    %ebx
0x000f0213:  pop    %esi
0x000f0214:  pop    %edi
0x000f0215:  pop    %ebp
0x000f0216:  ret    

----------------
IN: 
0x000f36c4:  mov    0xc(%esp),%eax
0x000f36c8:  mov    %eax,0x1b(%esp)
0x000f36cc:  mov    0x10(%esp),%eax
0x000f36d0:  mov    %eax,0x1f(%esp)
0x000f36d4:  mov    0x14(%esp),%eax
0x000f36d8:  mov    %eax,0x23(%esp)
0x000f36dc:  movb   $0x0,0x27(%esp)
0x000f36e1:  mov    $0xf5a98,%edx
0x000f36e6:  lea    0x1b(%esp),%eax
0x000f36ea:  call   0xf0070

----------------
IN: 
0x000f0070:  push   %ebx
0x000f0071:  xor    %ecx,%ecx
0x000f0073:  mov    (%eax,%ecx,1),%bl
0x000f0076:  cmp    (%edx,%ecx,1),%bl
0x000f0079:  je     0xf0087

----------------
IN: 
0x000f007b:  setge  %al
0x000f007e:  movzbl %al,%eax
0x000f0081:  lea    -0x1(%eax,%eax,1),%eax
0x000f0085:  jmp    0xf008e

----------------
IN: 
0x000f008e:  pop    %ebx
0x000f008f:  ret    

----------------
IN: 
0x000f36ef:  pop    %edx
0x000f36f0:  pop    %ecx
0x000f36f1:  test   %eax,%eax
0x000f36f3:  jne    0xf373c

----------------
IN: 
0x000f373c:  add    $0x100,%ebx
0x000f3742:  cmp    $0x40010000,%ebx
0x000f3748:  jne    0xf36ab

----------------
IN: 
0x000f36ab:  lea    0xc(%esp),%eax
0x000f36af:  push   %eax
0x000f36b0:  lea    0xc(%esp),%eax
0x000f36b4:  push   %eax
0x000f36b5:  lea    0xc(%esp),%ecx
0x000f36b9:  lea    0x8(%esp),%edx
0x000f36bd:  mov    %ebx,%eax
0x000f36bf:  call   0xf01be

----------------
IN: 
0x000f374e:  cmpl   $0x0,0xf5d10
0x000f3755:  jne    0xf3764

----------------
IN: 
0x000f3757:  push   $0xf5afe
0x000f375c:  call   0xf0cc9

----------------
IN: 
0x000f3761:  pop    %eax
0x000f3762:  jmp    0xf376e

----------------
IN: 
0x000f376e:  testb  $0x2,0xf67a0
0x000f3775:  jne    0xf377c

----------------
IN: 
0x000f3777:  call   0xf2d3f

----------------
IN: 
0x000f2d3f:  push   %esi
0x000f2d40:  push   %ebx
0x000f2d41:  xor    %edx,%edx
0x000f2d43:  or     $0xffffffff,%eax
0x000f2d46:  call   0xf0165

----------------
IN: 
0x000f0165:  push   %esi
0x000f0166:  push   %ebx
0x000f0167:  mov    %eax,%ebx
0x000f0169:  mov    %edx,%esi
0x000f016b:  test   $0x7,%al
0x000f016d:  jne    0xf01a0

----------------
IN: 
0x000f01a0:  inc    %ebx
0x000f01a1:  jmp    0xf0183

----------------
IN: 
0x000f0183:  movzbl %bh,%eax
0x000f0186:  cmp    %esi,%eax
0x000f0188:  jne    0xf01a3

----------------
IN: 
0x000f018a:  movzwl %bx,%eax
0x000f018d:  xor    %edx,%edx
0x000f018f:  call   0xf010e

----------------
IN: 
0x000f010e:  push   %ebx
0x000f010f:  mov    %eax,%ebx
0x000f0111:  mov    %edx,%ecx
0x000f0113:  mov    %edx,%eax
0x000f0115:  and    $0xfc,%eax
0x000f011a:  or     $0x80000000,%eax
0x000f011f:  movzwl %bx,%ebx
0x000f0122:  shl    $0x8,%ebx
0x000f0125:  or     %ebx,%eax
0x000f0127:  mov    $0xcf8,%edx
0x000f012c:  out    %eax,(%dx)
0x000f012d:  and    $0x2,%ecx
0x000f0130:  lea    0xcfc(%ecx),%edx
0x000f0136:  in     (%dx),%ax
0x000f0138:  pop    %ebx
0x000f0139:  ret    

----------------
IN: 
0x000f0194:  dec    %eax
0x000f0195:  cmp    $0xfffffffd,%ax
0x000f0199:  jbe    0xf01a8

----------------
IN: 
0x000f01a8:  mov    %ebx,%eax
0x000f01aa:  pop    %ebx
0x000f01ab:  pop    %esi
0x000f01ac:  ret    

----------------
IN: 
0x000f2d4b:  mov    %eax,%ebx
0x000f2d4d:  test   %eax,%eax
0x000f2d4f:  js     0xf2da0

----------------
IN: 
0x000f2d51:  movzwl %bx,%esi
0x000f2d54:  xor    %edx,%edx
0x000f2d56:  mov    %esi,%eax
0x000f2d58:  call   0xf00ee

----------------
IN: 
0x000f00ee:  mov    %eax,%ecx
0x000f00f0:  mov    %edx,%eax
0x000f00f2:  and    $0xfc,%eax
0x000f00f7:  or     $0x80000000,%eax
0x000f00fc:  movzwl %cx,%ecx
0x000f00ff:  shl    $0x8,%ecx
0x000f0102:  or     %ecx,%eax
0x000f0104:  mov    $0xcf8,%edx
0x000f0109:  out    %eax,(%dx)
0x000f010a:  mov    $0xfc,%dl
0x000f010c:  in     (%dx),%eax
0x000f010d:  ret    

----------------
IN: 
0x000f2d5d:  mov    %eax,%edx
0x000f2d5f:  shr    $0x10,%edx
0x000f2d62:  cmp    $0x8086,%ax
0x000f2d66:  sete   %al
0x000f2d69:  cmp    $0x1237,%edx
0x000f2d6f:  jne    0xf2d7b

----------------
IN: 
0x000f2d71:  test   %al,%al
0x000f2d73:  je     0xf2d7b

----------------
IN: 
0x000f2d75:  mov    $0x59,%dx
0x000f2d79:  jmp    0xf2d8b

----------------
IN: 
0x000f2d8b:  mov    %esi,%eax
0x000f2d8d:  call   0xf054b

----------------
IN: 
0x000f054b:  push   %esi
0x000f054c:  push   %ebx
0x000f054d:  mov    %edx,%esi
0x000f054f:  movzwl %ax,%ebx
0x000f0552:  mov    %ebx,%eax
0x000f0554:  call   0xf013a

----------------
IN: 
0x000f013a:  push   %ebx
0x000f013b:  mov    %eax,%ebx
0x000f013d:  mov    %edx,%ecx
0x000f013f:  mov    %edx,%eax
0x000f0141:  and    $0xfc,%eax
0x000f0146:  or     $0x80000000,%eax
0x000f014b:  movzwl %bx,%ebx
0x000f014e:  shl    $0x8,%ebx
0x000f0151:  or     %ebx,%eax
0x000f0153:  mov    $0xcf8,%edx
0x000f0158:  out    %eax,(%dx)
0x000f0159:  and    $0x3,%ecx
0x000f015c:  lea    0xcfc(%ecx),%edx
0x000f0162:  in     (%dx),%al
0x000f0163:  pop    %ebx
0x000f0164:  ret    

----------------
IN: 
0x000f0559:  mov    %esi,%edx
0x000f055b:  test   $0x10,%al
0x000f055d:  mov    %ebx,%eax
0x000f055f:  jne    0xf056b

----------------
IN: 
0x000f0561:  mov    $0xffff04e8,%ecx
0x000f0566:  call   *%ecx

----------------
IN: 
0xffff04e8:  push   %ebp
0xffff04e9:  push   %edi
0xffff04ea:  push   %esi
0xffff04eb:  push   %ebx
0xffff04ec:  mov    %edx,%edi
0xffff04ee:  lea    0x1(%edx),%esi
0xffff04f1:  lea    0x7(%edx),%ebp
0xffff04f4:  movzwl %ax,%ebx
0xffff04f7:  mov    %esi,%edx
0xffff04f9:  mov    %ebx,%eax
0xffff04fb:  call   0xffff013a

----------------
IN: 
0xffff013a:  push   %ebx
0xffff013b:  mov    %eax,%ebx
0xffff013d:  mov    %edx,%ecx
0xffff013f:  mov    %edx,%eax
0xffff0141:  and    $0xfc,%eax
0xffff0146:  or     $0x80000000,%eax
0xffff014b:  movzwl %bx,%ebx
0xffff014e:  shl    $0x8,%ebx
0xffff0151:  or     %ebx,%eax
0xffff0153:  mov    $0xcf8,%edx
0xffff0158:  out    %eax,(%dx)
0xffff0159:  and    $0x3,%ecx
0xffff015c:  lea    0xcfc(%ecx),%edx
0xffff0162:  in     (%dx),%al
0xffff0163:  pop    %ebx
0xffff0164:  ret    

----------------
IN: 
0xffff0500:  mov    $0x33,%ecx
0xffff0505:  mov    %esi,%edx
0xffff0507:  mov    %ebx,%eax
0xffff0509:  call   0xffff00bf

----------------
IN: 
0xffff00bf:  push   %esi
0xffff00c0:  push   %ebx
0xffff00c1:  mov    %eax,%ebx
0xffff00c3:  mov    %edx,%esi
0xffff00c5:  mov    %edx,%eax
0xffff00c7:  and    $0xfc,%eax
0xffff00cc:  or     $0x80000000,%eax
0xffff00d1:  movzwl %bx,%ebx
0xffff00d4:  shl    $0x8,%ebx
0xffff00d7:  or     %ebx,%eax
0xffff00d9:  mov    $0xcf8,%edx
0xffff00de:  out    %eax,(%dx)
0xffff00df:  and    $0x3,%esi
0xffff00e2:  lea    0xcfc(%esi),%edx
0xffff00e8:  mov    %cl,%al
0xffff00ea:  out    %al,(%dx)
0xffff00eb:  pop    %ebx
0xffff00ec:  pop    %esi
0xffff00ed:  ret    

----------------
IN: 
0xffff050e:  inc    %esi
0xffff050f:  cmp    %ebp,%esi
0xffff0511:  jne    0xffff04f7

----------------
IN: 
0xffff04f7:  mov    %esi,%edx
0xffff04f9:  mov    %ebx,%eax
0xffff04fb:  call   0xffff013a

----------------
IN: 
0xffff0513:  mov    %edi,%edx
0xffff0515:  mov    %ebx,%eax
0xffff0517:  call   0xffff013a

----------------
IN: 
0xffff051c:  mov    %eax,%esi
0xffff051e:  mov    $0x30,%ecx
0xffff0523:  mov    %edi,%edx
0xffff0525:  mov    %ebx,%eax
0xffff0527:  call   0xffff00bf

----------------
IN: 
0xffff052c:  and    $0x10,%esi
0xffff052f:  jne    0xffff0546

----------------
IN: 
0xffff0531:  mov    $0xddbb8,%eax
0xffff0536:  mov    $0x100000,%ecx
0xffff053b:  sub    %eax,%ecx
0xffff053d:  mov    $0xfffddbb8,%esi
0xffff0542:  mov    %eax,%edi
0xffff0544:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0xffff0544:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0xffff0546:  pop    %ebx
0xffff0547:  pop    %esi
0xffff0548:  pop    %edi
0xffff0549:  pop    %ebp
0xffff054a:  ret    

----------------
IN: 
0x000f0568:  pop    %ebx
0x000f0569:  pop    %esi
0x000f056a:  ret    

----------------
IN: 
0x000f2d92:  mov    %ebx,0xf5ce4
0x000f2d98:  jmp    0xf2dab

----------------
IN: 
0x000f2dab:  pop    %ebx
0x000f2dac:  pop    %esi
0x000f2dad:  ret    

----------------
IN: 
0x000f377c:  call   0xedb74

----------------
IN: 
0x000edb74:  push   %ebp
0x000edb75:  push   %edi
0x000edb76:  push   %esi
0x000edb77:  push   %ebx
0x000edb78:  sub    $0x24,%esp
0x000edb7b:  mov    $0xcf8,%edx
0x000edb80:  mov    $0x80000000,%eax
0x000edb85:  out    %eax,(%dx)
0x000edb86:  mov    $0xcfc,%ebp
0x000edb8b:  mov    %ebp,%edx
0x000edb8d:  in     (%dx),%ax
0x000edb8f:  mov    %eax,%ebx
0x000edb91:  lea    -0x1(%ebx),%eax
0x000edb94:  cmp    $0xfffffffd,%ax
0x000edb98:  ja     0xedc7a

----------------
IN: 
0x000edb9e:  mov    $0xcf8,%esi
0x000edba3:  mov    $0x80000000,%eax
0x000edba8:  mov    %esi,%edx
0x000edbaa:  out    %eax,(%dx)
0x000edbab:  mov    $0xfe,%dl
0x000edbad:  in     (%dx),%ax
0x000edbaf:  movzwl %ax,%ecx
0x000edbb2:  mov    $0x8000002c,%edi
0x000edbb7:  mov    %edi,%eax
0x000edbb9:  mov    %esi,%edx
0x000edbbb:  out    %eax,(%dx)
0x000edbbc:  mov    %ebp,%edx
0x000edbbe:  in     (%dx),%ax
0x000edbc0:  mov    %eax,%ebp
0x000edbc2:  mov    %edi,%eax
0x000edbc4:  mov    %esi,%edx
0x000edbc6:  out    %eax,(%dx)
0x000edbc7:  mov    $0xfe,%dl
0x000edbc9:  in     (%dx),%ax
0x000edbcb:  cmp    $0x1100,%ax
0x000edbcf:  jne    0xedc7a

----------------
IN: 
0x000edbd5:  cmp    $0x1af4,%bp
0x000edbda:  jne    0xedc7a

----------------
IN: 
0x000edbe0:  orl    $0x1,0xf67a0
0x000edbe7:  cmp    $0x1237,%cx
0x000edbec:  je     0xedbfc

----------------
IN: 
0x000edbfc:  push   $0xf595f
0x000edc01:  call   0xf0cc9

----------------
IN: 
0x000f0cc9:  lea    0x8(%esp),%ecx
0x000f0ccd:  mov    0x4(%esp),%edx
0x000f0cd1:  mov    $0xf5cf4,%eax
0x000f0cd6:  call   0xf0854

----------------
IN: 
0x000f0854:  push   %ebp
0x000f0855:  push   %edi
0x000f0856:  push   %esi
0x000f0857:  push   %ebx
0x000f0858:  sub    $0x8,%esp
0x000f085b:  mov    %eax,%edi
0x000f085d:  mov    %edx,%esi
0x000f085f:  mov    %ecx,%ebp
0x000f0861:  movsbl (%esi),%edx
0x000f0864:  test   %dl,%dl
0x000f0866:  je     0xf0a72

----------------
IN: 
0x000f086c:  cmp    $0x25,%dl
0x000f086f:  jne    0xf0991

----------------
IN: 
0x000f0991:  mov    %edi,%eax
0x000f0993:  call   0xeff40

----------------
IN: 
0x000eff40:  mov    %eax,%ecx
0x000eff42:  movsbl %dl,%edx
0x000eff45:  call   *(%ecx)

----------------
IN: 
0x000eff35:  mov    %edx,%eax
0x000eff37:  mov    0xf6abc,%dx
0x000eff3e:  out    %al,(%dx)
0x000eff3f:  ret    

----------------
IN: 
0x000eff47:  ret    

----------------
IN: 
0x000f0998:  jmp    0xf099c

----------------
IN: 
0x000f099c:  inc    %esi
0x000f099d:  jmp    0xf0861

----------------
IN: 
0x000f0861:  movsbl (%esi),%edx
0x000f0864:  test   %dl,%dl
0x000f0866:  je     0xf0a72

----------------
IN: 
0x000f0a72:  add    $0x8,%esp
0x000f0a75:  pop    %ebx
0x000f0a76:  pop    %esi
0x000f0a77:  pop    %edi
0x000f0a78:  pop    %ebp
0x000f0a79:  ret    

----------------
IN: 
0x000f0cdb:  ret    

----------------
IN: 
0x000edc06:  pop    %esi
0x000edc07:  jmp    0xedc1b

----------------
IN: 
0x000edc1b:  lea    0x10(%esp),%eax
0x000edc1f:  push   %eax
0x000edc20:  lea    0x10(%esp),%eax
0x000edc24:  push   %eax
0x000edc25:  lea    0x10(%esp),%ecx
0x000edc29:  lea    0xc(%esp),%edx
0x000edc2d:  mov    $0x40000000,%eax
0x000edc32:  call   0xf01be

----------------
IN: 
0x000f01be:  push   %ebp
0x000f01bf:  push   %edi
0x000f01c0:  push   %esi
0x000f01c1:  push   %ebx
0x000f01c2:  mov    %edx,%esi
0x000f01c4:  mov    %ecx,%edi
0x000f01c6:  mov    0x14(%esp),%ebp
0x000f01ca:  pushf  
0x000f01cb:  pop    %edx
0x000f01cc:  mov    %edx,%ecx
0x000f01ce:  xor    $0x200000,%ecx
0x000f01d4:  push   %ecx
0x000f01d5:  popf   

----------------
IN: 
0x000f01d6:  pushf  
0x000f01d7:  pop    %ecx
0x000f01d8:  push   %edx
0x000f01d9:  popf   

----------------
IN: 
0x000f01da:  xor    %ecx,%edx
0x000f01dc:  and    $0x200000,%edx
0x000f01e2:  jne    0xf0203

----------------
IN: 
0x000f0203:  cpuid  
0x000f0205:  mov    %eax,(%esi)
0x000f0207:  mov    %ebx,(%edi)
0x000f0209:  mov    %ecx,0x0(%ebp)
0x000f020c:  mov    0x18(%esp),%eax
0x000f0210:  mov    %edx,(%eax)
0x000f0212:  pop    %ebx
0x000f0213:  pop    %esi
0x000f0214:  pop    %edi
0x000f0215:  pop    %ebp
0x000f0216:  ret    

----------------
IN: 
0x000edc37:  mov    0x10(%esp),%eax
0x000edc3b:  mov    %eax,0x1f(%esp)
0x000edc3f:  mov    0x14(%esp),%eax
0x000edc43:  mov    %eax,0x23(%esp)
0x000edc47:  mov    0x18(%esp),%eax
0x000edc4b:  mov    %eax,0x27(%esp)
0x000edc4f:  movb   $0x0,0x2b(%esp)
0x000edc54:  mov    $0xf59b9,%edx
0x000edc59:  lea    0x1f(%esp),%eax
0x000edc5d:  call   0xf0070

----------------
IN: 
0x000f0070:  push   %ebx
0x000f0071:  xor    %ecx,%ecx
0x000f0073:  mov    (%eax,%ecx,1),%bl
0x000f0076:  cmp    (%edx,%ecx,1),%bl
0x000f0079:  je     0xf0087

----------------
IN: 
0x000f007b:  setge  %al
0x000f007e:  movzbl %al,%eax
0x000f0081:  lea    -0x1(%eax,%eax,1),%eax
0x000f0085:  jmp    0xf008e

----------------
IN: 
0x000f008e:  pop    %ebx
0x000f008f:  ret    

----------------
IN: 
0x000edc62:  pop    %ecx
0x000edc63:  pop    %ebx
0x000edc64:  test   %eax,%eax
0x000edc66:  jne    0xedc7a

----------------
IN: 
0x000edc7a:  testb  $0x2,0xf67a0
0x000edc81:  je     0xedd0f

----------------
IN: 
0x000edd0f:  mov    $0xb4,%al
0x000edd11:  out    %al,$0x70
0x000edd13:  in     $0x71,%al
0x000edd15:  movzbl %al,%ecx
0x000edd18:  mov    $0xb5,%al
0x000edd1a:  out    %al,$0x70
0x000edd1c:  in     $0x71,%al
0x000edd1e:  shl    $0x18,%eax
0x000edd21:  shl    $0x10,%ecx
0x000edd24:  mov    %ecx,%edx
0x000edd26:  or     %eax,%edx
0x000edd28:  je     0xedd32

----------------
IN: 
0x000edd2a:  lea    0x1000000(%edx),%eax
0x000edd30:  jmp    0xedd51

----------------
IN: 
0x000edd51:  mov    %eax,0xefed8
0x000edd56:  push   $0x1
0x000edd58:  xor    %edx,%edx
0x000edd5a:  push   %edx
0x000edd5b:  push   %eax
0x000edd5c:  xor    %eax,%eax
0x000edd5e:  xor    %edx,%edx
0x000edd60:  call   0xe17e4

----------------
IN: 
0x000e17e4:  push   %edi
0x000e17e5:  push   %esi
0x000e17e6:  push   %ebx
0x000e17e7:  mov    0x10(%esp),%ebx
0x000e17eb:  mov    0x14(%esp),%ecx
0x000e17ef:  mov    %ecx,%edi
0x000e17f1:  or     %ebx,%edi
0x000e17f3:  je     0xe17fd

----------------
IN: 
0x000e17f5:  pop    %ebx
0x000e17f6:  pop    %esi
0x000e17f7:  pop    %edi
0x000e17f8:  jmp    0xe1609

----------------
IN: 
0x000e1609:  push   %ebp
0x000e160a:  push   %edi
0x000e160b:  push   %esi
0x000e160c:  push   %ebx
0x000e160d:  sub    $0x24,%esp
0x000e1610:  mov    %eax,0x8(%esp)
0x000e1614:  mov    %edx,0xc(%esp)
0x000e1618:  mov    0x38(%esp),%eax
0x000e161c:  mov    0x3c(%esp),%edx
0x000e1620:  mov    %eax,0x18(%esp)
0x000e1624:  mov    %edx,0x1c(%esp)
0x000e1628:  mov    0x40(%esp),%eax
0x000e162c:  mov    %eax,0x20(%esp)
0x000e1630:  mov    0x8(%esp),%eax
0x000e1634:  mov    0xc(%esp),%edx
0x000e1638:  add    0x18(%esp),%eax
0x000e163c:  adc    0x1c(%esp),%edx
0x000e1640:  mov    %eax,(%esp)
0x000e1643:  mov    %edx,0x4(%esp)
0x000e1647:  mov    0xf67c4,%esi
0x000e164d:  mov    $0xf67c8,%ecx
0x000e1652:  xor    %ebx,%ebx
0x000e1654:  cmp    %esi,%ebx
0x000e1656:  jge    0xe1720

----------------
IN: 
0x000e1720:  imul   $0x14,%ebx,%esi
0x000e1723:  cmp    0xf67c4,%ebx
0x000e1729:  jge    0xe17a7

----------------
IN: 
0x000e17a7:  cmpl   $0xffffffff,0x20(%esp)
0x000e17ac:  je     0xe17dc

----------------
IN: 
0x000e17ae:  mov    0x20(%esp),%eax
0x000e17b2:  mov    %eax,0x40(%esp)
0x000e17b6:  mov    0x18(%esp),%eax
0x000e17ba:  mov    0x1c(%esp),%edx
0x000e17be:  mov    %eax,0x38(%esp)
0x000e17c2:  mov    %edx,0x3c(%esp)
0x000e17c6:  mov    0x8(%esp),%edx
0x000e17ca:  mov    0xc(%esp),%ecx
0x000e17ce:  mov    %ebx,%eax
0x000e17d0:  add    $0x24,%esp
0x000e17d3:  pop    %ebx
0x000e17d4:  pop    %esi
0x000e17d5:  pop    %edi
0x000e17d6:  pop    %ebp
0x000e17d7:  jmp    0xe1575

----------------
IN: 
0x000e1575:  push   %ebp
0x000e1576:  push   %edi
0x000e1577:  push   %esi
0x000e1578:  push   %ebx
0x000e1579:  sub    $0xc,%esp
0x000e157c:  mov    0x20(%esp),%edi
0x000e1580:  mov    0x24(%esp),%ebp
0x000e1584:  mov    0x28(%esp),%esi
0x000e1588:  mov    %esi,(%esp)
0x000e158b:  mov    0xf67c4,%ebx
0x000e1591:  cmp    $0x1f,%ebx
0x000e1594:  jle    0xe15ac

----------------
IN: 
0x000e15ac:  mov    %edx,0x4(%esp)
0x000e15b0:  mov    %ecx,0x8(%esp)
0x000e15b4:  sub    %eax,%ebx
0x000e15b6:  imul   $0x14,%ebx,%ecx
0x000e15b9:  imul   $0x14,%eax,%ebx
0x000e15bc:  lea    0xf67c8(%ebx),%esi
0x000e15c2:  inc    %eax
0x000e15c3:  imul   $0x14,%eax,%eax
0x000e15c6:  add    $0xf67c8,%eax
0x000e15cb:  mov    %esi,%edx
0x000e15cd:  call   0xe01b0

----------------
IN: 
0x000e01b0:  push   %edi
0x000e01b1:  push   %esi
0x000e01b2:  push   %ebx
0x000e01b3:  cmp    %eax,%edx
0x000e01b5:  jb     0xe01bf

----------------
IN: 
0x000e01bf:  lea    -0x1(%eax,%ecx,1),%esi
0x000e01c3:  mov    %ecx,%ebx
0x000e01c5:  mov    %esi,%edi
0x000e01c7:  sub    %ecx,%edi
0x000e01c9:  dec    %ebx
0x000e01ca:  cmp    $0xffffffff,%ebx
0x000e01cd:  je     0xe01d8

----------------
IN: 
0x000e01d8:  mov    %esi,%eax
0x000e01da:  sub    %ecx,%eax
0x000e01dc:  pop    %ebx
0x000e01dd:  pop    %esi
0x000e01de:  pop    %edi
0x000e01df:  ret    

----------------
IN: 
0x000e15d2:  incl   0xf67c4
0x000e15d8:  mov    0x4(%esp),%eax
0x000e15dc:  mov    0x8(%esp),%edx
0x000e15e0:  mov    %eax,0xf67c8(%ebx)
0x000e15e6:  mov    %edx,0xf67cc(%ebx)
0x000e15ec:  mov    %edi,0xf67d0(%ebx)
0x000e15f2:  mov    %ebp,0xf67d4(%ebx)
0x000e15f8:  mov    (%esp),%eax
0x000e15fb:  mov    %eax,0xf67d8(%ebx)
0x000e1601:  add    $0xc,%esp
0x000e1604:  pop    %ebx
0x000e1605:  pop    %esi
0x000e1606:  pop    %edi
0x000e1607:  pop    %ebp
0x000e1608:  ret    

----------------
IN: 
0x000edd65:  push   $0x2
0x000edd67:  push   $0x0
0x000edd69:  push   $0x40000
0x000edd6e:  mov    $0xfffc0000,%eax
0x000edd73:  xor    %edx,%edx
0x000edd75:  call   0xe1609

----------------
IN: 
0x000e165c:  mov    (%ecx),%eax
0x000e165e:  mov    0x4(%ecx),%edx
0x000e1661:  mov    %eax,%edi
0x000e1663:  mov    %edx,%ebp
0x000e1665:  add    0x8(%ecx),%edi
0x000e1668:  adc    0xc(%ecx),%ebp
0x000e166b:  mov    %edi,0x10(%esp)
0x000e166f:  mov    %ebp,0x14(%esp)
0x000e1673:  add    $0x14,%ecx
0x000e1676:  mov    0x14(%esp),%edi
0x000e167a:  cmp    %edi,0xc(%esp)
0x000e167e:  jb     0xe168f

----------------
IN: 
0x000e1680:  ja     0xe168c

----------------
IN: 
0x000e1682:  mov    0x10(%esp),%edi
0x000e1686:  cmp    %edi,0x8(%esp)
0x000e168a:  jbe    0xe168f

----------------
IN: 
0x000e168c:  inc    %ebx
0x000e168d:  jmp    0xe1654

----------------
IN: 
0x000e1654:  cmp    %esi,%ebx
0x000e1656:  jge    0xe1720

----------------
IN: 
0x000edd7a:  pushl  0xefed8
0x000edd80:  push   $0xf5a38
0x000edd85:  call   0xf0cc9

----------------
IN: 
0x000f0875:  lea    0x1(%esi),%ebx
0x000f0878:  movb   $0x20,(%esp)
0x000f087c:  xor    %ecx,%ecx
0x000f087e:  movsbl (%ebx),%eax
0x000f0881:  lea    -0x30(%eax),%edx
0x000f0884:  cmp    $0x9,%dl
0x000f0887:  ja     0xf08a3

----------------
IN: 
0x000f0889:  cmp    $0x30,%al
0x000f088b:  jne    0xf0891

----------------
IN: 
0x000f088d:  test   %ecx,%ecx
0x000f088f:  je     0xf089a

----------------
IN: 
0x000f089a:  movb   $0x30,(%esp)
0x000f089e:  xor    %ecx,%ecx
0x000f08a0:  inc    %ebx
0x000f08a1:  jmp    0xf087e

----------------
IN: 
0x000f087e:  movsbl (%ebx),%eax
0x000f0881:  lea    -0x30(%eax),%edx
0x000f0884:  cmp    $0x9,%dl
0x000f0887:  ja     0xf08a3

----------------
IN: 
0x000f0891:  imul   $0xa,%ecx,%edx
0x000f0894:  lea    -0x30(%edx,%eax,1),%ecx
0x000f0898:  jmp    0xf08a0

----------------
IN: 
0x000f08a0:  inc    %ebx
0x000f08a1:  jmp    0xf087e

----------------
IN: 
0x000f08a3:  mov    %ebx,%edx
0x000f08a5:  cmp    $0x6c,%al
0x000f08a7:  jne    0xf09a2

----------------
IN: 
0x000f09a2:  cmp    $0x64,%al
0x000f09a4:  jne    0xf08f2

----------------
IN: 
0x000f08f2:  jle    0xf09c9

----------------
IN: 
0x000f08f8:  cmp    $0x73,%al
0x000f08fa:  je     0xf0972

----------------
IN: 
0x000f08fc:  jle    0xf0a2e

----------------
IN: 
0x000f0902:  cmp    $0x75,%al
0x000f0904:  jne    0xf0922

----------------
IN: 
0x000f0922:  cmp    $0x78,%al
0x000f0924:  jne    0xf098c

----------------
IN: 
0x000f0926:  mov    %ebx,%esi
0x000f0928:  xor    %eax,%eax
0x000f092a:  mov    0x0(%ebp),%ebx
0x000f092d:  mov    %ebx,0x4(%esp)
0x000f0931:  test   %al,%al
0x000f0933:  movsbl (%esp),%eax
0x000f0937:  je     0xf0960

----------------
IN: 
0x000f0960:  lea    0x4(%ebp),%ebx
0x000f0963:  push   %eax
0x000f0964:  mov    0x8(%esp),%edx
0x000f0968:  mov    %edi,%eax
0x000f096a:  call   0xf0029

----------------
IN: 
0x000f0029:  push   %ebp
0x000f002a:  push   %edi
0x000f002b:  push   %esi
0x000f002c:  push   %ebx
0x000f002d:  push   %esi
0x000f002e:  mov    %eax,%edi
0x000f0030:  mov    %edx,%ebp
0x000f0032:  mov    0x18(%esp),%dl
0x000f0036:  mov    %ebp,%eax
0x000f0038:  mov    $0x1,%esi
0x000f003d:  shr    $0x4,%eax
0x000f0040:  je     0xf0045

----------------
IN: 
0x000f0042:  inc    %esi
0x000f0043:  jmp    0xf003d

----------------
IN: 
0x000f003d:  shr    $0x4,%eax
0x000f0040:  je     0xf0045

----------------
IN: 
0x000f0045:  mov    %ecx,%ebx
0x000f0047:  sub    %esi,%ebx
0x000f0049:  movsbl %dl,%eax
0x000f004c:  mov    %eax,(%esp)
0x000f004f:  test   %ebx,%ebx
0x000f0051:  jle    0xf0060

----------------
IN: 
0x000f0053:  mov    (%esp),%edx
0x000f0056:  mov    %edi,%eax
0x000f0058:  call   0xeff40

----------------
IN: 
0x000f005d:  dec    %ebx
0x000f005e:  jmp    0xf004f

----------------
IN: 
0x000f004f:  test   %ebx,%ebx
0x000f0051:  jle    0xf0060

----------------
IN: 
0x000f0060:  mov    %esi,%ecx
0x000f0062:  mov    %ebp,%edx
0x000f0064:  mov    %edi,%eax
0x000f0066:  pop    %ebx
0x000f0067:  pop    %ebx
0x000f0068:  pop    %esi
0x000f0069:  pop    %edi
0x000f006a:  pop    %ebp
0x000f006b:  jmp    0xeffa6

----------------
IN: 
0x000effa6:  push   %esi
0x000effa7:  push   %ebx
0x000effa8:  mov    %eax,%esi
0x000effaa:  mov    %edx,%ebx
0x000effac:  dec    %ecx
0x000effad:  cmp    $0x6,%ecx
0x000effb0:  ja     0xeffb9

----------------
IN: 
0x000effb2:  jmp    *0xf5b9c(,%ecx,4)

----------------
IN: 
0x000effc1:  mov    %ebx,%edx
0x000effc3:  shr    $0x18,%edx
0x000effc6:  and    $0xf,%edx
0x000effc9:  mov    %esi,%eax
0x000effcb:  call   0xeff93

----------------
IN: 
0x000eff93:  lea    0x57(%edx),%ecx
0x000eff96:  cmp    $0x9,%edx
0x000eff99:  ja     0xeff9e

----------------
IN: 
0x000eff9b:  lea    0x30(%edx),%ecx
0x000eff9e:  movsbl %cl,%edx
0x000effa1:  jmp    0xeff40

----------------
IN: 
0x000effd0:  mov    %ebx,%edx
0x000effd2:  shr    $0x14,%edx
0x000effd5:  and    $0xf,%edx
0x000effd8:  mov    %esi,%eax
0x000effda:  call   0xeff93

----------------
IN: 
0x000effdf:  mov    %ebx,%edx
0x000effe1:  shr    $0x10,%edx
0x000effe4:  and    $0xf,%edx
0x000effe7:  mov    %esi,%eax
0x000effe9:  call   0xeff93

----------------
IN: 
0x000effee:  mov    %ebx,%edx
0x000efff0:  shr    $0xc,%edx
0x000efff3:  and    $0xf,%edx
0x000efff6:  mov    %esi,%eax
0x000efff8:  call   0xeff93

----------------
IN: 
0x000efffd:  mov    %ebx,%edx
0x000effff:  shr    $0x8,%edx
0x000f0002:  and    $0xf,%edx
0x000f0005:  mov    %esi,%eax
0x000f0007:  call   0xeff93

----------------
IN: 
0x000f000c:  mov    %ebx,%edx
0x000f000e:  shr    $0x4,%edx
0x000f0011:  and    $0xf,%edx
0x000f0014:  mov    %esi,%eax
0x000f0016:  call   0xeff93

----------------
IN: 
0x000f001b:  and    $0xf,%ebx
0x000f001e:  mov    %ebx,%edx
0x000f0020:  mov    %esi,%eax
0x000f0022:  pop    %ebx
0x000f0023:  pop    %esi
0x000f0024:  jmp    0xeff93

----------------
IN: 
0x000f096f:  pop    %ecx
0x000f0970:  jmp    0xf099a

----------------
IN: 
0x000f099a:  mov    %ebx,%ebp
0x000f099c:  inc    %esi
0x000f099d:  jmp    0xf0861

----------------
IN: 
0x000edd8a:  add    $0x20,%esp
0x000edd8d:  push   $0xffffffff
0x000edd8f:  push   $0x0
0x000edd91:  push   $0x50000
0x000edd96:  mov    $0xa0000,%eax
0x000edd9b:  xor    %edx,%edx
0x000edd9d:  call   0xe1609

----------------
IN: 
0x000e168f:  cmp    %edx,0xc(%esp)
0x000e1693:  jb     0xe1720

----------------
IN: 
0x000e1699:  ja     0xe16a1

----------------
IN: 
0x000e169b:  cmp    %eax,0x8(%esp)
0x000e169f:  jbe    0xe1720

----------------
IN: 
0x000e16a1:  imul   $0x14,%ebx,%esi
0x000e16a4:  mov    0xf67d8(%esi),%ecx
0x000e16aa:  cmp    %ecx,0x20(%esp)
0x000e16ae:  jne    0xe16cd

----------------
IN: 
0x000e16cd:  mov    0x8(%esp),%edi
0x000e16d1:  mov    0xc(%esp),%ebp
0x000e16d5:  sub    %eax,%edi
0x000e16d7:  sbb    %edx,%ebp
0x000e16d9:  mov    %edi,0xf67d0(%esi)
0x000e16df:  mov    %ebp,0xf67d4(%esi)
0x000e16e5:  inc    %ebx
0x000e16e6:  mov    0x4(%esp),%eax
0x000e16ea:  cmp    %eax,0x14(%esp)
0x000e16ee:  jb     0xe1720

----------------
IN: 
0x000e16f0:  ja     0xe16fb

----------------
IN: 
0x000e16f2:  mov    (%esp),%eax
0x000e16f5:  cmp    %eax,0x10(%esp)
0x000e16f9:  jbe    0xe1720

----------------
IN: 
0x000e16fb:  push   %ecx
0x000e16fc:  mov    0x14(%esp),%eax
0x000e1700:  mov    0x18(%esp),%edx
0x000e1704:  sub    0x4(%esp),%eax
0x000e1708:  sbb    0x8(%esp),%edx
0x000e170c:  push   %edx
0x000e170d:  push   %eax
0x000e170e:  mov    0xc(%esp),%edx
0x000e1712:  mov    0x10(%esp),%ecx
0x000e1716:  mov    %ebx,%eax
0x000e1718:  call   0xe1575

----------------
IN: 
0x000e01cf:  mov    (%edx,%ebx,1),%al
0x000e01d2:  mov    %al,0x1(%edi,%ebx,1)
0x000e01d6:  jmp    0xe01c9

----------------
IN: 
0x000e01c9:  dec    %ebx
0x000e01ca:  cmp    $0xffffffff,%ebx
0x000e01cd:  je     0xe01d8

----------------
IN: 
0x000e171d:  add    $0xc,%esp
0x000e1720:  imul   $0x14,%ebx,%esi
0x000e1723:  cmp    0xf67c4,%ebx
0x000e1729:  jge    0xe17a7

----------------
IN: 
0x000e172b:  mov    0xf67c8(%esi),%eax
0x000e1731:  mov    0xf67cc(%esi),%edx
0x000e1737:  cmp    %edx,0x4(%esp)
0x000e173b:  jb     0xe17a7

----------------
IN: 
0x000e173d:  ja     0xe1744

----------------
IN: 
0x000e173f:  cmp    %eax,(%esp)
0x000e1742:  jb     0xe17a7

----------------
IN: 
0x000e1744:  add    0xf67d0(%esi),%eax
0x000e174a:  adc    0xf67d4(%esi),%edx
0x000e1750:  cmp    %edx,0x4(%esp)
0x000e1754:  jb     0xe1766

----------------
IN: 
0x000e1756:  ja     0xe175d

----------------
IN: 
0x000e1758:  cmp    %eax,(%esp)
0x000e175b:  jb     0xe1766

----------------
IN: 
0x000e1766:  imul   $0x14,%ebx,%ecx
0x000e1769:  mov    (%esp),%esi
0x000e176c:  mov    0x4(%esp),%edi
0x000e1770:  mov    %esi,0xf67c8(%ecx)
0x000e1776:  mov    %edi,0xf67cc(%ecx)
0x000e177c:  sub    %esi,%eax
0x000e177e:  sbb    %edi,%edx
0x000e1780:  mov    %eax,0xf67d0(%ecx)
0x000e1786:  mov    %edx,0xf67d4(%ecx)
0x000e178c:  mov    0x20(%esp),%esi
0x000e1790:  cmp    0xf67d8(%ecx),%esi
0x000e1796:  jne    0xe17a7

----------------
IN: 
0x000e17dc:  add    $0x24,%esp
0x000e17df:  pop    %ebx
0x000e17e0:  pop    %esi
0x000e17e1:  pop    %edi
0x000e17e2:  pop    %ebp
0x000e17e3:  ret    

----------------
IN: 
0x000edda2:  push   $0x2
0x000edda4:  push   $0x0
0x000edda6:  push   $0x10000
0x000eddab:  mov    $0xf0000,%eax
0x000eddb0:  xor    %edx,%edx
0x000eddb2:  call   0xe1609

----------------
IN: 
0x000eddb7:  mov    0xf67c4,%ebx
0x000eddbd:  lea    -0x1(%ebx),%eax
0x000eddc0:  mov    %eax,0x18(%esp)
0x000eddc4:  imul   $0x14,%ebx,%ebx
0x000eddc7:  add    $0xf67c8,%ebx
0x000eddcd:  add    $0x18,%esp
0x000eddd0:  xor    %esi,%esi
0x000eddd2:  cmpl   $0x0,(%esp)
0x000eddd6:  js     0xeddf5

----------------
IN: 
0x000eddd8:  mov    -0x14(%ebx),%eax
0x000edddb:  mov    -0x10(%ebx),%edx
0x000eddde:  mov    %eax,%edi
0x000edde0:  mov    %edx,%ebp
0x000edde2:  add    -0xc(%ebx),%edi
0x000edde5:  adc    -0x8(%ebx),%ebp
0x000edde8:  cmp    $0x0,%ebp
0x000eddeb:  ja     0xede36

----------------
IN: 
0x000ede36:  cmp    $0x0,%ebp
0x000ede39:  ja     0xede68

----------------
IN: 
0x000ede68:  decl   (%esp)
0x000ede6b:  sub    $0x14,%ebx
0x000ede6e:  jmp    0xeddd2

----------------
IN: 
0x000eddd2:  cmpl   $0x0,(%esp)
0x000eddd6:  js     0xeddf5

----------------
IN: 
0x000edded:  cmp    $0xfffff,%edi
0x000eddf3:  ja     0xede36

----------------
IN: 
0x000ede3b:  cmpl   $0x1,-0x4(%ebx)
0x000ede3f:  jne    0xede68

----------------
IN: 
0x000ede41:  mov    %edi,%ecx
0x000ede43:  test   %esi,%esi
0x000ede45:  jne    0xede5c

----------------
IN: 
0x000ede47:  lea    -0x40000(%edi),%edx
0x000ede4d:  and    $0xfffffff0,%edx
0x000ede50:  cmp    %eax,%edx
0x000ede52:  jb     0xede5c

----------------
IN: 
0x000ede54:  cmp    %edi,%edx
0x000ede56:  ja     0xede5c

----------------
IN: 
0x000ede58:  mov    %edx,%esi
0x000ede5a:  mov    %edx,%ecx
0x000ede5c:  mov    %eax,%edx
0x000ede5e:  mov    $0xefe5c,%eax
0x000ede63:  call   0xe1892

----------------
IN: 
0x000e1892:  push   %ebp
0x000e1893:  push   %edi
0x000e1894:  push   %esi
0x000e1895:  push   %ebx
0x000e1896:  sub    $0x2c,%esp
0x000e1899:  mov    (%eax),%ebx
0x000e189b:  test   %ebx,%ebx
0x000e189d:  jne    0xe18d7

----------------
IN: 
0x000e189f:  mov    %edx,0x20(%esp)
0x000e18a3:  mov    %edx,0x1c(%esp)
0x000e18a7:  mov    %ecx,0x24(%esp)
0x000e18ab:  lea    0x14(%esp),%esi
0x000e18af:  mov    %eax,%edx
0x000e18b1:  mov    %esi,%eax
0x000e18b3:  call   0xdf44f

----------------
IN: 
0x000df44f:  mov    (%edx),%ecx
0x000df451:  mov    %edx,0x4(%eax)
0x000df454:  mov    %ecx,(%eax)
0x000df456:  test   %ecx,%ecx
0x000df458:  je     0xdf45d

----------------
IN: 
0x000df45d:  mov    %eax,(%edx)
0x000df45f:  ret    

----------------
IN: 
0x000e18b8:  push   $0x0
0x000e18ba:  mov    $0x10,%ecx
0x000e18bf:  mov    $0x2c,%edx
0x000e18c4:  mov    $0xefe5c,%eax
0x000e18c9:  call   0xdf790

----------------
IN: 
0x000df790:  push   %ebp
0x000df791:  push   %edi
0x000df792:  push   %esi
0x000df793:  push   %ebx
0x000df794:  mov    0x14(%esp),%edi
0x000df798:  mov    (%eax),%esi
0x000df79a:  neg    %ecx
0x000df79c:  test   %esi,%esi
0x000df79e:  je     0xdf7d8

----------------
IN: 
0x000df7a0:  mov    0x10(%esi),%ebp
0x000df7a3:  mov    %ebp,%ebx
0x000df7a5:  sub    %edx,%ebx
0x000df7a7:  and    %ecx,%ebx
0x000df7a9:  cmp    %ebp,%ebx
0x000df7ab:  ja     0xdf7d4

----------------
IN: 
0x000df7ad:  cmp    0xc(%esi),%ebx
0x000df7b0:  jb     0xdf7d4

----------------
IN: 
0x000df7b2:  test   %edi,%edi
0x000df7b4:  jne    0xdf7b8

----------------
IN: 
0x000df7b6:  mov    %ebx,%edi
0x000df7b8:  mov    %ebx,0x8(%edi)
0x000df7bb:  add    %ebx,%edx
0x000df7bd:  mov    %edx,0xc(%edi)
0x000df7c0:  mov    %ebp,0x10(%edi)
0x000df7c3:  mov    %ebx,0x10(%esi)
0x000df7c6:  mov    0x4(%esi),%edx
0x000df7c9:  mov    %edi,%eax
0x000df7cb:  call   0xdf44f

----------------
IN: 
0x000df45a:  mov    %eax,0x4(%ecx)
0x000df45d:  mov    %eax,(%edx)
0x000df45f:  ret    

----------------
IN: 
0x000df7d0:  mov    %ebx,%eax
0x000df7d2:  jmp    0xdf7da

----------------
IN: 
0x000df7da:  pop    %ebx
0x000df7db:  pop    %esi
0x000df7dc:  pop    %edi
0x000df7dd:  pop    %ebp
0x000df7de:  ret    

----------------
IN: 
0x000e18ce:  mov    %eax,%ebx
0x000e18d0:  pop    %edx
0x000e18d1:  test   %eax,%eax
0x000e18d3:  jne    0xe1917

----------------
IN: 
0x000e1917:  mov    0x18(%esp),%ebp
0x000e191b:  mov    %esi,%eax
0x000e191d:  call   0xdf440

----------------
IN: 
0x000df440:  mov    (%eax),%edx
0x000df442:  mov    0x4(%eax),%eax
0x000df445:  mov    %edx,(%eax)
0x000df447:  test   %edx,%edx
0x000df449:  je     0xdf44e

----------------
IN: 
0x000df44e:  ret    

----------------
IN: 
0x000e1922:  lea    0x14(%ebx),%eax
0x000e1925:  mov    $0x5,%ecx
0x000e192a:  mov    %eax,%edi
0x000e192c:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000e192c:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000e192e:  movl   $0xffffffff,0x28(%ebx)
0x000e1935:  mov    %ebp,%edx
0x000e1937:  call   0xdf44f

----------------
IN: 
0x000e193c:  add    $0x2c,%esp
0x000e193f:  pop    %ebx
0x000e1940:  pop    %esi
0x000e1941:  pop    %edi
0x000e1942:  pop    %ebp
0x000e1943:  ret    

----------------
IN: 
0x000eddf5:  mov    $0x90000,%ecx
0x000eddfa:  mov    $0x7000,%edx
0x000eddff:  mov    $0xefe60,%eax
0x000ede04:  call   0xe1892

----------------
IN: 
0x000df7d4:  mov    (%esi),%esi
0x000df7d6:  jmp    0xdf79c

----------------
IN: 
0x000df79c:  test   %esi,%esi
0x000df79e:  je     0xdf7d8

----------------
IN: 
0x000ede09:  test   %esi,%esi
0x000ede0b:  je     0xede73

----------------
IN: 
0x000ede0d:  lea    0x40000(%esi),%ecx
0x000ede13:  mov    %esi,%edx
0x000ede15:  mov    $0xefe68,%eax
0x000ede1a:  call   0xe1892

----------------
IN: 
0x000ede1f:  mov    %esi,%eax
0x000ede21:  xor    %edx,%edx
0x000ede23:  push   $0x2
0x000ede25:  push   $0x0
0x000ede27:  push   $0x40000
0x000ede2c:  call   0xe1609

----------------
IN: 
0x000ede31:  add    $0xc,%esp
0x000ede34:  jmp    0xede73

----------------
IN: 
0x000ede73:  mov    $0xdf440,%esi
0x000ede78:  mov    $0xeff00,%ebx
0x000ede7d:  sub    %esi,%ebx
0x000ede7f:  mov    %ebx,%edx
0x000ede81:  mov    $0x10,%eax
0x000ede86:  call   0xe09ac

----------------
IN: 
0x000e09ac:  push   %esi
0x000e09ad:  push   %ebx
0x000e09ae:  mov    %eax,%esi
0x000e09b0:  mov    %edx,%ebx
0x000e09b2:  mov    %eax,%ecx
0x000e09b4:  mov    $0xefe5c,%eax
0x000e09b9:  call   0xdf818

----------------
IN: 
0x000df818:  push   %ebp
0x000df819:  push   %edi
0x000df81a:  push   %esi
0x000df81b:  push   %ebx
0x000df81c:  test   %edx,%edx
0x000df81e:  jne    0xdf824

----------------
IN: 
0x000df824:  mov    %ecx,%edi
0x000df826:  mov    %edx,%ebp
0x000df828:  mov    %eax,%esi
0x000df82a:  push   $0x0
0x000df82c:  mov    $0x10,%ecx
0x000df831:  mov    $0x2c,%edx
0x000df836:  mov    $0xefe5c,%eax
0x000df83b:  call   0xdf790

----------------
IN: 
0x000df840:  mov    %eax,%ebx
0x000df842:  pop    %eax
0x000df843:  test   %ebx,%ebx
0x000df845:  jne    0xdf864

----------------
IN: 
0x000df864:  movl   $0xffffffff,0x28(%ebx)
0x000df86b:  lea    0x14(%ebx),%eax
0x000df86e:  push   %eax
0x000df86f:  mov    %edi,%ecx
0x000df871:  mov    %ebp,%edx
0x000df873:  mov    %esi,%eax
0x000df875:  call   0xdf790

----------------
IN: 
0x000df7b8:  mov    %ebx,0x8(%edi)
0x000df7bb:  add    %ebx,%edx
0x000df7bd:  mov    %edx,0xc(%edi)
0x000df7c0:  mov    %ebp,0x10(%edi)
0x000df7c3:  mov    %ebx,0x10(%esi)
0x000df7c6:  mov    0x4(%esi),%edx
0x000df7c9:  mov    %edi,%eax
0x000df7cb:  call   0xdf44f

----------------
IN: 
0x000df87a:  pop    %edx
0x000df87b:  mov    %eax,%esi
0x000df87d:  test   %eax,%eax
0x000df87f:  jne    0xdf888

----------------
IN: 
0x000df888:  mov    %esi,%eax
0x000df88a:  pop    %ebx
0x000df88b:  pop    %esi
0x000df88c:  pop    %edi
0x000df88d:  pop    %ebp
0x000df88e:  ret    

----------------
IN: 
0x000e09be:  test   %eax,%eax
0x000e09c0:  jne    0xe09d2

----------------
IN: 
0x000e09d2:  pop    %ebx
0x000e09d3:  pop    %esi
0x000e09d4:  ret    

----------------
IN: 
0x000ede8b:  mov    %eax,%ebp
0x000ede8d:  test   %eax,%eax
0x000ede8f:  jne    0xede9b

----------------
IN: 
0x000ede9b:  push   %ebx
0x000ede9c:  push   %eax
0x000ede9d:  push   $0xdf440
0x000edea2:  push   $0xf5a6f
0x000edea7:  call   0xf0cc9

----------------
IN: 
0x000f0a2e:  cmp    $0x70,%al
0x000f0a30:  jne    0xf098c

----------------
IN: 
0x000f0a36:  lea    0x4(%ebp),%eax
0x000f0a39:  mov    %eax,(%esp)
0x000f0a3c:  mov    0x0(%ebp),%esi
0x000f0a3f:  mov    $0x30,%edx
0x000f0a44:  mov    %edi,%eax
0x000f0a46:  call   0xeff40

----------------
IN: 
0x000f0a4b:  mov    $0x78,%edx
0x000f0a50:  mov    %edi,%eax
0x000f0a52:  call   0xeff40

----------------
IN: 
0x000f0a57:  mov    $0x8,%ecx
0x000f0a5c:  mov    %esi,%edx
0x000f0a5e:  mov    %edi,%eax
0x000f0a60:  call   0xeffa6

----------------
IN: 
0x000effb9:  shr    $0x1c,%edx
0x000effbc:  call   0xeff93

----------------
IN: 
0x000eff9e:  movsbl %cl,%edx
0x000effa1:  jmp    0xeff40

----------------
IN: 
0x000f0a65:  jmp    0xf0a0e

----------------
IN: 
0x000f0a0e:  mov    %ebx,%esi
0x000f0a10:  mov    (%esp),%ebp
0x000f0a13:  jmp    0xf099c

----------------
IN: 
0x000f09aa:  mov    0x0(%ebp),%esi
0x000f09ad:  add    $0x4,%ebp
0x000f09b0:  test   %esi,%esi
0x000f09b2:  jns    0xf09c2

----------------
IN: 
0x000f09c2:  mov    %esi,%edx
0x000f09c4:  jmp    0xf0912

----------------
IN: 
0x000f0912:  mov    %edi,%eax
0x000f0914:  call   0xeff48

----------------
IN: 
0x000eff48:  push   %edi
0x000eff49:  push   %esi
0x000eff4a:  push   %ebx
0x000eff4b:  sub    $0xc,%esp
0x000eff4e:  mov    %eax,%esi
0x000eff50:  movb   $0x0,0xb(%esp)
0x000eff55:  lea    0xa(%esp),%ebx
0x000eff59:  mov    $0xa,%edi
0x000eff5e:  mov    %edx,%eax
0x000eff60:  xor    %edx,%edx
0x000eff62:  div    %edi
0x000eff64:  add    $0x30,%edx
0x000eff67:  mov    %dl,(%ebx)
0x000eff69:  mov    %eax,%edx
0x000eff6b:  test   %eax,%eax
0x000eff6d:  je     0xeff72

----------------
IN: 
0x000eff6f:  dec    %ebx
0x000eff70:  jmp    0xeff5e

----------------
IN: 
0x000eff5e:  mov    %edx,%eax
0x000eff60:  xor    %edx,%edx
0x000eff62:  div    %edi
0x000eff64:  add    $0x30,%edx
0x000eff67:  mov    %dl,(%ebx)
0x000eff69:  mov    %eax,%edx
0x000eff6b:  test   %eax,%eax
0x000eff6d:  je     0xeff72

----------------
IN: 
0x000eff72:  test   %ebx,%ebx
0x000eff74:  jne    0xeff7b

----------------
IN: 
0x000eff7b:  movsbl (%ebx),%edx
0x000eff7e:  test   %dl,%dl
0x000eff80:  je     0xeff8c

----------------
IN: 
0x000eff82:  mov    %esi,%eax
0x000eff84:  call   0xeff40

----------------
IN: 
0x000eff89:  inc    %ebx
0x000eff8a:  jmp    0xeff7b

----------------
IN: 
0x000eff8c:  add    $0xc,%esp
0x000eff8f:  pop    %ebx
0x000eff90:  pop    %esi
0x000eff91:  pop    %edi
0x000eff92:  ret    

----------------
IN: 
0x000f0919:  mov    %ebx,%esi
0x000f091b:  jmp    0xf099c

----------------
IN: 
0x000edeac:  mov    %ebp,%edx
0x000edeae:  sub    $0xdf440,%edx
0x000edeb4:  mov    %ebp,%edi
0x000edeb6:  mov    %ebx,%ecx
0x000edeb8:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000edeb8:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000edeba:  add    $0x10,%esp
0x000edebd:  mov    $0xddbb8,%eax
0x000edec2:  cmp    $0xde210,%eax
0x000edec7:  jae    0xeded4

----------------
IN: 
0x000edec9:  mov    (%eax),%ecx
0x000edecb:  add    %ebp,%ecx
0x000edecd:  add    %edx,(%ecx)
0x000edecf:  add    $0x4,%eax
0x000eded2:  jmp    0xedec2

----------------
IN: 
0x000edec2:  cmp    $0xde210,%eax
0x000edec7:  jae    0xeded4

----------------
IN: 
0x000eded4:  mov    %edx,%ebx
0x000eded6:  neg    %ebx
0x000eded8:  mov    $0xde210,%eax
0x000ededd:  cmp    $0xdeba8,%eax
0x000edee2:  jae    0xedeef

----------------
IN: 
0x000edee4:  mov    (%eax),%ecx
0x000edee6:  add    %ebp,%ecx
0x000edee8:  add    %ebx,(%ecx)
0x000edeea:  add    $0x4,%eax
0x000edeed:  jmp    0xededd

----------------
IN: 
0x000ededd:  cmp    $0xdeba8,%eax
0x000edee2:  jae    0xedeef

----------------
IN: 
0x000edeef:  mov    $0xdeba8,%eax
0x000edef4:  cmp    $0xdebc0,%eax
0x000edef9:  jae    0xedf08

----------------
IN: 
0x000edefb:  mov    (%eax),%ecx
0x000edefd:  add    %edx,0xddbb8(%ecx)
0x000edf03:  add    $0x4,%eax
0x000edf06:  jmp    0xedef4

----------------
IN: 
0x000edef4:  cmp    $0xdebc0,%eax
0x000edef9:  jae    0xedf08

----------------
IN: 
0x000edf08:  mov    $0xead91,%eax
0x000edf0d:  cmp    $0xdf440,%eax
0x000edf12:  jb     0xedf1d

----------------
IN: 
0x000edf14:  add    %eax,%edx
0x000edf16:  cmp    $0xeff00,%eax
0x000edf1b:  jb     0xedf22

----------------
IN: 
0x000edf22:  xor    %eax,%eax
0x000edf24:  call   *%edx

----------------
IN: 
0x07fbadd1:  xor    %eax,%eax
0x07fbadd3:  mov    0x7fbfe88(,%eax,4),%ecx
0x07fbadda:  mov    (%ecx),%edx
0x07fbaddc:  test   %edx,%edx
0x07fbadde:  je     0x7fbade3

----------------
IN: 
0x07fbade0:  mov    %ecx,0x4(%edx)
0x07fbade3:  inc    %eax
0x07fbade4:  cmp    $0x5,%eax
0x07fbade7:  jne    0x7fbadd3

----------------
IN: 
0x07fbadd3:  mov    0x7fbfe88(,%eax,4),%ecx
0x07fbadda:  mov    (%ecx),%edx
0x07fbaddc:  test   %edx,%edx
0x07fbadde:  je     0x7fbade3

----------------
IN: 
0x07fbade3:  inc    %eax
0x07fbade4:  cmp    $0x5,%eax
0x07fbade7:  jne    0x7fbadd3

----------------
IN: 
0x07fbade9:  push   %ebp
0x07fbadea:  push   %edi
0x07fbadeb:  push   %esi
0x07fbadec:  push   %ebx
0x07fbaded:  sub    $0x16c,%esp
0x07fbadf3:  mov    $0xdf440,%ecx
0x07fbadf8:  sub    $0xdebc0,%ecx
0x07fbadfe:  mov    $0xdebc0,%edx
0x07fbae03:  mov    $0xef680,%eax
0x07fbae08:  call   0x7fb01f0

----------------
IN: 
0x07fb01f0:  push   %edi
0x07fb01f1:  push   %esi
0x07fb01f2:  push   %ebx
0x07fb01f3:  cmp    %eax,%edx
0x07fb01f5:  jb     0x7fb01ff

----------------
IN: 
0x07fb01ff:  lea    -0x1(%eax,%ecx,1),%esi
0x07fb0203:  mov    %ecx,%ebx
0x07fb0205:  mov    %esi,%edi
0x07fb0207:  sub    %ecx,%edi
0x07fb0209:  dec    %ebx
0x07fb020a:  cmp    $0xffffffff,%ebx
0x07fb020d:  je     0x7fb0218

----------------
IN: 
0x07fb020f:  mov    (%edx,%ebx,1),%al
0x07fb0212:  mov    %al,0x1(%edi,%ebx,1)
0x07fb0216:  jmp    0x7fb0209

----------------
IN: 
0x07fb0209:  dec    %ebx
0x07fb020a:  cmp    $0xffffffff,%ebx
0x07fb020d:  je     0x7fb0218

----------------
IN: 
0x07fb0218:  mov    %esi,%eax
0x07fb021a:  sub    %ecx,%eax
0x07fb021c:  pop    %ebx
0x07fb021d:  pop    %esi
0x07fb021e:  pop    %edi
0x07fb021f:  ret    

----------------
IN: 
0x07fbae0d:  mov    $0xef680,%ecx
0x07fbae12:  mov    $0xe0010,%edx
0x07fbae17:  mov    $0x7fbfeac,%eax
0x07fbae1c:  call   0x7fb18d2

----------------
IN: 
0x07fb18d2:  push   %ebp
0x07fb18d3:  push   %edi
0x07fb18d4:  push   %esi
0x07fb18d5:  push   %ebx
0x07fb18d6:  sub    $0x2c,%esp
0x07fb18d9:  mov    (%eax),%ebx
0x07fb18db:  test   %ebx,%ebx
0x07fb18dd:  jne    0x7fb1917

----------------
IN: 
0x07fb18df:  mov    %edx,0x20(%esp)
0x07fb18e3:  mov    %edx,0x1c(%esp)
0x07fb18e7:  mov    %ecx,0x24(%esp)
0x07fb18eb:  lea    0x14(%esp),%esi
0x07fb18ef:  mov    %eax,%edx
0x07fb18f1:  mov    %esi,%eax
0x07fb18f3:  call   0x7faf48f

----------------
IN: 
0x07faf48f:  mov    (%edx),%ecx
0x07faf491:  mov    %edx,0x4(%eax)
0x07faf494:  mov    %ecx,(%eax)
0x07faf496:  test   %ecx,%ecx
0x07faf498:  je     0x7faf49d

----------------
IN: 
0x07faf49d:  mov    %eax,(%edx)
0x07faf49f:  ret    

----------------
IN: 
0x07fb18f8:  push   $0x0
0x07fb18fa:  mov    $0x10,%ecx
0x07fb18ff:  mov    $0x2c,%edx
0x07fb1904:  mov    $0x7fbfe9c,%eax
0x07fb1909:  call   0x7faf7d0

----------------
IN: 
0x07faf7d0:  push   %ebp
0x07faf7d1:  push   %edi
0x07faf7d2:  push   %esi
0x07faf7d3:  push   %ebx
0x07faf7d4:  mov    0x14(%esp),%edi
0x07faf7d8:  mov    (%eax),%esi
0x07faf7da:  neg    %ecx
0x07faf7dc:  test   %esi,%esi
0x07faf7de:  je     0x7faf818

----------------
IN: 
0x07faf7e0:  mov    0x10(%esi),%ebp
0x07faf7e3:  mov    %ebp,%ebx
0x07faf7e5:  sub    %edx,%ebx
0x07faf7e7:  and    %ecx,%ebx
0x07faf7e9:  cmp    %ebp,%ebx
0x07faf7eb:  ja     0x7faf814

----------------
IN: 
0x07faf7ed:  cmp    0xc(%esi),%ebx
0x07faf7f0:  jb     0x7faf814

----------------
IN: 
0x07faf814:  mov    (%esi),%esi
0x07faf816:  jmp    0x7faf7dc

----------------
IN: 
0x07faf7dc:  test   %esi,%esi
0x07faf7de:  je     0x7faf818

----------------
IN: 
0x07faf7f2:  test   %edi,%edi
0x07faf7f4:  jne    0x7faf7f8

----------------
IN: 
0x07faf7f6:  mov    %ebx,%edi
0x07faf7f8:  mov    %ebx,0x8(%edi)
0x07faf7fb:  add    %ebx,%edx
0x07faf7fd:  mov    %edx,0xc(%edi)
0x07faf800:  mov    %ebp,0x10(%edi)
0x07faf803:  mov    %ebx,0x10(%esi)
0x07faf806:  mov    0x4(%esi),%edx
0x07faf809:  mov    %edi,%eax
0x07faf80b:  call   0x7faf48f

----------------
IN: 
0x07faf49a:  mov    %eax,0x4(%ecx)
0x07faf49d:  mov    %eax,(%edx)
0x07faf49f:  ret    

----------------
IN: 
0x07faf810:  mov    %ebx,%eax
0x07faf812:  jmp    0x7faf81a

----------------
IN: 
0x07faf81a:  pop    %ebx
0x07faf81b:  pop    %esi
0x07faf81c:  pop    %edi
0x07faf81d:  pop    %ebp
0x07faf81e:  ret    

----------------
IN: 
0x07fb190e:  mov    %eax,%ebx
0x07fb1910:  pop    %edx
0x07fb1911:  test   %eax,%eax
0x07fb1913:  jne    0x7fb1957

----------------
IN: 
0x07fb1957:  mov    0x18(%esp),%ebp
0x07fb195b:  mov    %esi,%eax
0x07fb195d:  call   0x7faf480

----------------
IN: 
0x07faf480:  mov    (%eax),%edx
0x07faf482:  mov    0x4(%eax),%eax
0x07faf485:  mov    %edx,(%eax)
0x07faf487:  test   %edx,%edx
0x07faf489:  je     0x7faf48e

----------------
IN: 
0x07faf48e:  ret    

----------------
IN: 
0x07fb1962:  lea    0x14(%ebx),%eax
0x07fb1965:  mov    $0x5,%ecx
0x07fb196a:  mov    %eax,%edi
0x07fb196c:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb196c:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb196e:  movl   $0xffffffff,0x28(%ebx)
0x07fb1975:  mov    %ebp,%edx
0x07fb1977:  call   0x7faf48f

----------------
IN: 
0x07fb197c:  add    $0x2c,%esp
0x07fb197f:  pop    %ebx
0x07fb1980:  pop    %esi
0x07fb1981:  pop    %edi
0x07fb1982:  pop    %ebp
0x07fb1983:  ret    

----------------
IN: 
0x07fbae21:  mov    0x7fbfeac,%eax
0x07fbae26:  xor    %edx,%edx
0x07fbae28:  test   %eax,%eax
0x07fbae2a:  je     0x7fbae32

----------------
IN: 
0x07fbae2c:  mov    %eax,%edx
0x07fbae2e:  mov    (%eax),%eax
0x07fbae30:  jmp    0x7fbae28

----------------
IN: 
0x07fbae28:  test   %eax,%eax
0x07fbae2a:  je     0x7fbae32

----------------
IN: 
0x07fbae32:  mov    %edx,0xf5f88
0x07fbae38:  mov    $0xf67a0,%ecx
0x07fbae3d:  sub    $0xf5fa0,%ecx
0x07fbae43:  xor    %edx,%edx
0x07fbae45:  mov    $0xf5fa0,%eax
0x07fbae4a:  call   0xf0090

----------------
IN: 
0x000f0090:  test   %ecx,%ecx
0x000f0092:  je     0xf009a

----------------
IN: 
0x000f0094:  dec    %ecx
0x000f0095:  mov    %dl,(%eax,%ecx,1)
0x000f0098:  jmp    0xf0090

----------------
IN: 
0x000f009a:  ret    

----------------
IN: 
0x07fbae4f:  mov    $0xf67a0,%ecx
0x07fbae54:  mov    $0xf5fa0,%edx
0x07fbae59:  mov    $0x7fbfea4,%eax
0x07fbae5e:  call   0x7fb18d2

----------------
IN: 
0x07fbae63:  call   0x7faf9d7

----------------
IN: 
0x07faf9d7:  push   %esi
0x07faf9d8:  push   %ebx
0x07faf9d9:  mov    0xf67c4,%ecx
0x07faf9df:  lea    -0x1(%ecx),%ebx
0x07faf9e2:  imul   $0x14,%ecx,%ecx
0x07faf9e5:  add    $0xf67c8,%ecx
0x07faf9eb:  test   %ebx,%ebx
0x07faf9ed:  js     0x7fafa0f

----------------
IN: 
0x07faf9ef:  mov    -0x14(%ecx),%eax
0x07faf9f2:  mov    -0x10(%ecx),%edx
0x07faf9f5:  add    -0xc(%ecx),%eax
0x07faf9f8:  adc    -0x8(%ecx),%edx
0x07faf9fb:  mov    -0x4(%ecx),%esi
0x07faf9fe:  cmp    $0x0,%edx
0x07fafa01:  ja     0x7fafa09

----------------
IN: 
0x07fafa09:  dec    %ebx
0x07fafa0a:  sub    $0x14,%ecx
0x07fafa0d:  jmp    0x7faf9eb

----------------
IN: 
0x07faf9eb:  test   %ebx,%ebx
0x07faf9ed:  js     0x7fafa0f

----------------
IN: 
0x07fafa03:  and    $0xfffffffd,%esi
0x07fafa06:  dec    %esi
0x07fafa07:  je     0x7fafa11

----------------
IN: 
0x07fafa11:  mov    %eax,%edx
0x07fafa13:  cmp    $0x100000,%eax
0x07fafa18:  jae    0x7fafa1f

----------------
IN: 
0x07fafa1f:  mov    %edx,0xf67c0
0x07fafa25:  pop    %ebx
0x07fafa26:  pop    %esi
0x07fafa27:  ret    

----------------
IN: 
0x07fbae68:  mov    $0x510,%edx
0x07fbae6d:  xor    %eax,%eax
0x07fbae6f:  out    %ax,(%dx)
0x07fbae71:  mov    $0xf4fbe,%ecx
0x07fbae76:  mov    $0x11,%dl
0x07fbae78:  mov    $0x511,%esi
0x07fbae7d:  in     (%dx),%al
0x07fbae7e:  movzbl %al,%eax
0x07fbae81:  movsbl (%ecx),%ebx
0x07fbae84:  cmp    %ebx,%eax
0x07fbae86:  jne    0x7fbb352

----------------
IN: 
0x07fbae8c:  inc    %ecx
0x07fbae8d:  cmp    $0xf4fc2,%ecx
0x07fbae93:  jne    0x7fbae78

----------------
IN: 
0x07fbae78:  mov    $0x511,%esi
0x07fbae7d:  in     (%dx),%al
0x07fbae7e:  movzbl %al,%eax
0x07fbae81:  movsbl (%ecx),%ebx
0x07fbae84:  cmp    %ebx,%eax
0x07fbae86:  jne    0x7fbb352

----------------
IN: 
0x07fbae95:  push   $0xf5510
0x07fbae9a:  call   0xf0cc9

----------------
IN: 
0x07fbae9f:  push   $0x2
0x07fbaea1:  xor    %ecx,%ecx
0x07fbaea3:  mov    $0xe,%edx
0x07fbaea8:  mov    $0xf5523,%eax
0x07fbaead:  call   0x7fb1411

----------------
IN: 
0x07fb1411:  push   %ebp
0x07fb1412:  push   %edi
0x07fb1413:  push   %esi
0x07fb1414:  push   %ebx
0x07fb1415:  push   %ebx
0x07fb1416:  mov    %eax,(%esp)
0x07fb1419:  mov    %edx,%edi
0x07fb141b:  mov    %ecx,%esi
0x07fb141d:  mov    0x18(%esp),%ebp
0x07fb1421:  mov    $0x94,%eax
0x07fb1426:  call   0x7fb09cc

----------------
IN: 
0x07fb09cc:  push   %ebx
0x07fb09cd:  mov    %eax,%ebx
0x07fb09cf:  call   0x7faf8cf

----------------
IN: 
0x07faf8cf:  mov    $0x10,%ecx
0x07faf8d4:  mov    %eax,%edx
0x07faf8d6:  mov    $0x7fbfe9c,%eax
0x07faf8db:  jmp    0x7faf858

----------------
IN: 
0x07faf858:  push   %ebp
0x07faf859:  push   %edi
0x07faf85a:  push   %esi
0x07faf85b:  push   %ebx
0x07faf85c:  test   %edx,%edx
0x07faf85e:  jne    0x7faf864

----------------
IN: 
0x07faf864:  mov    %ecx,%edi
0x07faf866:  mov    %edx,%ebp
0x07faf868:  mov    %eax,%esi
0x07faf86a:  push   $0x0
0x07faf86c:  mov    $0x10,%ecx
0x07faf871:  mov    $0x2c,%edx
0x07faf876:  mov    $0x7fbfe9c,%eax
0x07faf87b:  call   0x7faf7d0

----------------
IN: 
0x07faf880:  mov    %eax,%ebx
0x07faf882:  pop    %eax
0x07faf883:  test   %ebx,%ebx
0x07faf885:  jne    0x7faf8a4

----------------
IN: 
0x07faf8a4:  movl   $0xffffffff,0x28(%ebx)
0x07faf8ab:  lea    0x14(%ebx),%eax
0x07faf8ae:  push   %eax
0x07faf8af:  mov    %edi,%ecx
0x07faf8b1:  mov    %ebp,%edx
0x07faf8b3:  mov    %esi,%eax
0x07faf8b5:  call   0x7faf7d0

----------------
IN: 
0x07faf7f8:  mov    %ebx,0x8(%edi)
0x07faf7fb:  add    %ebx,%edx
0x07faf7fd:  mov    %edx,0xc(%edi)
0x07faf800:  mov    %ebp,0x10(%edi)
0x07faf803:  mov    %ebx,0x10(%esi)
0x07faf806:  mov    0x4(%esi),%edx
0x07faf809:  mov    %edi,%eax
0x07faf80b:  call   0x7faf48f

----------------
IN: 
0x07faf8ba:  pop    %edx
0x07faf8bb:  mov    %eax,%esi
0x07faf8bd:  test   %eax,%eax
0x07faf8bf:  jne    0x7faf8c8

----------------
IN: 
0x07faf8c8:  mov    %esi,%eax
0x07faf8ca:  pop    %ebx
0x07faf8cb:  pop    %esi
0x07faf8cc:  pop    %edi
0x07faf8cd:  pop    %ebp
0x07faf8ce:  ret    

----------------
IN: 
0x07fb09d4:  test   %eax,%eax
0x07fb09d6:  jne    0x7fb09ea

----------------
IN: 
0x07fb09ea:  pop    %ebx
0x07fb09eb:  ret    

----------------
IN: 
0x07fb142b:  mov    %eax,%ebx
0x07fb142d:  test   %eax,%eax
0x07fb142f:  jne    0x7fb1445

----------------
IN: 
0x07fb1445:  mov    $0x94,%ecx
0x07fb144a:  xor    %edx,%edx
0x07fb144c:  call   0xf0090

----------------
IN: 
0x07fb1451:  lea    0x4(%ebx),%eax
0x07fb1454:  mov    $0x80,%ecx
0x07fb1459:  mov    (%esp),%edx
0x07fb145c:  call   0x7faf4dd

----------------
IN: 
0x07faf4dd:  push   %esi
0x07faf4de:  push   %ebx
0x07faf4df:  lea    0x1(%edx),%esi
0x07faf4e2:  add    %edx,%ecx
0x07faf4e4:  mov    %eax,%ebx
0x07faf4e6:  cmp    %ecx,%esi
0x07faf4e8:  je     0x7faf4f8

----------------
IN: 
0x07faf4ea:  inc    %esi
0x07faf4eb:  mov    -0x2(%esi),%dl
0x07faf4ee:  test   %dl,%dl
0x07faf4f0:  je     0x7faf4f8

----------------
IN: 
0x07faf4f2:  inc    %ebx
0x07faf4f3:  mov    %dl,-0x1(%ebx)
0x07faf4f6:  jmp    0x7faf4e6

----------------
IN: 
0x07faf4e6:  cmp    %ecx,%esi
0x07faf4e8:  je     0x7faf4f8

----------------
IN: 
0x07faf4f8:  movb   $0x0,(%ebx)
0x07faf4fb:  pop    %ebx
0x07faf4fc:  pop    %esi
0x07faf4fd:  ret    

----------------
IN: 
0x07fb1461:  mov    %ebp,0x84(%ebx)
0x07fb1467:  mov    %edi,0x8c(%ebx)
0x07fb146d:  mov    %esi,0x90(%ebx)
0x07fb1473:  movl   $0x7fb0ad9,0x88(%ebx)
0x07fb147d:  mov    0x7fbfe80,%eax
0x07fb1482:  mov    %eax,(%ebx)
0x07fb1484:  mov    %ebx,0x7fbfe80
0x07fb148a:  pop    %eax
0x07fb148b:  pop    %ebx
0x07fb148c:  pop    %esi
0x07fb148d:  pop    %edi
0x07fb148e:  pop    %ebp
0x07fb148f:  ret    

----------------
IN: 
0x07fbaeb2:  push   $0x1
0x07fbaeb4:  xor    %ecx,%ecx
0x07fbaeb6:  mov    $0x8002,%edx
0x07fbaebb:  mov    $0xf4678,%eax
0x07fbaec0:  call   0x7fb1411

----------------
IN: 
0x07fbaec5:  push   $0x2
0x07fbaec7:  xor    %ecx,%ecx
0x07fbaec9:  mov    $0xf,%edx
0x07fbaece:  mov    $0xf4b6d,%eax
0x07fbaed3:  call   0x7fb1411

----------------
IN: 
0x07fbaed8:  mov    $0x510,%ebp
0x07fbaedd:  mov    $0xd,%eax
0x07fbaee2:  mov    %ebp,%edx
0x07fbaee4:  out    %ax,(%dx)
0x07fbaee6:  mov    $0x8,%ecx
0x07fbaeeb:  lea    0xd4(%esp),%edi
0x07fbaef2:  mov    %esi,%edx
0x07fbaef4:  rep insb (%dx),%es:(%edi)

----------------
IN: 
0x07fbaef4:  rep insb (%dx),%es:(%edi)

----------------
IN: 
0x07fbaef6:  xor    %edx,%edx
0x07fbaef8:  xor    %ecx,%ecx
0x07fbaefa:  mov    $0xf4b6d,%eax
0x07fbaeff:  call   0x7fb0bfd

----------------
IN: 
0x07fb0bfd:  push   %ebp
0x07fb0bfe:  mov    %esp,%ebp
0x07fb0c00:  push   %edi
0x07fb0c01:  push   %esi
0x07fb0c02:  push   %ebx
0x07fb0c03:  sub    $0x8,%esp
0x07fb0c06:  mov    %edx,%esi
0x07fb0c08:  mov    %ecx,%edi
0x07fb0c0a:  call   0x7fb0bc8

----------------
IN: 
0x07fb0bc8:  push   %edi
0x07fb0bc9:  push   %esi
0x07fb0bca:  push   %ebx
0x07fb0bcb:  mov    %eax,%edi
0x07fb0bcd:  call   0x7faf4ae

----------------
IN: 
0x07faf4ae:  mov    %eax,%edx
0x07faf4b0:  cmpb   $0x0,(%edx)
0x07faf4b3:  je     0x7faf4b8

----------------
IN: 
0x07faf4b5:  inc    %edx
0x07faf4b6:  jmp    0x7faf4b0

----------------
IN: 
0x07faf4b0:  cmpb   $0x0,(%edx)
0x07faf4b3:  je     0x7faf4b8

----------------
IN: 
0x07faf4b8:  sub    %eax,%edx
0x07faf4ba:  mov    %edx,%eax
0x07faf4bc:  ret    

----------------
IN: 
0x07fb0bd2:  lea    0x1(%eax),%esi
0x07fb0bd5:  mov    0x7fbfe80,%ebx
0x07fb0bdb:  test   %ebx,%ebx
0x07fb0bdd:  je     0x7fb0bf3

----------------
IN: 
0x07fb0bdf:  lea    0x4(%ebx),%edx
0x07fb0be2:  mov    %esi,%ecx
0x07fb0be4:  mov    %edi,%eax
0x07fb0be6:  call   0x7faf4bd

----------------
IN: 
0x07faf4bd:  push   %esi
0x07faf4be:  push   %ebx
0x07faf4bf:  mov    %edx,%esi
0x07faf4c1:  xor    %ebx,%ebx
0x07faf4c3:  cmp    %ecx,%ebx
0x07faf4c5:  je     0x7faf4d8

----------------
IN: 
0x07faf4c7:  mov    (%eax,%ebx,1),%dl
0x07faf4ca:  inc    %ebx
0x07faf4cb:  cmp    -0x1(%esi,%ebx,1),%dl
0x07faf4cf:  je     0x7faf4c3

----------------
IN: 
0x07faf4c3:  cmp    %ecx,%ebx
0x07faf4c5:  je     0x7faf4d8

----------------
IN: 
0x07faf4d8:  xor    %eax,%eax
0x07faf4da:  pop    %ebx
0x07faf4db:  pop    %esi
0x07faf4dc:  ret    

----------------
IN: 
0x07fb0beb:  test   %eax,%eax
0x07fb0bed:  je     0x7fb0bf7

----------------
IN: 
0x07fb0bf7:  mov    %ebx,%eax
0x07fb0bf9:  pop    %ebx
0x07fb0bfa:  pop    %esi
0x07fb0bfb:  pop    %edi
0x07fb0bfc:  ret    

----------------
IN: 
0x07fb0c0f:  mov    %eax,%ebx
0x07fb0c11:  test   %eax,%eax
0x07fb0c13:  jne    0x7fb0c1b

----------------
IN: 
0x07fb0c1b:  mov    0x84(%eax),%eax
0x07fb0c21:  lea    -0x1(%eax),%edx
0x07fb0c24:  cmp    $0x7,%edx
0x07fb0c27:  ja     0x7fb0c15

----------------
IN: 
0x07fb0c29:  test   %eax,%edx
0x07fb0c2b:  jne    0x7fb0c15

----------------
IN: 
0x07fb0c2d:  movl   $0x0,-0x14(%ebp)
0x07fb0c34:  movl   $0x0,-0x10(%ebp)
0x07fb0c3b:  mov    $0x8,%ecx
0x07fb0c40:  lea    -0x14(%ebp),%edx
0x07fb0c43:  mov    %ebx,%eax
0x07fb0c45:  call   *0x88(%ebx)

----------------
IN: 
0x07fb0ad9:  push   %edi
0x07fb0ada:  push   %esi
0x07fb0adb:  push   %ebx
0x07fb0adc:  mov    %eax,%esi
0x07fb0ade:  mov    0x84(%eax),%ebx
0x07fb0ae4:  or     $0xffffffff,%eax
0x07fb0ae7:  cmp    %ecx,%ebx
0x07fb0ae9:  ja     0x7fb0b1a

----------------
IN: 
0x07fb0aeb:  mov    %edx,%edi
0x07fb0aed:  mov    0x8c(%esi),%eax
0x07fb0af3:  mov    $0x510,%edx
0x07fb0af8:  out    %ax,(%dx)
0x07fb0afa:  mov    0x90(%esi),%ecx
0x07fb0b00:  mov    $0x11,%dl
0x07fb0b02:  dec    %ecx
0x07fb0b03:  cmp    $0xffffffff,%ecx
0x07fb0b06:  je     0x7fb0b0b

----------------
IN: 
0x07fb0b0b:  mov    %ebx,%ecx
0x07fb0b0d:  mov    $0x511,%edx
0x07fb0b12:  rep insb (%dx),%es:(%edi)

----------------
IN: 
0x07fb0b12:  rep insb (%dx),%es:(%edi)

----------------
IN: 
0x07fb0b14:  mov    0x84(%esi),%eax
0x07fb0b1a:  pop    %ebx
0x07fb0b1b:  pop    %esi
0x07fb0b1c:  pop    %edi
0x07fb0b1d:  ret    

----------------
IN: 
0x07fb0c4b:  test   %eax,%eax
0x07fb0c4d:  js     0x7fb0c15

----------------
IN: 
0x07fb0c4f:  mov    -0x14(%ebp),%eax
0x07fb0c52:  mov    -0x10(%ebp),%edx
0x07fb0c55:  pop    %ecx
0x07fb0c56:  pop    %ebx
0x07fb0c57:  pop    %ebx
0x07fb0c58:  pop    %esi
0x07fb0c59:  pop    %edi
0x07fb0c5a:  pop    %ebp
0x07fb0c5b:  ret    

----------------
IN: 
0x07fbaf04:  lea    0x0(,%eax,8),%ebx
0x07fbaf0b:  push   %ebx
0x07fbaf0c:  mov    $0x8,%ecx
0x07fbaf11:  mov    $0xd,%edx
0x07fbaf16:  mov    $0xf4699,%eax
0x07fbaf1b:  call   0x7fb1411

----------------
IN: 
0x07fbaf20:  lea    0x8(%ebx),%ecx
0x07fbaf23:  mov    0xd8(%esp),%eax
0x07fbaf2a:  shl    $0x3,%eax
0x07fbaf2d:  push   %eax
0x07fbaf2e:  mov    $0xd,%edx
0x07fbaf33:  mov    $0xf468a,%eax
0x07fbaf38:  call   0x7fb1411

----------------
IN: 
0x07fbaf3d:  mov    $0xffff8000,%eax
0x07fbaf42:  mov    %ebp,%edx
0x07fbaf44:  out    %ax,(%dx)
0x07fbaf46:  mov    $0x2,%ecx
0x07fbaf4b:  lea    0xd0(%esp),%edi
0x07fbaf52:  mov    %esi,%edx
0x07fbaf54:  rep insb (%dx),%es:(%edi)

----------------
IN: 
0x07fbaf54:  rep insb (%dx),%es:(%edi)

----------------
IN: 
0x07fbaf56:  add    $0x18,%esp
0x07fbaf59:  mov    $0x2,%eax
0x07fbaf5e:  xor    %ebx,%ebx
0x07fbaf60:  lea    0xec(%esp),%esi
0x07fbaf67:  movzwl 0xb8(%esp),%edx
0x07fbaf6f:  cmp    %edx,%ebx
0x07fbaf71:  jge    0x7fbafd3

----------------
IN: 
0x07fbafd3:  mov    $0x510,%edx
0x07fbafd8:  mov    $0xffff8001,%eax
0x07fbafdd:  out    %ax,(%dx)
0x07fbafdf:  mov    $0x2,%ecx
0x07fbafe4:  lea    0xb8(%esp),%edi
0x07fbafeb:  mov    $0x11,%dl
0x07fbafed:  rep insb (%dx),%es:(%edi)

----------------
IN: 
0x07fbafed:  rep insb (%dx),%es:(%edi)

----------------
IN: 
0x07fbafef:  mov    $0x2,%ebx
0x07fbaff4:  xor    %ebp,%ebp
0x07fbaff6:  lea    0xec(%esp),%esi
0x07fbaffd:  movzwl 0xb8(%esp),%eax
0x07fbb005:  cmp    %eax,%ebp
0x07fbb007:  jge    0x7fbb0ad

----------------
IN: 
0x07fbb0ad:  mov    $0x510,%edx
0x07fbb0b2:  mov    $0x19,%eax
0x07fbb0b7:  out    %ax,(%dx)
0x07fbb0b9:  mov    $0x4,%ecx
0x07fbb0be:  lea    0xb8(%esp),%edi
0x07fbb0c5:  mov    $0x11,%dl
0x07fbb0c7:  rep insb (%dx),%es:(%edi)

----------------
IN: 
0x07fbb0c7:  rep insb (%dx),%es:(%edi)

----------------
IN: 
0x07fbb0c9:  mov    0xb8(%esp),%eax
0x07fbb0d0:  call   0x7fb09c9

----------------
IN: 
0x07fb09c9:  bswap  %eax
0x07fb09cb:  ret    

----------------
IN: 
0x07fbb0d5:  mov    %eax,0xb8(%esp)
0x07fbb0dc:  xor    %ebx,%ebx
0x07fbb0de:  cmp    0xb8(%esp),%ebx
0x07fbb0e5:  jae    0x7fbb125

----------------
IN: 
0x07fbb0e7:  mov    $0x40,%ecx
0x07fbb0ec:  lea    0xec(%esp),%edi
0x07fbb0f3:  mov    $0x511,%edx
0x07fbb0f8:  rep insb (%dx),%es:(%edi)

----------------
IN: 
0x07fbb0f8:  rep insb (%dx),%es:(%edi)

----------------
IN: 
0x07fbb0fa:  mov    0xec(%esp),%eax
0x07fbb101:  call   0x7fb09c9

----------------
IN: 
0x07fbb106:  mov    0xf0(%esp),%edx
0x07fbb10d:  xchg   %dh,%dl
0x07fbb10f:  movzwl %dx,%edx
0x07fbb112:  push   %eax
0x07fbb113:  xor    %ecx,%ecx
0x07fbb115:  lea    0xf8(%esp),%eax
0x07fbb11c:  call   0x7fb1411

----------------
IN: 
0x07fbb121:  inc    %ebx
0x07fbb122:  pop    %eax
0x07fbb123:  jmp    0x7fbb0de

----------------
IN: 
0x07fbb0de:  cmp    0xb8(%esp),%ebx
0x07fbb0e5:  jae    0x7fbb125

----------------
IN: 
0x07fbb125:  lea    0xbc(%esp),%edx
0x07fbb12c:  mov    $0xf5555,%eax
0x07fbb131:  call   0x7fb107c

----------------
IN: 
0x07fb107c:  push   %ebp
0x07fb107d:  push   %edi
0x07fb107e:  push   %esi
0x07fb107f:  push   %ebx
0x07fb1080:  mov    %edx,%ebp
0x07fb1082:  call   0x7fb0bc8

----------------
IN: 
0x07faf4d1:  sbb    %eax,%eax
0x07faf4d3:  or     $0x1,%eax
0x07faf4d6:  jmp    0x7faf4da

----------------
IN: 
0x07faf4da:  pop    %ebx
0x07faf4db:  pop    %esi
0x07faf4dc:  ret    

----------------
IN: 
0x07fb0bef:  mov    (%ebx),%ebx
0x07fb0bf1:  jmp    0x7fb0bdb

----------------
IN: 
0x07fb0bdb:  test   %ebx,%ebx
0x07fb0bdd:  je     0x7fb0bf3

----------------
IN: 
0x07fb1087:  mov    %eax,%edi
0x07fb1089:  test   %eax,%eax
0x07fb108b:  je     0x7fb10e0

----------------
IN: 
0x07fb108d:  mov    0x84(%eax),%esi
0x07fb1093:  xor    %eax,%eax
0x07fb1095:  test   %esi,%esi
0x07fb1097:  je     0x7fb10e2

----------------
IN: 
0x07fb1099:  lea    0x1(%esi),%eax
0x07fb109c:  call   0x7faf8cf

----------------
IN: 
0x07fb10a1:  mov    %eax,%ebx
0x07fb10a3:  test   %eax,%eax
0x07fb10a5:  jne    0x7fb10b8

----------------
IN: 
0x07fb10b8:  mov    %esi,%ecx
0x07fb10ba:  mov    %eax,%edx
0x07fb10bc:  mov    %edi,%eax
0x07fb10be:  call   *0x88(%edi)

----------------
IN: 
0x07fb10c4:  test   %eax,%eax
0x07fb10c6:  jns    0x7fb10d1

----------------
IN: 
0x07fb10d1:  test   %ebp,%ebp
0x07fb10d3:  je     0x7fb10d8

----------------
IN: 
0x07fb10d5:  mov    %esi,0x0(%ebp)
0x07fb10d8:  movb   $0x0,(%ebx,%esi,1)
0x07fb10dc:  mov    %ebx,%eax
0x07fb10de:  jmp    0x7fb10e2

----------------
IN: 
0x07fb10e2:  pop    %ebx
0x07fb10e3:  pop    %esi
0x07fb10e4:  pop    %edi
0x07fb10e5:  pop    %ebp
0x07fb10e6:  ret    

----------------
IN: 
0x07fbb136:  test   %eax,%eax
0x07fbb138:  je     0x7fbb240

----------------
IN: 
0x07fbb13e:  lea    0x8(%eax),%esi
0x07fbb141:  movl   $0x0,0x8(%esp)
0x07fbb149:  mov    0xbc(%esp),%eax
0x07fbb150:  mov    $0x14,%ecx
0x07fbb155:  xor    %edx,%edx
0x07fbb157:  div    %ecx
0x07fbb159:  cmp    %eax,0x8(%esp)
0x07fbb15d:  jae    0x7fbb32a

----------------
IN: 
0x07fbb163:  mov    0x8(%esi),%eax
0x07fbb166:  cmp    $0x1,%eax
0x07fbb169:  je     0x7fbb179

----------------
IN: 
0x07fbb179:  pushl  0x4(%esi)
0x07fbb17c:  pushl  (%esi)
0x07fbb17e:  pushl  -0x4(%esi)
0x07fbb181:  pushl  -0x8(%esi)
0x07fbb184:  push   $0xf555e
0x07fbb189:  call   0xf0cc9

----------------
IN: 
0x000f08ad:  mov    0x1(%ebx),%al
0x000f08b0:  cmp    $0x6c,%al
0x000f08b2:  je     0xf08ba

----------------
IN: 
0x000f08ba:  add    $0x2,%ebx
0x000f08bd:  mov    0x2(%edx),%al
0x000f08c0:  cmp    $0x64,%al
0x000f08c2:  je     0xf0a67

----------------
IN: 
0x000f08c8:  jle    0xf09c9

----------------
IN: 
0x000f08ce:  cmp    $0x73,%al
0x000f08d0:  je     0xf0972

----------------
IN: 
0x000f08d6:  jle    0xf0a2e

----------------
IN: 
0x000f08dc:  cmp    $0x75,%al
0x000f08de:  je     0xf08ee

----------------
IN: 
0x000f08e0:  cmp    $0x78,%al
0x000f08e2:  jne    0xf098c

----------------
IN: 
0x000f08e8:  mov    %ebx,%esi
0x000f08ea:  mov    $0x1,%al
0x000f08ec:  jmp    0xf092a

----------------
IN: 
0x000f092a:  mov    0x0(%ebp),%ebx
0x000f092d:  mov    %ebx,0x4(%esp)
0x000f0931:  test   %al,%al
0x000f0933:  movsbl (%esp),%eax
0x000f0937:  je     0xf0960

----------------
IN: 
0x000f0939:  lea    0x8(%ebp),%ebx
0x000f093c:  mov    0x4(%ebp),%edx
0x000f093f:  test   %edx,%edx
0x000f0941:  je     0xf0963

----------------
IN: 
0x000f0963:  push   %eax
0x000f0964:  mov    0x8(%esp),%edx
0x000f0968:  mov    %edi,%eax
0x000f096a:  call   0xf0029

----------------
IN: 
0x07fbb18e:  mov    -0x8(%esi),%ecx
0x07fbb191:  mov    -0x4(%esi),%ebx
0x07fbb194:  mov    0x7fbff18,%eax
0x07fbb199:  xor    %edx,%edx
0x07fbb19b:  mov    %eax,0x14(%esp)
0x07fbb19f:  mov    %edx,0x18(%esp)
0x07fbb1a3:  add    $0x14,%esp
0x07fbb1a6:  cmp    $0x0,%ebx
0x07fbb1a9:  ja     0x7fbb1b4

----------------
IN: 
0x07fbb1ab:  cmp    (%esp),%ecx
0x07fbb1ae:  jb     0x7fbb234

----------------
IN: 
0x07fbb234:  incl   0x8(%esp)
0x07fbb238:  add    $0x14,%esi
0x07fbb23b:  jmp    0x7fbb149

----------------
IN: 
0x07fbb149:  mov    0xbc(%esp),%eax
0x07fbb150:  mov    $0x14,%ecx
0x07fbb155:  xor    %edx,%edx
0x07fbb157:  div    %ecx
0x07fbb159:  cmp    %eax,0x8(%esp)
0x07fbb15d:  jae    0x7fbb32a

----------------
IN: 
0x07fbb32a:  mov    $0xf4c00,%eax
0x07fbb32f:  call   0x7fb0bc8

----------------
IN: 
0x07fbb334:  test   %eax,%eax
0x07fbb336:  je     0x7fbb352

----------------
IN: 
0x07fbb338:  movw   $0x600,0xf5ce8
0x07fbb341:  push   $0x600
0x07fbb346:  push   $0xf55ae
0x07fbb34b:  call   0xf0cc9

----------------
IN: 
0x07fbb350:  pop    %ebp
0x07fbb351:  pop    %eax
0x07fbb352:  movl   $0x1,0xf6c48
0x07fbb35c:  mov    $0x8f,%al
0x07fbb35e:  out    %al,$0x70
0x07fbb360:  xor    %eax,%eax
0x07fbb362:  out    %al,$0x71
0x07fbb364:  xor    %eax,%eax
0x07fbb366:  mov    $0xfff53,%edx
0x07fbb36b:  mov    %dx,0x0(,%eax,4)
0x07fbb373:  movw   $0xf000,0x2(,%eax,4)
0x07fbb37d:  inc    %eax
0x07fbb37e:  cmp    $0x100,%eax
0x07fbb383:  jne    0x7fbb36b

----------------
IN: 
0x07fbb36b:  mov    %dx,0x0(,%eax,4)
0x07fbb373:  movw   $0xf000,0x2(,%eax,4)
0x07fbb37d:  inc    %eax
0x07fbb37e:  cmp    $0x100,%eax
0x07fbb383:  jne    0x7fbb36b

----------------
IN: 
0x07fbb385:  mov    $0x8,%ax
0x07fbb389:  mov    $0xfd62c,%edx
0x07fbb38e:  mov    %dx,0x0(,%eax,4)
0x07fbb396:  movw   $0xf000,0x2(,%eax,4)
0x07fbb3a0:  inc    %eax
0x07fbb3a1:  cmp    $0x10,%eax
0x07fbb3a4:  jne    0x7fbb38e

----------------
IN: 
0x07fbb38e:  mov    %dx,0x0(,%eax,4)
0x07fbb396:  movw   $0xf000,0x2(,%eax,4)
0x07fbb3a0:  inc    %eax
0x07fbb3a1:  cmp    $0x10,%eax
0x07fbb3a4:  jne    0x7fbb38e

----------------
IN: 
0x07fbb3a6:  mov    $0x70,%al
0x07fbb3a8:  mov    $0xfec4e,%edx
0x07fbb3ad:  mov    %dx,0x0(,%eax,4)
0x07fbb3b5:  movw   $0xf000,0x2(,%eax,4)
0x07fbb3bf:  inc    %eax
0x07fbb3c0:  cmp    $0x78,%eax
0x07fbb3c3:  jne    0x7fbb3ad

----------------
IN: 
0x07fbb3ad:  mov    %dx,0x0(,%eax,4)
0x07fbb3b5:  movw   $0xf000,0x2(,%eax,4)
0x07fbb3bf:  inc    %eax
0x07fbb3c0:  cmp    $0x78,%eax
0x07fbb3c3:  jne    0x7fbb3ad

----------------
IN: 
0x07fbb3c5:  mov    $0xfe2c3,%eax
0x07fbb3ca:  mov    %ax,0x8
0x07fbb3d0:  movw   $0xf000,0xa
0x07fbb3d9:  mov    $0xff065,%eax
0x07fbb3de:  mov    %ax,0x40
0x07fbb3e4:  movw   $0xf000,0x42
0x07fbb3ed:  mov    $0xff84d,%eax
0x07fbb3f2:  mov    %ax,0x44
0x07fbb3f8:  movw   $0xf000,0x46
0x07fbb401:  mov    $0xff841,%eax
0x07fbb406:  mov    %ax,0x48
0x07fbb40c:  movw   $0xf000,0x4a
0x07fbb415:  mov    $0xfe3fe,%eax
0x07fbb41a:  mov    %ax,0x4c
0x07fbb420:  movw   $0xf000,0x4e
0x07fbb429:  mov    $0xfe739,%eax
0x07fbb42e:  mov    %ax,0x50
0x07fbb434:  movw   $0xf000,0x52
0x07fbb43d:  mov    $0xff859,%eax
0x07fbb442:  mov    %ax,0x54
0x07fbb448:  movw   $0xf000,0x56
0x07fbb451:  mov    $0xfe82e,%eax
0x07fbb456:  mov    %ax,0x58
0x07fbb45c:  movw   $0xf000,0x5a
0x07fbb465:  mov    $0xfefd2,%eax
0x07fbb46a:  mov    %ax,0x5c
0x07fbb470:  movw   $0xf000,0x5e
0x07fbb479:  mov    $0xfd648,%eax
0x07fbb47e:  mov    %ax,0x60
0x07fbb484:  movw   $0xf000,0x62
0x07fbb48d:  mov    $0xfe6f2,%eax
0x07fbb492:  mov    %ax,0x64
0x07fbb498:  movw   $0xf000,0x66
0x07fbb4a1:  mov    $0xffe6e,%eax
0x07fbb4a6:  mov    %ax,0x68
0x07fbb4ac:  movw   $0xf000,0x6a
0x07fbb4b5:  mov    $0xfec59,%eax
0x07fbb4ba:  mov    %ax,0x100
0x07fbb4c0:  movw   $0xf000,0x102
0x07fbb4c9:  mov    $0x60,%eax
0x07fbb4ce:  movw   $0x0,0x0(,%eax,4)
0x07fbb4d8:  movw   $0x0,0x2(,%eax,4)
0x07fbb4e2:  inc    %eax
0x07fbb4e3:  cmp    $0x67,%eax
0x07fbb4e6:  jne    0x7fbb4ce

----------------
IN: 
0x07fbb4ce:  movw   $0x0,0x0(,%eax,4)
0x07fbb4d8:  movw   $0x0,0x2(,%eax,4)
0x07fbb4e2:  inc    %eax
0x07fbb4e3:  cmp    $0x67,%eax
0x07fbb4e6:  jne    0x7fbb4ce

----------------
IN: 
0x07fbb4e8:  movw   $0x0,0x1e4
0x07fbb4f1:  movw   $0x0,0x1e6
0x07fbb4fa:  mov    $0x100,%ecx
0x07fbb4ff:  xor    %edx,%edx
0x07fbb501:  mov    $0x400,%ax
0x07fbb505:  call   0xf0090

----------------
IN: 
0x07fbb50a:  movw   $0x9fc0,0x40e
0x07fbb513:  movw   $0x27f,0x413
0x07fbb51c:  mov    $0x121,%ecx
0x07fbb521:  xor    %edx,%edx
0x07fbb523:  mov    $0x9fc00,%eax
0x07fbb528:  call   0xf0090

----------------
IN: 
0x07fbb52d:  movb   $0x1,0x9fc00
0x07fbb534:  push   $0x2
0x07fbb536:  push   $0x0
0x07fbb538:  push   $0x400
0x07fbb53d:  mov    $0x9fc00,%eax
0x07fbb542:  xor    %edx,%edx
0x07fbb544:  call   0x7fb1824

----------------
IN: 
0x07fb1824:  push   %edi
0x07fb1825:  push   %esi
0x07fb1826:  push   %ebx
0x07fb1827:  mov    0x10(%esp),%ebx
0x07fb182b:  mov    0x14(%esp),%ecx
0x07fb182f:  mov    %ecx,%edi
0x07fb1831:  or     %ebx,%edi
0x07fb1833:  je     0x7fb183d

----------------
IN: 
0x07fb1835:  pop    %ebx
0x07fb1836:  pop    %esi
0x07fb1837:  pop    %edi
0x07fb1838:  jmp    0x7fb1649

----------------
IN: 
0x07fb1649:  push   %ebp
0x07fb164a:  push   %edi
0x07fb164b:  push   %esi
0x07fb164c:  push   %ebx
0x07fb164d:  sub    $0x24,%esp
0x07fb1650:  mov    %eax,0x8(%esp)
0x07fb1654:  mov    %edx,0xc(%esp)
0x07fb1658:  mov    0x38(%esp),%eax
0x07fb165c:  mov    0x3c(%esp),%edx
0x07fb1660:  mov    %eax,0x18(%esp)
0x07fb1664:  mov    %edx,0x1c(%esp)
0x07fb1668:  mov    0x40(%esp),%eax
0x07fb166c:  mov    %eax,0x20(%esp)
0x07fb1670:  mov    0x8(%esp),%eax
0x07fb1674:  mov    0xc(%esp),%edx
0x07fb1678:  add    0x18(%esp),%eax
0x07fb167c:  adc    0x1c(%esp),%edx
0x07fb1680:  mov    %eax,(%esp)
0x07fb1683:  mov    %edx,0x4(%esp)
0x07fb1687:  mov    0xf67c4,%esi
0x07fb168d:  mov    $0xf67c8,%ecx
0x07fb1692:  xor    %ebx,%ebx
0x07fb1694:  cmp    %esi,%ebx
0x07fb1696:  jge    0x7fb1760

----------------
IN: 
0x07fb169c:  mov    (%ecx),%eax
0x07fb169e:  mov    0x4(%ecx),%edx
0x07fb16a1:  mov    %eax,%edi
0x07fb16a3:  mov    %edx,%ebp
0x07fb16a5:  add    0x8(%ecx),%edi
0x07fb16a8:  adc    0xc(%ecx),%ebp
0x07fb16ab:  mov    %edi,0x10(%esp)
0x07fb16af:  mov    %ebp,0x14(%esp)
0x07fb16b3:  add    $0x14,%ecx
0x07fb16b6:  mov    0x14(%esp),%edi
0x07fb16ba:  cmp    %edi,0xc(%esp)
0x07fb16be:  jb     0x7fb16cf

----------------
IN: 
0x07fb16c0:  ja     0x7fb16cc

----------------
IN: 
0x07fb16c2:  mov    0x10(%esp),%edi
0x07fb16c6:  cmp    %edi,0x8(%esp)
0x07fb16ca:  jbe    0x7fb16cf

----------------
IN: 
0x07fb16cf:  cmp    %edx,0xc(%esp)
0x07fb16d3:  jb     0x7fb1760

----------------
IN: 
0x07fb16d9:  ja     0x7fb16e1

----------------
IN: 
0x07fb16db:  cmp    %eax,0x8(%esp)
0x07fb16df:  jbe    0x7fb1760

----------------
IN: 
0x07fb16e1:  imul   $0x14,%ebx,%esi
0x07fb16e4:  mov    0xf67d8(%esi),%ecx
0x07fb16ea:  cmp    %ecx,0x20(%esp)
0x07fb16ee:  jne    0x7fb170d

----------------
IN: 
0x07fb170d:  mov    0x8(%esp),%edi
0x07fb1711:  mov    0xc(%esp),%ebp
0x07fb1715:  sub    %eax,%edi
0x07fb1717:  sbb    %edx,%ebp
0x07fb1719:  mov    %edi,0xf67d0(%esi)
0x07fb171f:  mov    %ebp,0xf67d4(%esi)
0x07fb1725:  inc    %ebx
0x07fb1726:  mov    0x4(%esp),%eax
0x07fb172a:  cmp    %eax,0x14(%esp)
0x07fb172e:  jb     0x7fb1760

----------------
IN: 
0x07fb1730:  ja     0x7fb173b

----------------
IN: 
0x07fb1732:  mov    (%esp),%eax
0x07fb1735:  cmp    %eax,0x10(%esp)
0x07fb1739:  jbe    0x7fb1760

----------------
IN: 
0x07fb1760:  imul   $0x14,%ebx,%esi
0x07fb1763:  cmp    0xf67c4,%ebx
0x07fb1769:  jge    0x7fb17e7

----------------
IN: 
0x07fb176b:  mov    0xf67c8(%esi),%eax
0x07fb1771:  mov    0xf67cc(%esi),%edx
0x07fb1777:  cmp    %edx,0x4(%esp)
0x07fb177b:  jb     0x7fb17e7

----------------
IN: 
0x07fb177d:  ja     0x7fb1784

----------------
IN: 
0x07fb177f:  cmp    %eax,(%esp)
0x07fb1782:  jb     0x7fb17e7

----------------
IN: 
0x07fb17e7:  cmpl   $0xffffffff,0x20(%esp)
0x07fb17ec:  je     0x7fb181c

----------------
IN: 
0x07fb17ee:  mov    0x20(%esp),%eax
0x07fb17f2:  mov    %eax,0x40(%esp)
0x07fb17f6:  mov    0x18(%esp),%eax
0x07fb17fa:  mov    0x1c(%esp),%edx
0x07fb17fe:  mov    %eax,0x38(%esp)
0x07fb1802:  mov    %edx,0x3c(%esp)
0x07fb1806:  mov    0x8(%esp),%edx
0x07fb180a:  mov    0xc(%esp),%ecx
0x07fb180e:  mov    %ebx,%eax
0x07fb1810:  add    $0x24,%esp
0x07fb1813:  pop    %ebx
0x07fb1814:  pop    %esi
0x07fb1815:  pop    %edi
0x07fb1816:  pop    %ebp
0x07fb1817:  jmp    0x7fb15b5

----------------
IN: 
0x07fb15b5:  push   %ebp
0x07fb15b6:  push   %edi
0x07fb15b7:  push   %esi
0x07fb15b8:  push   %ebx
0x07fb15b9:  sub    $0xc,%esp
0x07fb15bc:  mov    0x20(%esp),%edi
0x07fb15c0:  mov    0x24(%esp),%ebp
0x07fb15c4:  mov    0x28(%esp),%esi
0x07fb15c8:  mov    %esi,(%esp)
0x07fb15cb:  mov    0xf67c4,%ebx
0x07fb15d1:  cmp    $0x1f,%ebx
0x07fb15d4:  jle    0x7fb15ec

----------------
IN: 
0x07fb15ec:  mov    %edx,0x4(%esp)
0x07fb15f0:  mov    %ecx,0x8(%esp)
0x07fb15f4:  sub    %eax,%ebx
0x07fb15f6:  imul   $0x14,%ebx,%ecx
0x07fb15f9:  imul   $0x14,%eax,%ebx
0x07fb15fc:  lea    0xf67c8(%ebx),%esi
0x07fb1602:  inc    %eax
0x07fb1603:  imul   $0x14,%eax,%eax
0x07fb1606:  add    $0xf67c8,%eax
0x07fb160b:  mov    %esi,%edx
0x07fb160d:  call   0x7fb01f0

----------------
IN: 
0x07fb1612:  incl   0xf67c4
0x07fb1618:  mov    0x4(%esp),%eax
0x07fb161c:  mov    0x8(%esp),%edx
0x07fb1620:  mov    %eax,0xf67c8(%ebx)
0x07fb1626:  mov    %edx,0xf67cc(%ebx)
0x07fb162c:  mov    %edi,0xf67d0(%ebx)
0x07fb1632:  mov    %ebp,0xf67d4(%ebx)
0x07fb1638:  mov    (%esp),%eax
0x07fb163b:  mov    %eax,0xf67d8(%ebx)
0x07fb1641:  add    $0xc,%esp
0x07fb1644:  pop    %ebx
0x07fb1645:  pop    %esi
0x07fb1646:  pop    %edi
0x07fb1647:  pop    %ebp
0x07fb1648:  ret    

----------------
IN: 
0x07fbb549:  mov    $0xefee0,%eax
0x07fbb54e:  sub    $0xe0000,%eax
0x07fbb553:  mov    %eax,0xef6d8
0x07fbb558:  mov    $0x1,%edx
0x07fbb55d:  xor    %ecx,%ecx
0x07fbb55f:  mov    $0xf55c6,%eax
0x07fbb564:  call   0x7fb0bfd

----------------
IN: 
0x07fb0bf3:  xor    %eax,%eax
0x07fb0bf5:  jmp    0x7fb0bf9

----------------
IN: 
0x07fb0bf9:  pop    %ebx
0x07fb0bfa:  pop    %esi
0x07fb0bfb:  pop    %edi
0x07fb0bfc:  ret    

----------------
IN: 
0x07fb0c15:  mov    %esi,%eax
0x07fb0c17:  mov    %edi,%edx
0x07fb0c19:  jmp    0x7fb0c55

----------------
IN: 
0x07fb0c55:  pop    %ecx
0x07fb0c56:  pop    %ebx
0x07fb0c57:  pop    %ebx
0x07fb0c58:  pop    %esi
0x07fb0c59:  pop    %edi
0x07fb0c5a:  pop    %ebp
0x07fb0c5b:  ret    

----------------
IN: 
0x07fbb569:  mov    %eax,0xf5f90
0x07fbb56e:  mov    $0xb8,%al
0x07fbb570:  out    %al,$0x70
0x07fbb572:  in     $0x71,%al
0x07fbb574:  add    $0xc,%esp
0x07fbb577:  test   $0x1,%al
0x07fbb579:  je     0x7fbb585

----------------
IN: 
0x07fbb585:  mov    $0xbd,%al
0x07fbb587:  out    %al,$0x70
0x07fbb589:  in     $0x71,%al
0x07fbb58b:  movzbl %al,%edx
0x07fbb58e:  mov    $0xb8,%al
0x07fbb590:  out    %al,$0x70
0x07fbb592:  in     $0x71,%al
0x07fbb594:  and    $0xf0,%eax
0x07fbb599:  shl    $0x4,%eax
0x07fbb59c:  or     %edx,%eax
0x07fbb59e:  mov    $0x270f,%edi
0x07fbb5a3:  mov    $0x270f,%esi
0x07fbb5a8:  mov    $0x270f,%ebx
0x07fbb5ad:  mov    $0x270f,%ebp
0x07fbb5b2:  mov    $0x65,%edx
0x07fbb5b7:  mov    %eax,%ecx
0x07fbb5b9:  and    $0xf,%ecx
0x07fbb5bc:  shr    $0x4,%eax
0x07fbb5bf:  cmp    $0x2,%ecx
0x07fbb5c2:  je     0x7fbb5db

----------------
IN: 
0x07fbb5db:  mov    %edx,%edi
0x07fbb5dd:  jmp    0x7fbb5e1

----------------
IN: 
0x07fbb5e1:  inc    %edx
0x07fbb5e2:  cmp    $0x68,%edx
0x07fbb5e5:  jne    0x7fbb5b7

----------------
IN: 
0x07fbb5b7:  mov    %eax,%ecx
0x07fbb5b9:  and    $0xf,%ecx
0x07fbb5bc:  shr    $0x4,%eax
0x07fbb5bf:  cmp    $0x2,%ecx
0x07fbb5c2:  je     0x7fbb5db

----------------
IN: 
0x07fbb5c4:  ja     0x7fbb5cd

----------------
IN: 
0x07fbb5c6:  dec    %ecx
0x07fbb5c7:  jne    0x7fbb5e1

----------------
IN: 
0x07fbb5c9:  mov    %edx,%ebp
0x07fbb5cb:  jmp    0x7fbb5e1

----------------
IN: 
0x07fbb5cd:  cmp    $0x3,%ecx
0x07fbb5d0:  je     0x7fbb5df

----------------
IN: 
0x07fbb5df:  mov    %edx,%esi
0x07fbb5e1:  inc    %edx
0x07fbb5e2:  cmp    $0x68,%edx
0x07fbb5e5:  jne    0x7fbb5b7

----------------
IN: 
0x07fbb5e7:  mov    %ebp,0x7fbfe78
0x07fbb5ed:  mov    %edi,0x7fbfe70
0x07fbb5f3:  mov    %esi,0x7fbfe74
0x07fbb5f9:  mov    %ebx,0x7fbfe6c
0x07fbb5ff:  mov    $0xea60,%edx
0x07fbb604:  xor    %ecx,%ecx
0x07fbb606:  mov    $0xf55d2,%eax
0x07fbb60b:  call   0x7fb0bfd

----------------
IN: 
0x07fbb610:  mov    %eax,0xf5f74
0x07fbb615:  xor    %edx,%edx
0x07fbb617:  mov    $0xf55e5,%eax
0x07fbb61c:  call   0x7fb107c

----------------
IN: 
0x07fbb621:  mov    %eax,%ebx
0x07fbb623:  mov    $0x1,%edx
0x07fbb628:  test   %ebx,%ebx
0x07fbb62a:  je     0x7fbb6cb

----------------
IN: 
0x07fbb6cb:  movl   $0xfd4b1,0xf6ad4
0x07fbb6d5:  mov    $0x10,%edx
0x07fbb6da:  mov    $0xf6ad0,%eax
0x07fbb6df:  call   0xf069f

----------------
IN: 
0x000f069f:  push   %ebx
0x000f06a0:  xor    %ebx,%ebx
0x000f06a2:  xor    %ecx,%ecx
0x000f06a4:  cmp    %edx,%ecx
0x000f06a6:  je     0xf06ae

----------------
IN: 
0x000f06a8:  add    (%eax,%ecx,1),%bl
0x000f06ab:  inc    %ecx
0x000f06ac:  jmp    0xf06a4

----------------
IN: 
0x000f06a4:  cmp    %edx,%ecx
0x000f06a6:  je     0xf06ae

----------------
IN: 
0x000f06ae:  mov    %bl,%al
0x000f06b0:  pop    %ebx
0x000f06b1:  ret    

----------------
IN: 
0x07fbb6e4:  sub    %al,0xf6ada
0x07fbb6ea:  mov    $0xfd2f6,%eax
0x07fbb6ef:  mov    %ax,0xf67b7
0x07fbb6f5:  movw   $0xf000,0xf67b9
0x07fbb6fe:  mov    $0x10,%edx
0x07fbb703:  mov    $0xf67b0,%eax
0x07fbb708:  call   0xf069f

----------------
IN: 
0x07fbb70d:  sub    %al,0xf67b6
0x07fbb713:  mov    $0xfd358,%eax
0x07fbb718:  mov    %ax,0xf6afd
0x07fbb71e:  mov    $0xfd354,%eax
0x07fbb723:  mov    %ax,0xf6b01
0x07fbb729:  mov    $0x21,%edx
0x07fbb72e:  mov    $0xf6af0,%eax
0x07fbb733:  call   0xf069f

----------------
IN: 
0x07fbb738:  sub    %al,0xf6af8
0x07fbb73e:  movb   $0x10,0x496
0x07fbb745:  movw   $0x1e,0x41a
0x07fbb74e:  movw   $0x1e,0x41c
0x07fbb757:  movw   $0x1e,0x480
0x07fbb760:  movw   $0x3e,0x482
0x07fbb769:  orw    $0x4,0x410
0x07fbb771:  mov    %cr0,%eax
0x07fbb774:  and    $0x9fffffff,%eax
0x07fbb779:  mov    %eax,%cr0

----------------
IN: 
0x07fbb77c:  xor    %edx,%edx
0x07fbb77e:  mov    %dl,%al
0x07fbb780:  out    %al,$0xd
0x07fbb782:  out    %al,$0xda
0x07fbb784:  mov    $0xc0,%al
0x07fbb786:  out    %al,$0xd6
0x07fbb788:  mov    %dl,%al
0x07fbb78a:  out    %al,$0xd4
0x07fbb78c:  call   0xf067a

----------------
IN: 
0x000f067a:  mov    $0x11,%al
0x000f067c:  out    %al,$0x20
0x000f067e:  out    %al,$0xa0
0x000f0680:  mov    $0x8,%al
0x000f0682:  out    %al,$0x21
0x000f0684:  mov    $0x70,%al
0x000f0686:  out    %al,$0xa1
0x000f0688:  mov    $0x4,%al
0x000f068a:  out    %al,$0x21
0x000f068c:  mov    $0x2,%al
0x000f068e:  out    %al,$0xa1
0x000f0690:  mov    $0x1,%al
0x000f0692:  out    %al,$0x21
0x000f0694:  out    %al,$0xa1
0x000f0696:  mov    $0xfb,%al
0x000f0698:  out    %al,$0x21
0x000f069a:  mov    $0xff,%al
0x000f069c:  out    %al,$0xa1
0x000f069e:  ret    

----------------
IN: 
0x07fbb791:  orw    $0x2,0x410
0x07fbb799:  mov    $0x2000,%eax
0x07fbb79e:  call   0x7fb09b0

----------------
IN: 
0x07fb09b0:  mov    %eax,%edx
0x07fb09b2:  in     $0x21,%al
0x07fb09b4:  mov    %dl,%cl
0x07fb09b6:  not    %ecx
0x07fb09b8:  and    %ecx,%eax
0x07fb09ba:  out    %al,$0x21
0x07fb09bc:  in     $0xa1,%al
0x07fb09be:  shr    $0x8,%dx
0x07fb09c2:  not    %edx
0x07fb09c4:  and    %edx,%eax
0x07fb09c6:  out    %al,$0xa1
0x07fb09c8:  ret    

----------------
IN: 
0x07fbb7a3:  mov    $0xfd623,%eax
0x07fbb7a8:  mov    %ax,0x1d4
0x07fbb7ae:  movw   $0xf000,0x1d6
0x07fbb7b7:  cmpw   $0x0,0xf6ac0
0x07fbb7bf:  jne    0x7fbb8fa

----------------
IN: 
0x07fbb7c5:  movl   $0x0,0xec(%esp)
0x07fbb7d0:  lea    0xc4(%esp),%eax
0x07fbb7d7:  push   %eax
0x07fbb7d8:  lea    0xc0(%esp),%ebx
0x07fbb7df:  push   %ebx
0x07fbb7e0:  lea    0xc0(%esp),%ecx
0x07fbb7e7:  lea    0xbc(%esp),%edx
0x07fbb7ee:  xor    %eax,%eax
0x07fbb7f0:  call   0xf01be

----------------
IN: 
0x07fbb7f5:  pop    %ecx
0x07fbb7f6:  pop    %esi
0x07fbb7f7:  cmpl   $0x0,0xb4(%esp)
0x07fbb7ff:  je     0x7fbb824

----------------
IN: 
0x07fbb801:  lea    0xec(%esp),%eax
0x07fbb808:  push   %eax
0x07fbb809:  push   %ebx
0x07fbb80a:  lea    0xc0(%esp),%ecx
0x07fbb811:  lea    0xbc(%esp),%edx
0x07fbb818:  mov    $0x1,%eax
0x07fbb81d:  call   0xf01be

----------------
IN: 
0x07fbb822:  pop    %eax
0x07fbb823:  pop    %edx
0x07fbb824:  testb  $0x10,0xec(%esp)
0x07fbb82c:  jne    0x7fbb846

----------------
IN: 
0x07fbb846:  in     $0x61,%al
0x07fbb848:  mov    %al,%bl
0x07fbb84a:  mov    %al,%dl
0x07fbb84c:  and    $0xfffffffc,%edx
0x07fbb84f:  mov    %dl,%al
0x07fbb851:  or     $0x1,%eax
0x07fbb854:  out    %al,$0x61
0x07fbb856:  mov    $0xb0,%al
0x07fbb858:  out    %al,$0x43
0x07fbb85a:  xor    %eax,%eax
0x07fbb85c:  out    %al,$0x42
0x07fbb85e:  mov    $0x8,%al
0x07fbb860:  out    %al,$0x42
0x07fbb862:  rdtsc  
0x07fbb864:  mov    %eax,(%esp)
0x07fbb867:  mov    %edx,0x4(%esp)
0x07fbb86b:  in     $0x61,%al
0x07fbb86d:  test   $0x20,%al
0x07fbb86f:  je     0x7fbb86b

----------------
IN: 
0x07fbb86b:  in     $0x61,%al
0x07fbb86d:  test   $0x20,%al
0x07fbb86f:  je     0x7fbb86b

----------------
IN: 
0x07fbb871:  rdtsc  
0x07fbb873:  mov    %edx,%ecx
0x07fbb875:  mov    %eax,%edx
0x07fbb877:  mov    %bl,%al
0x07fbb879:  out    %al,$0x61
0x07fbb87b:  mov    %edx,%esi
0x07fbb87d:  mov    %ecx,%edi
0x07fbb87f:  sub    (%esp),%esi
0x07fbb882:  sbb    0x4(%esp),%edi
0x07fbb886:  imul   $0x369e99,%edi,%ecx
0x07fbb88c:  mov    $0x369e99,%eax
0x07fbb891:  mul    %esi
0x07fbb893:  add    %ecx,%edx
0x07fbb895:  add    $0x7ff,%eax
0x07fbb89a:  adc    $0x0,%edx
0x07fbb89d:  shrd   $0xb,%edx,%eax
0x07fbb8a1:  shr    $0xb,%edx
0x07fbb8a4:  mov    0xf6abe,%cl
0x07fbb8aa:  lea    0x1(%ecx),%ebx
0x07fbb8ad:  cmp    $0x0,%edx
0x07fbb8b0:  jbe    0x7fbb8c2

----------------
IN: 
0x07fbb8b2:  add    $0x1,%eax
0x07fbb8b5:  adc    $0x0,%edx
0x07fbb8b8:  shrd   $0x1,%edx,%eax
0x07fbb8bc:  shr    %edx
0x07fbb8be:  mov    %bl,%cl
0x07fbb8c0:  jmp    0x7fbb8aa

----------------
IN: 
0x07fbb8aa:  lea    0x1(%ecx),%ebx
0x07fbb8ad:  cmp    $0x0,%edx
0x07fbb8b0:  jbe    0x7fbb8c2

----------------
IN: 
0x07fbb8c2:  cmp    $0xffffff,%eax
0x07fbb8c7:  ja     0x7fbb8b2

----------------
IN: 
0x07fbb8c9:  mov    %cl,0xf6abe
0x07fbb8cf:  add    $0xbb7,%eax
0x07fbb8d4:  mov    $0xbb8,%esi
0x07fbb8d9:  xor    %edx,%edx
0x07fbb8db:  div    %esi
0x07fbb8dd:  mov    %eax,0xf6ac4
0x07fbb8e2:  shl    %cl,%eax
0x07fbb8e4:  mov    $0x3e8,%ecx
0x07fbb8e9:  xor    %edx,%edx
0x07fbb8eb:  div    %ecx
0x07fbb8ed:  push   %eax
0x07fbb8ee:  push   $0xf5604
0x07fbb8f3:  call   0xf0cc9

----------------
IN: 
0x000f0906:  xor    %eax,%eax
0x000f0908:  mov    0x0(%ebp),%edx
0x000f090b:  test   %al,%al
0x000f090d:  jne    0xf091d

----------------
IN: 
0x000f090f:  add    $0x4,%ebp
0x000f0912:  mov    %edi,%eax
0x000f0914:  call   0xeff48

----------------
IN: 
0x07fbb8f8:  pop    %ebp
0x07fbb8f9:  pop    %eax
0x07fbb8fa:  mov    $0x34,%al
0x07fbb8fc:  out    %al,$0x43
0x07fbb8fe:  xor    %eax,%eax
0x07fbb900:  out    %al,$0x40
0x07fbb902:  out    %al,$0x40
0x07fbb904:  mov    $0x8a,%cl
0x07fbb906:  mov    %cl,%al
0x07fbb908:  out    %al,$0x70
0x07fbb90a:  mov    $0x26,%al
0x07fbb90c:  out    %al,$0x71
0x07fbb90e:  mov    $0xb,%al
0x07fbb910:  out    %al,$0x70
0x07fbb912:  in     $0x71,%al
0x07fbb914:  and    $0x1,%eax
0x07fbb917:  or     $0x2,%eax
0x07fbb91a:  out    %al,$0x71
0x07fbb91c:  mov    $0x8c,%al
0x07fbb91e:  out    %al,$0x70
0x07fbb920:  in     $0x71,%al
0x07fbb922:  mov    $0x8d,%al
0x07fbb924:  out    %al,$0x70
0x07fbb926:  in     $0x71,%al
0x07fbb928:  mov    %cl,%al
0x07fbb92a:  out    %al,$0x70
0x07fbb92c:  in     $0x71,%al
0x07fbb92e:  test   %al,%al
0x07fbb930:  jns    0x7fbb95a

----------------
IN: 
0x07fbb95a:  mov    $0x80,%al
0x07fbb95c:  out    %al,$0x70
0x07fbb95e:  in     $0x71,%al
0x07fbb960:  mov    %al,%cl
0x07fbb962:  mov    $0x82,%al
0x07fbb964:  out    %al,$0x70
0x07fbb966:  in     $0x71,%al
0x07fbb968:  mov    %al,%dl
0x07fbb96a:  mov    $0x84,%al
0x07fbb96c:  out    %al,$0x70
0x07fbb96e:  in     $0x71,%al
0x07fbb970:  mov    %eax,%ebx
0x07fbb972:  and    $0xf,%ebx
0x07fbb975:  shr    $0x4,%al
0x07fbb978:  movzbl %al,%eax
0x07fbb97b:  imul   $0xa,%eax,%eax
0x07fbb97e:  add    %ebx,%eax
0x07fbb980:  imul   $0x3c,%eax,%eax
0x07fbb983:  mov    %edx,%ebx
0x07fbb985:  and    $0xf,%ebx
0x07fbb988:  shr    $0x4,%dl
0x07fbb98b:  movzbl %dl,%edx
0x07fbb98e:  imul   $0xa,%edx,%edx
0x07fbb991:  add    %ebx,%edx
0x07fbb993:  add    %edx,%eax
0x07fbb995:  imul   $0x3c,%eax,%eax
0x07fbb998:  mov    %ecx,%edx
0x07fbb99a:  and    $0xf,%edx
0x07fbb99d:  shr    $0x4,%cl
0x07fbb9a0:  movzbl %cl,%ecx
0x07fbb9a3:  imul   $0xa,%ecx,%ecx
0x07fbb9a6:  add    %edx,%ecx
0x07fbb9a8:  add    %ecx,%eax
0x07fbb9aa:  imul   $0x3e8,%eax,%eax
0x07fbb9b0:  mov    $0x369e99,%edx
0x07fbb9b5:  mul    %edx
0x07fbb9b7:  add    $0xffff,%eax
0x07fbb9bc:  adc    $0x0,%edx
0x07fbb9bf:  shrd   $0x10,%edx,%eax
0x07fbb9c3:  shr    $0x10,%edx
0x07fbb9c6:  add    $0xbb7,%eax
0x07fbb9cb:  mov    $0xbb8,%ebx
0x07fbb9d0:  xor    %edx,%edx
0x07fbb9d2:  div    %ebx
0x07fbb9d4:  mov    $0x1800b0,%ebx
0x07fbb9d9:  xor    %edx,%edx
0x07fbb9db:  div    %ebx
0x07fbb9dd:  mov    %edx,0x46c
0x07fbb9e3:  mov    $0xb2,%al
0x07fbb9e5:  out    %al,$0x70
0x07fbb9e7:  in     $0x71,%al
0x07fbb9e9:  mov    %al,0xef69d
0x07fbb9ee:  mov    $0x1,%eax
0x07fbb9f3:  call   0x7fb09b0

----------------
IN: 
0x07fbb9f8:  mov    $0xffea5,%eax
0x07fbb9fd:  mov    %ax,0x20
0x07fbba03:  movw   $0xf000,0x22
0x07fbba0c:  mov    $0x100,%eax
0x07fbba11:  call   0x7fb09b0

----------------
IN: 
0x07fbba16:  mov    $0xfd611,%eax
0x07fbba1b:  mov    %ax,0x1c0
0x07fbba21:  movw   $0xf000,0x1c2
0x07fbba2a:  call   0x7fb5ee3

----------------
IN: 
0x07fb5ee3:  push   %ebp
0x07fb5ee4:  push   %edi
0x07fb5ee5:  push   %esi
0x07fb5ee6:  push   %ebx
0x07fb5ee7:  sub    $0x88,%esp
0x07fb5eed:  mov    0xf67a0,%eax
0x07fb5ef2:  and    $0x2,%eax
0x07fb5ef5:  mov    %eax,0x30(%esp)
0x07fb5ef9:  je     0x7fb6094

----------------
IN: 
0x07fb6094:  push   $0xf493b
0x07fb6099:  call   0xf0cc9

----------------
IN: 
0x07fb609e:  mov    $0xcf8,%edx
0x07fb60a3:  mov    $0x80000000,%eax
0x07fb60a8:  out    %eax,(%dx)
0x07fb60a9:  in     (%dx),%eax
0x07fb60aa:  pop    %edx
0x07fb60ab:  cmp    $0x80000000,%eax
0x07fb60b0:  je     0x7fb7afa

----------------
IN: 
0x07fb7afa:  xor    %edx,%edx
0x07fb7afc:  xor    %ecx,%ecx
0x07fb7afe:  mov    $0xf3c12,%eax
0x07fb7b03:  call   0x7fb0bfd

----------------
IN: 
0x07fb7b08:  mov    %eax,%ebx
0x07fb7b0a:  movb   $0x0,0x68(%esp)
0x07fb7b0f:  lea    0x68(%esp),%edx
0x07fb7b13:  xor    %eax,%eax
0x07fb7b15:  call   0x7fb2ff1

----------------
IN: 
0x07fb2ff1:  push   %ebp
0x07fb2ff2:  push   %edi
0x07fb2ff3:  push   %esi
0x07fb2ff4:  push   %ebx
0x07fb2ff5:  sub    $0xc,%esp
0x07fb2ff8:  mov    %eax,(%esp)
0x07fb2ffb:  mov    %edx,%esi
0x07fb2ffd:  push   %eax
0x07fb2ffe:  push   $0x7fbe21c
0x07fb3003:  push   $0xf402b
0x07fb3008:  call   0xf0cc9

----------------
IN: 
0x000f0972:  mov    %ebx,%esi
0x000f0974:  lea    0x4(%ebp),%ebx
0x000f0977:  mov    0x0(%ebp),%ebp
0x000f097a:  movsbl 0x0(%ebp),%edx
0x000f097e:  test   %dl,%dl
0x000f0980:  je     0xf099a

----------------
IN: 
0x000f0982:  mov    %edi,%eax
0x000f0984:  call   0xeff40

----------------
IN: 
0x000f0989:  inc    %ebp
0x000f098a:  jmp    0xf097a

----------------
IN: 
0x000f097a:  movsbl 0x0(%ebp),%edx
0x000f097e:  test   %dl,%dl
0x000f0980:  je     0xf099a

----------------
IN: 
0x07fb300d:  mov    0xc(%esp),%ebx
0x07fb3011:  shl    $0x8,%ebx
0x07fb3014:  movzwl %bx,%ebx
0x07fb3017:  dec    %ebx
0x07fb3018:  mov    0xc(%esp),%edx
0x07fb301c:  mov    %ebx,%eax
0x07fb301e:  call   0xf0165

----------------
IN: 
0x000f0165:  push   %esi
0x000f0166:  push   %ebx
0x000f0167:  mov    %eax,%ebx
0x000f0169:  mov    %edx,%esi
0x000f016b:  test   $0x7,%al
0x000f016d:  jne    0xf01a0

----------------
IN: 
0x000f01a0:  inc    %ebx
0x000f01a1:  jmp    0xf0183

----------------
IN: 
0x000f0183:  movzbl %bh,%eax
0x000f0186:  cmp    %esi,%eax
0x000f0188:  jne    0xf01a3

----------------
IN: 
0x000f018a:  movzwl %bx,%eax
0x000f018d:  xor    %edx,%edx
0x000f018f:  call   0xf010e

----------------
IN: 
0x000f010e:  push   %ebx
0x000f010f:  mov    %eax,%ebx
0x000f0111:  mov    %edx,%ecx
0x000f0113:  mov    %edx,%eax
0x000f0115:  and    $0xfc,%eax
0x000f011a:  or     $0x80000000,%eax
0x000f011f:  movzwl %bx,%ebx
0x000f0122:  shl    $0x8,%ebx
0x000f0125:  or     %ebx,%eax
0x000f0127:  mov    $0xcf8,%edx
0x000f012c:  out    %eax,(%dx)
0x000f012d:  and    $0x2,%ecx
0x000f0130:  lea    0xcfc(%ecx),%edx
0x000f0136:  in     (%dx),%ax
0x000f0138:  pop    %ebx
0x000f0139:  ret    

----------------
IN: 
0x000f0194:  dec    %eax
0x000f0195:  cmp    $0xfffffffd,%ax
0x000f0199:  jbe    0xf01a8

----------------
IN: 
0x000f01a8:  mov    %ebx,%eax
0x000f01aa:  pop    %ebx
0x000f01ab:  pop    %esi
0x000f01ac:  ret    

----------------
IN: 
0x07fb3023:  mov    %eax,%edi
0x07fb3025:  add    $0xc,%esp
0x07fb3028:  test   %edi,%edi
0x07fb302a:  js     0x7fb306e

----------------
IN: 
0x07fb302c:  movzwl %di,%ebp
0x07fb302f:  mov    $0xa,%edx
0x07fb3034:  mov    %ebp,%eax
0x07fb3036:  call   0xf010e

----------------
IN: 
0x07fb303b:  cmp    $0x604,%ax
0x07fb303f:  jne    0x7fb3060

----------------
IN: 
0x07fb3060:  mov    (%esp),%edx
0x07fb3063:  mov    %edi,%eax
0x07fb3065:  call   0xf0165

----------------
IN: 
0x000f016f:  movzwl %ax,%eax
0x000f0172:  mov    $0xe,%edx
0x000f0177:  call   0xf013a

----------------
IN: 
0x000f013a:  push   %ebx
0x000f013b:  mov    %eax,%ebx
0x000f013d:  mov    %edx,%ecx
0x000f013f:  mov    %edx,%eax
0x000f0141:  and    $0xfc,%eax
0x000f0146:  or     $0x80000000,%eax
0x000f014b:  movzwl %bx,%ebx
0x000f014e:  shl    $0x8,%ebx
0x000f0151:  or     %ebx,%eax
0x000f0153:  mov    $0xcf8,%edx
0x000f0158:  out    %eax,(%dx)
0x000f0159:  and    $0x3,%ecx
0x000f015c:  lea    0xcfc(%ecx),%edx
0x000f0162:  in     (%dx),%al
0x000f0163:  pop    %ebx
0x000f0164:  ret    

----------------
IN: 
0x000f017c:  test   %al,%al
0x000f017e:  js     0xf01a0

----------------
IN: 
0x000f0180:  add    $0x8,%ebx
0x000f0183:  movzbl %bh,%eax
0x000f0186:  cmp    %esi,%eax
0x000f0188:  jne    0xf01a3

----------------
IN: 
0x07fb306a:  mov    %eax,%edi
0x07fb306c:  jmp    0x7fb3028

----------------
IN: 
0x07fb3028:  test   %edi,%edi
0x07fb302a:  js     0x7fb306e

----------------
IN: 
0x000f019b:  test   $0x7,%bl
0x000f019e:  je     0xf0180

----------------
IN: 
0x000f01a3:  or     $0xffffffff,%eax
0x000f01a6:  jmp    0xf01aa

----------------
IN: 
0x000f01aa:  pop    %ebx
0x000f01ab:  pop    %esi
0x000f01ac:  ret    

----------------
IN: 
0x07fb306e:  mov    (%esp),%edx
0x07fb3071:  mov    %ebx,%eax
0x07fb3073:  call   0xf0165

----------------
IN: 
0x07fb3078:  mov    %eax,%ebp
0x07fb307a:  movzbl (%esp),%eax
0x07fb307e:  mov    %eax,0x8(%esp)
0x07fb3082:  test   %ebp,%ebp
0x07fb3084:  js     0x7fb31c7

----------------
IN: 
0x07fb308a:  movzwl %bp,%edi
0x07fb308d:  mov    $0xa,%edx
0x07fb3092:  mov    %edi,%eax
0x07fb3094:  call   0xf010e

----------------
IN: 
0x07fb3099:  cmp    $0x604,%ax
0x07fb309d:  jne    0x7fb31b6

----------------
IN: 
0x07fb31b6:  mov    (%esp),%edx
0x07fb31b9:  mov    %ebp,%eax
0x07fb31bb:  call   0xf0165

----------------
IN: 
0x07fb31c0:  mov    %eax,%ebp
0x07fb31c2:  jmp    0x7fb3082

----------------
IN: 
0x07fb3082:  test   %ebp,%ebp
0x07fb3084:  js     0x7fb31c7

----------------
IN: 
0x07fb31c7:  add    $0xc,%esp
0x07fb31ca:  pop    %ebx
0x07fb31cb:  pop    %esi
0x07fb31cc:  pop    %edi
0x07fb31cd:  pop    %ebp
0x07fb31ce:  ret    

----------------
IN: 
0x07fb7b1a:  test   %bl,%bl
0x07fb7b1c:  je     0x7fb7b39

----------------
IN: 
0x07fb7b39:  push   $0xf4973
0x07fb7b3e:  call   0xf0cc9

----------------
IN: 
0x07fb7b43:  call   0x7fb22cb

----------------
IN: 
0x07fb22cb:  push   %ebp
0x07fb22cc:  push   %edi
0x07fb22cd:  push   %esi
0x07fb22ce:  push   %ebx
0x07fb22cf:  sub    $0x414,%esp
0x07fb22d5:  mov    $0x400,%ecx
0x07fb22da:  xor    %edx,%edx
0x07fb22dc:  lea    0x14(%esp),%eax
0x07fb22e0:  call   0xf0090

----------------
IN: 
0x07fb22e5:  xor    %edx,%edx
0x07fb22e7:  xor    %ecx,%ecx
0x07fb22e9:  mov    $0xf3c12,%eax
0x07fb22ee:  call   0x7fb0bfd

----------------
IN: 
0x07fb22f3:  mov    %eax,0x10(%esp)
0x07fb22f7:  movl   $0x0,0xc(%esp)
0x07fb22ff:  movl   $0x0,(%esp)
0x07fb2306:  movl   $0x0,0x4(%esp)
0x07fb230e:  or     $0xffffffff,%ebx
0x07fb2311:  mov    $0x7fbfed4,%ebp
0x07fb2316:  cmp    0xf6ac8,%ebx
0x07fb231c:  jge    0x7fb2454

----------------
IN: 
0x07fb2322:  inc    %ebx
0x07fb2323:  mov    %ebx,%eax
0x07fb2325:  shl    $0x8,%eax
0x07fb2328:  dec    %eax
0x07fb2329:  mov    %ebx,%edx
0x07fb232b:  call   0xf0165

----------------
IN: 
0x07fb2330:  mov    %eax,%edi
0x07fb2332:  test   %edi,%edi
0x07fb2334:  js     0x7fb2446

----------------
IN: 
0x07fb233a:  mov    $0x20,%eax
0x07fb233f:  call   0x7fb09cc

----------------
IN: 
0x07fb2344:  mov    %eax,%esi
0x07fb2346:  test   %eax,%eax
0x07fb2348:  jne    0x7fb235e

----------------
IN: 
0x07fb235e:  mov    $0x20,%ecx
0x07fb2363:  xor    %edx,%edx
0x07fb2365:  call   0xf0090

----------------
IN: 
0x07fb236a:  lea    0x4(%esi),%eax
0x07fb236d:  mov    %eax,0x8(%esp)
0x07fb2371:  mov    %ebp,%edx
0x07fb2373:  call   0x7faf48f

----------------
IN: 
0x07fb2378:  incl   0xc(%esp)
0x07fb237c:  mov    0x14(%esp,%ebx,4),%edx
0x07fb2380:  test   %edx,%edx
0x07fb2382:  jne    0x7fb23a0

----------------
IN: 
0x07fb2384:  xor    %eax,%eax
0x07fb2386:  cmp    0x4(%esp),%ebx
0x07fb238a:  setne  %al
0x07fb238d:  add    %eax,(%esp)
0x07fb2390:  cmp    0xf6ac8,%ebx
0x07fb2396:  jle    0x7fb23a6

----------------
IN: 
0x07fb23a6:  mov    (%esp),%eax
0x07fb23a9:  mov    %ebx,0x4(%esp)
0x07fb23ad:  mov    %di,(%esi)
0x07fb23b0:  mov    %edx,0xc(%esi)
0x07fb23b3:  mov    %al,0x2(%esi)
0x07fb23b6:  movzwl %di,%ebp
0x07fb23b9:  xor    %edx,%edx
0x07fb23bb:  mov    %ebp,%eax
0x07fb23bd:  call   0xf00ee

----------------
IN: 
0x000f00ee:  mov    %eax,%ecx
0x000f00f0:  mov    %edx,%eax
0x000f00f2:  and    $0xfc,%eax
0x000f00f7:  or     $0x80000000,%eax
0x000f00fc:  movzwl %cx,%ecx
0x000f00ff:  shl    $0x8,%ecx
0x000f0102:  or     %ecx,%eax
0x000f0104:  mov    $0xcf8,%edx
0x000f0109:  out    %eax,(%dx)
0x000f010a:  mov    $0xfc,%dl
0x000f010c:  in     (%dx),%eax
0x000f010d:  ret    

----------------
IN: 
0x07fb23c2:  mov    %ax,0x10(%esi)
0x07fb23c6:  shr    $0x10,%eax
0x07fb23c9:  mov    %ax,0x12(%esi)
0x07fb23cd:  mov    $0x8,%edx
0x07fb23d2:  mov    %ebp,%eax
0x07fb23d4:  call   0xf00ee

----------------
IN: 
0x07fb23d9:  mov    %eax,%edx
0x07fb23db:  shr    $0x10,%edx
0x07fb23de:  mov    %dx,0x14(%esi)
0x07fb23e2:  mov    %eax,%edx
0x07fb23e4:  shr    $0x8,%edx
0x07fb23e7:  mov    %dl,0x16(%esi)
0x07fb23ea:  mov    %al,0x17(%esi)
0x07fb23ed:  mov    $0xe,%edx
0x07fb23f2:  mov    %ebp,%eax
0x07fb23f4:  call   0xf013a

----------------
IN: 
0x07fb23f9:  mov    %al,0x18(%esi)
0x07fb23fc:  and    $0x7f,%eax
0x07fb23ff:  dec    %eax
0x07fb2400:  cmp    $0x1,%al
0x07fb2402:  ja     0x7fb2432

----------------
IN: 
0x07fb2432:  mov    %ebx,%edx
0x07fb2434:  mov    %edi,%eax
0x07fb2436:  call   0xf0165

----------------
IN: 
0x07fb243b:  mov    %eax,%edi
0x07fb243d:  mov    0x8(%esp),%ebp
0x07fb2441:  jmp    0x7fb2332

----------------
IN: 
0x07fb2332:  test   %edi,%edi
0x07fb2334:  js     0x7fb2446

----------------
IN: 
0x07fb2446:  cmp    $0xff,%ebx
0x07fb244c:  jne    0x7fb2316

----------------
IN: 
0x07fb2316:  cmp    0xf6ac8,%ebx
0x07fb231c:  jge    0x7fb2454

----------------
IN: 
0x07fb2454:  mov    0x10(%esp),%ecx
0x07fb2458:  cmp    %ecx,(%esp)
0x07fb245b:  jl     0x7fb2322

----------------
IN: 
0x07fb2461:  pushl  0xf6ac8
0x07fb2467:  pushl  0x10(%esp)
0x07fb246b:  push   $0xf3c26
0x07fb2470:  call   0xf0cc9

----------------
IN: 
0x07fb2475:  add    $0xc,%esp
0x07fb2478:  add    $0x414,%esp
0x07fb247e:  pop    %ebx
0x07fb247f:  pop    %esi
0x07fb2480:  pop    %edi
0x07fb2481:  pop    %ebp
0x07fb2482:  ret    

----------------
IN: 
0x07fb7b48:  mov    0x7fbff18,%eax
0x07fb7b4d:  mov    %eax,0x7fbfe08
0x07fb7b52:  movl   $0x0,0x7fbfe0c
0x07fb7b5c:  mov    0x7fbfed4,%eax
0x07fb7b61:  lea    -0x4(%eax),%ebx
0x07fb7b64:  pop    %ebp
0x07fb7b65:  cmp    $0xfffffffc,%ebx
0x07fb7b68:  je     0x7fb6237

----------------
IN: 
0x07fb7b6e:  xor    %ecx,%ecx
0x07fb7b70:  mov    %ebx,%edx
0x07fb7b72:  mov    $0x7fbfa0c,%eax
0x07fb7b77:  call   0x7faf57e

----------------
IN: 
0x07faf57e:  push   %esi
0x07faf57f:  push   %ebx
0x07faf580:  mov    %edx,%ebx
0x07faf582:  mov    %ecx,%edx
0x07faf584:  mov    (%eax),%esi
0x07faf586:  test   %esi,%esi
0x07faf588:  je     0x7faf5c9

----------------
IN: 
0x07faf58a:  cmp    $0xffffffff,%esi
0x07faf58d:  je     0x7faf597

----------------
IN: 
0x07faf58f:  movzwl 0x10(%ebx),%ecx
0x07faf593:  cmp    %ecx,%esi
0x07faf595:  jne    0x7faf5c4

----------------
IN: 
0x07faf597:  mov    0x4(%eax),%ecx
0x07faf59a:  cmp    $0xffffffff,%ecx
0x07faf59d:  je     0x7faf5a7

----------------
IN: 
0x07faf59f:  movzwl 0x12(%ebx),%esi
0x07faf5a3:  cmp    %esi,%ecx
0x07faf5a5:  jne    0x7faf5c4

----------------
IN: 
0x07faf5a7:  movzwl 0x14(%ebx),%esi
0x07faf5ab:  xor    0x8(%eax),%esi
0x07faf5ae:  test   %esi,0xc(%eax)
0x07faf5b1:  jne    0x7faf5c4

----------------
IN: 
0x07faf5b3:  mov    0x10(%eax),%ecx
0x07faf5b6:  xor    %eax,%eax
0x07faf5b8:  test   %ecx,%ecx
0x07faf5ba:  je     0x7faf5d2

----------------
IN: 
0x07faf5bc:  mov    %ebx,%eax
0x07faf5be:  call   *%ecx

----------------
IN: 
0x07faff38:  mov    0x7fbff18,%eax
0x07faff3d:  cmp    $0x80000000,%eax
0x07faff42:  ja     0x7faff50

----------------
IN: 
0x07faff44:  movl   $0x80000000,0x7fbfe08
0x07faff4e:  jmp    0x7faff61

----------------
IN: 
0x07faff61:  movl   $0x0,0x7fbfe0c
0x07faff6b:  movl   $0x7fafe74,0x7fbfde8
0x07faff75:  ret    

----------------
IN: 
0x07faf5c0:  xor    %eax,%eax
0x07faf5c2:  jmp    0x7faf5d2

----------------
IN: 
0x07faf5d2:  pop    %ebx
0x07faf5d3:  pop    %esi
0x07faf5d4:  ret    

----------------
IN: 
0x07fb7b7c:  mov    0x4(%ebx),%ebx
0x07fb7b7f:  sub    $0x4,%ebx
0x07fb7b82:  jmp    0x7fb7b65

----------------
IN: 
0x07fb7b65:  cmp    $0xfffffffc,%ebx
0x07fb7b68:  je     0x7fb6237

----------------
IN: 
0x07faf5c4:  add    $0x14,%eax
0x07faf5c7:  jmp    0x7faf584

----------------
IN: 
0x07faf584:  mov    (%eax),%esi
0x07faf586:  test   %esi,%esi
0x07faf588:  je     0x7faf5c9

----------------
IN: 
0x07faf5c9:  cmpl   $0x0,0xc(%eax)
0x07faf5cd:  jne    0x7faf58f

----------------
IN: 
0x07faf5cf:  or     $0xffffffff,%eax
0x07faf5d2:  pop    %ebx
0x07faf5d3:  pop    %esi
0x07faf5d4:  ret    

----------------
IN: 
0x07fb6237:  push   $0xf498f
0x07fb623c:  call   0xf0cc9

----------------
IN: 
0x07fb6241:  mov    0xf6ac8,%eax
0x07fb6246:  inc    %eax
0x07fb6247:  imul   $0x28,%eax,%eax
0x07fb624a:  call   0x7fb09cc

----------------
IN: 
0x07fb624f:  mov    %eax,0x4(%esp)
0x07fb6253:  pop    %edi
0x07fb6254:  test   %eax,%eax
0x07fb6256:  jne    0x7fb60c0

----------------
IN: 
0x07fb60c0:  mov    0xf6ac8,%eax
0x07fb60c5:  lea    0x1(%eax),%ecx
0x07fb60c8:  imul   $0x28,%ecx,%ecx
0x07fb60cb:  xor    %edx,%edx
0x07fb60cd:  mov    (%esp),%eax
0x07fb60d0:  call   0xf0090

----------------
IN: 
0x07fb60d5:  push   $0xf49b3
0x07fb60da:  call   0xf0cc9

----------------
IN: 
0x07fb60df:  mov    0x7fbfed4,%eax
0x07fb60e4:  lea    -0x4(%eax),%ebx
0x07fb60e7:  pop    %esi
0x07fb60e8:  cmp    $0xfffffffc,%ebx
0x07fb60eb:  jne    0x7fb7b84

----------------
IN: 
0x07fb7b84:  cmpw   $0x604,0x14(%ebx)
0x07fb7b8a:  jne    0x7fb7b9a

----------------
IN: 
0x07fb7b9a:  mov    (%ebx),%eax
0x07fb7b9c:  movzbl %ah,%eax
0x07fb7b9f:  imul   $0x28,%eax,%eax
0x07fb7ba2:  add    (%esp),%eax
0x07fb7ba5:  mov    %eax,0x34(%esp)
0x07fb7ba9:  cmpl   $0x0,0x24(%eax)
0x07fb7bad:  jne    0x7fb7bb6

----------------
IN: 
0x07fb7baf:  mov    (%esp),%eax
0x07fb7bb2:  mov    %eax,0x34(%esp)
0x07fb7bb6:  xor    %ebp,%ebp
0x07fb7bb8:  cmpw   $0x604,0x14(%ebx)
0x07fb7bbe:  jne    0x7fb7bce

----------------
IN: 
0x07fb7bce:  cmp    $0x6,%ebp
0x07fb7bd1:  je     0x7fb7bdc

----------------
IN: 
0x07fb7bd3:  lea    0x10(,%ebp,4),%eax
0x07fb7bda:  jmp    0x7fb7bf1

----------------
IN: 
0x07fb7bf1:  mov    %eax,0x10(%esp)
0x07fb7bf5:  movzwl (%ebx),%eax
0x07fb7bf8:  mov    %eax,0x8(%esp)
0x07fb7bfc:  mov    0x10(%esp),%edx
0x07fb7c00:  call   0xf00ee

----------------
IN: 
0x07fb7c05:  mov    %eax,0x28(%esp)
0x07fb7c09:  cmp    $0x6,%ebp
0x07fb7c0c:  jne    0x7fb7c3a

----------------
IN: 
0x07fb7c3a:  testb  $0x1,0x28(%esp)
0x07fb7c3f:  jne    0x7fb7c74

----------------
IN: 
0x07fb7c41:  mov    0x28(%esp),%eax
0x07fb7c45:  and    $0x8,%eax
0x07fb7c48:  cmp    $0x1,%eax
0x07fb7c4b:  sbb    %eax,%eax
0x07fb7c4d:  mov    %eax,0x20(%esp)
0x07fb7c51:  addl   $0x2,0x20(%esp)
0x07fb7c56:  mov    0x28(%esp),%eax
0x07fb7c5a:  and    $0x6,%eax
0x07fb7c5d:  cmp    $0x4,%eax
0x07fb7c60:  sete   %al
0x07fb7c63:  movzbl %al,%eax
0x07fb7c66:  mov    %eax,0x18(%esp)
0x07fb7c6a:  movl   $0xfffffff0,0x2c(%esp)
0x07fb7c72:  jmp    0x7fb7c8c

----------------
IN: 
0x07fb7c8c:  or     $0xffffffff,%ecx
0x07fb7c8f:  mov    0x10(%esp),%edx
0x07fb7c93:  mov    0x8(%esp),%eax
0x07fb7c97:  call   0xf009b

----------------
IN: 
0x000f009b:  push   %ebx
0x000f009c:  and    $0xfc,%edx
0x000f00a2:  or     $0x80000000,%edx
0x000f00a8:  movzwl %ax,%ebx
0x000f00ab:  shl    $0x8,%ebx
0x000f00ae:  mov    %edx,%eax
0x000f00b0:  or     %ebx,%eax
0x000f00b2:  mov    $0xcf8,%edx
0x000f00b7:  out    %eax,(%dx)
0x000f00b8:  mov    $0xfc,%dl
0x000f00ba:  mov    %ecx,%eax
0x000f00bc:  out    %eax,(%dx)
0x000f00bd:  pop    %ebx
0x000f00be:  ret    

----------------
IN: 
0x07fb7c9c:  mov    0x10(%esp),%edx
0x07fb7ca0:  mov    0x8(%esp),%eax
0x07fb7ca4:  call   0xf00ee

----------------
IN: 
0x07fb7ca9:  mov    %eax,0x40(%esp)
0x07fb7cad:  mov    0x28(%esp),%ecx
0x07fb7cb1:  mov    0x10(%esp),%edx
0x07fb7cb5:  mov    0x8(%esp),%eax
0x07fb7cb9:  call   0xf009b

----------------
IN: 
0x07fb7cbe:  cmpl   $0x0,0x18(%esp)
0x07fb7cc3:  je     0x7fb7d26

----------------
IN: 
0x07fb7d26:  mov    0x40(%esp),%eax
0x07fb7d2a:  and    0x2c(%esp),%eax
0x07fb7d2e:  neg    %eax
0x07fb7d30:  mov    %eax,%esi
0x07fb7d32:  xor    %edi,%edi
0x07fb7d34:  mov    %edi,%eax
0x07fb7d36:  or     %esi,%eax
0x07fb7d38:  je     0x7fb7d85

----------------
IN: 
0x07fb7d85:  mov    %ebp,%eax
0x07fb7d87:  inc    %eax
0x07fb7d88:  mov    %eax,%ebp
0x07fb7d8a:  cmp    $0x6,%eax
0x07fb7d8d:  jle    0x7fb7bb8

----------------
IN: 
0x07fb7bb8:  cmpw   $0x604,0x14(%ebx)
0x07fb7bbe:  jne    0x7fb7bce

----------------
IN: 
0x07fb7bdc:  mov    0x18(%ebx),%al
0x07fb7bdf:  and    $0x7f,%eax
0x07fb7be2:  dec    %al
0x07fb7be4:  sete   %al
0x07fb7be7:  movzbl %al,%eax
0x07fb7bea:  lea    0x30(,%eax,8),%eax
0x07fb7bf1:  mov    %eax,0x10(%esp)
0x07fb7bf5:  movzwl (%ebx),%eax
0x07fb7bf8:  mov    %eax,0x8(%esp)
0x07fb7bfc:  mov    0x10(%esp),%edx
0x07fb7c00:  call   0xf00ee

----------------
IN: 
0x07fb7c0e:  mov    $0xfffff800,%ecx
0x07fb7c13:  mov    0x10(%esp),%edx
0x07fb7c17:  mov    0x8(%esp),%eax
0x07fb7c1b:  call   0xf009b

----------------
IN: 
0x07fb7c20:  movl   $0xfffff800,0x2c(%esp)
0x07fb7c28:  movl   $0x1,0x20(%esp)
0x07fb7c30:  movl   $0x0,0x18(%esp)
0x07fb7c38:  jmp    0x7fb7c9c

----------------
IN: 
0x07fb7d93:  mov    0x4(%ebx),%eax
0x07fb7d96:  lea    -0x4(%eax),%ebx
0x07fb7d99:  jmp    0x7fb60e8

----------------
IN: 
0x07fb60e8:  cmp    $0xfffffffc,%ebx
0x07fb60eb:  jne    0x7fb7b84

----------------
IN: 
0x07fb7c74:  movl   $0xfffffffc,0x2c(%esp)
0x07fb7c7c:  movl   $0x0,0x20(%esp)
0x07fb7c84:  movl   $0x0,0x18(%esp)
0x07fb7c8c:  or     $0xffffffff,%ecx
0x07fb7c8f:  mov    0x10(%esp),%edx
0x07fb7c93:  mov    0x8(%esp),%eax
0x07fb7c97:  call   0xf009b

----------------
IN: 
0x07fb7d3a:  cmp    $0x0,%edi
0x07fb7d3d:  ja     0x7fb7d55

----------------
IN: 
0x07fb7d3f:  cmp    $0xfff,%esi
0x07fb7d45:  ja     0x7fb7d55

----------------
IN: 
0x07fb7d47:  cmpl   $0x0,0x20(%esp)
0x07fb7d4c:  je     0x7fb7d55

----------------
IN: 
0x07fb7d55:  pushl  0x18(%esp)
0x07fb7d59:  pushl  0x24(%esp)
0x07fb7d5d:  push   %edi
0x07fb7d5e:  push   %esi
0x07fb7d5f:  push   %edi
0x07fb7d60:  push   %esi
0x07fb7d61:  mov    %ebp,%ecx
0x07fb7d63:  mov    %ebx,%edx
0x07fb7d65:  mov    0x4c(%esp),%eax
0x07fb7d69:  call   0x7fb1490

----------------
IN: 
0x07fb1490:  push   %ebp
0x07fb1491:  push   %edi
0x07fb1492:  push   %esi
0x07fb1493:  push   %ebx
0x07fb1494:  sub    $0x10,%esp
0x07fb1497:  mov    %eax,0x8(%esp)
0x07fb149b:  mov    %edx,0xc(%esp)
0x07fb149f:  mov    %ecx,%edi
0x07fb14a1:  mov    0x24(%esp),%ebp
0x07fb14a5:  mov    0x28(%esp),%eax
0x07fb14a9:  mov    %eax,0x4(%esp)
0x07fb14ad:  mov    0x2c(%esp),%eax
0x07fb14b1:  mov    %eax,(%esp)
0x07fb14b4:  mov    0x30(%esp),%esi
0x07fb14b8:  mov    $0x28,%eax
0x07fb14bd:  call   0x7fb09cc

----------------
IN: 
0x07fb14c2:  mov    %eax,%ebx
0x07fb14c4:  test   %eax,%eax
0x07fb14c6:  jne    0x7fb14de

----------------
IN: 
0x07fb14de:  mov    $0x28,%ecx
0x07fb14e3:  xor    %edx,%edx
0x07fb14e5:  call   0xf0090

----------------
IN: 
0x07fb14ea:  mov    0xc(%esp),%eax
0x07fb14ee:  mov    %eax,(%ebx)
0x07fb14f0:  mov    %edi,0x4(%ebx)
0x07fb14f3:  mov    %ebp,0x8(%ebx)
0x07fb14f6:  mov    0x4(%esp),%eax
0x07fb14fa:  mov    %eax,0xc(%ebx)
0x07fb14fd:  mov    (%esp),%eax
0x07fb1500:  mov    %eax,0x10(%ebx)
0x07fb1503:  mov    %esi,0x14(%ebx)
0x07fb1506:  mov    0x38(%esp),%eax
0x07fb150a:  mov    %eax,0x18(%ebx)
0x07fb150d:  mov    0x34(%esp),%eax
0x07fb1511:  mov    %eax,0x1c(%ebx)
0x07fb1514:  imul   $0xc,%eax,%eax
0x07fb1517:  add    0x8(%esp),%eax
0x07fb151b:  lea    0x8(%eax),%edx
0x07fb151e:  mov    0x8(%eax),%eax
0x07fb1521:  test   %eax,%eax
0x07fb1523:  jne    0x7fb1531

----------------
IN: 
0x07fb1525:  lea    0x20(%ebx),%eax
0x07fb1528:  call   0x7faf48f

----------------
IN: 
0x07fb152d:  mov    %ebx,%eax
0x07fb152f:  jmp    0x7fb1563

----------------
IN: 
0x07fb1563:  add    $0x10,%esp
0x07fb1566:  pop    %ebx
0x07fb1567:  pop    %esi
0x07fb1568:  pop    %edi
0x07fb1569:  pop    %ebp
0x07fb156a:  ret    

----------------
IN: 
0x07fb7d6e:  add    $0x18,%esp
0x07fb7d71:  test   %eax,%eax
0x07fb7d73:  je     0x7fb626a

----------------
IN: 
0x07fb7d79:  cmpl   $0x1,0x18(%esp)
0x07fb7d7e:  mov    %ebp,%eax
0x07fb7d80:  sbb    $0xffffffff,%eax
0x07fb7d83:  mov    %eax,%ebp
0x07fb7d85:  mov    %ebp,%eax
0x07fb7d87:  inc    %eax
0x07fb7d88:  mov    %eax,%ebp
0x07fb7d8a:  cmp    $0x6,%eax
0x07fb7d8d:  jle    0x7fb7bb8

----------------
IN: 
0x07fb1531:  mov    -0x10(%eax),%ecx
0x07fb1534:  mov    -0xc(%eax),%edi
0x07fb1537:  cmp    %esi,%edi
0x07fb1539:  jb     0x7fb1525

----------------
IN: 
0x07fb153b:  jbe    0x7fb155c

----------------
IN: 
0x07fb155c:  cmp    (%esp),%ecx
0x07fb155f:  jb     0x7fb1525

----------------
IN: 
0x07fb60f1:  mov    0xf6ac8,%eax
0x07fb60f6:  mov    %eax,0x10(%esp)
0x07fb60fa:  imul   $0x28,%eax,%ebx
0x07fb60fd:  add    (%esp),%ebx
0x07fb6100:  cmpl   $0x0,0x10(%esp)
0x07fb6105:  jg     0x7fb7d9e

----------------
IN: 
0x07fb610b:  push   $0xf4c11
0x07fb6110:  call   0xf0cc9

----------------
IN: 
0x07fb6115:  mov    0x4(%esp),%eax
0x07fb6119:  call   0x7faff93

----------------
IN: 
0x07faff93:  push   %ebp
0x07faff94:  mov    %esp,%ebp
0x07faff96:  push   %edi
0x07faff97:  mov    0x8(%eax),%ecx
0x07faff9a:  sub    $0x20,%ecx
0x07faff9d:  xor    %eax,%eax
0x07faff9f:  xor    %edx,%edx
0x07faffa1:  cmp    $0xffffffe0,%ecx
0x07faffa4:  je     0x7faffb4

----------------
IN: 
0x07faffa6:  add    0x8(%ecx),%eax
0x07faffa9:  adc    0xc(%ecx),%edx
0x07faffac:  mov    0x20(%ecx),%ecx
0x07faffaf:  sub    $0x20,%ecx
0x07faffb2:  jmp    0x7faffa1

----------------
IN: 
0x07faffa1:  cmp    $0xffffffe0,%ecx
0x07faffa4:  je     0x7faffb4

----------------
IN: 
0x07faffb4:  pop    %edi
0x07faffb5:  pop    %ebp
0x07faffb6:  ret    

----------------
IN: 
0x07fb611e:  pop    %ecx
0x07fb611f:  cmp    $0x0,%edx
0x07fb6122:  ja     0x7fb7fc2

----------------
IN: 
0x07fb6128:  cmp    $0x3fff,%eax
0x07fb612d:  ja     0x7fb7fc2

----------------
IN: 
0x07fb6133:  mov    (%esp),%edi
0x07fb6136:  movl   $0xc000,(%edi)
0x07fb613c:  movl   $0x0,0x4(%edi)
0x07fb6143:  mov    (%esp),%edi
0x07fb6146:  mov    (%edi),%ecx
0x07fb6148:  mov    0x4(%edi),%ebx
0x07fb614b:  mov    %ecx,%esi
0x07fb614d:  mov    %ebx,%edi
0x07fb614f:  add    $0xffffffff,%esi
0x07fb6152:  adc    $0xffffffff,%edi
0x07fb6155:  add    %esi,%eax
0x07fb6157:  adc    %edi,%edx
0x07fb6159:  push   %edx
0x07fb615a:  push   %eax
0x07fb615b:  push   %ebx
0x07fb615c:  push   %ecx
0x07fb615d:  push   $0xf49f2
0x07fb6162:  call   0xf0cc9

----------------
IN: 
0x07fb6167:  push   $0x0
0x07fb6169:  push   $0xfec00000
0x07fb616e:  pushl  0x7fbfe0c
0x07fb6174:  pushl  0x7fbfe08
0x07fb617a:  push   $0xf4a0a
0x07fb617f:  call   0xf0cc9

----------------
IN: 
0x07fb6184:  add    $0x28,%esp
0x07fb6187:  mov    (%esp),%eax
0x07fb618a:  call   0x7fafff9

----------------
IN: 
0x07fafff9:  push   %ebp
0x07fafffa:  push   %edi
0x07fafffb:  push   %esi
0x07fafffc:  push   %ebx
0x07fafffd:  sub    $0x8,%esp
0x07fb0000:  lea    0x18(%eax),%esi
0x07fb0003:  lea    0xc(%eax),%ebx
0x07fb0006:  mov    %ebx,%eax
0x07fb0008:  call   0x7faff76

----------------
IN: 
0x07faff76:  push   %ebp
0x07faff77:  mov    %esp,%ebp
0x07faff79:  push   %edi
0x07faff7a:  mov    0x8(%eax),%eax
0x07faff7d:  test   %eax,%eax
0x07faff7f:  je     0x7faff89

----------------
IN: 
0x07faff81:  mov    -0xc(%eax),%edx
0x07faff84:  mov    -0x10(%eax),%eax
0x07faff87:  jmp    0x7faff90

----------------
IN: 
0x07faff90:  pop    %edi
0x07faff91:  pop    %ebp
0x07faff92:  ret    

----------------
IN: 
0x07fb000d:  mov    %eax,%edi
0x07fb000f:  mov    %edx,%ebp
0x07fb0011:  mov    %esi,%eax
0x07fb0013:  call   0x7faff76

----------------
IN: 
0x07fb0018:  cmp    %edx,%ebp
0x07fb001a:  ja     0x7fb0028

----------------
IN: 
0x07fb001c:  jb     0x7fb0022

----------------
IN: 
0x07fb001e:  cmp    %eax,%edi
0x07fb0020:  jae    0x7fb0028

----------------
IN: 
0x07fb0022:  mov    %esi,%eax
0x07fb0024:  mov    %ebx,%esi
0x07fb0026:  mov    %eax,%ebx
0x07fb0028:  mov    %esi,%eax
0x07fb002a:  call   0x7faff93

----------------
IN: 
0x07fb002f:  mov    %eax,%edi
0x07fb0031:  mov    %edx,%ebp
0x07fb0033:  mov    %esi,%eax
0x07fb0035:  call   0x7faff76

----------------
IN: 
0x07fb003a:  neg    %eax
0x07fb003c:  adc    $0x0,%edx
0x07fb003f:  neg    %edx
0x07fb0041:  mov    %eax,(%esp)
0x07fb0044:  mov    %edx,0x4(%esp)
0x07fb0048:  mov    $0xfec00000,%eax
0x07fb004d:  xor    %edx,%edx
0x07fb004f:  sub    %edi,%eax
0x07fb0051:  sbb    %ebp,%edx
0x07fb0053:  mov    (%esp),%ecx
0x07fb0056:  and    %eax,%ecx
0x07fb0058:  mov    %ecx,%edi
0x07fb005a:  mov    0x4(%esp),%ecx
0x07fb005e:  and    %edx,%ecx
0x07fb0060:  mov    %ecx,%ebp
0x07fb0062:  mov    %edi,(%esi)
0x07fb0064:  mov    %ecx,0x4(%esi)
0x07fb0067:  mov    %ebx,%eax
0x07fb0069:  call   0x7faff93

----------------
IN: 
0x07fb006e:  mov    %eax,(%esp)
0x07fb0071:  mov    %edx,0x4(%esp)
0x07fb0075:  mov    %ebx,%eax
0x07fb0077:  call   0x7faff76

----------------
IN: 
0x07fb007c:  sub    (%esp),%edi
0x07fb007f:  sbb    0x4(%esp),%ebp
0x07fb0083:  mov    %edi,%esi
0x07fb0085:  neg    %eax
0x07fb0087:  adc    $0x0,%edx
0x07fb008a:  neg    %edx
0x07fb008c:  mov    %esi,%ecx
0x07fb008e:  and    %eax,%ecx
0x07fb0090:  and    %ebp,%edx
0x07fb0092:  mov    %ecx,(%ebx)
0x07fb0094:  mov    %edx,0x4(%ebx)
0x07fb0097:  mov    $0x1,%bl
0x07fb0099:  cmp    0x7fbfe0c,%edx
0x07fb009f:  jb     0x7fb00ad

----------------
IN: 
0x07fb00a1:  ja     0x7fb00ab

----------------
IN: 
0x07fb00a3:  cmp    0x7fbfe08,%ecx
0x07fb00a9:  jb     0x7fb00ad

----------------
IN: 
0x07fb00ab:  xor    %ebx,%ebx
0x07fb00ad:  mov    $0x1,%al
0x07fb00af:  cmp    $0x0,%edx
0x07fb00b2:  ja     0x7fb00bd

----------------
IN: 
0x07fb00b4:  cmp    $0xfec00000,%ecx
0x07fb00ba:  seta   %al
0x07fb00bd:  or     %ebx,%eax
0x07fb00bf:  movzbl %al,%eax
0x07fb00c2:  neg    %eax
0x07fb00c4:  add    $0x8,%esp
0x07fb00c7:  pop    %ebx
0x07fb00c8:  pop    %esi
0x07fb00c9:  pop    %edi
0x07fb00ca:  pop    %ebp
0x07fb00cb:  ret    

----------------
IN: 
0x07fb618f:  test   %eax,%eax
0x07fb6191:  je     0x7fb818c

----------------
IN: 
0x07fb818c:  movl   $0x0,0x7fbfe00
0x07fb8196:  movl   $0x0,0x7fbfe04
0x07fb81a0:  jmp    0x7fb8185

----------------
IN: 
0x07fb8185:  mov    (%esp),%ebx
0x07fb8188:  xor    %esi,%esi
0x07fb818a:  jmp    0x7fb81a2

----------------
IN: 
0x07fb81a2:  cmp    0xf6ac8,%esi
0x07fb81a8:  jg     0x7fb61df

----------------
IN: 
0x07fb81ae:  mov    %ebx,%edx
0x07fb81b0:  mov    (%esp),%eax
0x07fb81b3:  call   0x7fb31e0

----------------
IN: 
0x07fb31e0:  push   %ebp
0x07fb31e1:  push   %edi
0x07fb31e2:  push   %esi
0x07fb31e3:  push   %ebx
0x07fb31e4:  sub    $0x24,%esp
0x07fb31e7:  mov    %eax,0x20(%esp)
0x07fb31eb:  mov    %edx,0x10(%esp)
0x07fb31ef:  mov    0x8(%edx),%eax
0x07fb31f2:  mov    %eax,(%esp)
0x07fb31f5:  lea    -0x20(%eax),%ebx
0x07fb31f8:  cmp    $0xffffffe0,%ebx
0x07fb31fb:  je     0x7fb3432

----------------
IN: 
0x07fb3201:  mov    0x20(%ebx),%eax
0x07fb3204:  mov    %eax,0x1c(%esp)
0x07fb3208:  mov    0x10(%esp),%eax
0x07fb320c:  mov    0x4(%eax),%edx
0x07fb320f:  mov    (%eax),%eax
0x07fb3211:  mov    %eax,(%esp)
0x07fb3214:  mov    %edx,0x4(%esp)
0x07fb3218:  mov    0x8(%ebx),%edi
0x07fb321b:  mov    0xc(%ebx),%ebp
0x07fb321e:  add    %edi,%eax
0x07fb3220:  adc    %ebp,%edx
0x07fb3222:  mov    %eax,0x14(%esp)
0x07fb3226:  mov    %edx,0x18(%esp)
0x07fb322a:  mov    0x10(%esp),%eax
0x07fb322e:  mov    0x14(%esp),%edx
0x07fb3232:  mov    0x18(%esp),%ecx
0x07fb3236:  mov    %edx,(%eax)
0x07fb3238:  mov    %ecx,0x4(%eax)
0x07fb323b:  mov    0x4(%ebx),%eax
0x07fb323e:  mov    %eax,0x8(%esp)
0x07fb3242:  inc    %eax
0x07fb3243:  jne    0x7fb3264

----------------
IN: 
0x07fb3264:  mov    (%ebx),%ecx
0x07fb3266:  movzwl (%ecx),%esi
0x07fb3269:  cmpl   $0x0,0x8(%esp)
0x07fb326e:  js     0x7fb32fc

----------------
IN: 
0x07fb3274:  mov    0x1c(%ebx),%eax
0x07fb3277:  pushl  0x7fbfb50(,%eax,4)
0x07fb327e:  push   %ebp
0x07fb327f:  push   %edi
0x07fb3280:  pushl  0x10(%esp)
0x07fb3284:  pushl  0x10(%esp)
0x07fb3288:  pushl  0x1c(%esp)
0x07fb328c:  mov    %esi,%eax
0x07fb328e:  and    $0x7,%eax
0x07fb3291:  push   %eax
0x07fb3292:  mov    %esi,%eax
0x07fb3294:  shr    $0x3,%ax
0x07fb3298:  and    $0x1f,%eax
0x07fb329b:  push   %eax
0x07fb329c:  mov    %esi,%eax
0x07fb329e:  movzbl %ah,%esi
0x07fb32a1:  push   %esi
0x07fb32a2:  push   $0xf413b
0x07fb32a7:  call   0xf0cc9

----------------
IN: 
0x07fb32ac:  mov    0x18(%ebx),%ebp
0x07fb32af:  mov    0x4(%ebx),%eax
0x07fb32b2:  mov    (%ebx),%edi
0x07fb32b4:  add    $0x28,%esp
0x07fb32b7:  lea    0x10(,%eax,4),%esi
0x07fb32be:  cmp    $0x6,%eax
0x07fb32c1:  jne    0x7fb32d8

----------------
IN: 
0x07fb32d8:  movzwl (%edi),%eax
0x07fb32db:  mov    (%esp),%ecx
0x07fb32de:  mov    %esi,%edx
0x07fb32e0:  call   0xf009b

----------------
IN: 
0x07fb32e5:  test   %ebp,%ebp
0x07fb32e7:  je     0x7fb3417

----------------
IN: 
0x07fb3417:  lea    0x20(%ebx),%eax
0x07fb341a:  call   0x7faf480

----------------
IN: 
0x07faf48b:  mov    %eax,0x4(%edx)
0x07faf48e:  ret    

----------------
IN: 
0x07fb341f:  mov    %ebx,%eax
0x07fb3421:  call   0x7faf92b

----------------
IN: 
0x07faf92b:  push   %esi
0x07faf92c:  push   %ebx
0x07faf92d:  mov    %eax,%esi
0x07faf92f:  call   0x7faf838

----------------
IN: 
0x07faf838:  xor    %ecx,%ecx
0x07faf83a:  mov    0x7fbfe88(,%ecx,4),%edx
0x07faf841:  mov    (%edx),%edx
0x07faf843:  test   %edx,%edx
0x07faf845:  je     0x7faf84f

----------------
IN: 
0x07faf847:  cmp    %eax,0x8(%edx)
0x07faf84a:  jne    0x7faf841

----------------
IN: 
0x07faf841:  mov    (%edx),%edx
0x07faf843:  test   %edx,%edx
0x07faf845:  je     0x7faf84f

----------------
IN: 
0x07faf84f:  inc    %ecx
0x07faf850:  cmp    $0x5,%ecx
0x07faf853:  jne    0x7faf83a

----------------
IN: 
0x07faf83a:  mov    0x7fbfe88(,%ecx,4),%edx
0x07faf841:  mov    (%edx),%edx
0x07faf843:  test   %edx,%edx
0x07faf845:  je     0x7faf84f

----------------
IN: 
0x07faf84c:  mov    %edx,%eax
0x07faf84e:  ret    

----------------
IN: 
0x07faf934:  mov    %eax,%ebx
0x07faf936:  or     $0xffffffff,%eax
0x07faf939:  cmp    %ebx,%esi
0x07faf93b:  je     0x7faf957

----------------
IN: 
0x07faf93d:  test   %ebx,%ebx
0x07faf93f:  je     0x7faf957

----------------
IN: 
0x07faf941:  cmp    0xc(%ebx),%esi
0x07faf944:  je     0x7faf957

----------------
IN: 
0x07faf946:  mov    %ebx,%eax
0x07faf948:  call   0x7faf81f

----------------
IN: 
0x07faf81f:  mov    (%eax),%edx
0x07faf821:  test   %edx,%edx
0x07faf823:  je     0x7faf833

----------------
IN: 
0x07faf825:  mov    0x8(%eax),%ecx
0x07faf828:  cmp    %ecx,0x10(%edx)
0x07faf82b:  jne    0x7faf833

----------------
IN: 
0x07faf82d:  mov    0x10(%eax),%ecx
0x07faf830:  mov    %ecx,0x10(%edx)
0x07faf833:  jmp    0x7faf480

----------------
IN: 
0x07faf94d:  lea    -0x14(%ebx),%eax
0x07faf950:  call   0x7faf81f

----------------
IN: 
0x07faf955:  xor    %eax,%eax
0x07faf957:  pop    %ebx
0x07faf958:  pop    %esi
0x07faf959:  ret    

----------------
IN: 
0x07fb3426:  mov    0x1c(%esp),%ebx
0x07fb342a:  sub    $0x20,%ebx
0x07fb342d:  jmp    0x7fb31f8

----------------
IN: 
0x07fb31f8:  cmp    $0xffffffe0,%ebx
0x07fb31fb:  je     0x7fb3432

----------------
IN: 
0x07fb3432:  add    $0x24,%esp
0x07fb3435:  pop    %ebx
0x07fb3436:  pop    %esi
0x07fb3437:  pop    %edi
0x07fb3438:  pop    %ebp
0x07fb3439:  ret    

----------------
IN: 
0x07fb81b8:  lea    0xc(%ebx),%edx
0x07fb81bb:  mov    (%esp),%eax
0x07fb81be:  call   0x7fb31e0

----------------
IN: 
0x07fb32c3:  mov    0x18(%edi),%al
0x07fb32c6:  and    $0x7f,%eax
0x07fb32c9:  dec    %al
0x07fb32cb:  sete   %al
0x07fb32ce:  movzbl %al,%eax
0x07fb32d1:  lea    0x30(,%eax,8),%esi
0x07fb32d8:  movzwl (%edi),%eax
0x07fb32db:  mov    (%esp),%ecx
0x07fb32de:  mov    %esi,%edx
0x07fb32e0:  call   0xf009b

----------------
IN: 
0x07fb81c3:  lea    0x18(%ebx),%edx
0x07fb81c6:  mov    (%esp),%eax
0x07fb81c9:  call   0x7fb31e0

----------------
IN: 
0x07fb81ce:  inc    %esi
0x07fb81cf:  add    $0x28,%ebx
0x07fb81d2:  jmp    0x7fb81a2

----------------
IN: 
0x07fb61df:  mov    0x7fbfed4,%eax
0x07fb61e4:  lea    -0x4(%eax),%ebx
0x07fb61e7:  cmp    $0xfffffffc,%ebx
0x07fb61ea:  jne    0x7fb81d4

----------------
IN: 
0x07fb81d4:  movzwl (%ebx),%esi
0x07fb81d7:  movzwl 0x12(%ebx),%eax
0x07fb81db:  push   %eax
0x07fb81dc:  movzwl 0x10(%ebx),%eax
0x07fb81e0:  push   %eax
0x07fb81e1:  mov    %esi,%eax
0x07fb81e3:  and    $0x7,%eax
0x07fb81e6:  push   %eax
0x07fb81e7:  mov    %esi,%eax
0x07fb81e9:  shr    $0x3,%ax
0x07fb81ed:  and    $0x1f,%eax
0x07fb81f0:  push   %eax
0x07fb81f1:  mov    %esi,%eax
0x07fb81f3:  movzbl %ah,%eax
0x07fb81f6:  push   %eax
0x07fb81f7:  push   $0xf4a7b
0x07fb81fc:  call   0xf0cc9

----------------
IN: 
0x07fb8201:  mov    $0x3d,%edx
0x07fb8206:  mov    %esi,%eax
0x07fb8208:  call   0xf013a

----------------
IN: 
0x07fb820d:  movzbl %al,%edx
0x07fb8210:  add    $0x18,%esp
0x07fb8213:  test   %edx,%edx
0x07fb8215:  je     0x7fb822e

----------------
IN: 
0x07fb822e:  xor    %ecx,%ecx
0x07fb8230:  mov    %ebx,%edx
0x07fb8232:  mov    $0x7fbfa48,%eax
0x07fb8237:  call   0x7faf57e

----------------
IN: 
0x07fb823c:  mov    $0x103,%ecx
0x07fb8241:  mov    $0x4,%edx
0x07fb8246:  mov    %esi,%eax
0x07fb8248:  call   0x7fb089b

----------------
IN: 
0x07fb089b:  push   %edi
0x07fb089c:  push   %esi
0x07fb089d:  push   %ebx
0x07fb089e:  mov    %edx,%edi
0x07fb08a0:  mov    %ecx,%ebx
0x07fb08a2:  movzwl %ax,%esi
0x07fb08a5:  mov    %esi,%eax
0x07fb08a7:  call   0xf010e

----------------
IN: 
0x07fb08ac:  or     %eax,%ebx
0x07fb08ae:  movzwl %bx,%ecx
0x07fb08b1:  mov    %edi,%edx
0x07fb08b3:  mov    %esi,%eax
0x07fb08b5:  pop    %ebx
0x07fb08b6:  pop    %esi
0x07fb08b7:  pop    %edi
0x07fb08b8:  jmp    0x7faf529

----------------
IN: 
0x07faf529:  push   %esi
0x07faf52a:  push   %ebx
0x07faf52b:  mov    %eax,%ebx
0x07faf52d:  mov    %edx,%esi
0x07faf52f:  mov    %edx,%eax
0x07faf531:  and    $0xfc,%eax
0x07faf536:  or     $0x80000000,%eax
0x07faf53b:  movzwl %bx,%ebx
0x07faf53e:  shl    $0x8,%ebx
0x07faf541:  or     %ebx,%eax
0x07faf543:  mov    $0xcf8,%edx
0x07faf548:  out    %eax,(%dx)
0x07faf549:  and    $0x2,%esi
0x07faf54c:  lea    0xcfc(%esi),%edx
0x07faf552:  mov    %ecx,%eax
0x07faf554:  out    %ax,(%dx)
0x07faf556:  pop    %ebx
0x07faf557:  pop    %esi
0x07faf558:  ret    

----------------
IN: 
0x07fb824d:  mov    0x4(%ebx),%ebx
0x07fb8250:  sub    $0x4,%ebx
0x07fb8253:  jmp    0x7fb61e7

----------------
IN: 
0x07fb61e7:  cmp    $0xfffffffc,%ebx
0x07fb61ea:  jne    0x7fb81d4

----------------
IN: 
0x07fb34f6:  push   %ebp
0x07fb34f7:  push   %edi
0x07fb34f8:  push   %esi
0x07fb34f9:  push   %ebx
0x07fb34fa:  push   %edx
0x07fb34fb:  mov    %eax,%esi
0x07fb34fd:  movb   $0x0,0x2(%esp)
0x07fb3502:  movb   $0x0,0x3(%esp)
0x07fb3507:  mov    $0x60,%ebx
0x07fb350c:  movzbl 0x7fbfaec(%ebx),%edi
0x07fb3513:  mov    %edi,%eax
0x07fb3515:  sar    $0x3,%eax
0x07fb3518:  mov    %edi,%ecx
0x07fb351a:  and    $0x7,%ecx
0x07fb351d:  mov    $0x1,%ebp
0x07fb3522:  mov    %ebp,%edx
0x07fb3524:  shl    %cl,%edx
0x07fb3526:  or     %dl,0x2(%esp,%eax,1)
0x07fb352a:  movzwl (%esi),%eax
0x07fb352d:  mov    %edi,%ecx
0x07fb352f:  mov    %ebx,%edx
0x07fb3531:  call   0xf00bf

----------------
IN: 
0x000f00bf:  push   %esi
0x000f00c0:  push   %ebx
0x000f00c1:  mov    %eax,%ebx
0x000f00c3:  mov    %edx,%esi
0x000f00c5:  mov    %edx,%eax
0x000f00c7:  and    $0xfc,%eax
0x000f00cc:  or     $0x80000000,%eax
0x000f00d1:  movzwl %bx,%ebx
0x000f00d4:  shl    $0x8,%ebx
0x000f00d7:  or     %ebx,%eax
0x000f00d9:  mov    $0xcf8,%edx
0x000f00de:  out    %eax,(%dx)
0x000f00df:  and    $0x3,%esi
0x000f00e2:  lea    0xcfc(%esi),%edx
0x000f00e8:  mov    %cl,%al
0x000f00ea:  out    %al,(%dx)
0x000f00eb:  pop    %ebx
0x000f00ec:  pop    %esi
0x000f00ed:  ret    

----------------
IN: 
0x07fb3536:  inc    %ebx
0x07fb3537:  cmp    $0x64,%ebx
0x07fb353a:  jne    0x7fb350c

----------------
IN: 
0x07fb350c:  movzbl 0x7fbfaec(%ebx),%edi
0x07fb3513:  mov    %edi,%eax
0x07fb3515:  sar    $0x3,%eax
0x07fb3518:  mov    %edi,%ecx
0x07fb351a:  and    $0x7,%ecx
0x07fb351d:  mov    $0x1,%ebp
0x07fb3522:  mov    %ebp,%edx
0x07fb3524:  shl    %cl,%edx
0x07fb3526:  or     %dl,0x2(%esp,%eax,1)
0x07fb352a:  movzwl (%esi),%eax
0x07fb352d:  mov    %edi,%ecx
0x07fb352f:  mov    %ebx,%edx
0x07fb3531:  call   0xf00bf

----------------
IN: 
0x07fb353c:  mov    $0x4d0,%edx
0x07fb3541:  mov    0x2(%esp),%al
0x07fb3545:  out    %al,(%dx)
0x07fb3546:  movzbl 0x3(%esp),%eax
0x07fb354b:  mov    $0xd1,%dl
0x07fb354d:  out    %al,(%dx)
0x07fb354e:  push   %eax
0x07fb354f:  movzbl 0x6(%esp),%eax
0x07fb3554:  push   %eax
0x07fb3555:  push   $0xf41a2
0x07fb355a:  call   0xf0cc9

----------------
IN: 
0x07fb355f:  add    $0x10,%esp
0x07fb3562:  pop    %ebx
0x07fb3563:  pop    %esi
0x07fb3564:  pop    %edi
0x07fb3565:  pop    %ebp
0x07fb3566:  ret    

----------------
IN: 
0x07fafedf:  push   %ebx
0x07fafee0:  movzwl (%eax),%ebx
0x07fafee3:  mov    $0x8000,%ecx
0x07fafee8:  mov    $0x40,%edx
0x07fafeed:  mov    %ebx,%eax
0x07fafeef:  call   0x7faf529

----------------
IN: 
0x07fafef4:  mov    $0x8000,%ecx
0x07fafef9:  mov    $0x42,%edx
0x07fafefe:  mov    %ebx,%eax
0x07faff00:  pop    %ebx
0x07faff01:  jmp    0x7faf529

----------------
IN: 
0x07fb8217:  mov    %ebx,%eax
0x07fb8219:  call   *0x7fbfde8

----------------
IN: 
0x07fafe74:  push   %ebx
0x07fafe75:  xor    %ecx,%ecx
0x07fafe77:  mov    0xc(%eax),%ebx
0x07fafe7a:  mov    (%eax),%eax
0x07fafe7c:  shr    $0x3,%ax
0x07fafe80:  and    $0x1f,%eax
0x07fafe83:  test   %ebx,%ebx
0x07fafe85:  je     0x7fafe8d

----------------
IN: 
0x07fafe8d:  lea    -0x1(%ecx,%eax,1),%eax
0x07fafe91:  lea    -0x1(%edx,%eax,1),%eax
0x07fafe95:  and    $0x3,%eax
0x07fafe98:  movzbl 0x7fbfb4c(%eax),%eax
0x07fafe9f:  pop    %ebx
0x07fafea0:  ret    

----------------
IN: 
0x07fb821f:  movzbl %al,%ecx
0x07fb8222:  mov    $0x3c,%edx
0x07fb8227:  mov    %esi,%eax
0x07fb8229:  call   0xf00bf

----------------
IN: 
0x07fb24a9:  movzwl (%eax),%eax
0x07fb24ac:  mov    %eax,0xf5ce0
0x07fb24b1:  call   0xf037a

----------------
IN: 
0x000f037a:  push   %esi
0x000f037b:  push   %ebx
0x000f037c:  movzwl %ax,%esi
0x000f037f:  mov    $0x9,%ecx
0x000f0384:  mov    $0x3c,%edx
0x000f0389:  mov    %esi,%eax
0x000f038b:  call   0xf00bf

----------------
IN: 
0x000f0390:  mov    0xf5ce8,%bx
0x000f0397:  mov    %ebx,%ecx
0x000f0399:  or     $0x1,%ecx
0x000f039c:  movzwl %cx,%ecx
0x000f039f:  mov    $0x40,%edx
0x000f03a4:  mov    %esi,%eax
0x000f03a6:  call   0xf009b

----------------
IN: 
0x000f03ab:  mov    $0x1,%ecx
0x000f03b0:  mov    $0x80,%edx
0x000f03b5:  mov    %esi,%eax
0x000f03b7:  call   0xf00bf

----------------
IN: 
0x000f03bc:  movzwl %bx,%ecx
0x000f03bf:  add    $0x100,%ecx
0x000f03c5:  or     $0x1,%ecx
0x000f03c8:  mov    $0x90,%edx
0x000f03cd:  mov    %esi,%eax
0x000f03cf:  call   0xf009b

----------------
IN: 
0x000f03d4:  mov    $0x9,%ecx
0x000f03d9:  mov    $0xd2,%edx
0x000f03de:  mov    %esi,%eax
0x000f03e0:  pop    %ebx
0x000f03e1:  pop    %esi
0x000f03e2:  jmp    0xf00bf

----------------
IN: 
0x07fb24b6:  movzwl 0xf5ce8,%edx
0x07fb24bd:  mov    %edx,%eax
0x07fb24bf:  add    $0x4,%edx
0x07fb24c2:  mov    %edx,0xf67a4
0x07fb24c8:  add    $0x8,%eax
0x07fb24cb:  movzwl %ax,%eax
0x07fb24ce:  jmp    0x7fb2483

----------------
IN: 
0x07fb2483:  push   %ebx
0x07fb2484:  mov    %eax,%ebx
0x07fb2486:  movzwl %ax,%eax
0x07fb2489:  push   %eax
0x07fb248a:  push   $0xf3c52
0x07fb248f:  call   0xf0cc9

----------------
IN: 
0x07fb2494:  mov    %bx,0xf6ac0
0x07fb249b:  movl   $0xdfc,0xf6ac4
0x07fb24a5:  pop    %eax
0x07fb24a6:  pop    %edx
0x07fb24a7:  pop    %ebx
0x07fb24a8:  ret    

----------------
IN: 
0x07fb61f0:  mov    (%esp),%eax
0x07fb61f3:  call   0x7faf92b

----------------
IN: 
0x07fb61f8:  mov    0x7fbfed4,%eax
0x07fb61fd:  lea    -0x4(%eax),%ebx
0x07fb6200:  cmp    $0xfffffffc,%ebx
0x07fb6203:  jne    0x7fb8258

----------------
IN: 
0x07fb8258:  mov    %ebx,%eax
0x07fb825a:  call   0x7fb02d2

----------------
IN: 
0x07fb02d2:  push   %ebx
0x07fb02d3:  mov    %eax,%ebx
0x07fb02d5:  cmpw   $0x300,0x14(%eax)
0x07fb02db:  je     0x7fb02e1

----------------
IN: 
0x07fb02dd:  xor    %eax,%eax
0x07fb02df:  jmp    0x7fb0316

----------------
IN: 
0x07fb0316:  pop    %ebx
0x07fb0317:  ret    

----------------
IN: 
0x07fb825f:  test   %eax,%eax
0x07fb8261:  je     0x7fb828b

----------------
IN: 
0x07fb828b:  mov    0x4(%ebx),%ebx
0x07fb828e:  sub    $0x4,%ebx
0x07fb8291:  jmp    0x7fb6200

----------------
IN: 
0x07fb6200:  cmp    $0xfffffffc,%ebx
0x07fb6203:  jne    0x7fb8258

----------------
IN: 
0x07fb02e1:  movzwl (%eax),%eax
0x07fb02e4:  mov    $0x4,%edx
0x07fb02e9:  call   0xf010e

----------------
IN: 
0x07fb02ee:  and    $0x3,%eax
0x07fb02f1:  cmp    $0x3,%ax
0x07fb02f5:  jne    0x7fb02dd

----------------
IN: 
0x07fb02f7:  mov    0xc(%ebx),%ebx
0x07fb02fa:  test   %ebx,%ebx
0x07fb02fc:  je     0x7fb0311

----------------
IN: 
0x07fb0311:  mov    $0x1,%eax
0x07fb0316:  pop    %ebx
0x07fb0317:  ret    

----------------
IN: 
0x07fb8263:  mov    (%ebx),%eax
0x07fb8265:  mov    %eax,%edx
0x07fb8267:  and    $0x7,%edx
0x07fb826a:  push   %edx
0x07fb826b:  mov    %eax,%edx
0x07fb826d:  shr    $0x3,%dx
0x07fb8271:  and    $0x1f,%edx
0x07fb8274:  push   %edx
0x07fb8275:  movzbl %ah,%eax
0x07fb8278:  push   %eax
0x07fb8279:  push   $0xf4aa4
0x07fb827e:  call   0xf0cc9

----------------
IN: 
0x07fb8283:  add    $0x10,%esp
0x07fb8286:  jmp    0x7fb626a

----------------
IN: 
0x07fb626a:  mov    $0x7113,%edx
0x07fb626f:  mov    $0x8086,%eax
0x07fb6274:  call   0x7faf559

----------------
IN: 
0x07faf559:  mov    0x7fbfed4,%ecx
0x07faf55f:  sub    $0x4,%ecx
0x07faf562:  cmp    $0xfffffffc,%ecx
0x07faf565:  je     0x7faf578

----------------
IN: 
0x07faf567:  cmp    %ax,0x10(%ecx)
0x07faf56b:  jne    0x7faf573

----------------
IN: 
0x07faf56d:  cmp    %dx,0x12(%ecx)
0x07faf571:  je     0x7faf57b

----------------
IN: 
0x07faf573:  mov    0x4(%ecx),%ecx
0x07faf576:  jmp    0x7faf55f

----------------
IN: 
0x07faf55f:  sub    $0x4,%ecx
0x07faf562:  cmp    $0xfffffffc,%ecx
0x07faf565:  je     0x7faf578

----------------
IN: 
0x07faf57b:  mov    %ecx,%eax
0x07faf57d:  ret    

----------------
IN: 
0x07fb6279:  mov    %eax,%ebx
0x07fb627b:  mov    $0x1237,%edx
0x07fb6280:  mov    $0x8086,%eax
0x07fb6285:  call   0x7faf559

----------------
IN: 
0x07fb628a:  mov    %eax,%edx
0x07fb628c:  test   %eax,%eax
0x07fb628e:  je     0x7fb6294

----------------
IN: 
0x07fb6290:  test   %ebx,%ebx
0x07fb6292:  jne    0x7fb62be

----------------
IN: 
0x07fb62be:  movzwl (%ebx),%eax
0x07fb62c1:  mov    %eax,0xf5cdc
0x07fb62c6:  movzwl (%edx),%eax
0x07fb62c9:  mov    %eax,0xf5cd8
0x07fb62ce:  call   0xf0572

----------------
IN: 
0x000f0572:  push   %ebp
0x000f0573:  push   %edi
0x000f0574:  push   %esi
0x000f0575:  push   %ebx
0x000f0576:  mov    0xf5cdc,%esi
0x000f057c:  test   %esi,%esi
0x000f057e:  js     0xf0675

----------------
IN: 
0x000f0584:  movzwl %si,%esi
0x000f0587:  mov    $0x2,%edx
0x000f058c:  mov    %esi,%eax
0x000f058e:  call   0xf010e

----------------
IN: 
0x000f0593:  cmp    $0x7113,%ax
0x000f0597:  mov    0xf5cd8,%ebx
0x000f059d:  jne    0xf060a

----------------
IN: 
0x000f059f:  mov    $0x58,%edx
0x000f05a4:  mov    %esi,%eax
0x000f05a6:  call   0xf00ee

----------------
IN: 
0x000f05ab:  mov    %eax,%edi
0x000f05ad:  test   $0x2000000,%eax
0x000f05b2:  jne    0xf0675

----------------
IN: 
0x000f05b8:  movzwl %bx,%ebx
0x000f05bb:  mov    $0x4a,%ecx
0x000f05c0:  mov    $0x72,%edx
0x000f05c5:  mov    %ebx,%eax
0x000f05c7:  call   0xf00bf

----------------
IN: 
0x000f05cc:  call   0xf0438

----------------
IN: 
0x000f0438:  push   %edi
0x000f0439:  push   %esi
0x000f043a:  mov    $0xafe00,%eax
0x000f043f:  mov    $0x3fe00,%esi
0x000f0444:  mov    $0x80,%ecx
0x000f0449:  mov    %eax,%edi
0x000f044b:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000f044b:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000f044d:  mov    0x38000,%eax
0x000f0452:  mov    %eax,0xa8000
0x000f0457:  mov    0x38004,%eax
0x000f045c:  mov    %eax,0xa8004
0x000f0461:  mov    $0xd29c,%eax
0x000f0466:  xor    %edx,%edx
0x000f0468:  shld   $0x18,%eax,%edx
0x000f046c:  shl    $0x18,%eax
0x000f046f:  or     $0xeac88c,%eax
0x000f0474:  mov    %eax,0x38000
0x000f0479:  mov    %edx,%eax
0x000f047b:  or     $0xf00000,%eax
0x000f0480:  mov    %eax,0x38004
0x000f0485:  pop    %esi
0x000f0486:  pop    %edi
0x000f0487:  ret    

----------------
IN: 
0x000f05d1:  or     $0x2000000,%edi
0x000f05d7:  mov    %edi,%ecx
0x000f05d9:  mov    $0x58,%edx
0x000f05de:  mov    %esi,%eax
0x000f05e0:  call   0xf009b

----------------
IN: 
0x000f05e5:  movzwl 0xf5ce8,%ecx
0x000f05ec:  lea    0x28(%ecx),%edx
0x000f05ef:  in     (%dx),%eax
0x000f05f0:  mov    %eax,%edx
0x000f05f2:  lea    0x28(%ecx),%eax
0x000f05f5:  or     $0x1,%edx
0x000f05f8:  out    %eax,(%dx)
0x000f05f9:  call   0xf0488

----------------
IN: 
0x000f0488:  mov    $0x1,%al
0x000f048a:  out    %al,$0xb3
0x000f048c:  xor    %eax,%eax
0x000f048e:  out    %al,$0xb2
0x000f0490:  in     $0xb3,%al
0x000f0492:  test   %al,%al
0x000f0494:  jne    0xf0490

----------------
IN: 
0x00038000:  mov    %cs,%ax
0x00038002:  ljmp   $0xf000,$0xd29c

----------------
IN: 
0x000fd29c:  mov    $0xfd2a5,%edx
0x000fd2a2:  jmp    0xfd160

----------------
IN: 
0x000fd160:  mov    %eax,%ecx
0x000fd163:  jmp    0xfd17a

----------------
IN: 
0x000fd17a:  lidtw  %cs:0x6c38
0x000fd180:  lgdtw  %cs:0x6bf4
0x000fd186:  mov    %cr0,%eax
0x000fd189:  or     $0x1,%eax
0x000fd18d:  mov    %eax,%cr0

----------------
IN: 
0x000fd190:  ljmpl  $0x8,$0xfd198

----------------
IN: 
0x000fd198:  mov    $0x10,%eax
0x000fd19d:  mov    %eax,%ds

----------------
IN: 
0x000fd19f:  mov    %eax,%es

----------------
IN: 
0x000fd1a1:  mov    %eax,%ss

----------------
IN: 
0x000fd1a3:  mov    %eax,%fs

----------------
IN: 
0x000fd1a5:  mov    %eax,%gs
0x000fd1a7:  mov    %ecx,%eax
0x000fd1a9:  jmp    *%edx

----------------
IN: 
0x000fd2a5:  mov    $0xa8000,%esp
0x000fd2aa:  call   0xf3904

----------------
IN: 
0x000f3904:  push   %edi
0x000f3905:  lea    0x8(%esp),%edi
0x000f3909:  and    $0xfffffff8,%esp
0x000f390c:  pushl  -0x4(%edi)
0x000f390f:  push   %ebp
0x000f3910:  mov    %esp,%ebp
0x000f3912:  push   %edi
0x000f3913:  push   %esi
0x000f3914:  push   %ebx
0x000f3915:  sub    $0x4c,%esp
0x000f3918:  mov    %eax,%edx
0x000f391a:  in     $0xb2,%al
0x000f391c:  movzwl %dx,%edx
0x000f391f:  shl    $0x4,%edx
0x000f3922:  cmp    $0x30000,%edx
0x000f3928:  jne    0xf39a1

----------------
IN: 
0x000f392a:  mov    0x3fefc,%eax
0x000f392f:  and    $0x2ffff,%eax
0x000f3934:  cmp    $0x20000,%eax
0x000f3939:  jne    0xf3947

----------------
IN: 
0x000f393b:  movl   $0xa0000,0x3fef8
0x000f3945:  jmp    0xf3973

----------------
IN: 
0x000f3973:  xor    %eax,%eax
0x000f3975:  out    %al,$0xb3
0x000f3977:  mov    $0x3fe00,%eax
0x000f397c:  mov    $0xa0000,%ebx
0x000f3981:  mov    $0x80,%ecx
0x000f3986:  mov    %ebx,%edi
0x000f3988:  mov    %eax,%esi
0x000f398a:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000f398a:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000f398c:  mov    $0x80,%cl
0x000f398e:  mov    %eax,%esi
0x000f3990:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000f3990:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000f3992:  movl   $0x1,0xf6bf0
0x000f399c:  jmp    0xf3ab8

----------------
IN: 
0x000f3ab8:  lea    -0xc(%ebp),%esp
0x000f3abb:  pop    %ebx
0x000f3abc:  pop    %esi
0x000f3abd:  pop    %edi
0x000f3abe:  pop    %ebp
0x000f3abf:  lea    -0x8(%edi),%esp
0x000f3ac2:  pop    %edi
0x000f3ac3:  ret    

----------------
IN: 
0x000fd2af:  rsm    

----------------
IN: 
0x000f0490:  in     $0xb3,%al
0x000f0492:  test   %al,%al
0x000f0494:  jne    0xf0490

----------------
IN: 
0x000f0496:  push   %edi
0x000f0497:  push   %esi
0x000f0498:  mov    $0x3fe00,%eax
0x000f049d:  mov    $0xafe00,%esi
0x000f04a2:  mov    $0x80,%ecx
0x000f04a7:  mov    %eax,%edi
0x000f04a9:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000f04a9:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000f04ab:  mov    0xa8000,%eax
0x000f04b0:  mov    %eax,0x38000
0x000f04b5:  mov    0xa8004,%eax
0x000f04ba:  mov    %eax,0x38004
0x000f04bf:  mov    $0xd29c,%eax
0x000f04c4:  xor    %edx,%edx
0x000f04c6:  shld   $0x18,%eax,%edx
0x000f04ca:  shl    $0x18,%eax
0x000f04cd:  or     $0xeac88c,%eax
0x000f04d2:  mov    %eax,0xa8000
0x000f04d7:  mov    %edx,%eax
0x000f04d9:  or     $0xf00000,%eax
0x000f04de:  mov    %eax,0xa8004
0x000f04e3:  wbinvd 
0x000f04e5:  pop    %esi
0x000f04e6:  pop    %edi
0x000f04e7:  ret    

----------------
IN: 
0x000f05fe:  mov    $0xa,%ecx
0x000f0603:  mov    $0x72,%edx
0x000f0608:  jmp    0xf066a

----------------
IN: 
0x000f066a:  mov    %ebx,%eax
0x000f066c:  pop    %ebx
0x000f066d:  pop    %esi
0x000f066e:  pop    %edi
0x000f066f:  pop    %ebp
0x000f0670:  jmp    0xf00bf

----------------
IN: 
0x07fb62d3:  lea    0x5c(%esp),%eax
0x07fb62d7:  push   %eax
0x07fb62d8:  lea    0x58(%esp),%eax
0x07fb62dc:  push   %eax
0x07fb62dd:  lea    0x58(%esp),%ecx
0x07fb62e1:  lea    0x54(%esp),%edx
0x07fb62e5:  mov    $0x1,%eax
0x07fb62ea:  call   0xf01be

----------------
IN: 
0x07fb62ef:  mov    0x64(%esp),%eax
0x07fb62f3:  and    $0x1020,%eax
0x07fb62f8:  pop    %edx
0x07fb62f9:  pop    %ecx
0x07fb62fa:  cmp    $0x1020,%eax
0x07fb62ff:  jne    0x7fb64f0

----------------
IN: 
0x07fb64f0:  lea    0x68(%esp),%eax
0x07fb64f4:  push   %eax
0x07fb64f5:  lea    0x60(%esp),%ebx
0x07fb64f9:  push   %ebx
0x07fb64fa:  lea    0x60(%esp),%ecx
0x07fb64fe:  lea    0x5c(%esp),%edx
0x07fb6502:  mov    $0x1,%eax
0x07fb6507:  call   0xf01be

----------------
IN: 
0x07fb650c:  pop    %ebp
0x07fb650d:  pop    %eax
0x07fb650e:  cmpl   $0x0,0x54(%esp)
0x07fb6513:  je     0x7fb651c

----------------
IN: 
0x07fb6515:  testb  $0x2,0x69(%esp)
0x07fb651a:  jne    0x7fb6540

----------------
IN: 
0x07fb6540:  movzbl 0x5b(%esp),%ecx
0x07fb6545:  mov    %ecx,%edx
0x07fb6547:  shr    $0x5,%edx
0x07fb654a:  mov    $0x1,%eax
0x07fb654f:  shl    %cl,%eax
0x07fb6551:  or     %eax,0xf5d14(,%edx,4)
0x07fb6558:  movl   $0x1,0xf5d34
0x07fb6562:  mov    0x10000,%esi
0x07fb6568:  mov    0x10004,%edi
0x07fb656e:  mov    $0xd2b1,%eax
0x07fb6573:  shl    $0x8,%eax
0x07fb6576:  or     $0xea,%al
0x07fb6578:  mov    %eax,0x10000
0x07fb657d:  movl   $0xf0,0x10004
0x07fb6587:  mov    0xfee000f0,%eax
0x07fb658c:  or     $0x1,%ah
0x07fb658f:  mov    %eax,0xfee000f0
0x07fb6594:  movl   $0x8700,0xfee00350
0x07fb659e:  movl   $0x8400,0xfee00360
0x07fb65a8:  movl   $0x1,0x7fbff04
0x07fb65b2:  movl   $0xc4500,0xfee00300
0x07fb65bc:  movl   $0xc4610,0xfee00300
0x07fb65c6:  mov    $0xdf,%al
0x07fb65c8:  out    %al,$0x70
0x07fb65ca:  in     $0x71,%al
0x07fb65cc:  inc    %eax
0x07fb65cd:  movzbl %al,%eax
0x07fb65d0:  cmp    0xf5d34,%eax
0x07fb65d6:  je     0x7fb65f7

----------------
IN: 
0x07fb65f7:  call   0xf0b7e

----------------
IN: 
0x000f0b7e:  mov    %esp,%eax
0x000f0b80:  cmp    $0x100000,%eax
0x000f0b85:  jbe    0xf0b93

----------------
IN: 
0x000f0b93:  mov    $0xf9a29,%ecx
0x000f0b98:  xor    %edx,%edx
0x000f0b9a:  xor    %eax,%eax
0x000f0b9c:  call   0xf0ae6

----------------
IN: 
0x000f0ae6:  push   %ebp
0x000f0ae7:  push   %edi
0x000f0ae8:  push   %esi
0x000f0ae9:  push   %ebx
0x000f0aea:  mov    %edx,%ebx
0x000f0aec:  mov    0xefee4,%dl
0x000f0af2:  cmp    $0x2,%dl
0x000f0af5:  jne    0xf0b25

----------------
IN: 
0x000f0b25:  dec    %dl
0x000f0b27:  jne    0xf0b5a

----------------
IN: 
0x000f0b5a:  mov    %ebx,%edx
0x000f0b5c:  cmpl   $0x1,0xf6c48
0x000f0b63:  jne    0xf0b6e

----------------
IN: 
0x000f0b65:  pop    %ebx
0x000f0b66:  pop    %esi
0x000f0b67:  pop    %edi
0x000f0b68:  pop    %ebp
0x000f0b69:  jmp    0xf0a90

----------------
IN: 
0x000f0a90:  push   %esi
0x000f0a91:  push   %ebx
0x000f0a92:  mov    %edx,%esi
0x000f0a94:  mov    %esp,%edx
0x000f0a96:  cmp    $0x7000,%edx
0x000f0a9c:  jbe    0xf0aa8

----------------
IN: 
0x000f0aa8:  lea    -0xf0000(%ecx),%ebx
0x000f0aae:  mov    $0x6c50,%edx
0x000f0ab3:  jmp    0xfd1c2

----------------
IN: 
0x000fd1c2:  mov    %eax,%ecx
0x000fd1c4:  mov    $0x30,%eax
0x000fd1c9:  mov    %eax,%ds

----------------
IN: 
0x000fd1cb:  mov    %eax,%es

----------------
IN: 
0x000fd1cd:  mov    %eax,%ss

----------------
IN: 
0x000fd1cf:  mov    %eax,%fs

----------------
IN: 
0x000fd1d1:  mov    %eax,%gs
0x000fd1d3:  ljmpw  $0x28,$0xd1d9

----------------
IN: 
0x000fd1d9:  mov    %cr0,%eax
0x000fd1dc:  and    $0xfffffffe,%eax
0x000fd1e0:  mov    %eax,%cr0

----------------
IN: 
0x000fd1e3:  ljmp   $0xf000,$0xd1e8

----------------
IN: 
0x000fd1e8:  lidtw  %cs:0x6c40
0x000fd1ee:  xor    %ax,%ax
0x000fd1f0:  mov    %ax,%fs
0x000fd1f2:  mov    %ax,%gs
0x000fd1f4:  mov    %ax,%es
0x000fd1f6:  mov    %ax,%ds
0x000fd1f8:  mov    %ax,%ss

----------------
IN: 
0x000fd1fa:  mov    %ecx,%eax

----------------
IN: 
0x000fd1fd:  jmpl   *%edx

----------------
IN: 
0x000f6c50:  mov    %esi,%edx
0x000f6c53:  calll  *%ebx

----------------
IN: 
0x000f9a29:  calll  0xf76c1

----------------
IN: 
0x000f76c1:  mov    %ss,%dx
0x000f76c3:  movzwl %dx,%edx
0x000f76c7:  xor    %eax,%eax
0x000f76ca:  cmp    $0xe000,%edx
0x000f76d1:  jne    0xf76e3

----------------
IN: 
0x000f76e3:  retl   

----------------
IN: 
0x000f9a2f:  test   %eax,%eax
0x000f9a32:  je     0xf9a43

----------------
IN: 
0x000f9a43:  sti    

----------------
IN: 
0x000f9a44:  nop    

----------------
IN: 
0x000f9a45:  pause  

----------------
IN: 
0x000f9a47:  cli    
0x000f9a48:  cld    
0x000f9a49:  retl   

----------------
IN: 
0x000f6c56:  mov    $0xf0ab8,%edx
0x000f6c5c:  jmp    0xfd165

----------------
IN: 
0x000fd165:  mov    %eax,%ecx
0x000fd168:  cli    
0x000fd169:  cld    
0x000fd16a:  mov    $0x8f,%eax
0x000fd170:  out    %al,$0x70
0x000fd172:  in     $0x71,%al
0x000fd174:  in     $0x92,%al
0x000fd176:  or     $0x2,%al
0x000fd178:  out    %al,$0x92
0x000fd17a:  lidtw  %cs:0x6c38
0x000fd180:  lgdtw  %cs:0x6bf4
0x000fd186:  mov    %cr0,%eax
0x000fd189:  or     $0x1,%eax
0x000fd18d:  mov    %eax,%cr0

----------------
IN: 
0x000fd190:  ljmpl  $0x8,$0xfd198

----------------
IN: 
0x000fd198:  mov    $0x10,%eax
0x000fd19d:  mov    %eax,%ds

----------------
IN: 
0x000fd19f:  mov    %eax,%es

----------------
IN: 
0x000fd1a1:  mov    %eax,%ss

----------------
IN: 
0x000fd1a3:  mov    %eax,%fs

----------------
IN: 
0x000fd1a5:  mov    %eax,%gs
0x000fd1a7:  mov    %ecx,%eax
0x000fd1a9:  jmp    *%edx

----------------
IN: 
0x000f0ab8:  pop    %ebx
0x000f0ab9:  pop    %esi
0x000f0aba:  ret    

----------------
IN: 
0x000f0ba1:  mov    $0xf6be4,%eax
0x000f0ba6:  jmp    0xeff18

----------------
IN: 
0x000eff18:  mov    0x4(%eax),%edx
0x000eff1b:  lea    -0x4(%edx),%ecx
0x000eff1e:  cmp    %ecx,%eax
0x000eff20:  je     0xeff34

----------------
IN: 
0x000eff34:  ret    

----------------
IN: 
0x07fb65fc:  mov    %esi,0x10000
0x07fb6602:  mov    %edi,0x10004
0x07fb6608:  xor    %edx,%edx
0x07fb660a:  xor    %ecx,%ecx
0x07fb660c:  mov    $0xf4b6d,%eax
0x07fb6611:  call   0x7fb0bfd

----------------
IN: 
0x07fb6616:  mov    %eax,0x7fbff08
0x07fb661b:  test   %eax,%eax
0x07fb661d:  je     0x7fb6627

----------------
IN: 
0x07fb661f:  cmp    0xf5d34,%eax
0x07fb6625:  jae    0x7fb6631

----------------
IN: 
0x07fb6631:  pushl  0x7fbff08
0x07fb6637:  pushl  0xf5d34
0x07fb663d:  push   $0xf4b7a
0x07fb6642:  call   0xf0cc9

----------------
IN: 
0x07fb6647:  add    $0xc,%esp
0x07fb664a:  movl   $0x52495024,0x7fbfc98
0x07fb6654:  mov    $0x80,%edx
0x07fb6659:  mov    $0x7fbfc98,%eax
0x07fb665e:  call   0xf069f

----------------
IN: 
0x07fb6663:  sub    %al,0x7fbfcb7
0x07fb6669:  mov    $0x7fbfc98,%eax
0x07fb666e:  call   0x7fb4392

----------------
IN: 
0x07fb4392:  cmpl   $0x52495024,(%eax)
0x07fb4398:  jne    0x7fb43fc

----------------
IN: 
0x07fb439a:  cmpl   $0x0,0xf67a8
0x07fb43a1:  jne    0x7fb43fc

----------------
IN: 
0x07fb43a3:  push   %edi
0x07fb43a4:  push   %esi
0x07fb43a5:  push   %ebx
0x07fb43a6:  movzwl 0x6(%eax),%ebx
0x07fb43aa:  cmp    $0x1f,%bx
0x07fb43ae:  jbe    0x7fb43f9

----------------
IN: 
0x07fb43b0:  mov    %eax,%esi
0x07fb43b2:  mov    %ebx,%edx
0x07fb43b4:  call   0xf069f

----------------
IN: 
0x07fb43b9:  test   %al,%al
0x07fb43bb:  jne    0x7fb43f9

----------------
IN: 
0x07fb43bd:  mov    %ebx,%eax
0x07fb43bf:  call   0x7faf8f1

----------------
IN: 
0x07faf8f1:  mov    $0x10,%ecx
0x07faf8f6:  mov    %eax,%edx
0x07faf8f8:  mov    $0x7fbfea4,%eax
0x07faf8fd:  jmp    0x7faf858

----------------
IN: 
0x07fb43c4:  mov    %eax,%ebx
0x07fb43c6:  test   %eax,%eax
0x07fb43c8:  jne    0x7fb43dc

----------------
IN: 
0x07fb43dc:  push   %eax
0x07fb43dd:  push   %esi
0x07fb43de:  push   $0xf442c
0x07fb43e3:  call   0xf0cc9

----------------
IN: 
0x07fb43e8:  movzwl 0x6(%esi),%ecx
0x07fb43ec:  mov    %ebx,%edi
0x07fb43ee:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb43ee:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb43f0:  mov    %ebx,0xf67a8
0x07fb43f6:  add    $0xc,%esp
0x07fb43f9:  pop    %ebx
0x07fb43fa:  pop    %esi
0x07fb43fb:  pop    %edi
0x07fb43fc:  ret    

----------------
IN: 
0x07fb6673:  mov    $0x8000,%eax
0x07fb6678:  call   0x7fb09cc

----------------
IN: 
0x07fb667d:  mov    %eax,%ebp
0x07fb667f:  test   %eax,%eax
0x07fb6681:  jne    0x7fb6697

----------------
IN: 
0x07fb6697:  mov    $0x2c,%ecx
0x07fb669c:  xor    %edx,%edx
0x07fb669e:  call   0xf0090

----------------
IN: 
0x07fb66a3:  movl   $0x504d4350,0x0(%ebp)
0x07fb66aa:  movb   $0x4,0x6(%ebp)
0x07fb66ae:  movl   $0x48434f42,0x8(%ebp)
0x07fb66b5:  movl   $0x55504353,0xc(%ebp)
0x07fb66bc:  lea    0x10(%ebp),%eax
0x07fb66bf:  mov    $0xf4ba3,%esi
0x07fb66c4:  mov    $0x3,%ecx
0x07fb66c9:  mov    %eax,%edi
0x07fb66cb:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb66cb:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb66cd:  movl   $0xfee00000,0x24(%ebp)
0x07fb66d4:  push   %ebx
0x07fb66d5:  lea    0x5c(%esp),%eax
0x07fb66d9:  push   %eax
0x07fb66da:  lea    0x5c(%esp),%ecx
0x07fb66de:  lea    0x58(%esp),%edx
0x07fb66e2:  mov    $0x1,%eax
0x07fb66e7:  call   0xf01be

----------------
IN: 
0x07fb66ec:  pop    %ebx
0x07fb66ed:  pop    %esi
0x07fb66ee:  cmpl   $0x0,0x50(%esp)
0x07fb66f3:  jne    0x7fb6705

----------------
IN: 
0x07fb6705:  mov    $0x1,%edi
0x07fb670a:  testb  $0x10,0x5f(%esp)
0x07fb670f:  je     0x7fb671d

----------------
IN: 
0x07fb671d:  mov    0xfee00030,%eax
0x07fb6722:  mov    %al,0x8(%esp)
0x07fb6726:  lea    0x2c(%ebp),%eax
0x07fb6729:  mov    %eax,(%esp)
0x07fb672c:  mov    %eax,%ebx
0x07fb672e:  xor    %esi,%esi
0x07fb6730:  cmp    0x7fbff08,%esi
0x07fb6736:  jae    0x7fb6786

----------------
IN: 
0x07fb6738:  mov    $0x14,%ecx
0x07fb673d:  xor    %edx,%edx
0x07fb673f:  mov    %ebx,%eax
0x07fb6741:  call   0xf0090

----------------
IN: 
0x07fb6746:  movb   $0x0,(%ebx)
0x07fb6749:  mov    %esi,%eax
0x07fb674b:  mov    %al,0x1(%ebx)
0x07fb674e:  mov    0x8(%esp),%al
0x07fb6752:  mov    %al,0x2(%ebx)
0x07fb6755:  mov    %esi,%eax
0x07fb6757:  movzbl %al,%eax
0x07fb675a:  call   0x7fb00cc

----------------
IN: 
0x07fb00cc:  mov    %al,%dl
0x07fb00ce:  shr    $0x5,%dl
0x07fb00d1:  movzbl %dl,%edx
0x07fb00d4:  mov    %al,%cl
0x07fb00d6:  and    $0x1f,%ecx
0x07fb00d9:  mov    0xf5d14(,%edx,4),%edx
0x07fb00e0:  mov    %edx,%eax
0x07fb00e2:  shr    %cl,%eax
0x07fb00e4:  and    $0x1,%eax
0x07fb00e7:  ret    

----------------
IN: 
0x07fb675f:  test   %eax,%eax
0x07fb6761:  setne  %al
0x07fb6764:  cmp    $0x1,%esi
0x07fb6767:  sbb    %edx,%edx
0x07fb6769:  and    $0x2,%edx
0x07fb676c:  or     %edx,%eax
0x07fb676e:  mov    %al,0x3(%ebx)
0x07fb6771:  mov    0x50(%esp),%eax
0x07fb6775:  mov    %eax,0x4(%ebx)
0x07fb6778:  mov    0x5c(%esp),%eax
0x07fb677c:  mov    %eax,0x8(%ebx)
0x07fb677f:  add    $0x14,%ebx
0x07fb6782:  add    %edi,%esi
0x07fb6784:  jmp    0x7fb6730

----------------
IN: 
0x07fb6730:  cmp    0x7fbff08,%esi
0x07fb6736:  jae    0x7fb6786

----------------
IN: 
0x07fb6786:  mov    %ebx,%esi
0x07fb6788:  mov    %ebx,%edi
0x07fb678a:  sub    (%esp),%edi
0x07fb678d:  sar    $0x2,%edi
0x07fb6790:  imul   $0xcccccccd,%edi,%edi
0x07fb6796:  cmpl   $0x0,0x7fbfed4
0x07fb679d:  je     0x7fb67c5

----------------
IN: 
0x07fb679f:  mov    $0x8,%ecx
0x07fb67a4:  xor    %edx,%edx
0x07fb67a6:  mov    %ebx,%eax
0x07fb67a8:  call   0xf0090

----------------
IN: 
0x07fb67ad:  movb   $0x1,(%ebx)
0x07fb67b0:  movb   $0x0,0x1(%ebx)
0x07fb67b4:  movl   $0x20494350,0x2(%ebx)
0x07fb67bb:  movw   $0x2020,0x6(%ebx)
0x07fb67c1:  add    $0x8,%ebx
0x07fb67c4:  inc    %edi
0x07fb67c5:  mov    $0x8,%ecx
0x07fb67ca:  xor    %edx,%edx
0x07fb67cc:  mov    %ebx,%eax
0x07fb67ce:  call   0xf0090

----------------
IN: 
0x07fb67d3:  movb   $0x1,(%ebx)
0x07fb67d6:  mov    %ebx,%eax
0x07fb67d8:  sub    %esi,%eax
0x07fb67da:  sar    $0x3,%eax
0x07fb67dd:  mov    %eax,0x10(%esp)
0x07fb67e1:  mov    0x10(%esp),%al
0x07fb67e5:  mov    %al,0x28(%esp)
0x07fb67e9:  mov    %al,0x1(%ebx)
0x07fb67ec:  movl   $0x20415349,0x2(%ebx)
0x07fb67f3:  movw   $0x2020,0x6(%ebx)
0x07fb67f9:  lea    0x8(%ebx),%eax
0x07fb67fc:  mov    $0x8,%ecx
0x07fb6801:  xor    %edx,%edx
0x07fb6803:  call   0xf0090

----------------
IN: 
0x07fb6808:  movb   $0x2,0x8(%ebx)
0x07fb680c:  movb   $0x0,0x9(%ebx)
0x07fb6810:  movb   $0x11,0xa(%ebx)
0x07fb6814:  movb   $0x1,0xb(%ebx)
0x07fb6818:  movl   $0xfec00000,0xc(%ebx)
0x07fb681f:  lea    0x2(%edi),%eax
0x07fb6822:  mov    %eax,0x2c(%esp)
0x07fb6826:  lea    0x10(%ebx),%eax
0x07fb6829:  mov    %eax,0x20(%esp)
0x07fb682d:  mov    0x7fbfed4,%eax
0x07fb6832:  lea    -0x4(%eax),%edi
0x07fb6835:  mov    0x20(%esp),%ebx
0x07fb6839:  movw   $0x0,0x18(%esp)
0x07fb6840:  or     $0xffffffff,%ecx
0x07fb6843:  cmp    $0xfffffffc,%edi
0x07fb6846:  je     0x7fb6854

----------------
IN: 
0x07fb6848:  mov    (%edi),%eax
0x07fb684a:  mov    %ax,(%esp)
0x07fb684e:  shr    $0x8,%ax
0x07fb6852:  je     0x7fb686b

----------------
IN: 
0x07fb686b:  mov    %ecx,0x40(%esp)
0x07fb686f:  movzwl (%esp),%esi
0x07fb6873:  mov    $0x3d,%edx
0x07fb6878:  mov    %esi,%eax
0x07fb687a:  call   0xf013a

----------------
IN: 
0x07fb687f:  mov    %al,0x8(%esp)
0x07fb6883:  movzbl %al,%eax
0x07fb6886:  mov    %eax,0x34(%esp)
0x07fb688a:  mov    $0x3c,%edx
0x07fb688f:  mov    %esi,%eax
0x07fb6891:  call   0xf013a

----------------
IN: 
0x07fb6896:  mov    %al,0x38(%esp)
0x07fb689a:  mov    0x40(%esp),%ecx
0x07fb689e:  mov    %ecx,%esi
0x07fb68a0:  cmpl   $0x0,0x34(%esp)
0x07fb68a5:  je     0x7fb6920

----------------
IN: 
0x07fb6920:  mov    0x4(%edi),%eax
0x07fb6923:  lea    -0x4(%eax),%edi
0x07fb6926:  mov    %esi,%ecx
0x07fb6928:  jmp    0x7fb6843

----------------
IN: 
0x07fb6843:  cmp    $0xfffffffc,%edi
0x07fb6846:  je     0x7fb6854

----------------
IN: 
0x07fb68a7:  mov    (%esp),%esi
0x07fb68aa:  and    $0xfff8,%esi
0x07fb68b0:  xor    %eax,%eax
0x07fb68b2:  cmp    %esi,%ecx
0x07fb68b4:  sete   %al
0x07fb68b7:  neg    %eax
0x07fb68b9:  and    %ax,0x18(%esp)
0x07fb68be:  movzwl 0x18(%esp),%eax
0x07fb68c3:  mov    0x8(%esp),%ecx
0x07fb68c7:  bt     %ecx,%eax
0x07fb68ca:  jb     0x7fb6920

----------------
IN: 
0x07fb68cc:  mov    $0x1,%eax
0x07fb68d1:  mov    0x8(%esp),%cl
0x07fb68d5:  shl    %cl,%eax
0x07fb68d7:  or     %ax,0x18(%esp)
0x07fb68dc:  mov    $0x8,%ecx
0x07fb68e1:  xor    %edx,%edx
0x07fb68e3:  mov    %ebx,%eax
0x07fb68e5:  call   0xf0090

----------------
IN: 
0x07fb68ea:  movb   $0x3,(%ebx)
0x07fb68ed:  movb   $0x0,0x1(%ebx)
0x07fb68f1:  movw   $0x1,0x2(%ebx)
0x07fb68f7:  movb   $0x0,0x4(%ebx)
0x07fb68fb:  mov    0x8(%esp),%al
0x07fb68ff:  dec    %eax
0x07fb6900:  mov    (%esp),%edx
0x07fb6903:  shr    $0x3,%dx
0x07fb6907:  and    $0x1f,%edx
0x07fb690a:  shl    $0x2,%edx
0x07fb690d:  or     %edx,%eax
0x07fb690f:  mov    %al,0x5(%ebx)
0x07fb6912:  movb   $0x0,0x6(%ebx)
0x07fb6916:  mov    0x38(%esp),%al
0x07fb691a:  mov    %al,0x7(%ebx)
0x07fb691d:  add    $0x8,%ebx
0x07fb6920:  mov    0x4(%edi),%eax
0x07fb6923:  lea    -0x4(%eax),%edi
0x07fb6926:  mov    %esi,%ecx
0x07fb6928:  jmp    0x7fb6843

----------------
IN: 
0x07fb6854:  xor    %edx,%edx
0x07fb6856:  xor    %ecx,%ecx
0x07fb6858:  mov    $0xf4678,%eax
0x07fb685d:  call   0x7fb0bfd

----------------
IN: 
0x07fb6862:  mov    %eax,%edi
0x07fb6864:  xor    %esi,%esi
0x07fb6866:  jmp    0x7fb692d

----------------
IN: 
0x07fb692d:  mov    $0x8,%ecx
0x07fb6932:  xor    %edx,%edx
0x07fb6934:  mov    %ebx,%eax
0x07fb6936:  call   0xf0090

----------------
IN: 
0x07fb693b:  mov    $0xe20,%eax
0x07fb6940:  bt     %esi,%eax
0x07fb6943:  jb     0x7fb697e

----------------
IN: 
0x07fb6945:  movb   $0x3,(%ebx)
0x07fb6948:  movb   $0x0,0x1(%ebx)
0x07fb694c:  movw   $0x0,0x2(%ebx)
0x07fb6952:  mov    0x28(%esp),%al
0x07fb6956:  mov    %al,0x4(%ebx)
0x07fb6959:  mov    %esi,%eax
0x07fb695b:  mov    %al,0x5(%ebx)
0x07fb695e:  movb   $0x0,0x6(%ebx)
0x07fb6962:  mov    %al,0x7(%ebx)
0x07fb6965:  test   %edi,%edi
0x07fb6967:  je     0x7fb697b

----------------
IN: 
0x07fb6969:  test   %esi,%esi
0x07fb696b:  jne    0x7fb6973

----------------
IN: 
0x07fb696d:  movb   $0x2,0x7(%ebx)
0x07fb6971:  jmp    0x7fb697b

----------------
IN: 
0x07fb697b:  add    $0x8,%ebx
0x07fb697e:  inc    %esi
0x07fb697f:  cmp    $0x10,%esi
0x07fb6982:  jne    0x7fb692d

----------------
IN: 
0x07fb6973:  cmp    $0x2,%esi
0x07fb6976:  jne    0x7fb697b

----------------
IN: 
0x07fb6978:  sub    $0x8,%ebx
0x07fb697b:  add    $0x8,%ebx
0x07fb697e:  inc    %esi
0x07fb697f:  cmp    $0x10,%esi
0x07fb6982:  jne    0x7fb692d

----------------
IN: 
0x07fb697e:  inc    %esi
0x07fb697f:  cmp    $0x10,%esi
0x07fb6982:  jne    0x7fb692d

----------------
IN: 
0x07fb6984:  movb   $0x4,(%ebx)
0x07fb6987:  movb   $0x3,0x1(%ebx)
0x07fb698b:  movw   $0x0,0x2(%ebx)
0x07fb6991:  mov    0x10(%esp),%al
0x07fb6995:  mov    %al,0x4(%ebx)
0x07fb6998:  movb   $0x0,0x5(%ebx)
0x07fb699c:  movb   $0x0,0x6(%ebx)
0x07fb69a0:  movb   $0x0,0x7(%ebx)
0x07fb69a4:  movb   $0x4,0x8(%ebx)
0x07fb69a8:  movb   $0x1,0x9(%ebx)
0x07fb69ac:  movw   $0x0,0xa(%ebx)
0x07fb69b2:  mov    %al,0xc(%ebx)
0x07fb69b5:  movb   $0x0,0xd(%ebx)
0x07fb69b9:  movb   $0xff,0xe(%ebx)
0x07fb69bd:  movb   $0x1,0xf(%ebx)
0x07fb69c1:  add    $0x10,%ebx
0x07fb69c4:  mov    %ebx,%edx
0x07fb69c6:  sub    %ebp,%edx
0x07fb69c8:  sub    0x20(%esp),%ebx
0x07fb69cc:  sar    $0x3,%ebx
0x07fb69cf:  mov    0x2c(%esp),%edi
0x07fb69d3:  add    %ebx,%edi
0x07fb69d5:  mov    %di,0x22(%ebp)
0x07fb69d9:  mov    %dx,0x4(%ebp)
0x07fb69dd:  mov    %ebp,%eax
0x07fb69df:  call   0xf069f

----------------
IN: 
0x07fb69e4:  sub    %al,0x7(%ebp)
0x07fb69e7:  mov    $0x10,%ecx
0x07fb69ec:  xor    %edx,%edx
0x07fb69ee:  lea    0x68(%esp),%eax
0x07fb69f2:  call   0xf0090

----------------
IN: 
0x07fb69f7:  movl   $0x5f504d5f,0x68(%esp)
0x07fb69ff:  mov    %ebp,0x6c(%esp)
0x07fb6a03:  movb   $0x1,0x70(%esp)
0x07fb6a08:  movb   $0x4,0x71(%esp)
0x07fb6a0d:  mov    $0x10,%edx
0x07fb6a12:  lea    0x68(%esp),%eax
0x07fb6a16:  call   0xf069f

----------------
IN: 
0x07fb6a1b:  sub    %al,0x72(%esp)
0x07fb6a1f:  lea    0x68(%esp),%eax
0x07fb6a23:  call   0x7fb43fd

----------------
IN: 
0x07fb43fd:  push   %ebp
0x07fb43fe:  push   %edi
0x07fb43ff:  push   %esi
0x07fb4400:  push   %ebx
0x07fb4401:  sub    $0x8,%esp
0x07fb4404:  mov    0x4(%eax),%esi
0x07fb4407:  test   %esi,%esi
0x07fb4409:  je     0x7fb448f

----------------
IN: 
0x07fb440f:  mov    %eax,%ebx
0x07fb4411:  mov    $0x10,%edx
0x07fb4416:  call   0xf069f

----------------
IN: 
0x07fb441b:  test   %al,%al
0x07fb441d:  jne    0x7fb448f

----------------
IN: 
0x07fb441f:  movzbl 0x8(%ebx),%ecx
0x07fb4423:  shl    $0x4,%ecx
0x07fb4426:  mov    %ecx,(%esp)
0x07fb4429:  movzwl 0x4(%esi),%eax
0x07fb442d:  mov    %eax,0x4(%esp)
0x07fb4431:  mov    0x4(%esp),%eax
0x07fb4435:  add    %ecx,%eax
0x07fb4437:  call   0x7faf8f1

----------------
IN: 
0x07fb443c:  mov    %eax,%ebp
0x07fb443e:  test   %eax,%eax
0x07fb4440:  jne    0x7fb4458

----------------
IN: 
0x07fb4458:  push   %eax
0x07fb4459:  pushl  0x4(%ebx)
0x07fb445c:  push   %ebx
0x07fb445d:  push   $0xf4447
0x07fb4462:  call   0xf0cc9

----------------
IN: 
0x07fb4467:  mov    %ebp,%edi
0x07fb4469:  mov    %ebx,%esi
0x07fb446b:  mov    0x10(%esp),%ecx
0x07fb446f:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb446f:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb4471:  mov    %edi,0x4(%ebp)
0x07fb4474:  mov    $0x10,%edx
0x07fb4479:  mov    %ebp,%eax
0x07fb447b:  call   0xf069f

----------------
IN: 
0x07fb4480:  sub    %al,0xa(%ebp)
0x07fb4483:  mov    0x4(%ebx),%esi
0x07fb4486:  mov    0x14(%esp),%ecx
0x07fb448a:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb448a:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb448c:  add    $0x10,%esp
0x07fb448f:  add    $0x8,%esp
0x07fb4492:  pop    %ebx
0x07fb4493:  pop    %esi
0x07fb4494:  pop    %edi
0x07fb4495:  pop    %ebp
0x07fb4496:  ret    

----------------
IN: 
0x07fb6a28:  mov    %ebp,%eax
0x07fb6a2a:  call   0x7faf92b

----------------
IN: 
0x07fb6a2f:  mov    $0xf4bb0,%eax
0x07fb6a34:  call   0x7fb0bc8

----------------
IN: 
0x07fb6a39:  mov    %eax,%edi
0x07fb6a3b:  mov    $0xf4bc9,%eax
0x07fb6a40:  call   0x7fb0bc8

----------------
IN: 
0x07fb6a45:  mov    %eax,%esi
0x07fb6a47:  test   %eax,%eax
0x07fb6a49:  je     0x7fb6cb8

----------------
IN: 
0x07fb6a4f:  test   %edi,%edi
0x07fb6a51:  je     0x7fb6cb8

----------------
IN: 
0x07fb6a57:  cmpl   $0x1f,0x84(%edi)
0x07fb6a5e:  jne    0x7fb6cb8

----------------
IN: 
0x07fb6a64:  lea    0x68(%esp),%ebx
0x07fb6a68:  mov    $0x1f,%ecx
0x07fb6a6d:  mov    %ebx,%edx
0x07fb6a6f:  mov    %edi,%eax
0x07fb6a71:  call   *0x88(%edi)

----------------
IN: 
0x07fb6a77:  mov    0x84(%esi),%eax
0x07fb6a7d:  movzwl 0x7e(%esp),%edx
0x07fb6a82:  cmp    %edx,%eax
0x07fb6a84:  jne    0x7fb6cb8

----------------
IN: 
0x07fb6a8a:  call   0x7faf8cf

----------------
IN: 
0x07fb6a8f:  mov    %eax,(%esp)
0x07fb6a92:  test   %eax,%eax
0x07fb6a94:  jne    0x7fb6aa9

----------------
IN: 
0x07fb6aa9:  mov    0x84(%esi),%ecx
0x07fb6aaf:  mov    (%esp),%edx
0x07fb6ab2:  mov    %esi,%eax
0x07fb6ab4:  call   *0x88(%esi)

----------------
IN: 
0x07fb6aba:  mov    (%esp),%eax
0x07fb6abd:  mov    %eax,0x80(%esp)
0x07fb6ac4:  xor    %edx,%edx
0x07fb6ac6:  mov    %ebx,%eax
0x07fb6ac8:  call   0x7fafe18

----------------
IN: 
0x07fafe18:  test   %eax,%eax
0x07fafe1a:  je     0x7fafe6d

----------------
IN: 
0x07fafe1c:  push   %ebx
0x07fafe1d:  mov    0x18(%eax),%ecx
0x07fafe20:  movzwl 0x16(%eax),%ebx
0x07fafe24:  add    %ecx,%ebx
0x07fafe26:  test   %edx,%edx
0x07fafe28:  je     0x7fafe50

----------------
IN: 
0x07fafe50:  xor    %eax,%eax
0x07fafe52:  cmp    %ebx,%ecx
0x07fafe54:  jae    0x7fafe72

----------------
IN: 
0x07fafe56:  lea    0x4(%ecx),%edx
0x07fafe59:  xor    %eax,%eax
0x07fafe5b:  cmp    %edx,%ebx
0x07fafe5d:  jbe    0x7fafe72

----------------
IN: 
0x07fafe5f:  movzbl 0x1(%ecx),%edx
0x07fafe63:  add    %ecx,%edx
0x07fafe65:  cmp    %edx,%ebx
0x07fafe67:  jbe    0x7fafe72

----------------
IN: 
0x07fafe69:  mov    %ecx,%eax
0x07fafe6b:  jmp    0x7fafe72

----------------
IN: 
0x07fafe72:  pop    %ebx
0x07fafe73:  ret    

----------------
IN: 
0x07fb6acd:  test   %eax,%eax
0x07fb6acf:  je     0x7fb6ada

----------------
IN: 
0x07fb6ad1:  cmpb   $0x0,(%eax)
0x07fb6ad4:  je     0x7fb6ae1

----------------
IN: 
0x07fb6ad6:  mov    %eax,%edx
0x07fb6ad8:  jmp    0x7fb6ac6

----------------
IN: 
0x07fb6ac6:  mov    %ebx,%eax
0x07fb6ac8:  call   0x7fafe18

----------------
IN: 
0x07fafe2a:  lea    0x4(%edx),%ecx
0x07fafe2d:  xor    %eax,%eax
0x07fafe2f:  cmp    %ecx,%ebx
0x07fafe31:  jb     0x7fafe72

----------------
IN: 
0x07fafe33:  movzbl 0x1(%edx),%eax
0x07fafe37:  lea    0x2(%edx,%eax,1),%ecx
0x07fafe3b:  cmp    %ebx,%ecx
0x07fafe3d:  jae    0x7fafe70

----------------
IN: 
0x07fafe3f:  cmpb   $0x0,-0x1(%ecx)
0x07fafe43:  je     0x7fafe48

----------------
IN: 
0x07fafe45:  inc    %ecx
0x07fafe46:  jmp    0x7fafe3b

----------------
IN: 
0x07fafe3b:  cmp    %ebx,%ecx
0x07fafe3d:  jae    0x7fafe70

----------------
IN: 
0x07fafe48:  cmpb   $0x0,-0x2(%ecx)
0x07fafe4c:  jne    0x7fafe45

----------------
IN: 
0x07fafe4e:  jmp    0x7fafe56

----------------
IN: 
0x07fafe70:  xor    %eax,%eax
0x07fafe72:  pop    %ebx
0x07fafe73:  ret    

----------------
IN: 
0x07fb6ada:  mov    $0x1,%esi
0x07fb6adf:  jmp    0x7fb6ae3

----------------
IN: 
0x07fb6ae3:  mov    0x7e(%esp),%ax
0x07fb6ae8:  mov    %ax,0x10(%esp)
0x07fb6aed:  test   %si,%si
0x07fb6af0:  je     0x7fb6b39

----------------
IN: 
0x07fb6af2:  mov    $0xf4be2,%eax
0x07fb6af7:  call   0x7faf4ae

----------------
IN: 
0x07fb6afc:  mov    %eax,%ebx
0x07fb6afe:  mov    $0xf5cf8,%eax
0x07fb6b03:  call   0x7faf4ae

----------------
IN: 
0x07fb6b08:  add    %eax,%ebx
0x07fb6b0a:  mov    $0xf4bea,%eax
0x07fb6b0f:  call   0x7faf4ae

----------------
IN: 
0x07fb6b14:  add    $0x1c,%ebx
0x07fb6b17:  add    %ebx,%eax
0x07fb6b19:  mov    0x10(%esp),%edi
0x07fb6b1d:  lea    (%eax,%edi,1),%edx
0x07fb6b20:  mov    %dx,0x7e(%esp)
0x07fb6b25:  cmp    0x70(%esp),%ax
0x07fb6b2a:  jbe    0x7fb6b31

----------------
IN: 
0x07fb6b31:  incw   0x84(%esp)
0x07fb6b39:  movzwl 0x7e(%esp),%eax
0x07fb6b3e:  cmp    $0x258,%ax
0x07fb6b42:  jbe    0x7fb6b4b

----------------
IN: 
0x07fb6b4b:  call   0x7faf8f1

----------------
IN: 
0x07fb6b50:  mov    %eax,%ebx
0x07fb6b52:  test   %eax,%eax
0x07fb6b54:  jne    0x7fb6b72

----------------
IN: 
0x07fb6b72:  mov    %eax,0x80(%esp)
0x07fb6b79:  test   %si,%si
0x07fb6b7c:  je     0x7fb6c6f

----------------
IN: 
0x07fb6b82:  lea    0x18(%eax),%ebp
0x07fb6b85:  movb   $0x0,(%eax)
0x07fb6b88:  movb   $0x18,0x1(%eax)
0x07fb6b8c:  movw   $0x0,0x2(%eax)
0x07fb6b92:  mov    $0xf4be2,%eax
0x07fb6b97:  call   0x7faf4ae

----------------
IN: 
0x07fb6b9c:  lea    0x1(%eax),%ecx
0x07fb6b9f:  cmp    $0x1,%ecx
0x07fb6ba2:  jle    0x7fb6bbd

----------------
IN: 
0x07fb6ba4:  mov    $0xf4be2,%esi
0x07fb6ba9:  mov    %ebp,%edi
0x07fb6bab:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb6bab:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb6bad:  mov    %edi,%ebp
0x07fb6baf:  movb   $0x1,0x4(%ebx)
0x07fb6bb3:  movl   $0x1,0x8(%esp)
0x07fb6bbb:  jmp    0x7fb6bc9

----------------
IN: 
0x07fb6bc9:  mov    $0xf5cf8,%eax
0x07fb6bce:  call   0x7faf4ae

----------------
IN: 
0x07fb6bd3:  lea    0x1(%eax),%ecx
0x07fb6bd6:  cmp    $0x1,%ecx
0x07fb6bd9:  jle    0x7fb6bf3

----------------
IN: 
0x07fb6bdb:  mov    $0xf5cf8,%esi
0x07fb6be0:  mov    %ebp,%edi
0x07fb6be2:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb6be2:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb6be4:  mov    %edi,%ebp
0x07fb6be6:  incl   0x8(%esp)
0x07fb6bea:  mov    0x8(%esp),%al
0x07fb6bee:  mov    %al,0x5(%ebx)
0x07fb6bf1:  jmp    0x7fb6bf7

----------------
IN: 
0x07fb6bf7:  movw   $0xe800,0x6(%ebx)
0x07fb6bfd:  mov    $0xf4bea,%eax
0x07fb6c02:  call   0x7faf4ae

----------------
IN: 
0x07fb6c07:  lea    0x1(%eax),%ecx
0x07fb6c0a:  cmp    $0x1,%ecx
0x07fb6c0d:  jle    0x7fb6c27

----------------
IN: 
0x07fb6c0f:  mov    $0xf4bea,%esi
0x07fb6c14:  mov    %ebp,%edi
0x07fb6c16:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb6c16:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb6c18:  mov    %edi,%ebp
0x07fb6c1a:  incl   0x8(%esp)
0x07fb6c1e:  mov    0x8(%esp),%al
0x07fb6c22:  mov    %al,0x8(%ebx)
0x07fb6c25:  jmp    0x7fb6c2b

----------------
IN: 
0x07fb6c2b:  movb   $0x0,0x9(%ebx)
0x07fb6c2f:  lea    0xa(%ebx),%eax
0x07fb6c32:  mov    $0x8,%ecx
0x07fb6c37:  xor    %edx,%edx
0x07fb6c39:  call   0xf0090

----------------
IN: 
0x07fb6c3e:  movb   $0x8,0xa(%ebx)
0x07fb6c42:  movb   $0x0,0x12(%ebx)
0x07fb6c46:  movb   $0x4,0x13(%ebx)
0x07fb6c4a:  movb   $0x0,0x14(%ebx)
0x07fb6c4e:  movb   $0x0,0x15(%ebx)
0x07fb6c52:  movb   $0xff,0x16(%ebx)
0x07fb6c56:  movb   $0xff,0x17(%ebx)
0x07fb6c5a:  movb   $0x0,0x0(%ebp)
0x07fb6c5e:  lea    0x1(%ebp),%ebx
0x07fb6c61:  cmpl   $0x0,0x8(%esp)
0x07fb6c66:  jne    0x7fb6c6f

----------------
IN: 
0x07fb6c6f:  movzwl 0x10(%esp),%ecx
0x07fb6c74:  mov    %ebx,%edi
0x07fb6c76:  mov    (%esp),%esi
0x07fb6c79:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb6c79:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb6c7b:  mov    (%esp),%eax
0x07fb6c7e:  call   0x7faf92b

----------------
IN: 
0x07fb6c83:  mov    $0x10,%edx
0x07fb6c88:  lea    0x68(%esp),%eax
0x07fb6c8c:  call   0xf069f

----------------
IN: 
0x07fb6c91:  sub    %al,0x6c(%esp)
0x07fb6c95:  movzbl 0x6d(%esp),%edx
0x07fb6c9a:  sub    $0x10,%edx
0x07fb6c9d:  lea    0x78(%esp),%eax
0x07fb6ca1:  call   0xf069f

----------------
IN: 
0x07fb6ca6:  sub    %al,0x7d(%esp)
0x07fb6caa:  lea    0x68(%esp),%eax
0x07fb6cae:  call   0x7fb44f2

----------------
IN: 
0x07fb44f2:  cmpl   $0x0,0x7fbff1c
0x07fb44f9:  jne    0x7fb4590

----------------
IN: 
0x07fb44ff:  push   %edi
0x07fb4500:  push   %esi
0x07fb4501:  push   %ebx
0x07fb4502:  mov    %eax,%esi
0x07fb4504:  mov    $0x4,%ecx
0x07fb4509:  mov    $0xf448a,%edx
0x07fb450e:  call   0x7faf4bd

----------------
IN: 
0x07fb4513:  test   %eax,%eax
0x07fb4515:  jne    0x7fb458d

----------------
IN: 
0x07fb4517:  mov    $0x10,%edx
0x07fb451c:  mov    %esi,%eax
0x07fb451e:  call   0xf069f

----------------
IN: 
0x07fb4523:  test   %al,%al
0x07fb4525:  jne    0x7fb458d

----------------
IN: 
0x07fb4527:  lea    0x10(%esi),%edi
0x07fb452a:  mov    $0x5,%ecx
0x07fb452f:  mov    $0xf448f,%edx
0x07fb4534:  mov    %edi,%eax
0x07fb4536:  call   0x7faf4bd

----------------
IN: 
0x07fb453b:  test   %eax,%eax
0x07fb453d:  jne    0x7fb458d

----------------
IN: 
0x07fb453f:  movzbl 0x5(%esi),%ebx
0x07fb4543:  lea    -0x10(%ebx),%edx
0x07fb4546:  mov    %edi,%eax
0x07fb4548:  call   0xf069f

----------------
IN: 
0x07fb454d:  test   %al,%al
0x07fb454f:  jne    0x7fb458d

----------------
IN: 
0x07fb4551:  mov    %ebx,%eax
0x07fb4553:  call   0x7faf8f1

----------------
IN: 
0x07fb4558:  mov    %eax,%ebx
0x07fb455a:  test   %eax,%eax
0x07fb455c:  jne    0x7fb4570

----------------
IN: 
0x07fb4570:  push   %eax
0x07fb4571:  push   %esi
0x07fb4572:  push   $0xf4495
0x07fb4577:  call   0xf0cc9

----------------
IN: 
0x07fb457c:  movzbl 0x5(%esi),%ecx
0x07fb4580:  mov    %ebx,%edi
0x07fb4582:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb4582:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb4584:  mov    %ebx,0x7fbff1c
0x07fb458a:  add    $0xc,%esp
0x07fb458d:  pop    %ebx
0x07fb458e:  pop    %esi
0x07fb458f:  pop    %edi
0x07fb4590:  ret    

----------------
IN: 
0x07fb6cb3:  jmp    0x7fb7804

----------------
IN: 
0x07fb7804:  lea    0x5c(%esp),%edx
0x07fb7808:  mov    $0xf4c00,%eax
0x07fb780d:  call   0x7fb107c

----------------
IN: 
0x07fb7812:  mov    %eax,0x8(%esp)
0x07fb7816:  test   %eax,%eax
0x07fb7818:  je     0x7fb7a8b

----------------
IN: 
0x07fb781e:  mov    0x5c(%esp),%eax
0x07fb7822:  test   $0x7f,%al
0x07fb7824:  je     0x7fb7842

----------------
IN: 
0x07fb7842:  shr    $0x7,%eax
0x07fb7845:  lea    0x4(,%eax,8),%eax
0x07fb784c:  call   0x7fb09cc

----------------
IN: 
0x07fb7851:  mov    %eax,(%esp)
0x07fb7854:  test   %eax,%eax
0x07fb7856:  jne    0x7fb7869

----------------
IN: 
0x07fb7869:  mov    (%esp),%eax
0x07fb786c:  movl   $0x0,(%eax)
0x07fb7872:  mov    0x8(%esp),%eax
0x07fb7876:  lea    0x4(%eax),%ebp
0x07fb7879:  movl   $0x0,0x10(%esp)
0x07fb7881:  mov    0x10(%esp),%eax
0x07fb7885:  cmp    0x5c(%esp),%eax
0x07fb7889:  jge    0x7fb7a6f

----------------
IN: 
0x07fb788f:  mov    -0x4(%ebp),%eax
0x07fb7892:  cmp    $0x2,%eax
0x07fb7895:  je     0x7fb796f

----------------
IN: 
0x07fb789b:  cmp    $0x3,%eax
0x07fb789e:  je     0x7fb7a09

----------------
IN: 
0x07fb78a4:  dec    %eax
0x07fb78a5:  jne    0x7fb7a62

----------------
IN: 
0x07fb78ab:  mov    (%esp),%eax
0x07fb78ae:  mov    (%eax),%esi
0x07fb78b0:  mov    0x38(%ebp),%edi
0x07fb78b3:  lea    -0x1(%edi),%eax
0x07fb78b6:  test   %edi,%eax
0x07fb78b8:  jne    0x7fb7963

----------------
IN: 
0x07fb78be:  mov    0x3c(%ebp),%al
0x07fb78c1:  cmp    $0x1,%al
0x07fb78c3:  je     0x7fb78d3

----------------
IN: 
0x07fb78c5:  mov    $0x7fbfea4,%ebx
0x07fb78ca:  cmp    $0x2,%al
0x07fb78cc:  je     0x7fb78d8

----------------
IN: 
0x07fb78d8:  cmp    $0xf,%edi
0x07fb78db:  ja     0x7fb78e2

----------------
IN: 
0x07fb78e2:  cmpb   $0x0,0x37(%ebp)
0x07fb78e6:  jne    0x7fb7963

----------------
IN: 
0x07fb78e8:  mov    %ebp,%eax
0x07fb78ea:  call   0x7fb0bc8

----------------
IN: 
0x07fb78ef:  mov    (%esp),%ecx
0x07fb78f2:  lea    (%ecx,%esi,8),%esi
0x07fb78f5:  mov    %eax,0x4(%esi)
0x07fb78f8:  test   %eax,%eax
0x07fb78fa:  je     0x7fb7a62

----------------
IN: 
0x07fb7900:  mov    0x84(%eax),%edx
0x07fb7906:  test   %edx,%edx
0x07fb7908:  je     0x7fb7a62

----------------
IN: 
0x07fb790e:  mov    %edi,%ecx
0x07fb7910:  mov    %ebx,%eax
0x07fb7912:  call   0x7faf858

----------------
IN: 
0x07fb7917:  mov    %eax,%ebx
0x07fb7919:  test   %eax,%eax
0x07fb791b:  jne    0x7fb7931

----------------
IN: 
0x07fb7931:  mov    0x4(%esi),%edi
0x07fb7934:  mov    0x84(%edi),%ecx
0x07fb793a:  mov    %eax,%edx
0x07fb793c:  mov    %edi,%eax
0x07fb793e:  call   *0x88(%edi)

----------------
IN: 
0x07fb7944:  mov    0x4(%esi),%edx
0x07fb7947:  cmp    0x84(%edx),%eax
0x07fb794d:  jne    0x7fb795c

----------------
IN: 
0x07fb794f:  mov    %ebx,0x8(%esi)
0x07fb7952:  mov    (%esp),%eax
0x07fb7955:  incl   (%eax)
0x07fb7957:  jmp    0x7fb7a62

----------------
IN: 
0x07fb7a62:  subl   $0xffffff80,0x10(%esp)
0x07fb7a67:  sub    $0xffffff80,%ebp
0x07fb7a6a:  jmp    0x7fb7881

----------------
IN: 
0x07fb7881:  mov    0x10(%esp),%eax
0x07fb7885:  cmp    0x5c(%esp),%eax
0x07fb7889:  jge    0x7fb7a6f

----------------
IN: 
0x07fb78d3:  mov    $0x7fbfea8,%ebx
0x07fb78d8:  cmp    $0xf,%edi
0x07fb78db:  ja     0x7fb78e2

----------------
IN: 
0x07fb7a09:  mov    0x38(%ebp),%ebx
0x07fb7a0c:  mov    0x3c(%ebp),%esi
0x07fb7a0f:  mov    0x40(%ebp),%edi
0x07fb7a12:  mov    (%esp),%edx
0x07fb7a15:  mov    %ebp,%eax
0x07fb7a17:  call   0x7fb01b3

----------------
IN: 
0x07fb01b3:  cmpb   $0x0,0x37(%eax)
0x07fb01b7:  jne    0x7fb01e8

----------------
IN: 
0x07fb01b9:  push   %ebp
0x07fb01ba:  push   %edi
0x07fb01bb:  push   %esi
0x07fb01bc:  push   %ebx
0x07fb01bd:  mov    %edx,%esi
0x07fb01bf:  mov    %eax,%edi
0x07fb01c1:  mov    (%edx),%ebp
0x07fb01c3:  xor    %ebx,%ebx
0x07fb01c5:  cmp    %ebp,%ebx
0x07fb01c7:  jge    0x7fb01e4

----------------
IN: 
0x07fb01c9:  mov    0x4(%esi,%ebx,8),%eax
0x07fb01cd:  add    $0x4,%eax
0x07fb01d0:  mov    %edi,%edx
0x07fb01d2:  call   0xf0070

----------------
IN: 
0x000f0087:  inc    %ecx
0x000f0088:  test   %bl,%bl
0x000f008a:  jne    0xf0073

----------------
IN: 
0x000f0073:  mov    (%eax,%ecx,1),%bl
0x000f0076:  cmp    (%edx,%ecx,1),%bl
0x000f0079:  je     0xf0087

----------------
IN: 
0x07fb01d7:  test   %eax,%eax
0x07fb01d9:  jne    0x7fb01e1

----------------
IN: 
0x07fb01e1:  inc    %ebx
0x07fb01e2:  jmp    0x7fb01c5

----------------
IN: 
0x07fb01c5:  cmp    %ebp,%ebx
0x07fb01c7:  jge    0x7fb01e4

----------------
IN: 
0x000f008c:  xor    %eax,%eax
0x000f008e:  pop    %ebx
0x000f008f:  ret    

----------------
IN: 
0x07fb01db:  lea    0x4(%esi,%ebx,8),%eax
0x07fb01df:  jmp    0x7fb01eb

----------------
IN: 
0x07fb01eb:  pop    %ebx
0x07fb01ec:  pop    %esi
0x07fb01ed:  pop    %edi
0x07fb01ee:  pop    %ebp
0x07fb01ef:  ret    

----------------
IN: 
0x07fb7a1c:  test   %eax,%eax
0x07fb7a1e:  je     0x7fb7a4e

----------------
IN: 
0x07fb7a20:  mov    0x4(%eax),%edx
0x07fb7a23:  test   %edx,%edx
0x07fb7a25:  je     0x7fb7a4e

----------------
IN: 
0x07fb7a27:  mov    (%eax),%eax
0x07fb7a29:  mov    0x84(%eax),%ecx
0x07fb7a2f:  cmp    %ecx,%ebx
0x07fb7a31:  jae    0x7fb7a4e

----------------
IN: 
0x07fb7a33:  lea    (%edi,%esi,1),%eax
0x07fb7a36:  cmp    %ecx,%eax
0x07fb7a38:  ja     0x7fb7a4e

----------------
IN: 
0x07fb7a3a:  cmp    %esi,%eax
0x07fb7a3c:  jb     0x7fb7a4e

----------------
IN: 
0x07fb7a3e:  add    %edx,%ebx
0x07fb7a40:  lea    (%edx,%esi,1),%eax
0x07fb7a43:  mov    %edi,%edx
0x07fb7a45:  call   0xf069f

----------------
IN: 
0x07fb7a4a:  sub    %al,(%ebx)
0x07fb7a4c:  jmp    0x7fb7a62

----------------
IN: 
0x07fb796f:  mov    0x70(%ebp),%eax
0x07fb7972:  mov    %eax,0x18(%esp)
0x07fb7976:  movl   $0x0,0x68(%esp)
0x07fb797e:  movl   $0x0,0x6c(%esp)
0x07fb7986:  mov    (%esp),%edx
0x07fb7989:  mov    %ebp,%eax
0x07fb798b:  call   0x7fb01b3

----------------
IN: 
0x07fb7990:  mov    %eax,%esi
0x07fb7992:  lea    0x38(%ebp),%eax
0x07fb7995:  mov    (%esp),%edx
0x07fb7998:  call   0x7fb01b3

----------------
IN: 
0x07fb799d:  test   %eax,%eax
0x07fb799f:  je     0x7fb7a00

----------------
IN: 
0x07fb79a1:  test   %esi,%esi
0x07fb79a3:  je     0x7fb7a00

----------------
IN: 
0x07fb79a5:  mov    0x4(%esi),%edi
0x07fb79a8:  test   %edi,%edi
0x07fb79aa:  je     0x7fb7a00

----------------
IN: 
0x07fb79ac:  mov    0x4(%eax),%ebx
0x07fb79af:  test   %ebx,%ebx
0x07fb79b1:  je     0x7fb7a00

----------------
IN: 
0x07fb79b3:  movzbl 0x74(%ebp),%edx
0x07fb79b7:  mov    %edx,%ecx
0x07fb79b9:  mov    0x18(%esp),%eax
0x07fb79bd:  add    %edx,%eax
0x07fb79bf:  jb     0x7fb7a00

----------------
IN: 
0x07fb79c1:  dec    %ecx
0x07fb79c2:  cmp    $0x7,%cl
0x07fb79c5:  ja     0x7fb7a00

----------------
IN: 
0x07fb79c7:  mov    (%esi),%ecx
0x07fb79c9:  cmp    0x84(%ecx),%eax
0x07fb79cf:  ja     0x7fb7a00

----------------
IN: 
0x07fb79d1:  lea    -0x1(%edx),%eax
0x07fb79d4:  test   %edx,%eax
0x07fb79d6:  jne    0x7fb7a00

----------------
IN: 
0x07fb79d8:  mov    0x18(%esp),%eax
0x07fb79dc:  add    %edi,%eax
0x07fb79de:  lea    0x68(%esp),%edi
0x07fb79e2:  mov    %eax,%esi
0x07fb79e4:  mov    %edx,%ecx
0x07fb79e6:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb79e6:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb79e8:  mov    %ebx,%ecx
0x07fb79ea:  xor    %ebx,%ebx
0x07fb79ec:  add    %ecx,0x68(%esp)
0x07fb79f0:  adc    %ebx,0x6c(%esp)
0x07fb79f4:  mov    %eax,%edi
0x07fb79f6:  lea    0x68(%esp),%esi
0x07fb79fa:  mov    %edx,%ecx
0x07fb79fc:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb79fc:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb79fe:  jmp    0x7fb7a62

----------------
IN: 
0x07fb7a6f:  mov    (%esp),%eax
0x07fb7a72:  call   0x7faf92b

----------------
IN: 
0x07fb7a77:  mov    0x8(%esp),%eax
0x07fb7a7b:  call   0x7faf92b

----------------
IN: 
0x07fb7a80:  jmp    0x7fb7a93

----------------
IN: 
0x07fb7a93:  mov    $0xf5faf,%ebx
0x07fb7a98:  and    $0xfffffff0,%ebx
0x07fb7a9b:  mov    $0xf67a0,%esi
0x07fb7aa0:  and    $0xfffffff0,%esi
0x07fb7aa3:  mov    $0xf67a0,%edi
0x07fb7aa8:  cmp    %esi,%ebx
0x07fb7aaa:  ja     0x7fb7ac2

----------------
IN: 
0x07fb7aac:  mov    %ebx,%ebp
0x07fb7aae:  mov    %edi,%edx
0x07fb7ab0:  sub    %ebx,%edx
0x07fb7ab2:  mov    %ebx,%eax
0x07fb7ab4:  call   0x7fb0903

----------------
IN: 
0x07fb0903:  cmp    $0x13,%edx
0x07fb0906:  jbe    0x7fb0966

----------------
IN: 
0x07fb0908:  push   %edi
0x07fb0909:  push   %esi
0x07fb090a:  push   %ebx
0x07fb090b:  mov    (%eax),%ebx
0x07fb090d:  xor    $0x20445352,%ebx
0x07fb0913:  mov    0x4(%eax),%ecx
0x07fb0916:  xor    $0x20525450,%ecx
0x07fb091c:  or     %ecx,%ebx
0x07fb091e:  jne    0x7fb095d

----------------
IN: 
0x07fb095d:  or     $0xffffffff,%ecx
0x07fb0960:  mov    %ecx,%eax
0x07fb0962:  pop    %ebx
0x07fb0963:  pop    %esi
0x07fb0964:  pop    %edi
0x07fb0965:  ret    

----------------
IN: 
0x07fb7ab9:  test   %eax,%eax
0x07fb7abb:  jns    0x7fb7ac4

----------------
IN: 
0x07fb7abd:  add    $0x10,%ebx
0x07fb7ac0:  jmp    0x7fb7aa8

----------------
IN: 
0x07fb7aa8:  cmp    %esi,%ebx
0x07fb7aaa:  ja     0x7fb7ac2

----------------
IN: 
0x07fb0920:  mov    %edx,%esi
0x07fb0922:  mov    %eax,%ebx
0x07fb0924:  mov    $0x14,%edx
0x07fb0929:  call   0xf069f

----------------
IN: 
0x07fb092e:  or     $0xffffffff,%ecx
0x07fb0931:  test   %al,%al
0x07fb0933:  jne    0x7fb0960

----------------
IN: 
0x07fb0935:  cmpb   $0x1,0xf(%ebx)
0x07fb0939:  jbe    0x7fb0954

----------------
IN: 
0x07fb0954:  mov    $0x14,%edi
0x07fb0959:  mov    %edi,%ecx
0x07fb095b:  jmp    0x7fb0960

----------------
IN: 
0x07fb0960:  mov    %ecx,%eax
0x07fb0962:  pop    %ebx
0x07fb0963:  pop    %esi
0x07fb0964:  pop    %edi
0x07fb0965:  ret    

----------------
IN: 
0x07fb7ac4:  mov    %ebp,0xf5ecc
0x07fb7aca:  test   %ebp,%ebp
0x07fb7acc:  jne    0x7fb831f

----------------
IN: 
0x07fb831f:  add    $0x88,%esp
0x07fb8325:  pop    %ebx
0x07fb8326:  pop    %esi
0x07fb8327:  pop    %edi
0x07fb8328:  pop    %ebp
0x07fb8329:  ret    

----------------
IN: 
0x07fbba2f:  call   0xeff00

----------------
IN: 
0x000eff00:  xor    %eax,%eax
0x000eff02:  cmpl   $0x2,0xf5f90
0x000eff09:  jne    0xeff17

----------------
IN: 
0x000eff17:  ret    

----------------
IN: 
0x07fbba34:  test   %eax,%eax
0x07fbba36:  je     0x7fbba3d

----------------
IN: 
0x07fbba3d:  push   $0xf5610
0x07fbba42:  call   0xf0cc9

----------------
IN: 
0x07fbba47:  mov    $0x1,%edx
0x07fbba4c:  xor    %ecx,%ecx
0x07fbba4e:  mov    $0xf5629,%eax
0x07fbba53:  call   0x7fb0bfd

----------------
IN: 
0x07fbba58:  mov    %eax,0xf5f84
0x07fbba5d:  mov    $0x1,%edx
0x07fbba62:  xor    %ecx,%ecx
0x07fbba64:  mov    $0xf5641,%eax
0x07fbba69:  call   0x7fb0bfd

----------------
IN: 
0x07fbba6e:  mov    %eax,0xf5f80
0x07fbba73:  mov    $0x1,%edx
0x07fbba78:  xor    %ecx,%ecx
0x07fbba7a:  mov    $0xf5658,%eax
0x07fbba7f:  call   0x7fb0bfd

----------------
IN: 
0x07fbba84:  mov    %eax,0xf5f7c
0x07fbba89:  call   0xf01ad

----------------
IN: 
0x000f01ad:  mov    0xf5f88,%eax
0x000f01b2:  mov    0x10(%eax),%eax
0x000f01b5:  sub    $0x10,%eax
0x000f01b8:  and    $0xfffff800,%eax
0x000f01bd:  ret    

----------------
IN: 
0x07fbba8e:  lea    -0xc0000(%eax),%ecx
0x07fbba94:  xor    %edx,%edx
0x07fbba96:  mov    $0xc0000,%eax
0x07fbba9b:  call   0xf0090

----------------
IN: 
0x07fbbaa0:  mov    0x7fbfed4,%eax
0x07fbbaa5:  lea    -0x4(%eax),%ebx
0x07fbbaa8:  pop    %edi
0x07fbbaa9:  cmp    $0xfffffffc,%ebx
0x07fbbaac:  je     0x7fbbccd

----------------
IN: 
0x07fbbab2:  mov    %ebx,%eax
0x07fbbab4:  call   0x7fb02d2

----------------
IN: 
0x07fbbab9:  test   %eax,%eax
0x07fbbabb:  jne    0x7fbbac5

----------------
IN: 
0x07fbbabd:  mov    0x4(%ebx),%ebx
0x07fbbac0:  sub    $0x4,%ebx
0x07fbbac3:  jmp    0x7fbbaa9

----------------
IN: 
0x07fbbaa9:  cmp    $0xfffffffc,%ebx
0x07fbbaac:  je     0x7fbbccd

----------------
IN: 
0x07fbbac5:  mov    $0xf566d,%edx
0x07fbbaca:  mov    $0xf3fc4,%eax
0x07fbbacf:  call   0xf0070

----------------
IN: 
0x07fbbad4:  test   %eax,%eax
0x07fbbad6:  jne    0x7fbbb01

----------------
IN: 
0x07fbbb01:  mov    $0xf567e,%edx
0x07fbbb06:  mov    $0xf3fc4,%eax
0x07fbbb0b:  call   0xf0070

----------------
IN: 
0x07fbbb10:  test   %eax,%eax
0x07fbbb12:  jne    0x7fbbb2b

----------------
IN: 
0x07fbbb2b:  mov    $0xf5689,%edx
0x07fbbb30:  mov    $0xf3fc4,%eax
0x07fbbb35:  call   0xf0070

----------------
IN: 
0x07fbbb3a:  test   %eax,%eax
0x07fbbb3c:  jne    0x7fbbb67

----------------
IN: 
0x07fbbb67:  mov    $0xf5696,%edx
0x07fbbb6c:  mov    $0xf3fc4,%eax
0x07fbbb71:  call   0xf0070

----------------
IN: 
0x07fbbb76:  test   %eax,%eax
0x07fbbb78:  jne    0x7fbbba3

----------------
IN: 
0x07fbbba3:  mov    0x10(%ebx),%ax
0x07fbbba7:  cmp    $0x1106,%ax
0x07fbbbab:  jne    0x7fbbca1

----------------
IN: 
0x07fbbca1:  cmp    $0x8086,%ax
0x07fbbca5:  jne    0x7fbbcbf

----------------
IN: 
0x07fbbcbf:  xor    %ecx,%ecx
0x07fbbcc1:  mov    $0x1,%edx
0x07fbbcc6:  mov    %ebx,%eax
0x07fbbcc8:  call   0x7fb576f

----------------
IN: 
0x07fb576f:  push   %ebp
0x07fb5770:  push   %edi
0x07fb5771:  push   %esi
0x07fb5772:  push   %ebx
0x07fb5773:  sub    $0x28,%esp
0x07fb5776:  mov    %eax,%ebx
0x07fb5778:  mov    %edx,0x8(%esp)
0x07fb577c:  mov    %ecx,(%esp)
0x07fb577f:  mov    (%eax),%eax
0x07fb5781:  mov    %ax,0x6(%esp)
0x07fb5786:  movzwl 0x12(%ebx),%eax
0x07fb578a:  push   %eax
0x07fb578b:  movzwl 0x10(%ebx),%eax
0x07fb578f:  push   %eax
0x07fb5790:  push   $0xf483c
0x07fb5795:  push   $0x11
0x07fb5797:  lea    0x27(%esp),%esi
0x07fb579b:  push   %esi
0x07fb579c:  call   0x7fb5724

----------------
IN: 
0x07fb5724:  push   %ebx
0x07fb5725:  sub    $0xc,%esp
0x07fb5728:  mov    0x14(%esp),%ebx
0x07fb572c:  mov    0x18(%esp),%edx
0x07fb5730:  xor    %eax,%eax
0x07fb5732:  test   %edx,%edx
0x07fb5734:  je     0x7fb576a

----------------
IN: 
0x07fb5736:  movl   $0x7faf4a0,(%esp)
0x07fb573d:  mov    %ebx,0x4(%esp)
0x07fb5741:  add    %ebx,%edx
0x07fb5743:  mov    %edx,0x8(%esp)
0x07fb5747:  lea    0x20(%esp),%ecx
0x07fb574b:  mov    0x1c(%esp),%edx
0x07fb574f:  mov    %esp,%eax
0x07fb5751:  call   0xf0854

----------------
IN: 
0x07faf4a0:  mov    0x4(%eax),%ecx
0x07faf4a3:  cmp    0x8(%eax),%ecx
0x07faf4a6:  jae    0x7faf4ad

----------------
IN: 
0x07faf4a8:  mov    %dl,(%ecx)
0x07faf4aa:  incl   0x4(%eax)
0x07faf4ad:  ret    

----------------
IN: 
0x07fb5756:  mov    0x4(%esp),%eax
0x07fb575a:  mov    0x8(%esp),%edx
0x07fb575e:  cmp    %edx,%eax
0x07fb5760:  jb     0x7fb5765

----------------
IN: 
0x07fb5765:  movb   $0x0,(%eax)
0x07fb5768:  sub    %ebx,%eax
0x07fb576a:  add    $0xc,%esp
0x07fb576d:  pop    %ebx
0x07fb576e:  ret    

----------------
IN: 
0x07fb57a1:  mov    %esi,%eax
0x07fb57a3:  call   0x7fb0bc8

----------------
IN: 
0x07fb57a8:  add    $0x14,%esp
0x07fb57ab:  test   %eax,%eax
0x07fb57ad:  je     0x7fb57be

----------------
IN: 
0x07fb57be:  movzwl (%ebx),%esi
0x07fb57c1:  testb  $0x7f,0x18(%ebx)
0x07fb57c5:  jne    0x7fb5930

----------------
IN: 
0x07fb57cb:  mov    $0x30,%edx
0x07fb57d0:  mov    %esi,%eax
0x07fb57d2:  call   0xf00ee

----------------
IN: 
0x07fb57d7:  mov    %eax,%edi
0x07fb57d9:  mov    $0xfffffffe,%ecx
0x07fb57de:  mov    $0x30,%edx
0x07fb57e3:  mov    %esi,%eax
0x07fb57e5:  call   0xf009b

----------------
IN: 
0x07fb57ea:  mov    $0x30,%edx
0x07fb57ef:  mov    %esi,%eax
0x07fb57f1:  call   0xf00ee

----------------
IN: 
0x07fb57f6:  and    $0xfffffffe,%edi
0x07fb57f9:  cmp    %eax,%edi
0x07fb57fb:  je     0x7fb58f1

----------------
IN: 
0x07fb5801:  dec    %eax
0x07fb5802:  cmp    $0xfffffffd,%eax
0x07fb5805:  ja     0x7fb58f1

----------------
IN: 
0x07fb580b:  lea    0x400000(%edi),%eax
0x07fb5811:  cmp    $0x13fffff,%eax
0x07fb5816:  jbe    0x7fb58f1

----------------
IN: 
0x07fb581c:  mov    %edi,%ecx
0x07fb581e:  or     $0x1,%ecx
0x07fb5821:  mov    $0x30,%edx
0x07fb5826:  mov    %esi,%eax
0x07fb5828:  call   0xf009b

----------------
IN: 
0x07fb582d:  mov    %edi,%edx
0x07fb582f:  cmpw   $0xaa55,(%edx)
0x07fb5834:  jne    0x7fb58f1

----------------
IN: 
0x07fb583a:  movzwl 0x18(%edx),%ebp
0x07fb583e:  mov    %ebp,%eax
0x07fb5840:  add    %edx,%ebp
0x07fb5842:  cmpl   $0x52494350,0x0(%ebp)
0x07fb5849:  jne    0x7fb58f1

----------------
IN: 
0x07fb584f:  test   $0x3,%al
0x07fb5851:  je     0x7fb5872

----------------
IN: 
0x07fb5872:  test   %ebp,%ebp
0x07fb5874:  je     0x7fb58f1

----------------
IN: 
0x07fb5876:  mov    0x10(%ebx),%eax
0x07fb5879:  cmp    %ax,0x4(%ebp)
0x07fb587d:  jne    0x7fb588f

----------------
IN: 
0x07fb587f:  mov    0x12(%ebx),%ax
0x07fb5883:  cmp    %ax,0x6(%ebp)
0x07fb5887:  jne    0x7fb588f

----------------
IN: 
0x07fb5889:  cmpb   $0x0,0x14(%ebp)
0x07fb588d:  je     0x7fb58a0

----------------
IN: 
0x07fb58a0:  movzbl 0x2(%edx),%ecx
0x07fb58a4:  mov    %edx,0x10(%esp)
0x07fb58a8:  shl    $0x9,%ecx
0x07fb58ab:  mov    %ecx,%eax
0x07fb58ad:  mov    %ecx,0xc(%esp)
0x07fb58b1:  call   0x7faf991

----------------
IN: 
0x07faf991:  push   %esi
0x07faf992:  push   %ebx
0x07faf993:  mov    0x7fbfe84,%esi
0x07faf999:  lea    0x7ff(%esi,%eax,1),%edx
0x07faf9a0:  mov    %edx,%ebx
0x07faf9a2:  and    $0xfffff800,%ebx
0x07faf9a8:  call   0xf01ad

----------------
IN: 
0x07faf9ad:  cmp    %eax,%ebx
0x07faf9af:  ja     0x7faf9d2

----------------
IN: 
0x07faf9b1:  mov    0xf5f88,%eax
0x07faf9b6:  mov    %ebx,%edx
0x07faf9b8:  cmp    $0xe0000,%ebx
0x07faf9be:  jae    0x7faf9c5

----------------
IN: 
0x07faf9c0:  mov    $0xe0000,%edx
0x07faf9c5:  add    $0x10,%edx
0x07faf9c8:  mov    %edx,0xc(%eax)
0x07faf9cb:  mov    %edx,0x8(%eax)
0x07faf9ce:  mov    %esi,%eax
0x07faf9d0:  jmp    0x7faf9d4

----------------
IN: 
0x07faf9d4:  pop    %ebx
0x07faf9d5:  pop    %esi
0x07faf9d6:  ret    

----------------
IN: 
0x07fb58b6:  mov    %eax,%ebp
0x07fb58b8:  test   %eax,%eax
0x07fb58ba:  mov    0xc(%esp),%ecx
0x07fb58be:  mov    0x10(%esp),%edx
0x07fb58c2:  jne    0x7fb58d5

----------------
IN: 
0x07fb58d5:  call   0x7fb0e24

----------------
IN: 
0x07fb0e24:  push   %ebp
0x07fb0e25:  push   %edi
0x07fb0e26:  push   %esi
0x07fb0e27:  push   %ebx
0x07fb0e28:  mov    %eax,%ebp
0x07fb0e2a:  mov    %edx,%esi
0x07fb0e2c:  mov    %ecx,%ebx
0x07fb0e2e:  call   0xf0b7e

Servicing hardware INT=0x08
----------------
IN: 
0x000ffea5:  pushl  $0xe990
0x000ffeab:  jmp    0xfd4d0

----------------
IN: 
0x000fd4d0:  cli    
0x000fd4d1:  cld    
0x000fd4d2:  push   %ds
0x000fd4d3:  push   %eax
0x000fd4d5:  mov    $0xe000,%eax
0x000fd4db:  mov    %ax,%ds
0x000fd4dd:  mov    0xf6d8,%eax
0x000fd4e1:  sub    $0x28,%eax
0x000fd4e5:  addr32 popl 0x1c(%eax)
0x000fd4ea:  addr32 popw (%eax)
0x000fd4ed:  addr32 mov %edi,0x4(%eax)
0x000fd4f2:  addr32 mov %esi,0x8(%eax)
0x000fd4f7:  addr32 mov %ebp,0xc(%eax)
0x000fd4fc:  addr32 mov %ebx,0x10(%eax)
0x000fd501:  addr32 mov %edx,0x14(%eax)
0x000fd506:  addr32 mov %ecx,0x18(%eax)
0x000fd50b:  addr32 mov %es,0x2(%eax)
0x000fd50f:  pop    %ecx
0x000fd511:  addr32 mov %esp,0x20(%eax)
0x000fd516:  addr32 mov %ss,0x24(%eax)
0x000fd51a:  mov    %ds,%dx
0x000fd51c:  mov    %dx,%ss

----------------
IN: 
0x000fd51e:  mov    %eax,%esp

----------------
IN: 
0x000fd521:  calll  *%ecx

----------------
IN: 
0x000fe990:  push   %ebp
0x000fe992:  push   %edi
0x000fe994:  push   %esi
0x000fe996:  push   %ebx
0x000fe998:  sub    $0x34,%esp
0x000fe99c:  mov    $0x40,%edx
0x000fe9a2:  mov    %dx,%es
0x000fe9a4:  mov    %es:0x6c,%eax
0x000fe9a9:  inc    %eax
0x000fe9ab:  cmp    $0x1800af,%eax
0x000fe9b1:  jbe    0xfe9c4

----------------
IN: 
0x000fe9c4:  mov    $0x40,%edx
0x000fe9ca:  mov    %dx,%es
0x000fe9cc:  mov    %eax,%es:0x6c
0x000fe9d1:  mov    %dx,%es
0x000fe9d3:  mov    %es:0x40,%al
0x000fe9d7:  test   %al,%al
0x000fe9d9:  je     0xfea04

----------------
IN: 
0x000fea04:  mov    %cs:0x6ab8,%edi
0x000fea0a:  test   %edi,%edi
0x000fea0d:  je     0xfeb8f

----------------
IN: 
0x000feb8f:  mov    %cs:0x6ab4,%esi
0x000feb95:  test   %esi,%esi
0x000feb98:  je     0xfec0a

----------------
IN: 
0x000fec0a:  mov    $0x26,%ecx
0x000fec10:  xor    %edx,%edx
0x000fec13:  addr32 lea 0xe(%esp),%eax
0x000fec19:  calll  0xf76e5

----------------
IN: 
0x000f76e5:  test   %ecx,%ecx
0x000f76e8:  je     0xf76f2

----------------
IN: 
0x000f76ea:  dec    %ecx
0x000f76ec:  addr32 mov %dl,(%eax,%ecx,1)
0x000f76f0:  jmp    0xf76e5

----------------
IN: 
0x000f76f2:  retl   

----------------
IN: 
0x000fec1f:  addr32 movw $0x200,0x32(%esp)
0x000fec26:  mov    $0xe981,%edx
0x000fec2c:  movzwl %dx,%edx
0x000fec30:  addr32 lea 0xe(%esp),%eax
0x000fec36:  calll  0xf9176

----------------
IN: 
0x000f9176:  addr32 mov %dx,0x20(%eax)
0x000f917a:  addr32 mov %cs,0x22(%eax)
0x000f917e:  mov    %ss,%dx
0x000f9180:  movzwl %dx,%edx
0x000f9184:  jmp    0xf9135

----------------
IN: 
0x000f9135:  push   %edi
0x000f9137:  push   %esi
0x000f9139:  push   %ebx
0x000f913b:  mov    %eax,%ebx
0x000f913e:  mov    %edx,%esi
0x000f9141:  calll  0xf76c1

----------------
IN: 
0x000f76d3:  mov    %esp,%eax
0x000f76d6:  cmp    $0xf6e0,%eax
0x000f76dc:  seta   %al
0x000f76df:  movzbl %al,%eax
0x000f76e3:  retl   

----------------
IN: 
0x000f9147:  test   %eax,%eax
0x000f914a:  je     0xf9162

----------------
IN: 
0x000f914c:  movzwl %si,%edx
0x000f9150:  mov    $0x9135,%ecx
0x000f9156:  mov    %ebx,%eax
0x000f9159:  pop    %ebx
0x000f915b:  pop    %esi
0x000f915d:  pop    %edi
0x000f915f:  jmp    0xf7824

----------------
IN: 
0x000f7824:  push   %edi
0x000f7826:  push   %esi
0x000f7828:  push   %ebx
0x000f782a:  push   %ebx
0x000f782c:  mov    %eax,%ebx
0x000f782f:  addr32 mov %edx,(%esp)
0x000f7834:  mov    %ecx,%esi
0x000f7837:  calll  0xf76c1

----------------
IN: 
0x000f783d:  test   %eax,%eax
0x000f7840:  addr32 mov (%esp),%edx
0x000f7845:  mov    %ebx,%eax
0x000f7848:  jne    0xf784f

----------------
IN: 
0x000f784f:  mov    %esi,%ecx
0x000f7852:  mov    -0x928,%esi
0x000f7857:  mov    %ss,%bx
0x000f7859:  mov    %esp,-0x928
0x000f785e:  addr32 mov -0x4(%esi),%edi
0x000f7863:  mov    %di,%ss

----------------
IN: 
0x000f7865:  addr32 mov -0x8(%esi),%sp

----------------
IN: 
0x000f7869:  mov    %di,%ds
0x000f786b:  calll  *%ecx

----------------
IN: 
0x000f9162:  mov    %ebx,%eax
0x000f9165:  mov    %esi,%edx
0x000f9168:  calll  0xfd200

----------------
IN: 
0x000fd200:  push   %ebp
0x000fd202:  push   %eax
0x000fd204:  push   %edx
0x000fd206:  mov    %dx,%ds
0x000fd208:  push   %cs
0x000fd209:  push   $0xd242
0x000fd20c:  addr32 pushw 0x24(%eax)
0x000fd210:  addr32 pushl 0x20(%eax)
0x000fd215:  addr32 mov 0x4(%eax),%edi
0x000fd21a:  addr32 mov 0x8(%eax),%esi
0x000fd21f:  addr32 mov 0xc(%eax),%ebp
0x000fd224:  addr32 mov 0x10(%eax),%ebx
0x000fd229:  addr32 mov 0x14(%eax),%edx
0x000fd22e:  addr32 mov 0x18(%eax),%ecx
0x000fd233:  addr32 mov 0x2(%eax),%es
0x000fd237:  addr32 pushl 0x1c(%eax)
0x000fd23c:  addr32 mov (%eax),%ds
0x000fd23f:  pop    %eax
0x000fd241:  iret   

----------------
IN: 
0x000fe981:  int    $0x1c

----------------
IN: 
0x000fff53:  iret   

----------------
IN: 
0x000fe983:  lret   

----------------
IN: 
0x000fd242:  pushf  
0x000fd243:  cli    
0x000fd244:  cld    
0x000fd245:  push   %ds
0x000fd246:  push   %eax
0x000fd248:  addr32 mov 0x8(%esp),%ds
0x000fd24d:  addr32 mov 0xc(%esp),%eax
0x000fd253:  addr32 popl 0x1c(%eax)
0x000fd258:  addr32 popw (%eax)
0x000fd25b:  addr32 mov %edi,0x4(%eax)
0x000fd260:  addr32 mov %esi,0x8(%eax)
0x000fd265:  addr32 mov %ebp,0xc(%eax)
0x000fd26a:  addr32 mov %ebx,0x10(%eax)
0x000fd26f:  addr32 mov %edx,0x14(%eax)
0x000fd274:  addr32 mov %ecx,0x18(%eax)
0x000fd279:  addr32 mov %es,0x2(%eax)
0x000fd27d:  addr32 popw 0x24(%eax)
0x000fd281:  mov    %ss,%cx
0x000fd283:  mov    %cx,%ds
0x000fd285:  pop    %edx
0x000fd287:  pop    %eax
0x000fd289:  pop    %ebp
0x000fd28b:  retl   

----------------
IN: 
0x000f916e:  pop    %ebx
0x000f9170:  pop    %esi
0x000f9172:  pop    %edi
0x000f9174:  retl   

----------------
IN: 
0x000f786e:  mov    %bx,%ds
0x000f7870:  mov    %bx,%ss

----------------
IN: 
0x000f7872:  mov    -0x928,%esp

----------------
IN: 
0x000f7877:  mov    %esi,-0x928
0x000f787c:  pop    %edx
0x000f787e:  pop    %ebx
0x000f7880:  pop    %esi
0x000f7882:  pop    %edi
0x000f7884:  retl   

----------------
IN: 
0x000fec3c:  mov    $0x20,%al
0x000fec3e:  out    %al,$0x20
0x000fec40:  add    $0x34,%esp
0x000fec44:  pop    %ebx
0x000fec46:  pop    %esi
0x000fec48:  pop    %edi
0x000fec4a:  pop    %ebp
0x000fec4c:  retl   

----------------
IN: 
0x000fd524:  mov    %esp,%eax
0x000fd527:  addr32 mov 0x24(%eax),%ss

----------------
IN: 
0x000fd52b:  addr32 mov 0x20(%eax),%esp

----------------
IN: 
0x000fd530:  addr32 mov 0x4(%eax),%edi
0x000fd535:  addr32 mov 0x8(%eax),%esi
0x000fd53a:  addr32 mov 0xc(%eax),%ebp
0x000fd53f:  addr32 mov 0x10(%eax),%ebx
0x000fd544:  addr32 mov 0x14(%eax),%edx
0x000fd549:  addr32 mov 0x18(%eax),%ecx
0x000fd54e:  addr32 mov 0x2(%eax),%es
0x000fd552:  addr32 pushl 0x1c(%eax)
0x000fd557:  addr32 mov (%eax),%ds
0x000fd55a:  pop    %eax
0x000fd55c:  iret   

----------------
IN: 
0x07fb0e33:  cmp    $0x3,%ebx
0x07fb0e36:  jbe    0x7fb0e5b

----------------
IN: 
0x07fb0e38:  mov    %ebx,%ecx
0x07fb0e3a:  cmp    $0x800,%ebx
0x07fb0e40:  jbe    0x7fb0e47

----------------
IN: 
0x07fb0e42:  mov    $0x800,%ecx
0x07fb0e47:  shr    $0x2,%ecx
0x07fb0e4a:  lea    0x0(,%ecx,4),%eax
0x07fb0e51:  sub    %eax,%ebx
0x07fb0e53:  mov    %ebp,%edi
0x07fb0e55:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb0e55:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb0e57:  mov    %edi,%ebp
0x07fb0e59:  jmp    0x7fb0e2e

----------------
IN: 
0x07fb0e2e:  call   0xf0b7e

----------------
IN: 
0x07fb0e47:  shr    $0x2,%ecx
0x07fb0e4a:  lea    0x0(,%ecx,4),%eax
0x07fb0e51:  sub    %eax,%ebx
0x07fb0e53:  mov    %ebp,%edi
0x07fb0e55:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb0e5b:  test   %ebx,%ebx
0x07fb0e5d:  je     0x7fb0e65

----------------
IN: 
0x07fb0e65:  pop    %ebx
0x07fb0e66:  pop    %esi
0x07fb0e67:  pop    %edi
0x07fb0e68:  pop    %ebp
0x07fb0e69:  ret    

----------------
IN: 
0x07fb58da:  mov    %edi,%ecx
0x07fb58dc:  mov    $0x30,%edx
0x07fb58e1:  mov    %esi,%eax
0x07fb58e3:  call   0xf009b

----------------
IN: 
0x07fb58e8:  or     $0xffffffff,%eax
0x07fb58eb:  test   %ebp,%ebp
0x07fb58ed:  jne    0x7fb5901

----------------
IN: 
0x07fb5901:  cmpl   $0x0,(%esp)
0x07fb5905:  je     0x7fb591e

----------------
IN: 
0x07fb591e:  movzwl 0x6(%esp),%edx
0x07fb5923:  mov    0x8(%esp),%ecx
0x07fb5927:  mov    %ebp,%eax
0x07fb5929:  call   0x7fb25e7

----------------
IN: 
0x07fb25e7:  push   %ebp
0x07fb25e8:  push   %edi
0x07fb25e9:  push   %esi
0x07fb25ea:  push   %ebx
0x07fb25eb:  mov    %eax,%esi
0x07fb25ed:  mov    %edx,%edi
0x07fb25ef:  mov    %ecx,%ebp
0x07fb25f1:  call   0xf1e34

----------------
IN: 
0x000f1e34:  xor    %ecx,%ecx
0x000f1e36:  cmpw   $0xaa55,(%eax)
0x000f1e3b:  jne    0xf1e81

----------------
IN: 
0x000f1e3d:  mov    0x2(%eax),%dl
0x000f1e40:  xor    %ecx,%ecx
0x000f1e42:  test   %dl,%dl
0x000f1e44:  je     0xf1e81

----------------
IN: 
0x000f1e46:  push   %esi
0x000f1e47:  push   %ebx
0x000f1e48:  mov    %eax,%esi
0x000f1e4a:  movzbl %dl,%ebx
0x000f1e4d:  shl    $0x9,%ebx
0x000f1e50:  mov    %ebx,%edx
0x000f1e52:  call   0xf069f

----------------
IN: 
0x000f1e57:  mov    $0x1,%ecx
0x000f1e5c:  test   %al,%al
0x000f1e5e:  je     0xf1e84

----------------
IN: 
0x000f1e84:  mov    %ecx,%eax
0x000f1e86:  pop    %ebx
0x000f1e87:  pop    %esi
0x000f1e88:  ret    

----------------
IN: 
0x07fb25f6:  test   %eax,%eax
0x07fb25f8:  je     0x7fb268d

----------------
IN: 
0x07fb25fe:  movzbl 0x2(%esi),%eax
0x07fb2602:  shl    $0x9,%eax
0x07fb2605:  call   0x7faf991

----------------
IN: 
0x07fb260a:  mov    %eax,%ebx
0x07fb260c:  test   %eax,%eax
0x07fb260e:  jne    0x7fb261c

----------------
IN: 
0x07fb261c:  cmp    %esi,%eax
0x07fb261e:  je     0x7fb262e

----------------
IN: 
0x07fb262e:  test   %ebp,%ebp
0x07fb2630:  jne    0x7fb2642

----------------
IN: 
0x07fb2642:  movzwl %di,%ecx
0x07fb2645:  mov    $0x3,%edx
0x07fb264a:  mov    %ebx,%eax
0x07fb264c:  call   0xf1dad

----------------
IN: 
0x000f1dad:  push   %edi
0x000f1dae:  push   %esi
0x000f1daf:  push   %ebx
0x000f1db0:  sub    $0x28,%esp
0x000f1db3:  mov    %edx,%esi
0x000f1db5:  mov    %ecx,%edi
0x000f1db7:  shr    $0x4,%eax
0x000f1dba:  mov    %eax,%ebx
0x000f1dbc:  movzwl %dx,%eax
0x000f1dbf:  push   %eax
0x000f1dc0:  movzwl %bx,%eax
0x000f1dc3:  push   %eax
0x000f1dc4:  push   $0xf3dbf
0x000f1dc9:  call   0xf0cc9

----------------
IN: 
0x000f1dce:  mov    $0x26,%ecx
0x000f1dd3:  xor    %edx,%edx
0x000f1dd5:  lea    0xe(%esp),%eax
0x000f1dd9:  call   0xf0090

----------------
IN: 
0x000f1dde:  movw   $0x200,0x32(%esp)
0x000f1de5:  mov    %di,0x2a(%esp)
0x000f1dea:  movw   $0xffff,0x1e(%esp)
0x000f1df1:  movw   $0xffff,0x22(%esp)
0x000f1df8:  movw   $0xf000,0x10(%esp)
0x000f1dff:  mov    $0xf6af0,%eax
0x000f1e04:  mov    %ax,0x12(%esp)
0x000f1e09:  mov    %si,0x2e(%esp)
0x000f1e0e:  mov    %bx,0x30(%esp)
0x000f1e13:  call   0xf06b2

----------------
IN: 
0x000f06b2:  call   0xeff00

----------------
IN: 
0x000f06b7:  test   %eax,%eax
0x000f06b9:  je     0xf06ec

----------------
IN: 
0x000f06ec:  ret    

----------------
IN: 
0x000f1e18:  mov    $0xf9135,%ecx
0x000f1e1d:  xor    %edx,%edx
0x000f1e1f:  lea    0xe(%esp),%eax
0x000f1e23:  call   0xf0a90

----------------
IN: 
0x000c0003:  jmp    0xc54ee

----------------
IN: 
0x000c54ee:  cli    
0x000c54ef:  cld    
0x000c54f0:  push   %eax
0x000c54f2:  push   %ecx
0x000c54f4:  push   %edx
0x000c54f6:  push   %ebx
0x000c54f8:  push   %ebp
0x000c54fa:  push   %esi
0x000c54fc:  push   %edi
0x000c54fe:  push   %es
0x000c54ff:  push   %ds
0x000c5500:  mov    %ss,%ax
0x000c5502:  mov    %ax,%ds
0x000c5504:  mov    %esp,%ebx
0x000c5507:  movzwl %sp,%esp
0x000c550b:  mov    %esp,%eax
0x000c550e:  push   %ax
0x000c550f:  call   0xc36e9

----------------
IN: 
0x000c36e9:  push   %ebp
0x000c36eb:  mov    %esp,%ebp
0x000c36ee:  push   %edi
0x000c36f0:  push   %esi
0x000c36f2:  push   %ebx
0x000c36f4:  sub    $0x1c,%esp
0x000c36f8:  mov    %eax,%ebx
0x000c36fb:  pushl  $0x94bc
0x000c3701:  pushl  $0x5627
0x000c3707:  push   %ax
0x000c3708:  call   0xc2640

----------------
IN: 
0x000c2640:  push   %ebp
0x000c2642:  mov    %esp,%ebp
0x000c2645:  push   %edi
0x000c2647:  push   %esi
0x000c2649:  push   %ebx
0x000c264b:  sub    $0xc,%esp
0x000c264f:  addr32 mov 0x8(%ebp),%ecx
0x000c2654:  mov    %ebp,%ebx
0x000c2657:  pushf  
0x000c2658:  add    $0xc,%ebx
0x000c265c:  popf   

----------------
IN: 
0x000c265d:  addr32 mov %cs:(%ecx),%al
0x000c2661:  test   %al,%al
0x000c2663:  je     0xc28d7

----------------
IN: 
0x000c2667:  cmp    $0x25,%al
0x000c2669:  je     0xc2673

----------------
IN: 
0x000c266b:  mov    %cs:-0x6b2e,%dx
0x000c2670:  jmp    0xc273d

----------------
IN: 
0x000c273d:  out    %al,(%dx)
0x000c273e:  jmp    0xc276c

----------------
IN: 
0x000c276c:  inc    %ecx
0x000c276e:  jmp    0xc265d

----------------
IN: 
0x000c2673:  mov    %ecx,%esi
0x000c2676:  pushf  
0x000c2677:  add    $0x1,%esi
0x000c267b:  popf   

----------------
IN: 
0x000c267c:  addr32 movb $0x20,-0x11(%ebp)
0x000c2681:  xor    %edi,%edi
0x000c2684:  addr32 mov %cs:(%esi),%al
0x000c2688:  addr32 mov %al,-0x10(%ebp)
0x000c268c:  mov    %al,%dl
0x000c268e:  sub    $0x30,%edx
0x000c2692:  cmp    $0x9,%dl
0x000c2695:  ja     0xc26c4

----------------
IN: 
0x000c26c4:  mov    %esi,%edx
0x000c26c7:  addr32 cmpb $0x6c,-0x10(%ebp)
0x000c26cc:  jne    0xc2771

----------------
IN: 
0x000c2771:  cmp    $0x64,%al
0x000c2773:  jne    0xc26fe

----------------
IN: 
0x000c26fe:  jle    0xc2799

----------------
IN: 
0x000c2702:  cmp    $0x73,%al
0x000c2704:  jne    0xc2725

----------------
IN: 
0x000c2706:  mov    %ebx,%edi
0x000c2709:  pushf  
0x000c270a:  add    $0x4,%edi
0x000c270e:  popf   

----------------
IN: 
0x000c270f:  addr32 mov (%ebx),%ecx
0x000c2713:  addr32 mov %cs:(%ecx),%al
0x000c2717:  test   %al,%al
0x000c2719:  je     0xc2766

----------------
IN: 
0x000c271b:  mov    %cs:-0x6b2e,%dx
0x000c2720:  out    %al,(%dx)
0x000c2721:  inc    %ecx
0x000c2723:  jmp    0xc2713

----------------
IN: 
0x000c2713:  addr32 mov %cs:(%ecx),%al
0x000c2717:  test   %al,%al
0x000c2719:  je     0xc2766

----------------
IN: 
0x000c2766:  mov    %esi,%ecx
0x000c2769:  mov    %edi,%ebx
0x000c276c:  inc    %ecx
0x000c276e:  jmp    0xc265d

----------------
IN: 
0x000c28d7:  add    $0xc,%esp
0x000c28db:  pop    %ebx
0x000c28dd:  pop    %esi
0x000c28df:  pop    %edi
0x000c28e1:  pop    %ebp
0x000c28e3:  ret    $0x2

----------------
IN: 
0x000c370b:  pop    %esi
0x000c370d:  pop    %edi
0x000c370f:  pushl  $0x58cc
0x000c3715:  pushl  $0x5646
0x000c371b:  push   %ax
0x000c371c:  call   0xc2640

----------------
IN: 
0x000c371f:  pop    %eax
0x000c3721:  pop    %edx
0x000c3723:  mov    %ebx,%eax
0x000c3726:  push   %ax
0x000c3727:  call   0xc28e6

----------------
IN: 
0x000c28e6:  push   %ebp
0x000c28e8:  mov    %esp,%ebp
0x000c28eb:  push   %ebx
0x000c28ed:  mov    %eax,%ebx
0x000c28f0:  test   %eax,%eax
0x000c28f3:  jne    0xc2903

----------------
IN: 
0x000c2903:  mov    %ss,%ax
0x000c2905:  movzwl %ax,%eax
0x000c2909:  push   %eax
0x000c290b:  addr32 movzwl 0x2(%ebx),%eax
0x000c2911:  push   %eax
0x000c2913:  addr32 movzwl (%ebx),%eax
0x000c2918:  push   %eax
0x000c291a:  addr32 pushl 0x14(%ebx)
0x000c291f:  addr32 pushl 0x18(%ebx)
0x000c2924:  addr32 pushl 0x10(%ebx)
0x000c2929:  addr32 pushl 0x1c(%ebx)
0x000c292e:  pushl  $0x5566
0x000c2934:  push   %ax
0x000c2935:  call   0xc2640

----------------
IN: 
0x000c2697:  cmp    $0x30,%al
0x000c2699:  jne    0xc26a0

----------------
IN: 
0x000c269b:  test   %edi,%edi
0x000c269e:  je     0xc26b8

----------------
IN: 
0x000c26b8:  addr32 movb $0x30,-0x11(%ebp)
0x000c26bd:  xor    %edi,%edi
0x000c26c0:  inc    %esi
0x000c26c2:  jmp    0xc2684

----------------
IN: 
0x000c2684:  addr32 mov %cs:(%esi),%al
0x000c2688:  addr32 mov %al,-0x10(%ebp)
0x000c268c:  mov    %al,%dl
0x000c268e:  sub    $0x30,%edx
0x000c2692:  cmp    $0x9,%dl
0x000c2695:  ja     0xc26c4

----------------
IN: 
0x000c26a0:  imul   $0xa,%edi,%eax
0x000c26a4:  addr32 movsbl -0x10(%ebp),%edx
0x000c26aa:  mov    %edx,%edi
0x000c26ad:  pushf  
0x000c26ae:  add    %eax,%edi
0x000c26b1:  add    $0xffffffd0,%edi
0x000c26b5:  popf   

----------------
IN: 
0x000c26b6:  jmp    0xc26c0

----------------
IN: 
0x000c26c0:  inc    %esi
0x000c26c2:  jmp    0xc2684

----------------
IN: 
0x000c2725:  jle    0xc2740

----------------
IN: 
0x000c2727:  xor    %edx,%edx
0x000c272a:  cmp    $0x75,%al
0x000c272c:  je     0xc27fc

----------------
IN: 
0x000c2730:  cmp    $0x78,%al
0x000c2732:  je     0xc2810

----------------
IN: 
0x000c2810:  addr32 mov (%ebx),%eax
0x000c2814:  addr32 mov %eax,-0x10(%ebp)
0x000c2819:  test   %dl,%dl
0x000c281b:  je     0xc2879

----------------
IN: 
0x000c2879:  mov    %ebx,%eax
0x000c287c:  pushf  
0x000c287d:  add    $0x4,%eax
0x000c2881:  popf   

----------------
IN: 
0x000c2882:  addr32 mov %eax,-0x18(%ebp)
0x000c2887:  addr32 mov -0x10(%ebp),%eax
0x000c288c:  mov    $0x1,%ecx
0x000c2892:  shr    $0x4,%eax
0x000c2896:  je     0xc289c

----------------
IN: 
0x000c2898:  inc    %ecx
0x000c289a:  jmp    0xc2892

----------------
IN: 
0x000c2892:  shr    $0x4,%eax
0x000c2896:  je     0xc289c

----------------
IN: 
0x000c289c:  sub    %ecx,%edi
0x000c289f:  mov    %edi,%ebx
0x000c28a2:  test   %ebx,%ebx
0x000c28a5:  jle    0xc28b5

----------------
IN: 
0x000c28a7:  mov    %cs:-0x6b2e,%dx
0x000c28ac:  addr32 mov -0x11(%ebp),%al
0x000c28b0:  out    %al,(%dx)
0x000c28b1:  dec    %ebx
0x000c28b3:  jmp    0xc28a2

----------------
IN: 
0x000c28a2:  test   %ebx,%ebx
0x000c28a5:  jle    0xc28b5

----------------
IN: 
0x000c28b5:  mov    %ecx,%edx
0x000c28b8:  addr32 mov -0x10(%ebp),%eax
0x000c28bd:  push   %ax
0x000c28be:  call   0xc0ec4

----------------
IN: 
0x000c0ec4:  push   %ebp
0x000c0ec6:  mov    %esp,%ebp
0x000c0ec9:  push   %ebx
0x000c0ecb:  mov    %eax,%ebx
0x000c0ece:  cmp    $0x4,%edx
0x000c0ed2:  je     0xc0f2a

----------------
IN: 
0x000c0ed4:  jg     0xc0ee4

----------------
IN: 
0x000c0ed6:  cmp    $0x2,%edx
0x000c0eda:  je     0xc0f48

----------------
IN: 
0x000c0f48:  mov    %ebx,%eax
0x000c0f4b:  shr    $0x4,%eax
0x000c0f4f:  and    $0xf,%eax
0x000c0f53:  push   %ax
0x000c0f54:  call   0xc0e9c

----------------
IN: 
0x000c0e9c:  push   %ebp
0x000c0e9e:  mov    %esp,%ebp
0x000c0ea1:  mov    %eax,%edx
0x000c0ea4:  pushf  
0x000c0ea5:  add    $0x57,%eax
0x000c0ea9:  popf   

----------------
IN: 
0x000c0eaa:  cmp    $0x9,%edx
0x000c0eae:  ja     0xc0eb9

----------------
IN: 
0x000c0eb0:  mov    %edx,%eax
0x000c0eb3:  pushf  
0x000c0eb4:  add    $0x30,%eax
0x000c0eb8:  popf   

----------------
IN: 
0x000c0eb9:  mov    %cs:-0x6b2e,%dx
0x000c0ebe:  out    %al,(%dx)
0x000c0ebf:  pop    %ebp
0x000c0ec1:  ret    $0x2

----------------
IN: 
0x000c0f57:  mov    %ebx,%eax
0x000c0f5a:  and    $0xf,%eax
0x000c0f5e:  pop    %ebx
0x000c0f60:  pop    %ebp
0x000c0f62:  jmp    0xc0e9c

----------------
IN: 
0x000c28c1:  mov    %esi,%ecx
0x000c28c4:  addr32 mov -0x18(%ebp),%ebx
0x000c28c9:  jmp    0xc276c

----------------
IN: 
0x000c0f2a:  mov    %ebx,%eax
0x000c0f2d:  shr    $0xc,%eax
0x000c0f31:  and    $0xf,%eax
0x000c0f35:  push   %ax
0x000c0f36:  call   0xc0e9c

----------------
IN: 
0x000c0f39:  mov    %ebx,%eax
0x000c0f3c:  shr    $0x8,%eax
0x000c0f40:  and    $0xf,%eax
0x000c0f44:  push   %ax
0x000c0f45:  call   0xc0e9c

----------------
IN: 
0x000c0edc:  jg     0xc0f39

----------------
IN: 
0x000c0ede:  dec    %edx
0x000c0ee0:  je     0xc0f57

----------------
IN: 
0x000c2938:  add    $0x20,%esp
0x000c293c:  addr32 movzwl 0x24(%ebx),%eax
0x000c2942:  push   %eax
0x000c2944:  addr32 movzwl 0x20(%ebx),%eax
0x000c294a:  push   %eax
0x000c294c:  addr32 movzwl 0x22(%ebx),%eax
0x000c2952:  push   %eax
0x000c2954:  mov    %ebx,%eax
0x000c2957:  pushf  
0x000c2958:  add    $0x26,%eax
0x000c295c:  popf   

----------------
IN: 
0x000c295d:  push   %eax
0x000c295f:  addr32 pushl 0xc(%ebx)
0x000c2964:  addr32 pushl 0x4(%ebx)
0x000c2969:  addr32 pushl 0x8(%ebx)
0x000c296e:  pushl  $0x55a1
0x000c2974:  push   %ax
0x000c2975:  call   0xc2640

----------------
IN: 
0x000c2978:  add    $0x20,%esp
0x000c297c:  addr32 mov -0x4(%ebp),%ebx
0x000c2981:  mov    %ebp,%esp
0x000c2984:  pop    %ebp
0x000c2986:  ret    $0x2

----------------
IN: 
0x000c372a:  mov    %cs:0x8d40,%eax
0x000c372f:  test   %eax,%eax
0x000c3732:  jne    0xc3780

----------------
IN: 
0x000c3734:  addr32 movzwl 0x1c(%ebx),%ebx
0x000c373a:  mov    %ebx,%ecx
0x000c373d:  shl    $0x8,%ecx
0x000c3741:  or     $0x80000000,%ecx
0x000c3748:  mov    $0xcf8,%edx
0x000c374e:  mov    %ecx,%eax
0x000c3751:  out    %eax,(%dx)
0x000c3753:  mov    $0xfc,%dl
0x000c3755:  in     (%dx),%ax
0x000c3756:  mov    %cs:-0x72b4,%dx
0x000c375b:  cmp    %dx,%ax
0x000c375d:  jne    0xc3780

----------------
IN: 
0x000c375f:  mov    $0xcf8,%edx
0x000c3765:  mov    %ecx,%eax
0x000c3768:  out    %eax,(%dx)
0x000c376a:  mov    $0xfe,%dl
0x000c376c:  in     (%dx),%ax
0x000c376d:  mov    %cs:-0x72b2,%dx
0x000c3772:  cmp    %dx,%ax
0x000c3774:  jne    0xc3780

----------------
IN: 
0x000c3776:  mov    %cs,%ax
0x000c3778:  mov    %ax,%es
0x000c377a:  mov    %ebx,%es:-0x72bc
0x000c3780:  mov    $0x3c2,%edx
0x000c3786:  mov    $0xc3,%al
0x000c3788:  out    %al,(%dx)
0x000c3789:  mov    $0xc4,%dl
0x000c378b:  mov    $0x204,%eax
0x000c3791:  out    %ax,(%dx)
0x000c3792:  xor    %ebx,%ebx
0x000c3795:  mov    $0x1ce,%esi
0x000c379b:  mov    %ebx,%eax
0x000c379e:  mov    %esi,%edx
0x000c37a1:  out    %ax,(%dx)
0x000c37a2:  mov    $0x1cf,%ecx
0x000c37a8:  mov    $0xffffb0c0,%eax
0x000c37ae:  mov    %ecx,%edx
0x000c37b1:  out    %ax,(%dx)
0x000c37b2:  mov    %ebx,%eax
0x000c37b5:  mov    %esi,%edx
0x000c37b8:  out    %ax,(%dx)
0x000c37b9:  mov    %ecx,%edx
0x000c37bc:  in     (%dx),%ax
0x000c37bd:  cmp    $0xb0c0,%ax
0x000c37c0:  je     0xc37d1

----------------
IN: 
0x000c37d1:  mov    $0x1ce,%edx
0x000c37d7:  xor    %eax,%eax
0x000c37da:  out    %ax,(%dx)
0x000c37db:  mov    $0xcf,%dl
0x000c37dd:  mov    $0xffffb0c5,%eax
0x000c37e3:  out    %ax,(%dx)
0x000c37e4:  mov    %cs,%ax
0x000c37e6:  mov    %ax,%es
0x000c37e8:  mov    $0x1,%eax
0x000c37ee:  mov    %eax,%es:0x58f8
0x000c37f3:  mov    %cs:0x8d40,%eax
0x000c37f8:  test   %eax,%eax
0x000c37fb:  jne    0xc3a08

----------------
IN: 
0x000c37ff:  mov    %cs:-0x72bc,%ebx
0x000c3805:  mov    $0xe0000000,%edi
0x000c380b:  test   %ebx,%ebx
0x000c380e:  js     0xc3892

----------------
IN: 
0x000c3812:  movzwl %bx,%eax
0x000c3816:  shl    $0x8,%eax
0x000c381a:  or     $0x80000000,%eax
0x000c3820:  addr32 mov %eax,-0x10(%ebp)
0x000c3825:  mov    $0xcf8,%edi
0x000c382b:  mov    %edi,%edx
0x000c382e:  out    %eax,(%dx)
0x000c3830:  mov    $0xcfc,%ecx
0x000c3836:  mov    %ecx,%edx
0x000c3839:  in     (%dx),%ax
0x000c383a:  cmp    $0x15ad,%ax
0x000c383d:  sete   %al
0x000c3840:  movzbl %al,%eax
0x000c3844:  mov    %eax,%esi
0x000c3847:  pushf  
0x000c3848:  add    $0x4,%eax
0x000c384c:  popf   

----------------
IN: 
0x000c384d:  shl    $0x2,%eax
0x000c3851:  addr32 or -0x10(%ebp),%eax
0x000c3856:  mov    %edi,%edx
0x000c3859:  out    %eax,(%dx)
0x000c385b:  mov    %ecx,%edx
0x000c385e:  in     (%dx),%eax
0x000c3860:  and    $0xfffffff0,%eax
0x000c3864:  mov    %eax,%edi
0x000c3867:  push   %esi
0x000c3869:  mov    %ebx,%eax
0x000c386c:  and    $0x7,%eax
0x000c3870:  push   %eax
0x000c3872:  mov    %ebx,%eax
0x000c3875:  shr    $0x3,%ax
0x000c3878:  and    $0x1f,%eax
0x000c387c:  push   %eax
0x000c387e:  movzbl %bh,%ebx
0x000c3882:  push   %ebx
0x000c3884:  pushl  $0x568a
0x000c388a:  push   %ax
0x000c388b:  call   0xc2640

----------------
IN: 
0x000c2775:  addr32 mov (%ebx),%ecx
0x000c2779:  add    $0x4,%ebx
0x000c277d:  test   %ecx,%ecx
0x000c2780:  jns    0xc278d

----------------
IN: 
0x000c278d:  mov    %ecx,%eax
0x000c2790:  push   %ax
0x000c2791:  call   0xc25ef

----------------
IN: 
0x000c25ef:  push   %ebp
0x000c25f1:  mov    %esp,%ebp
0x000c25f4:  push   %ebx
0x000c25f6:  sub    $0xc,%esp
0x000c25fa:  addr32 movb $0x0,-0x5(%ebp)
0x000c25ff:  mov    %ebp,%ecx
0x000c2602:  pushf  
0x000c2603:  add    $0xfffffffa,%ecx
0x000c2607:  popf   

----------------
IN: 
0x000c2608:  mov    $0xa,%ebx
0x000c260e:  xor    %edx,%edx
0x000c2611:  div    %ebx
0x000c2614:  add    $0x30,%edx
0x000c2618:  addr32 mov %dl,(%ecx)
0x000c261b:  test   %eax,%eax
0x000c261e:  je     0xc2624

----------------
IN: 
0x000c2624:  addr32 mov (%ecx),%al
0x000c2627:  test   %al,%al
0x000c2629:  je     0xc2635

----------------
IN: 
0x000c262b:  mov    %cs:-0x6b2e,%dx
0x000c2630:  out    %al,(%dx)
0x000c2631:  inc    %ecx
0x000c2633:  jmp    0xc2624

----------------
IN: 
0x000c2635:  add    $0xc,%esp
0x000c2639:  pop    %ebx
0x000c263b:  pop    %ebp
0x000c263d:  ret    $0x2

----------------
IN: 
0x000c2794:  mov    %esi,%ecx
0x000c2797:  jmp    0xc276c

----------------
IN: 
0x000c388e:  add    $0x14,%esp
0x000c3892:  mov    %cs,%cx
0x000c3894:  mov    %cx,%es
0x000c3896:  mov    %edi,%es:0x6720
0x000c389c:  mov    $0x1ce,%esi
0x000c38a2:  mov    $0xa,%eax
0x000c38a8:  mov    %esi,%edx
0x000c38ab:  out    %ax,(%dx)
0x000c38ac:  mov    $0x1cf,%ebx
0x000c38b2:  mov    %ebx,%edx
0x000c38b5:  in     (%dx),%ax
0x000c38b6:  shl    $0x10,%eax
0x000c38ba:  addr32 mov %eax,-0x10(%ebp)
0x000c38bf:  mov    %cx,%es
0x000c38c1:  mov    %eax,%es:0x6728
0x000c38c6:  mov    %cx,%es
0x000c38c8:  mov    $0x40,%eax
0x000c38ce:  mov    %ax,%es:0x671c
0x000c38d2:  mov    %cx,%es
0x000c38d4:  mov    $0x1,%eax
0x000c38da:  mov    %eax,%es:0x6724
0x000c38df:  addr32 mov -0x10(%ebp),%eax
0x000c38e4:  shr    $0x14,%eax
0x000c38e8:  push   %eax
0x000c38ea:  push   %edi
0x000c38ec:  pushl  $0x56af
0x000c38f2:  push   %ax
0x000c38f3:  call   0xc2640

----------------
IN: 
0x000c0ee4:  cmp    $0x6,%edx
0x000c0ee8:  je     0xc0f0c

----------------
IN: 
0x000c0eea:  jl     0xc0f1b

----------------
IN: 
0x000c0eec:  cmp    $0x7,%edx
0x000c0ef0:  je     0xc0efd

----------------
IN: 
0x000c0ef2:  mov    %ebx,%eax
0x000c0ef5:  shr    $0x1c,%eax
0x000c0ef9:  push   %ax
0x000c0efa:  call   0xc0e9c

----------------
IN: 
0x000c0efd:  mov    %ebx,%eax
0x000c0f00:  shr    $0x18,%eax
0x000c0f04:  and    $0xf,%eax
0x000c0f08:  push   %ax
0x000c0f09:  call   0xc0e9c

----------------
IN: 
0x000c0f0c:  mov    %ebx,%eax
0x000c0f0f:  shr    $0x14,%eax
0x000c0f13:  and    $0xf,%eax
0x000c0f17:  push   %ax
0x000c0f18:  call   0xc0e9c

----------------
IN: 
0x000c0f1b:  mov    %ebx,%eax
0x000c0f1e:  shr    $0x10,%eax
0x000c0f22:  and    $0xf,%eax
0x000c0f26:  push   %ax
0x000c0f27:  call   0xc0e9c

----------------
IN: 
0x000c2620:  dec    %ecx
0x000c2622:  jmp    0xc260e

----------------
IN: 
0x000c260e:  xor    %edx,%edx
0x000c2611:  div    %ebx
0x000c2614:  add    $0x30,%edx
0x000c2618:  addr32 mov %dl,(%ecx)
0x000c261b:  test   %eax,%eax
0x000c261e:  je     0xc2624

----------------
IN: 
0x000c38f6:  add    $0xc,%esp
0x000c38fa:  mov    $0x4,%ecx
0x000c3900:  mov    %ecx,%eax
0x000c3903:  mov    %esi,%edx
0x000c3906:  out    %ax,(%dx)
0x000c3907:  mov    %ebx,%edx
0x000c390a:  in     (%dx),%ax
0x000c390b:  mov    %eax,%edi
0x000c390e:  mov    %ecx,%eax
0x000c3911:  mov    %esi,%edx
0x000c3914:  out    %ax,(%dx)
0x000c3915:  mov    %edi,%eax
0x000c3918:  or     $0x2,%eax
0x000c391c:  mov    %ebx,%edx
0x000c391f:  out    %ax,(%dx)
0x000c3920:  mov    $0x1,%eax
0x000c3926:  mov    %esi,%edx
0x000c3929:  out    %ax,(%dx)
0x000c392a:  mov    %ebx,%edx
0x000c392d:  in     (%dx),%ax
0x000c392e:  addr32 mov %ax,-0x18(%ebp)
0x000c3932:  mov    $0x3,%eax
0x000c3938:  mov    %esi,%edx
0x000c393b:  out    %ax,(%dx)
0x000c393c:  mov    %ebx,%edx
0x000c393f:  in     (%dx),%ax
0x000c3940:  addr32 mov %ax,-0x1c(%ebp)
0x000c3944:  mov    %ecx,%eax
0x000c3947:  mov    %esi,%edx
0x000c394a:  out    %ax,(%dx)
0x000c394b:  mov    %edi,%eax
0x000c394e:  mov    %ebx,%edx
0x000c3951:  out    %ax,(%dx)
0x000c3952:  mov    $0x58fc,%esi
0x000c3958:  addr32 mov %cs:0x4(%esi),%bx
0x000c395d:  addr32 mov %cs:0x6(%esi),%ax
0x000c3962:  addr32 mov %ax,-0x20(%ebp)
0x000c3966:  addr32 mov %cs:0x8(%esi),%al
0x000c396b:  addr32 mov %al,-0x21(%ebp)
0x000c396f:  mov    %esi,%edi
0x000c3972:  pushf  
0x000c3973:  add    $0x2,%edi
0x000c3977:  popf   

----------------
IN: 
0x000c3978:  mov    %edi,%eax
0x000c397b:  push   %ax
0x000c397c:  call   0xc0f65

----------------
IN: 
0x000c0f65:  push   %ebp
0x000c0f67:  mov    %esp,%ebp
0x000c0f6a:  addr32 mov %cs:(%eax),%cl
0x000c0f6e:  mov    $0x10,%edx
0x000c0f74:  test   %cl,%cl
0x000c0f76:  je     0xc0f99

----------------
IN: 
0x000c0f78:  mov    $0x1,%edx
0x000c0f7e:  cmp    $0x3,%cl
0x000c0f81:  je     0xc0f99

----------------
IN: 
0x000c0f83:  addr32 mov %cs:0x6(%eax),%dl
0x000c0f88:  cmp    $0x8,%dl
0x000c0f8b:  movzbl %dl,%edx
0x000c0f8f:  jbe    0xc0f99

----------------
IN: 
0x000c0f99:  mov    %edx,%eax
0x000c0f9c:  pop    %ebp
0x000c0f9e:  ret    $0x2

----------------
IN: 
0x000c397f:  addr32 mov %eax,-0x14(%ebp)
0x000c3984:  mov    %edi,%eax
0x000c3987:  push   %ax
0x000c3988:  call   0xc094b

----------------
IN: 
0x000c094b:  push   %ebp
0x000c094d:  mov    %esp,%ebp
0x000c0950:  addr32 mov %cs:(%eax),%dl
0x000c0954:  cmp    $0x1,%dl
0x000c0957:  je     0xc0970

----------------
IN: 
0x000c0959:  jb     0xc0986

----------------
IN: 
0x000c095b:  xor    %eax,%eax
0x000c095e:  cmp    $0x3,%dl
0x000c0961:  sete   %al
0x000c0964:  pushf  
0x000c0965:  imul   $0x3,%eax,%eax
0x000c0969:  add    $0x1,%eax
0x000c096d:  popf   

----------------
IN: 
0x000c096e:  jmp    0xc098c

----------------
IN: 
0x000c098c:  pop    %ebp
0x000c098e:  ret    $0x2

----------------
IN: 
0x000c398b:  mov    %eax,%ecx
0x000c398e:  addr32 cmp -0x18(%ebp),%bx
0x000c3992:  ja     0xc39d5

----------------
IN: 
0x000c3994:  addr32 movzwl -0x20(%ebp),%eax
0x000c399a:  addr32 mov %eax,-0x20(%ebp)
0x000c399f:  movzwl %bx,%eax
0x000c39a3:  addr32 imul -0x14(%ebp),%eax
0x000c39a9:  add    $0x7,%eax
0x000c39ad:  mov    $0x8,%edi
0x000c39b3:  cltd   
0x000c39b5:  idiv   %edi
0x000c39b8:  addr32 imul -0x20(%ebp),%eax
0x000c39be:  imul   %eax,%ecx
0x000c39c2:  addr32 cmp -0x10(%ebp),%ecx
0x000c39c7:  ja     0xc39d5

----------------
IN: 
0x000c39c9:  addr32 movzbl -0x21(%ebp),%ebx
0x000c39cf:  addr32 cmp -0x1c(%ebp),%bx
0x000c39d3:  jbe    0xc39f9

----------------
IN: 
0x000c39f9:  add    $0xe,%esi
0x000c39fd:  cmp    $0x5cd0,%esi
0x000c3a04:  jb     0xc3958

----------------
IN: 
0x000c3958:  addr32 mov %cs:0x4(%esi),%bx
0x000c395d:  addr32 mov %cs:0x6(%esi),%ax
0x000c3962:  addr32 mov %ax,-0x20(%ebp)
0x000c3966:  addr32 mov %cs:0x8(%esi),%al
0x000c396b:  addr32 mov %al,-0x21(%ebp)
0x000c396f:  mov    %esi,%edi
0x000c3972:  pushf  
0x000c3973:  add    $0x2,%edi
0x000c3977:  popf   

----------------
IN: 
0x000c0f91:  add    $0x7,%edx
0x000c0f95:  and    $0xfffffff8,%edx
0x000c0f99:  mov    %edx,%eax
0x000c0f9c:  pop    %ebp
0x000c0f9e:  ret    $0x2

----------------
IN: 
0x000c3a08:  mov    %cs:0x8d40,%eax
0x000c3a0d:  test   %eax,%eax
0x000c3a10:  jne    0xc3d05

----------------
IN: 
0x000c3a14:  mov    $0x40,%al
0x000c3a16:  mov    %ax,%es
0x000c3a18:  mov    %es:0x10,%dx
0x000c3a1d:  mov    %ax,%es
0x000c3a1f:  and    $0xffffffcf,%edx
0x000c3a23:  or     $0x20,%edx
0x000c3a27:  mov    %dx,%es:0x10
0x000c3a2c:  mov    %ax,%es
0x000c3a2e:  mov    $0x51,%dl
0x000c3a30:  mov    %dl,%es:0x89
0x000c3a35:  mov    %ax,%es
0x000c3a37:  mov    $0x8,%dl
0x000c3a39:  mov    %dl,%es:0x8a
0x000c3a3e:  mov    %cs,%dx
0x000c3a40:  mov    %edx,%ecx
0x000c3a43:  shl    $0x10,%ecx
0x000c3a47:  mov    $0x94a0,%edx
0x000c3a4d:  movzwl %dx,%edx
0x000c3a51:  or     %ecx,%edx
0x000c3a54:  mov    %ax,%es
0x000c3a56:  mov    %edx,%es:0xa8
0x000c3a5c:  mov    %ax,%es
0x000c3a5e:  xor    %edx,%edx
0x000c3a61:  mov    %dl,%es:0x65
0x000c3a66:  mov    %ax,%es
0x000c3a68:  mov    %dl,%es:0x66
0x000c3a6d:  mov    %cs,%cx
0x000c3a6f:  mov    %ecx,%edx
0x000c3a72:  shl    $0x10,%edx
0x000c3a76:  mov    $0x8d60,%eax
0x000c3a7c:  movzwl %ax,%eax
0x000c3a80:  or     %edx,%eax
0x000c3a83:  mov    %cx,%es
0x000c3a85:  mov    %eax,%es:0x94a0
0x000c3a8a:  mov    $0x8d60,%ebx
0x000c3a90:  addr32 movl $0x0,-0x18(%ebp)
0x000c3a99:  addr32 cmpl $0x1d,-0x18(%ebp)
0x000c3a9f:  je     0xc3c6e

----------------
IN: 
0x000c3aa3:  addr32 mov -0x18(%ebp),%eax
0x000c3aa8:  addr32 mov %cs:0x58d8(%eax),%dl
0x000c3ab0:  movzbl %dl,%edx
0x000c3ab4:  test   %edx,%edx
0x000c3ab7:  je     0xc3c62

----------------
IN: 
0x000c3c62:  addr32 incl -0x18(%ebp)
0x000c3c67:  add    $0x40,%ebx
0x000c3c6b:  jmp    0xc3a99

----------------
IN: 
0x000c3a99:  addr32 cmpl $0x1d,-0x18(%ebp)
0x000c3a9f:  je     0xc3c6e

----------------
IN: 
0x000c3abb:  mov    $0x5cd0,%ecx
0x000c3ac1:  xor    %eax,%eax
0x000c3ac4:  addr32 mov %cs:(%ecx),%si
0x000c3ac8:  add    $0x2c,%ecx
0x000c3acc:  movzwl %si,%esi
0x000c3ad0:  cmp    %edx,%esi
0x000c3ad3:  jne    0xc3b4a

----------------
IN: 
0x000c3b4a:  inc    %eax
0x000c3b4c:  cmp    $0x10,%eax
0x000c3b50:  jne    0xc3ac4

----------------
IN: 
0x000c3ac4:  addr32 mov %cs:(%ecx),%si
0x000c3ac8:  add    $0x2c,%ecx
0x000c3acc:  movzwl %si,%esi
0x000c3ad0:  cmp    %edx,%esi
0x000c3ad3:  jne    0xc3b4a

----------------
IN: 
0x000c3ad5:  imul   $0x2c,%eax,%eax
0x000c3ad9:  mov    %eax,%edi
0x000c3adc:  pushf  
0x000c3add:  add    $0x5cd2,%edi
0x000c3ae4:  popf   

----------------
IN: 
0x000c3ae5:  addr32 mov %edi,-0x10(%ebp)
0x000c3aea:  addr32 mov %cs:0x5cd4(%eax),%cx
0x000c3af2:  movzwl %cx,%edi
0x000c3af6:  addr32 mov %edi,-0x1c(%ebp)
0x000c3afb:  addr32 mov %cs:0x5cd6(%eax),%di
0x000c3b03:  addr32 mov %di,-0x14(%ebp)
0x000c3b07:  movzwl %di,%edi
0x000c3b0b:  addr32 mov %cs:0x5cd2(%eax),%dl
0x000c3b13:  addr32 mov %dl,-0x20(%ebp)
0x000c3b17:  addr32 mov %cs:0x5cda(%eax),%dl
0x000c3b1f:  addr32 mov %dl,-0x21(%ebp)
0x000c3b23:  movzbl %dl,%esi
0x000c3b27:  addr32 mov %esi,-0x28(%ebp)
0x000c3b2c:  addr32 cmpb $0x0,-0x20(%ebp)
0x000c3b31:  jne    0xc3b57

----------------
IN: 
0x000c3b57:  addr32 mov %cs:0x5cd9(%eax),%cl
0x000c3b5f:  mov    %cs,%si
0x000c3b61:  mov    %si,%es
0x000c3b63:  movzbl %cl,%ecx
0x000c3b67:  addr32 mov -0x1c(%ebp),%eax
0x000c3b6c:  cltd   
0x000c3b6e:  idiv   %ecx
0x000c3b71:  addr32 mov %al,%es:(%ebx)
0x000c3b75:  mov    %si,%es
0x000c3b77:  mov    %edi,%eax
0x000c3b7a:  cltd   
0x000c3b7c:  addr32 idivl -0x28(%ebp)
0x000c3b81:  dec    %eax
0x000c3b83:  addr32 mov %al,%es:0x1(%ebx)
0x000c3b88:  addr32 mov %cs,-0x14(%ebp)
0x000c3b8c:  addr32 mov -0x14(%ebp),%es
0x000c3b90:  addr32 mov -0x21(%ebp),%al
0x000c3b94:  addr32 mov %al,%es:0x2(%ebx)
0x000c3b99:  addr32 movzbl -0x20(%ebp),%eax
0x000c3b9f:  mov    %edi,%ecx
0x000c3ba2:  addr32 mov -0x1c(%ebp),%edx
0x000c3ba7:  push   %ax
0x000c3ba8:  call   0xc0022

----------------
IN: 
0x000c0022:  push   %ebp
0x000c0024:  mov    %esp,%ebp
0x000c0027:  push   %ebx
0x000c0029:  test   %al,%al
0x000c002b:  je     0xc0059

----------------
IN: 
0x000c002d:  mov    $0x4000,%ebx
0x000c0033:  dec    %al
0x000c0035:  je     0xc006f

----------------
IN: 
0x000c006f:  mov    %ebx,%eax
0x000c0072:  pop    %ebx
0x000c0074:  pop    %ebp
0x000c0076:  ret    $0x2

----------------
IN: 
0x000c3bab:  addr32 mov -0x14(%ebp),%es
0x000c3baf:  addr32 mov %ax,%es:0x3(%ebx)
0x000c3bb4:  addr32 mov -0x10(%ebp),%eax
0x000c3bb9:  addr32 mov %cs:0x16(%eax),%esi
0x000c3bbf:  addr32 mov -0x14(%ebp),%es
0x000c3bc3:  mov    %ebx,%edi
0x000c3bc6:  pushf  
0x000c3bc7:  add    $0x5,%edi
0x000c3bcb:  popf   

----------------
IN: 
0x000c3bcc:  mov    $0x4,%ecx
0x000c3bd2:  addr32 mov -0x14(%ebp),%edx
0x000c3bd7:  mov    %ds,%ax
0x000c3bd9:  mov    %dx,%ds
0x000c3bdb:  rep movsb %ds:(%si),%es:(%di)

----------------
IN: 
0x000c3bdb:  rep movsb %ds:(%si),%es:(%di)

----------------
IN: 
0x000c3bdd:  mov    %ax,%ds
0x000c3bdf:  addr32 mov -0x10(%ebp),%eax
0x000c3be4:  addr32 mov %cs:0x1a(%eax),%al
0x000c3be9:  mov    %cs,%dx
0x000c3beb:  mov    %dx,%es
0x000c3bed:  addr32 mov %al,%es:0x9(%ebx)
0x000c3bf2:  addr32 mov -0x10(%ebp),%eax
0x000c3bf7:  addr32 mov %cs:0x1e(%eax),%esi
0x000c3bfd:  mov    %dx,%es
0x000c3bff:  mov    %ebx,%edi
0x000c3c02:  pushf  
0x000c3c03:  add    $0xa,%edi
0x000c3c07:  popf   

----------------
IN: 
0x000c3c08:  mov    $0x19,%ecx
0x000c3c0e:  mov    %ds,%ax
0x000c3c10:  mov    %dx,%ds
0x000c3c12:  rep movsb %ds:(%si),%es:(%di)

----------------
IN: 
0x000c3c12:  rep movsb %ds:(%si),%es:(%di)

----------------
IN: 
0x000c3c14:  mov    %ax,%ds
0x000c3c16:  addr32 mov -0x10(%ebp),%eax
0x000c3c1b:  addr32 mov %cs:0x22(%eax),%esi
0x000c3c21:  mov    %cs,%dx
0x000c3c23:  mov    %dx,%es
0x000c3c25:  mov    %ebx,%edi
0x000c3c28:  pushf  
0x000c3c29:  add    $0x23,%edi
0x000c3c2d:  popf   

----------------
IN: 
0x000c3c2e:  mov    $0x14,%ecx
0x000c3c34:  mov    %ds,%ax
0x000c3c36:  mov    %dx,%ds
0x000c3c38:  rep movsb %ds:(%si),%es:(%di)

----------------
IN: 
0x000c3c38:  rep movsb %ds:(%si),%es:(%di)

----------------
IN: 
0x000c3c3a:  mov    %ax,%ds
0x000c3c3c:  addr32 mov -0x10(%ebp),%eax
0x000c3c41:  addr32 mov %cs:0x26(%eax),%esi
0x000c3c47:  mov    %cs,%dx
0x000c3c49:  mov    %dx,%es
0x000c3c4b:  mov    %ebx,%edi
0x000c3c4e:  pushf  
0x000c3c4f:  add    $0x37,%edi
0x000c3c53:  popf   

----------------
IN: 
0x000c3c54:  mov    $0x9,%ecx
0x000c3c5a:  mov    %ds,%ax
0x000c3c5c:  mov    %dx,%ds
0x000c3c5e:  rep movsb %ds:(%si),%es:(%di)

----------------
IN: 
0x000c3c5e:  rep movsb %ds:(%si),%es:(%di)

----------------
IN: 
0x000c3c60:  mov    %ax,%ds
0x000c3c62:  addr32 incl -0x18(%ebp)
0x000c3c67:  add    $0x40,%ebx
0x000c3c6b:  jmp    0xc3a99

----------------
IN: 
0x000c3b33:  mov    %cs,%ax
0x000c3b35:  mov    %ax,%es
0x000c3b37:  addr32 mov %cl,%es:(%ebx)
0x000c3b3b:  mov    %ax,%es
0x000c3b3d:  addr32 mov -0x14(%ebp),%dl
0x000c3b41:  dec    %edx
0x000c3b43:  addr32 mov %dl,%es:0x1(%ebx)
0x000c3b48:  jmp    0xc3b88

----------------
IN: 
0x000c3b88:  addr32 mov %cs,-0x14(%ebp)
0x000c3b8c:  addr32 mov -0x14(%ebp),%es
0x000c3b90:  addr32 mov -0x21(%ebp),%al
0x000c3b94:  addr32 mov %al,%es:0x2(%ebx)
0x000c3b99:  addr32 movzbl -0x20(%ebp),%eax
0x000c3b9f:  mov    %edi,%ecx
0x000c3ba2:  addr32 mov -0x1c(%ebp),%edx
0x000c3ba7:  push   %ax
0x000c3ba8:  call   0xc0022

----------------
IN: 
0x000c0059:  shl    %ecx
0x000c005c:  imul   %dx,%cx
0x000c005f:  mov    %ecx,%ebx
0x000c0062:  pushf  
0x000c0063:  add    $0x7ff,%ebx
0x000c006a:  popf   

----------------
IN: 
0x000c006b:  and    $0xf800,%bx
0x000c006f:  mov    %ebx,%eax
0x000c0072:  pop    %ebx
0x000c0074:  pop    %ebp
0x000c0076:  ret    $0x2

----------------
IN: 
0x000c0037:  movzwl %dx,%edx
0x000c003b:  movzwl %cx,%ecx
0x000c003f:  imul   %edx,%ecx
0x000c0043:  sar    $0x3,%ecx
0x000c0047:  mov    %ecx,%ebx
0x000c004a:  pushf  
0x000c004b:  add    $0x1fff,%ebx
0x000c0052:  popf   

----------------
IN: 
0x000c0053:  and    $0xe000,%bx
0x000c0057:  jmp    0xc006f

----------------
IN: 
0x000c3c6e:  xor    %edx,%edx
0x000c3c71:  xor    %ecx,%ecx
0x000c3c74:  mov    $0x1,%eax
0x000c3c7a:  imul   $0x2c,%ecx,%ebx
0x000c3c7e:  addr32 cmpw $0x13,0x5cd0(%ebx)
0x000c3c86:  ja     0xc3c91

----------------
IN: 
0x000c3c88:  mov    %eax,%ebx
0x000c3c8b:  shl    %cl,%ebx
0x000c3c8e:  or     %ebx,%edx
0x000c3c91:  inc    %ecx
0x000c3c93:  cmp    $0x10,%ecx
0x000c3c97:  jne    0xc3c7a

----------------
IN: 
0x000c3c7a:  imul   $0x2c,%ecx,%ebx
0x000c3c7e:  addr32 cmpw $0x13,0x5cd0(%ebx)
0x000c3c86:  ja     0xc3c91

----------------
IN: 
0x000c3c99:  mov    %cs,%ax
0x000c3c9b:  mov    %ax,%es
0x000c3c9d:  mov    %edx,%es:-0x72d0
0x000c3ca3:  shl    $0x10,%eax
0x000c3ca7:  mov    $0x5526,%edx
0x000c3cad:  movzwl %dx,%edx
0x000c3cb1:  or     %edx,%eax
0x000c3cb4:  xor    %edx,%edx
0x000c3cb7:  mov    %dx,%es
0x000c3cb9:  mov    %eax,%es:0x40
0x000c3cbe:  mov    %cs,%cx
0x000c3cc0:  mov    %cx,%es
0x000c3cc2:  mov    $0x1,%eax
0x000c3cc8:  mov    %eax,%es:0x8d40
0x000c3ccd:  mov    %cx,%es
0x000c3ccf:  xor    %eax,%eax
0x000c3cd2:  mov    %al,%es:0x6
0x000c3cd6:  mov    %cs:0x2,%al
0x000c3cda:  movzbl %al,%edx
0x000c3cde:  shl    $0x9,%edx
0x000c3ce2:  mov    %cx,%es
0x000c3ce4:  xor    %eax,%eax
0x000c3ce7:  xor    %ecx,%ecx
0x000c3cea:  cmp    %edx,%ecx
0x000c3ced:  je     0xc3cfa

----------------
IN: 
0x000c3cef:  addr32 mov %es:(%ecx),%bl
0x000c3cf3:  add    %ebx,%eax
0x000c3cf6:  inc    %ecx
0x000c3cf8:  jmp    0xc3cea

----------------
IN: 
0x000c3cea:  cmp    %edx,%ecx
0x000c3ced:  je     0xc3cfa

----------------
IN: 
0x000c3cfa:  mov    %cs,%dx
0x000c3cfc:  mov    %dx,%es
0x000c3cfe:  neg    %eax
0x000c3d01:  mov    %al,%es:0x6
0x000c3d05:  lea    -0xc(%bp),%sp
0x000c3d08:  pop    %ebx
0x000c3d0a:  pop    %esi
0x000c3d0c:  pop    %edi
0x000c3d0e:  pop    %ebp
0x000c3d10:  ret    $0x2

----------------
IN: 
0x000c5512:  mov    %ebx,%esp
0x000c5515:  pop    %ds
0x000c5516:  pop    %es
0x000c5517:  pop    %edi
0x000c5519:  pop    %esi
0x000c551b:  pop    %ebp
0x000c551d:  pop    %ebx
0x000c551f:  pop    %edx
0x000c5521:  pop    %ecx
0x000c5523:  pop    %eax
0x000c5525:  lret   

----------------
IN: 
0x000fd198:  mov    $0x10,%eax
0x000fd19d:  mov    %eax,%ds

----------------
IN: 
0x000fd19f:  mov    %eax,%es

----------------
IN: 
0x000f1e28:  call   0xf0bab

----------------
IN: 
0x000f0bab:  call   0xeff00

----------------
IN: 
0x000f0bb0:  test   %eax,%eax
0x000f0bb2:  jne    0xf0bb9

----------------
IN: 
0x000f0bb4:  jmp    0xf0b7e

Servicing hardware INT=0x08
----------------
IN: 
0x000f1e2d:  add    $0x34,%esp
0x000f1e30:  pop    %ebx
0x000f1e31:  pop    %esi
0x000f1e32:  pop    %edi
0x000f1e33:  ret    

----------------
IN: 
0x07fb2651:  movzbl 0x2(%ebx),%ebx
0x07fb2655:  shl    $0x9,%ebx
0x07fb2658:  mov    %ebx,%eax
0x07fb265a:  call   0x7faf991

----------------
IN: 
0x07fb265f:  test   %eax,%eax
0x07fb2661:  jne    0x7fb2673

----------------
IN: 
0x07fb2673:  mov    0x7fbfe84,%eax
0x07fb2678:  lea    0x7ff(%ebx,%eax,1),%eax
0x07fb267f:  and    $0xfffff800,%eax
0x07fb2684:  mov    %eax,0x7fbfe84
0x07fb2689:  xor    %eax,%eax
0x07fb268b:  jmp    0x7fb2690

----------------
IN: 
0x07fb2690:  pop    %ebx
0x07fb2691:  pop    %esi
0x07fb2692:  pop    %edi
0x07fb2693:  pop    %ebp
0x07fb2694:  ret    

----------------
IN: 
0x07fb592e:  jmp    0x7fb5933

----------------
IN: 
0x07fb5933:  add    $0x28,%esp
0x07fb5936:  pop    %ebx
0x07fb5937:  pop    %esi
0x07fb5938:  pop    %edi
0x07fb5939:  pop    %ebp
0x07fb593a:  ret    

----------------
IN: 
0x07fbbccd:  xor    %ecx,%ecx
0x07fbbccf:  mov    $0x1,%edx
0x07fbbcd4:  mov    $0xf56dd,%eax
0x07fbbcd9:  call   0x7fb2695

----------------
IN: 
0x07fb2695:  push   %ebp
0x07fb2696:  push   %edi
0x07fb2697:  push   %esi
0x07fb2698:  push   %ebx
0x07fb2699:  sub    $0x8,%esp
0x07fb269c:  mov    %eax,(%esp)
0x07fb269f:  mov    %edx,0x4(%esp)
0x07fb26a3:  mov    %ecx,%esi
0x07fb26a5:  xor    %ebx,%ebx
0x07fb26a7:  mov    %ebx,%edx
0x07fb26a9:  mov    (%esp),%eax
0x07fb26ac:  call   0x7fafa28

----------------
IN: 
0x07fafa28:  push   %ebp
0x07fafa29:  push   %edi
0x07fafa2a:  push   %esi
0x07fafa2b:  push   %ebx
0x07fafa2c:  mov    %eax,%esi
0x07fafa2e:  mov    %edx,%edi
0x07fafa30:  call   0x7faf4ae

----------------
IN: 
0x07fafa35:  mov    %eax,%ebp
0x07fafa37:  mov    0x7fbfe80,%ebx
0x07fafa3d:  test   %edi,%edi
0x07fafa3f:  je     0x7fafa57

----------------
IN: 
0x07fafa57:  test   %ebx,%ebx
0x07fafa59:  jne    0x7fafa45

----------------
IN: 
0x07fafa45:  lea    0x4(%ebx),%edx
0x07fafa48:  mov    %ebp,%ecx
0x07fafa4a:  mov    %esi,%eax
0x07fafa4c:  call   0x7faf4bd

----------------
IN: 
0x07fafa51:  test   %eax,%eax
0x07fafa53:  je     0x7fafa5f

----------------
IN: 
0x07fafa55:  mov    (%ebx),%ebx
0x07fafa57:  test   %ebx,%ebx
0x07fafa59:  jne    0x7fafa45

----------------
IN: 
0x07fafa5b:  xor    %eax,%eax
0x07fafa5d:  jmp    0x7fafa61

----------------
IN: 
0x07fafa61:  pop    %ebx
0x07fafa62:  pop    %esi
0x07fafa63:  pop    %edi
0x07fafa64:  pop    %ebp
0x07fafa65:  ret    

----------------
IN: 
0x07fb26b1:  mov    %eax,%ebx
0x07fb26b3:  test   %eax,%eax
0x07fb26b5:  je     0x7fb26e3

----------------
IN: 
0x07fb26e3:  add    $0x8,%esp
0x07fb26e6:  pop    %ebx
0x07fb26e7:  pop    %esi
0x07fb26e8:  pop    %edi
0x07fb26e9:  pop    %ebp
0x07fb26ea:  ret    

----------------
IN: 
0x07fbbcde:  xor    %eax,%eax
0x07fbbce0:  call   0x7faf991

----------------
IN: 
0x07fbbce5:  cmpl   $0xc0000,0x7fbfe84
0x07fbbcef:  je     0x7fbbd00

----------------
IN: 
0x07fbbcf1:  movl   $0xc0000,0xf5f78
0x07fbbcfb:  call   0x7fb5624

----------------
IN: 
0x07fb5624:  push   %edi
0x07fb5625:  push   %ebx
0x07fb5626:  sub    $0x38,%esp
0x07fb5629:  push   $0xf474e
0x07fb562e:  call   0xf0cc9

----------------
IN: 
0x07fb5633:  mov    $0x26,%ecx
0x07fb5638:  xor    %edx,%edx
0x07fb563a:  lea    0x16(%esp),%eax
0x07fb563e:  call   0xf0090

----------------
IN: 
0x07fb5643:  movw   $0x3,0x32(%esp)
0x07fb564a:  lea    0x16(%esp),%eax
0x07fb564e:  call   0x7fb0f02

----------------
IN: 
0x07fb0f02:  push   %edx
0x07fb0f03:  movw   $0x200,0x24(%eax)
0x07fb0f09:  mov    %eax,(%esp)
0x07fb0f0c:  call   0xf06b2

----------------
IN: 
0x07fb0f11:  mov    $0xfd290,%edx
0x07fb0f16:  movzwl %dx,%edx
0x07fb0f19:  mov    (%esp),%eax
0x07fb0f1c:  call   0xf0c38

----------------
IN: 
0x000f0c38:  mov    %dx,0x20(%eax)
0x000f0c3c:  movw   $0xf000,0x22(%eax)
0x000f0c42:  movzwl 0xefee8,%edx
0x000f0c49:  mov    %edx,%ecx
0x000f0c4b:  shl    $0x4,%ecx
0x000f0c4e:  sub    %ecx,%eax
0x000f0c50:  mov    $0xf9135,%ecx
0x000f0c55:  jmp    0xf0ae6

----------------
IN: 
0x000fd290:  int    $0x10

----------------
IN: 
0x000c5526:  cli    
0x000c5527:  cld    
0x000c5528:  push   %eax
0x000c552a:  push   %ecx
0x000c552c:  push   %edx
0x000c552e:  push   %ebx
0x000c5530:  push   %ebp
0x000c5532:  push   %esi
0x000c5534:  push   %edi
0x000c5536:  push   %es
0x000c5537:  push   %ds
0x000c5538:  mov    %ss,%ax
0x000c553a:  mov    %ax,%ds
0x000c553c:  mov    %esp,%ebx
0x000c553f:  movzwl %sp,%esp
0x000c5543:  mov    %esp,%eax
0x000c5546:  push   %ax
0x000c5547:  call   0xc4756

----------------
IN: 
0x000c4756:  push   %ebp
0x000c4758:  mov    %esp,%ebp
0x000c475b:  push   %edi
0x000c475d:  push   %esi
0x000c475f:  push   %ebx
0x000c4761:  sub    $0x8,%esp
0x000c4765:  mov    %eax,%ebx
0x000c4768:  addr32 mov 0x1d(%eax),%al
0x000c476c:  cmp    $0xb,%al
0x000c476e:  je     0xc4a50

----------------
IN: 
0x000c4772:  ja     0xc4818

----------------
IN: 
0x000c4776:  cmp    $0x5,%al
0x000c4778:  je     0xc4931

----------------
IN: 
0x000c477c:  ja     0xc47e0

----------------
IN: 
0x000c477e:  cmp    $0x2,%al
0x000c4780:  je     0xc48f9

----------------
IN: 
0x000c4784:  ja     0xc47a6

----------------
IN: 
0x000c4786:  test   %al,%al
0x000c4788:  je     0xc48a0

----------------
IN: 
0x000c48a0:  addr32 mov 0x1c(%ebx),%dl
0x000c48a4:  and    $0x7f,%edx
0x000c48a8:  movzbl %dl,%eax
0x000c48ac:  cmp    $0x7,%dl
0x000c48af:  jbe    0xc48b8

----------------
IN: 
0x000c48b8:  cmp    $0x6,%dl
0x000c48bb:  sete   %dl
0x000c48be:  dec    %edx
0x000c48c0:  and    $0xfffffff1,%edx
0x000c48c4:  add    $0x3f,%edx
0x000c48c8:  addr32 mov %dl,0x1c(%ebx)
0x000c48cc:  mov    $0x40,%edx
0x000c48d2:  mov    %dx,%es
0x000c48d4:  mov    %es:0x89,%dl
0x000c48d9:  and    $0xa,%edx
0x000c48dd:  or     $0x1,%edx
0x000c48e1:  addr32 cmpb $0x0,0x1c(%ebx)
0x000c48e6:  jns    0xc48eb

----------------
IN: 
0x000c48eb:  lea    -0xc(%bp),%sp
0x000c48ee:  pop    %ebx
0x000c48f0:  pop    %esi
0x000c48f2:  pop    %edi
0x000c48f4:  pop    %ebp
0x000c48f6:  jmp    0xc3256

----------------
IN: 
0x000c3256:  push   %ebp
0x000c3258:  mov    %esp,%ebp
0x000c325b:  push   %edi
0x000c325d:  push   %esi
0x000c325f:  push   %ebx
0x000c3261:  sub    $0x10,%esp
0x000c3265:  addr32 mov %eax,-0x14(%ebp)
0x000c326a:  addr32 mov %edx,-0x10(%ebp)
0x000c326f:  push   %eax
0x000c3271:  pushl  $0x5616
0x000c3277:  push   %ax
0x000c3278:  call   0xc2640

----------------
IN: 
0x000c327b:  pop    %edx
0x000c327d:  pop    %ecx
0x000c327f:  addr32 mov -0x14(%ebp),%eax
0x000c3284:  push   %ax
0x000c3285:  call   0xc2bd3

----------------
IN: 
0x000c2bd3:  push   %ebp
0x000c2bd5:  mov    %esp,%ebp
0x000c2bd8:  push   %ebx
0x000c2bda:  mov    %cs:0x58f8,%edx
0x000c2be0:  test   %edx,%edx
0x000c2be3:  jne    0xc2bf0

----------------
IN: 
0x000c2bf0:  mov    $0x58fc,%edx
0x000c2bf6:  addr32 mov %cs:(%edx),%cx
0x000c2bfa:  movzwl %cx,%ecx
0x000c2bfe:  cmp    %eax,%ecx
0x000c2c01:  jne    0xc2c0e

----------------
IN: 
0x000c2c0e:  add    $0xe,%edx
0x000c2c12:  cmp    $0x5cd0,%edx
0x000c2c19:  jb     0xc2bf6

----------------
IN: 
0x000c2bf6:  addr32 mov %cs:(%edx),%cx
0x000c2bfa:  movzwl %cx,%ecx
0x000c2bfe:  cmp    %eax,%ecx
0x000c2c01:  jne    0xc2c0e

----------------
IN: 
0x000c2c1b:  jmp    0xc2be5

----------------
IN: 
0x000c2be5:  mov    $0x5cd0,%ecx
0x000c2beb:  xor    %edx,%edx
0x000c2bee:  jmp    0xc2c1d

----------------
IN: 
0x000c2c1d:  addr32 mov %cs:(%ecx),%bx
0x000c2c21:  add    $0x2c,%ecx
0x000c2c25:  movzwl %bx,%ebx
0x000c2c29:  cmp    %eax,%ebx
0x000c2c2c:  jne    0xc2c3f

----------------
IN: 
0x000c2c3f:  inc    %edx
0x000c2c41:  cmp    $0x10,%edx
0x000c2c45:  jne    0xc2c1d

----------------
IN: 
0x000c2c2e:  imul   $0x2c,%edx,%edx
0x000c2c32:  mov    %edx,%eax
0x000c2c35:  pushf  
0x000c2c36:  add    $0x5cd2,%eax
0x000c2c3c:  popf   

----------------
IN: 
0x000c2c3d:  jmp    0xc2c4a

----------------
IN: 
0x000c2c4a:  pop    %ebx
0x000c2c4c:  pop    %ebp
0x000c2c4e:  ret    $0x2

----------------
IN: 
0x000c3288:  mov    %eax,%ebx
0x000c328b:  mov    $0x1,%eax
0x000c3291:  test   %ebx,%ebx
0x000c3294:  je     0xc36db

----------------
IN: 
0x000c3298:  mov    %cs:0x58f8,%eax
0x000c329d:  test   %eax,%eax
0x000c32a0:  je     0xc32b4

----------------
IN: 
0x000c32a2:  mov    $0x1ce,%edx
0x000c32a8:  mov    $0x4,%eax
0x000c32ae:  out    %ax,(%dx)
0x000c32af:  mov    $0xcf,%dl
0x000c32b1:  xor    %al,%al
0x000c32b3:  out    %ax,(%dx)
0x000c32b4:  cmp    $0x58fe,%ebx
0x000c32bb:  jb     0xc32c8

----------------
IN: 
0x000c32bd:  cmp    $0x5cc4,%ebx
0x000c32c4:  jbe    0xc34b7

----------------
IN: 
0x000c32c8:  addr32 mov -0x10(%ebp),%edx
0x000c32cd:  mov    %ebx,%eax
0x000c32d0:  push   %ax
0x000c32d1:  call   0xc29b6

----------------
IN: 
0x000c29b6:  push   %ebp
0x000c29b8:  mov    %esp,%ebp
0x000c29bb:  push   %edi
0x000c29bd:  push   %esi
0x000c29bf:  push   %ebx
0x000c29c1:  push   %ecx
0x000c29c3:  mov    %eax,%ebx
0x000c29c6:  addr32 mov %edx,-0x10(%ebp)
0x000c29cb:  cmp    $0x5cd2,%eax
0x000c29d1:  jb     0xc2ba4

----------------
IN: 
0x000c29d5:  cmp    $0x5f66,%eax
0x000c29db:  ja     0xc2ba4

----------------
IN: 
0x000c29df:  addr32 testb $0x8,-0x10(%ebp)
0x000c29e4:  jne    0xc2a59

----------------
IN: 
0x000c29e6:  addr32 mov %cs:0xc(%ebx),%al
0x000c29eb:  mov    $0x3c6,%edx
0x000c29f1:  out    %al,(%dx)
0x000c29f2:  addr32 mov %cs:0xe(%ebx),%edi
0x000c29f8:  addr32 mov %cs:0x12(%ebx),%ax
0x000c29fd:  mov    $0x3,%ecx
0x000c2a03:  xor    %edx,%edx
0x000c2a06:  div    %cx
0x000c2a08:  movzwl %ax,%esi
0x000c2a0c:  mov    %cs,%ax
0x000c2a0e:  movzwl %ax,%eax
0x000c2a12:  push   %esi
0x000c2a14:  xor    %ecx,%ecx
0x000c2a17:  mov    %edi,%edx
0x000c2a1a:  push   %ax
0x000c2a1b:  call   0xc0d29

----------------
IN: 
0x000c0d29:  push   %ebp
0x000c0d2b:  mov    %esp,%ebp
0x000c0d2e:  push   %edi
0x000c0d30:  push   %esi
0x000c0d32:  push   %ebx
0x000c0d34:  mov    %edx,%esi
0x000c0d37:  addr32 mov 0x8(%ebp),%edi
0x000c0d3c:  mov    %eax,%ebx
0x000c0d3f:  mov    $0x3c8,%edx
0x000c0d45:  mov    %cl,%al
0x000c0d47:  out    %al,(%dx)
0x000c0d48:  test   %edi,%edi
0x000c0d4b:  je     0xc0d72

----------------
IN: 
0x000c0d4d:  mov    %bx,%es
0x000c0d4f:  addr32 mov %es:(%esi),%al
0x000c0d53:  mov    $0x3c9,%edx
0x000c0d59:  out    %al,(%dx)
0x000c0d5a:  mov    %bx,%es
0x000c0d5c:  addr32 mov %es:0x1(%esi),%al
0x000c0d61:  out    %al,(%dx)
0x000c0d62:  mov    %bx,%es
0x000c0d64:  addr32 mov %es:0x2(%esi),%al
0x000c0d69:  out    %al,(%dx)
0x000c0d6a:  add    $0x3,%esi
0x000c0d6e:  dec    %edi
0x000c0d70:  jmp    0xc0d48

----------------
IN: 
0x000c0d48:  test   %edi,%edi
0x000c0d4b:  je     0xc0d72

----------------
IN: 
0x000c0d72:  pop    %ebx
0x000c0d74:  pop    %esi
0x000c0d76:  pop    %edi
0x000c0d78:  pop    %ebp
0x000c0d7a:  ret    $0x2

----------------
IN: 
0x000c2a1e:  pop    %edx
0x000c2a20:  cmp    $0xff,%esi
0x000c2a27:  jg     0xc2a45

----------------
IN: 
0x000c2a29:  mov    %cs,%ax
0x000c2a2b:  movzwl %ax,%eax
0x000c2a2f:  pushl  $0x1
0x000c2a32:  mov    %esi,%ecx
0x000c2a35:  mov    $0x58d5,%edx
0x000c2a3b:  push   %ax
0x000c2a3c:  call   0xc0d29

----------------
IN: 
0x000c2a3f:  pop    %eax
0x000c2a41:  inc    %esi
0x000c2a43:  jmp    0xc2a20

----------------
IN: 
0x000c2a20:  cmp    $0xff,%esi
0x000c2a27:  jg     0xc2a45

----------------
IN: 
0x000c2a45:  addr32 testb $0x2,-0x10(%ebp)
0x000c2a4a:  je     0xc2a59

----------------
IN: 
0x000c2a59:  addr32 mov %cs:0x22(%ebx),%edi
0x000c2a5f:  xor    %esi,%esi
0x000c2a62:  addr32 mov %cs:(%edi,%esi,1),%dl
0x000c2a67:  movzbl %dl,%edx
0x000c2a6b:  mov    %esi,%eax
0x000c2a6e:  push   %ax
0x000c2a6f:  call   0xc0c18

----------------
IN: 
0x000c0c18:  push   %ebp
0x000c0c1a:  mov    %esp,%ebp
0x000c0c1d:  push   %esi
0x000c0c1f:  push   %ebx
0x000c0c21:  mov    %eax,%esi
0x000c0c24:  mov    %edx,%ebx
0x000c0c27:  mov    $0x3da,%edx
0x000c0c2d:  in     (%dx),%al
0x000c0c2e:  mov    $0xc0,%dl
0x000c0c30:  in     (%dx),%al
0x000c0c31:  mov    %al,%cl
0x000c0c33:  mov    %esi,%eax
0x000c0c36:  out    %al,(%dx)
0x000c0c37:  mov    %bl,%al
0x000c0c39:  out    %al,(%dx)
0x000c0c3a:  mov    %cl,%al
0x000c0c3c:  out    %al,(%dx)
0x000c0c3d:  pop    %ebx
0x000c0c3f:  pop    %esi
0x000c0c41:  pop    %ebp
0x000c0c43:  ret    $0x2

----------------
IN: 
0x000c2a72:  inc    %esi
0x000c2a74:  cmp    $0x14,%esi
0x000c2a78:  jne    0xc2a62

----------------
IN: 
0x000c2a62:  addr32 mov %cs:(%edi,%esi,1),%dl
0x000c2a67:  movzbl %dl,%edx
0x000c2a6b:  mov    %esi,%eax
0x000c2a6e:  push   %ax
0x000c2a6f:  call   0xc0c18

----------------
IN: 
0x000c2a7a:  xor    %edx,%edx
0x000c2a7d:  mov    $0x14,%eax
0x000c2a83:  push   %ax
0x000c2a84:  call   0xc0c18

----------------
IN: 
0x000c2a87:  mov    $0x3c4,%edx
0x000c2a8d:  mov    $0x300,%eax
0x000c2a93:  out    %ax,(%dx)
0x000c2a94:  addr32 mov %cs:0x16(%ebx),%esi
0x000c2a9a:  mov    $0x1,%ecx
0x000c2aa0:  addr32 mov %cs:-0x1(%esi,%ecx,1),%al
0x000c2aa6:  shl    $0x8,%eax
0x000c2aaa:  or     %ecx,%eax
0x000c2aad:  out    %ax,(%dx)
0x000c2aae:  inc    %ecx
0x000c2ab0:  cmp    $0x5,%ecx
0x000c2ab4:  jne    0xc2aa0

----------------
IN: 
0x000c2aa0:  addr32 mov %cs:-0x1(%esi,%ecx,1),%al
0x000c2aa6:  shl    $0x8,%eax
0x000c2aaa:  or     %ecx,%eax
0x000c2aad:  out    %ax,(%dx)
0x000c2aae:  inc    %ecx
0x000c2ab0:  cmp    $0x5,%ecx
0x000c2ab4:  jne    0xc2aa0

----------------
IN: 
0x000c2ab6:  addr32 mov %cs:0x26(%ebx),%esi
0x000c2abc:  xor    %cl,%cl
0x000c2abe:  mov    $0x3ce,%edx
0x000c2ac4:  addr32 mov %cs:(%esi,%ecx,1),%al
0x000c2ac9:  shl    $0x8,%eax
0x000c2acd:  or     %ecx,%eax
0x000c2ad0:  out    %ax,(%dx)
0x000c2ad1:  inc    %ecx
0x000c2ad3:  cmp    $0x9,%ecx
0x000c2ad7:  jne    0xc2ac4

----------------
IN: 
0x000c2ac4:  addr32 mov %cs:(%esi,%ecx,1),%al
0x000c2ac9:  shl    $0x8,%eax
0x000c2acd:  or     %ecx,%eax
0x000c2ad0:  out    %ax,(%dx)
0x000c2ad1:  inc    %ecx
0x000c2ad3:  cmp    $0x9,%ecx
0x000c2ad7:  jne    0xc2ac4

----------------
IN: 
0x000c2ad9:  addr32 mov %cs:0x1a(%ebx),%al
0x000c2ade:  mov    %eax,%esi
0x000c2ae1:  mov    $0x3d4,%edx
0x000c2ae7:  test   $0x1,%al
0x000c2ae9:  jne    0xc2aed

----------------
IN: 
0x000c2aed:  mov    $0x11,%eax
0x000c2af3:  out    %ax,(%dx)
0x000c2af4:  addr32 mov %cs:0x1e(%ebx),%edi
0x000c2afa:  xor    %ecx,%ecx
0x000c2afd:  addr32 mov %cs:(%edi,%ecx,1),%al
0x000c2b02:  shl    $0x8,%eax
0x000c2b06:  or     %ecx,%eax
0x000c2b09:  out    %ax,(%dx)
0x000c2b0a:  inc    %ecx
0x000c2b0c:  cmp    $0x19,%ecx
0x000c2b10:  jne    0xc2afd

----------------
IN: 
0x000c2afd:  addr32 mov %cs:(%edi,%ecx,1),%al
0x000c2b02:  shl    $0x8,%eax
0x000c2b06:  or     %ecx,%eax
0x000c2b09:  out    %ax,(%dx)
0x000c2b0a:  inc    %ecx
0x000c2b0c:  cmp    $0x19,%ecx
0x000c2b10:  jne    0xc2afd

----------------
IN: 
0x000c2b12:  mov    $0x3c2,%edx
0x000c2b18:  mov    %esi,%eax
0x000c2b1b:  out    %al,(%dx)
0x000c2b1c:  mov    $0xda,%dl
0x000c2b1e:  in     (%dx),%al
0x000c2b1f:  mov    $0xc0,%dl
0x000c2b21:  mov    $0x20,%al
0x000c2b23:  out    %al,(%dx)
0x000c2b24:  addr32 mov -0x10(%ebp),%edi
0x000c2b29:  and    $0x8000,%edi
0x000c2b30:  jne    0xc2b74

----------------
IN: 
0x000c2b32:  addr32 mov %cs:(%ebx),%al
0x000c2b36:  test   %al,%al
0x000c2b38:  je     0xc2b4d

----------------
IN: 
0x000c2b4d:  addr32 mov %cs:0xa(%ebx),%ax
0x000c2b52:  mov    %ax,%es
0x000c2b54:  mov    $0x4000,%ecx
0x000c2b5a:  mov    $0x720,%eax
0x000c2b60:  jmp    0xc2b72

----------------
IN: 
0x000c2b72:  rep stos %ax,%es:(%di)

----------------
IN: 
0x000c2b74:  addr32 mov %cs:(%ebx),%al
0x000c2b78:  xor    %ebx,%ebx
0x000c2b7b:  test   %al,%al
0x000c2b7d:  jne    0xc2bc2

----------------
IN: 
0x000c2b7f:  mov    %cs,%dx
0x000c2b81:  movzwl %dx,%eax
0x000c2b85:  pushl  $0x10
0x000c2b88:  pushl  $0x0
0x000c2b8b:  pushl  $0x0
0x000c2b8e:  mov    $0x100,%ecx
0x000c2b94:  mov    $0x6730,%edx
0x000c2b9a:  push   %ax
0x000c2b9b:  call   0xc07ff

----------------
IN: 
0x000c07ff:  push   %ebp
0x000c0801:  mov    %esp,%ebp
0x000c0804:  push   %edi
0x000c0806:  push   %esi
0x000c0808:  push   %ebx
0x000c080a:  sub    $0x10,%esp
0x000c080e:  mov    %edx,%ebx
0x000c0811:  addr32 mov 0xc(%ebp),%esi
0x000c0816:  addr32 mov %ax,-0x1a(%ebp)
0x000c081a:  addr32 mov %cx,-0x1c(%ebp)
0x000c081e:  mov    $0x3c4,%edx
0x000c0824:  mov    $0x100,%eax
0x000c082a:  out    %ax,(%dx)
0x000c082b:  mov    $0x402,%eax
0x000c0831:  out    %ax,(%dx)
0x000c0832:  mov    $0x704,%eax
0x000c0838:  out    %ax,(%dx)
0x000c0839:  mov    $0x300,%eax
0x000c083f:  out    %ax,(%dx)
0x000c0840:  mov    $0xce,%dl
0x000c0842:  mov    $0x204,%eax
0x000c0848:  out    %ax,(%dx)
0x000c0849:  mov    $0x5,%eax
0x000c084f:  out    %ax,(%dx)
0x000c0850:  mov    $0x406,%eax
0x000c0856:  out    %ax,(%dx)
0x000c0857:  addr32 movzbl 0x10(%ebp),%eax
0x000c085d:  addr32 mov %eax,-0x14(%ebp)
0x000c0862:  addr32 mov %ebx,-0x10(%ebp)
0x000c0867:  mov    %esi,%eax
0x000c086a:  and    $0x4,%eax
0x000c086e:  movzbl %al,%eax
0x000c0872:  shl    $0xb,%eax
0x000c0876:  shl    $0xe,%esi
0x000c087a:  add    %eax,%esi
0x000c087d:  movzwl %si,%esi
0x000c0881:  addr32 movzwl 0x8(%ebp),%eax
0x000c0887:  shl    $0x5,%eax
0x000c088b:  add    %esi,%eax
0x000c088e:  addr32 mov %eax,-0x18(%ebp)
0x000c0893:  xor    %ebx,%ebx
0x000c0896:  addr32 cmp -0x1c(%ebp),%bx
0x000c089a:  je     0xc08d3

----------------
IN: 
0x000c089c:  mov    $0xffffa000,%edi
0x000c08a2:  mov    %di,%es
0x000c08a4:  addr32 mov -0x14(%ebp),%ecx
0x000c08a9:  addr32 mov -0x10(%ebp),%esi
0x000c08ae:  addr32 mov -0x18(%ebp),%edi
0x000c08b3:  addr32 mov -0x1a(%ebp),%ax
0x000c08b7:  mov    %ds,%dx
0x000c08b9:  mov    %ax,%ds
0x000c08bb:  rep movsb %ds:(%si),%es:(%di)

----------------
IN: 
0x000c08bb:  rep movsb %ds:(%si),%es:(%di)

----------------
IN: 
0x000c08bd:  mov    %dx,%ds
0x000c08bf:  inc    %ebx
0x000c08c1:  addr32 mov -0x14(%ebp),%edi
0x000c08c6:  addr32 add %edi,-0x10(%ebp)
0x000c08cb:  addr32 addl $0x20,-0x18(%ebp)
0x000c08d1:  jmp    0xc0896

----------------
IN: 
0x000c0896:  addr32 cmp -0x1c(%ebp),%bx
0x000c089a:  je     0xc08d3

----------------
IN: 
0x000c08d3:  mov    $0x3c4,%edx
0x000c08d9:  mov    $0x100,%eax
0x000c08df:  out    %ax,(%dx)
0x000c08e0:  mov    $0x302,%eax
0x000c08e6:  out    %ax,(%dx)
0x000c08e7:  mov    $0x4,%al
0x000c08e9:  out    %ax,(%dx)
0x000c08ea:  xor    %al,%al
0x000c08ec:  out    %ax,(%dx)
0x000c08ed:  mov    $0xcc,%dl
0x000c08ef:  in     (%dx),%al
0x000c08f0:  mov    $0xe,%ecx
0x000c08f6:  test   $0x1,%al
0x000c08f8:  jne    0xc08fc

----------------
IN: 
0x000c08fc:  mov    %ecx,%eax
0x000c08ff:  shl    $0x8,%eax
0x000c0903:  or     $0x6,%eax
0x000c0907:  mov    $0x3ce,%edx
0x000c090d:  out    %ax,(%dx)
0x000c090e:  mov    $0x4,%eax
0x000c0914:  out    %ax,(%dx)
0x000c0915:  mov    $0x1005,%eax
0x000c091b:  out    %ax,(%dx)
0x000c091c:  add    $0x10,%esp
0x000c0920:  pop    %ebx
0x000c0922:  pop    %esi
0x000c0924:  pop    %edi
0x000c0926:  pop    %ebp
0x000c0928:  ret    $0x2

----------------
IN: 
0x000c2b9e:  add    $0xc,%esp
0x000c2ba2:  jmp    0xc2bc2

----------------
IN: 
0x000c2bc2:  mov    %ebx,%eax
0x000c2bc5:  lea    -0xc(%bp),%sp
0x000c2bc8:  pop    %ebx
0x000c2bca:  pop    %esi
0x000c2bcc:  pop    %edi
0x000c2bce:  pop    %ebp
0x000c2bd0:  ret    $0x2

----------------
IN: 
0x000c32d4:  test   %eax,%eax
0x000c32d7:  jne    0xc36db

----------------
IN: 
0x000c32db:  addr32 mov %cs:0x2(%ebx),%dx
0x000c32e0:  movzwl %dx,%eax
0x000c32e4:  addr32 mov %eax,-0x1c(%ebp)
0x000c32e9:  addr32 mov %cs:0x4(%ebx),%di
0x000c32ee:  movzwl %di,%ecx
0x000c32f2:  addr32 mov %cs:(%ebx),%al
0x000c32f6:  addr32 mov %al,-0x16(%ebp)
0x000c32fa:  addr32 mov %cs:0x8(%ebx),%al
0x000c32ff:  addr32 mov %al,-0x15(%ebp)
0x000c3303:  mov    $0x40,%eax
0x000c3309:  addr32 cmpl $0xff,-0x14(%ebp)
0x000c3312:  jg     0xc331c

----------------
IN: 
0x000c3314:  mov    %ax,%es
0x000c3316:  addr32 mov -0x14(%ebp),%al
0x000c331a:  jmp    0xc3320

----------------
IN: 
0x000c3320:  mov    %al,%es:0x49
0x000c3324:  mov    $0x40,%esi
0x000c332a:  mov    %si,%es
0x000c332c:  addr32 mov -0x10(%ebp),%eax
0x000c3331:  and    $0xfe00,%ax
0x000c3334:  addr32 or -0x14(%ebp),%eax
0x000c3339:  mov    %ax,%es:0xba
0x000c333d:  mov    %si,%es
0x000c333f:  mov    %bx,%es:0xbc
0x000c3344:  addr32 cmpb $0x0,-0x16(%ebp)
0x000c3349:  jne    0xc336b

----------------
IN: 
0x000c334b:  mov    %si,%es
0x000c334d:  mov    %dx,%es:0x4a
0x000c3352:  mov    %si,%es
0x000c3354:  mov    %edi,%eax
0x000c3357:  pushf  
0x000c3358:  add    $0xffffffff,%eax
0x000c335c:  popf   

----------------
IN: 
0x000c335d:  mov    %al,%es:0x84
0x000c3361:  mov    %si,%es
0x000c3363:  mov    $0x607,%eax
0x000c3369:  jmp    0xc339f

----------------
IN: 
0x000c339f:  mov    %ax,%es:0x60
0x000c33a3:  addr32 movzbl -0x16(%ebp),%eax
0x000c33a9:  addr32 mov -0x1c(%ebp),%edx
0x000c33ae:  push   %ax
0x000c33af:  call   0xc0022

----------------
IN: 
0x000c33b2:  mov    $0x40,%ebx
0x000c33b8:  mov    %bx,%es
0x000c33ba:  mov    %ax,%es:0x4c
0x000c33be:  push   %ax
0x000c33bf:  call   0xc092b

----------------
IN: 
0x000c092b:  push   %ebp
0x000c092d:  mov    %esp,%ebp
0x000c0930:  mov    $0x3cc,%edx
0x000c0936:  in     (%dx),%al
0x000c0937:  mov    %al,%dl
0x000c0939:  mov    $0x3d4,%eax
0x000c093f:  and    $0x1,%dl
0x000c0942:  jne    0xc0946

----------------
IN: 
0x000c0946:  pop    %ebp
0x000c0948:  ret    $0x2

----------------
IN: 
0x000c33c2:  mov    %bx,%es
0x000c33c4:  mov    %ax,%es:0x63
0x000c33c8:  mov    %bx,%es
0x000c33ca:  addr32 movzbl -0x15(%ebp),%eax
0x000c33d0:  mov    %ax,%es:0x85
0x000c33d4:  addr32 mov -0x10(%ebp),%eax
0x000c33d9:  and    $0x8000,%eax
0x000c33df:  cmp    $0x1,%eax
0x000c33e3:  sbb    %eax,%eax
0x000c33e6:  and    $0xffffff80,%eax
0x000c33ea:  sub    $0x20,%eax
0x000c33ee:  mov    %bx,%es
0x000c33f0:  mov    %al,%es:0x87
0x000c33f4:  mov    %bx,%es
0x000c33f6:  mov    $0xf9,%al
0x000c33f8:  mov    %al,%es:0x88
0x000c33fc:  mov    %bx,%es
0x000c33fe:  mov    %es:0x89,%al
0x000c3402:  mov    %bx,%es
0x000c3404:  and    $0x7f,%eax
0x000c3408:  mov    %al,%es:0x89
0x000c340c:  xor    %eax,%eax
0x000c340f:  mov    $0x40,%esi
0x000c3415:  xor    %bl,%bl
0x000c3417:  mov    $0x40,%edx
0x000c341d:  mov    %si,%es
0x000c341f:  xor    %ecx,%ecx
0x000c3422:  addr32 mov %bx,%es:0x50(%eax,%eax,1)
0x000c3428:  inc    %eax
0x000c342a:  cmp    $0x8,%eax
0x000c342e:  jne    0xc3417

----------------
IN: 
0x000c3417:  mov    $0x40,%edx
0x000c341d:  mov    %si,%es
0x000c341f:  xor    %ecx,%ecx
0x000c3422:  addr32 mov %bx,%es:0x50(%eax,%eax,1)
0x000c3428:  inc    %eax
0x000c342a:  cmp    $0x8,%eax
0x000c342e:  jne    0xc3417

----------------
IN: 
0x000c3430:  mov    %dx,%es
0x000c3432:  mov    %cx,%es:0x4e
0x000c3437:  mov    %dx,%es
0x000c3439:  xor    %eax,%eax
0x000c343c:  mov    %al,%es:0x62
0x000c3440:  mov    %cs,%ax
0x000c3442:  mov    %eax,%edx
0x000c3445:  shl    $0x10,%edx
0x000c3449:  mov    $0x8930,%eax
0x000c344f:  movzwl %ax,%eax
0x000c3453:  or     %edx,%eax
0x000c3456:  mov    %cx,%es
0x000c3458:  mov    %eax,%es:0x7c
0x000c345d:  addr32 cmpb $0xe,-0x15(%ebp)
0x000c3462:  je     0xc3483

----------------
IN: 
0x000c3464:  addr32 cmpb $0x10,-0x15(%ebp)
0x000c3469:  je     0xc34a6

----------------
IN: 
0x000c34a6:  mov    %cs,%ax
0x000c34a8:  mov    %eax,%edx
0x000c34ab:  shl    $0x10,%edx
0x000c34af:  mov    $0x6730,%eax
0x000c34b5:  jmp    0xc3492

----------------
IN: 
0x000c3492:  movzwl %ax,%eax
0x000c3496:  or     %edx,%eax
0x000c3499:  mov    %cx,%es
0x000c349b:  mov    %eax,%es:0x10c
0x000c34a0:  xor    %eax,%eax
0x000c34a3:  jmp    0xc36db

----------------
IN: 
0x000c36db:  lea    -0xc(%bp),%sp
0x000c36de:  pop    %ebx
0x000c36e0:  pop    %esi
0x000c36e2:  pop    %edi
0x000c36e4:  pop    %ebp
0x000c36e6:  ret    $0x2

----------------
IN: 
0x000c554a:  mov    %ebx,%esp
0x000c554d:  pop    %ds
0x000c554e:  pop    %es
0x000c554f:  pop    %edi
0x000c5551:  pop    %esi
0x000c5553:  pop    %ebp
0x000c5555:  pop    %ebx
0x000c5557:  pop    %edx
0x000c5559:  pop    %ecx
0x000c555b:  pop    %eax
0x000c555d:  iret   

Servicing hardware INT=0x08
----------------
IN: 
0x000fd292:  lret   

----------------
IN: 
0x07fb0f21:  pop    %ecx
0x07fb0f22:  jmp    0xf0bab

----------------
IN: 
0x07fb5653:  push   $0xf5cf8
0x07fb5658:  push   $0xf4770
0x07fb565d:  call   0xf2dae

----------------
IN: 
0x000f2dae:  lea    0x8(%esp),%ecx
0x000f2db2:  mov    0x4(%esp),%edx
0x000f2db6:  mov    $0xf5cf0,%eax
0x000f2dbb:  call   0xf0854

----------------
IN: 
0x000f0c9b:  push   %ebx
0x000f0c9c:  mov    %edx,%ebx
0x000f0c9e:  cmpl   $0x0,0xf5f7c
0x000f0ca5:  je     0xf0cb1

----------------
IN: 
0x000f0ca7:  mov    0xf6abc,%dx
0x000f0cae:  mov    %bl,%al
0x000f0cb0:  out    %al,(%dx)
0x000f0cb1:  cmp    $0xa,%bl
0x000f0cb4:  jne    0xf0cc0

----------------
IN: 
0x000f0cc0:  movsbl %bl,%eax
0x000f0cc3:  pop    %ebx
0x000f0cc4:  jmp    0xf0c5a

----------------
IN: 
0x000f0c5a:  push   %ebx
0x000f0c5b:  sub    $0x28,%esp
0x000f0c5e:  mov    %eax,%ebx
0x000f0c60:  mov    $0x26,%ecx
0x000f0c65:  xor    %edx,%edx
0x000f0c67:  lea    0x2(%esp),%eax
0x000f0c6b:  call   0xf0090

----------------
IN: 
0x000f0c70:  movw   $0x200,0x26(%esp)
0x000f0c77:  movb   $0xe,0x1f(%esp)
0x000f0c7c:  mov    %bl,0x1e(%esp)
0x000f0c80:  movb   $0x7,0x12(%esp)
0x000f0c85:  mov    $0xfd290,%edx
0x000f0c8a:  movzwl %dx,%edx
0x000f0c8d:  lea    0x2(%esp),%eax
0x000f0c91:  call   0xf0c38

----------------
IN: 
0x000c4818:  cmp    $0x11,%al
0x000c481a:  je     0xc4dce

----------------
IN: 
0x000c481e:  ja     0xc485a

----------------
IN: 
0x000c4820:  cmp    $0xe,%al
0x000c4822:  je     0xc4b00

----------------
IN: 
0x000c4b00:  addr32 mov 0x1c(%ebx),%dl
0x000c4b04:  addr32 mov 0x10(%ebx),%al
0x000c4b08:  lea    -0xc(%bp),%sp
0x000c4b0b:  pop    %ebx
0x000c4b0d:  pop    %esi
0x000c4b0f:  pop    %edi
0x000c4b11:  pop    %ebp
0x000c4b13:  jmp    0xc235b

----------------
IN: 
0x000c235b:  push   %ebp
0x000c235d:  mov    %esp,%ebp
0x000c2360:  push   %ebx
0x000c2362:  sub    $0x8,%esp
0x000c2366:  mov    %al,%bl
0x000c2368:  addr32 mov %dl,-0x9(%ebp)
0x000c236c:  mov    $0xff,%eax
0x000c2372:  push   %ax
0x000c2373:  call   0xc0fa1

----------------
IN: 
0x000c0fa1:  push   %ebp
0x000c0fa3:  mov    %esp,%ebp
0x000c0fa6:  mov    %al,%dl
0x000c0fa8:  inc    %al
0x000c0faa:  jne    0xc0fb9

----------------
IN: 
0x000c0fac:  mov    $0x40,%eax
0x000c0fb2:  mov    %ax,%es
0x000c0fb4:  mov    %es:0x62,%dl
0x000c0fb9:  mov    $0xfe0000,%eax
0x000c0fbf:  cmp    $0x7,%dl
0x000c0fc2:  ja     0xc0feb

----------------
IN: 
0x000c0fc4:  mov    $0x40,%eax
0x000c0fca:  mov    %ax,%es
0x000c0fcc:  movzbl %dl,%edx
0x000c0fd0:  addr32 mov %es:0x50(%edx,%edx,1),%cx
0x000c0fd6:  xor    %eax,%eax
0x000c0fd9:  mov    %cl,%al
0x000c0fdb:  shr    $0x8,%cx
0x000c0fde:  mov    %cl,%ah
0x000c0fe0:  shl    $0x10,%edx
0x000c0fe4:  movzwl %ax,%eax
0x000c0fe8:  or     %edx,%eax
0x000c0feb:  pop    %ebp
0x000c0fed:  ret    $0x2

----------------
IN: 
0x000c2376:  addr32 mov %eax,-0x8(%ebp)
0x000c237b:  pushl  $0x0
0x000c237e:  mov    %bl,%cl
0x000c2380:  addr32 mov -0x9(%ebp),%dl
0x000c2384:  mov    %ebp,%eax
0x000c2387:  pushf  
0x000c2388:  add    $0xfffffff8,%eax
0x000c238c:  popf   

----------------
IN: 
0x000c238d:  push   %ax
0x000c238e:  call   0xc2297

----------------
IN: 
0x000c2297:  push   %ebp
0x000c2299:  mov    %esp,%ebp
0x000c229c:  push   %edi
0x000c229e:  push   %esi
0x000c22a0:  push   %ebx
0x000c22a2:  mov    %eax,%ebx
0x000c22a5:  cmp    $0x8,%dl
0x000c22a8:  je     0xc22c3

----------------
IN: 
0x000c22aa:  ja     0xc22b3

----------------
IN: 
0x000c22b3:  cmp    $0xa,%dl
0x000c22b6:  je     0xc22d1

----------------
IN: 
0x000c22b8:  cmp    $0xd,%dl
0x000c22bb:  jne    0xc22d7

----------------
IN: 
0x000c22d7:  addr32 mov 0x8(%ebp),%al
0x000c22db:  push   %eax
0x000c22dd:  mov    %ebx,%eax
0x000c22e0:  push   %ax
0x000c22e1:  call   0xc210f

----------------
IN: 
0x000c210f:  push   %ebp
0x000c2111:  mov    %esp,%ebp
0x000c2114:  push   %edi
0x000c2116:  push   %esi
0x000c2118:  push   %ebx
0x000c211a:  push   %ebx
0x000c211c:  mov    %eax,%ebx
0x000c211f:  addr32 mov %dl,-0xd(%ebp)
0x000c2123:  mov    %ecx,%esi
0x000c2126:  addr32 mov (%eax),%al
0x000c2129:  addr32 mov %al,-0xe(%ebp)
0x000c212d:  addr32 mov 0x1(%ebx),%dl
0x000c2131:  addr32 mov 0x2(%ebx),%cl
0x000c2135:  mov    $0x40,%eax
0x000c213b:  mov    %ax,%es
0x000c213d:  mov    %es:0xbc,%di
0x000c2142:  movzwl %di,%edi
0x000c2146:  test   %edi,%edi
0x000c2149:  je     0xc21a4

----------------
IN: 
0x000c214b:  addr32 mov %cs:(%edi),%al
0x000c214f:  test   %al,%al
0x000c2151:  je     0xc216e

----------------
IN: 
0x000c216e:  addr32 mov -0xe(%ebp),%al
0x000c2172:  push   %ax
0x000c2173:  call   0xc0ff0

----------------
IN: 
0x000c0ff0:  push   %ebp
0x000c0ff2:  mov    %esp,%ebp
0x000c0ff5:  push   %esi
0x000c0ff7:  push   %ebx
0x000c0ff9:  mov    $0x40,%esi
0x000c0fff:  mov    %si,%es
0x000c1001:  mov    %es:0x4a,%bx
0x000c1006:  mov    %si,%es
0x000c1008:  mov    %es:0x4c,%si
0x000c100d:  movzwl %si,%esi
0x000c1011:  movzbl %cl,%ecx
0x000c1015:  imul   %ecx,%esi
0x000c1019:  movzbl %al,%eax
0x000c101d:  pushf  
0x000c101e:  push   %eax
0x000c1020:  shl    %eax
0x000c1023:  add    %eax,%esi
0x000c1026:  pop    %eax
0x000c1028:  popf   

----------------
IN: 
0x000c1029:  movzbl %dl,%eax
0x000c102d:  movzwl %bx,%ecx
0x000c1031:  add    %ecx,%ecx
0x000c1034:  imul   %eax,%ecx
0x000c1038:  mov    %ecx,%eax
0x000c103b:  pushf  
0x000c103c:  add    %esi,%eax
0x000c103f:  popf   

----------------
IN: 
0x000c1040:  pop    %ebx
0x000c1042:  pop    %esi
0x000c1044:  pop    %ebp
0x000c1046:  ret    $0x2

----------------
IN: 
0x000c2176:  addr32 mov %cs:0xa(%edi),%dx
0x000c217b:  addr32 cmpb $0x0,0x8(%ebp)
0x000c2180:  je     0xc219a

----------------
IN: 
0x000c219a:  mov    %dx,%es
0x000c219c:  addr32 mov -0xd(%ebp),%cl
0x000c21a0:  addr32 mov %cl,%es:(%eax)
0x000c21a4:  addr32 mov (%ebx),%al
0x000c21a7:  inc    %eax
0x000c21a9:  addr32 mov %al,(%ebx)
0x000c21ac:  mov    $0x40,%edx
0x000c21b2:  mov    %dx,%es
0x000c21b4:  mov    %es:0x4a,%dx
0x000c21b9:  movzbl %al,%eax
0x000c21bd:  cmp    %dx,%ax
0x000c21bf:  jne    0xc21c9

----------------
IN: 
0x000c21c9:  lea    -0xc(%bp),%sp
0x000c21cc:  pop    %ebx
0x000c21ce:  pop    %esi
0x000c21d0:  pop    %edi
0x000c21d2:  pop    %ebp
0x000c21d4:  ret    $0x2

----------------
IN: 
0x000c22e4:  pop    %eax
0x000c22e6:  mov    $0x40,%edi
0x000c22ec:  mov    %di,%es
0x000c22ee:  mov    %es:0x84,%al
0x000c22f2:  mov    %eax,%esi
0x000c22f5:  addr32 mov 0x1(%ebx),%al
0x000c22f9:  mov    %esi,%edx
0x000c22fc:  cmp    %al,%dl
0x000c22fe:  jae    0xc234d

----------------
IN: 
0x000c234d:  lea    -0xc(%bp),%sp
0x000c2350:  pop    %ebx
0x000c2352:  pop    %esi
0x000c2354:  pop    %edi
0x000c2356:  pop    %ebp
0x000c2358:  ret    $0x2

----------------
IN: 
0x000c2391:  pop    %ebx
0x000c2393:  addr32 mov -0x6(%ebp),%cl
0x000c2397:  addr32 mov -0x7(%ebp),%dl
0x000c239b:  addr32 mov -0x8(%ebp),%al
0x000c239f:  push   %ax
0x000c23a0:  call   0xc1314

----------------
IN: 
0x000c1314:  cmp    $0x7,%cl
0x000c1317:  ja     0xc139b

----------------
IN: 
0x000c131b:  push   %ebp
0x000c131d:  mov    %esp,%ebp
0x000c1320:  push   %edi
0x000c1322:  push   %esi
0x000c1324:  push   %ebx
0x000c1326:  push   %ebx
0x000c1328:  mov    $0x40,%edi
0x000c132e:  mov    %di,%es
0x000c1330:  movzbl %cl,%ebx
0x000c1334:  mov    %edx,%esi
0x000c1337:  shl    $0x8,%esi
0x000c133b:  addr32 mov %si,-0xe(%ebp)
0x000c133f:  movzbl %al,%esi
0x000c1343:  addr32 or -0xe(%ebp),%si
0x000c1347:  addr32 mov %si,%es:0x50(%ebx,%ebx,1)
0x000c134d:  mov    %di,%es
0x000c134f:  mov    %es:0x62,%bl
0x000c1354:  cmp    %bl,%cl
0x000c1356:  jne    0xc1391

----------------
IN: 
0x000c1358:  push   %ax
0x000c1359:  call   0xc0ff0

----------------
IN: 
0x000c135c:  mov    %eax,%esi
0x000c135f:  push   %ax
0x000c1360:  call   0xc092b

----------------
IN: 
0x000c1363:  mov    %eax,%ebx
0x000c1366:  mov    $0x2,%ecx
0x000c136c:  mov    %esi,%eax
0x000c136f:  cltd   
0x000c1371:  idiv   %ecx
0x000c1374:  mov    %eax,%ecx
0x000c1377:  and    $0xff00,%eax
0x000c137d:  or     $0xe,%eax
0x000c1381:  mov    %ebx,%edx
0x000c1384:  out    %ax,(%dx)
0x000c1385:  shl    $0x8,%ecx
0x000c1389:  mov    %ecx,%eax
0x000c138c:  or     $0xf,%eax
0x000c1390:  out    %ax,(%dx)
0x000c1391:  pop    %eax
0x000c1393:  pop    %ebx
0x000c1395:  pop    %esi
0x000c1397:  pop    %edi
0x000c1399:  pop    %ebp
0x000c139b:  ret    $0x2

----------------
IN: 
0x000c23a3:  addr32 mov -0x4(%ebp),%ebx
0x000c23a8:  mov    %ebp,%esp
0x000c23ab:  pop    %ebp
0x000c23ad:  ret    $0x2

----------------
IN: 
0x000f0c96:  add    $0x28,%esp
0x000f0c99:  pop    %ebx
0x000f0c9a:  ret    

----------------
IN: 
0x000f0cb6:  mov    $0xd,%eax
0x000f0cbb:  call   0xf0c5a

----------------
IN: 
0x000c22bd:  addr32 movb $0x0,(%eax)
0x000c22c1:  jmp    0xc22e6

----------------
IN: 
0x000c22e6:  mov    $0x40,%edi
0x000c22ec:  mov    %di,%es
0x000c22ee:  mov    %es:0x84,%al
0x000c22f2:  mov    %eax,%esi
0x000c22f5:  addr32 mov 0x1(%ebx),%al
0x000c22f9:  mov    %esi,%edx
0x000c22fc:  cmp    %al,%dl
0x000c22fe:  jae    0xc234d

----------------
IN: 
0x000c22d1:  addr32 incb 0x1(%eax)
0x000c22d5:  jmp    0xc22e6

----------------
IN: 
0x000f2dc0:  ret    

----------------
IN: 
0x07fb5662:  mov    0x7fbff1c,%edi
0x07fb5668:  xor    %edx,%edx
0x07fb566a:  mov    %edi,%eax
0x07fb566c:  call   0x7fafe18

----------------
IN: 
0x07fb5671:  mov    %eax,%ebx
0x07fb5673:  add    $0xc,%esp
0x07fb5676:  test   %ebx,%ebx
0x07fb5678:  je     0x7fb571e

----------------
IN: 
0x07fb567e:  cmpb   $0x1,(%ebx)
0x07fb5681:  jne    0x7fb570e

----------------
IN: 
0x07fb570e:  mov    %ebx,%edx
0x07fb5710:  mov    %edi,%eax
0x07fb5712:  call   0x7fafe18

----------------
IN: 
0x07fb5717:  mov    %eax,%ebx
0x07fb5719:  jmp    0x7fb5676

----------------
IN: 
0x07fb5676:  test   %ebx,%ebx
0x07fb5678:  je     0x7fb571e

----------------
IN: 
0x07fb5687:  movzbl 0x1(%ebx),%eax
0x07fb568b:  cmp    $0x17,%eax
0x07fb568e:  jle    0x7fb570e

----------------
IN: 
0x07fb5690:  lea    0x2(%esp),%edi
0x07fb5694:  mov    $0x4,%ecx
0x07fb5699:  xor    %eax,%eax
0x07fb569b:  rep stos %eax,%es:(%edi)

----------------
IN: 
0x07fb569b:  rep stos %eax,%es:(%edi)

----------------
IN: 
0x07fb569d:  lea    0x8(%ebx),%eax
0x07fb56a0:  mov    $0x10,%cl
0x07fb56a2:  lea    0x2(%esp),%edx
0x07fb56a6:  call   0x7faf4bd

----------------
IN: 
0x07fb56ab:  test   %eax,%eax
0x07fb56ad:  je     0x7fb571e

----------------
IN: 
0x07fb571e:  add    $0x38,%esp
0x07fb5721:  pop    %ebx
0x07fb5722:  pop    %edi
0x07fb5723:  ret    

----------------
IN: 
0x07fbbd00:  call   0xeff00

----------------
IN: 
0x07fbbd05:  test   %eax,%eax
0x07fbbd07:  jne    0x7fbbd13

----------------
IN: 
0x07fbbd09:  call   0x7fba1eb

----------------
IN: 
0x07fba1eb:  push   %ebp
0x07fba1ec:  push   %edi
0x07fba1ed:  push   %esi
0x07fba1ee:  push   %ebx
0x07fba1ef:  sub    $0x18,%esp
0x07fba1f2:  xor    %edx,%edx
0x07fba1f4:  mov    $0x7fb2764,%eax
0x07fba1f9:  call   0x7fb0a15

----------------
IN: 
0x07fb0a15:  push   %ebp
0x07fb0a16:  push   %edi
0x07fb0a17:  push   %esi
0x07fb0a18:  push   %ebx
0x07fb0a19:  mov    %eax,%edi
0x07fb0a1b:  mov    %edx,%ebp
0x07fb0a1d:  cmpl   $0x0,0xf5f90
0x07fb0a24:  je     0x7fb0a91

----------------
IN: 
0x07fb0a26:  mov    $0x1000,%ecx
0x07fb0a2b:  mov    $0x1000,%edx
0x07fb0a30:  mov    $0x7fbfe9c,%eax
0x07fb0a35:  call   0x7faf858

----------------
IN: 
0x07fb0a3a:  mov    %eax,%ebx
0x07fb0a3c:  test   %eax,%eax
0x07fb0a3e:  je     0x7fb0a91

----------------
IN: 
0x07fb0a40:  lea    0x1000(%eax),%eax
0x07fb0a46:  mov    %eax,(%ebx)
0x07fb0a48:  mov    %esp,%eax
0x07fb0a4a:  mov    $0xf6be4,%esi
0x07fb0a4f:  cmp    $0x100000,%eax
0x07fb0a54:  jbe    0x7fb0a5d

----------------
IN: 
0x07fb0a5d:  lea    0x4(%esi),%edx
0x07fb0a60:  lea    0x4(%ebx),%eax
0x07fb0a63:  call   0x7faf48f

----------------
IN: 
0x07fb0a68:  mov    %ebp,%eax
0x07fb0a6a:  mov    %edi,%ecx
0x07fb0a6c:  mov    %esi,%edx
0x07fb0a6e:  push   $0x7fb0a8f
0x07fb0a73:  push   %ebp
0x07fb0a74:  mov    %esp,(%edx)
0x07fb0a76:  mov    (%ebx),%esp
0x07fb0a78:  call   *%ecx

----------------
IN: 
0x07fb2764:  push   %ebp
0x07fb2765:  push   %edi
0x07fb2766:  push   %esi
0x07fb2767:  push   %ebx
0x07fb2768:  sub    $0x8,%esp
0x07fb276b:  mov    0x7fbfed4,%eax
0x07fb2770:  lea    -0x4(%eax),%esi
0x07fb2773:  cmp    $0xfffffffc,%esi
0x07fb2776:  je     0x7fb2955

----------------
IN: 
0x07fb277c:  movzwl 0x14(%esi),%eax
0x07fb2780:  shl    $0x8,%eax
0x07fb2783:  movzbl 0x16(%esi),%edx
0x07fb2787:  or     %edx,%eax
0x07fb2789:  cmp    $0xc0330,%eax
0x07fb278e:  jne    0x7fb294a

----------------
IN: 
0x07fb294a:  mov    0x4(%esi),%esi
0x07fb294d:  sub    $0x4,%esi
0x07fb2950:  jmp    0x7fb2773

----------------
IN: 
0x07fb2773:  cmp    $0xfffffffc,%esi
0x07fb2776:  je     0x7fb2955

----------------
IN: 
0x07fb2955:  mov    0x7fbfed4,%eax
0x07fb295a:  lea    -0x4(%eax),%ebx
0x07fb295d:  cmp    $0xfffffffc,%ebx
0x07fb2960:  je     0x7fb2a4b

----------------
IN: 
0x07fb2966:  movzwl 0x14(%ebx),%eax
0x07fb296a:  shl    $0x8,%eax
0x07fb296d:  movzbl 0x16(%ebx),%edx
0x07fb2971:  or     %edx,%eax
0x07fb2973:  cmp    $0xc0320,%eax
0x07fb2978:  jne    0x7fb2a40

----------------
IN: 
0x07fb2a40:  mov    0x4(%ebx),%ebx
0x07fb2a43:  sub    $0x4,%ebx
0x07fb2a46:  jmp    0x7fb295d

----------------
IN: 
0x07fb295d:  cmp    $0xfffffffc,%ebx
0x07fb2960:  je     0x7fb2a4b

----------------
IN: 
0x07fb2a4b:  cmpl   $0x0,0x7fbff34
0x07fb2a52:  je     0x7fb2a5b

----------------
IN: 
0x07fb2a5b:  mov    0x7fbfed4,%eax
0x07fb2a60:  lea    -0x4(%eax),%ebx
0x07fb2a63:  cmp    $0xfffffffc,%ebx
0x07fb2a66:  je     0x7fb2b5c

----------------
IN: 
0x07fb2a6c:  movzwl 0x14(%ebx),%eax
0x07fb2a70:  shl    $0x8,%eax
0x07fb2a73:  movzbl 0x16(%ebx),%edx
0x07fb2a77:  or     %edx,%eax
0x07fb2a79:  cmp    $0xc0300,%eax
0x07fb2a7e:  jne    0x7fb2b51

----------------
IN: 
0x07fb2b51:  mov    0x4(%ebx),%ebx
0x07fb2b54:  sub    $0x4,%ebx
0x07fb2b57:  jmp    0x7fb2a63

----------------
IN: 
0x07fb2a63:  cmp    $0xfffffffc,%ebx
0x07fb2a66:  je     0x7fb2b5c

----------------
IN: 
0x07fb2b5c:  mov    0x7fbfed4,%eax
0x07fb2b61:  lea    -0x4(%eax),%ebx
0x07fb2b64:  cmp    $0xfffffffc,%ebx
0x07fb2b67:  je     0x7fb2c36

----------------
IN: 
0x07fb2b6d:  movzwl 0x14(%ebx),%eax
0x07fb2b71:  shl    $0x8,%eax
0x07fb2b74:  movzbl 0x16(%ebx),%edx
0x07fb2b78:  or     %edx,%eax
0x07fb2b7a:  cmp    $0xc0310,%eax
0x07fb2b7f:  jne    0x7fb2c2b

----------------
IN: 
0x07fb2c2b:  mov    0x4(%ebx),%ebx
0x07fb2c2e:  sub    $0x4,%ebx
0x07fb2c31:  jmp    0x7fb2b64

----------------
IN: 
0x07fb2b64:  cmp    $0xfffffffc,%ebx
0x07fb2b67:  je     0x7fb2c36

----------------
IN: 
0x07fb2c36:  add    $0x8,%esp
0x07fb2c39:  pop    %ebx
0x07fb2c3a:  pop    %esi
0x07fb2c3b:  pop    %edi
0x07fb2c3c:  pop    %ebp
0x07fb2c3d:  ret    

----------------
IN: 
0x07fb0a7a:  mov    %ebx,%eax
0x07fb0a7c:  mov    0x4(%ebx),%ebx
0x07fb0a7f:  mov    0xf6be4,%esp
0x07fb0a85:  call   0x7fb0f27

----------------
IN: 
0x07fb0f27:  push   %ebx
0x07fb0f28:  mov    %eax,%ebx
0x07fb0f2a:  lea    0x4(%eax),%eax
0x07fb0f2d:  call   0x7faf480

----------------
IN: 
0x07fb0f32:  mov    %ebx,%eax
0x07fb0f34:  call   0x7faf92b

----------------
IN: 
0x07fb0f39:  cmpl   $0xf6be8,0xf6be8
0x07fb0f43:  jne    0x7fb0f50

----------------
IN: 
0x07fb0f45:  push   $0xf3bab
0x07fb0f4a:  call   0xf0cc9

----------------
IN: 
0x07fb0f4f:  pop    %eax
0x07fb0f50:  pop    %ebx
0x07fb0f51:  ret    

----------------
IN: 
0x07fb0a8a:  mov    -0x4(%ebx),%esp
0x07fb0a8d:  pop    %ebp
0x07fb0a8e:  ret    

----------------
IN: 
0x07fb0a8f:  jmp    0x7fb0a95

----------------
IN: 
0x07fb0a95:  pop    %ebx
0x07fb0a96:  pop    %esi
0x07fb0a97:  pop    %edi
0x07fb0a98:  pop    %ebp
0x07fb0a99:  ret    

----------------
IN: 
0x07fba1fe:  mov    $0x2,%eax
0x07fba203:  call   0x7fb09b0

----------------
IN: 
0x07fba208:  mov    $0xfe987,%eax
0x07fba20d:  mov    %ax,0x24
0x07fba213:  movw   $0xf000,0x26
0x07fba21c:  mov    $0x1000,%eax
0x07fba221:  call   0x7fb09b0

----------------
IN: 
0x07fba226:  mov    $0xfd61a,%eax
0x07fba22b:  mov    %ax,0x1d0
0x07fba231:  movw   $0xf000,0x1d2
0x07fba23a:  xor    %edx,%edx
0x07fba23c:  mov    $0x7fb4956,%eax
0x07fba241:  call   0x7fb0a15

----------------
IN: 
0x07fb4956:  push   %esi
0x07fb4957:  push   %ebx
0x07fb4958:  push   %esi
0x07fb4959:  mov    $0x10,%ebx
0x07fb495e:  in     $0x64,%al
0x07fb4960:  test   $0x1,%al
0x07fb4962:  je     0x7fb49d6

----------------
IN: 
0x07fb49d6:  lea    0x2(%esp),%edx
0x07fb49da:  mov    $0x1aa,%eax
0x07fb49df:  call   0x7fb1984

----------------
IN: 
0x07fb1984:  push   %ebp
0x07fb1985:  push   %edi
0x07fb1986:  push   %esi
0x07fb1987:  push   %ebx
0x07fb1988:  push   %ecx
0x07fb1989:  mov    %eax,%ebx
0x07fb198b:  mov    %edx,%ebp
0x07fb198d:  call   0xf0cfc

----------------
IN: 
0x000f0cfc:  push   %ebx
0x000f0cfd:  mov    $0x2710,%ebx
0x000f0d02:  in     $0x64,%al
0x000f0d04:  test   $0x2,%al
0x000f0d06:  je     0xf0d29

----------------
IN: 
0x000f0d29:  xor    %eax,%eax
0x000f0d2b:  pop    %ebx
0x000f0d2c:  ret    

----------------
IN: 
0x07fb1992:  test   %eax,%eax
0x07fb1994:  jne    0x7fb1a05

----------------
IN: 
0x07fb1996:  mov    %bl,%al
0x07fb1998:  out    %al,$0x64
0x07fb199a:  mov    %ebp,%edi
0x07fb199c:  mov    %ebx,%esi
0x07fb199e:  sar    $0xc,%esi
0x07fb19a1:  and    $0xf,%esi
0x07fb19a4:  lea    0x0(%ebp,%esi,1),%eax
0x07fb19a8:  mov    %eax,(%esp)
0x07fb19ab:  mov    %ebp,%esi
0x07fb19ad:  cmp    (%esp),%esi
0x07fb19b0:  je     0x7fb19c2

----------------
IN: 
0x07fb19c2:  sar    $0x8,%ebx
0x07fb19c5:  and    $0xf,%ebx
0x07fb19c8:  add    %ebx,%ebp
0x07fb19ca:  cmp    %ebp,%edi
0x07fb19cc:  je     0x7fb19fa

----------------
IN: 
0x07fb19ce:  mov    $0x2710,%ebx
0x07fb19d3:  in     $0x64,%al
0x07fb19d5:  test   $0x1,%al
0x07fb19d7:  jne    0x7fb19fe

----------------
IN: 
0x07fb19fe:  in     $0x60,%al
0x07fb1a00:  mov    %al,(%edi)
0x07fb1a02:  inc    %edi
0x07fb1a03:  jmp    0x7fb19ca

----------------
IN: 
0x07fb19ca:  cmp    %ebp,%edi
0x07fb19cc:  je     0x7fb19fa

----------------
IN: 
0x07fb19fa:  xor    %eax,%eax
0x07fb19fc:  jmp    0x7fb1a05

----------------
IN: 
0x07fb1a05:  pop    %edx
0x07fb1a06:  pop    %ebx
0x07fb1a07:  pop    %esi
0x07fb1a08:  pop    %edi
0x07fb1a09:  pop    %ebp
0x07fb1a0a:  ret    

----------------
IN: 
0x07fb49e4:  test   %eax,%eax
0x07fb49e6:  jne    0x7fb4a8b

----------------
IN: 
0x07fb49ec:  movzbl 0x2(%esp),%eax
0x07fb49f1:  cmp    $0x55,%al
0x07fb49f3:  je     0x7fb49fd

----------------
IN: 
0x07fb49fd:  lea    0x2(%esp),%edx
0x07fb4a01:  mov    $0x1ab,%eax
0x07fb4a06:  call   0x7fb1984

----------------
IN: 
0x07fb4a0b:  test   %eax,%eax
0x07fb4a0d:  jne    0x7fb4a8b

----------------
IN: 
0x07fb4a0f:  movzbl 0x2(%esp),%eax
0x07fb4a14:  test   %al,%al
0x07fb4a16:  je     0x7fb497f

----------------
IN: 
0x07fb497f:  movb   $0x30,0xef690
0x07fb4986:  xor    %edx,%edx
0x07fb4988:  xor    %ecx,%ecx
0x07fb498a:  mov    $0xf45b0,%eax
0x07fb498f:  call   0x7fb0bfd

----------------
IN: 
0x07fb4994:  mov    %eax,%ebx
0x07fb4996:  call   0xf0817

----------------
IN: 
0x000f0817:  push   %ebx
0x000f0818:  mov    %eax,%ebx
0x000f081a:  call   0xf0732

----------------
IN: 
0x000f0732:  mov    0xf6ac0,%dx
0x000f0739:  test   %dx,%dx
0x000f073c:  jne    0xf0756

----------------
IN: 
0x000f0756:  push   %ebx
0x000f0757:  cmp    $0x40,%dx
0x000f075b:  mov    0xef698,%ebx
0x000f0761:  je     0xf0781

----------------
IN: 
0x000f0763:  in     (%dx),%eax
0x000f0764:  and    $0xffffff,%eax
0x000f0769:  mov    %eax,%edx
0x000f076b:  mov    %ebx,%ecx
0x000f076d:  and    $0xff000000,%ecx
0x000f0773:  or     %ecx,%edx
0x000f0775:  cmp    %ebx,%edx
0x000f0777:  jae    0xf07a7

----------------
IN: 
0x000f07a7:  mov    %edx,0xef698
0x000f07ad:  mov    %edx,%eax
0x000f07af:  pop    %ebx
0x000f07b0:  ret    

----------------
IN: 
0x000f081f:  imul   0xf6ac4,%ebx
0x000f0826:  add    %ebx,%eax
0x000f0828:  pop    %ebx
0x000f0829:  ret    

----------------
IN: 
0x07fb499b:  mov    %eax,%esi
0x07fb499d:  lea    0x2(%esp),%edx
0x07fb49a1:  mov    $0x2ff,%eax
0x07fb49a6:  call   0x7fb47b4

----------------
IN: 
0x07fb47b4:  push   %ebp
0x07fb47b5:  push   %edi
0x07fb47b6:  push   %esi
0x07fb47b7:  push   %ebx
0x07fb47b8:  sub    $0xc,%esp
0x07fb47bb:  mov    %eax,%esi
0x07fb47bd:  mov    %edx,%edi
0x07fb47bf:  mov    0xef690,%al
0x07fb47c4:  mov    %al,0xa(%esp)
0x07fb47c8:  and    $0xffffffcc,%eax
0x07fb47cb:  or     $0x30,%eax
0x07fb47ce:  mov    %al,0xb(%esp)
0x07fb47d2:  lea    0xb(%esp),%edx
0x07fb47d6:  mov    $0x1060,%eax
0x07fb47db:  call   0x7fb1984

----------------
IN: 
0x07fb19b2:  call   0xf0cfc

----------------
IN: 
0x07fb19b7:  test   %eax,%eax
0x07fb19b9:  jne    0x7fb1a05

----------------
IN: 
0x07fb19bb:  mov    (%esi),%al
0x07fb19bd:  out    %al,$0x60
0x07fb19bf:  inc    %esi
0x07fb19c0:  jmp    0x7fb19ad

----------------
IN: 
0x07fb19ad:  cmp    (%esp),%esi
0x07fb19b0:  je     0x7fb19c2

----------------
IN: 
0x07fb47e0:  test   %eax,%eax
0x07fb47e2:  jne    0x7fb494e

----------------
IN: 
0x07fb47e8:  call   0xf0b7e

----------------
IN: 
0x000f0b87:  and    $0xfffff000,%eax
0x000f0b8c:  cmp    $0xf6be4,%eax
0x000f0b91:  jne    0xf0ba6

----------------
IN: 
0x000f0ba6:  jmp    0xeff18

----------------
IN: 
0x000eff22:  push   %edi
0x000eff23:  push   %esi
0x000eff24:  push   %ebx
0x000eff25:  push   $0xeff31
0x000eff2a:  push   %ebp
0x000eff2b:  mov    %esp,(%eax)
0x000eff2d:  mov    (%ecx),%esp
0x000eff2f:  pop    %ebp
0x000eff30:  ret    

----------------
IN: 
0x07fba246:  mov    $0x37a,%edx
0x07fba24b:  in     (%dx),%al
0x07fba24c:  and    $0xffffffdf,%eax
0x07fba24f:  out    %al,(%dx)
0x07fba250:  mov    $0x78,%dl
0x07fba252:  mov    $0xaa,%al
0x07fba254:  out    %al,(%dx)
0x07fba255:  in     (%dx),%al
0x07fba256:  xor    %ecx,%ecx
0x07fba258:  cmp    $0xaa,%al
0x07fba25a:  jne    0x7fba26e

----------------
IN: 
0x07fba25c:  movw   $0x378,0x408
0x07fba265:  movb   $0x14,0x478
0x07fba26c:  mov    $0x1,%cl
0x07fba26e:  mov    $0x27a,%edx
0x07fba273:  in     (%dx),%al
0x07fba274:  and    $0xffffffdf,%eax
0x07fba277:  out    %al,(%dx)
0x07fba278:  mov    $0x78,%dl
0x07fba27a:  mov    $0xaa,%al
0x07fba27c:  out    %al,(%dx)
0x07fba27d:  in     (%dx),%al
0x07fba27e:  xor    %ebx,%ebx
0x07fba280:  cmp    $0xaa,%al
0x07fba282:  jne    0x7fba29a

----------------
IN: 
0x07fba29a:  add    %ecx,%ebx
0x07fba29c:  movzwl %bx,%eax
0x07fba29f:  push   %eax
0x07fba2a0:  push   $0xf5178
0x07fba2a5:  call   0xf0cc9

----------------
IN: 
0x07fba2aa:  mov    %ebx,%ecx
0x07fba2ac:  shl    $0xe,%ecx
0x07fba2af:  mov    0x410,%ebx
0x07fba2b5:  and    $0x3fff,%bx
0x07fba2ba:  or     %ebx,%ecx
0x07fba2bc:  mov    %cx,0x410
0x07fba2c3:  xor    %edx,%edx
0x07fba2c5:  mov    $0x3f8,%eax
0x07fba2ca:  call   0x7fb08bd

----------------
IN: 
0x07fb08bd:  push   %edi
0x07fb08be:  push   %esi
0x07fb08bf:  push   %ebx
0x07fb08c0:  mov    %eax,%esi
0x07fb08c2:  mov    %edx,%ebx
0x07fb08c4:  lea    0x1(%eax),%edi
0x07fb08c7:  mov    $0x2,%al
0x07fb08c9:  mov    %edi,%edx
0x07fb08cb:  out    %al,(%dx)
0x07fb08cc:  in     (%dx),%al
0x07fb08cd:  cmp    $0x2,%al
0x07fb08cf:  jne    0x7fb08fd

----------------
IN: 
0x07fb08d1:  lea    0x2(%esi),%edx
0x07fb08d4:  in     (%dx),%al
0x07fb08d5:  and    $0x3f,%eax
0x07fb08d8:  mov    %al,%cl
0x07fb08da:  xor    %eax,%eax
0x07fb08dc:  cmp    $0x2,%cl
0x07fb08df:  jne    0x7fb08ff

----------------
IN: 
0x07fb08e1:  mov    %edi,%edx
0x07fb08e3:  out    %al,(%dx)
0x07fb08e4:  movzbl %bl,%ebx
0x07fb08e7:  mov    %si,0x400(%ebx,%ebx,1)
0x07fb08ef:  movb   $0xa,0x47c(%ebx)
0x07fb08f6:  mov    $0x1,%eax
0x07fb08fb:  jmp    0x7fb08ff

----------------
IN: 
0x07fb08ff:  pop    %ebx
0x07fb0900:  pop    %esi
0x07fb0901:  pop    %edi
0x07fb0902:  ret    

----------------
IN: 
0x07fba2cf:  mov    %eax,%ebx
0x07fba2d1:  movzbl %al,%edx
0x07fba2d4:  mov    $0x2f8,%eax
0x07fba2d9:  call   0x7fb08bd

----------------
IN: 
0x07fb08fd:  xor    %eax,%eax
0x07fb08ff:  pop    %ebx
0x07fb0900:  pop    %esi
0x07fb0901:  pop    %edi
0x07fb0902:  ret    

----------------
IN: 
0x07fba2de:  add    %eax,%ebx
0x07fba2e0:  movzbl %bl,%edx
0x07fba2e3:  mov    $0x3e8,%eax
0x07fba2e8:  call   0x7fb08bd

----------------
IN: 
0x07fba2ed:  add    %eax,%ebx
0x07fba2ef:  movzbl %bl,%edx
0x07fba2f2:  mov    $0x2e8,%eax
0x07fba2f7:  call   0x7fb08bd

----------------
IN: 
0x07fba2fc:  add    %eax,%ebx
0x07fba2fe:  movzwl %bx,%eax
0x07fba301:  push   %eax
0x07fba302:  push   $0xf518c
0x07fba307:  call   0xf0cc9

----------------
IN: 
0x07fba30c:  shl    $0x9,%ebx
0x07fba30f:  mov    0x410,%eax
0x07fba314:  and    $0xf1,%ah
0x07fba317:  or     %eax,%ebx
0x07fba319:  mov    %bx,0x410
0x07fba320:  mov    $0xfefc7,%edx
0x07fba325:  mov    $0xf6aa4,%eax
0x07fba32a:  mov    $0xb,%ecx
0x07fba32f:  mov    %edx,%edi
0x07fba331:  mov    %eax,%esi
0x07fba333:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fba333:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fba335:  mov    %ax,0x78
0x07fba33b:  movw   $0xf000,0x7a
0x07fba344:  mov    $0x90,%al
0x07fba346:  out    %al,$0x70
0x07fba348:  in     $0x71,%al
0x07fba34a:  mov    %al,0x10(%esp)
0x07fba34e:  add    $0x10,%esp
0x07fba351:  test   $0xf0,%al
0x07fba353:  je     0x7fba364

----------------
IN: 
0x07fba355:  mov    %al,%dl
0x07fba357:  shr    $0x4,%dl
0x07fba35a:  movzbl %dl,%edx
0x07fba35d:  xor    %eax,%eax
0x07fba35f:  call   0x7fb915e

----------------
IN: 
0x07fb915e:  push   %edi
0x07fb915f:  push   %esi
0x07fb9160:  push   %ebx
0x07fb9161:  sub    $0x100,%esp
0x07fb9167:  mov    %eax,%esi
0x07fb9169:  mov    %edx,%edi
0x07fb916b:  lea    -0x1(%edx),%eax
0x07fb916e:  cmp    $0x7,%eax
0x07fb9171:  jbe    0x7fb9185

----------------
IN: 
0x07fb9185:  mov    $0x24,%eax
0x07fb918a:  call   0x7faf8f1

----------------
IN: 
0x07fb918f:  mov    %eax,%ebx
0x07fb9191:  test   %eax,%eax
0x07fb9193:  jne    0x7fb91a9

----------------
IN: 
0x07fb91a9:  mov    $0x24,%ecx
0x07fb91ae:  xor    %edx,%edx
0x07fb91b0:  call   0xf0090

----------------
IN: 
0x07fb91b5:  mov    %esi,0x14(%ebx)
0x07fb91b8:  movb   $0x10,(%ebx)
0x07fb91bb:  movw   $0x200,0x1a(%ebx)
0x07fb91c1:  mov    %edi,%eax
0x07fb91c3:  mov    %al,0x1(%ebx)
0x07fb91c6:  movl   $0xffffffff,0xc(%ebx)
0x07fb91cd:  movl   $0xffffffff,0x10(%ebx)
0x07fb91d4:  imul   $0xa,%edi,%edi
0x07fb91d7:  mov    0xf6a48(%edi),%eax
0x07fb91dd:  mov    %eax,0x2(%ebx)
0x07fb91e0:  mov    0xf6a4c(%edi),%eax
0x07fb91e6:  mov    %eax,0x6(%ebx)
0x07fb91e9:  lea    0x41(%esi),%eax
0x07fb91ec:  push   %eax
0x07fb91ed:  push   $0xf4ec3
0x07fb91f2:  push   $0x50
0x07fb91f4:  call   0x7fb87a1

----------------
IN: 
0x07fb87a1:  push   %esi
0x07fb87a2:  push   %ebx
0x07fb87a3:  sub    $0xc,%esp
0x07fb87a6:  mov    0x18(%esp),%esi
0x07fb87aa:  xor    %eax,%eax
0x07fb87ac:  test   %esi,%esi
0x07fb87ae:  je     0x7fb8804

----------------
IN: 
0x07fb87b0:  mov    %esi,%eax
0x07fb87b2:  call   0x7fb09cc

----------------
IN: 
0x07fb87b7:  mov    %eax,%ebx
0x07fb87b9:  test   %eax,%eax
0x07fb87bb:  jne    0x7fb87d0

----------------
IN: 
0x07fb87d0:  movl   $0x7faf4a0,(%esp)
0x07fb87d7:  mov    %eax,0x4(%esp)
0x07fb87db:  add    %eax,%esi
0x07fb87dd:  mov    %esi,0x8(%esp)
0x07fb87e1:  lea    0x20(%esp),%ecx
0x07fb87e5:  mov    0x1c(%esp),%edx
0x07fb87e9:  mov    %esp,%eax
0x07fb87eb:  call   0xf0854

----------------
IN: 
0x000f09c9:  cmp    $0x2e,%al
0x000f09cb:  jne    0xf09f9

----------------
IN: 
0x000f09f9:  cmp    $0x63,%al
0x000f09fb:  jne    0xf0a15

----------------
IN: 
0x000f09fd:  lea    0x4(%ebp),%eax
0x000f0a00:  mov    %eax,(%esp)
0x000f0a03:  movsbl 0x0(%ebp),%edx
0x000f0a07:  mov    %edi,%eax
0x000f0a09:  call   0xeff40

----------------
IN: 
0x07fb87f0:  mov    0x4(%esp),%eax
0x07fb87f4:  mov    0x8(%esp),%edx
0x07fb87f8:  cmp    %edx,%eax
0x07fb87fa:  jb     0x7fb87ff

----------------
IN: 
0x07fb87ff:  movb   $0x0,(%eax)
0x07fb8802:  mov    %ebx,%eax
0x07fb8804:  add    $0xc,%esp
0x07fb8807:  pop    %ebx
0x07fb8808:  pop    %esi
0x07fb8809:  ret    

----------------
IN: 
0x07fb91f9:  mov    %eax,%edi
0x07fb91fb:  mov    0x7fbfed4,%eax
0x07fb9200:  lea    -0x4(%eax),%ecx
0x07fb9203:  add    $0xc,%esp
0x07fb9206:  cmp    $0xfffffffc,%ecx
0x07fb9209:  je     0x7fb9257

----------------
IN: 
0x07fb920b:  cmpw   $0x601,0x14(%ecx)
0x07fb9211:  jne    0x7fb924f

----------------
IN: 
0x07fb924f:  mov    0x4(%ecx),%ecx
0x07fb9252:  sub    $0x4,%ecx
0x07fb9255:  jmp    0x7fb9206

----------------
IN: 
0x07fb9206:  cmp    $0xfffffffc,%ecx
0x07fb9209:  je     0x7fb9257

----------------
IN: 
0x07fb9213:  or     $0xffffffff,%eax
0x07fb9216:  test   %ecx,%ecx
0x07fb9218:  je     0x7fb925a

----------------
IN: 
0x07fb921a:  mov    $0xf4ed5,%edx
0x07fb921f:  mov    %esp,%eax
0x07fb9221:  call   0x7fb832a

----------------
IN: 
0x07fb832a:  push   %ebp
0x07fb832b:  push   %edi
0x07fb832c:  push   %esi
0x07fb832d:  push   %ebx
0x07fb832e:  push   %ebx
0x07fb832f:  mov    %edx,%edi
0x07fb8331:  mov    %ecx,%ebp
0x07fb8333:  mov    0xc(%ecx),%ecx
0x07fb8336:  test   %ecx,%ecx
0x07fb8338:  lea    0x100(%eax),%esi
0x07fb833e:  je     0x7fb834e

----------------
IN: 
0x07fb834e:  movzbl 0x2(%ebp),%edx
0x07fb8352:  mov    %eax,%ebx
0x07fb8354:  test   %dl,%dl
0x07fb8356:  je     0x7fb836e

----------------
IN: 
0x07fb836e:  push   $0xf4c6c
0x07fb8373:  push   $0xf4c77
0x07fb8378:  mov    %esi,%eax
0x07fb837a:  sub    %ebx,%eax
0x07fb837c:  push   %eax
0x07fb837d:  push   %ebx
0x07fb837e:  call   0x7fb5724

----------------
IN: 
0x07fb8383:  add    %eax,%ebx
0x07fb8385:  add    $0x10,%esp
0x07fb8388:  mov    0x0(%ebp),%eax
0x07fb838b:  mov    %al,%cl
0x07fb838d:  and    $0x7,%ecx
0x07fb8390:  mov    %cl,0x3(%esp)
0x07fb8394:  shr    $0x3,%ax
0x07fb8398:  and    $0x1f,%eax
0x07fb839b:  push   %eax
0x07fb839c:  push   %edi
0x07fb839d:  push   $0xf4c7a
0x07fb83a2:  mov    %esi,%eax
0x07fb83a4:  sub    %ebx,%eax
0x07fb83a6:  push   %eax
0x07fb83a7:  push   %ebx
0x07fb83a8:  call   0x7fb5724

----------------
IN: 
0x07fb83ad:  add    %eax,%ebx
0x07fb83af:  add    $0x14,%esp
0x07fb83b2:  movzbl 0x3(%esp),%ecx
0x07fb83b7:  test   %cl,%cl
0x07fb83b9:  je     0x7fb83cf

----------------
IN: 
0x07fb83cf:  mov    %ebx,%eax
0x07fb83d1:  pop    %edx
0x07fb83d2:  pop    %ebx
0x07fb83d3:  pop    %esi
0x07fb83d4:  pop    %edi
0x07fb83d5:  pop    %ebp
0x07fb83d6:  ret    

----------------
IN: 
0x07fb9226:  push   %esi
0x07fb9227:  push   $0x3f0
0x07fb922c:  push   $0xf4ed9
0x07fb9231:  lea    0x10c(%esp),%edx
0x07fb9238:  sub    %eax,%edx
0x07fb923a:  push   %edx
0x07fb923b:  push   %eax
0x07fb923c:  call   0x7fb5724

----------------
IN: 
0x07fb9241:  lea    0x14(%esp),%eax
0x07fb9245:  call   0x7fb26eb

----------------
IN: 
0x07fb26eb:  push   %ebp
0x07fb26ec:  push   %edi
0x07fb26ed:  push   %esi
0x07fb26ee:  push   %ebx
0x07fb26ef:  push   %ecx
0x07fb26f0:  mov    %eax,%esi
0x07fb26f2:  push   %eax
0x07fb26f3:  push   $0xf3e1a
0x07fb26f8:  call   0xf0cc9

----------------
IN: 
0x07fb26fd:  mov    0x7fbff2c,%ebp
0x07fb2703:  mov    0x7fbfe7c,%edi
0x07fb2709:  pop    %ebx
0x07fb270a:  pop    %eax
0x07fb270b:  xor    %edx,%edx
0x07fb270d:  cmp    %ebp,%edx
0x07fb270f:  jge    0x7fb275b

----------------
IN: 
0x07fb275b:  or     $0xffffffff,%eax
0x07fb275e:  pop    %edx
0x07fb275f:  pop    %ebx
0x07fb2760:  pop    %esi
0x07fb2761:  pop    %edi
0x07fb2762:  pop    %ebp
0x07fb2763:  ret    

----------------
IN: 
0x07fb924a:  add    $0x14,%esp
0x07fb924d:  jmp    0x7fb925a

----------------
IN: 
0x07fb925a:  mov    0x7fbfe78,%edx
0x07fb9260:  test   %eax,%eax
0x07fb9262:  js     0x7fb9266

----------------
IN: 
0x07fb9266:  push   %edi
0x07fb9267:  mov    %ebx,%ecx
0x07fb9269:  mov    $0x1,%eax
0x07fb926e:  call   0x7fb112c

----------------
IN: 
0x07fb112c:  push   %ebp
0x07fb112d:  push   %edi
0x07fb112e:  push   %esi
0x07fb112f:  push   %ebx
0x07fb1130:  push   %esi
0x07fb1131:  mov    %eax,%esi
0x07fb1133:  mov    %edx,%ebp
0x07fb1135:  mov    %ecx,%edi
0x07fb1137:  mov    0x18(%esp),%ebx
0x07fb113b:  mov    $0x18,%eax
0x07fb1140:  call   0x7fb09cc

----------------
IN: 
0x07fb1145:  test   %eax,%eax
0x07fb1147:  jne    0x7fb115c

----------------
IN: 
0x07fb115c:  mov    %esi,(%eax)
0x07fb115e:  mov    %ebp,0x8(%eax)
0x07fb1161:  mov    %edi,0x4(%eax)
0x07fb1164:  mov    $0xf3bf3,%edx
0x07fb1169:  test   %ebx,%ebx
0x07fb116b:  je     0x7fb116f

----------------
IN: 
0x07fb116d:  mov    %ebx,%edx
0x07fb116f:  mov    %edx,0xc(%eax)
0x07fb1172:  mov    0x7fbfe68,%ebx
0x07fb1178:  movl   $0x7fbfe68,(%esp)
0x07fb117f:  test   %ebx,%ebx
0x07fb1181:  jne    0x7fb1193

----------------
IN: 
0x07fb1183:  add    $0x10,%eax
0x07fb1186:  mov    (%esp),%edx
0x07fb1189:  pop    %ecx
0x07fb118a:  pop    %ebx
0x07fb118b:  pop    %esi
0x07fb118c:  pop    %edi
0x07fb118d:  pop    %ebp
0x07fb118e:  jmp    0x7faf48f

----------------
IN: 
0x07fb9273:  pop    %eax
0x07fb9274:  add    $0x100,%esp
0x07fb927a:  pop    %ebx
0x07fb927b:  pop    %esi
0x07fb927c:  pop    %edi
0x07fb927d:  ret    

----------------
IN: 
0x07fba364:  mov    (%esp),%dl
0x07fba367:  and    $0xf,%dl
0x07fba36a:  je     0x7fba379

----------------
IN: 
0x07fba379:  mov    $0x40,%eax
0x07fba37e:  call   0x7fb09b0

----------------
IN: 
0x07fba383:  mov    $0xfef57,%eax
0x07fba388:  mov    %ax,0x38
0x07fba38e:  movw   $0xf000,0x3a
0x07fba397:  mov    $0x7d00,%eax
0x07fba39c:  call   0xf0817

----------------
IN: 
0x07fba3a1:  mov    %eax,0x7fbff30
0x07fba3a6:  mov    0x7fbfed4,%eax
0x07fba3ab:  lea    -0x4(%eax),%ebx
0x07fba3ae:  test   %eax,%eax
0x07fba3b0:  jne    0x7fba3e0

----------------
IN: 
0x07fba3e0:  cmp    $0xfffffffc,%ebx
0x07fba3e3:  je     0x7fba3fb

----------------
IN: 
0x07fba3e5:  xor    %ecx,%ecx
0x07fba3e7:  mov    %ebx,%edx
0x07fba3e9:  mov    $0x7fbfc4c,%eax
0x07fba3ee:  call   0x7faf57e

----------------
IN: 
0x07fba3f3:  mov    0x4(%ebx),%ebx
0x07fba3f6:  sub    $0x4,%ebx
0x07fba3f9:  jmp    0x7fba3e0

----------------
IN: 
0x07fb4631:  push   %ebp
0x07fb4632:  push   %edi
0x07fb4633:  push   %esi
0x07fb4634:  push   %ebx
0x07fb4635:  push   %ebx
0x07fb4636:  mov    %eax,%ebx
0x07fb4638:  movzbl 0x16(%eax),%edi
0x07fb463c:  movl   $0x1,0x1c(%eax)
0x07fb4643:  movzwl (%eax),%esi
0x07fb4646:  mov    $0x3c,%edx
0x07fb464b:  mov    %esi,%eax
0x07fb464d:  call   0xf013a

----------------
IN: 
0x07fb4652:  mov    %al,0x3(%esp)
0x07fb4656:  test   $0x1,%edi
0x07fb465c:  je     0x7fb4685

----------------
IN: 
0x07fb4685:  mov    $0xe,%edx
0x07fb468a:  mov    $0x3f4,%eax
0x07fb468f:  mov    $0x1f0,%ebp
0x07fb4694:  push   %eax
0x07fb4695:  mov    %ebp,%ecx
0x07fb4697:  mov    %ebx,%eax
0x07fb4699:  call   0x7fb4591

----------------
IN: 
0x07fb4591:  push   %ebp
0x07fb4592:  push   %edi
0x07fb4593:  push   %esi
0x07fb4594:  push   %ebx
0x07fb4595:  sub    $0x8,%esp
0x07fb4598:  mov    %eax,%edi
0x07fb459a:  mov    %edx,0x4(%esp)
0x07fb459e:  mov    %ecx,%ebp
0x07fb45a0:  mov    0x1c(%esp),%ecx
0x07fb45a4:  mov    %ecx,(%esp)
0x07fb45a7:  mov    $0x10,%eax
0x07fb45ac:  call   0x7faf8f1

----------------
IN: 
0x07fb45b1:  mov    %eax,%ebx
0x07fb45b3:  test   %eax,%eax
0x07fb45b5:  mov    (%esp),%ecx
0x07fb45b8:  mov    0x4(%esp),%edx
0x07fb45bc:  jne    0x7fb45d4

----------------
IN: 
0x07fb45d4:  mov    0x7fbfef8,%esi
0x07fb45da:  lea    0x1(%esi),%eax
0x07fb45dd:  mov    %eax,(%esp)
0x07fb45e0:  mov    %eax,0x7fbfef8
0x07fb45e5:  mov    %esi,%eax
0x07fb45e7:  mov    %al,0x7(%ebx)
0x07fb45ea:  mov    %dl,0x6(%ebx)
0x07fb45ed:  or     $0xffffffff,%esi
0x07fb45f0:  test   %edi,%edi
0x07fb45f2:  je     0x7fb45f7

----------------
IN: 
0x07fb45f4:  movzwl (%edi),%esi
0x07fb45f7:  mov    %esi,0x8(%ebx)
0x07fb45fa:  mov    %edi,0xc(%ebx)
0x07fb45fd:  mov    %bp,(%ebx)
0x07fb4600:  mov    %cx,0x2(%ebx)
0x07fb4604:  movw   $0x0,0x4(%ebx)
0x07fb460a:  push   %esi
0x07fb460b:  push   %edx
0x07fb460c:  push   $0x0
0x07fb460e:  push   %ecx
0x07fb460f:  push   %ebp
0x07fb4610:  pushl  0x14(%esp)
0x07fb4614:  push   $0xf44e8
0x07fb4619:  call   0xf0cc9

----------------
IN: 
0x07fb461e:  mov    %ebx,%edx
0x07fb4620:  mov    $0x7fb880a,%eax
0x07fb4625:  add    $0x24,%esp
0x07fb4628:  pop    %ebx
0x07fb4629:  pop    %esi
0x07fb462a:  pop    %edi
0x07fb462b:  pop    %ebp
0x07fb462c:  jmp    0x7fb0a15

----------------
IN: 
0x07fb880a:  push   %ebp
0x07fb880b:  push   %edi
0x07fb880c:  push   %esi
0x07fb880d:  push   %ebx
0x07fb880e:  sub    $0x26c,%esp
0x07fb8814:  mov    %eax,0x10(%esp)
0x07fb8818:  lea    0x40(%esp),%ebx
0x07fb881c:  mov    $0x2c,%ecx
0x07fb8821:  xor    %edx,%edx
0x07fb8823:  mov    %ebx,%eax
0x07fb8825:  call   0xf0090

----------------
IN: 
0x07fb882a:  mov    0x10(%esp),%eax
0x07fb882e:  mov    %eax,0x64(%esp)
0x07fb8832:  movb   $0x0,0x3(%esp)
0x07fb8837:  xor    %edi,%edi
0x07fb8839:  mov    %ebx,0x4(%esp)
0x07fb883d:  mov    0x10(%esp),%eax
0x07fb8841:  movzwl (%eax),%eax
0x07fb8844:  mov    %eax,%ebp
0x07fb8846:  mov    %eax,0x8(%esp)
0x07fb884a:  call   0x7fb2173

----------------
IN: 
0x07fb2173:  push   %esi
0x07fb2174:  push   %ebx
0x07fb2175:  xor    %ebx,%ebx
0x07fb2177:  lea    0x7(%eax),%esi
0x07fb217a:  mov    %esi,%edx
0x07fb217c:  in     (%dx),%al
0x07fb217d:  test   %al,%al
0x07fb217f:  jns    0x7fb21b1

----------------
IN: 
0x07fb21b1:  movzbl %al,%eax
0x07fb21b4:  jmp    0x7fb21bb

----------------
IN: 
0x07fb21bb:  pop    %ebx
0x07fb21bc:  pop    %esi
0x07fb21bd:  ret    

----------------
IN: 
0x07fb884f:  test   %eax,%eax
0x07fb8851:  js     0x7fb8bc3

----------------
IN: 
0x07fb8857:  cmpb   $0x1,0x3(%esp)
0x07fb885c:  sbb    %ebx,%ebx
0x07fb885e:  and    $0xfffffff0,%ebx
0x07fb8861:  sub    $0x50,%ebx
0x07fb8864:  lea    0x6(%ebp),%edx
0x07fb8867:  mov    %bl,%al
0x07fb8869:  out    %al,(%dx)
0x07fb886a:  mov    %edx,0xc(%esp)
0x07fb886e:  call   0xf07fa

----------------
IN: 
0x000f07fa:  imul   $0x190,0xf6ac4,%eax
0x000f0804:  add    $0xf423f,%eax
0x000f0809:  mov    $0xf4240,%ecx
0x000f080e:  xor    %edx,%edx
0x000f0810:  div    %ecx
0x000f0812:  jmp    0xf07c5

----------------
IN: 
0x000f07c5:  push   %ebx
0x000f07c6:  mov    %eax,%ebx
0x000f07c8:  call   0xf0732

----------------
IN: 
0x000f07cd:  add    %eax,%ebx
0x000f07cf:  mov    %ebx,%eax
0x000f07d1:  call   0xf07b1

----------------
IN: 
0x000f07b1:  push   %ebx
0x000f07b2:  mov    %eax,%ebx
0x000f07b4:  call   0xf0732

----------------
IN: 
0x000f07b9:  sub    %ebx,%eax
0x000f07bb:  test   %eax,%eax
0x000f07bd:  setg   %al
0x000f07c0:  movzbl %al,%eax
0x000f07c3:  pop    %ebx
0x000f07c4:  ret    

----------------
IN: 
0x000f07d6:  test   %eax,%eax
0x000f07d8:  jne    0xf07de

----------------
IN: 
0x000f07de:  pop    %ebx
0x000f07df:  ret    

----------------
IN: 
0x07fb8873:  mov    0x8(%esp),%eax
0x07fb8877:  call   0x7fb2173

----------------
IN: 
0x07fb887c:  test   %eax,%eax
0x07fb887e:  js     0x7fb8bc3

----------------
IN: 
0x07fb8884:  mov    %bl,%al
0x07fb8886:  mov    0xc(%esp),%edx
0x07fb888a:  out    %al,(%dx)
0x07fb888b:  in     (%dx),%al
0x07fb888c:  mov    %al,0xc(%esp)
0x07fb8890:  lea    0x2(%ebp),%ecx
0x07fb8893:  mov    $0x55,%al
0x07fb8895:  mov    %ecx,%edx
0x07fb8897:  out    %al,(%dx)
0x07fb8898:  lea    0x3(%ebp),%esi
0x07fb889b:  mov    $0xaa,%al
0x07fb889d:  mov    %esi,%edx
0x07fb889f:  out    %al,(%dx)
0x07fb88a0:  mov    %ecx,%edx
0x07fb88a2:  in     (%dx),%al
0x07fb88a3:  mov    %al,%cl
0x07fb88a5:  mov    %esi,%edx
0x07fb88a7:  in     (%dx),%al
0x07fb88a8:  cmp    $0xaa,%al
0x07fb88aa:  setne  %dl
0x07fb88ad:  cmp    $0x55,%cl
0x07fb88b0:  setne  %al
0x07fb88b3:  or     %al,%dl
0x07fb88b5:  jne    0x7fb8bc3

----------------
IN: 
0x07fb88bb:  cmp    %bl,0xc(%esp)
0x07fb88bf:  jne    0x7fb8bc3

----------------
IN: 
0x07fb88c5:  mov    0x3(%esp),%al
0x07fb88c9:  mov    %al,0x68(%esp)
0x07fb88cd:  test   %edi,%edi
0x07fb88cf:  jne    0x7fb898a

----------------
IN: 
0x07fb88d5:  mov    0x64(%esp),%eax
0x07fb88d9:  movzwl (%eax),%esi
0x07fb88dc:  mov    %esi,%ebx
0x07fb88de:  mov    0x2(%eax),%ax
0x07fb88e2:  add    $0x2,%eax
0x07fb88e5:  mov    %ax,0xc(%esp)
0x07fb88ea:  mov    $0xe,%al
0x07fb88ec:  mov    0xc(%esp),%edx
0x07fb88f0:  out    %al,(%dx)
0x07fb88f1:  mov    $0x5,%eax
0x07fb88f6:  call   0xf07e0

----------------
IN: 
0x000f07e0:  imul   0xf6ac4,%eax
0x000f07e7:  add    $0x3e7,%eax
0x000f07ec:  mov    $0x3e8,%ecx
0x000f07f1:  xor    %edx,%edx
0x000f07f3:  div    %ecx
0x000f07f5:  jmp    0xf07c5

----------------
IN: 
0x000f07da:  pause  

----------------
IN: 
0x000f07dc:  jmp    0xf07cf

----------------
IN: 
0x000f07cf:  mov    %ebx,%eax
0x000f07d1:  call   0xf07b1

----------------
IN: 
0x07fb88fb:  mov    $0xa,%al
0x07fb88fd:  mov    0xc(%esp),%edx
0x07fb8901:  out    %al,(%dx)
0x07fb8902:  mov    $0x2,%eax
0x07fb8907:  call   0x7fb0d6c

----------------
IN: 
0x07fb0d6c:  imul   0xf6ac4,%eax
0x07fb0d73:  jmp    0xf0be1

----------------
IN: 
0x000f0be1:  push   %ebx
0x000f0be2:  mov    %eax,%ebx
0x000f0be4:  call   0xf0732

----------------
IN: 
0x000f0be9:  add    %eax,%ebx
0x000f0beb:  mov    %ebx,%eax
0x000f0bed:  call   0xf07b1

----------------
IN: 
0x000f0bf2:  test   %eax,%eax
0x000f0bf4:  jne    0xf0bfd

----------------
IN: 
0x000f0bf6:  call   0xf0b7e

----------------
IN: 
0x000eff31:  pop    %ebx
0x000eff32:  pop    %esi
0x000eff33:  pop    %edi
0x000eff34:  ret    

----------------
IN: 
0x07fb47ed:  andb   $0xef,0xb(%esp)
0x07fb47f2:  lea    0xb(%esp),%edx
0x07fb47f6:  mov    $0x1060,%eax
0x07fb47fb:  call   0x7fb1984

----------------
IN: 
0x07fb4800:  mov    %eax,%ebx
0x07fb4802:  test   %eax,%eax
0x07fb4804:  jne    0x7fb493a

----------------
IN: 
0x07fb480a:  cmp    $0x2ff,%esi
0x07fb4810:  jne    0x7fb4858

----------------
IN: 
0x07fb4812:  mov    $0x3e8,%edx
0x07fb4817:  mov    $0xff,%eax
0x07fb481c:  call   0x7fb477a

----------------
IN: 
0x07fb477a:  push   %ebx
0x07fb477b:  push   %ecx
0x07fb477c:  mov    %eax,%ebx
0x07fb477e:  mov    %edx,(%esp)
0x07fb4781:  call   0xf0cfc

----------------
IN: 
0x07fb4786:  mov    %eax,%edx
0x07fb4788:  test   %eax,%eax
0x07fb478a:  jne    0x7fb47af

----------------
IN: 
0x07fb478c:  mov    %bl,%al
0x07fb478e:  out    %al,$0x60
0x07fb4790:  mov    (%esp),%edx
0x07fb4793:  mov    $0x1,%eax
0x07fb4798:  call   0x7fb46ec

----------------
IN: 
0x07fb46ec:  push   %edi
0x07fb46ed:  push   %esi
0x07fb46ee:  push   %ebx
0x07fb46ef:  mov    %eax,%edi
0x07fb46f1:  mov    %edx,%esi
0x07fb46f3:  mov    %edx,%eax
0x07fb46f5:  call   0xf0817

----------------
IN: 
0x07fb46fa:  mov    %eax,%ebx
0x07fb46fc:  in     $0x64,%al
0x07fb46fe:  movzbl %al,%ecx
0x07fb4701:  test   $0x1,%cl
0x07fb4704:  je     0x7fb4744

----------------
IN: 
0x07fb4706:  in     $0x60,%al
0x07fb4708:  test   $0x20,%cl
0x07fb470b:  jne    0x7fb4732

----------------
IN: 
0x07fb470d:  test   %edi,%edi
0x07fb470f:  jne    0x7fb4716

----------------
IN: 
0x07fb4716:  cmp    $0xfa,%al
0x07fb4718:  je     0x7fb476f

----------------
IN: 
0x07fb476f:  mov    $0xfa,%ebx
0x07fb4774:  mov    %ebx,%eax
0x07fb4776:  pop    %ebx
0x07fb4777:  pop    %esi
0x07fb4778:  pop    %edi
0x07fb4779:  ret    

----------------
IN: 
0x07fb479d:  mov    %eax,%edx
0x07fb479f:  test   %eax,%eax
0x07fb47a1:  js     0x7fb47af

----------------
IN: 
0x07fb47a3:  xor    %edx,%edx
0x07fb47a5:  cmp    $0xfa,%eax
0x07fb47aa:  setne  %dl
0x07fb47ad:  neg    %edx
0x07fb47af:  mov    %edx,%eax
0x07fb47b1:  pop    %edx
0x07fb47b2:  pop    %ebx
0x07fb47b3:  ret    

----------------
IN: 
0x07fb4821:  mov    %eax,%ebx
0x07fb4823:  test   %eax,%eax
0x07fb4825:  jne    0x7fb493a

----------------
IN: 
0x07fb482b:  mov    $0xfa0,%edx
0x07fb4830:  xor    %eax,%eax
0x07fb4832:  call   0x7fb46ec

----------------
IN: 
0x07fb4711:  movzbl %al,%ebx
0x07fb4714:  jmp    0x7fb4774

----------------
IN: 
0x07fb4774:  mov    %ebx,%eax
0x07fb4776:  pop    %ebx
0x07fb4777:  pop    %esi
0x07fb4778:  pop    %edi
0x07fb4779:  ret    

----------------
IN: 
0x07fb4837:  test   %eax,%eax
0x07fb4839:  js     0x7fb4938

----------------
IN: 
0x07fb483f:  mov    %al,(%edi)
0x07fb4841:  mov    $0x64,%edx
0x07fb4846:  xor    %eax,%eax
0x07fb4848:  call   0x7fb46ec

----------------
IN: 
0x07fb4744:  mov    %ebx,%eax
0x07fb4746:  call   0xf07b1

----------------
IN: 
0x07fb474b:  test   %eax,%eax
0x07fb474d:  je     0x7fb4768

----------------
IN: 
0x07fb4768:  call   0xf0b7e

----------------
IN: 
0x07fb469e:  pop    %ecx
0x07fb469f:  and    $0x4,%edi
0x07fb46a2:  je     0x7fb46cb

----------------
IN: 
0x07fb46cb:  mov    $0xf,%edx
0x07fb46d0:  mov    $0x374,%eax
0x07fb46d5:  mov    $0x170,%edi
0x07fb46da:  push   %eax
0x07fb46db:  mov    %edi,%ecx
0x07fb46dd:  mov    %ebx,%eax
0x07fb46df:  call   0x7fb4591

----------------
IN: 
0x000f0bfb:  jmp    0xf0beb

----------------
IN: 
0x000f0beb:  mov    %ebx,%eax
0x000f0bed:  call   0xf07b1

----------------
IN: 
0x07fb476d:  jmp    0x7fb46fc

----------------
IN: 
0x07fb46fc:  in     $0x64,%al
0x07fb46fe:  movzbl %al,%ecx
0x07fb4701:  test   $0x1,%cl
0x07fb4704:  je     0x7fb4744

----------------
IN: 
0x07fb46e4:  add    $0x8,%esp
0x07fb46e7:  pop    %ebx
0x07fb46e8:  pop    %esi
0x07fb46e9:  pop    %edi
0x07fb46ea:  pop    %ebp
0x07fb46eb:  ret    

----------------
IN: 
0x07fba3fb:  movb   $0xc0,0x476
0x07fba402:  mov    $0x4000,%eax
0x07fba407:  call   0x7fb09b0

----------------
IN: 
0x07fba40c:  mov    $0xfd608,%eax
0x07fba411:  mov    %ax,0x1d8
0x07fba417:  movw   $0xf000,0x1da
0x07fba420:  mov    0x7fbfed4,%eax
0x07fba425:  lea    -0x4(%eax),%edi
0x07fba428:  cmp    $0xfffffffc,%edi
0x07fba42b:  je     0x7fba609

----------------
IN: 
0x07fba431:  cmpw   $0x106,0x14(%edi)
0x07fba437:  jne    0x7fba5fe

----------------
IN: 
0x07fba5fe:  mov    0x4(%edi),%edi
0x07fba601:  sub    $0x4,%edi
0x07fba604:  jmp    0x7fba428

----------------
IN: 
0x07fba428:  cmp    $0xfffffffc,%edi
0x07fba42b:  je     0x7fba609

----------------
IN: 
0x07fba609:  mov    0x7fbfed4,%eax
0x07fba60e:  lea    -0x4(%eax),%ebx
0x07fba611:  cmp    $0xfffffffc,%ebx
0x07fba614:  je     0x7fba638

----------------
IN: 
0x07fba616:  cmpw   $0x805,0x14(%ebx)
0x07fba61c:  jne    0x7fba630

----------------
IN: 
0x07fba630:  mov    0x4(%ebx),%ebx
0x07fba633:  sub    $0x4,%ebx
0x07fba636:  jmp    0x7fba611

----------------
IN: 
0x07fba611:  cmp    $0xfffffffc,%ebx
0x07fba614:  je     0x7fba638

----------------
IN: 
0x07fba638:  mov    0x7fbfed4,%eax
0x07fba63d:  lea    -0x4(%eax),%ebx
0x07fba640:  cmp    $0xfffffffc,%ebx
0x07fba643:  je     0x7fba65d

----------------
IN: 
0x07fba645:  cmpl   $0x10011af4,0x10(%ebx)
0x07fba64c:  jne    0x7fba655

----------------
IN: 
0x07fba655:  mov    0x4(%ebx),%ebx
0x07fba658:  sub    $0x4,%ebx
0x07fba65b:  jmp    0x7fba640

----------------
IN: 
0x07fba640:  cmp    $0xfffffffc,%ebx
0x07fba643:  je     0x7fba65d

----------------
IN: 
0x07fba65d:  mov    0x7fbfed4,%eax
0x07fba662:  lea    -0x4(%eax),%ebx
0x07fba665:  cmp    $0xfffffffc,%ebx
0x07fba668:  je     0x7fba79c

----------------
IN: 
0x07fba66e:  cmpl   $0x10041af4,0x10(%ebx)
0x07fba675:  jne    0x7fba791

----------------
IN: 
0x07fba791:  mov    0x4(%ebx),%ebx
0x07fba794:  sub    $0x4,%ebx
0x07fba797:  jmp    0x7fba665

----------------
IN: 
0x07fba665:  cmp    $0xfffffffc,%ebx
0x07fba668:  je     0x7fba79c

----------------
IN: 
0x07fba79c:  mov    0x7fbfed4,%eax
0x07fba7a1:  lea    -0x4(%eax),%ebx
0x07fba7a4:  cmp    $0xfffffffc,%ebx
0x07fba7a7:  je     0x7fba8c8

----------------
IN: 
0x07fba7ad:  cmpl   $0x121000,0x10(%ebx)
0x07fba7b4:  jne    0x7fba8bd

----------------
IN: 
0x07fba8bd:  mov    0x4(%ebx),%ebx
0x07fba8c0:  sub    $0x4,%ebx
0x07fba8c3:  jmp    0x7fba7a4

----------------
IN: 
0x07fba7a4:  cmp    $0xfffffffc,%ebx
0x07fba7a7:  je     0x7fba8c8

----------------
IN: 
0x07fba8c8:  mov    0x7fbfed4,%eax
0x07fba8cd:  lea    -0x4(%eax),%ebx
0x07fba8d0:  cmp    $0xfffffffc,%ebx
0x07fba8d3:  je     0x7fba9f4

----------------
IN: 
0x07fba8d9:  cmpl   $0x20201022,0x10(%ebx)
0x07fba8e0:  jne    0x7fba9e9

----------------
IN: 
0x07fba9e9:  mov    0x4(%ebx),%ebx
0x07fba9ec:  sub    $0x4,%ebx
0x07fba9ef:  jmp    0x7fba8d0

----------------
IN: 
0x07fba8d0:  cmp    $0xfffffffc,%ebx
0x07fba8d3:  je     0x7fba9f4

----------------
IN: 
0x07fba9f4:  mov    0x7fbfed4,%eax
0x07fba9f9:  lea    -0x4(%eax),%esi
0x07fba9fc:  cmp    $0xfffffffc,%esi
0x07fba9ff:  je     0x7fbac66

----------------
IN: 
0x07fbaa05:  mov    0x10(%esi),%eax
0x07fbaa08:  cmp    $0x1028,%ax
0x07fbaa0c:  je     0x7fbaa18

----------------
IN: 
0x07fbaa0e:  cmp    $0x1000,%ax
0x07fbaa12:  jne    0x7fbac5b

----------------
IN: 
0x07fbac5b:  mov    0x4(%esi),%esi
0x07fbac5e:  sub    $0x4,%esi
0x07fbac61:  jmp    0x7fba9fc

----------------
IN: 
0x07fba9fc:  cmp    $0xfffffffc,%esi
0x07fba9ff:  je     0x7fbac66

----------------
IN: 
0x07fbac66:  mov    0x7fbfed4,%eax
0x07fbac6b:  lea    -0x4(%eax),%ebx
0x07fbac6e:  cmp    $0xfffffffc,%ebx
0x07fbac71:  je     0x7fbadb9

----------------
IN: 
0x07fbac77:  cmpl   $0x7c015ad,0x10(%ebx)
0x07fbac7e:  jne    0x7fbada0

----------------
IN: 
0x07fbada0:  mov    0x4(%ebx),%ebx
0x07fbada3:  sub    $0x4,%ebx
0x07fbada6:  jmp    0x7fbac6e

----------------
IN: 
0x07fbac6e:  cmp    $0xfffffffc,%ebx
0x07fbac71:  je     0x7fbadb9

----------------
IN: 
0x07fbadb9:  add    $0x18,%esp
0x07fbadbc:  pop    %ebx
0x07fbadbd:  pop    %esi
0x07fbadbe:  pop    %edi
0x07fbadbf:  pop    %ebp
0x07fbadc0:  ret    

----------------
IN: 
0x07fbbd0e:  call   0x7fb0d15

----------------
IN: 
0x07fb0d15:  cmpl   $0xf6be8,0xf6be8
0x07fb0d1f:  je     0x7fb0d28

----------------
IN: 
0x07fb0d21:  call   0xf0b7e

Servicing hardware INT=0x09
----------------
IN: 
0x000fe987:  pushl  $0xd0fb
0x000fe98d:  jmp    0xfd4d0

----------------
IN: 
0x000fd0fb:  in     $0x64,%al
0x000fd0fd:  test   $0x20,%al
0x000fd0ff:  je     0xfd111

----------------
IN: 
0x000fd111:  in     $0x60,%al
0x000fd113:  mov    $0xe000,%edx
0x000fd119:  mov    %dx,%es
0x000fd11b:  mov    %es:-0x970,%dl
0x000fd120:  and    $0x1,%dl
0x000fd123:  je     0xfd13e

----------------
IN: 
0x000fd13e:  mov    $0x20,%al
0x000fd140:  out    %al,$0x20
0x000fd142:  retl   

----------------
IN: 
0x000f0bfd:  pop    %ebx
0x000f0bfe:  ret    

----------------
IN: 
0x07fb890c:  mov    %esi,%eax
0x07fb890e:  call   0xf0e93

----------------
IN: 
0x000f0e93:  movzwl %ax,%ecx
0x000f0e96:  xor    %edx,%edx
0x000f0e98:  mov    $0x80,%eax
0x000f0e9d:  jmp    0xf0e3d

----------------
IN: 
0x000f0e3d:  push   %ebp
0x000f0e3e:  push   %edi
0x000f0e3f:  push   %esi
0x000f0e40:  push   %ebx
0x000f0e41:  mov    %eax,%esi
0x000f0e43:  mov    %edx,%edi
0x000f0e45:  mov    %ecx,%ebx
0x000f0e47:  mov    $0x7d00,%eax
0x000f0e4c:  call   0xf0817

----------------
IN: 
0x000f0e51:  mov    %eax,%ebp
0x000f0e53:  add    $0x7,%ebx
0x000f0e56:  mov    %ebx,%edx
0x000f0e58:  in     (%dx),%al
0x000f0e59:  mov    %esi,%edx
0x000f0e5b:  and    %eax,%edx
0x000f0e5d:  mov    %edi,%ecx
0x000f0e5f:  cmp    %cl,%dl
0x000f0e61:  jne    0xf0e68

----------------
IN: 
0x000f0e63:  movzbl %al,%eax
0x000f0e66:  jmp    0xf0e8e

----------------
IN: 
0x000f0e8e:  pop    %ebx
0x000f0e8f:  pop    %esi
0x000f0e90:  pop    %edi
0x000f0e91:  pop    %ebp
0x000f0e92:  ret    

----------------
IN: 
0x07fb8913:  test   %eax,%eax
0x07fb8915:  js     0x7fb8983

----------------
IN: 
0x07fb8917:  cmpb   $0x0,0x3(%esp)
0x07fb891c:  je     0x7fb8965

----------------
IN: 
0x07fb8965:  lea    0x6(%esi),%edx
0x07fb8968:  mov    $0xa0,%al
0x07fb896a:  out    %al,(%dx)
0x07fb896b:  cmpb   $0x20,0x40(%esp)
0x07fb8970:  jne    0x7fb8983

----------------
IN: 
0x07fb8983:  mov    $0x8,%al
0x07fb8985:  mov    0xc(%esp),%edx
0x07fb8989:  out    %al,(%dx)
0x07fb898a:  mov    $0xa1,%ecx
0x07fb898f:  lea    0x6c(%esp),%edx
0x07fb8993:  mov    0x4(%esp),%eax
0x07fb8997:  call   0x7fb20c5

----------------
IN: 
0x07fb20c5:  push   %edi
0x07fb20c6:  push   %esi
0x07fb20c7:  push   %ebx
0x07fb20c8:  sub    $0x20,%esp
0x07fb20cb:  mov    %eax,%edi
0x07fb20cd:  mov    %edx,%ebx
0x07fb20cf:  mov    %ecx,%esi
0x07fb20d1:  mov    $0x200,%ecx
0x07fb20d6:  xor    %edx,%edx
0x07fb20d8:  mov    %ebx,%eax
0x07fb20da:  call   0xf0090

----------------
IN: 
0x07fb20df:  mov    $0x14,%ecx
0x07fb20e4:  xor    %edx,%edx
0x07fb20e6:  lea    0xc(%esp),%eax
0x07fb20ea:  call   0xf0090

----------------
IN: 
0x07fb20ef:  mov    %edi,0x18(%esp)
0x07fb20f3:  movw   $0x1,0x1c(%esp)
0x07fb20fa:  movl   $0x1,0xc(%esp)
0x07fb2102:  movl   $0x0,0x10(%esp)
0x07fb210a:  mov    %ebx,0x14(%esp)
0x07fb210e:  mov    $0xc,%ecx
0x07fb2113:  xor    %edx,%edx
0x07fb2115:  mov    %esp,%eax
0x07fb2117:  call   0xf0090

----------------
IN: 
0x07fb211c:  mov    %esi,%eax
0x07fb211e:  mov    %al,0x6(%esp)
0x07fb2122:  mov    0x18(%esp),%ecx
0x07fb2126:  mov    0x24(%ecx),%eax
0x07fb2129:  mov    (%eax),%si
0x07fb212c:  mov    0x2(%eax),%bx
0x07fb2130:  add    $0x2,%ebx
0x07fb2133:  mov    $0xa,%al
0x07fb2135:  mov    %ebx,%edx
0x07fb2137:  out    %al,(%dx)
0x07fb2138:  mov    %esp,%edx
0x07fb213a:  mov    %ecx,%eax
0x07fb213c:  call   0xf0ea2

----------------
IN: 
0x000f0ea2:  push   %ebp
0x000f0ea3:  push   %edi
0x000f0ea4:  push   %esi
0x000f0ea5:  push   %ebx
0x000f0ea6:  mov    %edx,%edi
0x000f0ea8:  mov    0x28(%eax),%bl
0x000f0eab:  mov    0x24(%eax),%eax
0x000f0eae:  movzwl (%eax),%ebp
0x000f0eb1:  mov    %ebp,%eax
0x000f0eb3:  call   0xf0e93

----------------
IN: 
0x000f0eb8:  test   %eax,%eax
0x000f0eba:  js     0xf0f55

----------------
IN: 
0x000f0ec0:  mov    %ebp,%esi
0x000f0ec2:  mov    0x5(%edi),%cl
0x000f0ec5:  and    $0x4f,%ecx
0x000f0ec8:  cmp    $0x1,%bl
0x000f0ecb:  sbb    %eax,%eax
0x000f0ecd:  and    $0xfffffff0,%eax
0x000f0ed0:  sub    $0x50,%eax
0x000f0ed3:  or     %eax,%ecx
0x000f0ed5:  lea    0x6(%ebp),%edx
0x000f0ed8:  in     (%dx),%al
0x000f0ed9:  mov    %al,%bl
0x000f0edb:  mov    %cl,%al
0x000f0edd:  out    %al,(%dx)
0x000f0ede:  xor    %ebx,%ecx
0x000f0ee0:  and    $0x10,%cl
0x000f0ee3:  jne    0xf0f19

----------------
IN: 
0x000f0ee5:  mov    0x6(%edi),%cl
0x000f0ee8:  mov    %ecx,%eax
0x000f0eea:  and    $0xee,%eax
0x000f0eef:  cmp    $0x24,%eax
0x000f0ef2:  jne    0xf0f2b

----------------
IN: 
0x000f0f2b:  mov    (%edi),%al
0x000f0f2d:  lea    0x1(%esi),%edx
0x000f0f30:  out    %al,(%dx)
0x000f0f31:  mov    0x1(%edi),%al
0x000f0f34:  lea    0x2(%esi),%edx
0x000f0f37:  out    %al,(%dx)
0x000f0f38:  mov    0x2(%edi),%al
0x000f0f3b:  lea    0x3(%esi),%edx
0x000f0f3e:  out    %al,(%dx)
0x000f0f3f:  mov    0x3(%edi),%al
0x000f0f42:  lea    0x4(%esi),%edx
0x000f0f45:  out    %al,(%dx)
0x000f0f46:  mov    0x4(%edi),%al
0x000f0f49:  lea    0x5(%esi),%edx
0x000f0f4c:  out    %al,(%dx)
0x000f0f4d:  lea    0x7(%esi),%edx
0x000f0f50:  mov    %cl,%al
0x000f0f52:  out    %al,(%dx)
0x000f0f53:  xor    %eax,%eax
0x000f0f55:  pop    %ebx
0x000f0f56:  pop    %esi
0x000f0f57:  pop    %edi
0x000f0f58:  pop    %ebp
0x000f0f59:  ret    

----------------
IN: 
0x07fb2141:  mov    %eax,%ecx
0x07fb2143:  test   %eax,%eax
0x07fb2145:  jne    0x7fb2165

----------------
IN: 
0x07fb2147:  movzwl %si,%eax
0x07fb214a:  call   0xf0ff1

----------------
IN: 
0x000f0ff1:  push   %ebx
0x000f0ff2:  mov    %eax,%ebx
0x000f0ff4:  call   0xf07fa

----------------
IN: 
0x000f0ff9:  movzwl %bx,%eax
0x000f0ffc:  call   0xf0e93

----------------
IN: 
0x000f1001:  test   %eax,%eax
0x000f1003:  js     0xf101b

----------------
IN: 
0x000f1005:  test   $0x1,%al
0x000f1007:  jne    0xf1016

----------------
IN: 
0x000f1016:  mov    $0xfffffffc,%eax
0x000f101b:  pop    %ebx
0x000f101c:  ret    

----------------
IN: 
0x07fb214f:  mov    %eax,%ecx
0x07fb2151:  test   %eax,%eax
0x07fb2153:  jne    0x7fb2165

----------------
IN: 
0x07fb2165:  mov    $0x8,%al
0x07fb2167:  mov    %ebx,%edx
0x07fb2169:  out    %al,(%dx)
0x07fb216a:  mov    %ecx,%eax
0x07fb216c:  add    $0x20,%esp
0x07fb216f:  pop    %ebx
0x07fb2170:  pop    %esi
0x07fb2171:  pop    %edi
0x07fb2172:  ret    

----------------
IN: 
0x07fb899c:  test   %eax,%eax
0x07fb899e:  jne    0x7fb8a79

----------------
IN: 
0x07fb8a79:  lea    0x7(%ebp),%edx
0x07fb8a7c:  in     (%dx),%al
0x07fb8a7d:  test   %al,%al
0x07fb8a7f:  je     0x7fb8bbe

----------------
IN: 
0x07fb8a85:  mov    0x8(%esp),%ecx
0x07fb8a89:  mov    $0x40,%edx
0x07fb8a8e:  mov    $0x40,%eax
0x07fb8a93:  call   0xf0e3d

----------------
IN: 
0x07fb8a98:  test   %eax,%eax
0x07fb8a9a:  js     0x7fb8bbe

----------------
IN: 
0x07fb8aa0:  mov    $0xec,%ecx
0x07fb8aa5:  lea    0x6c(%esp),%edx
0x07fb8aa9:  mov    0x4(%esp),%eax
0x07fb8aad:  call   0x7fb20c5

----------------
IN: 
0x000f1009:  and    $0x8,%eax
0x000f100c:  cmp    $0x1,%eax
0x000f100f:  sbb    %eax,%eax
0x000f1011:  and    $0xfffffffb,%eax
0x000f1014:  jmp    0xf101b

----------------
IN: 
0x000f101b:  pop    %ebx
0x000f101c:  ret    

----------------
IN: 
0x07fb2155:  mov    $0x200,%edx
0x07fb215a:  lea    0xc(%esp),%eax
0x07fb215e:  call   0xf0f5a

----------------
IN: 
0x000f0f5a:  push   %ebp
0x000f0f5b:  push   %edi
0x000f0f5c:  push   %esi
0x000f0f5d:  push   %ebx
0x000f0f5e:  sub    $0x10,%esp
0x000f0f61:  mov    %eax,%ebx
0x000f0f63:  mov    %edx,(%esp)
0x000f0f66:  mov    0xc(%eax),%eax
0x000f0f69:  mov    0x24(%eax),%eax
0x000f0f6c:  mov    (%eax),%cx
0x000f0f6f:  mov    %cx,0x8(%esp)
0x000f0f74:  mov    0x2(%eax),%di
0x000f0f78:  movzwl 0x10(%ebx),%esi
0x000f0f7c:  mov    0x8(%ebx),%ebp
0x000f0f7f:  mov    $0x2,%ecx
0x000f0f84:  mov    %edx,%eax
0x000f0f86:  cltd   
0x000f0f87:  idiv   %ecx
0x000f0f89:  mov    %eax,0x4(%esp)
0x000f0f8d:  lea    0x2(%edi),%eax
0x000f0f90:  mov    %ax,0xa(%esp)
0x000f0f95:  movzwl 0x8(%esp),%eax
0x000f0f9a:  mov    %eax,0xc(%esp)
0x000f0f9e:  mov    0x4(%esp),%ecx
0x000f0fa2:  mov    %ebp,%edi
0x000f0fa4:  mov    0x8(%esp),%edx
0x000f0fa8:  rep insw (%dx),%es:(%edi)

----------------
IN: 
0x000f0fa8:  rep insw (%dx),%es:(%edi)

----------------
IN: 
0x000f0fab:  add    (%esp),%ebp
0x000f0fae:  mov    0xa(%esp),%dx
0x000f0fb3:  in     (%dx),%al
0x000f0fb4:  mov    0xc(%esp),%eax
0x000f0fb8:  call   0xf0e93

----------------
IN: 
0x000f0fbd:  test   %eax,%eax
0x000f0fbf:  jns    0xf0fc7

----------------
IN: 
0x000f0fc7:  and    $0x89,%eax
0x000f0fcc:  dec    %esi
0x000f0fcd:  je     0xf0fdf

----------------
IN: 
0x000f0fdf:  cmp    $0x1,%eax
0x000f0fe2:  sbb    %eax,%eax
0x000f0fe4:  not    %eax
0x000f0fe6:  and    $0xfffffff9,%eax
0x000f0fe9:  add    $0x10,%esp
0x000f0fec:  pop    %ebx
0x000f0fed:  pop    %esi
0x000f0fee:  pop    %edi
0x000f0fef:  pop    %ebp
0x000f0ff0:  ret    

----------------
IN: 
0x07fb2163:  mov    %eax,%ecx
0x07fb2165:  mov    $0x8,%al
0x07fb2167:  mov    %ebx,%edx
0x07fb2169:  out    %al,(%dx)
0x07fb216a:  mov    %ecx,%eax
0x07fb216c:  add    $0x20,%esp
0x07fb216f:  pop    %ebx
0x07fb2170:  pop    %esi
0x07fb2171:  pop    %edi
0x07fb2172:  ret    

----------------
IN: 
0x07fb8ab2:  test   %eax,%eax
0x07fb8ab4:  jne    0x7fb8bbe

----------------
IN: 
0x07fb8aba:  lea    0x6c(%esp),%edx
0x07fb8abe:  mov    0x4(%esp),%eax
0x07fb8ac2:  call   0x7fb1018

----------------
IN: 
0x07fb1018:  push   %edi
0x07fb1019:  push   %esi
0x07fb101a:  push   %ebx
0x07fb101b:  mov    %eax,%esi
0x07fb101d:  mov    %edx,%edi
0x07fb101f:  mov    $0x2c,%eax
0x07fb1024:  call   0x7faf8f1

----------------
IN: 
0x07fb1029:  mov    %eax,%ebx
0x07fb102b:  test   %eax,%eax
0x07fb102d:  jne    0x7fb1042

----------------
IN: 
0x07fb1042:  mov    $0x2c,%ecx
0x07fb1047:  xor    %edx,%edx
0x07fb1049:  call   0xf0090

----------------
IN: 
0x07fb104e:  mov    0x24(%esi),%eax
0x07fb1051:  mov    %eax,0x24(%ebx)
0x07fb1054:  mov    0x28(%esi),%dl
0x07fb1057:  mov    %dl,0x28(%ebx)
0x07fb105a:  movzbl 0x7(%eax),%ecx
0x07fb105e:  add    %ecx,%ecx
0x07fb1060:  movzbl 0x28(%esi),%eax
0x07fb1064:  add    %eax,%ecx
0x07fb1066:  mov    %ecx,0x14(%ebx)
0x07fb1069:  mov    (%edi),%ax
0x07fb106c:  shr    $0x7,%ax
0x07fb1070:  and    $0x1,%eax
0x07fb1073:  mov    %al,0x18(%ebx)
0x07fb1076:  mov    %ebx,%eax
0x07fb1078:  pop    %ebx
0x07fb1079:  pop    %esi
0x07fb107a:  pop    %edi
0x07fb107b:  ret    

----------------
IN: 
0x07fb8ac7:  mov    %eax,%ebx
0x07fb8ac9:  test   %eax,%eax
0x07fb8acb:  je     0x7fb8bbe

----------------
IN: 
0x07fb8ad1:  movb   $0x20,(%eax)
0x07fb8ad4:  movw   $0x200,0x1a(%eax)
0x07fb8ada:  mov    0x6e(%esp),%ax
0x07fb8adf:  mov    %ax,0x1e(%ebx)
0x07fb8ae3:  mov    0x72(%esp),%ax
0x07fb8ae8:  mov    %ax,0x1c(%ebx)
0x07fb8aec:  mov    0x78(%esp),%eax
0x07fb8af0:  mov    %ax,0x20(%ebx)
0x07fb8af4:  testb  $0x4,0x113(%esp)
0x07fb8afc:  je     0x7fb8b0e

----------------
IN: 
0x07fb8afe:  mov    0x134(%esp),%esi
0x07fb8b05:  mov    0x138(%esp),%edi
0x07fb8b0c:  jmp    0x7fb8b17

----------------
IN: 
0x07fb8b17:  mov    %esi,0xc(%ebx)
0x07fb8b1a:  mov    %edi,0x10(%ebx)
0x07fb8b1d:  shrd   $0xb,%edi,%esi
0x07fb8b21:  shr    $0xb,%edi
0x07fb8b24:  cmp    $0x0,%edi
0x07fb8b27:  ja     0x7fb8b33

----------------
IN: 
0x07fb8b29:  mov    $0x4d,%cl
0x07fb8b2b:  cmp    $0xffff,%esi
0x07fb8b31:  jbe    0x7fb8b3c

----------------
IN: 
0x07fb8b3c:  mov    %cl,0x8(%esp)
0x07fb8b40:  lea    0x6c(%esp),%eax
0x07fb8b44:  call   0x7faf7b5

----------------
IN: 
0x07faf7b5:  mov    $0xf,%edx
0x07faf7ba:  movzwl 0xa0(%eax),%ecx
0x07faf7c1:  movzbl %dl,%eax
0x07faf7c4:  bt     %edx,%ecx
0x07faf7c7:  jb     0x7faf7ce

----------------
IN: 
0x07faf7c9:  dec    %edx
0x07faf7ca:  jne    0x7faf7c1

----------------
IN: 
0x07faf7c1:  movzbl %dl,%eax
0x07faf7c4:  bt     %edx,%ecx
0x07faf7c7:  jb     0x7faf7ce

----------------
IN: 
0x07faf7ce:  ret    

----------------
IN: 
0x07fb8b49:  mov    %eax,%edi
0x07fb8b4b:  lea    0x6c(%esp),%edx
0x07fb8b4f:  lea    0x17(%esp),%eax
0x07fb8b53:  call   0x7fb0876

----------------
IN: 
0x07fb0876:  push   %ebx
0x07fb0877:  mov    %eax,%ebx
0x07fb0879:  xor    %ecx,%ecx
0x07fb087b:  mov    0x36(%edx,%ecx,2),%ax
0x07fb0880:  xchg   %ah,%al
0x07fb0882:  mov    %ax,(%ebx,%ecx,2)
0x07fb0886:  inc    %ecx
0x07fb0887:  cmp    $0x14,%ecx
0x07fb088a:  jne    0x7fb087b

----------------
IN: 
0x07fb087b:  mov    0x36(%edx,%ecx,2),%ax
0x07fb0880:  xchg   %ah,%al
0x07fb0882:  mov    %ax,(%ebx,%ecx,2)
0x07fb0886:  inc    %ecx
0x07fb0887:  cmp    $0x14,%ecx
0x07fb088a:  jne    0x7fb087b

----------------
IN: 
0x07fb088c:  movb   $0x0,0x28(%ebx)
0x07fb0890:  mov    %ebx,%eax
0x07fb0892:  call   0x7faf4fe

----------------
IN: 
0x07faf4fe:  push   %ebx
0x07faf4ff:  mov    %eax,%ebx
0x07faf501:  call   0x7faf4ae

----------------
IN: 
0x07faf506:  lea    -0x1(%ebx,%eax,1),%eax
0x07faf50a:  cmp    %ebx,%eax
0x07faf50c:  jb     0x7faf51f

----------------
IN: 
0x07faf50e:  cmpb   $0x20,(%eax)
0x07faf511:  jg     0x7faf51f

----------------
IN: 
0x07faf513:  dec    %eax
0x07faf514:  movb   $0x0,0x1(%eax)
0x07faf518:  jmp    0x7faf50a

----------------
IN: 
0x07faf50a:  cmp    %ebx,%eax
0x07faf50c:  jb     0x7faf51f

----------------
IN: 
0x07faf51f:  mov    (%ebx),%al
0x07faf521:  cmp    $0x20,%al
0x07faf523:  jle    0x7faf51a

----------------
IN: 
0x07faf525:  mov    %ebx,%eax
0x07faf527:  pop    %ebx
0x07faf528:  ret    

----------------
IN: 
0x07fb0897:  mov    %ebx,%eax
0x07fb0899:  pop    %ebx
0x07fb089a:  ret    

----------------
IN: 
0x07fb8b58:  movsbl 0x8(%esp),%ecx
0x07fb8b5d:  push   %ecx
0x07fb8b5e:  push   %esi
0x07fb8b5f:  push   %edi
0x07fb8b60:  push   %eax
0x07fb8b61:  movzbl 0x28(%ebx),%eax
0x07fb8b65:  push   %eax
0x07fb8b66:  mov    0x24(%ebx),%eax
0x07fb8b69:  movzbl 0x7(%eax),%eax
0x07fb8b6d:  push   %eax
0x07fb8b6e:  push   $0xf4d47
0x07fb8b73:  push   $0x50
0x07fb8b75:  call   0x7fb87a1

----------------
IN: 
0x07fb8b7a:  mov    %eax,%esi
0x07fb8b7c:  add    $0x20,%esp
0x07fb8b7f:  push   %eax
0x07fb8b80:  push   $0xf4d43
0x07fb8b85:  call   0xf0cc9

----------------
IN: 
0x07fb8b8a:  mov    0x24(%ebx),%eax
0x07fb8b8d:  movzbl 0x28(%ebx),%ecx
0x07fb8b91:  movzbl 0x7(%eax),%edx
0x07fb8b95:  mov    0xc(%eax),%eax
0x07fb8b98:  call   0x7fb8705

----------------
IN: 
0x07fb8705:  test   %eax,%eax
0x07fb8707:  je     0x7fb874f

----------------
IN: 
0x07fb8709:  push   %esi
0x07fb870a:  push   %ebx
0x07fb870b:  sub    $0x100,%esp
0x07fb8711:  mov    %ecx,%esi
0x07fb8713:  mov    %edx,%ebx
0x07fb8715:  mov    %eax,%ecx
0x07fb8717:  mov    $0xf4caa,%edx
0x07fb871c:  mov    %esp,%eax
0x07fb871e:  call   0x7fb832a

----------------
IN: 
0x07fb83bb:  push   %ecx
0x07fb83bc:  push   $0xf4c81
0x07fb83c1:  sub    %ebx,%esi
0x07fb83c3:  push   %esi
0x07fb83c4:  push   %ebx
0x07fb83c5:  call   0x7fb5724

----------------
IN: 
0x07fb83ca:  add    %eax,%ebx
0x07fb83cc:  add    $0x10,%esp
0x07fb83cf:  mov    %ebx,%eax
0x07fb83d1:  pop    %edx
0x07fb83d2:  pop    %ebx
0x07fb83d3:  pop    %esi
0x07fb83d4:  pop    %edi
0x07fb83d5:  pop    %ebp
0x07fb83d6:  ret    

----------------
IN: 
0x07fb8723:  push   %esi
0x07fb8724:  push   %ebx
0x07fb8725:  push   $0xf4cf4
0x07fb872a:  lea    0x10c(%esp),%edx
0x07fb8731:  sub    %eax,%edx
0x07fb8733:  push   %edx
0x07fb8734:  push   %eax
0x07fb8735:  call   0x7fb5724

----------------
IN: 
0x07fb873a:  lea    0x14(%esp),%eax
0x07fb873e:  call   0x7fb26eb

----------------
IN: 
0x07fb8743:  add    $0x14,%esp
0x07fb8746:  add    $0x100,%esp
0x07fb874c:  pop    %ebx
0x07fb874d:  pop    %esi
0x07fb874e:  ret    

----------------
IN: 
0x07fb8b9d:  mov    %eax,%ecx
0x07fb8b9f:  mov    %esi,%edx
0x07fb8ba1:  mov    %ebx,%eax
0x07fb8ba3:  call   0x7fb11c0

----------------
IN: 
0x07fb11c0:  push   %ebx
0x07fb11c1:  mov    0x7fbfe70,%ebx
0x07fb11c7:  test   %ecx,%ecx
0x07fb11c9:  js     0x7fb11cd

----------------
IN: 
0x07fb11cd:  push   %edx
0x07fb11ce:  mov    %eax,%ecx
0x07fb11d0:  mov    %ebx,%edx
0x07fb11d2:  mov    $0x2,%eax
0x07fb11d7:  call   0x7fb112c

----------------
IN: 
0x07fb1193:  cmp    -0x8(%ebx),%ebp
0x07fb1196:  jl     0x7fb1183

----------------
IN: 
0x07fb11dc:  pop    %eax
0x07fb11dd:  pop    %ebx
0x07fb11de:  ret    

----------------
IN: 
0x07fb8ba8:  pop    %eax
0x07fb8ba9:  pop    %edx
0x07fb8baa:  test   %ebx,%ebx
0x07fb8bac:  jne    0x7fb8a61

----------------
IN: 
0x07fb8a61:  mov    0x126(%esp),%ax
0x07fb8a69:  cmpb   $0x0,0x3(%esp)
0x07fb8a6e:  jne    0x7fb8bbe

----------------
IN: 
0x07fb8a74:  jmp    0x7fb8bb4

----------------
IN: 
0x07fb8bb4:  and    $0xdf61,%ax
0x07fb8bb8:  cmp    $0x4041,%ax
0x07fb8bbc:  je     0x7fb8bd4

----------------
IN: 
0x07fb8bbe:  mov    $0x1,%edi
0x07fb8bc3:  cmpb   $0x1,0x3(%esp)
0x07fb8bc8:  je     0x7fb8bd4

----------------
IN: 
0x07fb8bca:  movb   $0x1,0x3(%esp)
0x07fb8bcf:  jmp    0x7fb883d

----------------
IN: 
0x07fb883d:  mov    0x10(%esp),%eax
0x07fb8841:  movzwl (%eax),%eax
0x07fb8844:  mov    %eax,%ebp
0x07fb8846:  mov    %eax,0x8(%esp)
0x07fb884a:  call   0x7fb2173

----------------
IN: 
0x07fb898a:  mov    $0xa1,%ecx
0x07fb898f:  lea    0x6c(%esp),%edx
0x07fb8993:  mov    0x4(%esp),%eax
0x07fb8997:  call   0x7fb20c5

----------------
IN: 
0x07fb8bd4:  add    $0x26c,%esp
0x07fb8bda:  pop    %ebx
0x07fb8bdb:  pop    %esi
0x07fb8bdc:  pop    %edi
0x07fb8bdd:  pop    %ebp
0x07fb8bde:  ret    

----------------
IN: 
0x07fb0f50:  pop    %ebx
0x07fb0f51:  ret    

----------------
IN: 
0x07fb474f:  or     $0xffffffff,%ebx
0x07fb4752:  cmp    $0x64,%esi
0x07fb4755:  jle    0x7fb4774

----------------
IN: 
0x07fb484d:  mov    %eax,%edx
0x07fb484f:  not    %edx
0x07fb4851:  sar    $0x1f,%edx
0x07fb4854:  and    %edx,%eax
0x07fb4856:  jmp    0x7fb48c4

----------------
IN: 
0x07fb48c4:  mov    %al,0x1(%edi)
0x07fb48c7:  jmp    0x7fb493a

----------------
IN: 
0x07fb493a:  lea    0xa(%esp),%edx
0x07fb493e:  mov    $0x1060,%eax
0x07fb4943:  call   0x7fb1984

----------------
IN: 
0x07fb4948:  test   %eax,%eax
0x07fb494a:  jne    0x7fb494e

----------------
IN: 
0x07fb494c:  mov    %ebx,%eax
0x07fb494e:  add    $0xc,%esp
0x07fb4951:  pop    %ebx
0x07fb4952:  pop    %esi
0x07fb4953:  pop    %edi
0x07fb4954:  pop    %ebp
0x07fb4955:  ret    

----------------
IN: 
0x07fb49ab:  test   %eax,%eax
0x07fb49ad:  je     0x7fb4a2e

----------------
IN: 
0x07fb4a2e:  movzbl 0x2(%esp),%eax
0x07fb4a33:  cmp    $0xaa,%al
0x07fb4a35:  je     0x7fb4a46

----------------
IN: 
0x07fb4a46:  xor    %edx,%edx
0x07fb4a48:  mov    $0xf5,%eax
0x07fb4a4d:  call   0x7fb47b4

----------------
IN: 
0x07fb0d26:  jmp    0x7fb0d15

Servicing hardware INT=0x08
----------------
IN: 
0x07fb89a4:  lea    0x6c(%esp),%edx
0x07fb89a8:  mov    0x4(%esp),%eax
0x07fb89ac:  call   0x7fb1018

----------------
IN: 
0x07fb89b1:  mov    %eax,%ebx
0x07fb89b3:  test   %eax,%eax
0x07fb89b5:  je     0x7fb8a79

----------------
IN: 
0x07fb89bb:  movb   $0x21,(%eax)
0x07fb89be:  movw   $0x800,0x1a(%eax)
0x07fb89c4:  movl   $0xffffffff,0xc(%eax)
0x07fb89cb:  movl   $0xffffffff,0x10(%eax)
0x07fb89d2:  movzbl 0x6d(%esp),%eax
0x07fb89d7:  and    $0x1f,%eax
0x07fb89da:  cmp    $0x5,%ax
0x07fb89de:  sete   %cl
0x07fb89e1:  mov    $0xf4d13,%esi
0x07fb89e6:  test   %cl,%cl
0x07fb89e8:  jne    0x7fb89ef

----------------
IN: 
0x07fb89ef:  mov    %cl,0xc(%esp)
0x07fb89f3:  lea    0x6c(%esp),%eax
0x07fb89f7:  call   0x7faf7b5

----------------
IN: 
0x07fb89fc:  mov    %eax,%edi
0x07fb89fe:  lea    0x6c(%esp),%edx
0x07fb8a02:  lea    0x17(%esp),%eax
0x07fb8a06:  call   0x7fb0876

----------------
IN: 
0x07fb8a0b:  push   %esi
0x07fb8a0c:  push   %edi
0x07fb8a0d:  push   %eax
0x07fb8a0e:  movzbl 0x28(%ebx),%eax
0x07fb8a12:  push   %eax
0x07fb8a13:  mov    0x24(%ebx),%eax
0x07fb8a16:  movzbl 0x7(%eax),%eax
0x07fb8a1a:  push   %eax
0x07fb8a1b:  push   $0xf4d21
0x07fb8a20:  push   $0x50
0x07fb8a22:  call   0x7fb87a1

----------------
IN: 
0x07fb8a27:  mov    %eax,%esi
0x07fb8a29:  push   %eax
0x07fb8a2a:  push   $0xf4d43
0x07fb8a2f:  call   0xf0cc9

----------------
IN: 
0x07fb8a34:  add    $0x24,%esp
0x07fb8a37:  mov    0xc(%esp),%cl
0x07fb8a3b:  test   %cl,%cl
0x07fb8a3d:  je     0x7fb8a5d

----------------
IN: 
0x07fb8a3f:  mov    0x24(%ebx),%eax
0x07fb8a42:  movzbl 0x28(%ebx),%ecx
0x07fb8a46:  movzbl 0x7(%eax),%edx
0x07fb8a4a:  mov    0xc(%eax),%eax
0x07fb8a4d:  call   0x7fb8705

----------------
IN: 
0x07fb8a52:  mov    %eax,%ecx
0x07fb8a54:  mov    %esi,%edx
0x07fb8a56:  mov    %ebx,%eax
0x07fb8a58:  call   0x7fb11df

----------------
IN: 
0x07fb11df:  push   %ebx
0x07fb11e0:  mov    0x7fbfe74,%ebx
0x07fb11e6:  test   %ecx,%ecx
0x07fb11e8:  js     0x7fb11ec

----------------
IN: 
0x07fb11ec:  push   %edx
0x07fb11ed:  mov    %eax,%ecx
0x07fb11ef:  mov    %ebx,%edx
0x07fb11f1:  mov    $0x3,%eax
0x07fb11f6:  call   0x7fb112c

----------------
IN: 
0x07fb1198:  jg     0x7fb11b9

----------------
IN: 
0x07fb11b9:  mov    %ebx,(%esp)
0x07fb11bc:  mov    (%ebx),%ebx
0x07fb11be:  jmp    0x7fb117f

----------------
IN: 
0x07fb117f:  test   %ebx,%ebx
0x07fb1181:  jne    0x7fb1193

----------------
IN: 
0x07fb11fb:  pop    %eax
0x07fb11fc:  pop    %ebx
0x07fb11fd:  ret    

----------------
IN: 
0x07fb8a5d:  test   %ebx,%ebx
0x07fb8a5f:  je     0x7fb8a79

----------------
IN: 
0x07fb4858:  cmp    $0x2f2,%esi
0x07fb485e:  jne    0x7fb48cf

----------------
IN: 
0x07fb48cf:  mov    %esi,%eax
0x07fb48d1:  movzbl %al,%eax
0x07fb48d4:  mov    $0xc8,%edx
0x07fb48d9:  call   0x7fb477a

----------------
IN: 
0x07fb48de:  mov    %eax,%ebx
0x07fb48e0:  test   %eax,%eax
0x07fb48e2:  jne    0x7fb493a

----------------
IN: 
0x07fb48e4:  mov    %edi,%ebp
0x07fb48e6:  mov    %esi,%eax
0x07fb48e8:  sar    $0xc,%eax
0x07fb48eb:  and    $0xf,%eax
0x07fb48ee:  add    %edi,%eax
0x07fb48f0:  mov    %eax,(%esp)
0x07fb48f3:  mov    %edi,%ecx
0x07fb48f5:  cmp    (%esp),%ecx
0x07fb48f8:  je     0x7fb4916

----------------
IN: 
0x07fb4916:  sar    $0x8,%esi
0x07fb4919:  and    $0xf,%esi
0x07fb491c:  add    %esi,%edi
0x07fb491e:  cmp    %edi,%ebp
0x07fb4920:  je     0x7fb493a

----------------
IN: 
0x07fb4a52:  test   %eax,%eax
0x07fb4a54:  jne    0x7fb4a8b

----------------
IN: 
0x07fb4a56:  movb   $0x2,0x2(%esp)
0x07fb4a5b:  lea    0x2(%esp),%edx
0x07fb4a5f:  mov    $0x10f0,%ax
0x07fb4a63:  call   0x7fb47b4

----------------
IN: 
0x07fb48fa:  movzbl (%ecx),%eax
0x07fb48fd:  mov    %ecx,0x4(%esp)
0x07fb4901:  mov    $0xc8,%edx
0x07fb4906:  call   0x7fb477a

----------------
IN: 
0x07fb490b:  mov    0x4(%esp),%ecx
0x07fb490f:  inc    %ecx
0x07fb4910:  test   %eax,%eax
0x07fb4912:  je     0x7fb48f5

----------------
IN: 
0x07fb48f5:  cmp    (%esp),%ecx
0x07fb48f8:  je     0x7fb4916

----------------
IN: 
0x07fb4a68:  test   %eax,%eax
0x07fb4a6a:  jne    0x7fb4a8b

----------------
IN: 
0x07fb4a6c:  movb   $0x61,0xef690
0x07fb4a73:  xor    %edx,%edx
0x07fb4a75:  mov    $0xf4,%al
0x07fb4a77:  call   0x7fb47b4

----------------
IN: 
0x07fb4a7c:  test   %eax,%eax
0x07fb4a7e:  jne    0x7fb4a8b

----------------
IN: 
0x07fb4a80:  push   $0xf45f5
0x07fb4a85:  call   0xf0cc9

----------------
IN: 
0x07fb4a8a:  pop    %edx
0x07fb4a8b:  pop    %eax
0x07fb4a8c:  pop    %ebx
0x07fb4a8d:  pop    %esi
0x07fb4a8e:  ret    

----------------
IN: 
0x07fb0d28:  ret    

----------------
IN: 
0x07fbbd13:  call   0x7fb84e8

----------------
IN: 
0x07fb84e8:  push   %edi
0x07fb84e9:  lea    0x8(%esp),%edi
0x07fb84ed:  and    $0xfffffff8,%esp
0x07fb84f0:  pushl  -0x4(%edi)
0x07fb84f3:  push   %ebp
0x07fb84f4:  mov    %esp,%ebp
0x07fb84f6:  push   %edi
0x07fb84f7:  push   %esi
0x07fb84f8:  push   %ebx
0x07fb84f9:  sub    $0x314,%esp
0x07fb84ff:  push   $0xf4cd5
0x07fb8504:  call   0xf0cc9

----------------
IN: 
0x07fb8509:  mov    $0x300,%ecx
0x07fb850e:  xor    %edx,%edx
0x07fb8510:  lea    -0x310(%ebp),%eax
0x07fb8516:  call   0xf0090

----------------
IN: 
0x07fb851b:  mov    0x7fbfe84,%ebx
0x07fb8521:  mov    0x7fbfed4,%eax
0x07fb8526:  lea    -0x4(%eax),%esi
0x07fb8529:  pop    %ecx
0x07fb852a:  cmp    $0xfffffffc,%esi
0x07fb852d:  je     0x7fb8554

----------------
IN: 
0x07fb852f:  cmpw   $0x300,0x14(%esi)
0x07fb8535:  je     0x7fb854c

----------------
IN: 
0x07fb8537:  cmpl   $0x0,0x1c(%esi)
0x07fb853b:  jne    0x7fb854c

----------------
IN: 
0x07fb853d:  lea    -0x310(%ebp),%ecx
0x07fb8543:  xor    %edx,%edx
0x07fb8545:  mov    %esi,%eax
0x07fb8547:  call   0x7fb576f

----------------
IN: 
0x07fb58f1:  mov    %edi,%ecx
0x07fb58f3:  mov    $0x30,%edx
0x07fb58f8:  mov    %esi,%eax
0x07fb58fa:  call   0xf009b

----------------
IN: 
0x07fb58ff:  jmp    0x7fb5930

----------------
IN: 
0x07fb5930:  or     $0xffffffff,%eax
0x07fb5933:  add    $0x28,%esp
0x07fb5936:  pop    %ebx
0x07fb5937:  pop    %esi
0x07fb5938:  pop    %edi
0x07fb5939:  pop    %ebp
0x07fb593a:  ret    

----------------
IN: 
0x07fb854c:  mov    0x4(%esi),%esi
0x07fb854f:  sub    $0x4,%esi
0x07fb8552:  jmp    0x7fb852a

----------------
IN: 
0x07fb852a:  cmp    $0xfffffffc,%esi
0x07fb852d:  je     0x7fb8554

----------------
IN: 
0x07fb5907:  lea    -0xc0000(%ebp),%eax
0x07fb590d:  shr    $0xb,%eax
0x07fb5910:  mov    (%esp),%edi
0x07fb5913:  mov    %ebx,(%edi,%eax,8)
0x07fb5916:  movl   $0x2,0x4(%edi,%eax,8)
0x07fb591e:  movzwl 0x6(%esp),%edx
0x07fb5923:  mov    0x8(%esp),%ecx
0x07fb5927:  mov    %ebp,%eax
0x07fb5929:  call   0x7fb25e7

----------------
IN: 
0x07fb2632:  movzwl 0x1a(%ebx),%eax
0x07fb2636:  add    %ebx,%eax
0x07fb2638:  je     0x7fb2651

----------------
IN: 
0x07fb263a:  cmpl   $0x506e5024,(%eax)
0x07fb2640:  jne    0x7fb2651

----------------
IN: 
0x000c9803:  jmp    0xc98a5

----------------
IN: 
0x000c98a5:  pusha  
0x000c98a6:  push   %ds
0x000c98a7:  push   %es
0x000c98a8:  push   %fs
0x000c98aa:  push   %gs
0x000c98ac:  cld    
0x000c98ad:  push   %cs
0x000c98ae:  pop    %ds
0x000c98af:  mov    $0x303,%si
0x000c98b2:  xor    %di,%di
0x000c98b4:  call   0xc9cf6

----------------
IN: 
0x000c9cf6:  push   %ax
0x000c9cf7:  lods   %ds:(%si),%al
0x000c9cf8:  test   %al,%al
0x000c9cfa:  je     0xc9d01

----------------
IN: 
0x000c9cfc:  call   0xc9ccf

----------------
IN: 
0x000c9ccf:  push   %ax
0x000c9cd0:  push   %bx
0x000c9cd1:  push   %bp
0x000c9cd2:  test   %di,%di
0x000c9cd4:  je     0xc9cdb

----------------
IN: 
0x000c9cdb:  mov    $0x7,%bx
0x000c9cde:  mov    $0xe,%ah
0x000c9ce0:  cmp    $0xa,%al
0x000c9ce2:  jne    0xc9ce8

----------------
IN: 
0x000c9ce4:  int    $0x10

----------------
IN: 
0x000c9ce6:  mov    $0xd,%al
0x000c9ce8:  int    $0x10

----------------
IN: 
0x000c9cea:  pop    %bp
0x000c9ceb:  pop    %bx
0x000c9cec:  pop    %ax
0x000c9ced:  ret    

----------------
IN: 
0x000c9cff:  jmp    0xc9cf7

----------------
IN: 
0x000c9cf7:  lods   %ds:(%si),%al
0x000c9cf8:  test   %al,%al
0x000c9cfa:  je     0xc9d01

----------------
IN: 
0x000c9ce8:  int    $0x10

----------------
IN: 
0x000c9d01:  pop    %ax
0x000c9d02:  ret    

----------------
IN: 
0x000c98b7:  mov    %bx,%gs
0x000c98b9:  xor    %di,%di
0x000c98bb:  call   0xc9cee

----------------
IN: 
0x000c9cee:  push   %ax
0x000c9cef:  mov    $0x20,%al
0x000c9cf1:  call   0xc9ccf

----------------
IN: 
0x000c9cf4:  pop    %ax
0x000c9cf5:  ret    

----------------
IN: 
0x000c98be:  mov    %ax,0x355
0x000c98c1:  call   0xc9d2b

----------------
IN: 
0x000c9d2b:  push   %ax
0x000c9d2c:  xchg   %al,%ah
0x000c9d2e:  call   0xc9d15

----------------
IN: 
0x000c9d15:  ror    $0x4,%al
0x000c9d18:  call   0xc9d1e

----------------
IN: 
0x000c9d1e:  push   %ax
0x000c9d1f:  and    $0xf,%al
0x000c9d21:  cmp    $0xa,%al
0x000c9d23:  sbb    $0x69,%al
0x000c9d25:  das    
0x000c9d26:  call   0xc9ccf

----------------
IN: 
0x000c9d29:  pop    %ax
0x000c9d2a:  ret    

----------------
IN: 
0x000c9d1b:  ror    $0x4,%al
0x000c9d1e:  push   %ax
0x000c9d1f:  and    $0xf,%al
0x000c9d21:  cmp    $0xa,%al
0x000c9d23:  sbb    $0x69,%al
0x000c9d25:  das    
0x000c9d26:  call   0xc9ccf

----------------
IN: 
0x000c9d31:  mov    $0x3a,%al
0x000c9d33:  call   0xc9ccf

----------------
IN: 
0x000c9d36:  mov    %ah,%al
0x000c9d38:  shr    $0x3,%al
0x000c9d3b:  call   0xc9d15

----------------
IN: 
0x000c9d3e:  mov    $0x2e,%al
0x000c9d40:  call   0xc9ccf

----------------
IN: 
0x000c9d43:  mov    %ah,%al
0x000c9d45:  and    $0x7,%al
0x000c9d47:  call   0xc9d1e

----------------
IN: 
0x000c9d4a:  pop    %ax
0x000c9d4b:  ret    

----------------
IN: 
0x000c98c4:  mov    $0x7a,%di
0x000c98c7:  call   0xc9d2b

----------------
IN: 
0x000c9cd6:  mov    %al,(%di)
0x000c9cd8:  inc    %di
0x000c9cd9:  jmp    0xc9cea

----------------
IN: 
0x000c98ca:  movb   $0x20,0x74
0x000c98cf:  xor    %di,%di
0x000c98d1:  call   0xc9cee

----------------
IN: 
0x000c98d4:  mov    %cs,%ax
0x000c98d6:  call   0xc9d0e

----------------
IN: 
0x000c9d0e:  xchg   %al,%ah
0x000c9d10:  call   0xc9d15

----------------
IN: 
0x000c9d13:  xchg   %al,%ah
0x000c9d15:  ror    $0x4,%al
0x000c9d18:  call   0xc9d1e

----------------
IN: 
0x000c98d9:  push   %ebx
0x000c98db:  push   %edx
0x000c98dd:  push   %edi
0x000c98df:  stc    
0x000c98e0:  mov    $0xb101,%ax
0x000c98e3:  int    $0x1a

----------------
IN: 
0x000ffe6e:  cmp    $0xb1,%ah
0x000ffe71:  je     0xfd43d

----------------
IN: 
0x000fd43d:  cli    
0x000fd43e:  cld    
0x000fd43f:  push   %eax
0x000fd441:  push   %ecx
0x000fd443:  push   %edx
0x000fd445:  push   %ebx
0x000fd447:  push   %ebp
0x000fd449:  push   %esi
0x000fd44b:  push   %edi
0x000fd44d:  push   %es
0x000fd44e:  push   %ds
0x000fd44f:  mov    %ss,%ax
0x000fd451:  mov    %ax,%ds
0x000fd453:  mov    %esp,%ebx
0x000fd456:  movzwl %sp,%esp
0x000fd45a:  mov    %esp,%eax
0x000fd45d:  calll  0xfcd4b

----------------
IN: 
0x000fcd4b:  push   %ebp
0x000fcd4d:  push   %edi
0x000fcd4f:  push   %esi
0x000fcd51:  push   %ebx
0x000fcd53:  mov    %eax,%ebx
0x000fcd56:  addr32 mov 0x1c(%eax),%al
0x000fcd5a:  cmp    $0x9,%al
0x000fcd5c:  je     0xfcf4f

----------------
IN: 
0x000fcd60:  ja     0xfcde9

----------------
IN: 
0x000fcd64:  mov    %ebx,%esi
0x000fcd67:  cmp    $0x2,%al
0x000fcd69:  je     0xfce4a

----------------
IN: 
0x000fcd6d:  ja     0xfcd9e

----------------
IN: 
0x000fcd6f:  dec    %al
0x000fcd71:  jne    0xfd0ac

----------------
IN: 
0x000fcd75:  addr32 movb $0x1,0x1c(%ebx)
0x000fcd7a:  addr32 movw $0x210,0x10(%ebx)
0x000fcd80:  mov    %cs:0x6ac8,%eax
0x000fcd85:  addr32 mov %al,0x18(%ebx)
0x000fcd89:  addr32 movl $0x20494350,0x14(%ebx)
0x000fcd92:  addr32 movl $0xfd40f,0x4(%ebx)
0x000fcd9b:  jmp    0xfcec0

----------------
IN: 
0x000fcec0:  mov    %esi,%eax
0x000fcec3:  jmp    0xfd0a1

----------------
IN: 
0x000fd0a1:  pop    %ebx
0x000fd0a3:  pop    %esi
0x000fd0a5:  pop    %edi
0x000fd0a7:  pop    %ebp
0x000fd0a9:  jmp    0xf7b26

----------------
IN: 
0x000f7b26:  addr32 movb $0x0,0x1d(%eax)
0x000f7b2b:  addr32 andw $0xfffffffe,0x24(%eax)
0x000f7b30:  retl   

----------------
IN: 
0x000fd463:  mov    %ebx,%esp
0x000fd466:  pop    %ds
0x000fd467:  pop    %es
0x000fd468:  pop    %edi
0x000fd46a:  pop    %esi
0x000fd46c:  pop    %ebp
0x000fd46e:  pop    %ebx
0x000fd470:  pop    %edx
0x000fd472:  pop    %ecx
0x000fd474:  pop    %eax
0x000fd476:  iret   

----------------
IN: 
0x000c98e5:  jb     0xc993d

----------------
IN: 
0x000c98e7:  cmp    $0x20494350,%edx
0x000c98ee:  jne    0xc993d

----------------
IN: 
0x000c98f0:  test   %ah,%ah
0x000c98f2:  jne    0xc993d

----------------
IN: 
0x000c98f4:  mov    $0x31c,%si
0x000c98f7:  xor    %di,%di
0x000c98f9:  call   0xc9cf6

----------------
IN: 
0x000c98fc:  mov    %bh,%al
0x000c98fe:  call   0xc9d1e

----------------
IN: 
0x000c9901:  mov    $0x2e,%al
0x000c9903:  call   0xc9ccf

----------------
IN: 
0x000c9906:  mov    %bl,%al
0x000c9908:  call   0xc9d15

----------------
IN: 
0x000c990b:  cmp    $0x3,%bh
0x000c990e:  jb     0xc993d

----------------
IN: 
0x000c993d:  push   %cs
0x000c993e:  pop    %gs
0x000c9940:  pop    %edi
0x000c9942:  pop    %edx
0x000c9944:  pop    %ebx
0x000c9946:  mov    $0xefff,%bx
0x000c9949:  inc    %bx
0x000c994a:  je     0xc9976

----------------
IN: 
0x000c994c:  mov    %bx,%es
0x000c994e:  cmpl   $0x506e5024,%es:0x0
0x000c9958:  jne    0xc9949

----------------
IN: 
0x000c9949:  inc    %bx
0x000c994a:  je     0xc9976

----------------
IN: 
0x000c995a:  xor    %dx,%dx
0x000c995c:  xor    %si,%si
0x000c995e:  movzbw %es:0x5,%cx
0x000c9964:  lods   %es:(%si),%al
0x000c9966:  add    %al,%dl
0x000c9968:  loop   0xc9964

----------------
IN: 
0x000c9964:  lods   %es:(%si),%al
0x000c9966:  add    %al,%dl
0x000c9968:  loop   0xc9964

----------------
IN: 
0x000c996a:  jne    0xc9949

----------------
IN: 
0x000c996c:  mov    $0x321,%si
0x000c996f:  xor    %di,%di
0x000c9971:  call   0xc9cf6

----------------
IN: 
0x000c9974:  jmp    0xc9976

----------------
IN: 
0x000c9976:  mov    $0xdfff,%bx
0x000c9979:  inc    %bx
0x000c997a:  je     0xc9a1d

----------------
IN: 
0x000c997e:  mov    %bx,%es
0x000c9980:  cmpl   $0x4d4d5024,%es:0x0
0x000c998a:  jne    0xc9979

----------------
IN: 
0x000c9979:  inc    %bx
0x000c997a:  je     0xc9a1d

----------------
IN: 
0x000c998c:  xor    %dx,%dx
0x000c998e:  xor    %si,%si
0x000c9990:  movzbw %es:0x5,%cx
0x000c9996:  lods   %es:(%si),%al
0x000c9998:  add    %al,%dl
0x000c999a:  loop   0xc9996

----------------
IN: 
0x000c9996:  lods   %es:(%si),%al
0x000c9998:  add    %al,%dl
0x000c999a:  loop   0xc9996

----------------
IN: 
0x000c999c:  jne    0xc9979

----------------
IN: 
0x000c999e:  mov    $0x326,%si
0x000c99a1:  xor    %di,%di
0x000c99a3:  call   0xc9cf6

----------------
IN: 
0x000c99a6:  pushal 
0x000c99a8:  movzbl 0x2,%ecx
0x000c99ae:  add    0x35b,%cx
0x000c99b2:  add    $0x7,%cx
0x000c99b5:  and    $0xfffffff8,%cx
0x000c99b8:  shl    $0x5,%ecx
0x000c99bc:  mov    $0x18ae1000,%ebx
0x000c99c2:  mov    $0x2ea,%bp
0x000c99c5:  call   0xc9a96

----------------
IN: 
0x000c9a96:  push   %eax
0x000c9a98:  push   %di
0x000c9a99:  mov    $0x20,%di
0x000c9a9c:  push   %ebx
0x000c9a9e:  push   $0x1
0x000c9aa0:  lcall  *%es:0x7

----------------
IN: 
0x000fd2f6:  push   %esp
0x000fd2f8:  movzwl %sp,%esp
0x000fd2fc:  pushfl 
0x000fd2fe:  cli    
0x000fd2ff:  cld    
0x000fd300:  push   %eax
0x000fd302:  push   %ecx
0x000fd304:  push   %edx
0x000fd306:  push   %ebx
0x000fd308:  push   %ebp
0x000fd30a:  push   %esi
0x000fd30c:  push   %edi
0x000fd30e:  push   %es
0x000fd30f:  push   %ds
0x000fd310:  mov    %ss,%ecx
0x000fd313:  mov    %cx,%ds
0x000fd315:  shl    $0x4,%ecx
0x000fd319:  mov    $0x7fbdf66,%eax
0x000fd31f:  addr32 lea 0x2c(%esp,%ecx,1),%edx
0x000fd325:  mov    $0xffffffff,%ecx
0x000fd32b:  calll  0xf8d19

----------------
IN: 
0x000f8d19:  push   %ebp
0x000f8d1b:  push   %edi
0x000f8d1d:  push   %esi
0x000f8d1f:  push   %ebx
0x000f8d21:  mov    %eax,%edi
0x000f8d24:  mov    %edx,%esi
0x000f8d27:  mov    %cs:0x6bf0,%eax
0x000f8d2c:  test   %eax,%eax
0x000f8d2f:  je     0xf8d80

----------------
IN: 
0x000f8d31:  calll  0xf7589

----------------
IN: 
0x000f7589:  in     $0x70,%al
0x000f758b:  mov    %al,%cl
0x000f758d:  or     $0xffffff80,%eax
0x000f7591:  out    %al,$0x70
0x000f7593:  in     $0x71,%al
0x000f7595:  mov    $0xe000,%edx
0x000f759b:  mov    %dx,%es
0x000f759d:  mov    %cl,%es:-0x11b
0x000f75a2:  mov    %ss,%ax
0x000f75a4:  mov    %dx,%es
0x000f75a6:  mov    %ax,%es:0xfee8
0x000f75aa:  mov    %dx,%es
0x000f75ac:  mov    $0x2,%al
0x000f75ae:  mov    %al,%es:0xfee4
0x000f75b2:  retl   

----------------
IN: 
0x000f8d37:  mov    %esp,%ebp
0x000f8d3a:  mov    %ss,%eax
0x000f8d3d:  shl    $0x4,%eax
0x000f8d41:  add    %eax,%esp
0x000f8d44:  mov    $0xb5,%eax
0x000f8d4a:  mov    $0x1234,%ecx
0x000f8d50:  mov    $0xf8d5b,%ebx
0x000f8d56:  out    %al,$0xb2
0x000f8d58:  pause  

----------------
IN: 
0x000a8000:  mov    %cs,%ax
0x000a8002:  ljmp   $0xf000,$0xd29c

----------------
IN: 
0x000f39a1:  cmp    $0xb5,%al
0x000f39a3:  jne    0xf3ab8

----------------
IN: 
0x000f39a9:  mov    0xfefc(%edx),%eax
0x000f39af:  cmp    $0x20000,%eax
0x000f39b4:  jne    0xf3a33

----------------
IN: 
0x000f39b6:  lea    0xffd0(%edx),%eax
0x000f39bc:  mov    %eax,-0x54(%ebp)
0x000f39bf:  lea    -0x50(%ebp),%edi
0x000f39c2:  mov    $0x8,%ecx
0x000f39c7:  mov    %eax,%esi
0x000f39c9:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000f39c9:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000f39cb:  mov    0xffd4(%edx),%eax
0x000f39d1:  cmp    $0x1234,%eax
0x000f39d6:  lea    -0x50(%ebp),%ebx
0x000f39d9:  jne    0xf39fc

----------------
IN: 
0x000f39db:  lea    0xfe00(%edx),%eax
0x000f39e1:  mov    %eax,-0x58(%ebp)
0x000f39e4:  lea    0x200(%edx),%eax
0x000f39ea:  mov    $0x80,%cl
0x000f39ec:  mov    %eax,%edi
0x000f39ee:  mov    -0x58(%ebp),%esi
0x000f39f1:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000f39f1:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000f39f3:  mov    $0x80,%cl
0x000f39f5:  mov    -0x58(%ebp),%edi
0x000f39f8:  mov    %edx,%esi
0x000f39fa:  jmp    0xf3a1a

----------------
IN: 
0x000f3a1a:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000f3a1c:  mov    $0x8,%cl
0x000f3a1e:  mov    -0x54(%ebp),%edi
0x000f3a21:  mov    %ebx,%esi
0x000f3a23:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000f3a23:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000f3a25:  mov    -0x44(%ebp),%eax
0x000f3a28:  mov    %eax,0xfff0(%edx)
0x000f3a2e:  jmp    0xf3ab8

----------------
IN: 
0x000f8d5b:  mov    %esi,%eax
0x000f8d5d:  call   *%edi

----------------
IN: 
0x07fbdf66:  push   %ebp
0x07fbdf67:  push   %edi
0x07fbdf68:  push   %esi
0x07fbdf69:  push   %ebx
0x07fbdf6a:  push   %ebx
0x07fbdf6b:  mov    %eax,%esi
0x07fbdf6d:  movzwl (%eax),%eax
0x07fbdf70:  mov    %eax,%ebx
0x07fbdf72:  push   %eax
0x07fbdf73:  push   $0xf5b18
0x07fbdf78:  call   0xf0cc9

----------------
IN: 
0x07fbdf7d:  pop    %edi
0x07fbdf7e:  pop    %ebp
0x07fbdf7f:  cmp    $0x1,%bx
0x07fbdf83:  je     0x7fbe09d

----------------
IN: 
0x07fbe09d:  mov    0x2(%esi),%ebx
0x07fbe0a0:  xor    %ecx,%ecx
0x07fbe0a2:  cmp    $0xffffffff,%ebx
0x07fbe0a5:  je     0x7fbe0d4

----------------
IN: 
0x07fbe0a7:  xor    %edx,%edx
0x07fbe0a9:  mov    0x7fbfe88(,%edx,4),%eax
0x07fbe0b0:  mov    (%eax),%eax
0x07fbe0b2:  test   %eax,%eax
0x07fbe0b4:  je     0x7fbe0c5

----------------
IN: 
0x07fbe0b6:  cmp    %eax,0x8(%eax)
0x07fbe0b9:  jne    0x7fbe0b0

----------------
IN: 
0x07fbe0b0:  mov    (%eax),%eax
0x07fbe0b2:  test   %eax,%eax
0x07fbe0b4:  je     0x7fbe0c5

----------------
IN: 
0x07fbe0c5:  inc    %edx
0x07fbe0c6:  cmp    $0x5,%edx
0x07fbe0c9:  jne    0x7fbe0a9

----------------
IN: 
0x07fbe0a9:  mov    0x7fbfe88(,%edx,4),%eax
0x07fbe0b0:  mov    (%eax),%eax
0x07fbe0b2:  test   %eax,%eax
0x07fbe0b4:  je     0x7fbe0c5

----------------
IN: 
0x07fbe0bb:  cmp    %ebx,0x28(%eax)
0x07fbe0be:  jne    0x7fbe0b0

----------------
IN: 
0x07fbe0cb:  jmp    0x7fbe0d2

----------------
IN: 
0x07fbe0d2:  xor    %ecx,%ecx
0x07fbe0d4:  mov    %ecx,%eax
0x07fbe0d6:  pop    %edx
0x07fbe0d7:  pop    %ebx
0x07fbe0d8:  pop    %esi
0x07fbe0d9:  pop    %edi
0x07fbe0da:  pop    %ebp
0x07fbe0db:  ret    

----------------
IN: 
0x000f8d5f:  mov    %eax,%esi
0x000f8d61:  mov    $0xb5,%eax
0x000f8d66:  mov    $0x5678,%ecx
0x000f8d6b:  mov    $0x8d75,%ebx
0x000f8d70:  out    %al,$0xb2
0x000f8d72:  pause  

----------------
IN: 
0x000f39fc:  cmp    $0x5678,%eax
0x000f3a01:  jne    0xf3ab8

----------------
IN: 
0x000f3a07:  lea    0xfe00(%edx),%eax
0x000f3a0d:  lea    0x200(%edx),%esi
0x000f3a13:  mov    $0x80,%ecx
0x000f3a18:  mov    %eax,%edi
0x000f3a1a:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000f8d75:  mov    %ebp,%esp
0x000f8d78:  calll  0xf75b4

----------------
IN: 
0x000f75b4:  mov    $0xe000,%eax
0x000f75ba:  mov    %ax,%es
0x000f75bc:  xor    %edx,%edx
0x000f75bf:  mov    %dl,%es:-0x11c
0x000f75c4:  mov    %ax,%es
0x000f75c6:  xor    %edx,%edx
0x000f75c9:  mov    %dx,%es:-0x118
0x000f75ce:  mov    %ax,%es
0x000f75d0:  mov    %es:0xfee5,%al
0x000f75d4:  out    %al,$0x70
0x000f75d6:  in     $0x71,%al
0x000f75d8:  retl   

----------------
IN: 
0x000f8d7e:  jmp    0xf8dc6

----------------
IN: 
0x000f8dc6:  mov    %esi,%ecx
0x000f8dc9:  mov    %ecx,%eax
0x000f8dcc:  pop    %ebx
0x000f8dce:  pop    %esi
0x000f8dd0:  pop    %edi
0x000f8dd2:  pop    %ebp
0x000f8dd4:  retl   

----------------
IN: 
0x000fd331:  addr32 mov %ax,0x1c(%esp)
0x000fd336:  shr    $0x10,%eax
0x000fd33a:  addr32 mov %ax,0x14(%esp)
0x000fd33f:  pop    %ds
0x000fd340:  pop    %es
0x000fd341:  pop    %edi
0x000fd343:  pop    %esi
0x000fd345:  pop    %ebp
0x000fd347:  pop    %ebx
0x000fd349:  pop    %edx
0x000fd34b:  pop    %ecx
0x000fd34d:  pop    %eax
0x000fd34f:  popfl  

----------------
IN: 
0x000fd351:  pop    %esp
0x000fd353:  lret   

----------------
IN: 
0x000c9aa5:  add    $0x6,%sp
0x000c9aa8:  push   %dx
0x000c9aa9:  push   %ax
0x000c9aaa:  pop    %esi
0x000c9aac:  inc    %esi
0x000c9aae:  je     0xc9abc

----------------
IN: 
0x000c9ab0:  dec    %esi
0x000c9ab2:  je     0xc9abc

----------------
IN: 
0x000c9abc:  push   $0x2
0x000c9abe:  push   %ebx
0x000c9ac0:  push   %ecx
0x000c9ac2:  push   $0x0
0x000c9ac4:  lcall  *%es:0x7

----------------
IN: 
0x07fbdf89:  jb     0x7fbdfa9

----------------
IN: 
0x07fbdfa9:  mov    0x2(%esi),%ebx
0x07fbdfac:  mov    0x6(%esi),%ebp
0x07fbdfaf:  mov    0xa(%esi),%dx
0x07fbdfb3:  test   $0x8,%dl
0x07fbdfb6:  je     0x7fbdfc4

----------------
IN: 
0x07fbdfc4:  mov    $0x7fbfe9c,%edi
0x07fbdfc9:  mov    $0x7fbfea0,%eax
0x07fbdfce:  test   %ebx,%ebx
0x07fbdfd0:  jne    0x7fbe016

----------------
IN: 
0x07fbe016:  shl    $0x4,%ebx
0x07fbe019:  xor    %ecx,%ecx
0x07fbe01b:  test   %ebx,%ebx
0x07fbe01d:  jle    0x7fbe0d4

----------------
IN: 
0x07fbe023:  mov    $0x10,%esi
0x07fbe028:  test   $0x4,%dl
0x07fbe02b:  je     0x7fbe040

----------------
IN: 
0x07fbe040:  and    $0x3,%edx
0x07fbe043:  cmp    $0x2,%dx
0x07fbe047:  je     0x7fbe068

----------------
IN: 
0x07fbe068:  mov    %esi,%ecx
0x07fbe06a:  mov    %ebx,%edx
0x07fbe06c:  mov    %edi,%eax
0x07fbe06e:  call   0x7faf858

----------------
IN: 
0x07fbe073:  mov    %eax,%ecx
0x07fbe075:  test   %ecx,%ecx
0x07fbe077:  je     0x7fbe0d4

----------------
IN: 
0x07fbe079:  cmp    $0xffffffff,%ebp
0x07fbe07c:  je     0x7fbe0d4

----------------
IN: 
0x07fbe07e:  mov    %ecx,%eax
0x07fbe080:  mov    %ecx,(%esp)
0x07fbe083:  call   0x7faf838

----------------
IN: 
0x07fbe088:  mov    (%esp),%ecx
0x07fbe08b:  cmp    %eax,%ecx
0x07fbe08d:  je     0x7fbe0d4

----------------
IN: 
0x07fbe08f:  test   %eax,%eax
0x07fbe091:  je     0x7fbe0d4

----------------
IN: 
0x07fbe093:  cmp    0xc(%eax),%ecx
0x07fbe096:  je     0x7fbe0d4

----------------
IN: 
0x07fbe098:  mov    %ebp,0x14(%eax)
0x07fbe09b:  jmp    0x7fbe0d4

----------------
IN: 
0x07fbe0d4:  mov    %ecx,%eax
0x07fbe0d6:  pop    %edx
0x07fbe0d7:  pop    %ebx
0x07fbe0d8:  pop    %esi
0x07fbe0d9:  pop    %edi
0x07fbe0da:  pop    %ebp
0x07fbe0db:  ret    

----------------
IN: 
0x000c9ac9:  add    $0xc,%sp
0x000c9acc:  push   %dx
0x000c9acd:  push   %ax
0x000c9ace:  pop    %esi
0x000c9ad0:  mov    $0x2b,%di
0x000c9ad3:  mov    %di,%ax
0x000c9ad5:  xor    %di,%di
0x000c9ad7:  call   0xc9ccf

----------------
IN: 
0x000c9ada:  mov    %esi,%eax
0x000c9add:  call   0xc9d03

----------------
IN: 
0x000c9d03:  ror    $0x10,%eax
0x000c9d07:  call   0xc9d0e

----------------
IN: 
0x000c9d0a:  ror    $0x10,%eax
0x000c9d0e:  xchg   %al,%ah
0x000c9d10:  call   0xc9d15

----------------
IN: 
0x000c9ae0:  inc    %esi
0x000c9ae2:  je     0xc9ae6

----------------
IN: 
0x000c9ae4:  dec    %esi
0x000c9ae6:  pop    %di
0x000c9ae7:  pop    %eax
0x000c9ae9:  ret    

----------------
IN: 
0x000c99c8:  mov    %esi,0x357
0x000c99cd:  je     0xc99ef

----------------
IN: 
0x000c99cf:  push   %es
0x000c99d0:  xor    %ax,%ax
0x000c99d2:  mov    %ax,%es
0x000c99d4:  mov    %esi,%edi
0x000c99d7:  xor    %esi,%esi
0x000c99da:  movzbl 0x2,%ecx
0x000c99e0:  shl    $0x7,%ecx
0x000c99e4:  rep addr32 movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000c99e4:  rep addr32 movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x000c99e8:  pop    %es
0x000c99e9:  mov    0x9f,%al
0x000c99ec:  mov    %al,0x2
0x000c99ef:  mov    $0xa507,%ecx
0x000c99f5:  add    $0x1fff,%ecx
0x000c99fc:  and    $0xffffe000,%ecx
0x000c9a03:  mov    %ecx,%ebx
0x000c9a06:  shr    $0xc,%bx
0x000c9a09:  or     $0x18ae2000,%ebx
0x000c9a10:  mov    $0x301,%bp
0x000c9a13:  call   0xc9a96

----------------
IN: 
0x000c9a16:  mov    %esi,0x35d
0x000c9a1b:  popal  
0x000c9a1d:  xor    %bx,%bx
0x000c9a1f:  xor    %si,%si
0x000c9a21:  movzbw 0x2,%cx
0x000c9a26:  shl    $0x9,%cx
0x000c9a29:  lods   %ds:(%si),%al
0x000c9a2a:  add    %al,%bl
0x000c9a2c:  loop   0xc9a29

----------------
IN: 
0x000c9a29:  lods   %ds:(%si),%al
0x000c9a2a:  add    %al,%bl
0x000c9a2c:  loop   0xc9a29

----------------
IN: 
0x000c9a2e:  sub    %bl,0x6
0x000c9a32:  xor    %di,%di
0x000c9a34:  call   0xc9cee

----------------
IN: 
0x000c9a37:  mov    %gs,%ax
0x000c9a39:  call   0xc9d0e

----------------
IN: 
0x000c9a3c:  movzbw 0x2,%cx
0x000c9a41:  shl    $0x9,%cx
0x000c9a44:  mov    %ax,%es
0x000c9a46:  xor    %si,%si
0x000c9a48:  xor    %di,%di
0x000c9a4a:  rep movsb %cs:(%si),%es:(%di)

----------------
IN: 
0x000c9a4a:  rep movsb %cs:(%si),%es:(%di)

----------------
IN: 
0x000c9a4a:  rep movsb %cs:(%si),%es:(%di)

----------------
IN: 
0x000c9a4a:  rep movsb %cs:(%si),%es:(%di)

----------------
IN: 
0x000c9a4a:  rep movsb %cs:(%si),%es:(%di)

----------------
IN: 
0x000c9a4a:  rep movsb %cs:(%si),%es:(%di)

----------------
IN: 
0x000c9a4a:  rep movsb %cs:(%si),%es:(%di)

----------------
IN: 
0x000c9a4a:  rep movsb %cs:(%si),%es:(%di)

----------------
IN: 
0x000c9a4d:  testb  $0x7,0x355
0x000c9a52:  jne    0xc9a84

----------------
IN: 
0x000c9a54:  mov    $0x332,%si
0x000c9a57:  xor    %di,%di
0x000c9a59:  call   0xc9cf6

----------------
IN: 
0x000c9cf6:  push   %ax
0x000c9cf7:  lods   %ds:(%si),%al
0x000c9cf8:  test   %al,%al
0x000c9cfa:  je     0xc9d01

----------------
IN: 
0x000c9cfc:  call   0xc9ccf

----------------
IN: 
0x000c9ccf:  push   %ax
0x000c9cd0:  push   %bx
0x000c9cd1:  push   %bp
0x000c9cd2:  test   %di,%di
0x000c9cd4:  je     0xc9cdb

----------------
IN: 
0x000c9cdb:  mov    $0x7,%bx
0x000c9cde:  mov    $0xe,%ah
0x000c9ce0:  cmp    $0xa,%al
0x000c9ce2:  jne    0xc9ce8

----------------
IN: 
0x000c9ce4:  int    $0x10

----------------
IN: 
0x000c9ce6:  mov    $0xd,%al
0x000c9ce8:  int    $0x10

----------------
IN: 
0x000c9cea:  pop    %bp
0x000c9ceb:  pop    %bx
0x000c9cec:  pop    %ax
0x000c9ced:  ret    

----------------
IN: 
0x000c9cff:  jmp    0xc9cf7

----------------
IN: 
0x000c9cf7:  lods   %ds:(%si),%al
0x000c9cf8:  test   %al,%al
0x000c9cfa:  je     0xc9d01

----------------
IN: 
0x000c9ce8:  int    $0x10

----------------
IN: 
0x000c9d01:  pop    %ax
0x000c9d02:  ret    

----------------
IN: 
0x000c9a5c:  mov    $0x70,%si
0x000c9a5f:  call   0xc9cf6

----------------
IN: 
0x000c9a62:  mov    $0x34e,%si
0x000c9a65:  call   0xc9cf6

----------------
IN: 
0x000c9a68:  mov    $0xff02,%bx
0x000c9a6b:  call   0xc9c35

----------------
IN: 
0x000c9c35:  push   %cx
0x000c9c36:  push   %ax
0x000c9c37:  mov    $0x1,%ah
0x000c9c39:  int    $0x16

----------------
IN: 
0x000fe82e:  pushl  $0xc3b1
0x000fe834:  jmp    0xfd55d

----------------
IN: 
0x000fd55d:  cli    
0x000fd55e:  cld    
0x000fd55f:  push   %ds
0x000fd560:  push   %eax
0x000fd562:  mov    $0xe000,%eax
0x000fd568:  mov    %ax,%ds
0x000fd56a:  mov    0xf6d8,%eax
0x000fd56e:  sub    $0x30,%eax
0x000fd572:  addr32 popl 0x1c(%eax)
0x000fd577:  addr32 popw (%eax)
0x000fd57a:  addr32 mov %edi,0x4(%eax)
0x000fd57f:  addr32 mov %esi,0x8(%eax)
0x000fd584:  addr32 mov %ebp,0xc(%eax)
0x000fd589:  addr32 mov %ebx,0x10(%eax)
0x000fd58e:  addr32 mov %edx,0x14(%eax)
0x000fd593:  addr32 mov %ecx,0x18(%eax)
0x000fd598:  addr32 mov %es,0x2(%eax)
0x000fd59c:  pop    %ecx
0x000fd59e:  addr32 mov %esp,0x28(%eax)
0x000fd5a3:  addr32 mov %ss,0x2c(%eax)
0x000fd5a7:  addr32 popl 0x20(%eax)
0x000fd5ac:  addr32 popw 0x24(%eax)
0x000fd5b0:  mov    %ds,%dx
0x000fd5b2:  mov    %dx,%ss

----------------
IN: 
0x000fd5b4:  mov    %eax,%esp

----------------
IN: 
0x000fd5b7:  calll  *%ecx

----------------
IN: 
0x000fc3b1:  push   %ebx
0x000fc3b3:  mov    %eax,%ebx
0x000fc3b6:  calll  0xfefdb

----------------
IN: 
0x000fefdb:  push   %esi
0x000fefdd:  push   %ebx
0x000fefdf:  push   %edx
0x000fefe1:  mov    $0x40,%esi
0x000fefe7:  mov    %si,%es
0x000fefe9:  mov    %es:0x17,%al
0x000fefed:  shr    $0x4,%al
0x000feff0:  and    $0x7,%eax
0x000feff4:  addr32 mov %al,0x3(%esp)
0x000feff9:  mov    %si,%es
0x000feffb:  mov    %es:0x97,%bl
0x000ff000:  mov    %bl,%dl
0x000ff002:  and    $0x7,%edx
0x000ff006:  cmp    %dl,%al
0x000ff008:  je     0xff03b

----------------
IN: 
0x000ff03b:  pop    %eax
0x000ff03d:  pop    %ebx
0x000ff03f:  pop    %esi
0x000ff041:  retl   

----------------
IN: 
0x000fc3bc:  addr32 mov 0x1d(%ebx),%al
0x000fc3c0:  cmp    $0xa,%al
0x000fc3c2:  je     0xfc455

----------------
IN: 
0x000fc3c6:  ja     0xfc3f0

----------------
IN: 
0x000fc3c8:  cmp    $0x2,%al
0x000fc3ca:  je     0xfc422

----------------
IN: 
0x000fc3cc:  ja     0xfc3de

----------------
IN: 
0x000fc3ce:  test   %al,%al
0x000fc3d0:  je     0xfc41d

----------------
IN: 
0x000fc3d2:  dec    %al
0x000fc3d4:  jne    0xfc4b6

----------------
IN: 
0x000fc3d8:  xor    %ecx,%ecx
0x000fc3db:  jmp    0xfc46b

----------------
IN: 
0x000fc46b:  xor    %edx,%edx
0x000fc46e:  mov    %ebx,%eax
0x000fc471:  pop    %ebx
0x000fc473:  jmp    0xfe742

----------------
IN: 
0x000fe742:  push   %ebp
0x000fe744:  push   %edi
0x000fe746:  push   %esi
0x000fe748:  push   %ebx
0x000fe74a:  sub    $0x8,%esp
0x000fe74e:  mov    %eax,%esi
0x000fe751:  mov    %edx,%edi
0x000fe754:  addr32 mov %ecx,(%esp)
0x000fe759:  calll  0xf9a29

----------------
IN: 
0x000f9a34:  mov    $0x9a29,%ecx
0x000f9a3a:  xor    %edx,%edx
0x000f9a3d:  xor    %eax,%eax
0x000f9a40:  jmp    0xf7824

----------------
IN: 
0x000fe75f:  mov    $0x40,%eax
0x000fe765:  mov    $0x40,%ebp
0x000fe76b:  mov    %ax,%es
0x000fe76d:  mov    %es:0x1a,%bx
0x000fe772:  mov    %ax,%es
0x000fe774:  mov    %es:0x1c,%dx
0x000fe779:  cmp    %dx,%bx
0x000fe77b:  jne    0xfe79e

----------------
IN: 
0x000fe77d:  test   %edi,%edi
0x000fe780:  jne    0xfe78a

----------------
IN: 
0x000fe782:  addr32 orw $0x40,0x24(%esi)
0x000fe787:  jmp    0xfe819

----------------
IN: 
0x000fe819:  add    $0x8,%esp
0x000fe81d:  pop    %ebx
0x000fe81f:  pop    %esi
0x000fe821:  pop    %edi
0x000fe823:  pop    %ebp
0x000fe825:  retl   

----------------
IN: 
0x000fd5ba:  mov    %esp,%eax
0x000fd5bd:  addr32 mov 0x2c(%eax),%ss

----------------
IN: 
0x000fd5c1:  addr32 mov 0x28(%eax),%esp

----------------
IN: 
0x000fd5c6:  pop    %edx
0x000fd5c8:  pop    %dx
0x000fd5c9:  addr32 pushw 0x24(%eax)
0x000fd5cd:  addr32 pushl 0x20(%eax)
0x000fd5d2:  addr32 mov 0x4(%eax),%edi
0x000fd5d7:  addr32 mov 0x8(%eax),%esi
0x000fd5dc:  addr32 mov 0xc(%eax),%ebp
0x000fd5e1:  addr32 mov 0x10(%eax),%ebx
0x000fd5e6:  addr32 mov 0x14(%eax),%edx
0x000fd5eb:  addr32 mov 0x18(%eax),%ecx
0x000fd5f0:  addr32 mov 0x2(%eax),%es
0x000fd5f4:  addr32 pushl 0x1c(%eax)
0x000fd5f9:  addr32 mov (%eax),%ds
0x000fd5fc:  pop    %eax
0x000fd5fe:  iret   

----------------
IN: 
0x000c9c3b:  je     0xc9c43

----------------
IN: 
0x000c9c43:  mov    $0x0,%cx
0x000c9c46:  dec    %cx
0x000c9c47:  js     0xc9c5e

----------------
IN: 
0x000c9c5e:  pop    %ax
0x000c9c5f:  pop    %cx
0x000c9c60:  ret    

----------------
IN: 
0x000c9a6e:  pushf  
0x000c9a6f:  xor    %di,%di
0x000c9a71:  call   0xc9d4c

----------------
IN: 
0x000c9d4c:  push   %ax
0x000c9d4d:  push   %cx
0x000c9d4e:  mov    $0xd,%al
0x000c9d50:  call   0xc9ccf

----------------
IN: 
0x000c9d53:  mov    $0x4f,%cx
0x000c9d56:  call   0xc9cee

----------------
IN: 
0x000c9cee:  push   %ax
0x000c9cef:  mov    $0x20,%al
0x000c9cf1:  call   0xc9ccf

----------------
IN: 
0x000c9cf4:  pop    %ax
0x000c9cf5:  ret    

----------------
IN: 
0x000c9d59:  loop   0xc9d56

----------------
IN: 
0x000c9d56:  call   0xc9cee

----------------
IN: 
0x000c9d5b:  call   0xc9ccf

----------------
IN: 
0x000c9d5e:  pop    %cx
0x000c9d5f:  pop    %ax
0x000c9d60:  ret    

----------------
IN: 
0x000c9a74:  mov    $0x352,%si
0x000c9a77:  call   0xc9cf6

----------------
IN: 
0x000c9a7a:  popf   

----------------
IN: 
0x000c9a7b:  jne    0xc9a84

----------------
IN: 
0x000c9a84:  mov    $0xa,%al
0x000c9a86:  xor    %di,%di
0x000c9a88:  call   0xc9ccf

----------------
IN: 
0x000c9a8b:  pop    %gs
0x000c9a8d:  pop    %fs
0x000c9a8f:  pop    %es
0x000c9a90:  pop    %ds
0x000c9a91:  popa   
0x000c9a92:  mov    $0x20,%ax
0x000c9a95:  lret   

----------------
IN: 
0x07fb8554:  lea    -0x310(%ebp),%ecx
0x07fb855a:  xor    %edx,%edx
0x07fb855c:  mov    $0xf4ceb,%eax
0x07fb8561:  call   0x7fb2695

----------------
IN: 
0x07fafa5f:  mov    %ebx,%eax
0x07fafa61:  pop    %ebx
0x07fafa62:  pop    %esi
0x07fafa63:  pop    %edi
0x07fafa64:  pop    %ebp
0x07fafa65:  ret    

----------------
IN: 
0x07fb26b7:  call   0x7fb10e7

----------------
IN: 
0x07fb10e7:  push   %edi
0x07fb10e8:  push   %esi
0x07fb10e9:  push   %ebx
0x07fb10ea:  mov    %eax,%esi
0x07fb10ec:  mov    0x84(%eax),%edi
0x07fb10f2:  mov    %edi,%eax
0x07fb10f4:  call   0x7faf991

----------------
IN: 
0x07fb10f9:  mov    %eax,%ebx
0x07fb10fb:  test   %eax,%eax
0x07fb10fd:  jne    0x7fb1112

----------------
IN: 
0x07fb1112:  mov    %edi,%ecx
0x07fb1114:  mov    %eax,%edx
0x07fb1116:  mov    %esi,%eax
0x07fb1118:  call   *0x88(%esi)

----------------
IN: 
0x07fb111e:  xor    %ecx,%ecx
0x07fb1120:  test   %eax,%eax
0x07fb1122:  jle    0x7fb1126

----------------
IN: 
0x07fb1124:  mov    %ebx,%ecx
0x07fb1126:  mov    %ecx,%eax
0x07fb1128:  pop    %ebx
0x07fb1129:  pop    %esi
0x07fb112a:  pop    %edi
0x07fb112b:  ret    

----------------
IN: 
0x07fb26bc:  test   %eax,%eax
0x07fb26be:  je     0x7fb26a7

----------------
IN: 
0x07fb26c0:  xor    %ebp,%ebp
0x07fb26c2:  test   %esi,%esi
0x07fb26c4:  je     0x7fb26d6

----------------
IN: 
0x07fb26c6:  lea    -0xc0000(%eax),%edx
0x07fb26cc:  shr    $0xb,%edx
0x07fb26cf:  mov    %ebx,(%esi,%edx,8)
0x07fb26d2:  mov    %ebp,0x4(%esi,%edx,8)
0x07fb26d6:  mov    0x4(%esp),%ecx
0x07fb26da:  xor    %edx,%edx
0x07fb26dc:  call   0x7fb25e7

----------------
IN: 
0x07fb26e1:  jmp    0x7fb26a7

----------------
IN: 
0x07fb26a7:  mov    %ebx,%edx
0x07fb26a9:  mov    (%esp),%eax
0x07fb26ac:  call   0x7fafa28

----------------
IN: 
0x07fafa41:  mov    (%edi),%ebx
0x07fafa43:  jmp    0x7fafa57

----------------
IN: 
0x07fb8566:  xor    %eax,%eax
0x07fb8568:  call   0x7faf991

----------------
IN: 
0x07fb856d:  cmp    0x7fbfe84,%ebx
0x07fb8573:  jae    0x7fb86f9

----------------
IN: 
0x07fb8579:  mov    %ebx,%eax
0x07fb857b:  call   0xf1e34

----------------
IN: 
0x07fb8580:  test   %eax,%eax
0x07fb8582:  jne    0x7fb8595

----------------
IN: 
0x07fb8595:  movzbl 0x2(%ebx),%eax
0x07fb8599:  shl    $0x9,%eax
0x07fb859c:  add    $0x7ff,%eax
0x07fb85a1:  and    $0xfffff800,%eax
0x07fb85a6:  add    %ebx,%eax
0x07fb85a8:  mov    %eax,-0x314(%ebp)
0x07fb85ae:  movzwl 0x1a(%ebx),%esi
0x07fb85b2:  add    %ebx,%esi
0x07fb85b4:  je     0x7fb85be

----------------
IN: 
0x07fb85b6:  cmpl   $0x506e5024,(%esi)
0x07fb85bc:  je     0x7fb85f9

----------------
IN: 
0x07fb85f9:  mov    %ebx,%eax
0x07fb85fb:  shr    $0x4,%eax
0x07fb85fe:  movzwl %ax,%eax
0x07fb8601:  mov    %eax,%edi
0x07fb8603:  shl    $0x4,%edi
0x07fb8606:  mov    %edi,-0x31c(%ebp)
0x07fb860c:  movl   $0x1,-0x318(%ebp)
0x07fb8616:  shl    $0x10,%eax
0x07fb8619:  mov    %eax,-0x320(%ebp)
0x07fb861f:  mov    -0x318(%ebp),%eax
0x07fb8625:  lea    -0x1(%eax),%ecx
0x07fb8628:  cmpw   $0x0,0x1a(%esi)
0x07fb862d:  je     0x7fb8680

----------------
IN: 
0x07fb862f:  mov    %ebx,%edx
0x07fb8631:  lea    -0x310(%ebp),%eax
0x07fb8637:  call   0x7fb8461

----------------
IN: 
0x07fb8461:  push   %edi
0x07fb8462:  push   %esi
0x07fb8463:  push   %ebx
0x07fb8464:  sub    $0x100,%esp
0x07fb846a:  sub    $0xc0000,%edx
0x07fb8470:  shr    $0xb,%edx
0x07fb8473:  mov    (%eax,%edx,8),%edi
0x07fb8476:  mov    0x4(%eax,%edx,8),%eax
0x07fb847a:  mov    %eax,%ebx
0x07fb847c:  or     %edi,%ebx
0x07fb847e:  je     0x7fb84db

----------------
IN: 
0x07fb8480:  mov    %ecx,%ebx
0x07fb8482:  test   $0x2,%al
0x07fb8484:  mov    %esp,%esi
0x07fb8486:  je     0x7fb849c

----------------
IN: 
0x07fb8488:  mov    %edi,%ecx
0x07fb848a:  mov    $0xf4caa,%edx
0x07fb848f:  mov    %esp,%eax
0x07fb8491:  call   0x7fb832a

----------------
IN: 
0x07fb8496:  test   %ebx,%ebx
0x07fb8498:  je     0x7fb84d2

----------------
IN: 
0x07fb84d2:  mov    %esi,%eax
0x07fb84d4:  call   0x7fb26eb

----------------
IN: 
0x07fb84d9:  jmp    0x7fb84de

----------------
IN: 
0x07fb84de:  add    $0x100,%esp
0x07fb84e4:  pop    %ebx
0x07fb84e5:  pop    %esi
0x07fb84e6:  pop    %edi
0x07fb84e7:  ret    

----------------
IN: 
0x07fb863c:  mov    0x10(%esi),%dx
0x07fb8640:  movzwl 0x1a(%esi),%ecx
0x07fb8644:  mov    $0xf4cbb,%edi
0x07fb8649:  test   %dx,%dx
0x07fb864c:  je     0x7fb8657

----------------
IN: 
0x07fb864e:  movzwl %dx,%edi
0x07fb8651:  add    -0x31c(%ebp),%edi
0x07fb8657:  or     -0x320(%ebp),%ecx
0x07fb865d:  mov    0x7fbfe6c,%edx
0x07fb8663:  test   %eax,%eax
0x07fb8665:  js     0x7fb8669

----------------
IN: 
0x07fb8669:  push   %edi
0x07fb866a:  mov    $0x80,%eax
0x07fb866f:  call   0x7fb112c

----------------
IN: 
0x07fb8674:  movl   $0x270f,0x7fbfe6c
0x07fb867e:  jmp    0x7fb86cc

----------------
IN: 
0x07fb86cc:  pop    %eax
0x07fb86cd:  movzwl 0x6(%esi),%esi
0x07fb86d1:  test   %si,%si
0x07fb86d4:  je     0x7fb86ee

----------------
IN: 
0x07fb86ee:  mov    -0x314(%ebp),%ebx
0x07fb86f4:  jmp    0x7fb856d

----------------
IN: 
0x07fb85be:  xor    %ecx,%ecx
0x07fb85c0:  mov    %ebx,%edx
0x07fb85c2:  lea    -0x310(%ebp),%eax
0x07fb85c8:  call   0x7fb8461

----------------
IN: 
0x07fb849c:  add    $0x4,%edi
0x07fb849f:  push   %edi
0x07fb84a0:  push   $0xf4cb3
0x07fb84a5:  push   $0x100
0x07fb84aa:  push   %esi
0x07fb84ab:  call   0x7fb5724

----------------
IN: 
0x07fb84b0:  add    $0x10,%esp
0x07fb84b3:  test   %ebx,%ebx
0x07fb84b5:  je     0x7fb84d2

----------------
IN: 
0x07fb85cd:  shr    $0x4,%ebx
0x07fb85d0:  mov    %ebx,%ecx
0x07fb85d2:  shl    $0x10,%ecx
0x07fb85d5:  or     $0x3,%ecx
0x07fb85d8:  mov    0x7fbfe70,%edx
0x07fb85de:  test   %eax,%eax
0x07fb85e0:  js     0x7fb85e4

----------------
IN: 
0x07fb85e4:  push   $0xf4cc3
0x07fb85e9:  mov    $0x81,%eax
0x07fb85ee:  call   0x7fb112c

----------------
IN: 
0x07fb119a:  cmp    -0x10(%ebx),%esi
0x07fb119d:  jl     0x7fb1183

----------------
IN: 
0x07fb119f:  jg     0x7fb11b9

----------------
IN: 
0x07fb85f3:  pop    %edx
0x07fb85f4:  jmp    0x7fb86ee

----------------
IN: 
0x07fb86f9:  lea    -0xc(%ebp),%esp
0x07fb86fc:  pop    %ebx
0x07fb86fd:  pop    %esi
0x07fb86fe:  pop    %edi
0x07fb86ff:  pop    %ebp
0x07fb8700:  lea    -0x8(%edi),%esp
0x07fb8703:  pop    %edi
0x07fb8704:  ret    

----------------
IN: 
0x07fbbd18:  mov    $0x1,%edx
0x07fbbd1d:  xor    %ecx,%ecx
0x07fbbd1f:  mov    $0xf5523,%eax
0x07fbbd24:  call   0x7fb0bfd

----------------
IN: 
0x07fbbd29:  or     %eax,%edx
0x07fbbd2b:  je     0x7fbd4d5

----------------
IN: 
0x07fbd4d5:  call   0x7fb0d15

----------------
IN: 
0x07fbd4da:  mov    $0xf5823,%eax
0x07fbd4df:  call   0x7fb26eb

----------------
IN: 
0x07fbd4e4:  test   %eax,%eax
0x07fbd4e6:  js     0x7fbd4fc

----------------
IN: 
0x07fbd4fc:  mov    0x7fbfe68,%eax
0x07fbd501:  sub    $0x10,%eax
0x07fbd504:  mov    %eax,(%esp)
0x07fbd507:  cmpl   $0xfffffff0,(%esp)
0x07fbd50b:  je     0x7fbd8df

----------------
IN: 
0x07fbd511:  mov    (%esp),%eax
0x07fbd514:  mov    (%eax),%eax
0x07fbd516:  cmp    $0x2,%eax
0x07fbd519:  je     0x7fbd5ac

----------------
IN: 
0x07fbd5ac:  mov    (%esp),%eax
0x07fbd5af:  mov    0x4(%eax),%ebx
0x07fbd5b2:  movzbl 0x475,%eax
0x07fbd5b9:  mov    %al,0x20(%esp)
0x07fbd5bd:  mov    %eax,0x18(%esp)
0x07fbd5c1:  mov    %ebx,%ecx
0x07fbd5c3:  mov    $0x475,%edx
0x07fbd5c8:  mov    $0xf6b5c,%eax
0x07fbd5cd:  call   0x7fb0f86

----------------
IN: 
0x07fb0f86:  push   %ebx
0x07fb0f87:  movzbl (%edx),%ebx
0x07fb0f8a:  cmp    $0xf,%bl
0x07fb0f8d:  jbe    0x7fb0f9f

----------------
IN: 
0x07fb0f9f:  mov    %ecx,(%eax,%ebx,4)
0x07fb0fa2:  incb   (%edx)
0x07fb0fa4:  pop    %ebx
0x07fb0fa5:  ret    

----------------
IN: 
0x07fbd5d2:  cmpb   $0x20,(%ebx)
0x07fbd5d5:  jne    0x7fbd5fb

----------------
IN: 
0x07fbd5d7:  mov    0x14(%ebx),%ecx
0x07fbd5da:  mov    %cl,%al
0x07fbd5dc:  shr    $0x2,%al
0x07fbd5df:  add    $0x39,%eax
0x07fbd5e2:  or     $0xffffff80,%eax
0x07fbd5e5:  out    %al,$0x70
0x07fbd5e7:  in     $0x71,%al
0x07fbd5e9:  movzbl %al,%eax
0x07fbd5ec:  and    $0x3,%ecx
0x07fbd5ef:  add    %ecx,%ecx
0x07fbd5f1:  sar    %cl,%eax
0x07fbd5f3:  and    $0x3,%eax
0x07fbd5f6:  jmp    0x7fbd67d

----------------
IN: 
0x07fbd67d:  mov    %al,0x19(%ebx)
0x07fbd680:  mov    0x1c(%ebx),%esi
0x07fbd683:  mov    %si,0x8(%esp)
0x07fbd688:  movzwl 0x1e(%ebx),%ecx
0x07fbd68c:  mov    0x20(%ebx),%edi
0x07fbd68f:  mov    %di,0x10(%esp)
0x07fbd694:  mov    0xc(%ebx),%esi
0x07fbd697:  mov    %esi,0x1c(%esp)
0x07fbd69b:  mov    0x10(%ebx),%edx
0x07fbd69e:  cmp    $0x2,%al
0x07fbd6a0:  je     0x7fbd74e

----------------
IN: 
0x07fbd74e:  mov    %ecx,%ebp
0x07fbd750:  mov    0x8(%esp),%esi
0x07fbd754:  mov    $0xf54d5,%eax
0x07fbd759:  cmp    $0x400,%bp
0x07fbd75e:  jbe    0x7fbd771

----------------
IN: 
0x07fbd771:  mov    0x10(%esp),%edi
0x07fbd775:  jmp    0x7fbd792

----------------
IN: 
0x07fbd792:  pushl  0x1c(%esp)
0x07fbd796:  movzwl %di,%edx
0x07fbd799:  push   %edx
0x07fbd79a:  movzwl %si,%edx
0x07fbd79d:  push   %edx
0x07fbd79e:  movzwl %bp,%edx
0x07fbd7a1:  push   %edx
0x07fbd7a2:  push   %eax
0x07fbd7a3:  movzwl 0x24(%esp),%eax
0x07fbd7a8:  push   %eax
0x07fbd7a9:  movzwl 0x20(%esp),%eax
0x07fbd7ae:  push   %eax
0x07fbd7af:  push   %ecx
0x07fbd7b0:  push   %ebx
0x07fbd7b1:  push   $0xf5828
0x07fbd7b6:  call   0xf0cc9

----------------
IN: 
0x07fbd7bb:  mov    %si,0x2(%ebx)
0x07fbd7bf:  mov    %bp,0x4(%ebx)
0x07fbd7c3:  mov    %di,0x6(%ebx)
0x07fbd7c7:  add    $0x28,%esp
0x07fbd7ca:  cmpl   $0x1,0x18(%esp)
0x07fbd7cf:  jg     0x7fbd8a9

----------------
IN: 
0x07fbd7d5:  mov    0x1e(%ebx),%cx
0x07fbd7d9:  mov    0x1c(%ebx),%eax
0x07fbd7dc:  mov    %ax,0x8(%esp)
0x07fbd7e1:  mov    0x20(%ebx),%eax
0x07fbd7e4:  mov    %ax,0x10(%esp)
0x07fbd7e9:  movzwl 0x40e,%ebx
0x07fbd7f0:  shl    $0x4,%ebx
0x07fbd7f3:  mov    %ebx,%edx
0x07fbd7f5:  mov    0x18(%esp),%eax
0x07fbd7f9:  add    $0x3,%eax
0x07fbd7fc:  shl    $0x4,%eax
0x07fbd7ff:  lea    0xd(%ebx,%eax,1),%eax
0x07fbd803:  mov    %eax,0x1c(%esp)
0x07fbd807:  movzbl 0x20(%esp),%ebx
0x07fbd80c:  shl    $0x4,%ebx
0x07fbd80f:  add    %edx,%ebx
0x07fbd811:  movw   $0xffff,0x42(%ebx)
0x07fbd817:  cmpw   $0x9,0x8(%esp)
0x07fbd81d:  sbb    %edx,%edx
0x07fbd81f:  and    $0xfffffff8,%edx
0x07fbd822:  sub    $0x38,%edx
0x07fbd825:  mov    %dl,0x45(%ebx)
0x07fbd828:  mov    %cx,0x49(%ebx)
0x07fbd82c:  mov    %bp,0x3d(%ebx)
0x07fbd830:  mov    %esi,%edx
0x07fbd832:  mov    %dl,0x3f(%ebx)
0x07fbd835:  mov    %edi,%edx
0x07fbd837:  mov    %dl,0x4b(%ebx)
0x07fbd83a:  cmp    0x8(%esp),%si
0x07fbd83f:  setne  %dl
0x07fbd842:  mov    %dl,%al
0x07fbd844:  cmp    %cx,%bp
0x07fbd847:  setne  %dl
0x07fbd84a:  or     %dl,%al
0x07fbd84c:  jne    0x7fbd855

----------------
IN: 
0x07fbd84e:  cmp    0x10(%esp),%di
0x07fbd853:  je     0x7fbd87c

----------------
IN: 
0x07fbd87c:  cmpl   $0x0,0x18(%esp)
0x07fbd881:  mov    0x40e,%ax
0x07fbd887:  jne    0x7fbd89a

----------------
IN: 
0x07fbd889:  movw   $0x3d,0x104
0x07fbd892:  mov    %ax,0x106
0x07fbd898:  jmp    0x7fbd8a9

----------------
IN: 
0x07fbd8a9:  xor    %edx,%edx
0x07fbd8ab:  mov    $0x2,%eax
0x07fbd8b0:  jmp    0x7fbd8cf

----------------
IN: 
0x07fbd8cf:  call   0x7fafa66

----------------
IN: 
0x07fafa66:  push   %ebx
0x07fafa67:  cmp    $0x2,%eax
0x07fafa6a:  jne    0x7fafaa3

----------------
IN: 
0x07fafa6c:  mov    0x7fbff28,%ecx
0x07fafa72:  lea    0x1(%ecx),%ebx
0x07fafa75:  mov    %ebx,0x7fbff28
0x07fafa7b:  test   %ecx,%ecx
0x07fafa7d:  jne    0x7fafab9

----------------
IN: 
0x07fafa7f:  mov    0xf5ed0,%ecx
0x07fafa85:  cmp    $0x13,%ecx
0x07fafa88:  ja     0x7fafab9

----------------
IN: 
0x07fafa8a:  lea    0x1(%ecx),%ebx
0x07fafa8d:  mov    %ebx,0xf5ed0
0x07fafa93:  mov    %eax,0xf5ed4(,%ecx,8)
0x07fafa9a:  mov    %edx,0xf5ed8(,%ecx,8)
0x07fafaa1:  jmp    0x7fafab9

----------------
IN: 
0x07fafab9:  pop    %ebx
0x07fafaba:  ret    

----------------
IN: 
0x07fbd8d4:  mov    (%esp),%eax
0x07fbd8d7:  mov    0x10(%eax),%eax
0x07fbd8da:  jmp    0x7fbd501

----------------
IN: 
0x07fbd501:  sub    $0x10,%eax
0x07fbd504:  mov    %eax,(%esp)
0x07fbd507:  cmpl   $0xfffffff0,(%esp)
0x07fbd50b:  je     0x7fbd8df

----------------
IN: 
0x07fbd51f:  jg     0x7fbd529

----------------
IN: 
0x07fbd529:  cmp    $0x3,%eax
0x07fbd52c:  je     0x7fbd8b2

----------------
IN: 
0x07fbd532:  cmp    $0x81,%eax
0x07fbd537:  jne    0x7fbd8c7

----------------
IN: 
0x07fbd53d:  mov    (%esp),%eax
0x07fbd540:  movzwl 0x4(%eax),%edx
0x07fbd544:  movzwl 0x6(%eax),%eax
0x07fbd548:  shl    $0x4,%eax
0x07fbd54b:  xor    %ecx,%ecx
0x07fbd54d:  call   0xf1dad

Servicing hardware INT=0x08
----------------
IN: 
0x000ca803:  push   %es
0x000ca804:  push   %cs
0x000ca805:  pop    %es
0x000ca806:  xor    %ax,%ax
0x000ca808:  mov    $0x1000,%cx
0x000ca80b:  lea    0x300,%di
0x000ca80f:  cld    
0x000ca810:  rep stos %ax,%es:(%di)

----------------
IN: 
0x000ca810:  rep stos %ax,%es:(%di)

----------------
IN: 
0x000ca812:  pop    %es
0x000ca813:  mov    $0x20,%ax
0x000ca816:  out    %ax,$0x7e
0x000ca818:  lret   

----------------
IN: 
0x07fbd552:  jmp    0x7fbd8a9

----------------
IN: 
0x07fbd521:  dec    %eax
0x07fbd522:  je     0x7fbd557

----------------
IN: 
0x07fbd557:  mov    (%esp),%eax
0x07fbd55a:  mov    0x4(%eax),%ecx
0x07fbd55d:  mov    $0xf6bdc,%edx
0x07fbd562:  mov    $0xf6b1c,%eax
0x07fbd567:  call   0x7fb0f86

----------------
IN: 
0x07fbd56c:  cmpb   $0x1,0xf6bdc
0x07fbd573:  jne    0x7fbd58f

----------------
IN: 
0x07fbd575:  mov    0x410,%eax
0x07fbd57a:  and    $0xffffffbe,%eax
0x07fbd57d:  or     $0x1,%eax
0x07fbd580:  mov    %ax,0x410
0x07fbd586:  movb   $0x7,0x48f
0x07fbd58d:  jmp    0x7fbd5a0

----------------
IN: 
0x07fbd5a0:  xor    %edx,%edx
0x07fbd5a2:  mov    $0x1,%eax
0x07fbd5a7:  jmp    0x7fbd8cf

----------------
IN: 
0x07fafaa3:  cmp    $0x1,%eax
0x07fafaa6:  jne    0x7fafa7f

----------------
IN: 
0x07fafaa8:  mov    0x7fbff24,%ecx
0x07fafaae:  lea    0x1(%ecx),%ebx
0x07fafab1:  mov    %ebx,0x7fbff24
0x07fafab7:  jmp    0x7fafa7b

----------------
IN: 
0x07fafa7b:  test   %ecx,%ecx
0x07fafa7d:  jne    0x7fafab9

----------------
IN: 
0x07fbd8b2:  mov    (%esp),%eax
0x07fbd8b5:  mov    0x4(%eax),%ecx
0x07fbd8b8:  mov    $0x7fbff38,%edx
0x07fbd8bd:  mov    $0xf6b9c,%eax
0x07fbd8c2:  call   0x7fb0f86

----------------
IN: 
0x07fbd8c7:  mov    (%esp),%eax
0x07fbd8ca:  mov    0x4(%eax),%edx
0x07fbd8cd:  mov    (%eax),%eax
0x07fbd8cf:  call   0x7fafa66

----------------
IN: 
0x07fbd8df:  xor    %edx,%edx
0x07fbd8e1:  mov    $0x1,%eax
0x07fbd8e6:  call   0x7fafa66

----------------
IN: 
0x07fbd8eb:  xor    %edx,%edx
0x07fbd8ed:  mov    $0x2,%eax
0x07fbd8f2:  call   0x7fafa66

----------------
IN: 
0x07fbd8f7:  cmpb   $0x0,0x7fbff38
0x07fbd8fe:  je     0x7fbd959

----------------
IN: 
0x07fbd900:  call   0x7fb0f52

----------------
IN: 
0x07fb0f52:  push   %ebx
0x07fb0f53:  xor    %ebx,%ebx
0x07fb0f55:  cmpl   $0x0,0xf6b18
0x07fb0f5c:  jne    0x7fb0f82

----------------
IN: 
0x07fb0f5e:  mov    $0x800,%eax
0x07fb0f63:  call   0x7faf8e0

----------------
IN: 
0x07faf8e0:  mov    $0x10,%ecx
0x07faf8e5:  mov    %eax,%edx
0x07faf8e7:  mov    $0x7fbfeac,%eax
0x07faf8ec:  jmp    0x7faf858

----------------
IN: 
0x07fb0f68:  test   %eax,%eax
0x07fb0f6a:  jne    0x7fb0f7d

----------------
IN: 
0x07fb0f7d:  mov    %eax,0xf6b18
0x07fb0f82:  mov    %ebx,%eax
0x07fb0f84:  pop    %ebx
0x07fb0f85:  ret    

----------------
IN: 
0x07fbd905:  test   %eax,%eax
0x07fbd907:  js     0x7fbd959

----------------
IN: 
0x07fbd909:  mov    $0x24,%eax
0x07fbd90e:  call   0x7faf8f1

----------------
IN: 
0x07fbd913:  mov    %eax,%ebx
0x07fbd915:  test   %eax,%eax
0x07fbd917:  jne    0x7fbd931

----------------
IN: 
0x07fbd931:  mov    %eax,0xf6b14
0x07fbd936:  mov    $0x24,%ecx
0x07fbd93b:  xor    %edx,%edx
0x07fbd93d:  call   0xf0090

----------------
IN: 
0x07fbd942:  movb   $0x40,(%ebx)
0x07fbd945:  movw   $0x200,0x1a(%ebx)
0x07fbd94b:  movl   $0xffffffff,0xc(%ebx)
0x07fbd952:  movl   $0xffffffff,0x10(%ebx)
0x07fbd959:  movl   $0x0,0xf67b0
0x07fbd963:  movl   $0x0,0xf67b7
0x07fbd96d:  call   0xf01ad

----------------
IN: 
0x07fbd972:  mov    %eax,%ebx
0x07fbd974:  mov    0x7fbfe84,%eax
0x07fbd979:  mov    %ebx,%ecx
0x07fbd97b:  sub    %eax,%ecx
0x07fbd97d:  xor    %edx,%edx
0x07fbd97f:  call   0xf0090

----------------
IN: 
0x07fbd984:  movw   $0xaa55,(%ebx)
0x07fbd989:  mov    $0xf0000,%edx
0x07fbd98e:  sub    %ebx,%edx
0x07fbd990:  shr    $0x9,%edx
0x07fbd993:  cmp    $0xff,%edx
0x07fbd999:  jle    0x7fbd9a0

----------------
IN: 
0x07fbd9a0:  mov    %dl,0x2(%ebx)
0x07fbd9a3:  movzwl 0x413,%ecx
0x07fbd9aa:  shl    $0xa,%ecx
0x07fbd9ad:  mov    %ecx,%eax
0x07fbd9af:  cltd   
0x07fbd9b0:  push   $0x2
0x07fbd9b2:  mov    $0xa0000,%esi
0x07fbd9b7:  sub    %ecx,%esi
0x07fbd9b9:  xor    %edi,%edi
0x07fbd9bb:  push   %edi
0x07fbd9bc:  push   %esi
0x07fbd9bd:  call   0x7fb1824

----------------
IN: 
0x07fb1784:  add    0xf67d0(%esi),%eax
0x07fb178a:  adc    0xf67d4(%esi),%edx
0x07fb1790:  cmp    %edx,0x4(%esp)
0x07fb1794:  jb     0x7fb17a6

----------------
IN: 
0x07fb1796:  ja     0x7fb179d

----------------
IN: 
0x07fb1798:  cmp    %eax,(%esp)
0x07fb179b:  jb     0x7fb17a6

----------------
IN: 
0x07fb179d:  mov    %ebx,%eax
0x07fb179f:  call   0x7fb0220

----------------
IN: 
0x07fb0220:  mov    0xf67c4,%edx
0x07fb0226:  lea    -0x1(%edx),%ecx
0x07fb0229:  mov    %ecx,0xf67c4
0x07fb022f:  sub    %eax,%ecx
0x07fb0231:  imul   $0x14,%ecx,%ecx
0x07fb0234:  lea    0x1(%eax),%edx
0x07fb0237:  imul   $0x14,%edx,%edx
0x07fb023a:  add    $0xf67c8,%edx
0x07fb0240:  imul   $0x14,%eax,%eax
0x07fb0243:  add    $0xf67c8,%eax
0x07fb0248:  jmp    0x7fb01f0

----------------
IN: 
0x07fb01f7:  mov    %eax,%edi
0x07fb01f9:  mov    %edx,%esi
0x07fb01fb:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb01fb:  rep movsb %ds:(%esi),%es:(%edi)

----------------
IN: 
0x07fb01fd:  jmp    0x7fb021c

----------------
IN: 
0x07fb021c:  pop    %ebx
0x07fb021d:  pop    %esi
0x07fb021e:  pop    %edi
0x07fb021f:  ret    

----------------
IN: 
0x07fb17a4:  jmp    0x7fb1763

----------------
IN: 
0x07fb1763:  cmp    0xf67c4,%ebx
0x07fb1769:  jge    0x7fb17e7

----------------
IN: 
0x07fbd9c2:  mov    0x7fbfea4,%esi
0x07fbd9c8:  add    $0xc,%esp
0x07fbd9cb:  xor    %edi,%edi
0x07fbd9cd:  test   %esi,%esi
0x07fbd9cf:  je     0x7fbd9d7

----------------
IN: 
0x07fbd9d1:  mov    %esi,%edi
0x07fbd9d3:  mov    (%esi),%esi
0x07fbd9d5:  jmp    0x7fbd9cd

----------------
IN: 
0x07fbd9cd:  test   %esi,%esi
0x07fbd9cf:  je     0x7fbd9d7

----------------
IN: 
0x07fbd9d7:  mov    0xc(%edi),%eax
0x07fbd9da:  mov    0x10(%edi),%ecx
0x07fbd9dd:  sub    %eax,%ecx
0x07fbd9df:  xor    %edx,%edx
0x07fbd9e1:  call   0xf0090

----------------
IN: 
0x07fbd9e6:  pushl  0x10(%edi)
0x07fbd9e9:  pushl  0xc(%edi)
0x07fbd9ec:  push   %ebx
0x07fbd9ed:  pushl  0x7fbfe84
0x07fbd9f3:  push   $0xf5863
0x07fbd9f8:  call   0xf0cc9

----------------
IN: 
0x07fbd9fd:  mov    0x7fbfea8,%eax
0x07fbda02:  add    $0x14,%esp
0x07fbda05:  test   %eax,%eax
0x07fbda07:  je     0x7fbda0f

----------------
IN: 
0x07fbda09:  mov    %eax,%esi
0x07fbda0b:  mov    (%eax),%eax
0x07fbda0d:  jmp    0x7fbda05

----------------
IN: 
0x07fbda05:  test   %eax,%eax
0x07fbda07:  je     0x7fbda0f

----------------
IN: 
0x07fbda0f:  test   %esi,%esi
0x07fbda11:  je     0x7fbda3c

----------------
IN: 
0x07fbda13:  mov    0xc(%esi),%eax
0x07fbda16:  mov    0x10(%esi),%ebx
0x07fbda19:  sub    %eax,%ebx
0x07fbda1b:  and    $0xfffff000,%ebx
0x07fbda21:  xor    %edx,%edx
0x07fbda23:  push   $0x1
0x07fbda25:  xor    %edi,%edi
0x07fbda27:  push   %edi
0x07fbda28:  push   %ebx
0x07fbda29:  call   0x7fb1824

----------------
IN: 
0x07fb16cc:  inc    %ebx
0x07fb16cd:  jmp    0x7fb1694

----------------
IN: 
0x07fb1694:  cmp    %esi,%ebx
0x07fb1696:  jge    0x7fb1760

----------------
IN: 
0x07fb16f0:  mov    (%esp),%edi
0x07fb16f3:  mov    0x4(%esp),%ebp
0x07fb16f7:  sub    %eax,%edi
0x07fb16f9:  sbb    %edx,%ebp
0x07fb16fb:  mov    %edi,0x18(%esp)
0x07fb16ff:  mov    %ebp,0x1c(%esp)
0x07fb1703:  mov    %eax,0x8(%esp)
0x07fb1707:  mov    %edx,0xc(%esp)
0x07fb170b:  jmp    0x7fb1760

----------------
IN: 
0x07fb17a6:  imul   $0x14,%ebx,%ecx
0x07fb17a9:  mov    (%esp),%esi
0x07fb17ac:  mov    0x4(%esp),%edi
0x07fb17b0:  mov    %esi,0xf67c8(%ecx)
0x07fb17b6:  mov    %edi,0xf67cc(%ecx)
0x07fb17bc:  sub    %esi,%eax
0x07fb17be:  sbb    %edi,%edx
0x07fb17c0:  mov    %eax,0xf67d0(%ecx)
0x07fb17c6:  mov    %edx,0xf67d4(%ecx)
0x07fb17cc:  mov    0x20(%esp),%esi
0x07fb17d0:  cmp    0xf67d8(%ecx),%esi
0x07fb17d6:  jne    0x7fb17e7

----------------
IN: 
0x07fbda2e:  push   %ebx
0x07fbda2f:  push   $0xf588a
0x07fbda34:  call   0xf0cc9

----------------
IN: 
0x07fbda39:  add    $0x14,%esp
0x07fbda3c:  call   0x7faf9d7

----------------
IN: 
0x07fbda41:  pushl  0xf67c4
0x07fbda47:  push   $0xf58a9
0x07fbda4c:  call   0xf0cc9

----------------
IN: 
0x07fbda51:  mov    $0xf67c8,%esi
0x07fbda56:  pop    %ebp
0x07fbda57:  pop    %eax
0x07fbda58:  xor    %edi,%edi
0x07fbda5a:  cmp    0xf67c4,%edi
0x07fbda60:  jge    0x7fbdade

----------------
IN: 
0x07fbda62:  mov    (%esi),%ecx
0x07fbda64:  mov    0x4(%esi),%ebx
0x07fbda67:  mov    %ecx,%eax
0x07fbda69:  mov    %ebx,%edx
0x07fbda6b:  add    0x8(%esi),%eax
0x07fbda6e:  adc    0xc(%esi),%edx
0x07fbda71:  mov    %eax,(%esp)
0x07fbda74:  mov    %edx,0x4(%esp)
0x07fbda78:  mov    0x10(%esi),%edx
0x07fbda7b:  mov    $0xf54f1,%eax
0x07fbda80:  cmp    $0x3,%edx
0x07fbda83:  je     0x7fbdabb

----------------
IN: 
0x07fbda85:  ja     0x7fbda9b

----------------
IN: 
0x07fbda87:  mov    $0xf54e4,%eax
0x07fbda8c:  cmp    $0x1,%edx
0x07fbda8f:  je     0x7fbdabb

----------------
IN: 
0x07fbdabb:  push   %eax
0x07fbdabc:  push   %edx
0x07fbdabd:  pushl  0xc(%esp)
0x07fbdac1:  pushl  0xc(%esp)
0x07fbdac5:  push   %ebx
0x07fbdac6:  push   %ecx
0x07fbdac7:  push   %edi
0x07fbdac8:  push   $0xf58c1
0x07fbdacd:  call   0xf0cc9

----------------
IN: 
0x07fbdad2:  inc    %edi
0x07fbdad3:  add    $0x14,%esi
0x07fbdad6:  add    $0x20,%esp
0x07fbdad9:  jmp    0x7fbda5a

----------------
IN: 
0x07fbda5a:  cmp    0xf67c4,%edi
0x07fbda60:  jge    0x7fbdade

----------------
IN: 
0x07fbda91:  mov    $0xf54e8,%eax
0x07fbda96:  cmp    $0x2,%edx
0x07fbda99:  jmp    0x7fbdab4

----------------
IN: 
0x07fbdab4:  je     0x7fbdabb

----------------
IN: 
0x000f0943:  sub    $0x8,%ecx
0x000f0946:  push   %eax
0x000f0947:  mov    %edi,%eax
0x000f0949:  call   0xf0029

----------------
IN: 
0x000f094e:  mov    $0x8,%ecx
0x000f0953:  mov    0x8(%esp),%edx
0x000f0957:  mov    %edi,%eax
0x000f0959:  call   0xeffa6

----------------
IN: 
0x000f095e:  jmp    0xf096f

----------------
IN: 
0x07fbdade:  movl   $0x2,0xf6c48
0x07fbdae8:  mov    $0x10000,%edx
0x07fbdaed:  mov    $0xf0000,%eax
0x07fbdaf2:  call   0xf069f

----------------
IN: 
0x07fbdaf7:  sub    %al,0xfffff
0x07fbdafd:  call   0xf1ee4

----------------
IN: 
0x000f1ee4:  testb  $0x2,0xf67a0
0x000f1eeb:  jne    0xf1f2d

----------------
IN: 
0x000f1eed:  push   %ebx
0x000f1eee:  mov    0xf5ce4,%ebx
0x000f1ef4:  test   %ebx,%ebx
0x000f1ef6:  jns    0xf1f06

----------------
IN: 
0x000f1f06:  movzwl %bx,%ebx
0x000f1f09:  mov    $0x2,%edx
0x000f1f0e:  mov    %ebx,%eax
0x000f1f10:  call   0xf010e

----------------
IN: 
0x000f1f15:  mov    $0x59,%edx
0x000f1f1a:  cmp    $0x1237,%ax
0x000f1f1e:  je     0xf1f25

----------------
IN: 
0x000f1f25:  mov    %ebx,%eax
0x000f1f27:  pop    %ebx
0x000f1f28:  jmp    0xf030c

----------------
IN: 
0x000f030c:  push   %ebp
0x000f030d:  push   %edi
0x000f030e:  push   %esi
0x000f030f:  push   %ebx
0x000f0310:  push   %esi
0x000f0311:  mov    %eax,%ebx
0x000f0313:  mov    %edx,%edi
0x000f0315:  movzwl %ax,%ebp
0x000f0318:  wbinvd 
0x000f031a:  call   0xf01ad

----------------
IN: 
0x000f031f:  mov    %eax,(%esp)
0x000f0322:  mov    $0x1,%esi
0x000f0327:  lea    0x17(%esi),%eax
0x000f032a:  shl    $0xf,%eax
0x000f032d:  lea    (%esi,%edi,1),%edx
0x000f0330:  lea    0x8000(%eax),%ecx
0x000f0336:  cmp    %ecx,(%esp)
0x000f0339:  jae    0xf0354

----------------
IN: 
0x000f0354:  mov    $0x11,%ecx
0x000f0359:  mov    %ebp,%eax
0x000f035b:  call   0xf00bf

----------------
IN: 
0x000f0360:  inc    %esi
0x000f0361:  cmp    $0x7,%esi
0x000f0364:  jne    0xf0327

----------------
IN: 
0x000f0327:  lea    0x17(%esi),%eax
0x000f032a:  shl    $0xf,%eax
0x000f032d:  lea    (%esi,%edi,1),%edx
0x000f0330:  lea    0x8000(%eax),%ecx
0x000f0336:  cmp    %ecx,(%esp)
0x000f0339:  jae    0xf0354

----------------
IN: 
0x000f033b:  add    $0x4000,%eax
0x000f0340:  cmp    %eax,(%esp)
0x000f0343:  jb     0xf0366

----------------
IN: 
0x000f0345:  movzwl %bx,%eax
0x000f0348:  mov    $0x31,%ecx
0x000f034d:  call   0xf00bf

----------------
IN: 
0x000f0352:  jmp    0xf0366

----------------
IN: 
0x000f0366:  movzwl %bx,%eax
0x000f0369:  mov    $0x10,%ecx
0x000f036e:  mov    %edi,%edx
0x000f0370:  pop    %ebx
0x000f0371:  pop    %ebx
0x000f0372:  pop    %esi
0x000f0373:  pop    %edi
0x000f0374:  pop    %ebp
0x000f0375:  jmp    0xf00bf

----------------
IN: 
0x07fbdb02:  call   0xf3651

----------------
IN: 
0x000f3651:  sub    $0x28,%esp
0x000f3654:  mov    $0x89000,%ecx
0x000f3659:  xor    %edx,%edx
0x000f365b:  mov    $0x7000,%eax
0x000f3660:  call   0xf0090

----------------
IN: 
0x000f3665:  mov    $0x26,%ecx
0x000f366a:  xor    %edx,%edx
0x000f366c:  lea    0x2(%esp),%eax
0x000f3670:  call   0xf0090

----------------
IN: 
0x000f3675:  movw   $0x200,0x26(%esp)
0x000f367c:  mov    $0xfe984,%edx
0x000f3681:  movzwl %dx,%edx
0x000f3684:  lea    0x2(%esp),%eax
0x000f3688:  call   0xf0c38

----------------
IN: 
0x000f0b6e:  pop    %ebx
0x000f0b6f:  pop    %esi
0x000f0b70:  pop    %edi
0x000f0b71:  pop    %ebp
0x000f0b72:  jmp    0xf0abb

----------------
IN: 
0x000f0abb:  push   %esi
0x000f0abc:  push   %ebx
0x000f0abd:  mov    %edx,%esi
0x000f0abf:  mov    %esp,%edx
0x000f0ac1:  cmp    $0x7000,%edx
0x000f0ac7:  jbe    0xf0ad3

----------------
IN: 
0x000f0ad3:  lea    -0xf0000(%ecx),%ebx
0x000f0ad9:  mov    $0x6c5f,%edx
0x000f0ade:  jmp    0xfd1ab

----------------
IN: 
0x000fd1ab:  mov    %eax,%ecx
0x000fd1ad:  mov    $0x20,%eax
0x000fd1b2:  mov    %eax,%ds

----------------
IN: 
0x000fd1b4:  mov    %eax,%es

----------------
IN: 
0x000fd1b6:  mov    %eax,%ss

----------------
IN: 
0x000fd1b8:  mov    %eax,%fs

----------------
IN: 
0x000fd1ba:  mov    %eax,%gs
0x000fd1bc:  ljmpw  $0x18,$0xd1d9

----------------
IN: 
0x000f6c5f:  mov    %esi,%edx
0x000f6c62:  calll  *%ebx

Servicing hardware INT=0x08
----------------
IN: 
0x000fe984:  int    $0x19

----------------
IN: 
0x000fe6f2:  jmp    0xfd635

----------------
IN: 
0x000fd635:  xor    %dx,%dx
0x000fd637:  mov    %dx,%ss

----------------
IN: 
0x000fd639:  mov    $0x7000,%esp

----------------
IN: 
0x000fd63f:  mov    $0xf37ad,%edx
0x000fd645:  jmp    0xfd165

----------------
IN: 
0x000f37ad:  push   $0xf5c10
0x000f37b2:  push   $0xf5b2a
0x000f37b7:  call   0xf0cc9

----------------
IN: 
0x000f37bc:  push   $0xf5b35
0x000f37c1:  call   0xf0cc9

----------------
IN: 
0x000f37c6:  movl   $0x0,0xef680
0x000f37d0:  add    $0xc,%esp
0x000f37d3:  xor    %eax,%eax
0x000f37d5:  jmp    0xf3534

----------------
IN: 
0x000f3534:  push   %ebx
0x000f3535:  sub    $0x28,%esp
0x000f3538:  cmp    0xf5ed0,%eax
0x000f353e:  jge    0xf361f

----------------
IN: 
0x000f3544:  mov    0xf5ed4(,%eax,8),%edx
0x000f354b:  cmp    $0x3,%edx
0x000f354e:  je     0xf35ad

----------------
IN: 
0x000f3550:  jg     0xf3576

----------------
IN: 
0x000f3552:  cmp    $0x1,%edx
0x000f3555:  je     0xf3593

----------------
IN: 
0x000f3557:  cmp    $0x2,%edx
0x000f355a:  jne    0xf3624

----------------
IN: 
0x000f3560:  push   $0xf5436
0x000f3565:  call   0xf2dae

----------------
IN: 
0x000f6c65:  mov    $0xf0ae3,%edx
0x000f6c6b:  jmp    0xfd165

----------------
IN: 
0x000f0ae3:  pop    %ebx
0x000f0ae4:  pop    %esi
0x000f0ae5:  ret    

----------------
IN: 
0x000f356a:  mov    $0x1,%edx
0x000f356f:  mov    $0x80,%eax
0x000f3574:  jmp    0xf35a5

----------------
IN: 
0x000f35a5:  call   0xf2dc1

----------------
IN: 
0x000f2dc1:  push   %esi
0x000f2dc2:  push   %ebx
0x000f2dc3:  sub    $0x28,%esp
0x000f2dc6:  mov    %eax,%ebx
0x000f2dc8:  mov    %edx,%esi
0x000f2dca:  mov    $0x26,%ecx
0x000f2dcf:  xor    %edx,%edx
0x000f2dd1:  lea    0x2(%esp),%eax
0x000f2dd5:  call   0xf0090

----------------
IN: 
0x000f2dda:  movw   $0x200,0x26(%esp)
0x000f2de1:  mov    %bl,0x16(%esp)
0x000f2de5:  movw   $0x7c0,0x4(%esp)
0x000f2dec:  movb   $0x2,0x1f(%esp)
0x000f2df1:  movb   $0x1,0x1e(%esp)
0x000f2df6:  movb   $0x1,0x1a(%esp)
0x000f2dfb:  mov    $0xfd293,%edx
0x000f2e00:  movzwl %dx,%edx
0x000f2e03:  lea    0x2(%esp),%eax
0x000f2e07:  call   0xf0c38

----------------
IN: 
0x000fd293:  int    $0x13

----------------
IN: 
0x000fe3fe:  jmp    0xfd5ff

----------------
IN: 
0x000fd5ff:  pushl  $0xc21c
0x000fd605:  jmp    0xfd55d

----------------
IN: 
0x000fc21c:  push   %edi
0x000fc21e:  push   %esi
0x000fc220:  push   %ebx
0x000fc222:  addr32 mov 0x14(%eax),%dl
0x000fc226:  addr32 cmpb $0x4b,0x1d(%eax)
0x000fc22b:  jne    0xfc270

----------------
IN: 
0x000fc270:  mov    $0xe000,%ecx
0x000fc276:  mov    %cx,%es
0x000fc278:  mov    %es:-0x95b,%bl
0x000fc27d:  test   %bl,%bl
0x000fc27f:  je     0xfc2bf

----------------
IN: 
0x000fc2bf:  movzbl %dl,%edx
0x000fc2c3:  pop    %ebx
0x000fc2c5:  pop    %esi
0x000fc2c7:  pop    %edi
0x000fc2c9:  jmp    0xf95b8

----------------
IN: 
0x000f95b8:  test   %dl,%dl
0x000f95ba:  js     0xf95f6

----------------
IN: 
0x000f95f6:  cmp    $0xdf,%dl
0x000f95f9:  jbe    0xf9614

----------------
IN: 
0x000f9614:  add    $0xffffff80,%edx
0x000f9618:  cmp    $0xf,%dl
0x000f961b:  ja     0xf9633

----------------
IN: 
0x000f961d:  movzbl %dl,%edx
0x000f9621:  addr32 mov %cs:0x6b5c(,%edx,4),%edx
0x000f962b:  test   %edx,%edx
0x000f962e:  je     0xf9633

----------------
IN: 
0x000f9630:  jmp    0xf927c

----------------
IN: 
0x000f927c:  push   %esi
0x000f927e:  push   %ebx
0x000f9280:  mov    $0x40,%ebx
0x000f9286:  mov    %bx,%es
0x000f9288:  xor    %ecx,%ecx
0x000f928b:  mov    %cl,%es:0x8e
0x000f9290:  addr32 mov 0x1d(%eax),%cl
0x000f9294:  cmp    $0x14,%cl
0x000f9297:  je     0xf93f5

----------------
IN: 
0x000f929b:  ja     0xf9313

----------------
IN: 
0x000f929d:  cmp    $0x5,%cl
0x000f92a0:  je     0xf93ce

----------------
IN: 
0x000f92a4:  ja     0xf92d5

----------------
IN: 
0x000f92a6:  cmp    $0x2,%cl
0x000f92a9:  je     0xf93b9

----------------
IN: 
0x000f93b9:  mov    $0x2,%ecx
0x000f93bf:  jmp    0xf93c7

----------------
IN: 
0x000f93c7:  pop    %ebx
0x000f93c9:  pop    %esi
0x000f93cb:  jmp    0xf7bee

----------------
IN: 
0x000f7bee:  push   %ebp
0x000f7bf0:  push   %edi
0x000f7bf2:  push   %esi
0x000f7bf4:  push   %ebx
0x000f7bf6:  sub    $0x18,%esp
0x000f7bfa:  mov    %eax,%ebx
0x000f7bfd:  mov    %edx,%esi
0x000f7c00:  addr32 mov %edx,0x10(%esp)
0x000f7c06:  addr32 mov %cl,0x16(%esp)
0x000f7c0b:  addr32 movzbl 0x1c(%eax),%eax
0x000f7c11:  addr32 mov 0x19(%ebx),%cl
0x000f7c15:  addr32 mov %cl,0x3(%esp)
0x000f7c1a:  addr32 mov 0x18(%ebx),%cl
0x000f7c1e:  mov    %cl,%dl
0x000f7c20:  and    $0x3f,%edx
0x000f7c24:  addr32 mov %dl,0x1(%esp)
0x000f7c29:  addr32 mov 0x15(%ebx),%dl
0x000f7c2d:  addr32 mov %dl,0x2(%esp)
0x000f7c32:  mov    %al,%dl
0x000f7c34:  dec    %dl
0x000f7c36:  js     0xf7c40

----------------
IN: 
0x000f7c38:  addr32 cmpb $0x0,0x1(%esp)
0x000f7c3e:  jne    0xf7c49

----------------
IN: 
0x000f7c49:  addr32 lea 0x0(,%ecx,4),%edi
0x000f7c52:  and    $0x300,%di
0x000f7c56:  addr32 movzbl 0x3(%esp),%edx
0x000f7c5d:  or     %edx,%edi
0x000f7c60:  addr32 mov %ax,0x14(%esp)
0x000f7c65:  mov    %esi,%eax
0x000f7c68:  calll  0xf7886

----------------
IN: 
0x000f7886:  push   %ebx
0x000f7888:  mov    %cs:0x6b14,%edx
0x000f788e:  cmp    %edx,%eax
0x000f7891:  jne    0xf78d8

----------------
IN: 
0x000f78d8:  addr32 mov %cs:-0xefffc(%eax),%cx
0x000f78e0:  addr32 mov %cs:-0xefffe(%eax),%bx
0x000f78e8:  addr32 mov %cs:-0xefffa(%eax),%dx
0x000f78f0:  shl    $0x10,%ecx
0x000f78f4:  movzwl %bx,%eax
0x000f78f8:  or     %ecx,%eax
0x000f78fb:  movzwl %dx,%edx
0x000f78ff:  pop    %ebx
0x000f7901:  retl   

----------------
IN: 
0x000f7c6e:  mov    %edx,%ebp
0x000f7c71:  addr32 movzbl 0x1(%esp),%esi
0x000f7c78:  cmp    %dx,%si
0x000f7c7a:  seta   %cl
0x000f7c7d:  mov    %cl,%dl
0x000f7c7f:  addr32 movzbl 0x2(%esp),%esi
0x000f7c86:  cmp    %ax,%si
0x000f7c88:  setae  %cl
0x000f7c8b:  or     %cl,%dl
0x000f7c8d:  jne    0xf7c9a

----------------
IN: 
0x000f7c8f:  mov    %eax,%esi
0x000f7c92:  shr    $0x10,%esi
0x000f7c96:  cmp    %si,%di
0x000f7c98:  jb     0xf7ca2

----------------
IN: 
0x000f7ca2:  addr32 movzbl 0x1(%esp),%ecx
0x000f7ca9:  movzwl %di,%edi
0x000f7cad:  movzwl %ax,%eax
0x000f7cb1:  imul   %edi,%eax
0x000f7cb5:  addr32 movzbl 0x2(%esp),%edi
0x000f7cbc:  add    %edi,%eax
0x000f7cbf:  movzwl %bp,%edx
0x000f7cc3:  imul   %eax,%edx
0x000f7cc7:  addr32 lea -0x1(%ecx,%edx,1),%eax
0x000f7ccd:  addr32 mov %eax,0x4(%esp)
0x000f7cd3:  addr32 movl $0x0,0x8(%esp)
0x000f7cdd:  addr32 movzwl 0x2(%ebx),%eax
0x000f7ce3:  shl    $0x4,%eax
0x000f7ce7:  addr32 movzwl 0x10(%ebx),%edx
0x000f7ced:  add    %edx,%eax
0x000f7cf0:  addr32 mov %eax,0xc(%esp)
0x000f7cf6:  addr32 lea 0x4(%esp),%eax
0x000f7cfc:  calll  0xfe68d

----------------
IN: 
0x000fe68d:  push   %edi
0x000fe68f:  push   %esi
0x000fe691:  push   %ebx
0x000fe693:  mov    %eax,%ebx
0x000fe696:  mov    %ss,%dx
0x000fe698:  movzwl %dx,%esi
0x000fe69c:  calll  0xf76c1

----------------
IN: 
0x000fe6a2:  test   %eax,%eax
0x000fe6a5:  je     0xfe6b6

----------------
IN: 
0x000fe6a7:  mov    %esi,%edx
0x000fe6aa:  mov    %ebx,%eax
0x000fe6ad:  pop    %ebx
0x000fe6af:  pop    %esi
0x000fe6b1:  pop    %edi
0x000fe6b3:  jmp    0xfc009

----------------
IN: 
0x000fc009:  push   %ebp
0x000fc00b:  push   %edi
0x000fc00d:  push   %esi
0x000fc00f:  push   %ebx
0x000fc011:  sub    $0x14,%esp
0x000fc015:  mov    %eax,%ebp
0x000fc018:  mov    %edx,%ebx
0x000fc01b:  mov    %ss,%ax
0x000fc01d:  mov    %ax,%es
0x000fc01f:  mov    $0x14,%ecx
0x000fc025:  mov    %ebp,%esi
0x000fc028:  mov    %esp,%edi
0x000fc02b:  mov    %ds,%ax
0x000fc02d:  mov    %dx,%ds
0x000fc02f:  rep movsb %ds:(%si),%es:(%di)

----------------
IN: 
0x000fc02f:  rep movsb %ds:(%si),%es:(%di)

----------------
IN: 
0x000fc031:  mov    %ax,%ds
0x000fc033:  mov    %esp,%eax
0x000fc036:  calll  0xfbc0c

----------------
IN: 
0x000fbc0c:  push   %ebp
0x000fbc0e:  push   %edi
0x000fbc10:  push   %esi
0x000fbc12:  push   %ebx
0x000fbc14:  push   %ecx
0x000fbc16:  addr32 movzwl 0x10(%eax),%edi
0x000fbc1c:  addr32 mov 0xc(%eax),%esi
0x000fbc21:  addr32 mov %cs:-0xeffe6(%esi),%dx
0x000fbc29:  movzwl %dx,%edx
0x000fbc2d:  imul   %edi,%edx
0x000fbc31:  cmp    $0x10000,%edx
0x000fbc38:  jle    0xfbc49

----------------
IN: 
0x000fbc49:  mov    %eax,%ebx
0x000fbc4c:  addr32 mov %cs:-0xf0000(%esi),%al
0x000fbc54:  cmp    $0x61,%al
0x000fbc56:  je     0xfbf1c

----------------
IN: 
0x000fbc5a:  ja     0xfbc93

----------------
IN: 
0x000fbc5c:  cmp    $0x30,%al
0x000fbc5e:  je     0xfbfe5

----------------
IN: 
0x000fbc62:  ja     0xfbc78

----------------
IN: 
0x000fbc64:  cmp    $0x20,%al
0x000fbc66:  je     0xfbd7b

----------------
IN: 
0x000fbd7b:  addr32 mov 0x12(%ebx),%al
0x000fbd7f:  cmp    $0x5,%al
0x000fbd81:  ja     0xfbd96

----------------
IN: 
0x000fbd83:  cmp    $0x4,%al
0x000fbd85:  jae    0xfbfe5

----------------
IN: 
0x000fbd89:  cmp    $0x2,%al
0x000fbd8b:  je     0xfbda5

----------------
IN: 
0x000fbda5:  xor    %edx,%edx
0x000fbda8:  jmp    0xfbdb0

----------------
IN: 
0x000fbdb0:  mov    %ebx,%eax
0x000fbdb3:  calll  0xfb383

----------------
IN: 
0x000fb383:  push   %ebp
0x000fb385:  push   %edi
0x000fb387:  push   %esi
0x000fb389:  push   %ebx
0x000fb38b:  sub    $0xc,%esp
0x000fb38f:  mov    %eax,%edi
0x000fb392:  mov    %edx,%ebp
0x000fb395:  addr32 mov (%eax),%ebx
0x000fb399:  addr32 mov 0x4(%eax),%esi
0x000fb39e:  mov    $0xc,%ecx
0x000fb3a4:  xor    %edx,%edx
0x000fb3a7:  mov    %esp,%eax
0x000fb3aa:  calll  0xf76e5

----------------
IN: 
0x000fb3b0:  addr32 mov 0x10(%edi),%ecx
0x000fb3b5:  cmp    $0xff,%cx
0x000fb3b9:  ja     0xfb3d6

----------------
IN: 
0x000fb3bb:  movzwl %cx,%eax
0x000fb3bf:  xor    %edx,%edx
0x000fb3c2:  add    %ebx,%eax
0x000fb3c5:  adc    %esi,%edx
0x000fb3c8:  cmp    $0x0,%edx
0x000fb3cc:  ja     0xfb3d6

----------------
IN: 
0x000fb3ce:  cmp    $0xfffffff,%eax
0x000fb3d4:  jbe    0xfb426

----------------
IN: 
0x000fb426:  cmp    $0x1,%ebp
0x000fb42a:  sbb    %eax,%eax
0x000fb42d:  and    $0xfffffff0,%eax
0x000fb431:  add    $0x30,%eax
0x000fb435:  addr32 mov %al,0x6(%esp)
0x000fb43a:  addr32 mov %cl,0x1(%esp)
0x000fb43f:  addr32 mov %bl,0x2(%esp)
0x000fb444:  mov    %ebx,%eax
0x000fb447:  mov    %esi,%edx
0x000fb44a:  shrd   $0x8,%edx,%eax
0x000fb44f:  shr    $0x8,%edx
0x000fb453:  addr32 mov %al,0x3(%esp)
0x000fb458:  mov    %ebx,%eax
0x000fb45b:  mov    %esi,%edx
0x000fb45e:  shrd   $0x10,%edx,%eax
0x000fb463:  shr    $0x10,%edx
0x000fb467:  addr32 mov %al,0x4(%esp)
0x000fb46c:  mov    %ebx,%eax
0x000fb46f:  mov    %esi,%edx
0x000fb472:  shrd   $0x18,%edx,%eax
0x000fb477:  shr    $0x18,%edx
0x000fb47b:  mov    %al,%bl
0x000fb47d:  and    $0xf,%ebx
0x000fb481:  or     $0x40,%ebx
0x000fb485:  addr32 mov %bl,0x5(%esp)
0x000fb48a:  addr32 mov 0xc(%edi),%ecx
0x000fb48f:  addr32 mov %cs:-0xeffdc(%ecx),%eax
0x000fb498:  addr32 mov %cs:-0xf0000(%eax),%si
0x000fb4a0:  addr32 mov %cs:-0xefffe(%eax),%bx
0x000fb4a8:  add    $0x2,%ebx
0x000fb4ac:  mov    $0xa,%al
0x000fb4ae:  mov    %ebx,%edx
0x000fb4b1:  out    %al,(%dx)
0x000fb4b2:  mov    %esp,%edx
0x000fb4b5:  mov    %ecx,%eax
0x000fb4b8:  calll  0xfb0fc

----------------
IN: 
0x000fb0fc:  push   %ebp
0x000fb0fe:  push   %edi
0x000fb100:  push   %esi
0x000fb102:  push   %ebx
0x000fb104:  mov    %edx,%edi
0x000fb107:  addr32 mov %cs:-0xeffdc(%eax),%edx
0x000fb110:  addr32 mov %cs:-0xeffd8(%eax),%bl
0x000fb118:  addr32 mov %cs:-0xf0000(%edx),%si
0x000fb120:  movzwl %si,%ebp
0x000fb124:  mov    %ebp,%eax
0x000fb127:  calll  0xfb0ec

----------------
IN: 
0x000fb0ec:  movzwl %ax,%ecx
0x000fb0f0:  xor    %edx,%edx
0x000fb0f3:  mov    $0x80,%eax
0x000fb0f9:  jmp    0xfb079

----------------
IN: 
0x000fb079:  push   %ebp
0x000fb07b:  push   %edi
0x000fb07d:  push   %esi
0x000fb07f:  push   %ebx
0x000fb081:  mov    %eax,%esi
0x000fb084:  mov    %edx,%edi
0x000fb087:  mov    %ecx,%ebx
0x000fb08a:  mov    $0x7d00,%eax
0x000fb090:  calll  0xff823

----------------
IN: 
0x000ff823:  push   %ebx
0x000ff825:  mov    %eax,%ebx
0x000ff828:  calll  0xf8036

----------------
IN: 
0x000f8036:  mov    %cs:0x6ac0,%dx
0x000f803b:  test   %dx,%dx
0x000f803d:  jne    0xf805a

----------------
IN: 
0x000f805a:  push   %esi
0x000f805c:  push   %ebx
0x000f805e:  cmp    $0x40,%dx
0x000f8061:  je     0xf809a

----------------
IN: 
0x000f8063:  in     (%dx),%eax
0x000f8065:  mov    %eax,%edx
0x000f8068:  mov    $0xe000,%eax
0x000f806e:  mov    %ax,%es
0x000f8070:  mov    %es:-0x968,%ebx
0x000f8076:  and    $0xffffff,%edx
0x000f807d:  mov    %ebx,%ecx
0x000f8080:  and    $0xff000000,%ecx
0x000f8087:  or     %ecx,%edx
0x000f808a:  cmp    %ebx,%edx
0x000f808d:  jae    0xf8096

----------------
IN: 
0x000f8096:  mov    %ax,%es
0x000f8098:  jmp    0xf80d8

----------------
IN: 
0x000f80d8:  mov    %edx,%es:-0x968
0x000f80de:  mov    %edx,%eax
0x000f80e1:  pop    %ebx
0x000f80e3:  pop    %esi
0x000f80e5:  retl   

----------------
IN: 
0x000ff82e:  mov    %eax,%edx
0x000ff831:  mov    %cs:0x6ac4,%eax
0x000ff836:  imul   %ebx,%eax
0x000ff83a:  add    %edx,%eax
0x000ff83d:  pop    %ebx
0x000ff83f:  retl   

----------------
IN: 
0x000fb096:  mov    %eax,%ebp
0x000fb099:  add    $0x7,%ebx
0x000fb09d:  mov    %ebx,%edx
0x000fb0a0:  in     (%dx),%al
0x000fb0a1:  mov    %esi,%edx
0x000fb0a4:  and    %eax,%edx
0x000fb0a7:  mov    %edi,%ecx
0x000fb0aa:  cmp    %cl,%dl
0x000fb0ac:  jne    0xfb0b4

----------------
IN: 
0x000fb0ae:  movzbl %al,%eax
0x000fb0b2:  jmp    0xfb0e2

----------------
IN: 
0x000fb0e2:  pop    %ebx
0x000fb0e4:  pop    %esi
0x000fb0e6:  pop    %edi
0x000fb0e8:  pop    %ebp
0x000fb0ea:  retl   

----------------
IN: 
0x000fb12d:  test   %eax,%eax
0x000fb130:  js     0xfb1f9

----------------
IN: 
0x000fb134:  addr32 mov 0x5(%edi),%cl
0x000fb138:  and    $0x4f,%ecx
0x000fb13c:  cmp    $0x1,%bl
0x000fb13f:  sbb    %eax,%eax
0x000fb142:  and    $0xfffffff0,%eax
0x000fb146:  sub    $0x50,%eax
0x000fb14a:  or     %eax,%ecx
0x000fb14d:  addr32 lea 0x6(%esi),%edx
0x000fb152:  in     (%dx),%al
0x000fb153:  mov    %al,%bl
0x000fb155:  mov    %cl,%al
0x000fb157:  out    %al,(%dx)
0x000fb158:  xor    %ebx,%ecx
0x000fb15b:  and    $0x10,%cl
0x000fb15e:  jne    0xfb1a7

----------------
IN: 
0x000fb1a7:  calll  0xf812a

----------------
IN: 
0x000f812a:  mov    %cs:0x6ac4,%eax
0x000f812f:  imul   $0x190,%eax,%eax
0x000f8136:  add    $0xf423f,%eax
0x000f813c:  mov    $0xf4240,%ecx
0x000f8142:  xor    %edx,%edx
0x000f8145:  div    %ecx
0x000f8148:  jmp    0xf80e7

----------------
IN: 
0x000f80e7:  push   %ebx
0x000f80e9:  mov    %eax,%ebx
0x000f80ec:  calll  0xf8036

----------------
IN: 
0x000f80f2:  add    %eax,%ebx
0x000f80f5:  mov    %ebx,%eax
0x000f80f8:  calll  0xfe2a7

----------------
IN: 
0x000fe2a7:  push   %ebx
0x000fe2a9:  mov    %eax,%ebx
0x000fe2ac:  calll  0xf8036

----------------
IN: 
0x000fe2b2:  sub    %ebx,%eax
0x000fe2b5:  test   %eax,%eax
0x000fe2b8:  setg   %al
0x000fe2bb:  movzbl %al,%eax
0x000fe2bf:  pop    %ebx
0x000fe2c1:  retl   

----------------
IN: 
0x000f80fe:  test   %eax,%eax
0x000f8101:  jne    0xf8107

----------------
IN: 
0x000f8107:  pop    %ebx
0x000f8109:  retl   

----------------
IN: 
0x000fb1ad:  mov    %ebp,%eax
0x000fb1b0:  calll  0xfb0ec

----------------
IN: 
0x000fb1b6:  test   %eax,%eax
0x000fb1b9:  jns    0xfb160

----------------
IN: 
0x000fb160:  addr32 mov 0x6(%edi),%cl
0x000fb164:  mov    %ecx,%eax
0x000fb167:  and    $0xee,%eax
0x000fb16d:  cmp    $0x24,%eax
0x000fb171:  jne    0xfb1bd

----------------
IN: 
0x000fb1bd:  addr32 mov (%edi),%al
0x000fb1c0:  addr32 lea 0x1(%esi),%edx
0x000fb1c5:  out    %al,(%dx)
0x000fb1c6:  addr32 mov 0x1(%edi),%al
0x000fb1ca:  addr32 lea 0x2(%esi),%edx
0x000fb1cf:  out    %al,(%dx)
0x000fb1d0:  addr32 mov 0x2(%edi),%al
0x000fb1d4:  addr32 lea 0x3(%esi),%edx
0x000fb1d9:  out    %al,(%dx)
0x000fb1da:  addr32 mov 0x3(%edi),%al
0x000fb1de:  addr32 lea 0x4(%esi),%edx
0x000fb1e3:  out    %al,(%dx)
0x000fb1e4:  addr32 mov 0x4(%edi),%al
0x000fb1e8:  addr32 lea 0x5(%esi),%edx
0x000fb1ed:  out    %al,(%dx)
0x000fb1ee:  addr32 lea 0x7(%esi),%edx
0x000fb1f3:  mov    %cl,%al
0x000fb1f5:  out    %al,(%dx)
0x000fb1f6:  xor    %eax,%eax
0x000fb1f9:  pop    %ebx
0x000fb1fb:  pop    %esi
0x000fb1fd:  pop    %edi
0x000fb1ff:  pop    %ebp
0x000fb201:  retl   

----------------
IN: 
0x000fb4be:  mov    %eax,%ecx
0x000fb4c1:  test   %eax,%eax
0x000fb4c4:  jne    0xfb4ea

----------------
IN: 
0x000fb4c6:  movzwl %si,%eax
0x000fb4ca:  calll  0xfb34a

----------------
IN: 
0x000fb34a:  push   %ebx
0x000fb34c:  mov    %eax,%ebx
0x000fb34f:  calll  0xf812a

----------------
IN: 
0x000fb355:  movzwl %bx,%eax
0x000fb359:  calll  0xfb0ec

----------------
IN: 
0x000fb0b4:  mov    %ebp,%eax
0x000fb0b7:  calll  0xfe2a7

----------------
IN: 
0x000fb0bd:  test   %eax,%eax
0x000fb0c0:  je     0xfb0da

----------------
IN: 
0x000fb0da:  calll  0xf9a29

Servicing hardware INT=0x08
----------------
IN: 
0x000fb0e0:  jmp    0xfb09d

----------------
IN: 
0x000fb09d:  mov    %ebx,%edx
0x000fb0a0:  in     (%dx),%al
0x000fb0a1:  mov    %esi,%edx
0x000fb0a4:  and    %eax,%edx
0x000fb0a7:  mov    %edi,%ecx
0x000fb0aa:  cmp    %cl,%dl
0x000fb0ac:  jne    0xfb0b4

----------------
IN: 
0x000fb35f:  test   %eax,%eax
0x000fb362:  js     0xfb37f

----------------
IN: 
0x000fb364:  test   $0x1,%al
0x000fb366:  jne    0xfb379

----------------
IN: 
0x000fb368:  and    $0x8,%eax
0x000fb36c:  cmp    $0x1,%eax
0x000fb370:  sbb    %eax,%eax
0x000fb373:  and    $0xfffffffb,%eax
0x000fb377:  jmp    0xfb37f

----------------
IN: 
0x000fb37f:  pop    %ebx
0x000fb381:  retl   

----------------
IN: 
0x000fb4d0:  mov    %eax,%ecx
0x000fb4d3:  test   %eax,%eax
0x000fb4d6:  jne    0xfb4ea

----------------
IN: 
0x000fb4d8:  mov    $0x200,%cx
0x000fb4db:  mov    %ebp,%edx
0x000fb4de:  mov    %edi,%eax
0x000fb4e1:  calll  0xfb203

----------------
IN: 
0x000fb203:  push   %ebp
0x000fb205:  push   %edi
0x000fb207:  push   %esi
0x000fb209:  push   %ebx
0x000fb20b:  sub    $0x18,%esp
0x000fb20f:  mov    %eax,%ebx
0x000fb212:  addr32 mov %edx,0x8(%esp)
0x000fb218:  addr32 mov %ecx,0xc(%esp)
0x000fb21e:  addr32 mov 0xc(%eax),%eax
0x000fb223:  addr32 mov %cs:-0xeffdc(%eax),%eax
0x000fb22c:  addr32 mov %cs:-0xf0000(%eax),%cx
0x000fb234:  addr32 mov %cx,0x10(%esp)
0x000fb239:  addr32 mov %cs:-0xefffe(%eax),%si
0x000fb241:  addr32 movzwl 0x10(%ebx),%ebp
0x000fb247:  addr32 mov 0x8(%ebx),%eax
0x000fb24c:  addr32 mov %eax,(%esp)
0x000fb251:  mov    $0x2,%ecx
0x000fb257:  addr32 mov 0xc(%esp),%eax
0x000fb25d:  cltd   
0x000fb25f:  idiv   %ecx
0x000fb262:  movzwl %ax,%eax
0x000fb266:  addr32 mov %eax,0x4(%esp)
0x000fb26c:  addr32 lea 0x2(%esi),%eax
0x000fb271:  addr32 mov %ax,0x12(%esp)
0x000fb276:  addr32 movzwl 0x10(%esp),%eax
0x000fb27d:  addr32 mov %eax,0x14(%esp)
0x000fb283:  addr32 mov (%esp),%eax
0x000fb288:  shr    $0x4,%eax
0x000fb28c:  addr32 cmpl $0x0,0x8(%esp)
0x000fb293:  je     0xfb2b2

----------------
IN: 
0x000fb2b2:  mov    %ax,%es
0x000fb2b4:  addr32 mov (%esp),%edi
0x000fb2b9:  and    $0xf,%edi
0x000fb2bd:  addr32 mov 0x4(%esp),%ecx
0x000fb2c3:  addr32 mov 0x10(%esp),%edx
0x000fb2c9:  rep addr32 insw (%dx),%es:(%edi)

----------------
IN: 
0x000fb2c9:  rep addr32 insw (%dx),%es:(%edi)

----------------
IN: 
0x000fb2cc:  addr32 mov 0xc(%esp),%edi
0x000fb2d2:  addr32 add %edi,(%esp)
0x000fb2d7:  addr32 mov 0x12(%esp),%dx
0x000fb2dc:  in     (%dx),%al
0x000fb2dd:  addr32 mov 0x14(%esp),%eax
0x000fb2e3:  calll  0xfb0ec

----------------
IN: 
0x000fb2e9:  test   %eax,%eax
0x000fb2ec:  jns    0xfb2f4

----------------
IN: 
0x000fb2f4:  dec    %ebp
0x000fb2f6:  je     0xfb312

----------------
IN: 
0x000fb312:  mov    %eax,%edx
0x000fb315:  and    $0x89,%edx
0x000fb31c:  addr32 cmpl $0x0,0x8(%esp)
0x000fb323:  je     0xfb32e

----------------
IN: 
0x000fb32e:  cmp    $0x1,%edx
0x000fb332:  sbb    %eax,%eax
0x000fb335:  not    %eax
0x000fb338:  and    $0xfffffff9,%eax
0x000fb33c:  add    $0x18,%esp
0x000fb340:  pop    %ebx
0x000fb342:  pop    %esi
0x000fb344:  pop    %edi
0x000fb346:  pop    %ebp
0x000fb348:  retl   

----------------
IN: 
0x000fb4e7:  mov    %eax,%ecx
0x000fb4ea:  mov    $0x8,%al
0x000fb4ec:  mov    %ebx,%edx
0x000fb4ef:  out    %al,(%dx)
0x000fb4f0:  cmp    $0x1,%ecx
0x000fb4f4:  sbb    %eax,%eax
0x000fb4f7:  not    %eax
0x000fb4fa:  and    $0xc,%eax
0x000fb4fe:  add    $0xc,%esp
0x000fb502:  pop    %ebx
0x000fb504:  pop    %esi
0x000fb506:  pop    %edi
0x000fb508:  pop    %ebp
0x000fb50a:  retl   

----------------
IN: 
0x000fbdb9:  jmp    0xfbfc7

----------------
IN: 
0x000fbfc7:  xor    %edx,%edx
0x000fbfca:  test   %eax,%eax
0x000fbfcd:  je     0xfbffa

----------------
IN: 
0x000fbffa:  mov    %edx,%eax
0x000fbffd:  pop    %edx
0x000fbfff:  pop    %ebx
0x000fc001:  pop    %esi
0x000fc003:  pop    %edi
0x000fc005:  pop    %ebp
0x000fc007:  retl   

----------------
IN: 
0x000fc03c:  mov    %bx,%es
0x000fc03e:  addr32 mov 0x10(%esp),%edx
0x000fc044:  addr32 mov %dx,%es:0x10(%ebp)
0x000fc049:  add    $0x14,%esp
0x000fc04d:  pop    %ebx
0x000fc04f:  pop    %esi
0x000fc051:  pop    %edi
0x000fc053:  pop    %ebp
0x000fc055:  retl   

----------------
IN: 
0x000f7d02:  addr32 mov 0x14(%esp),%edx
0x000f7d08:  addr32 mov %dl,0x1c(%ebx)
0x000f7d0c:  or     $0x82,%ah
0x000f7d0f:  mov    %eax,%edx
0x000f7d12:  mov    %ebx,%eax
0x000f7d15:  calll  0xf7bbf

----------------
IN: 
0x000f7bbf:  mov    $0x40,%ecx
0x000f7bc5:  addr32 cmpb $0x0,0x14(%eax)
0x000f7bca:  js     0xf7bd5

----------------
IN: 
0x000f7bd5:  mov    %cx,%es
0x000f7bd7:  mov    %dl,%es:0x74
0x000f7bdc:  test   %dl,%dl
0x000f7bde:  je     0xf7beb

----------------
IN: 
0x000f7beb:  jmp    0xf7b26

----------------
IN: 
0x000f7d1b:  add    $0x18,%esp
0x000f7d1f:  pop    %ebx
0x000f7d21:  pop    %esi
0x000f7d23:  pop    %edi
0x000f7d25:  pop    %ebp
0x000f7d27:  retl   

----------------
IN: 
0x000fd295:  lret   

----------------
IN: 
0x000f2e0c:  testb  $0x1,0x26(%esp)
0x000f2e11:  je     0xf2e1a

----------------
IN: 
0x000f2e1a:  test   %esi,%esi
0x000f2e1c:  je     0xf2e36

----------------
IN: 
0x000f2e1e:  cmpw   $0xaa55,0x7dfe
0x000f2e27:  je     0xf2e36

----------------
IN: 
0x000f2e36:  movzbl %bl,%edx
0x000f2e39:  mov    $0x7c00,%eax
0x000f2e3e:  call   0xf1e89

----------------
IN: 
0x000f1e89:  push   %esi
0x000f1e8a:  push   %ebx
0x000f1e8b:  sub    $0x28,%esp
0x000f1e8e:  mov    %eax,%ebx
0x000f1e90:  mov    %edx,%esi
0x000f1e92:  movzwl %ax,%eax
0x000f1e95:  push   %eax
0x000f1e96:  mov    %ebx,%eax
0x000f1e98:  shr    $0x10,%eax
0x000f1e9b:  push   %eax
0x000f1e9c:  push   $0xf3e37
0x000f1ea1:  call   0xf0cc9

----------------
IN: 
0x000f1ea6:  mov    $0x26,%ecx
0x000f1eab:  xor    %edx,%edx
0x000f1ead:  lea    0xe(%esp),%eax
0x000f1eb1:  call   0xf0090

----------------
IN: 
0x000f1eb6:  movw   $0x200,0x32(%esp)
0x000f1ebd:  mov    %ebx,0x2e(%esp)
0x000f1ec1:  mov    %esi,%eax
0x000f1ec3:  mov    %al,0x22(%esp)
0x000f1ec7:  movw   $0xaa55,0x2a(%esp)
0x000f1ece:  mov    $0xf9135,%ecx
0x000f1ed3:  xor    %edx,%edx
0x000f1ed5:  lea    0xe(%esp),%eax
0x000f1ed9:  call   0xf0abb

----------------
IN: 
# ********************************************************************************** 
#                                    开始进入booltloader
# **********************************************************************************
0x00007c00:  cli    
0x00007c01:  cld    
# #################################### 将几个数据段寄存器置零
0x00007c02:  xor    %ax,%ax
0x00007c04:  mov    %ax,%ds
0x00007c06:  mov    %ax,%es
0x00007c08:  mov    %ax,%ss

----------------
# #################################### 开启地址线A20
IN: 
0x00007c0a:  in     $0x64,%al

----------------
IN: 
0x00007c0c:  test   $0x2,%al
0x00007c0e:  jne    0x7c0a

----------------
IN: 
0x00007c10:  mov    $0xd1,%al
0x00007c12:  out    %al,$0x64
0x00007c14:  in     $0x64,%al
0x00007c16:  test   $0x2,%al
0x00007c18:  jne    0x7c14

----------------
IN: 
0x00007c1a:  mov    $0xdf,%al
0x00007c1c:  out    %al,$0x60

# ##################################### 开启保护模式
0x00007c1e:  lgdtw  0x7c6c
0x00007c23:  mov    %cr0,%eax
0x00007c26:  or     $0x1,%eax
0x00007c2a:  mov    %eax,%cr0

----------------
IN: 
# ##################################### 跳转到32位模式的代码
0x00007c2d:  ljmp   $0x8,$0x7c32

----------------
IN: 
# ##################################### 设置其他数据段的选择子为0x10
0x00007c32:  mov    $0x10,%ax
0x00007c36:  mov    %eax,%ds

----------------
IN: 
0x00007c38:  mov    %eax,%es

----------------
IN: 
0x00007c3a:  mov    %eax,%fs
0x00007c3c:  mov    %eax,%gs
0x00007c3e:  mov    %eax,%ss

----------------
IN: 
# ##################################### 设置堆栈指针寄存器
0x00007c40:  mov    $0x0,%ebp

----------------
IN: 
0x00007c45:  mov    $0x7c00,%esp

# ##################################### 调用C函数bootmain(见bootasm.S)
0x00007c4a:  call   0x7d0f

----------------
IN: 
0x00007d0f:  mov    0x7df0,%eax
0x00007d14:  push   %ebp
0x00007d15:  xor    %ecx,%ecx
0x00007d17:  mov    %esp,%ebp
0x00007d19:  push   %esi
0x00007d1a:  push   %ebx
0x00007d1b:  lea    0x0(,%eax,8),%edx
0x00007d22:  mov    0x7dec,%eax
0x00007d27:  call   0x7c72

----------------
IN: 
0x00007c72:  push   %ebp
0x00007c73:  mov    %esp,%ebp
0x00007c75:  push   %edi
0x00007c76:  push   %esi
0x00007c77:  mov    %eax,%esi
0x00007c79:  push   %ebx
0x00007c7a:  add    %edx,%eax
0x00007c7c:  push   %ebx
0x00007c7d:  xor    %edx,%edx
0x00007c7f:  mov    %eax,-0x10(%ebp)
0x00007c82:  mov    %ecx,%eax
0x00007c84:  divl   0x7df0
0x00007c8a:  lea    0x1(%eax),%ebx
0x00007c8d:  sub    %edx,%esi
0x00007c8f:  cmp    -0x10(%ebp),%esi
0x00007c92:  jae    0x7d09

----------------
IN: 
0x00007c94:  mov    $0x1f7,%edx
0x00007c99:  in     (%dx),%al
0x00007c9a:  and    $0xffffffc0,%eax
0x00007c9d:  cmp    $0x40,%al
0x00007c9f:  jne    0x7c94

----------------
IN: 
0x00007ca1:  mov    $0x1f2,%edx
0x00007ca6:  mov    $0x1,%al
0x00007ca8:  out    %al,(%dx)
0x00007ca9:  mov    $0x1f3,%edx
0x00007cae:  mov    %bl,%al
0x00007cb0:  out    %al,(%dx)
0x00007cb1:  mov    %ebx,%eax
0x00007cb3:  mov    $0x1f4,%edx
0x00007cb8:  shr    $0x8,%eax
0x00007cbb:  out    %al,(%dx)
0x00007cbc:  mov    %ebx,%eax
0x00007cbe:  mov    $0x1f5,%edx
0x00007cc3:  shr    $0x10,%eax
0x00007cc6:  out    %al,(%dx)
0x00007cc7:  mov    %ebx,%eax
0x00007cc9:  mov    $0x1f6,%edx
0x00007cce:  shr    $0x18,%eax
0x00007cd1:  and    $0xf,%eax
0x00007cd4:  or     $0xffffffe0,%eax
0x00007cd7:  out    %al,(%dx)
0x00007cd8:  mov    $0x20,%al
0x00007cda:  mov    $0x1f7,%edx
0x00007cdf:  out    %al,(%dx)
0x00007ce0:  mov    $0x1f7,%edx
0x00007ce5:  in     (%dx),%al
0x00007ce6:  and    $0xffffffc0,%eax
0x00007ce9:  cmp    $0x40,%al
0x00007ceb:  jne    0x7ce0

----------------
IN: 
0x00007ce0:  mov    $0x1f7,%edx
0x00007ce5:  in     (%dx),%al
0x00007ce6:  and    $0xffffffc0,%eax
0x00007ce9:  cmp    $0x40,%al
0x00007ceb:  jne    0x7ce0

----------------
IN: 
0x00007ced:  mov    0x7df0,%ecx
0x00007cf3:  mov    %esi,%edi
0x00007cf5:  mov    $0x1f0,%edx
0x00007cfa:  shr    $0x2,%ecx
0x00007cfd:  cld    
0x00007cfe:  repnz insl (%dx),%es:(%edi)

----------------
IN: 
0x00007cfe:  repnz insl (%dx),%es:(%edi)

----------------
IN: 
0x00007d00:  add    0x7df0,%esi
0x00007d06:  inc    %ebx
0x00007d07:  jmp    0x7c8f

----------------
IN: 
0x00007c8f:  cmp    -0x10(%ebp),%esi
0x00007c92:  jae    0x7d09

----------------
IN: 
0x00007d09:  pop    %eax
0x00007d0a:  pop    %ebx
0x00007d0b:  pop    %esi
0x00007d0c:  pop    %edi
0x00007d0d:  pop    %ebp
0x00007d0e:  ret    

----------------
IN: 
0x00007d2c:  mov    0x7dec,%eax
0x00007d31:  cmpl   $0x464c457f,(%eax)
0x00007d37:  jne    0x7d72

----------------
IN: 
0x00007d39:  movzwl 0x2c(%eax),%esi
0x00007d3d:  mov    0x1c(%eax),%ebx
0x00007d40:  add    %eax,%ebx
0x00007d42:  shl    $0x5,%esi
0x00007d45:  add    %ebx,%esi
0x00007d47:  cmp    %esi,%ebx
0x00007d49:  jae    0x7d63

----------------
IN: 
0x00007d4b:  mov    0x8(%ebx),%eax
0x00007d4e:  mov    0x4(%ebx),%ecx
0x00007d51:  add    $0x20,%ebx
0x00007d54:  mov    -0xc(%ebx),%edx
0x00007d57:  and    $0xffffff,%eax
0x00007d5c:  call   0x7c72

----------------
IN: 
0x00007d61:  jmp    0x7d47

----------------
IN: 
0x00007d47:  cmp    %esi,%ebx
0x00007d49:  jae    0x7d63

----------------
IN: 
0x00007d63:  mov    0x7dec,%eax
0x00007d68:  mov    0x18(%eax),%eax
0x00007d6b:  and    $0xffffff,%eax
0x00007d70:  call   *%eax

----------------
IN: 
0x00100000:  push   %ebp
0x00100001:  mov    %esp,%ebp
0x00100003:  sub    $0x18,%esp
0x00100006:  mov    $0x10fd80,%edx
0x0010000b:  mov    $0x10ea16,%eax
0x00100010:  sub    %eax,%edx
0x00100012:  mov    %edx,%eax
0x00100014:  sub    $0x4,%esp
0x00100017:  push   %eax
0x00100018:  push   $0x0
0x0010001a:  push   $0x10ea16
0x0010001f:  call   0x102db9

----------------
IN: 
0x00102db9:  push   %ebp
0x00102dba:  mov    %esp,%ebp
0x00102dbc:  push   %edi
0x00102dbd:  sub    $0x24,%esp
0x00102dc0:  mov    0xc(%ebp),%eax
0x00102dc3:  mov    %al,-0x28(%ebp)
0x00102dc6:  movsbl -0x28(%ebp),%eax
0x00102dca:  mov    0x8(%ebp),%edx
0x00102dcd:  mov    %edx,-0x8(%ebp)
0x00102dd0:  mov    %al,-0x9(%ebp)
0x00102dd3:  mov    0x10(%ebp),%eax
0x00102dd6:  mov    %eax,-0x10(%ebp)
0x00102dd9:  mov    -0x10(%ebp),%ecx
0x00102ddc:  movzbl -0x9(%ebp),%eax
0x00102de0:  mov    -0x8(%ebp),%edx
0x00102de3:  mov    %edx,%edi
0x00102de5:  rep stos %al,%es:(%edi)

----------------
IN: 
0x00102de5:  rep stos %al,%es:(%edi)

----------------
IN: 
0x00102de7:  mov    %edi,%edx
0x00102de9:  mov    %ecx,-0x14(%ebp)
0x00102dec:  mov    %edx,-0x18(%ebp)
0x00102def:  mov    -0x8(%ebp),%eax
0x00102df2:  nop    
0x00102df3:  add    $0x24,%esp
0x00102df6:  pop    %edi
0x00102df7:  pop    %ebp
0x00102df8:  ret    

----------------
IN: 
0x00100024:  add    $0x10,%esp
0x00100027:  call   0x10156e

----------------
IN: 
0x0010156e:  push   %ebp
0x0010156f:  mov    %esp,%ebp
0x00101571:  sub    $0x8,%esp
0x00101574:  call   0x100e05

----------------
IN: 
0x00100e05:  push   %ebp
0x00100e06:  mov    %esp,%ebp
0x00100e08:  sub    $0x20,%esp
0x00100e0b:  movl   $0xb8000,-0x4(%ebp)
0x00100e12:  mov    -0x4(%ebp),%eax
0x00100e15:  movzwl (%eax),%eax
0x00100e18:  mov    %ax,-0x6(%ebp)
0x00100e1c:  mov    -0x4(%ebp),%eax
0x00100e1f:  movw   $0xa55a,(%eax)
0x00100e24:  mov    -0x4(%ebp),%eax
0x00100e27:  movzwl (%eax),%eax
0x00100e2a:  cmp    $0xa55a,%ax
0x00100e2e:  je     0x100e42

----------------
IN: 
0x00100e42:  mov    -0x4(%ebp),%eax
0x00100e45:  movzwl -0x6(%ebp),%edx
0x00100e49:  mov    %dx,(%eax)
0x00100e4c:  movw   $0x3d4,0x10ee66
0x00100e55:  movzwl 0x10ee66,%eax
0x00100e5c:  movzwl %ax,%eax
0x00100e5f:  mov    %ax,-0x8(%ebp)
0x00100e63:  movb   $0xe,-0x16(%ebp)
0x00100e67:  movzbl -0x16(%ebp),%eax
0x00100e6b:  movzwl -0x8(%ebp),%edx
0x00100e6f:  out    %al,(%dx)
0x00100e70:  movzwl 0x10ee66,%eax
0x00100e77:  add    $0x1,%eax
0x00100e7a:  movzwl %ax,%eax
0x00100e7d:  mov    %ax,-0xe(%ebp)
0x00100e81:  movzwl -0xe(%ebp),%eax
0x00100e85:  mov    %eax,%edx
0x00100e87:  in     (%dx),%al
0x00100e88:  mov    %al,-0x15(%ebp)
0x00100e8b:  movzbl -0x15(%ebp),%eax
0x00100e8f:  movzbl %al,%eax
0x00100e92:  shl    $0x8,%eax
0x00100e95:  mov    %eax,-0xc(%ebp)
0x00100e98:  movzwl 0x10ee66,%eax
0x00100e9f:  movzwl %ax,%eax
0x00100ea2:  mov    %ax,-0x10(%ebp)
0x00100ea6:  movb   $0xf,-0x14(%ebp)
0x00100eaa:  movzbl -0x14(%ebp),%eax
0x00100eae:  movzwl -0x10(%ebp),%edx
0x00100eb2:  out    %al,(%dx)
0x00100eb3:  movzwl 0x10ee66,%eax
0x00100eba:  add    $0x1,%eax
0x00100ebd:  movzwl %ax,%eax
0x00100ec0:  mov    %ax,-0x12(%ebp)
0x00100ec4:  movzwl -0x12(%ebp),%eax
0x00100ec8:  mov    %eax,%edx
0x00100eca:  in     (%dx),%al
0x00100ecb:  mov    %al,-0x13(%ebp)
0x00100ece:  movzbl -0x13(%ebp),%eax
0x00100ed2:  movzbl %al,%eax
0x00100ed5:  or     %eax,-0xc(%ebp)
0x00100ed8:  mov    -0x4(%ebp),%eax
0x00100edb:  mov    %eax,0x10ee60
0x00100ee0:  mov    -0xc(%ebp),%eax
0x00100ee3:  mov    %ax,0x10ee64
0x00100ee9:  nop    
0x00100eea:  leave  
0x00100eeb:  ret    

----------------
IN: 
0x00101579:  call   0x100eec

----------------
IN: 
0x00100eec:  push   %ebp
0x00100eed:  mov    %esp,%ebp
0x00100eef:  sub    $0x28,%esp
0x00100ef2:  movw   $0x3fa,-0xa(%ebp)
0x00100ef8:  movb   $0x0,-0x26(%ebp)
0x00100efc:  movzbl -0x26(%ebp),%eax
0x00100f00:  movzwl -0xa(%ebp),%edx
0x00100f04:  out    %al,(%dx)
0x00100f05:  movw   $0x3fb,-0xc(%ebp)
0x00100f0b:  movb   $0x80,-0x25(%ebp)
0x00100f0f:  movzbl -0x25(%ebp),%eax
0x00100f13:  movzwl -0xc(%ebp),%edx
0x00100f17:  out    %al,(%dx)
0x00100f18:  movw   $0x3f8,-0xe(%ebp)
0x00100f1e:  movb   $0xc,-0x24(%ebp)
0x00100f22:  movzbl -0x24(%ebp),%eax
0x00100f26:  movzwl -0xe(%ebp),%edx
0x00100f2a:  out    %al,(%dx)
0x00100f2b:  movw   $0x3f9,-0x10(%ebp)
0x00100f31:  movb   $0x0,-0x23(%ebp)
0x00100f35:  movzbl -0x23(%ebp),%eax
0x00100f39:  movzwl -0x10(%ebp),%edx
0x00100f3d:  out    %al,(%dx)
0x00100f3e:  movw   $0x3fb,-0x12(%ebp)
0x00100f44:  movb   $0x3,-0x22(%ebp)
0x00100f48:  movzbl -0x22(%ebp),%eax
0x00100f4c:  movzwl -0x12(%ebp),%edx
0x00100f50:  out    %al,(%dx)
0x00100f51:  movw   $0x3fc,-0x14(%ebp)
0x00100f57:  movb   $0x0,-0x21(%ebp)
0x00100f5b:  movzbl -0x21(%ebp),%eax
0x00100f5f:  movzwl -0x14(%ebp),%edx
0x00100f63:  out    %al,(%dx)
0x00100f64:  movw   $0x3f9,-0x16(%ebp)
0x00100f6a:  movb   $0x1,-0x20(%ebp)
0x00100f6e:  movzbl -0x20(%ebp),%eax
0x00100f72:  movzwl -0x16(%ebp),%edx
0x00100f76:  out    %al,(%dx)
0x00100f77:  movw   $0x3fd,-0x18(%ebp)
0x00100f7d:  movzwl -0x18(%ebp),%eax
0x00100f81:  mov    %eax,%edx
0x00100f83:  in     (%dx),%al
0x00100f84:  mov    %al,-0x1f(%ebp)
0x00100f87:  movzbl -0x1f(%ebp),%eax
0x00100f8b:  cmp    $0xff,%al
0x00100f8d:  setne  %al
0x00100f90:  movzbl %al,%eax
0x00100f93:  mov    %eax,0x10ee68
0x00100f98:  movw   $0x3fa,-0x1a(%ebp)
0x00100f9e:  movzwl -0x1a(%ebp),%eax
0x00100fa2:  mov    %eax,%edx
0x00100fa4:  in     (%dx),%al
0x00100fa5:  mov    %al,-0x1e(%ebp)
0x00100fa8:  movw   $0x3f8,-0x1c(%ebp)
0x00100fae:  movzwl -0x1c(%ebp),%eax
0x00100fb2:  mov    %eax,%edx
0x00100fb4:  in     (%dx),%al
0x00100fb5:  mov    %al,-0x1d(%ebp)
0x00100fb8:  mov    0x10ee68,%eax
0x00100fbd:  test   %eax,%eax
0x00100fbf:  je     0x100fce

----------------
IN: 
0x00100fc1:  sub    $0xc,%esp
0x00100fc4:  push   $0x4
0x00100fc6:  call   0x101684

----------------
IN: 
0x00101684:  push   %ebp
0x00101685:  mov    %esp,%ebp
0x00101687:  mov    0x8(%ebp),%eax
0x0010168a:  mov    $0x1,%edx
0x0010168f:  mov    %eax,%ecx
0x00101691:  shl    %cl,%edx
0x00101693:  mov    %edx,%eax
0x00101695:  not    %eax
0x00101697:  mov    %eax,%edx
0x00101699:  movzwl 0x10e550,%eax
0x001016a0:  and    %edx,%eax
0x001016a2:  movzwl %ax,%eax
0x001016a5:  push   %eax
0x001016a6:  call   0x10162b

----------------
IN: 
0x0010162b:  push   %ebp
0x0010162c:  mov    %esp,%ebp
0x0010162e:  sub    $0x14,%esp
0x00101631:  mov    0x8(%ebp),%eax
0x00101634:  mov    %ax,-0x14(%ebp)
0x00101638:  movzwl -0x14(%ebp),%eax
0x0010163c:  mov    %ax,0x10e550
0x00101642:  mov    0x10f08c,%eax
0x00101647:  test   %eax,%eax
0x00101649:  je     0x101681

----------------
IN: 
0x00101681:  nop    
0x00101682:  leave  
0x00101683:  ret    

----------------
IN: 
0x001016ab:  add    $0x4,%esp
0x001016ae:  nop    
0x001016af:  leave  
0x001016b0:  ret    

----------------
IN: 
0x00100fcb:  add    $0x10,%esp
0x00100fce:  nop    
0x00100fcf:  leave  
0x00100fd0:  ret    

----------------
IN: 
0x0010157e:  call   0x101553

----------------
IN: 
0x00101553:  push   %ebp
0x00101554:  mov    %esp,%ebp
0x00101556:  sub    $0x8,%esp
0x00101559:  call   0x10153a

----------------
IN: 
0x0010153a:  push   %ebp
0x0010153b:  mov    %esp,%ebp
0x0010153d:  sub    $0x8,%esp
0x00101540:  sub    $0xc,%esp
0x00101543:  push   $0x1013ad
0x00101548:  call   0x1012e8

----------------
IN: 
0x001012e8:  push   %ebp
0x001012e9:  mov    %esp,%ebp
0x001012eb:  sub    $0x18,%esp
0x001012ee:  jmp    0x101323

----------------
IN: 
0x00101323:  mov    0x8(%ebp),%eax
0x00101326:  call   *%eax

----------------
IN: 
0x001013ad:  push   %ebp
0x001013ae:  mov    %esp,%ebp
0x001013b0:  sub    $0x18,%esp
0x001013b3:  movw   $0x64,-0x14(%ebp)
0x001013b9:  movzwl -0x14(%ebp),%eax
0x001013bd:  mov    %eax,%edx
0x001013bf:  in     (%dx),%al
0x001013c0:  mov    %al,-0x15(%ebp)
0x001013c3:  movzbl -0x15(%ebp),%eax
0x001013c7:  movzbl %al,%eax
0x001013ca:  and    $0x1,%eax
0x001013cd:  test   %eax,%eax
0x001013cf:  jne    0x1013db

----------------
IN: 
0x001013d1:  mov    $0xffffffff,%eax
0x001013d6:  jmp    0x101538

----------------
IN: 
0x00101538:  leave  
0x00101539:  ret    

----------------
IN: 
0x00101328:  mov    %eax,-0xc(%ebp)
0x0010132b:  cmpl   $0xffffffff,-0xc(%ebp)
0x0010132f:  jne    0x1012f0

----------------
IN: 
0x00101331:  nop    
0x00101332:  leave  
0x00101333:  ret    

----------------
IN: 
0x0010154d:  add    $0x10,%esp
0x00101550:  nop    
0x00101551:  leave  
0x00101552:  ret    

----------------
IN: 
0x0010155e:  sub    $0xc,%esp
0x00101561:  push   $0x1
0x00101563:  call   0x101684

----------------
IN: 
0x00101568:  add    $0x10,%esp
0x0010156b:  nop    
0x0010156c:  leave  
0x0010156d:  ret    

----------------
IN: 
0x00101583:  mov    0x10ee68,%eax
0x00101588:  test   %eax,%eax
0x0010158a:  jne    0x10159c

----------------
IN: 
0x0010159c:  nop    
0x0010159d:  leave  
0x0010159e:  ret    

----------------
IN: 
0x0010002c:  movl   $0x103560,-0xc(%ebp)
0x00100033:  sub    $0x8,%esp
0x00100036:  pushl  -0xc(%ebp)
0x00100039:  push   $0x10357c
0x0010003e:  call   0x10024d

----------------
IN: 
0x0010024d:  push   %ebp
0x0010024e:  mov    %esp,%ebp
0x00100250:  sub    $0x18,%esp
0x00100253:  lea    0xc(%ebp),%eax
0x00100256:  mov    %eax,-0x10(%ebp)
0x00100259:  mov    -0x10(%ebp),%eax
0x0010025c:  sub    $0x8,%esp
0x0010025f:  push   %eax
0x00100260:  pushl  0x8(%ebp)
0x00100263:  call   0x100224

----------------
IN: 
0x00100224:  push   %ebp
0x00100225:  mov    %esp,%ebp
0x00100227:  sub    $0x18,%esp
0x0010022a:  movl   $0x0,-0xc(%ebp)
0x00100231:  pushl  0xc(%ebp)
0x00100234:  pushl  0x8(%ebp)
0x00100237:  lea    -0xc(%ebp),%eax
0x0010023a:  push   %eax
0x0010023b:  push   $0x100200
0x00100240:  call   0x1030ef

----------------
IN: 
0x001030ef:  push   %ebp
0x001030f0:  mov    %esp,%ebp
0x001030f2:  push   %esi
0x001030f3:  push   %ebx
0x001030f4:  sub    $0x20,%esp
0x001030f7:  jmp    0x103110

----------------
IN: 
0x00103110:  mov    0x10(%ebp),%eax
0x00103113:  lea    0x1(%eax),%edx
0x00103116:  mov    %edx,0x10(%ebp)
0x00103119:  movzbl (%eax),%eax
0x0010311c:  movzbl %al,%ebx
0x0010311f:  cmp    $0x25,%ebx
0x00103122:  jne    0x1030f9

----------------
IN: 
0x00103124:  movb   $0x20,-0x25(%ebp)
0x00103128:  movl   $0xffffffff,-0x1c(%ebp)
0x0010312f:  mov    -0x1c(%ebp),%eax
0x00103132:  mov    %eax,-0x18(%ebp)
0x00103135:  movl   $0x0,-0x24(%ebp)
0x0010313c:  mov    -0x24(%ebp),%eax
0x0010313f:  mov    %eax,-0x20(%ebp)
0x00103142:  mov    0x10(%ebp),%eax
0x00103145:  lea    0x1(%eax),%edx
0x00103148:  mov    %edx,0x10(%ebp)
0x0010314b:  movzbl (%eax),%eax
0x0010314e:  movzbl %al,%ebx
0x00103151:  lea    -0x23(%ebx),%eax
0x00103154:  cmp    $0x55,%eax
0x00103157:  ja     0x103462

----------------
IN: 
0x0010315d:  mov    0x103d14(,%eax,4),%eax
0x00103164:  jmp    *%eax

----------------
IN: 
0x0010326c:  mov    0x14(%ebp),%eax
0x0010326f:  lea    0x4(%eax),%edx
0x00103272:  mov    %edx,0x14(%ebp)
0x00103275:  mov    (%eax),%esi
0x00103277:  test   %esi,%esi
0x00103279:  jne    0x103280

----------------
IN: 
0x00103280:  cmpl   $0x0,-0x18(%ebp)
0x00103284:  jle    0x1032fc

----------------
IN: 
0x001032fc:  mov    %esi,%eax
0x001032fe:  lea    0x1(%eax),%esi
0x00103301:  movzbl (%eax),%eax
0x00103304:  movsbl %al,%ebx
0x00103307:  test   %ebx,%ebx
0x00103309:  je     0x103331

----------------
IN: 
0x0010330b:  cmpl   $0x0,-0x1c(%ebp)
0x0010330f:  js     0x1032c7

----------------
IN: 
0x001032c7:  cmpl   $0x0,-0x24(%ebp)
0x001032cb:  je     0x1032e9

----------------
IN: 
0x001032e9:  sub    $0x8,%esp
0x001032ec:  pushl  0xc(%ebp)
0x001032ef:  push   %ebx
0x001032f0:  mov    0x8(%ebp),%eax
0x001032f3:  call   *%eax

----------------
IN: 
0x00100200:  push   %ebp
0x00100201:  mov    %esp,%ebp
0x00100203:  sub    $0x8,%esp
0x00100206:  sub    $0xc,%esp
0x00100209:  pushl  0x8(%ebp)
0x0010020c:  call   0x10159f

----------------
IN: 
0x0010159f:  push   %ebp
0x001015a0:  mov    %esp,%ebp
0x001015a2:  sub    $0x8,%esp
0x001015a5:  pushl  0x8(%ebp)
0x001015a8:  call   0x10104b

----------------
IN: 
0x0010104b:  push   %ebp
0x0010104c:  mov    %esp,%ebp
0x0010104e:  cmpl   $0x8,0x8(%ebp)
0x00101052:  je     0x101061

----------------
IN: 
0x00101054:  pushl  0x8(%ebp)
0x00101057:  call   0x100fd1

----------------
IN: 
0x00100fd1:  push   %ebp
0x00100fd2:  mov    %esp,%ebp
0x00100fd4:  sub    $0x10,%esp
0x00100fd7:  movl   $0x0,-0x4(%ebp)
0x00100fde:  jmp    0x100fe9

----------------
IN: 
0x00100fe9:  movw   $0x379,-0xc(%ebp)
0x00100fef:  movzwl -0xc(%ebp),%eax
0x00100ff3:  mov    %eax,%edx
0x00100ff5:  in     (%dx),%al
0x00100ff6:  mov    %al,-0xd(%ebp)
0x00100ff9:  movzbl -0xd(%ebp),%eax
0x00100ffd:  test   %al,%al
0x00100fff:  js     0x10100a

----------------
IN: 
0x0010100a:  mov    0x8(%ebp),%eax
0x0010100d:  movzbl %al,%eax
0x00101010:  movw   $0x378,-0x8(%ebp)
0x00101016:  mov    %al,-0x10(%ebp)
0x00101019:  movzbl -0x10(%ebp),%eax
0x0010101d:  movzwl -0x8(%ebp),%edx
0x00101021:  out    %al,(%dx)
0x00101022:  movw   $0x37a,-0xa(%ebp)
0x00101028:  movb   $0xd,-0xf(%ebp)
0x0010102c:  movzbl -0xf(%ebp),%eax
0x00101030:  movzwl -0xa(%ebp),%edx
0x00101034:  out    %al,(%dx)
0x00101035:  movw   $0x37a,-0x6(%ebp)
0x0010103b:  movb   $0x8,-0xe(%ebp)
0x0010103f:  movzbl -0xe(%ebp),%eax
0x00101043:  movzwl -0x6(%ebp),%edx
0x00101047:  out    %al,(%dx)
0x00101048:  nop    
0x00101049:  leave  
0x0010104a:  ret    

----------------
IN: 
0x0010105c:  add    $0x4,%esp
0x0010105f:  jmp    0x10107f

----------------
IN: 
0x0010107f:  nop    
0x00101080:  leave  
0x00101081:  ret    

----------------
IN: 
0x001015ad:  add    $0x4,%esp
0x001015b0:  sub    $0xc,%esp
0x001015b3:  pushl  0x8(%ebp)
0x001015b6:  call   0x101082

----------------
IN: 
0x00101082:  push   %ebp
0x00101083:  mov    %esp,%ebp
0x00101085:  push   %ebx
0x00101086:  sub    $0x14,%esp
0x00101089:  mov    0x8(%ebp),%eax
0x0010108c:  mov    $0x0,%al
0x0010108e:  test   %eax,%eax
0x00101090:  jne    0x101099

----------------
IN: 
0x00101092:  orl    $0x700,0x8(%ebp)
0x00101099:  mov    0x8(%ebp),%eax
0x0010109c:  movzbl %al,%eax
0x0010109f:  cmp    $0xa,%eax
0x001010a2:  je     0x1010f2

----------------
IN: 
0x001010a4:  cmp    $0xd,%eax
0x001010a7:  je     0x101102

----------------
IN: 
0x001010a9:  cmp    $0x8,%eax
0x001010ac:  jne    0x10113c

----------------
IN: 
0x0010113c:  mov    0x10ee60,%ecx
0x00101142:  movzwl 0x10ee64,%eax
0x00101149:  lea    0x1(%eax),%edx
0x0010114c:  mov    %dx,0x10ee64
0x00101153:  movzwl %ax,%eax
0x00101156:  add    %eax,%eax
0x00101158:  add    %ecx,%eax
0x0010115a:  mov    0x8(%ebp),%edx
0x0010115d:  mov    %dx,(%eax)
0x00101160:  jmp    0x101163

----------------
IN: 
0x00101163:  movzwl 0x10ee64,%eax
0x0010116a:  cmp    $0x7cf,%ax
0x0010116e:  jbe    0x1011c9

----------------
IN: 
0x001011c9:  movzwl 0x10ee66,%eax
0x001011d0:  movzwl %ax,%eax
0x001011d3:  mov    %ax,-0xe(%ebp)
0x001011d7:  movb   $0xe,-0x18(%ebp)
0x001011db:  movzbl -0x18(%ebp),%eax
0x001011df:  movzwl -0xe(%ebp),%edx
0x001011e3:  out    %al,(%dx)
0x001011e4:  movzwl 0x10ee64,%eax
0x001011eb:  shr    $0x8,%ax
0x001011ef:  movzbl %al,%eax
0x001011f2:  movzwl 0x10ee66,%edx
0x001011f9:  add    $0x1,%edx
0x001011fc:  movzwl %dx,%edx
0x001011ff:  mov    %dx,-0x10(%ebp)
0x00101203:  mov    %al,-0x17(%ebp)
0x00101206:  movzbl -0x17(%ebp),%eax
0x0010120a:  movzwl -0x10(%ebp),%edx
0x0010120e:  out    %al,(%dx)
0x0010120f:  movzwl 0x10ee66,%eax
0x00101216:  movzwl %ax,%eax
0x00101219:  mov    %ax,-0x12(%ebp)
0x0010121d:  movb   $0xf,-0x16(%ebp)
0x00101221:  movzbl -0x16(%ebp),%eax
0x00101225:  movzwl -0x12(%ebp),%edx
0x00101229:  out    %al,(%dx)
0x0010122a:  movzwl 0x10ee64,%eax
0x00101231:  movzbl %al,%eax
0x00101234:  movzwl 0x10ee66,%edx
0x0010123b:  add    $0x1,%edx
0x0010123e:  movzwl %dx,%edx
0x00101241:  mov    %dx,-0x14(%ebp)
0x00101245:  mov    %al,-0x15(%ebp)
0x00101248:  movzbl -0x15(%ebp),%eax
0x0010124c:  movzwl -0x14(%ebp),%edx
0x00101250:  out    %al,(%dx)
0x00101251:  nop    
0x00101252:  mov    -0x4(%ebp),%ebx
0x00101255:  leave  
0x00101256:  ret    

----------------
IN: 
0x001015bb:  add    $0x10,%esp
0x001015be:  sub    $0xc,%esp
0x001015c1:  pushl  0x8(%ebp)
0x001015c4:  call   0x1012b1

----------------
IN: 
0x001012b1:  push   %ebp
0x001012b2:  mov    %esp,%ebp
0x001012b4:  cmpl   $0x8,0x8(%ebp)
0x001012b8:  je     0x1012c7

----------------
IN: 
0x001012ba:  pushl  0x8(%ebp)
0x001012bd:  call   0x101257

----------------
IN: 
0x00101257:  push   %ebp
0x00101258:  mov    %esp,%ebp
0x0010125a:  sub    $0x10,%esp
0x0010125d:  movl   $0x0,-0x4(%ebp)
0x00101264:  jmp    0x10126f

----------------
IN: 
0x0010126f:  movw   $0x3fd,-0x8(%ebp)
0x00101275:  movzwl -0x8(%ebp),%eax
0x00101279:  mov    %eax,%edx
0x0010127b:  in     (%dx),%al
0x0010127c:  mov    %al,-0x9(%ebp)
0x0010127f:  movzbl -0x9(%ebp),%eax
0x00101283:  movzbl %al,%eax
0x00101286:  and    $0x20,%eax
0x00101289:  test   %eax,%eax
0x0010128b:  jne    0x101296

----------------
IN: 
0x00101296:  mov    0x8(%ebp),%eax
0x00101299:  movzbl %al,%eax
0x0010129c:  movw   $0x3f8,-0x6(%ebp)
0x001012a2:  mov    %al,-0xa(%ebp)
0x001012a5:  movzbl -0xa(%ebp),%eax
0x001012a9:  movzwl -0x6(%ebp),%edx
0x001012ad:  out    %al,(%dx)
0x001012ae:  nop    
0x001012af:  leave  
0x001012b0:  ret    

----------------
IN: 
0x001012c2:  add    $0x4,%esp
0x001012c5:  jmp    0x1012e5

----------------
IN: 
0x001012e5:  nop    
0x001012e6:  leave  
0x001012e7:  ret    

----------------
IN: 
0x001015c9:  add    $0x10,%esp
0x001015cc:  nop    
0x001015cd:  leave  
0x001015ce:  ret    

----------------
IN: 
0x00100211:  add    $0x10,%esp
0x00100214:  mov    0xc(%ebp),%eax
0x00100217:  mov    (%eax),%eax
0x00100219:  lea    0x1(%eax),%edx
0x0010021c:  mov    0xc(%ebp),%eax
0x0010021f:  mov    %edx,(%eax)
0x00100221:  nop    
0x00100222:  leave  
0x00100223:  ret    

----------------
IN: 
0x001032f5:  add    $0x10,%esp
0x001032f8:  subl   $0x1,-0x18(%ebp)
0x001032fc:  mov    %esi,%eax
0x001032fe:  lea    0x1(%eax),%esi
0x00103301:  movzbl (%eax),%eax
0x00103304:  movsbl %al,%ebx
0x00103307:  test   %ebx,%ebx
0x00103309:  je     0x103331

----------------
IN: 
0x00103331:  cmpl   $0x0,-0x18(%ebp)
0x00103335:  jg     0x10331d

----------------
IN: 
0x00103337:  jmp    0x10348a

----------------
IN: 
0x0010348a:  jmp    0x1030f7

----------------
IN: 
0x001030f7:  jmp    0x103110

----------------
IN: 
0x001030f9:  test   %ebx,%ebx
0x001030fb:  je     0x10348f

----------------
IN: 
0x00103101:  sub    $0x8,%esp
0x00103104:  pushl  0xc(%ebp)
0x00103107:  push   %ebx
0x00103108:  mov    0x8(%ebp),%eax
0x0010310b:  call   *%eax

----------------
IN: 
0x001010f2:  movzwl 0x10ee64,%eax
0x001010f9:  add    $0x50,%eax
0x001010fc:  mov    %ax,0x10ee64
0x00101102:  movzwl 0x10ee64,%ebx
0x00101109:  movzwl 0x10ee64,%ecx
0x00101110:  movzwl %cx,%eax
0x00101113:  imul   $0xcccd,%eax,%eax
0x00101119:  shr    $0x10,%eax
0x0010111c:  mov    %eax,%edx
0x0010111e:  shr    $0x6,%dx
0x00101122:  mov    %edx,%eax
0x00101124:  shl    $0x2,%eax
0x00101127:  add    %edx,%eax
0x00101129:  shl    $0x4,%eax
0x0010112c:  sub    %eax,%ecx
0x0010112e:  mov    %ecx,%edx
0x00101130:  mov    %ebx,%eax
0x00101132:  sub    %edx,%eax
0x00101134:  mov    %ax,0x10ee64
0x0010113a:  jmp    0x101163

----------------
IN: 
0x0010310d:  add    $0x10,%esp
0x00103110:  mov    0x10(%ebp),%eax
0x00103113:  lea    0x1(%eax),%edx
0x00103116:  mov    %edx,0x10(%ebp)
0x00103119:  movzbl (%eax),%eax
0x0010311c:  movzbl %al,%ebx
0x0010311f:  cmp    $0x25,%ebx
0x00103122:  jne    0x1030f9

----------------
IN: 
0x0010348f:  nop    
0x00103490:  lea    -0x8(%ebp),%esp
0x00103493:  pop    %ebx
0x00103494:  pop    %esi
0x00103495:  pop    %ebp
0x00103496:  ret    

----------------
IN: 
0x00100245:  add    $0x10,%esp
0x00100248:  mov    -0xc(%ebp),%eax
0x0010024b:  leave  
0x0010024c:  ret    

----------------
IN: 
0x00100268:  add    $0x10,%esp
0x0010026b:  mov    %eax,-0xc(%ebp)
0x0010026e:  mov    -0xc(%ebp),%eax
0x00100271:  leave  
0x00100272:  ret    

----------------
IN: 
0x00100043:  add    $0x10,%esp
0x00100046:  call   0x1008ec

----------------
IN: 
0x001008ec:  push   %ebp
0x001008ed:  mov    %esp,%ebp
0x001008ef:  sub    $0x8,%esp
0x001008f2:  sub    $0xc,%esp
0x001008f5:  push   $0x103662
0x001008fa:  call   0x10024d

----------------
IN: 
0x001008ff:  add    $0x10,%esp
0x00100902:  sub    $0x8,%esp
0x00100905:  push   $0x100000
0x0010090a:  push   $0x10367b
0x0010090f:  call   0x10024d

----------------
IN: 
0x0010316c:  movb   $0x30,-0x25(%ebp)
0x00103170:  jmp    0x103142

----------------
IN: 
0x00103142:  mov    0x10(%ebp),%eax
0x00103145:  lea    0x1(%eax),%edx
0x00103148:  mov    %edx,0x10(%ebp)
0x0010314b:  movzbl (%eax),%eax
0x0010314e:  movzbl %al,%ebx
0x00103151:  lea    -0x23(%ebx),%eax
0x00103154:  cmp    $0x55,%eax
0x00103157:  ja     0x103462

----------------
IN: 
0x00103172:  movl   $0x0,-0x1c(%ebp)
0x00103179:  mov    -0x1c(%ebp),%edx
0x0010317c:  mov    %edx,%eax
0x0010317e:  shl    $0x2,%eax
0x00103181:  add    %edx,%eax
0x00103183:  add    %eax,%eax
0x00103185:  add    %ebx,%eax
0x00103187:  sub    $0x30,%eax
0x0010318a:  mov    %eax,-0x1c(%ebp)
0x0010318d:  mov    0x10(%ebp),%eax
0x00103190:  movzbl (%eax),%eax
0x00103193:  movsbl %al,%ebx
0x00103196:  cmp    $0x2f,%ebx
0x00103199:  jle    0x1031d4

----------------
IN: 
0x0010319b:  cmp    $0x39,%ebx
0x0010319e:  jg     0x1031d4

----------------
IN: 
0x001031d4:  nop    
0x001031d5:  cmpl   $0x0,-0x18(%ebp)
0x001031d9:  jns    0x103142

----------------
IN: 
0x001031df:  mov    -0x1c(%ebp),%eax
0x001031e2:  mov    %eax,-0x18(%ebp)
0x001031e5:  movl   $0xffffffff,-0x1c(%ebp)
0x001031ec:  jmp    0x103142

----------------
IN: 
0x0010340d:  sub    $0x8,%esp
0x00103410:  pushl  -0x20(%ebp)
0x00103413:  lea    0x14(%ebp),%eax
0x00103416:  push   %eax
0x00103417:  call   0x103035

----------------
IN: 
0x00103035:  push   %ebp
0x00103036:  mov    %esp,%ebp
0x00103038:  cmpl   $0x1,0xc(%ebp)
0x0010303c:  jle    0x103052

----------------
IN: 
0x00103052:  cmpl   $0x0,0xc(%ebp)
0x00103056:  je     0x10306e

----------------
IN: 
0x0010306e:  mov    0x8(%ebp),%eax
0x00103071:  mov    (%eax),%eax
0x00103073:  lea    0x4(%eax),%ecx
0x00103076:  mov    0x8(%ebp),%edx
0x00103079:  mov    %ecx,(%edx)
0x0010307b:  mov    (%eax),%eax
0x0010307d:  mov    $0x0,%edx
0x00103082:  pop    %ebp
0x00103083:  ret    

----------------
IN: 
0x0010341c:  add    $0x10,%esp
0x0010341f:  mov    %eax,-0x10(%ebp)
0x00103422:  mov    %edx,-0xc(%ebp)
0x00103425:  movl   $0x10,-0x14(%ebp)
0x0010342c:  movsbl -0x25(%ebp),%edx
0x00103430:  mov    -0x14(%ebp),%eax
0x00103433:  sub    $0x4,%esp
0x00103436:  push   %edx
0x00103437:  pushl  -0x18(%ebp)
0x0010343a:  push   %eax
0x0010343b:  pushl  -0xc(%ebp)
0x0010343e:  pushl  -0x10(%ebp)
0x00103441:  pushl  0xc(%ebp)
0x00103444:  pushl  0x8(%ebp)
0x00103447:  call   0x102f44

----------------
IN: 
0x00102f44:  push   %ebp
0x00102f45:  mov    %esp,%ebp
0x00102f47:  sub    $0x38,%esp
0x00102f4a:  mov    0x10(%ebp),%eax
0x00102f4d:  mov    %eax,-0x30(%ebp)
0x00102f50:  mov    0x14(%ebp),%eax
0x00102f53:  mov    %eax,-0x2c(%ebp)
0x00102f56:  mov    -0x30(%ebp),%eax
0x00102f59:  mov    -0x2c(%ebp),%edx
0x00102f5c:  mov    %eax,-0x18(%ebp)
0x00102f5f:  mov    %edx,-0x14(%ebp)
0x00102f62:  mov    0x18(%ebp),%eax
0x00102f65:  mov    %eax,-0x1c(%ebp)
0x00102f68:  mov    -0x18(%ebp),%eax
0x00102f6b:  mov    -0x14(%ebp),%edx
0x00102f6e:  mov    %eax,-0x20(%ebp)
0x00102f71:  mov    %edx,-0x10(%ebp)
0x00102f74:  mov    -0x10(%ebp),%eax
0x00102f77:  mov    %eax,-0xc(%ebp)
0x00102f7a:  cmpl   $0x0,-0x10(%ebp)
0x00102f7e:  je     0x102f9c

----------------
IN: 
0x00102f9c:  mov    -0x20(%ebp),%eax
0x00102f9f:  mov    -0xc(%ebp),%edx
0x00102fa2:  divl   -0x1c(%ebp)
0x00102fa5:  mov    %eax,-0x20(%ebp)
0x00102fa8:  mov    %edx,-0x24(%ebp)
0x00102fab:  mov    -0x20(%ebp),%eax
0x00102fae:  mov    -0x10(%ebp),%edx
0x00102fb1:  mov    %eax,-0x18(%ebp)
0x00102fb4:  mov    %edx,-0x14(%ebp)
0x00102fb7:  mov    -0x24(%ebp),%eax
0x00102fba:  mov    %eax,-0x28(%ebp)
0x00102fbd:  mov    0x18(%ebp),%eax
0x00102fc0:  mov    $0x0,%edx
0x00102fc5:  cmp    -0x2c(%ebp),%edx
0x00102fc8:  ja     0x10300b

----------------
IN: 
0x00102fca:  cmp    -0x2c(%ebp),%edx
0x00102fcd:  jb     0x102fd4

----------------
IN: 
0x00102fcf:  cmp    -0x30(%ebp),%eax
0x00102fd2:  ja     0x10300b

----------------
IN: 
0x00102fd4:  mov    0x1c(%ebp),%eax
0x00102fd7:  sub    $0x1,%eax
0x00102fda:  sub    $0x4,%esp
0x00102fdd:  pushl  0x20(%ebp)
0x00102fe0:  push   %eax
0x00102fe1:  pushl  0x18(%ebp)
0x00102fe4:  pushl  -0x14(%ebp)
0x00102fe7:  pushl  -0x18(%ebp)
0x00102fea:  pushl  0xc(%ebp)
0x00102fed:  pushl  0x8(%ebp)
0x00102ff0:  call   0x102f44

----------------
IN: 
0x0010300b:  subl   $0x1,0x1c(%ebp)
0x0010300f:  cmpl   $0x0,0x1c(%ebp)
0x00103013:  jg     0x102ffa

----------------
IN: 
0x00102ffa:  sub    $0x8,%esp
0x00102ffd:  pushl  0xc(%ebp)
0x00103000:  pushl  0x20(%ebp)
0x00103003:  mov    0x8(%ebp),%eax
0x00103006:  call   *%eax

----------------
IN: 
0x00103008:  add    $0x10,%esp
0x0010300b:  subl   $0x1,0x1c(%ebp)
0x0010300f:  cmpl   $0x0,0x1c(%ebp)
0x00103013:  jg     0x102ffa

----------------
IN: 
0x00103015:  mov    -0x28(%ebp),%eax
0x00103018:  add    $0x103cf0,%eax
0x0010301d:  movzbl (%eax),%eax
0x00103020:  movsbl %al,%eax
0x00103023:  sub    $0x8,%esp
0x00103026:  pushl  0xc(%ebp)
0x00103029:  push   %eax
0x0010302a:  mov    0x8(%ebp),%eax
0x0010302d:  call   *%eax

----------------
IN: 
0x0010302f:  add    $0x10,%esp
0x00103032:  nop    
0x00103033:  leave  
0x00103034:  ret    

----------------
IN: 
0x00102ff5:  add    $0x20,%esp
0x00102ff8:  jmp    0x103015

----------------
IN: 
0x0010344c:  add    $0x20,%esp
0x0010344f:  jmp    0x10348a

----------------
IN: 
0x00100914:  add    $0x10,%esp
0x00100917:  sub    $0x8,%esp
0x0010091a:  push   $0x103550
0x0010091f:  push   $0x103693
0x00100924:  call   0x10024d

----------------
IN: 
0x00100929:  add    $0x10,%esp
0x0010092c:  sub    $0x8,%esp
0x0010092f:  push   $0x10ea16
0x00100934:  push   $0x1036ab
0x00100939:  call   0x10024d

----------------
IN: 
0x0010093e:  add    $0x10,%esp
0x00100941:  sub    $0x8,%esp
0x00100944:  push   $0x10fd80
0x00100949:  push   $0x1036c3
0x0010094e:  call   0x10024d

----------------
IN: 
0x00100953:  add    $0x10,%esp
0x00100956:  mov    $0x10fd80,%eax
0x0010095b:  add    $0x3ff,%eax
0x00100960:  mov    $0x100000,%edx
0x00100965:  sub    %edx,%eax
0x00100967:  lea    0x3ff(%eax),%edx
0x0010096d:  test   %eax,%eax
0x0010096f:  cmovs  %edx,%eax
0x00100972:  sar    $0xa,%eax
0x00100975:  sub    $0x8,%esp
0x00100978:  push   %eax
0x00100979:  push   $0x1036dc
0x0010097e:  call   0x10024d

----------------
IN: 
0x0010333c:  sub    $0x8,%esp
0x0010333f:  pushl  -0x20(%ebp)
0x00103342:  lea    0x14(%ebp),%eax
0x00103345:  push   %eax
0x00103346:  call   0x103084

----------------
IN: 
0x00103084:  push   %ebp
0x00103085:  mov    %esp,%ebp
0x00103087:  cmpl   $0x1,0xc(%ebp)
0x0010308b:  jle    0x1030a1

----------------
IN: 
0x001030a1:  cmpl   $0x0,0xc(%ebp)
0x001030a5:  je     0x1030b9

----------------
IN: 
0x001030b9:  mov    0x8(%ebp),%eax
0x001030bc:  mov    (%eax),%eax
0x001030be:  lea    0x4(%eax),%ecx
0x001030c1:  mov    0x8(%ebp),%edx
0x001030c4:  mov    %ecx,(%edx)
0x001030c6:  mov    (%eax),%eax
0x001030c8:  cltd   
0x001030c9:  pop    %ebp
0x001030ca:  ret    

----------------
IN: 
0x0010334b:  add    $0x10,%esp
0x0010334e:  mov    %eax,-0x10(%ebp)
0x00103351:  mov    %edx,-0xc(%ebp)
0x00103354:  mov    -0x10(%ebp),%eax
0x00103357:  mov    -0xc(%ebp),%edx
0x0010335a:  test   %edx,%edx
0x0010335c:  jns    0x103381

----------------
IN: 
0x00103381:  movl   $0xa,-0x14(%ebp)
0x00103388:  jmp    0x10342c

----------------
IN: 
0x0010342c:  movsbl -0x25(%ebp),%edx
0x00103430:  mov    -0x14(%ebp),%eax
0x00103433:  sub    $0x4,%esp
0x00103436:  push   %edx
0x00103437:  pushl  -0x18(%ebp)
0x0010343a:  push   %eax
0x0010343b:  pushl  -0xc(%ebp)
0x0010343e:  pushl  -0x10(%ebp)
0x00103441:  pushl  0xc(%ebp)
0x00103444:  pushl  0x8(%ebp)
0x00103447:  call   0x102f44

----------------
IN: 
0x00100983:  add    $0x10,%esp
0x00100986:  nop    
0x00100987:  leave  
0x00100988:  ret    

----------------
IN: 
0x0010004b:  call   0x1000c9

----------------
IN: 
0x001000c9:  push   %ebp
0x001000ca:  mov    %esp,%ebp
0x001000cc:  sub    $0x8,%esp
0x001000cf:  mov    $0x100000,%eax
0x001000d4:  sub    $0x4,%esp
0x001000d7:  push   $0xffff0000
0x001000dc:  push   %eax
0x001000dd:  push   $0x0
0x001000df:  call   0x1000af

----------------
IN: 
0x001000af:  push   %ebp
0x001000b0:  mov    %esp,%ebp
0x001000b2:  sub    $0x8,%esp
0x001000b5:  sub    $0x8,%esp
0x001000b8:  pushl  0x10(%ebp)
0x001000bb:  pushl  0x8(%ebp)
0x001000be:  call   0x10008a

----------------
IN: 
0x0010008a:  push   %ebp
0x0010008b:  mov    %esp,%ebp
0x0010008d:  push   %ebx
0x0010008e:  sub    $0x4,%esp
0x00100091:  lea    0xc(%ebp),%ecx
0x00100094:  mov    0xc(%ebp),%edx
0x00100097:  lea    0x8(%ebp),%ebx
0x0010009a:  mov    0x8(%ebp),%eax
0x0010009d:  push   %ecx
0x0010009e:  push   %edx
0x0010009f:  push   %ebx
0x001000a0:  push   %eax
0x001000a1:  call   0x100070

----------------
IN: 
0x00100070:  push   %ebp
0x00100071:  mov    %esp,%ebp
0x00100073:  sub    $0x8,%esp
0x00100076:  sub    $0x4,%esp
0x00100079:  push   $0x0
0x0010007b:  push   $0x0
0x0010007d:  push   $0x0
0x0010007f:  call   0x100d41

----------------
IN: 
0x00100d41:  push   %ebp
0x00100d42:  mov    %esp,%ebp
0x00100d44:  sub    $0x8,%esp
0x00100d47:  call   0x100a36

----------------
IN: 
0x00100a36:  push   %ebp
0x00100a37:  mov    %esp,%ebp
0x00100a39:  sub    $0x28,%esp
0x00100a3c:  mov    %ebp,%eax
0x00100a3e:  mov    %eax,-0x20(%ebp)
0x00100a41:  mov    -0x20(%ebp),%eax
0x00100a44:  mov    %eax,-0xc(%ebp)
0x00100a47:  call   0x100a25

----------------
IN: 
0x00100a25:  push   %ebp
0x00100a26:  mov    %esp,%ebp
0x00100a28:  sub    $0x10,%esp
0x00100a2b:  mov    0x4(%ebp),%eax
0x00100a2e:  mov    %eax,-0x4(%ebp)
0x00100a31:  mov    -0x4(%ebp),%eax
0x00100a34:  leave  
0x00100a35:  ret    

----------------
IN: 
0x00100a4c:  mov    %eax,-0x10(%ebp)
0x00100a4f:  movl   $0x0,-0x14(%ebp)
0x00100a56:  jmp    0x100ae8

----------------
IN: 
0x00100ae8:  cmpl   $0x0,-0xc(%ebp)
0x00100aec:  je     0x100af8

----------------
IN: 
0x00100aee:  cmpl   $0x13,-0x14(%ebp)
0x00100af2:  jle    0x100a5b

----------------
IN: 
0x00100a5b:  sub    $0x4,%esp
0x00100a5e:  pushl  -0x10(%ebp)
0x00100a61:  pushl  -0xc(%ebp)
0x00100a64:  push   $0x103734
0x00100a69:  call   0x10024d

----------------
IN: 
0x00100a6e:  add    $0x10,%esp
0x00100a71:  mov    -0xc(%ebp),%eax
0x00100a74:  add    $0x8,%eax
0x00100a77:  mov    %eax,-0x1c(%ebp)
0x00100a7a:  movl   $0x0,-0x18(%ebp)
0x00100a81:  jmp    0x100aa9

----------------
IN: 
0x00100aa9:  cmpl   $0x3,-0x18(%ebp)
0x00100aad:  jle    0x100a83

----------------
IN: 
0x00100a83:  mov    -0x18(%ebp),%eax
0x00100a86:  lea    0x0(,%eax,4),%edx
0x00100a8d:  mov    -0x1c(%ebp),%eax
0x00100a90:  add    %edx,%eax
0x00100a92:  mov    (%eax),%eax
0x00100a94:  sub    $0x8,%esp
0x00100a97:  push   %eax
0x00100a98:  push   $0x103750
0x00100a9d:  call   0x10024d

----------------
IN: 
0x00100aa2:  add    $0x10,%esp
0x00100aa5:  addl   $0x1,-0x18(%ebp)
0x00100aa9:  cmpl   $0x3,-0x18(%ebp)
0x00100aad:  jle    0x100a83

----------------
IN: 
0x00100aaf:  sub    $0xc,%esp
0x00100ab2:  push   $0x103758
0x00100ab7:  call   0x10024d

----------------
IN: 
0x00100abc:  add    $0x10,%esp
0x00100abf:  mov    -0x10(%ebp),%eax
0x00100ac2:  sub    $0x1,%eax
0x00100ac5:  sub    $0xc,%esp
0x00100ac8:  push   %eax
0x00100ac9:  call   0x100989

----------------
IN: 
0x00100989:  push   %ebp
0x0010098a:  mov    %esp,%ebp
0x0010098c:  sub    $0x128,%esp
0x00100992:  sub    $0x8,%esp
0x00100995:  lea    -0x24(%ebp),%eax
0x00100998:  push   %eax
0x00100999:  pushl  0x8(%ebp)
0x0010099c:  call   0x1005de

----------------
IN: 
0x001005de:  push   %ebp
0x001005df:  mov    %esp,%ebp
0x001005e1:  sub    $0x38,%esp
0x001005e4:  mov    0xc(%ebp),%eax
0x001005e7:  movl   $0x103658,(%eax)
0x001005ed:  mov    0xc(%ebp),%eax
0x001005f0:  movl   $0x0,0x4(%eax)
0x001005f7:  mov    0xc(%ebp),%eax
0x001005fa:  movl   $0x103658,0x8(%eax)
0x00100601:  mov    0xc(%ebp),%eax
0x00100604:  movl   $0x9,0xc(%eax)
0x0010060b:  mov    0xc(%ebp),%eax
0x0010060e:  mov    0x8(%ebp),%edx
0x00100611:  mov    %edx,0x10(%eax)
0x00100614:  mov    0xc(%ebp),%eax
0x00100617:  movl   $0x0,0x14(%eax)
0x0010061e:  movl   $0x103e6c,-0xc(%ebp)
0x00100625:  movl   $0x10b8c4,-0x10(%ebp)
0x0010062c:  movl   $0x10b8c5,-0x14(%ebp)
0x00100633:  movl   $0x10d91d,-0x18(%ebp)
0x0010063a:  mov    -0x18(%ebp),%eax
0x0010063d:  cmp    -0x14(%ebp),%eax
0x00100640:  jbe    0x10064f

----------------
IN: 
0x00100642:  mov    -0x18(%ebp),%eax
0x00100645:  sub    $0x1,%eax
0x00100648:  movzbl (%eax),%eax
0x0010064b:  test   %al,%al
0x0010064d:  je     0x100659

----------------
IN: 
0x00100659:  movl   $0x0,-0x1c(%ebp)
0x00100660:  mov    -0x10(%ebp),%edx
0x00100663:  mov    -0xc(%ebp),%eax
0x00100666:  sub    %eax,%edx
0x00100668:  mov    %edx,%eax
0x0010066a:  sar    $0x2,%eax
0x0010066d:  imul   $0xaaaaaaab,%eax,%eax
0x00100673:  sub    $0x1,%eax
0x00100676:  mov    %eax,-0x20(%ebp)
0x00100679:  pushl  0x8(%ebp)
0x0010067c:  push   $0x64
0x0010067e:  lea    -0x20(%ebp),%eax
0x00100681:  push   %eax
0x00100682:  lea    -0x1c(%ebp),%eax
0x00100685:  push   %eax
0x00100686:  pushl  -0xc(%ebp)
0x00100689:  call   0x100487

----------------
IN: 
0x00100487:  push   %ebp
0x00100488:  mov    %esp,%ebp
0x0010048a:  sub    $0x20,%esp
0x0010048d:  mov    0xc(%ebp),%eax
0x00100490:  mov    (%eax),%eax
0x00100492:  mov    %eax,-0x4(%ebp)
0x00100495:  mov    0x10(%ebp),%eax
0x00100498:  mov    (%eax),%eax
0x0010049a:  mov    %eax,-0x8(%ebp)
0x0010049d:  movl   $0x0,-0xc(%ebp)
0x001004a4:  jmp    0x10057b

----------------
IN: 
0x0010057b:  mov    -0x4(%ebp),%eax
0x0010057e:  cmp    -0x8(%ebp),%eax
0x00100581:  jle    0x1004a9

----------------
IN: 
0x001004a9:  mov    -0x4(%ebp),%edx
0x001004ac:  mov    -0x8(%ebp),%eax
0x001004af:  add    %edx,%eax
0x001004b1:  mov    %eax,%edx
0x001004b3:  shr    $0x1f,%edx
0x001004b6:  add    %edx,%eax
0x001004b8:  sar    %eax
0x001004ba:  mov    %eax,-0x14(%ebp)
0x001004bd:  mov    -0x14(%ebp),%eax
0x001004c0:  mov    %eax,-0x10(%ebp)
0x001004c3:  jmp    0x1004c9

----------------
IN: 
0x001004c9:  mov    -0x10(%ebp),%eax
0x001004cc:  cmp    -0x4(%ebp),%eax
0x001004cf:  jl     0x1004f0

----------------
IN: 
0x001004d1:  mov    -0x10(%ebp),%edx
0x001004d4:  mov    %edx,%eax
0x001004d6:  add    %eax,%eax
0x001004d8:  add    %edx,%eax
0x001004da:  shl    $0x2,%eax
0x001004dd:  mov    %eax,%edx
0x001004df:  mov    0x8(%ebp),%eax
0x001004e2:  add    %edx,%eax
0x001004e4:  movzbl 0x4(%eax),%eax
0x001004e8:  movzbl %al,%eax
0x001004eb:  cmp    0x14(%ebp),%eax
0x001004ee:  jne    0x1004c5

----------------
IN: 
0x001004c5:  subl   $0x1,-0x10(%ebp)
0x001004c9:  mov    -0x10(%ebp),%eax
0x001004cc:  cmp    -0x4(%ebp),%eax
0x001004cf:  jl     0x1004f0

----------------
IN: 
0x001004f0:  mov    -0x10(%ebp),%eax
0x001004f3:  cmp    -0x4(%ebp),%eax
0x001004f6:  jge    0x100503

----------------
IN: 
0x00100503:  movl   $0x1,-0xc(%ebp)
0x0010050a:  mov    -0x10(%ebp),%edx
0x0010050d:  mov    %edx,%eax
0x0010050f:  add    %eax,%eax
0x00100511:  add    %edx,%eax
0x00100513:  shl    $0x2,%eax
0x00100516:  mov    %eax,%edx
0x00100518:  mov    0x8(%ebp),%eax
0x0010051b:  add    %edx,%eax
0x0010051d:  mov    0x8(%eax),%eax
0x00100520:  cmp    0x18(%ebp),%eax
0x00100523:  jae    0x100538

----------------
IN: 
0x00100538:  mov    -0x10(%ebp),%edx
0x0010053b:  mov    %edx,%eax
0x0010053d:  add    %eax,%eax
0x0010053f:  add    %edx,%eax
0x00100541:  shl    $0x2,%eax
0x00100544:  mov    %eax,%edx
0x00100546:  mov    0x8(%ebp),%eax
0x00100549:  add    %edx,%eax
0x0010054b:  mov    0x8(%eax),%eax
0x0010054e:  cmp    0x18(%ebp),%eax
0x00100551:  jbe    0x100569

----------------
IN: 
0x00100553:  mov    -0x10(%ebp),%eax
0x00100556:  lea    -0x1(%eax),%edx
0x00100559:  mov    0x10(%ebp),%eax
0x0010055c:  mov    %edx,(%eax)
0x0010055e:  mov    -0x10(%ebp),%eax
0x00100561:  sub    $0x1,%eax
0x00100564:  mov    %eax,-0x8(%ebp)
0x00100567:  jmp    0x10057b

----------------
IN: 
0x00100525:  mov    0xc(%ebp),%eax
0x00100528:  mov    -0x10(%ebp),%edx
0x0010052b:  mov    %edx,(%eax)
0x0010052d:  mov    -0x14(%ebp),%eax
0x00100530:  add    $0x1,%eax
0x00100533:  mov    %eax,-0x4(%ebp)
0x00100536:  jmp    0x10057b

----------------
IN: 
0x001004f8:  mov    -0x14(%ebp),%eax
0x001004fb:  add    $0x1,%eax
0x001004fe:  mov    %eax,-0x4(%ebp)
0x00100501:  jmp    0x10057b

----------------
IN: 
0x00100587:  cmpl   $0x0,-0xc(%ebp)
0x0010058b:  jne    0x10059c

----------------
IN: 
0x0010059c:  mov    0x10(%ebp),%eax
0x0010059f:  mov    (%eax),%eax
0x001005a1:  mov    %eax,-0x4(%ebp)
0x001005a4:  jmp    0x1005aa

----------------
IN: 
0x001005aa:  mov    0xc(%ebp),%eax
0x001005ad:  mov    (%eax),%eax
0x001005af:  cmp    -0x4(%ebp),%eax
0x001005b2:  jge    0x1005d3

----------------
IN: 
0x001005b4:  mov    -0x4(%ebp),%edx
0x001005b7:  mov    %edx,%eax
0x001005b9:  add    %eax,%eax
0x001005bb:  add    %edx,%eax
0x001005bd:  shl    $0x2,%eax
0x001005c0:  mov    %eax,%edx
0x001005c2:  mov    0x8(%ebp),%eax
0x001005c5:  add    %edx,%eax
0x001005c7:  movzbl 0x4(%eax),%eax
0x001005cb:  movzbl %al,%eax
0x001005ce:  cmp    0x14(%ebp),%eax
0x001005d1:  jne    0x1005a6

----------------
IN: 
0x001005a6:  subl   $0x1,-0x4(%ebp)
0x001005aa:  mov    0xc(%ebp),%eax
0x001005ad:  mov    (%eax),%eax
0x001005af:  cmp    -0x4(%ebp),%eax
0x001005b2:  jge    0x1005d3

----------------
IN: 
0x001005d3:  mov    0xc(%ebp),%eax
0x001005d6:  mov    -0x4(%ebp),%edx
0x001005d9:  mov    %edx,(%eax)
0x001005db:  nop    
0x001005dc:  leave  
0x001005dd:  ret    

----------------
IN: 
0x0010068e:  add    $0x14,%esp
0x00100691:  mov    -0x1c(%ebp),%eax
0x00100694:  test   %eax,%eax
0x00100696:  jne    0x1006a2

----------------
IN: 
0x001006a2:  mov    -0x1c(%ebp),%eax
0x001006a5:  mov    %eax,-0x24(%ebp)
0x001006a8:  mov    -0x20(%ebp),%eax
0x001006ab:  mov    %eax,-0x28(%ebp)
0x001006ae:  pushl  0x8(%ebp)
0x001006b1:  push   $0x24
0x001006b3:  lea    -0x28(%ebp),%eax
0x001006b6:  push   %eax
0x001006b7:  lea    -0x24(%ebp),%eax
0x001006ba:  push   %eax
0x001006bb:  pushl  -0xc(%ebp)
0x001006be:  call   0x100487

----------------
IN: 
0x001006c3:  add    $0x14,%esp
0x001006c6:  mov    -0x24(%ebp),%edx
0x001006c9:  mov    -0x28(%ebp),%eax
0x001006cc:  cmp    %eax,%edx
0x001006ce:  jg     0x10074c

----------------
IN: 
0x001006d0:  mov    -0x24(%ebp),%eax
0x001006d3:  mov    %eax,%edx
0x001006d5:  mov    %edx,%eax
0x001006d7:  add    %eax,%eax
0x001006d9:  add    %edx,%eax
0x001006db:  shl    $0x2,%eax
0x001006de:  mov    %eax,%edx
0x001006e0:  mov    -0xc(%ebp),%eax
0x001006e3:  add    %edx,%eax
0x001006e5:  mov    (%eax),%eax
0x001006e7:  mov    -0x18(%ebp),%ecx
0x001006ea:  mov    -0x14(%ebp),%edx
0x001006ed:  sub    %edx,%ecx
0x001006ef:  mov    %ecx,%edx
0x001006f1:  cmp    %edx,%eax
0x001006f3:  jae    0x100717

----------------
IN: 
0x001006f5:  mov    -0x24(%ebp),%eax
0x001006f8:  mov    %eax,%edx
0x001006fa:  mov    %edx,%eax
0x001006fc:  add    %eax,%eax
0x001006fe:  add    %edx,%eax
0x00100700:  shl    $0x2,%eax
0x00100703:  mov    %eax,%edx
0x00100705:  mov    -0xc(%ebp),%eax
0x00100708:  add    %edx,%eax
0x0010070a:  mov    (%eax),%edx
0x0010070c:  mov    -0x14(%ebp),%eax
0x0010070f:  add    %eax,%edx
0x00100711:  mov    0xc(%ebp),%eax
0x00100714:  mov    %edx,0x8(%eax)
0x00100717:  mov    -0x24(%ebp),%eax
0x0010071a:  mov    %eax,%edx
0x0010071c:  mov    %edx,%eax
0x0010071e:  add    %eax,%eax
0x00100720:  add    %edx,%eax
0x00100722:  shl    $0x2,%eax
0x00100725:  mov    %eax,%edx
0x00100727:  mov    -0xc(%ebp),%eax
0x0010072a:  add    %edx,%eax
0x0010072c:  mov    0x8(%eax),%edx
0x0010072f:  mov    0xc(%ebp),%eax
0x00100732:  mov    %edx,0x10(%eax)
0x00100735:  mov    0xc(%ebp),%eax
0x00100738:  mov    0x10(%eax),%eax
0x0010073b:  sub    %eax,0x8(%ebp)
0x0010073e:  mov    -0x24(%ebp),%eax
0x00100741:  mov    %eax,-0x2c(%ebp)
0x00100744:  mov    -0x28(%ebp),%eax
0x00100747:  mov    %eax,-0x30(%ebp)
0x0010074a:  jmp    0x100761

----------------
IN: 
0x00100761:  mov    0xc(%ebp),%eax
0x00100764:  mov    0x8(%eax),%eax
0x00100767:  sub    $0x8,%esp
0x0010076a:  push   $0x3a
0x0010076c:  push   %eax
0x0010076d:  call   0x102c2d

----------------
IN: 
0x00102c2d:  push   %ebp
0x00102c2e:  mov    %esp,%ebp
0x00102c30:  sub    $0x4,%esp
0x00102c33:  mov    0xc(%ebp),%eax
0x00102c36:  mov    %al,-0x4(%ebp)
0x00102c39:  jmp    0x102c4a

----------------
IN: 
0x00102c4a:  mov    0x8(%ebp),%eax
0x00102c4d:  movzbl (%eax),%eax
0x00102c50:  test   %al,%al
0x00102c52:  jne    0x102c3b

----------------
IN: 
0x00102c3b:  mov    0x8(%ebp),%eax
0x00102c3e:  movzbl (%eax),%eax
0x00102c41:  cmp    -0x4(%ebp),%al
0x00102c44:  je     0x102c56

----------------
IN: 
0x00102c46:  addl   $0x1,0x8(%ebp)
0x00102c4a:  mov    0x8(%ebp),%eax
0x00102c4d:  movzbl (%eax),%eax
0x00102c50:  test   %al,%al
0x00102c52:  jne    0x102c3b

----------------
IN: 
0x00102c56:  nop    
0x00102c57:  mov    0x8(%ebp),%eax
0x00102c5a:  leave  
0x00102c5b:  ret    

----------------
IN: 
0x00100772:  add    $0x10,%esp
0x00100775:  mov    %eax,%edx
0x00100777:  mov    0xc(%ebp),%eax
0x0010077a:  mov    0x8(%eax),%eax
0x0010077d:  sub    %eax,%edx
0x0010077f:  mov    0xc(%ebp),%eax
0x00100782:  mov    %edx,0xc(%eax)
0x00100785:  sub    $0xc,%esp
0x00100788:  pushl  0x8(%ebp)
0x0010078b:  push   $0x44
0x0010078d:  lea    -0x30(%ebp),%eax
0x00100790:  push   %eax
0x00100791:  lea    -0x2c(%ebp),%eax
0x00100794:  push   %eax
0x00100795:  pushl  -0xc(%ebp)
0x00100798:  call   0x100487

----------------
IN: 
0x0010079d:  add    $0x20,%esp
0x001007a0:  mov    -0x2c(%ebp),%edx
0x001007a3:  mov    -0x30(%ebp),%eax
0x001007a6:  cmp    %eax,%edx
0x001007a8:  jg     0x1007ce

----------------
IN: 
0x001007aa:  mov    -0x30(%ebp),%eax
0x001007ad:  mov    %eax,%edx
0x001007af:  mov    %edx,%eax
0x001007b1:  add    %eax,%eax
0x001007b3:  add    %edx,%eax
0x001007b5:  shl    $0x2,%eax
0x001007b8:  mov    %eax,%edx
0x001007ba:  mov    -0xc(%ebp),%eax
0x001007bd:  add    %edx,%eax
0x001007bf:  movzwl 0x6(%eax),%eax
0x001007c3:  movzwl %ax,%edx
0x001007c6:  mov    0xc(%ebp),%eax
0x001007c9:  mov    %edx,0x4(%eax)
0x001007cc:  jmp    0x1007e1

----------------
IN: 
0x001007e1:  mov    -0x2c(%ebp),%edx
0x001007e4:  mov    -0x1c(%ebp),%eax
0x001007e7:  cmp    %eax,%edx
0x001007e9:  jl     0x100841

----------------
IN: 
0x001007eb:  mov    -0x2c(%ebp),%eax
0x001007ee:  mov    %eax,%edx
0x001007f0:  mov    %edx,%eax
0x001007f2:  add    %eax,%eax
0x001007f4:  add    %edx,%eax
0x001007f6:  shl    $0x2,%eax
0x001007f9:  mov    %eax,%edx
0x001007fb:  mov    -0xc(%ebp),%eax
0x001007fe:  add    %edx,%eax
0x00100800:  movzbl 0x4(%eax),%eax
0x00100804:  cmp    $0x84,%al
0x00100806:  je     0x100841

----------------
IN: 
0x00100808:  mov    -0x2c(%ebp),%eax
0x0010080b:  mov    %eax,%edx
0x0010080d:  mov    %edx,%eax
0x0010080f:  add    %eax,%eax
0x00100811:  add    %edx,%eax
0x00100813:  shl    $0x2,%eax
0x00100816:  mov    %eax,%edx
0x00100818:  mov    -0xc(%ebp),%eax
0x0010081b:  add    %edx,%eax
0x0010081d:  movzbl 0x4(%eax),%eax
0x00100821:  cmp    $0x64,%al
0x00100823:  jne    0x1007d8

----------------
IN: 
0x001007d8:  mov    -0x2c(%ebp),%eax
0x001007db:  sub    $0x1,%eax
0x001007de:  mov    %eax,-0x2c(%ebp)
0x001007e1:  mov    -0x2c(%ebp),%edx
0x001007e4:  mov    -0x1c(%ebp),%eax
0x001007e7:  cmp    %eax,%edx
0x001007e9:  jl     0x100841

----------------
IN: 
0x00100841:  mov    -0x2c(%ebp),%edx
0x00100844:  mov    -0x1c(%ebp),%eax
0x00100847:  cmp    %eax,%edx
0x00100849:  jl     0x100891

----------------
IN: 
0x0010084b:  mov    -0x2c(%ebp),%eax
0x0010084e:  mov    %eax,%edx
0x00100850:  mov    %edx,%eax
0x00100852:  add    %eax,%eax
0x00100854:  add    %edx,%eax
0x00100856:  shl    $0x2,%eax
0x00100859:  mov    %eax,%edx
0x0010085b:  mov    -0xc(%ebp),%eax
0x0010085e:  add    %edx,%eax
0x00100860:  mov    (%eax),%eax
0x00100862:  mov    -0x18(%ebp),%ecx
0x00100865:  mov    -0x14(%ebp),%edx
0x00100868:  sub    %edx,%ecx
0x0010086a:  mov    %ecx,%edx
0x0010086c:  cmp    %edx,%eax
0x0010086e:  jae    0x100891

----------------
IN: 
0x00100870:  mov    -0x2c(%ebp),%eax
0x00100873:  mov    %eax,%edx
0x00100875:  mov    %edx,%eax
0x00100877:  add    %eax,%eax
0x00100879:  add    %edx,%eax
0x0010087b:  shl    $0x2,%eax
0x0010087e:  mov    %eax,%edx
0x00100880:  mov    -0xc(%ebp),%eax
0x00100883:  add    %edx,%eax
0x00100885:  mov    (%eax),%edx
0x00100887:  mov    -0x14(%ebp),%eax
0x0010088a:  add    %eax,%edx
0x0010088c:  mov    0xc(%ebp),%eax
0x0010088f:  mov    %edx,(%eax)
0x00100891:  mov    -0x24(%ebp),%edx
0x00100894:  mov    -0x28(%ebp),%eax
0x00100897:  cmp    %eax,%edx
0x00100899:  jge    0x1008e5

----------------
IN: 
0x0010089b:  mov    -0x24(%ebp),%eax
0x0010089e:  add    $0x1,%eax
0x001008a1:  mov    %eax,-0x2c(%ebp)
0x001008a4:  jmp    0x1008be

----------------
IN: 
0x001008be:  mov    -0x2c(%ebp),%edx
0x001008c1:  mov    -0x28(%ebp),%eax
0x001008c4:  cmp    %eax,%edx
0x001008c6:  jge    0x1008e5

----------------
IN: 
0x001008c8:  mov    -0x2c(%ebp),%eax
0x001008cb:  mov    %eax,%edx
0x001008cd:  mov    %edx,%eax
0x001008cf:  add    %eax,%eax
0x001008d1:  add    %edx,%eax
0x001008d3:  shl    $0x2,%eax
0x001008d6:  mov    %eax,%edx
0x001008d8:  mov    -0xc(%ebp),%eax
0x001008db:  add    %edx,%eax
0x001008dd:  movzbl 0x4(%eax),%eax
0x001008e1:  cmp    $0xa0,%al
0x001008e3:  je     0x1008a6

----------------
IN: 
0x001008e5:  mov    $0x0,%eax
0x001008ea:  leave  
0x001008eb:  ret    

----------------
IN: 
0x001009a1:  add    $0x10,%esp
0x001009a4:  test   %eax,%eax
0x001009a6:  je     0x1009bd

----------------
IN: 
0x001009bd:  movl   $0x0,-0xc(%ebp)
0x001009c4:  jmp    0x1009e2

----------------
IN: 
0x001009e2:  mov    -0x18(%ebp),%eax
0x001009e5:  cmp    -0xc(%ebp),%eax
0x001009e8:  jg     0x1009c6

----------------
IN: 
0x001009c6:  mov    -0x1c(%ebp),%edx
0x001009c9:  mov    -0xc(%ebp),%eax
0x001009cc:  add    %edx,%eax
0x001009ce:  movzbl (%eax),%eax
0x001009d1:  lea    -0x124(%ebp),%ecx
0x001009d7:  mov    -0xc(%ebp),%edx
0x001009da:  add    %ecx,%edx
0x001009dc:  mov    %al,(%edx)
0x001009de:  addl   $0x1,-0xc(%ebp)
0x001009e2:  mov    -0x18(%ebp),%eax
0x001009e5:  cmp    -0xc(%ebp),%eax
0x001009e8:  jg     0x1009c6

----------------
IN: 
0x001009ea:  lea    -0x124(%ebp),%edx
0x001009f0:  mov    -0xc(%ebp),%eax
0x001009f3:  add    %edx,%eax
0x001009f5:  movb   $0x0,(%eax)
0x001009f8:  mov    -0x14(%ebp),%eax
0x001009fb:  mov    0x8(%ebp),%edx
0x001009fe:  mov    %edx,%ecx
0x00100a00:  sub    %eax,%ecx
0x00100a02:  mov    -0x20(%ebp),%edx
0x00100a05:  mov    -0x24(%ebp),%eax
0x00100a08:  sub    $0xc,%esp
0x00100a0b:  push   %ecx
0x00100a0c:  lea    -0x124(%ebp),%ecx
0x00100a12:  push   %ecx
0x00100a13:  push   %edx
0x00100a14:  push   %eax
0x00100a15:  push   $0x103722
0x00100a1a:  call   0x10024d

----------------
IN: 
0x00100a1f:  add    $0x20,%esp
0x00100a22:  nop    
0x00100a23:  leave  
0x00100a24:  ret    

----------------
IN: 
0x00100ace:  add    $0x10,%esp
0x00100ad1:  mov    -0xc(%ebp),%eax
0x00100ad4:  add    $0x4,%eax
0x00100ad7:  mov    (%eax),%eax
0x00100ad9:  mov    %eax,-0x10(%ebp)
0x00100adc:  mov    -0xc(%ebp),%eax
0x00100adf:  mov    (%eax),%eax
0x00100ae1:  mov    %eax,-0xc(%ebp)
0x00100ae4:  addl   $0x1,-0x14(%ebp)
0x00100ae8:  cmpl   $0x0,-0xc(%ebp)
0x00100aec:  je     0x100af8

----------------
IN: 
0x00100825:  mov    -0x2c(%ebp),%eax
0x00100828:  mov    %eax,%edx
0x0010082a:  mov    %edx,%eax
0x0010082c:  add    %eax,%eax
0x0010082e:  add    %edx,%eax
0x00100830:  shl    $0x2,%eax
0x00100833:  mov    %eax,%edx
0x00100835:  mov    -0xc(%ebp),%eax
0x00100838:  add    %edx,%eax
0x0010083a:  mov    0x8(%eax),%eax
0x0010083d:  test   %eax,%eax
0x0010083f:  je     0x1007d8

----------------
IN: 
0x001008a6:  mov    0xc(%ebp),%eax
0x001008a9:  mov    0x14(%eax),%eax
0x001008ac:  lea    0x1(%eax),%edx
0x001008af:  mov    0xc(%ebp),%eax
0x001008b2:  mov    %edx,0x14(%eax)
0x001008b5:  mov    -0x2c(%ebp),%eax
0x001008b8:  add    $0x1,%eax
0x001008bb:  mov    %eax,-0x2c(%ebp)
0x001008be:  mov    -0x2c(%ebp),%edx
0x001008c1:  mov    -0x28(%ebp),%eax
0x001008c4:  cmp    %eax,%edx
0x001008c6:  jge    0x1008e5

----------------
IN: 
0x00101170:  mov    0x10ee60,%eax
0x00101175:  lea    0xa0(%eax),%edx
0x0010117b:  mov    0x10ee60,%eax
0x00101180:  sub    $0x4,%esp
0x00101183:  push   $0xf00
0x00101188:  push   %edx
0x00101189:  push   %eax
0x0010118a:  call   0x102df9

----------------
IN: 
0x00102df9:  push   %ebp
0x00102dfa:  mov    %esp,%ebp
0x00102dfc:  push   %edi
0x00102dfd:  push   %esi
0x00102dfe:  push   %ebx
0x00102dff:  sub    $0x30,%esp
0x00102e02:  mov    0x8(%ebp),%eax
0x00102e05:  mov    %eax,-0x10(%ebp)
0x00102e08:  mov    0xc(%ebp),%eax
0x00102e0b:  mov    %eax,-0x14(%ebp)
0x00102e0e:  mov    0x10(%ebp),%eax
0x00102e11:  mov    %eax,-0x18(%ebp)
0x00102e14:  mov    -0x10(%ebp),%eax
0x00102e17:  cmp    -0x14(%ebp),%eax
0x00102e1a:  jae    0x102e5e

----------------
IN: 
0x00102e1c:  mov    -0x10(%ebp),%eax
0x00102e1f:  mov    %eax,-0x1c(%ebp)
0x00102e22:  mov    -0x14(%ebp),%eax
0x00102e25:  mov    %eax,-0x20(%ebp)
0x00102e28:  mov    -0x18(%ebp),%eax
0x00102e2b:  mov    %eax,-0x24(%ebp)
0x00102e2e:  mov    -0x24(%ebp),%eax
0x00102e31:  shr    $0x2,%eax
0x00102e34:  mov    %eax,%ecx
0x00102e36:  mov    -0x1c(%ebp),%edx
0x00102e39:  mov    -0x20(%ebp),%eax
0x00102e3c:  mov    %edx,%edi
0x00102e3e:  mov    %eax,%esi
0x00102e40:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x00102e40:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x00102e42:  mov    -0x24(%ebp),%ecx
0x00102e45:  and    $0x3,%ecx
0x00102e48:  je     0x102e4c

----------------
IN: 
0x00102e4c:  mov    %esi,%eax
0x00102e4e:  mov    %edi,%edx
0x00102e50:  mov    %ecx,-0x28(%ebp)
0x00102e53:  mov    %edx,-0x2c(%ebp)
0x00102e56:  mov    %eax,-0x30(%ebp)
0x00102e59:  mov    -0x1c(%ebp),%eax
0x00102e5c:  jmp    0x102e94

----------------
IN: 
0x00102e94:  add    $0x30,%esp
0x00102e97:  pop    %ebx
0x00102e98:  pop    %esi
0x00102e99:  pop    %edi
0x00102e9a:  pop    %ebp
0x00102e9b:  ret    

----------------
IN: 
0x0010118f:  add    $0x10,%esp
0x00101192:  movl   $0x780,-0xc(%ebp)
0x00101199:  jmp    0x1011b0

----------------
IN: 
0x001011b0:  cmpl   $0x7cf,-0xc(%ebp)
0x001011b7:  jle    0x10119b

----------------
IN: 
0x0010119b:  mov    0x10ee60,%eax
0x001011a0:  mov    -0xc(%ebp),%edx
0x001011a3:  add    %edx,%edx
0x001011a5:  add    %edx,%eax
0x001011a7:  movw   $0x720,(%eax)
0x001011ac:  addl   $0x1,-0xc(%ebp)
0x001011b0:  cmpl   $0x7cf,-0xc(%ebp)
0x001011b7:  jle    0x10119b

----------------
IN: 
0x001011b9:  movzwl 0x10ee64,%eax
0x001011c0:  sub    $0x50,%eax
0x001011c3:  mov    %ax,0x10ee64
0x001011c9:  movzwl 0x10ee66,%eax
0x001011d0:  movzwl %ax,%eax
0x001011d3:  mov    %ax,-0xe(%ebp)
0x001011d7:  movb   $0xe,-0x18(%ebp)
0x001011db:  movzbl -0x18(%ebp),%eax
0x001011df:  movzwl -0xe(%ebp),%edx
0x001011e3:  out    %al,(%dx)
0x001011e4:  movzwl 0x10ee64,%eax
0x001011eb:  shr    $0x8,%ax
0x001011ef:  movzbl %al,%eax
0x001011f2:  movzwl 0x10ee66,%edx
0x001011f9:  add    $0x1,%edx
0x001011fc:  movzwl %dx,%edx
0x001011ff:  mov    %dx,-0x10(%ebp)
0x00101203:  mov    %al,-0x17(%ebp)
0x00101206:  movzbl -0x17(%ebp),%eax
0x0010120a:  movzwl -0x10(%ebp),%edx
0x0010120e:  out    %al,(%dx)
0x0010120f:  movzwl 0x10ee66,%eax
0x00101216:  movzwl %ax,%eax
0x00101219:  mov    %ax,-0x12(%ebp)
0x0010121d:  movb   $0xf,-0x16(%ebp)
0x00101221:  movzbl -0x16(%ebp),%eax
0x00101225:  movzwl -0x12(%ebp),%edx
0x00101229:  out    %al,(%dx)
0x0010122a:  movzwl 0x10ee64,%eax
0x00101231:  movzbl %al,%eax
0x00101234:  movzwl 0x10ee66,%edx
0x0010123b:  add    $0x1,%edx
0x0010123e:  movzwl %dx,%edx
0x00101241:  mov    %dx,-0x14(%ebp)
0x00101245:  mov    %al,-0x15(%ebp)
0x00101248:  movzbl -0x15(%ebp),%eax
0x0010124c:  movzwl -0x14(%ebp),%edx
0x00101250:  out    %al,(%dx)
0x00101251:  nop    
0x00101252:  mov    -0x4(%ebp),%ebx
0x00101255:  leave  
0x00101256:  ret    

----------------
IN: 
0x00100698:  mov    $0xffffffff,%eax
0x0010069d:  jmp    0x1008ea

----------------
IN: 
0x001008ea:  leave  
0x001008eb:  ret    

----------------
IN: 
0x001009a8:  sub    $0x8,%esp
0x001009ab:  pushl  0x8(%ebp)
0x001009ae:  push   $0x103706
0x001009b3:  call   0x10024d

----------------
IN: 
0x001009b8:  add    $0x10,%esp
0x001009bb:  jmp    0x100a22

----------------
IN: 
0x00100a22:  nop    
0x00100a23:  leave  
0x00100a24:  ret    

----------------
IN: 
0x00100af8:  nop    
0x00100af9:  leave  
0x00100afa:  ret    

----------------
IN: 
0x00100d4c:  mov    $0x0,%eax
0x00100d51:  leave  
0x00100d52:  ret    

----------------
IN: 
0x00100084:  add    $0x10,%esp
0x00100087:  nop    
0x00100088:  leave  
0x00100089:  ret    

----------------
IN: 
0x001000a6:  add    $0x10,%esp
0x001000a9:  nop    
0x001000aa:  mov    -0x4(%ebp),%ebx
0x001000ad:  leave  
0x001000ae:  ret    

----------------
IN: 
0x001000c3:  add    $0x10,%esp
0x001000c6:  nop    
0x001000c7:  leave  
0x001000c8:  ret    

----------------
IN: 
0x001000e4:  add    $0x10,%esp
0x001000e7:  nop    
0x001000e8:  leave  
0x001000e9:  ret    

----------------
IN: 
0x00100050:  call   0x102a7d

----------------
IN: 
0x00102a7d:  push   %ebp
0x00102a7e:  mov    %esp,%ebp
0x00102a80:  call   0x10297b

----------------
IN: 
0x0010297b:  push   %ebp
0x0010297c:  mov    %esp,%ebp
0x0010297e:  sub    $0x10,%esp
0x00102981:  mov    $0x10f980,%eax
0x00102986:  add    $0x400,%eax
0x0010298b:  mov    %eax,0x10f8a4
0x00102990:  movw   $0x10,0x10f8a8
0x00102999:  movw   $0x68,0x10ea08
0x001029a2:  mov    $0x10f8a0,%eax
0x001029a7:  mov    %ax,0x10ea0a
0x001029ad:  mov    $0x10f8a0,%eax
0x001029b2:  shr    $0x10,%eax
0x001029b5:  mov    %al,0x10ea0c
0x001029ba:  movzbl 0x10ea0d,%eax
0x001029c1:  and    $0xfffffff0,%eax
0x001029c4:  or     $0x9,%eax
0x001029c7:  mov    %al,0x10ea0d
0x001029cc:  movzbl 0x10ea0d,%eax
0x001029d3:  or     $0x10,%eax
0x001029d6:  mov    %al,0x10ea0d
0x001029db:  movzbl 0x10ea0d,%eax
0x001029e2:  and    $0xffffff9f,%eax
0x001029e5:  mov    %al,0x10ea0d
0x001029ea:  movzbl 0x10ea0d,%eax
0x001029f1:  or     $0xffffff80,%eax
0x001029f4:  mov    %al,0x10ea0d
0x001029f9:  movzbl 0x10ea0e,%eax
0x00102a00:  and    $0xfffffff0,%eax
0x00102a03:  mov    %al,0x10ea0e
0x00102a08:  movzbl 0x10ea0e,%eax
0x00102a0f:  and    $0xffffffef,%eax
0x00102a12:  mov    %al,0x10ea0e
0x00102a17:  movzbl 0x10ea0e,%eax
0x00102a1e:  and    $0xffffffdf,%eax
0x00102a21:  mov    %al,0x10ea0e
0x00102a26:  movzbl 0x10ea0e,%eax
0x00102a2d:  or     $0x40,%eax
0x00102a30:  mov    %al,0x10ea0e
0x00102a35:  movzbl 0x10ea0e,%eax
0x00102a3c:  and    $0x7f,%eax
0x00102a3f:  mov    %al,0x10ea0e
0x00102a44:  mov    $0x10f8a0,%eax
0x00102a49:  shr    $0x18,%eax
0x00102a4c:  mov    %al,0x10ea0f
0x00102a51:  movzbl 0x10ea0d,%eax
0x00102a58:  and    $0xffffffef,%eax
0x00102a5b:  mov    %al,0x10ea0d
0x00102a60:  push   $0x10ea10
0x00102a65:  call   0x102945

----------------
IN: 
0x00102945:  push   %ebp
0x00102946:  mov    %esp,%ebp
0x00102948:  mov    0x8(%ebp),%eax
0x0010294b:  lgdtl  (%eax)
0x0010294e:  mov    $0x23,%eax
0x00102953:  mov    %eax,%gs
0x00102955:  mov    $0x23,%eax
0x0010295a:  mov    %eax,%fs
0x0010295c:  mov    $0x10,%eax
0x00102961:  mov    %eax,%es

----------------
IN: 
0x00102963:  mov    $0x10,%eax
0x00102968:  mov    %eax,%ds

----------------
IN: 
0x0010296a:  mov    $0x10,%eax
0x0010296f:  mov    %eax,%ss

----------------
IN: 
0x00102971:  ljmp   $0x8,$0x102978

----------------
IN: 
0x00102978:  nop    
0x00102979:  pop    %ebp
0x0010297a:  ret    

----------------
IN: 
0x00102a6a:  add    $0x4,%esp
0x00102a6d:  movw   $0x28,-0x2(%ebp)
0x00102a73:  movzwl -0x2(%ebp),%eax
0x00102a77:  ltr    %ax
0x00102a7a:  nop    
0x00102a7b:  leave  
0x00102a7c:  ret    

----------------
IN: 
0x00102a85:  nop    
0x00102a86:  pop    %ebp
0x00102a87:  ret    

----------------
IN: 
0x00100055:  call   0x1016b1

----------------
IN: 
0x001016b1:  push   %ebp
0x001016b2:  mov    %esp,%ebp
0x001016b4:  sub    $0x30,%esp
0x001016b7:  movl   $0x1,0x10f08c
0x001016c1:  movw   $0x21,-0x2(%ebp)
0x001016c7:  movb   $0xff,-0x2a(%ebp)
0x001016cb:  movzbl -0x2a(%ebp),%eax
0x001016cf:  movzwl -0x2(%ebp),%edx
0x001016d3:  out    %al,(%dx)
0x001016d4:  movw   $0xa1,-0x4(%ebp)
0x001016da:  movb   $0xff,-0x29(%ebp)
0x001016de:  movzbl -0x29(%ebp),%eax
0x001016e2:  movzwl -0x4(%ebp),%edx
0x001016e6:  out    %al,(%dx)
0x001016e7:  movw   $0x20,-0x6(%ebp)
0x001016ed:  movb   $0x11,-0x28(%ebp)
0x001016f1:  movzbl -0x28(%ebp),%eax
0x001016f5:  movzwl -0x6(%ebp),%edx
0x001016f9:  out    %al,(%dx)
0x001016fa:  movw   $0x21,-0x8(%ebp)
0x00101700:  movb   $0x20,-0x27(%ebp)
0x00101704:  movzbl -0x27(%ebp),%eax
0x00101708:  movzwl -0x8(%ebp),%edx
0x0010170c:  out    %al,(%dx)
0x0010170d:  movw   $0x21,-0xa(%ebp)
0x00101713:  movb   $0x4,-0x26(%ebp)
0x00101717:  movzbl -0x26(%ebp),%eax
0x0010171b:  movzwl -0xa(%ebp),%edx
0x0010171f:  out    %al,(%dx)
0x00101720:  movw   $0x21,-0xc(%ebp)
0x00101726:  movb   $0x3,-0x25(%ebp)
0x0010172a:  movzbl -0x25(%ebp),%eax
0x0010172e:  movzwl -0xc(%ebp),%edx
0x00101732:  out    %al,(%dx)
0x00101733:  movw   $0xa0,-0xe(%ebp)
0x00101739:  movb   $0x11,-0x24(%ebp)
0x0010173d:  movzbl -0x24(%ebp),%eax
0x00101741:  movzwl -0xe(%ebp),%edx
0x00101745:  out    %al,(%dx)
0x00101746:  movw   $0xa1,-0x10(%ebp)
0x0010174c:  movb   $0x28,-0x23(%ebp)
0x00101750:  movzbl -0x23(%ebp),%eax
0x00101754:  movzwl -0x10(%ebp),%edx
0x00101758:  out    %al,(%dx)
0x00101759:  movw   $0xa1,-0x12(%ebp)
0x0010175f:  movb   $0x2,-0x22(%ebp)
0x00101763:  movzbl -0x22(%ebp),%eax
0x00101767:  movzwl -0x12(%ebp),%edx
0x0010176b:  out    %al,(%dx)
0x0010176c:  movw   $0xa1,-0x14(%ebp)
0x00101772:  movb   $0x3,-0x21(%ebp)
0x00101776:  movzbl -0x21(%ebp),%eax
0x0010177a:  movzwl -0x14(%ebp),%edx
0x0010177e:  out    %al,(%dx)
0x0010177f:  movw   $0x20,-0x16(%ebp)
0x00101785:  movb   $0x68,-0x20(%ebp)
0x00101789:  movzbl -0x20(%ebp),%eax
0x0010178d:  movzwl -0x16(%ebp),%edx
0x00101791:  out    %al,(%dx)
0x00101792:  movw   $0x20,-0x18(%ebp)
0x00101798:  movb   $0xa,-0x1f(%ebp)
0x0010179c:  movzbl -0x1f(%ebp),%eax
0x001017a0:  movzwl -0x18(%ebp),%edx
0x001017a4:  out    %al,(%dx)
0x001017a5:  movw   $0xa0,-0x1a(%ebp)
0x001017ab:  movb   $0x68,-0x1e(%ebp)
0x001017af:  movzbl -0x1e(%ebp),%eax
0x001017b3:  movzwl -0x1a(%ebp),%edx
0x001017b7:  out    %al,(%dx)
0x001017b8:  movw   $0xa0,-0x1c(%ebp)
0x001017be:  movb   $0xa,-0x1d(%ebp)

----------------
IN: 
0x001017c2:  movzbl -0x1d(%ebp),%eax
0x001017c6:  movzwl -0x1c(%ebp),%edx
0x001017ca:  out    %al,(%dx)
0x001017cb:  movzwl 0x10e550,%eax
0x001017d2:  cmp    $0xffffffff,%ax
0x001017d6:  je     0x1017eb

----------------
IN: 
0x001017d8:  movzwl 0x10e550,%eax
0x001017df:  movzwl %ax,%eax
0x001017e2:  push   %eax
0x001017e3:  call   0x10162b

----------------
IN: 
0x0010164b:  movzwl -0x14(%ebp),%eax
0x0010164f:  movzbl %al,%eax
0x00101652:  movw   $0x21,-0x2(%ebp)
0x00101658:  mov    %al,-0x6(%ebp)
0x0010165b:  movzbl -0x6(%ebp),%eax
0x0010165f:  movzwl -0x2(%ebp),%edx
0x00101663:  out    %al,(%dx)
0x00101664:  movzwl -0x14(%ebp),%eax
0x00101668:  shr    $0x8,%ax
0x0010166c:  movzbl %al,%eax
0x0010166f:  movw   $0xa1,-0x4(%ebp)
0x00101675:  mov    %al,-0x5(%ebp)
0x00101678:  movzbl -0x5(%ebp),%eax
0x0010167c:  movzwl -0x4(%ebp),%edx
0x00101680:  out    %al,(%dx)
0x00101681:  nop    
0x00101682:  leave  
0x00101683:  ret    

----------------
IN: 
0x001017e8:  add    $0x4,%esp
0x001017eb:  nop    
0x001017ec:  leave  
0x001017ed:  ret    

----------------
IN: 
0x0010005a:  call   0x101817

----------------
IN: 
0x00101817:  push   %ebp
0x00101818:  mov    %esp,%ebp
0x0010181a:  sub    $0x10,%esp
0x0010181d:  movl   $0x0,-0x4(%ebp)
0x00101824:  jmp    0x1018ec

----------------
IN: 
0x001018ec:  mov    -0x4(%ebp),%eax
0x001018ef:  cmp    $0xff,%eax
0x001018f4:  jbe    0x101829

----------------
IN: 
0x00101829:  mov    -0x4(%ebp),%eax
0x0010182c:  mov    0x10e5e0(,%eax,4),%eax
0x00101833:  mov    %eax,%edx
0x00101835:  mov    -0x4(%ebp),%eax
0x00101838:  mov    %dx,0x10f0a0(,%eax,8)
0x00101840:  mov    -0x4(%ebp),%eax
0x00101843:  movw   $0x8,0x10f0a2(,%eax,8)
0x0010184d:  mov    -0x4(%ebp),%eax
0x00101850:  movzbl 0x10f0a4(,%eax,8),%edx
0x00101858:  and    $0xffffffe0,%edx
0x0010185b:  mov    %dl,0x10f0a4(,%eax,8)
0x00101862:  mov    -0x4(%ebp),%eax
0x00101865:  movzbl 0x10f0a4(,%eax,8),%edx
0x0010186d:  and    $0x1f,%edx
0x00101870:  mov    %dl,0x10f0a4(,%eax,8)
0x00101877:  mov    -0x4(%ebp),%eax
0x0010187a:  movzbl 0x10f0a5(,%eax,8),%edx
0x00101882:  and    $0xfffffff0,%edx
0x00101885:  or     $0xe,%edx
0x00101888:  mov    %dl,0x10f0a5(,%eax,8)
0x0010188f:  mov    -0x4(%ebp),%eax
0x00101892:  movzbl 0x10f0a5(,%eax,8),%edx
0x0010189a:  and    $0xffffffef,%edx
0x0010189d:  mov    %dl,0x10f0a5(,%eax,8)
0x001018a4:  mov    -0x4(%ebp),%eax
0x001018a7:  movzbl 0x10f0a5(,%eax,8),%edx
0x001018af:  and    $0xffffff9f,%edx
0x001018b2:  mov    %dl,0x10f0a5(,%eax,8)
0x001018b9:  mov    -0x4(%ebp),%eax
0x001018bc:  movzbl 0x10f0a5(,%eax,8),%edx
0x001018c4:  or     $0xffffff80,%edx
0x001018c7:  mov    %dl,0x10f0a5(,%eax,8)
0x001018ce:  mov    -0x4(%ebp),%eax
0x001018d1:  mov    0x10e5e0(,%eax,4),%eax
0x001018d8:  shr    $0x10,%eax
0x001018db:  mov    %eax,%edx
0x001018dd:  mov    -0x4(%ebp),%eax
0x001018e0:  mov    %dx,0x10f0a6(,%eax,8)
0x001018e8:  addl   $0x1,-0x4(%ebp)
0x001018ec:  mov    -0x4(%ebp),%eax
0x001018ef:  cmp    $0xff,%eax
0x001018f4:  jbe    0x101829

----------------
IN: 
0x001018fa:  mov    0x10e7c4,%eax
0x001018ff:  mov    %ax,0x10f468
0x00101905:  movw   $0x8,0x10f46a
0x0010190e:  movzbl 0x10f46c,%eax
0x00101915:  and    $0xffffffe0,%eax
0x00101918:  mov    %al,0x10f46c
0x0010191d:  movzbl 0x10f46c,%eax
0x00101924:  and    $0x1f,%eax
0x00101927:  mov    %al,0x10f46c
0x0010192c:  movzbl 0x10f46d,%eax
0x00101933:  and    $0xfffffff0,%eax
0x00101936:  or     $0xe,%eax
0x00101939:  mov    %al,0x10f46d
0x0010193e:  movzbl 0x10f46d,%eax
0x00101945:  and    $0xffffffef,%eax
0x00101948:  mov    %al,0x10f46d
0x0010194d:  movzbl 0x10f46d,%eax
0x00101954:  or     $0x60,%eax
0x00101957:  mov    %al,0x10f46d
0x0010195c:  movzbl 0x10f46d,%eax
0x00101963:  or     $0xffffff80,%eax
0x00101966:  mov    %al,0x10f46d
0x0010196b:  mov    0x10e7c4,%eax
0x00101970:  shr    $0x10,%eax
0x00101973:  mov    %ax,0x10f46e
0x00101979:  movl   $0x10e560,-0x8(%ebp)
0x00101980:  mov    -0x8(%ebp),%eax
0x00101983:  lidtl  (%eax)
0x00101986:  nop    
0x00101987:  leave  
0x00101988:  ret    

----------------
IN: 
0x0010005f:  call   0x100d53

----------------
IN: 
0x00100d53:  push   %ebp
0x00100d54:  mov    %esp,%ebp
0x00100d56:  sub    $0x18,%esp
0x00100d59:  movw   $0x43,-0xa(%ebp)
0x00100d5f:  movb   $0x34,-0x11(%ebp)
0x00100d63:  movzbl -0x11(%ebp),%eax
0x00100d67:  movzwl -0xa(%ebp),%edx
0x00100d6b:  out    %al,(%dx)
0x00100d6c:  movw   $0x40,-0xc(%ebp)
0x00100d72:  movb   $0x9c,-0x10(%ebp)
0x00100d76:  movzbl -0x10(%ebp),%eax
0x00100d7a:  movzwl -0xc(%ebp),%edx
0x00100d7e:  out    %al,(%dx)
0x00100d7f:  movw   $0x40,-0xe(%ebp)
0x00100d85:  movb   $0x2e,-0xf(%ebp)
0x00100d89:  movzbl -0xf(%ebp),%eax
0x00100d8d:  movzwl -0xe(%ebp),%edx
0x00100d91:  out    %al,(%dx)
0x00100d92:  movl   $0x0,0x10f908
0x00100d9c:  sub    $0xc,%esp
0x00100d9f:  push   $0x103872
0x00100da4:  call   0x10024d

----------------
IN: 
0x00100da9:  add    $0x10,%esp
0x00100dac:  sub    $0xc,%esp
0x00100daf:  push   $0x0
0x00100db1:  call   0x101684

----------------
IN: 
0x00100db6:  add    $0x10,%esp
0x00100db9:  nop    
0x00100dba:  leave  
0x00100dbb:  ret    

----------------
IN: 
0x00100064:  call   0x1017ee

----------------
IN: 
0x001017ee:  push   %ebp
0x001017ef:  mov    %esp,%ebp
0x001017f1:  sti    

----------------
IN: 
0x001017f2:  nop    

----------------
IN: 
0x001017f3:  pop    %ebp
0x001017f4:  ret    

----------------
IN: 
0x00100069:  call   0x1001be

----------------
IN: 
0x001001be:  push   %ebp
0x001001bf:  mov    %esp,%ebp
0x001001c1:  sub    $0x8,%esp
0x001001c4:  call   0x1000ea

----------------
IN: 
0x001000ea:  push   %ebp
0x001000eb:  mov    %esp,%ebp
0x001000ed:  sub    $0x18,%esp
0x001000f0:  mov    %cs,-0xa(%ebp)
0x001000f3:  mov    %ds,-0xc(%ebp)
0x001000f6:  mov    %es,-0xe(%ebp)
0x001000f9:  mov    %ss,-0x10(%ebp)
0x001000fc:  movzwl -0xa(%ebp),%eax
0x00100100:  movzwl %ax,%eax
0x00100103:  and    $0x3,%eax
0x00100106:  mov    %eax,%edx
0x00100108:  mov    0x10ea20,%eax
0x0010010d:  sub    $0x4,%esp
0x00100110:  push   %edx
0x00100111:  push   %eax
0x00100112:  push   $0x103581
0x00100117:  call   0x10024d

----------------
IN: 
0x0010011c:  add    $0x10,%esp
0x0010011f:  movzwl -0xa(%ebp),%eax
0x00100123:  movzwl %ax,%edx
0x00100126:  mov    0x10ea20,%eax
0x0010012b:  sub    $0x4,%esp
0x0010012e:  push   %edx
0x0010012f:  push   %eax
0x00100130:  push   $0x10358f
0x00100135:  call   0x10024d

----------------
IN: 
0x0010013a:  add    $0x10,%esp
0x0010013d:  movzwl -0xc(%ebp),%eax
0x00100141:  movzwl %ax,%edx
0x00100144:  mov    0x10ea20,%eax
0x00100149:  sub    $0x4,%esp
0x0010014c:  push   %edx
0x0010014d:  push   %eax
0x0010014e:  push   $0x10359d
0x00100153:  call   0x10024d

----------------
IN: 
0x00100158:  add    $0x10,%esp
0x0010015b:  movzwl -0xe(%ebp),%eax
0x0010015f:  movzwl %ax,%edx
0x00100162:  mov    0x10ea20,%eax
0x00100167:  sub    $0x4,%esp
0x0010016a:  push   %edx
0x0010016b:  push   %eax
0x0010016c:  push   $0x1035ab
0x00100171:  call   0x10024d

----------------
IN: 
0x00100176:  add    $0x10,%esp
0x00100179:  movzwl -0x10(%ebp),%eax
0x0010017d:  movzwl %ax,%edx
0x00100180:  mov    0x10ea20,%eax
0x00100185:  sub    $0x4,%esp
0x00100188:  push   %edx
0x00100189:  push   %eax
0x0010018a:  push   $0x1035b9
0x0010018f:  call   0x10024d

Servicing hardware INT=0x20
----------------
IN: 
0x00101fc3:  push   $0x0
0x00101fc5:  push   $0x20
0x00101fc7:  jmp    0x102923

----------------
IN: 
0x00102923:  push   %ds
0x00102924:  push   %es
0x00102925:  push   %fs
0x00102927:  push   %gs
0x00102929:  pusha  
0x0010292a:  mov    $0x10,%eax
0x0010292f:  mov    %eax,%ds

----------------
IN: 
0x00102931:  mov    %eax,%es

----------------
IN: 
0x00102933:  push   %esp
0x00102934:  call   0x101e9c

----------------
IN: 
0x00101e9c:  push   %ebp
0x00101e9d:  mov    %esp,%ebp
0x00101e9f:  sub    $0x8,%esp
0x00101ea2:  sub    $0xc,%esp
0x00101ea5:  pushl  0x8(%ebp)
0x00101ea8:  call   0x101c6d

----------------
IN: 
0x00101c6d:  push   %ebp
0x00101c6e:  mov    %esp,%ebp
0x00101c70:  push   %edi
0x00101c71:  push   %esi
0x00101c72:  push   %ebx
0x00101c73:  sub    $0x1c,%esp
0x00101c76:  mov    0x8(%ebp),%eax
0x00101c79:  mov    0x30(%eax),%eax
0x00101c7c:  cmp    $0x2f,%eax
0x00101c7f:  ja     0x101ca2

----------------
IN: 
0x00101c81:  cmp    $0x2e,%eax
0x00101c84:  jae    0x101e89

----------------
IN: 
0x00101c8a:  cmp    $0x21,%eax
0x00101c8d:  je     0x101d1a

----------------
IN: 
0x00101c93:  cmp    $0x24,%eax
0x00101c96:  je     0x101cf3

----------------
IN: 
0x00101c98:  cmp    $0x20,%eax
0x00101c9b:  je     0x101cb9

----------------
IN: 
0x00101cb9:  mov    0x10f908,%eax
0x00101cbe:  add    $0x1,%eax
0x00101cc1:  mov    %eax,0x10f908
0x00101cc6:  mov    0x10f908,%ecx
0x00101ccc:  mov    $0x51eb851f,%edx
0x00101cd1:  mov    %ecx,%eax
0x00101cd3:  mul    %edx
0x00101cd5:  mov    %edx,%eax
0x00101cd7:  shr    $0x5,%eax
0x00101cda:  imul   $0x64,%eax,%eax
0x00101cdd:  sub    %eax,%ecx
0x00101cdf:  mov    %ecx,%eax
0x00101ce1:  test   %eax,%eax
0x00101ce3:  jne    0x101e8c

----------------
IN: 
0x00101e8c:  nop    
0x00101e8d:  jmp    0x101e93

----------------
IN: 
0x00101e93:  nop    
0x00101e94:  lea    -0xc(%ebp),%esp
0x00101e97:  pop    %ebx
0x00101e98:  pop    %esi
0x00101e99:  pop    %edi
0x00101e9a:  pop    %ebp
0x00101e9b:  ret    

----------------
IN: 
0x00101ead:  add    $0x10,%esp
0x00101eb0:  nop    
0x00101eb1:  leave  
0x00101eb2:  ret    

----------------
IN: 
0x00102939:  pop    %esp
0x0010293a:  popa   
0x0010293b:  pop    %gs
0x0010293d:  pop    %fs
0x0010293f:  pop    %es

----------------
IN: 
0x00102940:  pop    %ds

----------------
IN: 
0x00102941:  add    $0x8,%esp
0x00102944:  iret   

----------------
IN: 
0x00100194:  add    $0x10,%esp
0x00100197:  mov    0x10ea20,%eax
0x0010019c:  add    $0x1,%eax
0x0010019f:  mov    %eax,0x10ea20
0x001001a4:  nop    
0x001001a5:  leave  
0x001001a6:  ret    

----------------
IN: 
0x001001c9:  sub    $0xc,%esp
0x001001cc:  push   $0x1035c8
0x001001d1:  call   0x10024d

----------------
IN: 
0x001001d6:  add    $0x10,%esp
0x001001d9:  call   0x1001a7

----------------
IN: 
0x001001a7:  push   %ebp
0x001001a8:  mov    %esp,%ebp
0x001001aa:  sub    $0x8,%esp
0x001001ad:  int    $0x78

----------------
IN: 
0x001022db:  push   $0x0
0x001022dd:  push   $0x78
0x001022df:  jmp    0x102923

----------------
IN: 
0x00101ca2:  cmp    $0x78,%eax
0x00101ca5:  je     0x101d41

----------------
IN: 
0x00101d41:  mov    0x8(%ebp),%eax
0x00101d44:  movzwl 0x3c(%eax),%eax
0x00101d48:  cmp    $0x1b,%ax
0x00101d4c:  je     0x101e8f

----------------
IN: 
0x00101d52:  mov    0x8(%ebp),%edx
0x00101d55:  mov    $0x10f920,%eax
0x00101d5a:  mov    %edx,%ebx
0x00101d5c:  mov    $0x4c,%edx
0x00101d61:  mov    (%ebx),%ecx
0x00101d63:  mov    %ecx,(%eax)
0x00101d65:  mov    -0x4(%ebx,%edx,1),%ecx
0x00101d69:  mov    %ecx,-0x4(%eax,%edx,1)
0x00101d6d:  lea    0x4(%eax),%edi
0x00101d70:  and    $0xfffffffc,%edi
0x00101d73:  sub    %edi,%eax
0x00101d75:  sub    %eax,%ebx
0x00101d77:  add    %eax,%edx
0x00101d79:  and    $0xfffffffc,%edx
0x00101d7c:  mov    %edx,%eax
0x00101d7e:  shr    $0x2,%eax
0x00101d81:  mov    %ebx,%esi
0x00101d83:  mov    %eax,%ecx
0x00101d85:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x00101d85:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x00101d87:  movw   $0x1b,0x10f95c
0x00101d90:  movw   $0x23,0x10f968
0x00101d99:  movzwl 0x10f968,%eax
0x00101da0:  mov    %ax,0x10f948
0x00101da6:  movzwl 0x10f948,%eax
0x00101dad:  mov    %ax,0x10f94c
0x00101db3:  mov    0x8(%ebp),%eax
0x00101db6:  add    $0x44,%eax
0x00101db9:  mov    %eax,0x10f964
0x00101dbe:  mov    0x10f960,%eax
0x00101dc3:  or     $0x30,%ah
0x00101dc6:  mov    %eax,0x10f960
0x00101dcb:  mov    0x8(%ebp),%eax
0x00101dce:  sub    $0x4,%eax
0x00101dd1:  mov    $0x10f920,%edx
0x00101dd6:  mov    %edx,(%eax)
0x00101dd8:  jmp    0x101e8f

----------------
IN: 
0x00101e8f:  nop    
0x00101e90:  jmp    0x101e93

----------------
IN: 
0x001001af:  mov    %ebp,%esp
0x001001b1:  nop    
0x001001b2:  pop    %ebp
0x001001b3:  ret    

----------------
IN: 
0x001001de:  call   0x1000ea

----------------
IN: 
0x001000ea:  push   %ebp
0x001000eb:  mov    %esp,%ebp
0x001000ed:  sub    $0x18,%esp
0x001000f0:  mov    %cs,-0xa(%ebp)
0x001000f3:  mov    %ds,-0xc(%ebp)
0x001000f6:  mov    %es,-0xe(%ebp)
0x001000f9:  mov    %ss,-0x10(%ebp)
0x001000fc:  movzwl -0xa(%ebp),%eax
0x00100100:  movzwl %ax,%eax
0x00100103:  and    $0x3,%eax
0x00100106:  mov    %eax,%edx
0x00100108:  mov    0x10ea20,%eax
0x0010010d:  sub    $0x4,%esp
0x00100110:  push   %edx
0x00100111:  push   %eax
0x00100112:  push   $0x103581
0x00100117:  call   0x10024d

----------------
IN: 
0x0010024d:  push   %ebp
0x0010024e:  mov    %esp,%ebp
0x00100250:  sub    $0x18,%esp
0x00100253:  lea    0xc(%ebp),%eax
0x00100256:  mov    %eax,-0x10(%ebp)
0x00100259:  mov    -0x10(%ebp),%eax
0x0010025c:  sub    $0x8,%esp
0x0010025f:  push   %eax
0x00100260:  pushl  0x8(%ebp)
0x00100263:  call   0x100224

----------------
IN: 
0x00100224:  push   %ebp
0x00100225:  mov    %esp,%ebp
0x00100227:  sub    $0x18,%esp
0x0010022a:  movl   $0x0,-0xc(%ebp)
0x00100231:  pushl  0xc(%ebp)
0x00100234:  pushl  0x8(%ebp)
0x00100237:  lea    -0xc(%ebp),%eax
0x0010023a:  push   %eax
0x0010023b:  push   $0x100200
0x00100240:  call   0x1030ef

----------------
IN: 
0x001030ef:  push   %ebp
0x001030f0:  mov    %esp,%ebp
0x001030f2:  push   %esi
0x001030f3:  push   %ebx
0x001030f4:  sub    $0x20,%esp
0x001030f7:  jmp    0x103110

----------------
IN: 
0x00103110:  mov    0x10(%ebp),%eax
0x00103113:  lea    0x1(%eax),%edx
0x00103116:  mov    %edx,0x10(%ebp)
0x00103119:  movzbl (%eax),%eax
0x0010311c:  movzbl %al,%ebx
0x0010311f:  cmp    $0x25,%ebx
0x00103122:  jne    0x1030f9

----------------
IN: 
0x00103124:  movb   $0x20,-0x25(%ebp)
0x00103128:  movl   $0xffffffff,-0x1c(%ebp)
0x0010312f:  mov    -0x1c(%ebp),%eax
0x00103132:  mov    %eax,-0x18(%ebp)
0x00103135:  movl   $0x0,-0x24(%ebp)
0x0010313c:  mov    -0x24(%ebp),%eax
0x0010313f:  mov    %eax,-0x20(%ebp)
0x00103142:  mov    0x10(%ebp),%eax
0x00103145:  lea    0x1(%eax),%edx
0x00103148:  mov    %edx,0x10(%ebp)
0x0010314b:  movzbl (%eax),%eax
0x0010314e:  movzbl %al,%ebx
0x00103151:  lea    -0x23(%ebx),%eax
0x00103154:  cmp    $0x55,%eax
0x00103157:  ja     0x103462

----------------
IN: 
0x0010315d:  mov    0x103d14(,%eax,4),%eax
0x00103164:  jmp    *%eax

----------------
IN: 
0x0010333c:  sub    $0x8,%esp
0x0010333f:  pushl  -0x20(%ebp)
0x00103342:  lea    0x14(%ebp),%eax
0x00103345:  push   %eax
0x00103346:  call   0x103084

----------------
IN: 
0x00103084:  push   %ebp
0x00103085:  mov    %esp,%ebp
0x00103087:  cmpl   $0x1,0xc(%ebp)
0x0010308b:  jle    0x1030a1

----------------
IN: 
0x001030a1:  cmpl   $0x0,0xc(%ebp)
0x001030a5:  je     0x1030b9

----------------
IN: 
0x001030b9:  mov    0x8(%ebp),%eax
0x001030bc:  mov    (%eax),%eax
0x001030be:  lea    0x4(%eax),%ecx
0x001030c1:  mov    0x8(%ebp),%edx
0x001030c4:  mov    %ecx,(%edx)
0x001030c6:  mov    (%eax),%eax
0x001030c8:  cltd   
0x001030c9:  pop    %ebp
0x001030ca:  ret    

----------------
IN: 
0x0010334b:  add    $0x10,%esp
0x0010334e:  mov    %eax,-0x10(%ebp)
0x00103351:  mov    %edx,-0xc(%ebp)
0x00103354:  mov    -0x10(%ebp),%eax
0x00103357:  mov    -0xc(%ebp),%edx
0x0010335a:  test   %edx,%edx
0x0010335c:  jns    0x103381

----------------
IN: 
0x00103381:  movl   $0xa,-0x14(%ebp)
0x00103388:  jmp    0x10342c

----------------
IN: 
0x0010342c:  movsbl -0x25(%ebp),%edx
0x00103430:  mov    -0x14(%ebp),%eax
0x00103433:  sub    $0x4,%esp
0x00103436:  push   %edx
0x00103437:  pushl  -0x18(%ebp)
0x0010343a:  push   %eax
0x0010343b:  pushl  -0xc(%ebp)
0x0010343e:  pushl  -0x10(%ebp)
0x00103441:  pushl  0xc(%ebp)
0x00103444:  pushl  0x8(%ebp)
0x00103447:  call   0x102f44

----------------
IN: 
0x00102f44:  push   %ebp
0x00102f45:  mov    %esp,%ebp
0x00102f47:  sub    $0x38,%esp
0x00102f4a:  mov    0x10(%ebp),%eax
0x00102f4d:  mov    %eax,-0x30(%ebp)
0x00102f50:  mov    0x14(%ebp),%eax
0x00102f53:  mov    %eax,-0x2c(%ebp)
0x00102f56:  mov    -0x30(%ebp),%eax
0x00102f59:  mov    -0x2c(%ebp),%edx
0x00102f5c:  mov    %eax,-0x18(%ebp)
0x00102f5f:  mov    %edx,-0x14(%ebp)
0x00102f62:  mov    0x18(%ebp),%eax
0x00102f65:  mov    %eax,-0x1c(%ebp)
0x00102f68:  mov    -0x18(%ebp),%eax
0x00102f6b:  mov    -0x14(%ebp),%edx
0x00102f6e:  mov    %eax,-0x20(%ebp)
0x00102f71:  mov    %edx,-0x10(%ebp)
0x00102f74:  mov    -0x10(%ebp),%eax
0x00102f77:  mov    %eax,-0xc(%ebp)
0x00102f7a:  cmpl   $0x0,-0x10(%ebp)
0x00102f7e:  je     0x102f9c

----------------
IN: 
0x00102f9c:  mov    -0x20(%ebp),%eax
0x00102f9f:  mov    -0xc(%ebp),%edx
0x00102fa2:  divl   -0x1c(%ebp)
0x00102fa5:  mov    %eax,-0x20(%ebp)
0x00102fa8:  mov    %edx,-0x24(%ebp)
0x00102fab:  mov    -0x20(%ebp),%eax
0x00102fae:  mov    -0x10(%ebp),%edx
0x00102fb1:  mov    %eax,-0x18(%ebp)
0x00102fb4:  mov    %edx,-0x14(%ebp)
0x00102fb7:  mov    -0x24(%ebp),%eax
0x00102fba:  mov    %eax,-0x28(%ebp)
0x00102fbd:  mov    0x18(%ebp),%eax
0x00102fc0:  mov    $0x0,%edx
0x00102fc5:  cmp    -0x2c(%ebp),%edx
0x00102fc8:  ja     0x10300b

----------------
IN: 
0x00102fca:  cmp    -0x2c(%ebp),%edx
0x00102fcd:  jb     0x102fd4

----------------
IN: 
0x00102fcf:  cmp    -0x30(%ebp),%eax
0x00102fd2:  ja     0x10300b

----------------
IN: 
0x0010300b:  subl   $0x1,0x1c(%ebp)
0x0010300f:  cmpl   $0x0,0x1c(%ebp)
0x00103013:  jg     0x102ffa

----------------
IN: 
0x00103015:  mov    -0x28(%ebp),%eax
0x00103018:  add    $0x103cf0,%eax
0x0010301d:  movzbl (%eax),%eax
0x00103020:  movsbl %al,%eax
0x00103023:  sub    $0x8,%esp
0x00103026:  pushl  0xc(%ebp)
0x00103029:  push   %eax
0x0010302a:  mov    0x8(%ebp),%eax
0x0010302d:  call   *%eax

----------------
IN: 
0x00100200:  push   %ebp
0x00100201:  mov    %esp,%ebp
0x00100203:  sub    $0x8,%esp
0x00100206:  sub    $0xc,%esp
0x00100209:  pushl  0x8(%ebp)
0x0010020c:  call   0x10159f

----------------
IN: 
0x0010159f:  push   %ebp
0x001015a0:  mov    %esp,%ebp
0x001015a2:  sub    $0x8,%esp
0x001015a5:  pushl  0x8(%ebp)
0x001015a8:  call   0x10104b

----------------
IN: 
0x0010104b:  push   %ebp
0x0010104c:  mov    %esp,%ebp
0x0010104e:  cmpl   $0x8,0x8(%ebp)
0x00101052:  je     0x101061

----------------
IN: 
0x00101054:  pushl  0x8(%ebp)
0x00101057:  call   0x100fd1

----------------
IN: 
0x00100fd1:  push   %ebp
0x00100fd2:  mov    %esp,%ebp
0x00100fd4:  sub    $0x10,%esp
0x00100fd7:  movl   $0x0,-0x4(%ebp)
0x00100fde:  jmp    0x100fe9

----------------
IN: 
0x00100fe9:  movw   $0x379,-0xc(%ebp)
0x00100fef:  movzwl -0xc(%ebp),%eax
0x00100ff3:  mov    %eax,%edx
0x00100ff5:  in     (%dx),%al
0x00100ff6:  mov    %al,-0xd(%ebp)
0x00100ff9:  movzbl -0xd(%ebp),%eax
0x00100ffd:  test   %al,%al
0x00100fff:  js     0x10100a

----------------
IN: 
0x0010100a:  mov    0x8(%ebp),%eax
0x0010100d:  movzbl %al,%eax
0x00101010:  movw   $0x378,-0x8(%ebp)
0x00101016:  mov    %al,-0x10(%ebp)
0x00101019:  movzbl -0x10(%ebp),%eax
0x0010101d:  movzwl -0x8(%ebp),%edx
0x00101021:  out    %al,(%dx)
0x00101022:  movw   $0x37a,-0xa(%ebp)
0x00101028:  movb   $0xd,-0xf(%ebp)
0x0010102c:  movzbl -0xf(%ebp),%eax
0x00101030:  movzwl -0xa(%ebp),%edx
0x00101034:  out    %al,(%dx)
0x00101035:  movw   $0x37a,-0x6(%ebp)
0x0010103b:  movb   $0x8,-0xe(%ebp)
0x0010103f:  movzbl -0xe(%ebp),%eax
0x00101043:  movzwl -0x6(%ebp),%edx
0x00101047:  out    %al,(%dx)
0x00101048:  nop    
0x00101049:  leave  
0x0010104a:  ret    

----------------
IN: 
0x0010105c:  add    $0x4,%esp
0x0010105f:  jmp    0x10107f

----------------
IN: 
0x0010107f:  nop    
0x00101080:  leave  
0x00101081:  ret    

----------------
IN: 
0x001015ad:  add    $0x4,%esp
0x001015b0:  sub    $0xc,%esp
0x001015b3:  pushl  0x8(%ebp)
0x001015b6:  call   0x101082

----------------
IN: 
0x00101082:  push   %ebp
0x00101083:  mov    %esp,%ebp
0x00101085:  push   %ebx
0x00101086:  sub    $0x14,%esp
0x00101089:  mov    0x8(%ebp),%eax
0x0010108c:  mov    $0x0,%al
0x0010108e:  test   %eax,%eax
0x00101090:  jne    0x101099

----------------
IN: 
0x00101092:  orl    $0x700,0x8(%ebp)
0x00101099:  mov    0x8(%ebp),%eax
0x0010109c:  movzbl %al,%eax
0x0010109f:  cmp    $0xa,%eax
0x001010a2:  je     0x1010f2

----------------
IN: 
0x001010a4:  cmp    $0xd,%eax
0x001010a7:  je     0x101102

----------------
IN: 
0x001010a9:  cmp    $0x8,%eax
0x001010ac:  jne    0x10113c

----------------
IN: 
0x0010113c:  mov    0x10ee60,%ecx
0x00101142:  movzwl 0x10ee64,%eax
0x00101149:  lea    0x1(%eax),%edx
0x0010114c:  mov    %dx,0x10ee64
0x00101153:  movzwl %ax,%eax
0x00101156:  add    %eax,%eax
0x00101158:  add    %ecx,%eax
0x0010115a:  mov    0x8(%ebp),%edx
0x0010115d:  mov    %dx,(%eax)
0x00101160:  jmp    0x101163

----------------
IN: 
0x00101163:  movzwl 0x10ee64,%eax
0x0010116a:  cmp    $0x7cf,%ax
0x0010116e:  jbe    0x1011c9

----------------
IN: 
0x001011c9:  movzwl 0x10ee66,%eax
0x001011d0:  movzwl %ax,%eax
0x001011d3:  mov    %ax,-0xe(%ebp)
0x001011d7:  movb   $0xe,-0x18(%ebp)
0x001011db:  movzbl -0x18(%ebp),%eax
0x001011df:  movzwl -0xe(%ebp),%edx
0x001011e3:  out    %al,(%dx)
0x001011e4:  movzwl 0x10ee64,%eax
0x001011eb:  shr    $0x8,%ax
0x001011ef:  movzbl %al,%eax
0x001011f2:  movzwl 0x10ee66,%edx
0x001011f9:  add    $0x1,%edx
0x001011fc:  movzwl %dx,%edx
0x001011ff:  mov    %dx,-0x10(%ebp)
0x00101203:  mov    %al,-0x17(%ebp)
0x00101206:  movzbl -0x17(%ebp),%eax
0x0010120a:  movzwl -0x10(%ebp),%edx
0x0010120e:  out    %al,(%dx)
0x0010120f:  movzwl 0x10ee66,%eax
0x00101216:  movzwl %ax,%eax
0x00101219:  mov    %ax,-0x12(%ebp)
0x0010121d:  movb   $0xf,-0x16(%ebp)
0x00101221:  movzbl -0x16(%ebp),%eax
0x00101225:  movzwl -0x12(%ebp),%edx
0x00101229:  out    %al,(%dx)
0x0010122a:  movzwl 0x10ee64,%eax
0x00101231:  movzbl %al,%eax
0x00101234:  movzwl 0x10ee66,%edx
0x0010123b:  add    $0x1,%edx
0x0010123e:  movzwl %dx,%edx
0x00101241:  mov    %dx,-0x14(%ebp)
0x00101245:  mov    %al,-0x15(%ebp)
0x00101248:  movzbl -0x15(%ebp),%eax
0x0010124c:  movzwl -0x14(%ebp),%edx
0x00101250:  out    %al,(%dx)
0x00101251:  nop    
0x00101252:  mov    -0x4(%ebp),%ebx
0x00101255:  leave  
0x00101256:  ret    

----------------
IN: 
0x001015bb:  add    $0x10,%esp
0x001015be:  sub    $0xc,%esp
0x001015c1:  pushl  0x8(%ebp)
0x001015c4:  call   0x1012b1

----------------
IN: 
0x001012b1:  push   %ebp
0x001012b2:  mov    %esp,%ebp
0x001012b4:  cmpl   $0x8,0x8(%ebp)
0x001012b8:  je     0x1012c7

----------------
IN: 
0x001012ba:  pushl  0x8(%ebp)
0x001012bd:  call   0x101257

----------------
IN: 
0x00101257:  push   %ebp
0x00101258:  mov    %esp,%ebp
0x0010125a:  sub    $0x10,%esp
0x0010125d:  movl   $0x0,-0x4(%ebp)
0x00101264:  jmp    0x10126f

----------------
IN: 
0x0010126f:  movw   $0x3fd,-0x8(%ebp)
0x00101275:  movzwl -0x8(%ebp),%eax
0x00101279:  mov    %eax,%edx
0x0010127b:  in     (%dx),%al
0x0010127c:  mov    %al,-0x9(%ebp)
0x0010127f:  movzbl -0x9(%ebp),%eax
0x00101283:  movzbl %al,%eax
0x00101286:  and    $0x20,%eax
0x00101289:  test   %eax,%eax
0x0010128b:  jne    0x101296

----------------
IN: 
0x00101296:  mov    0x8(%ebp),%eax
0x00101299:  movzbl %al,%eax
0x0010129c:  movw   $0x3f8,-0x6(%ebp)
0x001012a2:  mov    %al,-0xa(%ebp)
0x001012a5:  movzbl -0xa(%ebp),%eax
0x001012a9:  movzwl -0x6(%ebp),%edx
0x001012ad:  out    %al,(%dx)
0x001012ae:  nop    
0x001012af:  leave  
0x001012b0:  ret    

----------------
IN: 
0x001012c2:  add    $0x4,%esp
0x001012c5:  jmp    0x1012e5

----------------
IN: 
0x001012e5:  nop    
0x001012e6:  leave  
0x001012e7:  ret    

----------------
IN: 
0x001015c9:  add    $0x10,%esp
0x001015cc:  nop    
0x001015cd:  leave  
0x001015ce:  ret    

----------------
IN: 
0x00100211:  add    $0x10,%esp
0x00100214:  mov    0xc(%ebp),%eax
0x00100217:  mov    (%eax),%eax
0x00100219:  lea    0x1(%eax),%edx
0x0010021c:  mov    0xc(%ebp),%eax
0x0010021f:  mov    %edx,(%eax)
0x00100221:  nop    
0x00100222:  leave  
0x00100223:  ret    

----------------
IN: 
0x0010302f:  add    $0x10,%esp
0x00103032:  nop    
0x00103033:  leave  
0x00103034:  ret    

----------------
IN: 
0x0010344c:  add    $0x20,%esp
0x0010344f:  jmp    0x10348a

----------------
IN: 
0x0010348a:  jmp    0x1030f7

----------------
IN: 
0x001030f7:  jmp    0x103110

----------------
IN: 
0x001030f9:  test   %ebx,%ebx
0x001030fb:  je     0x10348f

----------------
IN: 
0x00103101:  sub    $0x8,%esp
0x00103104:  pushl  0xc(%ebp)
0x00103107:  push   %ebx
0x00103108:  mov    0x8(%ebp),%eax
0x0010310b:  call   *%eax

----------------
IN: 
0x0010310d:  add    $0x10,%esp
0x00103110:  mov    0x10(%ebp),%eax
0x00103113:  lea    0x1(%eax),%edx
0x00103116:  mov    %edx,0x10(%ebp)
0x00103119:  movzbl (%eax),%eax
0x0010311c:  movzbl %al,%ebx
0x0010311f:  cmp    $0x25,%ebx
0x00103122:  jne    0x1030f9

Servicing hardware INT=0x20
----------------
IN: 
0x00101fc3:  push   $0x0
0x00101fc5:  push   $0x20
0x00101fc7:  jmp    0x102923

----------------
IN: 
0x00102923:  push   %ds
0x00102924:  push   %es
0x00102925:  push   %fs
0x00102927:  push   %gs
0x00102929:  pusha  
0x0010292a:  mov    $0x10,%eax
0x0010292f:  mov    %eax,%ds

----------------
IN: 
0x00102931:  mov    %eax,%es

----------------
IN: 
0x00102933:  push   %esp
0x00102934:  call   0x101e9c

----------------
IN: 
0x00101e9c:  push   %ebp
0x00101e9d:  mov    %esp,%ebp
0x00101e9f:  sub    $0x8,%esp
0x00101ea2:  sub    $0xc,%esp
0x00101ea5:  pushl  0x8(%ebp)
0x00101ea8:  call   0x101c6d

----------------
IN: 
0x00101c6d:  push   %ebp
0x00101c6e:  mov    %esp,%ebp
0x00101c70:  push   %edi
0x00101c71:  push   %esi
0x00101c72:  push   %ebx
0x00101c73:  sub    $0x1c,%esp
0x00101c76:  mov    0x8(%ebp),%eax
0x00101c79:  mov    0x30(%eax),%eax
0x00101c7c:  cmp    $0x2f,%eax
0x00101c7f:  ja     0x101ca2

----------------
IN: 
0x00101c81:  cmp    $0x2e,%eax
0x00101c84:  jae    0x101e89

----------------
IN: 
0x00101c8a:  cmp    $0x21,%eax
0x00101c8d:  je     0x101d1a

----------------
IN: 
0x00101c93:  cmp    $0x24,%eax
0x00101c96:  je     0x101cf3

----------------
IN: 
0x00101c98:  cmp    $0x20,%eax
0x00101c9b:  je     0x101cb9

----------------
IN: 
0x00101cb9:  mov    0x10f908,%eax
0x00101cbe:  add    $0x1,%eax
0x00101cc1:  mov    %eax,0x10f908
0x00101cc6:  mov    0x10f908,%ecx
0x00101ccc:  mov    $0x51eb851f,%edx
0x00101cd1:  mov    %ecx,%eax
0x00101cd3:  mul    %edx
0x00101cd5:  mov    %edx,%eax
0x00101cd7:  shr    $0x5,%eax
0x00101cda:  imul   $0x64,%eax,%eax
0x00101cdd:  sub    %eax,%ecx
0x00101cdf:  mov    %ecx,%eax
0x00101ce1:  test   %eax,%eax
0x00101ce3:  jne    0x101e8c

----------------
IN: 
0x00101e8c:  nop    
0x00101e8d:  jmp    0x101e93

----------------
IN: 
0x00101e93:  nop    
0x00101e94:  lea    -0xc(%ebp),%esp
0x00101e97:  pop    %ebx
0x00101e98:  pop    %esi
0x00101e99:  pop    %edi
0x00101e9a:  pop    %ebp
0x00101e9b:  ret    

----------------
IN: 
0x00101ead:  add    $0x10,%esp
0x00101eb0:  nop    
0x00101eb1:  leave  
0x00101eb2:  ret    

----------------
IN: 
0x00102939:  pop    %esp
0x0010293a:  popa   
0x0010293b:  pop    %gs
0x0010293d:  pop    %fs
0x0010293f:  pop    %es

----------------
IN: 
0x00102940:  pop    %ds

----------------
IN: 
0x00102941:  add    $0x8,%esp
0x00102944:  iret   

----------------
IN: 
0x001010f2:  movzwl 0x10ee64,%eax
0x001010f9:  add    $0x50,%eax
0x001010fc:  mov    %ax,0x10ee64
0x00101102:  movzwl 0x10ee64,%ebx
0x00101109:  movzwl 0x10ee64,%ecx
0x00101110:  movzwl %cx,%eax
0x00101113:  imul   $0xcccd,%eax,%eax
0x00101119:  shr    $0x10,%eax
0x0010111c:  mov    %eax,%edx
0x0010111e:  shr    $0x6,%dx
0x00101122:  mov    %edx,%eax
0x00101124:  shl    $0x2,%eax
0x00101127:  add    %edx,%eax
0x00101129:  shl    $0x4,%eax
0x0010112c:  sub    %eax,%ecx
0x0010112e:  mov    %ecx,%edx
0x00101130:  mov    %ebx,%eax
0x00101132:  sub    %edx,%eax
0x00101134:  mov    %ax,0x10ee64
0x0010113a:  jmp    0x101163

----------------
IN: 
0x00101170:  mov    0x10ee60,%eax
0x00101175:  lea    0xa0(%eax),%edx
0x0010117b:  mov    0x10ee60,%eax
0x00101180:  sub    $0x4,%esp
0x00101183:  push   $0xf00
0x00101188:  push   %edx
0x00101189:  push   %eax
0x0010118a:  call   0x102df9

----------------
IN: 
0x00102df9:  push   %ebp
0x00102dfa:  mov    %esp,%ebp
0x00102dfc:  push   %edi
0x00102dfd:  push   %esi
0x00102dfe:  push   %ebx
0x00102dff:  sub    $0x30,%esp
0x00102e02:  mov    0x8(%ebp),%eax
0x00102e05:  mov    %eax,-0x10(%ebp)
0x00102e08:  mov    0xc(%ebp),%eax
0x00102e0b:  mov    %eax,-0x14(%ebp)
0x00102e0e:  mov    0x10(%ebp),%eax
0x00102e11:  mov    %eax,-0x18(%ebp)
0x00102e14:  mov    -0x10(%ebp),%eax
0x00102e17:  cmp    -0x14(%ebp),%eax
0x00102e1a:  jae    0x102e5e

----------------
IN: 
0x00102e1c:  mov    -0x10(%ebp),%eax
0x00102e1f:  mov    %eax,-0x1c(%ebp)
0x00102e22:  mov    -0x14(%ebp),%eax
0x00102e25:  mov    %eax,-0x20(%ebp)
0x00102e28:  mov    -0x18(%ebp),%eax
0x00102e2b:  mov    %eax,-0x24(%ebp)
0x00102e2e:  mov    -0x24(%ebp),%eax
0x00102e31:  shr    $0x2,%eax
0x00102e34:  mov    %eax,%ecx
0x00102e36:  mov    -0x1c(%ebp),%edx
0x00102e39:  mov    -0x20(%ebp),%eax
0x00102e3c:  mov    %edx,%edi
0x00102e3e:  mov    %eax,%esi
0x00102e40:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x00102e40:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x00102e42:  mov    -0x24(%ebp),%ecx
0x00102e45:  and    $0x3,%ecx
0x00102e48:  je     0x102e4c

----------------
IN: 
0x00102e4c:  mov    %esi,%eax
0x00102e4e:  mov    %edi,%edx
0x00102e50:  mov    %ecx,-0x28(%ebp)
0x00102e53:  mov    %edx,-0x2c(%ebp)
0x00102e56:  mov    %eax,-0x30(%ebp)
0x00102e59:  mov    -0x1c(%ebp),%eax
0x00102e5c:  jmp    0x102e94

----------------
IN: 
0x00102e94:  add    $0x30,%esp
0x00102e97:  pop    %ebx
0x00102e98:  pop    %esi
0x00102e99:  pop    %edi
0x00102e9a:  pop    %ebp
0x00102e9b:  ret    

----------------
IN: 
0x0010118f:  add    $0x10,%esp
0x00101192:  movl   $0x780,-0xc(%ebp)
0x00101199:  jmp    0x1011b0

----------------
IN: 
0x001011b0:  cmpl   $0x7cf,-0xc(%ebp)
0x001011b7:  jle    0x10119b

----------------
IN: 
0x0010119b:  mov    0x10ee60,%eax
0x001011a0:  mov    -0xc(%ebp),%edx
0x001011a3:  add    %edx,%edx
0x001011a5:  add    %edx,%eax
0x001011a7:  movw   $0x720,(%eax)
0x001011ac:  addl   $0x1,-0xc(%ebp)
0x001011b0:  cmpl   $0x7cf,-0xc(%ebp)
0x001011b7:  jle    0x10119b

----------------
IN: 
0x001011b9:  movzwl 0x10ee64,%eax
0x001011c0:  sub    $0x50,%eax
0x001011c3:  mov    %ax,0x10ee64
0x001011c9:  movzwl 0x10ee66,%eax
0x001011d0:  movzwl %ax,%eax
0x001011d3:  mov    %ax,-0xe(%ebp)
0x001011d7:  movb   $0xe,-0x18(%ebp)
0x001011db:  movzbl -0x18(%ebp),%eax
0x001011df:  movzwl -0xe(%ebp),%edx
0x001011e3:  out    %al,(%dx)
0x001011e4:  movzwl 0x10ee64,%eax
0x001011eb:  shr    $0x8,%ax
0x001011ef:  movzbl %al,%eax
0x001011f2:  movzwl 0x10ee66,%edx
0x001011f9:  add    $0x1,%edx
0x001011fc:  movzwl %dx,%edx
0x001011ff:  mov    %dx,-0x10(%ebp)
0x00101203:  mov    %al,-0x17(%ebp)
0x00101206:  movzbl -0x17(%ebp),%eax
0x0010120a:  movzwl -0x10(%ebp),%edx
0x0010120e:  out    %al,(%dx)
0x0010120f:  movzwl 0x10ee66,%eax
0x00101216:  movzwl %ax,%eax
0x00101219:  mov    %ax,-0x12(%ebp)
0x0010121d:  movb   $0xf,-0x16(%ebp)
0x00101221:  movzbl -0x16(%ebp),%eax
0x00101225:  movzwl -0x12(%ebp),%edx
0x00101229:  out    %al,(%dx)
0x0010122a:  movzwl 0x10ee64,%eax
0x00101231:  movzbl %al,%eax
0x00101234:  movzwl 0x10ee66,%edx
0x0010123b:  add    $0x1,%edx
0x0010123e:  movzwl %dx,%edx
0x00101241:  mov    %dx,-0x14(%ebp)
0x00101245:  mov    %al,-0x15(%ebp)
0x00101248:  movzbl -0x15(%ebp),%eax
0x0010124c:  movzwl -0x14(%ebp),%edx
0x00101250:  out    %al,(%dx)
0x00101251:  nop    
0x00101252:  mov    -0x4(%ebp),%ebx
0x00101255:  leave  
0x00101256:  ret    

----------------
IN: 
0x0010348f:  nop    
0x00103490:  lea    -0x8(%ebp),%esp
0x00103493:  pop    %ebx
0x00103494:  pop    %esi
0x00103495:  pop    %ebp
0x00103496:  ret    

----------------
IN: 
0x00100245:  add    $0x10,%esp
0x00100248:  mov    -0xc(%ebp),%eax
0x0010024b:  leave  
0x0010024c:  ret    

----------------
IN: 
0x00100268:  add    $0x10,%esp
0x0010026b:  mov    %eax,-0xc(%ebp)
0x0010026e:  mov    -0xc(%ebp),%eax
0x00100271:  leave  
0x00100272:  ret    

----------------
IN: 
0x0010011c:  add    $0x10,%esp
0x0010011f:  movzwl -0xa(%ebp),%eax
0x00100123:  movzwl %ax,%edx
0x00100126:  mov    0x10ea20,%eax
0x0010012b:  sub    $0x4,%esp
0x0010012e:  push   %edx
0x0010012f:  push   %eax
0x00100130:  push   $0x10358f
0x00100135:  call   0x10024d

----------------
IN: 
0x0010340d:  sub    $0x8,%esp
0x00103410:  pushl  -0x20(%ebp)
0x00103413:  lea    0x14(%ebp),%eax
0x00103416:  push   %eax
0x00103417:  call   0x103035

----------------
IN: 
0x00103035:  push   %ebp
0x00103036:  mov    %esp,%ebp
0x00103038:  cmpl   $0x1,0xc(%ebp)
0x0010303c:  jle    0x103052

----------------
IN: 
0x00103052:  cmpl   $0x0,0xc(%ebp)
0x00103056:  je     0x10306e

----------------
IN: 
0x0010306e:  mov    0x8(%ebp),%eax
0x00103071:  mov    (%eax),%eax
0x00103073:  lea    0x4(%eax),%ecx
0x00103076:  mov    0x8(%ebp),%edx
0x00103079:  mov    %ecx,(%edx)
0x0010307b:  mov    (%eax),%eax
0x0010307d:  mov    $0x0,%edx
0x00103082:  pop    %ebp
0x00103083:  ret    

----------------
IN: 
0x0010341c:  add    $0x10,%esp
0x0010341f:  mov    %eax,-0x10(%ebp)
0x00103422:  mov    %edx,-0xc(%ebp)
0x00103425:  movl   $0x10,-0x14(%ebp)
0x0010342c:  movsbl -0x25(%ebp),%edx
0x00103430:  mov    -0x14(%ebp),%eax
0x00103433:  sub    $0x4,%esp
0x00103436:  push   %edx
0x00103437:  pushl  -0x18(%ebp)
0x0010343a:  push   %eax
0x0010343b:  pushl  -0xc(%ebp)
0x0010343e:  pushl  -0x10(%ebp)
0x00103441:  pushl  0xc(%ebp)
0x00103444:  pushl  0x8(%ebp)
0x00103447:  call   0x102f44

----------------
IN: 
0x00102fd4:  mov    0x1c(%ebp),%eax
0x00102fd7:  sub    $0x1,%eax
0x00102fda:  sub    $0x4,%esp
0x00102fdd:  pushl  0x20(%ebp)
0x00102fe0:  push   %eax
0x00102fe1:  pushl  0x18(%ebp)
0x00102fe4:  pushl  -0x14(%ebp)
0x00102fe7:  pushl  -0x18(%ebp)
0x00102fea:  pushl  0xc(%ebp)
0x00102fed:  pushl  0x8(%ebp)
0x00102ff0:  call   0x102f44

----------------
IN: 
0x00102ff5:  add    $0x20,%esp
0x00102ff8:  jmp    0x103015

----------------
IN: 
0x0010013a:  add    $0x10,%esp
0x0010013d:  movzwl -0xc(%ebp),%eax
0x00100141:  movzwl %ax,%edx
0x00100144:  mov    0x10ea20,%eax
0x00100149:  sub    $0x4,%esp
0x0010014c:  push   %edx
0x0010014d:  push   %eax
0x0010014e:  push   $0x10359d
0x00100153:  call   0x10024d

Servicing hardware INT=0x20
----------------
IN: 
0x00100158:  add    $0x10,%esp
0x0010015b:  movzwl -0xe(%ebp),%eax
0x0010015f:  movzwl %ax,%edx
0x00100162:  mov    0x10ea20,%eax
0x00100167:  sub    $0x4,%esp
0x0010016a:  push   %edx
0x0010016b:  push   %eax
0x0010016c:  push   $0x1035ab
0x00100171:  call   0x10024d

Servicing hardware INT=0x20
----------------
IN: 
0x00100176:  add    $0x10,%esp
0x00100179:  movzwl -0x10(%ebp),%eax
0x0010017d:  movzwl %ax,%edx
0x00100180:  mov    0x10ea20,%eax
0x00100185:  sub    $0x4,%esp
0x00100188:  push   %edx
0x00100189:  push   %eax
0x0010018a:  push   $0x1035b9
0x0010018f:  call   0x10024d

----------------
IN: 
0x00100194:  add    $0x10,%esp
0x00100197:  mov    0x10ea20,%eax
0x0010019c:  add    $0x1,%eax
0x0010019f:  mov    %eax,0x10ea20
0x001001a4:  nop    
0x001001a5:  leave  
0x001001a6:  ret    

----------------
IN: 
0x001001e3:  sub    $0xc,%esp
0x001001e6:  push   $0x1035e8
0x001001eb:  call   0x10024d

----------------
IN: 
0x001001f0:  add    $0x10,%esp
0x001001f3:  call   0x1001b4

----------------
IN: 
0x001001b4:  push   %ebp
0x001001b5:  mov    %esp,%ebp
0x001001b7:  int    $0x79

----------------
IN: 
0x001022e4:  push   $0x0
0x001022e6:  push   $0x79
0x001022e8:  jmp    0x102923

----------------
IN: 
0x00101ca2:  cmp    $0x78,%eax
0x00101ca5:  je     0x101d41

----------------
IN: 
0x00101cab:  cmp    $0x79,%eax
0x00101cae:  je     0x101ddd

----------------
IN: 
0x00101ddd:  mov    0x8(%ebp),%eax
0x00101de0:  movzwl 0x3c(%eax),%eax
0x00101de4:  cmp    $0x8,%ax
0x00101de8:  je     0x101e92

----------------
IN: 
0x00101dee:  mov    0x8(%ebp),%eax
0x00101df1:  movw   $0x8,0x3c(%eax)
0x00101df7:  mov    0x8(%ebp),%eax
0x00101dfa:  movw   $0x10,0x28(%eax)
0x00101e00:  mov    0x8(%ebp),%eax
0x00101e03:  movzwl 0x28(%eax),%edx
0x00101e07:  mov    0x8(%ebp),%eax
0x00101e0a:  mov    %dx,0x2c(%eax)
0x00101e0e:  mov    0x8(%ebp),%eax
0x00101e11:  mov    0x40(%eax),%eax
0x00101e14:  and    $0xcf,%ah
0x00101e17:  mov    %eax,%edx
0x00101e19:  mov    0x8(%ebp),%eax
0x00101e1c:  mov    %edx,0x40(%eax)
0x00101e1f:  mov    0x8(%ebp),%eax
0x00101e22:  mov    0x44(%eax),%eax
0x00101e25:  sub    $0x44,%eax
0x00101e28:  mov    %eax,0x10f96c
0x00101e2d:  mov    0x10f96c,%eax
0x00101e32:  sub    $0x4,%esp
0x00101e35:  push   $0x44
0x00101e37:  pushl  0x8(%ebp)
0x00101e3a:  push   %eax
0x00101e3b:  call   0x102df9

----------------
IN: 
0x00102df9:  push   %ebp
0x00102dfa:  mov    %esp,%ebp
0x00102dfc:  push   %edi
0x00102dfd:  push   %esi
0x00102dfe:  push   %ebx
0x00102dff:  sub    $0x30,%esp
0x00102e02:  mov    0x8(%ebp),%eax
0x00102e05:  mov    %eax,-0x10(%ebp)
0x00102e08:  mov    0xc(%ebp),%eax
0x00102e0b:  mov    %eax,-0x14(%ebp)
0x00102e0e:  mov    0x10(%ebp),%eax
0x00102e11:  mov    %eax,-0x18(%ebp)
0x00102e14:  mov    -0x10(%ebp),%eax
0x00102e17:  cmp    -0x14(%ebp),%eax
0x00102e1a:  jae    0x102e5e

----------------
IN: 
0x00102e1c:  mov    -0x10(%ebp),%eax
0x00102e1f:  mov    %eax,-0x1c(%ebp)
0x00102e22:  mov    -0x14(%ebp),%eax
0x00102e25:  mov    %eax,-0x20(%ebp)
0x00102e28:  mov    -0x18(%ebp),%eax
0x00102e2b:  mov    %eax,-0x24(%ebp)
0x00102e2e:  mov    -0x24(%ebp),%eax
0x00102e31:  shr    $0x2,%eax
0x00102e34:  mov    %eax,%ecx
0x00102e36:  mov    -0x1c(%ebp),%edx
0x00102e39:  mov    -0x20(%ebp),%eax
0x00102e3c:  mov    %edx,%edi
0x00102e3e:  mov    %eax,%esi
0x00102e40:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x00102e40:  rep movsl %ds:(%esi),%es:(%edi)

----------------
IN: 
0x00102e42:  mov    -0x24(%ebp),%ecx
0x00102e45:  and    $0x3,%ecx
0x00102e48:  je     0x102e4c

----------------
IN: 
0x00102e4c:  mov    %esi,%eax
0x00102e4e:  mov    %edi,%edx
0x00102e50:  mov    %ecx,-0x28(%ebp)
0x00102e53:  mov    %edx,-0x2c(%ebp)
0x00102e56:  mov    %eax,-0x30(%ebp)
0x00102e59:  mov    -0x1c(%ebp),%eax
0x00102e5c:  jmp    0x102e94

----------------
IN: 
0x00102e94:  add    $0x30,%esp
0x00102e97:  pop    %ebx
0x00102e98:  pop    %esi
0x00102e99:  pop    %edi
0x00102e9a:  pop    %ebp
0x00102e9b:  ret    

----------------
IN: 
0x00101e40:  add    $0x10,%esp
0x00101e43:  mov    0x8(%ebp),%eax
0x00101e46:  sub    $0x4,%eax
0x00101e49:  mov    0x10f96c,%edx
0x00101e4f:  mov    %edx,(%eax)
0x00101e51:  jmp    0x101e92

----------------
IN: 
0x00101e92:  nop    
0x00101e93:  nop    
0x00101e94:  lea    -0xc(%ebp),%esp
0x00101e97:  pop    %ebx
0x00101e98:  pop    %esi
0x00101e99:  pop    %edi
0x00101e9a:  pop    %ebp
0x00101e9b:  ret    

----------------
IN: 
0x001001b9:  mov    %ebp,%esp
0x001001bb:  nop    
0x001001bc:  pop    %ebp
0x001001bd:  ret    

----------------
IN: 
0x001001f8:  call   0x1000ea

Servicing hardware INT=0x20
----------------
IN: 
0x001001fd:  nop    
0x001001fe:  leave  
0x001001ff:  ret    

----------------
IN: 
0x0010006e:  jmp    0x10006e

Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
Servicing hardware INT=0x20
----------------
IN: 
0x00101ce9:  call   0x1017fc

----------------
IN: 
0x001017fc:  push   %ebp
0x001017fd:  mov    %esp,%ebp
0x001017ff:  sub    $0x8,%esp
0x00101802:  sub    $0x8,%esp
0x00101805:  push   $0x64
0x00101807:  push   $0x1038c0
0x0010180c:  call   0x10024d

----------------
IN: 
0x00101811:  add    $0x10,%esp
0x00101814:  nop    
0x00101815:  leave  
0x00101816:  ret    

----------------
IN: 
0x00101cee:  jmp    0x101e8c

Servicing hardware INT=0x20
Servicing hardware INT=0x20
