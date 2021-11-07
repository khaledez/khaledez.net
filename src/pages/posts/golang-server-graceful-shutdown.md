---
title: Golang Server Graceful Shutdown
date: "2020-05-03T04:04:46.318Z"
publishDate: 'Sunday, May 03 2020'
description: Using context to gracefully shutdown an HTTP Server in Golang
layout: '../../layouts/BlogPost.astro'
---

You always need to shutdown your server for maintenance, 
so it’s important when you do, you don’t kill the connections while they are still serving the clients.

Golang standard http server implementation comes with a graceful shutdown functionality [net/http#Server.Shutdown](https://golang.org/pkg/net/http/#Server.Shutdown). 
So you don't need to worry about the details of closing connections yourself.

However, you need to call this method once a shutdown signal is received.

Golang documentation uses channels to communicate between the goroutine which listens to OS signals (SIGINT, SIGHUP) and the main goroutine which listens to network connections.

In this post, I'm gonna use [context.Context](https://golang.org/pkg/context/#Context)

```go
package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"
)

func main() {
	srv := &http.Server{
		Addr:    ":8080",
		// Add more attributes
	}

	// we define a context for shutdown, we can set a timeout for shutdown,
	// if some connections don't finish on time just kill them,
	// here I'll give the connections 10 seconds to finish their operations
	timeoutContext, doCancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer doCancel()
	shutdownContext, doShutdown := context.WithCancel(timeoutContext)

	go listenForSignals(shutdownContext, doShutdown, srv)

	if err := srv.ListenAndServe(); err != http.ErrServerClosed {
		// Error starting or closing listener:
		log.Fatalf("HTTP server ListenAndServe: %v", err)
	}

	<-shutdownContext.Done()
}

func listenForSignals(ctx context.Context, doShutdown context.CancelFunc, srv *http.Server) {
	sigint := make(chan os.Signal, 1)
	signal.Notify(sigint, os.Interrupt, os.Kill)
	<-sigint

	// We received an interrupt signal, shut down.
	log.Println("Shutting down ..")
	if err := srv.Shutdown(ctx); err != nil {
		// Error from closing listeners, or context timeout:
		log.Printf("HTTP server Shutdown: %v", err)
	}
	doShutdown()
}
```
