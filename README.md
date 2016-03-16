About
=====
This is the earliest snapshot for the source code of [Eksi Sozluk](https://eksisozluk.com) as of May 1999, three months after the site was launched. It was my first attempt on developing an interactive web application. It turned out to be quite popular.

It kept the dictionary data in a plain text file (`dict.txt`). The original file from the backups was 2MB long, I had to trim it. You should still be able to run this code with existing stuff.

I also emptied the user database in `user.txt` to protect people's
privacy. One should still be able to add entries with username:`dummy` password: `dummy`.

It surprised me to find out that I had developed a primitive templating mechanism despite that I had never seen one at the time. So the common sense is universal I guess. The text file was a terrible choice but it worked out fine until I converted the database to MS Access when I converted the code to VBScript.

The names `show.txt` and `index.exe` had lived in Eksi Sozluk code even after as `show.asp` and `index.asp`. The "left frame" in Eksi Sozluk code today is still called "the index".

Changes
=======
A couple of users have contributed helper scripts to allow building of the code today. I decided to keep them since they didn't modify the existing code.

License
=======
MIT License. See `LICENSING` file for details.