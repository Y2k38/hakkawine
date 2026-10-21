.PHONY: init fmt check-fmt run release

init:
	mix deps.get
	mix deps.compile
	mix ua_inspector.download
	mix assets.setup
	mix ecto.setup

fmt:
	mix format

check-fmt:
	mix format --check-formatted

run:
	mix phx.server

release:
	MIX_ENV=prod mix deps.get --only prod
	MIX_ENV=prod mix deps.compile
	MIX_ENV=prod mix assets.deploy
	MIX_ENV=prod mix release --overwrite
