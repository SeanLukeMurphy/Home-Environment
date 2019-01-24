.m.m:.m.curr:.m.orig:50#'50#0b;
.m.d:.m.l:.m.r:.m.s::0;
\c 1000 2000
clear:{.m.m:.m.curr;.[`.m.m;;:;1b] each ((::;0);(::;49);(49;::));};
sp:{[x]?'[x;"@";" "]}
.p.b:4#'4#1b;                                                                                                               // Block
.p.s:2#'8#1b;                                                                                                               // Stick
.p.l:4#'8#0b;.[`.p.l;;:;1b]each ((0;::);(1;::);(::;2);(::;3));                                                              // Leg
.p.z:4#'6#0b;.[`.p.z;;:;1b]each ((0;0);(0;1);(1;0);(1;1);(2;0);(2;1);(2;2);(2;3);(3;0);(3;1);(3;2);(3;3);(4;2);(4;3);(5;2);(5;3)); // Z
.p.c:4#'6#0b;.[`.p.c;;:;1b]each ((::;2);(::;3);(2;0);(2;1);(3;0);(3;1));                                                    // Cross
.c.flip:`l`r!({[x] flip x};{[x] reverse each x});                                                                           // Dictionary of moves
.c.k:key[.c.flip];                                                                                                          // Keys of the dictionary of moves
.c.a:(.p.s;.p.l;.p.c;.p.z);                                                                                                 // List of all pieces
.c.b:raze 1?.c.a;                                                                                                           // Starter Piece

getPos:{:(0;"i"$count[.m.m[0;]]%2)+/:(,/),''[til[count[.c.b]];where each .c.b]};                                            // Get starting position of the piece
.pos.pos:getPos[];                                                                                                          // Set the starting position

flipPos:{ 
 // - Function to flip the piece and update the position accordingly 
 .c.b:.c.flip[first .c.k;.c.b];                                                                                             // Flip the piece
 .c.k:1 rotate .c.k;  clear[];                                                                                              // Rotate to the next move
 clear[];                                                                                                                   // Clear the screen
 .pos.pos:getPos[];                                                                                                         // Get the starter position
 do[.m.d;.pos.pos:.pos.pos+\:1 0];                                                        
 do[.m.l;.pos.pos:.pos.pos+\:1 -1];
 do[.m.r;.pos.pos:.pos.pos+\:1 1];
 };

.z.pi:{[x]
 x:first raze x;
 .m.d+:1;
 $["q"~x;
   exit 1;
   "a"~x;
   [.m.l+:1;.pos.pos:.pos.pos+\:1 -1];
   "d"~x;
   [.m.r+:1;.pos.pos:.pos.pos+\:1 1];
   "s"~x;
   [.pos.pos:.pos.pos+\:2 0];
   "w"~x;
   [.pos.pos:.pos.pos+\:1 0];
   "f"~x;
   [flipPos[]];
   .pos.pos:.pos.pos+\:1 0
  ];
  refresh[];
 }

.z.ts:{.z.pi system"read -s -t 2 -n 1 p;echo $p";}
\t 100

refresh:{
  $[not any any (count[.m.m]-2)<.pos.pos;
  [clear[];
   .[`.m.m;;:;1b] each .pos.pos]; 
  [.c.b:first 1?.c.a;.m.curr:.m.m;.m.d:.m.r:.m.l:0;.pos.pos:getPos[]]
 ];
 -1 sp .m.m;
 };


