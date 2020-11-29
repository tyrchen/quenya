compile: dep
	@cd installer; mix compile
	@cd builder; mix compile
	@mix compile

dep:
	@cd installer; mix deps.get
	@cd builder; mix deps.get
	@mix deps.get

test:
	@cd installer; mix test
	@cd builder; mix test
	@mix test

install:
	@cd installer; rm quenya_installer* && mix archive.install --force

.PHONY: compile dep test install
