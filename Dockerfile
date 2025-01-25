# Use latest stable channel SDK.
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copia o diretório de imagens para o contêiner
COPY ./images/ /app/images/

# Copia o código da aplicação e compila AOT
COPY . .
RUN dart compile exe bin/server.dart -o bin/server

# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/
COPY --from=build /app/images /app/images/  # Inclui as imagens no contêiner final

# Start server.
EXPOSE 8080
CMD ["/app/bin/server"]
