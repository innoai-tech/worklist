package distribution

import (
	"encoding/xml"
	"path"

	"github.com/avast/apkparser"
)

func patchConfigByAndroid(c *Config, m *Manifest) error {
	zipErr, resErr, manErr := apkparser.ParseApk(path.Join(c.Context, m.Artifact), &androidManifestCollector{m: m})
	if zipErr != nil {
		return zipErr
	}
	if resErr != nil {
		return resErr
	}
	if manErr != nil {
		return manErr
	}
	return nil
}

type androidManifestCollector struct {
	m *Manifest
}

func (c *androidManifestCollector) EncodeToken(t xml.Token) error {
	switch x := t.(type) {
	case xml.StartElement:
		switch x.Name.Local {
		case "manifest":
			for _, attr := range x.Attr {
				switch attr.Name.Local {
				case "package":
					c.m.Annotate("android.package", attr.Value)
				case "versionName":
					c.m.Annotate("android.versionName", attr.Value)
				case "versionCode":
					c.m.Annotate("android.versionCode", attr.Value)
				}
			}
		}
	}

	return nil
}

func (c *androidManifestCollector) Flush() error {
	return nil
}
