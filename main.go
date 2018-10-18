package main

import (
	"bufio"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strconv"
	"strings"
)

func main() {
	registry := flag.String("path", "", "Path to the DN42 registry")
	routeType := flag.Int("type", 4, "4: IPv4 Route / 6: IPv6 Route")
	flag.Parse()
	if *registry == "" || (*routeType != 4 && *routeType != 6) {
		flag.Usage()
		os.Exit(2)
	}
	mkroa(*registry, *routeType)
}

func mkroa(registry string, routeType int) {
	var folderName string
	if routeType == 4 {
		folderName = "/data/route/"
	} else {
		folderName = "/data/route6/"
	}
	files, err := ioutil.ReadDir(registry + folderName)
	if err != nil {
		log.Fatal(err)
	}
	for _, file := range files {
		var maxLength int
		length, _ := strconv.Atoi(strings.Split(file.Name(), "_")[1])
		if length >= 28 {
			maxLength = length
		} else {
			maxLength = 28
		}
		if routeType == 6 {
			maxLength = 64
		}
		f, err := os.Open(registry + folderName + file.Name())
		if err != nil {
			log.Fatal(err)
		}
		scanner := bufio.NewScanner(f)
		for scanner.Scan() {
			if strings.HasPrefix(scanner.Text(), "origin:") {
				fmt.Printf("route %s max %d as %s;\n", strings.Replace(file.Name(), "_", "/", 1), maxLength, scanner.Text()[22:])
			}
		}
		f.Close()
	}
}
