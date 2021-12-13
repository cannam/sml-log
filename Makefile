
example:	example.mlb log.mlb log.sig log.sml example.sml category-log-fn.sml
	mlton example.mlb
	./example

clean:
	rm -f example
