FROM node:12-alpine3.9
COPY . /work
ADD https://github.com/gohugoio/hugo/releases/download/v0.79.0/hugo_0.79.0_Linux-64bit.tar.gz /usr/local/bin
RUN tar -xf /usr/local/bin/hugo_0.79.0_Linux-64bit.tar.gz -C /usr/local/bin/
WORKdir /work/themes/terminal
RUN npm i
RUN cd ../../ && hugo --minify --buildDrafts

FROM nginx
COPY --from=0 /work/public /usr/share/nginx/html
