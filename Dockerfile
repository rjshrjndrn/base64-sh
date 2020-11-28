FROM node:12
COPY . /work
WORKdir /work/themes/terminal
RUN npm i

FROM nginx
COPY --from=0 /work/public /usr/share/nginx/html
