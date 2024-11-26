FROM golang:1.22-alpine AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o DataProxyService .

FROM alpine:3
WORKDIR /app
COPY --from=build /app/DataProxyService /app/
COPY --from=build /app/sql/prepare.sql /app/sql/
USER nobody
EXPOSE 9180
ENTRYPOINT ["/app/DataProxyService"]