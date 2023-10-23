package collection

import (
	"context"
	"sort"
)

func SortedIter[T any](ctx context.Context, values map[string]T) <-chan T {
	names := make([]string, 0, len(values))
	for name := range values {
		names = append(names, name)
	}
	sort.Strings(names)

	ch := make(chan T)

	go func() {
		defer func() {
			close(ch)
		}()

		for _, n := range names {
			select {
			case <-ctx.Done():
				return
			case ch <- values[n]:
			}
		}
	}()

	return ch
}
