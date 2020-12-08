SUB_PROJECTS=builder installer parser .

compile: dep
	@for dir in $(SUB_PROJECTS); do cd $${dir} && mix compile && cd ..; done

dep:
	@for dir in $(SUB_PROJECTS); do cd $${dir} && mix deps.get && cd ..; done


test: dep
	@for dir in $(SUB_PROJECTS); do cd $${dir} && mix test && cd ..; done

credo:
	@for dir in $(SUB_PROJECTS); do cd $${dir} && mix credo && cd ..; done

update-dep:
	@for dir in $(SUB_PROJECTS); do cd $${dir} && rm mix.lock && mix deps.get && cd ..; done

test-all: dep credo test

install:
	@cd installer; rm quenya_installer* && mix archive.install --force

.PHONY: compile dep test install
