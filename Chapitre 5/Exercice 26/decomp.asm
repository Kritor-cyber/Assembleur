
exo_26:     format de fichier elf32-i386


Déassemblage de la section .init :

00001000 <_init>:
    1000:	53                   	push   ebx
    1001:	83 ec 08             	sub    esp,0x8
    1004:	e8 c7 00 00 00       	call   10d0 <__x86.get_pc_thunk.bx>
    1009:	81 c3 d3 2f 00 00    	add    ebx,0x2fd3
    100f:	8b 83 18 00 00 00    	mov    eax,DWORD PTR [ebx+0x18]
    1015:	85 c0                	test   eax,eax
    1017:	74 02                	je     101b <_init+0x1b>
    1019:	ff d0                	call   eax
    101b:	83 c4 08             	add    esp,0x8
    101e:	5b                   	pop    ebx
    101f:	c3                   	ret

Déassemblage de la section .plt :

00001020 <__libc_start_main@plt-0x10>:
    1020:	ff b3 04 00 00 00    	push   DWORD PTR [ebx+0x4]
    1026:	ff a3 08 00 00 00    	jmp    DWORD PTR [ebx+0x8]
    102c:	00 00                	add    BYTE PTR [eax],al
	...

00001030 <__libc_start_main@plt>:
    1030:	ff a3 0c 00 00 00    	jmp    DWORD PTR [ebx+0xc]
    1036:	68 00 00 00 00       	push   0x0
    103b:	e9 e0 ff ff ff       	jmp    1020 <_init+0x20>

Déassemblage de la section .plt.got :

00001040 <__cxa_finalize@plt>:
    1040:	ff a3 14 00 00 00    	jmp    DWORD PTR [ebx+0x14]
    1046:	66 90                	xchg   ax,ax

Déassemblage de la section .text :

00001050 <main>:
    1050:	53                   	push   ebx
    1051:	31 d2                	xor    edx,edx
    1053:	bb 40 42 0f 00       	mov    ebx,0xf4240
    1058:	2e 8d b4 26 00 00 00 	lea    esi,cs:[esi+eiz*1+0x0]
    105f:	00 
    1060:	b8 00 fc ff ff       	mov    eax,0xfffffc00
    1065:	8d 76 00             	lea    esi,[esi+0x0]
    1068:	85 c0                	test   eax,eax
    106a:	78 24                	js     1090 <main+0x40>
    106c:	31 c9                	xor    ecx,ecx
    106e:	83 f8 01             	cmp    eax,0x1
    1071:	0f 9f c1             	setg   cl
    1074:	83 c0 01             	add    eax,0x1
    1077:	01 ca                	add    edx,ecx
    1079:	3d 01 04 00 00       	cmp    eax,0x401
    107e:	75 e8                	jne    1068 <main+0x18>
    1080:	83 eb 01             	sub    ebx,0x1
    1083:	75 db                	jne    1060 <main+0x10>
    1085:	89 d0                	mov    eax,edx
    1087:	5b                   	pop    ebx
    1088:	c3                   	ret
    1089:	8d b4 26 00 00 00 00 	lea    esi,[esi+eiz*1+0x0]
    1090:	83 ea 01             	sub    edx,0x1
    1093:	83 c0 01             	add    eax,0x1
    1096:	eb d0                	jmp    1068 <main+0x18>
    1098:	66 90                	xchg   ax,ax
    109a:	66 90                	xchg   ax,ax
    109c:	66 90                	xchg   ax,ax
    109e:	66 90                	xchg   ax,ax

000010a0 <_start>:
    10a0:	31 ed                	xor    ebp,ebp
    10a2:	5e                   	pop    esi
    10a3:	89 e1                	mov    ecx,esp
    10a5:	83 e4 f0             	and    esp,0xfffffff0
    10a8:	50                   	push   eax
    10a9:	54                   	push   esp
    10aa:	52                   	push   edx
    10ab:	e8 18 00 00 00       	call   10c8 <_start+0x28>
    10b0:	81 c3 2c 2f 00 00    	add    ebx,0x2f2c
    10b6:	6a 00                	push   0x0
    10b8:	6a 00                	push   0x0
    10ba:	51                   	push   ecx
    10bb:	56                   	push   esi
    10bc:	ff b3 1c 00 00 00    	push   DWORD PTR [ebx+0x1c]
    10c2:	e8 69 ff ff ff       	call   1030 <__libc_start_main@plt>
    10c7:	f4                   	hlt
    10c8:	8b 1c 24             	mov    ebx,DWORD PTR [esp]
    10cb:	c3                   	ret
    10cc:	66 90                	xchg   ax,ax
    10ce:	66 90                	xchg   ax,ax

000010d0 <__x86.get_pc_thunk.bx>:
    10d0:	8b 1c 24             	mov    ebx,DWORD PTR [esp]
    10d3:	c3                   	ret
    10d4:	66 90                	xchg   ax,ax
    10d6:	66 90                	xchg   ax,ax
    10d8:	66 90                	xchg   ax,ax
    10da:	66 90                	xchg   ax,ax
    10dc:	66 90                	xchg   ax,ax
    10de:	66 90                	xchg   ax,ax

000010e0 <deregister_tm_clones>:
    10e0:	e8 e4 00 00 00       	call   11c9 <__x86.get_pc_thunk.dx>
    10e5:	81 c2 f7 2e 00 00    	add    edx,0x2ef7
    10eb:	8d 8a 2c 00 00 00    	lea    ecx,[edx+0x2c]
    10f1:	8d 82 2c 00 00 00    	lea    eax,[edx+0x2c]
    10f7:	39 c8                	cmp    eax,ecx
    10f9:	74 1d                	je     1118 <deregister_tm_clones+0x38>
    10fb:	8b 82 10 00 00 00    	mov    eax,DWORD PTR [edx+0x10]
    1101:	85 c0                	test   eax,eax
    1103:	74 13                	je     1118 <deregister_tm_clones+0x38>
    1105:	55                   	push   ebp
    1106:	89 e5                	mov    ebp,esp
    1108:	83 ec 14             	sub    esp,0x14
    110b:	51                   	push   ecx
    110c:	ff d0                	call   eax
    110e:	83 c4 10             	add    esp,0x10
    1111:	c9                   	leave
    1112:	c3                   	ret
    1113:	2e 8d 74 26 00       	lea    esi,cs:[esi+eiz*1+0x0]
    1118:	c3                   	ret
    1119:	8d b4 26 00 00 00 00 	lea    esi,[esi+eiz*1+0x0]

00001120 <register_tm_clones>:
    1120:	e8 a4 00 00 00       	call   11c9 <__x86.get_pc_thunk.dx>
    1125:	81 c2 b7 2e 00 00    	add    edx,0x2eb7
    112b:	55                   	push   ebp
    112c:	89 e5                	mov    ebp,esp
    112e:	53                   	push   ebx
    112f:	8d 8a 2c 00 00 00    	lea    ecx,[edx+0x2c]
    1135:	8d 82 2c 00 00 00    	lea    eax,[edx+0x2c]
    113b:	83 ec 04             	sub    esp,0x4
    113e:	29 c8                	sub    eax,ecx
    1140:	89 c3                	mov    ebx,eax
    1142:	c1 e8 1f             	shr    eax,0x1f
    1145:	c1 fb 02             	sar    ebx,0x2
    1148:	01 d8                	add    eax,ebx
    114a:	d1 f8                	sar    eax,1
    114c:	74 14                	je     1162 <register_tm_clones+0x42>
    114e:	8b 92 20 00 00 00    	mov    edx,DWORD PTR [edx+0x20]
    1154:	85 d2                	test   edx,edx
    1156:	74 0a                	je     1162 <register_tm_clones+0x42>
    1158:	83 ec 08             	sub    esp,0x8
    115b:	50                   	push   eax
    115c:	51                   	push   ecx
    115d:	ff d2                	call   edx
    115f:	83 c4 10             	add    esp,0x10
    1162:	8b 5d fc             	mov    ebx,DWORD PTR [ebp-0x4]
    1165:	c9                   	leave
    1166:	c3                   	ret
    1167:	2e 8d b4 26 00 00 00 	lea    esi,cs:[esi+eiz*1+0x0]
    116e:	00 
    116f:	90                   	nop

00001170 <__do_global_dtors_aux>:
    1170:	f3 0f 1e fb          	endbr32
    1174:	55                   	push   ebp
    1175:	89 e5                	mov    ebp,esp
    1177:	53                   	push   ebx
    1178:	e8 53 ff ff ff       	call   10d0 <__x86.get_pc_thunk.bx>
    117d:	81 c3 5f 2e 00 00    	add    ebx,0x2e5f
    1183:	83 ec 04             	sub    esp,0x4
    1186:	80 bb 2c 00 00 00 00 	cmp    BYTE PTR [ebx+0x2c],0x0
    118d:	75 27                	jne    11b6 <__do_global_dtors_aux+0x46>
    118f:	8b 83 14 00 00 00    	mov    eax,DWORD PTR [ebx+0x14]
    1195:	85 c0                	test   eax,eax
    1197:	74 11                	je     11aa <__do_global_dtors_aux+0x3a>
    1199:	83 ec 0c             	sub    esp,0xc
    119c:	ff b3 28 00 00 00    	push   DWORD PTR [ebx+0x28]
    11a2:	e8 99 fe ff ff       	call   1040 <__cxa_finalize@plt>
    11a7:	83 c4 10             	add    esp,0x10
    11aa:	e8 31 ff ff ff       	call   10e0 <deregister_tm_clones>
    11af:	c6 83 2c 00 00 00 01 	mov    BYTE PTR [ebx+0x2c],0x1
    11b6:	8b 5d fc             	mov    ebx,DWORD PTR [ebp-0x4]
    11b9:	c9                   	leave
    11ba:	c3                   	ret
    11bb:	2e 8d 74 26 00       	lea    esi,cs:[esi+eiz*1+0x0]

000011c0 <frame_dummy>:
    11c0:	f3 0f 1e fb          	endbr32
    11c4:	e9 57 ff ff ff       	jmp    1120 <register_tm_clones>

000011c9 <__x86.get_pc_thunk.dx>:
    11c9:	8b 14 24             	mov    edx,DWORD PTR [esp]
    11cc:	c3                   	ret
    11cd:	66 90                	xchg   ax,ax
    11cf:	90                   	nop

000011d0 <zero_un_moins_un_c>:
    11d0:	8b 54 24 04          	mov    edx,DWORD PTR [esp+0x4]
    11d4:	b8 ff ff ff ff       	mov    eax,0xffffffff
    11d9:	85 d2                	test   edx,edx
    11db:	78 08                	js     11e5 <zero_un_moins_un_c+0x15>
    11dd:	31 c0                	xor    eax,eax
    11df:	83 fa 01             	cmp    edx,0x1
    11e2:	0f 9f c0             	setg   al
    11e5:	c3                   	ret
    11e6:	66 90                	xchg   ax,ax
    11e8:	66 90                	xchg   ax,ax
    11ea:	66 90                	xchg   ax,ax
    11ec:	66 90                	xchg   ax,ax
    11ee:	66 90                	xchg   ax,ax

000011f0 <zero_un_moins_un_asm>:
    11f0:	55                   	push   ebp
    11f1:	89 e5                	mov    ebp,esp
    11f3:	8b 4d 08             	mov    ecx,DWORD PTR [ebp+0x8]
    11f6:	b8 01 00 00 00       	mov    eax,0x1
    11fb:	ba ff ff ff ff       	mov    edx,0xffffffff
    1200:	f7 c1 00 00 00 80    	test   ecx,0x80000000
    1206:	0f 45 c2             	cmovne eax,edx
    1209:	31 d2                	xor    edx,edx
    120b:	d1 e9                	shr    ecx,1
    120d:	85 c9                	test   ecx,ecx
    120f:	0f 44 c2             	cmove  eax,edx
    1212:	89 ec                	mov    esp,ebp
    1214:	5d                   	pop    ebp
    1215:	c3                   	ret

Déassemblage de la section .fini :

00001218 <_fini>:
    1218:	53                   	push   ebx
    1219:	83 ec 08             	sub    esp,0x8
    121c:	e8 af fe ff ff       	call   10d0 <__x86.get_pc_thunk.bx>
    1221:	81 c3 bb 2d 00 00    	add    ebx,0x2dbb
    1227:	83 c4 08             	add    esp,0x8
    122a:	5b                   	pop    ebx
    122b:	c3                   	ret
