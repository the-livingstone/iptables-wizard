#!/bin/bash

# Test an IP address for validity:
# Usage:
#      valid_ip IP_ADDRESS
#      if [[ $? -eq 0 ]]; then echo good; else echo bad; fi
#   OR
#      if valid_ip IP_ADDRESS; then echo good; else echo bad; fi
#
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

function valid_mac()
{
    local  mac=$1
    local  stat=1

    if [[ $mac =~ ^[A-Fa-f0-9]{2}\:[A-Fa-f0-9]{2}\:[A-Fa-f0-9]{2}\:[A-Fa-f0-9]{2}\:[A-Fa-f0-9]{2}\:[A-Fa-f0-9]{2}$ ]]
    then
        stat=0
    fi
    return $stat
}
if [[ "$1" && "$2" && "$3" ]]
	then
		MAC=`sudo arp | grep $2 | awk '{ print $3 }'`
		echo "$MAC"
		case $1 in
			"input"|"INPUT" )
				CHAIN="INPUT"
				;;
			"forward"|"FORWARD" )
				CHAIN="FORWARD"
				;;
			* )
				echo "Usage: iptab [INPUT|FORWARD] [domain ip or name] [ACCEPT|REJECT|DROP] (optional: [protocol] [port number or name])"
				exit
				;;
		esac
		case $3 in
			"accept"|"ACCEPT" )
				ACT="ACCEPT"
				;;
			"reject"|"REJECT" )
				ACT="REJECT"
				;;
			"drop"|"DROP" )
				ACT="DROP"
				;;
			*)
				echo "Usage: iptab [INPUT|FORWARD] [domain ip or name] [ACCEPT|REJECT|DROP] (optional: [protocol] [port number or name])"
				exit
				;;
		esac
		if [[ "$4" && "$5" ]]
		then
			iptables -A $CHAIN -p $4 --dport $5 -m mac --mac-source $MAC -j $ACT 
			echo "iptables -A $CHAIN -p $4 --dport $5 -m mac --mac-source $MAC -j $ACT"
			/sbin/iptables-save  > /etc/iptables.rules
		else
			iptables -A $CHAIN -m mac --mac-source $MAC -j $ACT 
			echo "iptables -A $CHAIN -m mac --mac-source $MAC -j $ACT" 
			/sbin/iptables-save  > /etc/iptables.rules
		fi
	else
echo "Welcome to iptables editor!"
while :
do
	echo "Choose an option:"
	echo "1. Show iptables rules list"
	echo "2. Add new rule"
	echo "3. Delete existing rule"
	echo "4. Find a rule"
	echo "5. Exit"
	echo "?: "
	read a
	case "$a" in
		1 )
			cat | iptables -L -v
			;;
		2 )
			while :
			do
			echo "1. ip fiter"
			echo "2. mac filter"
			echo "?: "
			read b
			case "$b" in
				1 )
					while :
					do
						echo "enter source ip:"
						read SIP
						if valid_ip $SIP
						then
							echo "ok"
							break
						else
							echo "IP is not valid, try again"
						fi
					done
					while :
					do
						echo "enter destination ip:"
						read DIP
						if valid_ip $DIP
						then
							echo "ok"
							break
						else
							echo "IP is not valid, try again"
						fi
					done
					while :
					do
					echo "1. Input"
					echo "2. Output"
					echo "3. Forward"
					echo "?: "
					read c
					case "$c" in
						1 )
							CHAIN="INPUT"
							break
							;;
						2 )
							CHAIN="OUTPUT"
							break
							;;
						3 )
							CHAIN="FORWARD"
							break
							;;
						*)
							;;
					esac
					done
					while :
					do
						echo "specific port/protocol (Y/N)?"
						read q
						case "$q" in
							"Y"| "y" )
								echo "protocol (tcp, udp ...)"
								read PROTOCOL
								echo "port (ssh, telnet, 88, 443...)"
								read PORT
								break
								;;
							"N"| "n" )
								PORT=0
								PROTOCOL=0
								break
								;;
							*)
								;;
						esac
					done
					while :
					do
						echo "1. Accept connection"
						echo "2. Drop connection"
						echo "3. Reject connection"
						read conn
						case "$conn" in
							1 )
								ACT=ACCEPT
								break
								;;
							2 )
								ACT=DROP
								break
								;;
							3 )
								ACT=REJECT
								break
								;;
							* )
								;;
						esac
					done
					if [ $PORT != "0" ]; then
						if [ $DIP != "0" ]; then
							iptables -A $CHAIN -p $PROTOCOL --dport $PORT -s $SIP -d $DIP -j $ACT
							echo "iptables -A $CHAIN -p $PROTOCOL --dport $PORT -s $SIP -d $DIP -j $ACT"
							/sbin/iptables-save  > /etc/iptables.rules
						else
							iptables -A $CHAIN -p $PROTOCOL --dport $PORT -s $SIP -j $ACT
							echo "iptables -A $CHAIN -p $PROTOCOL --dport $PORT -s $SIP -j $ACT"
							/sbin/iptables-save  > /etc/iptables.rules
						fi
					else
						if [ $DIP != "0" ]; then
							iptables -A $CHAIN -s $SIP -d $DIP -j $ACT
							echo "iptables -A $CHAIN -s $SIP -d $DIP -j $ACT"
							/sbin/iptables-save  > /etc/iptables.rules
						else
							iptables -A $CHAIN -s $SIP -j $ACT
							echo "iptables -A $CHAIN -s $SIP -j $ACT"
							/sbin/iptables-save  > /etc/iptables.rules
						fi
					fi						
					break
					;;
				2 )
					while :
					do
						echo "enter mac:"
						read MAC
						if valid_mac $MAC
						then
							echo "ok"
							break
						else
							echo "mac is not valid, try again"
						fi
					done
					while :
					do
					echo "1. Input"
					echo "2. Forward"
					echo "?: "
					read c
					case "$c" in
						1 )
							CHAIN="INPUT"
							break
							;;
						2 )
							CHAIN="FORWARD"
							break
							;;
						*)
							;;
					esac
					done
					while :
					do
						echo "specific port/protocol (Y/N)?"
						read q
						case "$q" in
							"Y"| "y" )
								echo "protocol (tcp, udp ...)"
								read PROTOCOL
								echo "port (ssh, telnet, 88, 443...)"
								read PORT
								break
								;;
							"N"| "n" )
								PORT=0
								PROTOCOL=0
								break
								;;
							*)
								;;
						esac
					done
					while :
					do
						echo "1. Accept connection"
						echo "2. Drop connection"
						echo "3. Reject connection"
						read conn
						case "$conn" in
							1 )
								ACT=ACCEPT
								break
								;;
							2 )
								ACT=DROP
								break
								;;
							3 )
								ACT=REJECT
								break
								;;
							* )
								;;
						esac
					done

					# iptables -I INPUT -p tcp --dport 22 -m mac --mac-source 3E:D7:88:A6:66:8E -j REJECT

					if [ $PORT != "0" ]; then
						iptables -A $CHAIN -p $PROTOCOL --dport $PORT -m mac --mac-source $MAC -j $ACT
						echo "iptables -A $CHAIN -p $PROTOCOL --dport $PORT -m mac --mac-source $MAC -j $ACT"
						/sbin/iptables-save  > /etc/iptables.rules
					else
						iptables -A $CHAIN -m mac --mac-source $MAC -j $ACT
						echo "iptables -A $CHAIN -m mac --mac-source $MAC -j $ACT"
						/sbin/iptables-save  > /etc/iptables.rules
					fi
					break
					;;
				*)
					;;
			esac
			done
			;;
		3) 
			while :
			do
			echo "enter chain:"
			echo "1. Input"
			echo "2. Output"
			echo "3. Forward"
			read w
			case "$w" in
				1 )
					CHAIN=INPUT
					break
					;;
				2 )
					CHAIN=OUTPUT
					break
					;;
				3 )
					CHAIN=FORWARD
					break
					;;
				* )
					;;
			esac
			done
			echo "enter rule number in chain (start from 1):"
			read NUMBER
			iptables -D $CHAIN $NUMBER
			echo "iptables -D $CHAIN $NUMBER"
			/sbin/iptables-save  > /etc/iptables.rules
			;;
		4)
			echo "enter search string (ip, mac, port...):"
			read SEARCH
			cat iptables -L -v | grep $SEARCH
			;;
		5)
			break
			;;
		*)
			;;
	esac

done
fi