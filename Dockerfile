FROM golang:1.20-alpine AS builder

WORKDIR /app

COPY app/go.* ./
RUN go mod tidy

COPY app/ .

RUN go build -o server .

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/server .
EXPOSE 8080

ENV PORT=8080

CMD ["./server"]