package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"path/filepath"
	"regexp"
	"strings"
	"text/template"
)

var (
	metadataTypes = []string{"Title", "Tags", "Description", "CLIExample", "MinimalVersion"}
	metadataRegex = regexp.MustCompile(fmt.Sprintf("#\\s*(%s):\\s*(.+)\\s*", strings.Join(metadataTypes, "|")))
)

func main() {
	log.SetFlags(0)

	t, err := template.New("README_TEMPLATE.md").Funcs(template.FuncMap{
		"Join":              strings.Join,
		"MarkdownTitleLink": markdownTitleLink,
	}).ParseFiles("./README_TEMPLATE.md")
	if err != nil {
		log.Fatal(err)
	}

	examples, err := buildExamples()
	if err != nil {
		log.Fatal(err)
	}

	var buff bytes.Buffer
	if err := t.Execute(&buff, examples); err != nil {
		log.Fatal(err)
	}

	if err := ioutil.WriteFile("./README.md", buff.Bytes(), 0666); err != nil {
		log.Fatal(err)
	}

	if err := writeManifest(examples); err != nil {
		log.Fatal(err)
	}
}

type Metadata struct {
	Title, CLIExample           string   `json:",omitempty"`
	Description, MinimalVersion string   `json:",omitempty"`
	Tags                        []string `json:",omitempty"`
}

type Example struct {
	*Metadata
	Name, Link    string `json:",omitempty"`
	Documentation string `json:"-"`
}

func buildExamples() ([]*Example, error) {
	var examples []*Example

	path := filepath.Join(".", "*.aws")
	files, err := filepath.Glob(path)
	if err != nil {
		return examples, err
	}

	for _, filename := range files {
		ex, err := buildExample(filename)
		if err != nil {
			return examples, nil
		}
		examples = append(examples, ex)
	}

	return examples, nil
}

func buildExample(filename string) (*Example, error) {
	content, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, err
	}
	doc, err := buildTemplateDoc(content)
	if err != nil {
		return nil, err
	}
	meta, err := parseTemplateMetadata(content)
	if err != nil {
		return nil, err
	}

	name := strings.TrimSuffix(filename, filepath.Ext(filename))
	link := fmt.Sprintf("https://raw.githubusercontent.com/wallix/awless-templates/master/%s.aws", name)
	if strings.TrimSpace(meta.Title) == "" {
		meta.Title = fmt.Sprintf("%s", humanize(name))
	}
	var tags []string
	for _, raw := range meta.Tags {
		tags = append(tags, strings.TrimSpace(raw))
	}

	return &Example{Metadata: meta, Link: link, Name: name, Documentation: doc}, nil
}

func parseTemplateMetadata(content []byte) (*Metadata, error) {
	metadata := make(map[string]interface{})
	scanner := bufio.NewScanner(bytes.NewReader(content))
	for scanner.Scan() {
		match := metadataRegex.FindStringSubmatch(scanner.Text())
		if len(match) > 0 {
			if directive := strings.TrimSpace(match[1]); directive == "Tags" {
				metadata[directive] = splitTrim(match[2])
			} else {
				metadata[match[1]] = match[2]
			}
		}
	}

	b, err := json.Marshal(metadata)
	if err != nil {
		return nil, err
	}

	out := new(Metadata)
	if err := json.Unmarshal(b, out); err != nil {
		return nil, err
	}

	return out, nil
}

func buildTemplateDoc(content []byte) (string, error) {
	var buff bytes.Buffer
	var openCodeSection bool

	scanner := bufio.NewScanner(bytes.NewReader(content))
	for scanner.Scan() {
		text := strings.TrimSpace(scanner.Text())

		if text == "" || metadataRegex.MatchString(text) {
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

func writeManifest(ex []*Example) error {
	b, err := json.MarshalIndent(ex, "", " ")
	if err != nil {
		return err
	}
	return ioutil.WriteFile("manifest.json", b, 0644)
}

func humanize(s string) string {
	out := strings.Replace(s, "_", " ", -1)
	if len(s) > 0 {
		return strings.ToUpper(string(out[0])) + out[1:]
	}
	return out
}

func markdownTitleLink(s string) string {
	return strings.ToLower(strings.Replace(s, " ", "-", -1))
}

func splitTrim(s string) (out []string) {
	for _, e := range strings.Split(s, ",") {
		out = append(out, strings.TrimSpace(e))
	}
	return
}
