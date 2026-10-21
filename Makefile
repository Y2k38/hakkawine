.PHONY: init fmt check-fmt run release

init:
	mix deps.get
	mix assets.setup
	mix deps.compile
	mix ecto.setup

fmt:
	mix format

check-fmt:
	mix format --check-formatted

run:
	mix phx.server

release:
	MIX_ENV=prod mix clean
	MIX_ENV=prod mix assets.deploy
	MIX_ENV=prod mix release --overwrite
