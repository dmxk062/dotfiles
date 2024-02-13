#!/usr/bin/env bash

vpns=""
active_vpn=""
ether=""

update(){
    eww -c "$XDG_CONFIG_HOME/eww/settings" update "$@"
}

VPN_ENABLED=false


VPN=false
ETHER=false
WIFI=false

append_vpn(){
    name="$1"
    active="$2"
    uuid="$3"
    dev="$4"

    if [[ "$active" == "true" ]]; then
        VPN_ENABLED=true
    fi

    config_data="$(nmcli connection show "$name")"
    data_field="$(echo "$config_data"|grep "vpn.data" \
    |sed 's/^vpn\.data:\s\+//' \
    |sed 's/\\\,/_ESCAPED_COMMA_/g; s/,/\n/g; s/_ESCAPED_COMMA_/\,/g')"
    while read -r line; do
        IFS=" = " read -r field value <<< "$line"
        case $field in
            ca)
                certificate_path="$value";;
            cipher)
                cipher="$value";;
            connection-type)
                authtype="$value";;
            username)
                username="$value";;
            remote)
                addresses_f="["
                IFS=", " read -ra addresses <<< "$value"
                for addr in "${addresses[@]}"; do
                    IFS=":" read -r ip port <<< "$addr"
                    format="{\"ip\":\"$ip\",\"port\":$port}"
                    if [[ "$addresses_f" == "[" ]]; then
                        addresses_f="[$format"
                    else
                        addresses_f+=",$format"
                    fi
                done
                addresses_f+="]"
                ;;

        esac
    done <<< "$data_field"
    formatted="$(
    printf '{"active":%s,"name":"%s","uuid":"%s","device":"%s","cert":"%s","cipher":"%s","authtype":"%s","user":"%s","addresses":%s}' \
        "$active" "$name" "$uuid" "$dev" "$certificate_path" "$cipher" "$authtype" "$username" "$addresses_f")"
    if [[ "$vpns" == "" ]]; then
        vpns="[$formatted"
    else
        vpns+=",$formatted"
    fi

    if [[ "$active" == "true" ]]; then
        active_vpn="$formatted"
    fi
}

append_ether(){
    name="$1"
    active="$2"
    uuid="$3"
    dev="$4"

    config_data="$(nmcli connection show "$name"|tr -d ' ')"
    while read -r line; do
        IFS=":" read -r field value <<< "$line"
        case $field in
            connection.zone)
                if [[ "$value" == "--" ]]; then
                    zone=null
                else
                    zone=\"$value\"
                fi
                ;;
            'IP4.DNS[1]')
                dns="$value"
                ;;
            'IP4.ADDRESS[1]')
                addr4="$value"
                ;;
            'IP6.ADDRESS[1]')
                addr6="$value"
                ;;
            'DHCP4.OPTION'*)
                IFS="=" read -r key val <<< "$value"
                case $key in
                    host_name)
                        modemhost="$val"
                        ;;
                    ip_address)
                        dhcp_ip="$val"
                        ;;
                    subnet_mask)
                        subnet_mask="$val";;
                    domain_name_servers)
                        dhcp_server_ip="$val";;
                esac

        esac
    done <<< "$config_data"
    formatted="$(printf '{"active":%s,"name":"%s","uuid":"%s","device":"%s","addresses":{"ipv4":"%s", "ipv6":"%s"},
"dhcp":{"server_host":"%s", "leased_ip":"%s","mask":"%s", "server_ip":"%s"}}' \
    "$active" "$name" "$uuid" "$dev" "$addr4" "$addr6" "$modemhost" "$dhcp_ip" "$subnet_mask" "$dhcp_server_ip")"
    if [[ "$ether" == "" ]]; then
        ether="[$formatted"
    else
        ether+=",$formatted"
    fi

}

list_all(){

while read -r line; do
    IFS=":" read -r active type dev uuid name <<< "$line"
    if [[ "$active" == "yes" ]]; then
        connected=true
    else
        connected=false
    fi
    case $type in 
        vpn)
            $VPN&&append_vpn "$name" "$connected" "$uuid" "$dev"
            ;;
        *ethernet)
            $ETHER&&append_ether "$name" "$connected" "$uuid" "$dev"
            ;;
    esac

done<<<"$(nmcli --terse --get-values ACTIVE,TYPE,DEVICE,UUID,NAME, connection)"

}


public(){
    curl -s ipinfo.io
}


update net_loading=true
case $1 in
    list)
        case $2 in
            vpn)
                VPN=true;;
            ether)
                ETHER=true;;
        esac
                
        list_all
        case $2 in
            vpn)
                vpns+="]"
                echo "$vpns"
                ;;
            ether)
                ether+="]"
                echo "$ether"
        esac
        ;;

    update)
        case $2 in
            all)
                VPN=true
                ETHER=true
                list_all
                ether+="]"
                vpns+="]"
                eww -c "$XDG_CONFIG_HOME/eww/settings" update "net_public"="$(public)" "net_active_vpn"="$active_vpn" \
                    "net_ether"="$ether" "net_vpn"="$vpns" "net_vpn_enabled"="$VPN_ENABLED"
                ;;
            vpn)
                VPN=true
                list_all
                vpns+="]"
                eww -c "$XDG_CONFIG_HOME/eww/settings" update "net_public"="$(public)" "net_active_vpn"="$active_vpn" \
                    "net_vpn"="$vpns" "net_vpn_enabled"="$VPN_ENABLED"
        esac
        ;;
esac

update net_loading=false

