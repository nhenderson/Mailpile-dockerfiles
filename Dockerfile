FROM ubuntu:14.04
MAINTAINER Nathan Henderson <nhenderson@ipg.com>
# Update packages lists
RUN apt-get update -y

# Force -y for apt-get
RUN echo "APT::Get::Assume-Yes true;" >> /etc/apt/apt.conf

RUN apt-get install make git supervisor

# We need to add a config file for supervisor, so stop the service that was auto-started on intstall
RUN service supervisor stop

# Clone the Mailpile repo to the root directory
git clone -b release/beta https://github.com/pagekite/Mailpile.git /Mailpile

# NOTE: Mailpile's Makefile handles installing the Mailpile dependencies via APT
ADD Makefile /Mailpile/Makefile
WORKDIR /Mailpile
RUN make debian-dev

# Add code
ADD . /Mailpile

# Setup
RUN ./mp setup

# Initialization and Startup Script (start Mailpile via supervisor)
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

EXPOSE 33411
VOLUME /.mailpile

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/bin/bash", "/start.sh"]
