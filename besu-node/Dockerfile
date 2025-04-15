FROM

ARG isBoot
ARG mode
ARG numDir

RUN if [ "$mode" == "new" ]; then \
    ./script/creationBesu.sh; \
    while ! [ -d "./config/genesis.json" ]; do \
        sleep 1; \
    done; \
fi

RUN if [  "$isBoot" == "true"  ]; then \
    ./script/recuperationEnode.sh "./data-node/Node-${numDir}";\
fi