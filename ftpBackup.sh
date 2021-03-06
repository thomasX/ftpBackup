#!/bin/sh

ftpuser="admin"
ftppasswd="admin"
cfgFailure=""
backupName=$1
ftpHost=$3
localBackupDir=$2
backupdir=$4
maxBackupFiles=3

curBackupDir=""
subfolder=""
regBase=""
folderParams=$(mktemp)


printUsage(){
    echo "##########################################################################################################"
    echo "# $0"
    echo "# created by Thomas Margreiter 2017-08-22                            "
    echo "# "
    echo "# "
    echo "# "
    echo "# usage: "$0" [backupname] [localBackupDirecory] [ftpHost] [ftpBackupDirectory1] [ftpBakupDirectory2] ... "
    echo "# "
    echo "#     more informations on   https://github.com/thomasX/ftpBackup "
    echo "# "
    echo "##########################################################################################################"
}

getFolder(){
    regBase="$subfolder"
    registerSubfolder
    #echo "meine params: $curBackupDir"    "$subfolder"
    mkdir -p "$curBackupDir"/"$subfolder"
    cd "$curBackupDir"/"$subfolder"
    curPath=$(pwd)
    echo "Backupstatus $subfolder:" >> "$curBackupDir"/backupStatus
    ftp -n -v $ftpHost >> "$curBackupDir"/backupStatus << END_SCRIPT
    quote USER "$ftpuser"
    quote PASS "$ftppasswd"
    bin yes
    prompt no
    passive yes
    cd "$subfolder"
    mget * .
    quit
END_SCRIPT
    echo "ftpdir: subfolder:$subfolder"
    echo "Backupstatus $subfolder finished ###############" >> "$curBackupDir"/backupStatus
    echo "" >> "$curBackupDir"/backupStatus
    echo "" >> "$curBackupDir"/backupStatus
}

registerSubfolder(){
    local curSubfolderFile=$(mktemp)
    local curSubfolderfile=$(mktemp)
    echo "im reg:  regBase: $regBase    subfolder:$subfolder"
    ftp -n $ftpHost >> "$curSubfolderFile" << END_SCRIPT
    quote USER "$ftpuser"
    quote PASS "$ftppasswd"
    bin yes
    prompt no
    passive yes
    ls "$regBase"
    quit
END_SCRIPT
    cat "$curSubfolderFile" | grep DIR  > "$curSubfolderfile"
    while read LINE ; do
       subname=$LINE
         subName=$(echo $subname | sed 's/.*<DIR>//' | sed 's/^[ \t]*//')
         echo "$regBase"/"$subName" >> "$folderParams"
         echo "folgender subfolder wurde gefunden: $regBase"/"$subName"
    done <$curSubfolderfile
    rm -f $curSubfolderFile
    rm -f $curSubfolderfile
}
### Main script starts here ##


if [ $# -lt 4 ]; then
    printUsage
    cfgFailure="X"
    echo ""
fi

if [[ $ftpuser == "" ]]; then
    if [[ cfgFailure == "" ]]; then
       printUsage
    fi
    echo ""
    echo " please configure the ftpuser in $0"
    cfgFailure="X"
fi

if [[ $ftppasswd == "" ]]; then
    if [[ cfgFailure == "" ]]; then
       printUsage
    fi
    echo ""
    echo " please configure the ftppasswd in $0"
    cfgFailure="X"
fi



if [[ $cfgFailure == "X" ]];then
   echo ""
   echo ""
else
   echo ""
   echo "Backup $backupName in progress"
   basedir="$localBackupDir"
   mkdir -p "$basedir"
   cd "$basedir"
   tmpfolder=$(date +%Y%m%d%H%M%S)
   tmpBasedir=$(mktemp -d -p "$basedir" -t "$backupName"_"$tmpfolder"_XXXXXXXXXX)
   curBackupDir="$tmpBasedir"
   while [ "$#" -gt 3 ]; do
    subfolder="$4"
    echo "subfolder: $subfolder"
    echo "$subfolder">>"$folderParams"
    shift
   done

   while read LINE ; do
     subfolder="$LINE"
     echo " ############ hole folder:$LINE"
     getFolder
   done <$folderParams

   #grep -B3 unavailable "$curBackupDir"/backupStatus
   echo ""
   cd "$curBackupDir"
   tar -czf "$curBackupDir".tar.gz *
   if [[ $curBackupDir == "$localBackupDir"* ]];then
       rm -rf $curBackupDir
   fi
   deletableBackups=$(($maxBackupFiles+1))
   somethingDoDelete=$(ls "$basedir"/"$backupName"*.tar.gz -t | tail -n +"$deletableBackups" | xargs echo --)
   if [[ $somethingDoDelete == "--" ]]; then
        echo ""
   else
      ls "$basedir"/"$backupName"*.tar.gz -t | tail -n +"$deletableBackups" | xargs rm --
   fi
   echo ""
   echo "Backup $backupName finished"
   rm -f "$folderParams"
fi
