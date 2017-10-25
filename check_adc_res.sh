#!/bin/bash

usage() {
        echo "Usage: $0 [-h <hostname/ip>][-u <user>][-p <password>]"
        echo
        echo "Example: check_adc_res.sh -h 127.0.0.1 -u admin -p Secur3pa55 -r ram -w 90 -c 100" 1>&2;
        exit 1;
}

while getopts ":h:u:p:r:c:w:" o; do
    case "${o}" in
        h)
            h=${OPTARG}
            ;;
        u)
            u=${OPTARG}
            ;;
        p)
            p=${OPTARG}
            ;;
        r)
            r=${OPTARG}
            ;;
        c)
            c=${OPTARG}
            ;;
        w)
            w=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

if [ -z "${h}" ] ||[ -z "${u}" ]||[ -z "${p}" ]||[ -z "${r}" ]||[ -z "${w}" ]||[ -z "${c}" ] ; then
    usage
fi

host=$h
user=$u
pass=$p
resource=$r
warning=$w
critical=$c

login_data(){
cat <<EOF
{"username":"${user}","password":"${pass}"}
EOF
}

#Login, create session and store session-cookie
curl -s -H "Content-Type: application/json" -X POST -d "$(login_data)" http://${host}/api/user/login --cookie-jar /tmp/adcfortinetresource_session.${pid}> /dev/null

#Get and parse stats
stats=$(curl -s http://${host}/api/platform/resources_usage -b /tmp/adcfortinetresource_session.${pid} | sed 's/{"payload":{//g' | sed 's/}}//' | sed 's/,/ /g' | xargs)

#Logout and delete cookie
curl -s http://${host}/api/user/logout -b /tmp/adcfortinetresource_session.${pid} > /dev/null
rm /tmp/adcfortinetresource_session.${pid}


#Fetch right flag dependly on resource argument
cpu=$(for i in $stats; do echo $i; done | grep cpu | sed 's/cpu://g')
ram=$(for i in $stats; do echo $i; done | grep ram | sed 's/ram://g')
disk=$(for i in $stats; do echo $i; done | grep disk | sed 's/disk://g')

#Resource flag check

if [ "${resource}" == "cpu" ]
then
    stat=$cpu
elif [ "${resource}" == "ram" ]
then
    stat=$ram
elif [ "${resource}" == "disk" ]
then
    stat=$disk
fi


if [ -z "${stat}" ]
then
    output="Unable to retrive ${resource} stat from ${host}"
    echo "CRITICAL - $output"
    exit 2
fi

if [[ ${stat} -lt ${warning} ]]
then
    output="Fortinet ADC ${resource} usage: ${stat}%"
    echo "OK - $output"
    exit 0

elif [[ ${stat} -ge ${warning} ]]&&[[ ${stat} -lt ${critical} ]]
then
    output="Fortinet ADC ${resource} usage: ${stat}%"
    echo "WARNING - $output"
    exit 1

elif [[ ${stat} -ge ${critical} ]]
then
    output="Fortinet ADC ${resource} usage: ${stat}%"
    echo "CRITICAL - $output"
    exit 2
fi
