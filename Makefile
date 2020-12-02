compile: dep
	@cd installer; mix compile
	@cd builder; mix compile
	@mix compile

dep:
	@cd installer; mix deps.get
	@cd builder; mix deps.get
	@mix deps.get

test: dep
	@cd installer; mix test
	@cd builder; mix test
	@mix test

credo:
	@cd installer; mix credo
	@cd builder; mix credo
	@mix credo

update-dep:
	@cd installer; rm mix.lock; mix deps.get
	@cd builder; rm mix.lock; mix deps.get
	@rm mix.lock; mix deps.get
test-all: dep credo test

install:
	@cd installer; rm quenya_installer* && mix archive.install --force

.PHONY: compile dep test install
