layout_npm() {
	strict_env
	dotenv_if_exists .env 2>/dev/null
	layout node
}
