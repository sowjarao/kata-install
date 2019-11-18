FROM debian 

COPY runin-container.sh .
COPY install.sh .

RUN chmod u+x runin-container.sh
RUN chmod u+x install.sh

RUN mkdir host
CMD ["./runin-container.sh"]
