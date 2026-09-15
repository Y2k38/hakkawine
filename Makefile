init:
	mix deps.get
	mix assets.setup
	mix deps.compile
	ecto.create

run:
	mix phx.server