package main

import (
	"fmt"
	"os"

	"github.com/memphisdev/memphis.go"
)

func main() {
    // TODO: Read local CSV
    conn, err := memphis.Connect("memphis.bespin.local", "go_producer", memphis.Password("Go-P@55word"), memphis.AccountId(1))
    if err != nil {
        os.Exit(1)
    }
    defer conn.Close()

    p, err := conn.CreateProducer("ual", "gobin")
    if err != nil {
        fmt.Printf("Producer failed: %v", err)
        os.Exit(1)
    }

    hdrs := memphis.Headers{}
    hdrs.New()
    // err = hdrs.Add("<key>", "<value>")
	// if err != nil {
	// 	fmt.Printf("Header failed: %v", err)
	// 	os.Exit(1)
	// }

    err = p.Produce([]byte("You have a message!"), memphis.MsgHeaders(hdrs), memphis.AsyncProduce())
    if err != nil {
        fmt.Printf("Produce failed: %v", err)
    }
}
