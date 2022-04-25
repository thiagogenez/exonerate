# same version as in Codon
FROM centos:centos8.3.2011 AS builder

# Fix Failed to download metadata for repo ‘AppStream’ [CentOS]
# https://techglimpse.com/failed-metadata-repo-appstream-centos-8/
RUN cd /etc/yum.repos.d/ && \
  sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Preparing the environment
RUN yum update -y && yum install -y epel-release
RUN yum groupinstall "Development Tools" -y   
RUN yum install -y \
  wget \
  autoconf \
  gcc \
  automake \
  make \
  glib2-devel

# compile
WORKDIR /usr/src/app
COPY . .
RUN autoreconf -i \
  && ./configure \
  && make -j \
  && make test \
  && make install \
  && rm -rf /usr/src/app


# lighweight image
FROM centos:centos8.3.2011

# Fix Failed to download metadata for repo ‘AppStream’ [CentOS]
# https://techglimpse.com/failed-metadata-repo-appstream-centos-8/
RUN cd /etc/yum.repos.d/ && \
  sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# intall dependencies
RUN yum update -y && yum install -y glib2-devel

# copy the exonerate binaries
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/share/man /usr/local/share/man

# cleanup
RUN yum clean all
RUN rm -rf /var/cache/yum/*

WORKDIR /usr/local
#ENTRYPOINT ["/usr/local/bin/exonerate"]
