package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"path/filepath"
	"testing"

	"github.com/wallix/awless/template"
	"github.com/wallix/awless/aws/driver"
)

func TestCompileAllTemplates(t *testing.T) {
	path := filepath.Join(".", "*.aws")
	files, err := filepath.Glob(path)
	if err != nil {
		t.Fatal(err)
	}

	templates := make(map[string]*template.Template)

	for _, file := range files {
		b, err := ioutil.ReadFile(file)
		if err != nil {
			t.Fatal(err)
		}
		if tpl, err := template.Parse(string(b)); err != nil {
			t.Error(fmt.Errorf("cannot parse template '%s'\n\n%s\n%s", file, b, err))
		} else {
			templates[fmt.Sprint(file)] = tpl
		}
	}

	if len(files) != len(templates) {
		t.Fatal("compilation run only on all templates parsed successfully")
	}

	for name, tpl := range templates {
		if _, _, err := template.Compile(tpl, awsdriver.DefaultTemplateEnv(), template.LenientCompileMode); err != nil {
			t.Fatalf("cannot compile template '%s'\n%s", name, err)
		} else {
			log.Printf("successfully parsed and compiled '%s'\n", name)
		}
	}
}
