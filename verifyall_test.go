package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"path/filepath"
	"testing"

	"github.com/wallix/awless/aws/driver"
	"github.com/wallix/awless/config"
	"github.com/wallix/awless/template"
)

func TestCompileAllTemplates(t *testing.T) {
	path := filepath.Join(".", "*.aws")
	files, err := filepath.Glob(path)
	if err != nil {
		t.Fatal(err)
	}

	templates := make(map[string]*template.Template)

	fileCount := len(files)
	for _, file := range files {
		b, err := ioutil.ReadFile(file)
		if err != nil {
			t.Fatal(err)
		}

		meta, err := parseTemplateMetadata(b)
		if err != nil {
			t.Fatalf("parsing template metadata: %s", err)
		}

		if meta.MinimalVersion != "" {
			comp, err := config.CompareSemver(config.Version, meta.MinimalVersion)
			if err != nil {
				t.Errorf("version from '%s' template: %s", file, err)
			}
			if comp < 0 {
				t.Logf("ignoring %s as at least %s version required\n", file, meta.MinimalVersion)
				fileCount--
				continue
			}
		}

		if tpl, err := template.Parse(string(b)); err != nil {
			t.Error(fmt.Errorf("cannot parse template '%s'\n\n%s\n%s", file, b, err))
		} else {
			templates[fmt.Sprint(file)] = tpl
		}
	}

	if fileCount != len(templates) {
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
