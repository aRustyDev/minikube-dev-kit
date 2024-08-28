package main

import (
	"fmt"
	"os"

	"encoding/csv"
	"log"

	"memphis-producer/protobuf"

	"github.com/memphisdev/memphis.go"
	"google.golang.org/protobuf/proto"
)

func main() {
	// Open the CSV file
	file, err := os.Open("data/ual.csv")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	// Create a new CSV reader
	reader := csv.NewReader(file)

	// Read all records
	records, err := reader.ReadAll()
	if err != nil {
		log.Fatal(err)
	}

    conn, err := memphis.Connect("memphis.bespin.local", "go_producer", memphis.Password("Go-P@55word"), memphis.AccountId(1))
    if err != nil {
		log.Fatal(err)
    }
    defer conn.Close()

    p, err := conn.CreateProducer("ual", "gobin")
    if err != nil {
        fmt.Printf("Producer failed: %v", err)
		log.Fatal(err)
    }

    hdrs := memphis.Headers{}
    hdrs.New()
    // err = hdrs.Add("<key>", "<value>")
	// if err != nil {
	// 	fmt.Printf("Header failed: %v", err)
	// 	os.Exit(1)
	// }

    // err = p.Produce([]byte("You have a message!"), memphis.MsgHeaders(hdrs), memphis.AsyncProduce())
	// if err != nil {
	// 	fmt.Printf("Produce failed: %v", err)
	// }

    // err = p.Produce([]byte("You have a message!"), memphis.MsgHeaders(hdrs), memphis.AsyncProduce())
	// if err != nil {
	// 	fmt.Printf("Produce failed: %v", err)
	// }

    err = p.Produce([]byte("You have a message!"), memphis.MsgHeaders(hdrs), memphis.AsyncProduce())
    if err != nil {
        fmt.Printf("Produce failed: %v", err)
    }

    // Iterate through records and send to Memphis
	for _, record := range records {
		// Create your protobuf message
		message := &protobuf.UalLog{
			ActivityDisplayName: record[0],
			AdditionalDetails: record[1],
            AppDisplayName: record[2],
			AppId: record[3],
			Category: protobuf.Category(protobuf.Category_value[record[4]]),
			CorrelationId: record[5],
			Id: record[6],
			IpAddress: record[7],
			LoggedByService: record[8],
			OperationType: protobuf.OperationType(protobuf.OperationType_value[record[9]]),
			Result: protobuf.Result(protobuf.Result_value[record[10]]),
			ResultReason: record[11],
			ServicePrincipalId: record[12],
			ServicePrincipalName: record[13],
			TargetResources: record[14],
			TenantId: record[15],
			TenantName: record[16],
			Ts: record[17],
			UserAgent: record[18],
			UserDisplayName: record[19],
			UserId: record[20],
			UserPrincipalName: record[21],
			UserType: record[22],
		}

		// Marshal the protobuf message
		data, err := proto.Marshal(message)
		if err != nil {
			log.Printf("Error marshaling message: %v", err)
			continue
		}

		// Produce the message
		err = p.Produce(data, memphis.MsgHeaders(hdrs))
		if err != nil {
			log.Printf("Error producing message: %v", err)
		} else {
			fmt.Println("Message sent successfully")
		}
	}
}
