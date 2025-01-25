# Use latest stable channel SDK.
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copiar o diretório images para o contêiner (certifique-se de que as imagens existam)
COPY /images/ /app/images/  # Copia as imagens para o contêiner

# Copiar o código da aplicação e compilar AOT
COPY . .
RUN dart compile exe bin/server.dart -o bin/server

# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/

# Adiciona as imagens no contêiner final
COPY --from=build /app/images /app/images/

# Start server.
EXPOSE 8080
CMD ["/app/bin/server"]
