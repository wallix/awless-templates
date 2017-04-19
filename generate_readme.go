package main

import (
	"bufio"
	"bytes"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"text/template"
)

func main() {
	log.SetFlags(0)

	t, err := template.ParseFiles("./README_TEMPLATE.md")
	if err != nil {
		log.Fatal(err)
	}

	f, err := os.Create("./README.md")
	if err != nil {
		log.Fatal(err)
	}

	examples, err := buildExamples()
	if err != nil {
		log.Fatal(err)
	}

	if err := t.Execute(f, examples); err != nil {
		log.Fatal(err)
	}
}

type Example struct {
	Title, Link, ScriptName string
	Content                 string
}

func buildExamples() ([]*Example, error) {
	var examples []*Example

	path := filepath.Join(".", "*.aws")
	files, err := filepath.Glob(path)
	if err != nil {
		return examples, err
	}

	for _, filename := range files {
		name := strings.TrimSuffix(filename, filepath.Ext(filename))
		title := fmt.Sprintf("%s", humanize(name))
		link := fmt.Sprintf("%s", markdownTitleLink(name))

		content, err := parseFile(filename)
		if err != nil {
			return examples, nil
		}
		examples = append(examples, &Example{Title: title, ScriptName: name, Link: link, Content: content})
	}

	return examples, nil
}

func parseFile(filename string) (string, error) {
	f, err := os.Open(filename)
	if err != nil {
		return "", err
	}

	var buff bytes.Buffer
	var openCodeSection bool

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		text := strings.TrimSpace(scanner.Text())

		if text == "" {
			continue
		}

		if strings.HasPrefix(text, "#") {
			if openCodeSection {
				buff.WriteString("\n```\n")
				openCodeSection = false
			}
			clean := strings.Replace(text, "#", "", -1)
			buff.WriteString(clean)
			buff.WriteString("\n")
		} else {
			if !openCodeSection {
				buff.WriteString("\n```sh\n")
				openCodeSection = true
			}
			buff.WriteString(text)
			buff.WriteString("\n")
		}
	}

	if openCodeSection {
		buff.WriteString("```\n")
	}

	return buff.String(), nil
}

func humanize(s string) string {
	out := strings.Replace(s, "_", " ", -1)
	if len(s) > 0 {
		return strings.ToUpper(string(out[0])) + out[1:]
	}
	return out
}

func markdownTitleLink(s string) string {
	return strings.Replace(s, "_", "-", -1)
}
