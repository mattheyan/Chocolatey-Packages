 ======================================================================
	SysTrayMeter -- Copyright (c) 2007; jacky
	Computers Are Fun, Right?
	http://88.191.26.34/computers_are_fun/

 ======================================================================
 === Description

  SysTrayMeter  (STM) is a little freeware application  that will add an
icon  to your  systray, in  which the  CPU &  RAM usage  will be  shown.
Nothing very new indeed, but I've  always wanted to have both those info
available quickly every  time I needed them, and never  found what I was
really looking for.

  Either it  used a full sidebar and not only  one single little systray
icon, or it didn't show what I  wanted, or it used too much resources...
so I made STM.

  Is it perfect?  Probably not, but according to my  needs, it does what
it should, and does it better than any other applications out there.

 ======================================================================
 === How does it work?

  Start it. That's it. Enjoy! ;-)
No really,  that's pretty much all there  is to it.  Once you've started
it, you'll  see a  new icon  on your  systray, with  two "sections"  : a
small one,  and another  small one  somewhat a  little bigger.  One will
report the CPU usage, the other one the RAM.

  And if you want to quit, simply double-click on the icon.

  Yet there are  a few things you can set up,  simply by creating a file
called   SysTrayMeter.ini   in the  same  folder as the  EXE  file. This
configuration file can contain up to 3 sections :

	Global Settings, under [Settings]

First off,  you can choose  the section's order:  do you like  the small
one on top (default), or do you want the big one on top?
To have the big one on top, simply add this line:
ReverseOrder=1

By default,  STM puts  info about  the CPU on  top, and  the RAM  on the
bottom.  If  you want  things  the  other  way  around, add  this  line:
InfoSection=1

Then, you  can decide what will actually  be shown. For  CPU, default is
to  show how  much it's  used (percent-wise),  but you  can have  either
nothing (no  text will  be shown), usage  percent or  free/idle percent:
to have no text at all, use:
ShowCpu=0
to have how much is free/unused/idle, use:
ShowCpu=1
to have how much is used, either remove ShowCpu or use:
ShowCpu=2

And for the RAM, to show nothing use:
ShowUsedRam=0
to show how much free RAM there is, remove ShowUsedRam or use:
ShowUsedRam=1
to show how much RAM is being used, use:
ShowUsedRam=2


	Color Schemes, under [CpuColors] and [RamColors]

You can  also define which  colors will be  used, according to  how much
CPU/RAM is being  used. For each one,  you can define as  many colors as
you want, for both text & background.

Both sections accept the same settings:
First, for the text colors, define how many will be used:
NbText=x
Then, for each one - which MUST  be ordered by usage, define what is the
highest value to use this color for,  eg. setting it to 42 means it will
be for usage up to 42 (ie. usage <= MaxValue)
TextX.MaxValue=x
and  define  the  color  to  used,   as  you  may  know  from  HTML/CSS:
TextX.Color=#RRGGBB

For example, to have the text in black  for usage from 0 to 85, and then
(86 to 100) in white, use this:
--------
; 2 colors used
NbText=2
; up to 85
Text1.MaxValue=85
; in black
Text1.Color=#000000
; and up to 100%
Text2.MaxValue=100
; in white
Text2.Color=#FFFFFF
--------

To set  the background colors,  it's exactly  the same, but  with "Back"
instead of "Text" on the values names, so:
NbBack=x
BackX.MaxValue=x
BackX.Color=#RRGGBB

 ======================================================================
 === History

*** September 5, 2007 -- v0.2.0006
> When explorer.exe crashed, STM would  keep running but its icon wasn't
put back on systray. Fixed.

*** April 19, 2007 -- v0.2.0005
> first public release
