FROM python:3.7.4
LABEL MAINTAINER=ningpeng@ibmsp.com.cn
ENV TZ=Asia/Shanghai
ENV smokeping_home_dir=/usr/local/smokeping
WORKDIR /tmp
COPY sources.list /etc/apt/sources.list
RUN set -x && \
    apt-get update && \
    apt install rrdtool  librrd-dev  libssl-dev fping libffi-dev cron git -y && \
    wget https://oss.oetiker.ch/smokeping/pub/smokeping-2.7.3.tar.gz && \
    pip3 install requests flask rrdtool pycurl lxml IPy retrying -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    git clone  https://github.com/skyisfuck/idc_ping_monitor.git && \
    tar xf smokeping-2.7.3.tar.gz && \
    cd smokeping-2.7.3 && \
    ./configure --prefix=/usr/local/smokeping && \
    make && make install && \
    cd $smokeping_home_dir/etc && \
    sed -i 's/192.168.56.101/prometheus-server/' /tmp/idc_ping_monitor/collection_to_prometheus.py && \
    cp -rf /tmp/idc_ping_monitor/smokeping/* ./ && \
    cp -rf /tmp/idc_ping_monitor/*.py $smokeping_home_dir && \
    mkdir -p $smokeping_home_dir/cache && \
    mkdir -p $smokeping_home_dir/data && \
    mkdir -p $smokeping_home_dir/var && \
    chmod 600 $smokeping_home_dir/etc/smokeping_secrets.dist && \
    service cron start && \
    echo "* * * * *  python /usr/local/smokeping/collection_to_prometheus.py" >> /var/spool/cron/crontabs/root && \
    rm -rf /var/lib/apt/lists/*

CMD ["/usr/local/smokeping/bin/smokeping", "--nodaemon"]
