function wifi
    set -q argv[1]; or begin
        echo "Usage: wifi <network>"
        return 1
    end

    set -l name $argv[1]
    set -l identity perry3
    if test $name = eduroam
        set identity "$identity@ualberta.ca"
    end

    nmcli c add type wifi ifname wlan0 con-name "$name" ssid "$name"
    nmcli c modify "$name" wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 802-1x.identity $identity 802-1x.domain-suffix-match "ualberta.ca" 802-1x.password I-Hate-Windows
    nmcli c up "$name" --ask
end
