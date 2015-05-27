FROM debian:wheezy
MAINTAINER Quentin Devos <q.devos@student.uclouvain.be>, Loic Fortemps <loic.fortemps@student.uclouvain.be>
 
RUN apt-get update && apt-get install -y \
        --no-install-recommends \
        --no-install-suggests \
	autoconf \
	automake \
	ca-certificates \
	gcc \
	git \
	g++ \
	libtool \
	make \
	net-tools \
	patch \
	tcpdump \
	unzip \
	wget

RUN mkdir experience

WORKDIR /tmp

RUN git clone https://github.com/multipathdtls/wolfssl-mpdtls.git && cd wolfssl-mpdtls/ && \
	./autogen.sh && \
	./configure --enable-mpdtls --enable-debug --enable-dh --enable-ecc --disable-examples --disable-oldtls && \
	make install && cd .. && \
	rm -rf wolfssl-mpdtls/

RUN git clone git://github.com/mininet/mininet.git && \
	sed -e 's/sudo //g' \
	-e 's/\(apt-get -y install\)/\1 --no-install-recommends --no-install-suggests/g' \
	-i mininet/util/install.sh && \
	mininet/util/install.sh -nfv -s / && \
	rm -rf mininet/ openflow/

RUN wget http://traffic.comics.unina.it/software/ITG/codice/D-ITG-2.8.1-r1023-src.zip -O DITG.zip && \
	unzip DITG.zip -d DITG && rm DITG.zip && cd DITG/ && \
	mv `ls`/* . && \
	make -C src

ENV PATH /tmp/DITG/bin:$PATH

RUN git clone https://github.com/multipathdtls/mpdtls-vpn.git && cd mpdtls-vpn/ && \
	make && \
	cp -r client server certs/ /experience/ && cd .. && \
	rm -rf mpdtls-vpn

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY minitopo/src/ /tmp/minitopo

ENV PYTHONPATH /tmp/minitopo:$PYTHONPATH

WORKDIR /experience

COPY minitopo/src/mpPerf.py mpPerf.py

COPY conf conf

COPY xp xp

COPY script.itg script.itg

COPY bootstrap bootstrap

COPY run_var_bw run_var_bw

COPY run_var_loss run_var_loss

VOLUME ["/experience/data"]

ENTRYPOINT ["./bootstrap"]
