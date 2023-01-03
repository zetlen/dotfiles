layout_npm() {
	strict_env
	use asdf 2>/dev/null
	dotenv_if_exists .env 2>/dev/null
	layout node
}
