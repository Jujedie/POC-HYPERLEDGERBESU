usage() {
  echo "Usage: $0 <container-name|\"Prometheus\"> "
  echo "  <container-name> : Name of the Docker container to check size"
  echo "  --help : Show this help message"
  exit 0
}
# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
	--help)
	  usage
	  exit 0
	  ;;
	*)
	  break
	  ;;
  esac
done

if [[ $# -ne 1 ]]; then
  CONTAINER_NAME="prometheus"
else
  CONTAINER_NAME="$1"
fi
printf "Container name: %s\n" "$CONTAINER_NAME"

docker inspect --size "$CONTAINER_NAME" --format='{{.SizeRootFs}}' 2>/dev/null | awk '{print $1}' | sed 's/[^0-9]*//g' | awk '{printf "%.2f GB\n", $1 / 1024 / 1024 / 1024}'