# EAForceClose
Autohotkey V2 script to force close the EA background processes when you actually want to close it. 

The script seems to function almost perfectly with sometimes having difficulty with launching a game from EA for the first time after a PC restart.
If you want to make any modifications you can turn on the "DEBUG" to true in the script and you'll be able to see the actions the script is registering in a .log file that will be created in the directory of the location of the script.

I added the script in my startup sequence as it is really lightweight so it shouldn't really give you any performance issues. 

The admin acces is purely because there are EA backround processes that keep running on the SYSTEM and not on the user, so the script closes ALL EA processes when you press the X in the app of EA. Feel free to remove the admin rights if you feel uncomfortable running this script with admin rights. But you can ofcourse just read and interpret the script and see nothing sketchy is going on, AI can help you with this.
