package main

import (
	"log"

	"github.com/deis/logbomb/logbomb"
)

func main() {
	logBomb, err := logbomb.NewLogBomb()
	if err != nil {
		log.Fatalf("error building a log bomb: %s", err)
	}
	if err := logBomb.Detonate(); err != nil {
		log.Fatalf("error detonating the log bomb: %s", err)
	}
}
