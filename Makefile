
example:	example.mlb log.mlb log.sig log.sml example.sml
	mlton example.mlb
	./example

clean:
	rm -f example
