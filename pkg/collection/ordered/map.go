package ordered

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strconv"

	"github.com/go-json-experiment/json/jsontext"
)

type Map[K comparable, V any] struct {
	kv map[K]*Element[K, V]
	ll list[K, V]
}

func (m *Map[K, V]) Get(key K) (value V, ok bool) {
	if m.kv != nil {
		v, ok := m.kv[key]
		if ok {
			value = v.Value
		}
	}
	return
}

func (m *Map[K, V]) Set(key K, value V) bool {
	if m.kv == nil {
		m.kv = map[K]*Element[K, V]{}
	}

	_, alreadyExist := m.kv[key]
	if alreadyExist {
		m.kv[key].Value = value
		return false
	}

	element := m.ll.PushBack(key, value)
	m.kv[key] = element
	return true
}

func (m *Map[K, V]) Delete(key K) (didDelete bool) {
	element, ok := m.kv[key]
	if ok {
		m.ll.Remove(element)
		delete(m.kv, key)
	}
	return ok
}

func (m *Map[K, V]) Len() int {
	return len(m.kv)
}

func (m *Map[K, V]) Iter(ctx context.Context) <-chan *Element[K, V] {
	ch := make(chan *Element[K, V])

	go func() {
		defer func() {
			close(ch)
		}()

		if m == nil {
			return
		}

		for el := m.ll.Front(); el != nil; el = el.Next() {
			select {
			case <-ctx.Done():
			case ch <- el:
			}
		}
	}()

	return ch
}

func (m Map[K, V]) MarshalJSON() ([]byte, error) {
	b := bytes.NewBuffer(nil)

	b.WriteString("{")

	idx := 0
	for e := range m.Iter(context.Background()) {
		if idx > 0 {
			b.WriteString(",")
		}

		b.WriteString(strconv.Quote(fmt.Sprint(e.Key)))
		b.WriteString(":")
		valueRaw, err := json.Marshal(e.Value)
		if err != nil {
			return []byte{}, err
		}
		b.Write(valueRaw)
		idx++
	}

	b.WriteString("}")

	return b.Bytes(), nil
}

func (m *Map[K, V]) UnmarshalJSON(b []byte) error {
	d := jsontext.NewDecoder(bytes.NewReader(b))

	t, err := d.ReadToken()
	if err != nil {
		return err
	}

	if t.Kind() != '{' {
		return errors.New("object should starts with `{`")
	}

	for kind := d.PeekKind(); kind != '}'; kind = d.PeekKind() {
		k, err := d.ReadValue()
		if err != nil {
			return err
		}
		key := new(K)

		if err := json.Unmarshal(k, key); err != nil {
			return err
		}

		v, err := d.ReadValue()
		if err != nil {
			return err
		}
		value := new(V)
		if err := json.Unmarshal(v, value); err != nil {
			return err
		}
		m.Set(*key, *value)
	}

	return nil
}

type Element[K comparable, V any] struct {
	Key   K
	Value V

	next, prev *Element[K, V]
}

func (e *Element[K, V]) Next() *Element[K, V] {
	return e.next
}

func (e *Element[K, V]) Prev() *Element[K, V] {
	return e.prev
}

type list[K comparable, V any] struct {
	root Element[K, V]
}

func (l *list[K, V]) IsEmpty() bool {
	return l.root.next == nil
}

// Front returns the first element of list l or nil if the list is empty.
func (l *list[K, V]) Front() *Element[K, V] {
	return l.root.next
}

// Back returns the last element of list l or nil if the list is empty.
func (l *list[K, V]) Back() *Element[K, V] {
	return l.root.prev
}

// Remove removes e from its list
func (l *list[K, V]) Remove(e *Element[K, V]) {
	if e.prev == nil {
		l.root.next = e.next
	} else {
		e.prev.next = e.next
	}
	if e.next == nil {
		l.root.prev = e.prev
	} else {
		e.next.prev = e.prev
	}
	e.next = nil // avoid memory leaks
	e.prev = nil // avoid memory leaks
}

// PushFront inserts a new element e with value v at the front of list l and returns e.
func (l *list[K, V]) PushFront(key K, value V) *Element[K, V] {
	e := &Element[K, V]{Key: key, Value: value}
	if l.root.next == nil {
		// It's the first element
		l.root.next = e
		l.root.prev = e
		return e
	}

	e.next = l.root.next
	l.root.next.prev = e
	l.root.next = e
	return e
}

// PushBack inserts a new element e with value v at the back of list l and returns e.
func (l *list[K, V]) PushBack(key K, value V) *Element[K, V] {
	e := &Element[K, V]{Key: key, Value: value}
	if l.root.prev == nil {
		// It's the first element
		l.root.next = e
		l.root.prev = e
		return e
	}

	e.prev = l.root.prev
	l.root.prev.next = e
	l.root.prev = e
	return e
}
