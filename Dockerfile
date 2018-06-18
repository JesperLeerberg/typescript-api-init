# ---- Base Node ----
FROM node:9.5.0-alpine AS base
WORKDIR /usr/src/app
# copy project file
COPY package.json .

# ---- Dependencies ----
FROM base AS dependencies
# install node packages
RUN npm set progress=false && npm config set depth 0
RUN npm install --only=production 
# copy production node_modules aside
RUN cp -R node_modules prod_node_modules
# install ALL node_modules, including 'devDependencies'
RUN npm install

# ---- Typescript ----
FROM dependencies AS typescript
COPY src ./src
COPY tsconfig.json tsconfig.json
RUN npm run tsc 

# ---- Release ----
FROM base
# copy production node_modules
COPY --from=dependencies /usr/src/app/prod_node_modules ./node_modules
# copy app sources
COPY --from=typescript /usr/src/app/build ./build
# expose port and define CMD
EXPOSE 4444
CMD npm run start