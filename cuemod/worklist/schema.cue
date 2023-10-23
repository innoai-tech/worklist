package worklist

#Field: #String | #Number | #Boolean | #Object | #Array

#String: {
	type:  "string"
	meta?: #Meta
}

#Number: {
	type:  "number"
	meta?: #Meta
}

#Boolean: {
	type:  "boolean"
	meta?: #Meta
}

#Object: {
	type: "object"
	properties: [Name=string]: #Field
	meta?: #Meta
}

#Array: {
	type:  "array"
	items: #Field
	meta?: #Meta
}

#Ex: [string, ...]

#MetaCommon: {
	label:        string
	description?: string
	help?:        string
	condition?:   #Ex
	validate?:    #Ex
}

#Meta: {
	#Input | #Select | #Autocomplete | #FileUploader

	#MetaCommon
}

#Input: {
	type:     "input"
	format?:  string // "tel"
	pattern?: string
	mask?:    string
}

#Select: {
	type: "select"
	options: [{
		label: string
		// value of type
		value: _
	}]
	// multiple allowed when value type is array
}

#Autocomplete: {
	type: "autocomplete"
	// "https://xxx?q={}"
	search: string
	// multiple allowed when value type is array
}

#FileUploader: {
	type: "file"
	// ext limit
	// see more https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/file
	accept?: "image/*"
}
