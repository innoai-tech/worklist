package convert

import (
	"context"
	"fmt"
	"github.com/innoai-tech/worklist/pkg/jtd"
)

func ToJSONSchema(schema jtd.Schema) (results map[string]any) {
	defer func() {
		if meta := schema.Meta(); meta != nil {
			// FIXME
		}

		if defs := schema.Defs(); defs != nil {
			definitions := map[string]any{}

			for name, s := range defs {
				definitions[name] = ToJSONSchema(s)
			}

			results["$schema"] = "https://json-schema.org/draft/2020-12/schema"
			results["$defs"] = definitions
		}
	}()

	switch x := schema.(type) {
	case *jtd.Basic:
		switch x.Type {
		case jtd.TypeUint8, jtd.TypeUint16, jtd.TypeUint32, jtd.TypeUint64:
		case jtd.TypeInt8, jtd.TypeInt16, jtd.TypeInt32, jtd.TypeInt64:
			return map[string]any{
				"type":   "integer",
				"format": x.Type,
			}
		case jtd.TypeFloat32, jtd.TypeFloat64:
			return map[string]any{
				"type":   "number",
				"format": x.Type,
			}
		case jtd.TypeString, jtd.TypeBoolean:
			return map[string]any{
				"type": x.Type,
			}
		case jtd.TypeTimestamp:
			return map[string]any{
				"type":   "string",
				"format": "date-time",
			}
		default:
			return map[string]any{
				"type":   "string",
				"format": x.Type,
			}
		}
	case *jtd.List:
		return map[string]any{
			"type":  "array",
			"items": ToJSONSchema(x.Elements),
		}
	case *jtd.Object:
		properties := map[string]any{}
		required := make([]string, 0)

		for e := range x.Properties.Iter(context.Background()) {
			properties[e.Key] = ToJSONSchema(e.Value)
			required = append(required, e.Key)
		}

		for e := range x.OptionalProperties.Iter(context.Background()) {
			properties[e.Key] = ToJSONSchema(e.Value)
		}

		return map[string]any{
			"type":       "object",
			"properties": properties,
			"required":   required,
		}
	case *jtd.Map:
		return map[string]any{
			"type":                 "object",
			"propertyNames":        ToJSONSchema(x.PropertyNames),
			"additionalProperties": ToJSONSchema(x.Values),
		}
	case *jtd.Ref:
		return map[string]any{
			"$ref": fmt.Sprintf("#/$defs/%s", x.Ref),
		}
	case *jtd.Any:
		return map[string]any{}
	}

	return map[string]any{}
}
