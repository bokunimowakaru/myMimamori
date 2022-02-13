#!/bin/bash
#############
# login det for CentOS; SSH ログイン を監視する
#############

KEY="xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   # IFTTTのKey(鍵)
URL="https://maker.ifttt.com/trigger/"              # IFTTTのURL(変更不要)
IP_TALK="192.168.1.10"                              # Wi-Fiコンシェルジェ音声アナウンス担当

if [ "${1}" = "std_in" ]; then
    while read stdin; do
        data=`echo ${stdin}|grep -e "password" -e "Failed"`
        if [ -n "${data}" ]; then
            DATE=`date "+%Y/%m/%d %R"`
            data=`echo ${data}|cut -d" " -f6-`
            if [ -n "${data}" ]; then
                event=`echo ${data}|cut -d" " -f1`
                DATA=""
                if [ "${event}" = "Failed" ] || [ "${event}" = "FAILED" ]; then
                    DATA="CentOSに不正なSSHアクセスがありました。ログを確認してください。"
                    # curl -s -m3 ${IP_TALK}/?TEXT=\"${DATA}\"\&VOL=100 &> /dev/null &
                    curl -X POST -H "Content-Type: application/json" -d '{"value1":"'${DATA}'"}' ${URL}notify/with/key/${KEY} &> /dev/null &
                fi
                if [ "${event}" = "Accepted" ]; then
                    user=`echo ${data}|cut -d" " -f4`
                    if [ "${user}" = "root" ]; then
                        DATA="ルートへのアクセスがありました。"
                        # curl -s -m3 ${IP_TALK}/?TEXT=\"${DATA}\"\&VOL=50 &> /dev/null &
                        curl -X POST -H "Content-Type: application/json" -d '{"value1":"'${DATA}'"}' ${URL}notify/with/key/${KEY} &> /dev/null &
                    else
                        DATA="ログインしました。"
                        # curl -s -m3 ${IP_TALK}/?TEXT=\"${DATA}\"\&VOL=50 &> /dev/null &
                    fi
                fi
                if [ -n "${DATA}" ]; then
                    echo ${DATE},${data} | tee -a login_det.log
                fi
            fi
        fi
    done
    exit
else
    while true; do
        nice -n 10 tail -F /var/log/secure| ${0} std_in
    done
    exit
fi
exit
###########################################################################
tail -F /var/log/secure | grep password |awk '{print "{\"value1\":\""$6"\"}"}'|curl -s -m3 -XPOST -H "Content-Type: application/json" -d @- ${URL}notify/with/key/${KEY}

sudo su
cd
cat > login_det.sh
ペースト
[Ctrl]+[D]
chmod a+x login_det.sh
sudo cat >> /etc/rc.local
nohup /root/login_det.sh &> /dev/null &
[Ctrl]+[D]
chmod +x /etc/rc.d/rc.local
# exitがあるばあいは、exitの前に移動

# Please note that you must run 'chmod +x /etc/rc.d/rc.local' to ensure
# that this script will be executed during boot.
