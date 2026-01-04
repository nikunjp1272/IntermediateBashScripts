#!/usr/bin/sh

# Load HTTP proxy configuration
. /etc/profile.d/http_proxy.sh

# == Description ======================
# ======================================
# Check status - log information into a log file for Splunk or send metric to CloudWatch
# option : logfile|aws
#       logfile : write status into a log file
#       aws : send metrics to cloudWatch

# ***********************************************************************
# Configuration
# ***********************************************************************
unix_user=ec2-user
cft_user=cft
Usage="
CFT monitoring tool

Usage:  ${Prog} [OPTION]
Options are:
        -u, --usedrec   # Displays the number of records
                                                # Displays the number of records in the catalog
                        # Displays the number of free records
                        # Displays the number of free records (in percent)

        -s, --status    # Returns the status of CFT monitor
                        #   0 = CFT is running. The environment (shared memory) is consistent.
                        # 252 = CFT is not running. The environment (shared memory) is correct.
                        # 253 = CFT is running but the status is inconsistent at shared memory level.
                        # 254 = CFT is not running (CFTMAIN is not present) but the status is inconsistent (at least one of the shared memory segments exists).
                        # 255 = Procedure error

        -o, --output logfile|aws|debug    # where write/send the result
                                                # logfile : Writes the result in a CSV output file
                                                # aws : send the result to cloudwatch
                                                # debug : send the result to output
        -f, --files out|other    # other filesystem tests
        --help

"
TRANSCFTDIR="/transfert_nr/cft"

 # ***********************************************************************
# Function
# ***********************************************************************
# ==============================================
# Function : log_json (line, mylogCsvFile)
# ==============================================
# Log message in a log file
# Input :
#       line : line to log
#       mylogCsvFile : log file name
# Output :
#       N/A
# ==============================================
Log_json ()
{
        line=$1
        mylogCsvFile=$2

        echo ${line} 2>&1 | tee -a ${mylogCsvFile}
}
# ==============================================
# Function : log (message, logFile)
# ==============================================
# Log message in a log file
# Input :
#       message : message to log
#       mylogFile : log file name
# Output :
#       N/A
# ==============================================
Log ()
{
        message=$1
        mylogFile=$2
        currentDate=`date +'%Y-%m-%dT%T'`

        echo ${currentDate}" "${message} 2>&1 | tee -a ${mylogFile}
}
# ==============================================
# Function : SendMetricsAws (processAlias, metricName, metricValue, instanceid, region, logFile)
# ==============================================
# Log message in a log file
# Input :
#       processAlias : process alias to log
#       metricName : name of the metric (ProcessStatus, RecordSelected, ..)
#       metricValue : value of the metric
#       instanceid : aws instanceid
#       region : aws region
#       mylogFile : log file name
# Output :
#       N/A
# ==============================================
SendMetricsAws ()
{
        processAlias=$1
        metricName=$2
        metricValue=$3
        instanceid=$4
        region=$5
        mylogFile=$6
        mynamespace="Processes"

        # for process status used the namespace Processes
        # for the catalog used the namespace CFT
        if [ ${Metric} == "CFT_process" ]; then
                mynamespace="Processes"
        elif [ ${Metric} == "CFT_catalog" ]; then
                mynamespace="CFT"
        elif [ ${Metric} == "CFT_out" ]; then
                mynamespace="CFT"
        fi

        aws cloudwatch put-metric-data --metric-name ${metricName} --namespace ${mynamespace} --unit None --value ${metricValue} --dimensions InstanceId=${instanceid},ProcessName="${processAlias}" --region ${region}

        if [ $? -ne 0 ]; then
                Log "[ERROR] An error occured and metrics for ${processAlias} could not be sent to AWS CloudWatch" ${mylogFile}
                exit 1
        else
                Log "[INFO] Metrics for ${processAlias} were successfully sent to AWS CloudWatch" ${mylogFile}
        fi
}

# ==============================================
# Function : StatusReturn (Message,ExitCode)
# ==============================================
# Send or log Process status
# Input :
#       Message : message
#       ExitCode : exit code of the process status
# Output :
#       N/A
# ==============================================
function StatusReturn {
    Message=$1
    ExitCode=$2

        mydate=`date +'%Y-%m-%dT%T'`
        myline="${mydate}","${Metric}","${ExitCode}",\""${Message}"\"

        # log or send metrics
        case $OutputType in
                logfile)
                        Log_json "${myline}" ${logCsvFileProcess}
                ;;
                aws)
                        SendMetricsAws "cft" "ProcessStatus" ${ExitCode} ${instanceid} ${region} ${logFile}
                ;;
                debug)
                        echo "${myline}" ${logCsvFileProcess} ${instanceid} ${region} ${logFile}
                ;;
        esac

}
# ==============================================
# Function : CatalogReturn (record_selected, record_in_catalog, record_free, record_free_pcent)
# ==============================================
# Send or log Process status
# Input :
#   record_selected : value of record
#   record_in_catalog : value of record in the catalog file
#       record_free : value of free record
#       record_free_pcent : value of free record (in percent)
# Output :
#       N/A
# ==============================================
function CatalogReturn {
    record_selected=$1
    record_in_catalog=$2
        record_free=$3
        record_free_pcent=$4

        mydate=`date +'%Y-%m-%dT%T'`
        myline="${mydate}","${Metric}","${record_selected}","${record_in_catalog}","${record_free}","${record_free_pcent}"

        # log or send metrics
        case $OutputType in
                logfile)
                        Log_json "${myline}" ${logCsvFileRecord}
                ;;
                aws)
                        SendMetricsAws "cft" "RecordSelected" ${record_selected} ${instanceid} ${region} ${logFile}
                        SendMetricsAws "cft" "RecordInCatalogFile" ${record_in_catalog} ${instanceid} ${region} ${logFile}
                        SendMetricsAws "cft" "RecordFree" ${record_free} ${instanceid} ${region} ${logFile}
                        SendMetricsAws "cft" "RecordFreePercent" ${record_free_pcent} ${instanceid} ${region} ${logFile}
                ;;
                debug)
                        echo "${myline}" ${logCsvFileRecord} ${instanceid} ${region} ${logFile}
                ;;
        esac

}

# ==============================================
# Function : FilesystemReturn (filestoSend,filestoSend15mn,filestoSend60mn)
# ==============================================
# Send or log FS Queue output status
# Input : 4 args
#   filestoSend0mn 15mn 60mn 240mn
# Output :
#       N/A
# ==============================================
function FilesystemReturn {
    filestoSendNow=$1
    filestoSend15mn=$2
    filestoSend60mn=$3
    filestoSend240mn=$4

        mydate=`date +'%Y-%m-%dT%T'`
        myline="${mydate}","${Metric}","${filestoSendNow}","${filestoSend15mn}","${filestoSend60mn}","${filestoSend240mn}"

        # log or send metrics
        case $OutputType in
                logfile)
                        Log_json "${myline}" ${logCsvFileRecord}
                ;;
                aws)
                        SendMetricsAws "cft" "filestoSendNow" ${filestoSendNow} ${instanceid} ${region} ${logFile}
                        SendMetricsAws "cft" "filestoSend15mn" ${filestoSend15mn} ${instanceid} ${region} ${logFile}
                        SendMetricsAws "cft" "filestoSend60mn" ${filestoSend60mn} ${instanceid} ${region} ${logFile}
                        SendMetricsAws "cft" "filestoSend240mn" ${filestoSend240mn} ${instanceid} ${region} ${logFile}
                ;;
                debug)
                        echo "${myline}" ${logCsvFileRecord} ${instanceid} ${region} ${logFile}
                ;;
        esac

}

# ***********************************************************************
# Generate EC2 tags
# ***********************************************************************
current_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
sh ${current_directory}/aws_get_tags.sh
. ~/aws_ec2_tags

# ***********************************************************************
# Global variable
# ***********************************************************************
date=`date '+%Y%m%d'`

# get AWS properties - instanceid / region
aws_token=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 1800")
curl_command="curl -H \"X-aws-ec2-metadata-token:$aws_token\" -s"
instanceid=$(eval $curl_command http://169.254.169.254/latest/meta-data/instance-id)
region=$(eval $curl_command http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')

# define log and properties directory
logDirectory=/logs/operation

myFilename=`basename -s .sh $0`
logFile=${logDirectory}/${myFilename}_${date}.log
logCsvFileProcess=${logDirectory}/${myFilename}_process_${date}.csv
logCsvFileRecord=${logDirectory}/${myFilename}_record_${date}.csv


# ***********************************************************************
# Main
# ***********************************************************************

# script only used by CFT - exit if not CFT
if [ "${AWS_TAG_COMPONENT}" != "cft" ]; then
        exit 0
fi

# check if the log directory exists - if not, create it
if [ ! -d "${logDirectory}" ]; then
        sudo mkdir -p ${logDirectory}
        sudo chown ${unix_user}. ${logDirectory}
        status=$?
        if [ ${status} -eq 0 ]; then
                Log "[INFO] Log directory created: ${logDirectory}" ${logFile}
        else
                Log "[ERROR] Error during the creation of the log directory: ${logDirectory}" ${logFile}
                exit 1
        fi
fi

if  [ $# -eq 0 ]; then
    echo "${Usage}" | more >&2; exit 255
fi

while [ $# -gt 0 ]; do
    case $1 in
        --help ) echo "${Usage}" | more >&2; exit 255 ;;
        -o | --output)
                        OutputType=$2
                        #important? echo $OutputType
                        if [ "$OutputType" != "logfile" ] && [ "$OutputType" != "aws" ]&& [ "$OutputType" != "debug" ]; then
                                 echo "${Usage}" | more >&2; exit 255
                        fi
            shift
            ;;
        -f | --filsystem)
                        export STATE=FOUT
                        if [ "$2" != "out" ]; then
                                 echo "${Usage}" | more >&2; exit 255
                        fi
            shift
            ;;
        -s | --status) export STATE=S ;;
        -u | --usedrec ) export STATE=CDHKTX ;;
        * ) echo "Option not found: $1"
            echo "${Usage}" | more >&2; exit 255
        ;;
    esac
    shift
done

case ${STATE} in

    CDHKTX) Metric="CFT_catalog"
                record_selected=`sudo su - ${cft_user} -c "cftutil listcat state=${STATE} " | sed -e '/'"^[ ]*[0-9]* record(s) selected"'/ !d' | sed -e 's/\([0-9]\) record.*/\1/'`
                record_in_catalog=`sudo su - ${cft_user} -c "cftutil listcat state=${STATE} " | sed -e '/'"^[ ]*[0-9]* record(s) in Catalog file"'/ !d' | sed -e 's/\([0-9]\) record.*/\1/'`
                record_free=`sudo su - ${cft_user} -c "cftutil listcat state=${STATE} " | sed -e '/'"^[ ]*[0-9]* record(s) free"'/ !d' | sed -e 's/\([0-9]\) record.*/\1/'`
                record_free_pcent=`sudo su - ${cft_user} -c "cftutil listcat state=${STATE} " | sed -e '/'"^[ ]*[0-9]* record(s) free"'/ !d' | sed -e 's/^.*[free (]\([0-9]*\)[%)]*$/\1/'`

                CatalogReturn ${record_selected} ${record_in_catalog} ${record_free} ${record_free_pcent}
    ;;

    S)  Metric="CFT_process"
        sudo su - ${cft_user} -c "cftping;"
                RETVAL=$?

        if [[ ${RETVAL} -eq 0 ]]; then
            StatusReturn "CFT is not running. The environment (shared memory) is correct:" "252"
            exit 252
        elif [[ ${RETVAL} -eq 1 ]]; then
            StatusReturn "CFT is running. The environment (shared memory) is consistent:" "0"
            exit 0
        elif [[ ${RETVAL} -eq 2 ]]; then
            StatusReturn "CFT is running but the status is inconsistent at shared memory level:" "253"
            exit 253
        elif [[ ${RETVAL} -eq 3 ]]; then
            StatusReturn "CFT is not running (CFTMAIN is not present) but the status is inconsistent (at least one of the shared memory segments exists):" "254"
            exit 254
        else
            StatusReturn "Procedure error." "255"
            exit 255
        fi
    ;;
    FOUT)  Metric="CFT_out"
                FOUTMNS=""
                for FOUTMN in 0 15 60 240;do
                        FOUTMNN=$(sudo -u ${cft_user} find $TRANSCFTDIR/*/out/* -type f -mmin +$FOUTMN -mtime -7|wc -l|sed -e 's/[^0-9]*//' -e 's/^$/0/' 2>/dev/null)
                        FOUTMNS="$FOUTMNS $FOUTMNN"
                done
                FilesystemReturn $FOUTMNS

                FOUTAUTOP=30
                FOUTAUTOM=120
                #auto resend > FOUTAUTOP mn, but not more than AUTOM #//TODO put param in config
                FOUTSND=$(sudo -u ${cft_user} find $TRANSCFTDIR/*/out/* -type f -mmin +$FOUTAUTOP -mmin -$FOUTAUTOM -mtime -7 2>/dev/null)
                if [ "$FOUTSND" != "" ];then
                        for FTOSND in $FOUTSND;do
                                IDF=$(dirname $FTOSND|sed -e 's:/out.*$::' -e 's:^.*/::')
                                sudo -u ${cft_user} /transfert_nr/ines/cft_scripts/ines_transfert -proj_trans $IDF -fname $(basename $FTOSND)
                        done
                fi

                #CANNOT CHECK EXISTS if [ "$?" != "0" ]; then StatusReturn "problem on filesystem /transfert_nr/cft/*/out :" "248" ; exit 252;fi
        ;;
esac

exit 0
