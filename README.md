# book-managment

RUN \
  apt-get update && \
  apt-get remove -y curl && \
  apt-get install -y ruby3.1 --no-install-recommends && \
  rm -rf /var/lib/apt/lists/*


RUN \
  apt-get update && \
  apt-get remove -y curl && \
  apt-get install -y ruby3.1=3.1.2-7 --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*