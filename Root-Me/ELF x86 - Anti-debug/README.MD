# Root-Me - ELF x86 - CrackPass

## Enoncé

Le cracking ne sera pas aisé...

Challenge : https://www.root-me.org/fr/Challenges/Cracking/ELF-x86-Anti-debug?action_solution=voir&debut_affiche_solutions=3

Niveau de difficulté : Moyen

## Solution

Le programme est capable de détecter des modifications dans son code et l'utiilisation des points d'arrêts empêche souvent le programme de se terminer correctement. Je vais donc utiliser la fonction `disassemble` pour comprendre le fonctionnement du programme.

En utilisant la commande `readelf -h ch13` je sais que le point d'entrée du programme se trouve à l'adresse `0x8048060`.

disas 0x8048060,0x8048060+4 :
```Assembly
0x08048060:	jmp    0x8048063
0x08048062:	call   0x804b11f
```

Le programme commence par sauter à l'adresse `0x8048063` or il n'y a pas d'instruction à cette adresse, je vais donc forcer gdb à m'afficher le code assembleur en commençant à cette adresse.

disas 0x8048063,0x8048063+18 :
```Assembly
0x08048063:	mov    eax,0x30
0x08048068:	mov    ebx,0x5
0x0804806d:	mov    ecx,0x80480e2
0x08048072:	int    0x80
0x08048074:	jmp    0x8048077
```

L'instruction `int 0x80` permet, sous linux, de réaliser un `syscall` (appel système). Le registre `eax` contient l'identifiant de la fonction à appeler, `ebx` le premier paramètre et `ecx` le second paramètre. Dans le fichier `unistd_32.h` je trouve la correspondant entre les identifiants et les fonctions :

```C
#define __NR_exit 1
#define __NR_fork 2
#define __NR_read 3
#define __NR_write 4
// ...
```

Dans le code ci-dessus est équivalent au code C suivant :

```C
signal(5, 0x80480e2);
```

Lorsque le programme recevra le signal `SIGTRAP` (`0x5`), le code à l'adresse `0x80480e2` sera exécuté. Je vais continuer à dérouler le programme :

disas 0x8048077,0x8048077+2 :
```Assembly
0x08048077:	int3
0x08048078:	jmp    0x804807b
```

L'instruction `int3` envoi le signal `SIGTRAP` au programme qui l'appelle. Cela va donc exécuter le contenu de l'adresse précédemment définie : `0x80480e2`.

disas 0x80480e2,... :
```Assembly
0x080480e2:	mov    eax,0x8048104                ; eax = 0x8048104
0x080480e7:	jmp    0x8048101

0x08048101:	jmp    0x80480e9

; Début de la boucle
0x080480e9:	cmp    eax,0x80482e8                ; Si eax == 0x80482e8
0x080480ee:	je     0x8048103                    ; Fin de la boucle
0x080480f0:	jmp    0x80480f3                    ; Sinon je continue la boucle

0x080480f3:	xor    DWORD PTR [eax],0x8048fc1    ; [eax] = [eax] XOR 0x8048fc1
0x080480f9:	add    eax,0x4                      ; eax += 4
0x080480fc:	jmp    0x80480ff

0x080480ff:	jmp    0x80480e9                    ; Retour au début de la boucle

0x08048103:	ret                                 ; Fin de la fonction, retour au code principal
```

Ce code modifie les instructions du programme en appliquant un XOR sur toutes les données de l'adresse `0x8048104` à l'adresse `0x80482e8`. Lorsque toutes les données sont traitées, la fonction s'arrête et notre programme reprend à l'adresse `0x08048078` (qui n'a pas été modifiée) qui consiste en un saut à l'adresse `0x804807b` (qui n'a pas été modifiée).

disas 0x804807b,... :
```Assembly
0x0804807b:	mov    eax,0x30
0x08048080:	mov    ebx,0x5
0x08048085:	mov    ecx,0x8048194
0x0804808a:	int    0x80
;Le programme modifie la fonction à appeler au prochain SIGTRAP.
0x0804808c:	jmp    0x804808f

; Puis appel la nouvelle fonction
0x0804808f:	int3
0x08048090:	jmp    0x8048093
```

Le signal entraine l'exécution des instructions à l'adresse `0x8048194` mais elle a été modifiée par la précédente fonction. J'ai choisi de lancer l'exécution du programme et de reprendre la main lorsque ce dernier me demande un mot de passe, ainsi je sais que le code a été modifié et je peux l'analyser. Lorsque gdb reçoit un `SIGTRAP` du programme, je lui en renvoie 1 pour assurer son bon fonctionnement. Je peux maintenant analyser l'adresse `0x8048194`.

disas 0x8048194,... :
```Assembly
0x08048194:	xor    eax,eax              ; eax = 0
0x08048196:	mov    ebx,0x8048060        ; ebx = 0x8048060
0x0804819b:	cmp    ebx,0x80482e4        ; Si ebx = 0x80482e4
0x080481a1:	je     0x80481aa            ; fin de la boucle
0x080481a3:	xor    eax,DWORD PTR [ebx]  ; eax = eax XOR [ebx]
0x080481a5:	add    ebx,0x4              ; ebx += 4
0x080481a8:	jmp    0x804819b            ; Retour au début de la fonction

0x080481aa:	mov    ebx,0x80482e4        ; ebx = 0x80482e4
0x080481af:	cmp    eax,DWORD PTR [ebx]  ; si eax = [ebx] (soit 0x7e5a6f0a)
0x080481b1:	je     0x80481cc            ; l'exécution continue
0x080481b3:	mov    ebx,0x1              ; ebx = 1
0x080481b8:	mov    ecx,0x804821d        ; ecx = 0x804821d
0x080481bd:	mov    edx,0x20             ; edx = 20
0x080481c2:	call   0x80481cd

; Premier call
0x080481cd:	mov    eax,0x4
0x080481d2:	int    0x80                 ; syscall qui appelle la fonction write (eax = 0x4) qui écrit dans le terminal (ebx = 1), le contenu à l'adresse 0x804821d sur 32 caractères
; 0x804821d sur 20 caractères = "QUIT ! Executable is modified !\n"
0x080481d4:	ret                         ; fin de la fonction
```

La valeur contenue dans le registre `eax` dépend de l'ensemble des données comprises entre `0x8048060` et `0x80482e4`. Si le code est modifié, alors la valeur de `eax` changera et ne sera plus `0x80482e4` donc le programme détectera la modification et s'arrêtera. Lorsque le code n'a pas été modifié, il continue à l'instruction `0x80481cc`.

disas 0x80481cc,... :
```Assembly
0x080481cc:	ret
```

Le code appelé suite au signal s'arrête et l'exécution principale reprend son cours. L'instruction à l'adresse `0x08048090` saute à `0x8048093`.

disas 0x8048093,... :
```Assembly
0x08048093:	mov    eax,0x30
0x08048098:	mov    ebx,0x5
0x0804809d:	mov    ecx,0x8048104
0x080480a2:	int    0x80
0x080480a4:	jmp    0x80480a7
; Préparation d'une nouvelle fonction

0x080480a7:	int3                ; Appel du code à l'adresse 0x8048104
0x080480a8:	jmp    0x80480ab
```

disas 0x08048104,... :
```Assembly
0x08048104:	mov    ebx,0x1
0x08048109:	mov    ecx,0x804823d
0x0804810e:	mov    edx,0x14
0x08048113:	call   0x80481cd

0x080481cd:	mov    eax,0x4          ; Appel de la fonction write avec la caîne de caractères à l'adresse 0x804823d sur 20 caractères.
; 0x804823d = "Enter the password: "
0x080481d2:	int    0x80
0x080481d4:	ret                     ; Sortie de la fonction, retour à l'instruction 0x08048118

0x08048118:	mov    ebx,0x0
0x0804811d:	mov    ecx,0x8048251
0x08048122:	mov    edx,0x80
0x08048127:	call   0x80481d5
;0x0804812c:	mov    ebx,0x8048251

0x080481d5:	mov    eax,0x3
0x080481da:	int    0x80                 ; syscall de read (eax = 0x3) dont le résultat sera enregistré à l'adresse 0x8048251 pour un maximum de 128 octets 
0x080481dc:	ret                         ; Sortie de la fonction, retour à l'instruction 0x0804812c

0x0804812c:	mov    ebx,0x8048251        ; ebx pointe désormais sur l'entrée de l'utilisateur
0x08048131:	add    ebx,eax              ; ebx pointe sur l'octet suivant le dernier caractère de l'entrée de l'utilisateur
0x08048133:	dec    ebx                  ; ebx pointe sur le dernier caractère de l'entrée de l'utilisateur (\n)
0x08048134:	mov    BYTE PTR [ebx],0x0   ; Et le remplace par \0
0x08048137:	ret
```

Le programme affiche donc le texte "Enter the password: ", récupère l'entrée de l'utilisateur qu'il enregistre à l'adresse 0x8048251. Puis se rend à l'instruction `0x080480a8` qui saute à `0x80480ab`
0x080480b0:	mov    ebx,0x5
0x080480b5:	mov    ecx,0x8048138
0x080480ba:	int    0x80
0x080480bc:	jmp    0x80480bf

0x080480bf:	int3                    ; Appel, via les signaux, de la fonction à l'adresse 0x8048138
0x080480c0:	jmp    0x80480c3
```

disas 0x8048138,... :
```Assembly
0x08048138:	mov    eax,0x8048251        ; eax = 0x8048251 (adresse de l'entrée de l'utilisateur)
0x0804813d:	cmp    BYTE PTR [eax],0x0   ; Si l'octet pointé par eax vaut 0
0x08048140:	je     0x8048148            ; Sorti de la boucle
0x08048142:	xor    BYTE PTR [eax],0xfc  ; [eax] = [eax] XOR 0xfc
0x08048145:	inc    eax                  ; eax += 1
0x08048146:	jmp    0x804813d            ; Retour au début de la boucle

0x08048148:	ret                         ; Fin
```

Cette fonction applique un `XOR 0xfc` sur tous les octets à partir de l'adresse `0x8048251` jusqu'à atteindre un octet valant 0, c'est à dire l'entrée de l'utilisateur.

disas 0x80480c3,... :
```Assembly
0x080480c3:	mov    eax,0x30
0x080480c8:	mov    ebx,0x5
0x080480cd:	mov    ecx,0x8048149
0x080480d2:	int    0x80
0x080480d4:	jmp    0x80480d7

0x080480d7:	int3                    ; Appel, via les signaux, de la fonction à l'adresse 0x8048149
0x080480d8:	jmp    0x80480db
```

disas 0x8048149,... :
```Assembly
0x08048149:	mov    eax,0x8048251        ; eax contient l'adresse vers l'entrée de l'utilisateur
0x0804814e:	mov    ebx,0x80482d1        ; ebx contient une autre adresse
; Début de la boucle
0x08048153:	mov    cl,BYTE PTR [eax]    ; cl contient l'octet pointé par eax
0x08048155:	cmp    cl,BYTE PTR [ebx]    ; Si [eax] != [ebx] (sur 1 octet)
0x08048157:	jne    0x8048162            ; Saut à l'adresse 0x8048162
0x08048159:	cmp    cl,0x0               ; Si cl = 0
0x0804815c:	je     0x804817b            ; Saut à l'adresse 0x804817b
0x0804815e:	inc    eax                  ; eax++
0x0804815f:	inc    ebx                  ; ebx++
0x08048160:	jmp    0x8048153            ; Retour au début de la boucle
```

ebx contient probablement l'adresse vers le mot de passe chiffré.

disas 0x8048162,... :
```Assembly
0x08048162:	mov    ebx,0x1
0x08048167:	mov    ecx,0x8048207
0x0804816c:	mov    edx,0x16
0x08048171:	call   0x80481cd
0x08048176:	call   0x80481dd

; Premier call
0x080481cd:	mov    eax,0x4
0x080481d2:	int    0x80     ; write des 22 octets à l'adresse 0x8048207 ("Bad password, sorry !\n")
0x080481d4:	ret

; Second call
0x080481dd:	mov    eax,0x1
0x080481e2:	int    0x80     ; Appel de la fonction exit => fin du programme
0x080481e4:	inc    edi
```

S'il y a une différence entre ce qui est pointé par `eax` et `ebx` le programme détecte que le mot de passe est mauvais. J'ai trouvé la fonction qui permet de valider l'entrée de l'utilisateur.

disas 0x804817b,... :
```Assembly
0x0804817b:	mov    ebx,0x1
0x08048180:	mov    ecx,0x80481e4
0x08048185:	mov    edx,0x23
0x0804818a:	call   0x80481cd
0x0804818f:	call   0x80481dd

; Premier call
0x080481cd:	mov    eax,0x4
0x080481d2:	int    0x80     ; Write des 35 octets à l'adresse 0x80481e4 ("Gratz, this is the good password !\n")
0x080481d4:	ret

; Second call déjà traité précédemment, il s'agit de l'appel à la fonction exit
```

Donc à l'adresse `0x80482d1` se trouve le mot de passe que je vais sur lequel `XOR 0xfc` a été appliqué. Je le récupère en m'arrêtant au premier octet 0 :

```
0x80482d1:	0xa5	0xcf	0x9d	0xb4	0xdd	0x88	0xb4	0x95
0x80482d9:	[...]
0x80482e1:	0x85	0xdd	0x00
```

J'utilise cyberchef pour appliquer le XOR et j'obtiens : `Y3[...]y!`