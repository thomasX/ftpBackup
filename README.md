# ftpBackup
linux sh script to transfer folders with multiple subfolders over ftp

to configure this script change the following lines in the script: 

ftpuser=""
      
ftppasswd=""
       
       
maxBackupfiles=3

       maxBackupfiles defines the maximum Backups with the same Backupname 
       if there are more Backups with the same Backupname on the System, the oldest Backup will be deleted !



usage: 
Example:

      ./ftpBackup.sh myBackupName <ftpIP> /user/local/Backups /Documents /pictures /otherfiles
  
does create the backupfile myBackupName_20170822120000_xxxxxx.tar.gz in the folder /usr/local/Backups
        the Backupfile contains the Directory /Documents , /pictures, /otherfile with all their subdirectories.
        in the root folder of the Backupfile you can find a File 'Backupstatus' containing the ftp status of each file
        
        
        

