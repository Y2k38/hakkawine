init:
	mix deps.get
	mix assets.setup
	mix deps.compile
	ecto.create

fmt:
	mix format

check-fmt:
	mix format --check-formatted

run:
	mix phx.server